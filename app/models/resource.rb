class Resource < ActiveRecord::Base
  attr_accessible :link, :name, :image_attributes

  has_one :image, :as => :imageable_socio

  accepts_nested_attributes_for :image, :allow_destroy => true

end