extends Node3D

# Tiaret, 1956 — expanded playable historical environment.
# Layout is a researched visual reconstruction, not a surveyed cadastral map.

const WALL := Color("#d7c6a8")
const LIGHT_WALL := Color("#e6d8bd")
const STONE := Color("#9b8c75")
const ROOF := Color("#8b5944")
const DARK := Color("#30383a")
const WOOD := Color("#654631")
const OCHRE := Color("#c7a77a")
const PALE_STONE := Color("#eee2c9")
const SHUTTER_GREEN := Color("#68735d")
const TERRACOTTA := Color("#985d43")
const IRON := Color("#343638")

func _ready() -> void:
    _make_environment()
    _make_ground()
    _make_roads()
    _make_old_quarter()
    _make_civic_district()
    _make_landmarks()
    _make_market()
    _make_street_life()
    _make_labels()

func _material(color: Color) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = 0.9
    return m

func _visual_box(parent: Node3D, n: String, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = n
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.position = pos
    node.material_override = _material(color)
    parent.add_child(node)
    return node

func _solid_box(parent: Node3D, n: String, pos: Vector3, size: Vector3, color: Color) -> void:
    _visual_box(parent, n, pos, size, color)
    var body := StaticBody3D.new()
    body.name = n + "_Collision"
    var shape := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = size
    shape.shape = box
    body.add_child(shape)
    body.position = pos
    parent.add_child(body)

func _make_environment() -> void:
    var env := WorldEnvironment.new()
    var e := Environment.new()
    e.background_mode = Environment.BG_SKY
    e.sky = Sky.new()
    e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    e.ambient_light_color = Color("#c5cbd0")
    e.ambient_light_energy = 0.72
    e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env.environment = e
    add_child(env)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-42, -32, 0)
    sun.light_energy = 1.25
    sun.shadow_enabled = true
    add_child(sun)

func _make_ground() -> void:
    _solid_box(self, "High_Plateau_Ground", Vector3(0, -0.65, 0), Vector3(240, 1.2, 240), Color("#b6a17e"))
    for i in range(18):
        var x := -105.0 + float(i) * 12.0
        var hill := _visual_box(self, "Guezzoul_Ridge_%02d" % i, Vector3(x, 5.0 + float(i % 4), -105.0), Vector3(16, 12 + float(i % 3) * 3, 20), Color("#858a78"))
        hill.rotation_degrees.y = float(i * 13)
    for i in range(12):
        var x := -105.0 + float(i) * 19.0
        var hill := _visual_box(self, "Southern_Hills_%02d" % i, Vector3(x, 3.0, 105.0), Vector3(22, 8 + float(i % 3) * 2, 16), Color("#99947e"))
        hill.rotation_degrees.y = float(i * 19)

func _make_roads() -> void:
    _solid_box(self, "Avenue_Carnot", Vector3(0, 0.015, 4), Vector3(13, 0.12, 150), Color("#655f56"))
    _solid_box(self, "Rue_Bugeaud", Vector3(-39, 0.02, -3), Vector3(9, 0.12, 118), Color("#71685b"))
    _solid_box(self, "Rue_Cambon", Vector3(39, 0.02, -8), Vector3(9, 0.12, 125), Color("#71685b"))
    _solid_box(self, "Place_Centrale", Vector3(0, 0.04, -23), Vector3(42, 0.18, 30), Color("#a59b88"))
    for z in range(-65, 76, 14):
        _visual_box(self, "Road_Drain_%d" % z, Vector3(7.0, 0.09, float(z)), Vector3(0.18, 0.08, 4), Color("#4c4a45"))
        _visual_box(self, "Road_Drain_L_%d" % z, Vector3(-7.0, 0.09, float(z)), Vector3(0.18, 0.08, 4), Color("#4c4a45"))
    for x in [-7.8, 7.8, -44.0, -34.0, 34.0, 44.0]:
        _visual_box(self, "Stone_Sidewalk_%d" % int(x), Vector3(x, 0.12, 0), Vector3(1.2, 0.22, 150), Color("#c3b69f"))

