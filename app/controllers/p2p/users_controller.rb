class P2p::UsersController < ApplicationController

  layout :p2p_layout 
  before_filter :p2p_user_signed_in 

  #check for user presence inside p2p
  before_filter :check_p2p_user_presence ,:except => [:welcome,:user_first_time]

  def dashboard
  	
  end

  def list
    users = User.where("email like '%#{params[:q]}%'")
    resp = []

    users.each do |usr|
      p2pusr = P2p::User.find_by_user_id(usr.id)
      resp.push(:value => p2pusr.id , :label => "#{usr.name}(#{usr.email})" )
    end

    render :json => resp

  end

  def welcome

  			# check if signed in , purpose fully removed the before filter 
  			# because it would create loop

  			if current_user.nil? 
  				redirect_to '/p2p'
          flash[:notice] = 'Nothing could be found for your request'
  				return
  			end

  			#get image
        unless p2p_current_user.nil?
  	      user=p2p_current_user
          redirect_to '/p2p'
          return
        end

  end

  def user_first_time


        if p2p_current_user.nil?
          user = P2p::User.new
          user.user = current_user
          user.save

          P2p::User.find(1).sent_messages.create({:receiver_id => p2p_current_user.id ,
                                              :message => "Hi #{p2p_current_user.user.name},  <br/> Welcome to Peer2Peer. This is an online platform for you to sell and buy products from other students in any college across india. Make most use of the site. Any queries, just compose a message and send it to me in message section. Thank you.. <br/> Sincerly, <br/> Admin - Sociorent",
                                              :messagetype => 6,
                                              :sender_id => 1,
                                              :sender_status => 2,
                                              :receiver_status => 0,
                                              :parent_id => 0
                                              });

          redirect_to '/p2p'
          return
        end

        redirect_to '/p2p'
  end

end
