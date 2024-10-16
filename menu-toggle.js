// menu-toggle.js
document.addEventListener('DOMContentLoaded', function() {
    const sideMenu = document.getElementById('side-menu');
    const toggleButton = document.getElementById('menu-toggle');

    toggleButton.addEventListener('click', function() {
        // Toggle the 'open' class to show/hide the menu
        sideMenu.classList.toggle('open');
    });
});
