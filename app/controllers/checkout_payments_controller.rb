class CheckoutPaymentsController < ApplicationController
  before_action :authenticate_customer!
  before_action :check_cart
  before_action :check_province, only: [:create]
  
  def new
    # Initialize session checkout info if it doesn't exist
    session[:checkout_info] ||= {}
    
    # Store checkout information in session
    session[:checkout_info] = {
      shipping_address: params[:shipping_address] || params[:order].try(:[], :shipping_address) || session[:checkout_info][:shipping_address],
      province_id: params[:province_id] || session[:checkout_info][:province_id],
      use_for_profile: params[:use_for_profile] || session[:checkout_info][:use_for_profile]
    }
    
    # Calculate cart totals
    calculate_cart_totals
    
    # Save province selection for tax calculation
    @selected_province = Province.find_by(id: params[:province_id])
  end
  
  def create
    # Calculate cart totals
    calculate_cart_totals
    
    # Process payment
    begin
      result = process_payment
      
      if result[:success]
        # Create the order after successful payment
        create_order(result[:charge])
        
        # Clear the cart and checkout info
        session[:cart] = {}
        session[:checkout_info] = nil
        
        redirect_to order_path(@order), notice: "Payment successful! Your order has been processed."
      else
        flash.now[:alert] = result[:message]
        render :new
      end
    rescue => e
      # Log the error
      Rails.logger.error "Payment error: #{e.message}"
      
      # Show a user-friendly error message
      flash.now[:alert] = "There was a problem processing your payment: #{e.message}"
      render :new
    end
  end
  
  private
  
  def check_cart
    if session[:cart].blank? || session[:cart].empty?
      redirect_to products_path, alert: "Your cart is empty." and return
    end
  end
  
  def check_province
    if params[:province_id].blank? && (session[:checkout_info].blank? || session[:checkout_info][:province_id].blank?)
      flash.now[:alert] = "Please select a province for tax calculation."
      render :new and return
    end
  end
  
  def process_payment
    begin
      # For testing, we'll use Stripe's test token instead of creating one from card details
      # This is the token for the test card 4242 4242 4242 4242
      test_token = 'tok_visa'
      
      # Calculate the total amount in cents (must be an integer)
      total_amount = @subtotal + @tax_total
      Rails.logger.info "Payment amount: #{total_amount} (#{total_amount.class})"
      
      # Convert to cents and ensure it's an integer
      # Multiply by 100 and round to avoid floating point issues
      amount_in_cents = (total_amount * 100).round
      Rails.logger.info "Amount in cents: #{amount_in_cents} (#{amount_in_cents.class})"
      
      # Create a charge using the test token
      charge = Stripe::Charge.create({
        amount: amount_in_cents, # Amount in cents as an integer
        currency: 'cad',
        source: test_token,
        description: "Payment for order from #{current_customer.email}",
        metadata: {
          customer_email: current_customer.email
        }
      })
      
      # If the charge is successful, return success
      if charge.status == 'succeeded'
        return { success: true, message: "Payment processed successfully", charge: charge }
      else
        return { success: false, message: "Payment processing failed: #{charge.failure_message}" }
      end
    rescue Stripe::CardError => e
      # Card was declined
      return { success: false, message: "Card declined: #{e.message}" }
    rescue Stripe::StripeError => e
      # Other Stripe errors
      return { success: false, message: "Payment error: #{e.message}" }
    rescue => e
      # General errors
      return { success: false, message: "An unexpected error occurred: #{e.message}" }
    end
  end
  
  def create_order(charge)
    # Get checkout info from session
    checkout_info = session[:checkout_info] || {}
    
    # Get province information
    province_id = checkout_info[:province_id] || params[:province_id]
    province = Province.find_by(id: province_id) if province_id.present?
    
    # Build the order with all details including province information
    @order = current_customer.orders.build(
      order_date: Time.current,
      total_amount: @subtotal + @tax_total,
      status: Order::STATUS_PAID, # Already paid
      gst_amount: @gst_amount,
      pst_amount: @pst_amount,
      hst_amount: @hst_amount,
      tax_total: @tax_total,
      shipping_address: checkout_info[:shipping_address] || params[:shipping_address],
      payment_id: charge.id,
      # Store province details at time of order
      province_name: province&.name,
      province_gst_rate: province&.gst_rate || 0,
      province_pst_rate: province&.pst_rate || 0,
      province_hst_rate: province&.hst_rate || 0
    )
    
    if @order.save
      # Create order items with product details
      @cart_items.each do |item|
        product = item[:product]
        @order.order_items.create(
          product_id: product.id,
          quantity: item[:quantity],
          price_at_order: product.on_sale? ? product.sale_price : product.price,
          # Store product details at time of order
          product_name: product.name,
          product_description: product.description
        )
      end
      
      # Update customer's province if requested
      if (checkout_info[:use_for_profile] == "1" || params[:use_for_profile] == "1") && 
         (checkout_info[:province_id].present? || params[:province_id].present?)
        current_customer.update(
          province_id: checkout_info[:province_id] || params[:province_id],
          address: checkout_info[:shipping_address] || params[:shipping_address]
        )
      end
    end
  end
  
  def calculate_cart_totals
    @cart_items = []
    @subtotal = 0
    
    # Process each item in the cart
    session[:cart].each do |product_id, quantity|
      product = Product.find_by(id: product_id)
      next unless product
      
      # Use sale price if product is on sale
      price = product.on_sale? ? product.sale_price : product.price
      item_subtotal = price * quantity
      @subtotal += item_subtotal
      
      @cart_items << {
        product: product,
        quantity: quantity,
        subtotal: item_subtotal
      }
    end
    
    # Calculate taxes
    calculate_taxes
  end
  
  def calculate_taxes
    @gst_amount = 0
    @pst_amount = 0
    @hst_amount = 0
    @tax_total = 0
    
    # Get province from params or session
    province_id = params[:province_id] || (session[:checkout_info].present? ? session[:checkout_info][:province_id] : nil)
    
    if province_id.present?
      province = Province.find_by(id: province_id)
      
      if province
        # Calculate tax amounts based on province rates
        @gst_amount = (@subtotal * province.gst_rate).round(2)
        @pst_amount = (@subtotal * province.pst_rate).round(2)
        @hst_amount = (@subtotal * province.hst_rate).round(2)
        
        # Calculate total tax
        @tax_total = (@gst_amount + @pst_amount + @hst_amount).round(2)
        
        # Log tax calculations for debugging
        Rails.logger.info "Tax Calculation: GST=#{@gst_amount}, PST=#{@pst_amount}, HST=#{@hst_amount}, Total=#{@tax_total}"
        
        # Make province available to the view for displaying tax rates
        @selected_province = province
      end
    end
  end
end