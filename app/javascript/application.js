
import "@hotwired/turbo-rails"
import "controllers"
import * as ActiveStorage from "@rails/activestorage"

ActiveStorage.start()

// Retrieve the saved theme or use the system preference
function getPreferredTheme() {
  const savedTheme = localStorage.getItem("theme");

  if (savedTheme === "light" || savedTheme === "dark") {
    return savedTheme;
  }

  return window.matchMedia("(prefers-color-scheme: light)").matches
    ? "light"
    : "dark";
}

// Update the theme toggle button appearance
function updateToggleVisuals(isEther) {
  const toggleBtn = document.getElementById("dark-mode-toggle");

  if (!toggleBtn) return;

  const iconCard = toggleBtn.querySelector(".icon-card");
  const labelVoid = toggleBtn.querySelector(".label-void");
  const labelEther = toggleBtn.querySelector(".label-ether");

  if (!iconCard || !labelVoid || !labelEther) return;

  toggleBtn.setAttribute("aria-pressed", String(isEther));

  if (isEther) {
    iconCard.style.transform = "rotateY(0deg)";

    labelEther.style.opacity = "1";
    labelEther.style.color = "#b45309";
    labelEther.style.textShadow =
      "0 0 12px rgba(245, 158, 11, 0.2)";

    labelVoid.style.opacity = "0.5";
    labelVoid.style.color = "var(--text-muted)";
    labelVoid.style.textShadow = "none";
  } else {
    iconCard.style.transform = "rotateY(180deg)";

    labelVoid.style.opacity = "1";
    labelVoid.style.color = "var(--text-body)";
    labelVoid.style.textShadow =
      "0 0 8px rgba(255, 255, 255, 0.2)";

    labelEther.style.opacity = "0.4";
    labelEther.style.color = "var(--text-muted)";
    labelEther.style.textShadow = "none";
  }
}

// Apply the theme consistently throughout the application
function applyTheme(theme) {
  const isEther = theme === "light";
  const themeName = isEther ? "ether" : "void";

  const root = document.documentElement;

  root.classList.toggle("light-theme", isEther);
  root.dataset.theme = themeName;

  if (document.body) {
    document.body.classList.toggle("light-theme", isEther);
    document.body.dataset.theme = themeName;
  }

  updateToggleVisuals(isEther);
}

// Synchronize the theme after page navigation
function initializeTheme() {
  applyTheme(getPreferredTheme());
}

// A single delegated click listener survives Turbo navigation
document.addEventListener("click", (event) => {
  const toggleBtn = event.target.closest("#dark-mode-toggle");

  if (!toggleBtn) return;

  const isEther =
    document.documentElement.dataset.theme === "ether";

  const nextTheme = isEther ? "dark" : "light";

  localStorage.setItem("theme", nextTheme);

  applyTheme(nextTheme);
});

// Synchronize newly rendered pages without adding click listeners
document.addEventListener("turbo:load", initializeTheme);
document.addEventListener("turbo:render", initializeTheme);

// Initialize the current page
initializeTheme();
