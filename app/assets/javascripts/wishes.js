$(document).ready(function(){
  $('.user_list_wishes').sortable({
   connectWith: ".user_list_wishes",
   items: ".user_list_wish",
   placeholder: "sortable_placeholder",
   update: function(e, ui)
   {
      if (this === ui.item.parent()[0]) 
      {
        item_id = ui.item.data('item-id');
        list_id = $(this).data('list-id');
        position = ui.item.index();
        $.ajax({
          type: 'POST',
          url: $(this).data('update-url'),
          dataType: 'json',
          data: { id: item_id, wish: { row_order_position: position, list_id: list_id } }
        })
      }
    }
  })
})