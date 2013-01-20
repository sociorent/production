ActiveAdmin.register BookOrder do
	scope :shipped
	scope :unshipped

	index do
		selectable_column
		column :book_id do |id|
			Book.find(id).name
		end
		column :shipped
		if params[:scope] == "shipped"
			column :order_id
			column :courier_name
			column :tracking_number
			column :shipped_date
		end
	end
end
