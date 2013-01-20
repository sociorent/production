class Shipping < ActiveRecord::Base
  belongs_to :order
end
