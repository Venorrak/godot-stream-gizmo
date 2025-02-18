extends Node
var socket = PacketPeerUDP.new()
var num_socket = 12345
var json = JSON.new()
signal messageReceived

func _init():
	socket.bind(num_socket, "127.0.0.1", 8300)
	if(socket.is_socket_connected() == true):
		print("An error occurred listening on port ", num_socket)
	else:
		print("Listening on port ", num_socket, " on localhost")

func _process(delta):
	if socket.get_available_packet_count() > 0:
		var pkt = socket.get_packet().get_string_from_ascii()
		pkt = json.parse_string(pkt)
		messageReceived.emit(pkt)
		#print(pkt)
