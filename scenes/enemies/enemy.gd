class_name Enemy
extends Area2D
## Base de todos os inimigos (inclusive meteoros, caixas e chefes).
## Cuida de vida, dano, "flash" ao ser atingido, pontos e morte.

signal died(enemy: Enemy)

const TINT_SHADER := preload("res://shaders/tint.gdshader")
const FLASH_TIME := 0.08

var max_hp := 1
var hp := 1
var score_value := 100
## Dano causado ao jogador quando encosta nele (0 = não causa dano).
var contact_damage := 0
## Se verdadeiro, o inimigo é destruído ao encostar no jogador.
var dies_on_contact := true
## Raio do colisor (também usado pela bomba).
var radius := 10.0
var invulnerable := false
var dead := false
var sprite := Sprite2D.new()
var _flash_time := 0.0
var _was_on_screen := false


## Cria o sprite e o colisor. Chame no _init/_ready das classes filhas.
func setup(texture: Texture2D, hit_points: int, collider_radius: float, sprite_scale := 1.0) -> void:
	max_hp = hit_points
	hp = hit_points
	radius = collider_radius * sprite_scale
	sprite.texture = texture
	sprite.scale = Vector2.ONE * sprite_scale
	var material := ShaderMaterial.new()
	material.shader = TINT_SHADER
	sprite.material = material
	add_child(sprite)
	GameState.setup_area(self, radius, GameState.LAYER_ENEMY, 0)
	add_to_group(&"enemies")


func _process(delta: float) -> void:
	if _flash_time > 0.0:
		_flash_time -= delta
		sprite.material.set_shader_parameter("amount", 0.8 if _flash_time > 0.0 else 0.0)


func can_be_hit() -> bool:
	return not dead and not invulnerable


func take_damage(amount: int, play_sound := true) -> void:
	if not can_be_hit():
		return
	hp -= amount
	_flash_time = FLASH_TIME
	if hp <= 0:
		die()
	elif play_sound:
		Audio.play_sfx(&"enemy_hit", 0.1)


## Morte "normal": dá pontos, efeito, som e possivelmente um item.
func die() -> void:
	if dead:
		return
	dead = true
	GameState.add_score(score_value)
	_death_effect()
	_drop_loot()
	died.emit(self)
	queue_free()


## Chamado quando o jogador encosta neste inimigo.
func on_player_contact() -> void:
	if dies_on_contact:
		explode()


## Destrói o inimigo só com o efeito visual: sem pontos e sem itens.
func explode() -> void:
	if dead:
		return
	dead = true
	_death_effect()
	died.emit(self)
	queue_free()


func _death_effect() -> void:
	Audio.play_sfx(&"enemy_death", 0.1)
	Fx.small_explosion(global_position)


func _drop_loot() -> void:
	pass


## Remove inimigos que já passaram pela tela e saíram dela.
func _cull_if_offscreen(margin := 80.0) -> void:
	var visible_now := GameState.on_screen(global_position, radius)
	if visible_now:
		_was_on_screen = true
	elif (_was_on_screen and not GameState.on_screen(global_position, margin)) \
			or global_position.y > GameState.SCREEN.y + margin:
		died.emit(self)
		queue_free()
