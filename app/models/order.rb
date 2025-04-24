# app/models/order.rb

class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  # Order status constants
  STATUS_PENDING = 'pending'
  STATUS_PAID = 'paid'
  STATUS_SHIPPED = 'shipped'
  STATUS_COMPLETED = 'completed'
  STATUS_CANCELLED = 'cancelled'
  
  STATUSES = [STATUS_PENDING, STATUS_PAID, STATUS_SHIPPED, STATUS_COMPLETED, STATUS_CANCELLED]
  
  validates :order_date, :total_amount, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  # -- Ransack Allowlisting --
  # Explicitly list all attributes you want Ransack to search/filter.
  # If you don't have 'shipping_address' in your Orders table, remove it from this array.
  def self.ransackable_attributes(auth_object = nil)
    [
      "id",
      "customer_id",
      "order_date",
      "total_amount",
      "status",
      "shipping_address",
      "created_at",
      "updated_at"
    ]
  end

  # List any associations that might be used for searching/filtering in ActiveAdmin.
  def self.ransackable_associations(auth_object = nil)
    [
      "customer",
      "order_items",
      "products"
    ]
  end
end
