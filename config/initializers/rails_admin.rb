require Rails.root.join('lib','rails_admin_rented.rb')
require Rails.root.join('lib','rails_admin_search_index.rb')

RailsAdmin.config do |config|

  config.current_user_method { current_user } # auto-generated

  config.main_app_name = ['Sociorent', 'Admin']

	config.authorize_with do
		redirect_to "/home/index" unless current_user.is_admin?
	end

	config.excluded_models = ["BookCart", "BookOrder", "CompanyUser"]

	config.actions do
		# root actions
    dashboard
    # collection actions 
    index
    new do
			visible do
				["General", "Ambassador"].exclude?bindings[:abstract_model].model.to_s
			end
		end
    export
    rented do
      visible do
        bindings[:abstract_model].model.to_s == "Book"
      end
    end
    search_index do
      visible do
        bindings[:abstract_model].model.to_s == "Book"
      end
    end
    bulk_delete
    # member actions
    show
    edit
    delete
    show_in_app
	end

  config.model User do
    edit do
      field :email 
      field :password
      field :name
      field :is_admin
      field :ambassador_manager do
        label "Ambassador"
      end
    end
    create do
      field :email 
      field :password
      field :name
      field :is_admin
      field :ambassador_manager do
        label "Ambassador"
      end
    end
    show do
      include_all_fields
      field :ambassador do
        label "Referrer"
      end
      field :ambassador_manager do
        label "Ambassador"
      end
    end
  end

  config.model Counter do
    edit do
      field :email 
      field :password
      field :name
      field :college
    end
    create do
      field :email 
      field :password
      field :name
      field :college
    end
    show do
      include_all_fields
    end
  end
end