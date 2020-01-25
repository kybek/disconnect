extends Node

# Default game port
const DEFAULT_PORT = 6007

# Max number of players
const MAX_PEERS = 12

# Name for myself
var player_name: String = "The Warrior"

# My power
var power_name: String = "none"

# Number of players
var player_count: int = 1

# Names for remote players in id:name format (excluding self)
var players: Dictionary = {}

# Names for players in id:name format
var player_names: Dictionary = {}

# Id's for players in turn:id format
var player_turns: Dictionary = {}

# Powers for players in id:power format
var player_powers: Dictionary = {}

# Number of power uses left for players in id:count format
var player_power_uses: Dictionary = {}

# The world (and the board as a child)
var world: Node = null

# Colors for players in id:color format
remote var player_colors: Dictionary = {}

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
	rpc_id(id, "register_player", player_name, power_name)

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
remote func register_player(new_player_name: String, new_power_name: String) -> void:
	if not new_power_name in powers.power_names:
		print("There is no power called " + new_power_name + ", " + new_player_name + " is cheating.")
		return
	
	var id = get_tree().get_rpc_sender_id()
	print(str(id) + " is joined as " + new_player_name)
	players[id] = new_player_name
	player_powers[id] = power_name
	emit_signal("player_list_changed")


func unregister_player(id) -> void:
	players.erase(id)
	player_powers.erase(id)
	emit_signal("player_list_changed")

# Set the game world and players for given parameters
remote func pre_start_game(order: Dictionary, rows: int, cols: int) -> void:
	player_names = players
	player_names[get_tree().get_network_unique_id()] = player_name
	player_powers[get_tree().get_network_unique_id()] = power_name
	
	# Change scene
	world = preload("res://src/world.tscn").instance()
	get_tree().get_root().add_child(world)
	get_tree().get_root().get_node("lobby").hide()
	world.get_node("board").make_board(rows, cols)
	
	var player_scene = preload("res://src/player.tscn")
	
	player_count = len(order)
	
	for player_id in order:
		var player = player_scene.instance()
		
		player.set_name(str(player_id)) # Use unique ID as node name
		player.my_turn = order[player_id]
		player.color = player_colors[player_id]
		player_turns[order[player_id]] = player_id
		player.set_network_master(1) # set server (ID: 1) as master
		
		if player_id == get_tree().get_network_unique_id():
			# If node for this peer id, set name
			player.player_name = player_name
			player.power_name = power_name
		else:
			# Otherwise set name from peer
			player.player_name = player_names[player_id]
			player.power_name = player_powers[player_id]
		
		player.power_uses = powers.cap[power_name]
		player_power_uses[player_id] = player.power_uses
		
		if player_id == get_tree().get_network_unique_id():
			player.can_input = true
		
		world.get_node("players").add_child(player)
	
	# Set up score
	for player_id in players:
		world.get_node("score").add_player(player_id, players[player_id], player_powers[player_id])
	
	world.get_node("score").update_current_player()

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


func host_game(new_player_name: String, new_player_power: String) -> void:
	player_name = new_player_name
	power_name = new_player_power
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(host)


func join_game(ip: String, new_player_name: String, new_player_power: String) -> void:
	player_name = new_player_name
	power_name = new_player_power
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(host)


func get_player_list() -> Array:
	return players.values()


func get_player_name() -> String:
	return player_name


func begin_game(rows: int, cols: int) -> void:
	assert(get_tree().is_network_server())
	
	randomize()
	
	# Server
	player_colors[get_tree().get_network_unique_id()] = Color(randf(), randf(), randf(), 1.0)
	
	for player_id in players:
		player_colors[player_id] = Color(randf(), randf(), randf(), 1.0)
	
	rset("player_colors", player_colors)
	
	var turns_to_pick_from: Array = []
	
	for i in range(0, len(player_colors)):
		turns_to_pick_from.append(i)
	
	turns_to_pick_from.shuffle()
	
	var order = {}
	
	# Server
	order[get_tree().get_network_unique_id()] = turns_to_pick_from[0]
	
	var order_id = 1
	
	for player_id in players:
		order[player_id] = turns_to_pick_from[order_id]
		order_id += 1
	
	# Call to pre-start game with the spawn points
	for player_id in players:
		rpc_id(player_id, "pre_start_game", order, rows, cols)
	
	pre_start_game(order, rows, cols)


func end_game() -> void:
	if has_node("/root/world"): # Game is in progress
		# End it
		get_node("/root/world").queue_free()

	emit_signal("game_ended")
	players.clear()
	get_tree().set_network_peer(null) # End networking


func update_turn() -> void:
	rset("current_turn", current_turn)


func _next_turn() -> void:
	assert(player_count > 0)
	current_turn = (current_turn + 1) % player_count
	update_turn()


func _prev_turn() -> void:
	assert(player_count > 0)
	current_turn = (current_turn - 1 + player_count) % player_count
	update_turn()


remote func _make_move(player_id: int, col: int) -> bool:	
	return world.get_node("board").move(col, player_names[player_id], player_id, player_colors[player_id])


sync func request_move(col: int) -> bool:
	if (not get_tree().is_network_server()) or get_tree().get_network_unique_id() != 1:
		print_debug("This node is not a server")
		return false
	
	var player_id = get_tree().get_rpc_sender_id()
	
	if player_id == 0:
		player_id = 1
	
	if not player_id in player_names:
		print_debug("You are not a real player")
		return false
	
	if player_turns[current_turn] != player_id:
		print_debug("This is not your turn")
		return false
	
	if not _make_move(player_id, col):
		print_debug("Invalid move")
		return false
	
	rpc("_make_move", player_id, col)
	_next_turn()
	return true


remote func _rewind_move() -> bool:	
	print_debug("Rewinding last moves")
	for count in range(player_count):
		if not world.get_node("board").undo_last_move():
			return false
	
	return true


sync func _decrease_power_count(player_id: int) -> void:
	player_power_uses[player_id] -= 1
	world.get_node("players").get_node(str(player_id)).power_uses -= 1


sync func request_rewind() -> bool:
	if (not get_tree().is_network_server()) or get_tree().get_network_unique_id() != 1:
		print_debug("This node is not a server")
		return false
	
	var player_id = get_tree().get_rpc_sender_id()
	
	if player_id == 0:
		player_id = 1
	
	if not player_id in player_names:
		print_debug("You are not a real player")
		return false
	
	if player_turns[current_turn] != player_id:
		print_debug("This is not your turn")
		return false
	
	if player_powers[player_id] != "rewind":
		print_debug("This is not your power")
		return false
	
	if player_power_uses[player_id] == 0:
		print_debug("You have used all of your power")
		return false
	
	if not _rewind_move():
		print_debug("Rewind failed")
		return false
	
	rpc("_decrease_power_count", player_id)
	rpc("_rewind_move")
	world.get_node("score").rpc("decrease_power_uses", player_id)
	return true



func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
