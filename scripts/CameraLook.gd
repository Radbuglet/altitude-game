extends Camera

var x_rot = 0
var y_rot = 0
var total_sensitivity = -0.5
var x_sensitivity = 0.75
var y_sensitivity = 1
var has_control = false

func _init():
	pass

func set_has_control(b):
	has_control = b

func get_x_rot():
	return x_rot

func get_y_rot():
	return y_rot

func _input(event):
	if has_control:
		if event is InputEventMouseMotion:
			x_rot += event.relative.x * x_sensitivity * total_sensitivity
			y_rot += event.relative.y * y_sensitivity * total_sensitivity
			
			y_rot = clamp(y_rot, -90, 90)
			
			self.force_rotate_camera()

func force_rotate_camera():
	transform.basis = Basis()
	rotate_object_local(Vector3(0, 1, 0), deg2rad(x_rot))
	rotate_object_local(Vector3(1, 0, 0), deg2rad(y_rot))