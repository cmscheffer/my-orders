// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

// Import jQuery
import jquery from "jquery"
window.jQuery = jquery
window.$ = jquery

// Import Popper.js (required for Bootstrap dropdowns)
import * as Popper from "@popperjs/core"
window.Popper = Popper

// Import Bootstrap - usando a versão bundle que já inclui Popper
import * as bootstrap from "bootstrap"
window.bootstrap = bootstrap

// Initialize Bootstrap components on Turbo load
document.addEventListener("turbo:load", () => {
  // Initialize tooltips
  const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
  const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl))

  // Initialize popovers
  const popoverTriggerList = document.querySelectorAll('[data-bs-toggle="popover"]')
  const popoverList = [...popoverTriggerList].map(popoverTriggerEl => new bootstrap.Popover(popoverTriggerEl))
})
