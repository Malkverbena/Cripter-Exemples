extends Node


"""
Most of Cripter's methods are static, so they do not require an instance to be created.
"""


@export var test_iv : bool = true
@export var show_available_curves : bool = true


func _ready() -> void:
	if test_iv: iv_test()
	if show_available_curves: show_curves()
	
	get_tree().quit()




func iv_test() -> void:
	print("\n\n=============== iv_test =================")
	var iv : PackedByteArray
	for n in range(1, 10):
		iv = Cripter.generate_iv(n, "Test")
		assert(iv.size() == n, "Wong iv size")
		print(iv)



func  show_curves() -> void:
	print("\n\n=============== Curves =================")
	print("Available Curves: ")
	var curves :=  Cripter.get_available_curves()
	for curve in curves:
		print("    ", curve)
