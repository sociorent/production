
#set up cron job
#minute hour day-of-month mounth day-of-week command

#****************************************
#give full path
#crontab -e
#0 0 * 0 0 bundle exec rails runner '/lib/p2p/disapproval_of_items_after_15days.rb'
#****************************************


#15 days approval limit or reapprove...

  #load Rails.root.to_s + '/lib/p2p/disapproval_of_items_after_15days.rb'
  
  socio_admin = User.find_by_is_admin(1)
  admin = P2p::User.find_by_user_id(socio_admin.id)

	P2p::Item.notsold.approved.where("datediff('#{Time.now}' ,updated_at) == 15").each do |item|
		item.update_attributes(:approveddate => nil)


        admin.sent_messages.create({:receiver_id => item.user.id ,
                                              :message => "This is an auto generated system message. Your item #{item.title} has been not sold for over 15 days and hence has been disapproved .Reply to this message asking the admin to re approve if you need the item to be on sociorent.  <br/> Thank you.. <br/> Sincerly, <br/> Admin - Sociorent",
                                              :messagetype => 5,
                                              :sender_id => admin.id,
                                              :sender_status => 2,
                                              :receiver_status => 0,
                                              :parent_id => 0,
                                              :item_id => item.id

                                                  });

        # admin.sent_messages.create({:receiver_id => admin.id,
        #                                       :message => "This is an auto generated system message. #{item.title} has been idle for over 15 days and hence has been automatically disapproved and is waiting for your approval.. A automated message is sent to the user.Your can see it here <a href='" + URI.encode("/p2p/#{item.category.name}/#{item.product.name}/#{item.title}") + "'> #{item.title} </a>. <br/> Thank you.. <br/> Sincerly, <br/> Developers ",
        #                                       :messagetype => 5,
        #                                       :sender_id => admin.id,
        #                                       :sender_status => 1,
        #                                       :receiver_status => 0,
        #                                       :parent_id => 0,
        #                                       :item_id => item.id

        #                                           });



	end


	P2p::Item.notsold.approved.where("datediff('#{Time.now}' ,updated_at) == 13").each do |item|
		item.update_attributes(:approveddate => nil)


        admin.sent_messages.create({:receiver_id => item.user.id ,
                                              :message => "This is an auto generated system message. Your item #{item.title} has been not sold for over 13 days and hence will be disapproved automatically if u don ask for reapproval from the admin.. Reply to this message to know the reason.  <br/> Thank you.. <br/> Sincerly, <br/> Admin - Sociorent",
                                              :messagetype => 5,
                                              :sender_id => admin.id,
                                              :sender_status => 2,
                                              :receiver_status => 0,
                                              :parent_id => 0,
                                              :item_id => item.id

                                                  });



	end	