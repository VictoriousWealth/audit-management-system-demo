document.addEventListener("DOMContentLoaded", function () {
  const select = document.getElementById("audit-select");
  const form = document.getElementById("closure-letter-dropdown-form");
  const button = document.getElementById("start-letter-btn");

  if (select && button) {
    select.addEventListener("change", function () {
      button.disabled = !select.value;
    });

    // Disable the button initially if no value
    button.disabled = !select.value;
  }

  if (form && select) {
    form.addEventListener("submit", function (e) {
      e.preventDefault();
      if (select.value) {
        const auditId = select.value;
        window.location.href = `/audits/${auditId}/audit_closure_letters/new`;
      }
    });
  }
});
