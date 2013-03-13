class UsersController < ApplicationController
  def get_user_details
    user = current_user
    if user && (user.mobile_number.nil? || user.college.nil? || user.stream.nil?)
      render "home/get_user_details"
    else
      redirect_to "/"
    end
  end

  def save_user_details
    user = current_user
    college = College.find(params[:college])
    stream = Stream.find(params[:stream])
    temp_id="#{params[:college][0..2].downcase}-#{rand(1000..1000000)}"
    while User.where(:unique_id=>temp_id).count>0
      temp_id="#{params[:college][0..2].downcase}-#{rand(1000..1000000)}"
    end
    user.update_attributes(:mobile_number => params[:mobile], :college_id => college.id, :stream_id => stream.id,:unique_id=>temp_id)

    #send the sms when the user completes signup
   # sms_text=Sms.where(:sms_type=>"signup").first.content
    send_sms(user.mobile_number,"Thanks for signing-up with Sociorent.com. Your ID is #{temp_id} . You may now login to place your order. Thank you.")
    render :text => "1"
  end

  def update
  	user = current_user
    college = College.where(:name => params[:college]).first
    stream = Stream.where(:name => params[:stream]).first
  	user.update_attributes(:name => params[:name], :mobile_number => params[:mobile_number], :college_id => college.id, :stream_id => stream.id)
  	render :nothing => true
  end

  def add_to_wishlist
    user = current_user
    book = Book.find(params[:book].to_i)
    if user.wishlist.nil?
      wishlist = []
    else
      wishlist = JSON.parse user.wishlist
    end
    wishlist << book.id
    user.update_attributes(:wishlist => wishlist.to_json())
    render :json => wishlist.to_json()
  end

  def wishlist
    user = current_user
    resp = []
    unless user.wishlist.nil?
      wishlist = JSON.parse user.wishlist
      wishlist.uniq
      wishlist.each do |id|
        resp << Book.find(id.to_i)
      end
    end
    render :json => resp.to_json()
  end

  def remove_from_wishlist
    user = current_user
    wishlist = JSON.parse user.wishlist
    book = Book.find(params[:book].to_i)
    wishlist.delete book.id
    user.update_attributes(:wishlist => wishlist.to_json())
    render :nothing => true
  end

  def select_reference
    ambassador = Ambassador.find(params[:ambassador_id].to_i)
    user = current_user
    user.ambassador = ambassador
    user.save
    render :nothing => true
  end

  def get_colleges
    result=[]
    College.where("name like ?","%#{params['term']}%").limit(20).each do |c|
        result << {"id"=>c.id, "label"=>c.name, "value" => c.name}
    end
    render :text=>result.to_json()
  end

  def get_streams
    result=[]
    Stream.where("name like ?","%#{params['term']}%").limit(20).each do |s|
        result << {"id"=>s.id, "label"=>s.name, "value" => s.name}
    end
    render :text=>result.to_json()
  end
end