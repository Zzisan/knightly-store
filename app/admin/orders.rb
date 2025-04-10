ActiveAdmin.register Order do
  permit_params :customer_id, :order_date, :total_amount, :status, :shipping_address

  index do
    selectable_column
    id_column
    column "Customer" do |order|
      order.customer.email
    end
    column :order_date
    column :total_amount do |order|
      number_to_currency(order.total_amount)
    end
    column :status
    column :shipping_address
    actions
  end

  filter :customer_email, as: :string, label: 'Customer Email'
  filter :status
  filter :order_date

  form do |f|
    f.inputs "Order Details" do
      f.input :customer, as: :select, collection: Customer.all.collect { |c| [c.email, c.id] }
      f.input :order_date, as: :datepicker
      f.input :total_amount
      f.input :status, as: :select, collection: ["pending", "paid", "shipped", "completed"]
      f.input :shipping_address
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row "Customer" do |order|
        order.customer.email
      end
      row :order_date
      row :total_amount do |order|
        number_to_currency(order.total_amount)
      end
      row :status
      row :shipping_address
    end

    panel "Order Items" do
      table_for order.order_items do
        column "Product" do |item|
          item.product.name
        end
        column :quantity
        column "Price at Order" do |item|
          number_to_currency(item.price_at_order)
        end
      end
    end
  end
end