func _make_house(n: String, center: Vector3, dims: Vector3, wall: Color, front: float = 1.0) -> void:
    var w := dims.x
    var h := dims.y
    var d := dims.z
    _solid_box(self, n + "_Walls", center + Vector3(0, h * 0.5, 0), Vector3(w, h, d), wall)
    _visual_box(self, n + "_Roof", center + Vector3(0, h + 0.16, 0), Vector3(w + 0.55, 0.32, d + 0.55), ROOF)
    _visual_box(self, n + "_Cornice", center + Vector3(0, h - 0.12, front * (d * 0.5 + 0.12)), Vector3(w + 0.25, 0.22, 0.22), LIGHT_WALL)
    var face_z := center.z + front * (d * 0.5 + 0.075)
    _visual_box(self, n + "_Door", Vector3(center.x, 1.15, face_z), Vector3(1.25, 2.3, 0.16), WOOD)
    for wx in [-w * 0.29, w * 0.29]:
        for wy in [2.0, minf(4.0, h - 0.8)]:
            if wy < h - 0.35:
                _visual_box(self, n + "_Window_%d_%d" % [int(wx), int(wy)], Vector3(center.x + wx, wy, face_z + 0.04), Vector3(1.05, 1.25, 0.16), DARK)
                _visual_box(self, n + "_Shutter_L", Vector3(center.x + wx - 0.63, wy, face_z + 0.12), Vector3(0.18, 1.35, 0.12), Color("#65705d"))
                _visual_box(self, n + "_Shutter_R", Vector3(center.x + wx + 0.63, wy, face_z + 0.12), Vector3(0.18, 1.35, 0.12), Color("#65705d"))

func _make_old_quarter() -> void:
    # Dense low-rise houses, courtyards and narrow lanes on the sloping upper town.
    var row_x := [-66.0, -54.0, 54.0, 66.0]
    var row_z := [-54.0, -34.0, -14.0, 10.0, 31.0, 52.0]
    var index := 0
    for x in row_x:
        for z in row_z:
            var height := 4.2 + float(index % 3) * 0.7
            var tint := WALL if index % 2 == 0 else LIGHT_WALL
            _make_house("Old_Tiaret_House_%02d" % index, Vector3(x, 0, z), Vector3(9.0, height, 10.0), tint, 1.0)
            index += 1
    # Courtyard walls and small alley connectors.
    for z in [-43.0, -3.0, 37.0]:
        _visual_box(self, "Courtyard_Wall", Vector3(-79, 1.2, z), Vector3(0.5, 2.4, 18), STONE)
        _visual_box(self, "Courtyard_Wall_R", Vector3(79, 1.2, z), Vector3(0.5, 2.4, 18), STONE)
    for x in [-60.0, 60.0]:
        _visual_box(self, "Alley_Rubble", Vector3(x, 0.2, -2), Vector3(4, 0.35, 95), Color("#9a8c75"))

func _make_civic_building(n: String, center: Vector3, width: float, height: float, depth: float, wall: Color) -> void:
    _solid_box(self, n + "_Main", center + Vector3(0, height * 0.5, 0), Vector3(width, height, depth), wall)
    _visual_box(self, n + "_Cornice", center + Vector3(0, height - 0.15, depth * 0.5 + 0.2), Vector3(width + 0.8, 0.35, 0.5), LIGHT_WALL)
    _visual_box(self, n + "_Steps", center + Vector3(0, 0.22, depth * 0.5 + 1.0), Vector3(width * 0.42, 0.44, 2.0), STONE)
    for x in range(-int(width * 0.38), int(width * 0.39), 3):
        _visual_box(self, n + "_Pilaster_%d" % x, center + Vector3(float(x), height * 0.5, depth * 0.5 + 0.13), Vector3(0.32, height - 0.5, 0.28), LIGHT_WALL)
        for y in [2.1, 4.5]:
            if y < height - 0.5:
                _visual_box(self, n + "_Tall_Window", center + Vector3(float(x) + 1.0, y, depth * 0.5 + 0.2), Vector3(0.95, 1.55, 0.16), DARK)
    _visual_box(self, n + "_Sign", center + Vector3(0, height - 1.0, depth * 0.5 + 0.28), Vector3(width * 0.35, 0.45, 0.12), Color("#e8ddc4"))

func _make_civic_district() -> void:
    # The post office is documented in Tiaret as completed in 1931.
    _make_civic_building("Historic_Post_Office_1931", Vector3(0, 0, -42), 21, 8, 8, Color("#d9c9aa"))
    _make_civic_building("Town_Hall", Vector3(-25, 0, -42), 17, 7, 8, Color("#d8c7a9"))
    _make_civic_building("Tribunal", Vector3(26, 0, -42), 16, 7, 8, Color("#cdbd9f"))
    _make_civic_building("School_Gambetta", Vector3(-26, 0, 28), 22, 7, 10, Color("#d8c6a8"))
    _make_civic_building("Hospital", Vector3(27, 0, 30), 23, 6, 12, Color("#e1d5bd"))
    _make_civic_building("Hotel_Finances", Vector3(0, 0, 57), 18, 7, 9, Color("#d2c2a4"))

