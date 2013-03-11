
#development

# item = P2p::Item.find(4)

# item.solddate = DateTime.now.prev_day.prev_day
# item.save

# item.item_deliveries.update_all("p2p_status = 2" , "p2p_status = 3")




	#get admin user
	@admin = P2p::User.find_by_user_id(User.find_by_is_admin(1).id)


def send_warning(item)
	puts "Sending warining for "	 + item.title

		pay = item.item_deliveries.where('p2p_status = 2').first

        @admin.sent_messages.create({:receiver_id => @admin.id,
                                                  :message => "This is an auto generated system message. <a href='/p2p/#{item.category.name}/#{item.product.name}/#{item.title}'>#{item.title}</a> was ordered on  #{item.solddate}. You had agreed to ship the item by 2 days. Please dont forget to ship the item - System",
                                                  :messagetype => 5,
                                                  :sender_id => @admin.id,
                                                  :sender_status => 2,
                                                  :receiver_status => 0,
                                                  :parent_id => 0
                                                  });

end

def refund_money(item)
	puts "\n\n\n\n"
	puts "Refundin money for "	 + item.title
	puts "\n\n\n\n"

  item.solddate = nil
  item.item_deliveries.update_all("p2p_status = 3" , "p2p_status = 2")
  item.save

end



P2p::ItemDelivery.update_all('p2p_status = 1','citrus_ref_no is null')

P2p::Item.sold.where("paytype = 1 and id in (select p2p_item_id from  p2p_item_deliveries where p2p_status = 2)").each do |item|
	
	days = item.payinfo.split(',')[0].to_i

	temp = item.solddate.to_datetime.next
	count = 1


	while(count <= days and temp < DateTime.now)

		if  (1..5).include?(temp.wday)
			count +=1
		end
		temp = temp.next

	end

	if count >= days 
		refund_money(item)
	else count >=(days + 2)
		send_warning(item)
	end

end
