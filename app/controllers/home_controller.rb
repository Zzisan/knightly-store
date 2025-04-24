class HomeController < ApplicationController
  def index
    # For example, let's load some featured products or all products. 
    # Adjust as needed for your site’s logic.
    @products = Product.all
    # If you want to paginate:
    @products = Product.page(params[:page]).per(5)
  end
end
