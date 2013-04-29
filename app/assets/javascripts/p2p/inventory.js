$(document).ready(function(){

      $(".delete_item").live("click",function(){
        var that = this;

        showNotifications('Deleting item.Please wait..!');

        show_div_overlay($(that).closest('li'));


        $.ajax({
          url:"/street/items/" + $(this).attr("itemid"),
          type:"delete",
          dataType:"json",
          data:{"authenticity_token" : AUTH_TOKEN},
          success:function(data){
            console.log(data);
            if (data.status == 1){
              showNotifications('Listing deleted');
              $(that).closest('li').fadeOut(1000);
              hide_div_overlay();
            }
            else{
              showNotifications('There was an error in deleting');
              hide_div_overlay();
            }
          }
        });


      });



      $('.disapprove_item').on('click',function(){
          var that  = $(this);


          show_div_overlay($(that).closest('li'));

          $("#disapprove_reason_modal").modal("show");
          $("#disapprove_item_with_reason").on("click",function(){
            showNotifications('Please wait while we process it');
            $.ajax({
              url:'/street/approve/disapprove',
              data:{id: that.attr('itemid'),"disapprove":$("#reason_disapprove").val()},
              dateType:'json',
              type:'post',
              success:function(data){
                  if (data ==  1) {
                    $("#disapprove_reason_modal").modal("hide");
                    showNotifications('Item Disapproved');
                    $("#reason_disapprove").val("");
                    that.closest('li').fadeOut(1000);
                    hide_div_overlay();
                  }
                  else{
                    showNotifications('Something went wrong');
                    hide_div_overlay();
                  }
              },
              error:function(){
                  showNotifications('Something went wrong');
                  hide_div_overlay();
              }
            });
          });
      });


      $('.approve_item').on('click',function(){
          var that  = $(this);

          showNotifications('Please wait while we process it');

          show_div_overlay($(that).closest('li'));

          $.ajax({
            url:'/street/approve/approve',
            data:{id: that.attr('itemid')},
            dateType:'json',
            type:'post',
            success:function(data){
                if (data ==  '1') {
                  showNotifications('Item Approved');
                  that.closest('li').fadeOut(1000);
                  hide_div_overlay();
                }
                else{
                  showNotifications('Something went wrong');
                  hide_div_overlay();
                }
            },
            error:function(){
                showNotifications('Something went wrong');
                hide_div_overlay();
            }
          });
      });




    window.cache={}

      $("#user_id").autocomplete({
        minLength: 2,
        source: function( request, response ) {
          var term = request.term;
          if ( term in cache ) {
            response( cache[ term ] );
            return;
          }

              $.ajax({
                url:'/street/users/list',
                data:{q:term},
                dataType:"json",
                type:'post',
                success:function(data){
                      cache[ term ] = data;
                        response( data );

                }
              });

        },
        select:function(event,elem){
            window.location = '/street/mystore/sold/user/' + elem.item.value
            return elem.item.label;
        },
        focus:function(){

        }
      });


});
