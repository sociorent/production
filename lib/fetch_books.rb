		
# File.open("tmp/isbn.txt","r:ISO-8859-1") do |file|
# 	@isbns = file.gets().split(",")
# end
puts "===================="
puts "fetched isbn numbers"
puts "===================="

#store isbn for which we could not get the details
isbn_failed=[]
@isbns= ["9789381068816"]

#Loop over all the isbns we got and fetch the details from
#flipkart
@isbns.each do |isbn|
	@failed = false
	begin
  	if BookApi.where(:isbn13 => isbn).count > 0 
    		puts "ISBN : #{isbn} Already in db"
    		next
  	end
    book_details = BookFinder.flipkart(isbn)

    #if the isbn is present store the book details
    unless book_details["ISBN-13"].empty?
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

      #if the BookApi Could not be created then
      #store it in the failed isbn storage
      unless BookApi.create(book)
      	puts "Unable To create Book API"
      	@failed = true
      end
      puts "ISBN :#{isbn} completed"
      puts book

      #if there is not details for the requested isbn
      # then store it in the failed isbn list
    else
    	puts "No required Field SO failed"
    	@failed = true
    end
    if @failed == true
    	puts "ISBN :#{isbn} Failed"
    	File.open("tmp/failed.txt",'a') do |file|
					file.puts("#{isbn},")
		end
	end
  rescue
  	puts "Exception :ISBN :#{isbn} Failed"
  	File.open("tmp/failed.txt",'a') do |file|
					file.puts("#{isbn},")
		end
  	next
  end
end
