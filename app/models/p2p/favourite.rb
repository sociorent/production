class P2p::Favourite < ActiveRecord::Base
  belongs_to :p2puser , :foreign_key => 'user_id' ,:class_name => 'P2p::User'
  belongs_to :p2pfav , :foreign_key => 'fav_id' ,:class_name => 'P2p::User'
  # attr_accessible :title, :body
  attr_accessible :fav_id
  
end
