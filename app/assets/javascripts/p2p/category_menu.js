
		$(document).ready(function(){
			var browseTop = $('#browse_menu').offset().top; 	

			 $(window).scroll(function(){ // scroll event
	 
	 		   var windowTop = $(window).scrollTop(); // returns number

	 		      if (browseTop < windowTop) {
	      				$('#browse_menu').css({ position: 'fixed', top: 0 });
	    			}
	    		else {
	      			$('#browse_menu').css('position','static');
	    		}
	 		});

			 $("#browse_button").mouseenter(function(){
			 	$(this).trigger('click');
			 });
	 
		});
	 
