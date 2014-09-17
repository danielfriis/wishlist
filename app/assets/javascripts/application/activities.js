$(document).ready(function() {
	$("#activities_popover").bind("click", function() {
		var e = $(this);
		e.unbind("click");
		var see_more = "<div class='activity text-center'><a href='/activities'>See more</a></div>"
		$.ajax({
		  url: e.data('url'),
		  success: function(d) {
		    e.popover({ content: d + see_more }).popover("show");
		  }
		});
		return false
	});
});