function sendEmail(){
    let parameters = {
        email: document.getElementById("email").value,
        message: document.getElementById("message").value,
        firstName: document.getElementById("first-name").value,
        lastName: document.getElementById("last-name").value,
    }

    emailjs.send("service_5xaedc4", "template_x2zhee4", parameters).then(alert("Email successfully sent."))
}