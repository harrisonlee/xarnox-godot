@tool extends OffsetYGenerator

#-------------------------------------------------------------------------------
# Private Overrides
#-------------------------------------------------------------------------------
func _get_offset_y(x: float, p: float, a: float) -> float:
	return a * sin(3 * x * p + sin(x * p))
