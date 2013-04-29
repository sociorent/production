

$(document).ready(function(){

	//trigger the upload on the file input when click on the div
	$('#upload_image').click(function(){
     $('#image_upload').trigger('click');
	});

	$('#upload_pic').click(function(){
     $('#image_upload').trigger('click');
	});


	// edit new js

		// cancel edit function trigger
	// #TODO: CHECK IF THE FORM IS CHANGED OR NOT AND REDIRECT ACCORDINGLY
	$("#cancel_top").on('click',function(){
			window.location.reload();
	});

	$("#cancel_bottom").on('click',function(){
			window.location.reload();
	});

	//remove image funciton
	$(".remove_image").click(function(){

		if (window.image_count == 1  ){
			showNotifications('Add more images to delete.');
			return false;
		}

		if ( (window.image_count - $("#image_upload")[0].files.length) <= 1  ){
			showNotifications('Save the new images first to delete this image.');
			return false;
		}


		var that = $(this);

		show_div_overlay(that.siblings('a'));

		$.ajax({

			url:"/street/images/" + that.siblings('a').attr("imgid"),
			type:"delete",
			dataType:"json",
			data:{"authenticity_token" : AUTH_TOKEN},
			success:function(data){
				if (data.status == 1){
					var imgid = that.siblings('a').attr("imgid");
					that.parent().remove();
					window.image_count -= 1;
					$(".thumbs :first").trigger("click");
					hide_div_overlay();
				}
			},
			error:function(){
				hide_div_overlay();
			}
		});
	});

	// for edit and new clear the temporarly selected files from inpu

  $(".icon-repeat").click(function(){
  	$("#image_upload").val("");
  });

  $("#clearuploads").on('click',function(){

		$("#image_upload").val('');

		if ($("#image_upload")[0].files.length == 0 ){
			window.image_count = 0;
		}else{
			window.image_count -= $("#image_upload")[0].files.length;
			if (window.image_count <0) window.image_count = 0;
		}



	_.each($(".thumb_img"),function(elem){
				if ($(elem).attr('imgid') == "-1"){
					$(elem).parent().remove();
				}
		});

});




});


//initialize variables
	window.cache ={}

//both for new and edit
function check_before_save(){

				var flag = 1;

				if (!('title' in window.item_values) || window.item_values['title'] == "" || window.item_values['title'] == null || window.item_values['title'] == undefined ){
					$("#title").addClass("error");
					$("#title").tooltip('show');
					return false;
				}

				if (!('cat' in window.item_values) || window.item_values['cat'] == "" || window.item_values['cat'] == null || window.item_values['cat'] == undefined ){
					$("#category_item").addClass("error");
					$("#category_item").tooltip('show');
					return false;
				}

				if (window.brand =="" || window.brand == null || window.brand == undefined ){
					if ($('#model').hasClass('hidden')){
						$("#add_new_model").removeClass('hidden');
						$("#add_new_model").editable('show');
					}else{
						$("#model").addClass("error");
						$("#model").tooltip('show');
					}

					return false;
				}

				if (window.price == '' || window.price == null || window.price == undefined ){
					$("#price").addClass("error");
					$("#model").tooltip('show');
					return false;
				}

				if (!('condition' in window.item_values) || window.item_values['condition'] == ""  || window.item_values['condition'] == null  || window.item_values['condition'] == undefined){
					$("#condition").addClass("error");
					$("#condition").tooltip('show');
					return false;
				}

				if (!('desc' in window.item_values) || window.item_values['desc'] == ""  || window.item_values['desc'] == null  || window.item_values['desc'] == undefined){
					$("#item_desc").addClass("error");
					$("#item_desc").tooltip('show');
					return false;

				}

				if (!('location' in window.item_values) || window.item_values['location'] == ""){
					$("#location").addClass("error");
					$("#location").tooltip('show');
					alert("Enter item location");
					return false;
				}
				_.each(window.item_values['spec'],function(value,key){
					$("#item_" + key).removeClass("error");
					if (value == ""){
						$("#item_" + key).addClass("error");
						$("#item_" + key).tooltip('show');
					}else{
						flag =  0;
					}
				});

				if (flag){
					alert(" Enter Specifications" );
					return false;
				}
				if ( (window.image_count >3) ){
					showNotifications("No more than 3 images are allowed. Please delete some.");
					return false;
				}else if ((window.image_count == 0)){
					showNotifications("Atleast one image is required.");
					return false;
				}

			return true;
}


clean_values = function(elm){
	_.each(elm,function(val,key){
		if (typeof(val) == 'object'){
			clean_values(val);
		}else if (typeof(val) == 'string'){
			elm[key] = window.btoa(val);
		}
	});
}
