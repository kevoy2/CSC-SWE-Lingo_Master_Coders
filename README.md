# LingoScape: Real-Time Translation App

## Project Overview
LingoScape is a live translation application that enables real-time language translation through speech recognition, text translation, and text-to-speech functionality.

## Key Features
- Speech-to-text translation
- Text-to-text translation
- Multi-language support
- Text-to-speech output
- User authentication and profile management
- Translation history and favorites

## Prerequisites
- Node.js (v14 or later)
- npm (Node Package Manager)
- VS Code
- Live Server extension by Ritwick Dey (install as VS Code extension)

## Dependencies
- bcrypt: ^5.1.1 (Password hashing)
- cors: ^2.8.5 (Cross-origin resource sharing)
- dotenv: ^16.4.5 (Environment variable management)
- express: ^4.21.1 (Web application framework)
- pg: ^8.13.0 (PostgreSQL client)
- @supabase/supabase-js (Database management)

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

### 3. Create .env File
Create a `.env` file in the project root with the following variables:
```
DB_URL=[supabase-project-url]
DB_API=[supabase-anon-key]
SERVICE_ROLE_KEY=[supabase-service-role-key]
APP_URL=http://localhost:5500
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

## Browser Compatibility
- Chrome (recommended)
- Edge

## Limitations
- Video conferencing integration (incomplete)
- No collaboration with news aggregator project

## Future Enhancements
- Complete video conferencing translation
- Expand language support
- Improve speech recognition accuracy

## Technologies Used
- Frontend: HTML, CSS, JavaScript
- Backend: Node.js, Express
- Database: Supabase
- Authentication: GMAIL and Supabase Auth
- Speech Recognition: Web Speech API

## Contributors
- Kaleb Evoy
- Jesse Annan
- Zoha Khundmiri
- McDavid Adofoli
- Hashim Omar

