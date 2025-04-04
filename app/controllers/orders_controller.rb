class OrdersController < ApplicationController
  before_action :authenticate_customer!

  # List all orders for the current customer
  def index
    @orders = current_customer.orders.order(order_date: :desc)
  end

  # Show a specific order
  def show
    @order = current_customer.orders.find(params[:id])
  end
end
