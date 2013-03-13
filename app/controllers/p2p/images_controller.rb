class P2p::ImagesController < ApplicationController

	before_filter :p2p_user_signed_in 

   #check for user presence inside p2p
   before_filter :check_p2p_user_presence

	layout :p2p_layout
	
	def destroy
		begin
			img = P2p::Image.find(params[:id])
		rescue
			render :json => {:status => "0"}
			return
		end
		
		img.img = nil
		img.destroy

		render :json => {:status => "1"}

	end
end
