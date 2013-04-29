class P2p::City < ActiveRecord::Base
  attr_accessible :latitude, :longitude, :name ,:pickup ,:show_city
  has_many :items , :class_name => 'P2p::Item'

	after_save do

      # socio_admin = User.find_by_is_admin(1)
      # admin = P2p::User.find_by_user_id(socio_admin.id)

      #   admin.sent_messages.create({:receiver_id => admin.id,
      #                                         :message => "Auto Generated Message.<br/><h4>Fall back creation</h4>. The city  #{self.name} was not found in your system and hence is created automatically for you. We urge you to check the same. Sincerally - Developers",
      #                                         :messagetype => 5,
      #                                         :sender_id => admin.id,
      #                                         :sender_status => 2,
      #                                         :receiver_status => 0,
      #                                         :parent_id => 0,
      #                                         :item_id => nil
      #                                        });

	end
end
