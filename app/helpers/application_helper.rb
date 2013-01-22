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
end
