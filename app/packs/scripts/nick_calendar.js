import { Calendar } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import interactionPlugin from '@fullcalendar/interaction';

document.addEventListener('DOMContentLoaded', () => {
  const calendarEl = document.getElementById('auditCalendar');
  if (calendarEl) {
    const calendar = new Calendar(calendarEl, {
      plugins: [dayGridPlugin, interactionPlugin],
      initialView: 'dayGridMonth',
      events: window.auditEvents,
      headerToolbar: false,

      datesSet: function () {
        const existing = document.querySelector(".custom-calendar-header");
        if (existing) existing.remove();

        const toolbarContainer = document.querySelector(".fc-header-toolbar") || calendarEl;

        const header = document.createElement("div");
        header.className = "custom-calendar-header mb-2";

        header.innerHTML = `
          <div class="d-flex justify-content-between align-items-center p-2 mb-2"
               style="background: #c0c0c030; border-top: solid 1px; border-bottom: solid 1px;">
            <button class="fc-prev-button btn btn-outline-secondary px-3 mt-0"
                    style="border: none; color: #42CA68;">◀</button>

            <h2 class="fc-toolbar-title m-0 flex-grow-1 text-center"
                    style="font-weight: 100; min-inline-size: max-content;">${calendar.view.title}
            </h2>

            <button class="fc-next-button btn btn-outline-secondary px-3 mt-0"
                    style="border: none; color: #42CA68;">▶</button>
          </div>

          <div class="d-flex justify-content-center">
            <button class="fc-today-button btn btn-primary mt-0"
                    style="background: #c0c0c030;border: black solid;color: black;">Today</button>
          </div>
        `;

        toolbarContainer.prepend(header);

        header.querySelector(".fc-prev-button").addEventListener("click", () => calendar.prev());
        header.querySelector(".fc-next-button").addEventListener("click", () => calendar.next());
        header.querySelector(".fc-today-button").addEventListener("click", () => calendar.today());
      }
    });

    calendar.render();
  }
});
