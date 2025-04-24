class ProductsController < ApplicationController
  def index
    @products = Product.all

    # Apply category filter if provided
    if params[:category_id].present?
      @products = @products.where(category_id: params[:category_id])
    end
    
    # Apply keyword search if provided
    if params[:keyword].present?
      @products = @products.where("name LIKE ? OR description LIKE ?", 
                                 "%#{params[:keyword]}%", 
                                 "%#{params[:keyword]}%")
    end

    # Apply filters if provided
    case params[:filter]
    when 'on_sale'
      @products = @products.on_sale
    when 'newly_added'
      @products = @products.newly_added
    when 'recently_updated'
      @products = @products.recently_updated
    end

    # Set the current filter for highlighting in the view
    @current_filter = params[:filter]

    # Order products by newest first by default
    @products = @products.order(created_at: :desc)
  end

  def show
    @product = Product.find(params[:id])
    # Get related products from the same category
    @related_products = Product.where(category_id: @product.category_id)
                              .where.not(id: @product.id)
                              .limit(3)
  end
end
