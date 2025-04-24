class WebhooksController < ApplicationController
  # Skip CSRF protection for webhooks
  skip_before_action :verify_authenticity_token
  
  # Handle Stripe webhooks
  def stripe
    # Retrieve the request's body and parse it as JSON
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil
    
    begin
      # Verify webhook signature and extract the event
      # In production, use a webhook secret: Stripe::Webhook.construct_event(payload, sig_header, ENV['STRIPE_WEBHOOK_SECRET'])
      event = JSON.parse(payload)
      event = Stripe::Event.construct_from(event)
    rescue JSON::ParserError => e
      # Invalid payload
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      return head :bad_request
    end
    
    # Handle the event
    case event.type
    when 'charge.succeeded'
      # Payment was successful
      charge = event.data.object
      order = Order.find_by(payment_id: charge.id)
      
      if order && order.status == Order::STATUS_PENDING
        order.update(status: Order::STATUS_PAID)
        # You could send a confirmation email here
        Rails.logger.info "Order ##{order.id} marked as paid via webhook"
      end
    when 'charge.failed'
      # Payment failed
      charge = event.data.object
      order = Order.find_by(payment_id: charge.id)
      
      if order
        # You could notify the customer about the failed payment
        Rails.logger.info "Payment failed for Order ##{order.id}"
      end
    end
    
    head :ok
  end
  
  # Legacy endpoint for manual testing
  def payment_confirmation
    order_id = params[:order_id]
    payment_status = params[:status]
    
    if order_id.present? && payment_status == "succeeded"
      order = Order.find_by(id: order_id)
      
      if order && order.status == Order::STATUS_PENDING
        # Update order status to paid
        order.update(status: Order::STATUS_PAID)
        
        render json: { success: true, message: "Payment confirmed and order updated" }, status: :ok
      else
        render json: { success: false, message: "Order not found or already processed" }, status: :unprocessable_entity
      end
    else
      render json: { success: false, message: "Invalid webhook data" }, status: :bad_request
    end
  end
end