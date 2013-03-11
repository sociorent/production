class P2p::ItemDeliveriesController < ApplicationController

  layout :p2p_layout
  
  # GET /p2p/item_deliveries
  # GET /p2p/item_deliveries.json
  def index
    @p2p_item_deliveries = P2p::ItemDelivery.order('updated_at desc').paginate(:page => params[:page] ,:per_page => 10)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @p2p_item_deliveries }
    end
  end

  # GET /p2p/item_deliveries/1
  # GET /p2p/item_deliveries/1.json
  def show
    @p2p_item_delivery = P2p::ItemDelivery.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @p2p_item_delivery }
    end
  end

  # GET /p2p/item_deliveries/new
  # GET /p2p/item_deliveries/new.json
  def new
    @p2p_item_delivery = P2p::ItemDelivery.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @p2p_item_delivery }
    end
  end

  # GET /p2p/item_deliveries/1/edit
  def edit
    begin
      @p2p_item_delivery = p2p_current_user.soldpayments.find(params[:id])

      rescue
        begin
         @p2p_item_delivery = p2p_current_user.payments.find(params[:id])

        rescue Exception => e
          redirect_to '/p2p'     
          return
        end

    end

  end

  # POST /p2p/item_deliveries
  # POST /p2p/item_deliveries.json
  def create
    @p2p_item_delivery = P2p::ItemDelivery.new(params[:p2p_item_delivery])

    respond_to do |format|
      if @p2p_item_delivery.save
        format.html { redirect_to @p2p_item_delivery, notice: 'Item delivery was successfully created.' }
        format.json { render json: @p2p_item_delivery, status: :created, location: @p2p_item_delivery }
      else
        format.html { render action: "new" }
        format.json { render json: @p2p_item_delivery.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /p2p/item_deliveries/1
  # PUT /p2p/item_deliveries/1.json
  def update
    @p2p_item_delivery = P2p::ItemDelivery.find(params[:id])

    respond_to do |format|
      if @p2p_item_delivery.update_attributes(params[:p2p_item_delivery])
        format.html { redirect_to '/p2p/paymentdetails', notice: 'Item delivery was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: 'p2p/paymentdetails', status: :unprocessable_entity }
      end
    end
  end

  # DELETE /p2p/item_deliveries/1
  # DELETE /p2p/item_deliveries/1.json
  def destroy
    @p2p_item_delivery = P2p::ItemDelivery.find(params[:id])
    @p2p_item_delivery.destroy

    respond_to do |format|
      format.html { redirect_to p2p_item_deliveries_url }
      format.json { head :no_content }
    end
  end
end
