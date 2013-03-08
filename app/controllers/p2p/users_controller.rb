class P2p::UsersController < ApplicationController
  layout :p2p_layout
  before_filter :p2p_user_signed_in  ,:except => [:guesslocation ,:setlocation]

  #check for user presence inside p2p
  before_filter :check_p2p_user_presence ,:except => [:welcome,:user_first_time]

  def dashboard
    
    @total_items = p2p_current_user.items.count.to_f


    @sold_count = p2p_current_user.items.sold.count.to_f
    
    if @sold_count == 0 
      @sold_percentage = 0
    else
      @sold_percentage = ((@sold_count/@total_items) * 100 ).ceil
    end
    #@sold_count = 1 if p2p_current_user.items.sold.count == 0

    @waiting_count = p2p_current_user.items.waiting.count.to_f
    if @waiting_count == 0 
      @waiting_percentage = 0
    else
      @waiting_percentage = ((@waiting_count/@total_items) * 100 ).ceil
    end
    
    #@waiting_count = 1 if @waiting_count == 0

    @disapproved_count = p2p_current_user.items.disapproved.count.to_f
    if @disapproved_count == 0 
      @disapproved_percentage = 0
    else
      @disapproved_percentage = ((@disapproved_count/@total_items) *100 ).ceil
    end


    @approved_count = p2p_current_user.items.approved.count.to_f
    if @approved_count == 0 
      @approved_percentage = 0
    else
      @approved_percentage = ((@approved_count/@total_items) *100 ).ceil
    end    
#    @disapproved_count = 1 if @disapproved_count == 0

 #   @total_sold_count = 1 if p2p_current_user.items.count == 0

 @total_items = @total_items.to_i
  @sold_count = @sold_count.to_i
  @disapproved_count= @disapproved_count.to_i
  @approved_count = @approved_count.to_i
  @waiting_count =  @waiting_count.to_i
  
    
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

        admin =P2p::User.find_by_user_id(session[:admin_id])

        if p2p_current_user.nil?
          user = P2p::User.new
          user.user = current_user
          user.save

          admin.sent_messages.create({:receiver_id => p2p_current_user.id ,
                                              :message => "Hi #{p2p_current_user.user.name},  <br/> Welcome to Peer2Peer. This is an online platform for you to sell and buy products from other students in any college across india. Make most use of the site. Any queries, just compose a message and send it to me in message section. Thank you.. <br/> Sincerly, <br/> Admin - Sociorent",
                                              :messagetype => 6,
                                              :sender_id => admin.id,
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
        #geocode  = Geocoder.search(request[:REMOTE_ADDR])

        geocode  = Geocoder.search('106.51.99.160')

        session[:city] = (geocode.count > 0 ) ? geocode[0].data["city"] : ""

        puts geocode.inspect

        city_id = P2p::City.find_or_create_by_name(session[:city]).id

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
      msg = "Your Sociorent.com Order 1234 has been shipped through #{session[:verify]} with tracking number . Thank you."
      sendsms(p2p_current_user.user.mobile_number,msg)
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

  def paymenthistory

  end

  def favouriteusers
    @fav = p2p_current_user.favouriteusers
  end

  def setfavourite

    begin
      fav_id = P2p::Item.find(params[:itemid].to_i).user.id

      fav = p2p_current_user.favouriteusers.find_by_fav_id(fav_id)

      if fav.nil?
        flag = 1
        fav = p2p_current_user.favouriteusers.new
        fav.fav_id = fav_id
        fav.save
      else      
        flag = 0   
        fav.destroy
      end

      render :json => {:status => 1 ,:fav => flag }

    rescue Exception => ex
      render :json => {:status => 0}
    end

  end

  def paymentdetails
      if params.has_key?(:bought)
        @payments = p2p_current_user.payments.order('updated_at desc').paginate(:page => params[:page],:per_page => 10)
      else
        @payments = p2p_current_user.soldpayments.order('updated_at desc').paginate(:page => params[:page],:per_page => 10)
      end

  end
  
  # Vendor 
  def vendorsdetails
    @vendors=Array.new
    @users=P2p::User.all.paginate(:page => params[:page],:per_page => 10)
    @users.each do |user| 
     @vendors << [user.id,user.user.name,user.user.email,user.user_type]
    end   
  end

  def togglevendor
    params[:user].each_with_index do |(user_id,status),index|
      user = P2p::User.find(user_id.to_i)
      user.update_attributes(:user_type =>status.to_i)
    end
    redirect_to :action => "vendorsdetails"
  end
end
