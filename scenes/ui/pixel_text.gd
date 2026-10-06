@tool
class_name PixelText
extends Control
## Desenha texto usando a fonte bitmap "font-20x20.png" (grade de 15 colunas,
## caracteres ASCII a partir do espaço). Usado no logo, pontos e ranking.

const FONT := preload("res://space-shooter/font-20x20.png")
const CELL := 20
const COLUMNS := 15
const FIRST_CHAR := 32
const ADVANCE := 15

@export var text := "":
	set(value):
		text = value
		_refresh()
@export var glyph_scale := 1.0:
	set(value):
		glyph_scale = value
		_refresh()
## Se verdadeiro, o texto fica centralizado na posição do nó.
@export var centered := false:
	set(value):
		centered = value
		_refresh()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_refresh()


func text_width() -> float:
	return (text.length() * ADVANCE + (CELL - ADVANCE)) * glyph_scale if text else 0.0


func _refresh() -> void:
	custom_minimum_size = Vector2(text_width(), CELL * glyph_scale)
	size = custom_minimum_size
	queue_redraw()


func _draw() -> void:
	var origin := Vector2(-text_width() / 2.0, -CELL * glyph_scale / 2.0) if centered else Vector2.ZERO
	var upper := text.to_upper()
	for i in upper.length():
		var index := upper.unicode_at(i) - FIRST_CHAR
		if index <= 0 or index >= COLUMNS * 8:
			continue
		var source := Rect2(Vector2(index % COLUMNS, index / COLUMNS) * CELL, Vector2(CELL, CELL))
		var target := Rect2(origin + Vector2(i * ADVANCE * glyph_scale, 0), Vector2(CELL, CELL) * glyph_scale)
		draw_texture_rect_region(FONT, target, source)
