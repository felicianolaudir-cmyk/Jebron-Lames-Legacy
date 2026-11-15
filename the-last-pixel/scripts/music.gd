extends Node
## Música de fundo global (autoload "Music").
## Sobrevive às trocas de cena, por isso não reinicia entre níveis nem ao morrer (R).
## Tecla M: liga/desliga o som.

const TRACK := preload("res://assets/music.mp3")
const VOLUME_DB := -8.0

var player: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var stream: AudioStreamMP3 = TRACK
	stream.loop = true
	player = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = VOLUME_DB
	player.bus = &"Master"
	add_child(player)
	# Segurança extra: se o loop do ficheiro falhar, volta a tocar.
	player.finished.connect(player.play)
	player.play()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_M:
		player.stream_paused = not player.stream_paused
