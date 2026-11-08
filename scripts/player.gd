extends CharacterBody3D

@export var move_speed := 5.0
@export var sprint_speed := 8.0
@export var gravity := 18.0
var camera_pivot: Node3D

func _ready() -> void:
    camera_pivot = $CameraPivot
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * 0.003)
        camera_pivot.rotate_x(-event.relative.y * 0.003)
        camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -0.8, 0.25)
    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    if event is InputEventMouseButton and event.pressed:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
    var input_vec := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var dir := (transform.basis * Vector3(input_vec.x, 0, input_vec.y)).normalized()
    var speed := sprint_speed if Input.is_key_pressed(KEY_SHIFT) else move_speed
    if dir:
        velocity.x = dir.x * speed
        velocity.z = dir.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0, move_speed)
        velocity.z = move_toward(velocity.z, 0, move_speed)
    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = 0
    move_and_slide()
