class P2pServicePincodesController < ApplicationController
  # GET /p2p_service_pincodes
  # GET /p2p_service_pincodes.json
  def index
    @p2p_service_pincodes = P2pServicePincode.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @p2p_service_pincodes }
    end
  end

  # GET /p2p_service_pincodes/1
  # GET /p2p_service_pincodes/1.json
  def show
    @p2p_service_pincode = P2pServicePincode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @p2p_service_pincode }
    end
  end

  # GET /p2p_service_pincodes/new
  # GET /p2p_service_pincodes/new.json
  def new
    @p2p_service_pincode = P2pServicePincode.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @p2p_service_pincode }
    end
  end

  # GET /p2p_service_pincodes/1/edit
  def edit
    @p2p_service_pincode = P2pServicePincode.find(params[:id])
  end

  # POST /p2p_service_pincodes
  # POST /p2p_service_pincodes.json
  def create
    @p2p_service_pincode = P2pServicePincode.new(params[:p2p_service_pincode])

    respond_to do |format|
      if @p2p_service_pincode.save
        format.html { redirect_to @p2p_service_pincode, notice: 'P2p service pincode was successfully created.' }
        format.json { render json: @p2p_service_pincode, status: :created, location: @p2p_service_pincode }
      else
        format.html { render action: "new" }
        format.json { render json: @p2p_service_pincode.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /p2p_service_pincodes/1
  # PUT /p2p_service_pincodes/1.json
  def update
    @p2p_service_pincode = P2pServicePincode.find(params[:id])

    respond_to do |format|
      if @p2p_service_pincode.update_attributes(params[:p2p_service_pincode])
        format.html { redirect_to @p2p_service_pincode, notice: 'P2p service pincode was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @p2p_service_pincode.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /p2p_service_pincodes/1
  # DELETE /p2p_service_pincodes/1.json
  def destroy
    @p2p_service_pincode = P2pServicePincode.find(params[:id])
    @p2p_service_pincode.destroy

    respond_to do |format|
      format.html { redirect_to p2p_service_pincodes_url }
      format.json { head :no_content }
    end
  end
end
