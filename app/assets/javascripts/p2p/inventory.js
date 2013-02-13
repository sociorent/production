      $(".delete_item").live("click",function(){
        var that = this;
        $.ajax({
          url:"/p2p/items/" + $(this).attr("itemid"),
          type:"delete",
          dataType:"json",
          data:{"authenticity_token" : AUTH_TOKEN},
          success:function(data){
            console.log(data);
            if (data.status == 1){
              $(that).parent().remove();
            }
          }
        });
      });
          
