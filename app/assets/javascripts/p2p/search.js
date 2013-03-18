

  $(document).ready(function() {

    var cache = {};

        // $("#top_search_input").keyup(function(e){
        //     if (e.which == 13 && $.trim($(this).val()) !=""){
        //         window.location.href = '/p2p/search/q/' + $.trim($(this).val());
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

    //auto complete for the search
    $("#top_search_input").autocomplete({
      minLength: 2,
      source: function( request, response ) {
        console.log(request);
        var term = request.term;
        if ( term in cache ) {
          response( cache[ term ] );
          return;
        }

        $.getJSON( "/p2p/search/" + request.term,{}, function( data, status, xhr ) {
          cache[ term ] = data;
          response( data );
        });
      },
      select:function(event,elem){
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

    setupunotify();

    $(".action_popover").popover();
    $('.action-icon').tooltip();


    $("#seller_send_verify_code").live("click",function(){
        var verify_ele = $(this)
         $(this).html('Sending verification code').attr('disabled','disabled');

         $.ajax({
              url:'/p2p/users/verifymobile/code',
              type:'post',
              data:{"mobile":$("#seller_mobile_number").val()},
              dataType:'json',
              success:function(data){
                   if (data.status== 1){
                        $(verify_ele).removeClass('btn-primary').attr('disabled','disable').html('Code Sent');

                        $("#seller_verify_code_submit").addClass('btn-primary');

                   }else{
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


    $("#seller_verify_code_submit").live("click",function(){


         if ($("#seller_verify_mobile").val().length  <4){
              alert('Wrong code. Enter the correct code');
              return false;
         }

         $(this).html('Verifying code').attr('disabled','disabled');

         $.ajax({
              url:'/p2p/users/verifymobile/' + $("#seller_verify_mobile").val(),
              type:'post',
              dataType:'json',
              success:function(data){
                   if (data.status== 1){
                        location.href="/p2p/sellitem"
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
