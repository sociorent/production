$(document).ready(function(){

	$(document).on('click',function(e){
		if ($(e.target).parents('.tooltip').length == 0) $('[data-original-title]').tooltip('hide');
	});

	
	
	// save the form onclick trigger
	$("#save_top").click(function(){
		// call the save function if saved not return false
		if (!saveItem()){
			return false;
		}
		
		$('.action-icon').tooltip('destroy');

	});

	$("#save_bottom").click(function(){
		// call the save function if saved not return false
		if (!saveItem()){
			return false;
		}
	});



	// EDIT Button click function..
	// if edit is pressed for first time then open all editable elements
	// 	if in edit rather than new dn enable the category and brand for edition
	// if edit is pressed for second time then try to toggle all the editable elements to normal
	$('#enable').click(function(){
		$(this).toggleClass('active');
			//close all editable elements
			if ($('.canEdit').hasClass('editable')){
				cancel_edit();
			}
			else{
				edit_item();
			}
  });

});
// save the item

saveItem = function(){

				// if some fields are not filled this will return false 
				// 	so dont save them
				if (!check_before_save()){
					return false;
				}

				//showOverlay();
				showNotifications('Saving item..! Please wait..!');

				// add all the fields to the form 
				// and submit the form

				$("#form_temp").html('');
				$('#form_temp').append($("<input  class='hide' name='price' value='" + item_values['price'] + "'>"));
				$('#form_temp').append($("<input  class='hide' name='title' value='" + item_values['title'] + "'>"));
				$('#form_temp').append($("<input  class='hide' name='location' value='" + item_values['location'] + "'>"));
				$('#form_temp').append($("<input class='hide' name='condition' value='" + item_values['condition'] + "'>"));
				$('#form_temp').append($("<input class='hide' name='brand' value='" + item_values['brand'] + "'>"));
				$('#form_temp').append($("<input class='hide' name='desc' value='" + item_values['desc'] + "'>"));
				$('#form_temp').append($("<input class='hide' name='brand' value='" + item_values['brand'] + "'>"));
				$('#form_temp').append($("<input  class='hide' name='cat' value='" + item_values['cat'] + "'>"));

				_.each(item_values['spec'],function(value,key){
					$('#form_temp').append($("<input class='hide' name='spec[" + key + "]' value='" + value + "'>"));
				});


			// if new form get the payment details and them save
			if (!window.edit){
				save_new_item();
			}else{

				$("#fileupload").attr({
					'action':window.editsaveurl
				});

				//if edit just submit the form
				$("#fileupload").submit();
			}
} //save item

//on save trigger for specs
check_specs =  function(e, params) {

		 var that = $(this);

		if (params.newValue.length > 0) {
			if (params.newValue.length > 1) {
				item_values['spec'][that.attr('specid')] = params.newValue;
				$(this).removeClass('error');

				if ($('[id^=item_]')[Number($(this).attr('specid')) ]){

					$($('[id^=item_]')[Number($(this).attr('specid'))]).tooltip('show');
				}
				else{
					$(window).scrollTop = $("#desc_content").top;
					$("#desc_content")[0].scrollIntoView(false);
				}
		}
		else{
			item_values['spec'][that.attr('specid')]="";
			params.newValue = params.oldValue;
			$(this).addClass('error');
		}
	}
	else{
		item_values['spec'][that.attr('specid')]="";
		$(this).tooltip('show');
	}
}// check specs

