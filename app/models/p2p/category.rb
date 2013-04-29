class P2p::Category < ActiveRecord::Base
  attr_accessible :name, :category_id,:priority ,:specs_attributes,:products_attributes,:courier_charge , :commission

  has_many :subcategories ,:class_name => "P2p::Category" ,:foreign_key => "category_id"
  belongs_to :category , :class_name => "P2p::Category"

  has_many :products , :class_name => "P2p::Product"

  #has_many :subproducts , :class_name => "P2p::Product",:through => :subcategories
  has_many :specs ,:class_name => "P2p::Spec"


  #for nested form
  accepts_nested_attributes_for :products ,:allow_destroy => true
  accepts_nested_attributes_for :specs ,:allow_destroy => true
  scope :main_categories, where("category_id is null").order(:priority)



  has_many :items , :through => :products

  define_index do
    indexes :name

#    set_property :delta =>true

    #indexes p2p_products(:name), :as=> :product_name

    #has created_at,updated_at
  end

end
