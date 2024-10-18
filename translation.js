document.addEventListener('DOMContentLoaded', function() {
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

    // Character count functionality
    sourceText.addEventListener('input', function() {
        const currentLength = this.value.length;
        charCount.textContent = `${currentLength}/1000`;
        
        if (currentLength > 800) {
            charCount.style.color = '#e74c3c';
        } else {
            charCount.style.color = '#666';
        }
    });

    // Clear text functionality
    clearTextButton.addEventListener('click', function() {
        sourceText.value = '';
        charCount.textContent = '0/1000';
        charCount.style.color = '#666';
    });

    // Swap functionality
    swapButton.addEventListener('click', function() {
        let tempCode = sourceLanguage.value,
        tempText = sourceText.value;
        sourceLanguage.value = targetLanguage.value;
        targetLanguage.value = tempCode;
        sourceText.value = targetText.value;
        targetText.value = tempText;
        sourceText.dispatchEvent(new Event('input'));
    });

    // Translation functionality
    translateButton.addEventListener('click', function() {
        let apiUrl = `https://api.mymemory.translated.net/get?q=${encodeURIComponent(sourceText.value)}&langpair=${sourceLanguage.value}|${targetLanguage.value}`;
        fetch(apiUrl).then(res => res.json()).then(data => {
            console.log(data);
            targetText.value = data.responseData.translatedText;
        }).catch(error => {
            console.error('Translation error:', error);
            targetText.value = 'Error: Could not translate text';
        });
    });

    // Text-to-speech functionality
    function speak(text, lang) {
        const utterance = new SpeechSynthesisUtterance(text);
        utterance.lang = lang;
        speechSynthesis.speak(utterance);
    }

    sourceVolume.addEventListener('click', () => speak(sourceText.value, sourceLanguage.value));
    targetVolume.addEventListener('click', () => speak(targetText.value, targetLanguage.value));

    // Copy functionality
    function copyToClipboard(text) {
        navigator.clipboard.writeText(text).then(() => {
            alert('Text copied to clipboard!');
        }).catch(err => {
            console.error('Failed to copy text: ', err);
        });
    }

    targetCopy.addEventListener('click', () => copyToClipboard(targetText.value));
});