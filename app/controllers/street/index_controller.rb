#paginate the array...
require 'will_paginate/array'
class Street::IndexController < ApplicationController
  #check for user presence inside p2p
  before_filter :check_p2p_user_presence , :except => [:get_city]
  layout :p2p_layout

  def index
    # load the categories based on their priority
    @category = P2p::Category.order("priority")
    @main_categories = P2p::Category.main_categories.includes(:items)
    
#    category_count = 0
    @category_items = Hash.new
#    if category_count<5
      @main_categories.each do |main_cate|
        if main_cate.items.listing_items_by_location(p2p_get_user_location).count > 0
          @category_items["#{make_category_url(main_cate)}"] = []
          main_cate.items.listing_items_by_location(p2p_get_user_location).limit(4).each do |item|
            @category_items["#{make_category_url(main_cate)}"] << item
          end
#          category_count += 1
        end
      end
#    end
  end

  # the autocomplete seeearch for site wide search
  def search
    begin
      unless request.xhr?
        redirect_to '/street'
        flash[:notice] ="Invalid Request"
        return
      end
      response = get_search_suggestions(params[:id])
      if response.size == 0
        suggested_word = suggest(params[:id])
        response = get_search_suggestions(suggested_word)
      end
      # truncte response to display only first 15 results
      response = response.first(15)
      if response.empty?
        render :json => [{:label => "No results found" ,:value => ""}]
        return
      else
        render :json => response
        return
      end
    end
  end

  def search_query
    item = P2p::Item
    item_count = 0
    if params[:category] !=""
      item = P2p::Category.find(params[:category]).items
      item_count = item.count
    end
    if params[:query] !="" && ((params[:category]!="" && item_count > 0 ) || params[:category] =="")
      puts "falled in sphinx"
      @result = item.listing_items_by_location(p2p_get_user_location).active_items.search(params[:query] ,:match_mode => :any ,:star => true).paginate(:page => params[:page] ,:per_page => 20)

      # //if 0 results dn depend on sphinx
      if @result.count == 0
          @result = item.listing_items_by_location(p2p_get_user_location).active_items.where("title like '%#{params[:query]}%' or title like lower('%#{params[:query]}%')").paginate(:page => params[:page] ,:per_page => 20)
      end

    elsif params[:category]!="" && params[:query] ==""
      puts "Falled in cate"
      @result = item.paginate(:page => params[:page] ,:per_page => 20)
    else
      flash[:notice]="No query has been entered"
      redirect_to "/street"
      return
    end
  end
  def get_search_suggestions(query)
    #response =[{:label => query ,:value => URI.encode("#{query}")}]
    response =[]

    item_result = P2p::Item.by_location_or_allover(p2p_get_user_location).active_items.group('product_id').notsold.approved.select('product_id').search(query ,:match_mode => :any ,:star => true)

    if item_result.count == 0
      item_result = P2p::Item.by_location_or_allover(p2p_get_user_location).active_items.group('product_id').notsold.approved.select('product_id').where("title like '%#{query}%' or title like lower('%#{query}%')").paginate(:page => params[:page] ,:per_page => 20)
    end

    used_cat =[]
    item_result.each do |prod|
    # cat_result = P2p::Category.search(query ,:match_mode => :any ,:star => true)
    #   result.each do |res|
    #     response.push( {:label => "#{query} in #{res.name}" , :value => URI.encode("/p2p/#{res.name}")} )
    #   end

      res = P2p::Product.find(prod.product_id)

      next if used_cat.include?(res.category.id)
      used_cat.push(res.category.id)

      response.push({:label=> "#{query} in #{res.category.name}",:value => "#{res.name}"})
    end


    item_result = P2p::Item.by_location_or_allover(p2p_get_user_location).active_items.search(query ,:match_mode => :any ,:star => true)
    if item_result.count == 0
      item_result = P2p::Item.by_location_or_allover(p2p_get_user_location).active_items.where("title like '%#{query}%' or title like lower('%#{query}%')").paginate(:page => params[:page] ,:per_page => 20)
    end

    item_result.each do |res|
      response.push({:label=> "#{res.title}" ,:value => URI.encode("#{make_item_url(res)}") }) unless res.nil?
    end
    return response
  end

  # search inside a category
  #for urls like /p2p/books
  def search_cat
    @cat = P2p::Category.find(params[:cat].to_i)
    @cat_name = @cat.name
    if params.has_key?("prod")
      @products = @cat.products.find(params[:prod].to_i)
    else
      @products = @cat.products
    end
  end
  # aspell

  def suggest(query_word)
    speller = Aspell.new("en_US")
    speller.suggestion_mode = Aspell::ULTRA
    query_word.split(" ").each do |word|
      if !speller.check(word)
        query_word.gsub! word , speller.suggest(word).first
      end
    end
    query_word
  end

  def browse
    @cat = P2p::Category.find(params[:cat].to_i)
    if @cat.nil? or @cat.products.count == 0
      flash[:notice] ="Nothing found for your request"
      redirect_to "/street"
      return
    end
    if params.has_key?("prod")
      @products=@cat.products.order("priority").find(:all,params[:prod].to_i)
      if @products.nil?
        # @cat = P2p::Category.find(params[:prod].to_i)
        @products= @cat.products.all.order("priority")
        params.delete("prod")
      end
    else
      @products=@cat.products.all
      if !@cat.subcategories.nil?
        @cat.subcategories.each do |cat|
          @products += cat.products.order("priority")
        end
      end
    end

    @view_filter_set=[]

    @products
  end

  def seller_items
    @items = P2p::User.find(params[:id]).items.active_items
  end


  def browse_filter
    # // if applied_filters filters is passed we
    # must be sure we are called via ajax
    if params.has_key?(:applied_filters)
      if  request.xhr?
        render :json =>  []
        return
      end
    end
    # find the category in which the filter is to be applied
    @cat = P2p::Category.find(params[:cat].to_i)
    if @cat.nil?
      render :json => []
      return
    end
    # //initialise the varaiables
    filter =[]
    order_result = ""
    item_condition_filter = ""
    # check if we have filters already
    #that is we have filter coming by url..
    if params.has_key?(:applied_filters)
      #filters come in get query format lik  OS=Win8&Ram=8GB
      #so seperate them by & firs and then split each key value by =
      spec= params[:applied_filters].split('&')
      (0..(spec.size() - 1 ) ).each do |i|
        begin
          spec[i] = spec[i].split('=')
        rescue
        end
      end
      # initialize the filter an dput the key value pair inisede it..
      # each filter would be in this format
      #eg. OS=WIn8,win7,xp
      #tat is user might have applied morethan one in same category..
      #so we have to split them at put in params array
      #and simulate as if they had been sent by the user
      params[:filter] = {}
      spec.each do |key,val|
        begin
          params[:filter][key] = val.split(',')
        rescue
        end
      end
      puts spec.inspect + " passed filter"
    end #end for applied filters
    #not the filter is presetnt..
    #first find order by
    @view_filter_set = []
    if params.has_key?("filter")
      @view_filter_set = params[:filter].dup
      if params[:filter].has_key?("sort")
        sortby =  params[:filter][:sort][0].to_s
        params[:filter].delete(:sort)
        case sortby
        # when "0"
        #   order_result = "priority"
        when "1"
          order_result = "price desc"
        when "2"
          order_result = "price asc"
        else
          order_result = ""
        end
      end

      if params[:filter].has_key?(:price) and !params[:filter][:price].nil?
        if params[:filter][:price][1].nil?
          item_price = "  p2p_items.price > #{params[:filter][:price][0]} "
        else
          item_price = "  p2p_items.price between  #{params[:filter][:price][0]}  and #{params[:filter][:price][1]} "
        end
        item_condition_filter += "(#{item_price})"
      end

      # second from the query
      # by parsing each and every filter


      if params[:filter].has_key?(:model)
        params[:prod] = params[:filter][:model]

        if item_condition_filter !=""
          item_condition_filter += ' and '
        end

        item_condition_filter += " p2p_items.product_id in (#{ params[:filter][:model].join(',')}) "
      end

      # second from the query
      # by parsing each and every filter

      if params[:filter].has_key?("condition")
        temp = []

        params[:filter][:condition].each do |fil|
          temp.push("'" + fil + "'")
        end


        if item_condition_filter!=""
                item_condition_filter   += " and "
        end

        item_condition_filter += ' p2p_items.condition in (' + temp.join(",") + ")  "
      end

        params[:filter].each do |key,val|
          begin
            temp = @cat.specs.find_by_name(key)
            val_temp=[]
            val.each do |v|
              val_temp.push("'#{v}'")
            end
            filter.push( " (spec_id = #{temp.id}  and value in (#{val_temp.join(",")}) )" )
          rescue
          end
        end

    if !filter.empty? and item_condition_filter != ""
      item_condition_filter   += " and "
    end
  end

    item_where_condition = item_condition_filter
    #if we have prod then search inside it..
    #eg.. if the filter is applied in nokia..
    #search only in nokia..
    unless filter.empty?
      filter_size = filter.size
      filter =  (filter.size > 1) ? filter.join(" or ") : filter[0]
      item_where_condition =  item_where_condition + " p2p_items.id in ( select item_id from `p2p_item_specs`   where  ( " + filter + " )   group by(item_id) having count(*) = #{filter_size} ) "
    end
    #if search inside the product,, search so
    # or else search inside the category.

    items = @cat.items.by_location_or_allover(p2p_get_user_location).notsold.approved.where(  item_where_condition ).select('p2p_items.id,title,price,p2p_items.condition,product_id').order(order_result)

    #formt the output appropiatly,
    # required by view
    res = []
    items.each do |itm|
      url = itm.get_image(1,:search)[0][:url]
      temp_url = URI.encode("#{make_item_url(itm)}")
      prod_url = URI.encode("#{make_product_url(itm.product)}")
      prod = itm.product.name
      cat = itm.product.category.name
      cat_url = URI.encode("#{make_category_url(itm.category)}")
      itm = to_hash(itm)
      itm[:url] = temp_url
      itm[:img] = url
      itm[:title] =itm[:title].truncate(20)
      itm[:prod_url] = prod_url
      itm[:prod] = prod
      itm[:cat_url] = cat_url
      itm[:cat] = cat
      res.push(itm)
    end
    #if we are called byt ajax, send teh value alone,
    # else render the whole page witht the filtered items..
    if request.xhr?
      temp_result = res.paginate(:page => params[:page], :per_page => 20 )
      puts temp_result.next_page.to_s + "next page"
      render :json => {:res => temp_result , :next => ((temp_result.next_page.nil?) ? 0 : 1) ,:tme => @start_time }
      return
    else
      #redirect if items is empty meaning no items found for filters
      if res.count == 0
        redirect_to '/street'
        flash[:notice] = 'Nothing can be found for your request'
        return
      end
      @items = res
      return
    end
  end

  def get_city
    cities = P2p::City.where(" name like '%#{params[:q]}%' and 1=1").limit(15)
    resp = [];
    cities.each do |city|
      resp << { :label=> city.name, :value=>city.name}
    end
    render :text=> resp.to_json() and return
  end
end