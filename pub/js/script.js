$("#login").click(function() {
	$("#login-box").toggle('slow');
	$("#signup-box").hide('slow');
});
$("#signup").click(function() {
	$("#signup-box").toggle('slow');
	$("#login-box").hide('slow');
});

$("#sqlButton").click(function() {
	$('.main').toggle('fast').css( "display", "block" );
	$('.instructions').hide('fast');
	$('.about').hide('fast');
});
$("#instructionsButton").click(function() {
	$('.instructions').toggle('fast');
	$('.main').hide('fast');
	$('.about').hide('fast');
});
$("#aboutButton").click(function() {
	$('.about').toggle('fast');
	$('.instructions').hide('fast');
	$('.main').hide('fast');
});
