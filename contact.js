function sendEmail() {
    let params = {
        firstName: document.getElementById("first-name").value,
        lastName: document.getElementById("last-name").value,
        email: document.getElementById("email").value,
        message: document.getElementById("message").value,
    };

    emailjs.send('service_5xaedc4', 'template_x2zhee4', params).then(alert('SUCCESS!!!'));
}