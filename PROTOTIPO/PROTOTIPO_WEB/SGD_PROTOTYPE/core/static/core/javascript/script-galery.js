document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('.gallery-item img').forEach(image => {
        image.addEventListener('click', function() {
            const modal = document.createElement('div');
            modal.classList.add('modal');
            modal.innerHTML = `
                <span class="close">&times;</span>
                <img class="modal-content" src="${this.src}">
            `;
            document.body.appendChild(modal);
            
            requestAnimationFrame(() => {
                modal.classList.add('show');
            });

            modal.querySelector('.close').addEventListener('click', () => {
                modal.classList.remove('show');
                setTimeout(() => modal.remove(), 300);
            });

            modal.addEventListener('click', (e) => {
                if (e.target === modal) {
                    modal.classList.remove('show');
                    setTimeout(() => modal.remove(), 300);
                }
            });
        });
    });
});
