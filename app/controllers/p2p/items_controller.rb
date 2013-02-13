class P2p::ItemsController < ApplicationController


  before_filter :p2p_user_signed_in ,:except => [:view]
  layout :p2p_layout

  def new
   @item = P2p::User.find(current_user.id).items.new

  end


  def create


    item = P2p::User.find(current_user.id).items.new({:title => params["title"], :desc => params["desc"], :price => params["price"] ,:condition => params["condition"]})

    item.product = P2p::Product.find(params["brand"])

    #echo params["item"]['attribute'].count
    
     params["spec"].each do |key,value|
        next if value == "" 

       attr = P2p::ItemSpec.new
       attr.spec = P2p::Spec.find(key.to_i)
       attr.value = value
       item.specs << attr
     end

     data={}
    if item.save 
      data['status'] = 1;
      data['id'] = URI.encode("#{item.product.category.name}/#{item.product.name}/#{item.title}")
    else
      data['status'] = 0;
      data['msg'] = "Fails";
    end

    render :json => data

  end

 def update


    item = P2p::User.find(current_user.id).items.find(params[:id])

    item.update_attributes({:title => params["title"], :desc => params["desc"], :price => params["price"] ,:condition => params[:condition]});

    item.product = P2p::Product.find(params["brand"])

    #echo params["item"]['attribute'].count
    #clear all
    item.specs.clear

     params["spec"].each do |key,value|
        next if value == "" 
        
       attr = P2p::ItemSpec.new
       attr.spec = P2p::Spec.find(key.to_i)
       attr.value = value
       item.specs << attr
     end

     data={}
    if item.save 
      data['status'] = 1;
      data['id'] = URI.encode("#{item.product.category.name}/#{item.product.name}/#{item.title}")
    else
      data['status'] = 0;
      data['msg'] = "Fails";
    end

    render :json => data

end

  def destroy

    begin
      item = P2p::Item.find(params[:id])

      raise "Cannot Delete" if item.user.id != current_user.id 
    rescue
      if request.xhr? 
        render :json => {:status => 0}
      else
        flash[:notice] ="Nothing found for your request"
        redirect_to "/p2p/mystore"
        return
      end
    end
    

    item.deletedate = Time.now
    item.save

    if request.xhr? 
      render :json => {:status => 1}
    else
      flash[:notice] ="Nothing found for your request"
      redirect_to "/p2p/mystore"
      return
    end
  end

  def edit
  end

  def get_attributes
    cat = P2p::Category.find(params[:id])
    @attr = cat.specs.select("id,name,display_type").all

  #  render :json => @attr
  end

  def get_spec
    items = P2p::Item.find(params[:id])
    spec = items.specs.select("id,value,spec_id")
    
    render :partial => "p2p/items/editspec" , :locals => {:spec => spec}
  #  render :json => @attr
  end

  def get_brands
    cat =P2p::Category.find(params[:id]) 
    brand  = cat.products.select("id,name")
    render :json => brand
  end


  def get_sub_categories
    cat = P2p::Category.select("id,name").where("category_id = " + params[:id])
    render :json => cat
  end


  def view

      begin
        #@item = P2p::Item.find(params[:id])
        @cat =  P2p::Category.find_by_name(params[:cat])
        @prod=  @cat.products.find_by_name(params[:prod])
        @item = @prod.items.find_by_title(params[:item])

        raise "Nothing found" if @prod.nil? or  @item.nil? or @cat.nil?
        
      rescue
        flash[:notice] ="Nothing found for your request"
        redirect_to '/p2p/mystore'
        return
      end

      if @item.product.category.category.nil?
        @category_name = @item.product.category.name 
        @category_id = @item.product.category.id

        @sub_category_name = "" 
        @sub_category_id =""
      else
        @sub_category_name = @item.product.category.name 
        @sub_category_id = @item.product.category.id
        
        @category_name = @item.product.category.category.name 
        @category_id = @item.product.category.category.id

      end

      @brand_name = @item.product.name 
      @brand_id = @item.product.id

     @attr = @item.specs(:includes => :attr)

      if current_user.nil?
        @item.viewcount= @item.viewcount.to_i + 1
      end

    @item.save 
    
  end

  def inventory
    user = P2p::User.find(current_user)

    if params[:query].present? 

      if params[:query] == "sold"
        @items = user.items.sold
      end

    else

      @items = user.items.notsold
      
    end
    
  end

  def sold
      @item = P2p::Item.find(params[:id])
      @item.solddate =Time.now
      @item.save

      #render :json => {:status => 1 ,:id => "/p2p/#{@item.product.category.name}/#{@item.product.name}/#{@item.title}"}
      redirect_to URI.encode("/p2p/#{@item.product.category.name}/#{@item.product.name}/#{@item.title}")

  end

  def add_image


    item = P2p::Item.find(params["item_id"])
    unless params["img"].nil?


      params["img"].each do |img|

        i = item.images.new(:img=>img)

        i.save

      end

    end
    #render :inline => params.inspect

    redirect_to URI.encode("/p2p/#{item.product.category.name}/#{item.product.name}/#{item.title}")

  end

end
