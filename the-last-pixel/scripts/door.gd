extends Area2D
## Porta: ao tocar, passa para o próximo nível.
## Se "next_level" estiver vazio, é a porta final (o nível mostra o ecrã de vitória).

signal reached

const LevelList := preload("res://scripts/levels.gd")

## Opcional: força um nível específico. Vazio = usa a ordem de scripts/levels.gd.
@export_file("*.tscn") var next_level := ""
@export var fade_time := 0.4

var done := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if done or not body.is_in_group("player"):
		return
	done = true
	if body.has_method("win"):
		body.win()
	reached.emit()
	var path := get_next_level()
	if path != "":
		_go_to_next_level(path)


## Próximo nível: o definido no Inspetor ou o seguinte em levels.gd ("" = fim do jogo).
func get_next_level() -> String:
	if next_level != "":
		return next_level
	var level: Node = owner if owner != null else get_tree().current_scene
	if level == null:
		return ""
	return LevelList.next_after(level.scene_file_path)


func _go_to_next_level(path: String) -> void:
	if not ResourceLoader.exists(path):
		push_error("Porta: nível não encontrado: %s" % path)
		return
	var layer := CanvasLayer.new()
	layer.layer = 100
	var fade := ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(fade)
	add_child(layer)
	var tween := create_tween()
	tween.tween_property(fade, "color:a", 1.0, fade_time)
	await tween.finished
	get_tree().change_scene_to_file(path)


func _draw() -> void:
	# Origem = base central da porta
	draw_rect(Rect2(-30, -96, 60, 96), Color(0.5, 0.2, 0.9))        # aro
	draw_rect(Rect2(-24, -90, 48, 90), Color(0.08, 0.02, 0.15))     # interior
	draw_rect(Rect2(-24, -90, 48, 90), Color(1.0, 0.55, 0.0), false, 3.0)
	draw_circle(Vector2(14, -44), 4.0, Color(1.0, 0.55, 0.0))       # maçaneta
