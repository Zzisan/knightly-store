class HomeController < ApplicationController
  def index
    @products = Product.limit(5)  # Loads the first 5 products from the database
  end
end
