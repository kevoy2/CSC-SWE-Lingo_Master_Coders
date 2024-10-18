document.addEventListener('DOMContentLoaded', function() {
    const menuButton = document.querySelector('.menu-btn');
    const sideMenu = document.getElementById('side-menu');

    menuButton.addEventListener('click', function() {
        sideMenu.classList.toggle('open');
        menuButton.classList.toggle('active');
    });
});
