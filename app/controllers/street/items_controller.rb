require 'will_paginate/array'
class Street::ItemsController < ApplicationController
  protect_from_forgery :except => :update_online_payment
  before_filter :p2p_user_signed_in ,:except => [:view]
  #check for user presence inside p2p
  before_filter :check_p2p_user_presence
  layout :p2p_layout

  def new
    if p2p_current_user.mobileverified == false
      flash[:warning] = "You should verify your mobile number before listing"
      redirect_to "/street#verify_mobile" and return
    end
    @item = p2p_current_user.items.new
  end

  #creates the item..
  #the trick here is first time we dn save the item..
  #we simulate the save process
  #this is to diplay the payment options for the user
  #when the user submits from the payment options,
  #we save it then :)
  def create
    puts "Price #{params[:price]}"
    item = p2p_current_user.items.new({:title => params[:title].strip, :desc => params[:desc], :price => params[:price] ,:condition => params[:condition]})
    # render :json => item
    item.category = P2p::Category.find(params[:cat].to_i)
    begin
      item.city = P2p::City.find_by_name(params[:location])
      if item.city.nil?
        raise 'nothing found'
      end
    rescue
      begin
        item.city = P2p::City.new(:name => params[:location])
        #todo add send message to admin
      rescue
      end
    end
    #item.product = P2p::Product.find(1)
    #if the publisher is not in us..!
    begin
      item.product = item.category.products.find(params[:brand].to_i)
      raise "Product not found" if item.product.nil?
    rescue
      begin
        item.product = item.category.products.find_by_name(params[:brand].gsub(/-/," "))
        raise "Product not found" if item.product.nil?
      rescue
        begin
          item.product = item.category.products.new(:name =>  (Publisher.find_by_name(params[:brand].gsub(/-/," "))).name )
        rescue
          begin
            item.product = item.category.products.new(:name => params[:brand].gsub(/-/," ") )
          end
        end
      end
    end

    #if paytype is not found , then the save was not triggered in payment and hence
    #dn save the item.. so skip all these process
    if params.has_key?(:paytype)
      if params[:img].respond_to?('each')
        params[:img].each do |img|
          item.images << P2p::Image.new(:img=>img)
        end
      else
        item.images.new(:img => params[:img])
      end
      unless params['spec'].respond_to?('each')
        params['spec'] = [params['spec']]
      end
      params["spec"].each do |key,value|
        next if value.length == 0 or value == "null" or value =='undefined'
        begin
          attr = P2p::ItemSpec.new
          attr.spec = P2p::Spec.find(key.to_i)
          attr.value = value
          item.specs << attr
        rescue
        end
      end

      # set payment type
      if params[:paytype] == "1" #courier
        item.paytype = 1
        item.payinfo =  params[:dispatch_day] + "," + ( (params[:alloverindia].nil?) ? "" : params[:alloverindia] )
      elsif params[:paytype] == "2" #direct
        item.paytype = 1
        item.payinfo = params[:meet_at]
      elsif params[:paytype] == "3" #via sociorent
        item.paytype = 3
        item.payinfo = params[:payinfo]
      end
    end

    #as i said if paytype is not defined
    if !params.has_key?(:paytype)
      @item = item
      render :sellitem_pricing
      return
    end

    #save the item now..
    if item.save
      redirect_to URI.encode("/street/#{item.category.name.gsub(/ /,"-")}/#{item.product.name.gsub(/ /,"-")}/#{(item.title).gsub(/ /,"-")}/#{item.id}")
      # redirect_to URI.encode('/street/itempayment/' + item.id.to_s)
    else
      flash[:notice] = "Failed"
      redirect_to URI.encode("/street/")
    end
  end

  #update the item
  def update
    item = p2p_current_user.items.find(params[:id])
    item.update_attributes({:title => params[:title], :desc => params[:desc], :price => params[:price] ,:condition => params[:condition]});
    item.product = P2p::Product.find(params[:brand])
    begin
      item.city = P2p::City.find_by_name(params[:location])
      raise 'nothing found' if item.city.nil?
    rescue
      begin
        city = P2p::City.create(:name => params[:location])
        city.save
        item.city = city
        P2p::User.find(session[:admin_id]).sent_messages.create({:receiver_id => session[:admin_id],
                                                                 :message => "Auto Generated Message.<br/><h4>Fall back creation</h4>. The city  #{params[:location]} was not found in your system and hence is created automatically for you, when the #{p2p_current_user.user.email} requested on listing a item We urge you to check the same.",
                                                                 :messagetype => 5,
                                                                 :sender_id => session[:admin_id],
                                                                 :sender_status => 2,
                                                                 :receiver_status => 0,
                                                                 :parent_id => 0,
                                                                 :item_id => item.id
                                                                 });
      rescue
      end
    end
    #set the item.. this is used to set the time with seconds
    #same for all the edit..
    update_time = Time.now

    ActiveRecord::Base.transaction do
      item.updated_at = update_time
      params[:spec].each do |key,value|
        begin

          attr = item.specs.find_by_spec_id(key.to_i)
          # skip if same value
          next if attr.value == value
          attr.updated_at = update_time

          if value.strip.length == 0  or value == 'undefined'
            attr.delete
            next
          else
            attr.value = value
            attr.save
          end

        rescue
          attr = item.specs.new
          attr.spec = item.category.specs.find(key.to_i)
          attr.updated_at = update_time
          attr.value = value
        end
      end

      data={}
      if params[:img].respond_to?('each')
        params[:img].each do |img|
          item.images << P2p::Image.new(:img=>img)
        end
      elsif params.has_key?(:img)
        item.images.new(:img => params[:img])
        puts "images in single"
      end
      item.images.each do |img|
        puts img.errors.full_messages
      end
      item.approveddate = nil
      if item.save
        flash[:notice] = "Saved changes"
      else
        flash[:notice] = "Failed to save"
      end
    end
    redirect_to URI.encode("/street/#{item.product.category.name.gsub(/ /,"-")}/#{item.product.name.gsub(/ /,"-")}/#{(item.title).gsub(/ /, "-")}/#{item.id}")
  end


  def destroy
    begin
      item = P2p::Item.find(params[:id])
      raise "Cannot Delete" if item.user.id != session[:userid]  and !session[:isadmin]
      item.deletedate = Time.now
      item.save
    rescue
      if request.xhr?
        render :json => {:status => 0}
        return
      else
        flash[:notice] ="Nothing found for your request"
        redirect_to "/street/mystore"
        return
      end
    end
    if request.xhr?
      render :json => {:status => 1}
      return
    else
      flash[:notice] ="Nothing found for your request"
      redirect_to "/street/mystore"
      return
    end
  end

  def edit
  end

  def get_spec
    items = P2p::Item.find(params[:id])
    spec = items.specs.select("id,value,spec_id")
    render :partial => "street/items/editspec" , :locals => {:spec => spec}
    #  render :json => @attr
  end
  def get_sub_categories
    cat = P2p::Category.select("id as value ,name as text")
    render :json => cat
  end
  def view
    begin
      #@item = P2p::Item.find(params[:id])
      @cat =  P2p::Category.find_by_name(params[:cat].gsub(/-/," "))
      @prod=  @cat.products.find_by_name(params[:prod].gsub(/-/," "))

      if !session[:userid].nil? and  session[:isadmin]
        @item = @prod.items.unscoped.find(params[:id])
      else
        @item = @prod.items.find(params[:id])
      end

      raise "Nothing found" if   @item.nil? 

      if session[:userid]

        if session[:userid] != @item.user.id and !@item.solddate.nil?

          unless @item.item_deliveries.paysucess.pluck('buyer').include?(session[:userid])
            redirect_to "/street/"
            return
          end
        end
      elsif (@item.approveddate.nil? or !@item.solddate.nil? )
        raise 'Nothing found..!'
      end

  
    rescue
      redirect_to '/street'
      return
    end

    if @item.product.category.category.nil?
      @category_name = @item.product.category.name
      @category_id = @item.product.category.id
      @sub_category_name = ""
      @sub_category_id =""
    else
      @sub_category_name = @item.product.category.name
      @sub_category_id = @item.product.category.id
      @category_name = @item.product.category.category.name
      @category_id = @item.product.category.category.id
    end

    if !session[:userid].nil?
      if  session[:userid] != @item.user_id and !session[:isadmin]
        @item.update_attributes(:viewcount => @item.viewcount.to_i + 1 )
      end
    else
      @item.update_attributes(:viewcount => @item.viewcount.to_i + 1 )
    end

    @brand_name = @item.product.name
    @brand_id = @item.product.id
    @attr = @item.specs(:includes => :attr)

    if !session[:userid].nil? and session[:userid] == @item.user_id
      @messages = @item.messages.all
    elsif !session[:userid].nil?
      # intialize the request messages
      @message = @item.messages.new
      @buyerreqcount = @item.messages.find_all_by_sender_id(session[:userid]).count
    end

    @fullimage = @item.get_image(0,:view)
    @thumbimage = @item.get_image(0,:thumb)
    @viewimage = @item.get_image(0,:view)
    # decide the paycontne and title for popover
    @item_message_url = "/street/messages/#{@item.title}"
    @payurl = "/street/itempayment/#{@item.id}"

    if @item.paytype == 1
      @paytype_content = "You have selected to send this item via courier in #{@item.payinfo.split(',')[0]} business days <br/> Click on the button to change it."
      @paytype_title = "Send by Courier"
    elsif @item.paytype == 2
      @paytype_content = "You have selected to deal with the buyer directly <br/> Click on the button to change it."
      @paytype_title = "Pay Directly"
    elsif @item.paytype == 3
      @paytype_content = "You have selected sociorent to pickup and safely deliver the item. <br/> Click on the button to change it"
      @paytype_title = "Send by Sociorent"
    end

    #random image
    @rand_image = rand(0..(@item.get_image(0,:thumb).count-1))

    # load address of the current user
    @address = JSON.parse(current_user.address) rescue ""

    @address = {"address_street_1" => "",
    "address_street_2" => "",
    "address_city" => "",
    "address_state" => "",
    "address_pincode" => "" } if @address == ''

  end
  def inventory
    user = p2p_current_user
    if params[:query].present?
      if params[:query] == "sold"
        if session[:isadmin]
          if params.has_key?(:id)
            @items = P2p::User.find(params[:id]).items.sold.paginate(:page => params[:page] , :per_page => 20)
            @user = P2p::User.find(params[:id])
            @user_id = @user.id
            @user = @user.user.name + "(" +  @user.user.email  + ")"
          else
            @items = P2p::Item.sold.paginate(:page => params[:page] , :per_page => 20)
            @user = "All users"
            @user_id = ""
          end
        else
          @items = p2p_current_user.items.sold.paginate(:page => params[:page] , :per_page => 20)
          @user = p2p_current_user.user.name + "(" +  p2p_current_user.user.email  + ")"
          @user_id = session[:userid]
        end
        render :approve
        return
      end
    else
      @items = user.items.all.paginate(:page => params[:page] ,:per_page => 20 ,:class=> 'bootstrap pagination' )
    end
  end
  def sold
    @item = P2p::Item.find(params[:id])
    @item.solddate =Time.now
    @item.save
    redirect_to URI.encode("/street/#{@item.product.category.name.gsub(/ /,"-")}/#{@item.product.name.gsub(/ /,"-")}/#{(@item.title).gsub(/ /, "-")}/#{@item.id}")
  end
  def add_image
    if params[:item_id] != ""
      item = P2p::Item.find(params[:item_id])
      unless params[:img].nil?
        if params[:img].respond_to?('each')
          params[:img].each do |img|
            i = item.images.new(:img=>img)
            i.save
          end
        else
          i = item.images.new(:img => params[:img])
          i.save
        end
        render :json => {
          :name  =>  "picture1.jpg",
          :size =>  902604,
          :url =>  "http:\/\/example.org\/files\/picture1.jpg",
          :thumbnail_url => "http:\/\/example.org\/files\/thumbnail\/picture1.jpg",
          :delete_url => "http:\/\/example.org\/files\/picture1.jpg",
          :delete_type => "DELETE"
        }
        return
      end
      session[:img] = []
      params[:img].each do |img|
        i = P2p::Image.new(:img=>img)
        session[:img].push(i.id)
        i.save
      end
      render :text => session[:img].inspect
    end
    #render :inline => params.inspect
  end
  def waiting
    if session[:isadmin]
      if params.has_key?(:id)
        @user = P2p::User.find(params[:id])
        puts 'in user'
        @items = @user.items.waiting.paginate(:page => params[:page] , :per_page => 20)
        puts @items.inspect + "asd"
        @user_id = @user.id
        @user = @user.user.name + "(" +  @user.user.email  + ")"
      else
        @items = P2p::Item.waiting.paginate(:page => params[:page] , :per_page => 20)
        @user_id = ""
        @user = "All users"
      end
    else
      @items = p2p_current_user.items.waiting.paginate(:page => params[:page] , :per_page => 20)
      @user = p2p_current_user.user.name + "(" +  p2p_current_user.user.email  + ")"
      @user_id = session[:userid]
    end
    render :approve
  end
  def disapprove
    if session[:isadmin]
      if params.has_key?(:id)
        @items = P2p::User.find(params[:id]).items.disapproved.paginate(:page => params[:page] , :per_page => 20)
        @user = P2p::User.find(params[:id])
        @user_id = @user.id
        @user = @user.user.name + "(" +  @user.user.email  + ")"
      else
        @items = P2p::Item.disapproved.paginate(:page => params[:page] , :per_page => 20)
        @user = "All users"
        @user_id = ""
      end
    else
      @items = p2p_current_user.items.disapproved.paginate(:page => params[:page] , :per_page => 20)
      @user = p2p_current_user.user.name + "(" +  p2p_current_user.user.email  + ")"
      @user_id = session[:userid]
    end
    render :approve
  end
  def approve
    if params.has_key?(:query)
      if params[:query] == 'disapprove'
        item = P2p::Item.notsold.find(params[:id])
        item.update_attributes(:disapproveddate => Time.now , :approveddate => nil, :disapproved_reason=>params[:disapprove].to_s)
        P2p::User.find(session[:admin_id]).sent_messages.create({:receiver_id => item.user.id ,
                                                                 :message => "Your listing for the item #{item.title} has been disapproved for the following reason.<br>#{item.disapproved_reason}<br>You may edit the appropriate content and re-submit the listing for review. <br><br>This is a system generated message and you need not reply.<br><br>Thank you.<br>Sincerly,<br>Sociorent Street",
                                                                 :messagetype => 5,
                                                                 :sender_id => session[:admin_id],
                                                                 :sender_status => 2,
                                                                 :receiver_status => 0,
                                                                 :parent_id => 0,
                                                                 :item_id => item.id
                                                                 });
        P2p::User.find(session[:admin_id]).sent_messages.create({:receiver_id => session[:admin_id],
                                                                 :message => "This is an auto generated system message. You have disapproved item no #{item.id} , #{item.title} and this listing will not appear on the site. A automated message is sent to the user.You can see it here <a href='" + URI.encode("/street/#{item.category.name.gsub(/ /,"-")}/#{item.product.name.gsub(/ /,"-")}/#{(item.title).gsub(/ /, "-")}}/#{item.id}") + "'> #{item.title} </a>. <br/> Thank you.. <br/> Sincerly, <br/> Developers ",
                                                                 :messagetype => 5,
                                                                 :sender_id => session[:admin_id],
                                                                 :sender_status => 1,
                                                                 :receiver_status => 0,
                                                                 :parent_id => 0,
                                                                 :item_id => item.id
                                                                 });
        @message_notification = "
