/*
//= require dataTables/jquery.dataTables
//= require dataTables/jquery.dataTables.bootstrap
*/


	$(document).ready(function(){



			oVendorTable = $('#payment_table').dataTable({
				"sDom": "<r><f>t<i><p>",
			  	"sAjaxSource": window.bought ,
	            "bFilter":false,
	         	"iDisplayLength" : 20,
	            "bAutoWidth": false,
  	            "sPaginationType": "bootstrap",
		  		"bProcessing": true,
	    	  	"bServerSide": true,
	  			"fnServerParams": function ( aoData ) {
		  				if ($.trim($("#search_payment").val()).length != 0){
            				aoData.push( { "name" : "searchq" ,"value" : $("#search_payment").val() } );
            			}
          		}
			});

			$("#search_payment").keyup(function(){
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
});

