require 'will_paginate/array'
class P2p::ItemsController < ApplicationController
  protect_from_forgery :except => :update_online_payment
  before_filter :p2p_user_signed_in ,:except => [:view]
  #check for user presence inside p2p
  before_filter :check_p2p_user_presence
  layout :p2p_layout
  def new
    @item = p2p_current_user.items.new
  end

  def create
    item = p2p_current_user.items.new({:title => params[:title], :desc => params[:desc], :price => params[:price] ,:condition => params[:condition]})
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
        item.product = item.category.products.find_by_name(params[:brand])
        raise "Product not found" if item.product.nil?
      rescue
        begin
          item.product = item.category.products.new(:name =>  (Publisher.find_by_name(params[:brand])).name )
          # P2p::User.find(session[:admin_id]).sent_messages.create({:receiver_id => 1 ,
          #                                       :message => "Auto Generated Message.<br/><h4>Fall back creation</h4>. The publisher #{product.name} was not found in your p2p and hence was taken from sociorent and created automatically for you, when the #{p2p_current_user.user.email} requested on listing a book and was created automatically. Sincerally - Developers",
          #                                       :messagetype => 5,
          #                                       :sender_id => 1,
          #                                       :sender_status => 2,
          #                                       :receiver_status => 0,
          #                                       :parent_id => 0,
          #                                       :item_id => item.id
          #                                      });
        rescue
          begin
            item.product = item.category.products.new(:name => params[:brand] )
            #item.category.products.new(:name => params[:brand] )
            # P2p::User.find(session[:admin_id]).sent_messages.create({:receiver_id => 1 ,
            #                                       :message => "Auto Generated Message.<br/><h4>Fall back creation</h4>. The publisher #{product.name} was not found in either p2p nor in sociorent, when the #{p2p_current_user.user.email} requested on listing a book and was created automatically.  <br/><h4>We request you to verify the same.</h4>Sincerally - Developers",
            #                                       :messagetype => 5,
            #                                       :sender_id => 1,
            #                                       :sender_status => 2,
            #                                       :receiver_status => 0,
            #                                       :parent_id => 0,
            #                                       :item_id => item.id
            #                                      });
          end
        end
      end
    end
    #todo add image validation in server side
    #   images = []
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
        next if value == ""
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
    if !params.has_key?(:paytype)
      @item = item
      render :sellitem_pricing
      return
    end
    if item.save
      redirect_to URI.encode("/p2p/#{item.product.category.name}/#{item.product.name}/#{item.title}")
      # redirect_to URI.encode('/p2p/itempayment/' + item.id.to_s)
    else
      flash[:notice] = "Failed "
      redirect_to URI.encode("/p2p/")
    end
  end

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
                                                :message => "Auto Generated Message.<br/><h4>Fall back creation</h4>. The city  #{params[:location]} was not found in your system and hence is created automatically for you, when the #{p2p_current_user.user.email} requested on listing a item We urge you to check the same. Sincerally - Developers",
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
    update_time = Time.now
    #echo params["item"]['attribute'].count
    #clear all
    #item.specs.clear
    ActiveRecord::Base.transaction do
      item.updated_at = update_time
      params[:spec].each do |key,value|
        begin
          attr = item.specs.find_by_spec_id(key.to_i)
          attr.updated_at = update_time
          attr.value = value
          attr.save
          if value == ""  || value == 'undefined'
            attr.destroy
            next
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
      item.approveddate = false
      if item.save
        flash[:notice] = "Saved changes"
        puts "in success"
      else
        puts "in fail"
        flash[:notice] = "Failed to save"
      end
    end
    redirect_to URI.encode("/p2p/#{item.product.category.name}/#{item.product.name}/#{item.title}")
  end

  def destroy
    begin
      item = P2p::Item.find(params[:id])
      raise "Cannot Delete" if item.user.id != current_user.id  and !session[:isadmin]
      item.deletedate = Time.now
      item.save
    rescue
      if request.xhr?
        render :json => {:status => 0}
        return
      else
        flash[:notice] ="Nothing found for your request"
        redirect_to "/p2p/mystore"
        return
      end
    end
    if request.xhr?
      render :json => {:status => 1}
      return
    else
      flash[:notice] ="Nothing found for your request"
      redirect_to "/p2p/mystore"
      return
    end
  end

  def edit
  end

  def get_attributes
    cat = P2p::Category.find(params[:id])
    @attr = cat.specs.select("id,name,display_type").all
    #  render :json => @attr
  end

  def get_spec
    items = P2p::Item.find(params[:id])
    spec = items.specs.select("id,value,spec_id")
    render :partial => "p2p/items/editspec" , :locals => {:spec => spec}
    #  render :json => @attr
  end

  def get_brands
    cat =P2p::Category.find(params[:id])
    brand  = cat.products.select("id as value,name as text")
    render :json => brand
  end

  def get_sub_categories
    cat = P2p::Category.select("id as value ,name as text")
    render :json => cat
  end

  def view
    begin
      #@item = P2p::Item.find(params[:id])
      @cat =  P2p::Category.find_by_name(params[:cat])
      @prod=  @cat.products.find_by_name(params[:prod])
      if !p2p_current_user.nil? and  session[:isadmin]
        @item = @prod.items.unscoped.find_by_title(params[:item])
      else
        @item = @prod.items.find_by_title(params[:item])
      end

      raise "Nothing found" if   @item.nil?
      if !p2p_current_user.nil? and @item.paytype.nil? and p2p_current_user.id == @item.user.id
        redirect_to "/p2p/itempayment/#{@item.id}"
        return
      end
      if (p2p_current_user.nil? and @item.approveddate.nil?) or @item.paytype.nil?
        raise "Nothing found paytype and not approved"
      end
    rescue
      redirect_to '/p2p'
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

    if !p2p_current_user.nil?
      if  p2p_current_user.id != @item.user_id
        @item.update_attributes(:viewcount => @item.viewcount.to_i + 1 )
      end
    else
      @item.update_attributes(:viewcount => @item.viewcount.to_i + 1 )
    end

    @brand_name = @item.product.name
    @brand_id = @item.product.id
    @attr = @item.specs(:includes => :attr)

    if !p2p_current_user.nil? and p2p_current_user.id == @item.user_id
      @messages = @item.messages.all
    elsif !p2p_current_user.nil?
      # intialize the request messages
      @message = @item.messages.new
      @buyerreqcount = @item.messages.find_all_by_sender_id(p2p_current_user.id).count
    end

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
          @user_id = p2p_current_user.id
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
    #render :json => {:status => 1 ,:id => "/p2p/#{@item.product.category.name}/#{@item.product.name}/#{@item.title}"}
    redirect_to URI.encode("/p2p/#{@item.product.category.name}/#{@item.product.name}/#{@item.title}")
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
      @user_id = p2p_current_user.id
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
      @user_id = p2p_current_user.id
    end
    render :approve
  end

  def approve
    if params.has_key?(:query)
      if params[:query] == 'disapprove'
        item = P2p::Item.notsold.find(params[:id])
        item.update_attributes(:disapproveddate => Time.now , :approveddate => nil)
        P2p::User.find(session[:admin_id]).sent_messages.create({:receiver_id => item.user.id ,
                                                :message => "This is an auto generated system message. Your item #{item.title} has been disapproved due to some reasons . Reply to this message to know the reason.  <br/> Thank you.. <br/> Sincerly, <br/> Admin - Sociorent",
                                                :messagetype => 5,
                                                :sender_id => session[:admin_id],
                                                :sender_status => 2,
                                                :receiver_status => 0,
                                                :parent_id => 0,
                                                :item_id => item.id
                                                });
        P2p::User.find(session[:admin_id]).sent_messages.create({:receiver_id => session[:admin_id],
                                                :message => "This is an auto generated system message. You have disapproved item no #{item.id} , #{item.title} and this listing will not appear on the site. A automated message is sent to the user.Your can see it here <a href='" + URI.encode("/p2p/#{item.category.name}/#{item.product.name}/#{item.title}") + "'> #{item.title} </a>. <br/> Thank you.. <br/> Sincerly, <br/> Developers ",
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
              window.location.href = '/p2p/#{item.category.name}/#{item.product.name}/#{item.title}';
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
                                                :message => "This is an auto generated system message. Your item is verified , approved  and  will appear on the site. You can see it here <a href='" + URI.encode("/p2p/#{item.category.name}/#{item.product.name}/#{item.title}") + "'> #{item.title} </a>. <br/> Thank you.. <br/> Sincerly, <br/> Admin - Sociorent",
                                                :messagetype => 5,
                                                :sender_id => session[:admin_id],
                                                :sender_status => 2,
                                                :receiver_status => 0,
                                                :parent_id => 0,
                                                :item_id => item.id
                                                });
        P2p::User.find(session[:admin_id]).sent_messages.create({:receiver_id => session[:admin_id] ,
                                                :message => "This is an auto generated system message. You have approved item no #{item.id} and this listing will appear on the site. You can see it here <a href='" + URI.encode("/p2p/#{item.category.name}/#{item.product.name}/#{item.title}") + "'> #{item.title} </a>. <br/> Thank you.. <br/> Sincerly, <br/> Developers ",
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
            window.location.href = '/p2p/#{item.category.name}/#{item.product.name}/#{item.title}';
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
        @user_id = p2p_current_user.id
      end
    end
  end

  def getbook_details
    book = Book.select('description,isbn13,isbn10,binding,publisher_id,published,pages,price,author').find_by_isbn13(params[:isbn13])
    if book.nil?
      render :json => {}
      return
    end
    publisher = book.publisher.name
    book = to_hash(book)
    book["publisher_id"] = publisher
    render :json => book
  end

  def sellitem_pricing
    if request.xhr?
      layout :false
    end
    if p2p_current_user.nil?
      flash[:notice] = "Nothing found for you request"
      redirect_to '/p2p'
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
      redirect_to URI.encode("/p2p/#{@item.category.name}/#{@item.product.name}/#{@item.title}")
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
      when "SUCCESS"
        flash[:warning] = "Transaction success"
        item_delivery.item.update_attributes(:solddate=>Time.now)
      end
      item_delivery.update_attributes(:citrus_pay_id=>params[:TxStatus],:citrus_reason=>params[:TxMsg],:citrus_ref_no=>params[:TxRefNo])
      redirect_to "/p2p/paymentdetails/bought"
    end
  end
end
