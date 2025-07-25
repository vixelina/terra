extends TextureButton

@onready var sprite = $Sprite2D
@onready var anim_sprite = $AnimatedSprite2D

func _ready():
	anim_sprite.visible = false
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	sprite.visible = false
	anim_sprite.visible = true
	anim_sprite.play()

func _on_mouse_exited():
	anim_sprite.stop()
	anim_sprite.visible = false
	sprite.visible = true
