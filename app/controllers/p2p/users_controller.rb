class P2p::UsersController < ApplicationController

  layout :p2p_layout 
  before_filter :p2p_user_signed_in 

  def dashboard
  	
  end

end
