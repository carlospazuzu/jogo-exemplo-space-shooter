class_name Beam
extends Area2D
## Feixe de luz do chefe final, feito em código (não há imagem para ele).
## Aponta para o +X local. Primeiro "avisa" (linha fina piscando, sem dano)
## e depois dispara de verdade.

const WARNING_TIME := 0.5
const LENGTH := 900.0
const TEXTURE := preload("res://space-shooter/shots/12.png")

var damage := 2
var thickness := 34.0
var _time := 0.0
var _active := false
var _sound: AudioStreamPlayer


func _ready() -> void:
	collision_layer = GameState.LAYER_ENEMY_SHOT
	collision_mask = 0
	monitorable = false
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(LENGTH, thickness * 0.6)
	shape.shape = rect
	shape.position = Vector2(LENGTH / 2, 0)
	add_child(shape)
	add_to_group(&"beams")
	z_index = 4


func _process(delta: float) -> void:
	_time += delta
	if not _active and _time >= WARNING_TIME:
		_active = true
		monitorable = true
		_sound = Audio.play_sfx(&"boss_beam")
	queue_redraw()


func stop() -> void:
	queue_free()


func _exit_tree() -> void:
	Audio.stop_sfx(_sound)  # o som do feixe para junto com ele


func _draw() -> void:
	if not _active:
		if int(_time * 20.0) % 2 == 0:
			draw_line(Vector2.ZERO, Vector2(LENGTH, 0), Color(1, 0.9, 0.5, 0.7), 2.0)
		return
	var pulse := 1.0 + 0.15 * sin(_time * 40.0)
	var half := thickness * 0.5 * pulse
	draw_rect(Rect2(0, -half, LENGTH, half * 2), Color(1.0, 0.55, 0.15, 0.45))
	draw_rect(Rect2(0, -half * 0.65, LENGTH, half * 1.3), Color(1.0, 0.85, 0.3, 0.85))
	draw_rect(Rect2(0, -half * 0.3, LENGTH, half * 0.6), Color(1, 1, 0.95))
	# Clarão na boca do canhão usando o sprite shots/12 deitado.
	draw_set_transform(Vector2.ZERO, -PI / 2, Vector2.ONE * pulse * 1.2)
	draw_texture(TEXTURE, -TEXTURE.get_size() / 2)
