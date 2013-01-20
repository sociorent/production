class BookSemester < ActiveRecord::Base
  belongs_to :book
  belongs_to :semester
  attr_accessible :semester_id

end
