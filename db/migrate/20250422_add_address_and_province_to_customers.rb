class AddAddressAndProvinceToCustomers < ActiveRecord::Migration[7.0]
  def change
    # Skip adding address column as it already exists
    # add_column :customers, :address, :string
    
    # Add province_id column without foreign key constraint
    # The foreign key will be added after the provinces table is created
    add_column :customers, :province_id, :integer
    add_index :customers, :province_id
  end
end