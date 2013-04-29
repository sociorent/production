/*
//= require dataTables/jquery.dataTables
//= require dataTables/jquery.dataTables.bootstrap
*/


	$(document).ready(function(){


			oVendorTable = $('#city_table').dataTable({
				"sDom": "<r><f>t<i><p>",
			  	"sAjaxSource": '/street/admin/cities' ,
	            "bFilter":false,
	         	"iDisplayLength" : 20,
	            "bAutoWidth": false,
	            "sPaginationType": "bootstrap",
			  	"bProcessing": true,
	    	  	"bServerSide": true,
	     	  	"aoColumns": [{ sWidth: '25%',"bSortable":true },{ sWidth: '25%',"bSortable":false},{ sWidth: '25%',"bSortable":false}],
		  		"fnServerParams": function ( aoData ) {
		  				if ($.trim($("#search_city").val()).length != 0){
            		aoData.push( { "name" : "searchq" ,"value" : $("#search_city").val() } );
            	}
          		}
			});

			$("#search_city").keyup(function(){
				oVendorTable.fnDraw();
			});

	    	$('.master_check').on("change",function(){
	    		var tbl=$("#" + $(this).attr("tbl")+ "_id");
	    		if (this.checked){
	    			 tbl.find("tbody tr td .vendor_check").attr("checked","checked");
	    		}else{
							tbl.find("tbody tr td .vendor_check").removeAttr("checked");
	    		}
	    	});

			$(".refresh_messsage").click(function(){
					oVendorTable.fnDraw();
			});


		// delete selected messages
		$('.delete_vendor_user').click(function(){
			var that = $(this);

			var delete_messages = [];

			//get all the messages that are checked
			_.each($("#" + that.attr("tbl") + "_id").find('.vendor_check'),function(elm){
					if ($(elm).attr('checked')){
						delete_messages.push($(elm).attr('userid'));
					}
			});


			//if nothing is selected reutnr
			if (delete_messages.length < 1 ){
				alert('Please select atleast one User');
				$("#" + that.attr('tbl') + " .vendor_check").removeAttr('checked');
				return false;
			}

			showNotifications("Processing  " + delete_messages.length + " users.! Please wait");
			// delete the messages using ajax
			var vendorurl = ""
			if (that.attr('tbl') == 'vendor'){
				vendorurl = '/street/vendors/remove'
			}else{
				vendorurl = '/street/vendors/set'
			}

			$.ajax({
				url:vendorurl ,
				data:{userid:delete_messages , tbl: that.attr('tbl')},
				type:'post',
				dataType:'json',
				success:function(data){

					// reset the checkbox
					$("#" + that.attr('tbl') + "_id").find(".vendor_check").removeAttr('checked');

					// redraw the table
						oVendorTable.fnDraw();
						oUserTable.fnDraw();

					// #hide the overloy

					if (delete_messages.length > 0)
						showNotifications("Successfully Processed" + delete_messages.length + " User");

					$("#overlay").hide();
				},
				error:function(){
					showNotifications("Cannot Process command");
					$("#overlay").hide();
				}
			});

		});


	});

