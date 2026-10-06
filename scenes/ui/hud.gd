class_name Hud
extends CanvasLayer
## HUD: barra de vida, vidas, pontos, arma selecionada e vida do chefe.

const WEAPON_ICONS := {
	GameState.Weapon.NORMAL: preload("res://space-shooter/shots/1.png"),
	GameState.Weapon.BOMB: preload("res://space-shooter/items/bomb.png"),
	GameState.Weapon.ROCKET: preload("res://space-shooter/items/rocket-2.png"),
}

var _health := TextureProgressBar.new()
var _lives := UiStyle.label("x3", 8)
var _score := PixelText.new()
var _weapon_slots := {}
var _boss_bar := Control.new()
var _boss_fill := ColorRect.new()
var _banner := UiStyle.centered_label("", 200, 16, Color("#ffd23f"))
var _banner_tween: Tween


func _ready() -> void:
	layer = 10
	_health.texture_under = preload("res://space-shooter/hud/health-bar.png")
	_health.texture_progress = preload("res://space-shooter/hud/health-bar-fill.png")
	_health.texture_progress_offset = Vector2(9, 7)
	_health.max_value = GameState.MAX_HP
	_health.position = Vector2(8, 8)
	add_child(_health)

	var lives_icon := TextureRect.new()
	lives_icon.texture = preload("res://space-shooter/hud/lives-icon.png")
	lives_icon.position = Vector2(112, 11)
	add_child(lives_icon)
	_lives.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_lives.position = Vector2(142, 20)
	add_child(_lives)

	_score.position = Vector2(GameState.SCREEN.x - 8, 10)
	add_child(_score)

	_build_weapon_slots()
	_build_boss_bar()
	add_child(_banner)

	GameState.hp_changed.connect(func(hp: int, _max: int) -> void: _health.value = hp)
	GameState.lives_changed.connect(func(lives: int) -> void: _lives.text = "x%d" % lives)
	GameState.score_changed.connect(_on_score_changed)
	GameState.inventory_changed.connect(_update_weapons)
	GameState.boss_bar_visible.connect(func(shown: bool) -> void: _boss_bar.visible = shown)
	GameState.boss_health_changed.connect(_on_boss_health_changed)
	refresh()


func refresh() -> void:
	_health.value = GameState.hp
	_lives.text = "x%d" % GameState.lives
	_on_score_changed(GameState.score)
	_update_weapons()
	_boss_bar.hide()


## Mostra um aviso grande no meio da tela por alguns segundos.
func announce(text: String, duration := 2.5) -> void:
	_banner.text = text
	_banner.modulate.a = 1.0
	if _banner_tween:
		_banner_tween.kill()
	_banner_tween = create_tween()
	_banner_tween.tween_interval(duration)
	_banner_tween.tween_property(_banner, "modulate:a", 0.0, 0.4)


func _on_score_changed(score: int) -> void:
	_score.text = "%07d" % score
	_score.position.x = GameState.SCREEN.x - 8 - _score.text_width()


func _build_weapon_slots() -> void:
	var x := 8.0
	for weapon in WEAPON_ICONS:
		var slot := Panel.new()
		slot.position = Vector2(x, GameState.SCREEN.y - 34)
		slot.size = Vector2(56, 26)
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.03, 0.12, 0.6)
		style.border_color = Color("#ffd23f")
		style.set_corner_radius_all(3)
		slot.add_theme_stylebox_override(&"panel", style)
		var icon := TextureRect.new()
		icon.texture = WEAPON_ICONS[weapon]
		icon.position = Vector2(4, 13 - icon.texture.get_height() / 2.0)
		slot.add_child(icon)
		var amount := UiStyle.label("", 8)
		amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		amount.position = Vector2(22, 9)
		slot.add_child(amount)
		add_child(slot)
		_weapon_slots[weapon] = { "panel": slot, "style": style, "amount": amount }
		x += 62


func _update_weapons() -> void:
	for weapon in _weapon_slots:
		var slot: Dictionary = _weapon_slots[weapon]
		var ammo := GameState.ammo_for(weapon)
		slot.amount.text = "L%d" % GameState.shot_level if ammo < 0 else str(ammo)
		var selected: bool = weapon == GameState.weapon
		slot.style.set_border_width_all(2 if selected else 0)
		slot.panel.modulate.a = 1.0 if selected or ammo != 0 else 0.4


func _build_boss_bar() -> void:
	_boss_bar.position = Vector2(170, 46)
	var background := ColorRect.new()
	background.color = Color("#2a0f2e")
	background.size = Vector2(300, 10)
	_boss_bar.add_child(background)
	_boss_fill.color = Color("#ff3d6e")
	_boss_fill.position = Vector2(2, 2)
	_boss_fill.size = Vector2(296, 6)
	_boss_bar.add_child(_boss_fill)
	var title := UiStyle.label("BOSS", 8, Color("#ffd23f"))
	title.position = Vector2(0, -14)
	title.size = Vector2(300, 10)
	_boss_bar.add_child(title)
	add_child(_boss_bar)


func _on_boss_health_changed(hp: int, max_hp: int) -> void:
	_boss_fill.size.x = 296.0 * hp / maxf(max_hp, 1)
