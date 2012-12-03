class UserMailer < ActionMailer::Base
  default from: "alert@sociorent.com", :cc => "testing@devbrother.com"

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
end
