extends Node
## Gerenciador de áudio (autoload "Audio").
##
## O jogo nunca aponta para arquivos de som diretamente: ele pede um EVENTO
## (ex.: Audio.play_sfx(&"enemy_death")) e este script busca o arquivo no
## banco de sons "res://audio/sound_bank.tres".

const BANK_PATH := "res://audio/sound_bank.tres"
const SFX_VOICES := 24
## Quantas cópias do mesmo efeito podem tocar ao mesmo tempo.
const MAX_SAME_SFX := 3

var bank: SoundBank = load(BANK_PATH)

var _music_player := AudioStreamPlayer.new()
var _music_event: StringName = &""
var _music_tween: Tween
var _voices: Array[AudioStreamPlayer] = []
var _voice_events := {}  # AudioStreamPlayer -> StringName
var _next_voice := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_music_player)
	for i in SFX_VOICES:
		var voice := AudioStreamPlayer.new()
		add_child(voice)
		_voices.append(voice)


## Toca um efeito sonoro. Devolve o player usado (ou null se o evento estiver vazio).
func play_sfx(event: StringName, pitch_variation := 0.0) -> AudioStreamPlayer:
	var stream := _stream_for(event)
	if stream == null:
		return null
	var voice := _free_voice(event)
	if voice == null:
		return null
	voice.stream = stream
	voice.volume_db = bank.sfx_volume_db
	voice.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	_voice_events[voice] = event
	voice.play()
	return voice


## Para um efeito que ainda está tocando (ex.: o feixe do chefe final).
func stop_sfx(voice: AudioStreamPlayer) -> void:
	if voice:
		voice.stop()


## Começa uma música em loop. Se a mesma música já está tocando, nada muda.
func play_music(event: StringName) -> void:
	if event == _music_event and _music_player.playing:
		return
	var stream := _stream_for(event)
	_music_event = event
	_kill_music_tween()
	_music_player.stop()
	if stream == null:
		return
	_enable_loop(stream)
	_music_player.stream = stream
	_music_player.volume_db = bank.music_volume_db
	_music_player.play()


## Para a música com um fade-out curto. As telas fora do gameplay ficam em silêncio.
func stop_music(fade_time := 0.6) -> void:
	_music_event = &""
	_kill_music_tween()
	if not _music_player.playing:
		return
	_music_tween = create_tween()
	_music_tween.tween_property(_music_player, "volume_db", -60.0, fade_time)
	_music_tween.tween_callback(_music_player.stop)


func _stream_for(event: StringName) -> AudioStream:
	if not event in bank:
		push_warning("Evento de som desconhecido: %s" % event)
		return null
	return bank.get(event)


func _free_voice(event: StringName) -> AudioStreamPlayer:
	var same_event_playing: Array[AudioStreamPlayer] = []
	for voice in _voices:
		if voice.playing and _voice_events.get(voice) == event:
			same_event_playing.append(voice)
	if same_event_playing.size() >= MAX_SAME_SFX:
		return same_event_playing[0]  # reaproveita: corta a cópia mais antiga
	for voice in _voices:
		if not voice.playing:
			return voice
	_next_voice = (_next_voice + 1) % _voices.size()
	return _voices[_next_voice]


func _enable_loop(stream: AudioStream) -> void:
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_end = int(stream.get_length() * stream.mix_rate)
	elif "loop" in stream:
		stream.loop = true


func _kill_music_tween() -> void:
	if _music_tween and _music_tween.is_valid():
		_music_tween.kill()
