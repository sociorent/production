class ApplicationController < ActionController::Base
 # before_filter :add_www_subdomain

 if Rails.env.production?
    rescue_from Exception, with: :render_404
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionController::UnknownController, with: :render_404

    rescue_from AbstractController::ActionNotFound, with: :render_404 # To prevent Rails 3.2.8 deprecation warnings
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
 end

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

  ##P2P layout
  # this selects the layout for the p2p namespace
  def p2p_layout
    if request.xhr? 
      return false;
    else
      return 'p2p_layout1'
      #return 'p2p_layout'
      #return 'application'
    end
  end

  ##P2p Authentication
  def p2p_user_signed_in
    if !(user_signed_in?)
      redirect_to '/p2p'
    end
  end

  def to_hash(obj)
    hash = {}; obj.attributes.each { |k,v| hash[k] = v }
    return hash
  end
end