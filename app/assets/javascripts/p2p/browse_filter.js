$(document).ready(function(){

	// TO Apply filter on all attributes has spec filter class
	// $(".spec-filter").click(function(){
	// 	var spec = $(this).attr('spec-name');
	// 	var val = $(this).attr('spec-value');
	// 	filter(spec,val,this);
	// 	return false;
	// });

	$(".spec_filter_check").on('change',function(){
			var spec = $(this).attr('spec-name');
			var val = $(this).attr('spec-value');
			filter(spec,val,this);
			return false;
	});

	$('.spec-filter').on('click',function(){

		if ($(this).children('.spec_filter_check').attr('checked') != undefined ){
			$(this).children('.spec_filter_check').removeAttr('checked');
		}else{
			$(this).children('.spec_filter_check').attr('checked','checked');
		}

		$(this).children('.spec_filter_check').trigger('change');

	});

	// For storing the applied filter
	window.filters={};
	window.page_num =2;

	//Updating the widnow.filter vaiable and calling ajax function

	function filter(spec,val,that){

		$("#dummy_filter_holder").css({"position":"relative"});

		if (spec in filters){
			if (filters[spec].indexOf(val) == -1){
				filters[spec].push(val)
				$(that).addClass('active');
				$(that).children(".icon-remove").removeClass("hidden");

			}else{
				filters[spec].splice(filters[spec].indexOf(val),1)
				$(that).removeClass('active');
				$(that).children(".icon-remove").addClass("hidden");
			}
		}
		else{
			filters[spec]=[]
			filters[spec].push(val)
			$(that).addClass('active');
			$(that).children(".icon-remove").removeClass("hidden");
		}
		// Ajax Call for selected filter
		call_filter(spec,val,that);
	}

	// TO load more items
	function load_more(){

		$("#dummy_filter_holder").css({"position":"relative"});

		$("#load_more div").html(' <img src="/assets/ajax_small.gif"/> Loading more items..! Please wait');
		$.ajax({
			url:window.filterurl ,
			data:{"filter": filters ,page: page_num},
			type:"post",
			dataType:"json",
			success:function(data){

				window.page_num += 1;
				var templ=_.template($("#item_template").html(),{data:data});
				$("#load_more_content").replaceWith(templ);
				if (data.next == 1){
					$("#load_more div").html("Load more...");
				}else{
					$("#load_more div").hide();
				}
				$("#filter_loading_image").addClass('hide');
			},
			error:function(){
				showNotifications("Something went wrong. Try again");
				$("#filter_loading_image").addClass('hide');
				$("#load_more div").html("Load more...");
			}
		});

	}

	// Main function working out the filter
	function call_filter(spec,val,that){

		showNotifications(' <img src="/assets/ajax_small.gif"/> Applying filters Please wait..!');

		showOverlay();
		$.ajax({
			url:window.filterurl ,
			data:{"filter": filters ,page : 1 },
			type:"post",
			dataType:"json",
			success:function(data){


				var fil_url =[];
				_.each(filters,function(val,key){
					if (typeof(val) == 'Array' && val.length > 0 ){
						fil_url .push(key + '=' + val.join(","));
					}
					else if (val.length > 0){
						fil_url .push(key + '='+ val);
					}

					hideNotifications();
				});

				// Pushing into the histroy
				History.pushState('filter','filter',window.filterurl + '/'  + fil_url.join('&'));

				window.page_num =  2 ;

				var templ=_.template($("#item_template").html(),{data:data});
				$("#items").html(templ);
				$("#filter_loading_image").removeClass('hide');
			},
			error:function(){
				showNotifications("Something went wrong. Try again");
				$("#filter_loading_image").addClass('hide');
				filters[spec].splice(filters[spec].indexOf(val),1)
				$(that).removeClass('active');
				$(that).children(".icon-remove").addClass("hidden");

			}
		});
	}

	// Sorting dropdown (price range)
	$("#filter_sort").change(function(){
		 filters['sort'] = $("#filter_sort").val();
		 call_filter('sort',$("#filter_sort").val(),$("#filter_sort"));
	});

 	// bind load more
 	$("#load_more").die().live('click',load_more);

 	// Showing overlay while fetching contents
	showOverlay = function(){

		$("#filter_loading_image").removeClass('hide');



		// $("#overlay").css({
		// 	"width":$("#items").outerWidth(),
		// 	"height":$("#items").outerHeight(),
		// 	"top":$("#items").top,
		// 	"left":$("#items").offset().left,
		// });
		// $("#overlay").show();
	}




	// ***********************
	// fixinf the filter



				//$(window).scroll(function(){



			// 			if ($("#dummy_filter_holder").length == 0) return false;

			// 			var stop =  $(window).scrollTop() > ($("#dummy_filter_holder").offset().top + $("#dummy_filter_holder").height() -100) ;
			// 			var sbot = ($(window).scrollTop() + ($(window).height()/2) ) < ($("#dummy_filter_holder").offset().top ) ;
			// 			if ( stop){
			// 				$("#pull_here").css({'display':'block','position':'absolute'});

			// 				$("#pull_here").clearQueue().animate({
			// 					top: ( $(window).scrollTop() + ( $(window).height()/2)  ),
			// 					"margin-left" : "0px"
			// 				});


			// 			}else if(sbot){
			// 				pull_here();

			// 			}
			// 			else{
			// 				$("#pull_here").css({'display':'none',"margin-left" : ""});
			// 			}
			// 	});

			// 	window.filter_initial_height = $("#dummy_filter_holder").offset().top;

			// 	pull_here = function(){


			// 		$("#pull_here").css({'display':'none',"margin-left" : ""});

			// 		if ( ($(window).scrollTop() +  $("#dummy_filter_holder").outerHeight()  ) > $(document).height() ){

			// 				$("#dummy_filter_holder").css({'position':'absolute'});

			// 				$("#dummy_filter_holder").clearQueue().animate({
			// 						top:(  ($(document).height() -130) - $("#dummy_filter_holder").outerHeight()  ) ,
			// 						'width':'105px'
			// 					});
			// 		}else{
			// 				$("#dummy_filter_holder").css({'position':'absolute'});


			// 		if ($(window).scrollTop() < filter_initial_height) {
			// 				$("#dummy_filter_holder").clearQueue().animate({top:filter_initial_height,'position':'relative','width':'auto'},200);
			// 		}else{

			// 				$("#dummy_filter_holder").clearQueue().animate({top:$(window).scrollTop() ,
			// 							'width':'105px'
			// 						},200);
			// 		}


			// 	}
			// }

			// 	$("#pull_here").click(pull_here);

// end of fixinf

});