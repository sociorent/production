require 'csv'
csvfiles = Csvupload.where(:status=>nil)
csvfiles.each do |csvfile|
  File.open(csvfile.csv.path,"r:iso-8859-1") do |f|
    @csvs = f.read
  end
  puts "=========================================="
  puts "Opening file :#{csvfile.csv.path}"
  puts "=========================================="
  total_books = 0
  attempts = 0
  isbns_not_uploaded = []
  @books_uploaded = 0
  begin
    CSV.parse(@csvs) do |row|
      total_books += 1
      @isbn = row[4]
      unless row[4] == "" || row[4] == "0" || row[4] ==" - "
        puts "================================="
        puts "Starting --- #{row[4]}-----------"
        puts "================================="
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

        if row[7] !="" && row[7]!="0" && row[7]!=" - "
            publisher = Publisher.where(:name=>row[7]).first
            if publisher.nil?
              publisher=Publisher.create(:name=>row[7])
            end
            book["publisher_id"] = publisher.id
        else
            puts "No publisher.."
        end

        # puts book
        if Book.where(:isbn13=>row[4]).count == 0
          book_save=Book.create(book)
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
        else
          book_save=Book.where(:isbn13=>row[4]).first
          #puts book_save
          book_save.update_attributes(book)
        end

        college = College.where(:name =>row[17]).first

        college = College.create(:name=>row[17]) if college.nil?
        

        book_save.book_colleges.create(:college_id=>college.id)
        stream=Stream.where(:name =>row[18]).first

        
        stream=Stream.create(:name=>row[18]) if stream.nil?
        
        book_save.book_streams.create(:stream_id=>stream.id)
        #book_save.publisher=publisher

        book_save.save
        #csvfile.update_attributes(:total_books=>total_books, :books_uploaded=>@books_uploaded,:isbns_not_uploaded=>isbns_not_uploaded.join(","))
        puts "===================="
        puts "Book #{@isbn} saved"
        puts "===================="
        @books_uploaded += 1
      end
    end
    csvfile.update_attributes(:status=>"finished")
  rescue Exception => e
    puts "#{e.message}"
    puts "==========================="
    puts "Error sync ------#{@isbn}"
    puts "==========================="
    isbns_not_uploaded << @isbn
    puts isbns_not_uploaded
    #csvfile.update_attributes(:total_books=>total_books, :books_uploaded=>@books_uploaded,:isbns_not_uploaded=>isbns_not_uploaded.join(","),:status=>"error")
    attempts += 1
    retry unless attempts > 3
  end
end