$(document).ready ->
  $("#linkpreview_form").on("ajax:success", (e, data, status, xhr) ->
    $("#urlb").removeClass("disabled").addClass("btn-primary");
    $('#manual_wish').show();
    $("#modal-default-body").show();
    $("#loading").remove();
    $('#url').val("");

    $('.carousel-inner').html('')
    $("#item_title").val("");
    $("#item_link").val("");
    $("#item_remote_image_url").val("");
    $("#item_via").val("");
    $("#item_price").val("");

    $('label[for="item_image"]').hide();
    $("#item_image").hide();
    $('label[for="item_remote_image_url"]').hide();
    $("#item_remote_image_url").hide();
    $('label[for="item_link"]').hide();
    $("#item_link").hide();

    i = 0
    data.images.map (e) ->
      if i is 0
        $('.carousel-inner').append("<div class='item active'><img src='#{e}' /></div>")
      else
        $('.carousel-inner').append("<div class='item'><img src='#{e}' /></div>")

      i += 1
    $("#item_title").val(data.title);
    $("#item_link").val(data.url);
    $("#item_price").val(data.price);
    $("#item_remote_image_url").val($(".carousel-inner .active img").attr("src"));
    $("#item_via").val("linkpreview");
    $('#commit').hover ->
    	$("#item_remote_image_url").val($(".carousel-inner .active img").attr("src"));

    $('#linkpreview').hide()
    $('#item_fields').show()

    if data.images.length == 0
        $('.carousel-inner').html('')
        $("#item_remote_image_url").val("");
        $('label[for="item_image"]').show();
        $("#item_image").show();
        $("#item_via").val("no_image")
        $("#imgPreview").hide()

    ###
    IF YOU WANT TO GIVE ERROR WHEN NO IMAGES FOUND UNCOMMENT BELOW
    $('#linkpreview').hide() if data.images.length > 0
    $('#item_fields').show() if data.images.length > 0

    if data.images.length == 0
        $('.carousel-inner').html('')
        $("#item_title").val("");
        $("#item_link").val("");
        $("#item_remote_image_url").val("");
        $("#item_via").val("");
        $("#urlb").removeClass("disabled")
        $('#manual_wish').show();
        $("#modal-default-body").show();
        $("#loading").remove();
        $('#url').val("");
        $('label[for="item_image"]').show();
        $("#item_image").show();
        $('label[for="item_remote_image_url"]').show();
        $("#item_remote_image_url").show();
        $('label[for="item_link"]').show();
        $("#item_link").show();
        alert('Damn, could not find any good images!');
    ###


  	).bind "ajax:error", (e, xhr, status, error) ->
        $("#modal-default-body").show();
        $("#loading").remove();
        $("#urlb").removeClass("disabled").addClass("btn-primary");
        $('#manual_wish').show();
        $('#url').val("");
        alert('Damn, could not find any good images!');