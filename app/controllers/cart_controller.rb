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
    quantity = params[:quantity].present? ? params[:quantity].to_i : 1
    
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
