extends Node

class_name Genetic_Alg

var n_bots = 10
var n_generations = 0
var bots = []
var best_w_input_hidden = PackedFloat32Array()
var best_w_hidden_output = PackedFloat32Array()
var neural_network = NeuralNetwork

func _ready() -> void:
	init_gen(n_bots)

# iniciamos los bots
func init_gen(_n):
	neural_network = neural_network.new(3, 5, 1)
	for i in range(_n):
		var bot = create_bot()
		bots.append(bot)
		
# se crea un bot
func create_bot():
	var bot = Genetic_Alg.new()
	bot.position = Vector2(randf_range(-16, 16), 0)  
	add_child(bot)
	return bot

# proxima generacion
func next_gen():
	for bot in bots:
		bot.queue_free()
	bots.clear()

	# se crea el mejor bot de nueva
	var best_bot = create_bot()
	best_bot.neural_network.weights_input_hidden = best_w_input_hidden.duplicate()
	best_bot.neural_network.weights_hidden_output = best_w_hidden_output.duplicate()

	# inicializamos nuevos bots
	init_gen(n_bots)

 # mutamos los nuevos bots
	for i in range(1, n_bots):  
		var bot = bots[i]
		bot.neural_network.weights_input_hidden = mutate_weights(best_w_input_hidden, 25, -0.1, 0.1)
		bot.neural_network.weights_hidden_output = mutate_weights(best_w_hidden_output, 25, -0.1, 0.1)

	bots[0] = best_bot
	n_generations += 1

# mutamos la matriz de pesos
func mutate_weights(weights: PackedFloat32Array, prob: float, minv: float, maxv: float) -> PackedFloat32Array:
	var random = RandomNumberGenerator.new()
	random.randomize()
	var mutated_weights = PackedFloat32Array(weights)
	for i in range(mutated_weights.size()):
		if random.randf() * 100 < prob:
			mutated_weights[i] += random.randf_range(minv, maxv)
	return mutated_weights
