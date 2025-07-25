# scene_transition.gd
extends CanvasLayer

var params = {}

func change_scene(target: String, transition_type: String, play_backwards: bool, scene_params: Dictionary = {}) -> void:
	params = scene_params
	
	var transition_anim: String
	match transition_type:
		"dissolve":
			transition_anim = "dissolve"
			
	$AnimationPlayer.play(transition_anim)
	await $AnimationPlayer.animation_finished
	
	var next_scene = load(target).instantiate()
	if next_scene.has_method("set_params"):
		next_scene.set_params(params)
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(next_scene)
	get_tree().current_scene = next_scene
	
	if play_backwards:
		$AnimationPlayer.play_backwards(transition_anim)

func exit() -> void:
	$AnimationPlayer.play("dissolve")
	await $AnimationPlayer.animation_finished
	get_tree().quit()
