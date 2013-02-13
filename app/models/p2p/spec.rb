class P2p::Spec < ActiveRecord::Base
  
  attr_accessible :display_type, :name ,:category_id ,:priority
  
  belongs_to :category

  has_many :itemspecs ,:class_name => "P2p::ItemSpec"

  define_index do
    indexes :name
    has created_at,updated_at
  end
  
end
