// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require global/jquery.ui.core.js
//= require global/jquery.ui.widget.js
//= require global/jquery.ui.position.js
//= require ./underscore.js
//= require ./backbone
//= require ./jquery.sticky
//= require ./jquery.ui.dialog.js
//= require ./jquery.ui.tabs
//= require ./jquery.validate.min
//= require ./chosen.jquery
//= require ./jquery.sticky
//= require ./jquery.typewatch
//= require ./bootstrap.min
//= require ./jquery.nivo.slider.pack

$(document).ready(function(){
	$("#resources_button").click(function(){
		$("#resources_dialog").dialog("open");
	});

	$("#static_page_dialog").dialog({
		autoOpen: false,
		draggable: false,
		height: 700,
		width: 1100,
		resizable: false,
    modal: true
	});

	$(".static_page_dialog_open").click(function(){
		current = $(this).attr("href");
		// page=current.replace("_"," ")
		// page=page.slice(1).toUpperCase()

		$("#static_page_dialog").dialog('option','title',$(current).attr('title'))
		$("#static_page_dialog .sub").hide();
		$(current).show();
		$("#static_page_dialog").dialog("open");
		return false;
	});
	$("#university_dialog").dialog({
			autoOpen: false,
			title:'Universities',
			draggable: false,
			dialogClass: 'user_dialog',
			height: 500,
			width: 1000,
			resizable: false,
      modal: true
	});
	$(".open_university").click(function(){
			$("#university_dialog").dialog("open");
	});
	if($("#page_not_found").html().trim()!="")
		$("#page_not_found").fadeIn(1000).delay(5000).fadeOut(300);
	$(".rails_notice").delay(5000).fadeOut(300);


	//start router on page load
	if (/^book\/\d{13}/i.test(window.location.hash.substr(1)) ){

	  	$.ajax( {
	  		url:"/" + window.location.hash.substr(1),
	  		dataType:"json",
	  		success:function(data){
				sociorent.collections.search_object.reset(data);
				sociorent.fn.renderSearch();
				$(".search_books_single").trigger("click");
			}
		});
	 }

  });



