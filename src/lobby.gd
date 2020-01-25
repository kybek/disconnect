extends Control

var config : ConfigFile = null

# Load configuration file if stored in user://settings.cfg
func load_config() -> bool:
	config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	
	if err == OK:
		get_node("connect/ip").text = config.get_value("network", "ip", "127.0.0.1")
		get_node("connect/name").text = config.get_value("network", "username", "Unnamed")
		randomize()
		get_node("connect/color").color.r = config.get_value("player", "color_r", randi() % 256)
		get_node("connect/color").color.g = config.get_value("player", "color_g", randi() % 256)
		get_node("connect/color").color.b = config.get_value("player", "color_b", randi() % 256)
		return true
	else:
		print_debug(err)
		return false

# Save current configuration
func save_config() -> bool:
	config = ConfigFile.new()
	config.set_value("network", "ip", get_node("connect/ip").text)
	config.set_value("network", "username", get_node("connect/name").text)
	config.set_value("player", "color_r", get_node("connect/color").color.r)
	config.set_value("player", "color_g", get_node("connect/color").color.g)
	config.set_value("player", "color_b", get_node("connect/color").color.b)
	var err = config.save("user://settings.cfg")
	
	if err == OK:
		return true
	else:
		print_debug(err)
		return false


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

	var player_name: String = get_node("connect/name").text
	var power_name: String = get_node("power_selection/power_name").text
	var player_color: Color = get_node("connect/color").color
	
	save_config()
	
	gamestate.host_game(player_name, power_name, player_color)
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

	var player_name: String = get_node("connect/name").text
	var power_name: String = get_node("power_selection/power_name").text
	var player_color: Color = get_node("connect/color").color
	
	save_config()
	
	gamestate.join_game(ip, player_name, power_name, player_color)


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


func _on_none_pressed():
	get_node("power_selection/power_name").text = "none"


func _on_rewind_pressed():
	get_node("power_selection/power_name").text = "rewind"
