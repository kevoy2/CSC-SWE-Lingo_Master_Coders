# LingoScape: Real-Time Translation App

## Project Overview
LingoScape is an innovative language translation application designed to break down communication barriers by providing real-time translation services. The application leverages advanced web technologies to offer seamless translation across multiple languages.

## Project Motivation
In an increasingly globalized world, effective communication across language barriers is crucial. LingoScape aims to:
- Facilitate real-time communication for travelers
- Support multilingual professional environments
- Enhance language learning experiences
- Provide accessible translation tools

## Key Features
- **Speech-to-Text Translation**
  - Convert spoken language to text in real-time
  - Support for multiple languages
  - Continuous speech recognition

- **Text-to-Text Translation**
  - Instant translation between supported languages
  - Character limit of 1000 characters
  - Easy language swapping

- **Text-to-Speech Output**
  - Pronunciation assistance
  - Support for multiple language accents
  - Voice playback for source and translated text

- **User Management**
  - Secure user registration and authentication
  - Email verification
  - Profile language preferences

- **Translation History**
  - Save translation sessions
  - Favorite phrase bookmarking
  - Personal translation archive

## Supported Languages
- English
- Spanish
- French
- Chinese (Simplified)
- Arabic
- Russian
- German
- Portuguese
- Hindi
- Japanese
- Korean
- Italian
- Dutch
- Turkish
- Ukrainian

## Prerequisites
- Node.js (v14 or later)
- npm (Node Package Manager)
- Web browser with modern JavaScript support
- VS Code
- Live Server extension by Ritwick Dey

## Dependencies

### Production Dependencies
- `bcrypt@^5.1.1`: Secure password hashing
  - Ensures user passwords are safely stored
  - Provides cryptographic password comparison

- `cors@^2.8.5`: Cross-Origin Resource Sharing middleware
  - Enables secure cross-domain requests
  - Configurable origin, method, and header permissions

- `dotenv@^16.4.5`: Environment variable management
  - Loads environment variables from .env file
  - Separates configuration from code

- `express@^4.21.1`: Web application framework
  - Robust routing
  - Middleware support
  - HTTP utility methods

- `pg@^8.13.0`: PostgreSQL client
  - Database connection and query management
  - Promise-based interface

- `@supabase/supabase-js`: Database and authentication management
  - Real-time database operations
  - Authentication flows
  - Secure client-side interactions

- `@emailjs/browser`: (OR: `--save @emailjs/browser`)Email sending functionality
  - Client-side email sending
  - Template-based email generation

### Development Dependencies
- `jest@latest`: (OR: `--save-dev jest`) Node.js unit testing framework
  - Automated test case management
  - Code coverage reporting
  - Snapshot testing

## Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/kevoy2/CSC-SWE-Lingo_Master_Coders.git
cd [project-directory]
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Environment Configuration
Create a `.env` file in the project root:
```
DB_URL=[supabase-project-url]
DB_API=[supabase-anon-key]
SERVICE_ROLE_KEY=[supabase-service-role-key]
APP_URL=localhost:5500
# PORT=3000
```

### 4. Start the Backend Server
```bash
node server.js
```

### 5. Launch Frontend
- Install Live Server extension in VS Code
- Right-click on `index.html` or `register.html`
- Select "Open with Live Server"

## Running Tests
```bash
npm test
```

## Browser Compatibility
- Google Chrome (Recommended)
- Microsoft Edge

## Known Limitations
- Incomplete video conferencing translation integration
- No collaboration with news aggregator project
- Speech recognition accuracy varies by language and accent

## Potential Future Enhancements
- Advanced video conferencing translation
- Expanded language support
- Machine learning-based speech recognition improvement
- Real-time subtitle generation
- Offline translation mode

## Technologies Used
- **Frontend**: 
  - HTML5
  - CSS3
  - JavaScript
- **Backend**: 
  - Node.js
  - Express.js
- **Database**: 
  - Supabase
- **Authentication**: 
  - GMAIL and Supabase Auth
- **Speech Technology**: 
  - Web Speech API

## Performance Metrics
- Translation Response Time: <500ms
- Supported Languages: 15
- Maximum Translation Length: 1000 characters

## Contributors
- Kaleb Evoy
- Jesse Annan
- Zoha Khundmiri
- McDavid Adofoli
- Hashim Omar

## Acknowledgments
- Supabase for database and GMAIL for vanilla authentication services
- MyMemory Translation API
- Web Speech API

---

**Happy Translating!** 🌐🗣️
