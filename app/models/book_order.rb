class BookOrder < ActiveRecord::Base
  attr_accessible :shipped, :tracking_number, :courier_name, :shipped_date, :status
  belongs_to :book
  belongs_to :order
  scope :Unshipped, (where :status => 'unshipped')
  scope :Shipped, (where :status => 'shipped')
  scope :Cancelled, (where :status => 'cancel')
end
