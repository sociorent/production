
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

	P2p::Item.notsold.approved.where("datediff('#{Time.now}' ,approveddate) = 15 and totalcount = 1 ").each do |item|
    next if item.owner.user_type == 1
		item.update_attributes(:approveddate => nil)

    admin.sent_messages.create({:receiver_id => item.user.id ,
                                              :message => "This is an auto generated system message. Your item <a href='#{make_item_url(item)}'> #{item.title} </a> has been idel for over 15 days and hence has been disapproved .Reply to this message asking the admin to re approve if you need the item to be on sociorent.  <br/> Thank you.. <br/> Sincerly, <br/> Admin - Sociorent",
                                              :messagetype => 5,
                                              :sender_id => admin.id,
                                              :sender_status => 2,
                                              :receiver_status => 0,
                                              :parent_id => 0,
                                              :item_id => item.id

                                                  });
	end



	P2p::Item.notsold.approved.where("datediff('#{Time.now}' ,approveddate) = 13 and totalcount = 1").each do |item|
    next if item.owner.user_type == 1

		#item.update_attributes(:approveddate => nil)


    admin.sent_messages.create({:receiver_id => item.user.id ,
                                              :message => "This is an auto generated system message. Your item #{item.title} has been not sold for over 13 days and hence will be disapproved automatically with in 2 days. Reply to this message to know the reason.  <br/> Thank you.. <br/> Sincerly, <br/> Admin - Sociorent",
                                              :messagetype => 5,
                                              :sender_id => admin.id,
                                              :sender_status => 2,
                                              :receiver_status => 0,
                                              :parent_id => 0,
                                              :item_id => item.id

                                                  });



	end