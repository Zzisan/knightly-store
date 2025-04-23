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
    
    # Ensure quantity is at least 1
    quantity = 1 if quantity < 1
    
    # Update cart in session
    session[:cart] ||= {}
    session[:cart][product_id] ||= 0
    session[:cart][product_id] += quantity
    
    @product = Product.find_by(id: product_id)
    
    # Show a popup notification
    flash[:cart_added] = {
      product_name: @product.name,
      product_price: @product.on_sale? ? @product.sale_price : @product.price,
      quantity: quantity
    }
    
    # Redirect back to the previous page
    redirect_back(fallback_location: products_path, notice: "#{@product.name} added to cart!")
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
