jQuery ->
  $('.user_list_wishes').sortable
  	connectWith: ".user_list_wishes"
  	items: ".user_list_wish"
  	update: (e, ui) ->
      item_id = ui.item.data('item-id')
      position = ui.item.index()
      list_id = $(this).data('list-id')
      $.ajax(
        type: 'POST'
        url: $(this).data('update-url')
        dataType: 'json'

        # the :wish hash gets passed to @wish.attributes
        # row_order is the default column name expected in ranked-model
        data: { id: item_id, wish: { row_order_position: position, list_id: list_id } }
      )