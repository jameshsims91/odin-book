// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()
function initializeThemeToggle() {
  const toggleBtn = document.getElementById('dark-mode-toggle');
  if (!toggleBtn) return; // Guard clause in case the button isn't on the current page

  const knob = toggleBtn.querySelector('.mini-knob');
  const trail = toggleBtn.querySelector('.mini-trail');
  const labelVoid = toggleBtn.querySelector('.label-void');
  const labelEther = toggleBtn.querySelector('.label-ether');

  function updateToggleVisuals(isEther) {
    if (isEther) {
      knob.style.transform = 'translateX(16px)';
      trail.style.width = '20px';
      labelEther.style.opacity = '1';
      labelEther.style.color = '#FFD700';
      labelEther.style.textShadow = '0 0 8px rgba(255, 215, 0, 0.6)';
      labelVoid.style.opacity = '0.4';
      labelVoid.style.color = 'var(--text-body)';
      labelVoid.style.textShadow = 'none';
    } else {
      knob.style.transform = 'translateX(0px)';
      trail.style.width = '0px';
      labelVoid.style.opacity = '1';
      labelVoid.style.color = 'var(--text-body)';
      labelVoid.style.textShadow = '0 0 8px rgba(255, 255, 255, 0.2)';
      labelEther.style.opacity = '0.4';
      labelEther.style.color = 'var(--text-body)';
      labelEther.style.textShadow = 'none';
    }
  }

  // Set the initial visual state based on your app's active class on page load
  const isLightModeNow = document.body.classList.contains('light-theme'); // Update 'light-theme' to match your setup
  updateToggleVisuals(isLightModeNow);

  // Click Handler
  toggleBtn.addEventListener('click', () => {
    // 1. Run your existing theme switching logic here (e.g., adding classes, saving to local storage)
    document.body.classList.toggle('light-theme'); 
    
    // 2. Animate the Golden Thread elements
    const updatedState = document.body.classList.contains('light-theme');
    updateToggleVisuals(updatedState); 
  });
}

// Listen to Turbo loads so the switch functions properly across page transitions
document.addEventListener('turbo:load', initializeThemeToggle);