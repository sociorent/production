class P2p::City < ActiveRecord::Base
  attr_accessible :latitude, :longitude, :name
  has_many :items , :class_name => 'P2p::Item'
  
end
