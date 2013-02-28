class P2p::UsersController < ApplicationController

  layout :p2p_layout 
  before_filter :p2p_user_signed_in  ,:except => [:guesslocation ,:setlocation]

  #check for user presence inside p2p
  before_filter :check_p2p_user_presence ,:except => [:welcome,:user_first_time]

  def dashboard  	
  end

  def dashboard_use
  end

  def list
    params[:q] = params[:user_id] if params.has_key?(:user_id)
    users = User.where("email like '%#{params[:q]}%'")
    resp = []

    users.each do |usr|
      p2pusr = P2p::User.find_by_user_id(usr.id)
        resp.push(:value => p2pusr.id , :label => "#{usr.name}(#{usr.email})" )
    end

    if resp.count ==0 
        resp.push(:value => -1 , :label => "Nothing Found" )
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

  def guesslocation

    begin

      if !session.has_key?(:city) or session[:city] == ""
        #todo replace ip from request
        geocode  = Geocoder.search(request[:REMOTE_ADDR])
        session[:city] = (geocode.count > 0 ) ? geocode[0].data["city"] : ""

        puts geocode.inspect 
        
        city_id = P2p::City.find_by_name(session[:city])
        session[:city_id] = (city_id.nil? ) ? '' : city_id;

        raise 'Location not found' if session[:city] == ""
        render :json => {:status => 1 , :location => session[:city]}
      else
        render :json => {:status => 3 , :location => session[:city]}
      end

    rescue
        render :json => {:status => 2}
    end


  end

  def setlocation

      if params[:location] == session[:city_id]
        render :json => {:status => 3}
        return
      end

    begin
      city = P2p::City.find(params[:location])

      session[:city] = city.name.titleize
      session[:city_id] = city.id.to_s

      render :json => {:status => 1}
    rescue
      render :json => {:status => 2}
    end
    return
  end

  def getcode

      session[:verify] = rand(10000..99999)

      #todo sendsms
      render :json => {:status => 1}
  end

  def verifycode
      if session.has_key?(:verify) and params[:code] == session[:verify].to_s
        
        session.delete(:verify)

        user = P2p::User.find(p2p_current_user.id)
        puts user.inspect + 'user'
        user.update_attributes(:mobileverified => 1)
        puts user.inspect + 'user1'

        render :json => {:status => 1}
      else
        render :json => {:status => 0}
      end
  end

end
