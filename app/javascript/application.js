// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

// Import jQuery and Bootstrap
import jquery from "jquery"
window.jQuery = jquery
window.$ = jquery

import "bootstrap"

// Initialize Bootstrap tooltips and popovers
document.addEventListener("turbo:load", () => {
  // Initialize tooltips
  const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
  const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl))

  // Initialize popovers
  const popoverTriggerList = document.querySelectorAll('[data-bs-toggle="popover"]')
  const popoverList = [...popoverTriggerList].map(popoverTriggerEl => new bootstrap.Popover(popoverTriggerEl))
})
