extends Node

# Default game port
const DEFAULT_PORT = 10567

# Max number of players
const MAX_PEERS = 12

# Name for my player
var player_name = "The Warrior"

# Name of the class
var _class_name = "warrior"

# Names for remote players in id:name format
var players = {}

var players_classes = {}

var players_turns = {}

var current_turn = 0

# Signals to let lobby GUI know what's going on
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

# Callback from SceneTree
func _player_connected(id):
	# Registration of a client beings here, tell the connected player that we are here
	rpc_id(id, "register_player", player_name, _class_name)

# Callback from SceneTree
func _player_disconnected(id):
	if has_node("/root/world"): # Game is in progress
		if get_tree().is_network_server():
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
	else: # Game is not in progress
		# Unregister this player
		unregister_player(id)

# Callback from SceneTree, only for clients (not server)
func _connected_ok():
	# We just connected to a server
	emit_signal("connection_succeeded")

# Callback from SceneTree, only for clients (not server)
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()

# Callback from SceneTree, only for clients (not server)
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")

# Lobby management functions

remote func register_player(new_player_name, new_player_class_name):
	var id = get_tree().get_rpc_sender_id()
	print(id)
	players[id] = new_player_name
	players_classes[id] = new_player_class_name
	emit_signal("player_list_changed")

func unregister_player(id):
	players.erase(id)
	players_classes.erase(id)
	emit_signal("player_list_changed")

remote func pre_start_game():
	# Change scene
	var world = load("res://src/world.tscn").instance()
	get_tree().get_root().add_child(world)

	get_tree().get_root().get_node("lobby").hide()

	var player_scene = load("res://src/player.tscn")
	
	var turns = []
	
	for x in range(len(players)):
		turns.append(x)
	
	turns.shuffle()
	
	var i = 0
	
	for p_nid in players.keys():
		var player = player_scene.instance()
		
		player.set_name(str(p_nid)) # Use unique ID as node name
		player.set_network_master(p_nid) #set unique id as master
		
		if p_nid == get_tree().get_network_unique_id():
			# If node for this peer id, set name
			player.set_player_name(player_name)
			player.set_class(_class_name)
			player.set_turn(turns[i])
		else:
			# Otherwise set name from peer
			player.set_player_name(players[p_nid])
			player.set_class(players_classes[p_nid])
			player.set_turn(turns[i])
		
		world.get_node("players").add_child(player)
		i += 1
	
	if not get_tree().is_network_server():
		# Tell server we are ready to start
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()

remote func post_start_game():
	get_tree().set_pause(false) # Unpause and unleash the game!

var players_ready = []

remote func ready_to_start(id):
	assert(get_tree().is_network_server())
	
	if not id in players_ready:
		players_ready.append(id)
	
	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()

func host_game(new_player_name, new_player_class_name):
	player_name = new_player_name
	_class_name = new_player_class_name
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(host)

func join_game(ip, new_player_name, new_player_class_name):
	player_name = new_player_name
	_class_name = new_player_class_name
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(host)

func get_player_list():
	return players.values()

func get_player_name():
	return player_name

func begin_game():
	assert(get_tree().is_network_server())
	
	players[get_tree().get_network_unique_id()] = "BEGIN_GAME"
	
	for p in players:
		rpc_id(p, "pre_start_game")
	
	pre_start_game()

func end_game():
	if has_node("/root/world"): # Game is in progress
		# End it
		get_node("/root/world").queue_free()

	emit_signal("game_ended")
	players.clear()
	get_tree().set_network_peer(null) # End networking

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")