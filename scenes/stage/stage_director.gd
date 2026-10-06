class_name StageDirector
extends Node
## Roteiro do jogo: ondas de inimigos, ondas de recompensa e chefes.
## Cada parte é uma função; a ordem está em _run(). Os números de
## dificuldade ficam nas constantes abaixo para facilitar ajustes.
##
## As esperas usam o sinal "frame" deste nó: se o diretor for removido
## (recomeçar o jogo), o roteiro para sozinho.

signal frame(delta: float)
signal finished
signal announce(text: String)

## Partes do jogo (também usadas pelos atalhos F1-F6).
enum Section { WAVE_1, WAVE_2, BOSS_OCTOPUS, WAVE_3, BONUS, FINAL_BOSS }

# Onda 1
const WAVE_1_GROUPS := 8
const WAVE_1_GROUP_INTERVAL := 6.0
const WAVE_1_MAX_ALIVE := 6
# Onda 2
const WAVE_2_OCTOPUS_TOTAL := 40
const WAVE_2_MAX_OCTOPUS_ALIVE := 10
const WAVE_2_START_COOLDOWN := 3.5
const WAVE_2_END_COOLDOWN := 1.2
# Onda 3 (meteoros): duração de cada parte e intervalo entre meteoros
const WAVE_3_PART_TIME := 35.0
const WAVE_3_INTERVALS := [1.3, 0.9, 0.6]
# Recompensas
const CRATES_PER_REWARD := Vector2i(5, 8)
const RARE_CRATE_CHANCE := 0.15
const CLEAR_TIMEOUT := 15.0

var background: ScrollingBackground


func _physics_process(delta: float) -> void:
	frame.emit(delta)


func start(from: Section = Section.WAVE_1) -> void:
	_run(from)


func _run(from: Section) -> void:
	var sections := [_wave_1, _wave_2, _boss_octopus, _wave_3, _bonus, _final_boss]
	for i in range(from, sections.size()):
		await sections[i].call()
	finished.emit()


# --- Partes do jogo ----------------------------------------------------------

func _wave_1() -> void:
	Audio.play_music(&"music_wave_1")
	background.set_playlist([1, 2])
	announce.emit("ONDA 1")
	await _wait(2.0)
	for group in WAVE_1_GROUPS:
		if group == WAVE_1_GROUPS / 2:
			await _benefactor_break()
		await _wait_until(func() -> bool: return _count(&"astronauts") < WAVE_1_MAX_ALIVE, 10.0)
		var amount := mini(1 + group / 2, 4)
		for i in amount:
			_spawn_astronaut()
		await _wait(WAVE_1_GROUP_INTERVAL)
	await _wait_until_clear()
	await _reward_crates()


func _wave_2() -> void:
	Audio.play_music(&"music_wave_2")
	background.set_playlist([2, 3, 4])
	announce.emit("ONDA 2")
	await _wait(2.0)
	var spawned := 0
	var had_break := false
	while spawned < WAVE_2_OCTOPUS_TOTAL:
		var progress := float(spawned) / WAVE_2_OCTOPUS_TOTAL
		if not had_break and progress >= 0.5:
			had_break = true
			await _benefactor_break()
		# Cada vez mais polvos e menos astronautas, até só restarem polvos.
		var octopus_amount := 1 + int(progress * 4.0)
		for i in octopus_amount:
			if _count(&"octopuses") < WAVE_2_MAX_OCTOPUS_ALIVE:
				_spawn_octopus()
				spawned += 1
		if randf() < 1.0 - progress * 1.6:
			_spawn_astronaut()
		await _wait(lerpf(WAVE_2_START_COOLDOWN, WAVE_2_END_COOLDOWN, progress))
	await _wait_until_clear()


func _boss_octopus() -> void:
	background.set_playlist([2, 3, 4])
	await _boss_warning()
	var boss := BossOctopus.new()
	GameState.spawn(boss, Vector2.ZERO)
	await boss.died
	await _wait(2.0)
	await _reward_crates()


