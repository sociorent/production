class P2p::VendorUpload < ActiveRecord::Base
	has_attached_file :upload_csv
	belongs_to :user, :class_name=>"P2p::User"
	attr_accessible :upload_csv, :upload_csv_file_name, :processed,:category_id
	validates :upload_csv, :presence=>true
	has_many :failed_csvs, :class_name=>"P2p::FailedCsv"
end
