class CheckoutController < ApplicationController
  before_action :authenticate_customer!

  def new
    if session[:cart].blank? || session[:cart].empty?
      redirect_to products_path, alert: "Your cart is empty." and return
    end
    @order = Order.new
  end

  def create
    if session[:cart].blank? || session[:cart].empty?
      redirect_to products_path, alert: "Your cart is empty." and return
    end

    total = 0
    order_items = []

    # Process each item in the session-based cart
    session[:cart].each do |product_id, quantity|
      product = Product.find_by(id: product_id)
      next unless product
      subtotal = product.price * quantity
      total += subtotal
      order_items << { product_id: product.id, quantity: quantity, price_at_order: product.price }
    end

    @order = current_customer.orders.build(order_params.merge(
      order_date: Time.current,
      total_amount: total,
      status: "pending"  # Order starts as pending; you'll update it after payment confirmation.
    ))

    if @order.save
      # Create associated order_items records
      order_items.each do |item_data|
        @order.order_items.create(item_data)
      end

      # Clear the cart
      session[:cart] = {}

      redirect_to order_path(@order), notice: "Order placed successfully!"
    else
      render :new
    end
  end

  private

  def order_params
    params.require(:order).permit(:shipping_address)
  end
end