func _wave_3() -> void:
	Audio.play_music(&"music_wave_3")
	background.set_playlist([5])
	var parts := [[1, 2], [3, 4, 5], [1, 2, 3, 4, 5]]
	for part in parts.size():
		announce.emit("CHUVA DE METEOROS" if part == 0 else "PARTE %d" % (part + 1))
		var elapsed := 0.0
		while elapsed < WAVE_3_PART_TIME:
			_spawn_meteor(parts[part].pick_random())
			var interval: float = WAVE_3_INTERVALS[part] * randf_range(0.7, 1.3)
			await _wait(interval)
			elapsed += interval
		if part == 1:
			await _benefactor_break()
	await _wait_until_clear()
	await _reward_crates()


## Parte bônus antes do chefe final: 2 ou 3 ondas de recompensa aleatórias.
func _bonus() -> void:
	Audio.play_music(&"music_wave_3")  # continua a música da chuva de meteoros
	announce.emit("BÔNUS!")
	for i in randi_range(2, 3):
		if randf() < 0.5:
			await _reward_crates()
		else:
			await _benefactor_break()


func _final_boss() -> void:
	await _wait_until_clear()
	background.set_playlist([1])
	background.warp()  # o fundo volta para a imagem 1 bem na chegada do chefe
	await _boss_warning()
	var boss := BossFinal.new()
	GameState.spawn(boss, Vector2.ZERO)
	await boss.died
	await _wait(2.0)


# --- Ondas de recompensa -----------------------------------------------------

func _reward_crates() -> void:
	announce.emit("RECOMPENSA!")
	for i in randi_range(CRATES_PER_REWARD.x, CRATES_PER_REWARD.y):
		var kind := 2 if randf() < RARE_CRATE_CHANCE else 1
		GameState.spawn(Crate.create(kind), Vector2(randf_range(40, 600), -30))
		await _wait(randf_range(0.8, 1.6))
	await _wait_until_clear()


## Calmaria: os inimigos param de vir e a nave amiga traz presentes.
func _benefactor_break() -> void:
	await _wait_until_clear(10.0)
	await _wait(1.0)
	GameState.spawn(BenefactorShip.new(), Vector2(randf_range(120, 520), GameState.SCREEN.y + 40))
	await _wait(5.0)


func _boss_warning() -> void:
	await _wait_until_clear()
	Audio.stop_music(1.0)
	await _wait(1.0)
	announce.emit("ALERTA: CHEFE SE APROXIMANDO!")
	for i in 3:
		Audio.play_sfx(&"boss_alert")
		await _wait(0.6)
	Audio.play_music(&"music_boss")
	await _wait(0.5)


# --- Criação de inimigos -----------------------------------------------------

func _spawn_astronaut() -> void:
	GameState.spawn(Astronaut.new(), Vector2(randf_range(30, 610), randf_range(-220, -120)))


func _spawn_octopus() -> void:
	var octopus := Octopus.new()
	octopus.add_to_group(&"octopuses")
	GameState.spawn(octopus, Vector2(randf_range(30, 610), randf_range(-80, -30)))


func _spawn_meteor(kind: int) -> void:
	GameState.spawn(Meteor.create(kind), Vector2(randf_range(20, 620), -40))


# --- Ajudantes de tempo ------------------------------------------------------

func _wait(seconds: float) -> void:
	while seconds > 0.0:
		seconds -= await frame


## Espera uma condição ficar verdadeira (ou o tempo limite acabar).
func _wait_until(condition: Callable, timeout: float) -> void:
	while timeout > 0.0 and not condition.call():
		timeout -= await frame


## Espera a tela ficar sem inimigos (ou o tempo limite acabar).
func _wait_until_clear(timeout := CLEAR_TIMEOUT) -> void:
	await _wait_until(func() -> bool: return _count(&"enemies") == 0, timeout)


func _count(group: StringName) -> int:
	return get_tree().get_node_count_in_group(group)
