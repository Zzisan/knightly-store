ActiveAdmin.register Product do
  permit_params :name, :description, :price, :stock_quantity, :image_url, :category_id, :image

  index do
    selectable_column
    id_column
    column :name
    column "Category", :category
    column :price
    column :stock_quantity
    column "Image" do |product|
      if product.image.attached?
        image_tag url_for(product.image), width: "50"
      else
        "No image"
      end
    end
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
      f.input :category, as: :select, collection: Category.all.collect { |c| [c.name, c.id] }
      f.input :image, as: :file  # This adds the file upload field
    end
    f.actions
  end
end
