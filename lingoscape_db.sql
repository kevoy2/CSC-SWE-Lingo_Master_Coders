
-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create updated_at function for all tables
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Languages table
CREATE TABLE "languages" (
    "code" VARCHAR(50) PRIMARY KEY,
    "name" VARCHAR(100) NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User profiles table for registration
CREATE TABLE "user_profiles" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "dob" DATE NOT NULL,
    "age" INT,
    "email" TEXT UNIQUE NOT NULL,
    "password" TEXT NOT NULL,
    "language" VARCHAR(50) REFERENCES languages(code),
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Modify user_profiles table
ALTER TABLE user_profiles
ADD COLUMN auth_id UUID,
ADD COLUMN email_verified BOOLEAN DEFAULT FALSE;

-- Users table for authentication
CREATE TABLE "users" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "profile_id" UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    "email" TEXT UNIQUE NOT NULL,
    "password" TEXT NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE "users"
ADD COLUMN auth_id UUID;

-- Create trigger to automatically create users entry after user_profiles
CREATE OR REPLACE FUNCTION create_user_after_profile()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO users (profile_id, email, password, auth_id)
    VALUES (NEW.id, NEW.email, NEW.password, NEW.auth_id); 
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER create_user_trigger
    AFTER INSERT ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION create_user_after_profile();

-- Rest of the tables with updated references
CREATE TABLE "chat_history" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "user_id" UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    "origin_lang_code" VARCHAR(50) REFERENCES languages(code),
    "target_lang_code" VARCHAR(50) REFERENCES languages(code),
    "source_text" TEXT NOT NULL,
    "target_text" TEXT NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "favorite_phrases" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "user_id" UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    "translation_id" UUID REFERENCES chat_history(id) ON DELETE CASCADE,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "emergency_phrases" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "translation_id" UUID REFERENCES chat_history(id) ON DELETE CASCADE,
    "emergency" BOOLEAN DEFAULT false,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "support_tickets" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "user_id" UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    "subject" VARCHAR(255) NOT NULL,
    "description" TEXT NOT NULL,
    "status" VARCHAR(50) DEFAULT 'Pending',
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "video_conferences" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "user_id" UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    "origin_lang_code" VARCHAR(50) REFERENCES languages(code),
    "target_lang_code" VARCHAR(50) REFERENCES languages(code),
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "user_settings" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "user_id" UUID REFERENCES user_profiles(id) ON DELETE CASCADE UNIQUE,
    "theme" BOOLEAN DEFAULT false,
    "ui_language" VARCHAR(50) REFERENCES languages(code),
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create triggers for updated_at
CREATE TRIGGER update_languages_updated_at
    BEFORE UPDATE ON languages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chat_history_updated_at
    BEFORE UPDATE ON chat_history
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_favorite_phrases_updated_at
    BEFORE UPDATE ON favorite_phrases
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_emergency_phrases_updated_at
    BEFORE UPDATE ON emergency_phrases
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_support_tickets_updated_at
    BEFORE UPDATE ON support_tickets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_video_conferences_updated_at
    BEFORE UPDATE ON video_conferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_settings_updated_at
    BEFORE UPDATE ON user_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- First, enable RLS on all tables
ALTER TABLE languages ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorite_phrases ENABLE ROW LEVEL SECURITY;
ALTER TABLE emergency_phrases ENABLE ROW LEVEL SECURITY;
ALTER TABLE support_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE video_conferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

-- define role of users
ALTER TABLE users ADD COLUMN role VARCHAR(50) DEFAULT 'user';

-- User profiles policies
CREATE POLICY "Profiles are insertable by anyone"
    ON user_profiles 
    FOR INSERT 
    TO public 
    WITH CHECK (true);

-- CREATE POLICY "Profiles are viewable by authenticated users"
--     ON user_profiles 
--     FOR SELECT 
--     TO public 
--     USING (true);

-- Update the policies for email verification
CREATE POLICY "Profiles are viewable by verified users"
    ON user_profiles 
    FOR SELECT 
    TO public 
    USING (
        email_verified = TRUE 
        OR 
        EXISTS (
            SELECT 1 
            FROM users 
            WHERE profile_id = user_profiles.id 
            AND email = current_user
        )
    );

CREATE POLICY "Profiles are updatable by owner"
    ON user_profiles 
    FOR UPDATE 
    TO public 
    USING (
        EXISTS (
            SELECT 1 
            FROM users 
            WHERE profile_id = user_profiles.id 
            AND email = current_user
        )
    );

CREATE POLICY "Profiles are deletable by owner"
    ON user_profiles 
    FOR DELETE 
    TO public 
    USING (
        EXISTS (
            SELECT 1 
            FROM users 
            WHERE profile_id = user_profiles.id 
            AND email = current_user
        )
    );

-- Users table policies
CREATE POLICY "Users are insertable by anyone"
    ON users 
    FOR INSERT 
    TO public 
    WITH CHECK (true);

CREATE POLICY "Users are viewable by owner"
    ON users 
    FOR SELECT 
    TO public 
    USING (email = current_user);

CREATE POLICY "Users are updatable by owner"
    ON users 
    FOR UPDATE 
    TO public 
    USING (email = current_user)
    WITH CHECK (email = current_user);

CREATE POLICY "Users are deletable by owner"
    ON users 
    FOR DELETE 
    TO public 
    USING (email = current_user);

-- Languages table policies
CREATE POLICY "Languages are publicly readable"
    ON languages FOR SELECT
    TO public
    USING (true);

-- CREATE POLICY "Only admins can modify languages"
--     ON languages FOR ALL
--     TO authenticated
--     USING (email IN (SELECT email FROM users WHERE role = 'admin'))
--     WITH CHECK (email IN (SELECT email FROM users WHERE role = 'admin'));

-- Chat history policies
CREATE POLICY "Chat history viewable by anyone"
    ON chat_history 
    FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Chat history insertable by anyone"
    ON chat_history
    FOR INSERT 
    TO public
    WITH CHECK (true);

CREATE POLICY "Chat history updatable by anyone"
    ON chat_history 
    FOR UPDATE
    TO public
    USING (true);

-- Favorite phrases policies
CREATE POLICY "Favorite phrases viewable by anyone"
    ON favorite_phrases 
    FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Favorite phrases insertable by anyone"
    ON favorite_phrases
    FOR INSERT 
    TO public
    WITH CHECK (true);

CREATE POLICY "Favorite phrases updatable by anyone"
    ON favorite_phrases 
    FOR UPDATE
    TO public
    USING (true);

CREATE POLICY "Favorite phrases deletable by anyone"
    ON favorite_phrases 
    FOR DELETE
    TO public
    USING (true);

-- Emergency phrases policies
CREATE POLICY "Emergency phrases are publicly readable"
    ON emergency_phrases FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Emergency phrases manageable by admins"
    ON emergency_phrases
    FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE email = current_user 
            AND role = 'admin'
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users 
            WHERE email = current_user 
            AND role = 'admin'
        )
    );

