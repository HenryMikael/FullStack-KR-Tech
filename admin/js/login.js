const API_URL = 'http://127.0.0.1:5000';

async function login() {

    const email = document.getElementById('email').value;
    const senha = document.getElementById('senha').value;

    const response = await fetch(`${API_URL}/login`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            email,
            senha
        })
    });

    const data = await response.json();

    if(response.ok){
        window.location.href = 'dashboard.html';
    } else {
        alert(data.message);
    }
}