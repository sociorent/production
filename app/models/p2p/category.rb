class P2p::Category < ActiveRecord::Base
  attr_accessible :name, :category_id,:priority

  belongs_to :category , :class_name => "P2p::Category"
  has_many :products , :class_name => "P2p::Product"
  has_many :specs ,:class_name => "P2p::Spec"
  
  define_index do
    indexes :name
    indexes p2p_products(:name), :as=> :product_name
    has created_at,updated_at
  end

end
