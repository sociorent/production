class P2p::ImagesController < ApplicationController

	before_filter :p2p_user_signed_in 
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
