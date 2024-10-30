-- CODE TO CREATE NECESSARY RELATIONAL TABLES FOR LINGOSCAPE

-- Main tables without foreign key references

CREATE TABLE "user_profiles" ( 
    "id" BIGSERIAL PRIMARY KEY, 
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL, 
    "dob" DATE NOT NULL, 
    "age" INT, 
    "email" TEXT UNIQUE NOT NULL, 
    "password" TEXT NOT NULL, 
    "language" VARCHAR(100) DEFAULT 'English', 
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
);

CREATE TABLE "languages" (
    "code" VARCHAR(50) PRIMARY KEY,
    "name" VARCHAR(100) NOT NULL
);

-- Tables with foreign key references

CREATE TABLE "users" ( 
    "id" BIGSERIAL PRIMARY KEY, 
    "profile_id" BIGSERIAL, 
    "email" TEXT UNIQUE NOT NULL, 
    "password" TEXT NOT NULL, 
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("profile_id") REFERENCES "user_profiles"("id") ON DELETE CASCADE 
);



-- NOTE !!!
-- NEED TO REWRITE THE DATABASE TABLES FOR THE BELOW 


CREATE TABLE "chat_history" (
	"translation_id" BIGSERIAL PRIMARY KEY,
    "user_id" BIGSERIAL,
    "origin_lang_code" VARCHAR(10),
    "target_lang_code" VARCHAR(10),
    "source_text" TEXT NOT NULL,
    "target_text" TEXT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("user_id") REFERENCES "users"("user_id") ON DELETE CASCADE,
    FOREIGN KEY ("origin_lang_code") REFERENCES "languages"("lang_code") ON DELETE RESTRICT,
    FOREIGN KEY ("target_lang_code") REFERENCES "languages"("lang_code") ON DELETE RESTRICT
);

CREATE TABLE "favorite_phrases" (
    "fav_id" BIGSERIAL PRIMARY KEY,
    "user_id" BIGSERIAL,
    "translation_id" BIGSERIAL,
    FOREIGN KEY ("user_id") REFERENCES "users"("user_id") ON DELETE CASCADE,
    FOREIGN KEY ("translation_id") REFERENCES "chat_history"("translation_id") ON DELETE CASCADE
);

CREATE TABLE "emergency_phrases" (
    "emg_id" BIGSERIAL PRIMARY KEY,
    "translation_id" BIGSERIAL,
    "emergency" BOOLEAN DEFAULT 'false',
    FOREIGN KEY ("translation_id") REFERENCES "chat_history"("translation_id") ON DELETE SET NULL
);

CREATE TABLE "ticket_id" (
    "ticket_id" BIGSERIAL PRIMARY KEY,
    "user_id" BIGSERIAL,
    "subject" VARCHAR(255) NOT NULL,
    "description" TEXT NOT NULL,
    "status" VARCHAR(50) DEFAULT 'Pending',
    FOREIGN KEY ("user_id") REFERENCES "users"("user_id") ON DELETE SET NULL
);

CREATE TABLE "video_conferences" (
    "conference_id" BIGSERIAL PRIMARY KEY,
    "user_id" BIGSERIAL,
    "origin_lang_code" VARCHAR(10),
    "target_lang_code" VARCHAR(10),
    FOREIGN KEY ("user_id") REFERENCES "users"("user_id") ON DELETE CASCADE,
    FOREIGN KEY ("origin_lang_code") REFERENCES "languages"("lang_code") ON DELETE RESTRICT,
    FOREIGN KEY ("target_lang_code") REFERENCES "languages"("lang_code") ON DELETE RESTRICT
);

CREATE TABLE "user_settings" (
    "preference_id" BIGSERIAL PRIMARY KEY,
    "user_id" BIGSERIAL UNIQUE,
    "theme" BOOLEAN,
    "ui_language" VARCHAR(10) DEFAULT 'en',
    FOREIGN KEY ("user_id") REFERENCES "users"("user_id") ON DELETE CASCADE,
    FOREIGN KEY ("ui_language") REFERENCES "languages"("lang_code") ON DELETE RESTRICT
);
