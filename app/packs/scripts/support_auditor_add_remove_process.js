// Ensure the DOM is fully loaded before running the script
document.addEventListener("DOMContentLoaded", function () {
    // Get the container that will hold all support auditor fields
    const container = document.getElementById("support-auditor-container");
  
    // Get the button to add new support auditor dropdowns
    const addBtn = document.getElementById("add-support-auditor");
  
    // Event listener for adding a new support auditor field
    addBtn.addEventListener("click", () => {
      // Try to find an existing field inside the container
      let existing = container.querySelector(".support-auditor-field");
  
      // If none exists, create the first one from scratch
      if (!existing) {
        existing = document.createElement("div");
        existing.className = "form-group mt-4 support-auditor-field";
  
        // Create the HTML structure for the field, including the dropdown and remove button
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
  
        // Append it to the container and stop further execution
        container.appendChild(existing);
        return;
      }
  
      // If a field already exists, clone it
      const clone = existing.cloneNode(true);
  
      // Reset the dropdown to default
      const select = clone.querySelector("select");
      select.selectedIndex = 0;
  
      // Append the cloned field to the container
      container.appendChild(clone);
    });
  
    // Event delegation to handle removal of dynamically added fields
    container.addEventListener("click", (e) => {
      if (e.target.classList.contains("remove-support-auditor")) {
        const field = e.target.closest(".support-auditor-field");
  
        // Remove the field from the DOM
        if (document.querySelectorAll(".support-auditor-field").length > 0) {
          field.remove();
        }
      }
    });
  
    // Helper function to build <option> tags from a list of auditors in a hidden JSON element
    function buildOptions() {
      const auditors = JSON.parse(document.getElementById("auditor-data").textContent);
      return auditors.map(a => `<option value="${a.id}">${a.email}</option>`).join("");
    }
  });
  