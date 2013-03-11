require 'koala'
class OrdersController < ApplicationController
	# disabling the csrf token verification , since response coming from cross domain.
	protect_from_forgery :except => :create
	def create
		user = current_user
		cart = user.cart
		books = cart.books.uniq

		# total price - save this in orders
		deposit_total = 0
		rental_total = 0
		cart_items=[]
		books.each do |book|
			rental_price = ((book.price.to_i * book.publisher.rental.to_i)/100).ceil
			rental_total += rental_price
			deposit_total += book.price.to_i
			product={"productID" =>book.isbn13,"unitCost"=>rental_price,"productDescription"=>book.name}
			cart_items << product
		end
		shipping_charge = deposit_total < 1000 ? 50 : 0
		total = deposit_total + shipping_charge

		# check the transaction status, if cancelled then store nothing,, and redirect to books page
		if params[:TxStatus] && params[:TxStatus]=="CANCELED"
			flash[:warning]="Transaction Failed. Try again"
			redirect_to "/"
			return
		end

		order_type = params[:order_type]
		accept_terms_of_use = params[:accept_terms_of_use]
		user_address=JSON.parse(user.address)
		address=user_address.map{|k,v| "#{v}"}.join(',')
		# creating an order
		order = user.orders.create(:total => total, :rental_total => rental_total, :deposit_total => deposit_total, :order_type => order_type, :accept_terms_of_use => accept_terms_of_use, :status => 'new')
		if order_type=="COD"
	  	order.update_attributes(:COD_mobile=>params[:mobile_number])
		end

		unless params[:bank_id].nil?
    	bank=Bank.where(:id=>params[:bank_id]).first

    	unless bank.nil?
    		#adding the bank to order
    		order.bank = bank
    		#sending the sms
    		@bank_sms_text = "Thank you for the order #{order.random} . Please use the unique ID #{user.unique_id} while depositing cash at the bank. Thank you."
    		# send_sms(user.mobile_number,sms_text)
    	end
    end

    # adding all the books in the cart to orders
		order.books = books
		order.save

    # Changing the Current Status all books orders to unshipped
    # TODO : Should be implemented in above line
    order.books.update_all(:status => 2)

		# empty the cart
		cart.book_carts.each do |book_cart|
			book_cart.delete
		end

		delayed_job_object = DelayedJob.new
		delayed_job_object.order(user.id, order.id, @bank_sms_text)

		# For the successful transaction store the citruspay response..and redirect to print invoice page
		if params[:TxStatus] && params[:TxStatus] == "SUCCESS"
			order.update_attributes(:citruspay_response=>params.to_json())
			flash[:notice]="Transaction successful. Open Your My Account to print invoice"
			redirect_to "/print_invoice/#{order.random}"
			return
		end
		render :json => order.to_json(:include => {:books => {:only => [:name, :price, :author, :id]}})
	end

	def rented_show_more
		@rented_books = []
		count = 10
		offset = params[:offset].to_i * count
		select = params[:select]
    if select == "all"
    	@orders = Order.includes(:books).all
    else
    	college = College.where(:name => select).first
    	@orders = college.orders
    end
    @orders.each do |order|
	    if @rented_books.count <= offset
	      @rented_books += order.books
	    else
	      break
	    end
	  end
	  @rented_books = @rented_books.drop(offset-count).first(count)
	  render :json => @rented_books.to_json()
	end

	def rented_college
    @rented_books = []
    @number_of_books = 0
    count = 1
    select = params[:select]
    resp = {}
    if select == "all"
    	@orders = Order.includes(:books).all
    else
    	college = College.where(:name => select).first
    	@orders = []
    	college.users.includes(:orders).each do |user|
    		@orders += user.orders
    	end

    end
    @orders.each do |order|
      if @rented_books.count <= count
        @rented_books += order.books
        @number_of_books += order.books.count
      else
        @number_of_books += order.books.count
      end
    end
    resp[:books] = @rented_books = @rented_books.first(count)
    resp[:number_of_books] = @number_of_books
    render :json => resp.to_json()
	end

	def counter_cash_payment
		msg = {}
		counter = current_counter
		order = Order.find(params[:order_id].to_i)
		if order.order_type == "cash" && order.user.college == counter.college
			order.update_attributes(:payment_done => true)
			msg[:status] = 1
			msg[:msg] = "Order payment confirmed."
		else
			msg[:status] = 0
			msg[:msg] = "Invalid order."
		end
		render :json => msg
	end

	def verify_code
		result = 0
		if params[:mobile]
			code = rand(100000..999999)
			session[:code] = code
			sms_text= "Thanks for signing-up with Sociorent.com. Your ID is #{temp_id} . You may now login to place your order. Thank you."
			puts session[:code]
			result = 1 if send_sms(params[:mobile],sms_text)
		elsif params[:code]
			if params[:code].to_i == session[:code]
				result = 1
			end
		end
		render :text=>result and return
	end
	def print_invoice
		@order=Order.where(:random=>params[:order]).first
		@user=current_user
		render "print_invoice",:layout=>false
	end

	private
	def strip_html(html_page)
  	html_page.to_s.gsub!(/(<[^>]+>|&nbsp;|\r|\n)/,"")
	end
end