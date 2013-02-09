class ApplicationController < ActionController::Base
 # before_filter :add_www_subdomain
  rescue_from Exception, with: :render_404
  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from ActionController::UnknownController, with: :render_404

  rescue_from AbstractController::ActionNotFound, with: :render_404 # To prevent Rails 3.2.8 deprecation warnings
  rescue_from ActiveRecord::RecordNotFound, with: :render_404

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

  
end
