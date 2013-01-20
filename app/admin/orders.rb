ActiveAdmin.register Order do
  scope :All
  scope :Cancelled
  scope :Shipped
  config.clear_action_items!
  index do
  	column :id
  	column "Order ID", :random
  	column "User", :user_name do |order|
  		order.user.name
  	end
  	column :order_type
  	column :payment_done
  	column :deposit_total
  	column :rental_total
  	column :gharpay_id
  	column :citruspay_response
  	column :COD_mobile
    column "" do |resource|
      links = ''.html_safe
      links += link_to 'View', resource_path(resource), :class => "member_link view_link"
      links += link_to 'Delete', resource_path(resource), :method => :delete, :confirm => I18n.t('active_admin.delete_confirmation'), :class => "member_link delete_link"
      links
    end
  end
  member_action :shipping_order_form do 
    @order = Order.find(params[:id])
    @dates = @order.book_orders.select("DISTINCT(shipped_date)").pluck(:shipped_date)
    @book_orders = @order.book_orders.where(:shipped => false)
  end

  member_action :shipping_cancel_form do 
    @order = Order.find(params[:id])
  end
  
  member_action :shipping_cancel, :method=>:get do 
    @order = Order.find(params[:id])
    @order.status = 'cancel'
    @order.save
    redirect_to '/admin/orders'
  end

  action_item :only => [:show] do
    link_to('Shipping Details',shipping_order_form_admin_order_path(order))
  end

  action_item :only => [:show] do
    link_to('Cancel Order',shipping_cancel_form_admin_order_path(order))
  end
  
  member_action :shipping_order, :method=>:post do 
    @order= Order.find(params[:id])

    book_order_ids = JSON.parse params[:book_orders]
    book_order_ids.each do |book_order_id|
      book_order = BookOrder.find(book_order_id.to_i)
      if book_order
        book_order.update_attributes(:shipped => true,  :shipped_date=>Time.now, :tracking_number => params[:tracking_number], :courier_name => params[:courier_name])
      end
    end
    if book_order_ids.count > 0
      msg = "Your Sociorent.com Order #{@order.random} has been shipped through #{params[:courier_name]} with tracking number #{params[:tracking_number]} . Thank you."
      send_sms(@order.user.mobile_number ,msg)
      puts msg
    end
    @order.update_attributes(:status => "shipped") if @order.book_orders.where(:shipped => false).count == 0
    render :nothing=>true
  end
end
