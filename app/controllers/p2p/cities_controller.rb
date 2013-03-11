class P2p::CitiesController < ApplicationController

  layout :p2p_layout

  def index
  end

  def list
    unless params[:query].nil?
  	  cities = P2p::City.select('name').where("name like '" + params[:query] + "%' or name is not null")
    else
      cities = P2p::City.select('name')
    end

  	if cities.nil? 
  		cities[0] = [{:name =>'No Result'}]
  	end



  	render :json => cities.collect{|city| city.name =((city.name.nil?)  ? "" : city.name) ; {city.name  => city.name}}
  end
end
