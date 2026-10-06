class_name Crate
extends Enemy
## Caixa de recompensa. Ao ser destruída, solta gemas e power-ups.
## Caixa 1 (marrom): 80% -> 2 a 4 gemas; 20% -> 6 gemas + 1 power-up.
## Caixa 2 (azul, rara): 10 a 20 gemas + 2 power-ups.

const FALL_SPEED := 40.0

var kind := 1


static func create(crate_kind: int) -> Crate:
	var crate := Crate.new()
	crate.kind = crate_kind
	crate.setup(load("res://space-shooter/items/crate-%d.png" % crate_kind), 15, 10.0, 1.5)
	crate.score_value = 50
	return crate


func _physics_process(delta: float) -> void:
	position.y += FALL_SPEED * delta
	_cull_if_offscreen()


func _death_effect() -> void:
	Audio.play_sfx(&"crate_break")
	Fx.spark(global_position)
	Fx.small_explosion(global_position, 0.8)


func _drop_loot() -> void:
	var items := []
	if kind == 2:
		items.append_array(_gems(randi_range(10, 20)))
		items.append_array([Pickup.random_powerup(), Pickup.random_powerup()])
	elif randf() < 0.8:
		items.append_array(_gems(randi_range(2, 4)))
	else:
		items.append_array(_gems(6))
		items.append(Pickup.random_powerup())
	Pickup.scatter(items, global_position)


func _gems(amount: int) -> Array:
	var gems := []
	for i in amount:
		gems.append(Pickup.random_gem())
	return gems
