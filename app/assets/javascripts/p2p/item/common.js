
$(document).ready(function(){


	//trigger the upload on the file input when click on the div
	$('#upload_image').click(function(){
     $('#image_upload').trigger('click');
	});


	// edit new js

	// set the configuration for tooltips
	$('.action-icon').tooltip('destroy');

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

		if (window.image_count == 1 ){
			showNotifications('Add more images to delete this.');
			return false;
		}
		
		var that = $(this);


		$.ajax({

			url:"/p2p/images/" + that.siblings('img').attr("imgid"),
			type:"delete",
			dataType:"json",
			data:{"authenticity_token" : AUTH_TOKEN},
			success:function(data){
				if (data.status == 1){
					var imgid = that.siblings('img').attr("imgid");
					that.parent().remove();
					widow.image_count -= 1;
					$(".thumbs :first").trigger("click");
				}
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
				if ($(elem).attr('imgid') == -1){
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

				if (!('title' in item_values) || item_values['title'] == ""){
					$("#title").addClass("error");
					$("#title").tooltip('show');
					return false;
				}

				if (!('cat' in item_values) || item_values['cat'] == ""){
					$("#category_item").addClass("error");
					$("#category_item").tooltip('show');
					return false;
				}



				if (!('brand' in item_values) || item_values['brand'] == ""){
					$("#model").addClass("error");
					$("#model").tooltip('show');
					return false;
				}

				if (!('price' in item_values) || item_values['price'] == ""){
					$("#price").addClass("error");
					$("#model").tooltip('show');
					return false;
				}

				if (!('condition' in item_values) || item_values['condition'] == ""){
					$("#condition").addClass("error");
					$("#condition").tooltip('show');
					return false;
				}

				if (!('desc' in item_values) || item_values['desc'] == ""){
					$("#item_desc").addClass("error");
					$("#item_desc").tooltip('show');
					return false;

				}

				if (!('location' in item_values) || item_values['location'] == ""){
					$("#location").addClass("error");
					$("#location").tooltip('show');
					alert("Enter item location");
					return false;
				}
				_.each(item_values['spec'],function(value,key){
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

