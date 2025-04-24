class ProfilesController < ApplicationController
  before_action :authenticate_customer!
  
  def show
    @customer = current_customer
  end
  
  def edit
    @customer = current_customer
    @provinces = Province.all.order(:name)
  end
  
  def update
    @customer = current_customer
    
    if @customer.update(customer_params)
      redirect_to profile_path, notice: "Your profile has been updated successfully."
    else
      @provinces = Province.all.order(:name)
      render :edit
    end
  end
  
  private
  
  def customer_params
    params.require(:customer).permit(:first_name, :last_name, :phone, :address, :province_id)
  end
end