class Street::CitiesController < ApplicationController

  layout :p2p_layout

  # GET /p2p/cities
  # GET /p2p/cities.json
  def index
    response={:aaData => []}
    #where to start
    if params.has_key?("iDisplayStart")
      start = (params[:iDisplayStart].to_i / params[:iDisplayLength].to_i) + 1
    else
      start = 1
    end
    #order by the time by default
    order = "updated_at desc"

    #if sort is explicitly sennt from the client
    if params.has_key?(:iSortCol_0)
      case params[:iSortCol_0]
      when "1" #based on sender column
        #check the table and sent the order by
          order = "name " + params[:sSortDir_0]
        #based on item
      end
    end

    if params[:searchq]
      cities = P2p::City.where("name like '%#{params[:searchq]}%'").paginate(:page => start,:per_page =>  params[:iDisplayLength] )
    else
      cities = P2p::City.paginate(:page => start,:per_page =>  params[:iDisplayLength] )
    end

    # form the response for the datatable
    response[:iTotalRecords] =  cities.count
    response[:iTotalDisplayRecords] = cities.count
    
    #form the time to be displayed
    cities.each do |city|
      response[:aaData].push({
                                 "0" => city.name,
                                 "1" => city.show_city,
                                 "2" => "<a href='/street/admin/cities/#{city.id}/edit'><i class='icon-edit'></i></a> <a href='/street/admin/cities/#{city.id}/destory'><i class='icon-trash'></i></a>".html_safe


      })
    end
    if request.xhr?
      render :json => response
    end
  end

  # GET /p2p/cities/1
  # GET /p2p/cities/1.json
  def show
    @p2p_city = P2p::City.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @p2p_city }
    end
  end

  # GET /p2p/cities/new
  # GET /p2p/cities/new.json
  def new
    @p2p_city = P2p::City.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @p2p_city }
    end
  end

  # GET /p2p/cities/1/edit
  def edit
    @p2p_city = P2p::City.find(params[:id])
  end

  # POST /p2p/cities
  # POST /p2p/cities.json
  def create
    @p2p_city = P2p::City.new(params[:p2p_city])

    respond_to do |format|
      if @p2p_city.save
        format.html { redirect_to '/street/admin/cities', notice: 'City was successfully created.' }
        format.json { render json: @p2p_city, status: :created, location: @p2p_city }
      else
        format.html { render action: "new" }
        format.json { render json: @p2p_city.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /p2p/cities/1
  # PUT /p2p/cities/1.json
  def update
    @p2p_city = P2p::City.find(params[:id])

    respond_to do |format|
      if @p2p_city.update_attributes(params[:p2p_city])
        format.html { redirect_to '/street/admin/cities', notice: 'City was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @p2p_city.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /p2p/cities/1
  # DELETE /p2p/cities/1.json
  def destroy
    @p2p_city = P2p::City.find(params[:id])
    @p2p_city.destroy

    respond_to do |format|
      format.html { redirect_to street_cities_url }
      format.json { head :no_content }
    end
  end

  # get the city list for xeditable
  def list
    unless params[:query].nil?
      # if some how we have empty city name empyt in database  ignore it
  	  cities = P2p::City.select('name').where("name like '" + params[:query] + "%' or name is not null and show_city = 1")
    else
      cities = P2p::City.select('name').where(:show_city => true)
    end

  	if cities.nil?
  		cities[0] = [{:name =>'No Result'}]
  	end

  	render :json => cities.collect{|city| city.name =((city.name.nil?)  ? "" : city.name) ; {city.name  => city.name}}
  end
end
