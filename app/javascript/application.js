// Entry point for the build script in your package.json
console.log("🚀 application.js carregado!")

// Try to import Turbo and controllers, but don't fail if they error
try {
  await import("@hotwired/turbo-rails")
  console.log("✅ Turbo carregado")
} catch (error) {
  console.warn("⚠️ Erro ao carregar Turbo:", error)
}

try {
  await import("./controllers")
  console.log("✅ Controllers carregados")
} catch (error) {
  console.warn("⚠️ Erro ao carregar controllers:", error)
}

// jQuery, Popper and Bootstrap are loaded via <script> tags in application.html.erb
// They are available globally as window.jQuery, window.$, window.Popper, and window.bootstrap

// Initialize Bootstrap components on Turbo load and page load
function initializeBootstrapComponents() {
  console.log("🔄 Inicializando componentes Bootstrap...")
  
  // Verify Bootstrap is loaded
  if (typeof bootstrap === 'undefined') {
    console.error("❌ Bootstrap não está carregado!")
    return
  }
  
  // Initialize all dropdowns manually WITH CLICK HANDLERS
  const dropdownElementList = document.querySelectorAll('[data-bs-toggle="dropdown"]')
  console.log("📋 Dropdowns encontrados:", dropdownElementList.length)
  
  dropdownElementList.forEach((dropdownToggleEl) => {
    // Check if already initialized to avoid duplicates
    if (!dropdownToggleEl.dataset.bsInitialized) {
      // Create Bootstrap dropdown instance
      const dropdown = new bootstrap.Dropdown(dropdownToggleEl)
      
      // Add manual click handler to ensure it works
      dropdownToggleEl.addEventListener('click', function(e) {
        e.preventDefault()
        e.stopPropagation()
        console.log("🖱️ Clique detectado no dropdown:", this)
        dropdown.toggle()
      })
      
      dropdownToggleEl.dataset.bsInitialized = 'true'
      console.log("✅ Dropdown inicializado com handler:", dropdownToggleEl)
    }
  })
  
  // Initialize tooltips
  const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
  const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => {
    if (!tooltipTriggerEl.dataset.bsInitialized) {
      const tooltip = new bootstrap.Tooltip(tooltipTriggerEl)
      tooltipTriggerEl.dataset.bsInitialized = 'true'
      return tooltip
    }
  })

  // Initialize popovers
  const popoverTriggerList = document.querySelectorAll('[data-bs-toggle="popover"]')
  const popoverList = [...popoverTriggerList].map(popoverTriggerEl => {
    if (!popoverTriggerEl.dataset.bsInitialized) {
      const popover = new bootstrap.Popover(popoverTriggerEl)
      popoverTriggerEl.dataset.bsInitialized = 'true'
      return popover
    }
  })
  
  console.log("✨ Componentes Bootstrap inicializados!")
}

// Initialize on first load
document.addEventListener("DOMContentLoaded", () => {
  console.log("📄 DOMContentLoaded disparado")
  initializeBootstrapComponents()
})

// Initialize on Turbo navigation
document.addEventListener("turbo:load", () => {
  console.log("🚀 Turbo:load disparado")
  initializeBootstrapComponents()
})

console.log("✅ application.js carregado completamente!")
