// app/javascript/application.js
import "@hotwired/turbo-rails"

// Import our custom modules
import "./checkout_tax_calculator"
import { initializeCart, updateCartCount } from "./cart_manager"

// Initialize cart functionality when DOM is loaded
document.addEventListener('turbo:load', function() {
  console.log('Turbo load event fired - initializing cart');
  initializeCart();
  updateCartCount();
});

// Also initialize on DOMContentLoaded for non-Turbo pages
document.addEventListener('DOMContentLoaded', function() {
  console.log('DOMContentLoaded event fired - initializing cart');
  initializeCart();
  updateCartCount();
});
