class_name Astronaut
extends Enemy
## Astronauta do mal: desce até uma linha no topo da tela e depois só anda
## na horizontal para se alinhar com o jogador, atirando a cada 3 segundos.
## Astronautas na mesma linha não se sobrepõem: ficam lado a lado.

const DESCEND_SPEED := 70.0
const STRAFE_SPEED := 80.0
const SHOOT_COOLDOWN := 3.0
const SHOT_SPEED := 230.0
const MAX_ROW := 0.25  # nunca desce mais que 25% da altura da tela
const GEM_CHANCE := 0.10
const SHOT_TEXTURE := preload("res://space-shooter/shots/7.png")

var _row_y := 0.0
var _in_row := false
var _shoot_timer := 0.0


func _init() -> void:
	setup(preload("res://space-shooter/ships/5.png"), 5, 12.0)
	score_value = 100
	contact_damage = 1
	dies_on_contact = false
	_row_y = randf_range(40.0, GameState.SCREEN.y * MAX_ROW)
	_shoot_timer = randf_range(0.8, SHOOT_COOLDOWN)
	add_to_group(&"astronauts")


func _physics_process(delta: float) -> void:
	if not _in_row:
		position.y += DESCEND_SPEED * delta
		_in_row = position.y >= _row_y
	else:
		var target_x := GameState.player_position().x
		position.x = move_toward(position.x, target_x, STRAFE_SPEED * delta)
	_keep_side_by_side()
	position.x = clampf(position.x, 14, GameState.SCREEN.x - 14)
	_shoot_timer -= delta
	if _shoot_timer <= 0.0 and position.y > 0.0 and GameState.is_player_alive():
		_shoot_timer = SHOOT_COOLDOWN
		_shoot()
	_cull_if_offscreen()


## Empurra para o lado os astronautas que estão na mesma linha.
func _keep_side_by_side() -> void:
	var min_distance := radius * 2.0
	for other: Astronaut in get_tree().get_nodes_in_group(&"astronauts"):
		if other == self or absf(other.position.y - position.y) > min_distance:
			continue
		var dx := position.x - other.position.x
		if absf(dx) >= min_distance:
			continue
		var side := signf(dx) if dx != 0.0 else (1.0 if get_instance_id() > other.get_instance_id() else -1.0)
		position.x += side * (min_distance - absf(dx)) * 0.5


func _shoot() -> void:
	var shot := EnemyShot.create(SHOT_TEXTURE, Vector2(0, SHOT_SPEED), 1, 5.0, true)
	GameState.spawn(shot, position + Vector2(0, 14))
	Audio.play_sfx(&"enemy_shoot", 0.1)


func _drop_loot() -> void:
	if randf() < GEM_CHANCE:
		GameState.spawn.call_deferred(Pickup.create(Pickup.random_gem()), global_position)
