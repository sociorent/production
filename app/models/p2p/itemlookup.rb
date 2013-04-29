class P2p::Itemlookup < ActiveRecord::Base
  attr_accessible :view_count,:item_id
  belongs_to :item, :class_name=>"P2p::Item"
end
