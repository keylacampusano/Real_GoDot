extends CharacterBody2D

var SPEED = 20000.0
var JUMP_VELOCITY = -450.0
var rotacion = 500

var isOrbe = false
var fuerzaorbe = 0
var canInvert = false
var isUfo = false

var gravity = 5000

var neural_network = NeuralNetwork.new(3, 5, 1)


func _ready() -> void:
	$RayCast2D.enabled = true

func _physics_process(delta: float) -> void:
	var sensor_data = get_sensor_info()
	var action = neural_network.predict(sensor_data)
	print("Sensor Data: ", sensor_data) # Print sensor data for debugging 
	print("Neural Network Output: ", action)

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		$Sprite2D.rotation_degrees += 380 * delta
	else:
		var modulo = int($Sprite2D.rotation_degrees) % 90
		if modulo > 45:
			$Sprite2D.rotation_degrees += (90 - modulo)
		else:
			$Sprite2D.rotation_degrees -= modulo
	
	if action:
		if isUfo or is_on_floor():
			velocity.y = JUMP_VELOCITY
	# controla que el jugador se mueva solo a la derecha
	velocity.x = SPEED * delta
	
	if isOrbe and action:
		velocity.y = -fuerzaorbe
		if canInvert:
			gravity = -gravity
			JUMP_VELOCITY = -JUMP_VELOCITY
			rotacion = -rotacion
			isOrbe = false
	print("Velocity: ", velocity)
	move_and_slide()
	print("Position: ", position)
	
func _draw() -> void:
	var ray_cast = $RayCast2D
	if ray_cast.is_colliding():
		draw_line(position, ray_cast.get_collision_point(), Color(1, 0, 0), 2)
	
func get_sensor_info() -> Dictionary:
	var sensor_data = {
		"Distance_to_Obstacle": check_distance_to_obstacle(),
		"is_colliding_with_orb": is_colliding_with_orb(),
		"Current_Speed": velocity.length()
	}
	
	print("Sensor Data: ", sensor_data)
	return sensor_data

func check_distance_to_obstacle() -> float:
	var ray_cast  = $RayCast2D
	if ray_cast.is_colliding():
		return position.distance_to(ray_cast.get_collision_point())
	else:
		return 100.0 #if the obstacle is not detected return a bigger distance
	
	
func is_colliding_with_orb() -> bool:
	var orbs = get_tree().get_nodes_in_group("orbe")
	for orb in orbs:
		if position.distance_to(orb.position) < 20:
			return true
	return false

func death():
	SPEED = 0
	$Sprite2D.visible = false
	$AudioStreamPlayer2D.play()
	$Timer.start()

func _on_timer_timeout():
	get_tree().reload_current_scene()

func _on_externo_area_entered(area: Area2D) -> void:
	if area.is_in_group("orbe"):
		isOrbe = true
		fuerzaorbe = area.fuerza
		canInvert = area.invertir
		
	
	if area.is_in_group("trampolines") :
		velocity.y = -area.fuerza
		if area.invertir == true :
			gravity = -gravity
			JUMP_VELOCITY = -JUMP_VELOCITY
			rotacion = -rotacion
	if area.is_in_group("portal") :
		match area.tipo :
			0 :
				$Sprite2D.texture = load("res://imagenes/Ball001.png")
				isUfo = false
			1:
				$Sprite2D.texture = load("res://imagenes/Cube001.png")
				isUfo= false
			2:
				$Sprite2D.texture = load("res://imagenes/Ship001.png")
				isUfo = false
			3:
				$Sprite2D.texture = load("res://imagenes/UFO001.png")
				isUfo = true
				JUMP_VELOCITY = -800
			4:
				$Sprite2D.texture = load("res://imagenes/Wave001.png")
				isUfo = false
				JUMP_VELOCITY = -1200

func _on_externo_area_exited(area: Area2D) -> void:
	if area.is_in_group("orbe"):
			isOrbe = false
			fuerzaorbe = 0
			canInvert = false
			
			
			
