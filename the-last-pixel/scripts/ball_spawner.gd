extends Marker2D
## Gerador de bolas num local fixo. Só ativo quando o jogador está perto.

@export var ball_scene: PackedScene
@export var interval := 3.0
@export var initial_delay := 1.5
@export var max_alive := 2
@export var horizontal_speed := -90.0
@export var active_range := 1000.0

var timer := 0.0
var balls: Array[Node] = []
var player: Node2D


func _ready() -> void:
	timer = initial_delay
	player = get_tree().get_first_node_in_group("player") as Node2D


func _process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player") as Node2D
		return
	if absf(player.global_position.x - global_position.x) > active_range:
		return
	timer -= delta
	if timer > 0.0:
		return
	timer = interval
	balls = balls.filter(func(b): return is_instance_valid(b))
	if balls.size() >= max_alive or ball_scene == null:
		return
	var ball := ball_scene.instantiate()
	ball.horizontal_speed = horizontal_speed
	ball.position = global_position
	get_parent().add_child(ball)
	balls.append(ball)
	queue_redraw()


func _draw() -> void:
	# Marca discreta do ponto onde as bolas surgem
	draw_arc(Vector2.ZERO, 10.0, 0.0, TAU, 24, Color(1.0, 0.2, 0.4, 0.35), 2.0)
