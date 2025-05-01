document.addEventListener("DOMContentLoaded", function () {
  const select = document.getElementById("audit-select");
  const form = document.getElementById("closure-letter-dropdown-form");
  const button = document.getElementById("start-letter-btn");

  if (select) {
    select.addEventListener("change", function () {
      button.disabled = !select.value;
    });
  }

  if (form) {
    form.addEventListener("submit", function (e) {
      e.preventDefault();
      if (select.value) {
        const auditId = select.value;
        window.location.href = `/audits/${auditId}/audit_closure_letters/new`;
      }
    });
  }
})