-- Support tickets policies
CREATE POLICY "Tickets viewable by owner and admin"
    ON support_tickets FOR SELECT
    TO public
    USING (
        user_id IN (
            SELECT id 
            FROM user_profiles 
            WHERE id IN (
                SELECT profile_id 
                FROM users 
                WHERE email = current_user
            )
        )
        OR
        EXISTS (
            SELECT 1 FROM users 
            WHERE email = current_user 
            AND role = 'admin'
        )
    );

CREATE POLICY "Tickets insertable by authenticated users"
    ON support_tickets FOR INSERT
    TO public
    WITH CHECK (
        user_id IN (
            SELECT id 
            FROM user_profiles 
            WHERE id IN (
                SELECT profile_id 
                FROM users 
                WHERE email = current_user
            )
        )
    );

CREATE POLICY "Tickets updatable by owner and admin"
    ON support_tickets FOR UPDATE
    TO public
    USING (
        user_id IN (
            SELECT id 
            FROM user_profiles 
            WHERE id IN (
                SELECT profile_id 
                FROM users 
                WHERE email = current_user
            )
        )
        OR
        EXISTS (
            SELECT 1 FROM users 
            WHERE email = current_user 
            AND role = 'admin'
        )
    );

-- Video conferences policies
CREATE POLICY "Conferences manageable by owner"
    ON video_conferences
    FOR ALL
    TO public
    USING (
        user_id IN (
            SELECT id 
            FROM user_profiles 
            WHERE id IN (
                SELECT profile_id 
                FROM users 
                WHERE email = current_user
            )
        )
    )
    WITH CHECK (
        user_id IN (
            SELECT id 
            FROM user_profiles 
            WHERE id IN (
                SELECT profile_id 
                FROM users 
                WHERE email = current_user
            )
        )
    );

-- User settings policies
CREATE POLICY "Settings manageable by owner"
    ON user_settings
    FOR ALL
    TO public
    USING (
        user_id IN (
            SELECT id 
            FROM user_profiles 
            WHERE id IN (
                SELECT profile_id 
                FROM users 
                WHERE email = current_user
            )
        )
    )
    WITH CHECK (
        user_id IN (
            SELECT id 
            FROM user_profiles 
            WHERE id IN (
                SELECT profile_id 
                FROM users 
                WHERE email = current_user
            )
        )
    );

-- Initial language data
INSERT INTO languages (code, name)
VALUES
    ('en', 'English'),
    ('es', 'Spanish'),
    ('fr', 'French'),
    ('zh', 'Chinese Simplified'),
    ('ar', 'Arabic'),
    ('ru', 'Russian'),
    ('de', 'German'),
    ('pt', 'Portuguese'),
    ('hi', 'Hindi'),
    ('ja', 'Japanese'),
    ('ko', 'Korean'),
    ('it', 'Italian'),
    ('nl', 'Dutch'),
    ('tr', 'Turkish'),
    ('uk', 'Ukrainian');

-- Create indexes for better performance
CREATE INDEX idx_users_profile_id ON users(profile_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_user_profiles_email ON user_profiles(email);
CREATE INDEX idx_chat_history_user_id ON chat_history(user_id);
CREATE INDEX idx_favorite_phrases_user_id ON favorite_phrases(user_id);
CREATE INDEX idx_support_tickets_user_id ON support_tickets(user_id);
CREATE INDEX idx_video_conferences_user_id ON video_conferences(user_id);
CREATE INDEX idx_user_settings_user_id ON user_settings(user_id);

-- Add index for auth_id
CREATE INDEX idx_user_profiles_auth_id ON user_profiles(auth_id);
CREATE INDEX idx_users_auth_id ON users(auth_id);
