## Orders Dashboard
# This dashboard contains details and management 
# functions of the Orders
ActiveAdmin.register Order do

  ##Scope
  # A scope is something that is used to fileter data during display
  #The details are contained in the corresponding model

  ##All scope
  #Displays all the orders
  scope :All

  ##New scope
  #Displays all the orders
  scope :New

  ##Approved scope
  #Displays all the approved orders
  scope :Approved

  ##Shipped scope
  #Displays all the Shipped orders
  scope :Shipped

  ##Shipped scope
  #Displays all the Shipped orders
  scope :Unshipped

  ##Cancelled scope
  #Displays all the Cancelled orders
  scope :Cancelled

  ##Partially unshipped scope
  #Displays all the Partially unshipped orders
  scope :Partially_unshipped

  ##Partially Shipped scope
  #Displays all the Partially Shipped orders
  scope :Partially_shipped

  ##Partially Chipped scope
  #Dislpays all the Partially Chipped orders
  scope :Partially_cancelled

  ## Include helpers
  #include the helper function that are available in the Application Helper
  controller do 
    include ApplicationHelper

    def new
      @bank = []

      Bank.all.each do |bank|
        @bank.push([bank.name,bank.id])
      end

      @user = []
      User.order(:name).all.each do |user|
        @user.push([user.email,user.id])
      end
      
      super
    end

    def edit
      
      @ord = Order.find(params[:id])
      super
    end

    def fetch_amount

        resp  = []
        rent  = 0 
        price = 0
        params[:isbn].each do |isbn|


            book = Book.find_by_sql("select (ceil(b.price * (p.rental / 100))) as rate,price from books b, publishers p where b.publisher_id = p.id and b.isbn13 ='" + isbn + "'")

            if book.length == 1 
              #puts "book " + book[0].inspect
              rent += book[0].rate.to_i
              price += book[0].price.to_i
            end

        end

          resp.push(rent)
          resp.push(price)

      render :json => resp
    end

    def update
      order = Order.find(params[:id])
      #order.bank = Bank.find(params[:order][:bank_id])
      if order.update_attributes(params[:order])
        redirect_to ab_admin_path
      else
          flash[:notice] = "Order updated Successfully"
          redirect_to ab_admin_path
      end

    end

    def create

      error_message =""

      puts params.inspect

      if params[:payment_type] == 'bank' 
        if params[:order][:bank_id].nil? or params[:order][:bank_id] == "" 
            error_message ="Please Choose the Bank"
        end
      elsif  params[:payment_type] == 'COD' 
          if params[:order][:COD_mobile].nil? or params[:order][:COD_mobile] =="" 
          error_message ="Please Enter the COD mobile number"
        end
      elsif  params[:payment_type] == 'online' 
          if params[:order][:citruspay_response].nil? or params[:order][:citruspay_response] =="" 
          error_message ="Please Enter the citruspay response"
        end

      else
          error_message ="Please select atleast one payment type"
      end

      if params[:order][:rental_total] == "" || params[:order][:total] == "" || params[:order][:deposit_total] == "" || params[:order][:rental_total] == "0"
          error_message = "Please fetch the amounts by entering the ISBN 13"
      end

      if error_message != ""
        render :js => "alert('" + error_message + "');"
        return
      end


      order = Order.new
      order.total = params[:order][:total]
      order.rental_total = params[:order][:rental_total]
      order.order_type =params[:payment_type]
      order.payment_done = params[:payment_done]
      order.rental_total = params[:order][:deposit_total]


      params[:isbn13].split(",").each do |isbn|
          
          book = Book.find_by_isbn13(isbn)
          unless book.nil? 
            bookorder = order.book_orders.new({:shipped => 0 ,:status => 2})
            bookorder.book = book
          end

      end

      #order.book_orders.build

      order.user = current_user

      if params[:payment_type] == "online"
        order.gharpay_id = params[:citruspay_response]
      elsif params[:payment_type] == "COD_mobile"
        order.COD_mobile = params[:COD_mobile]
      elsif params[:payment_type] == "bank"
        order.bank = Bank.find(params[:order][:bank_id])
      end
      
      order.status = 0
      order.accept_terms_of_use = true

      if order.save 
        msg = "Order Placed Sucessfully"
        render :js => "alert('" + msg+ "'); window.location ='/ab_admin/orders' "
      return
      else
        msg = "Order Placing Failed"
        render :js => "alert('" + msg+ "');"
        return
      end

    end
  end


  #config.clear_action_items! 
  actions :all #, :except => [:edit]
  index do
    
  	selectable_column
  	column "Order ID", :random
  	column "User", :user_name do |order|
      puts order.inspect
  		link_to(order.user.name ,ab_admin_user_path(order.user))
  	end
  	column :order_type
  	column :deposit_total
  	column :COD_mobile
    column "Order Date",:created_at
    default_actions
  end

  show do |order|


    attributes_table do
      row :random
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
        order.books.select("name, isbn13, author,publisher_id,price").each do |b|
          html+="#{b.name} -> "
          html+="#{b.author} -> "
          html+=(b.publisher) ? "#{b.publisher.name} -> " : " - "
          html+="#{b.isbn13} -> "
          html+="#{b.price} -> "
          rental=((b.price.to_i * b.publisher.rental.to_i)/100).ceil
          html+="#{rental} <br> "
          
        end
        raw html
      end
      row :status do 
        order.order_status
      end
    end
    active_admin_comments
  end

  ##Shipping order form
  #display the datat for the shipping order
  member_action :shipping_order_form do 
    @order = Order.find(params[:id])
    @dates = @order.book_orders.select("DISTINCT(shipped_date)").pluck(:shipped_date)
    @book_orders = @order.book_orders.where('shipped = false and status not in(1,5,4)')
  end

  form :partial => "order_form"
  

    # form do |f|
    
    #  f.inputs do 

    #   f.input :random , :label => "Order ID" ,:input_html => {:disabled => true } 
    
    #   f.input :bank
    #   f.input :user , :input_html => {:disabled => true}

    #   f.input :total  
    #   f.input :rental_total 
    #   f.input :order_type 
    #   f.input :payment_done 
    #   f.input :deposit_total 
    #   f.input :citruspay_response ,:input_html => {:disabled => true } 
    #   f.input :COD_mobile 
    
    #   f.template do |aa|
    #     puts aa.inspect.to_s
    #     puts "dsafs"
    #   end
    # end

  #end



  #Cancel an Order
  #This action cancels the particular order which is displayed
  member_action :cancel_order_form, :method => :get do
    @order = Order.find(params[:id])
    @book_orders=@order.book_orders.where("status in (0,2,3,6,7)")
    @cancelled_orders = @order.book_orders.where("status = 4")
  end

  ## Cancel Order
  # This action performs the Cancellation of the Order
  #and updating the details of the order to Cancelled
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


  ## Approving Order
  # This action performs the Approval of the Order
  #and updating the details of the order to approved
  member_action :approve_order, :method=>:get do 
    @order = Order.find(params[:id])
    
    @order.books.update_all({:status => 2}, ["status != 2"])
    state = get_status(@order.book_orders.order('status desc'))
      @order.status = state[:code]
    @order.save


    flash[:notice] = "Order Approved Successfully!"
    redirect_to :action => :index, :scope => state[:value]
  end

  #Display these actions only on the show action
  #hide for rest of the action
  action_item :only => [:show] do
    link_to('Shipping Details',shipping_order_form_ab_admin_order_path(order))
  end

  action_item :only => [:show] do
    link_to('Approve Order',approve_order_ab_admin_order_path(order))
  end

  action_item :only => [:show] do
    link_to('Cancel Order',cancel_order_form_ab_admin_order_path(order))
  end

  ## Shipping Order
  # This action performs the creation of the Shipping entry 
  #and updating the details of the order to shipped
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



end



    #  f.inputs :for => :bank do |ordr| 
    #    f.input ordr 
    # <% end 