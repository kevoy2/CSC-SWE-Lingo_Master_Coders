document.addEventListener('DOMContentLoaded', function() {
    const sourceText = document.querySelector('.translation-box textarea');
    const targetText = document.getElementById('translated-text');
    const sourceLanguage = document.getElementById('source-language');
    const targetLanguage = document.getElementById('target-language');
    const swapButton = document.getElementById('swap-languages');
    const translateButton = document.getElementById('translate-button');

    swapButton.addEventListener('click', function() {
        const temp = sourceLanguage.value;
        sourceLanguage.value = targetLanguage.value;
        targetLanguage.value = temp;
    });

    translateButton.addEventListener('click', function() {
        // Here you would typically make an API call to a translation service
        // For now, we'll just simulate a translation
        const translatedText = `Translated: ${sourceText.value}`;
        targetText.value = translatedText;
    });
});