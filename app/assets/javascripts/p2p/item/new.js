//= require p2p/item/application

$(document).ready(function(){

	//show the new item welcome popover
	$("#new_listing_info").popover('show');
	setTimeout(function(){
		$("#new_listing_info").popover('hide');
	},2000);


save_new_item = 	function(){
		window.item_values['price'] = window.price
		window.item_values['model'] = window.brand

		var upload_values = _.clone(window.item_values);
		clean_values(upload_values);


		window.item_values['authenticity_token']= AUTH_TOKEN;
		$.ajax({
			url:window.editsaveurl,
			data:upload_values,
			type:window.editsavetype,
			success:function(data){

				$("#sellitem_pricing_modal .modal-body").html(data);
				$("#sellitem_pricing_modal").modal({
					'backdrop':'static',
					'keyboard':false,
					'show':true
				}).css({
				    width: ($(window).width()/2)
				});


			    $("#direct_payment_submit").on('click',function(){

			       if (!($("#direct_payment_form #terms")[0].checked) ){
			       		showNotifications('Agree to Terms and conditions');
			       		return false;
			       }

			       $('#form_temp').append($("<input  class='hide' name='paytype' value='2'>"));
			       $('#form_temp').append($("<input  class='hide' name='meet_at' value='" + $("#direct_payment_form #meet_at").val() + "'>"));

						 $('#direct_payment_submit').val('Uploading images..Please wait..').attr('disabled','disabled');

						 show_notification_modal('<i class="icon-info-sign"></i> Uploading your images and saving you listing..! <br/> Please wait',true);

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

						 $('#courier_payment_submit').val('Uploading images..Please wait..').attr('disabled','disabled');

							show_notification_modal('<i class="icon-info-sign"></i> Uploading your images and saving you listing..! <br/> Please wait',true);
			       $("#fileupload").submit();

			      return false;

			    });

			$("#sociorent_payment_submit").on('click',function(){

			       if (!($("#sociorent_payment_form #terms")[0].checked) ){
			       		showNotifications('Agree to Terms and conditions');
			       		return false;
			       }

			       if ($("#sociorent_payment_form #p2p_item_payinfo").val() == "" ){
			       		showNotifications('Enter your address');
			       		return false;
			       }

			       $('#form_temp').append($("<input  class='hide' name='paytype' value='3'>"));
			       $('#form_temp').append($("<input  class='hide' name='payinfo' value='" + $("#p2p_item_payinfo").val() + "'>"));

					   $('#sociorent_payment_submit').val('Uploading images..Please wait..').attr('disabled','disabled');

 						show_notification_modal('<i class="icon-info-sign"></i> Uploading your images and saving you listing..! <br/> Please wait',true);

			       $("#fileupload").submit();

			       return false;

			    });
			}
		});
	}

});

