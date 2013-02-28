class P2p::ProductsController < ApplicationController

  layout :p2p_layout
  # GET /p2p/products
  # GET /p2p/products.json
  def index
    @p2p_products = P2p::Product.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @p2p_products }
    end
  end

  # GET /p2p/products/1
  # GET /p2p/products/1.json
  def show
    @p2p_product = P2p::Product.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @p2p_product }
    end
  end

  # GET /p2p/products/new
  # GET /p2p/products/new.json
  def new
    @p2p_product = P2p::Product.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @p2p_product }
    end
  end

  # GET /p2p/products/1/edit
  def edit
    @p2p_product = P2p::Product.find(params[:id])
  end

  # POST /p2p/products
  # POST /p2p/products.json
  def create
    @p2p_product = P2p::Product.new(params[:p2p_product])

    respond_to do |format|
      if @p2p_product.save
        format.html { redirect_to @p2p_product, notice: 'Product was successfully created.' }
        format.json { render json: @p2p_product, status: :created, location: @p2p_product }
      else
        format.html { render action: "new" }
        format.json { render json: @p2p_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /p2p/products/1
  # PUT /p2p/products/1.json
  def update
    @p2p_product = P2p::Product.find(params[:id])

    respond_to do |format|
      if @p2p_product.update_attributes(params[:p2p_product])
        format.html { redirect_to @p2p_product, notice: 'Product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @p2p_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /p2p/products/1
  # DELETE /p2p/products/1.json
  def destroy
    @p2p_product = P2p::Product.find(params[:id])
    @p2p_product.destroy

    respond_to do |format|
      format.html { redirect_to p2p_products_url }
      format.json { head :no_content }
    end
  end
end
