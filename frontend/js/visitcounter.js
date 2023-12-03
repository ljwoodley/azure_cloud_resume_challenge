const apis = {
    non_prod: 'TODO',
    prod: 'https://counter31jsr2b0.azurewebsites.net/api/visit_counter?code=UawQdFkYwkZ3ep5I4PAVrQEmE-urbPsatgKkyv93pnf7AzFuUaIDWg=='
};

function getEnvironment() {
    if (window.location.hostname.endsWith('azureedge.net') || window.location.hostname === 'localhost') {
        return 'non_prod';
    } else {
        return 'prod';
    }
}

// Use the correct API based on the environment
const functionApi = apis[getEnvironment()];

fetch(functionApi)
    .then(response => response.json())
    .then(response => {
        console.log('Fetch succeeded to function.');
        document.getElementById('counter').innerText = response;
    })
    .catch(error => {
        console.error('There has been a problem with your fetch operation:', error);
    });
