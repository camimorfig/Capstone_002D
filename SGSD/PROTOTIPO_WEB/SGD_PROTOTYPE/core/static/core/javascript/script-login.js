document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('login-form').addEventListener('submit', function(event) {
        let username = document.getElementById('username').value;
        let password = document.getElementById('password').value;
        let emailPattern = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;

        if (!emailPattern.test(username)) {
            alert('Por favor, ingresa un correo electrónico válido.');
            event.preventDefault();
        } else if (!password) {
            alert('Por favor, ingresa tu contraseña.');
            event.preventDefault();
        }
    });
});
