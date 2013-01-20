class BookStream < ActiveRecord::Base
  belongs_to :book
  belongs_to :stream
  attr_accessible :stream_id

end
