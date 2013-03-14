class P2p::CategoriesController < ApplicationController

 layout :p2p_layout 

   before_filter :p2p_user_signed_in 

  # GET /p2p/categories
  # GET /p2p/categories.json
  def index
    @p2p_categories = P2p::Category.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @p2p_categories }
    end
  end

  # GET /p2p/categories/1
  # GET /p2p/categories/1.json
  def show
    @p2p_category = P2p::Category.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @p2p_category }
    end
  end

  # GET /p2p/categories/new
  # GET /p2p/categories/new.json
  def new
    @p2p_category = P2p::Category.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @p2p_category }
    end
  end

  # GET /p2p/categories/1/edit
  def edit
    @p2p_category = P2p::Category.find(params[:id])
  end

  # POST /p2p/categories
  # POST /p2p/categories.json
  def create
    @p2p_category = P2p::Category.new(params[:p2p_category])

    respond_to do |format|
      if @p2p_category.save
                 
                 redirect_to p2p_categories_url, notice: 'Category was successfully created.'
                 return

        format.html { redirect_to @p2p_category, notice: 'Category was successfully created.' }
        format.json { render json: @p2p_category, status: :created, location: @p2p_category }
      else
        format.html { render action: "new" }
        format.json { render json: @p2p_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /p2p/categories/1
  # PUT /p2p/categories/1.json
  def update
    @p2p_category = P2p::Category.find(params[:id])


    respond_to do |format|
      if @p2p_category.update_attributes(params[:p2p_category])

        redirect_to p2p_categories_url, notice: 'Category was successfully created.'
        return

        format.html { redirect_to @p2p_category, notice: 'Category was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @p2p_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /p2p/categories/1
  # DELETE /p2p/categories/1.json
  def destroy
    @p2p_category = P2p::Category.find(params[:id])
    @p2p_category.destroy

    respond_to do |format|
      format.html { redirect_to p2p_categories_url }
      format.json { head :no_content }
    end
  end



  # get the categories for listing in xeditable
  def getcategories
    @res = []
    P2p::Category.all.each do |c|
#      next if c.name!="Books" or c.specs.size == 0 
      @res << {:value => c.id, :text => c.name}
    end
    render :json => @res
  end

  # for new item
  def get_attributes
    cat = P2p::Category.find(params[:id])
    @attributes = cat.specs.select("id,name,display_type")
    #  render :json => @attr
  end

  def get_brands
    cat =P2p::Category.find(params[:id])
    brand  = cat.products.select("id as value,name as text")
    brand << "Other"
    render :json => brand
    return
  end

end
