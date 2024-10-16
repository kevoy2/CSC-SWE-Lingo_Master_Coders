// // menu-toggle.js
// document.addEventListener('DOMContentLoaded', function() {
//     const sideMenu = document.getElementById('side-menu');
//     const toggleButton = document.getElementById('menu-toggle');

//     toggleButton.addEventListener('click', function() {
//         // Toggle the 'open' class to show/hide the menu
//         sideMenu.classList.toggle('open');
//     });
// });

document.addEventListener('DOMContentLoaded', function() {
    const menuButton = document.querySelector('.menu-btn');
    const sideMenu = document.getElementById('side-menu');

    menuButton.addEventListener('click', function() {
        // Toggle the side menu visibility
        sideMenu.classList.toggle('open');
        
        // Toggle the active state for the menu button (for CSS)
        menuButton.classList.toggle('active');
    });
});
