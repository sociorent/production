class Cart < ActiveRecord::Base
  # attr_accessible :title, :body

  has_many :book_carts
  has_many :books, :through => :book_carts

  belongs_to :user
end
