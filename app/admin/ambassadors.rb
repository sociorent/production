ActiveAdmin.register Ambassador do
  index do

    selectable_column
  	column "Ambassador", :ambassador do |amb|
  		amb.ambassador_manager.name
  	end
    column :colleges do |amb|
      html=""
      amb.colleges.each do |col|
        html+="#{col.name}"
        html+="<br>"
      end
      raw html
    end

  	default_actions
  end
end
