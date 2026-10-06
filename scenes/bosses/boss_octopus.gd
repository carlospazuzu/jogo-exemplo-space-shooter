class_name BossOctopus
extends Boss
## Polvo gigante (chefe da onda 2).
## Padrão 1: vai para um canto aleatório e gira ao redor dele soltando polvinhos.
## Padrão 2: treme no centro da tela soltando polvinhos em espiral.

const HIT_POINTS := 1000
const MINI_SPEED := 140.0
const CORNER_MARGIN := Vector2(110, 110)

var _shots_fired := 0


func _init() -> void:
	setup(preload("res://space-shooter/ships/9.png"), HIT_POINTS, 22.0, 2.4)
	score_value = 10000
	contact_damage = 2
	home = Vector2(GameState.SCREEN.x / 2, 70)


func _run() -> void:
	await _enter()
	while not dead:
		await _wait(1.2)
		if dead:
			return
		if randf() < 0.5:
			await _pattern_corner_orbit()
		else:
			await _pattern_spiral()
		await _move_to(home, 240.0)


func _pattern_corner_orbit() -> void:
	var corners := [
		CORNER_MARGIN,
		Vector2(GameState.SCREEN.x - CORNER_MARGIN.x, CORNER_MARGIN.y),
		Vector2(CORNER_MARGIN.x, GameState.SCREEN.y - CORNER_MARGIN.y - 40),
		Vector2(GameState.SCREEN.x - CORNER_MARGIN.x, GameState.SCREEN.y - CORNER_MARGIN.y - 40),
	]
	var corner: Vector2 = corners.pick_random()
	await _move_to(corner, 300.0)
	var orbit_radius := 55.0
	var center := corner - Vector2(orbit_radius, 0)
	var direction := 1.0 if randf() < 0.5 else -1.0  # horário ou anti-horário
	var angle := 0.0
	var elapsed := 0.0
	var shoot_timer := 0.0
	while elapsed < 5.0 and not dead:
		var delta: float = await frame
		elapsed += delta
		angle += direction * 2.4 * delta
		position = center + Vector2.from_angle(angle) * orbit_radius
		shoot_timer -= delta
		if shoot_timer <= 0.0:
			shoot_timer = 0.35
			# Direção aleatória, mas "mirando" mais ou menos no jogador.
			var aim := global_position.direction_to(GameState.player_position())
			_launch_mini(aim.rotated(randf_range(-0.8, 0.8)) * MINI_SPEED * randf_range(0.9, 1.3))


func _pattern_spiral() -> void:
	var center := GameState.SCREEN / 2 - Vector2(0, 40)
	await _move_to(center, 260.0)
	var angle := randf() * TAU
	var turn := 0.38 if randf() < 0.5 else -0.38
	var elapsed := 0.0
	var shoot_timer := 0.0
	while elapsed < 6.0 and not dead:
		var delta: float = await frame
		elapsed += delta
		position = center + Vector2(randi_range(-2, 2), randi_range(-2, 2))  # "tremedeira"
		shoot_timer -= delta
		if shoot_timer <= 0.0:
			shoot_timer = 0.09
			angle += turn
			_launch_mini(Vector2.from_angle(angle) * MINI_SPEED)
	position = center


func _launch_mini(velocity: Vector2) -> void:
	if dead:
		return
	var mini := Octopus.new().launch(velocity)
	GameState.spawn(mini, global_position + velocity.normalized() * radius * 0.6)
	_shots_fired += 1
	if _shots_fired % 3 == 0:
		Audio.play_sfx(&"boss_shoot", 0.1)
