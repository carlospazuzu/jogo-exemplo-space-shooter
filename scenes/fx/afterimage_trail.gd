class_name AfterimageTrail
extends Node
## Componente reutilizável: deixa "afterimagens" (cópias que somem aos poucos)
## de um Sprite2D enquanto ele se move, como o Alucard de Castlevania SOTN.
## Basta adicionar como filho e apontar o sprite.

const TINT_SHADER := preload("res://shaders/tint.gdshader")

@export var sprite: Sprite2D
@export var color := Color(0.45, 0.8, 1.0, 0.6)
## Intervalo entre uma cópia e outra, em segundos.
@export var interval := 0.05
## Tempo que cada cópia leva para sumir.
@export var lifetime := 0.35
## Só cria cópias se o sprite andou pelo menos esta distância (pixels/segundo).
@export var min_speed := 40.0
@export var enabled := true

var _timer := 0.0
var _last_position := Vector2.INF


func _physics_process(delta: float) -> void:
	if sprite == null or not enabled:
		return
	var current := sprite.global_position
	if _last_position == Vector2.INF:
		_last_position = current
	var speed := current.distance_to(_last_position) / maxf(delta, 0.0001)
	_last_position = current
	_timer -= delta
	if _timer <= 0.0 and speed >= min_speed:
		_timer = interval
		spawn_copy()


func spawn_copy() -> Sprite2D:
	var ghost := make_ghost(sprite, color)
	var tween := ghost.create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, lifetime)
	tween.tween_callback(ghost.queue_free)
	return ghost


## Cria uma cópia "fantasma" de um sprite, pintada com a cor dada.
static func make_ghost(source: Sprite2D, ghost_color: Color) -> Sprite2D:
	var ghost := Sprite2D.new()
	ghost.texture = source.texture
	ghost.hframes = source.hframes
	ghost.frame = source.frame
	ghost.flip_h = source.flip_h
	ghost.flip_v = source.flip_v
	ghost.global_rotation = source.global_rotation
	ghost.scale = source.global_scale
	ghost.z_index = -1
	var material := ShaderMaterial.new()
	material.shader = TINT_SHADER
	material.set_shader_parameter("tint", ghost_color)
	material.set_shader_parameter("amount", 0.85)
	ghost.material = material
	ghost.modulate.a = ghost_color.a
	GameState.spawn(ghost, source.global_position)
	return ghost
