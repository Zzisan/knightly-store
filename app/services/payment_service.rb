class PaymentService
  def self.process_payment(order, payment_params)
    begin
      # Create a Stripe token with the card information
      token = Stripe::Token.create({
        card: {
          number: payment_params[:card_number].gsub(/\s+/, ""), # Remove spaces
          exp_month: payment_params[:expiry_month],
          exp_year: payment_params[:expiry_year],
          cvc: payment_params[:cvv],
          name: payment_params[:name_on_card]
        },
      })
      
      # Create a charge using the token
      charge = Stripe::Charge.create({
        amount: (order.total_amount * 100).to_i, # Amount in cents
        currency: 'cad',
        source: token.id,
        description: "Payment for Order ##{order.id}",
        metadata: {
          order_id: order.id,
          customer_email: order.customer.email
        }
      })
      
      # If the charge is successful, update the order status
      if charge.status == 'succeeded'
        order.update(status: "paid", payment_id: charge.id)
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
  
  # For testing purposes, you can use these test card numbers:
  # Success: 4242 4242 4242 4242
  # Decline: 4000 0000 0000 0002
  # For more test cards: https://stripe.com/docs/testing#cards
end