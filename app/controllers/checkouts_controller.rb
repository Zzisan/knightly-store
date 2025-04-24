class CheckoutsController < ApplicationController
  before_action :authenticate_customer!
  before_action :check_cart, except: [:calculate_taxes_for_province]
  before_action :check_province, only: [:create]

  def new
    @order = Order.new
    @provinces = Province.all.order(:name)
    
    # Use customer's address if available
    if current_customer.address.present?
      @order.shipping_address = current_customer.address
    end
    
    # Calculate cart totals
    calculate_cart_totals
  end

  def create
    # Calculate cart totals and tax amounts
    calculate_cart_totals
    
    # Build the order with all details
    @order = current_customer.orders.build(order_params.merge(
      order_date: Time.current,
      total_amount: @subtotal + @tax_total,
      status: "pending",
      gst_amount: @gst_amount,
      pst_amount: @pst_amount,
      hst_amount: @hst_amount,
      tax_total: @tax_total,
      shipping_address: params[:order][:shipping_address]
    ))

    if @order.save
      # Create order items
      @cart_items.each do |item|
        @order.order_items.create(
          product_id: item[:product].id,
          quantity: item[:quantity],
          price_at_order: item[:product].price
        )
      end
      
      # Update customer's province if provided
      if params[:use_for_profile] == "1" && params[:province_id].present?
        current_customer.update(
          province_id: params[:province_id],
          address: params[:shipping_address]
        )
      end
      
      # Clear the cart
      session[:cart] = {}
      redirect_to new_order_payment_path(@order), notice: "Order placed successfully! Please complete your payment."
    else
      @provinces = Province.all.order(:name)
      render :new
    end
  end
  
  # AJAX endpoint to calculate taxes for a selected province
  def calculate_taxes_for_province
    # Set the province_id from the AJAX request
    params[:province_id] = params[:province_id]
    
    # Skip default province to ensure we use the selected one
    params[:skip_default_province] = true
    
    # Calculate cart totals with the new province
    calculate_cart_totals
    
    # Render the tax calculation as JSON
    respond_to do |format|
      format.json {
        render json: {
          subtotal: @subtotal,
          gst_amount: @gst_amount,
          pst_amount: @pst_amount,
          hst_amount: @hst_amount,
          tax_total: @tax_total,
          grand_total: @subtotal + @tax_total,
          province: @selected_province ? {
            name: @selected_province.name,
            gst_rate: @selected_province.gst_rate,
            pst_rate: @selected_province.pst_rate,
            hst_rate: @selected_province.hst_rate
          } : nil
        }
      }
    end
  end
  
  # Preview invoice before checkout
  def preview_invoice
    @provinces = Province.all.order(:name)
    
    # Set the province_id if provided
    if params[:province_id].present?
      params[:skip_default_province] = true
    end
    
    # Calculate cart totals with the selected province
    calculate_cart_totals
    
    # Create a new order for the form
    @order = Order.new
    if current_customer.address.present?
      @order.shipping_address = current_customer.address
    end
  end

  private

  def check_cart
    if session[:cart].blank? || session[:cart].empty?
      redirect_to products_path, alert: "Your cart is empty." and return
    end
  end
  
  def check_province
    if params[:province_id].blank?
      @provinces = Province.all.order(:name)
      @order = Order.new(order_params)
      calculate_cart_totals
      flash.now[:alert] = "Please select a province for tax calculation."
      render :new and return
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
    
    # Calculate taxes if province is selected
    calculate_taxes
  end
  
  def calculate_taxes
    @gst_amount = 0
    @pst_amount = 0
    @hst_amount = 0
    @tax_total = 0
    
    # Determine which province to use for tax calculation
    province = nil
    
    if params[:province_id].present?
      # Use the province selected in the form
      province = Province.find_by(id: params[:province_id])
    elsif current_customer.province.present? && !params[:skip_default_province]
      # Use customer's saved province if available
      province = current_customer.province
    end
    
    # Calculate taxes if we have a province
    if province
      # Calculate tax amounts based on province rates
      @gst_amount = (@subtotal * province.gst_rate).round(2)
      @pst_amount = (@subtotal * province.pst_rate).round(2)
      @hst_amount = (@subtotal * province.hst_rate).round(2)
      
      # Calculate total tax
      @tax_total = @gst_amount + @pst_amount + @hst_amount
      
      # Make province available to the view for displaying tax rates
      @selected_province = province
    end
  end

  def order_params
    params.require(:order).permit(:shipping_address)
  end
end
