class CheckoutController < ApplicationController
  before_action :authenticate_customer!
  
  def new
    if session[:cart].blank? || session[:cart].empty?
      redirect_to products_path, alert: "Your cart is empty."
    else
      @order = Order.new
    end
  end
  
  def create
    cart = session[:cart] || {}
    if cart.empty?
      redirect_to products_path, alert: "Your cart is empty." and return
    end
    
    # Calculate total order amount
    total = 0
    cart.each do |product_id, quantity|
      product = Product.find_by(id: product_id)
      total += product.price * quantity if product
    end
    
    @order = current_customer.orders.build(order_params.merge(
      order_date: Time.current,
      total_amount: total,
      status: "pending"
    ))
    
    if @order.save
      # Create order items for each product in the cart
      cart.each do |product_id, quantity|
        product = Product.find_by(id: product_id)
        if product
          @order.order_items.create(
            product: product,
            quantity: quantity,
            price_at_order: product.price
          )
        end
      end
      
      # Clear the cart after placing the order
      session[:cart] = {}
      redirect_to order_path(@order), notice: "Order placed successfully."
    else
      render :new
    end
  end
  
  private
  
  def order_params
    # Permit shipping_address from the form
    params.require(:order).permit(:shipping_address)
  end
end
