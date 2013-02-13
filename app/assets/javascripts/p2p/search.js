
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
  });