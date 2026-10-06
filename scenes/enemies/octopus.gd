class_name Octopus
extends Enemy
## Polvo do mal: desce devagar e, depois de 30% da tela, persegue o jogador.
## Ao encostar no jogador ele explode e tira 2 de HP.
## Também é usado como "projétil" pelo polvo gigante (função launch).

const DESCEND_SPEED := 45.0
const CHASE_SPEED := 115.0
const CHASE_LINE := 0.30

## Se diferente de zero, o polvo é um projétil e anda em linha reta.
var velocity := Vector2.ZERO
var _chasing := false
var _direction := Vector2.DOWN
var _time := randf() * TAU


func _init() -> void:
	setup(preload("res://space-shooter/ships/10.png"), 2, 11.0)
	score_value = 150
	contact_damage = 2


## Transforma o polvo num polvinho-projétil (usado pelo chefe).
func launch(launch_velocity: Vector2) -> Octopus:
	velocity = launch_velocity
	max_hp = 1
	hp = 1
	contact_damage = 1
	score_value = 20
	sprite.scale = Vector2.ONE * 0.75
	return self


func _physics_process(delta: float) -> void:
	_time += delta
	sprite.rotation = sin(_time * 5.0) * 0.15
	if velocity != Vector2.ZERO:
		position += velocity * delta
		if not GameState.on_screen(position, 40):
			queue_free()
		return
	if not _chasing:
		position.y += DESCEND_SPEED * delta
		position.x += sin(_time * 2.0) * 20.0 * delta
		_chasing = position.y >= GameState.SCREEN.y * CHASE_LINE
	else:
		var wanted := global_position.direction_to(GameState.player_position())
		_direction = _direction.slerp(wanted, minf(2.5 * delta, 1.0))
		position += _direction * CHASE_SPEED * delta
	_cull_if_offscreen()
