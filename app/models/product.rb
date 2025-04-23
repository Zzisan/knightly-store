# app/models/product.rb

class Product < ApplicationRecord
  belongs_to :category
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items

  has_one_attached :image

  validates :name, :description, :price, :stock_quantity, presence: true

  # Tell Ransack which attributes may be searched/filtered in ActiveAdmin
  def self.ransackable_attributes(auth_object = nil)
    %w[
      id
      category_id
      name
      description
      price
      sale_price
      stock_quantity
      image_url
      created_at
      updated_at
      on_sale
      discount_percentage
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[
      category
      order_items
      orders
    ]
  end

  # Scopes for your public filters
  scope :on_sale, -> { where(on_sale: true) }
  scope :newly_added, -> { where("created_at >= ?", 3.days.ago) }
  scope :recently_updated, -> { where("updated_at >= ?", 3.days.ago) }

  # Calculate sale price if not set
  def sale_price
    if self[:sale_price].present?
      self[:sale_price]
    elsif on_sale? && discount_percentage.to_i > 0
      (price * (100 - discount_percentage) / 100.0).round(2)
    else
      price
    end
  end
  
  # Set sale price and update discount percentage
  def sale_price=(value)
    self[:sale_price] = value
    
    # Update discount percentage if price and sale_price are present
    if price.present? && value.present? && value < price
      self.on_sale = true
      self.discount_percentage = ((1 - (value / price)) * 100).round
    end
  end
end
