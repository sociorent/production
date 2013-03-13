$(document).ready(function(){

	//show the new item welcome popover
	$("#new_listing_info").popover('show');
	setTimeout(function(){
		$("#new_listing_info").popover('hide');
	},2000);


save_new_item = 	function(){

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
	}

});