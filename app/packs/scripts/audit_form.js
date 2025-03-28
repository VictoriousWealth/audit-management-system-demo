document.addEventListener("DOMContentLoaded", function () {
  const container = document.getElementById("support-auditor-container");
  const addBtn = document.getElementById("add-support-auditor");

  addBtn.addEventListener("click", () => {
    let existing = container.querySelector(".support-auditor-field");

    if (!existing) {
      // If no existing field, create one from scratch
      existing = document.createElement("div");
      existing.className = "form-group mt-4 support-auditor-field";
      existing.innerHTML = `
        <div class="text-black-75 text-capitalize fs-3 mb-2 visually-hidden">
          <label for="audit_assignment_support_auditor">Support Auditor's Email</label>
        </div>
        <select name="audit_assignment[support_auditor][]" class="text-black-50 text-capitalize form-control fw-semibold mb-2">
          <option selected disabled>Select a Support Auditor</option>
          ${buildOptions()} 
        </select>
        <button type="button" class="btn btn-danger btn-sm mb-2 ms-3 remove-support-auditor" title="Remove Support Auditor" aria-label="Remove Support Auditor">⊖</button>
      `;
      container.appendChild(existing);
      return;
    }

    const clone = existing.cloneNode(true);

    // Clear selected value in cloned field
    const select = clone.querySelector("select");
    select.selectedIndex = 0;

    container.appendChild(clone);
  });

  // Remove button delegation
  container.addEventListener("click", (e) => {
    if (e.target.classList.contains("remove-support-auditor")) {
      const field = e.target.closest(".support-auditor-field");
      if (document.querySelectorAll(".support-auditor-field").length > 0) {
        field.remove();
      }
    }
  });

  // Function to dynamically build <option>s from JSON passed by Rails
  function buildOptions() {
    const auditors = JSON.parse(document.getElementById("auditor-data").textContent);
    return auditors.map(a => `<option value="${a.id}">${a.email}</option>`).join("");
  }
});



document.addEventListener("DOMContentLoaded", function () {
  const smeContainer = document.getElementById("sme-container");
  const addSMEBtn = document.getElementById("add-sme");

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

  smeContainer.addEventListener("click", (e) => {
    if (e.target.classList.contains("remove-sme")) {
      const field = e.target.closest(".sme-field");
      if (document.querySelectorAll(".sme-field").length > 0) {
        field.remove();
      }
    }
  });

  function buildSMEOptions() {
    const users = JSON.parse(document.getElementById("user-data").textContent);
    return users.map(u => `<option value="${u.id}">${u.email}</option>`).join("");
  }
});

document.addEventListener("DOMContentLoaded", function () {
  const standardContainer = document.getElementById("standard-container");
  const addStandardBtn = document.getElementById("add-standard");

  addStandardBtn.addEventListener("click", () => {
    let existingStandard = standardContainer.querySelector(".standard-field");

    if (!existingStandard) {
      existingStandard = document.createElement("div");
      existingStandard.className = "form-group mt-4 standard-field";
      existingStandard.innerHTML = `
        <div class="text-black-75 text-capitalize fs-3 mb-2 visually-hidden">
          <label for="audit_standard_standard">Applicable Standard</label>
        </div>
        <input type="text" name="audit_standard[standard][]" list="standard-options" class="text-black-50 text-capitalize form-control fw-semibold mb-2" placeholder="Type and select an applicable standard" />
        <button type="button" class="btn btn-danger btn-sm mb-2 ms-3 remove-standard" title="Remove Standard" aria-label="Remove Standard">⊖</button>
      `;
      standardContainer.appendChild(existingStandard);
      return;
    }

    const clone = existingStandard.cloneNode(true);
    const input = clone.querySelector("input");
    input.value = "";

    standardContainer.appendChild(clone);
  });

  standardContainer.addEventListener("click", (e) => {
    if (e.target.classList.contains("remove-standard")) {
      const field = e.target.closest(".standard-field");
      if (document.querySelectorAll(".standard-field").length > 0) {
        field.remove();
      }
    }
  });
});
