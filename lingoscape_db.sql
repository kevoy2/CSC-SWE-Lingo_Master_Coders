-- PROJECT: LINGOSCAPE --

-- Table: User
CREATE TABLE "User" (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(255),
    password VARCHAR(255)
);

-- Table: User Settings
CREATE TABLE "User_Settings" (
    preference_id SERIAL PRIMARY KEY,
    user_id INT,
    light_dark_mode BOOLEAN,
    display_language VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES "User"(user_id)
);

-- Table: User Profile
CREATE TABLE "User_Profile" (
    profile_id SERIAL PRIMARY KEY,
    user_id INT,
    first_name VARCHAR(255),
    middle_initial VARCHAR(10),
    last_name VARCHAR(255),
    email VARCHAR(255),
    language VARCHAR(255),
    age INT,
    date_of_birth DATE,
    FOREIGN KEY (user_id) REFERENCES "User"(user_id)
);

-- Table: Video Conference
CREATE TABLE "Video_Conference" (
    conference_id SERIAL PRIMARY KEY,
    user_id INT,
    original_language_id INT,
    target_language_id INT,
    FOREIGN KEY (user_id) REFERENCES "User"(user_id),
    FOREIGN KEY (original_language_id) REFERENCES "Language"(language_id),
    FOREIGN KEY (target_language_id) REFERENCES "Language"(language_id)
);

-- Table: Chat History
CREATE TABLE "Chat_History" (
    translation_id SERIAL PRIMARY KEY,
    user_id INT,
    original_language_id INT,
    target_language_id INT,
    input_text VARCHAR(255),
    output_text VARCHAR(255),
    original_language VARCHAR(255),
    target_language VARCHAR(255),
    timestamp TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES "User"(user_id),
    FOREIGN KEY (original_language_id) REFERENCES "Language"(language_id),
    FOREIGN KEY (target_language_id) REFERENCES "Language"(language_id)
);

-- Table: Favorite Phrases
CREATE TABLE "Favorite_Phrases" (
    fav_id SERIAL PRIMARY KEY,
    user_id INT,
    translation_id INT,
    original_language_id INT,
    target_language_id INT,
    input_text VARCHAR(255),
    output_text VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES "User"(user_id),
    FOREIGN KEY (translation_id) REFERENCES "Chat_History"(translation_id),
    FOREIGN KEY (original_language_id) REFERENCES "Language"(language_id),
    FOREIGN KEY (target_language_id) REFERENCES "Language"(language_id)
);

-- Table: Support Ticket
CREATE TABLE "Support_Ticket" (
    ticket_id SERIAL PRIMARY KEY,
    user_id INT,
    subject VARCHAR(255),
    description VARCHAR(255),
    status VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES "User"(user_id)
);

-- Table: Emergency Phrases
CREATE TABLE "Emergency_Phrases" (
    phrase_id SERIAL PRIMARY KEY,
    original_language_id INT,
    target_language_id INT,
    text_in_target_language VARCHAR(255),
    text_in_original_language VARCHAR(255),
    emergency_type VARCHAR(255),
    FOREIGN KEY (original_language_id) REFERENCES "Language"(language_id),
    FOREIGN KEY (target_language_id) REFERENCES "Language"(language_id)
);

-- Table: Language
CREATE TABLE "Language" (
    language_id SERIAL PRIMARY KEY,
    language_name VARCHAR(255)
);
