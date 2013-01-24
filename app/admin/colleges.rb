
##== College Dashboard
# This Activeadmin contains the management activites to 
# manage colleges
ActiveAdmin.register College do
  index do
  	column :id
  	column :name
  	default_actions
  end
end
