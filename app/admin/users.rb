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
    column "College", :college_id do |college|
    	div do 
    		College.find(college).name rescue ""
    	end
    end
    column "Stream",:stream_id do |stream|
    	div do 
    		Stream.find(stream).name rescue ""
    	end
    end
    column "Ambassador", :ambassador_id do |amb|
    	div do
    		User.find(amb).name
    	end
    end
    default_actions
  end
  
end
