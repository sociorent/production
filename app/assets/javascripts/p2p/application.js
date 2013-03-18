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
//= require jquery.ui.core
//= require jquery.ui.widget
//= require jquery.ui.position
//= require jquery.ui.autocomplete
//= require jquery.ui.datepicker
//= require jquery_nested_form
//= require jquery-fileupload
//= require p2p/jquery.notify
//= require p2p/jquery.fancybox-1.3.4
//= require global/underscore
//= require bootstrap
//= require bootstrap-editable
//= require bootstrap-editable-rails
//= require global/wysihtml5-0.3.0.min
//= require global/bootstrap-wysihtml5-0.0.2.min
//= require global/wysihtml5
//= require p2p/select2
//= require private_pub
//= require p2p/jquery.history
//= require p2p/jqplot.min
//= require p2p/jqplot.barRenderer.min
//= require p2p/jqplot.pointLabels
//= require p2p/jqplot.pieRenderer.min
//= require p2p/jqplot.canvasAxisLabelRenderer.min
//= require p2p/jqplot.canvasTextRenderer.min
//= require p2p/jqplot.canvasAxisTickRenderer.min
//= require p2p/jqplot.categoryAxisRenderer.min
//= require p2p/jquery-scrolltofixed-min
//= require p2p/search
//= require p2p/category_menu
//= require global/chosen.jquery
//= require global/jstorage.min
//= require ckeditor-jquery
// require_tree .


$(document).ready(function(){
//	$(".action_icon").tooltip();
  $(".datepicker").datepicker();
	$("#head_user_location").click(function(){
		$("#location_modal").modal('show');
	});
	if($("#user_city").val()!=""){
		$("#user_location").val($("#user_city").val());
	}

	$("#user_location").change(function(){

		$.ajax({
			url:'/p2p/location',
			type:'post',
			data:{location:$("#user_location :selected").val()},
			dataType:'json',
			success:function(data){
				if (data.status == 1){
					window.location.reload();
					$("#user_location").val(data.location);
					$("#head_user_location i").attr('title',$("#user_location :selected").text()).tooltip('destroy').tooltip();
				}
				else if(data.status == 2){
					$("#head_user_location i").attr('title','Error occured in setting your location').tooltip('destroy').tooltip('show');
				}
			},
			error:function(){
				$("#head_user_location i").attr('title','Error occured in setting your location').tooltip('destroy').tooltip('show');
			}
		});
		return false;
	});


	// //guess location of user if not set
	// if ($("#user_location").val() == ''){
	// 	$.ajax({
	// 		url:'/p2p/guesslocation',
	// 		type:'post',
	// 		dataType:'json',
	// 		success:function(data){
	// 			if (data.status == 1){
	// 				window.location.reload();
	// 				$("#user_location").val(data.location);
	// 				$("#head_user_location i").attr('title',$("#user_location :selected").text()).tooltip('destroy').tooltip();
	// 			}
	// 			else if(data.status == 2){
	// 				$("#head_user_location").css('background-color','red');
	// 				$("#head_user_location i").addClass('icon-white');
	// 				$("#head_user_location i").attr('title','Error occured in setting your location').tooltip('destroy').tooltip('show');
	// 			}
	// 		},
	// 		error:function(){
	// 			$("#head_user_location").css('background-color','red');
	// 			$("#head_user_location i").addClass('icon-white');
	// 			$("#head_user_location i").attr('title','Error occured in setting your location').tooltip('destroy').tooltip('show');
	// 		}
	// 	});



// JS code for Dash board > Static page
$("#static_page_page_name").live("change", function(){
	$.getJSON("/static_pages/get_page/"+this.value , function(data){
		$(".page_title").val(data.page_title);
		for (instance in CKEDITOR.instances){
      CKEDITOR.instances[instance].setData(data.page_content);
    }
    $(".edit_static_page").attr("action","/static_pages/"+data.id);
    $(".edit_static_page").attr("id","edit_static_page_"+data.id);
	});
});


// Code for Job html

$("#start_background").click(function(){
	$.jStorage.set("background", "1");
	$.jStorage.setTTL("background", 15000); // expires in 3 seconds
});

});