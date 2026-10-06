class_name PlayerShot
extends Area2D
## Tiro normal do jogador. O nível do tiro (1 a 9) define a imagem e o dano.

const SPEED := 560.0

var damage := 1


static func create(level: int) -> PlayerShot:
	var shot := PlayerShot.new()
	shot.damage = level
	var sprite := Sprite2D.new()
	sprite.texture = load("res://space-shooter/shots/%d.png" % level)
	shot.add_child(sprite)
	var radius := maxf(sprite.texture.get_width(), sprite.texture.get_height()) * 0.35
	GameState.setup_area(shot, radius, GameState.LAYER_PLAYER_SHOT, GameState.LAYER_ENEMY)
	return shot


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	position.y -= SPEED * delta
	if position.y < -40:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if is_queued_for_deletion() or not area is Enemy or not area.can_be_hit():
		return
	area.take_damage(damage)
	Fx.hit(global_position)
	queue_free()
