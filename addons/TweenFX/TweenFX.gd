@icon("res://addons/TweenFX/icon.png")
## TweenFX — A juicy tween animation library for Godot 4.
## [br][br]
## Provides one-shot and looping animations for CanvasItem nodes.
## Call any animation directly, stop it explicitly, or await its completion.
## [br][br]
## All animations are tracked automatically. Use [method stop] and [method stop_all]
## to interrupt running animations, and [method is_playing] to check their state.
## [br][br]
## [b]Basic usage:[/b]
## [codeblock]
## TweenFX.shake(node)
## TweenFX.shake(node, 0.5, 20.0, 8)
## await TweenFX.shake(node).finished
## [/codeblock]
extends Node
const TweenManager = preload("res://addons/TweenFX/TweenManager.gd")

#region ENUM
## Some animations support [b]PlayState[/b] for interactive use.
## [b]ENTER[/b] and [b]EXIT[/b] are designed as pairs.[br]
## [i]Pass the target property explicitly so TweenFX always knows where to go regardless of the node's current state.
enum PlayState {
	FULL,       # play complete animation
	ENTER,      # animate to target state and hold
	EXIT        # animate back to original
}

enum Animations {
	POP_IN,
	POP_OUT,
	PUNCH_IN,
	PUNCH_OUT,
	FADE_IN,
	FADE_OUT,
	DROP_IN,
	DROP_OUT,
	JUMP_SCARE,
	SPIN,
	SKEW,
	VANISH,
	SHAKE,
	PULSATE,
	JITTER,
	JELLY,
	FLIP,
	HOP,
	BLINK,
	SQUASH,
	STRETCH,
	SNAP,
	COLOR_CYCLE,
	HEARTBEAT,
	SWING,
	CHARGE_UP,
	RICOCHET,
	GLITCH,
	SPOTLIGHT,
	WAVE_DISTORT,
	WIGGLE,
	FLOAT_BOB,
	GLOW_PULSE,
	TWIST,
	ROTATE_HOP,
	EXPLODE,
	BLACK_HOLE,
	MELT,
	TV_SHUTDOWN,
	MAD_HELICO,
	SPIN_BOUNCE,
	IDLE_RUBBER,
	BUBBLE_ASCEND,
	CREEP_OUT,
	RUBBER_BAND,
	FIDGET,
	DEFLATE,
	DRUNK,
	IMPACT_LAND,
	BREATHE,
	SWAY,
	FLICKER,
	CRITICAL_HIT,
	UPGRADE,
	FOLD_IN,
	FOLD_OUT,
	ALARM,
	POINT,
	TADA,
	GHOST,
	ATTRACT,
	ORBIT,
}

enum AnimationType {
	ONE_SHOT,
	LOOPING
}

enum NodeRequirement {
	CANVAS_ITEM,
	NODE_2D
}

#endregion

#region DICT
const ANIMATION_TYPES: Dictionary = {
	Animations.POP_IN:            AnimationType.ONE_SHOT,
	Animations.POP_OUT:           AnimationType.ONE_SHOT,
	Animations.PUNCH_IN:          AnimationType.ONE_SHOT,
	Animations.PUNCH_OUT:         AnimationType.ONE_SHOT,
	Animations.FADE_IN:           AnimationType.ONE_SHOT,
	Animations.FADE_OUT:          AnimationType.ONE_SHOT,
	Animations.DROP_IN:           AnimationType.ONE_SHOT,
	Animations.DROP_OUT:          AnimationType.ONE_SHOT,
	Animations.JUMP_SCARE:        AnimationType.ONE_SHOT,
	Animations.SPIN:              AnimationType.ONE_SHOT,
	Animations.SKEW:              AnimationType.ONE_SHOT,
	Animations.VANISH:            AnimationType.ONE_SHOT,
	Animations.SHAKE:             AnimationType.ONE_SHOT,
	Animations.PULSATE:           AnimationType.ONE_SHOT,
	Animations.JITTER:            AnimationType.ONE_SHOT,
	Animations.JELLY:             AnimationType.ONE_SHOT,
	Animations.FLIP:              AnimationType.ONE_SHOT,
	Animations.HOP:               AnimationType.ONE_SHOT,
	Animations.BLINK:             AnimationType.ONE_SHOT,
	Animations.SQUASH:            AnimationType.ONE_SHOT,
	Animations.STRETCH:           AnimationType.ONE_SHOT,
	Animations.SNAP:              AnimationType.ONE_SHOT,
	Animations.CHARGE_UP:         AnimationType.ONE_SHOT,
	Animations.RICOCHET:          AnimationType.ONE_SHOT,
	Animations.GLITCH:            AnimationType.ONE_SHOT,
	Animations.SPOTLIGHT:         AnimationType.ONE_SHOT,
	Animations.TWIST:             AnimationType.ONE_SHOT,
	Animations.EXPLODE:           AnimationType.ONE_SHOT,
	Animations.BLACK_HOLE:        AnimationType.ONE_SHOT,
	Animations.TV_SHUTDOWN:       AnimationType.ONE_SHOT,
	Animations.CREEP_OUT:         AnimationType.ONE_SHOT,
	Animations.RUBBER_BAND:       AnimationType.ONE_SHOT,
	Animations.FIDGET:            AnimationType.ONE_SHOT,
	Animations.DEFLATE:           AnimationType.ONE_SHOT,
	Animations.DRUNK:             AnimationType.ONE_SHOT,
	Animations.IMPACT_LAND:       AnimationType.ONE_SHOT,
	Animations.CRITICAL_HIT:      AnimationType.ONE_SHOT,
	Animations.UPGRADE:           AnimationType.ONE_SHOT,
	Animations.FOLD_IN:           AnimationType.ONE_SHOT,
	Animations.FOLD_OUT:          AnimationType.ONE_SHOT,
	Animations.POINT:             AnimationType.ONE_SHOT,
	Animations.TADA:              AnimationType.ONE_SHOT,

	Animations.COLOR_CYCLE:       AnimationType.LOOPING,
	Animations.HEARTBEAT:         AnimationType.LOOPING,
	Animations.SWING:             AnimationType.LOOPING,
	Animations.WAVE_DISTORT:      AnimationType.LOOPING,
	Animations.WIGGLE:            AnimationType.LOOPING,
	Animations.FLOAT_BOB:         AnimationType.LOOPING,
	Animations.GLOW_PULSE:        AnimationType.LOOPING,
	Animations.ROTATE_HOP:        AnimationType.LOOPING,
	Animations.SPIN_BOUNCE:       AnimationType.LOOPING,
	Animations.MAD_HELICO:        AnimationType.LOOPING,
	Animations.MELT:              AnimationType.LOOPING,
	Animations.IDLE_RUBBER:       AnimationType.LOOPING,
	Animations.BUBBLE_ASCEND:     AnimationType.LOOPING,
	Animations.BREATHE:           AnimationType.LOOPING,
	Animations.SWAY:              AnimationType.LOOPING,
	Animations.FLICKER:           AnimationType.LOOPING,
	Animations.ALARM:             AnimationType.LOOPING,
	Animations.GHOST:             AnimationType.LOOPING,
	Animations.ATTRACT:           AnimationType.LOOPING,
	Animations.ORBIT:             AnimationType.LOOPING,
}

