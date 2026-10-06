class_name EnemyShot
extends Area2D
## Projétil inimigo genérico: anda em linha reta e causa dano ao jogador.

var velocity := Vector2(0, 220)
var damage := 1


static func create(texture: Texture2D, shot_velocity: Vector2, shot_damage := 1,
		radius := 5.0, flip := false) -> EnemyShot:
	var shot := EnemyShot.new()
	shot.velocity = shot_velocity
	shot.damage = shot_damage
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.flip_v = flip
	shot.add_child(sprite)
	GameState.setup_area(shot, radius, GameState.LAYER_ENEMY_SHOT, 0)
	shot.add_to_group(&"enemy_shots")
	return shot


func _physics_process(delta: float) -> void:
	position += velocity * delta
	if not GameState.on_screen(position, 60):
		queue_free()
