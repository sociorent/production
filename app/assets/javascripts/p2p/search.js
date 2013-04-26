
// window.search_request = null;

// clear_search_request = function(){
//   if (window.search_request != null and window.search_request and != undefined){
//     window.search_request.abort();
//   }
// }

  $(document).ready(function() {

  //we are with slider
  $('#slider-code').tinycarousel({ display: 2 });

    var cache = {};

        // $("#top_search_input").keyup(function(e){
        //     if (e.which == 13 && $.trim($(this).val()) !=""){
        //         window.location.href = '/street/search/q/' + $.trim($(this).val());
        //     }
        // });

        show_all_session_button = function(){
          $("#signup_button").show();
          $("#forgot_pass_button").show();
          $("#login_button").show();
        }
    // Login script
    $('#login_button').hide();

    $("#devise_pages a").live("click",function(){
      var action = $(this).text();
      $("#head_login_modalLabel").html(action);
      $("#login_popup_content .boxes").hide();
      switch(action)
      {
        case "Login":
           $("#login_box").fadeIn();
           show_all_session_button();
           $('#login_button').hide();


          break;
        case "Sign Up":
           $("#signup_box").fadeIn();
           show_all_session_button();
           $('#signup_button').hide();

          break;
        case "Forgot Password?":
           $("#forgot_box").fadeIn();
           show_all_session_button();
           $('#forgot_pass_button').hide();
          break;
      }
      $("#devise_pages a").css("display","none");
      $("#devise_pages a").each(function(ele){
        if($(this).text() != action)
          $(this).show()
      });
      return false;
    });

    //search is now form

    $(".search_btn").click(function(){

      $("#top_search_form").submit();
    });

    $("#user_location, #location").autocomplete({
      minLength: 2,
      source: function( request, response ) {
       var term = request.term;
        if ( term in cache ) {
          response( cache[ term ] );
          return;
        }
        $.getJSON( "/street/get_city/" + request.term,{}, function( data, status, xhr ) {
          cache[ term ] = data;
          response( data );
        });
      },
      select:function(event,elem){
          set_location(elem.item.value);
          event.preventDefault();
      }
    });


    function set_location(city)
    {
      $.ajax({
            url:'/street/location',
            type:'post',
            data:{location:city},
            dataType:'json',
            success:function(data){
              if (data.status == 1){
                window.location.reload();
              }
              else if(data.status == 2){
                $("#user_location").val($("#user_city").val());
                $("#head_user_location i").attr('title','Error: Entered city not available. Try with different location').tooltip('destroy').tooltip('show');
              }
            },
            error:function(){
              $("#user_location").val($("#user_city").val());
              $("#head_user_location i").attr('title','Error occured in setting your location').tooltip('destroy').tooltip('show');
            }
          });
    }

    $("#user_location").blur(function(){
      $("#user_location").val($("#user_city").val());
    })


    //auto complete for the search
    $("#top_search_input").autocomplete({
      minLength: 2,
      source: function( request, response ) {
        var term = request.term;
        if ( term in cache ) {
          response( cache[ term ] );
          return;
        }

        $.getJSON( "/street/search/" + request.term,{}, function( data, status, xhr ) {
          cache[ term ] = data;
          response( data );
        });
      },
      select:function(event,elem){

        if (elem.item.value == "") {
          $("#top_search_input").val('');
          return false;
        }

        var category_val = elem.item.label.split(" in ");

        if ( elem.item.value[0] == '/'){
          window.location.pathname = encodeURI(elem.item.value);
          return false;
        }

        if(category_val[1] != undefined){
          $("#category option:contains("+ category_val[1] +")").attr("selected","selected");
          $("#top_search_input").val(category_val[0]);
        }else{
          $("#top_search_input").val(elem.item.label);
        }
        //after selecting the item from autocomplete submit the form

        $("#top_search_form").submit();
        return false;
      },
      focus:function(event,elem){
        $("#top_search_input").val(elem.item.label);
        return false;
      }
    });


    $("#top_search_form").on('submit',function(){
      if ($("#top_search_input").val() == '') {
        return false;
      }
    });
    setupunotify();

    $(".action_popover").popover();

    // $("*").tooltip('disable');

    $('[data-toggle="tooltip"]').tooltip('enable');


    $("#seller_send_verify_code").live("click",function(){
        var verify_ele = $(this)
         $(this).html('Sending verification code');

         $.ajax({
              url:'/street/users/verifymobile/code',
              type:'post',
              data:{"mobile":$("#seller_mobile_number").val()},
              dataType:'json',
              success:function(data){
                   if (data.status == 1){
                        $(verify_ele).removeClass('btn-primary').html('Code Sent. Resend Code');
                        $("#seller_verify_code_submit").addClass('btn-primary');

                   }else if (data.status == 1){
                        showNotifications('Mobile Number in use');
                        $(verify_ele).addClass('btn-primary').removeAttr('disabled').html('Failed.Retry');
                   }
                   else{
                        showNotifications('Some error occured. Try again.');
                        $(verify_ele).addClass('btn-primary').removeAttr('disabled').html('Failed.Retry');
                   }
              },
              error:function(){
                        showNotifications('Some error occured. Try again.');
                        $(verify_ele).addClass('btn-primary').removeAttr('disabled').html('Failed.Retry');

              }

         });//ajax
    });//click

    $(".unfollow_user").click(function(){
      var id = $(this).attr("userid");
      $.post('/street/favourites/'+id, function(data) {
        console.log(data);
        if (data.status == 1){
          $("#"+id).hide();
        }
        if(data.count == 0) {
          $("#fav_table").hide();
          $("#fav_container").html("<h3>You don't have any favourite sellers.</h3>");
        }

      });
    });

    $("#seller_verify_code_submit").live("click",function(){


         if ($("#seller_verify_mobile").val().length  !=6 ){
              alert('Wrong code. Enter the correct code');
              return false;
         }

         $(this).html('Verifying code').attr('disabled','disabled');

         $.ajax({
              url:'/street/users/verifymobile/' + $("#seller_verify_mobile").val(),
              type:'post',
              dataType:'json',
              success:function(data){
                   if (data.status== 1){
                        location.href="/street/sellitem"
                        location.reload
                   }else{
                        showNotifications('Some error occured. Try again.');
                        $("#seller_verify_code_submit").addClass('btn-primary').removeAttr('disabled').html('Failed.Retry');
                   }
              },
              error:function(){
                        showNotifications('Some error occured. Try again.');
                        $("#seller_verify_code_submit").addClass('btn-primary').removeAttr('disabled').html('Failed.Retry');
              }
         });//ajax
    });
    if(location.hash == "#verify_mobile")
      $("#seller_mobile_verify_modal").modal("show");



   });


  function setupunotify(){
    if ($.fn.notify){
       $("#notificationcontainer").notify();
    }else{
      setTimeout(setupunotify,3000);
    }

  }

  // display the notification
  function showNotifications(content){
    hideNotifications();
    $("#flash_notice").html(content).clearQueue().fadeIn(1000).delay(500).fadeOut(1000);
  }

  function hideNotifications(){
    $("#flash_notice").hide();
  }


  function hide_div_overlay(){
    $('.block_div').css({'display':'none'});
  }

  function show_div_overlay(elm){
    var blockelm= $(".block_div");

    $(blockelm).offset($(elm).offset());
    $(blockelm).css({'display':'table-cell',
                    'width':$(elm).width() + 'px',
                    'height':$(elm).height() + 'px' ,
                    'line-height':$(elm).height() + 'px',
                    'z-index' : 1000
                  });
  }

  function show_notification_modal(data,keyboard,backdrop){

      if (keyboard == undefined || keyboard == null){
        keyboard = false;
      }

      if (backdrop == undefined || backdrop == null){
       backdrop  = 'static';
      }
            $('.close').trigger('click');
        $('#notification_modal .modal-body').html(data);
        $('#notification_modal').modal({'keyboard':keyboard,'show':true,'backdrop':backdrop});
  }

  function hide_notification_modal(){
    $('#notification_modal').modal('hide')
  }