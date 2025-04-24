# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Recent Orders" do
          table_for Order.order(order_date: :desc).limit(10) do
            column("Order ID") { |order| link_to(order.id, admin_order_path(order)) }
            column("Customer") { |order| link_to(order.customer.email, admin_customer_path(order.customer)) }
            column("Date") { |order| order.order_date.strftime("%B %d, %Y %I:%M %p") }
            column("Status") { |order| status_tag(order.status) }
            column("Total") { |order| number_to_currency(order.total_amount) }
          end
          div do
            link_to "View All Orders", admin_orders_path, class: "button"
          end
        end
      end

      column do
        panel "Store Statistics" do
          div class: "dashboard_stats" do
            ul do
              li do
                span "Total Orders: "
                strong Order.count
              end
              li do
                span "Total Revenue: "
                strong number_to_currency(Order.sum(:total_amount))
              end
              li do
                span "Total Customers: "
                strong Customer.count
              end
              li do
                span "Total Products: "
                strong Product.count
              end
              li do
                span "Products on Sale: "
                strong Product.where(on_sale: true).count
              end
            end
          end
        end
      end
    end

    panel "Customer Order Summary" do
      table_for Customer.joins(:orders).distinct.order('email ASC') do
        column("Customer") { |customer| link_to(customer.email, admin_customer_path(customer)) }
        column("Total Orders") { |customer| customer.orders.count }
        column("Total Spent") { |customer| number_to_currency(customer.orders.sum(:total_amount)) }
        column("Latest Order") { |customer| 
          order = customer.orders.order(order_date: :desc).first
          link_to("Order ##{order.id}", admin_order_path(order)) if order
        }
        column("View Orders") { |customer| 
          link_to("View All Orders", admin_orders_path(q: { customer_email_eq: customer.email }))
        }
      end
    end

    panel "Recent Order Details" do
      paginated_collection(Order.order(order_date: :desc).page(params[:page]).per(10), download_links: false) do
        table_for(collection) do
          column("Order ID") { |order| link_to(order.id, admin_order_path(order)) }
          column("Customer") { |order| link_to(order.customer.email, admin_customer_path(order.customer)) }
          column("Date") { |order| order.order_date.strftime("%B %d, %Y") }
          column("Products") { |order| 
            ul class: "order_products" do
              order.order_items.includes(:product).each do |item|
                li "#{item.quantity} × #{item.product.name} (#{number_to_currency(item.price_at_order)})"
              end
            end
          }
          column("Taxes") { |order|
            div do
              "GST: #{number_to_currency(order.gst_amount || 0)}"
            end
            div do
              "PST: #{number_to_currency(order.pst_amount || 0)}"
            end
            div do
              "HST: #{number_to_currency(order.hst_amount || 0)}"
            end
            div do
              strong "Total Tax: #{number_to_currency(order.tax_total || 0)}"
            end
          }
          column("Total") { |order| number_to_currency(order.total_amount) }
        end
      end
    end
  end # content
end
