#= require jquery

window.onmessage = (e) ->
  console.log e.data
  $('[data-title]').text e.data.title
  $('[data-price]').text e.data.price
  $('[data-picture]').attr 'src', e.data.picture
