class_name Rocket
extends Area2D
## Foguete teleguiado: persegue o inimigo mais próximo e causa 4 de dano.

const DAMAGE := 4
const START_SPEED := 380.0
const MAX_SPEED := 720.0
const ACCELERATION := 900.0
const TURN_SPEED := 9.0  # radianos por segundo

var velocity := Vector2(0, -START_SPEED)
var _sprite := Sprite2D.new()


func _ready() -> void:
	_sprite.texture = preload("res://space-shooter/items/rocket-2.png")
	add_child(_sprite)
	GameState.setup_area(self, 6.0, GameState.LAYER_PLAYER_SHOT, GameState.LAYER_ENEMY)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	var target := _nearest_enemy()
	var speed := minf(velocity.length() + ACCELERATION * delta, MAX_SPEED)
	var direction := velocity.normalized()
	if target:
		var wanted := global_position.direction_to(target.global_position)
		var turn := clampf(direction.angle_to(wanted), -TURN_SPEED * delta, TURN_SPEED * delta)
		direction = direction.rotated(turn)
	velocity = direction * speed
	position += velocity * delta
	_sprite.rotation = velocity.angle() + PI / 2
	if not GameState.on_screen(position, 60):
		queue_free()


func _nearest_enemy() -> Enemy:
	var best: Enemy = null
	var best_distance := INF
	for enemy: Enemy in get_tree().get_nodes_in_group(&"enemies"):
		if not enemy.can_be_hit() or not GameState.on_screen(enemy.global_position):
			continue
		var distance := global_position.distance_squared_to(enemy.global_position)
		if distance < best_distance:
			best_distance = distance
			best = enemy
	return best


func _on_area_entered(area: Area2D) -> void:
	if is_queued_for_deletion() or not area is Enemy or not area.can_be_hit():
		return
	area.take_damage(DAMAGE)
	Fx.small_explosion(global_position, 0.6)
	queue_free()
