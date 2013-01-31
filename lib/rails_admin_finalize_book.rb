require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
require 'csv'
 
module RailsAdminFinalizeBook
end
 
module RailsAdmin
  module Config
    module Actions
      class FinalizeBook < RailsAdmin::Config::Actions::Base
      	RailsAdmin::Config::Actions.register(self)
				register_instance_option :link_icon do
					'icon-check'
				end
				
				# Should the action be visible
        register_instance_option :visible? do
          true
        end

        register_instance_option :authorized? do
          true
        end

        # Is the action on a model scope (Example: /admin/team/export)
        register_instance_option :collection? do
          true
        end
        
        register_instance_option :action_name do
          custom_key.to_sym
        end

        # I18n key
        register_instance_option :i18n_key do
          key
        end

        # User should override only custom_key (action name and route fragment change, allows for duplicate actions)
        register_instance_option :custom_key do
          key
        end
        
        # This block is evaluated in the context of the controller when action is called
        # You can access:
        # - @objects if you're on a model scope
        # - @abstract_model & @model_config if you're on a model or object scope
        # - @object if you're on an object scope
        register_instance_option :controller do
					Proc.new do
            if request.method == "GET"
              render :action => @action.template_name
            else
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
              redirect_to "/cb_admin/book"
            end
					end
				end
				
				
				# List of methods allowed. Note that you are responsible for correctly handling them in :controller block
        register_instance_option :http_methods do
          [:get, :post]
        end
      	
      end
    end
  end
end