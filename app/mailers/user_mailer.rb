class UserMailer < ActionMailer::Base
  default from: "\"SocioRent\" <alert@sociorent.com>", :bcc => "marudhu@devbrother.com"
  def welcome_email(user)
  	@general = General.first
    @user = user
    mail(:to => @user.email, :subject => @general.welcome_mail_subject)
  end

  def order_email(user, order)
  	@general = General.first
  	@user = user
  	@order = order
  	mail(:to => @user.email, :subject => @general.order_email_subject)
  end

  def p2p_listing_new_msg_notification(currentuser,listing)
      @listing = listing
      @user = currentuser
      #mail(:to => listing.user.user.email , :subject => "You have received a new message for your listing")
      mail(:to => 'marudhupandiyang@gmail.com' , :subject => "You have received a new message for your listing")
  end

end
