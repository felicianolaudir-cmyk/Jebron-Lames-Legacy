extends SceneTree
## Testa as bolas do Fase2: surgem no ponto fixo, saltam sempre, matam o jogador.
var lvl: Node
var p: CharacterBody2D
var frames := 0
var step := 0
var ok := true
var deaths := 0
var ball: Node2D
var spawn_x := 0.0
var bounces := 0
var prev_vy := 0.0
var last_y := 0.0
var apexes: Array[float] = []
var min_y := 1e9

func _check(c: bool, m: String) -> void:
	print(("  OK   " if c else "  FALHOU ") + m)
	if not c: ok = false

func _balls() -> Array:
	return lvl.get_children().filter(func(n): return n.name.begins_with("Ball") and n is CharacterBody2D and not n.name.begins_with("BallSpawner"))

func _initialize() -> void:
	lvl = load("res://scenes/Fase2.tscn").instantiate()
	root.add_child(lvl)
	p = lvl.get_node("Player")
	p.died.connect(func(): deaths += 1)
	# mantém o jogador parado e em segurança durante a medição
	p.set_physics_process(false)

func _physics_process(_d: float) -> bool:
	frames += 1
	match step:
		0:
			var bs := _balls()
			if bs.size() > 0:
				ball = bs[0]
				spawn_x = ball.global_position.x
				_check(absf(spawn_x - 620.0) < 5.0, "bola surge no ponto fixo x=620 (x=%.0f)" % spawn_x)
				step = 1; frames = 0
			elif frames > 240:
				_check(false, "nenhuma bola surgiu em 4s"); return true
		1:
			if not is_instance_valid(ball): return false
			var vy: float = ball.velocity.y
			if prev_vy > 0.0 and vy < 0.0:
				bounces += 1
				apexes.append(ball.global_position.y)
			prev_vy = vy
			if frames == 300:  # 5 s
				_check(bounces >= 4, "bola salta repetidamente (%d saltos em 5s)" % bounces)
				var a := apexes.slice(1)
				var spread: float = (a.max() - a.min()) if a.size() > 1 else 999.0
				_check(spread < 6.0, "altura dos saltos constante (variação %.1fpx)" % spread)
				step = 2; frames = 0
		2:
			if is_instance_valid(ball):
				p.global_position = ball.global_position
				p.velocity = Vector2.ZERO
			if frames == 10:
				_check(deaths >= 1, "bola mata o jogador ao toque (mortes=%d)" % deaths)
				step = 3; frames = 0
		3:
			if frames == 1:
				# afasta o jogador para parar de gerar; as bolas existentes expiram
				p.global_position = Vector2(100, 550)
			if frames == 60 * 14:
				var alive := _balls().filter(func(b): return not b.dying)
				_check(alive.size() <= 2, "no máximo 2 bolas vivas por gerador (vivas=%d)" % alive.size())
				print("RESULTADO: ", "TUDO OK" if ok else "HÁ FALHAS")
				return true
	return false
