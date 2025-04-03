class CartController < ApplicationController
  # Show the shopping cart
  def show
    # The cart is stored in the session as a hash { product_id => quantity }
    @cart_items = session[:cart] || {}
    # Fetch the corresponding products from the database
    @products = Product.where(id: @cart_items.keys)
  end

  # Add a product to the cart
  def add
    product_id = params[:product_id].to_s
    session[:cart] ||= {}
    session[:cart][product_id] ||= 0
    session[:cart][product_id] += 1
    redirect_to cart_path, notice: "Product added to cart!"
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
