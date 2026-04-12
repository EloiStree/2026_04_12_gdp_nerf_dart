extends Node
# Inside your gun script
@export var dart_scene: PackedScene
@export var muzzle_speed := 32.0          # m/s – tweak to match your Nerf blaster
@export var muzzle_node:Node

func shoot():
	var dart: NerfDart = dart_scene.instantiate()
	get_tree().current_scene.add_child(dart)
	dart.fire(muzzle_node, muzzle_speed, 1.5)   # 1.5° spread
