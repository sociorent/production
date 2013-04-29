class Company < ActiveRecord::Base
  attr_accessible :name, :offer_position, :offer_stipend, :image_attributes

  has_many :company_users
  has_many :users, :through => :company_users

  has_one :image, :as => :imageable_socio

  accepts_nested_attributes_for :image, :allow_destroy => true
end
