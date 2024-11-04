const { createClient } = require('@supabase/supabase-js');
const express = require('express');
const bcrypt = require('bcrypt');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors());

// Supabase client initialization
const supabaseUrl = process.env.DB_URL;
const supabaseAnonKey = process.env.DB_API;
const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Registration endpoint
app.post('/register', async (req, res) => {
    console.log('Received registration data:', req.body);
    const { firstName, lastName, dob, email, password, language } = req.body;
    
    try {
        // Hash the password
        const passwordStr = String(password);
        const hashedPassword = await bcrypt.hash(passwordStr, 10);
        
        // Calculate age
        const birthDate = new Date(dob);
        const today = new Date();
        let age = today.getFullYear() - birthDate.getFullYear();
        const m = today.getMonth() - birthDate.getMonth();
        if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
            age--;
        }

        // Create user profile with all necessary data
        const { data: profileData, error: profileError } = await supabase
            .from('user_profiles')
            .insert({
                first_name: firstName,
                last_name: lastName,
                dob: dob,
                age: age,
                email: email,
                password: hashedPassword,
                language: language
            })
            .select();

        if (profileError) {
            throw profileError;
        }

        // The users table entry will be automatically created by the trigger
        // No need to manually insert into the users table

        res.status(201).json({ 
            message: 'User registered successfully',
            profile: profileData[0]
        });

    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({ 
            message: 'Error registering user', 
            error: error.message 
        });
    }
});

// Login endpoint
app.post('/login', async (req, res) => {
    const { email, password } = req.body;

    try {
        // Get the user profile with its associated user data
        const { data: profileData, error: profileError } = await supabase
            .from('user_profiles')
            .select(`
                id,
                first_name,
                last_name,
                email,
                password,
                language
            `)
            .eq('email', email)
            .single();

        if (profileError) {
            console.error('Profile fetch error:', profileError);
            return res.status(400).json({ message: 'User not found' });
        }

        if (!profileData) {
            return res.status(400).json({ message: 'User not found' });
        }

        // Compare passwords
        const isMatch = await bcrypt.compare(String(password), profileData.password);
        
        if (isMatch) {
            // Return user data without the password
            const { password: _, ...userDataWithoutPassword } = profileData;
            
            res.json({ 
                message: 'Login successful',
                profile: userDataWithoutPassword
            });
        } else {
            res.status(400).json({ message: 'Invalid credentials' });
        }
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ 
            message: 'Error logging in', 
            error: error.message 
        });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));