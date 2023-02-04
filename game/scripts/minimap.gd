extends Sprite
var minimap_viewport


func _ready():
	minimap_viewport = get_node("../minimap/viewport")
	texture = minimap_viewport.get_texture()
	set_texture(texture)
