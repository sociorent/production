class P2p::MessagesController < ApplicationController
  layout :p2p_layout
  before_filter :p2p_user_signed_in
  #check for user presence inside p2p
  before_filter :check_p2p_user_presence

  # @list all messages
  def index
    @user=p2p_current_user
    @message = @user.sent_messages.new
    @inbox = @user.received_messages.inbox
  end

  #create a new message
  def create
    user=p2p_current_user
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
      
      if @message.item.paytype == 2
        UserMailer.p2p_listing_new_msg_notification(current_user,@message.item).deliver
      end

    end
  end

  #show the message as requested by the id
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
      if @message.receiver_id = session[:userid]
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

  #destroy the message as requested bye id
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
        if msg.sender.id == session[:userid]
          msg.update_attributes(:sender_status => 4 )
        end
        if msg.receiver.id == session[:userid]
          msg.update_attributes(:receiver_status => 4 )
        end
        deleted_messages.push(id)
      end
    end
    unreadcount =  p2p_current_user.received_messages.inbox.unread.count
    # private pub section
    render :json => {:id =>  deleted_messages , :unreadcount => unreadcount}
  end

  #ititate a empyt message record for compose
  def new
    @mesage= p2p_current_user.sent_messages.new
    #render "p2p/messages/compose" ,:message => @message
    #return
  end

  #get the messages as requested bye the data table
  def getmessages
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
      when "4" #based on time column
        order = "created_at " + params[:sSortDir_0]
      when "2" #based on sender column
        #check the table and sent the order by
        if params[:id] == 'inbox'
          order = "sender_id " + params[:sSortDir_0]
        elsif  params[:id] == 'sentbox'
          order = "receiver_id " + params[:sSortDir_0]
        end
        #based on item
      when "1"
        order = "item_id " + params[:sSortDir_0]
      end
    end
    #if the client has request for search
    if params.has_key?(:searchq)
      search = params[:searchq]
      #the searc for item begines with #
      #eg, to searchh for nokia product search like #nokia
      #reset searches in message column
      if search.index('#') == 0
        begin
          item = P2p::Item.find_by_title(search.slice(1,(search.size-1))).id
        rescue
          item = 0
        end
      end
    end
    #find for which items is the request came for
    # and get messages appropiatly
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
    # form the response for the datatable
    response[:iTotalRecords] =  message_count
    response[:iTotalDisplayRecords] = message_count
    #form the time to be displayed
    messages.each do |msg|
      tme =Time.now - msg.created_at
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
      #add unread mesage if for color display
      if params[:id] == 'inbox'  and msg.receiver_status.to_s == "0"
        row_class = 'unread'
      else
        row_class = ''
      end
      #add click trigger for js to display the message
      row_class += ' message_show_trigger'

      if msg.messagetype ==  2
        msgtype = "  <i class=' action  icon-shopping-cart '  title='Buy Request'></i>  ";
      else
        msgtype = "  <i class=' action  icon-list-alt ' title='Admin Messages'></i>  ";
      end
      response[:aaData].push({
                               "0" => "<input type='checkbox' class='msg_check' msgid='#{msg.id}' >",
                               "1" => (msg.item.nil?) ?    msgtype + " Sociorent" : msgtype +  msg.item.title,
                               "2" => msg.sender.user.name,
                               "3" => "<div class='showmessage' msgid='#{msg.id}' ><a href='#' >#{msg.message.slice(0,15).gsub('<br>','').gsub('<br/>','') + '...'}</a></div>",
                               "4" => tme,
                               "DT_RowClass" => row_class
      })
    end
    render :json => response
  end

  def mark_as_read
    messages = p2p_current_user.received_messages.unread
    messages.update_all({:receiver_status => 1})
    PrivatePub.publish_to("/user_#{p2p_current_user.id}", "$('#unread_count').html('');$('#header_msg_count').html('');")
    render :text=>"Updated"
  end
end
