// $("#url").keyup(function(e) {
//   var text = $("url").val();
//         $.get('/linkpreview', {text: text}, function(answer) {

//             $("h1").html(answer);
//         });
// });



$(document).ready(function() {
  $("#urlb").on('click', function() {
    var link = $("#url");
    setTimeout(function() {
      var text = $(link).val();
      // send url to service for parsing
      $.ajax('/linkpreview', {
        type: 'POST',
        dataType:'json',
        data: { url: text },
        success: function(data, textStatus, jqXHR) {
          $("#item_title").val(data['title']);
          $("#item_link").val(data['url']);
          $("#item_remote_image_url").val(data['img']);
        },
        error: function() { alert("error"); }
      }); 
    }, 100);
  });
});


// alert("Sejt");

// $("#linkpreview").bind('paste', function(e) {
//   var link = $(this);

//   setTimeout(function() {
//     var text = $(link).val();
     
//     // send url to service for parsing
//     $.ajax('/linkpreview', {
//       type: 'POST',
//       data: { url: text },
//       success: function(data,textStatus,jqXHR ) {
//         $("#preview-title").text(data['title']);
//       },
//       error: function() { alert("error"); }
//     }); 
//   }, 100);
// });