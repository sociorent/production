require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module RailsAdminGetBookDetails
end
 
module RailsAdmin
  module Config
    module Actions
      class GetBookDetails < RailsAdmin::Config::Actions::Base
      	RailsAdmin::Config::Actions.register(self)
      
#       	register_instance_option :member? do
# 					true
# 				end
				
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
              isbns = params[:isbn].split(",")
              isbns.each do |isbn|
                if isbn.to_i.is_a? (Integer)
                  book_details = BookFinder.flipkart(isbn)
                  puts book_details
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
                  BookApi.create(book)
                end
              end
              flash[:notice]="Books Retrieved"
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