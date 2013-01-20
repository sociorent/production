ActiveAdmin.register Ambassador do
  index do

    selectable_column
  	column "Ambassador", :ambassador do |amb|
  		amb.ambassador_manager.name
  	end

  	column "College", :amb_college do |amb|
  		Ambassador.find(amb).college.name
  	end

  	default_actions
  end
end
