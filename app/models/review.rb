class Review < ActiveRecord::Base
  attr_accessible :rating, :content, :book_id, :user_id

  belongs_to :book
  belongs_to :user

end
