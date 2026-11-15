extends CharacterBody2D
## Bola saltitona: salta sempre à mesma altura, anda na horizontal,
## inverte nas paredes e mata o jogador ao toque.

@export var gravity := 1500.0
@export var bounce_speed := 700.0
@export var horizontal_speed := -90.0
@export var lifetime := 10.0
@export var fall_limit := 900.0
@export var radius := 16.0

const COLOR := Color(1.0, 0.2, 0.4)

@onready var hitbox: Area2D = $Hitbox

var age := 0.0
var dying := false


func _ready() -> void:
	velocity = Vector2(horizontal_speed, 0.0)
	# A bola não colide fisicamente com o jogador, só o mata (Hitbox).
	for p in get_tree().get_nodes_in_group("player"):
		if p is PhysicsBody2D:
			add_collision_exception_with(p)
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	# Efeito de surgir
	scale = Vector2(0.1, 0.1)
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.25) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _physics_process(delta: float) -> void:
	if dying:
		return
	age += delta
	if age >= lifetime or global_position.y > fall_limit:
		_pop()
		return

	velocity.y += gravity * delta
	var collision := move_and_collide(velocity * delta)
	if collision:
		var n := collision.get_normal()
		if n.y < -0.5:
			velocity.y = -bounce_speed          # chão: salta sempre igual
		elif n.y > 0.5:
			velocity.y = absf(velocity.y) * 0.5 # teto
		if absf(n.x) > 0.5:
			velocity.x = absf(velocity.x) * signf(n.x)  # parede: inverte


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("die"):
		body.call_deferred("die")


func _pop() -> void:
	dying = true
	hitbox.set_deferred("monitoring", false)
	var t := create_tween()
	t.tween_property(self, "scale", Vector2(0.1, 0.1), 0.2)
	t.tween_callback(queue_free)


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, COLOR)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, Color(1, 1, 1, 0.9), 2.0)
	draw_circle(Vector2(-5, -5), 4.0, Color(1, 1, 1, 0.7))
