document.addEventListener("DOMContentLoaded", function () {
  const select = document.getElementById("audit-select");
  const form = document.getElementById("closure-letter-dropdown-form");
  const button = document.getElementById("start-letter-btn");

  select.addEventListener("change", function () {
    button.disabled = !select.value;
  });

  form.addEventListener("submit", function (e) {
    e.preventDefault();
    if (select.value) {
      const auditId = select.value;
      window.location.href = `/audits/${auditId}/audit_closure_letters/new`;
    }
  });
})