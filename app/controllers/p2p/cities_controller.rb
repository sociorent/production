class P2p::CitiesController < ApplicationController

  layout :p2p_layout

  def index
  end

  def list
  	cities = P2p::City.where("name like '" + params[:query] + "%'")

  	if cities.nil? 
  		cities[0] = ['No Result']
  	end

  	render :json => cities
  end
end
