class AddTaxFieldsToOrders < ActiveRecord::Migration[7.0]
    def change
      add_column :orders, :gst_amount,  :decimal, precision: 10, scale: 2, null: false, default: 0
      add_column :orders, :pst_amount,  :decimal, precision: 10, scale: 2, null: false, default: 0
      add_column :orders, :hst_amount,  :decimal, precision: 10, scale: 2, null: false, default: 0
      add_column :orders, :tax_total,   :decimal, precision: 10, scale: 2, null: false, default: 0
    end
  end
  