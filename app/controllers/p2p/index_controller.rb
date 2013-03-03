require 'will_paginate/array'

class P2p::IndexController < ApplicationController

   #check for user presence inside p2p
   before_filter :check_p2p_user_presence


  layout :p2p_layout

  def index
    # @mobiles=P2p::Item.select("title,price").where('product_id=1').limit(4);
    # @electronics=P2p::Item.select("title,price").where('product_id=2').limit(4);
    
    # load the categories based on their priority
    @category = P2p::Category.order("priority")

  end

def search

  begin

    unless request.xhr?
     redirect_to '/p2p'
     flash[:notice] ="Invalid Request"
      return
    end


    response = get_search_suggestions(params[:id])

    if response.size == 0

        suggested_word = suggest(params['id'])

        if suggested_word == params[:id]


        result = P2p::Item.by_location_or_allover(p2p_get_user_location).notsold.approved.search(suggested_word ,:match_mode => :any ,:star => true)

        result.each do |res|
          response.push({:label=> "#{res.title}" ,:value => URI.encode("/p2p/#{res.product.category.name}/#{res.product.name}/#{res.title}") })
        end

      else
        response = get_search_suggestions(suggested_word)
      end 

    end

    response = response.first(15)
    

    if response.empty?
        render :json => [{:label => "No results found" ,:value => ""}]
        return
    else
        render :json => response
        return
    end

  # rescue 
  #   if request.xhr?
  #     render :json => []
  #     return
  #   else
      
  #     flash[:notice] = "Something went wrong"
  #     redirect_to '/p2p'
  #     return
  #   end
    
  end
end


def search_query
  @result = P2p::Item.by_location_or_allover(p2p_get_user_location).notsold.approved.order('product_id').search(params[:query] ,:match_mode => :any ,:star => true).paginate(:page => params[:page] ,:per_page => 20)
end


def get_search_suggestions(query)
  response =[{:label => query ,:value => URI.encode("/p2p/search/q/#{query}")}]

  result = P2p::Category.search(query ,:match_mode => :any ,:star => true)

  puts result.inspect + "fsad"

  result.each do |res|
    response.push( {:label => "#{query} in #{res.name}" , :value => URI.encode("/p2p/#{res.name}")} )
  end


  result = P2p::Product.search(query ,:match_mode => :any ,:star => true)

  result.each do |res|
    response.push({:label=> "#{query} in #{res.category.name} (#{res.items.count})" ,:value => URI.encode("/p2p/#{res.category.name}/#{res.name}")} ) if res.items.count >0
  end

  result = P2p::Item.by_location_or_allover(p2p_get_user_location).notsold.approved.search(query ,:match_mode => :any ,:star => true)

  result.each do |res|
    response.push({:label=> "#{res.title}" ,:value => URI.encode("/p2p/#{res.product.category.name}/#{res.product.name}/#{res.title}") })
  end
  return response

end  

def search_list

    res ={}


    #search for Category
    result = P2p::Category.search(params[:id])

    temp_res =[]

    unless result.empty?
        res["type"] ="cat"

        result.each do |r|

            cat = r.name

            items =  r.products[0].items.by_location_or_allover(p2p_get_user_location).select("id,title,price").limit(10)

            next if items.size == 0  

            temp_item =[]

            items.each do |itm|
              i = itm.get_image(1,:search)[0][:url]
              itm = itm.attributes
              itm[:image] = i
              temp_item.push(itm)

              
            end

            temp_res.push(:cat => cat , :items => temp_item )

        end 

          res["data"] = temp_res   
        

        render :json => res
        return
    end




    #search for product
    result = P2p::Product.search(params[:id])

    temp_res =[]

    unless result.empty?
        res["type"] ="pro"

        cat_done =[]

        result.each do |r|

            cat = r.category.name

            next  if cat_done.include?(r.category.id) 

            cat_done.push( r.category.id)

            #temp = r.items.select("id,title,price").search(params[:id])

            #puts r.inspect + " category "

            #if temp.size == 0
              items =  r.items.by_location_or_allover(p2p_get_user_location).select("id,title,price").limit(10)
