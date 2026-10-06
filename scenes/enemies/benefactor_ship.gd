class_name BenefactorShip
extends Node2D
## Nave amiga: atravessa a tela de baixo para cima e, perto do topo,
## solta power-ups e gemas para o jogador.

const SPEED := 130.0
const DROP_LINE := 0.20  # solta os itens a 20% da altura da tela

var _dropped := false
var _sprite := Sprite2D.new()
var _time := 0.0


func _ready() -> void:
	_sprite.texture = preload("res://space-shooter/ships/6.png")
	_sprite.flip_v = true  # a nave sobe, então fica de "frente" para cima
	add_child(_sprite)
	z_index = 1


func _physics_process(delta: float) -> void:
	_time += delta
	position.y -= SPEED * delta
	position.x += sin(_time * 3.0) * 30.0 * delta
	if not _dropped and position.y <= GameState.SCREEN.y * DROP_LINE:
		_dropped = true
		_drop_gifts()
	if position.y < -60:
		queue_free()


func _drop_gifts() -> void:
	Audio.play_sfx(&"benefactor_drop")
	Fx.spark(global_position, 3.0)
	var items := []
	for i in randi_range(3, 5):
		items.append(Pickup.random_powerup() if randf() < 0.6 else Pickup.random_gem())
	Pickup.scatter(items, global_position)
