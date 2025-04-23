class CartController < ApplicationController
  # Show the shopping cart
  def show
    # The cart is stored in the session as a hash { product_id => quantity }
    @cart_items = session[:cart] || {}
    # Fetch the corresponding products from the database
    @products = Product.where(id: @cart_items.keys)
    
    respond_to do |format|
      format.html
      format.json { 
        render json: { 
          cart: @cart_items,
          cart_count: @cart_items.values.sum,
          success: true
        } 
      }
    end
  end

  # Add a product to the cart
  def add
    product_id = params[:product_id].to_s
    quantity = 1
    
    # Try to parse quantity from params
    if params[:quantity].present?
      quantity = params[:quantity].to_i
    elsif request.content_type =~ /json/
      # Try to parse from request body for JSON requests
      begin
        json_params = JSON.parse(request.body.read)
        quantity = json_params['quantity'].to_i if json_params['quantity'].present?
      rescue JSON::ParserError
        # If JSON parsing fails, default to 1
        quantity = 1
      end
    end
    
    # Ensure quantity is at least 1
    quantity = 1 if quantity < 1
    
    # Update cart in session
    session[:cart] ||= {}
    session[:cart][product_id] ||= 0
    session[:cart][product_id] += quantity
    
    @product = Product.find_by(id: product_id)
    
    respond_to do |format|
      format.html { 
        redirect_back(fallback_location: products_path, notice: "#{@product.name} added to cart!") 
      }
      format.js
      format.json { 
        render json: { 
          success: true, 
          message: "#{@product.name} added to cart!",
          cart_count: session[:cart].values.sum,
          product: {
            id: @product.id,
            name: @product.name,
            price: @product.on_sale? ? @product.sale_price : @product.price,
            image_url: @product.image.attached? ? url_for(@product.image) : nil
          }
        } 
      }
    end
  end

  # Update the quantity of a product in the cart
  def update
    product_id = params[:product_id].to_s
    quantity = params[:quantity].to_i
    session[:cart] ||= {}
    if quantity > 0
      session[:cart][product_id] = quantity
    else
      session[:cart].delete(product_id)
    end
    redirect_to cart_path, notice: "Cart updated!"
  end

  # Remove a product from the cart
  def remove
    product_id = params[:product_id].to_s
    session[:cart] ||= {}
    session[:cart].delete(product_id)
    redirect_to cart_path, notice: "Product removed from cart!"
  end
end
