class P2p::FailedCsv < ActiveRecord::Base
	belongs_to :vendors_upload
	attr_accessible :csv_data,:reason ,:created_at ,:category_id

	belongs_to :category , :class_name => "P2p::Category"
end
