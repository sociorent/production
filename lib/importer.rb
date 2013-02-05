require 'csv'

csvfile = File.open("tmp/x.csv", "r:ISO-8859-1")
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
      puts "Saving book #{row[4]}"
      if row[7] !="" && row[7]!="0" && row[7]!=" - "
        publisher = Publisher.where(:name=>row[7]).first
        if publisher.nil?
          publisher=Publisher.create(:name=>row[7])
        end
        book["publisher_id"] =  publisher.id
      end

      # puts book
      if Book.where(:isbn13=>row[4]).count == 0
        book_save=Book.create(book)
      else
        book_save=Book.where(:isbn13=>row[4]).first
        # puts book_save
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
        if book_save.images.count==0
          book_save.images.create(:image_url=>row[13])
        else
          puts row[13]
          book_save.images.first.update_attributes(:image_url=>row[13])   
        end
      end

      book_save.save
      puts "Saved book #{book_save.id}"
      puts "--------------------------"
    end
  rescue Exception => e
    File.open("tmp/linecount.txt",'a') do |file|
      file.puts row[4]
      file.puts e.message
      file.puts "-------------------------------------"
    end
    next
  end
end