func _make_landmarks() -> void:
    # Mosque: courtyard, prayer hall, square minaret and crescent-like finial.
    _solid_box(self, "Mosque_Prayer_Hall", Vector3(-5, 2.5, 8), Vector3(15, 5, 13), Color("#e4d8bf"))
    _visual_box(self, "Mosque_Roof", Vector3(-5, 5.1, 8), Vector3(15.8, 0.35, 13.8), Color("#a18b70"))
    _solid_box(self, "Mosque_Minaret", Vector3(5, 8, 3), Vector3(2.2, 16, 2.2), LIGHT_WALL)
    _visual_box(self, "Minaret_Balcony", Vector3(5, 12, 3), Vector3(3.2, 0.55, 3.2), STONE)
    _visual_box(self, "Minaret_Cap", Vector3(5, 16.5, 3), Vector3(2.8, 1.0, 2.8), ROOF)
    _visual_box(self, "Mosque_Door", Vector3(-5, 1.5, 14.58), Vector3(2.0, 3.0, 0.18), WOOD)
    # Church and its bell tower are included as a period urban landmark.
    _solid_box(self, "Church_Nave", Vector3(54, 3.0, -57), Vector3(15, 6, 24), Color("#d9cbb2"))
    _solid_box(self, "Church_Tower", Vector3(54, 8, -69), Vector3(4, 16, 4), LIGHT_WALL)
    _visual_box(self, "Church_Roof", Vector3(54, 6.3, -57), Vector3(15.8, 0.4, 24.8), ROOF)
    # Historic railway station / rail sidings at the edge of the town.
    _make_civic_building("Tiaret_Station", Vector3(-67, 0, 82), 22, 6, 9, Color("#d8c7a9"))
    _visual_box(self, "Rail_Bed", Vector3(-67, 0.05, 98), Vector3(10, 0.16, 38), Color("#65584a"))
    for x in [-70.0, -68.0, -66.0, -64.0]:
        _visual_box(self, "Rail", Vector3(x, 0.22, 98), Vector3(0.12, 0.16, 38), Color("#45484a"))
    for z in range(82, 116, 4):
        _visual_box(self, "Rail_Sleeper", Vector3(-67, 0.18, float(z)), Vector3(5, 0.18, 0.35), WOOD)

func _make_market() -> void:
    for i in range(7):
        var x := -18.0 + float(i) * 6.0
        _visual_box(self, "Market_Stall_%02d" % i, Vector3(x, 1.0, -3), Vector3(4.2, 1.6, 2.6), WOOD)
        _visual_box(self, "Market_Canopy_%02d" % i, Vector3(x, 2.3, -3), Vector3(4.8, 0.18, 3.2), Color("#b76f4c") if i % 2 == 0 else Color("#d6c29a"))
        for j in range(4):
            _visual_box(self, "Market_Crate", Vector3(x - 1.2 + float(j) * 0.75, 0.42, -1.3), Vector3(0.55, 0.65, 0.55), Color("#8d6846"))

func _make_street_life() -> void:
    for z in range(-65, 71, 22):
        for x in [-11.0, 11.0]:
            _visual_box(self, "Iron_Lamp_Post", Vector3(x, 2.5, float(z)), Vector3(0.16, 5.0, 0.16), DARK)
            _visual_box(self, "Lamp_Glass", Vector3(x, 5.15, float(z)), Vector3(0.65, 0.5, 0.65), Color("#e5d6a4"))
    for x in [-31.0, 31.0]:
        for z in [-20.0, 16.0, 52.0]:
            _visual_box(self, "Plane_Tree_Trunk", Vector3(x, 2.0, z), Vector3(0.55, 4.0, 0.55), Color("#6b5038"))
            var crown := SphereMesh.new()
            crown.radius = 2.3
            crown.height = 4.2
            var foliage := MeshInstance3D.new()
            foliage.name = "Tree_Crown"
            foliage.mesh = crown
            foliage.position = Vector3(x, 4.6, z)
            foliage.material_override = _material(Color("#68734f"))
            add_child(foliage)
    # A period handcart and water barrel add human scale without modern traffic.
    _visual_box(self, "Wooden_Cart_Bed", Vector3(16, 0.8, 13), Vector3(2.8, 0.25, 1.5), WOOD)
    for x in [14.9, 17.1]:
        var wheel := CylinderMesh.new()
        wheel.top_radius = 0.62
        wheel.bottom_radius = 0.62
        wheel.height = 0.18
        var mesh := MeshInstance3D.new()
        mesh.mesh = wheel
        mesh.position = Vector3(x, 0.65, 13)
        mesh.rotation_degrees.z = 90
        mesh.material_override = _material(DARK)
        add_child(mesh)
    _visual_box(self, "Water_Trough", Vector3(-20, 0.45, 17), Vector3(3.5, 0.8, 1.2), STONE)

func _make_labels() -> void:
    var label := Label3D.new()
    label.text = "TIARET  •  1956"
    label.font_size = 80
    label.position = Vector3(0, 11, -55)
    label.modulate = Color("#f6e8c8")
    add_child(label)
