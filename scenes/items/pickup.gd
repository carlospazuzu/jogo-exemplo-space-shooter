class_name Pickup
extends Area2D
## Item coletável: gemas (pontos) e power-ups. Desce devagar e some ao sair da tela.

enum Kind { GEM_1, GEM_2, GEM_3, GEM_4, POWERUP_1, POWERUP_2, POWERUP_3, POWERUP_4 }

## Pontos de cada gema: a última vale 10x a primeira.
const GEM_POINTS := [100, 250, 500, 1000]
const FALL_SPEED := 45.0

var kind := Kind.GEM_1
var velocity := Vector2.ZERO
var _sprite := Sprite2D.new()
var _time := 0.0


static func create(item_kind: Kind, burst := Vector2.ZERO) -> Pickup:
	var item := Pickup.new()
	item.kind = item_kind
	item.velocity = burst
	return item


## Gema aleatória: as mais simples são as mais comuns.
static func random_gem() -> Kind:
	var roll := randf()
	if roll < 0.5:
		return Kind.GEM_1
	if roll < 0.8:
		return Kind.GEM_2
	if roll < 0.95:
		return Kind.GEM_3
	return Kind.GEM_4


static func random_powerup() -> Kind:
	return [Kind.POWERUP_1, Kind.POWERUP_2, Kind.POWERUP_3, Kind.POWERUP_4].pick_random()


## Solta vários itens espalhados a partir de um ponto.
## (Criados de forma "deferred" porque isso costuma acontecer durante colisões.)
static func scatter(kinds: Array, at: Vector2) -> void:
	for item_kind in kinds:
		var burst := Vector2.from_angle(randf_range(PI, TAU)) * randf_range(40, 140)
		GameState.spawn.call_deferred(create(item_kind, burst), at)


func is_gem() -> bool:
	return kind <= Kind.GEM_4


func _ready() -> void:
	if is_gem():
		_sprite.texture = load("res://space-shooter/items/gem-%d.png" % (kind + 1))
		_sprite.hframes = 4
	else:
		_sprite.texture = load("res://space-shooter/items/power-up-%d.png" % (kind - Kind.POWERUP_1 + 1))
	add_child(_sprite)
	GameState.setup_area(self, 11.0, GameState.LAYER_ITEM, 0)
	z_index = 2


func _physics_process(delta: float) -> void:
	_time += delta
	velocity = velocity.move_toward(Vector2.ZERO, 160.0 * delta)
	position += velocity * delta + Vector2(0, FALL_SPEED * delta)
	position.x = clampf(position.x, 10, GameState.SCREEN.x - 10)
	if is_gem():
		_sprite.frame = int(_time * 8.0) % 4
	else:
		_sprite.scale = Vector2.ONE * (1.0 + 0.08 * sin(_time * 8.0))
	if position.y > GameState.SCREEN.y + 30:
		queue_free()


func collect() -> void:
	if is_queued_for_deletion():
		return
	if is_gem():
		GameState.add_score(GEM_POINTS[kind])
		Audio.play_sfx(StringName("gem_%d" % (kind + 1)))
	else:
		GameState.apply_powerup(kind - Kind.POWERUP_1 + 1)
		Audio.play_sfx(&"powerup")
	Fx.play(preload("res://space-shooter/effects/fx-2.png"), 6, global_position, Color.WHITE, 1.0, 24.0)
	queue_free()
