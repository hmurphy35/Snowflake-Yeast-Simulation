extends Node

func len(a):
	return sqrt(a.dot(a))

func circle_candidates(radius, number, mindist):
	var pos_array = []
	for i in range(number):
		var valid: bool
		var radial = rand_range(0,2*PI)
		var pos = Vector2(cos(radial)*radius, sin(radial)*radius)
		if pos_array.empty():
			continue
		for j in pos_array:
			if len(pos-j) > mindist:
				pos_array.append(pos)
	
