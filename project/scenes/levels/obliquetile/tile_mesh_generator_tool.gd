@tool
extends Node

@export_tool_button("Generate Tiles", "MeshInstance3D")
var generate_tiles_action := _generate

@export var material: Resource


func _generate() -> void:
	var parent: Node3D = get_parent()
	print("Generating tiles on ", parent)

	for child in parent.get_children():
		if child is MeshInstance3D:
			child.queue_free()

	_add_mesh_instance(parent, Vector3.ZERO, _quad(1, 0, 1), material)
	_add_mesh_instance(parent, Vector3.RIGHT, _box(1, 0.5, 1), material)
	_add_mesh_instance(parent, Vector3.RIGHT * 2, _ramp(1, 0.5, 1), material)


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


func _add_mesh_instance(
		parent: Node3D,
		position: Vector3,
		mesh: ArrayMesh,
		material_override: Resource,
) -> void:
	var mi := MeshInstance3D.new()
	mi.position = position
	mi.mesh = mesh
	if material_override:
		mi.material_override = material_override
	parent.add_child(mi)
	mi.owner = get_tree().edited_scene_root
