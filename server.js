const express = require('express');
const { Pool } = require('pg');
const bcrypt = require('bcrypt');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors());

const pool = new Pool({
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    database: process.env.DB_NAME,
});

// Registration endpoint
app.post('/register', async (req, res) => {
    console.log('Received registration data:', req.body);
    const { firstName, middleInitial, familyName, dob, email, password, language } = req.body;
    
    try {
        // Hash the password
        const passwordstr = String(password);
        const hashedPassword = await bcrypt.hash(passwordstr, 10);
        
        // Calculate age
        const birthDate = new Date(dob);
        const today = new Date();
        let age = today.getFullYear() - birthDate.getFullYear();
        const m = today.getMonth() - birthDate.getMonth();
        if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
            age--;
        }

        // Insert into user_profiles
        const profileResult = await pool.query(
            'INSERT INTO user_profiles (first_name, middle_initial, family_name, dob, age, email, password, language) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING profile_id',
            [firstName, middleInitial, familyName, dob, age, email, hashedPassword, language]
        );

        const profileId = profileResult.rows[0].profile_id;

        // Insert into users table (previously misnamed as user_login)
        await pool.query(
            'INSERT INTO users (profile_id, email, password) VALUES ($1, $2, $3)',
            [profileId, email, hashedPassword]
        );

        res.status(201).json({ message: 'User registered successfully' });
    } catch (error) {
        console.error('Detailed error:', error);
        res.status(500).json({ message: 'Error registering user', error: error.message });
    }
});

// Login endpoint
app.post('/login', async (req, res) => {
    const { email, password } = req.body;

    try {
        const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
        
        if (result.rows.length > 0) {
            const user = result.rows[0];
            const passwordString = String(password);
            const isMatch = await bcrypt.compare(passwordString, user.password);
            
            if (isMatch) {
                res.json({ message: 'Login successful', profileId: user.profile_id });
            } else {
                res.status(400).json({ message: 'Invalid credentials' });
            }
        } else {
            res.status(400).json({ message: 'User not found' });
        }
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ message: 'Error logging in', error: error.message });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));