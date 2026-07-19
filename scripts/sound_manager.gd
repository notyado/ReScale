extends Node

var pool_size = 5 
var players = []
var can_play_step = true
var step_cooldown = 0.3

var music_player = AudioStreamPlayer.new()

var bg_music = preload("res://assets/audio/bg_music.mp3")
var click_button = preload("res://assets/audio/click-b.ogg")
var enemy_step = preload("res://assets/audio/step.mp3")

func _ready():
	for i in range(pool_size):
		var p = AudioStreamPlayer.new()
		p.volume_db = -15
		add_child(p)
		players.append(p)
	
	add_child(music_player)
	music_player.volume_db = -20
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.stream = bg_music
	music_player.bus = "Music"
	music_player.play()
	
	_connect_buttons_recursive(get_tree().root)
	get_tree().node_added.connect(_on_node_added)

func _connect_buttons_recursive(node: Node):
	if node is TextureButton:
		if not node.pressed.is_connected(play_click):
			node.pressed.connect(play_click)
			
	for child in node.get_children():
		_connect_buttons_recursive(child)

func _on_node_added(node: Node):
	_connect_buttons_recursive(node)

func play_sound(stream: AudioStream):
	for p in players:
		if not p.playing:
			p.stream = stream
			p.play()
			return
	players[0].stream = stream
	players[0].play()

func play_click():
	play_click_sound()

func play_click_sound():
	play_sound(click_button)

func play_enemy_step():
	if not can_play_step:
		return
	play_sound(enemy_step)
	start_step_cooldown()

func start_step_cooldown():
	can_play_step = false
	await get_tree().create_timer(step_cooldown).timeout
	can_play_step = true
