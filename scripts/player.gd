extends CharacterBody2D

@export var max_speed: float = 180.0
@export var acceleration: float = 600.0
@export var drag: float = 500.0
@export var arrive_slowdown_distance: float = 96.0
@export var stop_distance: float = 8.0

var target_position: Vector2
var has_target: bool = false

func _ready() -> void:
	target_position = global_position

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Convert click to world position and set as target
		target_position = get_global_mouse_position()
		has_target = true

func _physics_process(delta: float) -> void:
	# Underwater movement: no gravity or jumping

	# Holding LMB: continuously update target to cursor
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		target_position = get_global_mouse_position()
		has_target = true

	# Check if we've reached the target
	if has_target:
		var to_target := target_position - global_position
		if to_target.length() <= stop_distance:
			has_target = false

	if has_target:
		var to_target := target_position - global_position
		var distance := to_target.length()
		var dir := to_target.normalized()

		# Slow down as we approach the target for a smooth stop
		var target_speed := max_speed
		if distance < arrive_slowdown_distance:
			target_speed = lerp(0.0, max_speed, clamp(distance / arrive_slowdown_distance, 0.0, 1.0))

		var desired_velocity := dir * target_speed
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	else:
		# No target: water drag slows the diver to a gentle stop
		velocity = velocity.move_toward(Vector2.ZERO, drag * delta)

	move_and_slide()
