function openNav() {
  document.getElementById("mySidenav").style.width = "250px";
}

function closeNav() {
  document.getElementById("mySidenav").style.width = "0";
}

// Make them global (dont forget to do it too)
window.openNav = openNav;
window.closeNav = closeNav;

document.addEventListener("DOMContentLoaded", function () {
  let dropdowns = document.querySelectorAll(".dropdown-btn");

  dropdowns.forEach(function (btn) {
      btn.addEventListener("click", function () {
          let dropdownContainer = this.nextElementSibling;

          if (dropdownContainer.classList.contains("show")) {
              dropdownContainer.classList.remove("show");
          } else {
              document.querySelectorAll(".dropdown-container").forEach(function (container) {
                  container.classList.remove("show");
              });
              dropdownContainer.classList.add("show");
          }
      });
  });
});
