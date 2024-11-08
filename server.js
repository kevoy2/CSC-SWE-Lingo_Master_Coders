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
const supabaseServiceRole = process.env.SERVICE_ROLE_KEY;

// Create two clients - one for normal operations and one with service role
const supabase = createClient(supabaseUrl, supabaseAnonKey);
const serviceClient = createClient(supabaseUrl, supabaseServiceRole);

// Registration endpoint
app.post('/register', async (req, res) => {
    console.log('Received registration data:', req.body);
    const { firstName, lastName, dob, email, password, language } = req.body;
    
    try {
        // Using auth.signUp() for the standard client
        const { data: authData, error: authError } = await supabase.auth.signUp({
            email: email,
            password: password,
            options: {
                data: {
                    first_name: firstName,
                    last_name: lastName
                },
                emailRedirectTo: `${process.env.APP_URL}/auth/callback`
            }
        });

        if (authError) {
            throw authError;
        }

        // Create user profile
        const hashedPassword = await bcrypt.hash(String(password), 10);
        const birthDate = new Date(dob);
        const today = new Date();
        let age = today.getFullYear() - birthDate.getFullYear();
        const m = today.getMonth() - birthDate.getMonth();
        if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
            age--;
        }

        // Use service client for database operations
        const { data: profileData, error: profileError } = await serviceClient
            .from('user_profiles')
            .insert({
                first_name: firstName,
                last_name: lastName,
                dob: dob,
                age: age,
                email: email,
                password: hashedPassword,
                language: language,
                auth_id: authData.user.id,
                email_verified: false
            })
            .select();

        if (profileError) {
            // If profile creation fails, delete the auth user using admin API
            await serviceClient.auth.admin.deleteUser(authData.user.id);
            throw profileError;
        }

        res.status(201).json({ 
            message: 'Registration initiated. Please check your email to verify your account.',
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

// Verification callback endpoint
app.get('/auth/callback', async (req, res) => {
    // Get the token from query parameters
    const { token, type } = req.query;
    
    if (!token) {
        console.error('No token provided in callback');
        return res.redirect(`${process.env.APP_URL}/login?error=no_token`);
    }

    try {
        // Exchange the token
        const { data, error } = await serviceClient.auth.verifyOtp({
            token: token,
            type: 'signup'
        });

        if (error) {
            console.error('Token verification error:', error);
            throw error;
        }

        if (data.user) {
            // Update user profile email_verified status
            const { error: updateError } = await serviceClient
                .from('user_profiles')
                .update({ email_verified: true })
                .eq('auth_id', data.user.id);

            if (updateError) {
                console.error('Profile update error:', updateError);
                throw updateError;
            }

            // Successful verification
            return res.redirect(`${process.env.APP_URL}/login?verified=true`);
        } else {
            throw new Error('No user data received after verification');
        }

    } catch (error) {
        console.error('Verification error:', error);
        return res.redirect(`${process.env.APP_URL}/login?error=verification_failed`);
    }
});

// Updated login endpoint to properly check verification
app.post('/login', async (req, res) => {
    const { email, password } = req.body;

    try {
        // First authenticate with Supabase Auth
        const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
            email: email,
            password: password
        });

        if (authError) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        // Check if email is confirmed in auth
        if (!authData.user.email_confirmed_at) {
            return res.status(403).json({ 
                message: 'Please verify your email before logging in.',
                needsVerification: true
            });
        }

        // Get the user profile
        const { data: profileData, error: profileError } = await serviceClient
            .from('user_profiles')
            .select(`
                id,
                first_name,
                last_name,
                email,
                language,
                email_verified
            `)
            .eq('auth_id', authData.user.id)
            .single();

        if (profileError) {
            console.error('Profile fetch error:', profileError);
            return res.status(400).json({ message: 'User profile not found' });
        }

        // If auth is confirmed but profile isn't marked as verified, update it
        if (!profileData.email_verified) {
            const { error: updateError } = await serviceClient
                .from('user_profiles')
                .update({ email_verified: true })
                .eq('id', profileData.id);

            if (updateError) {
                console.error('Error updating profile verification status:', updateError);
            }
        }

        res.json({ 
            message: 'Login successful',
            profile: profileData,
            session: authData.session
        });

    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ 
            message: 'Error logging in', 
            error: error.message 
        });
    }
});

// endpoint to resend verification email if needed
app.post('/resend-verification', async (req, res) => {
    const { email } = req.body;

    try {
        const { data, error } = await supabase.auth.resend({
            type: 'signup',
            email: email,
            options: {
                emailRedirectTo: `${process.env.APP_URL}/auth/callback`
            }
        });

        if (error) throw error;

        res.json({ 
            message: 'Verification email resent. Please check your inbox.' 
        });

    } catch (error) {
        console.error('Error resending verification:', error);
        res.status(500).json({ 
            message: 'Error resending verification email', 
            error: error.message 
        });
    }
});


// Chat History endpoint 
app.post('/save-translation', async (req, res) => {
    const { userId, originLangCode, targetLangCode, sourceText, targetText } = req.body;
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
        return res.status(401).json({
            message: 'No authorization header'
        });
    }

    const token = authHeader.replace('Bearer ', '');

    try {
        // Verify the session
        const { data: { user }, error: authError } = await supabase.auth.getUser(token);
        
        if (authError) {
            throw authError;
        }

        // Use service client for database operation
        const { data, error } = await serviceClient
            .from('chat_history')
            .insert({
                user_id: userId,
                origin_lang_code: originLangCode,
                target_lang_code: targetLangCode,
                source_text: sourceText,
                target_text: targetText
            })
            .select();

        if (error) throw error;

        res.status(201).json({
            message: 'Translation saved successfully',
            translation: data[0]
        });
    } catch (error) {
        console.error('Error saving translation:', error);
        res.status(500).json({
            message: 'Error saving translation',
            error: error.message
        });
    }
});


// Favorite Phrase endpoint
app.post('/save-favorite', async (req, res) => {
    const { userId, translationId } = req.body;
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
        return res.status(401).json({
            message: 'No authorization header'
        });
    }

    const token = authHeader.replace('Bearer ', '');

    try {
        // Verify the session
        const { data: { user }, error: authError } = await supabase.auth.getUser(token);
        
        if (authError) {
            throw authError;
        }

        // Use service client for database operation
        const { data, error } = await serviceClient
            .from('favorite_phrases')
            .insert({
                user_id: userId,
                translation_id: translationId
            })
            .select();

        if (error) throw error;

        res.status(201).json({
            message: 'Translation saved to favorites successfully',
            favorite: data[0]
        });
    } catch (error) {
        console.error('Error saving favorite:', error);
        res.status(500).json({
            message: 'Error saving to favorites',
            error: error.message
        });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));