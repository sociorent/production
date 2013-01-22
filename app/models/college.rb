class College < ActiveRecord::Base
  attr_accessible :name

  has_many :users

  has_many :orders, :through => :users

  has_many :class_adoptions, :dependent => :destroy

  has_and_belongs_to_many :ambassadors

  has_many :counters

  has_many :book_colleges
  has_many :books, :through => :book_colleges
end
