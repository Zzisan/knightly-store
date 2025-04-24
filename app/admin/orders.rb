ActiveAdmin.register Order do
  permit_params :customer_id, :order_date, :total_amount, :status, :shipping_address
  
  # Add a custom action to mark an order as shipped
  action_item :ship, only: :show do
    if order.status == Order::STATUS_PAID
      link_to "Mark as Shipped", ship_admin_order_path(order), method: :put
    end
  end
  
  # Add a custom action to mark an order as completed
  action_item :complete, only: :show do
    if order.status == Order::STATUS_SHIPPED
      link_to "Mark as Completed", complete_admin_order_path(order), method: :put
    end
  end
  
  # Add a custom action to cancel an order
  action_item :cancel, only: :show do
    if [Order::STATUS_PENDING, Order::STATUS_PAID].include?(order.status)
      link_to "Cancel Order", cancel_admin_order_path(order), method: :put, 
              data: { confirm: "Are you sure you want to cancel this order?" }
    end
  end
  
  # Define the controller actions for shipping and completing orders
  member_action :ship, method: :put do
    order = Order.find(params[:id])
    if order.status == Order::STATUS_PAID
      order.update(status: Order::STATUS_SHIPPED)
      redirect_to admin_order_path(order), notice: "Order has been marked as shipped"
    else
      redirect_to admin_order_path(order), alert: "Order must be paid before it can be shipped"
    end
  end
  
  member_action :complete, method: :put do
    order = Order.find(params[:id])
    if order.status == Order::STATUS_SHIPPED
      order.update(status: Order::STATUS_COMPLETED)
      redirect_to admin_order_path(order), notice: "Order has been marked as completed"
    else
      redirect_to admin_order_path(order), alert: "Order must be shipped before it can be completed"
    end
  end
  
  member_action :cancel, method: :put do
    order = Order.find(params[:id])
    if [Order::STATUS_PENDING, Order::STATUS_PAID].include?(order.status)
      order.update(status: Order::STATUS_CANCELLED)
      redirect_to admin_order_path(order), notice: "Order has been cancelled"
    else
      redirect_to admin_order_path(order), alert: "This order cannot be cancelled"
    end
  end

  index do
    selectable_column
    id_column
    column "Customer" do |order|
      link_to order.customer.email, admin_customer_path(order.customer)
    end
    column :order_date
    column "Products" do |order|
      order.order_items.count
    end
    column "Subtotal" do |order|
      number_to_currency(order.total_amount - (order.tax_total || 0))
    end
    column "Tax" do |order|
      number_to_currency(order.tax_total || 0)
    end
    column "Total" do |order|
      number_to_currency(order.total_amount)
    end
    column :status do |order|
      status_tag order.status
    end
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
      f.input :status, as: :select, collection: Order::STATUSES
      f.input :shipping_address
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row "Customer" do |order|
        link_to order.customer.email, admin_customer_path(order.customer)
      end
      row :order_date
      row :status do |order|
        status_tag order.status
      end
      row "Status History" do |order|
        div do
          case order.status
          when "pending"
            "Order created on #{order.created_at.strftime("%B %d, %Y at %I:%M %p")}"
          when "paid"
            "Order created on #{order.created_at.strftime("%B %d, %Y at %I:%M %p")}<br/>".html_safe +
            "Payment received on #{order.updated_at.strftime("%B %d, %Y at %I:%M %p")}"
          when "shipped"
            "Order created on #{order.created_at.strftime("%B %d, %Y at %I:%M %p")}<br/>".html_safe +
            "Payment received<br/>".html_safe +
            "Shipped on #{order.updated_at.strftime("%B %d, %Y at %I:%M %p")}"
          when "completed"
            "Order created on #{order.created_at.strftime("%B %d, %Y at %I:%M %p")}<br/>".html_safe +
            "Payment received<br/>".html_safe +
            "Shipped<br/>".html_safe +
            "Completed on #{order.updated_at.strftime("%B %d, %Y at %I:%M %p")}"
          end
        end
      end
      row :shipping_address
    end

    panel "Order Items" do
      table_for order.order_items do
        column "Product" do |item|
          link_to item.product.name, admin_product_path(item.product)
        end
        column :quantity
        column "Price at Order" do |item|
          number_to_currency(item.price_at_order)
        end
        column "Subtotal" do |item|
          number_to_currency(item.price_at_order * item.quantity)
        end
      end
    end
    
    panel "Tax Information" do
      attributes_table_for order do
        row "GST" do |order|
          number_to_currency(order.gst_amount || 0)
        end
        row "PST" do |order|
          number_to_currency(order.pst_amount || 0)
        end
        row "HST" do |order|
          number_to_currency(order.hst_amount || 0)
        end
        row "Total Tax" do |order|
          number_to_currency(order.tax_total || 0)
        end
        row "Subtotal" do |order|
          number_to_currency(order.total_amount - (order.tax_total || 0))
        end
        row "Grand Total" do |order|
          number_to_currency(order.total_amount)
        end
      end
    end
  end
end
