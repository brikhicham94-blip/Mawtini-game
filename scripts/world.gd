extends Node3D
# Greybox blockout. Historic street/building footprints are placeholders pending archival verification.

func _ready() -> void:
    _make_environment()
    _make_ground()
    _make_square()
    _make_street()
    _make_buildings()
    _make_props()
    _make_labels()

func _mat(color: Color) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = 0.92
    return m

func _box(parent: Node3D, box_name: String, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = box_name
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.position = pos
    node.material_override = _mat(color)
    parent.add_child(node)
    var body := StaticBody3D.new()
    body.name = box_name + "_Collision"
    var shape := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = size
    shape.shape = box
    body.add_child(shape)
    body.position = pos
    add_child(body)
    return node

func _make_environment() -> void:
    var env := WorldEnvironment.new()
    var e := Environment.new()
    e.background_mode = Environment.BG_SKY
    e.sky = Sky.new()
    e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    e.ambient_light_color = Color(0.72, 0.76, 0.8)
    e.ambient_light_energy = 0.8
    env.environment = e
    add_child(env)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -28, 0)
    sun.light_energy = 1.15
    add_child(sun)

func _make_ground() -> void:
    _box(self, "Terrain_Base", Vector3(0, -0.35, 0), Vector3(100, 0.7, 100), Color("#b6a17e"))
    for i in range(9):
        var x := -44.0 + i * 11.0
        var hill := _box(self, "Distant_Hill_%02d" % i, Vector3(x, 2.0, -43), Vector3(12, 7 + float(i % 3) * 2, 8), Color("#8b927e"))
        hill.rotation_degrees.y = float(i * 17)

func _make_square() -> void:
    _box(self, "Town_Square", Vector3(0, 0.03, -5), Vector3(27, 0.12, 22), Color("#9b9488"))
    for i in range(8):
        _box(self, "Paving_%02d" % i, Vector3(-11 + i * 3.1, 0.105, -5), Vector3(0.08, 0.025, 21), Color("#77766f"))

func _make_street() -> void:
    _box(self, "Main_Street", Vector3(0, 0.02, 14), Vector3(12, 0.1, 42), Color("#625f58"))
    for side in [-1, 1]:
        for i in range(8):
            _box(self, "Kerb_%s_%02d" % [str(side), i], Vector3(side * 6.25, 0.12, -5 + i * 5.5), Vector3(0.35, 0.25, 5.3), Color("#c0b7a5"))

func _make_buildings() -> void:
    var plaster := Color("#d6c5a6")
    var pale := Color("#c6b99f")
    var roof := Color("#8a5840")
    var specs = [
        [Vector3(-18, 3.2, -13), Vector3(9, 6.4, 8)],
        [Vector3(-18, 2.6, -1), Vector3(9, 5.2, 7)],
        [Vector3(18, 3.0, -13), Vector3(9, 6, 8)],
        [Vector3(18, 2.7, -1), Vector3(9, 5.4, 7)],
        [Vector3(-13, 2.5, 25), Vector3(8, 5, 9)],
        [Vector3(13, 3.0, 25), Vector3(8, 6, 9)],
        [Vector3(-28, 2.4, 13), Vector3(8, 4.8, 10)],
        [Vector3(28, 2.8, 13), Vector3(8, 5.6, 10)]
    ]
    for i in range(specs.size()):
        var p: Vector3 = specs[i][0]
        var s: Vector3 = specs[i][1]
        var c := plaster if i % 2 == 0 else pale
        _box(self, "Historic_Block_%02d" % i, p, s, c)
        _box(self, "Roof_%02d" % i, p + Vector3(0, s.y * 0.5 + 0.18, 0), Vector3(s.x + 0.4, 0.35, s.z + 0.4), roof)
        var front_z := p.z + s.z * 0.5 + 0.03
        for wx in [-2.5, 0.0, 2.5]:
            for wy in [1.7, 3.6]:
                if wy < s.y:
                    _box(self, "Window_%02d" % i, Vector3(p.x + wx, wy, front_z), Vector3(1.0, 1.25, 0.12), Color("#343b3d"))
    _box(self, "Civic_Hall_Base", Vector3(0, 2.6, -20), Vector3(19, 5.2, 5), Color("#d8c7a9"))
    _box(self, "Civic_Hall_Upper", Vector3(0, 5.6, -20), Vector3(17, 1.1, 5.3), Color("#c8b99f"))
    for x in range(-8, 9, 4):
        _box(self, "Civic_Column", Vector3(float(x), 2.3, -17.35), Vector3(0.55, 4.6, 0.55), Color("#eee1c9"))

func _make_props() -> void:
    for i in range(5):
        var x := -10.0 + i * 4.8
        _box(self, "Market_Counter_%02d" % i, Vector3(x, 0.7, 3), Vector3(3.2, 1.1, 1.6), Color("#8a6548"))
        _box(self, "Market_Canopy_%02d" % i, Vector3(x, 2.0, 3), Vector3(3.5, 0.15, 2.0), Color("#b46b45") if i % 2 == 0 else Color("#d5c29b"))
    for x in [-5.5, 5.5]:
        _box(self, "Street_Lamp", Vector3(x, 2.0, -5), Vector3(0.12, 4, 0.12), Color("#292b2b"))
        _box(self, "Lamp_Head", Vector3(x, 4.05, -5), Vector3(0.65, 0.35, 0.65), Color("#e5d6a4"))

func _make_labels() -> void:
    var label := Label3D.new()
    label.text = "TIARET  •  1956"
    label.font_size = 72
    label.position = Vector3(0, 9, -20)
    label.modulate = Color("#f6e8c8")
    add_child(label)
