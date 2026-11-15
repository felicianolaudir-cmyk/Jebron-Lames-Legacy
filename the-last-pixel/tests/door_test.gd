extends SceneTree
## Testa a cadeia de níveis: cada porta leva ao seguinte; a última mostra a vitória.
const LEVELS := ["Fase1", "Fase2", "Fase3"]
var frames := 0
var idx := 0
var phase := 0
var ok := true

func _check(c: bool, m: String) -> void:
	print(("  OK   " if c else "  FALHOU ") + m)
	if not c: ok = false

func _initialize() -> void:
	var lvl = load("res://scenes/Fase1.tscn").instantiate()
	root.add_child(lvl)
	current_scene = lvl

func _physics_process(_d: float) -> bool:
	frames += 1
	if phase == 0 and frames == 20:
		var p = current_scene.get_node("Player")
		_check(p.global_position.distance_to(Vector2(100, 550)) < 60, "%s começa no spawn" % LEVELS[idx])
		p.global_position = current_scene.get_node("Door").global_position + Vector2(0, -50)
		phase = 1; frames = 0
	elif phase == 1:
		if idx == LEVELS.size() - 1:
			if frames == 10:
				_check(current_scene.get_node("HUD/WinPanel").visible, "porta final (%s) mostra vitória" % LEVELS[idx])
				print("RESULTADO: ", "TUDO OK" if ok else "HÁ FALHAS")
				return true
		elif frames == 90:
			idx += 1
			_check(current_scene.scene_file_path == "res://scenes/%s.tscn" % LEVELS[idx], "porta leva ao %s (atual: %s)" % [LEVELS[idx], current_scene.scene_file_path])
			phase = 0; frames = 0
	return false
