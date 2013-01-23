ActiveAdmin.register Order do
  scope :All
  scope :New
  scope :Approved
  scope :Shipped
  scope :Unshipped
  scope :Cancelled
  scope :Partially_unshipped
  scope :Partially_shipped
  scope :Partially_cancelled

  config.clear_action_items!
  actions :all, :except => [:edit]
  index do
    
  	selectable_column
  	column "Order ID", :random
  	column "User", :user_name do |order|
  		link_to(order.user.name,admin_user_path(order.user))
  	end
  	column :order_type
  	column :deposit_total
  	column :COD_mobile
    column "Order Date",:created_at
    default_actions
  end

  show do |order|
    attributes_table do
      row :id
      row :user_name do 
        order.user.name
      end
      row :order_type
      row :deposit_total
      row :COD_mobile
      row :Address do 
        html=""
        begin
        JSON.parse(order.user.address).each do |k,v|
          html+="#{v}<br>"
        end
        rescue
          order.user.address
        end
        raw html
      end
      row :created_at do 
        order.created_at
      end
      row :items do
        #TODO : Print it Neatly
        html=""
        order.books.select("name, isbn13, author,publisher_id").each do |b|
          html+="#{b.name} -> "
          html+="#{b.isbn13} -> "
          html+="#{b.author} -> "
          html+="#{b.publisher.name}<br>"
        end
        raw html
      end
      row :status
    end
    active_admin_comments
  end

  member_action :shipping_order_form do 
    @order = Order.find(params[:id])
    @dates = @order.book_orders.select("DISTINCT(shipped_date)").pluck(:shipped_date)
    @book_orders = @order.book_orders.where('shipped = false and status not in(1,5,4)')
  end

  member_action :cancel_order_form, :method => :get do
    @order = Order.find(params[:id])
    @book_orders=@order.book_orders.where("status in (0,2,3,6,7)")
    @cancelled_orders = @order.book_orders.where("status = 4")
  end

  member_action :cancel_order, :method=>:post do 
    scope=:ALL
    
    if params[:book_order]
      book_order_ids = params[:book_order]
      book_order_ids.each do |id, value|
        book_order = BookOrder.find(id.to_i)
        if book_order
          book_order.update_attributes(:status => 4)
          book_order.save
        end
      end
    end

    order= Order.find(params[:id])
    state = get_status(order.book_orders.order('status desc'))

    order.update_attributes(:status => state[:code])

    flash[:notice] = "Order Items cancelled Successfully "

    redirect_to :action => :index,:scope=> state[:value]
  end


  member_action :approve_order, :method=>:get do 
    @order = Order.find(params[:id])
    
    @order.books.update_all({:status => 2}, ["status != 2"])
    state = get_status(@order.book_orders.order('status desc'))
      @order.status = state[:code]
    @order.save


    flash[:notice] = "Order Approved Successfully!"
    redirect_to :action => :index, :scope => state[:value]
  end

  action_item :only => [:show] do
    link_to('Shipping Details',shipping_order_form_admin_order_path(order))
  end

  action_item :only => [:show] do
    link_to('Approve Order',approve_order_admin_order_path(order))
  end

  action_item :only => [:show] do
    link_to('Cancel Order',cancel_order_form_admin_order_path(order))
  end

  member_action :shipping_order, :method=>:post do 
    @order= Order.find(params[:id])
    if params[:book_order]
      book_order_ids = params[:book_order]
      book_order_ids.each do |id, value|
        book_order = BookOrder.find(id.to_i)
        if book_order
          book_order.update_attributes(:shipped => true, :status => 1, :shipped_date=>Time.now, :tracking_number => params[:tracking_number], :courier_name => params[:courier_name])
        end
      end
      if book_order_ids.count > 0
        msg = "Your Sociorent.com Order #{@order.random} has been shipped through #{params[:courier_name]} with tracking number #{params[:tracking_number]} . Thank you."
        send_sms(@order.user.mobile_number ,msg)
        puts msg
      end

      state = get_status(@order.book_orders.order('status desc'))

      @order.update_attributes(:status => state[:code]) # if @order.book_orders.where(:shipped => false).count == 0
      flash[:notice]="Checked books are marked as shipped"
    end
    redirect_to :action => :index, :scope=> state[:value]
  end


controller do 
  include ApplicationHelper
end


end

