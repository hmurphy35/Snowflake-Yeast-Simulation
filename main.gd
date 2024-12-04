extends Node

export(PackedScene) var cell_scene
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const my_script = preload("res://cellmaker.gd")
var radius: float = 0.5
var ar: float = 3.0
var length = 2*radius*(ar-1)


var basis = Basis()
var put_on_z: Vector3 = Vector3(0,1,0)
var t_axis: Vector3 = Vector3(0,01,0)
var p_axis: Vector3 = Vector3(0,0,01)

#var my_seed = "Peter Yunker".hash() 

#Take two arrays of the same size, subtract them element-wise
func subtraction(a,b):
	var c = []
	for i in range(len(a)):
		c.append(a[i] - b[i])
	return c

#Given a vector, return the length of that vector
func length(a):
	var c = 0
	for i in a:
		c += i * i
	return sqrt(c)

#Given spherical coordinates, return the equivalent cartesian coordinates
func sph_to_xyz(r, theta, phi):
	var x = r * sin(theta) * cos(phi)
	var y = r * sin(theta) * sin(phi)
	var z = r * cos(theta)
	return [x, y, z]

#Given a radius to the center of capsules (should be l/2), number of candidates to generate, 
# min separation (radius of cell), and max attempts
# generate a list of candidate angles. 
# Returns a list of 2-angle arrays
func hemi_cands(rad = (length/2), num = 3, mindist = radius, maxattempts = 20):
	#Generate some blank arrays and an attempt counter. Only angle_array is returned, but pos_array is useful for verifying the minimum separation
	var pos_array = []
	var angle_array = []
	var failcount = 0
	
	#Randomly generate the angles
	var i_theta = rand_range(0, PI/2)
	var i_phi = rand_range(0, 2*PI)
	
	#Plug the angles into some arrays and put them in storage
	var i_ang = [i_theta, i_phi]
	var i_pos = sph_to_xyz(radius, i_theta, i_phi)
	angle_array.append(i_ang)
	pos_array.append(i_pos)
	
	#The core loop that generates candidates
	while len(angle_array) < num:
		#Seeded randomness probably won't work here with how many different points need generated
		#Generate random candidate points and then find the distance between it and the reference 
		var theta = rand_range(0, PI/2)
		var phi = rand_range(0, 2*PI)
		var pos = sph_to_xyz(radius, theta, phi)
		var ang = [theta, phi]
		
		var valid: bool = true
		for j in pos_array:
			var c = subtraction(pos,j)
			if length(c) < mindist:
				valid = false
				failcount += 1
				break
		if failcount >= maxattempts:
			return angle_array
		if valid:
			failcount = 0
			angle_array.append(ang)
	
	return angle_array

#Given two lists, each containing 2-angle arrays, pack them into one list. 
# Root first, then children
func angle_packer(root, child):
	var packed = []
	packed.append_array(root)
	packed.append_array(child)
	return packed

#Take a list and repackage it. I don't know if gdscript does similarly funky things to lists as python does, but just in case.
func repacker(l):
	var gene = []
	for i in l:
		gene.append(i)
	return gene

#Given a list of angles (including the initial one), initial pos, and a length, 
# return the cell center position associated with those initial values
func thangler(angs, zpos, l):
	var ent = repacker(angs)
	var a = 0
	var b = 0
	var c = 0
	
	#print("ent" + str(ent))
	#Special condition for the root because it's not supposed to really move
	if len(ent) == 1:
		return zpos
	
	#Move by the first cell
	a += zpos[0] + l/2*sin(ent[0][0])*cos(ent[0][1])
	b += zpos[1] + l/2*sin(ent[0][0])*sin(ent[0][1])
	c += zpos[2] + l/2*cos(ent[0][0])
	
	#Move by inner cells
	var pink = repacker(ent)
	#print("initial" + str(pink))
	pink.pop_front()
	pink.pop_back()
	#print(pink)
	for i in pink:
		if len(pink) != 0:
			a += l*sin(i[0])*cos(i[1])
			b += l*sin(i[0])*sin(i[1])
			c += l*cos(i[0])
	
	#Move by the last cell
	a += l/2*sin(ent[-1][0])*cos(ent[-1][1])
	b += l/2*sin(ent[-1][0])*sin(ent[-1][1])
	c += l/2*cos(ent[-1][0])
	
	return [a,b,c]

func angler(angs):
	var x = 0
	var y = 0
	for i in angs:
		x += i[0]
		y += i[1]
	
	return [x,y]


#Take a Rigidbody and give it a randomly translated and rotated mesh/shape
func add_meshes(mother):
	var x = randi() % 20 - 10
	var y = randi() % 20 - 10
	var z = randi() % 20 - 10
	var rotation_amount: float = randi() % 6
	
	var coll = CollisionShape.new()
	coll.shape = CapsuleShape.new()
	coll.shape.set_radius(radius)
	coll.shape.set_height(length)
	coll.transform.origin = Vector3(x,y,z)
	coll.transform.basis = coll.transform.basis.rotated(t_axis.normalized(), rotation_amount)
	coll.transform.basis = coll.transform.basis.rotated(p_axis.normalized(), rotation_amount)
	
	var mesh = MeshInstance.new()
	mesh.mesh = CapsuleMesh.new()
	mesh.mesh.radius = radius
	mesh.mesh.mid_height = length
	mesh.transform.origin = Vector3(x,y,z)
	mesh.transform.basis = mesh.transform.basis.rotated(t_axis.normalized(), rotation_amount)
	mesh.transform.basis = mesh.transform.basis.rotated(p_axis.normalized(), rotation_amount)
	
	mother.add_child(coll)
	mother.add_child(mesh)