$('#notificationcontainer').notify('create', {
title: 'Disapproval of Listing',
text: 'Your item #{item.title} has been disapproved by admin. Please check messages and reply to correct the issue'
},{
expires:false,
click:function(){
window.location.href = '/street/#{item.category.name.gsub(/ /,"-")}/#{item.product.name.gsub(/ /,"-")}/#{(item.title).gsub(/ /, "-")}/#{item.id}';
}
});
if (oInboxTable){
oInboxTable.fnDraw();
}
if (oSentBoxTable){
oSentBoxTable.fnDraw();
}
if (oDeleteBoxTable){
oDeleteBoxTable.fnDraw();
}
"
        PrivatePub.publish_to("/user_#{item.user_id}", @message_notification )
        render :json => '1'
        return
      elsif params[:query] == 'approve'
        item = P2p::Item.notsold.find(params[:id])
        item.update_attributes(:approveddate => Time.now ,:disapproveddate => nil)
        P2p::User.find(session[:admin_id]).sent_messages.create({:receiver_id => item.user.id ,
                                                                 :message => "Congratulations, Your item <b>#{item.title}</b> has been approved and it is now live. <br>
<br>
This is a system generated message and you need not reply to this.
<br><br>
Thank you.
<br>
Sincerly,<br>
Sociorent Street Team.",
                                                                 :messagetype => 5,
                                                                 :sender_id => session[:admin_id],
                                                                 :sender_status => 2,
                                                                 :receiver_status => 0,
                                                                 :parent_id => 0,
                                                                 :item_id => item.id
                                                                 });
        P2p::User.find(session[:admin_id]).sent_messages.create({:receiver_id => session[:admin_id] ,
                                                                 :message => "This is an auto generated system message. You have approved item no #{item.id} and this listing will appear on the site. You can see it here <a href='" + URI.encode("/street/#{item.category.name.gsub(/ /,"-")}/#{item.product.name.gsub(/ /,"-")}/#{(item.title).gsub(/ /, "-")}}/#{item.id}") + "'> #{item.title} </a>. <br/> Thank you.. <br/> Sincerly, <br/> Developers ",
                                                                 :messagetype => 5,
                                                                 :sender_id => session[:admin_id],
                                                                 :sender_status => 1,
                                                                 :receiver_status => 0,
                                                                 :parent_id => 0,
                                                                 :item_id => item.id
                                                                 });
        #session[:verifycode] = rand(0..100000)
        begin
          send_sms(item.user.user.mobile_number,"Thanks for signing-up with Sociorent.com. Your ID is #{item.title.truncate(110)} . You may now login to place your order. Thank you.")
        rescue
          P2p::User.find(session[:admin_id]).sent_messages.create({:receiver_id => session[:admin_id],
                                                                   :message => "This is an auto generated system message. A approval message cant be sent to #{item.user.user.mobile_number } (#{item.user.user.email},  #{item.user.user.name} ).<br/> Thank you.. <br/> Sincerly, <br/> Developers ",
                                                                   :messagetype => 5,
                                                                   :sender_id => session[:admin_id],
                                                                   :sender_status => 1,
                                                                   :receiver_status => 0,
                                                                   :parent_id => 0,
                                                                   :item_id => item.id
                                                                   });
        end
        # private pub
        unreadcount = item.user.received_messages.inbox.unread.count
        if unreadcount > 0
          header_count = "$('#header_msg_count').html('(#{unreadcount})');"
        else
          header_count = "$('#header_msg_count').html('');"
        end
        if unreadcount > 0
          message_page_count = " $('#unread_count').html('(#{unreadcount})');"
        else
          message_page_count = " $('#unread_count').html('');"
        end
        @message_notification = "
