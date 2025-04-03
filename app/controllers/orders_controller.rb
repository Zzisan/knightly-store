class OrdersController < ApplicationController
  before_action :authenticate_customer!
  
  def show
    @order = current_customer.orders.find(params[:id])
  end
end
