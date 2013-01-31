require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module RailsAdminShipping
end
 
module RailsAdmin
  module Config
    module Actions
      class Shipping < RailsAdmin::Config::Actions::Base
      	RailsAdmin::Config::Actions.register(self)
      
      	register_instance_option :member? do
					true
				end
				
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
        # register_instance_option :collection? do
        #   true
        # end
        
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
              @book_orders = @object.book_orders.where(:shipped => false)
            	render :action => @action.template_name
            else
              book_order_ids = JSON.parse params[:book_orders]
              book_order_ids.each do |book_order_id|
                book_order = BookOrder.find(book_order_id.to_i)
                if book_order
                  book_order.update_attributes(:shipped => true, :tracking_number => params[:tracking_number], :courier_name => params[:courier_name])
                end
              end
              if book_order_ids.count > 0

                msg = "Your Sociorent.com Order #{@object.random} has been shipped through #{params[:courier_name]} with tracking number #{params[:tracking_number]} . Thank you."
                send_sms(@object.user.mobile_number ,msg)
                puts msg
              end
            	render :nothing => true
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