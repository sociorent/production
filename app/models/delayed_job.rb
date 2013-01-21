require Rails.root.join('lib','Gharpay.rb')

class DelayedJob
	def send_sms(receipient,msg)
    user_pwd="Sathish@sociorent.com:Sathish1"
    sender_id="SOCRNT"
    url= "http://api.mVaayoo.com/mvaayooapi/MessageCompose?user=#{user_pwd}&senderID=#{sender_id}&receipientno=#{receipient}&dcs=0&msgtxt=#{msg}&state=4"
    agent =Mechanize.new
    page = agent.get(url)
    puts page.body
  end

  def order(user_id, order_id, bank_sms_text)
  	general = General.first
  	user = User.find(user_id)
  	order = user.orders.find(order_id)
  	books = order.books
  	# facebooks actions for order
  	if ENV["RAILS_ENV"] == "production"
	    # koala publish actions 
	    unless user.token.nil?
	    	token = user.token
	    	graph  = Koala::Facebook::API.new(token)
	    	books.each do |book|
		    	book_url = "http://www.sociorent.in/book/details/#{book.id}"
		    	graph.put_connections("me", "sociorent:rented", :book => book_url)
		    end
	    end
	  end

	  # sms
		if order.order_type == "bank"
    	send_sms(user.mobile_number,bank_sms_text)
    else 
    	send_sms(user.mobile_number,"Your order #{order.random} has been successfully received and will be processed. Please visit Sociorent.com to track the status of the order. Thank you.")
    end

    # mail 
		UserMailer.order_email(user, order).deliver
		
    # gharpay
    if order.order_type=="gharpay"
    	cart_items=[]
			order.books.each do |book|
				rental_price = (book.price.to_i * book.publisher.rental.to_i)/100
				product={"productID" =>book.isbn13,"unitCost"=>rental_price,"productDescription"=>book.name}
				cart_items << product
			end
			order_array={}
			user_address=JSON.parse(user.address)
			address=user_address.map{|k,v| "#{v}"}.join(',')
			dd=Time.now + (24*60*60*3)
			delivery=dd.strftime("%d-%m-%Y")
    	order_array["customerDetails"]={"firstName"=>user.name,"contactNo"=>user.mobile_number,"address"=>address}
    	order_array["orderDetails"]={"deliveryDate"=>delivery,"pincode"=>user_address["address_pincode"],"orderAmount"=>order.total,"clientOrderID"=>order.random}
    	order_array["productDetails"]=cart_items
	    g=Gharpay::Base.new('gv%tn3fcc62r0YZM','ccxjk24y6y%%%d!#')
	    gharpay_resp = g.create_order(order_array)
	    if gharpay_resp["status"]==true
	    	order.update_attributes(:gharpay_id=>gharpay_resp["orderID"])
	    end
		end
	end

	handle_asynchronously :order, :run_at => Proc.new { 5.minutes.from_now }
end