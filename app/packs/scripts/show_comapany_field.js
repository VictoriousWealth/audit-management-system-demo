document.addEventListener("DOMContentLoaded", function() {

    var roleSelect = document.getElementById("role_select");
    var companyField = document.getElementById("company_field");
    
    roleSelect.addEventListener("change", function() {
      if (this.value === "auditee") {
        companyField.style.display = "block";
      } else {
        companyField.style.display = "none";
      }
    });
});