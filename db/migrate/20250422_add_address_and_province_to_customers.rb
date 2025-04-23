class AddAddressAndProvinceToCustomers < ActiveRecord::Migration[7.0]
    def change
      add_column    :customers, :address,     :string
      add_reference :customers, :province, foreign_key: true
    end
  end
  