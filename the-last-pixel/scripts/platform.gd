@tool
extends StaticBody2D
## Plataforma retangular. A origem é o canto superior esquerdo.
## Mude "size" no Inspetor para a redimensionar (colisão + visual).

const TEX := preload("res://assets/chao.png")
const EDGE := Color(1.0, 0.55, 0.0)
const TOP_THICKNESS := 6.0

@export var size := Vector2(200, 32):
	set(value):
		size = value
		_refresh()


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return
	var shape_node := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node and shape_node.shape is RectangleShape2D:
		(shape_node.shape as RectangleShape2D).size = size
		shape_node.position = size / 2.0
	queue_redraw()


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_texture_rect(TEX, rect, true)
	draw_rect(Rect2(0, 0, size.x, TOP_THICKNESS), EDGE)
	draw_rect(rect, Color(0.5, 0.2, 0.9, 0.9), false, 2.0)
