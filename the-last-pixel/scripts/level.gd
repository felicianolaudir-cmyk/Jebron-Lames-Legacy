extends Node2D
## Script comum a todos os níveis: HUD, mortes, vitória, reinício.

const LevelList := preload("res://scripts/levels.gd")

## Nome mostrado no HUD.
@export var level_name := "Nível"

# Partilhado entre níveis
static var total_deaths := 0

@onready var player: CharacterBody2D = $Player
@onready var door: Area2D = $Door
@onready var hud_label: Label = $HUD/Info
@onready var win_panel: Control = $HUD/WinPanel
@onready var win_label: Label = $HUD/WinPanel/WinLabel

var won := false


func _ready() -> void:
	if scene_file_path == LevelList.first():
		total_deaths = 0
	win_panel.visible = false
	player.died.connect(_on_player_died)
	door.reached.connect(_on_door_reached)
	_update_hud()
	_fade_in()


func _fade_in() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	var fade := ColorRect.new()
	fade.color = Color(0, 0, 0, 1)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(fade)
	add_child(layer)
	var tween := create_tween()
	tween.tween_property(fade, "color:a", 0.0, 0.4)
	tween.finished.connect(layer.queue_free)


func _update_hud() -> void:
	hud_label.text = "%s      Deaths: %d      ← → / A D: move    Space / ↑ / W: Jump    R: restart level" % [level_name, total_deaths]


func _on_player_died() -> void:
	total_deaths += 1
	_update_hud()


func _on_door_reached() -> void:
	# Porta com próximo nível trata da transição sozinha; sem próximo nível = fim.
	if door.get_next_level() != "":
		return
	won = true
	win_label.text = "Jebron Lames Legacy\n\nYOU DID IT!\nDeaths: %d\n\nEnter or R to play again" % total_deaths
	win_panel.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if won and (event.physical_keycode == KEY_R or event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER):
			total_deaths = 0
			get_tree().change_scene_to_file(LevelList.first())
		elif event.physical_keycode == KEY_R:
			get_tree().reload_current_scene()
