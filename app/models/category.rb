class Category < ActiveRecord::Base
  attr_accessible :name, :books_attributes

  has_many :books

  accepts_nested_attributes_for :books, :allow_destroy => true
  def self.find_by_name(name)
  	User.find(:all, :conditions => ["name = lower(?)", name.downcase])
	end
end
