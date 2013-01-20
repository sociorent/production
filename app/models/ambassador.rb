class Ambassador < ActiveRecord::Base
  belongs_to :college
  has_many :users

  belongs_to :ambassador_manager, :class_name => "User", :foreign_key => "ambassador_manager_id"
  
  attr_accessible :college_id, :ambassador_manager_id
end