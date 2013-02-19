class P2p::MessagesController < ApplicationController
	layout :p2p_layout

  before_filter :p2p_user_signed_in 

  #check for user presence inside p2p
  before_filter :check_p2p_user_presence

  def index
  	
      @user=p2p_current_user
      @message = @user.sent_messages.new

     # puts @message.inspect + "message"
   
  	#Inbox => Both read and unread messages from scope
	   @inbox = @user.received_messages.inbox
  #   @inbox_admin_msg = @user.received_messages.inbox.where("messagetype=2")
  #   @inbox_sell_req = @user.received_messages.inbox.where("messagetype=1") 
  #   @inbox_buy_req = @user.received_messages.inbox.where("messagetype=0") 
  
	 #  # getting the sent messages from the scope
	 #  @sent = @user.sent_messages.sentbox
  # #@mesage=P2p::Message.all
  # #@inbox=P2p::Message.inbox

  end

  def create
  	 user=p2p_current_user

      # if params[:p2p_message][:item_id] != "" 
      #   item= P2p::Item.find(params[:p2p_message][:item_id])
      #   item.reqCount += 1
        
      # end
      params[:p2p_message][:receiver_status] = 0
      params[:p2p_message][:sender_status] = 2

      # //remove from from the params to pass to create message
      from = params[:p2p_message][:from]
      parent = params[:p2p_message][:parent_id]

      params[:p2p_message].delete(:from)
      params[:p2p_message][:parent_id]=0
      
      @receiver_id = params[:p2p_message][:receiver_id]
   	  @message=user.sent_messages.create(params[:p2p_message])

      unless parent.nil?
        begin
          @message.parent_msg = P2p::Message.find(parent)
        rescue
          @message.parent_msg = nil
        end

      end

     unless @message.item.nil?
      @message.item.reqCount +=1
      @message.item.save
     end


 end
        
  
  def show

    unless request.xhr?
        @user=p2p_current_user
        @message = @user.sent_messages.new
        @inbox = @user.received_messages.inbox

        render :action => :index
        return 
    end

    @message=P2p::Message.find(params[:id])

    resp =[]

    while !@message.nil?

      puts "Recive id : " + @message.receiver_id.to_s
      puts " My id: " + p2p_current_user.id.to_s

      if @message.receiver_id = p2p_current_user.id
        
           @message.update_attributes(:receiver_status => 1) if @message.receiver_status != 0

          name = @message.sender.user.name
          id = @message.sender.id
      else
          name = @message.receiver.user.name
          id = @message.receiver.id
        
        return
      end

 
     dte = @message.created_at.strftime("%d-%h-%C%y %I:%M %p")

      if @message.messagetype == 1 #admin requet
        sub = "Message from Admin"
      elsif @message.messagetype == 2 #admin requet
        sub = "Buy request from " + name
      else
        sub = "Message"
      end

      msg = @message.message

      resp.push( {:name => name , :sub => sub ,:msg => msg ,:dte => dte ,:receiver => id })

      puts @message.inspect + "pp "

      @message = @message.parent_msg

      puts @message.inspect + "p  asdfp "

    end

    render :json => resp

  end  

  def destroy
    
    deleted_messages = []

    if !params.has_key?(:msgid) 
      render :json=> []
      return
    end

    params[:msgid].each do |id|

        if params[:tbl] == 'inbox' 
          if p2p_current_user.received_messages.inbox.find(id).update_attributes(:receiver_status => 3 ) 
            deleted_messages.push(id)
          end
        elsif params[:tbl] == 'sentbox' 
          if p2p_current_user.sent_messages.sentbox.find(id).update_attributes(:sender_status => 3 ) 
            deleted_messages.push(id)
          end
        elsif params[:tbl] == 'deletebox' 
            msg = P2p::Message.deleted(p2p_current_user).find(id)

            if msg.sender.id == p2p_current_user.id
                msg.update_attributes(:sender_status => 4 ) 
            end
            if msg.receiver.id == p2p_current_user.id
                msg.update_attributes(:receiver_status => 4 ) 
            end

            deleted_messages.push(id)
        end
    end

    unreadcount =  p2p_current_user.received_messages.inbox.unread.count 

   # private pub section

    # publish to change th read count
    if unreadcount > 0 
      header_count = ""
      message_page_count = " "
    else
      header_count = "$('#header_msg_count').html('');"
      message_page_count = " $('#unread_count').html();"
    end

    PrivatePub.publish_to("/user_#{p2p_current_user.id}", (header_count + message_page_count).html_safe )
    
    

    render :json => {:id =>  deleted_messages , :unreadcount => unreadcount}


  end

  def new

    @mesage= p2p_current_user.sent_messages.new

    #render "p2p/messages/compose" ,:message => @message
    #return

 end

  def getmessages

    response={:aaData => []}

    if params.has_key?("iDisplayStart")
      start = (params[:iDisplayStart].to_i / 10) + 1
    else
      start = 1
    end

    order = "created_at desc"
    search = ""
    item = 0

    if params.has_key?(:iSortCol_0)
        case params[:iSortCol_0]
          when "4"
            order = "created_at " + params[:sSortDir_0]
          when "2"
            
            if params[:id] == 'inbox'
              order = "sender_id " + params[:sSortDir_0]
            elsif  params[:id] == 'sentbox'
              order = "receiver_id " + params[:sSortDir_0]
            end

          when "1"
            order = "item_id " + params[:sSortDir_0]
        end
    end



    if params.has_key?(:searchq)
      search = params[:searchq]
      
      puts search.slice(1,(search.size-1))+ "lsjdfak"

      if search.index('#') == 0
        begin
          item = P2p::Item.find_by_title(search.slice(1,(search.size-1))).id
        rescue 
           item = 0
        end 
      end

    end

    puts " Search " + search + " Item " + item.to_s

    if params[:id] == 'inbox' 

      if search != ""
            if item !=0
              messages = p2p_current_user.received_messages.inbox.order(order).where("item_id=#{item}").paginate( :page => start ,:per_page => 10)
              message_count = p2p_current_user.received_messages.inbox.where("item_id=#{item}").count      
            else

              messages = p2p_current_user.received_messages.inbox.order(order).where("message like '%#{search}%'").paginate( :page => start ,:per_page => 10)
              message_count = p2p_current_user.received_messages.inbox.where("message like '%#{search}%'").count
          end
      else
        messages = p2p_current_user.received_messages.inbox.order(order).paginate( :page => start ,:per_page => 10)
        message_count = p2p_current_user.received_messages.inbox.count
      end


    elsif params[:id] == 'sentbox' 
      if search != ''
          if item !=0
              messages = p2p_current_user.sent_messages.sentbox.order(order).where("item_id=#{item}").paginate( :page => start,:per_page => 10)
              message_count = p2p_current_user.sent_messages.sentbox.where("item_id=#{item}").count
          else
            messages = p2p_current_user.sent_messages.sentbox.order(order).where("message like '%#{search}%'").paginate( :page => start,:per_page => 10)
            message_count = p2p_current_user.sent_messages.sentbox.where("message like '%#{search}%'").count
          end
        
      else
        messages = p2p_current_user.sent_messages.sentbox.order(order).paginate( :page => start,:per_page => 10)
        message_count = p2p_current_user.sent_messages.sentbox.count
      end
      
    elsif params[:id] == 'deletebox' 
      if search !=''
            if item !=0
              messages = P2p::Message.deleted(p2p_current_user).order(order).where("item_id=#{item}").paginate( :page => start,:per_page => 10)
              message_count = P2p::Message.deleted(p2p_current_user).where("item_id=#{item}").count
            else
              messages = P2p::Message.deleted(p2p_current_user).order(order).where("message like '%#{search}%'").paginate( :page => start,:per_page => 10)
              message_count = P2p::Message.deleted(p2p_current_user).where("message like '%#{search}%'").count
            end
      else
        messages = P2p::Message.deleted(p2p_current_user).order(order).paginate( :page => start,:per_page => 10)
        message_count = P2p::Message.deleted(p2p_current_user).count
      end
      
    end
