window.sociorent = window.sociorent || {fn: {}, models: {}, collections: {}, views: {}, app_events: {}}
_.extend sociorent.app_events, Backbone.Events

$(document).ready ->	

	sociorent.fn.renderSearch = ()->
		$("#search_books").hide().html ""
		if sociorent.collections.search_object.models.length > 0
			_.each sociorent.collections.search_object.models, (model)->
				view = new sociorent.views.search
					model: model
				$("#search_books").append view.render().el
				if sociorent.collections.compare_object.get model.id
					$(view.render().el).find(".add_to_compare").attr
						checked: true
			# highlight found value
			val = $("#search_books_input_hidden").val()
			unless $.trim(val) == ""
				$("#search_books .name, #search_books .isbn, #search_books .author").highlight(val)
			$("#no_search_result").hide()
		else 
			$("#no_search_result").show()
		$("#search_books").stop().fadeIn(300)

	sociorent.fn.renderCompareSearch = ()->
		$("#compare_search_result").hide().html ""
		if sociorent.collections.compare_search_object.models.length > 0
			_.each sociorent.collections.compare_search_object.models, (model)->
				view = new sociorent.views.compare_search
					model: model
				$("#compare_search_result").append view.render().el
				$("#compare_search_result").show()
			$("#compare_search_no_result").hide()
		else 
			$("#compare_search_no_result").show()

	sociorent.fn.renderCart = ()->
		$("#cart").html ""
		_.each sociorent.collections.cart_object.models, (model)->
			view = new sociorent.views.cart
				model: model
			$("#cart").append view.render().el

	sociorent.fn.renderCompare = ()->
		$("#compare").html ""
		unless sociorent.collections.compare_object.models.length == 0
			_.each sociorent.collections.compare_object.models, (model)->
				view = new sociorent.views.compare
					model: model
				$("#compare").append view.render().el
		else
			$("#compare").html "<div class='no_compare_book'>There are no books to compare.</div>"
			$("#compare_box").delay(1500)
			sociorent.fn.hide_compare()

	sociorent.fn.show_compare = ()->
		$("#compare_box").fadeIn 500

	sociorent.fn.hide_compare = ()->
		$("#compare_box").fadeOut 500
	
	sociorent.fn.search = ()->
		sociorent.load_more = 0
		$.ajax "/search" , 
			type:"post"
			async:true
			data:
				query: $("#search_books_input").val()
			success: (msg)->
				if msg.suggestion != ''
					$("#search_books_input_hidden").val(msg.suggestion)
				# reset the search collections
				if msg.load_more
					$("#load_more").show()
				else
					$("#load_more").hide()
				sociorent.collections.search_object.reset($.parseJSON(msg.books))
				sociorent.fn.renderSearch()


	options =
	  callback: -> 
	  	sociorent.fn.search()
	  wait: 500
	  highlight: true
	  captureLength: 0

	$("#search_books_input").typeWatch options


	# searching for books within compare
	compare_search = ()->
		$.ajax "/search" , 
			type:"post"
			async:true
			data:
				query: $("#compare_search_input").val()
			success: (msg)->
				# reset the compare search collections
				sociorent.collections.compare_search_object.reset $.parseJSON(msg.books)
				sociorent.fn.renderCompareSearch()


	options =
	  callback: -> 
	  	compare_search()
	  wait: 500
	  highlight: true
	  captureLength: 2

	# $("#compare_search_input").typeWatch options
	sociorent.allow_ajax = true
	$("#compare_search_input").keypress ->
		if sociorent.allow_ajax
			compare_search()
			sociorent.allow_ajax = false
			setTimeout(()->
				sociorent.allow_ajax = true
			, 50)

	sociorent.fn.getUserOrderedBooks = ()->
		books = new Array()
		_.each sociorent.collections.order_object.models, (model)->
			_.each model.get("books"), (book)->
				books.push book.id
		_.uniq books


	$(".apply_intership").click ->
		that = this
		c = confirm("Are you sure?")
		if c
			company_id = this.id.replace("company_", "")
			$.ajax "/home/apply_intership"
				type:"post"
				async:true
				data:
					company_id: company_id
				success: (msg)->
					$(that).hide().html ""
					alert("You have successfully applied for intership.")
		false
	$(".print_invoice a").live "click", ->
		$(this).attr("href","/print_invoice/"+$(this).attr("data-attr"))
	
	$("#verify_mobile_div").hide()

	sociorent.fn.save_order = (post_data,order_type) ->
		$("#checkout_box_content").hide()
		$("#checkout_box_response").html "<div class='center'> Order processing...</div>"
		sociorent.fn.show_notification()
		$.ajax "/orders/create" ,
			type:"post"
			async:true
			data: post_data
			success: (msg)->
				sociorent.fn.hide_notification()
				$("#checkout_box").dialog "close"
				$("#order_box").dialog "open"
				$("#order_id span").html msg.random
				$(".print_invoice a").attr("data-attr",msg.random)
				$(".print_invoice").show()
				if order_type=="COD"
					$("#cash_on_delivery").show()
					$("#cash_on_delivery span").html msg.deposit_total
					$("#order_bank_cheque").hide()
				else
					$("#order_bank_cheque").show()
					$("#cash_on_delivery").hide()

				sociorent.collections.order_object.add(msg)
				sociorent.collections.cart_object.reset()
				sociorent.fn.renderSearch()
				sociorent.fn.renderCart()
				$("#profile_orders_button").click()
				$("#checkout_box_content").show()
				$("#checkout_box_response").html ""
	sociorent.fn.shipping_validation = (id)->
		$("#"+id).validate
			rules:
				address_street_name1:
					minlength: 2
					required: true

				address_city:
					minlength: 2
					required: true

				address_state:
					required: true

				address_pincode:
					required: true
					digits: true
					minlength:6
			highlight: (label) ->
				$(label).closest(".control-group").addClass "error"
			focusCleanup: true,
			success : (label) ->
				$(label).closest(".control-group").removeClass "error"
			validClass: "success"
			messages :
				address_pincode: "Please enter correct pincode"
	sociorent.fn.shipping_validation("shipping_form")

	sociorent.fn.show_notification = ()->
		$("#notification").fadeIn 100

	sociorent.fn.hide_notification = ()->
		$("#notification").fadeOut 100