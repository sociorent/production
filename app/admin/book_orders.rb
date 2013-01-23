ActiveAdmin.register BookOrder do
	scope :Shipped
	scope :Unshipped
	scope :Cancelled
	menu :label => "Shipping"
	config.clear_action_items!
	index do
		selectable_column

		column :order_id  do |book_order|
			link_to book_order.order_id , admin_order_path(book_order)
		end

		column :user_id do |book_order|
			link_to User.find(book_order.order.user_id).name ,admin_user_path(User.find(book_order.order.user_id))
		end

		column :book_id do |book_order|
			link_to Book.find(book_order.book_id).name , admin_book_path(Book.find(book_order.book_id))
		end

		column :Total_Rental do |book_order|
			"Rs. " +  book_order.order.rental_total.to_s
		end

		column :Total_Amount do |book_order|
			"Rs. " +  book_order.order.total.to_s
		end

		column :Payment do |book_order|
			book_order.order.payment_done ? "Done" : "Not Done"
		end


		column "Order Date", :created_at

		if params[:scope] == "Shipped"
			column :order_id
			column :courier_name
			column :tracking_number
			column :shipped_date
		end
	end
end
