class P2p::Message < ActiveRecord::Base
  attr_accessible :item_id, :message, :messageself , :messagetype, :readdatetime, :receiver, :sender, :flag, :sender_status
  
  
  # Associations to User
  belongs_to :sender, :class_name=>'P2p::User', :foreign_key=>'sender_id'
  belongs_to :receiver, :class_name=>'P2p::User', :foreign_key=>'receiver_id'

  belongs_to :item
  
  # scopes to the messages
  scope :inbox, where("flag = 'unread' or flag = 'read'")
  scope :sentbox, where(:sender_status => "sent")


  	def message_type

		if self.messagetype == 0 
			return "Sell Request".html_safe
		elsif self.messagetype == 1 
			return "Buy Request".html_safe
		elsif self.messagetype == 2
			return "Admin".html_safe
		else
			return "Unknown".html_safe
		end

	end


end
