csvfiles = P2p::VendorUpload.where(:processed=>false)

csvfiles.each do |csvfile_obj|
    category = P2p::Category.find(csvfile_obj.category_id.to_i)
    csvfile = csvfile_obj.upload_csv
    csvfile_obj.update_attributes(:processed=>true)
    begin
      CSV.foreach(csvfile.path, {:headers => true}) do |row|
        next if row.header_row?
        row_ar = row.to_a
        header_count = row.count
        begin
          item = csvfile_obj.user.items.new
          item.category = category
          item.product= category.products.find_or_create_by_name(CGI::unescape(row[0]))
          item.title = CGI::unescape(row[1])
          #saving to database
          item.price = CGI::unescape(row[2])
          item.condition = CGI::unescape(row[3])
          item.desc = CGI::unescape(row[5])

          paytype = [ ['courier',"1"] ]

          paytype.each do |type|
            if type[0].downcase == CGI::unescape(row[6]).downcase
              item.paytype = type[1]
            end
          end

          payinfo = [['yes',1] ,['no',0] ]

          payinfo.each do |info|
            if info[0].downcase == CGI::unescape(row[7]).downcase
              item.payinfo = "1" + ((info[1] == 0 ) ? '' : ',1')
            end
          end

          if item.payinfo.nil? or item.paytype.nil?
            puts 'Failed..!'
            next
          end

          item.city = P2p::City.find_or_create_by_name(CGI::unescape(row[4]))

          image_3 = 10
          #checking the validation
          image_valid = true if row_ar[image_3]!= "" || row_ar[image_3-1] || row_ar[image_3-2]!=""
          spec_valid = false
          (11..header_count).each do |i|

            if (CGI::unescape(row[i]) !="")
              spec_valid = true
              break
            end
          end
          if spec_valid == true && image_valid == true

            specs= category.specs.pluck('id')

            #saving itemspecs
            (11..(header_count-1)).each do |i|
              if !(row[i].nil?) and CGI::unescape(row[i])!=""

                item.specs.new(:spec_id=>specs[11-i],:value=>CGI::unescape(row[i]))
              end
            end

            #save images
            (image_3-2..image_3).each do |i|
              if !row[i].nil? and (/http:\/\/[^"]+\..*$/i).match(CGI::unescape(row[i]))!= nil
                a = item.images.new(:image_url => CGI::unescape(row[i]) )
                a.download_remote_image

              end
            end

            if item.is_valid_data?
              item.save
            else
              raise "Data not Valid"
            end
          end
        rescue Exception => e
          puts "Error Occured for User"
          csvfile_obj.failed_csvs.create(:csv_data=>row.to_json())
          next
        end
      end
    rescue  Exception => e
      puts "caught#{e}"
      csvfile_obj.update_attributes(:processed=>false)
    end
end