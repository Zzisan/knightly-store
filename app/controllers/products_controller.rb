class ProductsController < ApplicationController
  def index
    @products = Product.all

    # Filter by keyword in product name or description (case-insensitive)
    if params[:keyword].present?
      @products = @products.where("name ILIKE ? OR description ILIKE ?", "%#{params[:keyword]}%", "%#{params[:keyword]}%")
    end

    # Filter by category if a category_id is provided
    if params[:category_id].present?
      @products = @products.where(category_id: params[:category_id])
    end

    @products = @products.order(:id).page(params[:page]).per(10)
  end

  def show
    @product = Product.find(params[:id])
  end
end
