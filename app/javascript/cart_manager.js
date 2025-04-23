// Cart Manager - Handles cart operations and notifications

// Export functions for use in other modules
export function initializeCart() {
  console.log('Initializing cart functionality');
  
  // Find all add-to-cart buttons
  const addToCartButtons = document.querySelectorAll('.add-to-cart-btn');
  console.log(`Found ${addToCartButtons.length} add-to-cart buttons`);
  
  // Add event listeners to all add-to-cart buttons
  addToCartButtons.forEach(button => {
    button.addEventListener('click', function(event) {
      event.preventDefault();
      console.log('Add to cart button clicked');
      
      const productId = this.getAttribute('data-product-id');
      console.log(`Product ID: ${productId}`);
      
      const quantityInput = document.querySelector(`input[data-product-id="${productId}"]`);
      const quantity = quantityInput ? parseInt(quantityInput.value) : 1;
      console.log(`Quantity: ${quantity}`);
      
      // Add the product to the cart
      addToCart(productId, quantity);
    });
  });
}

export function updateCartCount(count) {
  // Get the cart count from the server if not provided
  if (count === undefined) {
    fetch('/cart.json', {
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      },
      credentials: 'same-origin'
    })
    .then(response => response.json())
    .then(data => {
      const cartCount = Object.values(data.cart || {}).reduce((a, b) => a + b, 0);
      updateCartCountDisplay(cartCount);
    })
    .catch(error => {
      console.error('Error fetching cart count:', error);
      // Try to get the count from the DOM as a fallback
      const cartCountElement = document.getElementById('cart-count');
      if (cartCountElement && cartCountElement.textContent) {
        updateCartCountDisplay(parseInt(cartCountElement.textContent) || 0);
      }
    });
  } else {
    updateCartCountDisplay(count);
  }
}

export function addToCart(productId, quantity = 1) {
  // Show loading state
  const button = document.querySelector(`.add-to-cart-btn[data-product-id="${productId}"]`);
  if (button) {
    const originalText = button.innerHTML;
    button.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Adding...';
    button.disabled = true;
  }
  
  // Get CSRF token
  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
  
  // Make AJAX request to add the product to the cart
  fetch(`/cart/add/${productId}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': csrfToken || ''
    },
    credentials: 'same-origin',
    body: JSON.stringify({ quantity: quantity })
  })
  .then(response => response.json())
  .then(data => {
    // Reset button state
    if (button) {
      button.innerHTML = 'Added!';
      setTimeout(() => {
        button.innerHTML = originalText;
        button.disabled = false;
      }, 1000);
    }
    
    // Update cart count
    updateCartCount(data.cart_count);
    
    // Show notification
    showCartNotification(data);
  })
  .catch(error => {
    console.error('Error adding to cart:', error);
    
    // Reset button state
    if (button) {
      button.innerHTML = 'Error';
      setTimeout(() => {
        button.innerHTML = originalText;
        button.disabled = false;
      }, 1000);
    }
  });
}

function updateCartCount(count) {
  // Get the cart count from the server if not provided
  if (count === undefined) {
    fetch('/cart.json', {
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      },
      credentials: 'same-origin'
    })
    .then(response => response.json())
    .then(data => {
      const cartCount = Object.values(data.cart || {}).reduce((a, b) => a + b, 0);
      updateCartCountDisplay(cartCount);
    })
    .catch(error => {
      console.error('Error fetching cart count:', error);
      // Try to get the count from the DOM as a fallback
      const cartCountElement = document.getElementById('cart-count');
      if (cartCountElement && cartCountElement.textContent) {
        updateCartCountDisplay(parseInt(cartCountElement.textContent) || 0);
      }
    });
  } else {
    updateCartCountDisplay(count);
  }
}

export function updateCartCountDisplay(count) {
  // Update the cart count in the header
  const cartCountElement = document.getElementById('cart-count');
  if (cartCountElement) {
    cartCountElement.textContent = count;
    
    // Show/hide based on count
    if (count > 0) {
      cartCountElement.style.display = 'inline-block';
    } else {
      cartCountElement.style.display = 'none';
    }
  }
}

export function showCartNotification(data) {
  // Remove any existing notification
  const existingNotification = document.getElementById('cart-notification');
  if (existingNotification) {
    existingNotification.remove();
  }
  
  // Create notification element
  const notification = document.createElement('div');
  notification.id = 'cart-notification';
  notification.className = 'cart-notification';
  
  // Create notification content
  notification.innerHTML = `
    <div class="cart-notification-header">
      <h5>Added to Cart</h5>
      <button type="button" class="btn-close" aria-label="Close"></button>
    </div>
    <div class="cart-notification-body">
      <div class="cart-notification-product">
        ${data.product.image_url ? `<img src="${data.product.image_url}" alt="${data.product.name}" class="cart-notification-image">` : ''}
        <div class="cart-notification-details">
          <p class="cart-notification-name">${data.product.name}</p>
          <p class="cart-notification-price">${formatCurrency(data.product.price)}</p>
        </div>
      </div>
    </div>
    <div class="cart-notification-footer">
      <a href="/cart" class="btn btn-outline-primary btn-sm">View Cart</a>
      <a href="/checkouts/preview_invoice" class="btn btn-outline-info btn-sm">View Tax Invoice</a>
      <a href="/checkouts/new" class="btn btn-primary btn-sm">Checkout</a>
    </div>
  `;
  
  // Add notification to the page
  document.body.appendChild(notification);
  
  // Add event listener to close button
  notification.querySelector('.btn-close').addEventListener('click', function() {
    notification.classList.add('cart-notification-hiding');
    setTimeout(() => {
      notification.remove();
    }, 300);
  });
  
  // Show notification with animation
  setTimeout(() => {
    notification.classList.add('cart-notification-visible');
  }, 10);
  
  // Auto-hide notification after 5 seconds
  setTimeout(() => {
    notification.classList.add('cart-notification-hiding');
    setTimeout(() => {
      notification.remove();
    }, 300);
  }, 5000);
}

export function formatCurrency(amount) {
  return new Intl.NumberFormat('en-CA', { 
    style: 'currency', 
    currency: 'CAD' 
  }).format(amount);
}