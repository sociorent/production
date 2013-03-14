class P2p::UsersController < ApplicationController
  layout :p2p_layout
  before_filter :p2p_user_signed_in  ,:except => [:guesslocation ,:setlocation]
  #check for user presence inside p2p
  before_filter :check_p2p_user_presence ,:except => [:welcome,:user_first_time]

  def dashboard
    #find the total items and convert them to the
    #% based on the totalitem count
    @total_items = p2p_current_user.items.count.to_f
    @sold_count = p2p_current_user.items.sold.count.to_f
    if @sold_count == 0
      @sold_percentage = 0
    else
      @sold_percentage = ((@sold_count/@total_items) * 100 ).ceil
    end
    @waiting_count = p2p_current_user.items.waiting.count.to_f
    if @waiting_count == 0
      @waiting_percentage = 0
    else
      @waiting_percentage = ((@waiting_count/@total_items) * 100 ).ceil
    end
    @disapproved_count = p2p_current_user.items.disapproved.count.to_f
    if @disapproved_count == 0
      @disapproved_percentage = 0
    else
      @disapproved_percentage = ((@disapproved_count/@total_items) *100 ).ceil
    end
    @approved_count = p2p_current_user.items.notsold.approved.count.to_f
    if @approved_count == 0
      @approved_percentage = 0
    else
      @approved_percentage = ((@approved_count/@total_items) *100 ).ceil
    end

    # convert the float values back to integer values
    @total_items = @total_items.to_i
    @sold_count = @sold_count.to_i
    @disapproved_count= @disapproved_count.to_i
    @approved_count = @approved_count.to_i
    @waiting_count =  @waiting_count.to_i
    @view_counts = p2p_current_user.items.notsold.select("title,viewcount").order("viewcount desc").limit(10)
    @count_items =[]
    @view_counts.each do |item|
      @count_items << "['#{item.title}',#{item.viewcount}]"
    end
  end

  def list
    #list the users for jquery autocomplete..
    #used in places like message compose..
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

  #action used for first time user entry into the system..
  def welcome
    # check if signed in , purpose fully removed the before filter
    # because it would create loop
    if current_user.nil?
      redirect_to '/p2p'
      flash[:notice] = 'Nothing could be found for your request'
      return
    end
    #get image
    unless session[:userid].nil?
      user=p2p_current_user
      redirect_to '/p2p'
      return
    end
  end

  #send the first time initializing messages..
  def user_first_time
    admin =P2p::User.find_by_user_id(session[:admin_id])
    if session[:userid].nil?
      user = P2p::User.new
      user.user = current_user
      user.save
      admin.sent_messages.create({:receiver_id => session[:userid] ,
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

  #guess the user location
  # temporarily not in use.. :)
  def guesslocation
    begin
      if !session.has_key?(:city) or session[:city] == ""
        #todo replace ip from request
        #get the location from gecoder using the ip
        geocode  = Geocoder.search(request[:REMOTE_ADDR])
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

  #used to set the locatin forcibly when user want to change it manually
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

  # Get code for verification of mobile
  def getcode
    session[:verify] = rand(10000..99999)
    msg = "Your Sociorent.com Order 1234 has been shipped through #{session[:verify]} with tracking number . Thank you."
    sendsms(p2p_current_user.user.mobile_number,msg)
    #todo sendsms
    render :json => {:status => 1}
  end

  #verify the code sent in mobile..
  def verifycode
    if session.has_key?(:verify) and params[:code] == session[:verify].to_s
      session.delete(:verify)
      user = P2p::User.find(session[:userid])
      puts user.inspect + 'user'
      user.update_attributes(:mobileverified => 1)
      puts user.inspect + 'user1'
      render :json => {:status => 1}
    else
      render :json => {:status => 0}
    end
  end

  #list all the favourite users  for the current user
  def favouriteusers
    @fav = p2p_current_user.favouriteusers
  end

  #toggle the favourite users for a user
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

  #list all the payment details of the user
  #if params has bought(:checkroutes :-) ) then display only bought payments
  #else display sold
  def paymentdetails
    if params.has_key?(:bought)
      @payments = p2p_current_user.payments.order('updated_at desc').paginate(:page => params[:page],:per_page => 10)
    else
      @payments = p2p_current_user.soldpayments.order('updated_at desc').paginate(:page => params[:page],:per_page => 10)
    end
  end

  def getusers


    
    response={:aaData => []}
    #where to start
    if params.has_key?("iDisplayStart")
      start = (params[:iDisplayStart].to_i / params[:iDisplayLength].to_i) + 1
    else
      start = 1
    end
    #order by the time by default
    order = "updated_at desc"

    #if sort is explicitly sennt from the client
    if params.has_key?(:iSortCol_0)
      case params[:iSortCol_0]
      when "4" #based on time column
        order = "updated_at " + params[:sSortDir_0]
      when "1" #based on sender column
        #check the table and sent the order by 
          order = "id " + params[:sSortDir_0]
        #based on item
      end
    end

    #find for which items is the request came for 
    # and get messages appropiatly
    if params[:query] == 'vendors'
      usertype = 1
    elsif params[:query] == 'users'
      usertype = 0
    end

    if params[:searchq]
      users = User.where("email like '%#{params[:searchq]}%'")
      users = users.pluck('id') 
      users << 0
      vendors = P2p::User.where("id in (#{users.join(',')}) and user_type = #{usertype}").paginate(:page => start,:per_page =>  params[:iDisplayLength] )
    else
      vendors = P2p::User.where("user_type = #{usertype}").paginate(:page => start,:per_page => params[:iDisplayLength] )
    end

    # form the response for the datatable
    response[:iTotalRecords] =  vendors.count
    response[:iTotalDisplayRecords] = vendors.count
    #form the time to be displayed
    vendors.each do |vendor|
      tme =Time.now - vendor.created_at
      if tme >= 86400
        tme =  (tme/86400).to_i.to_s + " days ago"
      elsif tme >=3600
        tme =  (tme/3600).to_i.to_s + " hr ago"
      else
        if (tme/60).to_i > 2
          tme = (tme/60).to_i.to_s + "min ago"
        else
          tme =  "about a min ago"
        end
      end

      response[:aaData].push({
                               "0" => "<input type='checkbox' class='vendor_check' userid='#{vendor.id}' >",
                               "1" => vendor.user.name,
                               "2" => vendor.user.email,
                               "3" => tme

      })
    end
    render :json => response
end

  # Vendor
  #toggle vendors based on the params
  #set set the vendor,
  #remove removes the vendor
  def vendorsdetails
    if params.has_key?(:cmd)
      if params[:cmd] == 'set'
        params[:userid].each do |user_id|
          user = P2p::User.find(user_id.to_i)
          user.update_attributes(:user_type => 1)
        end
      elsif params[:cmd] == 'remove'
        params[:userid].each do |user_id|
          user = P2p::User.find(user_id.to_i)
          user.update_attributes(:user_type => 0)
        end
      else
        redirect_to '/p2p/vendors' ,:notice => 'Nothing found for your request'
        return
      end

      if request.xhr?
        render :json => {:success => 1}
      end
    end


    #get vendors
    @vendors=P2p::User.where('user_type = 1').paginate(:page => params[:vendor_page],:per_page => 20 )
    @users=P2p::User.where('user_type = 0').paginate(:page => params[:user_page],:per_page => 20 )
  end

  def show_jobs
    
    if  params.has_key?(:job)

      case params[:job]
      
        when 'bulk'
          if params[:cmd] ='start'
            Kernel.spawn("bundle exec rails runner '#{Rails.root.join('lib/update_vendor_items.rb')}'")
          end
      end

      redirect_to '/p2p/admin/jobs'
      return
    end


    if File.exist?(Rails.root.join('log/update_bulk_vendor.lock'))
        @vendor_upload = "Vendor Bulk uploads is currently running"
        @icon_class = 'icon-spin'
         @run_bulk_upload =  false
      else
        @vendor_upload = "Bulk uploads is  currently not running"
        @icon_class = ''
        @run_bulk_upload = true
    end

  end

end
