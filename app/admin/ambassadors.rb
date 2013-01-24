##== Ambassador
# This ActiveAdmin contains the details of the ambassador
# that the colleges has.
# 

ActiveAdmin.register Ambassador do

  ## Index action
  # Displays all the ambassdors  of each and every college
  index do

    ## Column 1
    # This is a column with check box which enables admin to perform 
    # batch actions in the dashboard
    selectable_column

    ## Column 2
    # This is a column which displays names of the ambassadors
  	column "Ambassador", :ambassador do |amb|
  		amb.ambassador_manager.name
  	end

    ## Column 3
    # This is a column which displays the column name 
    # and   ##TODO##
    column :colleges do |amb|
      html=""
      amb.colleges.each do |col|
        html+="#{col.name}"
        html+="<br>"
      end
      raw html
    end

    ##Column 5
    #This column displays the common actions
    # like view, edit, delete
  	default_actions

  end

  ## Form for new, edit Ambassador
  # This is the format of the active admin to create a form
  # which would be used for new and edit actions
  #
  # Has Nested form to add teh college the ambassador belongs to
  form do |f|

    f.inputs "Ambassador" do
      f.input :ambassador_manager

      f.inputs "Colleges" do 
        f.input :colleges , :collection => College.all
      end

      f.buttons
    end

  end

  ##== Show Action
  # This is the show action which display a single ambassador and his/her details
  # displays the name and the college he belongs to.
  show do |ambassador|
    attributes_table do
      row :ambassador_manager
      row :colleges do |amb|
        html=""
        amb.colleges.each do |col|
          html+= "#{col.name}<br>"
        end
        raw html
      end
    end
  end
end
