extends Node3D

@onready var player: CharacterBody3D = get_node("../Player")
@onready var player_camera: Camera3D = get_node("../Player/CameraPivot/Camera3D")

var cinematic_camera: Camera3D
var shade: ColorRect
var title_label: Label
var subtitle_label: Label
var sound_bed: AudioStreamPlayer
var skip_requested := false
var finished := false

func _ready() -> void:
    await get_tree().process_frame
    _build_cinematic_ui()
    _play_opening()

func _build_cinematic_ui() -> void:
    var layer := CanvasLayer.new()
    layer.layer = 20
    add_child(layer)
    shade = ColorRect.new()
    shade.color = Color(0, 0, 0, 1)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(shade)
    title_label = Label.new()
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    title_label.add_theme_font_size_override("font_size", 48)
    title_label.add_theme_color_override("font_color", Color("#f1dfbd"))
    title_label.anchor_left = 0.06
    title_label.anchor_right = 0.94
    title_label.anchor_top = 0.30
    title_label.anchor_bottom = 0.52
    layer.add_child(title_label)
    subtitle_label = Label.new()
    subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    subtitle_label.add_theme_font_size_override("font_size", 25)
    subtitle_label.add_theme_color_override("font_color", Color("#e5d4b5"))
    subtitle_label.anchor_left = 0.07
    subtitle_label.anchor_right = 0.93
    subtitle_label.anchor_top = 0.53
    subtitle_label.anchor_bottom = 0.72
    layer.add_child(subtitle_label)
    var skip_label := Label.new()
    skip_label.text = "اضغط للتخطي"
    skip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    skip_label.add_theme_font_size_override("font_size", 18)
    skip_label.add_theme_color_override("font_color", Color("#d8d0c2"))
    skip_label.anchor_left = 0.68
    skip_label.anchor_right = 0.96
    skip_label.anchor_top = 0.9
    skip_label.anchor_bottom = 0.98
    layer.add_child(skip_label)
    sound_bed = AudioStreamPlayer.new()
    sound_bed.name = "OpeningSoundBed"
    sound_bed.bus = "Master"
    add_child(sound_bed)
    # Audio recordings can be placed in res://audio/ and assigned here.
    # No fabricated historical recordings are bundled with this script.

func _unhandled_input(event: InputEvent) -> void:
    if finished:
        return
    if (event is InputEventScreenTouch and event.pressed) or (event is InputEventKey and event.pressed and not event.echo) or (event is InputEventMouseButton and event.pressed):
        skip_requested = true

func _play_opening() -> void:
    player.set_physics_process(false)
    player_camera.current = false
    cinematic_camera = Camera3D.new()
    cinematic_camera.name = "OpeningCamera"
    cinematic_camera.fov = 55.0
    add_child(cinematic_camera)
    cinematic_camera.global_position = Vector3(0, 52, 78)
    cinematic_camera.look_at(Vector3(0, 0, -18), Vector3.UP)
    cinematic_camera.current = true

    await _show_card("1956", "الجزاير… تحت ليل الاستعمار", 2.8)
    if skip_requested:
        _finish_opening()
        return
    await _show_card("صرخات خلف الأبواب", "عيالات ورجالة يعيطو ويستغيثو… وعائلات تستنى خبر على وليداتها.", 4.0)
    if skip_requested:
        _finish_opening()
        return
    await _show_card("التعذيب والاعتقال", "كانو يعذّبو الناس بالكهرباء، بالماء والضرب… ويهينوهم باش يكسروهم.", 4.0)
    if skip_requested:
        _finish_opening()
        return
    await _show_card("الإعدام والاختفاء", "يمّاوات يقلبو على وليداتهم… وديار ولات خاوية من ناسها.", 4.0)
    if skip_requested:
        _finish_opening()
        return
    await _show_card("لكن الذاكرة لا تموت", "من وسط الوجع، الشعب ما سكتش… ومن هنا تبدا حكايتنا في تيارت، عام 1956.", 4.5)
    if skip_requested:
        _finish_opening()
        return

    title_label.text = ""
    subtitle_label.text = ""
    var reveal_city := create_tween()
    reveal_city.tween_property(shade, "color:a", 0.0, 1.8)
    await reveal_city.finished
    var move := create_tween()
    move.tween_property(cinematic_camera, "global_position", Vector3(0, 23, 43), 6.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    await _wait_or_skip(6.0)
    if skip_requested:
        _finish_opening()
        return
    await _show_card("تيارت — 1956", "ومن هنا… تبدا رحلتك.", 2.5)
    var fade := create_tween()
    fade.tween_property(shade, "color:a", 1.0, 0.8)
    await fade.finished
    _finish_opening()

func _show_card(main_text: String, sub_text: String, duration: float) -> void:
    title_label.text = main_text
    subtitle_label.text = sub_text
    shade.color.a = 1.0
    var fade := create_tween()
    fade.tween_property(shade, "color:a", 0.18, 0.9)
    await fade.finished
    await _wait_or_skip(duration)
    if skip_requested:
        return
    var darken := create_tween()
    darken.tween_property(shade, "color:a", 1.0, 0.65)
    await darken.finished

func _wait_or_skip(seconds: float) -> void:
    var elapsed := 0.0
    while elapsed < seconds and not skip_requested:
        await get_tree().process_frame
        elapsed += get_process_delta_time()

func _finish_opening() -> void:
    if finished:
        return
    finished = true
    if is_instance_valid(sound_bed):
        sound_bed.stop()
    if is_instance_valid(cinematic_camera):
        cinematic_camera.current = false
        cinematic_camera.queue_free()
    player_camera.current = true
    player.set_physics_process(true)
    var reveal := create_tween()
    reveal.tween_property(shade, "color:a", 0.0, 1.0)
    await reveal.finished
    title_label.text = ""
    subtitle_label.text = ""
    shade.queue_free()
