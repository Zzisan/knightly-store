class ProductsController < ApplicationController
  def index
    @products = Product.all.order(:id)  # Optionally order products by id or any attribute.
  end

  def show
    @product = Product.find(params[:id])
  end
end
