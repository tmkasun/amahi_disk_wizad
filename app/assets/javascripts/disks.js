// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function() {

	$('.alert').hide();
	$('.alert').fadeIn(1500, function() {
		$(this).delay(6000).fadeOut(1000, function() {
		});
	});

});
