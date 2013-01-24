##== Details of each Order
# This ActiveAdmin contains the details of each and every book
# that the order has. 
# The scope of the Items inside the orrder are only 3 status as of now
# == The scope are ::
#  		Shipped, Unshipped and Cancelled, with status numbers 1,2,4 respectively
#
#
ActiveAdmin.register BookOrder do

	## Scope Shipped
	# Retervies all the shipped items with the respective status and 
	# displays it in a table
	scope :Shipped

	## Scope UnShipped
	# Retervies all the Unshipped items with the respective status and 
	# displays it in a table
	scope :Unshipped

	##Scope Cancelled
	# Retervies all the Cancelled items with the respective status and 
	# displays it in a table
	scope :Cancelled

	##Menu Name 
	# Customizing the menu name that is to be displayed 
	# in the active admin dashboard page
	# default would be the name of the Controller (ie, BookOrder in this case)
	menu :label => "Shipping"

	## ##TODO##
	config.clear_action_items!
	

	## Overriding index action of Active admin
	# This definition overrides the default index action of the active admin page
	# Here we customize it to display our own column that are needed in the view
	index do
	
		## Column 1
		# This is a column with check box which enables admin to perform 
		# batch actions in the dashboard
		selectable_column

		## Column 2
		# This is a column which displays the order id 
		# and also provides a link to it.
		column :order_id  do |book_order|
			link_to book_order.order.random , admin_order_path(book_order.order)
		end

		## Column 3
		# This is a column which displays the user id
		# and also provides a link to it.
		column :user_id do |book_order|
			link_to User.find(book_order.order.user_id).name ,admin_user_path(User.find(book_order.order.user_id))
		end

		## Column 4
		# This is a column which displays the name of the book
		# and also provides a link to it. ##TODO##
		column :book_id do |book_order|
			link_to Book.find(book_order.book_id).name , admin_book_path(Book.find(book_order.book_id))
		end

		## Column 5
		# This is a column which displays the total rental of the particular order
		column :Total_Rental do |book_order|
			"Rs. " +  book_order.order.rental_total.to_s
		end

		## Column 6
		# This is a column which displays the total amount of the particular order
		column :Total_Amount do |book_order|
			"Rs. " +  book_order.order.total.to_s
		end

		## Column 7
		# This is a column which displays the type(bank,cod) of the order
		column :order_type do |book_order|
			book_order.order.order_type
		end

		## Column 8
		# This is a column with conditional data.
		# These column appears only in the shipped scope(ie, 2 here)
		# Also we are customizing the name of the column which is displayed 
		# Default would be the column name which would be "Created At" here
		# Changed to "Order Date"
		column "Order Date", :created_at

		## Conditional Columns
		# Display these only if we are in shipped scope
		if params[:scope] == "Shipped"

			## Order ID
			#Id of the place order
			column :order_id

			## Courier Name
			# The name of the courier company through which the order was dispatched.
			column :courier_name

			## Tracking Number
			# The Tracking number as giving by us ##TODO##
			column :tracking_number

			## Shipped Date
			# The date the oder was shipped(or dispatched).
			column :shipped_date
		end
	end
end
