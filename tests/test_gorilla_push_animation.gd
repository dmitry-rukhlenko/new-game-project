extends SceneTree


const MAIN_SCENE = preload("res://main.tscn")


var failed := false


func _initialize():
	var main = MAIN_SCENE.instantiate()

	root.add_child(main)

	# The script runner does not enter the normal game loop before this test runs,
	# so the scene is initialized explicitly before we test the gorilla animation.
	main._ready()

	main.current_character = main.PLAYER_2
	main.setup_character()

	var center = main.player.position

	_assert_animation_rule(
		main.get_gorilla_push_texture_path(center + Vector2(-72, 0)).ends_with("gorilla_push_left.png"),
		"A wall on the left should use the left-push gorilla frame."
	)

	_assert_animation_rule(
		main.get_gorilla_push_texture_path(center + Vector2(72, 0)).ends_with("gorilla_push_right.png"),
		"A wall on the right should use the right-push gorilla frame."
	)

	_assert_animation_rule(
		main.get_gorilla_push_texture_path(center + Vector2(0, -72)).ends_with("gorilla_push_up.png"),
		"A wall above should use the up-push gorilla frame."
	)

	_assert_animation_rule(
		main.get_gorilla_push_texture_path(center + Vector2(0, 72)).ends_with("gorilla_push_down.png"),
		"A wall below should use the down-push gorilla frame."
	)

	main.play_gorilla_push_animation(
		center + Vector2(72, 0),
		false
	)

	_assert_animation_rule(
		main.player.texture.resource_path.ends_with("gorilla_push_right.png"),
		"The gorilla should immediately switch to the matching push frame."
	)

	_assert_animation_rule(
		main.GORILLA_PUSH_ANIMATION_SECONDS == 0.5,
		"The gorilla push animation should still last half a second overall."
	)

	_assert_animation_rule(
		main.GORILLA_PUSH_PRE_COLLISION_SECONDS == 0.3,
		"The gorilla push animation should start 0.3 seconds before the hit."
	)

	_assert_animation_rule(
		main.GORILLA_PUSH_POST_COLLISION_SECONDS == 0.2,
		"The gorilla push animation should stay visible 0.2 seconds after the hit."
	)

	main.walls.clear()
	main.walls.append(
		_create_wall_at(
			center + Vector2(72, 0)
		)
	)
	main.velocity = Vector2(10.0, 0.0)

	var predicted_wall_position = main.get_predicted_gorilla_wall_hit(
		1.0 / 60.0
	)

	_assert_animation_rule(
		predicted_wall_position == center + Vector2(72, 0),
		"The gorilla should predict a wall hit inside the 0.3 second pre-animation window."
	)

	main.queue_free()
	quit(1 if failed else 0)


func _create_wall_at(position: Vector2) -> Sprite2D:
	var wall = Sprite2D.new()

	wall.position = position

	return wall


func _assert_animation_rule(condition: bool, message: String):
	if condition:
		return

	failed = true
	push_error(message)
