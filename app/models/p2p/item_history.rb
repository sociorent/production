class P2p::ItemHistory < ActiveRecord::Base
  belongs_to :p2p_items , :class_name => 'P2p::Item'
  attr_accessible :approved, :columnname, :newvalue, :oldvalue ,:created_at



end
