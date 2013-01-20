class BookCollege < ActiveRecord::Base
  belongs_to :book
  belongs_to :college
  attr_accessible :college_id

end