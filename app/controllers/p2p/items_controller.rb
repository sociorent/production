require 'will_paginate/array'

class P2p::ItemsController < ApplicationController

  before_filter :p2p_user_signed_in ,:except => [:view]

   #check for user presence inside p2p
   before_filter :check_p2p_user_presence

  layout :p2p_layout

  def new
   @item = p2p_current_user.items.new

  end


  def create


    item = p2p_current_user.items.new({:title => params["title"], :desc => params["desc"], :price => params["price"] ,:condition => params["condition"]})

    #item.product = P2p::Product.find(1)
    item.product = P2p::Product.find(params["brand"])

    #echo params["item"]['attribute'].count

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

     data={}
    if item.save 

      data['status'] = 1;
      data['id'] = URI.encode("#{item.product.category.name}/#{item.product.name}/#{item.title}")
    else
      data['status'] = 0;
      data['msg'] = "Fails";
    end

    render :json => data

  end

 def update


    item = p2p_current_user.items.find(params[:id])

    item.update_attributes({:title => params["title"], :desc => params["desc"], :price => params["price"] ,:condition => params[:condition]});

    item.product = P2p::Product.find(params["brand"])

    #echo params["item"]['attribute'].count
    #clear all
    item.specs.clear

     params["spec"].each do |key,value|
        next if value == "" 
        
       attr = P2p::ItemSpec.new
       attr.spec = P2p::Spec.find(key.to_i)
       attr.value = value
       item.specs << attr
     end

     data={}
    if item.save 
      data['status'] = 1;
      data['id'] = URI.encode("#{item.product.category.name}/#{item.product.name}/#{item.title}")
    else
      data['status'] = 0;
      data['msg'] = "Fails";
    end

    render :json => data

end

  def destroy

    begin
      item = P2p::Item.find(params[:id])

      raise "Cannot Delete" if item.user.id != current_user.id 
    rescue
      if request.xhr? 
        render :json => {:status => 0}
      else
        flash[:notice] ="Nothing found for your request"
        redirect_to "/p2p/mystore"
        return
      end
    end
    

    item.deletedate = Time.now
    item.save

    if request.xhr? 
      render :json => {:status => 1}
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

        if !p2p_current_user.nil? and  p2p_current_user.id == 1 
          @item = @prod.items.unscoped.find_by_title(params[:item])
        else
          @item = @prod.items.find_by_title(params[:item])
        end

        puts @item.inspect + "asf"

        if p2p_current_user.nil? and @item.approveddate.nil?
            raise "Nothing found" 
        end

        raise "Nothing found" if   @item.nil? 
        
      rescue

        flash[:notice] ="Nothing found for your request"
        redirect_to '/p2p/mystore'
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
        if p2p_current_user.id == 1 
          @items = P2p::Item.sold.paginate(:page => params[:page] , :per_page => 20)
        else
          @items = user.items.sold.paginate(:page => params[:page] , :per_page => 20)
        end
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


    item = P2p::Item.find(params["item_id"])
    unless params["img"].nil?


      params["img"].each do |img|

        i = item.images.new(:img=>img)

        i.save

      end

    end
    #render :inline => params.inspect

    redirect_to URI.encode("/p2p/#{item.product.category.name}/#{item.product.name}/#{item.title}")

  end

  def waiting

        if p2p_current_user.id != 1
      
          @items = p2p_current_user.items.waiting.paginate(:page => params[:page] , :per_page => 20)
        else
          @items = P2p::Item.waiting.paginate(:page => params[:page] , :per_page => 20)
        end

    render :approve

  end


  def disapprove

        if p2p_current_user.id != 1
      
          @items = p2p_current_user.items.disapproved.paginate(:page => params[:page] , :per_page => 20)
        else
          @items = P2p::Item.disapproved.paginate(:page => params[:page] , :per_page => 20)
        end

          

    render :approve

  end

  def approve

    if params.has_key?(:query)

      if params[:query] == 'disapprove'
        item = P2p::Item.notsold.find(params[:id])
        item.update_attributes(:disapproveddate => Time.now , :approveddate => nil)

        P2p::User.find(1).sent_messages.create({:receiver_id => item.user.id ,
                                              :message => "This is an auto generated system message. Your item #{item.title} has been disapproved due to some reasons . Reply to this message to know the reason.  <br/> Thank you.. <br/> Sincerly, <br/> Admin - Sociorent",
                                              :messagetype => 5,
                                              :sender_id => 1,
                                              :sender_status => 2,
                                              :receiver_status => 0,
                                              :parent_id => 0,
                                              :item_id => item.id

                                                  });

        P2p::User.find(1).sent_messages.create({:receiver_id => 1 ,
                                              :message => "This is an auto generated system message. You have disapproved item no #{item.id} , #{item.title} and this listing will not appear on the site. A automated message is sent to the user.Your can see it here <a href='" + URI.encode("/p2p/#{item.category.name}/#{item.product.name}/#{item.title}") + "'> #{item.title} </a>. <br/> Thank you.. <br/> Sincerly, <br/> Developers ",
                                              :messagetype => 5,
                                              :sender_id => 1,
                                              :sender_status => 1,
                                              :receiver_status => 0,
                                              :parent_id => 0,
                                              :item_id => item.id

                                                  });


     @message_notification = "
         $('#notificationcontainer').notify('create', {
              title: 'Disapproval of Listing',
              text: 'Your item #{item.title} has been disapproved by admin. Please check messages and reply to correct the issue'
          });
      "


       PrivatePub.publish_to("/user_#{item.user_id}", @message_notification )


        render :json => '1'
        return

      elsif params[:query] == 'approve'
        item = P2p::Item.notsold.find(params[:id])
        item.update_attributes(:approveddate => Time.now ,:disapproveddate => nil)

        P2p::User.find(1).sent_messages.create({:receiver_id => item.user.id ,
                                              :message => "This is an auto generated system message. Your item is verified , approved  and  will appear on the site. You can see it here <a href='" + URI.encode("/p2p/#{item.category.name}/#{item.product.name}/#{item.title}") + "'> #{item.title} </a>. <br/> Thank you.. <br/> Sincerly, <br/> Admin - Sociorent",
                                              :messagetype => 5,
                                              :sender_id => 1,
                                              :sender_status => 2,
                                              :receiver_status => 0,
                                              :parent_id => 0,
                                              :item_id => item.id

                                                  });

        P2p::User.find(1).sent_messages.create({:receiver_id => 1 ,
                                              :message => "This is an auto generated system message. You have approved item no #{item.id} and this listing will appear on the site. You can see it here <a href='" + URI.encode("/p2p/#{item.category.name}/#{item.product.name}/#{item.title}") + "'> #{item.title} </a>. <br/> Thank you.. <br/> Sincerly, <br/> Developers ",
                                              :messagetype => 5,
                                              :sender_id => 1,
                                              :sender_status => 1,
                                              :receiver_status => 0,
                                              :parent_id => 0,
                                              :item_id => item.id

                                                  });

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
          });"


          PrivatePub.publish_to("/user_#{item.user_id}", header_count + message_page_count  + @message_notification)
          
          

        render :json => '1'
        return
      end

      render :json => '0'
      return

    else

        if p2p_current_user.id != 1
           @items = p2p_current_user.items.approved.notsold.paginate(:page => params[:page] , :per_page => 20)
          else
           @items = P2p::Item.approved.notsold.paginate(:page => params[:page] , :per_page => 20)    
        end
        

        

    end
  end


end
