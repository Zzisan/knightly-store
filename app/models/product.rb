class Product < ApplicationRecord
  belongs_to :category
  has_many :order_items
  has_many :orders, through: :order_items

  # Add this line to attach an image
  has_one_attached :image

  validates :name, :description, :price, :stock_quantity, presence: true
end
