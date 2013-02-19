module P2p::MessagesHelper


class InboxDataTable
  delegate :params, :h, to: :@view
  def initialize(view,user)
    @view = view
    @user = P2p::User.find_by_user_id(1)
  end

  def as_json(options = {})
    # if params[:iSortCol_0].to_i == 1
    #   data = data.sort_by{ |k, v| v[1] }
    # end
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: @user.received_messages.inbox.count,
      iTotalDisplayRecords: inbox.total_entries,
      aaData: data
    }
  end

private

  def data
    inbox.map do |message|
      delete = "<input type='checkbox' class='inbox_checkbox' id='inbox_#{message.id}'>"
      email = "<a href='/messages/#{message.id}' class='read_#{message.id} message_#{message.receiver_status}' data-remote='true'> #{message.sender.email}</a>"
      subject = "<a href='/messages/#{message.id}.js' class='read_#{message.id}' class='message_#{message.receiver_status}' data-remote='true'> #{message.subject}</a>"
      msg = truncate(message.message, :length => 17, :separator => " ")
      date = (Date.today == message.created_at.to_date) ? message.created_at.strftime("%I:%M %p") : message.created_at.strftime("%b %d")
      msg = "#{subject}-#{msg}"
      #delete = "<a href='/messages/#{message.id}?from=inbox' id='inbox_#{message.id}' data-remote='true' data-method='DELETE'> Delete</a>"
      [
        delete,
        email,
        msg,
        date
      ]
    end

  end

  def inbox
    @inbox ||= fetch_inbox_messages
  end

  def fetch_inbox_messages
    if params[:iSortCol_0].nil?
      inbox = @user.received_messages.inbox.order("updated_at desc")
    else
      inbox = @user.received_messages.inbox.order("#{sort_column} #{sort_direction}")
    end
    inbox = inbox.page(page).per_page(per_page)
    if params[:sSearch].present?
      inbox = Message.search("#{params[:sSearch]}", :star => true, :match_mode => :any)
    end
    
    inbox
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[sender_id sender_id message created_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
end
