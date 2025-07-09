extends OffsetYGenerator

#-------------------------------------------------------------------------------
# Private Overrides
#-------------------------------------------------------------------------------
func _get_offset_y(x: float, p: float, a: float) -> float:
	return a * sin(sin(2 * x * p) + sin(4 * x * p))
