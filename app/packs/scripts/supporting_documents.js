document.addEventListener("DOMContentLoaded", () => {
    const addButton = document.getElementById("submit-button") || null;
    const form = document.getElementById("upload-the-document")|| null;
    const fileInput = document.getElementById("document-upload")|| null;
    const attachmentSection = document.querySelector(".rectangle-attachments") || null;
  if (addButton && form && fileInput && attachmentSection) {
    // This is a listener for displaying the file's details
    fileInput.addEventListener("change", (e) => {
      const file = e.target.files[0];
      if (file) {
        const fileName = file.name;
        //Turning the size into kilobytes, we can change it for bigger files
        const fileSize = (file.size / 1024).toFixed(2); 

        // Allow the user to preview the file
        const preview = document.createElement("div");
        preview.classList.add("file-preview");
        preview.innerHTML = `
          <p>${fileName} (${fileSize} KB)
            <a href="#" class="remove-preview">X</a>
          </p>
          <p><a href="${URL.createObjectURL(file)}" target="_blank">View File</a></p>
        `;

        // Put the file under attachments
        const attachmentParagraph = attachmentSection.querySelector("p:nth-of-type(2)");
        attachmentSection.insertBefore(preview, attachmentParagraph.nextSibling);
        
        // Add listener to the remove button too
        const removeButton = preview.querySelector(".remove-preview");
        removeButton.addEventListener("click", (e) => {
          e.preventDefault(); 
          preview.remove();   
          fileInput.value = ''; 
        });
      }
    });

    // Only submit the form after adding 
    addButton.addEventListener("click", (e) => {
      e.preventDefault(); 
      
      // Check the details before submitting
      if (form.checkValidity()) {
        form.submit();     
      } else {
        alert("Please fill in the required fields.");
      }
    });
  }
  });