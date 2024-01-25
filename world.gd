extends Node2D

@export var next_level: PackedScene
@onready var level_completed: ColorRect = $CanvasLayer/LevelCompleted
@onready var start_in: ColorRect = %StartIn
@onready var start_in_label: Label = %StartInLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var level_time_label: Label = %LevelTimeLabel

var level_time = 0.0
var start_level_msec = 0.0

func _ready() -> void:
	if not next_level is PackedScene:
		level_completed.next_level_button.text = "Victory Screen"
		next_level = load("res://victory_screen.tscn")

	Events.level_completed.connect(show_level_completed)

	get_tree().paused = true
	start_in.visible = true
	LevelTransition.fade_from_black()
	animation_player.play("countdown")
	await animation_player.animation_finished
	get_tree().paused = false
	start_in.visible = false
	start_level_msec = Time.get_ticks_msec()


func _process(delta: float) -> void:
	level_time = Time.get_ticks_msec() - start_level_msec;
	level_time_label.text = str(level_time / 1000.0)


func retry():
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_file(scene_file_path)

func goto_next_level():
	if not next_level is PackedScene: return

	LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)


func show_level_completed():
	level_completed.show()
	level_completed.retry_button.grab_focus()
	get_tree().paused = true


func _on_level_completed_retry() -> void:
	retry()


func _on_level_completed_next_level() -> void:
	goto_next_level()
