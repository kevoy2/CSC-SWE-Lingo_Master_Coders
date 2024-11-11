// Define video and audio elements
const localVideo = document.getElementById('localVideo');
const remoteVideo = document.getElementById('remoteVideo');
const translatedText = document.getElementById('translatedText');

// Define language selection elements
const inputLanguageSelect = document.getElementById('input-language');
const outputLanguageSelect = document.getElementById('output-language');

let localStream;
let isMuted = false;
let recognition;
let isRecording = false;

// Start the video conference and access media
async function startConference() {
    try {
        // Access the user's video/audio
        localStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
        localVideo.srcObject = localStream;

        // Initialize translation and speech recognition after conference starts
        initializeTranslation();
    } catch (error) {
        alert('Error accessing video/audio: ' + error.message);
    }
}

// Function to end the conference
function endConference() {
    if (localStream) {
        localStream.getTracks().forEach(track => track.stop());
    }
    localVideo.srcObject = null;
    remoteVideo.srcObject = null;
    translatedText.innerText = 'Conference ended.';
}

// Toggle mute/unmute functionality
function toggleMute() {
    if (localStream) {
        localStream.getAudioTracks().forEach(track => (track.enabled = !track.enabled));
        isMuted = !isMuted;
        document.getElementById('muteButton').textContent = isMuted ? 'Unmute' : 'Mute';
    }
}

// Initialize Translation and Speech Recognition
function initializeTranslation() {
    if (!('webkitSpeechRecognition' in window)) {
        alert("Sorry, your browser doesn't support speech recognition.");
        return;
    }

    const fromLang = inputLanguageSelect.value || 'en';
    const toLang = outputLanguageSelect.value || 'en';

    if (!fromLang || !toLang) {
        alert('Please select both source and target languages.');
        return;
    }

    recognition = new webkitSpeechRecognition();
    recognition.lang = getRecognitionLanguageCode(fromLang);
    recognition.continuous = true;
    recognition.interimResults = false;
    recognition.maxAlternatives = 1;

    recognition.onresult = async (event) => {
        const transcript = event.results[event.results.length - 1][0].transcript;
        const translatedTextContent = await translateText(transcript, fromLang, toLang);
        translatedText.innerText = translatedTextContent;
    };

    recognition.onerror = (event) => {
        console.error('Speech recognition error:', event);
        alert('Speech recognition error');
        toggleRecording();
    };

    recognition.onend = () => {
        if (isRecording) {
            recognition.start();
        }
    };

    recognition.start();
}

// Translation function
async function translateText(text, fromLang, toLang) {
    const apiUrl = `https://api.mymemory.translated.net/get?q=${encodeURIComponent(text)}&langpair=${fromLang}|${toLang}`;
    try {
        const response = await fetch(apiUrl);
        const data = await response.json();
        return data.responseData ? data.responseData.translatedText : 'Translation failed. Please try again.';
    } catch (error) {
        console.error('Translation error:', error);
        return 'Error: Could not translate text';
    }
}

// Helper function to get the correct language code format for speech recognition
function getRecognitionLanguageCode(langCode) {
    const langMap = {
        'en': 'en-US',
        'es': 'es-ES',
        'fr': 'fr-FR',
        'zh-cn': 'zh-CN',
        'ar': 'ar-SA',
        'ru': 'ru-RU',
        'de': 'de-DE',
        'pt': 'pt-PT',
        'hi': 'hi-IN',
        'ja': 'ja-JP',
        'ko': 'ko-KR',
        'it': 'it-IT',
        'nl': 'nl-NL',
        'tr': 'tr-TR',
        'uk': 'uk-UA'
    };
    return langMap[langCode] || langCode;
}

// Clear translated text
function clearText() {
    translatedText.innerText = 'Translations will appear here...';
}

// Swap languages functionality
function swapLanguages() {
    const tempLang = inputLanguageSelect.value;
    inputLanguageSelect.value = outputLanguageSelect.value;
    outputLanguageSelect.value = tempLang;
}

// Toggle recording functionality
function toggleRecording() {
    isRecording = !isRecording;
    if (isRecording) {
        startSpeechRecognition();
        recordButton.textContent = 'Stop Recording';
        recordButton.style.backgroundColor = '#e74c3c';
    } else {
        stopSpeechRecognition();
        recordButton.textContent = 'Start Recording';
        recordButton.style.backgroundColor = '#1ABC9C';
    }
}

// Start Speech Recognition
function startSpeechRecognition() {
    if (!('webkitSpeechRecognition' in window)) {
        alert("Sorry, your browser doesn't support speech recognition.");
        return;
    }

    recognition = new webkitSpeechRecognition();
    recognition.lang = getRecognitionLanguageCode(inputLanguageSelect.value);
    recognition.interimResults = false;
    recognition.maxAlternatives = 1;
    recognition.continuous = true;

    recognition.onresult = (event) => {
        const transcript = event.results[event.results.length - 1][0].transcript;
        translatedText.innerText = transcript;
    };

    recognition.onerror = (event) => {
        console.error('Speech recognition error:', event);
        alert('Speech recognition error');
        toggleRecording();
    };

    recognition.onend = () => {
        if (isRecording) {
            recognition.start();
        }
    };

    recognition.start();
}

// Stop Speech Recognition
function stopSpeechRecognition() {
    if (recognition) {
        recognition.stop();
    }
}

// Invite Participant Function
function inviteParticipant() {
    const participantEmail = document.getElementById('participantEmail').value;
    if (participantEmail && !participants.includes(participantEmail)) {
        participants.push(participantEmail);
        
        // Display participant in the list
        const participantsList = document.getElementById('participants');
        const listItem = document.createElement('li');
        listItem.textContent = participantEmail;
        participantsList.appendChild(listItem);

        // Clear the input field
        document.getElementById('participantEmail').value = '';
    } else {
        alert("Please enter a valid email that hasn't already been added.");
    }
}

// Schedule Conference Function
function scheduleConference() {
    const conferenceDate = document.getElementById('conferenceDate').value;
    const conferenceTime = document.getElementById('conferenceTime').value;
    
    if (conferenceDate && conferenceTime) {
        alert(`Conference scheduled for ${conferenceDate} at ${conferenceTime}`);
    } else {
        alert('Please select both date and time to schedule the conference.');
    }
}

// Add Event Listeners 
document.addEventListener('DOMContentLoaded', function() {
    const startConferenceButton = document.getElementById('start-conference');
    const translateButton = document.getElementById('translate-button');
    const clearTextButton = document.getElementById('clear-text');
    const swapButton = document.getElementById('swap-languages');
    const recordButton = document.getElementById('record-button');
    const inviteButton = document.getElementById('inviteParticipant');
    const scheduleButton = document.getElementById('scheduleConference');

    if (startConferenceButton) startConferenceButton.addEventListener('click', startConference);
    if (translateButton) translateButton.addEventListener('click', translateText);
    if (clearTextButton) clearTextButton.addEventListener('click', clearText);
    if (swapButton) swapButton.addEventListener('click', swapLanguages);
    if (recordButton) recordButton.addEventListener('click', toggleRecording);
    if (inviteButton) inviteButton.addEventListener('click', inviteParticipant);
    if (scheduleButton) scheduleButton.addEventListener('click', scheduleConference);
});
