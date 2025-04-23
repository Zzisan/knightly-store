class CreateProvinces < ActiveRecord::Migration[7.0]
    def change
      create_table :provinces do |t|
        t.string  :name,      null: false
        t.decimal :gst_rate,  precision: 5, scale: 4, null: false, default: 0.05
        t.decimal :pst_rate,  precision: 5, scale: 4, null: false, default: 0.00
        t.decimal :hst_rate,  precision: 5, scale: 4, null: false, default: 0.00
  
        t.timestamps
      end
    end
  end
  