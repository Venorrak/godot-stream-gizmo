extends Node

var json : JSON = JSON.new()
var num_socket : int = 5555
var server = WebSocketPeer.new()

func _ready() -> void:
	server.connect_to_url("ws://192.168.0.16:5963")
	
func _process(delta: float) -> void:
	server.poll()
	var state = server.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while server.get_available_packet_count():
			var pkt = server.get_packet()
			var data = json.parse_string(str(pkt.get_string_from_utf8()))
			#TODO debugger logger
			SignalBus.websocketMessage.emit(data)
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = server.get_close_code()
		var reason = server.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
