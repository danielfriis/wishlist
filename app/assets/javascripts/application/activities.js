$(document).ready(function() {
	$("#activities_popover").bind("click", function() {
		var e = $(this);
		e.unbind("click");
		var see_more = "<div class='activity text-center'><a href='/activities'>See more</a></div>"
		var nothing = "<div class='activity text-center'>No new activity.<br/> Try following more people <a href='/users'>here</a></div>"
		$.ajax({
		  url: e.data('url'),
		  success: function(d) {
		  	if (d) {
		  		e.popover({ content: d + see_more }).popover("show");
		  	} else {
	  			e.popover({ content: nothing }).popover("show");
	  		}
		  }
		});
		return false
	});
});