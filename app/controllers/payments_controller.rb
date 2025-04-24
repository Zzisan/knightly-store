class PaymentsController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_order
  
  def new
    # Display payment form
  end
  
  def create
    # Process the payment using Stripe
    result = PaymentService.process_payment(@order, payment_params)
    
    if result[:success]
      # Payment was successful
      redirect_to order_path(@order), notice: "Payment successful! Your order has been processed."
    else
      # Payment failed
      flash.now[:alert] = result[:message]
      render :new
    end
  end
  
  private
  
  def set_order
    @order = current_customer.orders.find(params[:order_id])
    
    # Redirect if order is already paid
    if @order.status != "pending"
      redirect_to order_path(@order), notice: "This order has already been processed."
    end
  end
  
  def payment_params
    # Get parameters from form
    params.permit(:card_number, :expiry_month, :expiry_year, :cvv, :name_on_card, :payment_method_id)
  end
end