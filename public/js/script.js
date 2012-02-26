/* Author:

*/

$(document).ready(function() {
	$('h1.linkable').click( function() {
		$("#"+this.id+"_data").toggle();
	});
});