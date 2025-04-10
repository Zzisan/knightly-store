# spec/models/product_spec.rb
require 'rails_helper'

RSpec.describe Product, type: :model do
  before(:each) do
    # Create a category to be used for products
    @category = Category.create!(name: "Swords", description: "Sharp and legendary blades.")
  end

  it "is valid with valid attributes" do
    product = Product.new(
      name: "Excalibur",
      description: "Legendary sword of King Arthur.",
      price: 999.99,
      stock_quantity: 5,
      category: @category
    )
    expect(product).to be_valid
  end

  it "is not valid without a name" do
    product = Product.new(
      description: "Legendary sword without a name.",
      price: 999.99,
      stock_quantity: 5,
      category: @category
    )
    expect(product).not_to be_valid
  end

  it "is not valid without a description" do
    product = Product.new(
      name: "Unnamed Sword",
      price: 999.99,
      stock_quantity: 5,
      category: @category
    )
    expect(product).not_to be_valid
  end

  it "is not valid without a price" do
    product = Product.new(
      name: "Excalibur",
      description: "Legendary sword without a price.",
      stock_quantity: 5,
      category: @category
    )
    expect(product).not_to be_valid
  end

  it "is not valid without a stock quantity" do
    product = Product.new(
      name: "Excalibur",
      description: "Legendary sword with no stock info.",
      price: 999.99,
      category: @category
    )
    expect(product).not_to be_valid
  end
end
