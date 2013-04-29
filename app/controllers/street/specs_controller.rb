class Street::SpecsController < ApplicationController
  layout :p2p_layout
  # GET /p2p/specs
  # GET /p2p/specs.json
  def index
    @p2p_specs = P2p::Spec.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @p2p_specs }
    end
  end

  # GET /p2p/specs/1
  # GET /p2p/specs/1.json
  def show
    @p2p_spec = P2p::Spec.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @p2p_spec }
    end
  end

  # GET /p2p/specs/new
  # GET /p2p/specs/new.json
  def new
    @p2p_spec = P2p::Spec.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @p2p_spec }
    end
  end

  # GET /p2p/specs/1/edit
  def edit
    @p2p_spec = P2p::Spec.find(params[:id])
  end

  # POST /p2p/specs
  # POST /p2p/specs.json
  def create
    @p2p_spec = P2p::Spec.new(params[:p2p_spec])
    respond_to do |format|
      if @p2p_spec.save
        redirect_to street_specs_url, notice: 'Specification was successfully created.'
        return
        format.html { redirect_to @p2p_spec, notice: 'Spec was successfully created.' }
        format.json { render json: @p2p_spec, status: :created, location: @p2p_spec }
      else
        format.html { render action: "new" }
        format.json { render json: @p2p_spec.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /p2p/specs/1
  # PUT /p2p/specs/1.json
  def update
    @p2p_spec = P2p::Spec.find(params[:id])
    respond_to do |format|
      if @p2p_spec.update_attributes(params[:p2p_spec])
        redirect_to street_specs_url, notice: 'Specification was successfully created.'
        return
        format.html { redirect_to @p2p_spec, notice: 'Spec was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @p2p_spec.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /p2p/specs/1
  # DELETE /p2p/specs/1.json
  def destroy
    @p2p_spec = P2p::Spec.find(params[:id])
    @p2p_spec.destroy
    respond_to do |format|
      format.html { redirect_to street_specs_url }
      format.json { head :no_content }
    end
  end

end
