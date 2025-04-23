# config/importmap.rb

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true

# Custom JavaScript modules
pin "cart_manager", to: "cart_manager.js", preload: true
pin "checkout_tax_calculator", to: "checkout_tax_calculator.js", preload: true

# Add any other libraries you want pinned here, for example:
# pin "some-library", to: "https://cdn.jsdelivr.net/npm/some-library/dist/index.js"
