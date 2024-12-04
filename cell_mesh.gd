class_name Daughter


# Declare member variables here. Examples:
var radius: float = 0.5
var ar: float = 2.5
var max_children: int
var length = 2*radius*(ar-1)

var basis = Basis()
var axis: Vector3
var rotation_amount: float

# Called when the node enters the scene tree for the first time.
func _ready():
	var coll = CollisionShape.new()
	coll.shape = CapsuleShape.new()
	coll.radius = radius
	coll.height = length
	
	var mesh = MeshInstance.new()
	mesh.mesh = CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = length
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