const ANIMATION_REQUIREMENTS: Dictionary = {
	Animations.WAVE_DISTORT: NodeRequirement.NODE_2D,
	Animations.SKEW:         NodeRequirement.NODE_2D,
}
#endregion

#region LOGIC
## Stops a specific animation running on the node.
func stop(node: CanvasItem, anim: Animations) -> void:
	TweenManager.stop(node, anim)

## Stops all animations currently running on the node.
func stop_all(node: CanvasItem) -> void:
	TweenManager.stop_all(node)

## Returns true if the given animation is currently playing on the node.
func is_playing(node: CanvasItem, anim: Animations) -> bool:
	return TweenManager.is_playing(node, anim)

## Returns true if the animation loops indefinitely until stopped.
func is_looping_type(anim: Animations) -> bool:
	return ANIMATION_TYPES.get(anim, AnimationType.ONE_SHOT) == AnimationType.LOOPING

## Returns true if the animation requires a Node2D target instead of CanvasItem.
func requires_node2d(anim: Animations) -> bool:
	return ANIMATION_REQUIREMENTS.get(anim, NodeRequirement.CANVAS_ITEM) == NodeRequirement.NODE_2D
	
#endregion

#region TWEEN ANIMATIONS

	#region Looping

## Goes through the colors.
func color_cycle(node: CanvasItem, duration: float = 3.0) -> Tween:
	TweenManager.stop(node, Animations.COLOR_CYCLE)
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	var colors = [
		Color.from_hsv(0.0, 1.0, 1.0),
		Color.from_hsv(0.17, 1.0, 1.0),
		Color.from_hsv(0.33, 1.0, 1.0),
		Color.from_hsv(0.5, 1.0, 1.0),
		Color.from_hsv(0.67, 1.0, 1.0),
		Color.from_hsv(0.83, 1.0, 1.0),
		Color.from_hsv(1.0, 1.0, 1.0)
	]
	for color in colors:
		tween.tween_property(node, "modulate", color, duration / colors.size())
	TweenManager.track(node, Animations.COLOR_CYCLE, tween)
	return tween

## Simulates a heartbeat with two rhythmic pulses.
func heartbeat(node: CanvasItem, duration: float = 1.0, strength: float = 0.2) -> Tween:
	TweenManager.stop(node, Animations.HEARTBEAT)
	var original_scale = node.scale
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(node, "scale", original_scale * (1 + strength), 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", original_scale, 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", original_scale, 0.1)
	tween.tween_property(node, "scale", original_scale * (1 + strength * 0.6), 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", original_scale, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", original_scale, duration - 0.6)
	TweenManager.track(node, Animations.HEARTBEAT, tween)
	return tween

## Rotates the node back and forth like a pendulum.
func swing(node: CanvasItem, duration: float = 1.0, angle: float = 30.0) -> Tween:
	TweenManager.stop(node, Animations.SWING)
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "rotation_degrees", angle, duration * 0.5)
	tween.tween_property(node, "rotation_degrees", -angle, duration)
	tween.tween_property(node, "rotation_degrees", 0, duration * 0.5)
	TweenManager.track(node, Animations.SWING, tween)
	return tween

## Applies a wave-like distortion effect to the node.
func wave_distort(node: Node2D, duration: float = 1.0, amplitude: float = 0.1) -> Tween:
	TweenManager.stop(node, Animations.WAVE_DISTORT)
	var original_scale = node.scale
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "scale:x", original_scale.x * (1 + amplitude), duration * 0.25)
	tween.parallel().tween_property(node, "scale:y", original_scale.y * (1 - amplitude/2), duration * 0.25)
	tween.parallel().tween_property(node, "skew", amplitude/2, duration * 0.25)
	tween.tween_property(node, "scale:x", original_scale.x * (1 - amplitude/2), duration * 0.25)
	tween.parallel().tween_property(node, "scale:y", original_scale.y * (1 + amplitude), duration * 0.25)
	tween.parallel().tween_property(node, "skew", -amplitude/2, duration * 0.25)
	tween.tween_property(node, "scale:x", original_scale.x * (1 - amplitude), duration * 0.25)
	tween.parallel().tween_property(node, "scale:y", original_scale.y * (1 - amplitude/2), duration * 0.25)
	tween.parallel().tween_property(node, "skew", amplitude/2, duration * 0.25)
	tween.tween_property(node, "scale:x", original_scale.x, duration * 0.25)
	tween.parallel().tween_property(node, "scale:y", original_scale.y, duration * 0.25)
	tween.parallel().tween_property(node, "skew", 0.0, duration * 0.25)
	TweenManager.track(node, Animations.WAVE_DISTORT, tween)
	return tween

