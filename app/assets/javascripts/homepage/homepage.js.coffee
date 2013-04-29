window.sociorent = window.sociorent || {fn: {}, models: {}, collections: {}, views: {}}

$(document).ready ->

	# backbone model
	sociorent.models.search = Backbone.Model.extend
		initialize: ->
			publisher = @get("publisher")
			rental = 0
			if publisher
				publisher.rental = publisher.rental || 25
			else
				publisher = new Object()
				publisher.rental = 25
				@set
					publisher: publisher

	# backbone collection
	sociorent.collections.search = Backbone.Collection.extend
		model: sociorent.models.search

	# backbone view for  search
	sociorent.views.search = Backbone.View.extend
		tagName: "div"
		className: "search_books_single"

		template: _.template $("#search_template").html()

		initialize: ->
			_.bindAll this, 'render'
			that = this

		events:
			"click .add_to_cart" : "add_to_cart"
			"click" : "view_book_info"

		view_book_info: ->
			that = this
			$("#book_details").html ""
			view = new sociorent.views.book_details
				model: @model
			$("#book_details").append view.render().el
			$(view.el).find(".timeago").timeago()


			#add has for the url

			window.location.hash = "book/" + @model.get "isbn13"

			# update authors in book details
			author = @model.get "author"
			author_array = author.split ","
			_.each author_array, (author)->
				$(view.el).find(".author_names").append "<a href='#' class='author_name'>" + author + "</a><br/>"
			$.ajax "/home/get_adoption_rate" ,
				type:"post"
				async:true
				data:
					book: that.model.id
				success: (msg)->
					sociorent.collections.review_object.reset msg[0]
					sociorent.collections.review_object.sort({silent: true})
					_.each sociorent.collections.review_object.models, (model)->
						view = new sociorent.views.review
							model: model
						$(".reviews_content").append view.render().el
			$("#book_details").dialog "open"

		add_to_cart: ->
			that = this
			$.ajax "/home/add_to_cart" ,
				type:"post"
				async:true
				data:
					book: that.model.id
				success: (msg)->
					$("#login_box").dialog("open");
			false

		render: ->
			image = @model.get("book_image")
			original_image = @model.get("book_original")
			$(@el).html @template
				id: @model.id
				image: image
				original_image: original_image
				name: @model.get "name"
				author: @model.get "author"
				isbn: @model.get "isbn10"
				cart_message: "Add to Cart"
				mrp: Math.ceil((@model.get "price"))
				rent_price: Math.ceil((@model.get("price") * @model.get("publisher").rental)/100)
			this

	#backbone view for Book details
	sociorent.views.book_details = Backbone.View.extend
		tagName: "div"
		className: "book_details"
		template: _.template $("#book_details_template").html()
		initialize: ->
			_.bindAll this, 'render'

		events:
			"click .add_to_cart" : "add_to_cart"
			"click .author_names a" : "search_author"

		render: ->
			$(@el).html @template(@model.toJSON())
			this

		add_to_cart: ->
			that = this
			$.ajax "/home/add_to_cart" ,
				type:"post"
				async:true
				data:
					book: that.model.id
				success: (msg)->
					$("#login_box").dialog("open");
			false

		search_author: (ev)->
			author = $.trim $(ev.target).html()
			$("#book_details").dialog("close")
			$("#search_books_input").val(author)
			search()
			false

	# Backbone for reviews
	sociorent.models.review = Backbone.Model.extend()

	sociorent.collections.review = Backbone.Collection.extend
		model: sociorent.models.review

		initialize: ->
			@on "reset", ()->
				if @models.length == 0
					$(".reviews_content").html "<div>No reviews are made yet.</div>"

		comparator: (model)->
			-model.id

	sociorent.views.review = Backbone.View.extend

		template: _.template $("#review_template").html()

		initialize: ->
			_.bindAll this, 'render'

		render: ->
			$(@el).html @template(@model.toJSON())
			this

	sociorent.collections.review_object = new sociorent.collections.review()



	# render all search result
	sociorent.fn.renderSearch = ()->
		$("#search_books").html ""
		if sociorent.collections.search_object.models.length > 0
			_.each sociorent.collections.search_object.models, (model)->
				view = new sociorent.views.search
					model: model
				$("#search_books").append view.render().el
			# highlight found value
			val = $("#search_books_input_hidden").val()
			unless $.trim(val) == ""
				$("#search_books .name, #search_books .isbn, #search_books .author").highlight(val)
			$("#no_search_result").hide()
		else
			$("#search_books").append "<div id='no_search_result_caption'>No books found.</div>"
			$("#no_search_result").show()
		$("#search_books").stop().fadeIn(500)
		$("#searchClose").show()

	# initialize collection
	sociorent.collections.search_object = new sociorent.collections.search()

	# search ajax request
	search = ()->
		$.ajax "/search" ,
			type:"post"
			async:true
			data:
				query: $("#search_books_input").val()
			success: (msg)->
				if msg.suggestion != ''
					$("#search_books_input_hidden").val(msg.suggestion)
				# reset the search collections
				sociorent.collections.search_object.reset($.parseJSON(msg.books))
				sociorent.fn.renderSearch()

	# type watch plugin for search box
	options =
	  callback: ->
	  	search()
	  wait: 200
	  highlight: true
	  captureLength: 2

	$("#search_books_input").typeWatch options

	$("#search").submit ->
		search()
		false

	$("#searchClose").click ->
		$("#search_books").fadeOut 200
		$(this).hide()

	$("#search_books_input").live "focus", ->
		$("#search_books").show()
		if $(this).val().length >=2
			$("#searchClose").show()

	$(".open_login_popup").live "click", ->
		$("#book_details").dialog "close"
		$("#login_box").dialog "open"

	$("a[href='/users/sign_in']").hide()
	$("#devise_pages a").click ->
		action = $(this).text()
		$("#login_box").dialog('option','title',action)
		switch(action)
			when "Login"
				$("#login_box_left .boxes").slideUp 0
				$("#login_box_left_login").slideDown 200
			when "Sign Up"
				$("#login_box_left .boxes").slideUp 0
				$("#login_box_left_signup").slideDown 200
			when "Forgot Password?"
				$("#login_box_left .boxes").slideUp 0
				$("#login_box_left_password").slideDown 200
		$("#devise_pages a").css("display","none")
		$("#devise_pages a").each (ele) ->
			if $(this).text() != action
				$(this).show()
		false