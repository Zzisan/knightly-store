class AddOnSaleAndDiscountToProducts < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:products, :on_sale)
      add_column :products, :on_sale, :boolean, default: false, null: false
    end

    unless column_exists?(:products, :discount_percentage)
      add_column :products, :discount_percentage, :integer, default: 0, null: false
    end
  end
end
