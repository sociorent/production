class P2p::User < ActiveRecord::Base
  belongs_to :user ,:class_name => "::User" 
  
  attr_accessible :mobileverified, :user_id

  has_many :items
  has_many :credits
 # Association for Messages
  has_many :sent_messages, :class_name=>'P2p::Message', :foreign_key=>'sender_id'
  has_many :received_messages, :class_name=>'P2p::Message', :foreign_key=>'receiver_id'
  
end
