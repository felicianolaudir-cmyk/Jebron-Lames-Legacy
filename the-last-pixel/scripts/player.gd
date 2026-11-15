extends CharacterBody2D
## Jogador: andar (setas / A D), saltar (espaço / seta cima / W).

signal died

@export var spawn_point: Marker2D
@export var fall_limit := 900.0
@export var speed := 260.0
@export var jump_velocity := -600.0
@export var gravity := 1500.0
@export var max_fall_speed := 1100.0

const RESPAWN_BOUNCE := -380.0
const COYOTE_TIME := 0.10
const JUMP_BUFFER := 0.10

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var base_scale: Vector2
var respawn_position: Vector2
var can_move := true
var was_on_floor := true
var coyote := 0.0
var buffer := 0.0
var tween: Tween


func _ready() -> void:
	add_to_group("player")
	base_scale = sprite.scale
	if spawn_point == null:
		spawn_point = get_node_or_null("../SpawnPoint") as Marker2D
	if spawn_point != null:
		global_position = spawn_point.global_position
	else:
		push_warning("SpawnPoint não encontrado!")
	respawn_position = global_position


func _physics_process(delta: float) -> void:
	# Gravidade
	if not is_on_floor():
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)

	# Coyote time e buffer de salto
	coyote = COYOTE_TIME if is_on_floor() else maxf(coyote - delta, 0.0)
	buffer = maxf(buffer - delta, 0.0)

	# Salto
	if buffer > 0.0 and coyote > 0.0:
		velocity.y = jump_velocity
		buffer = 0.0
		coyote = 0.0
		_bounce_scale(Vector2(0.8, 1.3))
	# Salto mais curto se largar a tecla
	if can_move and velocity.y < -200.0 and not _jump_held():
		velocity.y = maxf(velocity.y, -200.0)

	# Movimento horizontal
	var direction := _get_direction() if can_move else 0.0
	velocity.x = direction * speed

	# Animações
	if direction > 0.0:
		sprite.play("Walk_right")
	elif direction < 0.0:
		sprite.play("Walk_left")
	else:
		sprite.play("Still")

	var fall_speed := velocity.y
	move_and_slide()

	# Esmagar ao aterrar
	if is_on_floor() and not was_on_floor and fall_speed > 200.0:
		var amount := clampf(fall_speed / 1200.0, 0.1, 0.35)
		_bounce_scale(Vector2(1.0 + amount, 1.0 - amount))
	was_on_floor = is_on_floor()

	# Queda no vazio
	if global_position.y > fall_limit:
		die()


func die() -> void:
	global_position = respawn_position
	velocity = Vector2(0, RESPAWN_BOUNCE)
	was_on_floor = false
	coyote = 0.0
	buffer = 0.0
	_bounce_scale(Vector2(0.7, 1.4))
	var cam := get_node_or_null("Camera2D") as Camera2D
	if cam:
		cam.reset_smoothing()
	died.emit()


func set_checkpoint(pos: Vector2) -> void:
	respawn_position = pos


func win() -> void:
	can_move = false


func _get_direction() -> float:
	var d := Input.get_axis("ui_left", "ui_right")
	if Input.is_key_pressed(KEY_A):
		d -= 1.0
	if Input.is_key_pressed(KEY_D):
		d += 1.0
	return clampf(d, -1.0, 1.0)


func _unhandled_input(event: InputEvent) -> void:
	if not can_move:
		return
	var pressed := event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_up")
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_W:
		pressed = true
	if pressed:
		buffer = JUMP_BUFFER


func _jump_held() -> bool:
	return Input.is_action_pressed("ui_accept") \
		or Input.is_action_pressed("ui_up") \
		or Input.is_key_pressed(KEY_W)


func _bounce_scale(factor: Vector2) -> void:
	if tween:
		tween.kill()
	sprite.scale = base_scale * factor
	tween = create_tween()
	tween.tween_property(sprite, "scale", base_scale, 0.4) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
