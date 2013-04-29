
#development

# item = P2p::Item.find(4)

# item.solddate = DateTime.now.prev_day.prev_day
# item.save

# item.item_deliveries.update_all("p2p_status = 2" , "p2p_status = 3")

warning_file = 'item_warning.html'
refunding_file = 'item_error.html'

#get admin user
@admin = P2p::User.find_by_user_id(User.find_by_is_admin(1).id)

def send_warning(item)

		puts "Sending warining for "	 + item.title

		pay = item.item_deliveries.paysuccess.where('p2p_status = 2')

		pay.each do |apay |
    		@admin.sent_messages.create({:receiver_id => apay.item.user.id,
                                 :message => "This is an auto generated system message. <a href='#{make_item_url(item)}'>#{item.title}</a> was ordered on  #{item.solddate}. You had agreed to ship the item by 2 days. Please dont forget to ship the item - System",
                                 :messagetype => 5,
                                 :sender_id => @admin.id,
                                 :sender_status => 2,
                                 :receiver_status => 0,
                                 :parent_id => 0
                               });

    apay.p2p_status = 8
    apay.save

    aa = "<br/><br/><hr/><br/>
    			********************************************** <br/>
    			Start <br/>
    			********************************************** <br/>
    		  Sending Warning <br/>

    		  Item: #{item.inspect}
    		  <br/>
    		  Pay: #{apay.inspect}
    		  <br/>
    			********************************************** <br/>
    			End <br/>
    			********************************************** <br/>

    		";

    File.write(Rails.root.join("public/#{warning_file}"),'a+') {|file| file.write()}


    end



end

def refund_money(item)
	puts "\n\n\n\n"
	puts "Refundin money for "	 + item.title
	puts "\n\n\n\n"

  #item.solddate = nil

  #item.item_deliveries.update_all("p2p_status = 3" , "p2p_status = 2")
  #item.save

  pay = item.item_deliveries.paysuccess.where('p2p_status = 8')

  pay.each do |apay|

			  @admin.sent_messages.create({:receiver_id => @admin.id,
			                              :message => "This is an auto generated system message. <a href='#{make_item_url(item)}'>#{item.title}</a> was ordered on  #{item.solddate}. The product was not shipped on time and hence the amount has to be refunded to the buyer <br/> CITRUSPAY ID: #{apay.citrus_pay_id} <br/> Txn ID: #{apay.txn_id} <br/> Buyer: #{apay.buyer.user.name}<br/> Email: #{apay.buyer.user.email}  - System",
				                            :messagetype => 5,
				                            :sender_id => @admin.id,
				                            :sender_status => 2,
				                            :receiver_status => 0,
				                            :parent_id => 0
				                            });

			  @admin.sent_messages.create({:receiver_id => apay.item.user.id,
			                              :message => "This is an auto generated system message. <a href='#{make_item_url(item)}'>#{item.title}</a> was ordered on  #{item.solddate}. The product was not shipped on time and hence the amount is refunded to the buyer. Your product has been moved to not sold items and will be available on site for selling - System",
				                            :messagetype => 5,
				                            :sender_id => @admin.id,
				                            :sender_status => 2,
				                            :receiver_status => 0,
				                            :parent_id => 0
				                            });

 	apay.p2p_status = 3
 	apay.save

 	apay.item.soldcount -= 1

 	begin
 		apay.item.solddate =  item.item_deliveries.where('p2p_status = 2').order('created_at desc').first
 	rescue
 		apay.item.solddate = nil
 	end

 	apay.item.save



    aa = "<br/><br/><hr/><br/>
    			********************************************** <br/>
    			Start <br/>
    			********************************************** <br/>
    		  Sending Warning <br/>

    		  Item: #{item.inspect}
    		  <br/>
    		  Pay: #{apay.inspect}
    		  <br/>
    			********************************************** <br/>
    			End <br/>
    			********************************************** <br/>

    		";

    File.write(Rails.root.join("public/#{refunding_file}"),'a+') {|file| file.write()}


	end

end



P2p::ItemDelivery.update_all('p2p_status = 1','citrus_ref_no is null')

#find all items for sending warning
P2p::Item.sold.where("paytype = 1 and id in (select p2p_item_id from p2p_item_deliveries where p2p_status = 2)").uniq.each do |item|

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


#find all items for refundin
P2p::Item.sold.where("paytype = 1 and id in (select p2p_item_id from p2p_item_deliveries where p2p_status = 8)").uniq.each do |item|

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
