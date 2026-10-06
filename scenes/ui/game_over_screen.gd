class_name GameOverScreen
extends Control
## Tela de fim de jogo (derrota ou vitória):
## mensagem -> (se bateu recorde) escolha das 3 letras -> ranking + opções.

signal restart_requested
signal title_requested

enum Step { MESSAGE, NAME_ENTRY, RANKING }

## Tempo da mensagem antes de liberar o ranking e as opções.
const MESSAGE_TIME := 3.0
const LETTERS := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "
const OPTIONS := ["RECOMEÇAR", "TELA INICIAL"]

var victory := false
var _step := Step.MESSAGE
var _letters: Array[int] = [0, 0, 0]
var _cursor := 0
var _letter_nodes: Array[PixelText] = []
var _option_labels: Array[Label] = []
var _selected := 0
var _new_rank := -1
var _content := Control.new()
var _time := 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_content)
	if victory:
		_content.add_child(UiStyle.pixel_text("VOCE VENCEU!", Vector2(320, 200), 2.0))
		_content.add_child(UiStyle.centered_label("O universo está a salvo!", 240, 8, Color("#ffd23f")))
	else:
		_content.add_child(UiStyle.pixel_text("GAME OVER", Vector2(320, 220), 2.0))
	# Timer filho: se a tela for removida antes, a espera é simplesmente cancelada.
	var timer := Timer.new()
	add_child(timer)
	timer.start(MESSAGE_TIME)
	await timer.timeout
	timer.queue_free()
	if HighScores.qualifies(GameState.score):
		_show_name_entry()
	else:
		_show_ranking()


func _process(delta: float) -> void:
	_time += delta
	if _step == Step.NAME_ENTRY:
		for i in _letter_nodes.size():
			var blink := i == _cursor and int(_time * 6.0) % 2 == 0
			_letter_nodes[i].modulate = Color("#ffd23f") if blink else Color.WHITE
	elif _step == Step.RANKING and _new_rank >= 0:
		var row: CanvasItem = _content.get_node_or_null("Row%d" % _new_rank)
		if row:
			row.modulate = Color("#ffd23f") if int(_time * 4.0) % 2 == 0 else Color.WHITE


func _unhandled_input(event: InputEvent) -> void:
	match _step:
		Step.NAME_ENTRY:
			_name_entry_input(event)
		Step.RANKING:
			_menu_input(event)


func _clear() -> void:
	for child in _content.get_children():
		child.queue_free()


# --- Escolha das 3 letras, estilo arcade -------------------------------------

func _show_name_entry() -> void:
	_clear()
	_step = Step.NAME_ENTRY
	_content.add_child(UiStyle.pixel_text("NOVO RECORDE!", Vector2(320, 110), 1.5))
	_content.add_child(UiStyle.pixel_text("%07d" % GameState.score, Vector2(320, 160)))
	_content.add_child(UiStyle.centered_label("CIMA/BAIXO: letra   ESQ/DIR: mover   ENTER: ok", 320, 8))
	for i in 3:
		var letter := UiStyle.pixel_text("", Vector2(260 + i * 60, 240), 3.0)
		_content.add_child(letter)
		_letter_nodes.append(letter)
	_update_letters()


func _name_entry_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"move_up", true):
		_change_letter(1)
	elif event.is_action_pressed(&"move_down", true):
		_change_letter(-1)
	elif event.is_action_pressed(&"move_left"):
		_cursor = maxi(_cursor - 1, 0)
		Audio.play_sfx(&"menu_move")
	elif event.is_action_pressed(&"move_right"):
		_cursor = mini(_cursor + 1, 2)
		Audio.play_sfx(&"menu_move")
	elif event.is_action_pressed(&"confirm"):
		Audio.play_sfx(&"menu_confirm")
		if _cursor < 2:
			_cursor += 1
		else:
			var player_name := ""
			for index in _letters:
				player_name += LETTERS[index]
			_new_rank = HighScores.insert(player_name, GameState.score)
			_show_ranking()
	else:
		return
	get_viewport().set_input_as_handled()


func _change_letter(step: int) -> void:
	_letters[_cursor] = wrapi(_letters[_cursor] + step, 0, LETTERS.length())
	_update_letters()
	Audio.play_sfx(&"menu_move")


func _update_letters() -> void:
	for i in 3:
		var character := LETTERS[_letters[i]]
		_letter_nodes[i].text = "_" if character == " " else character


# --- Ranking e opções --------------------------------------------------------

func _show_ranking() -> void:
	_clear()
	_letter_nodes.clear()
	_step = Step.RANKING
	_content.add_child(UiStyle.pixel_text("TOP 10", Vector2(320, 40), 1.5))
	for i in HighScores.entries.size():
		var entry: Dictionary = HighScores.entries[i]
		var row := UiStyle.pixel_text("%2d %s %07d" % [i + 1, entry.name, entry.score], Vector2(320, 84 + i * 26))
		row.name = "Row%d" % i
		_content.add_child(row)
	for i in OPTIONS.size():
		var option := UiStyle.centered_label("", 370 + i * 22, 16)
		_content.add_child(option)
		_option_labels.append(option)
	_update_options()


func _menu_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"move_up") or event.is_action_pressed(&"move_down"):
		_selected = 1 - _selected
		_update_options()
		Audio.play_sfx(&"menu_move")
	elif event.is_action_pressed(&"confirm"):
		Audio.play_sfx(&"menu_confirm")
		set_process_unhandled_input(false)
		if _selected == 0:
			restart_requested.emit()
		else:
			title_requested.emit()
	else:
		return
	get_viewport().set_input_as_handled()


func _update_options() -> void:
	for i in _option_labels.size():
		var selected := i == _selected
		_option_labels[i].text = ("> %s <" if selected else "%s") % OPTIONS[i]
		_option_labels[i].label_settings.font_color = Color("#ffd23f") if selected else Color.WHITE
