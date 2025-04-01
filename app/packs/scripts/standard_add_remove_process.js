document.addEventListener("DOMContentLoaded", function () {
  const standardContainer = document.getElementById("standard-container");
  const addStandardBtn = document.getElementById("add-standard");

  // Exit early if this page doesn't have standard fields
  if (!standardContainer || !addStandardBtn) return;

  // Add standard input field
  addStandardBtn.addEventListener("click", () => {
    let existingStandard = standardContainer.querySelector(".standard-field");

    if (!existingStandard) {
      existingStandard = document.createElement("div");
      existingStandard.className = "form-group mt-4 standard-field";
      existingStandard.innerHTML = `
        <div class="text-black-75 text-capitalize fs-3 mb-2 visually-hidden">
          <label for="audit_standard_standard">Applicable Standard</label>
        </div>
        <input type="text" name="audit_standard[standard][]" list="standard-options"
          class="text-black-50 text-capitalize form-control fw-semibold mb-2"
          placeholder="Type and select an applicable standard" />
        <button type="button" class="btn btn-danger btn-sm mb-2 ms-3 remove-standard"
          title="Remove Standard" aria-label="Remove Standard">⊖</button>
      `;
      standardContainer.appendChild(existingStandard);
      return;
    }

    const clone = existingStandard.cloneNode(true);
    const input = clone.querySelector("input");
    input.value = "";
    standardContainer.appendChild(clone);
  });

  // Remove standard input field
  standardContainer.addEventListener("click", (e) => {
    if (e.target.classList.contains("remove-standard")) {
      const field = e.target.closest(".standard-field");
      if (field) field.remove();
    }
  });
});
