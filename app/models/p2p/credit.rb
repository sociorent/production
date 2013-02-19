class P2p::Credit < ActiveRecord::Base
  belongs_to :user
  attr_accessible :available, :totalCredits, :type

  before_save :set_available

  def set_available

  	self.available = self.totalCredits if self.new_record?

  end
end
