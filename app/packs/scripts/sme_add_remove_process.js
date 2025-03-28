// Run the script once the DOM has fully loaded
document.addEventListener("DOMContentLoaded", function () {
    // Get the container where SME fields will be added
    const smeContainer = document.getElementById("sme-container");
  
    // Get the button that adds a new SME dropdown field
    const addSMEBtn = document.getElementById("add-sme");
  
    // Add event listener to handle adding new SME fields
    addSMEBtn.addEventListener("click", () => {
      // Try to find an existing SME field in the container
      let existingSME = smeContainer.querySelector(".sme-field");
  
      // If none exists, create the first one from scratch
      if (!existingSME) {
        existingSME = document.createElement("div");
        existingSME.className = "form-group mt-4 sme-field";
  
        // Populate the field with a dropdown and a remove button
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
        
        // Add the newly created SME field to the container
        smeContainer.appendChild(existingSME);
        return; // Stop here after adding the first one
      }
  
      // If an SME field already exists, clone it
      const clone = existingSME.cloneNode(true);
      const select = clone.querySelector("select");
  
      // Reset the selected option
      select.selectedIndex = 0;
  
      // Append the cloned SME field to the container
      smeContainer.appendChild(clone);
    });
  
    // Event delegation to handle removing SME fields
    smeContainer.addEventListener("click", (e) => {
      // If the clicked button is a remove button
      if (e.target.classList.contains("remove-sme")) {
        const field = e.target.closest(".sme-field");
        if (document.querySelectorAll(".sme-field").length > 0) {
          field.remove(); // Remove the field from the DOM
        }
      }
    });
  
    // Function that generates the <option> tags for the SME <select>
    function buildSMEOptions() {
      // Get user data from the hidden element containing JSON
      const users = JSON.parse(document.getElementById("user-data").textContent);
  
      // Map each user to an <option> tag and join into a string
      return users.map(u => `<option value="${u.id}">${u.email}</option>`).join("");
    }
  });
  