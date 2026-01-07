class_name MathX

static func is_equal_approxf(a: float, b: float, tolerance: float) -> bool:
	return absf(a - b) < tolerance
