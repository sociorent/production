class ApplicationController < ActionController::Base
 # before_filter :add_www_subdomain

 # Helper method for all views
 helper_method  :p2p_current_user


 # if Rails.env.production?
	#  rescue_from Exception, with: :render_404
	#  rescue_from ActionController::RoutingError, with: :render_404
	#  rescue_from ActionController::UnknownController, with: :render_404

	#  rescue_from AbstractController::ActionNotFound, with: :render_404 # To prevent Rails 3.2.8 deprecation warnings
	#  rescue_from ActiveRecord::RecordNotFound, with: :render_404
 # end

  protect_from_forgery
  def send_sms(receipient,msg)
	 user_pwd="Sathish@sociorent.com:Sathish1"
	 sender_id="SOCRNT"
	 url= "http://api.mVaayoo.com/mvaayooapi/MessageCompose?user=#{user_pwd}&senderID=#{sender_id}&receipientno=#{receipient}&dcs=0&msgtxt=#{msg}&state=4"
	 agent =Mechanize.new
	 page = agent.get(url)
	 resp=page.body.split(",")
	 puts page.body
	 puts resp
	 if resp[0]=="Status=1"
		return false
	 elsif resp[0] == "Status=0"
		return true
	 end
  end

  def render_404(exception = nil)
	  flash[:warning]="Page not found"
	  redirect_to "/"
  end


  ##P2P layout
  # this selects the layout for the p2p namespace
  def p2p_layout
	 if request.xhr? 
		return false;
	 else

		return 'p2p_layout'
		#return 'application'
	 end
  end


  ##return p2pUser 
  def p2p_current_user
  	if current_user.nil?
  		return nil
  	else
  		return P2p::User.find_by_user_id(current_user.id)
  	end

  end



  ##P2p Authentication
  def p2p_user_signed_in

  
	 if current_user.nil?
		redirect_to '/p2p'
		return false
	 end
  end

  def check_p2p_user_presence
	# check for ucrrent user and ignore the user presnce if the user is not logged in
	if current_user.nil?
		return true 
	end	

	if P2p::User.find_by_user_id(current_user.id).nil?
	  redirect_to '/p2p/welcome'  
	  return false
	end

  end

  def to_hash(obj)
     hash = {}; obj.attributes.each { |k,v| hash[k.to_sym] = v }
	 return hash
  end




  ###########################

  private
	  def add_www_subdomain
		 unless /^www/.match(request.host)
			redirect_to "http://www.sociorent.com"
		 end
	  end
	  def authenticate_admin!
		 authenticate_user! 
		 unless current_user.is_admin?
			flash[:alert] = "Unauthorized Access!"
			redirect_to root_path 
		 end
	  end  



end