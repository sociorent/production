
  $(document).ready(function() {

    var cache = {};
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

  });


  function setupunotify(){
    if ($.notify){
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
