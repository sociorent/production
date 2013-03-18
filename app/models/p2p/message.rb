class P2p::Message < ActiveRecord::Base
  attr_accessible :item_id, :message, :messagetype, :created_at, :updated_at, :sender_id ,:receiver_id, :sender_status ,:receiver_status,:parent_id
  
  
  # Associations to User
  belongs_to :sender, :class_name=>'P2p::User', :foreign_key=>'sender_id'
  belongs_to :receiver, :class_name=>'P2p::User', :foreign_key=>'receiver_id'

  has_one :parent_msg ,:class_name => 'P2p::Message' , :foreign_key => 'parent_id'

  belongs_to :item
  
  #messge cod
  # 0 unread
  # 1 read
  # 2 sent
  # 3 deleted
  #4 permenantly deleted
  #5 system generate
  #6, welcome message

  scope :unread, where("receiver_status = 0")
  scope :inbox, where("receiver_status = 0 or receiver_status = 1 ")
  scope :receiver_deleted, where(:receiver_status => 3)
  scope :sender_deleted, where(:sender_status=>3)
  scope :sentbox, where( :sender_status => 2)

  # scope :sentbox_deleted ,where( :sender_status => 3)
  # scope :inbox_deleted ,where( :receiver_status => 3)

  # scope :deleted inbox_deleted.merge(sentbox_deleted)

  validates :receiver_id, :presence=>true
  scope :deleted, lambda { |user|
    where("(sender_id = #{user.id} and sender_status=3) or (receiver_id = #{user.id} and receiver_status=3)")
  } 

  after_create :publish_to_stream

  def publish_to_stream


    message_notification = "

        if (oInboxTable){
          oInboxTable.fnDraw();
        }
        
        if (oSentBoxTable){
          oSentBoxTable.fnDraw();
        }

        if (oDeleteBoxTable){
          oDeleteBoxTable.fnDraw();
        }
      "

      if self.messagetype !=5 
        message_notification += "
        $('#notificationcontainer').notify('create', 'new_message_notification', {
              username: '#{self.sender.user.name}',
              msg: '#{self.message.slice(0,40)}'
          });"

      end

    receiver_unreadcount = self.receiver.received_messages.inbox.unread.count

      if receiver_unreadcount > 0 
            unread_msg = "$('#unread_count').html('(#{receiver_unreadcount})');"
            header_msg = "$('#header_msg_count').html('(#{receiver_unreadcount})');"
      else
            unread_msg = "$('#unread_count').html('');"
            header_msg = "$('#header_msg_count').html('');"
      end

      



    PrivatePub.publish_to("/user_#{self.receiver.id}", header_msg + unread_msg + message_notification )
  end

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
