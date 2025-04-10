# app/models/product.rb

class Product < ApplicationRecord
  belongs_to :category
  has_many :order_items
  has_many :orders, through: :order_items

  # If you're using Active Storage for images:
  has_one_attached :image

  validates :name, :description, :price, :stock_quantity, presence: true

  # -- Ransack Allowlisting --
  # List all columns you want to be searchable/filterable in the admin.
  # If you no longer use image_url (because of Active Storage), you can omit it.
  def self.ransackable_attributes(auth_object = nil)
    [
      "id",
      "category_id",
      "name",
      "description",
      "price",
      "stock_quantity",
      "image_url",   # Remove if you're not using an image_url column anymore
      "created_at",
      "updated_at"
    ]
  end

  # List associations if you want to allow filtering on them in ActiveAdmin
  def self.ransackable_associations(auth_object = nil)
    [
      "category",
      "order_items",
      "orders",
      # If you want to allow searching on attached image data (rarely needed):
      # "image_attachment",
      # "image_blob"
    ]
  end
end
