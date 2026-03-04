@tool
extends Node

@export_tool_button("Generate MeshLibrary", "MeshInstance3D")
var generate_tiles_action := _generate

@export var meshlib_name: String = "test"
@export var collisions: bool
@export var material: Material

@onready var parent: Node3D = get_parent()


func _generate() -> void:
	assert(meshlib_name)
	var filepath := str("res://assets/meshlibrary/", meshlib_name, ".meshlib")
	print("Generating MeshLibrary: ", filepath)

	for child in parent.get_children():
		if child is MeshInstance3D:
			child.queue_free()

	var meshes: Array[ArrayMesh] = [
		_quad(1, 0, 1),
		_box(1, 0.5, 1),
		_ramp(1, 0.5, 1),
	]

	var ml := MeshLibrary.new()

	for i in meshes.size():
		_add_lib_mesh(ml, Vector3.RIGHT * i, meshes[i])

	util.aok(ResourceSaver.save(ml, filepath))


class MeshBuilder:
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	var size := 0


	func _add_point(vert: Vector3, normal: Vector3, uv: Vector2) -> void:
		util.expect_false(verts.push_back(vert))
		util.expect_false(normals.push_back(normal))
		util.expect_false(uvs.push_back(uv))
		size += 1


	func add_quad(
			p0: Vector3,
			p1: Vector3,
			p2: Vector3,
			uv0: Vector2,
			uv1: Vector2,
			uv2: Vector2,
	) -> void:
		var i := size

		var dp1 := p1 - p0
		var dp2 := p2 - p0
		var duv1 := uv1 - uv0
		var duv2 := uv2 - uv0

		var normal := dp2.cross(dp1)

		_add_point(p0, normal, uv0)
		_add_point(p1, normal, uv1)
		_add_point(p2, normal, uv2)
		_add_point(p0 + dp1 + dp2, normal, uv0 + duv1 + duv2)

		util.expect_false(indices.push_back(i + 0))
		util.expect_false(indices.push_back(i + 1))
		util.expect_false(indices.push_back(i + 2))
		util.expect_false(indices.push_back(i + 2))
		util.expect_false(indices.push_back(i + 1))
		util.expect_false(indices.push_back(i + 3))


	func add_tri(
			p0: Vector3,
			p1: Vector3,
			p2: Vector3,
			uv0: Vector2,
			uv1: Vector2,
			uv2: Vector2,
	) -> void:
		var i := size

		var dp1 := p1 - p0
		var dp2 := p2 - p0

		var normal := dp2.cross(dp1)

		_add_point(p0, normal, uv0)
		_add_point(p1, normal, uv1)
		_add_point(p2, normal, uv2)

		util.expect_false(indices.push_back(i + 0))
		util.expect_false(indices.push_back(i + 1))
		util.expect_false(indices.push_back(i + 2))


	func build() -> ArrayMesh:
		var surface := []
		var mesh := ArrayMesh.new()

		var _size := surface.resize(Mesh.ARRAY_MAX)
		surface[Mesh.ARRAY_VERTEX] = verts
		surface[Mesh.ARRAY_NORMAL] = normals
		surface[Mesh.ARRAY_TEX_UV] = uvs
		surface[Mesh.ARRAY_INDEX] = indices

		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface)

		return mesh


static func _quad(dx: float, dy: float, dz: float) -> ArrayMesh:
	assert(dx > 0.0)
	assert(dz > 0.0)

	var b := MeshBuilder.new()

	b.add_quad(
		Vector3(0.0, dy, 0.0),
		Vector3(dx, dy, 0.0),
		Vector3(0.0, dy, dz),
		Vector2(0.0, 0.0),
		Vector2(1.0, 0.0),
		Vector2(0.0, 1.0),
	)

	return b.build()


static func _box(dx: float, dy: float, dz: float) -> ArrayMesh:
	assert(dx > 0.0)
	assert(dy > 0.0)
	assert(dz > 0.0)

	var b := MeshBuilder.new()

	# Top
	b.add_quad(
		Vector3(0.0, dy, 0.0),
		Vector3(dx, dy, 0.0),
		Vector3(0.0, dy, dz),
		Vector2(0.0, 0.0),
		Vector2(1.0, 0.0),
		Vector2(0.0, 1.0),
	)

	# Front
	b.add_quad(
		Vector3(0.0, dy, dz),
		Vector3(dx, dy, dz),
		Vector3(0.0, 0.0, dz),
		Vector2(0.0, 0.0),
		Vector2(1.0, 0.0),
		Vector2(0.0, 1.0),
	)

	# Left
	b.add_quad(
		Vector3(0.0, dy, 0.0),
		Vector3(0.0, dy, dz),
		Vector3(0.0, 0.0, 0.0),
		Vector2(0.0, 0.0),
		Vector2(1.0, 0.0),
		Vector2(0.0, 1.0),
	)

	# Right
	b.add_quad(
		Vector3(dx, dy, dz),
		Vector3(dx, dy, 0.0),
		Vector3(dx, 0.0, dz),
		Vector2(0.0, 0.0),
		Vector2(1.0, 0.0),
		Vector2(0.0, 1.0),
	)

	return b.build()


static func _ramp(dx: float, dy: float, dz: float) -> ArrayMesh:
	assert(dx > 0.0)
	assert(dy > 0.0)
	assert(dz > 0.0)

	var b := MeshBuilder.new()

	# Top
	b.add_quad(
		Vector3(0.0, dy, 0.0),
		Vector3(dx, dy, 0.0),
		Vector3(0.0, 0.0, dz),
		Vector2(0.0, 0.0),
		Vector2(1.0, 0.0),
		Vector2(0.0, 1.0),
	)

	# Left
	b.add_tri(
		Vector3(0.0, dy, 0.0),
		Vector3(0.0, 0.0, dz),
		Vector3(0.0, 0.0, 0.0),
		Vector2(0.0, 0.0),
		Vector2(1.0, 1.0),
		Vector2(0.0, 1.0),
	)

	# Right
	b.add_tri(
		Vector3(dx, 0.0, dz),
		Vector3(dx, dy, 0.0),
		Vector3(dx, 0.0, 0.0),
		Vector2(0.0, 1.0),
		Vector2(1.0, 0.0),
		Vector2(1.0, 1.0),
	)

	return b.build()


static func _create_mesh(
		verts: PackedVector3Array,
		normals: PackedVector3Array,
		uvs: PackedVector2Array,
		indices: PackedInt32Array,
) -> ArrayMesh:
	var surface := []
	var mesh := ArrayMesh.new()

	var _size := surface.resize(Mesh.ARRAY_MAX)
	surface[Mesh.ARRAY_VERTEX] = verts
	surface[Mesh.ARRAY_NORMAL] = normals
	surface[Mesh.ARRAY_TEX_UV] = uvs
	surface[Mesh.ARRAY_INDEX] = indices

	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface)

	return mesh


func _add_lib_mesh(
		ml: MeshLibrary,
		position: Vector3,
		mesh: ArrayMesh,
) -> void:
	if material:
		for i in mesh.get_surface_count():
			mesh.surface_set_material(i, material)

	var mi := MeshInstance3D.new()
	mi.position = position
	mi.mesh = mesh
	parent.add_child(mi)
	mi.owner = get_tree().edited_scene_root

	var id := ml.get_last_unused_item_id()
	ml.create_item(id)
	ml.set_item_mesh(id, mesh)

	if collisions:
		mi.create_convex_collision(true, true)
		var coll_shape: CollisionShape3D = mi.get_child(0).get_child(0)
		ml.set_item_shapes(id, [coll_shape.shape])
