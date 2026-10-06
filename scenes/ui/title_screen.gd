class_name TitleScreen
extends Control
## Tela inicial: logo do jogo e a mensagem piscando. Sem música (silêncio).

signal start_requested

var _press_start := UiStyle.centered_label("APERTE ENTER PARA INICIAR", 300, 16)
var _time := 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(UiStyle.pixel_text("SPACE SHOOTER", Vector2(320, 170), 3.0))
	add_child(_press_start)
	add_child(UiStyle.centered_label("SETAS: mover   Z: atirar   X: trocar arma   ESC: pausa", 430, 8, Color(1, 1, 1, 0.7)))
	if OS.is_debug_build():
		add_child(UiStyle.centered_label("F1-F6: pular para uma parte do jogo (teste de áudio)", 450, 8, Color(1, 1, 1, 0.5)))


func _process(delta: float) -> void:
	_time += delta
	_press_start.visible = fmod(_time, 1.0) < 0.6


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"confirm"):
		get_viewport().set_input_as_handled()
		Audio.play_sfx(&"menu_confirm")
		start_requested.emit()
