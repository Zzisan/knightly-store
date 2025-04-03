ActiveAdmin.register Product do
    permit_params :name, :description, :price, :stock_quantity, :image_url, :category_id
  
    index do
      selectable_column
      id_column
      column :name
      column "Category", :category
      column :price
      column :stock_quantity
      actions
    end
  
    filter :name
    filter :category
    filter :price
  
    form do |f|
      f.inputs "Product Details" do
        f.input :name
        f.input :description
        f.input :price
        f.input :stock_quantity
        f.input :image_url
        f.input :category, as: :select, collection: Category.all.collect { |c| [c.name, c.id] }
      end
      f.actions
    end
  end
  