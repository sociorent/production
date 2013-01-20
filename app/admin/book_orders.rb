ActiveAdmin.register BookOrder do
	scope :Shipped
	scope :Unshipped
	scope :Cancelled
	menu :label => "Shipping"
	config.clear_action_items!
	index do
		selectable_column
		column :book_id do |id|
			Book.find(id).name
		end
		column "Order Date", :created_at
		if params[:scope] == "shipped"
			column :order_id
			column :courier_name
			column :tracking_number
			column :shipped_date
		end
	end
end
