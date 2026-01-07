extends Node
class_name Util

static func _ga_worker(nd: Node3D, aabb: AABB) -> AABB:
	if nd.has_method(&'get_aabb'):
		var ret: Variant = nd.call('get_aabb')
		if ret is AABB:
			var ra: AABB = ret
			aabb = aabb.merge(ra)
			
	for cn: Node3D in nd.get_children():
		aabb = _ga_worker(cn, aabb)
		
	return aabb
	
static func get_aabb(nd: Node3D) -> AABB:
	var aabb: AABB = AABB()
	
	return _ga_worker(nd, aabb)
