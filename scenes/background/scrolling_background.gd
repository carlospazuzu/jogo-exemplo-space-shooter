class_name ScrollingBackground
extends Node2D
## Fundo com scroll vertical infinito. Duas "folhas" de 640x480 se revezam:
## quando uma sai por baixo, volta para cima com a próxima imagem da playlist.
## Cada folha recebe algumas decorações (planetas, estrelas, lua) em lugares
## livres, longe dos desenhos que já existem nos fundos 2, 3 e 4.

const SIZE := Vector2(640, 480)
const TEXTURES := {
	1: preload("res://space-shooter/backgrounds/1.png"),
	2: preload("res://space-shooter/backgrounds/2.png"),
	3: preload("res://space-shooter/backgrounds/3.png"),
	4: preload("res://space-shooter/backgrounds/4.png"),
	5: preload("res://space-shooter/backgrounds/5.png"),
}
const DECORATIONS: Array[Texture2D] = [
	preload("res://space-shooter/backgrounds/planet-1.png"),
	preload("res://space-shooter/backgrounds/planet-2.png"),
	preload("res://space-shooter/backgrounds/star-1.png"),
	preload("res://space-shooter/backgrounds/star-2.png"),
	preload("res://space-shooter/backgrounds/moon.png"),
]
## Áreas de cada fundo que já têm desenhos (buraco negro, planetas, lua...).
const BUSY_AREAS := {
	2: [Rect2(440, 60, 140, 110), Rect2(65, 310, 45, 40)],
	3: [Rect2(110, 225, 150, 160), Rect2(50, 330, 50, 45), Rect2(520, 235, 45, 45)],
	4: [Rect2(420, 105, 95, 85), Rect2(100, 75, 55, 50), Rect2(260, 215, 65, 60),
		Rect2(70, 265, 40, 40), Rect2(495, 295, 40, 40), Rect2(395, 345, 40, 35),
		Rect2(360, 80, 50, 45), Rect2(160, 365, 50, 45)],
	5: [Rect2(Vector2.ZERO, SIZE)],  # a chuva de meteoros já é cheia demais
}
const DECORATION_GAP := 40.0

@export var speed := 45.0

var _playlist: Array = [1, 2]
var _next_index := 0
var _sheets: Array[Sprite2D] = []


func _ready() -> void:
	z_index = -10
	for i in 2:
		var sheet := Sprite2D.new()
		sheet.centered = false
		sheet.position.y = -SIZE.y * i
		add_child(sheet)
		_sheets.append(sheet)
		_assign_next_texture(sheet)


## Define as imagens de fundo da onda atual (ex.: [2, 3, 4]).
## A troca aparece quando a próxima folha entrar pela parte de cima.
func set_playlist(ids: Array) -> void:
	_playlist = ids
	_next_index = 0


## Acelera o fundo por um instante ("dobra espacial") para que a nova
## playlist apareça na hora. Duas folhas inteiras passam durante o warp.
func warp() -> void:
	var normal_speed := speed
	var tween := create_tween()
	tween.tween_property(self, "speed", 700.0, 0.5).set_ease(Tween.EASE_IN)
	tween.tween_interval(1.4)
	tween.tween_property(self, "speed", normal_speed, 0.8).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	for sheet in _sheets:
		sheet.position.y += speed * delta
	for sheet in _sheets:
		if sheet.position.y >= SIZE.y:
			sheet.position.y -= SIZE.y * 2
			_assign_next_texture(sheet)


func _assign_next_texture(sheet: Sprite2D) -> void:
	var id: int = _playlist[_next_index % _playlist.size()]
	_next_index += 1
	sheet.texture = TEXTURES[id]
	for child in sheet.get_children():
		child.queue_free()
	_decorate(sheet, id)


func _decorate(sheet: Sprite2D, background_id: int) -> void:
	var taken: Array = BUSY_AREAS.get(background_id, []).duplicate()
	for i in randi_range(0, 2):
		var texture: Texture2D = DECORATIONS.pick_random()
		for attempt in 12:
			var rect := Rect2(
					Vector2(randf_range(0, SIZE.x - texture.get_width()), randf_range(0, SIZE.y - texture.get_height())),
					texture.get_size())
			if taken.any(func(busy: Rect2) -> bool: return busy.grow(DECORATION_GAP).intersects(rect)):
				continue
			taken.append(rect)
			var decoration := Sprite2D.new()
			decoration.texture = texture
			decoration.centered = false
			decoration.position = rect.position
			decoration.modulate = Color(1, 1, 1, randf_range(0.7, 1.0))
			sheet.add_child(decoration)
			break
