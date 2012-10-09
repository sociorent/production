$(document).ready ->
	sociorent.views.app = Backbone.View.extend
		el: 'body'

		initialize: ->
			# search collection
			sociorent.collections.search_object = new sociorent.collections.search()
			# cart collection
			sociorent.collections.cart_object = new sociorent.collections.cart()
			# compare collection
			sociorent.collections.compare_object = new sociorent.collections.compare()
		
		events:
			"submit #search_books_form"	: "cancel_submit"
			"focus #search_books_input" : "expand_search"
			"click #close_search_books" : "shrink_search"
			"submit #request_form" : "make_request"
			"click #cart_button" : "open_cart_dialog"
			"click #cart_options_left" : "close_cart_dialog"
			"click #cart_options_right" : "checkout"
			"click .create_order" : "create_order"
			"click #compare_close" : "compare_close"
			"click #compare_dialog_button" : "compare_dialog"

		cancel_submit: ->
			false

		expand_search: ->
			$("#content .left").stop().animate
				width: "49%"
			, 300
			$("#content .right").stop().animate
				width: "50%"
			, 300
			$("#close_search_books").show()

		shrink_search: ->
			$("#content .left").animate
				width: "69%"
			, 300
			$("#content .right").animate
				width: "30%"
			, 300
			$("#close_search_books").hide()

		make_request: ->
			if $.trim($("#request_title").val()) == ""
				$("#request_error").html "Please specify the book title."
				false
			else if ($.trim($("#request_author").val()) == "" && $.trim($("#request_isbn").val()) == "")
				$("#request_error").html "Please specify either the author name or isbn or both."
				false
			else
				$.ajax "/home/book_request" ,
					type: "post" 
					async: true
					data: 
						title: $("#request_title").val()
						author: $("#request_author").val()
						isbn: $("#request_isbn").val()
					success: (msg)->
						$("#request_error").html msg
						$("#request_form").animate({height: "0px"}, 300).html ""
			false

		open_cart_dialog: ->
			$("#cart_box").dialog("open")

		close_cart_dialog: ->
			$("#cart_box").dialog("close")

		checkout: ->
			$("#cart_box").dialog("close")
			$("#checkout_box").dialog("open")

		create_order: ->
			$.ajax "/orders/create" ,
				type:"post"
				async:true
				success: (msg)->
					$("#checkout_box").dialog "close"
					$("#order_box").dialog "open"
					$("#order_id span").html msg.random
					sociorent.collections.cart_object.reset()
					sociorent.fn.renderSearch()
					sociorent.fn.renderCart()

		compare_close: ->
			$("#compare_box").fadeOut(300)

		compare_dialog: ->
			$("#compare_dialog").dialog "open"
		
	sociorent.views.app_object = new sociorent.views.app()