#   

    response[:iTotalRecords] =  message_count
    response[:iTotalDisplayRecords] = message_count
    #response[:iStart] =  (params.has_key("iStart") ? (params[:iStart].to_i + 10) : 0 


    messages.each do |msg|

      tme =Time.now - msg.created_at

      if tme >= 86400
        tme =  (tme/86400).to_i.to_s + " days ago"
      elsif tme >=3600
        tme =  (tme/3600).to_i.to_s + " hr ago"
      else
        tme = (tme/60).to_i.to_s + "min ago"
      end
  
      


      if params[:id] == 'inbox'  and msg.receiver_status.to_s == "0"
        row_class = 'unread'
      else
        row_class = ''
      end

      puts "class " + row_class + msg.receiver_status.to_s + "sfs " + params.inspect

      

      if msg.messagetype ==  2
        msgtype = "  <i class=' action  icon-shopping-cart '  title='Buy Request'></i>  ";
      else
        msgtype = "  <i class=' action  icon-list-alt ' title='Admin Messages'></i>  ";  
      end


      response[:aaData].push({
                          "0" => "<input type='checkbox' class='msg_check' msgid='#{msg.id}' >",
                          "1" => (msg.item.nil?) ?    msgtype + " ---" : msgtype +  msg.item.title,
                          "2" => msg.sender.user.name,
                          "3" => "<div class='showmessage' msgid='#{msg.id}' ><a href='#' >#{msg.message.slice(0,15) + '...'}</a></div>",
                          "4" => tme,
                          "DT_RowClass" => row_class
                          })

    end 

    render :json => response

 end

end

