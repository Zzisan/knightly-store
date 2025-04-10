class ProductsController < ApplicationController
  def index
    @products = Product.all

    if params[:keyword].present?
      # Sanitize the keyword to escape any special SQL characters.
      safe_keyword = ActiveRecord::Base.sanitize_sql_like(params[:keyword])
      # Use LOWER on both the column and the search term for case-insensitive matching in SQLite.
      @products = @products.where("LOWER(name) LIKE ? OR LOWER(description) LIKE ?", "%#{safe_keyword.downcase}%", "%#{safe_keyword.downcase}%")
    end

    if params[:category_id].present?
      @products = @products.where(category_id: params[:category_id])
    end

    @products = @products.order(:id).page(params[:page]).per(10)
  end

  def show
    @product = Product.find(params[:id])
  end
end
