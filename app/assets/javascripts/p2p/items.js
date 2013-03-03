$(document).ready(function(){




	$('#upload_image').click(function(){
       $('#image_upload').trigger('click');
	});

	window.cache ={}
    $("#check_availability").autocomplete({
      minLength: 6,
      source: function( request, response ) {
        console.log(request);
        var term = request.term;
        if ( term in cache ) {
          response( cache[ term ] );
          return;
        }

        $.getJSON( "/p2p/getserviceavailability/" + $("#check_availability").attr('itemid') + '/'  + request.term,{}, function( data, status, xhr ) {
          cache[ term ] = data;
          response( data );
        });
      },
      select:function(event,elem){
      		$(elem).val(elem.item.label);
      		$("#check_availability_modal").modal('hide');
      		if (elem.item.value == 1 ){
         		pay_now_citrus_pay();
         	}

      },
      focus:function(){
        return false;
      }
    });

    $("#upload_pic").click(function(){
    	$("#image_upload").trigger('click');
    });

	$('#view_image_fancy').fancybox({
		'speedIn'		:	500,
		'speedOut'		:	200,
		'centerOnScroll': true
 	});

	$(".action_icon").tooltip('destroy');

	$("#new_listing_info").popover('show');
	setTimeout(function(){
		$("#new_listing_info").popover('hide');
	},2000);
	// save the form onclick trigger
	$("#save").click(function(){

		// call the save function if saved not return false
		if (!saveItem()){
			return false;
		}

	});

	// cancel edit function trigger
	// #TODO: CHECK IF THE FORM IS CHANGED OR NOT AND REDIRECT ACCORDINGLY
	$("#cancel").click(function(){
			window.location.reload();
	});

	// EDIT Button click function..
	// if edit is pressed for first time then open all editable elements
	// 	if in edit rather than new dn enable the category and brand for edition
	// if edit is pressed for second time then try to toggle all the editable elements to normal
	$('#enable').click(function() {
		$(this).toggleClass('active');

		//close all editable elements
		if ($('.canEdit').hasClass('editable')){

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

			$("#category").editable('toggleDisabled');

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
		//Enable all the edits here.
		else {

			$(".action_icon").tooltip({"delay":{show:0,hide:100}});

			$(".edit_visible").addClass('edit_shown').removeClass('edit_visible');

			$('#clearuploads').removeClass('hidden');
			$('.remove_image').removeClass('hidden');

			// show all the tooltips11
			// hide the edit button and show the save and cancel button
			$("#enable").hide();
			$("#save").show();
			$("#cancel").show();

			$(this).addClass('btn-primary').attr('title','Save Changes');

			$("#enable i").attr('title','Click here to save your changes');
			$("#enable i").removeClass('icon-pencil');
			$("#enable i").addClass('icon-ok');

			// enable upload form
			// $("#file_add_image").removeProp("disabled");
			$("#upload_pic").removeAttr("disabled");

			$(".remove_image").css({'display':'block'});
			$("#add_more_spec").removeClass('hide');

			//enable the remove image butotn

			$("#upload_pic").removeClass('hide');

			$('.canEdit').editable();

			$("#image_upload").removeAttr('disabled','disabled');
			if (window.edit){
				$("#category").editable('toggleDisabled');
				$('[id^=item_]').on('save',check_specs);

			}

			$("#title").css({'color':'blue'});
			$("#title").editable({
				placement:'bottom'
			});
			$("#title").tooltip('show');


			$("#empty_specs").removeClass('hide');


			window.try = 0;
			$("#category").on('save',function(e,params){
				//set_category(params.newValue);


				if (params.newValue == item_values['cat']) return false ;

				item_values['cat'] = params.newValue;

				$(".specs").remove();

				item_values['spec']={};

				//$('#model').removeClass('editable').removeClass('editable-click').removeClass('editable-unsaved');
				var temp = $('#model').parent().html();
				var par = $('#model').parent();
				$(par).html(temp);
				$("#model").html("Select one");
				$("#model").attr("data-source",'/p2p/getbrand/' + params.newValue);
				item_values['brand'] = '';

				
				//add custom brand
				$('#add_new_model').on('keyup',function(){
					if ($.trim ( $(this).val() ) != '' ) {
						item_values['brand'] = $.trim ( $(this).val() );
						$("#model").val('');
					}
				});


				//$("#model").editable({sourceCache:false});

				//$("#model").destroy();
				$("#model").editable();

						//set model save handler
						//validate location
						$('#model').on('save', function(e, params) {
			   				 //alert('Saved value: ' + params.newValue);
			   				 //alert('saving');
							if (params.newValue != "") {
								item_values['brand'] = params.newValue;
								$(this).removeClass('error');

								$("#price").tooltip('show');
							}
							else{
								item_values['brand']="";
								params.newValue = params.oldValue;
								$(this).addClass('error');
								$("#model").tooltip('show');
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

		// //validate brand
			// $('#category').on('save', function(e, params) {
   // 				 //alert('Saved value: ' + params.newValue);
			// 	if (params.newValue != "") {
			// 		item_values['title'] = params.newValue;


			// 		$(this).removeClass('error');
			// 	}
			// 	else{
			// 		item_values['title']="";
			// 		params.newValue = params.oldValue;
			// 		$(this).addClass('error');
			// 	}
			// });

			//validate title
			$('#title').on('save', function(e, params) {
   				 //alert('Saved value: ' + params.newValue);
				if (params.newValue.length > 5) {
					item_values['title'] = params.newValue;
					$(this).removeClass('error');
					$('#category').tooltip('show');
				}
				else{
					item_values['title']="";
					params.newValue = params.oldValue;
					$(this).addClass('error');
					$(this).tooltip('show');
				}
			});

			// window.url = '/p2p'
			// $('#model').editable({
  	// 		selector: 'a',
  	// 		url: window.url,
  	// 		pk: 1
			// });

			//validate price
			$('#price').on('save', function(e, params) {
   				 //alert('Saved value: ' + params.newValue);
				if (params.newValue.match(/^\d+\.?\d+$/) != null) {
					item_values['price'] = params.newValue;
					$(this).removeClass('error');
					$("#condition").tooltip('show');

				}else{
					item_values['price']="";
					params.newValue = params.oldValue;
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

			$("#image_upload").change(function(){


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

						$(".thumb_holder .thumbnails ").append('<li class="thumbs"><i class="icon-remove pull-right hide remove_image "></i>\
	              			<img src="' + e.target.result + '"  imgid="-1" class="thumb_img pull-left" viewimage="' + e.target.result + '">\
	              		</li>');

			        };
			      })(f);

			      // Read in the image file as a data URL.
			      reader.readAsDataURL(f);
			    }

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

				$('#save i').tooltip('show');
			});

			//validate condition
			$('#desc_content').on('save', function(e, params) {
   				 //alert('Saved value: ' + params.newValue);
   				 params.newValue = $.trim(params.newValue);

				if (params.newValue.length > 20) {
					item_values['desc'] = params.newValue;
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

		}

		if ($(this).hasClass('active')){
			$(this).children().attr('data-original-title','Please click on blue text to edit');
		}
   });

	//delete the item
    $("#delete_button").on('click',function(){
    	// if user says no stop deleting
    	if (!confirm("Are you sure you want to delete this listing?")){
    		return true;
    	}

	    $.ajax({
	      url:"/p2p/items/" + $(this).attr("itemid"),
	      type:"delete",
	      dataType:"json",
	      data:{"authenticity_token" : AUTH_TOKEN},
	      success:function(data){
	        if (data.status == 1){
	          window.location.href="/p2p/mystore"
	        }
	      }
	    });
  });

	//remove image funciton
	$(".remove_image").click(function(){

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
					$(".thumbs :first").trigger("click");
				}
			}
		});
	});

			saveItem = function(){



				if (!('title' in item_values) || item_values['title'] == ""){
					$("#title").addClass("error");
					$("#title").tooltip('show');
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


				var flag = 1;

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

				//showOverlay();
				showNotifications('Saving item..! Please wait..!');

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

				if (window.edit){
					$("#fileupload").attr({
						'action':window.editsaveurl						});

				}

				//$("#fileupload").submit();
				//showOverlay();
				showNotifications('Saving item..! Please wait..!');

			if (!window.edit){
				item_values['authenticity_token']= AUTH_TOKEN;
				$.ajax({
					url:window.editsaveurl,
					data:item_values,
					type:window.editsavetype,
					success:function(data){

						$("#sellitem_pricing_modal .modal-body").html(data);
						$("#sellitem_pricing_modal").modal({
							'backdrop':'static',
							'keyboard':false,
							'show':true
						}).css({
						    width: 'auto',
						    'margin-left': function () {
						        return -($(this).width() / 2);
						    }
						});


					    $("#direct_payment_submit").on('click',function(){

					       if (!($("#direct_payment_form #terms")[0].checked) ){
					       		showNotifications('Agree to Terms and conditions');
					       		return false;
					       }

					       $('#form_temp').append($("<input  class='hide' name='paytype' value='2'>"));
					       $('#form_temp').append($("<input  class='hide' name='meet_at' value='" + $("#direct_payment_form #meet_at").val() + "'>"));


					       $("#fileupload").submit();

					      return false;

					    });

					    $("#courier_payment_submit").on('click',function(){

					       if (!($("#courier_payment_form #terms")[0].checked) ){
					       		showNotifications('Agree to Terms and conditions');
					       		return false;
					       }

					       $('#form_temp').append($("<input  class='hide' name='paytype' value='1'>"));
					       $('#form_temp').append($("<input  class='hide' name='dispatch_day' value='" + $("#dispatch_day").val() + "'>"));
					       $('#form_temp').append($("<input  class='hide' name='alloverindia' value='" + $("#alloverindia").val() + "'>"));



					       $("#fileupload").submit();

					      return false;

					    });

					$("#sociorent_payment_submit").on('click',function(){

					       if (!($("#sociorent_payment_form #terms")[0].checked) ){
					       		showNotifications('Agree to Terms and conditions');
					       		return false;
					       }

					       if ($("#sociorent_payment_form #p2p_item_payinfo").val() == "" ){
					       		showNotifications('Select one pincode');
					       		return false;
					       }

					       $('#form_temp').append($("<input  class='hide' name='paytype' value='3'>"));
					       $('#form_temp').append($("<input  class='hide' name='payinfo' value='" + $("#payinfo").val() + "'>"));


					       $("#fileupload").submit();

					       return false;

					    });

					}
				});
			}else{
				$("#fileupload").submit();
			}

			};

	      $('#approve').on('click',function(){
	          var that  = $(this);

	          $.ajax({
	            url:'/p2p/approve/approve',
	            data:{id: that.attr('itemid')},
	            dateType:'json',
	            type:'post',
	            success:function(data){
	                if (data ==  1) {
	                  showNotifications('Item Approved');
	                  that.remove();
	                }
	                else{
	                  showNotifications('Something went wrong');
	                }
	            },
	            error:function(){
	                showNotifications('Something went wrong');
	            }
	          });
	      });

	      $('#disapprove').on('click',function(){
	          var that  = $(this);

	          $.ajax({
	            url:'/p2p/approve/disapprove',
	            data:{id: that.attr('itemid')},
	            dateType:'json',
	            type:'post',
	            success:function(data){
	                if (data ==  1) {
	                  showNotifications('Item Disapproved');
	                  that.remove();
	                }
	                else{
	                  showNotifications('Something went wrong');
	                }
	            },
	            error:function(){
	                showNotifications('Something went wrong');
	            }
	          });
	      });


	      $('.thumbs').on('click',function(){
	      		$('#view_image').attr('src',$(this).children('img').attr("viewimage"));
	      		$('#view_image_fancy').attr('href',$(this).children('img').attr("fancyimg"));
	      		$('#view_image').attr('imgid',$(this).children('img').attr("imgid"));
	      });

	      $(".icon-repeat").click(function(){
	      	$("#image_upload").val("");
	      });

	      $("#clearuploads").on('click',function(){

	      	if ($("#image_upload")[0].files.length == 0 ){
	      		window.image_count = 0;
	      	}else{
	      		window.image_count -= $("#image_upload")[0].files.length;
	      		if (window.image_count <0) window.image_count = 0;
	      	}

	      	$("#image_upload").val('');

			_.each($(".thumb_img"),function(elem){
	      			if ($(elem).attr('imgid') == -1){
	      				$(elem).parent().remove();
	      			}
	      	});

	      });

	      
		pay_now_citrus_pay =  function(){

	  	showNotifications('Redirecting to Payment Gateway. Please wait...!');
	  	var merchantId="wnw4zo7md1";
	  	var orderAmt =$("#OrderAmount").val();
	  	var signature_data;
			// signature parameter
			sign_params= "merchantId=" + merchantId + "&item_id=" + window.item_id	+ "&merchantTxnId=" + $("input[name=merchantTxnId]").val() + "&currency=INR";
			// get the signature hmac sha1 encoded
			$.ajax({
						url:"/getSignature",
						type : "post",
						dataType: "json",
						async : false,
						data : sign_params,
						success : function(data){
							showNotifications('Redirecting to Payment Gateway..... Please wait...!');
							
							// set the signature to merchant key
							signature_data = data;
							$("input[name='reqtime']").val(signature_data.time);
							$("input[name='secSignature']").val(signature_data.signature);
							$("input[name='merchantTxnId']").val(signature_data.txn_id);
							$("#citruspay_form").submit();
							// submitting the form to citruspay
							return false;

					}});
			return false;
		};

		$("#pay_now_citrus_pay").live("click",pay_now_citrus_pay);
	});


check_specs =  function(e, params) {
				   				 //alert('Saved value: ' + params.newValue);
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
											$("#desc_content").tooltip('show');
											$("#desc_content")[0].scrollIntoView(false);
										}
									}
									else{
										item_values['spec'][that.attr('specid')]="";
										params.newValue = params.oldValue;
										$(this).addClass('error');
										$(this).tooltip('show');
									}
								}
								else{
									item_values['spec'][that.attr('specid')]="";
									$(this).tooltip('show');
								}

							}
