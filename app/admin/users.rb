##== User
# This ActiveAdmin contains the details of the user
# and provides the management functions on those things
# 
ActiveAdmin.register User do

  config.clear_action_items!

  ##Index Action
  #This action displays the user details on the dashboard
  index do
    selectable_column
  	column :name
    column :email
    column :mobile_number
    # column :address do |user|
    #   begin
    #     addr=JSON.parse user.address
    #     addr.each do |k,v|
    #       span do
    #         raw "#{v}<br>"
    #       end
    #     end
    #   rescue
    #    user.address
    #   end
    # end
    column "College", :college
    column "Stream",:stream
    column "Ambassador" do |user|
      if user.ambassador
        "#{user.ambassador.ambassador_manager.name}"
      else
        " - "
      end
    end
    default_actions
  end
  
end
