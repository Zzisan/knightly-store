class AddProductDetailsToOrderItems < ActiveRecord::Migration[7.2]
  def change
    add_column :order_items, :product_name, :string
    add_column :order_items, :product_description, :text
  end
end
