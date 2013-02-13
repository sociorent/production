(function( $ ){

  $.fn.fixedScroll = function( ) {
  
  var defaults = {objSelected : this.selector}  
                  
  var getProp =  $.extend(defaults);
  
  $(window).scroll(function(){

      obj= getProp.objSelected;
      
        if($(window).scrollTop() > ($(obj).parent().offset().top) &&
           ($(obj).parent().height() + $(obj).parent().position().top - 30) > ($(window).scrollTop() + $(obj).height())){
        $(obj).css({"top":0,'position':'fixed','left': $(obj).offset().left});
        }
        else if($(window).scrollTop() < ($(obj).parent().offset().top)){
          $(obj).css({"position":'relative','left':0});
        }
  });
  };
})( jQuery );