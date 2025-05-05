document.addEventListener("DOMContentLoaded", function () {
  const container = document.getElementById("support-auditor-container");
  const addBtn = document.getElementById("add-support-auditor");
  const auditorData = document.getElementById("auditor-data");

  // Exit early if required elements are not present on the page
  if (!container || !addBtn || !auditorData) return;

  // Function to generate <option> tags
  function buildOptions() {
    const auditors = JSON.parse(auditorData.textContent);
    return auditors.map(a => `<option value="${a.id}">${a.email}</option>`).join("");
  }

  // Add new support auditor dropdown
  addBtn.addEventListener("click", () => {
    let existing = container.querySelector(".support-auditor-field");

    if (!existing) {
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
    const select = clone.querySelector("select");
    select.selectedIndex = 0;
    container.appendChild(clone);
  });

  // Remove support auditor field
  container.addEventListener("click", (e) => {
    if (e.target.classList.contains("remove-support-auditor")) {
      const field = e.target.closest(".support-auditor-field");
      if (field) field.remove();
    }
  });
});
