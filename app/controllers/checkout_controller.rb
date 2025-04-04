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
      status: "pending"  # Initially pending until payment is confirmed
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

      # Create a Stripe Checkout session for this order
      session_stripe = Stripe::Checkout::Session.create(
        payment_method_types: ['card'],
        line_items: [{
          price_data: {
            currency: 'usd',
            product_data: {
              name: "Order ##{@order.id}",
            },
            unit_amount: (total * 100).to_i,  # Convert total to cents
          },
          quantity: 1,
        }],
        mode: 'payment',
        success_url: order_url(@order),  # On success, redirect to order confirmation page
        cancel_url: new_checkout_url,      # On cancel, go back to the checkout page
      )

      # Store the Stripe session ID in the order (optional)
      @order.update(stripe_session_id: session_stripe.id) if @order.respond_to?(:stripe_session_id)

      # Clear the cart after creating the order
      session[:cart] = {}

      # Redirect to Stripe Checkout
      redirect_to session_stripe.url, allow_other_host: true
    else
      render :new
    end
  rescue Stripe::StripeError => e
    # Handle any Stripe errors gracefully
    redirect_to new_checkout_url, alert: e.message
  end

  private

  def order_params
    params.require(:order).permit(:shipping_address)
  end
end
