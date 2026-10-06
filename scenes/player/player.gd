class_name Player
extends Area2D
## Nave do jogador: move nas 8 direções, atira com Z e troca de arma com X.

signal destroyed

const BASE_SPEED := 200.0
const SPEED_PER_LEVEL := 35.0
const SHOT_COOLDOWN := 0.13
const ROCKET_COOLDOWN := 0.18
const HIT_INVINCIBILITY := 0.7
const SPAWN_INVINCIBILITY := 2.0
const MARGIN := Vector2(18, 18)

var alive := true
var controls_enabled := true
var _cooldown := 0.0
var _invincible_time := 0.0
var _sprite := Sprite2D.new()


func _ready() -> void:
	_sprite.texture = preload("res://space-shooter/ships/2.png")
	add_child(_sprite)
	# Hitbox pequena, como nos shmups clássicos.
	GameState.setup_area(self, 9.0, GameState.LAYER_PLAYER,
			GameState.LAYER_ENEMY | GameState.LAYER_ENEMY_SHOT | GameState.LAYER_ITEM)
	# Área maior só para coletar itens.
	var magnet := Area2D.new()
	GameState.setup_area(magnet, 20.0, 0, GameState.LAYER_ITEM)
	magnet.area_entered.connect(func(item: Area2D) -> void: if alive and item is Pickup: item.collect())
	add_child(magnet)
	z_index = 3
	_invincible_time = SPAWN_INVINCIBILITY


func _physics_process(delta: float) -> void:
	if not alive:
		return
	_cooldown -= delta
	_invincible_time -= delta
	_sprite.visible = _invincible_time <= 0.0 or int(_invincible_time * 20.0) % 2 == 0
	if controls_enabled:
		_move(delta)
		_handle_weapons()
	_check_collisions()


func _move(delta: float) -> void:
	var direction := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	var speed := BASE_SPEED + SPEED_PER_LEVEL * GameState.speed_level
	position += direction * speed * delta
	position = position.clamp(MARGIN, GameState.SCREEN - MARGIN)


func _handle_weapons() -> void:
	if Input.is_action_just_pressed(&"switch_weapon"):
		GameState.cycle_weapon()
		Audio.play_sfx(&"weapon_switch")
	if not Input.is_action_pressed(&"shoot") or _cooldown > 0.0:
		return
	match GameState.weapon:
		GameState.Weapon.NORMAL:
			_cooldown = SHOT_COOLDOWN
			GameState.spawn(PlayerShot.create(GameState.shot_level), position + Vector2(0, -18))
			Audio.play_sfx(&"player_shoot", 0.05)
		GameState.Weapon.BOMB:
			if Input.is_action_just_pressed(&"shoot"):
				GameState.spawn(Bomb.new(), position + Vector2(0, -16))
				Audio.play_sfx(&"bomb_launch")
				GameState.consume_ammo()
		GameState.Weapon.ROCKET:
			_cooldown = ROCKET_COOLDOWN
			GameState.spawn(Rocket.new(), position + Vector2(0, -16))
			Audio.play_sfx(&"rocket_launch", 0.08)
			GameState.consume_ammo()


## Verifica tudo que está encostando na nave (tiros, inimigos, feixes).
func _check_collisions() -> void:
	for area in get_overlapping_areas():
		if not alive:
			return
		if area is Pickup:
			area.collect()
		elif _invincible_time > 0.0:
			continue
		elif area is EnemyShot:
			take_damage(area.damage)
			area.queue_free()
		elif area is Beam:
			take_damage(area.damage)
		elif area is Enemy and area.contact_damage > 0 and not area.dead:
			take_damage(area.contact_damage)
			area.on_player_contact()


func take_damage(amount: int) -> void:
	if not alive or _invincible_time > 0.0:
		return
	GameState.set_hp(GameState.hp - amount)
	_invincible_time = HIT_INVINCIBILITY
	if GameState.hp <= 0:
		_explode()
	else:
		Audio.play_sfx(&"player_hit")


func _explode() -> void:
	alive = false
	_sprite.hide()
	Audio.play_sfx(&"player_death")
	Fx.explosion(global_position)
	Fx.small_explosion(global_position + Vector2(12, 8))
	Fx.small_explosion(global_position + Vector2(-10, -6))
	set_deferred(&"monitoring", false)
	destroyed.emit()


## Faz a nave reaparecer (depois de perder uma vida).
func respawn(at: Vector2) -> void:
	position = at
	alive = true
	_sprite.show()
	set_deferred(&"monitoring", true)
	_invincible_time = SPAWN_INVINCIBILITY
	_cooldown = 0.3
