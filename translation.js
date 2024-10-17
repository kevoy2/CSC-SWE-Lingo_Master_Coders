document.addEventListener('DOMContentLoaded', function() {
    const sourceText = document.querySelector('.translation-box textarea');
    const targetText = document.getElementById('translated-text');
    const sourceLanguage = document.getElementById('source-language');
    const targetLanguage = document.getElementById('target-language');
    const swapButton = document.getElementById('swap-languages');
    const translateButton = document.getElementById('translate-button');

    swapButton.addEventListener('click', function() {
        let tempCode = sourceLanguage.value,
        tempText = sourceText.value;
        sourceLanguage.value = targetLanguage.value;
        targetLanguage.value = tempCode;
        sourceText.value = targetText.value;
        targetText.value = tempText;
    });

    translateButton.addEventListener('click', function() {
        let apiUrl = `https://api.mymemory.translated.net/get?q=${sourceText.value}&langpair=${sourceLanguage.value}|${targetLanguage.value}`;
        fetch(apiUrl).then(res => res.json()).then(data => {
            console.log(data);
            targetText.value = data.responseData.translatedText;
        }).catch(error => {
            console.error('Translation error:', error);
            targetText.value = 'Error: Could not translate text';
        });
    });
});