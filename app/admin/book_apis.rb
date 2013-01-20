require 'csv'
ActiveAdmin.register BookApi do
	collection_action :book_details_form do
	end
  collection_action :get_book_details, :method=>:post do
	  isbns = params[:isbn].split(",")
	  isbn_failed=[]
	  isbns.each do |isbn|
	    if isbn.to_i.is_a? (Integer)
	      book_details = BookFinder.flipkart(isbn)
	      puts book_details
	      unless book_details['Book'].empty?
		      book = Hash.new()
		      book["book"] = book_details["Book"]
		      book["author"] = book_details["Author"]
		      book["isbn"] = book_details["ISBN-10"] || book_details["ISBN"]
		      book["isbn13"] = book_details["ISBN-13"]
		      book["binding"] = book_details["Binding"]
		      book["publishing_date"] = book_details["Publication Year"]
		      book["publisher"] = book_details["Publisher"]
		      book["edition"] = book_details["Edition"]
		      book["number_of_pages"] = book_details["Number of Pages"]
		      book["language"] = book_details["Language"]
		      book["image_url"]=book_details["img_url"]
		      book["availability"]=book_details["availability"]
		      book["price"]=book_details["price"]
		      book["description"]=book_details["description"]
		      book["college"]=book_details["college"]
		      book["stream"]=book_details["stream"] 
		      unless BookApi.create(book)
		      	isbn_failed << isbn
		      end
		    else
		    	isbn_failed << isbn
		    end
	    end
	  end
	  flash[:notice] = (isbn_failed.count > 0) ? "#{isbn_failed.join(",")} isbns failded to update" : "Books created"
	  redirect_to :action => :index
	end
	collection_action :finalize_book_form do
	end
	collection_action :update_book_details, :method=>:post do
    csvfile = params[:book_csv].read
    CSV.parse(csvfile) do |row|
	    begin
	      unless row[7] == "" || row[7] == "0" || row[7] ==" - "
	        book = Hash.new()
	        book["name"] = row[1]
	        book["author"] = row[2]
	        book["isbn10"] =row[3]
	        book["isbn13"] = row[4]
	        book["binding"] = row[5]
	        book["published"] = row[6]
	        book["edition"] = row[8]
	        book["pages"] = row[9]
	        book["availability"]=row[14]
	        book["price"]=row[15]
	        book["description"]=row[16].force_encoding("UTF-8") if row[16]
	        book["description"].gsub!('<a href="#">top</a>',"") if row[16]
	        
	        if row[16] && book["description"].valid_encoding?
	          # book["language"] = row[10]
	          if row[7] !="" && row[7]!="0" && row[7]!=" - "
	            publisher = Publisher.where(:name=>row[7]).first
	            if publisher.nil?
	              publisher=Publisher.create(:name=>row[7])
	            end
	          end
	        end

	        # puts book
	        if Book.where(:isbn13=>row[4]).count == 0
	          book_save=Book.create(book)
	        else
	          book_save=Book.where(:isbn13=>row[4]).first
	          puts book_save
	          book_save.update_attributes(book)
	        end

	        college = College.where(:name =>row[17]).first

	        college = College.create(:name=>row[17]) if college.nil?
	        

	        book_save.book_colleges.create(:college_id=>college.id)
	        stream=Stream.where(:name =>row[18]).first

	        
	        stream=Stream.create(:name=>row[18]) if stream.nil?
	        
	        book_save.book_streams.create(:stream_id=>stream.id)
	        book_save.publisher=publisher

	        if row[13] !="" && row[13]!="0" && row[13]!=" - "
	          begin
	            if book_save.images.nil? 
	              book_save.images.create(:image_url=>row[13])
	            else
	              book_save.images.first.update_attributes(:image_url=>row[13])   
	            end
	          rescue
	          end
	        end
	        book_save.save
	      end
	    rescue EncodingError => e
	      puts "Bad encoding"
	      next
	    end
	  end
	  redirect_to "/admin/books"
  end
  action_item :only => [:index] do
    link_to('Get Book Details',book_details_form_admin_book_apis_path())
  end
  action_item :only => [:index] do
    link_to('Update Book Details',finalize_book_form_admin_book_apis_path())
  end
end
