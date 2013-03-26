Dir.chdir(Rails.root) do
    begin

      puts 'start'

      Lock_File = File.open(Rails.root.join('log/update_bulk_vendor.lock'),'w',2)

      tme = Time.now

      csvfiles = P2p::VendorUpload.where(:processed=>false)

      csvfiles.each do |csvfile_obj|

          category = P2p::Category.find(csvfile_obj.category_id.to_i)
          csvfile = csvfile_obj.upload_csv
          csvfile_obj.update_attributes(:processed=>true)
begin

File.open(csvfile.path,"r:iso-8859-1") do |f|
            @csvs = f.read
          end
rescue Exception => e
puts e.message

end
          begin
            CSV.parse(@csvs, {:headers => true}) do |row|
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
                item.totalcount = ( ( CGI::unescape(row[3]).to_s.empty?)  ? 1 : CGI::unescape(row[3]) )
                item.condition = CGI::unescape(row[4])
                item.desc = CGI::unescape(row[6])

                paytype = [ ['courier',"1"] ]

                paytype.each do |type|
                  if type[0].downcase == CGI::unescape(row[7]).downcase
                    item.paytype = type[1]
                  end
                end

                payinfo = [['yes',1] ,['no',0] ]

                payinfo.each do |info|
                  if info[0].downcase == CGI::unescape(row[8]).downcase
                    item.payinfo = "1" + ((info[1] == 0 ) ? '' : ',1')
                  end
                end

                if item.payinfo.nil? or item.paytype.nil?
                  raise 'Failed..! wrong paytype or payinfo'
                end

                item.city = P2p::City.find_or_create_by_name(CGI::unescape(row[5]))

                image_3 = 11
                #checking the validation
                image_valid = true if row_ar[image_3]!= "" || row_ar[image_3-1] || row_ar[image_3-2]!=""
                spec_valid = false
                (12..header_count).each do |i|
                  if (!row[i].nil? and CGI::unescape(row[i]) !="")
                    spec_valid = true
                    break
                  end
                end
                if spec_valid == true && image_valid == true

                  specs= category.specs.pluck('id')

                  #saving itemspecs
                  (12..(header_count-1)).each do |i|
                    if !(row[i].nil?) and CGI::unescape(row[i])!=""

                      item.specs.new(:spec_id=>specs[12-i],:value=>CGI::unescape(row[i]))
                    end
                  end

                  #save images
                  (image_3-2..image_3).each do |i|
                    if !row[i].nil? and (/http:\/\/[^"]+\..*$/i).match(CGI::unescape(row[i]))!= nil
                      a = item.images.new(:image_url => URI.encode(row[i]) )
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
                puts "Error Occured for User\n" + e.message + "       "  + e.backtrace.join('\n')
                csvfile_obj.failed_csvs.create(:csv_data=>row.to_s ,:reason => e.message, :created_at => tme ,:categroy_id => category.id )
                next
              end
            end
          rescue  Exception => e
            puts "caught#{e}\n" + e.message + e.backtrace.join('\n')
          end
      end



    Lock_File.close()
    File.delete(Rails.root.join('log/update_bulk_vendor.lock'))

    rescue
    end
end
