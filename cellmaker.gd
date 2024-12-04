extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var Movement = Vector3()
var x = randi() % 20 - 10
var y = randi() % 20 - 10
var z = randi() % 20 - 10

# Called when the node enters the scene tree for the first time.
func _ready():
	self.translation.x = x
	self.translation.y = y
	self.translation.z = z
	self.rotate_y(PI/2)
	self.rotate_z(PI/2)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#Movement = Vector3(0,0,0)
	#add_force(Movement, Vector3(1,0,0))
	pass


func _on_DivTimer_timeout():

	pass # Replace with function body.