#              puts temp.inspect + " selected "
 #           else
  #            items = temp
   #           puts temp.inspect + " selected "
#            end


            next if items.size == 0  

            temp_item =[]

            items.each do |itm|
              i = itm.get_image(1,:search)[0][:url]
              itm = itm.attributes
              itm[:image] = i
              temp_item.push(itm)

              
            end





            temp_res.push(:cat => cat , :items => temp_item )

        end 

          res["data"] = temp_res   
        

        render :json => res
        return
    end

    
    #search for items
    result = P2p::Item.by_location_or_allover(p2p_get_user_location).notsold.approved.select("title").search(params[:id] ,:star => true ,:match_mode => :any)

    unless result.empty?
        
      #   res["type"] ="redirect"
      #   res["data"] = "/p2p/view/" + result[0].id.to_s

      #   render :json => res
      #   return

      # end

        result.each do |r|
          r[:image] = r.get_image(1,:search)[0][:url]
        end

        res["type"] ="item"
        res["data"] = result

        render :json => res
        return
    end
    
    
    render :json => []



  end


   def search_cat
        @cat = P2p::Category.find_by_name(params[:cat])
        @cat_name = @cat.name

        if params.has_key?("prod")
          @products = @cat.products.find_all_by_name(params[:prod])
       else

         @products = @cat.products
        end
  end
  
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

    @cat = P2p::Category.find_by_name(params[:cat])

    if @cat.nil? or @cat.products.count == 0
      flash[:notice] ="Nothing found for your request"
      redirect_to "/p2p"
      return
    end


    if params.has_key?("prod") 
      @products=@cat.products.order("priority").find_all_by_name(params[:prod])

      if @products.nil?
        @cat = P2p::Category.find_by_name(params[:prod])
        @products= @cat.products.all.order("priority")
        params.delete("prod")
    
      end

    else
      @products=@cat.products.all

      if !@cat.subcategories.nil?
          @cat.subcategories.each do |cat|
            @products +=cat.products.order("priority")
          end
      end
    end

    
    @products

  end



  def browse_filter

    if params.has_key?(:applied_filters)
      if  request.xhr?
          render :json =>  []
          return
      end
    end

    @cat = P2p::Category.find_by_name(params[:cat])

    if @cat.nil?
      render :json => []
      return
    end

    filter =[]
    order_result = ""
    item_condition_filter = ""


    # check if we have filters already
    if params.has_key?(:applied_filters)
      
        spec= params[:applied_filters].split('&')
        (0..(spec.size() - 1 ) ).each do |i|
      
          begin
              spec[i] = spec[i].split('=')
          rescue
          end

        end

        params[:filter] = {}

        spec.each do |key,val|

          begin
            params[:filter][key] = val.split(',')
          rescue
          end

        end

        puts spec.inspect + " passed filter"

    end


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


        if params[:filter].has_key?("condition")

          temp = []
          params[:filter][:condition].each do |fil|
              temp.push("'" + fil + "'")
          end

          item_condition_filter = 'p2p_items.condition in (' + temp.join(",") + ") "


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

    end


    if !filter.empty? and item_condition_filter != ""
      item_condition_filter   += " and "
    end

    item_where_condition = item_condition_filter

    if params.has_key?(:prod) 
      @products=@cat.products.find_by_name(params[:prod])


      if filter.empty?

        if order_result != ""
          items = @products.items.by_location_or_allover(p2p_get_user_location).notsold.approved.select('p2p_items.id,title,price,p2p_items.condition,product_id').where(item_where_condition).order(order_result)
        else
          items = @products.items.by_location_or_allover(p2p_get_user_location).notsold.approved.select('p2p_items.id,title,price,p2p_items.condition,product_id').where(item_where_condition).order(order_result)
        end

      else

      filter_size = filter.size

      filter =  (filter.size > 1) ? filter.join(" or ") : filter[0]

          if order_result != ""
          items = @products.by_location_or_allover(p2p_get_user_location).items.notsold.approved.where( item_where_condition + " p2p_items.id in ( select item_id from `p2p_item_specs`   where  ( " + filter + " )   group by(item_id) having count(*) = #{filter_size} ) " ).select('p2p_items.id,title,price,p2p_items.condition,product_id').order(order_result)
        else
          items = @products.by_location_or_allover(p2p_get_user_location).items.notsold.approved.where( item_where_condition + " p2p_items.id in ( select item_id from `p2p_item_specs`   where  (" + filter + ")   group by(item_id) having count(*) = #{filter_size}  )"  ).select('p2p_items.id,title,price,p2p_items.condition,product_id')
        end

      end


      res = []

      items.each do |itm|
        url = itm.get_image(1,:search)[0][:url]
        temp_url = URI.encode("/p2p/#{itm.product.category.name}/#{itm.product.name}/#{itm.title}")
        
        prod_url = URI.encode("/p2p/#{itm.product.category.name}/#{itm.product.name}")
        prod = itm.product.name

        cat = itm.product.category.name
        cat_url = URI.encode("/p2p/#{itm.product.category.name}")

        itm = to_hash(itm)
        itm[:url] = temp_url
        itm[:img] = url
        
        itm[:prod_url] = prod_url
        itm[:prod] = prod

        itm[:cat_url] = cat_url
        itm[:cat] = cat

        res.push(itm)
      end

      if request.xhr?
        temp_result = res.paginate(:page => params[:page], :per_page => 20 )
        puts temp_result.next_page.to_s + "next page"
        render :json => {:res => temp_result , :next => ((temp_result.next_page.nil?) ? 0 : 1) }
        return
      else

          #redirect if items is empty meaning noting found for filters
        if res.count == 0
          redirect_to '/p2p'
          flash[:notice] = 'Nothing can be found for your request'
          return
        end

        @items = res
        return
      end


    else

      if filter.empty?

        if order_result !=""
          items = @cat.items.by_location_or_allover(p2p_get_user_location).notsold.approved.select('p2p_items.id,title,price,p2p_items.condition,product_id').where(item_where_condition).order(order_result)
        else
          items = @cat.items.by_location_or_allover(p2p_get_user_location).notsold.approved.select('p2p_items.id,title,price,p2p_items.condition,product_id').where(item_where_condition)
        end

      else

      filter_size = filter.size
      
      filter =  (filter.size > 1) ? filter.join(" or ") : filter[0]

      if order_result !=""
        items = @cat.items.by_location_or_allover(p2p_get_user_location).notsold.approved.where( item_where_condition + "p2p_items.id in ( select item_id from `p2p_item_specs`  where (" + filter + ")   group by(item_id) having count(*) = #{filter_size} ) " ).select('p2p_items.id,title,price,p2p_items.condition,product_id').order(order_result)
      else
        items = @cat.items.by_location_or_allover(p2p_get_user_location).notsold.approved.where( item_where_condition + "p2p_items.id in ( select item_id from `p2p_item_specs`  where (" + filter + ")    group by(item_id) having count(*) = #{filter_size}) " ).select('p2p_items.id,title,price,p2p_items.condition,product_id')
      end

      end


      res = []

      items.each do |itm|
        url = itm.get_image(1,:search)[0][:url]
        temp_url = URI.encode("/p2p/#{itm.product.category.name}/#{itm.product.name}/#{itm.title}")
        
        prod_url = URI.encode("/p2p/#{itm.product.category.name}/#{itm.product.name}")
        prod = itm.product.name

        cat = itm.product.category.name
        cat_url = URI.encode("/p2p/#{itm.product.category.name}")

        itm = to_hash(itm)
        itm[:url] = temp_url
        itm[:img] = url
        
        itm[:prod_url] = prod_url
        itm[:prod] = prod

        itm[:cat_url] = cat_url
        itm[:cat] = cat

        res.push(itm)
      end
      
      if request.xhr?
        temp_result = res.paginate(:page => params[:page], :per_page => 20 )
        render :json => {:res => temp_result , :next => ((temp_result.next_page.nil?) ? 0 : 1) }
        return
      else

        if res.nil? 
          #redirect if items is empty meaning noting found for filters
          redirect_to '/p2p'
          flash[:notice] = 'Nothing can be found for your request'
          return
        end

        @items = res
        return
      end

    end

  end

 end