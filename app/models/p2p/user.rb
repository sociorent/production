class P2p::User < ActiveRecord::Base
  belongs_to :user ,:class_name => "::User"

  has_many :items

  has_many :payments ,:class_name => "P2p::ItemDelivery" , :foreign_key => 'buyer'
  has_many :soldpayments ,:class_name => "P2p::ItemDelivery" , :through => :items ,:source => :item_deliveries

  has_many :vendor_uploads, :class_name=>"P2p::VendorUpload"
  attr_accessible :mobileverified, :user_id ,:user_type, :mobile_number ,:address

  #user_type
  # => 0 normal user
  # => 1 vendor
  #

  belongs_to :city ,:class_name => P2p::City

  has_many :credits
 # Association for Messages
  has_many :sent_messages, :class_name=>'P2p::Message', :foreign_key=>'sender_id'
  has_many :received_messages, :class_name=>'P2p::Message', :foreign_key=>'receiver_id'

  has_many :favouriteusers ,:class_name => 'P2p::Favourite', :foreign_key => 'user_id'
end
