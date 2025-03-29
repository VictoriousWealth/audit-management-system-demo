// Wait for the entire DOM to load before running the script
document.addEventListener("DOMContentLoaded", function () {
    // Get the container that will hold all the standard input fields
    const standardContainer = document.getElementById("standard-container");
    
    // Get the button that will be used to add a new standard input field
    const addStandardBtn = document.getElementById("add-standard");
  
    // When the 'Add Standard' button is clicked
    addStandardBtn.addEventListener("click", () => {
      // Try to find an existing standard input field in the container
      let existingStandard = standardContainer.querySelector(".standard-field");
  
      // If none exists, create a new one from scratch
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
        // Append the newly created standard field to the container
        standardContainer.appendChild(existingStandard);
        return; // Exit after adding the first input
      }
  
      // If a standard input field already exists, clone it
      const clone = existingStandard.cloneNode(true);
      const input = clone.querySelector("input");
      input.value = ""; // Clear the input value
  
      // Append the cloned input field to the container
      standardContainer.appendChild(clone);
    });
  
    // Event delegation for removing standard fields
    standardContainer.addEventListener("click", (e) => {
      // Check if the clicked element is a 'Remove Standard' button
      if (e.target.classList.contains("remove-standard")) {
        // Find the closest parent element with the class 'standard-field'
        const field = e.target.closest(".standard-field");
        // Only remove if at least one standard-field exists
        if (document.querySelectorAll(".standard-field").length > 0) {
          field.remove();
        }
      }
    });
  });
  