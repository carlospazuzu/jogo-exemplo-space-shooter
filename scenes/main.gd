extends Node
## Cena principal. Controla os estados do jogo:
## TÍTULO -> JOGANDO -> GAME OVER / VITÓRIA (letras + ranking) -> ...
##
## Atalhos de teste (apenas rodando pelo editor): F1 a F6 começam o jogo
## direto numa parte, para ouvir rapidamente a música e os sons dela.

enum State { TITLE, PLAYING, GAME_OVER }

const RESPAWN_DELAY := 1.5
const GAME_OVER_DELAY := 1.5
const PLAYER_START := Vector2(320, 420)
const DEBUG_KEYS := {
	KEY_F1: StageDirector.Section.WAVE_1,
	KEY_F2: StageDirector.Section.WAVE_2,
	KEY_F3: StageDirector.Section.BOSS_OCTOPUS,
	KEY_F4: StageDirector.Section.WAVE_3,
	KEY_F5: StageDirector.Section.BONUS,
	KEY_F6: StageDirector.Section.FINAL_BOSS,
}

## Parte em que o jogo começa ao apertar Enter na tela inicial.
@export var start_section := StageDirector.Section.WAVE_1

var _state := State.TITLE
var _background := ScrollingBackground.new()
var _world := Node2D.new()
var _hud := Hud.new()
var _screens := CanvasLayer.new()
var _pause_label := UiStyle.centered_label("PAUSA", 220, 16, Color("#ffd23f"))
var _director: StageDirector
var _player: Player


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_background.process_mode = Node.PROCESS_MODE_PAUSABLE
	_world.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(_background)
	add_child(_world)
	add_child(_hud)
	_screens.layer = 20
	add_child(_screens)
	_pause_label.hide()
	_screens.add_child(_pause_label)
	GameState.world = _world
	_show_title()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause") and _state == State.PLAYING:
		get_tree().paused = not get_tree().paused
		_pause_label.visible = get_tree().paused
		get_viewport().set_input_as_handled()
	elif OS.is_debug_build() and event is InputEventKey and event.pressed \
			and not event.echo and event.keycode in DEBUG_KEYS:
		_start_game(DEBUG_KEYS[event.keycode])
		get_viewport().set_input_as_handled()


# --- Estados -----------------------------------------------------------------

func _show_title() -> void:
	_state = State.TITLE
	_clear_game()
	Audio.stop_music()
	_hud.hide()
	_background.set_playlist([1, 2])
	var title := TitleScreen.new()
	title.start_requested.connect(func() -> void: _start_game(start_section))
	_screens.add_child(title)


func _start_game(section: StageDirector.Section) -> void:
	_state = State.PLAYING
	get_tree().paused = false
	_pause_label.hide()
	_clear_game()
	GameState.new_game()
	_hud.refresh()
	_hud.show()

	_player = Player.new()
	_player.destroyed.connect(_on_player_destroyed)
	GameState.player = _player
	GameState.spawn(_player, PLAYER_START)

	_director = StageDirector.new()
	_director.process_mode = Node.PROCESS_MODE_PAUSABLE
	_director.background = _background
	_director.announce.connect(_hud.announce)
	_director.finished.connect(_on_victory)
	add_child(_director)
	_director.start(section)


func _on_player_destroyed() -> void:
	GameState.lose_life()
	if GameState.lives > 0:
		await get_tree().create_timer(RESPAWN_DELAY, false).timeout
		if _state == State.PLAYING and is_instance_valid(_player) and not _player.alive:
			GameState.reset_powerups()  # morreu: perde todos os power-ups
			_player.respawn(PLAYER_START)
	else:
		_end_game(false)


func _on_victory() -> void:
	_end_game(true)


func _end_game(victory: bool) -> void:
	if _state != State.PLAYING:
		return
	_state = State.GAME_OVER
	if is_instance_valid(_director):
		_director.queue_free()  # para de criar inimigos; o fundo continua rolando
	if victory:
		if is_instance_valid(_player):
			_player.controls_enabled = false
		_clear_threats()  # vitória: tudo o que sobrou explode na hora
	Audio.stop_music(1.5)
	await get_tree().create_timer(GAME_OVER_DELAY).timeout
	if _state != State.GAME_OVER:
		return
	_clear_threats()  # deixa a tela limpa para o ranking
	var screen := GameOverScreen.new()
	screen.victory = victory
	screen.restart_requested.connect(func() -> void: _start_game(start_section))
	screen.title_requested.connect(_show_title)
	_screens.add_child(screen)


## Explode os inimigos que restaram e apaga os tiros inimigos.
func _clear_threats() -> void:
	for enemy: Enemy in get_tree().get_nodes_in_group(&"enemies"):
		enemy.explode()
	for shot in get_tree().get_nodes_in_group(&"enemy_shots"):
		shot.queue_free()
	for beam in get_tree().get_nodes_in_group(&"beams"):
		beam.queue_free()


## Remove inimigos, tiros, itens, telas e o roteiro da partida anterior.
func _clear_game() -> void:
	for child in _world.get_children():
		child.queue_free()
	for child in _screens.get_children():
		if child != _pause_label:
			child.queue_free()
	if is_instance_valid(_director):
		_director.queue_free()
	_director = null
	_player = null
	GameState.player = null
	GameState.boss_bar_visible.emit(false)
