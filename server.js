const { createClient } = require('@supabase/supabase-js');
const express = require('express');
const bcrypt = require('bcrypt');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors());

// Get your Supabase connection details from environment variables
const supabaseUrl = process.env.DB_URL;
const supabaseAnonKey = process.env.DB_API;
const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Necessary functions
async function insertProfile(table, pattern) {
    try {
        const { data, error } = await supabase
            .from(table)
            .insert(pattern);

        if (error) {
            throw error;
        }

        console.log('User inserted:', data);
    } catch (error) {
        console.error('Error inserting user:', error);
    }
}

async function insertUser(table, email, password, match) {
    try {
        let fk = await fetchValue('user_profiles', 'id', match);
        console.log('FK recieved:', fk[0].id);
        const { data, error } = await supabase
            .from(table)
            .insert({ email: email, password: password, profile_id: fk[0].id });
        if (error) {
            throw error;
        }

        console.log('User inserted:', data);
    } catch (error) {
        console.error('Error inserting user:', error);
    }
}

async function fetchValue(table, target, match) {
    try {
        const { data, error } = await supabase
            .from(table)
            .select(target)
            .match(match);
        if (error) {
            throw error;
        }
        console.log('FK fetched:', data);
        return data;
    } catch (error) {
        console.error('Error inserting user:', error);
    }
}

// Registration endpoint
app.post('/register', async (req, res) => {
    console.log('Received registration data:', req.body);
    const { firstName, lastName, dob, email, password, language } = req.body;
    
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

        // Initialize pattern
        let pattern = { first_name: firstName, last_name: lastName, dob: dob, age: age, email: email, password: hashedPassword, language: language };

        // Insert user profile into user_profiles table
        await insertProfile('user_profiles', pattern);
        // Insert user into users table
        await insertUser('users', email, hashedPassword, pattern);

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
        const result = await fetchValue('users', '', { email: email });
        
        if (result.length > 0) {
            const user = result[0];
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