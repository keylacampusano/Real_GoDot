extends Node

class_name NeuralNetwork

var input_size: int
var hidden_size: int
var output_size: int
var weights_input_hidden: PackedFloat32Array
var weights_hidden_output: PackedFloat32Array

func _init(_input_size, _hidden_size, _output_size):
	input_size = _input_size
	hidden_size = _hidden_size
	output_size = _output_size
	weights_input_hidden = PackedFloat32Array()
	weights_hidden_output = PackedFloat32Array()
	_initialize_weights()
	
func _initialize_weights():
	var random = RandomNumberGenerator.new()
	random.randomize()
	
	for i in range(input_size * hidden_size):
		weights_input_hidden.append(random.randf_range(-1.0, 1.0))
	
	for i in range(hidden_size * output_size):
		weights_hidden_output.append(random.randf_range(-1.0, 1.0))

func sigmoid(x):
	return 1.0 / (1.0 + exp(-x))

func forward(input_array: PackedFloat32Array) -> float:
	var hidden_layer = PackedFloat32Array()
	for i in range(hidden_size):
		var sum = 0.0
		for j in range(input_size):
			sum += input_array[j] * weights_input_hidden[j + i * input_size]
		hidden_layer.append(sigmoid(sum))
		
	var output = 0.0
	for i in range(output_size):
		var sum = 0.0
		for j in range(hidden_size):
			sum += hidden_layer[j] * weights_hidden_output[j + i * hidden_size]
		output = sigmoid(sum)
	
	return output > 0.5

func predict(sensor_data: Dictionary) -> bool:
	var input_array = PackedFloat32Array([sensor_data["Distance_to_Obstacle"], (1.0 if sensor_data["is_colliding_with_orb"] else 0.0), sensor_data["Current_Speed"]])
	return forward(input_array)
		
		
	
	
