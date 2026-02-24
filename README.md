# TweenFX
A simple, juicy tween animation library for Godot 4.

## Installation
1. Download from the [Godot Asset Library](https://godotengine.org/asset-library/asset/4827) or copy `addons/TweenFX` into your project
2. Enable the plugin in Project Settings → Plugins

## Usage
```gdscript
# Call any animation directly
TweenFX.shake(node)
TweenFX.shake(node, 0.5, 20.0, 8)  # duration, amount, shakes

# Await completion
await TweenFX.pop_in(node).finished

# Stop animations
TweenFX.stop(node, TweenFX.Animations.SHAKE)
TweenFX.stop_all(node)

# Looping animations run until stopped
TweenFX.float_bob(node)
TweenFX.stop(node, TweenFX.Animations.FLOAT_BOB)

# PlayState for interactive UI
TweenFX.snap(node, 0.1, Vector2.ONE * 1.2, TweenFX.PlayState.ENTER)
TweenFX.snap(node, 0.1, Vector2.ONE, TweenFX.PlayState.EXIT)
```

## Try it out!
A live demo is available in the [releases](https://github.com/EvilBunnyMan/TweenFX/releases).
It includes an interactive tutorial.

## License
MIT — free for personal and commercial use.

## Fonts used in demo
- PxPlus IBM VGA8
- PixelOperator8
- Google Sans Code
