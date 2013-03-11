class P2p::FailedCsv < ActiveRecord::Base
	belongs_to :vendors_upload
	attr_accessible :csv_data
end
