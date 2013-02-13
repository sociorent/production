class P2p::Product < ActiveRecord::Base

  attr_accessible :name, :category_id ,:priority

  belongs_to :category , :class_name => "P2p::Category"
  has_many :items , :class_name => "P2p::Item"
  
  define_index do
    indexes :name
   
  end
  
end
