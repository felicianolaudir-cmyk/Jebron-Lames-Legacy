extends Area2D
## Espinhos: matam o jogador ao toque.


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("die"):
		# deferred: não mexer na física dentro do callback de colisão
		body.call_deferred("die")