// edit item form
edit_item =function(){

		$('#viewcount').addClass('hidden');
		$("[id^=reqcount_]").addClass('hidden');
		$("#owner_item").addClass('hidden');
		$("#payment_btn").addClass('hidden');
		
		

		$(".edit_visible").addClass('edit_shown').removeClass('edit_visible');

		$('#clearuploads').removeClass('hidden');
		$('.remove_image').removeClass('hidden');

		// show all the tooltips11
		// hide the edit button and show the save and cancel button
		$("#enable").hide();
		$("#save_top").show();
		$("#save_bottom").show();
		$("#cancel_top").show();
		$("#cancel_bottom").show();

		$(this).attr('title','Save Changes');

		$("#enable i").attr('title','Click here to save your changes').removeClass('icon-pencil').addClass('icon-ok');

		// enable upload form
		// $("#file_add_image").removeProp("disabled");
		$("#upload_pic").removeAttr("disabled").removeClass('hide');
		$(".remove_image").css({'display':'block'});
		$("#add_more_spec").removeClass('hide');

		//enable the remove image butotn


			$("#image_upload").change(function(){

					// get the files uploaded ..
					// Read locally..
					// then display on the page

			    var files = $(this)[0].files; // FileList object
			    // Loop through the FileList and render image files as thumbnails.
			    for (var i = 0, f; f = files[i]; i++) {

			      // Only process image files.
			      if (!f.type.match('image.*')) {
			        continue;
			      }

			      window.image_count += 1;

			      var reader = new FileReader();

			      // Closure to capture the file information.
			      reader.onload = (function(theFile) {
			        return function(e) {

						$(".thumb_holder .thumbnails ").append('<li class="thumbs"><!--<i class="icon-white icon-remove pull-right hide remove_image "></i> -->\
	              			<img src="' + e.target.result + '"  imgid="-1" class="thumb_img pull-left" viewimage="' + e.target.result + '">\
	              		</li>');

			        };
			      })(f);

			      // Read in the image file as a data URL.
			      reader.readAsDataURL(f);
			    }

			  // if (($(this)[0].files.length  )>0 ){
			  // 	$("#clearuploads").attr('disabled','disabled');
			  // }else{
			  // 	$("#clearuploads").removeAttr('disabled');
			  // }

				if ((window.image_count  )>3 ){
					showNotifications("No more than 3 images are allowed. Please delete some");
					return false;
				}

				if ($("#image_upload")[0].files.length > 3 ){
					showNotifications('Image limit is 3. Please add only three files');
					return false;
				}else if ( !window.edit && $("#image_upload")[0].files.length == 0){
					showNotifications('Add atleast one image');
					return false;
				}

			});

		// enable xeditable
		$('.canEdit').editable();
		
		//enbale image upload
		$("#image_upload").removeAttr('disabled','disabled');

		// if i'm in edit 
		if (window.edit){
			$('[id^=item_]').on('save',check_specs);
		}else{
			$("#category_item").editable();
		}

		$("#title").css({'color':'blue'});
		$("#title").editable({
			placement:'bottom'
		});
		$("#title").tooltip('show');
		$("#empty_specs").removeClass('hide');


		window.try = 0;
		//trigger on category change
		$("#category_item").on('save',function(e,params){

			// if new value is old value dn do anything
			if (params.newValue == item_values['cat']) return false ;

			// set the new value in global
			item_values['cat'] = params.newValue;

			// clear the specs 
			$(".specs").remove();
			item_values['spec']={};

			//for editable dirty hack..
			//remove the element from the page and add it newly
			//clears the cache
			var temp = $('#model').parent().html();
			var par = $('#model').parent();
			$(par).html(temp);
			$("#model").html("Select one");
			$("#model").attr("data-source",'/p2p/getbrand/' + params.newValue);
			item_values['brand'] = '';


			//make the model editable
			$("#model").editable();

					//set model save handler
					//validate location
					$('#model').on('save', function(e, params) {
		   				 //alert('Saved value: ' + params.newValue);
		   				 //alert('saving');
						if (params.newValue != "") {
							item_values['brand'] = params.newValue;
							$(this).removeClass('error');

							if (params.newValue == 'Other'){
								$("#add_new_model").removeClass('hidden');
								$("#add_new_model").editable('show');
								$("#model").addClass('hidden');

								item_values['brand'] = '';

							}else{
								$("#add_new_model").addClass('hidden');
								$("#add_new_model").editable('destroy');
							}

							$("#price").tooltip('show');
							$('#add_new_model').val('');
						}
						else{
							item_values['brand']="";
							params.newValue = params.oldValue;
							$(this).addClass('error');
							$("#model").tooltip('show');
						}
					});


					$('#add_new_model').on('save', function(e, params) {
		   				 //alert('Saved value: ' + params.newValue);
		   				 //alert('saving');
						if (params.newValue != "") {
							item_values['brand'] = params.newValue;
							$("#price").tooltip('show');
							$('#model').text(params.newValue);
							$("#add_new_model").addClass('hidden');
							$("#model").removeClass('hidden');
							
						}
						else{
							item_values['brand']="";
							params.newValue = params.oldValue;
							$(this).addClass('error');
						}
					});


			showNotifications("Fetching specifications...! Please Wait..");

			$.ajax({
				url:'/p2p/getattributes/' + params.newValue,
				type:"get",
				success:function(data){

					$('#table_specs .cat_spec').remove();
					$(data).insertAfter($('#table_specs tr:last '));
					$("[id^=item_]").editable();

					//validate specification
						$('[id^=item_]').on('save',check_specs);

				},
				error:function(){

					$('#table_specs .cat_spec').remove();
					$('<tr class="error cat_spec"><td colspan = 2 >Specifications were not loaded. Something went wrong. Try again</td></tr>').insertAfter($('#table_specs tr:last '));

					showNotifications('Some Error Occured. Please Try again');
				}

			});

			$('#model').tooltip('show');
		});


		//validate title
		$('#title').on('save', function(e, params) {
 				 //alert('Saved value: ' + params.newValue);
			if (params.newValue.length > 2) {
				item_values['title'] = params.newValue;
				$(this).removeClass('error');
				$('#category_item').tooltip('show');
			}
			else{
				item_values['title']="";
				params.newValue = params.oldValue;
				$(this).addClass('error');
				$(this).tooltip('show');
			}
		});


		//validate price
		$('#price').on('save', function(e, params) {
 				 //alert('Saved value: ' + params.newValue);
			if (params.newValue.match(/^\d+\.?\d+$/) != null) {
				item_values['price'] = params.newValue;
				$(this).removeClass('error');
				$("#condition").tooltip('show');

			}else{
				item_values['price']="";
				$(this).editable('setValue','');
				$(this).addClass('error');
				$(this).tooltip('show');
			}
		});

		//validate location
		$('#location').on('save', function(e, params) {
 				 //alert('Saved value: ' + params.newValue);

			if (params.newValue.length !=0 ) {
				item_values['location'] = params.newValue;
				$(this).removeClass('error');
				$('[id^=item_] :first').tooltip('show');
			}
			else{
				item_values['location']="";
				params.newValue = params.oldValue;
				$(this).addClass('error');
				$(this).tooltip('show');
			}
		});


		//validate condition
		$('#desc_content').on('save', function(e, params) {
 				 //alert('Saved value: ' + params.newValue);
 				 params.newValue = $.trim(params.newValue);

			if (params.newValue.length > 20) {
				item_values['desc'] = escape(params.newValue);
				$(this).removeClass('error');
				$("#upload_pic").tooltip('show');
			}
			else{
				item_values['desc']="";
				params.newValue = params.oldValue;
				$(this).addClass('error');
				$(this).tooltip('show');
			}
		});


		//validate condition
		$('#condition').on('save', function(e, params) {
 				 //alert('Saved value: ' + params.newValue);
 				 params.newValue = $.trim(params.newValue);

			if (params.newValue.length > 2) {
				item_values['condition'] = params.newValue;
				$(this).removeClass('error');
				$("#location").tooltip('show');
			}
			else{
				item_values['condition']="";
				params.newValue = params.oldValue;
				$(this).addClass('error');
				$(this).tooltip('show');
			}
		});

	}//edit item end


