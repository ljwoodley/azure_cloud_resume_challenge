const functionApi = 'https://counter31jsr2b0.azurewebsites.net/api/visit_counter?code=UawQdFkYwkZ3ep5I4PAVrQEmE-urbPsatgKkyv93pnf7AzFuUaIDWg==';

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
