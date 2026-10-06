class_name Boss
extends Enemy
## Base dos chefes: barra de vida no HUD, movimento "idle" de onda seno,
## afterimagens ao se mover e uma morte com várias explosões.
##
## Os padrões de ataque são escritos como corrotinas (await). Elas esperam o
## sinal "frame" do próprio chefe; se o chefe sumir, elas simplesmente param.

signal frame(delta: float)

const DEATH_TIME := 3.5

var home := Vector2(GameState.SCREEN.x / 2, 70)
var trail := AfterimageTrail.new()
var _time := 0.0


func _ready() -> void:
	trail.sprite = sprite
	add_child(trail)
	dies_on_contact = false
	invulnerable = true
	GameState.boss_bar_visible.emit(true)
	GameState.boss_health_changed.emit(hp, max_hp)
	_run()


func _physics_process(delta: float) -> void:
	_time += delta
	sprite.position.y = sin(_time * 2.5) * 6.0  # "idle" flutuando
	frame.emit(delta)


## Roteiro do chefe. As classes filhas sobrescrevem.
func _run() -> void:
	pass


func take_damage(amount: int, play_sound := true) -> void:
	super.take_damage(amount, play_sound)
	GameState.boss_health_changed.emit(maxi(hp, 0), max_hp)


func die() -> void:
	if dead:
		return
	dead = true
	GameState.add_score(score_value)
	GameState.boss_bar_visible.emit(false)
	Audio.stop_music(1.0)
	Audio.play_sfx(&"boss_death")
	_death_sequence()


func _death_sequence() -> void:
	var elapsed := 0.0
	var next_explosion := 0.0
	while elapsed < DEATH_TIME:
		var delta: float = await frame
		elapsed += delta
		sprite.modulate.a = 1.0 - elapsed / DEATH_TIME
		next_explosion -= delta
		if next_explosion <= 0.0:
			next_explosion = 0.15
			var offset := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * radius
			Fx.explosion(global_position + offset, randf_range(0.6, 1.2))
	died.emit(self)
	queue_free()


# --- Ajudantes para escrever os padrões de ataque ---------------------------

func _wait(seconds: float) -> void:
	while seconds > 0.0 and not dead:
		seconds -= await frame


## Move até um ponto. "spin" faz o chefe girar enquanto anda (radianos/s).
func _move_to(target: Vector2, speed: float, spin := 0.0) -> void:
	while not dead and position.distance_to(target) > 1.0:
		var delta: float = await frame
		position = position.move_toward(target, speed * delta)
		rotation += spin * delta


func _rotate_to(angle: float, speed := 6.0) -> void:
	while not dead and absf(angle_difference(rotation, angle)) > 0.01:
		var delta: float = await frame
		rotation = rotate_toward(rotation, angle, speed * delta)
	rotation = angle


func _enter() -> void:
	position = Vector2(home.x, -120)
	await _move_to(home, 260.0)
	invulnerable = false
