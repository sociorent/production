class ApplicationController < ActionController::Base
 # before_filter :add_www_subdomain

 # Helper method for all views
 helper_method  :p2p_current_user ,:p2p_get_user_location


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




  def guess_user_location
  	begin
  	    if !session.has_key?(:city) or session[:city] == ""
	        #todo replace ip from request
	        #geocode  = Geocoder.search(request[:REMOTE_ADDR])

	        geocode  = Geocoder.search(request.env['REMOTE_ADDR'])

	        puts session.inspect

	        session[:city] = (geocode.count > 0 ) ? geocode[0].data["city"] : ""

	        puts geocode.inspect

	        city_id = P2p::City.find_or_create_by_name(session[:city]).id

	        session[:city_id] = (city_id.nil? ) ? '' : city_id;
      	end
    rescue Exception => ex
    end
  end


  ##P2P layout
  # this selects the layout for the p2p namespace
  def p2p_layout

	 if request.xhr? 
		return false;
	 else
		guess_user_location
		return 'p2p_layout'
		#return 'application'
	 end
  end


  ##return p2pUser 
  def p2p_current_user

  	begin
		session[:isadmin] = false

		socio_admin = User.find_by_is_admin(1)
		session[:admin_id] = (P2p::User.find_by_user_id(socio_admin.id)).id

	  	if current_user.nil?
	  		return nil
	  		session[:userid] = nil
	  	else
	  		user = P2p::User.find_by_user_id(current_user.id)

	  		session[:user_type] = user.user_type
	  		session[:userid] = user.id

	  		if user.user.is_admin 
	  			session[:isadmin] = true
	  		end



	  		return user
	  	end

	  rescue
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

	guess_user_location

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

  def p2p_get_user_location

  	if session.has_key?(:city_id) and session[:city_id] != ""
  		return session[:city_id]
  	else
  		return ''
  	end
  end

  def p2p_is_admin
  	if !session[:isadmin]
  		redirect_to '/p2p'
  		return false
  	end
  	return true
  end

  def after_sign_in_path_for(resource)
  	
  	unless request.xhr?
  		return request.env["HTTP_REFERER"] 
  	end
  	super
  end

  def after_sign_out_path_for(resource)
  	unless request.xhr?
  		return request.env["HTTP_REFERER"] 	

  	end
  	super
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