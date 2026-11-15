extends SceneTree
## Teste automático: um "bot" joga o nível.
## godot --headless --path . --script res://tests/bot.gd --fixed-fps 60

var level: Node
var player: CharacterBody2D
var frames := 0
var deaths := 0
var won := false
var jump_cooldown := 0
var last_pos := Vector2.ZERO


func _initialize() -> void:
	level = load(OS.get_environment("LEVEL") if OS.get_environment("LEVEL") != "" else "res://scenes/Fase1.tscn").instantiate()
	root.add_child(level)
	player = level.get_node("Player")
	if OS.get_environment("NOBALLS") != "":
		for c in level.get_children():
			if c.name.begins_with("BallSpawner"):
				c.queue_free()
	player.died.connect(func(): deaths += 1; print("  morreu (ultima pos x=%d y=%d) frame %d" % [last_pos.x, last_pos.y, frames]))
	level.get_node("Door").reached.connect(func(): won = true)
	Input.action_press("ui_right")


func _press_jump() -> void:
	var ev := InputEventAction.new()
	ev.action = "ui_accept"
	ev.pressed = true
	Input.parse_input_event(ev)


func _release_jump() -> void:
	var ev := InputEventAction.new()
	ev.action = "ui_accept"
	ev.pressed = false
	Input.parse_input_event(ev)


func _physics_process(_delta: float) -> bool:
	frames += 1
	if player.global_position.distance_to(Vector2(100, 550)) > 5:
		last_pos = player.global_position
	if jump_cooldown > 0:
		jump_cooldown -= 1
		if jump_cooldown == 0:
			_release_jump()
	if player.is_on_floor() and jump_cooldown == 0 and not won:
		var px := player.global_position.x
		var need := false
		for c in level.get_children():
			if c.name.begins_with("Spike") and c.global_position.x - px > 20 and c.global_position.x - px < 62:
				need = true
		var space := player.get_world_2d().direct_space_state
		var q := PhysicsRayQueryParameters2D.create(Vector2(px + 38, player.global_position.y), Vector2(px + 38, player.global_position.y + 90))
		if space.intersect_ray(q).is_empty():
			need = true
		if need:
			_press_jump()
			jump_cooldown = 25
	if frames % 120 == 0:
		print("t=%ds x=%d y=%d floor=%s" % [frames / 60, player.global_position.x, player.global_position.y, player.is_on_floor()])
	if won:
		print("RESULTADO: VENCEU em %d frames, mortes=%d" % [frames, deaths])
		print("HUD: ", level.get_node("HUD/Info").text, " | painel visível: ", level.get_node("HUD/WinPanel").visible)
		return true
	if frames > 60 * 45:
		print("RESULTADO: TIMEOUT x=%d mortes=%d" % [player.global_position.x, deaths])
		return true
	return false
