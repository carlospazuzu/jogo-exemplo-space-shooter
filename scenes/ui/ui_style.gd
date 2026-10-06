class_name UiStyle
## Fonte e estilos compartilhados pelos textos da interface.

const FONT := preload("res://fonts/PressStart2P-Regular.ttf")


static func label(text: String, font_size := 8, color := Color.WHITE) -> Label:
	var node := Label.new()
	node.text = text
	var settings := LabelSettings.new()
	settings.font = FONT
	settings.font_size = font_size
	settings.font_color = color
	settings.outline_size = maxi(2, font_size / 4)
	settings.outline_color = Color("#2a0f2e")
	node.label_settings = settings
	node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return node


## Label centralizado horizontalmente na tela, na altura y.
static func centered_label(text: String, y: float, font_size := 8, color := Color.WHITE) -> Label:
	var node := label(text, font_size, color)
	node.position = Vector2(0, y)
	node.size = Vector2(GameState.SCREEN.x, font_size * 2)
	return node


static func pixel_text(text: String, at: Vector2, scale := 1.0) -> PixelText:
	var node := PixelText.new()
	node.centered = true
	node.glyph_scale = scale
	node.text = text
	node.position = at
	return node
