class P2p::CategoriesController < ApplicationController

 layout :p2p_layout 

  def index
  	@res = []
  	P2p::Category.all.each do |c|
      next if c.products.size == 0 or c.specs.size == 0 
  		@res << {:value => c.id, :text => c.name}
  	end
  	render :json => @res
  end

  def set_category
  	session[:cat] = params[:id]
  	render :text => session[:cat]
  end
  
  def sub_category
  	@res = []
  	cat = P2p::Category.find(session[:cat])
  	cat.products.each do |c|
  		@res << {:value => c.id, :text => c.name}
  	end
  	render :json => @res
  end

end
