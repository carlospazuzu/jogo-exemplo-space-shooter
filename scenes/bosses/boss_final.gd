class_name BossFinal
extends Boss
## Chefe final. Sempre deixa afterimagens ao se mover.
## Padrão 1: gira até o canto inferior esquerdo, dispara um feixe para a direita e sobe.
## Padrão 2: gira até o canto superior direito, dispara um feixe para baixo e anda para a esquerda.
## Padrão 3: cria dois clones piscando; todos atiram.
## Padrão 4: patrulha na horizontal e, de repente, se alinha com o jogador e atira.

const HIT_POINTS := 1600
const SPRITE_SCALE := 1.6
## Canhões nas "mãos" (posição local, já na escala do sprite).
const CANNONS := [Vector2(-30, 26) * SPRITE_SCALE, Vector2(30, 26) * SPRITE_SCALE]
const BEAM_SAFE_LINE := 100.0  # o feixe para a ~100px da borda (área de fuga)
const SPLASH_SHOT := preload("res://space-shooter/shots/8.png")
const CANNON_SHOT := preload("res://space-shooter/shots/11.png")


func _init() -> void:
	setup(preload("res://space-shooter/ships/7.png"), HIT_POINTS, 30.0, SPRITE_SCALE)
	score_value = 25000
	contact_damage = 3
	home = Vector2(GameState.SCREEN.x / 2, 90)


func _ready() -> void:
	super._ready()
	trail.color = Color(1.0, 0.4, 0.8, 0.6)


func _run() -> void:
	await _enter()
	var patterns := [_pattern_beam_rising, _pattern_beam_sweep, _pattern_clones, _pattern_ambush]
	while not dead:
		await _wait(1.0)
		if dead:
			return
		await patterns.pick_random().call()
		await _move_to(home, 280.0, TAU)
		await _rotate_to(0.0)


func _pattern_beam_rising() -> void:
	await _move_to(Vector2(70, GameState.SCREEN.y - 60), 320.0, TAU * 1.5)
	await _rotate_to(-PI / 2)  # canhões apontando para a direita
	var beam := _start_beam()
	await _wait(Beam.WARNING_TIME)
	await _move_dragging_beam(Vector2(70, BEAM_SAFE_LINE), 150.0, beam)
	await _wait(0.4)
	if is_instance_valid(beam):
		beam.stop()


func _pattern_beam_sweep() -> void:
	await _move_to(Vector2(GameState.SCREEN.x - 70, 70), 320.0, TAU * 1.5)
	await _rotate_to(0.0)  # canhões apontando para baixo
	var beam := _start_beam()
	await _wait(Beam.WARNING_TIME)
	await _move_dragging_beam(Vector2(BEAM_SAFE_LINE, 70), 170.0, beam)
	await _wait(0.4)
	if is_instance_valid(beam):
		beam.stop()


func _pattern_clones() -> void:
	var center := Vector2(GameState.SCREEN.x / 2, 130)
	await _move_to(center, 280.0)
	var clones: Array[Sprite2D] = []
	for side in [-1, 1]:
		var clone := AfterimageTrail.make_ghost(sprite, Color(1.0, 0.4, 0.8, 0.5))
		clone.z_index = 1
		clone.create_tween().tween_property(clone, "position:x", center.x + side * 170, 0.5)
		clones.append(clone)
	for volley in 5:
		await _wait(0.7)
		if dead:
			break
		for clone in clones:
			clone.modulate.a = randf_range(0.25, 0.75)  # "tentando existir"
			_fire_aimed(clone.global_position)
		_fire_aimed(global_position)
		Audio.play_sfx(&"boss_shoot")
	for clone in clones:
		var tween := clone.create_tween()
		tween.tween_property(clone, "modulate:a", 0.0, 0.3)
		tween.tween_callback(clone.queue_free)


func _pattern_ambush() -> void:
	var duration := randf_range(5.0, 7.0)
	var ambush_at := randf_range(1.0, duration - 1.5)
	var direction := 1.0 if randf() < 0.5 else -1.0
	var elapsed := 0.0
	var ambushed := false
	while elapsed < duration and not dead:
		var delta: float = await frame
		elapsed += delta
		position.x += direction * 200.0 * delta
		if position.x < 80 or position.x > GameState.SCREEN.x - 80:
			direction = -direction
			position.x = clampf(position.x, 80, GameState.SCREEN.x - 80)
		if not ambushed and elapsed >= ambush_at:
			ambushed = true
			await _move_to(Vector2(GameState.player_position().x, position.y), 450.0)
			await _cannon_burst()


func _cannon_burst() -> void:
	for i in 6:
		if dead:
			return
		for cannon in CANNONS:
			var shot := EnemyShot.create(CANNON_SHOT, Vector2(0, 420), 1, 7.0, true)
			GameState.spawn(shot, to_global(cannon))
		if i % 2 == 0:
			Audio.play_sfx(&"boss_shoot")
		await _wait(0.08)


func _fire_aimed(from: Vector2) -> void:
	if dead:
		return
	var velocity := from.direction_to(GameState.player_position()) * 200.0
	var shot := EnemyShot.create(SPLASH_SHOT, velocity, 1, 10.0)
	shot.get_child(0).rotation = velocity.angle() + PI / 2
	GameState.spawn(shot, from)


func _start_beam() -> Beam:
	var beam := Beam.new()
	GameState.spawn(beam, _beam_origin())
	beam.rotation = rotation + PI / 2
	return beam


func _beam_origin() -> Vector2:
	return to_global(Vector2(0, 40))


## Igual ao _move_to da base, mas arrastando o feixe junto.
func _move_dragging_beam(target: Vector2, speed: float, beam: Beam) -> void:
	while not dead and position.distance_to(target) > 1.0:
		var delta: float = await frame
		position = position.move_toward(target, speed * delta)
		if is_instance_valid(beam):
			beam.global_position = _beam_origin()
			beam.rotation = rotation + PI / 2


func die() -> void:
	for beam in get_tree().get_nodes_in_group(&"beams"):
		beam.stop()
	super.die()
