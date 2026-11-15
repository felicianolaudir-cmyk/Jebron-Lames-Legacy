extends SceneTree
## Testa: espinho mata, buraco mata, checkpoint guarda o respawn.

var level: Node
var player: CharacterBody2D
var step := 0
var frames := 0
var deaths := 0
var ok := true


func _check(cond: bool, msg: String) -> void:
	print(("  OK   " if cond else "  FALHOU ") + msg)
	if not cond:
		ok = false


func _initialize() -> void:
	level = load("res://scenes/Fase2.tscn").instantiate()
	root.add_child(level)
	player = level.get_node("Player")
	player.died.connect(func(): deaths += 1)


func _physics_process(_d: float) -> bool:
	frames += 1
	match step:
		0:
			if frames == 30:
				_check(player.is_on_floor(), "jogador aterra no chão no início")
				_check(player.is_in_group("player"), "jogador está no grupo 'player'")
				player.global_position = Vector2(330, 560)  # em cima do espinho
				step = 1; frames = 0
		1:
			if frames == 5:
				_check(deaths == 1, "espinho mata (mortes=%d)" % deaths)
				_check(player.global_position.distance_to(Vector2(100, 550)) < 60, "renasce no spawn (%s)" % player.global_position)
				player.global_position = Vector2(890, 550)  # checkpoint 1
				step = 2; frames = 0
		2:
			if frames == 10:
				_check(player.respawn_position.x > 800, "checkpoint 1 ativado (%s)" % player.respawn_position)
				player.global_position = Vector2(780, 700)  # buraco
				player.velocity = Vector2.ZERO
				step = 3; frames = 0
		3:
			if frames == 90:
				_check(deaths == 2, "queda no buraco mata (mortes=%d)" % deaths)
				_check(abs(player.global_position.x - 890) < 60, "renasce no checkpoint (%s)" % player.global_position)
				step = 4; frames = 0
		4:
			if frames == 60:
				_check(level.get_node("HUD/Info").text.contains("Mortes: 2"), "HUD mostra 2 mortes")
				print("RESULTADO: ", "TUDO OK" if ok else "HÁ FALHAS")
				return true
	return false
