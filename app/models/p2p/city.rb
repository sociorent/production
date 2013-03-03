class P2p::City < ActiveRecord::Base
  attr_accessible :latitude, :longitude, :name ,:pickup
  has_many :items , :class_name => 'P2p::Item'

	after_save do 


      adminid = 2

        P2p::User.find(1).sent_messages.create({:receiver_id => adminid,
                                              :message => "Auto Generated Message.<br/><h4>Fall back creation</h4>. The city  #{self.name} was not found in your system and hence is created automatically for you. We urge you to check the same. Sincerally - Developers",
                                              :messagetype => 5,
                                              :sender_id => adminid,
                                              :sender_status => 2,
                                              :receiver_status => 0,
                                              :parent_id => 0,
                                              :item_id => nil
                                             });

	end  
end
