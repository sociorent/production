require 'koala'

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    resp = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)
    resp_hash = JSON.parse(resp)

    @user = User.find(resp_hash["user"])
    new_user = resp_hash["new_user"]

    if @user.persisted?
      # get fb token and save it
      token = request.env["omniauth.auth"].credentials.token
      @user.update_attributes(:token => token)
      # initialize koala graph api and get uid of all friends
      @graph  = Koala::Facebook::API.new(token)
      friends = @graph.fql_query("SELECT uid FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me())")
      # save all friends
      @user.update_attributes(:friends => friends.to_json())

      sign_in @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?

      if cookies.has_key?(:return_url)
        redirect_to cookies[:return_url]
        return
      end

      if request.env['omniauth.origin']
        redirect_to request.env['omniauth.origin']
        return
      end

      if new_user
        redirect_to "/welcome"
      else
        redirect_to "/"
      end
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
    # Or alternatively,
    # raise ActionController::RoutingError.new('Not Found')
  end
end