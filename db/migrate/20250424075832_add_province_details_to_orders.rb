class AddProvinceDetailsToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :province_name, :string
    add_column :orders, :province_gst_rate, :decimal, precision: 5, scale: 3, default: 0.0
    add_column :orders, :province_pst_rate, :decimal, precision: 5, scale: 3, default: 0.0
    add_column :orders, :province_hst_rate, :decimal, precision: 5, scale: 3, default: 0.0
  end
end
