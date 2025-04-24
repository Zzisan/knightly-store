class AddProvinceForeignKeyToCustomers < ActiveRecord::Migration[7.0]
  def change
    # Add foreign key constraint to province_id column
    add_foreign_key :customers, :provinces
  end
end