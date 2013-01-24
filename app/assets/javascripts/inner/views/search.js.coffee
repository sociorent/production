$(document).ready ->
	sociorent.views.search = Backbone.View.extend
		tagName: "div"
		className: "search_books_single"

		template: _.template $("#search_template").html()

		initialize: ->
			_.bindAll this, 'render', 'add_to_cart', 'details'

			that = this
			sociorent.app_events.bind "added_to_cart", (id)->
				if that.model.id == id
					# when this model is added to cart
					that.$(".add_to_cart").html("Added to Cart").css
						background: "#0F8159"
						cursor: 'default'

			sociorent.app_events.bind "removed_from_cart", (id)->
				if that.model.id == id
					# when this model is removed from cart
					that.$(".add_to_cart").html("Add to Cart").css
						background: "#F65757"
						cursor: 'pointer'

			sociorent.app_events.bind "added_to_compare", (id)->
				if that.model.id == id
					# when this model is added to compare
					that.$(".add_to_compare").attr
						checked: true

			sociorent.app_events.bind "removed_from_compare", (id)->
				if that.model.id == id
					# when this model is removed from compare
					that.$(".add_to_compare").attr
						checked: false

		events:
			"click .add_to_cart" : "add_to_cart"
			"change .add_to_compare": "add_to_compare"
			"click" : "details"

		add_to_cart: ->
			if sociorent.collections.cart_object.get(@model.id)
				false
			else
				sociorent.fn.show_notification()
				that = this
				$.ajax "/home/add_to_cart" ,
					type:"post"
					async:true
					data: 
						book: that.model.id 
					success: (msg)->
						sociorent.fn.hide_notification()
						sociorent.collections.cart_object.add msg
						sociorent.fn.renderCart()
			false

		add_to_compare: (ev)->
			checkbox = $(ev.target)
			unless checkbox.attr "checked"
				sociorent.collections.compare_object.remove @model.id
			else
				sociorent.collections.compare_object.add @model.attributes
			sociorent.fn.renderCompare()
			sociorent.fn.show_compare()

		details: (ev)->
			that = this
			unless $(ev.target).parent().attr("class") == "add_to_compare_box"
				view = new sociorent.views.book_details
					model: @model
				$("#book_details_box").html view.render().el
				$(view.el).find(".timeago").timeago()
				if sociorent.collections.cart_object.get(@model.id)
					$(".book_details .add_to_cart").html "In Your Cart"
				$("#book_details_box").scrollTop("0px")
				$("#book_details_box").dialog("open")

				#add has for the url

				window.location.hash = "book/" + @model.get "isbn13"

				# update authors in book details
				author = @model.get "author"
				author_array = author.split ","
				_.each author_array, (author)->
					$(view.el).find(".author_names").append "<a href='#' class='author_name'>" + author + "</a><br/>"
				sociorent.fn.show_notification()
				$.ajax "/home/get_adoption_rate" ,
					type:"post"
					async:true
					data:
						book: that.model.id
					success: (msg)->
						sociorent.fn.hide_notification()

						# show reviews
						sociorent.collections.review_object.reset msg[0]
						sociorent.collections.review_object.sort({silent: true})
						_.each sociorent.collections.review_object.models, (model)->
							view = new sociorent.views.review
								model: model
							$(".reviews_content").append view.render().el
						# show class adoption rate
						sociorent.collections.class_adoption_object.reset msg[1]
						rate_sum = _.reduce sociorent.collections.class_adoption_object.models, (rate_sum, model)->
							model.get("rate") + rate_sum 
						, 0


		render: ->
			image = @model.get("book_image")
			original_image = @model.get("book_original")
			rented_message = ""
			if sociorent.collections.cart_object.get(@model.id)
				cart_message = "In Your Cart"
			else if _.indexOf(sociorent.fn.getUserOrderedBooks(), @model.id) > -1
				cart_message = "Add to Cart"
				rented_message = "you have already rented this book"
			else
				cart_message = "Add to Cart"
			$(@el).html @template
				id: @model.id
				image: image
				original_image: original_image
				name: @model.get "name"
				author: @model.get "author"
				mrp: Math.ceil(@model.get "price")
				rent_price: Math.ceil((@model.get("price") * @model.get("publisher").rental)/100)
				cart_message: cart_message
				rented_message: rented_message
			if sociorent.collections.cart_object.get(@model.id)
				@$(".add_to_cart").css
					background: "#0F8159"
					cursor: 'default'
			this