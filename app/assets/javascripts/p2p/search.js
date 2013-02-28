

  $(document).ready(function() {

    var cache = {};

        $("#top_search_input").keyup(function(e){
            if (e.which == 13 && $.trim($(this).val()) !=""){
                window.location.href = '/p2p/search/q/' + $.trim($(this).val());
            }
        });

    // Login script
    $("#devise_pages a").live("click",function(){
      var action = $(this).text();
      $("#head_login_modalLabel").html(action);
      $("#login_popup_content .boxes").hide();
      switch(action)
      {
        case "Login":
           $("#login_box").fadeIn();
          break;
        case "Sign Up":
           $("#signup_box").fadeIn();
          break;
        case "Forgot Password?":
           $("#forgot_box").fadeIn();
          break;
      }
      $("#devise_pages a").css("display","none");
      $("#devise_pages a").each(function(ele){
        if($(this).text() != action)
          $(this).show()
      });
      return false;
    });

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
         $("#search_books_input").val("");
          window.location.href=elem.item.value
          return false;
      },
      focus:function(){
        return false;
      }
    });

    setupunotify();

    $(".action_popover").popover();
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
