class BookOrder < ActiveRecord::Base
  attr_accessible :shipped, :tracking_number, :courier_name, :shipped_date, :status
  belongs_to :book
  belongs_to :order
  scope :Unshipped, (where :status => 2)
  scope :Shipped, (where :status => 1)
  scope :Cancelled, (where :status => 4)
end
