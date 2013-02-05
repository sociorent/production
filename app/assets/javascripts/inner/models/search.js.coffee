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