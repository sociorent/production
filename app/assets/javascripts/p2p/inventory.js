$(document).ready(function(){

      $(".delete_item").live("click",function(){
        var that = this;
        
        showNotifications('Deleting item.Please wait..!');

        $.ajax({
          url:"/p2p/items/" + $(this).attr("itemid"),
          type:"delete",
          dataType:"json",
          data:{"authenticity_token" : AUTH_TOKEN},
          success:function(data){
            console.log(data);
            if (data.status == 1){
              showNotifications('Listing deleted');
              $(that).closest('li').fadeOut(1000);
            }
            else{
              showNotifications('There was an error in deleting');
            }
          }
        });


      });


      $('.disapprove_item').on('click',function(){
          var that  = $(this);
          showNotifications('Please wait while we process it');
          
          $.ajax({
            url:'/p2p/approve/disapprove',
            data:{id: that.attr('itemid')},
            dateType:'json',
            type:'post',
            success:function(data){
                if (data ==  1) {
                  showNotifications('Item Disapproved');
                  that.parent().parent().fadeOut(1000);
                }
                else{
                  showNotifications('Something went wrong');
                }
            },
            error:function(){
                showNotifications('Something went wrong');
            }
          });
      });


      $('.approve_item').on('click',function(){
          var that  = $(this);

          showNotifications('Please wait while we process it');

          $.ajax({
            url:'/p2p/approve/approve',
            data:{id: that.attr('itemid')},
            dateType:'json',
            type:'post',
            success:function(data){
                if (data ==  1) {
                  showNotifications('Item Approved');
                  that.parent().parent().fadeOut(1000);
                }
                else{
                  showNotifications('Something went wrong');
                }
            },
            error:function(){
                showNotifications('Something went wrong');
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
        url:'/p2p/users/list',
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
            window.location = '/p2p/mystore/sold/user/' + elem.item.value
            return elem.item.label;
        },
        focus:function(){
          
        }
      });


});
          


