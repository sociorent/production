
$(document).ready(function(){

  // fancy box for view image
  $('#view_image_fancy').fancybox({
      'speedIn'   : 500,
      'speedOut'    : 200,
      'centerOnScroll': true,
      'showCloseButton':true,
      'enableEscapeButton':true,
      'autoScale':true
  });


  // thumbs on clicked must change the image in view
  $('.thumbs').on('click',function(){
      $('#view_image').attr('src',$(this).children('img').attr("viewimage"));
      $('#view_image_fancy').attr('href',$(this).children('img').attr("fancyimg"));
      $('#view_image').attr('imgid',$(this).children('img').attr("imgid"));
  });


    //check the availabiltiy for the item to be shipped
    //in paytype = 1
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

    //view image fancy box for view
    $('#view_image_fancy').fancybox({
      'speedIn'   : 500,
      'speedOut'    : 200,
      'centerOnScroll': true
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


//form admin approve
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

//admin disapprove
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





pay_now_citrus_pay =  function(){

  showNotifications('Redirecting to Payment Gateway. Please wait...!');
  var merchantId="wnw4zo7md1";
  var orderAmt =$("#OrderAmount").val();
  var signature_data;
  // signature parameter
  sign_params= "merchantId=" + merchantId + "&item_id=" + window.item_id  + "&merchantTxnId=" + $("input[name=merchantTxnId]").val() + "&currency=INR";
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


  $("#send_verify_code").click(function(){
         $(this).html('Sending verification code').attr('disabled','disabled');

         $.ajax({
              url:'/p2p/users/verifymobile/code',
              type:'post',
              dataType:'json',
              success:function(data){
                   if (data.status== 1){
                        $("#send_verify_code").removeClass('btn-primary').attr('disabled','disable').html('Code Sent');

                        $("#verify_code_submit").addClass('btn-primary');

                   }else{
                        showNotifications('Some error occured. Try again.');
                        $("#send_verify_code").addClass('btn-primary').removeAttr('disabled').html('Failed.Retry');
                   }
              },
              error:function(){
                        showNotifications('Some error occured. Try again.');
                        $("#send_verify_code").addClass('btn-primary').removeAttr('disabled').html('Failed.Retry');

              }

         });//ajax
    });//click


    $("#verify_code_submit").click(function(){


         if ($("#verify_mobile").val().length  <4){
              alert('Wrong code. Enter the correct code');
              return false;
         }

         $(this).html('Verifying code').attr('disabled','disabled');

         $.ajax({
              url:'/p2p/users/verifymobile/' + $("#verify_mobile").val(),
              type:'post',
              dataType:'json',
              success:function(data){
                   if (data.status== 1){
                        $("#mobile_verify_modal").modal('hide');
                        $("#mobile_verify_modal_button").remove();
                        $("#contact_seller_modal_button").removeClass('hide');
                        alert('Sucessfully Verified');
                        $("#contact_seller_modal_button").trigger('click');

                   }else{
                        showNotifications('Some error occured. Try again.');
                        $("#verify_code_submit").addClass('btn-primary').removeAttr('disabled').html('Failed.Retry');
                   }
              },
              error:function(){
                        showNotifications('Some error occured. Try again.');
                        $("#verify_code_submit").addClass('btn-primary').removeAttr('disabled').html('Failed.Retry');
              }
         });//ajax
    });

  $('.action_icon').tooltip('destroy');

});