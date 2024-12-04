document.addEventListener('DOMContentLoaded', function() {
    const calendarDates = document.getElementById('calendar-dates');
    const monthYear = document.getElementById('month-year');
    const prevMonth = document.getElementById('prev-month');
    const nextMonth = document.getElementById('next-month');
    const eventModal = document.getElementById('event-modal');
    const closeModal = document.querySelector('.close');
    const eventForm = document.getElementById('event-form');

    let currentDate = new Date();
    let events = [];

    function renderCalendar() {
        calendarDates.innerHTML = '';
        const firstDay = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);
        const lastDay = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 0);

        monthYear.textContent = `${currentDate.toLocaleString('default', { month: 'long' })} ${currentDate.getFullYear()}`;

        for (let i = 1; i < firstDay.getDay(); i++) {
            calendarDates.innerHTML += '<div></div>';
        }

        for (let i = 1; i <= lastDay.getDate(); i++) {
            const dayDiv = document.createElement('div');
            dayDiv.textContent = i;
            dayDiv.addEventListener('click', () => openModal(i));
            calendarDates.appendChild(dayDiv);
        }
    }

    function openModal(day) {
        eventModal.style.display = 'block';
        document.getElementById('event-date').value = `${currentDate.getFullYear()}-${String(currentDate.getMonth() + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
    }

    closeModal.addEventListener('click', () => {
        eventModal.style.display = 'none';
    });

    eventForm.addEventListener('submit', function(e) {
        e.preventDefault();
        const title = document.getElementById('event-title').value;
        const date = document.getElementById('event-date').value;
        events.push({ title, date });
        renderEvents();
        eventModal.style.display = 'none';
    });

    function renderEvents() {
        const firstDay = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);
        events.forEach(event => {
            const eventDate = new Date(event.date);
            if (eventDate.getMonth() === currentDate.getMonth() && eventDate.getFullYear() === currentDate.getFullYear()) {
                const dayDiv = calendarDates.querySelector(`div:nth-child(${eventDate.getDate() + firstDay.getDay() - 1})`);
                if (dayDiv) {
                    dayDiv.style.backgroundColor = '#007bff';
                    dayDiv.style.color = '#fff';
                    dayDiv.title = event.title;
                }
            }
        });
    }

    prevMonth.addEventListener('click', () => {
        currentDate.setMonth(currentDate.getMonth() - 1);
        renderCalendar();
        renderEvents();
    });

    nextMonth.addEventListener('click', () => {
        currentDate.setMonth(currentDate.getMonth() + 1);
        renderCalendar();
        renderEvents();
    });

    renderCalendar();
    renderEvents();
});