$('#notificationcontainer').notify('create', {
title: 'Approval of Listing',
text: 'Your item #{item.title} has been approved by admin and will be listed on the site.'
},{
expires:false,
click:function(){
window.location.href = '/street/#{item.category.name.gsub(/ /,"-")}/#{item.product.name.gsub(/ /,"-")}/#{(item.title).gsub(/ /, "-")}/#{item.id}';
}
});
if (oInboxTable){
oInboxTable.fnDraw();
}
if (oSentBoxTable){
oSentBoxTable.fnDraw();
}
if (oDeleteBoxTable){
oDeleteBoxTable.fnDraw();
}
"
        PrivatePub.publish_to("/user_#{item.user_id}", header_count + message_page_count  + @message_notification)
        render :json => '1'
        return
      end
      render :json => '0'
      return
    else
      if session[:isadmin]
        if params.has_key?(:id)
          @items = P2p::User.find(params[:id]).items.approved.notsold.paginate(:page => params[:page] , :per_page => 20)
          @user = P2p::User.find(params[:id])
          @user_id = @user.id
          @user = @user.user.name + "(" +  @user.user.email  + ")"
        else
          @items = P2p::Item.approved.notsold.paginate(:page => params[:page] , :per_page => 20)
          @user = "All users"
          @user_id = ""
        end
      else
        @items = p2p_current_user.items.approved.notsold.paginate(:page => params[:page] , :per_page => 20)
        @user = p2p_current_user.user.name + "(" +  p2p_current_user.user.email  + ")"
        @user_id = session[:userid]
      end
    end
  end
  def getbook_details

    book = Book.select('description as desc_content,isbn13 as \'ISBN-13\',isbn10 as \'ISBN-10\',binding as \'Binding\',publisher_id as \'Publisher\',published as \'Published Year\',pages as \'Page Count\',price,author as \'Author\'').find_by_isbn13(params[:isbn13])
    if book.nil?
      render :json => {}
      return
    end
    publisher = book.publisher.name
    book = to_hash(book)
    book["Publisher"] = publisher
    render :json => book
  end
  def sellitem_pricing
    if request.xhr?
      layout :false
    end
    if session[:userid].nil?
      flash[:notice] = "Nothing found for you request"
      redirect_to '/street'
      return
    end
    #@item = P2p::Item.first
    @item = p2p_current_user.items.unscoped.notdeleted.notsold.find(params[:id])
    puts @item.inspect
    if params.has_key?(:commit) and params.has_key?(:terms) and params[:terms] == "1"
      new_item =  ( @item.paytype.nil? ) ?  true : false
      if params[:p2p_item][:paytype] == "1" #courier
        @item.paytype = params[:p2p_item][:paytype]
        @item.payinfo =  params[:dispatch_day] + "," + ( (params[:alloverindia].nil?) ? "" : params[:alloverindia] )
      elsif params[:p2p_item][:paytype] == "2" #direct
        @item.paytype = params[:p2p_item][:paytype]
        @item.payinfo = params[:meet_at]
      elsif params[:p2p_item][:paytype] == "3" #via sociorent
        @item.paytype = params[:p2p_item][:paytype]
        @item.payinfo = params[:p2p_item][:payinfo]
      end
      @item.save
      flash[:notice] = "Changes Saved"
      if new_item
        @item.new_item_created
      else
      end
      redirect_to URI.encode("/street/#{@item.category.name.gsub(/ /,"-")}/#{@item.product.name.gsub(/-/," ")}/#{(@item.title).gsub(/ /, "-")}/#{@item.id}")
      return
    elsif params.has_key?(:terms) and params[:terms] !='1'
      flash.now[:notice] = 'Agree to the terms and conditions.'
    elsif params.has_key?(:commit) and !params.has_key?(:terms)
      flash.now[:notice] = 'Agree to the terms and conditions.'
    end
    #@item = p2p_current_user.items.unscoped.notfinished.find(params[:id])
  end
  def update_online_payment
    # check the transaction status, if cancelled then store nothing,, and redirect to books page
    if params[:TxStatus]
      item_delivery = P2p::ItemDelivery.find_by_txn_id(params[:TxId])
      case params[:TxStatus]
      when "CANCELED"
        flash[:warning]="Transaction Failed. Try again"
        status = 4

        P2p::User.find(session[:admin_id]).sent_messages.create({:receiver_id => item_delivery.buyer.id ,
                                                                 :message => "This is an auto generated system message. You attempted to buy <a href='/street/#{item_delivery.item.category.name.gsub(/ /,"-")}/#{item_delivery.item.product.name.gsub(/-/," ")}/#{(item_delivery.item.title).gsub(/ /, "-")}/#{item_delivery.item.id}'> #{item_delivery.item.title} </a>, but didn proceed there after.<br/> Thank you <br/> Admin- Sociorent",
                                                                 :messagetype => 7,
                                                                 :sender_id => session[:admin_id],
                                                                 :sender_status => 1,
                                                                 :receiver_status => 0,
                                                                 :parent_id => 0,
                                                                 :item_id => item.id
                                                                 });


      when "SUCCESS"
        flash[:warning] = "Transaction success"
        item_delivery.item.update_attributes(:solddate=>Time.now)
        status = 2

        P2p::User.find(session[:admin_id]).sent_messages.create({:receiver_id => item_delivery.buyer.id ,
                                                                 :message => "This is an auto generated system message. You had bought <a href='/street/#{item_delivery.item.category.name.gsub(/ /,"-")}/#{item_delivery.item.product.name.gsub(/-/," ")}/#{(item_delivery.item.title).gsub(/ /, "-")}/#{item_delivery.item.id}'> #{item_delivery.item.title} </a>, but didn proceed there after.<br/> Thank you <br/> Admin- Sociorent",
                                                                 :messagetype => 8,
                                                                 :sender_id => session[:admin_id],
                                                                 :sender_status => 1,
                                                                 :receiver_status => 0,
                                                                 :parent_id => 0,
                                                                 :item_id => item.id
                                                                 });
        msg =""

        if item_delivery.item.paytype == 1 #courier
          msg = "Please ship the product to the buyer"
        elsif item_delivery.item.paytype == 3 #onlie
          msg = "We will contact you to collect the product."
        end

        P2p::User.find(session[:admin_id]).sent_messages.create({:receiver_id => item_delivery.item.user.id ,
                                                                 :message => "This is an auto generated system message. #{item_delivery.buyer.name} has bought your listing <a href='/street/#{@item.category.name.gsub(/ /,"-")}/#{@item.product.name.gsub(/-/," ")}/#{(@item.title).gsub(/ /, "-")}/#{@item.id}'> #{item_delivery.item.title} </a>. #{msg} <br/> Thank you <br/> Admin- Sociorent",
                                                                 :messagetype => 8,
                                                                 :sender_id => session[:admin_id],
                                                                 :sender_status => 1,
                                                                 :receiver_status => 0,
                                                                 :parent_id => 0,
                                                                 :item_id => item.id
                                                                 });

      end
      item_delivery.update_attributes(:citrus_pay_id=>params[:TxStatus],:citrus_reason=>params[:TxMsg],:citrus_ref_no=>params[:TxRefNo] ,:p2p_status => status)
      redirect_to "/street/paymentdetails/bought"
    end
  end
  def upload_csv
    redirect_to "/street/dashboard" and return if p2p_current_user.user_type != 1
    puts p2p_current_user.inspect
    vendor_upload = p2p_current_user.vendor_uploads.create(:upload_csv => params[:csvfile],:category_id=>params[:category])
    flash[:warning] =" Your bulk upload was successful" if vendor_upload
    redirect_to "/street/dashboard"
  end
  def downloadtemplate
    if params.has_key?(:category_template)
      cat = P2p::Category.find(params[:category_template])
      require 'csv'
      item = ['Brand','Title','Price','Condition','Location','Description','Send By','All over India','Image Url','Image Url','Image Url']
      if cat.name =="Books"
        item[0] = 'Book Category'
      end
      item = item + cat.specs.pluck('name')
      csv_string = CSV.generate do |csv|
        csv << item
      end
      send_data(csv_string ,:filename => cat.name + ".csv")
      return
    else
      @cat = P2p::Category.all
      @not_processed = p2p_current_user.vendor_uploads.where(:processed=>false)
    end
  end
end
