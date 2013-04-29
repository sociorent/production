class Street::ServicePincodesController < ApplicationController

  layout :p2p_layout
  # GET /p2p/service_pincodes
  # GET /p2p/service_pincodes.json
  def index
    @p2p_service_pincodes = P2p::ServicePincode.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @p2p_service_pincodes }
    end
  end

  # GET /p2p/service_pincodes/1
  # GET /p2p/service_pincodes/1.json
  def show
    @p2p_service_pincode = P2p::ServicePincode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @p2p_service_pincode }
    end
  end

  # GET /p2p/service_pincodes/new
  # GET /p2p/service_pincodes/new.json
  def new
    @p2p_service_pincode = P2p::ServicePincode.new


    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @p2p_service_pincode }
    end
  end

  # GET /p2p/service_pincodes/1/edit
  def edit
    @p2p_service_pincode = P2p::ServicePincode.find(params[:id])
  end

  # POST /p2p/service_pincodes
  # POST /p2p/service_pincodes.json
  def create
    @p2p_service_pincode = P2p::ServicePincode.new(params[:p2p_service_pincode])

    respond_to do |format|
      if @p2p_service_pincode.save

        redirect_to street_service_pincodes_url, notice: 'Service Pincode was successfully created.'
        return


        format.html { redirect_to @p2p_service_pincode, notice: 'Service pincode was successfully created.' }
        format.json { render json: @p2p_service_pincode, status: :created, location: @p2p_service_pincode }
      else
        format.html { render action: "new" }
        format.json { render json: @p2p_service_pincode.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /p2p/service_pincodes/1
  # PUT /p2p/service_pincodes/1.json
  def update
    @p2p_service_pincode = P2p::ServicePincode.find(params[:id])

    respond_to do |format|
      if @p2p_service_pincode.update_attributes(params[:p2p_service_pincode])

        redirect_to street_service_pincodes_url, notice: 'Service Pincode was successfully created.'
        return

        format.html { redirect_to @p2p_service_pincode, notice: 'Service pincode was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @p2p_service_pincode.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /p2p/service_pincodes/1
  # DELETE /p2p/service_pincodes/1.json
  def destroy
    @p2p_service_pincode = P2p::ServicePincode.find(params[:id])
    @p2p_service_pincode.destroy

    respond_to do |format|
      format.html { redirect_to street_service_pincodes_url }
      format.json { head :no_content }
    end
  end

  def check_availability

    item = P2p::Item.find(params[:itemid])
    if item.paytype == 3

      pincode = P2p::ServicePincode.find_by_pincode(params[:pincode])

      if !pincode.nil?
        render :json => [{:label => "Available in this region." , :value=> "1"}]
      else
        render :json => [{:label => "Not available in this region" , :value => "0"}]
      end

    else
      render :json => [{:label => "Not available in this region" , :value => "1"}]
    end

    return
  end
end
