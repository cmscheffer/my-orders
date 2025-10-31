// Bootstrap 5 Dropdowns Initialization
// This file manually initializes Bootstrap dropdowns to ensure compatibility with Turbo

(function() {
  'use strict';
  
  // Initialize Bootstrap dropdowns
  function initializeDropdowns() {
    // Verify Bootstrap is loaded
    if (typeof bootstrap === 'undefined') {
      console.error('Bootstrap não está carregado. Dropdowns não funcionarão.');
      return;
    }
    
    // Find all dropdown toggles
    const dropdownElements = document.querySelectorAll('[data-bs-toggle="dropdown"]');
    
    if (dropdownElements.length === 0) {
      return; // No dropdowns on this page
    }
    
    // Initialize each dropdown with click handler
    dropdownElements.forEach(function(element) {
      // Skip if already initialized
      if (element.dataset.dropdownInitialized) {
        return;
      }
      
      // Create Bootstrap dropdown instance
      const dropdown = new bootstrap.Dropdown(element);
      
      // Add click handler to ensure it works with Turbo
      element.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        dropdown.toggle();
      });
      
      // Mark as initialized
      element.dataset.dropdownInitialized = 'true';
    });
  }
  
  // Initialize on DOM ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeDropdowns);
  } else {
    initializeDropdowns();
  }
  
  // Re-initialize on Turbo navigation
  document.addEventListener('turbo:load', initializeDropdowns);
  
})();
