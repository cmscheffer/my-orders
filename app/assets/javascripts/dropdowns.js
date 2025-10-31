// Dropdowns initialization for Bootstrap 5
console.log("🚀 dropdowns.js carregado!");

// Initialize Bootstrap dropdowns
function initializeDropdowns() {
  console.log("🔄 Inicializando dropdowns...");
  
  // Check if Bootstrap is loaded
  if (typeof bootstrap === 'undefined') {
    console.error("❌ Bootstrap não está carregado!");
    return;
  }
  
  console.log("✅ Bootstrap detectado:", bootstrap);
  
  // Find all dropdown toggles
  const dropdownElements = document.querySelectorAll('[data-bs-toggle="dropdown"]');
  console.log("📋 Dropdowns encontrados:", dropdownElements.length);
  
  // Initialize each dropdown
  dropdownElements.forEach((element, index) => {
    console.log(`Inicializando dropdown ${index + 1}:`, element);
    
    // Create dropdown instance
    const dropdown = new bootstrap.Dropdown(element);
    
    // Add click handler
    element.addEventListener('click', function(e) {
      e.preventDefault();
      e.stopPropagation();
      console.log("🖱️ CLIQUE no dropdown:", this);
      dropdown.toggle();
    });
    
    console.log(`✅ Dropdown ${index + 1} inicializado!`);
  });
  
  console.log("✨ Todos os dropdowns inicializados!");
}

// Run when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeDropdowns);
} else {
  initializeDropdowns();
}

// Also run on Turbo navigation
document.addEventListener('turbo:load', initializeDropdowns);

console.log("✅ dropdowns.js configurado!");