#Take a Rigidbody and, given both a position and orientation, generate a mesh/shape
func super_add_meshes(mother, x, y, z, theta, phi):
	
	var coll = CollisionShape.new()
	coll.shape = CapsuleShape.new()
	coll.shape.set_radius(radius)
	coll.shape.set_height(length)
	coll.transform.origin = Vector3(x,y,z)
	#coll.transform.basis = coll.transform.basis.rotated(put_on_z.normalized(), PI/2)
	coll.transform.basis = coll.transform.basis.rotated(t_axis.normalized(), theta)
	coll.transform.basis = coll.transform.basis.rotated(p_axis.normalized(), phi)
	
	var mesh = MeshInstance.new()
	mesh.mesh = CapsuleMesh.new()
	mesh.mesh.radius = radius
	mesh.mesh.mid_height = length
	mesh.transform.origin = Vector3(x,y,z)
	#mesh.transform.basis = mesh.transform.basis.rotated(put_on_z.normalized(), PI/2)
	mesh.transform.basis = mesh.transform.basis.rotated(t_axis.normalized(), theta)
	mesh.transform.basis = mesh.transform.basis.rotated(p_axis.normalized(), phi)
	
	mother.add_child(coll)
	mother.add_child(mesh)


func mesh_monster(mother, zpos, max_children, group_size, mindist):
	for i in range(group_size):
		buffer.shuffle()
		#print("buffer " + str(buffer))
		var meek = buffer[0]
		#print("meek" + str(meek))
		universal_angle_buffer.append(meek)
		
		var center = thangler(meek, zpos, length)
		#This needs worked on later. When plotting, the angles aren't accumulating like they're supposed tp
#		var ank = angler(meek)
#		super_add_meshes(mother, center[0], center[1], center[2], ank[0], ank[1])
		super_add_meshes(mother, center[0], center[1], center[2], meek[-1][0], meek[-1][1])
		print(meek)
		
		var samuel = hemi_cands(length/2, max_children, mindist, 30)
		for j in samuel:
			var mid = []
			mid.append_array(meek)
			mid.append(j)
			buffer.append(mid)
			#print(buffer)
		
		buffer.pop_front()
	pass
	


var mother = RigidBody.new()
var greg = RigidBody.new()
var zpos = [0,0,0]
var buffer = []
var universal_angle_buffer = []

# Called when the node enters the scene tree for the first time.
func _ready():
	mother.transform.origin = Vector3(0,0,0)
	mother.set_gravity_scale(0)
	mother.set_script(my_script)
	self.add_child(mother)
	#add_meshes(mother)
#	super_add_meshes(mother, 0, 0, 0, 0, 0)
#	super_add_meshes(mother, 0, 0, length/2, PI/2, 0)
#	var egg = thangler([[0,0], [0,0]], [0,0,0], length/2)
#	super_add_meshes(mother, egg[0], egg[1], egg[2], 0, 0)
	
#	super_add_meshes(mother, 0, 0, 0, 1.09258314, 3.57724729)
#	super_add_meshes(mother, -0.38983034343240586, 0.3632043468777584, 0.99243074062713, 1.00955537, 1.05839627)
#	super_add_meshes(mother, -0.7086401394260793, -0.493435906592708, 1.4484388418047804, 0.15347837, 5.39342559)
#	super_add_meshes(mother, -1.5702386465686333, -0.08272468887731865, 1.033791860962845, 0.95990438, 2.77718327)
##
#	greg.transform.origin = Vector3(0,0,0)
#	greg.set_gravity_scale(0.1)
#	greg.set_script(my_script)
#	self.add_child(greg)
#	super_add_meshes(greg, -7, -8.5, 5, PI/2 ,0)

#	print("length " + str(length))
#
#	var init_angles = hemi_cands(length/2, 1, radius, 4)
#	#print(init_angles)
#	universal_angle_buffer.append(init_angles)
#	print(universal_angle_buffer)
#	var init_pos = [0, 0, 0]
#	var jeff = hemi_cands(length/2, 3, radius, 20)
#	#print(jeff)
#	for i in jeff:
#		var mid = []
#		mid.append_array(init_angles)
#		mid.append(i)
#		universal_angle_buffer.append(mid)
#	print(universal_angle_buffer)
#	for i in universal_angle_buffer:
#		var center = thangler(i, init_pos, length)
#		print(center)
#		super_add_meshes(mother, center[0], center[1], center[2], i[-1][0], i[-1][1])
	randomize()

	var init_angles = hemi_cands(length/2, 1, radius, 3)
	buffer.append(init_angles)
#
func _on_Timer_timeout():
	mesh_monster(mother, zpos, 3, 2, radius)
	pass
