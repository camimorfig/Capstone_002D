document.addEventListener('DOMContentLoaded', function() {
    var modal = document.getElementById('newsModal');
    var modalContent = document.getElementById('modalContent');
    var closeBtn = document.getElementsByClassName('close')[0];

    // Cerrar el modal al hacer clic en la X
    closeBtn.onclick = function() {
        modal.style.display = 'none';
    }

    // Cerrar el modal al hacer clic fuera de él
    window.onclick = function(event) {
        if (event.target == modal) {
            modal.style.display = 'none';
        }
    }

    // Abrir el modal al hacer clic en "Leer más"
    document.querySelectorAll('.read-more').forEach(function(button) {
        button.onclick = function() {
            var card = this.closest('.card');
            var fullContent = card.querySelector('.full-news-content').innerHTML;
            modalContent.innerHTML = fullContent;
            modal.style.display = 'block';
        }
    });
});