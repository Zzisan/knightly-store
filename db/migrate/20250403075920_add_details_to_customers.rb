class AddDetailsToCustomers < ActiveRecord::Migration[7.2]
  def change
    add_column :customers, :first_name, :string
    add_column :customers, :last_name, :string
    add_column :customers, :phone, :string
    add_column :customers, :address, :string
  end
end
