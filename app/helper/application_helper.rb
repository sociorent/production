module ApplicationHelper

	def get_status(orders)


		state = []
		state_id = []

		puts orders.inspect


		orders.each do |order|

			#puts "Processing :  "+ order.status.to_s + orders.inspect.to_s

			if order.status.to_i == 4 and  !(state_id.include?(4))
				state.push("cancelled")
				state_id.push(4)
			elsif order.status.to_i == 2 and  !(state_id.include?(2))
				state.push("unshipped" )
				state_id.push(2)
			elsif order.status.to_i == 1 and  !(state_id.include?(1))
				state.push("shipped" )
				state_id.push(1)
			end

		end



			if state_id.count > 1

				val = "partially_" + state.join("_and_")

				case val
				 when "partially_cancelled_and_unshipped"
				 	code = 6
				 when "partially_cancelled_and_shipped"
				 	code = 5
				 when "partially_cancelled_and_unshipped_and_shipped"
				 	code = 7
				 when "partially_unshipped_and_shipped"
				 	code = 3
				 end


				return {:value => val ,:code => code}
			else
				return {:value => state[0] ,:code => state_id[0] }
			end


	end




  def self.convert_order_status(status)
  #contants for order status

     state = {
      0 => 'New' ,
      1 => 'Fully Shipped' ,
      2 => 'Fully Unshipped' ,
      3 => 'Partially Shipped and Unshipped' ,
      4 => 'Fully Cancelled',
      5 => 'Partially Cancelled and Partially Shipped',
      6 => 'Partially Cancelled and Partially Unshipped',
      7 => 'Partially Cancelled and Partially Unshipped and Partially Shipped',
      8 => 'Approved'
    }

    state[status];
 end


  def p2p_current_user
  	if current_user.nil?
  		return nil
  	else
  		return P2p::User.find_by_user_id(current_user.id)
  	end

  end

  def get_seller_url
  	begin
      p2p_current_user
  	if session[:userid]
  		if p2p_current_user.mobileverified == true
        url = "/street/sellitem"
      else
      	url = "#seller_mobile_verify_modal"
      end
    else
    	url = "#head_login_modal"
    end
    return url
  rescue
  	session.delete(session[:userid])
  	session.delete(session[:user_type])
  end

  end
end