const imagenes = document.querySelectorAll('.img');
const imgModal = document.querySelector('#imgModal')

imagenes.forEach(img => {
    img.addEventListener('click', (e) => {
        imgModal.src = e.target.src  
        e.target.setAttribute('data-toggle', 'modal')
        e.target.setAttribute('data-target', '#exampleModal')    
    })
})