-- First, drop all existing policies
DROP POLICY IF EXISTS "Profiles are insertable by anyone" ON user_profiles;
DROP POLICY IF EXISTS "Profiles are viewable by verified users" ON user_profiles;
DROP POLICY IF EXISTS "Profiles are updatable by owner" ON user_profiles;
DROP POLICY IF EXISTS "Profiles are deletable by owner" ON user_profiles;
DROP POLICY IF EXISTS "Users are insertable by anyone" ON users;
DROP POLICY IF EXISTS "Users are viewable by owner" ON users;
DROP POLICY IF EXISTS "Users are updatable by owner" ON users;
DROP POLICY IF EXISTS "Users are deletable by owner" ON users;
DROP POLICY IF EXISTS "Languages are publicly readable" ON languages;
DROP POLICY IF EXISTS "Chat history viewable by anyone" ON chat_history;
DROP POLICY IF EXISTS "Chat history insertable by anyone" ON chat_history;
DROP POLICY IF EXISTS "Chat history updatable by anyone" ON chat_history;
DROP POLICY IF EXISTS "Favorite phrases viewable by anyone" ON favorite_phrases;
DROP POLICY IF EXISTS "Favorite phrases insertable by anyone" ON favorite_phrases;
DROP POLICY IF EXISTS "Favorite phrases updatable by anyone" ON favorite_phrases;
DROP POLICY IF EXISTS "Favorite phrases deletable by anyone" ON favorite_phrases;
DROP POLICY IF EXISTS "Emergency phrases are publicly readable" ON emergency_phrases;
DROP POLICY IF EXISTS "Emergency phrases manageable by admins" ON emergency_phrases;
DROP POLICY IF EXISTS "Tickets viewable by owner and admin" ON support_tickets;
DROP POLICY IF EXISTS "Tickets insertable by authenticated users" ON support_tickets;
DROP POLICY IF EXISTS "Tickets updatable by owner and admin" ON support_tickets;
DROP POLICY IF EXISTS "Conferences manageable by owner" ON video_conferences;
DROP POLICY IF EXISTS "Settings manageable by owner" ON user_settings;

-- Create new policies for user_profiles
CREATE POLICY "Enable insert for registration" ON user_profiles
    FOR INSERT TO authenticated, anon
    WITH CHECK (true);

CREATE POLICY "Enable select for authenticated users" ON user_profiles
    FOR SELECT TO authenticated, anon
    USING (
        auth_id = auth.uid() OR
        email_verified = true OR
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE id = auth.uid() AND role = 'service_role'
        )
    );

CREATE POLICY "Enable update for own profile" ON user_profiles
    FOR UPDATE TO authenticated
    USING (auth_id = auth.uid())
    WITH CHECK (auth_id = auth.uid());

CREATE POLICY "Enable delete for own profile" ON user_profiles
    FOR DELETE TO authenticated
    USING (auth_id = auth.uid());

-- Users table policies
CREATE POLICY "Enable insert for users" ON users
    FOR INSERT TO authenticated, anon
    WITH CHECK (true);

CREATE POLICY "Enable select for own user" ON users
    FOR SELECT TO authenticated, anon
    USING (auth_id = auth.uid() OR EXISTS (
        SELECT 1 FROM auth.users
        WHERE id = auth.uid() AND role = 'service_role'
    ));

CREATE POLICY "Enable update for own user" ON users
    FOR UPDATE TO authenticated
    USING (auth_id = auth.uid())
    WITH CHECK (auth_id = auth.uid());

CREATE POLICY "Enable delete for own user" ON users
    FOR DELETE TO authenticated
    USING (auth_id = auth.uid());

-- Languages table policies (publicly readable)
CREATE POLICY "Enable read for all" ON languages
    FOR SELECT TO authenticated, anon
    USING (true);

-- Chat history policies
CREATE POLICY "Enable all for own chat history" ON chat_history
    FOR ALL TO authenticated
    USING (user_id IN (
        SELECT id FROM user_profiles WHERE auth_id = auth.uid()
    ))
    WITH CHECK (user_id IN (
        SELECT id FROM user_profiles WHERE auth_id = auth.uid()
    ));

-- Favorite phrases policies
CREATE POLICY "Enable all for own favorites" ON favorite_phrases
    FOR ALL TO authenticated
    USING (user_id IN (
        SELECT id FROM user_profiles WHERE auth_id = auth.uid()
    ))
    WITH CHECK (user_id IN (
        SELECT id FROM user_profiles WHERE auth_id = auth.uid()
    ));

-- Emergency phrases policies
CREATE POLICY "Enable read for all emergency phrases" ON emergency_phrases
    FOR SELECT TO authenticated, anon
    USING (true);

CREATE POLICY "Enable manage for admins" ON emergency_phrases
    FOR ALL TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE auth_id = auth.uid() AND 
            auth_id IN (SELECT id FROM auth.users WHERE role = 'admin')
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE auth_id = auth.uid() AND 
            auth_id IN (SELECT id FROM auth.users WHERE role = 'admin')
        )
    );

-- Support tickets policies
CREATE POLICY "Enable manage own tickets" ON support_tickets
    FOR ALL TO authenticated
    USING (
        user_id IN (
            SELECT id FROM user_profiles WHERE auth_id = auth.uid()
        ) OR 
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE auth_id = auth.uid() AND 
            auth_id IN (SELECT id FROM auth.users WHERE role = 'admin')
        )
    )
    WITH CHECK (
        user_id IN (
            SELECT id FROM user_profiles WHERE auth_id = auth.uid()
        ) OR 
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE auth_id = auth.uid() AND 
            auth_id IN (SELECT id FROM auth.users WHERE role = 'admin')
        )
    );

-- Video conferences policies
CREATE POLICY "Enable manage own conferences" ON video_conferences
    FOR ALL TO authenticated
    USING (user_id IN (
        SELECT id FROM user_profiles WHERE auth_id = auth.uid()
    ))
    WITH CHECK (user_id IN (
        SELECT id FROM user_profiles WHERE auth_id = auth.uid()
    ));

-- User settings policies
CREATE POLICY "Enable manage own settings" ON user_settings
    FOR ALL TO authenticated
    USING (user_id IN (
        SELECT id FROM user_profiles WHERE auth_id = auth.uid()
    ))
    WITH CHECK (user_id IN (
        SELECT id FROM user_profiles WHERE auth_id = auth.uid()
    ));

-- Create new indexes for auth_id if not exists
DROP INDEX IF EXISTS idx_user_profiles_auth_id;
DROP INDEX IF EXISTS idx_users_auth_id;
CREATE INDEX idx_user_profiles_auth_id ON user_profiles(auth_id);
CREATE INDEX idx_users_auth_id ON users(auth_id);

-- Grant necessary permissions to authenticated and anon roles
GRANT USAGE ON SCHEMA public TO authenticated, anon;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated, anon;