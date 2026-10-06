extends Node
## Estado da partida (autoload "GameState"): pontos, vidas, HP e inventário.

signal score_changed(score: int)
signal hp_changed(hp: int, max_hp: int)
signal lives_changed(lives: int)
signal inventory_changed
signal boss_health_changed(hp: int, max_hp: int)
signal boss_bar_visible(visible: bool)

enum Weapon { NORMAL, BOMB, ROCKET }

const SCREEN := Vector2(640, 480)
const MAX_HP := 10
const START_LIVES := 3
const EXTRA_LIFE_EVERY := 10000
const MAX_SHOT_LEVEL := 9
const ROCKETS_PER_PICKUP := 20
const HEAL_AMOUNT := 5

# Camadas de colisão (todas as entidades são Area2D).
const LAYER_PLAYER := 1
const LAYER_PLAYER_SHOT := 2
const LAYER_ENEMY := 4
const LAYER_ENEMY_SHOT := 8
const LAYER_ITEM := 16

## Nó onde inimigos, tiros, itens e efeitos são criados (definido pela cena principal).
var world: Node2D
var player: Player

var score := 0
var lives := START_LIVES
var hp := MAX_HP
var shot_level := 1
var speed_level := 0
var bombs := 0
var rockets := 0
var weapon := Weapon.NORMAL
var _next_extra_life := EXTRA_LIFE_EVERY


func new_game() -> void:
	score = 0
	lives = START_LIVES
	_next_extra_life = EXTRA_LIFE_EVERY
	reset_powerups()
	score_changed.emit(score)
	lives_changed.emit(lives)


## Volta o jogador ao estado inicial: HP cheio e sem nenhum power-up.
func reset_powerups() -> void:
	hp = MAX_HP
	shot_level = 1
	speed_level = 0
	bombs = 0
	rockets = 0
	weapon = Weapon.NORMAL
	hp_changed.emit(hp, MAX_HP)
	inventory_changed.emit()


func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)
	while score >= _next_extra_life:
		_next_extra_life += EXTRA_LIFE_EVERY
		lives += 1
		lives_changed.emit(lives)
		Audio.play_sfx(&"extra_life")


func set_hp(value: int) -> void:
	hp = clampi(value, 0, MAX_HP)
	hp_changed.emit(hp, MAX_HP)


func lose_life() -> void:
	lives -= 1
	lives_changed.emit(lives)


## Aplica o efeito de um power-up (1 a 4, igual ao número da imagem).
func apply_powerup(kind: int) -> void:
	match kind:
		1:
			set_hp(hp + HEAL_AMOUNT)
			shot_level = mini(shot_level + 1, MAX_SHOT_LEVEL)
		2:
			bombs += 1
		3:
			rockets += ROCKETS_PER_PICKUP
		4:
			speed_level += 1
	inventory_changed.emit()


func ammo_for(w: Weapon) -> int:
	match w:
		Weapon.BOMB:
			return bombs
		Weapon.ROCKET:
			return rockets
	return -1  # arma normal: infinita


## Troca para a próxima arma que tem munição.
func cycle_weapon() -> void:
	var next := weapon
	for i in Weapon.size():
		next = (next + 1) % Weapon.size() as Weapon
		if ammo_for(next) != 0:
			break
	weapon = next
	inventory_changed.emit()


func consume_ammo() -> void:
	match weapon:
		Weapon.BOMB:
			bombs -= 1
		Weapon.ROCKET:
			rockets -= 1
	if ammo_for(weapon) == 0:
		weapon = Weapon.NORMAL
	inventory_changed.emit()


## Adiciona um nó ao mundo do jogo (inimigos, tiros, itens, efeitos).
func spawn(node: Node2D, at: Vector2) -> Node2D:
	node.position = at
	world.add_child(node)
	return node


func is_player_alive() -> bool:
	return is_instance_valid(player) and player.alive


func player_position() -> Vector2:
	if is_instance_valid(player):
		return player.global_position
	return Vector2(SCREEN.x / 2, SCREEN.y - 60)


## Configura uma Area2D com um colisor circular.
func setup_area(area: Area2D, radius: float, layer: int, mask: int) -> void:
	area.collision_layer = layer
	area.collision_mask = mask
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = radius
	shape.shape = circle
	area.add_child(shape)


## Verdadeiro se o ponto está dentro da tela (com uma margem extra).
func on_screen(point: Vector2, margin := 0.0) -> bool:
	return Rect2(Vector2.ZERO, SCREEN).grow(margin).has_point(point)
