class Csvupload < ActiveRecord::Base
  attr_accessible :books_uploaded, :csv, :isbns_not_uploaded, :total_books, :status
  has_attached_file :csv
 	rails_admin do
  	edit do
  		field :csv
  	end
		list do
			field :csv
			field :status do 
				label "Status of Upload"
			end
			field :books_uploaded
		end
		show do
			field :csv
			field :status do 
				label "Status of Upload"
			end
			field :books_uploaded
		end
			

	end
end
