class AddFeaturedToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :featured, :boolean
  end
end
