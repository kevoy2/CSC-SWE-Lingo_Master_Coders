document.addEventListener('DOMContentLoaded', function() {
    // Common elements
    const sourceText = document.getElementById('source-text');
    const targetText = document.getElementById('translated-text');
    const sourceLanguage = document.getElementById('source-language');
    const targetLanguage = document.getElementById('target-language');
    const swapButton = document.getElementById('swap-languages');
    const translateButton = document.getElementById('translate-button');
    const charCount = document.getElementById('char-count');
    const sourceVolume = document.getElementById('source-volume');
    const targetVolume = document.getElementById('target-volume');
    const targetCopy = document.getElementById('target-copy');
    const clearTextButton = document.getElementById('clear-text');
    const recordButton = document.getElementById('record-button');

    // Speech Recognition variables
    let recognition;
    let isRecording = false;

    // Character count functionality
    if (sourceText) {
        sourceText.addEventListener('input', function() {
            updateCharCount();
        });
    }

    // Clear text functionality
    if (clearTextButton) {
        clearTextButton.addEventListener('click', function() {
            clearText();
        });
    }

    // Swap functionality
    if (swapButton) {
        swapButton.addEventListener('click', function() {
            swapLanguages();
        });
    }

    // Translation functionality
    if (translateButton) {
        translateButton.addEventListener('click', function() {
            translateText();
        });
    }

    // Recording functionality
    if (recordButton) {
        recordButton.addEventListener('click', function() {
            toggleRecording();
        });
    }

    // Text-to-speech functionality
    if (sourceVolume) {
        sourceVolume.addEventListener('click', () => speak(sourceText.value, getVoiceLanguageCode(sourceLanguage.value)));
    }
    if (targetVolume) {
        targetVolume.addEventListener('click', () => speak(targetText.value, getVoiceLanguageCode(targetLanguage.value)));
    }

    // Copy functionality
    if (targetCopy) {
        targetCopy.addEventListener('click', () => copyToClipboard());
    }

    // Functions
    function updateCharCount() {
        const currentLength = sourceText.value.length;
        charCount.textContent = `${currentLength}/1000`;
        
        if (currentLength > 800) {
            charCount.style.color = '#e74c3c';
        } else {
            charCount.style.color = '#666';
        }
    }

    function clearText() {
        if (sourceText) sourceText.value = '';
        if (targetText) targetText.value = '';
        if (charCount) charCount.textContent = '0/1000';
        if (charCount) charCount.style.color = '#666';
    }

    function swapLanguages() {
        if (sourceLanguage && targetLanguage) {
            let tempLang = sourceLanguage.value;
            let tempText = sourceText.value;
            
            sourceLanguage.value = targetLanguage.value;
            targetLanguage.value = tempLang;
            sourceText.value = targetText.value;
            targetText.value = tempText;
            
            updateCharCount();

            // Update recognition language if it exists
            if (recognition) {
                recognition.lang = getRecognitionLanguageCode(sourceLanguage.value);
            }
        }
    }

    function translateText() {
        const text = sourceText.value;
        const fromLang = sourceLanguage.value;
        const toLang = targetLanguage.value;
        
        const apiUrl = `https://api.mymemory.translated.net/get?q=${encodeURIComponent(text)}&langpair=${fromLang}|${toLang}`;
        
        fetch(apiUrl)
            .then(res => res.json())
            .then(data => {
                targetText.value = data.responseData.translatedText;
            })
            .catch(error => {
                console.error('Translation error:', error);
                targetText.value = 'Error: Could not translate text';
            });
    }

    // Helper function to get the correct language code format for speech recognition
    function getRecognitionLanguageCode(langCode) {
        const langMap = {
            'en': 'en-US',
            'es': 'es-ES',
            'fr': 'fr-FR',
            'zh': 'zh-CN',
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

    // Helper function to get the correct language code format for text-to-speech
    function getVoiceLanguageCode(langCode) {
        return getRecognitionLanguageCode(langCode); // Using the same mapping for now
    }

    function speak(text, lang) {
        const utterance = new SpeechSynthesisUtterance(text);
        utterance.lang = lang;
        speechSynthesis.speak(utterance);
    }

    function copyToClipboard() {
        targetText.select();
        document.execCommand('copy');
        alert('Text copied to clipboard!');
    }

    // Speech Recognition functions
    function toggleRecording() {
        if (!recordButton) return;
        
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

    function startSpeechRecognition() {
        if (!('webkitSpeechRecognition' in window)) {
            alert("Sorry, your browser doesn't support speech recognition.");
            return;
        }
        
        recognition = new webkitSpeechRecognition();
        recognition.lang = getRecognitionLanguageCode(sourceLanguage.value);
        recognition.interimResults = false;
        recognition.maxAlternatives = 1;
        recognition.continuous = true;

        recognition.onresult = (event) => {
            const transcript = event.results[event.results.length - 1][0].transcript;
            sourceText.value += transcript + ' ';
            updateCharCount();
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

    function stopSpeechRecognition() {
        if (recognition) {
            recognition.stop();
        }
    }
});
