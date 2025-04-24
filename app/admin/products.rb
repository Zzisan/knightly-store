ActiveAdmin.register Product do
  # Permit the additional fields for on_sale and discount_percentage
  permit_params :name, :description, :price, :stock_quantity, :image_url, :category_id, :image, :on_sale, :discount_percentage

  index do
    selectable_column
    id_column
    column :name
    column "Category", :category
    column :price
    column :stock_quantity
    column "On Sale", :on_sale
    column "Discount (%)", :discount_percentage
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
  filter :on_sale
  filter :discount_percentage

  form do |f|
    f.inputs "Product Details" do
      f.input :name
      f.input :description
      f.input :price
      f.input :stock_quantity
      f.input :on_sale, as: :boolean, label: "On Sale?"
      f.input :discount_percentage, label: "Discount (%)"
      f.input :category, as: :select, collection: Category.all.collect { |c| [c.name, c.id] }
      f.input :image, as: :file  # This adds a file upload field for the product image
    end
    f.actions
  end
end
