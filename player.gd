extends CharacterBody2D

@onready var weapon = $weapon.get_child(0)

@export var MOVE_SPEED = 300.0
@export var DODGE_MULTIPLIER = 2
var SPEED_M = 1

var MAX_ST = 100
var CUR_ST = 100

var is_dodging = false
var is_attacking = false
var can_recover = true

var weapon_angle = 0

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	# MOVEMENT CODE
	$UI/ST.value = CUR_ST
	if Input.is_action_just_pressed("dodge") and not is_dodging and not is_attacking and velocity != Vector2.ZERO and CUR_ST > 0:
		$DodgeTimer.start()
		is_dodging = true
		can_recover = false
		SPEED_M = DODGE_MULTIPLIER
		CUR_ST -= 25
		if CUR_ST < 0:
			CUR_ST = 0
	if not is_dodging and not is_attacking:
		SPEED_M = 1
		velocity = Vector2.ZERO
		if Input.is_action_pressed("up"):
			velocity.y = -MOVE_SPEED
		if Input.is_action_pressed("down"):
			velocity.y = MOVE_SPEED
		if Input.is_action_pressed("left"):
			velocity.x = -MOVE_SPEED
		if Input.is_action_pressed("right"):
			velocity.x = MOVE_SPEED
	if Input.is_action_just_pressed("light") and not is_dodging and CUR_ST > 0:
		set_collision_mask
		can_recover = false
		weapon.visible = true
		is_attacking = true
		$LightTimer.start()
		await get_tree().process_frame
		weapon_angle = -80
		CUR_ST -= 35
		if CUR_ST < 0:
			CUR_ST = 0
	if is_attacking:
		velocity = Vector2.ZERO
		weapon_angle += 1/$LightTimer.wait_time * 160 * delta
		weapon.rotation = deg_to_rad(weapon_angle)
	if can_recover and CUR_ST < MAX_ST:
		CUR_ST += 30 * delta
		if CUR_ST > MAX_ST:
			CUR_ST = MAX_ST
	
	var collision = move_and_collide(velocity * SPEED_M * delta)


func _on_dodge_timer_timeout():
	$STTimer.start()
	is_dodging = false


func _on_st_timer_timeout():
	can_recover = true


func _on_light_timer_timeout():
	$STTimer.start()
	is_attacking = false
	weapon.visible = false
