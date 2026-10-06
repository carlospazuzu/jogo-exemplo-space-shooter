extends Node
## Ranking estilo arcade com as 10 maiores pontuações (autoload "HighScores").

const SAVE_PATH := "user://highscores.cfg"
const MAX_ENTRIES := 10
const DEFAULT_ENTRIES := [
	["ACE", 50000], ["ZAP", 40000], ["RAY", 30000], ["SKY", 25000], ["ORB", 20000],
	["UFO", 15000], ["GEM", 10000], ["MAX", 7500], ["ION", 5000], ["PIX", 2500],
]

## Lista de dicionários { "name": String, "score": int }, da maior para a menor.
var entries: Array = []


func _ready() -> void:
	_load()


func qualifies(score: int) -> bool:
	return score > 0 and (entries.size() < MAX_ENTRIES or score > entries[-1].score)


## Insere uma pontuação e devolve a posição (0 a 9), ou -1 se não entrou.
func insert(player_name: String, score: int) -> int:
	if not qualifies(score):
		return -1
	var index := 0
	while index < entries.size() and entries[index].score >= score:
		index += 1
	entries.insert(index, { "name": player_name, "score": score })
	entries.resize(mini(entries.size(), MAX_ENTRIES))
	_save()
	return index


func _load() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		entries = config.get_value("ranking", "entries", [])
	if entries.is_empty():
		for entry in DEFAULT_ENTRIES:
			entries.append({ "name": entry[0], "score": entry[1] })


func _save() -> void:
	var config := ConfigFile.new()
	config.set_value("ranking", "entries", entries)
	config.save(SAVE_PATH)
