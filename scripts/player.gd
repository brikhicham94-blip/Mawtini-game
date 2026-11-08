extends CharacterBody3D

@export var move_speed := 5.0
@export var sprint_speed := 8.0
@export var gravity := 18.0
@export var look_sensitivity := 0.004
var camera_pivot: Node3D
var touch_look_active := false
var last_touch_position := Vector2.ZERO

func _ready() -> void:
    camera_pivot = $CameraPivot
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    _create_mobile_controls()

func _create_mobile_controls() -> void:
    var layer := CanvasLayer.new()
    layer.name = "MobileControls"
    add_child(layer)

    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_PASS
    layer.add_child(root)

    _make_action_button(root, "◀", "move_left", Vector2(28, -112))
    _make_action_button(root, "▶", "move_right", Vector2(168, -112))
    _make_action_button(root, "▲", "move_forward", Vector2(98, -182))
    _make_action_button(root, "▼", "move_back", Vector2(98, -42))
    _make_action_button(root, "ركض", "sprint", Vector2(-116, -100), true)

func _make_action_button(parent: Control, caption: String, action: String, offset: Vector2, sprint := false) -> void:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(64, 64) if not sprint else Vector2(88, 64)
    button.anchor_left = 0.0 if offset.x >= 0 else 1.0
    button.anchor_right = button.anchor_left
    button.anchor_top = 1.0
    button.anchor_bottom = 1.0
    button.offset_left = offset.x
    button.offset_right = offset.x + button.custom_minimum_size.x
    button.offset_top = offset.y
    button.offset_bottom = offset.y + button.custom_minimum_size.y
    button.modulate = Color(1, 1, 1, 0.82)
    parent.add_child(button)
    button.button_down.connect(func():
        Input.action_press(action)
    )
    button.button_up.connect(func():
        Input.action_release(action)
    )
    button.tree_exiting.connect(func():
        Input.action_release(action)
    )

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and event.position.x > get_viewport().get_visible_rect().size.x * 0.42:
            touch_look_active = true
            last_touch_position = event.position
        elif not event.pressed:
            touch_look_active = false
    elif event is InputEventScreenDrag and touch_look_active:
        var delta := event.position - last_touch_position
        _rotate_camera(delta)
        last_touch_position = event.position
    elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        _rotate_camera(event.relative)
    elif event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    elif event is InputEventMouseButton and event.pressed:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _rotate_camera(delta: Vector2) -> void:
    rotate_y(-delta.x * look_sensitivity)
    camera_pivot.rotate_x(-delta.y * look_sensitivity)
    camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -0.85, 0.35)

func _physics_process(delta: float) -> void:
    var input_vec := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var dir := (transform.basis * Vector3(input_vec.x, 0, input_vec.y)).normalized()
    var speed := sprint_speed if Input.is_action_pressed("sprint") or Input.is_key_pressed(KEY_SHIFT) else move_speed
    if dir.length_squared() > 0.001:
        velocity.x = dir.x * speed
        velocity.z = dir.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0.0, move_speed)
        velocity.z = move_toward(velocity.z, 0.0, move_speed)
    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = 0.0
    move_and_slide()
