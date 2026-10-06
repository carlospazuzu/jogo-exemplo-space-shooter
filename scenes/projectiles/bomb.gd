class_name Bomb
extends Node2D
## Bomba: sobe por 1 segundo e explode num círculo que causa 2 de dano
## por frame em tudo que estiver dentro (e apaga os tiros inimigos).

const FUSE_TIME := 1.0
const SPEED := 220.0
const MAX_RADIUS := 110.0
const GROW_TIME := 0.2
const EXPLOSION_TIME := 0.8
const DAMAGE_PER_FRAME := 2
const COLORS: Array[Color] = [
	Color("#fff3b0"), Color("#ffd23f"), Color("#ff8c1a"), Color("#ff3d1f"), Color("#ffb347"),
]

var _time := 0.0
var _exploded := false
var _radius := 0.0
var _sprite := Sprite2D.new()


func _ready() -> void:
	_sprite.texture = preload("res://space-shooter/items/bomb.png")
	add_child(_sprite)
	z_index = 4


func _physics_process(delta: float) -> void:
	_time += delta
	if not _exploded:
		position.y -= SPEED * delta
		_sprite.rotation += 8.0 * delta
		if _time >= FUSE_TIME:
			_explode()
		return
	var t := _time - FUSE_TIME
	_radius = MAX_RADIUS * minf(t / GROW_TIME, 1.0)
	_damage_everything_inside()
	queue_redraw()
	if t >= EXPLOSION_TIME:
		queue_free()


func _explode() -> void:
	_exploded = true
	_sprite.hide()
	Audio.play_sfx(&"bomb_explode")


func _damage_everything_inside() -> void:
	for enemy: Enemy in get_tree().get_nodes_in_group(&"enemies"):
		if enemy.can_be_hit() and enemy.global_position.distance_to(global_position) <= _radius + enemy.radius:
			enemy.take_damage(DAMAGE_PER_FRAME, false)
	for shot: Node2D in get_tree().get_nodes_in_group(&"enemy_shots"):
		if shot.global_position.distance_to(global_position) <= _radius:
			shot.queue_free()


func _draw() -> void:
	if not _exploded:
		return
	var t := _time - FUSE_TIME
	var fade := clampf(1.0 - (t - EXPLOSION_TIME * 0.6) / (EXPLOSION_TIME * 0.4), 0.0, 1.0)
	var index := int(_time * 30.0)
	var outer := COLORS[index % COLORS.size()]
	var inner := COLORS[(index + 2) % COLORS.size()]
	outer.a = 0.75 * fade
	inner.a = 0.9 * fade
	draw_circle(Vector2.ZERO, _radius, outer)
	draw_circle(Vector2.ZERO, _radius * 0.65, inner)
	draw_arc(Vector2.ZERO, _radius, 0, TAU, 48, Color(1, 1, 1, fade), 3.0)
