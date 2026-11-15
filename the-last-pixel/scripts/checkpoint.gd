extends Area2D
## Bandeira de checkpoint: ao tocar, o jogador passa a renascer aqui.

var active := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if active or not body.is_in_group("player"):
		return
	active = true
	if body.has_method("set_checkpoint"):
		body.set_checkpoint(global_position + Vector2(0, -50))
	queue_redraw()


func _draw() -> void:
	var color := Color(1.0, 0.55, 0.0) if active else Color(0.5, 0.5, 0.55)
	draw_line(Vector2(0, 0), Vector2(0, -90), Color(0.85, 0.85, 0.9), 4.0)
	draw_colored_polygon(PackedVector2Array([
		Vector2(2, -90), Vector2(42, -76), Vector2(2, -62)]), color)
