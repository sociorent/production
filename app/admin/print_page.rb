ActiveAdmin.register_page "Print Page" do
	content do
		@order=Order.find(params[:order])
		shipped_date = params[:date] || Time.now
		@shipped=@order.book_orders.where("DATE(shipped_date)=Date(?)",shipped_date)
		total_amount = @shipped.inject(0) {|sum, hash| sum + hash.book.price} #=> 30
		render :partial =>"index", :locals=>{ :order=>@order,:total_amount=>total_amount,:shipped=>@shipped}
	end
end