extends Control

var config : ConfigFile = null


func load_config() -> bool:
	config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	
	if err == OK:
		get_node("connect/ip").text = config.get_value("network", "ip", "127.0.0.1")
		get_node("connect/name").text = config.get_value("network", "username", "Unnamed")
		
		config.save("user://settings.cfg")
		return true
	
	return false


func save_config() -> void:
	config = ConfigFile.new()
	
	config.set_value("network", "ip", get_node("connect/ip").text)
	config.set_value("network", "username", get_node("connect/name").text)
	
	config.save("user://settings.cfg")


func _ready():
	load_config()
	
	gamestate.connect("connection_failed", self, "_on_connection_failed")
	gamestate.connect("connection_succeeded", self, "_on_connection_success")
	gamestate.connect("player_list_changed", self, "refresh_lobby")
	gamestate.connect("game_ended", self, "_on_game_ended")
	gamestate.connect("game_error", self, "_on_game_error")


func _on_host_pressed():
	if get_node("connect/name").text == "":
		get_node("connect/error_label").text = "Invalid name!"
		return

	get_node("connect").hide()
	get_node("players").show()
	get_node("connect/error_label").text = ""

	var player_name = get_node("connect/name").text
	var _class_name = get_node("class_selection/class_name").text
	
	save_config()
	
	gamestate.host_game(player_name)
	refresh_lobby()


func _on_join_pressed():
	if get_node("connect/name").text == "":
		get_node("connect/error_label").text = "Invalid name!"
		return

	var ip = get_node("connect/ip").text
	if not ip.is_valid_ip_address():
		get_node("connect/error_label").text = "Invalid IPv4 address!"
		return

	get_node("connect/error_label").text=""
	get_node("connect/host").disabled = true
	get_node("connect/join").disabled = true

	var player_name = get_node("connect/name").text
	var _class_name = get_node("class_selection/class_name").text
	
	save_config()
	
	gamestate.join_game(ip, player_name)


func _on_connection_success():
	get_node("connect").hide()
	get_node("players").show()


func _on_connection_failed():
	get_node("connect/host").disabled = false
	get_node("connect/join").disabled = false
	get_node("connect/error_label").set_text("Connection failed.")


func _on_game_ended():
	show()
	get_node("connect").show()
	get_node("players").hide()
	get_node("connect/host").disabled = false


func _on_game_error(errtxt):
	get_node("error").dialog_text = errtxt
	get_node("error").popup_centered_minsize()


func refresh_lobby() -> void:
	var players = gamestate.get_player_list()
	players.sort()
	get_node("players/list").clear()
	get_node("players/list").add_item(gamestate.get_player_name() + " (You)")
	for p in players:
		get_node("players/list").add_item(p)
	
	get_node("players/start").disabled = not get_tree().is_network_server()


func _on_start_pressed():
	gamestate.begin_game(int(get_node("connect/board_sizes/rows").text), int(get_node("connect/board_sizes/cols").text))


func _on_warrior_pressed():
	get_node("class_selection/class_name").text = "warrior"
