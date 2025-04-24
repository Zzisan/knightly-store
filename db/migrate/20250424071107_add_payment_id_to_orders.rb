class AddPaymentIdToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :payment_id, :string
  end
end
