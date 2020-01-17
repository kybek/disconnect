extends Node

# Default game port
const DEFAULT_PORT = 6007

# Max number of players
const MAX_PEERS = 12

# Name for my player
var player_name: String = "The Warrior"

var player_count: int = 1

# Names for remote players in id:name format
var players: Dictionary = {}

var player_names: Dictionary = {}

remote var current_turn: int = 0

# Signals to let lobby GUI know what's going on
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

# Callback from SceneTree
func _player_connected(id):
	# Registration of a client beings here, tell the connected player that we are here
	rpc_id(id, "register_player", player_name)

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
remote func register_player(new_player_name: String) -> void:
	var id = get_tree().get_rpc_sender_id()
	print(str(id) + " is joined as " + new_player_name)
	players[id] = new_player_name
	emit_signal("player_list_changed")


func unregister_player(id) -> void:
	players.erase(id)
	emit_signal("player_list_changed")


remote func pre_start_game(spawn_points: Dictionary, rows: int, cols: int) -> void:
	player_names = players
	player_names[get_tree().get_network_unique_id()] = player_name
	
	# Change scene
	var world = load("res://src/world.tscn").instance()
	get_tree().get_root().add_child(world)
	get_tree().get_root().get_node("lobby").hide()
	world.get_node("board").make_board(rows, cols)
	
	var player_scene = load("res://src/player.tscn")
	
	player_count = len(spawn_points)
	
	for p_id in spawn_points:
		var spawn_pos = world.get_node("spawn_points/" + str(spawn_points[p_id])).position
		var player = player_scene.instance()
		
		player.set_name(str(p_id)) # Use unique ID as node name
		player.position=spawn_pos
		player.turn=spawn_points[p_id]
		player.set_network_master(p_id) #set unique id as master
		
		if p_id == get_tree().get_network_unique_id():
			# If node for this peer id, set name
			player.set_player_name(player_name)
		else:
			# Otherwise set name from peer
			player.set_player_name(players[p_id])
		
		if p_id == get_tree().get_network_unique_id():
			player.connect("next_turn", self, "_next_turn")
			player.can_input = true
		world.get_node("players").add_child(player)
	
	# Set up score
	for pn in players:
		world.get_node("score").add_player(pn, players[pn])

	if not get_tree().is_network_server():
		# Tell server we are ready to start
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()


remote func post_start_game() -> void:
	get_tree().set_pause(false) # Unpause and unleash the game!


var players_ready: Array = []


remote func ready_to_start(id: int) -> void:
	assert(get_tree().is_network_server())

	if not id in players_ready:
		players_ready.append(id)

	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()


func host_game(new_player_name: String) -> void:
	player_name = new_player_name
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(host)


func join_game(ip: String, new_player_name: String) -> void:
	player_name = new_player_name
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(host)


func get_player_list() -> Array:
	return players.values()


func get_player_name() -> String:
	return player_name


func begin_game(rows: int, cols: int) -> void:
	assert(get_tree().is_network_server())
	
	# Create a dictionary with peer id and respective spawn points, could be improved by randomizing
	var spawn_points = {}
	spawn_points[1] = 0 # Server in spawn point 0
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	# Call to pre-start game with the spawn points
	for p in players:
		rpc_id(p, "pre_start_game", spawn_points, rows, cols)
	
	pre_start_game(spawn_points, rows, cols)


func end_game() -> void:
	if has_node("/root/world"): # Game is in progress
		# End it
		get_node("/root/world").queue_free()

	emit_signal("game_ended")
	players.clear()
	get_tree().set_network_peer(null) # End networking


func update_turn() -> void:
	rset("current_turn", current_turn)
	get_tree().get_root().get_node("world/score").update_current_player()


func _next_turn():
	assert(player_count > 0)
	current_turn = (current_turn + 1) % player_count
	update_turn()


func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
