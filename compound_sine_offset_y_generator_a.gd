extends OffsetYGenerator

#-------------------------------------------------------------------------------
# Private Overrides
#-------------------------------------------------------------------------------
func _get_offset_y(x: float, p: float, a: float) -> float:
	return a * (sin(x * p) + sin(2 * x * p))