## Slightly rotates the node back and forth.
func wiggle(node: CanvasItem, duration: float = 1.2) -> Tween:
	TweenManager.stop(node, Animations.WIGGLE)
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(node, "rotation_degrees", 5.0, duration * 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", -5.0, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", 0.0, duration * 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	TweenManager.track(node, Animations.WIGGLE, tween)
	return tween

## Makes the node float up and down in a looping motion.
func float_bob(node: CanvasItem, duration: float = 2.0, height: float = 5.0) -> Tween:
	TweenManager.stop(node, Animations.FLOAT_BOB)
	var original_pos: Vector2 = node.position
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(node, "position:y", original_pos.y - height, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "position:y", original_pos.y + height, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	TweenManager.track(node, Animations.FLOAT_BOB, tween)
	return tween

## Gently pulses the node's scale and opacity in a loop.
func glow_pulse(node: CanvasItem, duration: float = 1.2, scale_amt: float = 0.05, alpha_amt: float = 0.3) -> Tween:
	TweenManager.stop(node, Animations.GLOW_PULSE)
	var original_scale: Vector2 = node.scale
	var original_alpha: float = node.modulate.a
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(node, "scale", original_scale * (1.0 + scale_amt), duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(node, "modulate:a", original_alpha * (1.0 - alpha_amt), duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", original_scale, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(node, "modulate:a", original_alpha, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	TweenManager.track(node, Animations.GLOW_PULSE, tween)
	return tween

## Rotates a bit while doing a mini-hop. Good for idle feedback.
func rotate_hop(node: CanvasItem, duration: float = 0.4, angle: float = 15.0, height: float = 10.0) -> Tween:
	TweenManager.stop(node, Animations.ROTATE_HOP)
	var start_pos = node.position
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(node, "rotation_degrees", angle, duration * 0.25)
	tween.parallel().tween_property(node, "position:y", start_pos.y - height, duration * 0.25)
	tween.tween_property(node, "rotation_degrees", -angle, duration * 0.25)
	tween.parallel().tween_property(node, "position:y", start_pos.y + height, duration * 0.25)
	tween.tween_property(node, "rotation_degrees", 0, duration * 0.25)
	tween.parallel().tween_property(node, "position:y", start_pos.y, duration * 0.25)
	TweenManager.track(node, Animations.ROTATE_HOP, tween)
	return tween

## Pure entropy: spin, random jitter, squash-stretch bounce.
func spin_bounce(node: CanvasItem, duration: float = 0.6, bounce_scale: float = 0.2, spin_speed: float = 180.0) -> Tween:
	TweenManager.stop(node, Animations.SPIN_BOUNCE)
	var original_scale = node.scale
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	tween.parallel().tween_property(node, "rotation_degrees", node.rotation_degrees + spin_speed, duration).set_trans(Tween.TRANS_LINEAR)
	tween.parallel().tween_property(node, "scale", original_scale * Vector2(1.0 + randf_range(-bounce_scale, bounce_scale), 1.0 + randf_range(-bounce_scale, bounce_scale)), duration * 0.5)
	tween.tween_property(node, "scale", original_scale, duration * 0.5)
	TweenManager.track(node, Animations.SPIN_BOUNCE, tween)
	return tween

## Makes the object look like it's trying to fly off in a panic.
func mad_helico(node: CanvasItem, duration: float = 0.6, spin_speed: float = 1080.0, bob_height: float = 5.0) -> Tween:
	TweenManager.stop(node, Animations.MAD_HELICO)
	var original_pos = node.position
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	tween.parallel().tween_property(node, "rotation_degrees", node.rotation_degrees + spin_speed, duration).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(node, "position:y", original_pos.y - bob_height, duration * 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "position:y", original_pos.y + bob_height, duration * 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "position:y", original_pos.y, duration * 0.3).set_trans(Tween.TRANS_SINE)
	TweenManager.track(node, Animations.MAD_HELICO, tween)
	return tween

## Makes objects drip down slowly and squash — like they're melting.
func melt(node: CanvasItem, duration: float = 2.0, melt_distance: float = 20.0) -> Tween:
	TweenManager.stop(node, Animations.MELT)
	var original_pos = node.position
	var original_scale = node.scale
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	tween.parallel().tween_property(node, "position:y", original_pos.y + melt_distance, duration * 0.5).set_trans(Tween.TRANS_LINEAR)
	tween.parallel().tween_property(node, "scale:y", original_scale.y * 1.3, duration * 0.5)
	tween.tween_property(node, "position:y", original_pos.y, duration * 0.5)
	tween.tween_property(node, "scale:y", original_scale.y, duration * 0.5)
	TweenManager.track(node, Animations.MELT, tween)
	return tween

## Gives the object rubbery springy movement.
func idle_rubber(node: CanvasItem, duration: float = 0.6, strength: float = 0.1) -> Tween:
	TweenManager.stop(node, Animations.IDLE_RUBBER)
	var original_pos = node.position
	var original_scale = node.scale
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(node, "position:x", original_pos.x + 6, duration * 0.3)
	tween.parallel().tween_property(node, "scale", original_scale * Vector2(1.1, 0.9), duration * 0.3)
	tween.tween_property(node, "position:x", original_pos.x - 6, duration * 0.3)
	tween.parallel().tween_property(node, "scale", original_scale * Vector2(0.9, 1.1), duration * 0.3)
	tween.tween_property(node, "position:x", original_pos.x, duration * 0.3)
	tween.parallel().tween_property(node, "scale", original_scale, duration * 0.3)
	TweenManager.track(node, Animations.IDLE_RUBBER, tween)
	return tween

## Floats upward with a bit of distortion.
func bubble_ascend(node: CanvasItem, duration: float = 2.0, height: float = 15.0) -> Tween:
	TweenManager.stop(node, Animations.BUBBLE_ASCEND)
	var original_pos = node.position
	var original_scale = node.scale
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(node, "position:y", original_pos.y - height, duration * 0.6).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(node, "scale:y", original_scale.y * 0.95, duration * 0.3)
	tween.tween_property(node, "position:y", original_pos.y, duration * 0.4).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(node, "scale", original_scale, duration * 0.2)
	TweenManager.track(node, Animations.BUBBLE_ASCEND, tween)
	return tween

## Very subtle slow scale pulse. Good for alive/idle state.
func breathe(node: CanvasItem, duration: float = 3.0, strength: float = 0.03) -> Tween:
	TweenManager.stop(node, Animations.BREATHE)
	var original_scale = node.scale
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(node, "scale", original_scale * (1.0 + strength), duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", original_scale, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	TweenManager.track(node, Animations.BREATHE, tween)
	return tween
	#endregion

	#region One-Shot

## Object fades into the dark and shrinks away.
func creep_out(node: CanvasItem, duration: float = 1.0) -> Tween:
	TweenManager.stop(node, Animations.CREEP_OUT)
	var original_scale = node.scale
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "modulate", Color(0.2, 0.2, 0.2, 1), duration * 0.5)
	tween.tween_property(node, "scale", original_scale * 0.8, duration * 0.5)
	tween.tween_property(node, "modulate:a", 0.0, duration * 0.3)
	TweenManager.track(node, Animations.CREEP_OUT, tween)
	return tween

## Makes the object look like it's being shut down like a cartoon TV.
func tv_shutdown(node: CanvasItem, duration: float = 0.5) -> Tween:
	TweenManager.stop(node, Animations.TV_SHUTDOWN)
	var original_scale = node.scale
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "scale", original_scale * Vector2(1.3, 0.7), duration * 0.25).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(node, "scale", original_scale * Vector2(0.7, 1.3), duration * 0.25).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(node, "scale", Vector2.ZERO, duration * 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	TweenManager.track(node, Animations.TV_SHUTDOWN, tween)
	return tween

## Spins and collapses into nothingness.
func black_hole(node: CanvasItem, duration: float = 0.8) -> Tween:
	TweenManager.stop(node, Animations.BLACK_HOLE)
	var tween = node.get_tree().create_tween()
	tween.parallel().tween_property(node, "scale", Vector2.ZERO, duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(node, "modulate:a", 0.0, duration)
	tween.parallel().tween_property(node, "rotation_degrees", node.rotation_degrees + 720, duration)
	TweenManager.track(node, Animations.BLACK_HOLE, tween)
	return tween

## Boom!
func explode(node: CanvasItem, duration: float = 0.4, scale_amt: float = 1.8) -> Tween:
	TweenManager.stop(node, Animations.EXPLODE)
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "scale", Vector2.ONE * scale_amt, duration * 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "rotation_degrees", randf_range(-10, 10), duration * 0.2)
	tween.tween_property(node, "scale", Vector2.ONE * 0.5, duration * 0.4).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(node, "modulate:a", 0.0, duration * 0.4).set_trans(Tween.TRANS_LINEAR)
	TweenManager.track(node, Animations.EXPLODE, tween)
	return tween

## Builds up energy visually before a release.
func charge_up(node: CanvasItem, duration: float = 1.0) -> Tween:
	TweenManager.stop(node, Animations.CHARGE_UP)
	var original_scale = node.scale
	var original_color = node.modulate
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "scale", original_scale * 0.8, duration * 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(node, "modulate", Color(1.5, 1.5, 0.5, 1.0), duration * 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	for i in range(3):
		var pulse_scale = 0.05 * (i + 1)
		tween.tween_property(node, "scale", original_scale * (0.8 + pulse_scale), duration * 0.1)
		tween.tween_property(node, "scale", original_scale * 0.8, duration * 0.1)
	tween.tween_property(node, "scale", original_scale * 1.5, duration * 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "modulate", Color(2.0, 2.0, 1.0, 1.0), duration * 0.2)
	tween.tween_property(node, "scale", original_scale, duration * 0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "modulate", original_color, duration * 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	TweenManager.track(node, Animations.CHARGE_UP, tween)
	return tween

## Shrinks and wobbles like it took a hit.
func punch_out(node: CanvasItem, duration: float = 0.5, min_scale: float = 0.5) -> Tween:
	TweenManager.stop(node, Animations.PUNCH_OUT)
	var original_scale = node.scale
	var original_pos = node.position
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "scale", original_scale * min_scale, duration * 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	for i in range(3):
		var jitter = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * 5.0
		tween.tween_property(node, "position", original_pos + jitter, duration * 0.1)
	tween.tween_property(node, "scale", original_scale, duration * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "position", original_pos, duration * 0.1)
	TweenManager.track(node, Animations.PUNCH_OUT, tween)
	return tween

## Bounces around as if hitting walls.
func ricochet(node: CanvasItem, duration: float = 0.8, strength: float = 30.0, bounces: int = 4) -> Tween:
	TweenManager.stop(node, Animations.RICOCHET)
	var original_pos = node.position
	var tween = node.get_tree().create_tween()
	for i in range(bounces):
		var random_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		var target_pos = original_pos + random_dir * strength
		tween.tween_property(node, "position", target_pos, (duration / bounces) * 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position", original_pos, duration * 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	TweenManager.track(node, Animations.RICOCHET, tween)
	return tween

## Simulates a digital glitch with color and position jitter.
func glitch(node: CanvasItem, duration: float = 1.0, intensity: float = 10.0) -> Tween:
	TweenManager.stop(node, Animations.GLITCH)
	var original_pos = node.position
	var original_color = node.modulate
	var tween = node.get_tree().create_tween()
	var glitch_frames = 12
	for i in range(glitch_frames):
		var offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * intensity
		var color_shift = Color(randf_range(0.8, 1.2), randf_range(0.8, 1.2), randf_range(0.8, 1.2), 1.0)
		var glitch_time = duration / glitch_frames * 0.5
		tween.tween_property(node, "position", original_pos + offset, glitch_time)
		tween.parallel().tween_property(node, "modulate", color_shift, glitch_time)
		tween.tween_property(node, "position", original_pos, glitch_time)
		tween.parallel().tween_property(node, "modulate", original_color, glitch_time)
	tween.tween_property(node, "position", original_pos, 0.1)
	tween.parallel().tween_property(node, "modulate", original_color, 0.1)
	TweenManager.track(node, Animations.GLITCH, tween)
	return tween

## A fast zoom and shake for a startling impact.
func jump_scare(node: CanvasItem, duration: float = 0.4, intensity: float = 1.3) -> Tween:
	TweenManager.stop(node, Animations.JUMP_SCARE)
	var original_scale = node.scale
	var original_pos = node.position
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "scale", original_scale * intensity, duration * 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	for i in range(6):
		var shake_offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * 10.0
		tween.parallel().tween_property(node, "position", original_pos + shake_offset, duration * 0.05)
		tween.tween_property(node, "position", original_pos, duration * 0.05)
	tween.parallel().tween_property(node, "scale", original_scale, duration * 0.7).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	TweenManager.track(node, Animations.JUMP_SCARE, tween)
	return tween

## Highlights the node with a glowing effect. Supports PlayState for hold/release.
func spotlight(node: CanvasItem, duration: float = 1.0, glow: Color = Color(1.5, 1.5, 1.5, 1.0), state: PlayState = PlayState.FULL) -> Tween:
	TweenManager.stop(node, Animations.SPOTLIGHT)
	var original_color = node.modulate
	var tween = node.get_tree().create_tween()
	match state:
		PlayState.ENTER:
			tween.tween_property(node, "modulate", glow, duration * 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		PlayState.EXIT:
			tween.tween_property(node, "modulate", glow, duration * 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		PlayState.FULL:
			tween.tween_property(node, "modulate", glow, duration * 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			tween.tween_property(node, "modulate", glow, duration * 0.4)
			tween.tween_property(node, "modulate", original_color, duration * 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	TweenManager.track(node, Animations.SPOTLIGHT, tween)
	return tween

## Flips the node along the given axis.
func flip(node: CanvasItem, duration: float = 0.4, axis: String = "x", flips: int = 1) -> Tween:
	TweenManager.stop(node, Animations.FLIP)
	var original_scale: Vector2 = node.scale
	var tween = node.get_tree().create_tween()
	for i in range(flips):
		tween.tween_property(node, "scale:" + axis, -original_scale[axis], duration * 0.5 / flips).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(node, "scale:" + axis, original_scale[axis], duration * 0.5 / flips).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	TweenManager.track(node, Animations.FLIP, tween)
	return tween

## Makes the node hop upward and land back down.
func hop(node: CanvasItem, duration: float = 0.4, height: float = 20.0) -> Tween:
	TweenManager.stop(node, Animations.HOP)
	var original_pos: Vector2 = node.position
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "position:y", original_pos.y - height, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position:y", original_pos.y, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	TweenManager.track(node, Animations.HOP, tween)
	return tween

## Rapidly blinks the node's opacity.
func blink(node: CanvasItem, duration: float = 0.1, times: int = 3, from: float = 0.0, to: float = 1.0) -> Tween:
	TweenManager.stop(node, Animations.BLINK)
	var tween = node.get_tree().create_tween()
	for i in range(times):
		tween.tween_property(node, "modulate:a", from, duration)
		tween.tween_property(node, "modulate:a", to, duration)
	TweenManager.track(node, Animations.BLINK, tween)
	return tween

## Squashes the node along one axis and stretches the other, then returns.
func squash(node: CanvasItem, duration: float = 0.2, amount: float = 0.3, horizontal: bool = true) -> Tween:
	TweenManager.stop(node, Animations.SQUASH)
	var original_scale: Vector2 = node.scale
	var target = Vector2(original_scale.x * (1 + amount), original_scale.y * (1 - amount)) if horizontal else Vector2(original_scale.x * (1 - amount), original_scale.y * (1 + amount))
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "scale", target, duration * 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "scale", original_scale, duration * 0.5).set_trans(Tween.TRANS_SINE)
	TweenManager.track(node, Animations.SQUASH, tween)
	return tween

## Stretches the node vertically, then returns to original scale.
func stretch(node: CanvasItem, duration: float = 0.2, amount: float = 0.3) -> Tween:
	TweenManager.stop(node, Animations.STRETCH)
	var original_scale: Vector2 = node.scale
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "scale", Vector2(original_scale.x * (1 - amount), original_scale.y * (1 + amount)), duration * 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "scale", original_scale, duration * 0.5).set_trans(Tween.TRANS_SINE)
	TweenManager.track(node, Animations.STRETCH, tween)
	return tween

## Scales the node up quickly, then resets. Supports PlayState for hold/release.
func snap(node: CanvasItem, duration: float = 0.1, scale: Vector2 = Vector2(1.3, 1.3), state: PlayState = PlayState.FULL) -> Tween:
	TweenManager.stop(node, Animations.SNAP)
	var original_scale: Vector2 = node.scale
	var tween = node.get_tree().create_tween()
	match state:
		PlayState.ENTER:
			tween.tween_property(node, "scale", scale, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		PlayState.EXIT:
			tween.tween_property(node, "scale", scale, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		PlayState.FULL:
			tween.tween_property(node, "scale", scale, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.tween_property(node, "scale", original_scale, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	TweenManager.track(node, Animations.SNAP, tween)
	return tween

## Quickly flashes the node's opacity.
func flash(node: CanvasItem, duration: float = 0.1, flashes: int = 3) -> Tween:
	TweenManager.stop(node, Animations.BLINK)
	var tween = node.get_tree().create_tween()
	for i in range(flashes):
		tween.tween_property(node, "modulate", Color(1, 1, 1, 0), duration)
		tween.tween_property(node, "modulate", Color(1, 1, 1, 1), duration)
	TweenManager.track(node, Animations.BLINK, tween)
	return tween

## Fades the node in from transparent.
func fade_in(node: CanvasItem, duration: float = 0.5) -> Tween:
	TweenManager.stop(node, Animations.FADE_IN)
	node.modulate.a = 0.0
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "modulate:a", 1.0, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	TweenManager.track(node, Animations.FADE_IN, tween)
	return tween

## Fades the node out to transparent.
func fade_out(node: CanvasItem, duration: float = 0.5) -> Tween:
	TweenManager.stop(node, Animations.FADE_OUT)
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	TweenManager.track(node, Animations.FADE_OUT, tween)
	return tween

## Twists the node in place with a quick rotation.
func twist(node: CanvasItem, duration: float = 0.4, angle: float = 30.0) -> Tween:
	TweenManager.stop(node, Animations.TWIST)
	var start = node.rotation_degrees
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "rotation_degrees", start + angle, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "rotation_degrees", start, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	TweenManager.track(node, Animations.TWIST, tween)
	return tween

## Expands and contracts the node once.
func pulsate(node: CanvasItem, duration: float = 0.5, scale_factor: float = 1.2) -> Tween:
	TweenManager.stop(node, Animations.PULSATE)
	var original_scale = node.scale
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "scale", original_scale * scale_factor, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", original_scale, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	TweenManager.track(node, Animations.PULSATE, tween)
	return tween

## Rapid nervous jitter with rotation and scale micro-variations.
func jitter(node: CanvasItem, duration: float = 0.5, amount: float = 5.0, times: int = 8) -> Tween:
	TweenManager.stop(node, Animations.JITTER)
	var original_position = node.position
	var original_rotation = node.rotation_degrees
	var original_scale = node.scale
	var tween = node.get_tree().create_tween()
	for i in range(times):
		var offset = Vector2(randf_range(-amount, amount), randf_range(-amount, amount))
		var rot = randf_range(-3.0, 3.0)
		var scl = original_scale * Vector2(randf_range(0.95, 1.05), randf_range(0.95, 1.05))
		tween.tween_property(node, "position", original_position + offset, duration / times)
		tween.parallel().tween_property(node, "rotation_degrees", original_rotation + rot, duration / times)
		tween.parallel().tween_property(node, "scale", scl, duration / times)
	tween.tween_property(node, "position", original_position, 0.05)
	tween.parallel().tween_property(node, "rotation_degrees", original_rotation, 0.05)
	tween.parallel().tween_property(node, "scale", original_scale, 0.05)
	TweenManager.track(node, Animations.JITTER, tween)
	return tween

## Alternates between squash and stretch repeatedly, like jelly wobbling.
func jelly(node: CanvasItem, duration: float = 0.6, amount: float = 0.3, cycles: int = 2) -> Tween:
	TweenManager.stop(node, Animations.JELLY)
	var original_scale = node.scale
	var tween = node.get_tree().create_tween()
	for i in range(cycles):
		tween.tween_property(node, "scale", original_scale * Vector2(1.0 + amount, 1.0 - amount), duration * 0.25 / cycles).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(node, "scale", original_scale * Vector2(1.0 - amount, 1.0 + amount), duration * 0.25 / cycles).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", original_scale, duration * 0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	TweenManager.track(node, Animations.JELLY, tween)
	return tween

## Rotates the node one or more full revolutions.
func spin(node: CanvasItem, duration: float = 0.5, revolutions: float = 1.0) -> Tween:
	TweenManager.stop(node, Animations.SPIN)
	var original_rotation = node.rotation_degrees
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "rotation_degrees", original_rotation + 360.0 * revolutions, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", original_rotation, 0.0)
	TweenManager.track(node, Animations.SPIN, tween)
	return tween

## Scales in from zero with a slight overshoot.
func pop_in(node: CanvasItem, duration: float = 0.3, overshoot: float = 0.1) -> Tween:
	TweenManager.stop(node, Animations.POP_IN)
	var original_scale: Vector2 = node.scale
	var original_alpha := node.modulate.a
	node.scale = Vector2.ZERO
	node.modulate.a = 0.0
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "scale", original_scale * (1.0 + overshoot), duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", original_scale, duration * 0.33)
	tween.parallel().tween_property(node, "modulate:a", original_alpha, duration * 0.66)
	TweenManager.track(node, Animations.POP_IN, tween)
	return tween

## Scales out to zero with a slight pull in before vanishing.
func pop_out(node: CanvasItem, duration: float = 0.3, overshoot: float = 0.1) -> Tween:
	TweenManager.stop(node, Animations.POP_OUT)
	var original_scale: Vector2 = node.scale
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "scale", original_scale * (1.0 + overshoot), duration * 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2.ZERO, duration * 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(node, "modulate:a", 0.0, duration * 0.8)
	TweenManager.track(node, Animations.POP_OUT, tween)
	return tween

## Skews the node along X and Y axes temporarily.
func skew(node: Node2D, duration: float = 0.3, skew_x: float = 0.5, skew_y: float = 0.5) -> Tween:
	TweenManager.stop(node, Animations.SKEW)
	var original_scale: Vector2 = node.scale
	var target_scale := original_scale * Vector2(1.0 + skew_x, 1.0 + skew_y)
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "scale", target_scale, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", original_scale, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT).set_delay(duration)
	TweenManager.track(node, Animations.SKEW, tween)
	return tween

## Fades out and scales down the node.
func vanish(node: CanvasItem, duration: float = 0.4) -> Tween:
	TweenManager.stop(node, Animations.VANISH)
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration)
	tween.parallel().tween_property(node, "scale", Vector2(0.0, 0.0), duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	TweenManager.track(node, Animations.VANISH, tween)
	return tween

## Quickly scales the node in with a slight bounce.
func punch_in(node: CanvasItem, duration: float = 0.15, strength: float = 0.3) -> Tween:
	TweenManager.stop(node, Animations.PUNCH_IN)
	var original_scale = node.scale
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "scale", original_scale * (1 + strength), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", original_scale, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	TweenManager.track(node, Animations.PUNCH_IN, tween)
	return tween

## Moves the node back and forth rapidly.
func shake(node: CanvasItem, duration: float = 0.3, amount: float = 10.0, shakes: int = 5) -> Tween:
	TweenManager.stop(node, Animations.SHAKE)
	var original_pos = node.position
	var tween = node.get_tree().create_tween()
	for i in range(shakes):
		var offset = Vector2(randf_range(-amount, amount), randf_range(-amount, amount))
		tween.tween_property(node, "position", original_pos + offset, duration / (shakes * 2))
		tween.tween_property(node, "position", original_pos, duration / (shakes * 2))
	TweenManager.track(node, Animations.SHAKE, tween)
	return tween

## Drops the node from above into its position.
func drop_in(node: CanvasItem, duration: float = 0.5, drop_height: float = 100.0, scale_distort: Vector2 = Vector2(1.2, 0.8)) -> Tween:
	TweenManager.stop(node, Animations.DROP_IN)
	var original_pos = node.position
	var original_scale = node.scale
	var original_alpha = node.modulate.a
	node.position = original_pos - Vector2(0, drop_height)
	node.scale = scale_distort
	node.modulate.a = 0.0
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "position", original_pos, duration).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "scale", original_scale, duration * 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "modulate:a", original_alpha, duration * 0.4)
	TweenManager.track(node, Animations.DROP_IN, tween)
	return tween

## Drops the node downward and fades out.
func drop_out(node: CanvasItem, duration: float = 0.5, drop_height: float = 100.0) -> Tween:
	TweenManager.stop(node, Animations.DROP_OUT)
	var original_pos = node.position
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "position", original_pos + Vector2(0, drop_height), duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(node, "modulate:a", 0.0, duration * 0.6)
	TweenManager.track(node, Animations.DROP_OUT, tween)
	return tween

## Stretches in one direction then snaps back with overshoot.
func rubber_band(node: CanvasItem, duration: float = 0.5, strength: float = 0.4) -> Tween:
	TweenManager.stop(node, Animations.RUBBER_BAND)
	var original_scale = node.scale
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "scale", original_scale * Vector2(1.0 + strength, 1.0 - strength * 0.5), duration * 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", original_scale * Vector2(0.9, 1.1), duration * 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", original_scale * Vector2(1.05, 0.97), duration * 0.2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "scale", original_scale, duration * 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	TweenManager.track(node, Animations.RUBBER_BAND, tween)
	return tween

## Rapidly cycles random rotations then snaps to original. Good for randomness feedback.
func fidget(node: CanvasItem, duration: float = 0.8, spins: int = 6) -> Tween:
	TweenManager.stop(node, Animations.FIDGET)
	var original_rotation = node.rotation_degrees
	var tween = node.get_tree().create_tween()
	for i in range(spins):
		var random_rot = randf_range(-25.0, 25.0)
		tween.tween_property(node, "rotation_degrees", original_rotation + random_rot, duration / spins).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "rotation_degrees", original_rotation, duration * 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	TweenManager.track(node, Animations.FIDGET, tween)
	return tween

## Slowly shrinks Y while expanding X, like air leaving a balloon.
func deflate(node: CanvasItem, duration: float = 0.6) -> Tween:
	TweenManager.stop(node, Animations.DEFLATE)
	var original_scale = node.scale
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "scale", original_scale * Vector2(1.3, 0.2), duration * 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", original_scale * Vector2(1.1, 0.15), duration * 0.2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "scale", original_scale, duration * 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	TweenManager.track(node, Animations.DEFLATE, tween)
	return tween

## Slow random wobble on position and rotation. Good for status effects.
func drunk(node: CanvasItem, duration: float = 0.8) -> Tween:
	TweenManager.stop(node, Animations.DRUNK)
	var original_pos = node.position
	var original_rot = node.rotation_degrees
	var tween = node.get_tree().create_tween()
	for i in range(4):
		var offset = Vector2(randf_range(-8, 8), randf_range(-5, 5))
		var rot = randf_range(-8, 8)
		tween.tween_property(node, "position", original_pos + offset, duration * 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.parallel().tween_property(node, "rotation_degrees", original_rot + rot, duration * 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "position", original_pos, duration * 0.2).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(node, "rotation_degrees", original_rot, duration * 0.2).set_trans(Tween.TRANS_SINE)
	TweenManager.track(node, Animations.DRUNK, tween)
	return tween

## Squash on hit, bounce up, then settle. Classic landing feel.
func impact_land(node: CanvasItem, duration: float = 0.5) -> Tween:
	TweenManager.stop(node, Animations.IMPACT_LAND)
	var original_scale = node.scale
	var original_pos = node.position
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "scale", original_scale * Vector2(1.4, 0.6), duration * 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", original_scale * Vector2(0.85, 1.2), duration * 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "position:y", original_pos.y - 12, duration * 0.2)
	tween.tween_property(node, "scale", original_scale * Vector2(1.05, 0.97), duration * 0.15).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(node, "position:y", original_pos.y, duration * 0.15)
	tween.tween_property(node, "scale", original_scale, duration * 0.2).set_trans(Tween.TRANS_SINE)
	TweenManager.track(node, Animations.IMPACT_LAND, tween)
	return tween
	#endregion

	#region NEW
	
## Gentle organic sway like a plant in wind.
func sway(node: CanvasItem, duration: float = 2.0, angle: float = 8.0) -> Tween:
	TweenManager.stop(node, Animations.SWAY)
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(node, "rotation_degrees", angle, duration * 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", -angle * 0.6, duration * 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", angle * 0.3, duration * 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", 0.0, duration * 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	TweenManager.track(node, Animations.SWAY, tween)
	return tween

## Random opacity flicker like a candle or broken light.
func flicker(node: CanvasItem, duration: float = 0.08, min_alpha: float = 0.4) -> Tween:
	TweenManager.stop(node, Animations.FLICKER)
	var original_alpha = node.modulate.a
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	for i in range(8):
		var alpha = randf_range(min_alpha, original_alpha)
		tween.tween_property(node, "modulate:a", alpha, duration * randf_range(0.5, 1.5))
	TweenManager.track(node, Animations.FLICKER, tween)
	return tween

## Big scale punch with chromatic color shift. Classic critical hit feedback.
func critical_hit(node: CanvasItem, duration: float = 0.5, color: Color = Color(2.0, 0.3, 0.3, 1.0)) -> Tween:
	TweenManager.stop(node, Animations.CRITICAL_HIT)
	var original_scale = node.scale
	var original_color = node.modulate
	var secondary_color = Color(color.r, clampf(color.g + 0.8, 0.0, 2.0), 0.2, 1.0)
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "scale", original_scale * 1.6, duration * 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "modulate", color, duration * 0.1)
	tween.tween_property(node, "scale", original_scale * 0.85, duration * 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(node, "modulate", secondary_color, duration * 0.15)
	tween.tween_property(node, "scale", original_scale * 1.1, duration * 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", original_scale, duration * 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "modulate", original_color, duration * 0.3)
	TweenManager.track(node, Animations.CRITICAL_HIT, tween)
	return tween

## Scale up, glow, then settle. Celebratory upgrade feedback.
func upgrade(node: CanvasItem, duration: float = 0.8, glow: Color = Color(2.0, 1.8, 0.2, 1.0)) -> Tween:
	TweenManager.stop(node, Animations.UPGRADE)
	var original_scale = node.scale
	var original_color = node.modulate
	var secondary_color = Color(glow.r * 0.9, glow.g * 0.9, glow.b + 0.3, 1.0)
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "scale", original_scale * 0.8, duration * 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", original_scale * 1.5, duration * 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "modulate", glow, duration * 0.2)
	tween.tween_property(node, "scale", original_scale * 1.2, duration * 0.15).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(node, "modulate", secondary_color, duration * 0.15)
	tween.tween_property(node, "scale", original_scale * 1.35, duration * 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "scale", original_scale, duration * 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "modulate", original_color, duration * 0.3)
	TweenManager.track(node, Animations.UPGRADE, tween)
	return tween

## Unfolds the node by scaling Y from 0 to full size.
func fold_in(node: CanvasItem, duration: float = 0.3) -> Tween:
	TweenManager.stop(node, Animations.FOLD_IN)
	var original_scale = node.scale
	node.scale.y = 0.0
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "scale:y", original_scale.y, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	TweenManager.track(node, Animations.FOLD_IN, tween)
	return tween

## Folds the node away by scaling Y to 0.
func fold_out(node: CanvasItem, duration: float = 0.3) -> Tween:
	TweenManager.stop(node, Animations.FOLD_OUT)
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "scale:y", 0.0, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	TweenManager.track(node, Animations.FOLD_OUT, tween)
	return tween

## Rapid red flash loop, urgent warning.
func alarm(node: CanvasItem, duration: float = 0.3, color : Color = Color(2.0, 0.2, 0.2, 1.0)) -> Tween:
	TweenManager.stop(node, Animations.ALARM)
	var original_color = node.modulate
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(node, "modulate", color, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "modulate", original_color, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	TweenManager.track(node, Animations.ALARM, tween)
	return tween

## Quick nudge in one direction then back, like pointing at something.
func point(node: CanvasItem, duration: float = 0.5, direction: Vector2 = Vector2.RIGHT, amount: float = 24.0) -> Tween:
	TweenManager.stop(node, Animations.POINT)
	var original_pos = node.position
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "position", original_pos + direction.normalized() * amount, duration * 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position", original_pos, duration * 0.7).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	TweenManager.track(node, Animations.POINT, tween)
	return tween

## Scale up, slight rotation, then settle. Celebratory reveal.
func tada(node: CanvasItem, duration: float = 0.6) -> Tween:
	TweenManager.stop(node, Animations.TADA)
	var original_scale = node.scale
	var original_rotation = node.rotation_degrees
	var tween = node.get_tree().create_tween()
	tween.tween_property(node, "scale", original_scale * 0.8, duration * 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", original_scale * 1.4, duration * 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "rotation_degrees", original_rotation - 8.0, duration * 0.2)
	tween.tween_property(node, "rotation_degrees", original_rotation + 8.0, duration * 0.15).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "rotation_degrees", original_rotation, duration * 0.15).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "scale", original_scale, duration * 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	TweenManager.track(node, Animations.TADA, tween)
	return tween

## Slowly fades to low alpha and back, ethereal feel.
func ghost(node: CanvasItem, duration: float = 2.0, min_alpha: float = 0.2) -> Tween:
	TweenManager.stop(node, Animations.GHOST)
	var original_alpha = node.modulate.a
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(node, "modulate:a", min_alpha, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "modulate:a", original_alpha, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	TweenManager.track(node, Animations.GHOST, tween)
	return tween

## Grows slightly then pulses to draw attention.
func attract(node: CanvasItem, duration: float = 1.2, strength: float = 0.12) -> Tween:
	TweenManager.stop(node, Animations.ATTRACT)
	var original_scale = node.scale
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(node, "scale", original_scale * (1.0 + strength), duration * 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", original_scale * (1.0 + strength * 0.5), duration * 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", original_scale * (1.0 + strength), duration * 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", original_scale, duration * 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	TweenManager.track(node, Animations.ATTRACT, tween)
	return tween

## Orbits the node in a circle around its original position.
func orbit(node: CanvasItem, duration: float = 2.0, radius: float = 30.0) -> Tween:
	TweenManager.stop(node, Animations.ORBIT)
	var original_pos = node.position
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	var steps = 60
	for i in range(steps + 1):
		var angle = (float(i) / steps) * TAU
		var offset = Vector2(cos(angle), sin(angle)) * radius
		tween.tween_property(node, "position", original_pos + offset, duration / steps).set_trans(Tween.TRANS_LINEAR)
	TweenManager.track(node, Animations.ORBIT, tween)
	return tween

	#endregion

#endregion
