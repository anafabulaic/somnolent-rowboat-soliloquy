extends TextureRect
class_name UITransitionEffect

@export var zoom_transition: ShaderMaterial
@export var strip_transition: ShaderMaterial
@export var fade_transition: ShaderMaterial

signal finished_fade_out
signal finished_fade_in
signal fade_done

var faded: bool = false

func _ready() -> void:
	SignalBus.ui_do_transition.connect(do_transition)
	
func do_transition(trans: TransitionEffectResource, duration: float, is_level_change: bool) -> void:	
	await RenderingServer.frame_post_draw
	var viewport_tex: ViewportTexture = get_viewport().get_texture()
	var viewport_image := viewport_tex.get_image()
	
	texture = ImageTexture.create_from_image(viewport_image)

	set_transition(trans, duration, is_level_change)

func set_transition(trans: TransitionEffectResource, duration: float, is_level_change: bool) -> void:
	if !trans or !Game.player:
		return
	
	Game.player.lock(true)
		
	material = trans.transition_material
	
	var fade_out_time: float = trans.fade_out
	var fade_in_time: float = trans.fade_in
	var fade_time: float = trans.fade_time
	
	if duration != 0.0:
		fade_out_time = duration
		fade_in_time = duration
		fade_time = duration
	
	if trans.use_double_sided_fade:
		fade_out(fade_out_time)
		await self.finished_fade_out
		SignalBus.transition_captured_screen.emit()
		SignalBus.transition_begin_done.emit()
		if is_level_change: await SignalBus.on_level_changed
		
		## HACK: unlocks the player for a single frame after we've loaded a level to let it unstuck itself
		## this is kinda gay but it's ok!
		#Game.player.stats.can_move_and_slide = true
		Game.player._collider.disabled = false
		Game.player._physshadow.collider.disabled = false
		Game.player.locked = false
		await get_tree().process_frame
		Game.player.lock(true)
		
		fade_in(fade_in_time)
	else:
		set_fade(0.0)
		SignalBus.transition_captured_screen.emit()
		if is_level_change: await SignalBus.on_level_changed
		
		#Game.player.stats.can_move_and_slide = true
		Game.player._collider.disabled = false
		Game.player._physshadow.collider.disabled = false
		Game.player.locked = false
		await get_tree().process_frame
		Game.player.lock(true)
		
		fade_in(fade_time)
		SignalBus.transition_begin_done.emit()
	
	await self.finished_fade_in
	SignalBus.transition_end_done.emit()
	
	if Game.player:
		Game.player.unlock(true)
		
		## HACK: we wait two physics frames after loading so we don't make a landing sound upon entering the scene
		Game.player.enable_steps()
	
	
	#match type:
		#System.TransitionType.zoom:
			#material = zoom_transition
			#set_fade(0.0)
			#SignalBus.transition_captured_screen.emit()
			#if is_level_change: await SignalBus.on_level_changed
			#fade_in(duration)
			#SignalBus.transition_begin_done.emit()
			#await self.finished_fade_in
			#SignalBus.transition_end_done.emit()
			#
			#if Game.player:
				#Game.player.unlock(true)
			#
		#System.TransitionType.strip:
			#material = strip_transition
			#set_fade(0.0)
			#SignalBus.transition_captured_screen.emit()
			#if is_level_change: await SignalBus.on_level_changed
			#fade_in(duration)
			#SignalBus.transition_begin_done.emit()
			#await self.finished_fade_in
			#SignalBus.transition_end_done.emit()
			#
			#if Game.player:
				#Game.player.unlock(true)
			#
		#System.TransitionType.fade:
			#material = fade_transition
			#fade_out(duration)
			#await self.finished_fade_out
			#SignalBus.transition_captured_screen.emit()
			#SignalBus.transition_begin_done.emit()
			#if is_level_change: await SignalBus.on_level_changed
			#fade_in(duration)
			#await self.finished_fade_in
			#SignalBus.transition_end_done.emit()
			#
			#if Game.player:
				#Game.player.unlock(true)

func set_fade(fade: float) -> void:
	var shader_mat: ShaderMaterial = material
	shader_mat.set_shader_parameter("progress", fade)

func fade_out(seconds: float) -> void:
	var tween: Tween = self.create_tween()
	tween.tween_method(set_fade, 1.0, 0.0, seconds)
	tween.tween_callback(finished_fade_out.emit)
	
func fade_in(seconds: float) -> void:
	var tween: Tween = self.create_tween()
	tween.tween_method(set_fade, 0.0, 1.0, seconds)
	tween.tween_callback(finished_fade_in.emit)
