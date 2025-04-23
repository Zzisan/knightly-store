// Tax calculator for checkout page
// Make the function globally available
window.updateTaxCalculation = function(provinceId) {
    // Show loading indicator
    document.getElementById('tax-loading').style.display = 'block';
    
    // Make AJAX request to get tax calculation
    fetch(`/checkouts/calculate_taxes_for_province?province_id=${provinceId}`, {
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.json())
    .then(data => {
      // Update tax information in the UI
      document.getElementById('subtotal-amount').textContent = formatCurrency(data.subtotal);
      
      // Update GST
      const gstRow = document.getElementById('gst-row');
      if (data.gst_amount > 0) {
        document.getElementById('gst-amount').textContent = formatCurrency(data.gst_amount);
        document.getElementById('gst-rate').textContent = formatPercentage(data.province.gst_rate);
        gstRow.style.display = 'table-row';
      } else {
        gstRow.style.display = 'none';
      }
      
      // Update PST
      const pstRow = document.getElementById('pst-row');
      if (data.pst_amount > 0) {
        document.getElementById('pst-amount').textContent = formatCurrency(data.pst_amount);
        document.getElementById('pst-rate').textContent = formatPercentage(data.province.pst_rate);
        pstRow.style.display = 'table-row';
      } else {
        pstRow.style.display = 'none';
      }
      
      // Update HST
      const hstRow = document.getElementById('hst-row');
      if (data.hst_amount > 0) {
        document.getElementById('hst-amount').textContent = formatCurrency(data.hst_amount);
        document.getElementById('hst-rate').textContent = formatPercentage(data.province.hst_rate);
        hstRow.style.display = 'table-row';
      } else {
        hstRow.style.display = 'none';
      }
      
      // Update tax total
      document.getElementById('tax-total').textContent = formatCurrency(data.tax_total);
      
      // Update grand total
      document.getElementById('grand-total').textContent = formatCurrency(data.grand_total);
      
      // Update order summary section
      document.getElementById('order-subtotal').textContent = formatCurrency(data.subtotal);
      document.getElementById('order-tax-total').textContent = formatCurrency(data.tax_total);
      
      // Update province name in the tax invoice header
      document.getElementById('province-name').textContent = data.province.name;
      
      // Hide loading indicator
      document.getElementById('tax-loading').style.display = 'none';
      
      // Show tax invoice section
      document.getElementById('tax-invoice-content').style.display = 'block';
      document.getElementById('tax-invoice-empty').style.display = 'none';
    })
    .catch(error => {
      console.error('Error fetching tax calculation:', error);
      document.getElementById('tax-loading').style.display = 'none';
    });
  }
  
  function formatCurrency(amount) {
    return new Intl.NumberFormat('en-CA', { 
      style: 'currency', 
      currency: 'CAD' 
    }).format(amount);
  }
  
  function formatPercentage(rate) {
    return new Intl.NumberFormat('en-CA', { 
      style: 'percent',
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    }).format(rate);
  }
};

// Initialize tax calculation when the page loads
document.addEventListener('DOMContentLoaded', function() {
  const provinceDropdown = document.getElementById('province_id');
  if (provinceDropdown && provinceDropdown.value) {
    updateTaxCalculation(provinceDropdown.value);
  }
});