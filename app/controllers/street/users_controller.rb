class Street::UsersController < ApplicationController
  layout :p2p_layout
  before_filter :p2p_user_signed_in  ,:except => [:guesslocation ,:setlocation]
  #check for user presence inside p2p
  before_filter :check_p2p_user_presence ,:except => [:welcome,:user_first_time,:setlocation]

  def dashboard
    #find the total items and convert them to the
    #% based on the totalitem count
    if session[:isadmin]
      items = P2p::Item
    else
      items = p2p_current_user.items
    end

    @total_items = items.count.to_f
    @sold_count = items.sold.count.to_f
    if @sold_count == 0
      @sold_percentage = 0
    else
      @sold_percentage = ((@sold_count/@total_items) * 100 ).ceil
    end
    @waiting_count = items.waiting.count.to_f
    if @waiting_count == 0
      @waiting_percentage = 0
    else
      @waiting_percentage = ((@waiting_count/@total_items) * 100 ).ceil
    end
    @disapproved_count = items.disapproved.count.to_f
    if @disapproved_count == 0
      @disapproved_percentage = 0
    else
      @disapproved_percentage = ((@disapproved_count/@total_items) *100 ).ceil
    end
    @approved_count = items.notsold.approved.count.to_f
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
    @view_counts = []
    # for displaying chart for admin & vendors
    if session[:isadmin] || session[:user_type] == 1
      @categories = []
      @cate_counts = []
      categories = P2p::Category.includes(:items).all
      categories.each do |cate|
        # for vendor getting items
        if session[:user_type] == 1 && session[:isadmin].nil?
          count_hash=cate.items.where("user_id=?",p2p_current_user.id).group("viewcount").count
        else
          count_hash=cate.items.group("viewcount").count
        end
        total_count = 0
        count_hash.each_with_index do |(cnt_val,count),index|
          puts "Total Count =(#{total_count})+(#{cnt_val} * #{count})"
          total_count += (cnt_val * count)
        end
        @cate_counts << "['#{cate.name}',#{total_count}]"
        @categories << "'#{cate.name}'"
      end
    end

    @view_counts = items.notsold.order("viewcount desc").limit(10)
    @count_items =[]
    @item_names = []
    @count_ticks = []
    @view_counts.each do |item|
      #@count_items << "['#{item.title}_#{item.id}',#{item.viewcount}]"
      @count_items << "#{item.viewcount}"
      @count_ticks << "'#{item.title}'"
      @item_names << "#{make_item_url(item)}"
    end
  end

  def list
    #list the users for jquery autocomplete..
    #used in places like message compose..
    params[:q] = params[:user_id] if params.has_key?(:user_id)
    users = User.where("email like '%#{params[:q]}%'")
    resp = []
    users.each do |usr|
      begin
      p2pusr = P2p::User.find_by_user_id(usr.id)
      resp.push(:value => p2pusr.id , :label => "#{usr.name}(#{usr.email})" )
      rescue
        next
      end
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
      redirect_to '/street'
      flash[:notice] = 'Nothing could be found for your request'
      return
    end

    user_first_time
  end

  #send the first time initializing messages..
  def user_first_time
    admin = P2p::User.find_by_user_id(session[:admin_id])
    if p2p_current_user.nil?
      user = P2p::User.new
      user.user = current_user
      user.save

      p2p_current_user

      begin
      admin.sent_messages.create({:receiver_id => session[:userid] ,
                                  :message => "Welcome to Sociorent Street, your own marketplace. Your ID is #{p2p_current_user.id.rjust(2,'0')} and you may now login to buy / sell awesome items. Thanks.",
                                  :messagetype => 6,
                                  :sender_id => admin.id,
                                  :sender_status => 2,
                                  :receiver_status => 0,
                                  :parent_id => 0
                                  });


      rescue
      end

      redirect_to '/street'
      return
    end
    redirect_to '/street'
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
    begin
      city = P2p::City.find_by_name(params[:location])
      session[:city] = city.name.titleize
      session[:city_id] = city.id.to_s
      cookies.permanent[:city] = session[:city]

      user = p2p_current_user
      if user
        user.city = city
        user.save
      end

      render :json => {:status => 1}
    rescue
      session.delete(:city)
      session.delete(:city_id)

      render :json => {:status => 2}
    end
    return
  end

  # Get code for verification of mobile
  def getcode

    user_mobile = P2p::User.find_by_mobile_number(params[:mobile])

    if (!user_mobile.nil? and user_mobile.id != session[:userid])
      render :json => {:status => 10}
      return
    end

    session[:verify] = rand(100000..999999)
    mobile_number = params[:mobile]
    msg = "Please enter the six digit mobile verification code #{session[:verify]} to confirm the listing. Thanks - Sociorent.com"
    user = P2p::User.find(session[:userid])
    user.update_attributes(:mobile_number=>mobile_number)
    puts session[:verify]
    #TODO :: check the send sms function whether it pinging mvooyoo correctly.or not
    send_sms(mobile_number,msg)
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

  def updateaddress
    begin

      p2p_current_user.update_attributes(:address => params[:address].to_json)
      render :json => {:status => 1}
    rescue
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

      if params[:itemid]
        fav_id = P2p::Item.find(params[:itemid].to_i).user.id
      else
        fav_id = P2p::User.find(params[:id].to_i)
      end

      fav = p2p_current_user.favouriteusers.find_by_fav_id(fav_id)
      if fav.nil?
        flag = 1
        fav = p2p_current_user.favouriteusers.create(:fav_id => fav_id)
      else
        flag = 0
        fav.destroy
      end

      render :json => {:status => 1 ,:fav => flag ,:count => p2p_current_user.favouriteusers.count}
      return
    rescue Exception => ex
      render :json => {:status => 0}
      # render :text => ex.message
    end
  end

  #list all the payment details of the user
  #if params has bought(:checkroutes :-) ) then display only bought payments
  #else display sold

  def paymentdetails
    if request.xhr?

      paymenttable
      return

    end

    if params.has_key?(:bought)
      @payments = p2p_current_user.payments.order('updated_at desc').paginate(:page => params[:page],:per_page => 10)
    else
      @payments = p2p_current_user.soldpayments.order('updated_at desc').paginate(:page => params[:page],:per_page => 10)
    end
  end


  def paymenttable

    response={:aaData => []}
    #where to start
    if params.has_key?("iDisplayStart")
      start = (params[:iDisplayStart].to_i / 10) + 1
    else
      start = 1
    end
    #order by the time by default
    order = "created_at desc"
    search = ""
    item = 0
    #if sort is explicitly sennt from the client
    if params.has_key?(:iSortCol_0)
      case params[:iSortCol_0]
        #based on item
      when "1"
        order = "p2p_status " + params[:sSortDir_0]
      end
    end
    #if the client has request for search
    if params.has_key?(:searchq) and params[:searchq].strip !=""
      search = params[:searchq]

      where = ""


      if search.index('@') == 0
        begin
          user = P2p::User.where( "user_id in (select id from users where email like '%#{search.slice(1,(search.size-1))}%')").pluck('id')
        rescue
          user = 0
        end
      end


      if search.index('#') == 0

        case search.slice(1,(search.size-1))
          when 'shipped'
              where += 'shipping_date is not null'
          when 'delivered'
              where += 'delivery_date is not null'
          when 'success'
              where += 'p2p_status =2 '
          when 'fail'
              where += 'p2p_status = 0'
          when 'cancelled'
              where += 'p2p_status = 4'
        end

      end

      begin
        item = P2p::Item.where( "title like '%#{search}%'").pluck('id')
      rescue
        item = 0
      end
    end
    #find for which items is the request came for
    # and get messages appropiatly



    if user!=0 and !user.nil? and user.count > 0

      where += ' and ' if where!=""

      where += " buyer in (#{user.join(',')})"
    elsif item!=0 and !item.nil? and item.count > 0

      where=" and " if where!=""

      where += " p2p_item_id in (#{item.join(',')})"
    end

    if params.has_key?(:searchq) and params[:searchq].strip !=""
      if where == ""
        render :json => response
        return
      end
    end

    if params.has_key?(:bought)
        @payments = p2p_current_user.payments.where(where).order('updated_at desc').paginate(:page => start,:per_page => params[:iDisplayLength])
    else
        @payments = p2p_current_user.soldpayments.where(where).order('updated_at desc').paginate(:page => start,:per_page => params[:iDisplayLength])
    end


    # form the response for the datatable
    response[:iTotalRecords] =  @payments.count
    response[:iTotalDisplayRecords] = @payments.count
    #form the time to be displayed
    if params.has_key?(:bought)
      @payments.each do |pay|

        if pay.shipping_date.nil?
          action = ""
        else
          action ="<a class='aslink' href='/street/admin/item_deliveries/#{pay.id}/edit'><i class='icon-edit'></i> Update Delivery date</a>".html_safe
        end

        response[:aaData].push({
                                 "0" =>  pay.statustext,
                                 "1" => "<a class='aslink' href='#{make_item_url(pay.item)}'>#{pay.item.title}</a>",
                                 "2" => (pay.courier_name == "" or pay.courier_name.nil? ) ? "-NA-" : pay.courier_name,
                                 "3" => (pay.tracking_no =="" or pay.tracking_no.nil?) ? "-NA-" : pay.tracking_no,
                                 "4" => (pay.shipping_date.nil?) ? "-NA-" : pay.shipping_date.strftime("%d-%b-%C%y") ,
                                 "5" => (pay.delivery_date.nil?) ? "-NA-" : pay.delivery_date.strftime("%d-%b-%C%y"),
                                 "6" =>  pay.item.price,
                                 "7" =>  action

        })
      end
    else


      @payments.each do |pay|

        downloadlinks =""

        if pay.delivery_date.nil?
          downloadlinks +="<a class='aslink' href='/street/admin/item_deliveries/#{pay.id}/edit'><i class='icon-edit'></i>Update Shipping Date</a><br/>"
        end

        unless pay.shipping_date.nil?
          downloadlinks += " <a class='aslink' href='/street/paymentdetails/invoice/#{pay.id}'>Invoice </a> <br/><a class='aslink' href='/street/paymentdetails/label/#{pay.id}'>Label </a>"
        end

        response[:aaData].push({
                                 "0" =>  pay.statustext,
                                 "1" => "<a class='aslink' href='#{make_item_url(pay.item)}'>#{pay.item.title}</a>",
                                 "2" => (pay.courier_name == "" or pay.courier_name.nil? ) ? "-NA-" : pay.courier_name,
                                 "3" => (pay.tracking_no =="" or pay.tracking_no.nil?) ? "-NA-" : pay.tracking_no,
                                 "4" => (pay.shipping_date.nil?) ? "-NA-" : pay.shipping_date.strftime("%d-%b-%C%y") ,
                                 "5" => (pay.delivery_date.nil?) ? "-NA-" : pay.delivery_date.strftime("%d-%b-%C%y"),
                                 "6" =>  "#{pay.commission}%"  ,
                                 "7" => "Rs. #{pay.shipping_charge}",
                                 "8" =>  "Rs. #{(pay.item.price - ((pay.item.price *  (pay.commission/100) ) + pay.shipping_charge.to_f).ceil).to_i}",
                                 "9" => downloadlinks

        })
      end
    end

    render :json => response
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
      tme =Time.now - vendor.updated_at
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
      admin = P2p::User.find_by_user_id(session[:admin_id])
      if params[:cmd] == 'set'
        params[:userid].each do |user_id|
          user = P2p::User.find(user_id.to_i)
          user.update_attributes(:user_type => 1)

          admin.sent_messages.create({:receiver_id => user.id ,
                            :message => "This is an auto generated message. You have been promoted as a vendor and hence you can start to bulk upload items from now on. Go to your dashboard to find the 'Bulk Upload' link <br/>-Thank you<br/> Sociorent ",
                            :messagetype => 6,
                            :sender_id => admin.id,
                            :sender_status => 2,
                            :receiver_status => 0,
                            :parent_id => 0
                            });

        end
      elsif params[:cmd] == 'remove'
        params[:userid].each do |user_id|
          user = P2p::User.find(user_id.to_i)
          user.update_attributes(:user_type => 0)

          admin.sent_messages.create({:receiver_id => session[:admin_id] ,
                            :message => "This is an auto generated message. You have been de-promoted from vendor by admin. <br/>-Thank you<br/> Sociorent ",
                            :messagetype => 6,
                            :sender_id => admin.id,
                            :sender_status => 2,
                            :receiver_status => 0,
                            :parent_id => 0
                            });


        end
      else
        redirect_to '/street/vendors' ,:notice => 'Nothing found for your request'
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
          if params[:cmd] == 'start'
            Kernel.spawn("RAILS_ENV=#{Rails.env} bundle exec rails runner '#{Rails.root.join('lib/update_vendor_items.rb')}'")
            puts "RAILS_ENV=#{Rails.env} bundle exec rails runner '#{Rails.root.join('lib/update_vendor_items.rb')}'"

          end
      end
      redirect_to '/street/admin/jobs'
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


  def cms
    @page = StaticPage.new
  end



  def failed_uploads

      #todo : find only for current user

    @failed = P2p::FailedCsv.select('category_id,created_at,count(*) as cnt').group('created_at desc')

  end

  def download_failed
    if params[:type] == 'csv'
      @failed = P2p::FailedCsv.select('category_id,csv_data').where("created_at = '#{params[:dte]}'")


      if @failed.count == 0
        redirect_to '/street/faileduploads'
        return
      end

      cat = P2p::Category.find(@failed[0].category_id)
      require 'csv'
      item = ['Brand','Title','Price','Quantity','Condition','Location','Description','Send By','All over India','Image Url','Image Url','Image Url']
      if cat.name =="Books"
        item[0] = 'Book Category'
      end


      item = item + cat.specs.pluck('name')
      csv_string = CSV.generate do |csv|
        csv << item
        @failed.each do |fail|
          csv  << CSV.parse_line(fail.csv_data)
        end
      end

      send_data(csv_string ,:filename => "Failed #{cat.name} Items.csv")
      return

    elsif params[:type] == 'reason'
      @failed = P2p::FailedCsv.select('category_id,reason').where("created_at = '#{params[:dte]}'")

      cat = P2p::Category.find(@failed[0].category_id)

      if @failed.count == 0
        redirect_to '/street/faileduploads'
        return
      end

      require 'csv'
      csv_string = CSV.generate do |csv|
        csv << CSV.parse_line('Find Reasons below. You can match the reasons row by row to the failed item in the Item CSV file')
        @failed.each do |fail|
          csv << CSV.parse_line(fail.reason)
        end
      end

      send_data(csv_string ,:filename => "Failed #{cat.name} Reasons.csv")
      return

    else
      redirect_to '/street/faileduploads'
      return
    end
  end

  def profile
    begin
        # load address of the current user
      @address = JSON.parse(p2p_current_user.address)
      @address_present = true
    rescue
     @address= {"address_street_1" => "","address_street_2" => "", "address_city" => "","address_state" => "","address_pincode" => "" }
     @address_present = false
    end



    if p2p_current_user.mobileverified
      @mobile =p2p_current_user.mobile_number
      @mobile_preset = true
    else
      @mobile = ''
      @mobile_preset = false
    end




  end



  def staticpages

  end

end