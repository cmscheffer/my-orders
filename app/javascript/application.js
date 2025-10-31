// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

// jQuery, Popper and Bootstrap are loaded via <script> tags in application.html.erb
// They are available globally as window.jQuery, window.$, window.Popper, and window.bootstrap

// Initialize Bootstrap components on Turbo load and page load
function initializeBootstrapComponents() {
  // Initialize tooltips
  const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
  const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl))

  // Initialize popovers
  const popoverTriggerList = document.querySelectorAll('[data-bs-toggle="popover"]')
  const popoverList = [...popoverTriggerList].map(popoverTriggerEl => new bootstrap.Popover(popoverTriggerEl))
}

// Initialize on first load
document.addEventListener("DOMContentLoaded", initializeBootstrapComponents)

// Initialize on Turbo navigation
document.addEventListener("turbo:load", initializeBootstrapComponents)
