class ClassAdoption < ActiveRecord::Base
  belongs_to :book
  belongs_to :college
  
  attr_accessible :rate, :book_id, :college_id

end