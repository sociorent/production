class P2p::ItemSpec < ActiveRecord::Base

  belongs_to :spec ,:class_name => 'P2p::Spec'
  belongs_to :item ,:class_name => 'P2p::Item'

  attr_accessible :value   
end
