// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

function initializeThemeToggle() {
  const toggleBtn = document.getElementById('dark-mode-toggle');
  if (!toggleBtn) return; 

  const iconCard = toggleBtn.querySelector('.icon-card');
  const labelVoid = toggleBtn.querySelector('.label-void');
  const labelEther = toggleBtn.querySelector('.label-ether');

  function updateToggleVisuals(isEther) {
    if (isEther) {
      if (iconCard) iconCard.style.transform = 'rotateY(0deg)';
      labelEther.style.opacity = '1';
      labelEther.style.color = '#FFD700';
      labelEther.style.textShadow = '0 0 8px rgba(255, 215, 0, 0.6)';
      labelVoid.style.opacity = '0.4';
      labelVoid.style.color = 'var(--text-body)';
      labelVoid.style.textShadow = 'none';
    } else {
      if (iconCard) iconCard.style.transform = 'rotateY(180deg)';
      labelVoid.style.opacity = '1';
      labelVoid.style.color = 'var(--text-body)';
      labelVoid.style.textShadow = '0 0 8px rgba(255, 255, 255, 0.2)';
      labelEther.style.opacity = '0.4';
      labelEther.style.color = 'var(--text-body)';
      labelEther.style.textShadow = 'none';
    }
  }

  // Check state on load from either the root element or body element
  const isLightModeNow = document.documentElement.classList.contains('light-theme') || document.body.classList.contains('light-theme'); 
  
  // Sync elements in case head script only modified documentElement
  if (isLightModeNow) {
    document.body.classList.add('light-theme');
  }

  updateToggleVisuals(isLightModeNow);

  // Click Handler
  toggleBtn.addEventListener('click', () => {
    const wasLightMode = document.body.classList.contains('light-theme');
    const willBeLightMode = !wasLightMode;

    if (willBeLightMode) {
      document.body.classList.add('light-theme');
      document.documentElement.classList.add('light-theme');
      localStorage.setItem('theme', 'light');
    } else {
      document.body.classList.remove('light-theme');
      document.documentElement.classList.remove('light-theme');
      localStorage.setItem('theme', 'dark');
    }
    
    updateToggleVisuals(willBeLightMode); 
  });
}

// Ensure execution across all dynamic Turbo page switches
document.addEventListener('turbo:load', initializeThemeToggle);
document.addEventListener('turbo:render', initializeThemeToggle);