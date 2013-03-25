class Street::MobileController < ApplicationController

	  def get_city
	    cities = P2p::City.all
	    resp = [];
	    cities.each do |city|
	      resp.push city.name
	    end

	    	render :text=> resp.to_json() and return
		end

		def recent_items

			resp =[]

			begin

					if params.has_key?(:query)
						items = P2p::Item.search(params[:query] ,:match_mode => :any ,:star => true ,:order => :created_at , :sort_mode => :desc ,:cutoff => 15)

						#if no item found check spelling and find items again
						if items.count ==0 

							query_word  = params[:query]

						    speller = Aspell.new("en_US")
						    speller.suggestion_mode = Aspell::ULTRA
						    query_word.split(" ").each do |word|
						      if !speller.check(word)
						        query_word.gsub! word , speller.suggest(word).first
						      end
						    end

						    items = P2p::Item.search(query_word ,:match_mode => :any ,:star => true ,:order => :created_at , :sort_mode => :desc ,:cutoff => 15 )

						    # if still no items found render nothing
						    if items.count ==0 
						    	render :json => {}
						    	return
						    end
						end

					elsif params.has_key?(:prod)
						cat = P2p::Category.find_by_name(params[:cat].gsub(/-/," "))
						prod = cat.products.find_by_name(params[:prod].gsub(/-/," "))
						items = prod.items.active_items.order('created_at desc').limit(10)
					elsif params.has_key?(:cat)
						items = P2p::Category.find_by_name(params[:cat].gsub(/-/," ")).items.active_items.order('created_at desc').limit(10)
					else
						items = P2p::Item.active_items.order('created_at desc').limit(10)
					end

					items.each do |item|
							resp.push({:id => item.id,
													:title => item.title,
													:condition => item.condition,
													:price => item.price,
													:product_id => item.product.id,
													:url => URI.encode("http://#{request.env['HTTP_HOST']}/street/mob/#{item.product.category.name.gsub(/ /,"-")}/#{item.product.name.gsub(/ /,"-")}/#{item.title.gsub(/ /,"-")}/#{item.id}"),
													:prod_url =>URI.encode("http://#{request.env['HTTP_HOST']}/street/mob/recentitems/#{item.product.category.name.gsub(/ /,"-")}/#{item.product.name.gsub(/ /,"-")}"),
													:prod => item.product.name,
													:cat_url => URI.encode("http://#{request.env['HTTP_HOST']}/street/mob/recentitems/#{item.product.category.name.gsub(/ /,"-")}"),
													:cat => item.category.name,
													:view_count => item.viewcount,
													:img => URI.encode("http://#{request.env['HTTP_HOST']}#{item.get_image(0,:thumb)[0][:url]}")
												})
					end
				end

					render :json => resp

		end

		def view_item
				resp =[]

			    begin
			      cat =  P2p::Category.find_by_name(params[:cat].gsub(/-/," "))
			      prod=  cat.products.find_by_name(params[:prod].gsub(/-/," "))

		        item = prod.items.active_items.find(params[:id])

			      raise "Nothing found" if   item.nil? 

			      resp={ :id=> item.id,
			      				:title => item.title,
			      				:price => item.price,
			      				:condition => item.condition,
			      				:product_id => prod.id,
			      				:desc => URI.decode(item.desc).html_safe,
			      				:img => URI.encode("http://#{request.env['HTTP_HOST']}#{item.get_image(0,:view)[0][:url]}"),
			      				:specs => {}
			       }

			       item.specs.each do |spec|
			       		resp[:specs][spec.spec.name.to_sym] = spec.value
			       end

			       render :json => resp
			     rescue
			     	 render :json => resp
			    end
		end

end
