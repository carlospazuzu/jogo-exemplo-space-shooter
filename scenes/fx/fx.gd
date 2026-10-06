class_name Fx
extends Sprite2D
## Efeito visual de uma vez só, tocado a partir de uma spritesheet horizontal.
## Some sozinho quando termina. Use as funções estáticas (Fx.explosion(...) etc.).

const SMALL_EXPLOSION := preload("res://space-shooter/effects/fx-1.png")  # 6 quadros
const SPARK := preload("res://space-shooter/effects/fx-5.png")            # 5 quadros
const BIG_EXPLOSION := preload("res://space-shooter/effects/fx-7.png")    # 8 quadros
const HIT := preload("res://space-shooter/effects/fx-3.png")              # 6 quadros

var fps := 15.0
var _time := 0.0


static func play(sheet: Texture2D, frames: int, at: Vector2, color := Color.WHITE,
		fx_scale := 1.0, frames_per_second := 15.0) -> Fx:
	var fx := Fx.new()
	fx.texture = sheet
	fx.hframes = frames
	fx.modulate = color
	fx.scale = Vector2.ONE * fx_scale
	fx.fps = frames_per_second
	fx.z_index = 5
	GameState.spawn(fx, at)
	return fx


## Explosão pequena (morte de inimigos comuns).
static func small_explosion(at: Vector2, fx_scale := 1.0) -> Fx:
	return play(SMALL_EXPLOSION, 6, at, Color(1.0, 0.85, 0.5), fx_scale)


## Explosão grande (nave do jogador, chefes).
static func explosion(at: Vector2, fx_scale := 1.0) -> Fx:
	return play(BIG_EXPLOSION, 8, at, Color(1.0, 0.75, 0.35), fx_scale, 14.0)


## Faísca (caixas quebrando).
static func spark(at: Vector2, fx_scale := 2.0) -> Fx:
	return play(SPARK, 5, at, Color(1.0, 0.95, 0.6), fx_scale, 12.0)


## Pequeno impacto quando um tiro acerta.
static func hit(at: Vector2) -> Fx:
	return play(HIT, 6, at, Color(1.0, 1.0, 0.8, 0.8), 0.5, 30.0)


func _process(delta: float) -> void:
	_time += delta
	var current := int(_time * fps)
	if current >= hframes:
		queue_free()
	else:
		frame = current
