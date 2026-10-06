class_name Meteor
extends Enemy
## Meteoro (tipos 1 a 5). Os maiores se partem em menores quando destruídos.
## Ao bater no jogador, o meteoro some e causa dano.

## Tabela dos meteoros: vida, dano, velocidade, filhos gerados e pontos.
const TYPES := {
	1: { "hp": 10, "damage": 4, "speed": 35.0, "children": [2, 2], "score": 300, "radius": 18.0 },
	2: { "hp": 6, "damage": 2, "speed": 60.0, "children": [], "score": 120, "radius": 9.0 },
	3: { "hp": 5, "damage": 3, "speed": 95.0, "children": [4, 4, 4, 4], "score": 200, "radius": 14.0 },
	4: { "hp": 3, "damage": 2, "speed": 150.0, "children": [5, 5, 5, 5, 5, 5], "score": 100, "radius": 11.0 },
	5: { "hp": 1, "damage": 1, "speed": 210.0, "children": [], "score": 50, "radius": 7.0 },
}

var kind := 1
var velocity := Vector2.ZERO
var _spin := 0.0


## Cria um meteoro. Sem direção, ele cai para baixo com um leve desvio.
static func create(meteor_kind: int, direction := Vector2.ZERO) -> Meteor:
	var meteor := Meteor.new()
	meteor.kind = meteor_kind
	var data: Dictionary = TYPES[meteor_kind]
	meteor.setup(load("res://space-shooter/backgrounds/meteor-%d.png" % meteor_kind), data.hp, data.radius)
	meteor.contact_damage = data.damage
	meteor.score_value = data.score
	if direction == Vector2.ZERO:
		direction = Vector2(randf_range(-0.25, 0.25), 1.0).normalized()
	meteor.velocity = direction.normalized() * data.speed * randf_range(0.85, 1.15)
	meteor._spin = randf_range(-2.0, 2.0)
	return meteor


func _physics_process(delta: float) -> void:
	position += velocity * delta
	sprite.rotation += _spin * delta
	_cull_if_offscreen()


func _death_effect() -> void:
	Audio.play_sfx(&"meteor_break", 0.15)
	Fx.small_explosion(global_position, radius / 12.0)


## Ao ser destruído, gera os meteoros menores.
func _drop_loot() -> void:
	var children: Array = TYPES[kind].children
	for i in children.size():
		var direction := Vector2.from_angle(randf() * TAU)
		# O meteoro 1 manda o primeiro pedaço na direção do jogador.
		if kind == 1 and i == 0:
			direction = global_position.direction_to(GameState.player_position())
		GameState.spawn.call_deferred(Meteor.create(children[i], direction), global_position)
