sociorent.collections.cart = Backbone.Collection.extend
	model: sociorent.models.cart

	initialize: ->
		@on "add", (model)->
			# listen to add to cart
			$("#cart_button .cart_button_count").html @models.length
			$("#no_item_in_cart").hide()
			$("#cart_hide_on_no_item").show()
			$("#cart_deposit_total span").html sociorent.fn.calculate_cart_deposit_total()
			$("#cart_rental_total span").html sociorent.fn.calculate_cart_rental_total()
			$("#cart_refundable_amount span").html(sociorent.fn.calculate_cart_deposit_total() - sociorent.fn.calculate_cart_rental_total())
			$("#cart_total span").html(sociorent.fn.calculate_cart_deposit_total() + sociorent.shipping_charge)
			$("#cart_button_total_left span").html(sociorent.fn.calculate_cart_deposit_total() + sociorent.shipping_charge)
			$("#cart_header").show()
			# trigger that something has been added to cart
			sociorent.app_events.trigger "added_to_cart", model.id

		@on "remove", (model)->
			# listen to remove from cart
			$("#cart_button .cart_button_count").html @models.length
			if @models.length == 0
				$("#no_item_in_cart").show()
				$("#cart_hide_on_no_item").hide()
				$("#cart_header").hide()
			$("#cart_deposit_total span").html sociorent.fn.calculate_cart_deposit_total()
			$("#cart_rental_total span").html sociorent.fn.calculate_cart_rental_total()
			$("#cart_refundable_amount span").html(sociorent.fn.calculate_cart_deposit_total() - sociorent.fn.calculate_cart_rental_total())
			$("#cart_total span").html(sociorent.fn.calculate_cart_deposit_total() + sociorent.shipping_charge)
			$("#cart_button_total_left span").html(sociorent.fn.calculate_cart_deposit_total() + sociorent.shipping_charge)
			# trigger that something has been removed from cart
			sociorent.app_events.trigger "removed_from_cart", model.id
  
		@on "reset", ()->
			# listen to reset of cart
			$("#cart_button .cart_button_count").html @models.length
			if @models.length == 0
				$("#no_item_in_cart").show()
				$("#cart_hide_on_no_item").hide()
				$("#cart_header").hide()
			$("#cart_deposit_total span").html sociorent.fn.calculate_cart_deposit_total()
			$("#cart_rental_total span").html sociorent.fn.calculate_cart_rental_total()
			$("#cart_refundable_amount span").html(sociorent.fn.calculate_cart_deposit_total() - sociorent.fn.calculate_cart_rental_total())
			$("#cart_total span").html(sociorent.fn.calculate_cart_deposit_total() + sociorent.shipping_charge)
			$("#cart_button_total_left span").html(sociorent.fn.calculate_cart_deposit_total() + sociorent.shipping_charge)

sociorent.fn.calculate_cart_deposit_total = ()->
	total = 0
	_.each sociorent.collections.cart_object.models, (model)->
		total += parseInt(model.get("price"))
	if total < 1000 && total != 0
		sociorent.shipping_charge = 50
		$("#shipping_charge span").html 50
	else
		sociorent.shipping_charge = 0
		$("#shipping_charge span").html 0
	total

sociorent.fn.calculate_cart_rental_total = ()->
	total = 0
	_.each sociorent.collections.cart_object.models, (model)->
		rental = (parseInt(model.get("price")*model.get("publisher").rental)/100).toFixed(0)
		total += parseInt(rental)
	total