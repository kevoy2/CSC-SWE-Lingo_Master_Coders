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

-- User profiles table
CREATE TABLE "user_profiles" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "auth_id" UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "dob" DATE NOT NULL,
    "age" INT,
    "email" TEXT UNIQUE NOT NULL,
    "language" VARCHAR(50) REFERENCES languages(code),
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Chat history table
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

-- Favorite phrases table
CREATE TABLE "favorite_phrases" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "user_id" UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    "translation_id" UUID REFERENCES chat_history(id) ON DELETE CASCADE,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Emergency phrases table
CREATE TABLE "emergency_phrases" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "translation_id" UUID REFERENCES chat_history(id) ON DELETE CASCADE,
    "emergency" BOOLEAN DEFAULT false,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Support tickets table
CREATE TABLE "support_tickets" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "user_id" UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    "subject" VARCHAR(255) NOT NULL,
    "description" TEXT NOT NULL,
    "status" VARCHAR(50) DEFAULT 'Pending',
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Video conferences table
CREATE TABLE "video_conferences" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "user_id" UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    "origin_lang_code" VARCHAR(50) REFERENCES languages(code),
    "target_lang_code" VARCHAR(50) REFERENCES languages(code),
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User settings table
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

-- Enable RLS on all tables
ALTER TABLE languages ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorite_phrases ENABLE ROW LEVEL SECURITY;
ALTER TABLE emergency_phrases ENABLE ROW LEVEL SECURITY;
ALTER TABLE support_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE video_conferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

-- RLS Policies for languages
CREATE POLICY "Allow public read access to languages"
    ON languages FOR SELECT
    TO authenticated, anon
    USING (true);

CREATE POLICY "Allow admin language management"
    ON languages
    TO authenticated
    USING (auth.jwt() ->> 'email' IN (SELECT email FROM auth.users WHERE role = 'admin'))
    WITH CHECK (auth.jwt() ->> 'email' IN (SELECT email FROM auth.users WHERE role = 'admin'));

-- RLS Policies for user_profiles
CREATE POLICY "Users can view own profile"
    ON user_profiles FOR SELECT
    TO authenticated
    USING (auth_id = auth.uid() OR 
          auth.jwt() ->> 'email' IN (SELECT email FROM auth.users WHERE role = 'admin'));

CREATE POLICY "Users can create own profile"
    ON user_profiles FOR INSERT
    TO authenticated
    WITH CHECK (auth_id = auth.uid());

CREATE POLICY "Users can update own profile"
    ON user_profiles FOR UPDATE
    TO authenticated
    USING (auth_id = auth.uid())
    WITH CHECK (auth_id = auth.uid());

-- RLS Policies for chat_history
CREATE POLICY "Users can view own chat history"
    ON chat_history FOR SELECT
    TO authenticated
    USING (user_id IN (SELECT id FROM user_profiles WHERE auth_id = auth.uid()));

CREATE POLICY "Users can create own chat history"
    ON chat_history FOR INSERT
    TO authenticated
    WITH CHECK (user_id IN (SELECT id FROM user_profiles WHERE auth_id = auth.uid()));

CREATE POLICY "Users can update own chat history"
    ON chat_history FOR UPDATE
    TO authenticated
    USING (user_id IN (SELECT id FROM user_profiles WHERE auth_id = auth.uid()));

-- RLS Policies for favorite_phrases
CREATE POLICY "Users can manage own favorite phrases"
    ON favorite_phrases
    TO authenticated
    USING (user_id IN (SELECT id FROM user_profiles WHERE auth_id = auth.uid()))
    WITH CHECK (user_id IN (SELECT id FROM user_profiles WHERE auth_id = auth.uid()));

-- RLS Policies for emergency_phrases
CREATE POLICY "Public can view emergency phrases"
    ON emergency_phrases FOR SELECT
    TO authenticated, anon
    USING (true);

CREATE POLICY "Admin can manage emergency phrases"
    ON emergency_phrases
    TO authenticated
    USING (auth.jwt() ->> 'email' IN (SELECT email FROM auth.users WHERE role = 'admin'))
    WITH CHECK (auth.jwt() ->> 'email' IN (SELECT email FROM auth.users WHERE role = 'admin'));

-- RLS Policies for support_tickets
CREATE POLICY "Users can view own tickets"
    ON support_tickets FOR SELECT
    TO authenticated
    USING (user_id IN (SELECT id FROM user_profiles WHERE auth_id = auth.uid()) OR 
          auth.jwt() ->> 'email' IN (SELECT email FROM auth.users WHERE role = 'admin'));

CREATE POLICY "Users can create tickets"
    ON support_tickets FOR INSERT
    TO authenticated
    WITH CHECK (user_id IN (SELECT id FROM user_profiles WHERE auth_id = auth.uid()));

CREATE POLICY "Users and admins can update tickets"
    ON support_tickets FOR UPDATE
    TO authenticated
    USING (user_id IN (SELECT id FROM user_profiles WHERE auth_id = auth.uid()) OR 
          auth.jwt() ->> 'email' IN (SELECT email FROM auth.users WHERE role = 'admin'));

-- RLS Policies for video_conferences
CREATE POLICY "Users can manage own conferences"
    ON video_conferences
    TO authenticated
    USING (user_id IN (SELECT id FROM user_profiles WHERE auth_id = auth.uid()))
    WITH CHECK (user_id IN (SELECT id FROM user_profiles WHERE auth_id = auth.uid()));

-- RLS Policies for user_settings
CREATE POLICY "Users can manage own settings"
    ON user_settings
    TO authenticated
    USING (user_id IN (SELECT id FROM user_profiles WHERE auth_id = auth.uid()))
    WITH CHECK (user_id IN (SELECT id FROM user_profiles WHERE auth_id = auth.uid()));

-- Create indexes for better performance
CREATE INDEX idx_user_profiles_auth_id ON user_profiles(auth_id);
CREATE INDEX idx_user_profiles_email ON user_profiles(email);
CREATE INDEX idx_chat_history_user_id ON chat_history(user_id);
CREATE INDEX idx_favorite_phrases_user_id ON favorite_phrases(user_id);
CREATE INDEX idx_support_tickets_user_id ON support_tickets(user_id);
CREATE INDEX idx_video_conferences_user_id ON video_conferences(user_id);
CREATE INDEX idx_user_settings_user_id ON user_settings(user_id);

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
    ('uk', 'Ukrainian')
;