function cancel_edit(){

			$('#viewcount').removeClass('hidden');
			$("[id^=reqcount_]").removeClass('hidden');
			$("#owner_item").removeClass('hidden');
			$("#payment_btn").removeClass('hidden');
		
			$(".action_icon").tooltip('destroy');

			$('#clearuploads').addClass('hidden');
			$('.remove_image').addClass('hidden');
			

			$("#add_more_spec").addClass('hide');

			$(".edit_shown").addClass('edit_visible').removeClass('edit_shown');
			//$("#upload_pic").addClass('hide');

			$("#empty_specs").addClass('hide');

			$("#title").css({'color':""});

			$('.canEdit').editable('toggleDisabled');

			$("#title").editable('toggleDisabled');

			$("#category_item").editable('toggleDisabled');

			$(this).children().attr('data-original-title','Edit Item');

			// disable upload form
			//$("#file_add_image").attr("disabled","disabled");

			$(".remove_image").css({'display':'block'});

			$(this).removeClass('btn-primary').attr('title','Edit Listing');

			// replace the edit icon
			// #TODO: REMOVE THIS NOT NEEDED IN FUTURE
			$("#enable i").addClass('icon-pencil');
			$("#enable i").removeClass('icon-ok');
			$("#enable i").attr('title','Edit Listing');

}


