// window.addEventListener('DOMContentLoaded', (event) =>{
//     getVisitCount();
// })

const functionApi = 'TODO';

fetch(functionApi)
    .then(response => {
        return response.json();
    })
    .then (response => {
        console.log('Fetch succeeded to function.');
        document.getElementById('counter').innerText = response;
    })
    .catch(error => {
        console.error('There has been a problem with your fetch operation:', error);
    });
