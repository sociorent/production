class P2p::CreditsController < ApplicationController
   before_filter :p2p_user_signed_in ,:except => [:view]
   layout :p2p_layout
 
  def new
   @user=P2p::User.find(current_user.id)
   @credit=@user.credits.new

  end

  def create
   @user=P2p::User.find(current_user.id)
   @credit = @user.credits.new(params['p2p_credit'])
   if @credit.save
   	render :list
   else
    render :new
   end

  end

  def delete
    @user=P2p::User.find(current_user.id)
     credit=@user.credits.find(params[:id])
     newcredit=credit.available
     credit.update_attributes(:available=>newcredit-1)   
  end

  def list
  	@user=P2p::User.find(current_user.id)
      
     @credit= @user.credits 
       respond_to do |format|
        format.js
        end
      
  end
end
