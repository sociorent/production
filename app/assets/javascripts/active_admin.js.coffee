#= require active_admin/base
$ ->
	$(".view_description").click ->
		console.log "Description"
		opt = 
			title: "Details"
			width: 600
			height: 600
		desc_id = $(this).attr("show-desc");
		$('#myModal').html($("#"+desc_id).val());
		$('#myModal').dialog(opt).dialog("open")