var map;

function initMap() {
	map = new google.maps.Map(document.getElementById('map'), {
		center: {lat: 40.397, lng: -100.644},
		zoom: 5
	});
}

var socket = io.connect('http://' + document.domain + ':' + location.port, {'force new connection': true});
socket.on('connect', function() {
	socket.emit('readyMessage', {data: 'I\'m connected!'});
});

socket.on('newPoints', function(data) {
	var marker = new google.maps.Marker({
		position: {lat: data["lat"], lng: data["long"]},
		map: map,
		title: 'Hello World!'
	});

	console.log($(".sidebarlist"));

	$(".sidebarlist").append("<li>" + data["title"] + "</li>");
});

socket.on('disconnect', function() {
	console.log('reconnecting');
});
