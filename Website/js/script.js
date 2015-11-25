$( document ).ready(function() {
    $.getJSON( "https://hka75ju5ch.execute-api.us-east-1.amazonaws.com/live/moments", function( data ) {
	  var items = [];
	  $.each( data.Items, function( key, val ) {
		items.push("<li class='list-group-item list-group-item-info container'><div class='instagram-list container'><h2>" + val.comment + "</h2><img class='instagram-img container' src='https://s3.amazonaws.com/awslambdacognitoapigatewaylecture/" + val.s3Object + "'/></div></li>");
	  });

	  $( "ul.list-group").append(items.join( "" ));
	});
});