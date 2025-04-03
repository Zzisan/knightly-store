class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, :price_at_order, presence: true
end
