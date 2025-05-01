document.addEventListener("DOMContentLoaded", function () {
  // Only run this script if the SME container exists on the page
  const smeContainer = document.getElementById("sme-container");
  const addSMEBtn = document.getElementById("add-sme");
  const userData = document.getElementById("user-data");

  if (!smeContainer || !addSMEBtn || !userData) return; // Exit safely if any key element is missing

  // Function that generates the <option> tags for the SME <select>
  function buildSMEOptions() {
    const users = JSON.parse(userData.textContent);
    return users.map(u => `<option value="${u.id}">${u.email}</option>`).join("");
  }

  // Add SME field
  addSMEBtn.addEventListener("click", () => {
    let existingSME = smeContainer.querySelector(".sme-field");

    if (!existingSME) {
      existingSME = document.createElement("div");
      existingSME.className = "form-group mt-4 sme-field";

      existingSME.innerHTML = `
        <div class="text-black-75 text-capitalize fs-3 mb-2 visually-hidden">
          <label for="audit_assignment_sme">Subject Matter Expert's Email</label>
        </div>
        <select name="audit_assignment[sme][]" class="text-black-50 text-capitalize form-control fw-semibold mb-2">
          <option selected disabled>Select a Subject Matter Expert</option>
          ${buildSMEOptions()} 
        </select>
        <button type="button" class="btn btn-danger btn-sm mb-2 ms-3 remove-sme" title="Remove SME" aria-label="Remove SME">⊖</button>
      `;

      smeContainer.appendChild(existingSME);
      return;
    }

    const clone = existingSME.cloneNode(true);
    const select = clone.querySelector("select");
    select.selectedIndex = 0;
    smeContainer.appendChild(clone);
  });

  // Remove SME field via event delegation
  smeContainer.addEventListener("click", (e) => {
    if (e.target.classList.contains("remove-sme")) {
      const field = e.target.closest(".sme-field");
      if (field) field.remove();
    }
  });
});
