$(document).ready ->
  $("#linkpreview_form").on("ajax:success", (e, data, status, xhr) ->
    $('.carousel-inner').html('')
    $("#item_title").val("");
    $("#item_link").val("");
    $("#item_remote_image_url").val("");
    $("#item_via").val("");

    $('label[for="item_image"]').hide();
    $("#item_image").hide();
    $('label[for="item_remote_image_url"]').hide();
    $("#item_remote_image_url").hide();
    $('label[for="item_link"]').hide();
    $("#item_link").hide();

    i = 0
    data.img.map (e) ->
      if i is 0
        $('.carousel-inner').append("<div class='item active'><img src='#{e}' /></div>")
      else
        $('.carousel-inner').append("<div class='item'><img src='#{e}' /></div>")

      i += 1
    $("#item_title").val(data.title);
    $("#item_link").val(data.url);
    $("#item_remote_image_url").val($(".carousel-inner .active img").attr("src"));
    $("#item_via").val("linkpreview");
    $('#commit').hover ->
    	$("#item_remote_image_url").val($(".carousel-inner .active img").attr("src"));

    $('#linkpreview').hide() if data.img.length > 1
    $('#item_fields').show() if data.img.length > 1

  	).bind "ajax:error", (e, xhr, status, error) ->
    	$("#url").after "<p>Damn, no good images found!</p>"