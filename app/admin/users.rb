ActiveAdmin.register User do
  config.clear_action_items!
  index do
    selectable_column
  	column :name
    column :email
    column :mobile_number
    column "Profile Image", :image do |user|
      div do
        image_tag(user.image,:width=>100)
      end
    end
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
    column "Ambassador", :ambassador
    default_actions
  end
  
end
