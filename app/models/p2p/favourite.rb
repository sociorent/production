class P2p::Favourite < ActiveRecord::Base
  belongs_to :p2puser , :foreign_key => 'user_id' ,:class_name => 'P2p::User'
  # attr_accessible :title, :body
end
