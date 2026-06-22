extends Node2D

const CELL = 72

const COLS = 10
const ROWS = 8

const FIELD_WIDTH = 720.0
const FIELD_HEIGHT = 576.0

# Границы между скалами

const LEFT_BORDER = 602.0
const RIGHT_BORDER = 1322.0

const TOP_BORDER = 193.0
const BOTTOM_BORDER = 1040.0

const PLAYER_START_X = 962.0
const PLAYER_START_Y = 850.0

const RESTART_X = 1132.0
const RESTART_Y = 950.0

# Игра

const START_MOVES = 10
const TARGET_KILLS = 10

const PLAYER_1 = 1
const PLAYER_2 = 2
const PLAYER_3 = 3
const PLAYER_5 = 5
const PLAYER_7 = 7
const PLAYER_8 = 8
const PLAYER_9 = 9
const PLAYER_10 = 10


const LEVEL_0 = 0
const LEVEL_1 = 1
const LEVEL_2 = 2
const LEVEL_3 = 3
const LEVEL_1S = 11
const LEVEL_2S = 12
const LEVEL_3S = 13
# Физика как в CodePen

const SHOT_POWER = 0.18
const FRICTION = 0.992

const MIN_SPEED = 0.08

const MAX_PULL = 180.0

const GORILLA_PUSH_POWER = 1.0

const GORILLA_PUSH_PRE_COLLISION_SECONDS = 0.3

const GORILLA_PUSH_POST_COLLISION_SECONDS = 0.2

const GORILLA_PUSH_ANIMATION_SECONDS = (
	GORILLA_PUSH_PRE_COLLISION_SECONDS +
	GORILLA_PUSH_POST_COLLISION_SECONDS
)
# Траектория

const TRAJECTORY_POINTS = 12
const TRAJECTORY_STEP = 5.0

# Размеры

const PLAYER_SIZE = 52.0
const OBJECT_SIZE = 70.0

const WALK_SPEED = 350.0

const ACORN_SIZE = 52.0
const ACORN_SPEED = 0.85

const WORLD_OFFSET_X = -180.0 

const PEACOCK_MOVES = 1
const PEACOCK_STARS = 8

var rabbit_bounces = 0

var tree = null

var tree_active = false

var bear_tree_turn = true

var last_sparrow_cell = Vector2(
	-1,
	-1
)

var player: Sprite2D

var restart_button: Sprite2D

var background_sprite: Sprite2D

var victory_popup: Node2D

var victory_label: Label

var victory_retry_button: Node2D

var victory_retry_label: Label

var victory_next_button: Node2D

var victory_next_label: Label

var victory_audio_player: AudioStreamPlayer

var victory_sound_requested = false

var defeat_popup: Node2D

var defeat_label: Label

var defeat_retry_button: Node2D

var defeat_retry_label: Label

var dragging := false

var mouse_pos := Vector2.ZERO

var drag_start := Vector2.ZERO

var turn_active = false

var score := 0

var moves := START_MOVES

var game_over := false

var returning := false

var velocity := Vector2.ZERO

var trajectory_dots = []

var penguin_trajectory_dots = []

var move_icons = []

var enemies = []

var stars = []

var traps = []

var crystals = []

var enemy2 = null

var gift = null

var current_character = PLAYER_1

var enemy2_alive = false

var trap_growth_enabled = false

var gorilla_push_animation_id = 0

var current_level = 2

var level_buttons = []

var active_level_outlines = []

var character_buttons = []

var walls = [] 

var wall_velocities = []

var floor_tiles = []

var penguins = []

var penguin_velocities = []

var penguin_alive = []

var active_penguin_index = 0

var snail_trail_cells = []

var snail_trail_tiles = []

var snail_first_launch_recorded = false

var snail_launch_start_position = Vector2(
	PLAYER_START_X,
	PLAYER_START_Y
)

var acorns = [] 

var acorn_velocities = []

var acorns_spawned = false

var map_generation_id = 0
func _ready():

	randomize()

	create_background()

	create_player()

	setup_character()

	create_restart_button()

	create_move_icons()

	create_trajectory_dots()

	create_character_buttons()

	create_level_buttons()

	create_victory_popup()

	create_victory_audio_player()

	create_defeat_popup()

	start_new_game()


func create_background():

	background_sprite = Sprite2D.new()

	background_sprite.texture = load(
		get_background_texture_path()
	)

	background_sprite.centered = false

	background_sprite.position = Vector2.ZERO

	add_child(background_sprite)


func get_background_texture_path() -> String:

	if is_winter_level():
		return "res://art/background2.png"

	return "res://art/background.png"


func update_background():

	if background_sprite == null:
		return

	background_sprite.texture = load(
		get_background_texture_path()
	)


func create_player():

	player = Sprite2D.new()

	player.texture = load(
		"res://art/player.png"
	)

	player.position = Vector2(
		PLAYER_START_X,
		PLAYER_START_Y
	)

	player.z_index = 100

	add_child(player)


func create_restart_button():

	restart_button = Sprite2D.new()

	restart_button.texture = load(
		"res://art/restart.png"
	)

	restart_button.position = Vector2(
		RESTART_X,
		RESTART_Y
	)

	restart_button.z_index = 200

	add_child(restart_button)


func create_move_icons():

	for icon in move_icons:

		if is_instance_valid(icon):

			icon.queue_free()

	move_icons.clear()

	for i in range(START_MOVES):

		var icon = Sprite2D.new()

		icon.texture = load(
			"res://art/move.png"
		)

		icon.scale = Vector2(
			0.45,
			0.45
		)

		icon.position = Vector2(
			840 + (i % 5) * 52,
			900 + int(i / 5) * 52
		)

		icon.z_index = 300

		add_child(icon)

		move_icons.append(icon) 


func update_move_icons():

	for icon in move_icons:

		if is_instance_valid(icon):

			icon.queue_free()

	move_icons.clear()

	for i in range(moves):

		var icon = Sprite2D.new()

		icon.texture = load(
			"res://art/move.png"
		)

		icon.scale = Vector2(
			0.45,
			0.45
		)

		icon.position = Vector2(
			840 + (i % 5) * 52,
			926 + int(i / 5) * 52
		)

		icon.z_index = 300

		add_child(icon)

		move_icons.append(icon)


func create_trajectory_dots():

	for i in range(
		TRAJECTORY_POINTS
	):

		var dot = ColorRect.new()

		dot.size = Vector2(
			6,
			6
		)

		dot.color = Color.WHITE

		dot.visible = false

		dot.z_index = 400

		add_child(dot)

		trajectory_dots.append(dot)

		var penguin_dot = ColorRect.new()

		penguin_dot.size = Vector2(
			6,
			6
		)

		penguin_dot.color = Color8(
			128,
			218,
			238
		)

		penguin_dot.visible = false

		penguin_dot.z_index = 400

		add_child(penguin_dot)

		penguin_trajectory_dots.append(penguin_dot)


func hide_trajectory():

	for dot in trajectory_dots:

		dot.visible = false 

	for dot in penguin_trajectory_dots:

		dot.visible = false


func create_victory_popup():

	victory_popup = Node2D.new()

	victory_popup.visible = false

	victory_popup.z_index = 1000

	add_child(victory_popup)

	var dimmer = ColorRect.new()

	dimmer.color = Color(
		0,
		0,
		0,
		0.45
	)

	dimmer.size = Vector2(
		1920,
		1080
	)

	dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE

	victory_popup.add_child(dimmer)

	var panel = Node2D.new()

	panel.position = Vector2(
		960,
		900
	)

	victory_popup.add_child(panel)

	var border_texture = load("res://art/wall.png")

	var center_texture = load("res://art/floor2.png")

	for y in range(4):

		for x in range(8):

			var tile = Sprite2D.new()

			var is_border_tile = (
				x == 0
				or
				x == 7
				or
				y == 0
				or
				y == 3
			)

			if is_border_tile:

				tile.texture = border_texture

			else:

				tile.texture = center_texture

			tile.position = Vector2(
				(x - 3.5) * CELL,
				(y - 1.5) * CELL
			)

			panel.add_child(tile)

	victory_label = Label.new()

	victory_label.name = "VictoryText"

	victory_label.text = "Победа"

	victory_label.size = Vector2(
		6 * CELL,
		1.25 * CELL
	)

	victory_label.position = Vector2(
		-3 * CELL,
		-1.65 * CELL
	)

	victory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	victory_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	victory_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	victory_label.add_theme_font_size_override(
		"font_size",
		56
	)

	victory_label.add_theme_color_override(
		"font_color",
		Color(
			0.92,
			0.84,
			0.78
		)
	)

	# The popup is built from the same tile sprites as the game field so it
	# reads as an in-world result screen instead of a system dialog.
	panel.add_child(victory_label)

	create_victory_result_buttons()


func create_victory_audio_player():

	victory_audio_player = AudioStreamPlayer.new()

	victory_audio_player.stream = load("res://art/sfx/victory.mp3")

	victory_audio_player.volume_db = -3.0

	add_child(victory_audio_player)


func play_victory_sound():

	victory_sound_requested = true

	if (
		victory_audio_player == null
		or
		victory_audio_player.stream == null
	):
		return

	if not victory_audio_player.is_inside_tree():
		return

	victory_audio_player.stop()

	victory_audio_player.play()


func create_victory_result_buttons():

	victory_retry_button = create_result_button(
		victory_popup,
		Vector2(820, 965),
		"res://art/ui/button_retry.png",
		"Играть снова",
		25
	)

	victory_retry_label = (
		victory_retry_button.get_node("ButtonText")
		as Label
	)

	victory_next_button = create_result_button(
		victory_popup,
		Vector2(1090, 965),
		"res://art/ui/button_next.png",
		"Следующий уровень",
		22
	)

	victory_next_label = (
		victory_next_button.get_node("ButtonText")
		as Label
	)


func create_result_button(
	parent: Node,
	button_position: Vector2,
	texture_path: String,
	text: String,
	font_size: int
) -> Node2D:

	var button = Node2D.new()

	button.position = button_position

	parent.add_child(button)

	var button_sprite = Sprite2D.new()

	button_sprite.texture = load(texture_path)

	button.add_child(button_sprite)

	var label = Label.new()

	label.name = "ButtonText"

	label.text = text

	label.size = Vector2(
		button_sprite.texture.get_width(),
		CELL
	)

	label.position = Vector2(
		-button_sprite.texture.get_width() / 2.0,
		-CELL / 2.0
	)

	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	label.add_theme_font_size_override(
		"font_size",
		font_size
	)

	label.add_theme_color_override(
		"font_color",
		Color(
			0.92,
			0.84,
			0.78
		)
	)

	# Result buttons use generated single-slab stone sprites so they feel like
	# solid game UI controls instead of repeated map tiles.
	button.add_child(label)

	return button


func create_defeat_popup():

	defeat_popup = Node2D.new()

	defeat_popup.visible = false

	defeat_popup.z_index = 1000

	add_child(defeat_popup)

	var dimmer = ColorRect.new()

	dimmer.color = Color(
		0,
		0,
		0,
		0.45
	)

	dimmer.size = Vector2(
		1920,
		1080
	)

	dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE

	defeat_popup.add_child(dimmer)

	var panel = Node2D.new()

	panel.position = Vector2(
		960,
		900
	)

	defeat_popup.add_child(panel)

	var border_texture = load("res://art/wall.png")

	var center_texture = load("res://art/floor2.png")

	for y in range(4):

		for x in range(8):

			var tile = Sprite2D.new()

			var is_border_tile = (
				x == 0
				or
				x == 7
				or
				y == 0
				or
				y == 3
			)

			if is_border_tile:

				tile.texture = border_texture

			else:

				tile.texture = center_texture

			tile.position = Vector2(
				(x - 3.5) * CELL,
				(y - 1.5) * CELL
			)

			panel.add_child(tile)

	defeat_label = Label.new()

	defeat_label.name = "DefeatText"

	defeat_label.text = "Поражение"

	defeat_label.size = Vector2(
		6 * CELL,
		2 * CELL
	)

	defeat_label.position = Vector2(
		-3 * CELL,
		-CELL
	)

	defeat_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	defeat_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	defeat_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	defeat_label.add_theme_font_size_override(
		"font_size",
		60
	)

	defeat_label.add_theme_color_override(
		"font_color",
		Color(
			0.92,
			0.84,
			0.78
		)
	)

	panel.add_child(defeat_label)

	create_defeat_retry_button()


func create_defeat_retry_button():

	defeat_retry_button = Node2D.new()

	defeat_retry_button.position = Vector2(
		960,
		985
	)

	defeat_popup.add_child(defeat_retry_button)

	var button_sprite = Sprite2D.new()

	button_sprite.texture = load("res://art/ui/button_retry.png")

	defeat_retry_button.add_child(button_sprite)

	defeat_retry_label = Label.new()

	defeat_retry_label.name = "RetryText"

	defeat_retry_label.text = "Играть снова"

	defeat_retry_label.size = Vector2(
		button_sprite.texture.get_width(),
		CELL
	)

	defeat_retry_label.position = Vector2(
		-button_sprite.texture.get_width() / 2.0,
		-CELL / 2.0
	)

	defeat_retry_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	defeat_retry_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	defeat_retry_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	defeat_retry_label.add_theme_font_size_override(
		"font_size",
		34
	)

	defeat_retry_label.add_theme_color_override(
		"font_color",
		Color(
			0.92,
			0.84,
			0.78
		)
	)

	# The retry button uses the same generated single-slab stone sprite as the
	# victory controls, so result actions stay visually consistent.
	defeat_retry_button.add_child(defeat_retry_label)


func show_victory_popup():

	if victory_popup == null:
		return

	victory_popup.visible = true

	play_victory_sound()


func hide_victory_popup():

	if victory_popup == null:
		return

	victory_popup.visible = false


func show_defeat_popup():

	if defeat_popup == null:
		return

	defeat_popup.visible = true


func hide_defeat_popup():

	if defeat_popup == null:
		return

	defeat_popup.visible = false


func handle_defeat_retry_click(click_position: Vector2) -> bool:

	if (
		defeat_popup == null
		or
		not defeat_popup.visible
		or
		defeat_retry_button == null
	):
		return false

	if not is_result_button_click(
		defeat_retry_button,
		click_position
	):
		return false

	start_new_game()

	return true


func handle_victory_retry_click(click_position: Vector2) -> bool:

	if (
		victory_popup == null
		or
		not victory_popup.visible
		or
		victory_retry_button == null
	):
		return false

	if not is_result_button_click(
		victory_retry_button,
		click_position
	):
		return false

	start_new_game()

	return true


func handle_victory_next_click(click_position: Vector2) -> bool:

	if (
		victory_popup == null
		or
		not victory_popup.visible
		or
		victory_next_button == null
	):
		return false

	if not is_result_button_click(
		victory_next_button,
		click_position
	):
		return false

	current_level = get_next_level()

	start_new_game()

	return true


func is_result_button_click(
	button: Node2D,
	click_position: Vector2
) -> bool:

	var button_sprite = button.get_child(0) as Sprite2D

	if button_sprite == null or button_sprite.texture == null:
		return false

	var button_half_size = Vector2(
		button_sprite.texture.get_width() / 2.0,
		button_sprite.texture.get_height() / 2.0
	)

	return (
		click_position.x >= button.position.x - button_half_size.x
		and
		click_position.x <= button.position.x + button_half_size.x
		and
		click_position.y >= button.position.y - button_half_size.y
		and
		click_position.y <= button.position.y + button_half_size.y
	)


func get_character_ids() -> Array:

	return [
		PLAYER_1,
		PLAYER_2,
		PLAYER_3,
		PLAYER_5,
		PLAYER_7,
		PLAYER_8,
		PLAYER_9,
		PLAYER_10
	]


func get_level_ids() -> Array:

	return [
		LEVEL_0,
		LEVEL_1,
		LEVEL_2,
		LEVEL_3,
		LEVEL_1S,
		LEVEL_2S,
		LEVEL_3S
	]


func is_winter_level() -> bool:

	return (
		current_level == LEVEL_1S
		or
		current_level == LEVEL_2S
		or
		current_level == LEVEL_3S
	)


func is_level_3s() -> bool:

	return current_level == LEVEL_3S


func handle_character_button_click(click_position: Vector2) -> bool:

	var character_ids = get_character_ids()

	for i in range(
		character_buttons.size()
	):

		var button = (
			character_buttons[i]
		)

		if button == null:
			continue

		if click_position.distance_to(
			button.position
		) >= 40:
			continue

		current_character = (
			character_ids[i]
		)

		setup_character()

		# Switching characters is a full restart of the current level. This must
		# also work while the old character is moving, because the player uses
		# the character buttons as a quick way to redraw the level with a new hero.
		start_new_game()

		return true

	return false


func handle_level_button_click(click_position: Vector2) -> bool:

	var level_ids = get_level_ids()

	for i in range(
		level_buttons.size()
	):

		var button = (
			level_buttons[i]
		)

		if button == null:
			continue

		if click_position.distance_to(
			button.position
		) >= 40:
			continue

		current_level = level_ids[i]

		# Level switching is also a full restart. It must work while the current
		# character is moving so the player can quickly redraw the map with a
		# different level selected.
		start_new_game()

		return true

	return false


func get_level_target_kills() -> int:

	if current_level == LEVEL_0:
		return 1

	return TARGET_KILLS


func get_next_level() -> int:

	var level_ids = get_level_ids()

	var current_index = level_ids.find(
		current_level
	)

	if (
		current_index >= 0
		and
		current_index < level_ids.size() - 1
	):
		return level_ids[
			current_index + 1
		]

	return LEVEL_3S


func get_level_start_moves() -> int:

	if current_level == LEVEL_0:
		return 1

	if current_character == PLAYER_7:
		return PEACOCK_MOVES

	return START_MOVES


func update_level_button_states():

	for outline in active_level_outlines:

		if is_instance_valid(outline):

			if outline.get_parent() != null:

				outline.get_parent().remove_child(outline)

			outline.queue_free()

	active_level_outlines.clear()

	var level_ids = get_level_ids()

	for i in range(level_buttons.size()):

		var button = level_buttons[i]

		if button == null:
			continue

		if level_ids[i] != current_level:
			continue

		var outline = Line2D.new()

		outline.name = "ActiveLevelOutline"

		outline.width = 5.0

		outline.default_color = Color8(244, 214, 166)

		outline.z_index = 5

		# The selected level keeps its original icon. A light outline, matched to
		# the highlight color from the lightest floor tile, marks the current
		# level without making the button look disabled or pressed.
		outline.points = PackedVector2Array([
			Vector2(-39, -39),
			Vector2(39, -39),
			Vector2(39, 39),
			Vector2(-39, 39),
			Vector2(-39, -39)
		])

		button.add_child(outline)

		active_level_outlines.append(outline)
				
func start_new_game():

	hide_victory_popup()

	hide_defeat_popup()

	update_background()

	map_generation_id += 1

	if tree != null:

		tree.queue_free()

		tree = null

	tree_active = false

	score = 0

	moves = START_MOVES

	game_over = false 
	
	for enemy in enemies:

		if is_instance_valid(enemy):

			enemy.queue_free()

	for wall in walls:

		if is_instance_valid(wall):

			wall.queue_free()

	for star in stars:

		if is_instance_valid(star):

			star.queue_free()

	for trap in traps:

		if is_instance_valid(trap):

			trap.queue_free()

	for crystal in crystals:

		if is_instance_valid(crystal):

			crystal.queue_free()

	if gift != null and is_instance_valid(gift):

		gift.queue_free()

	for tile in floor_tiles:

		if is_instance_valid(tile):

			tile.queue_free()

	for penguin in penguins:

		if is_instance_valid(penguin):

			penguin.queue_free()

	for trail_tile in snail_trail_tiles:

		if is_instance_valid(trail_tile):

			trail_tile.queue_free()

	enemies.clear()

	walls.clear()

	wall_velocities.clear()

	stars.clear()

	traps.clear()

	crystals.clear()

	gift = null

	floor_tiles.clear()

	penguins.clear()

	penguin_velocities.clear()

	penguin_alive.clear()

	active_penguin_index = 0

	snail_trail_cells.clear()

	snail_trail_tiles.clear()

	snail_first_launch_recorded = false

	snail_launch_start_position = Vector2(
		PLAYER_START_X,
		PLAYER_START_Y
	)

	for acorn in acorns:

		if acorn != null:

			acorn.queue_free()

	acorns.clear()

	acorn_velocities.clear()

	acorns_spawned = false
	if enemy2 != null:

		enemy2.queue_free()

		enemy2 = null

	enemy2_alive = false
	
	acorns_spawned = false
	
	score = 0

	moves = get_level_start_moves()

	update_move_icons()

	update_move_icons()

	update_level_button_states()

	velocity = Vector2.ZERO

	game_over = false

	returning = false

	dragging = false

	player.position = Vector2(
		PLAYER_START_X,
		PLAYER_START_Y
	)

	player.visible = (
		current_character != PLAYER_9
	)
	
	if current_character == PLAYER_8:

		place_sparrow()

	if current_character == PLAYER_9:

		create_penguins()
		
		
	create_floor()

	generate_level()
			
	hide_trajectory()


func generate_level():

	var enemy_count = 8

	var wall_count = 4

	var trap_count = 4

	var star_count = 6

	if current_character == PLAYER_7:

		star_count = PEACOCK_STARS

	trap_growth_enabled = false

	if current_level == LEVEL_0:

		# Level 0 is intentionally tiny so it can be used as a quick manual
		# test level while tuning controls, collisions, and character behavior.
		enemy_count = 1

		wall_count = 1

		trap_count = 1

		star_count = 1

	if current_level == LEVEL_1:

		enemy_count = 6

		wall_count = 2

	if current_level == LEVEL_2:

		enemy_count = 8

		wall_count = 4

	if current_level == LEVEL_3:

		enemy_count = 7

		wall_count = 6

		trap_count = 0

		trap_growth_enabled = true

	if current_level == LEVEL_1S:

		enemy_count = 6

		wall_count = 2

	if current_level == LEVEL_2S:

		enemy_count = 8

		wall_count = 4

	if current_level == LEVEL_3S:

		enemy_count = 7

		wall_count = 0

		star_count = 0

	var used_cells = {}

	if current_level == LEVEL_3S:

		create_enemy4_with_crystals(
			used_cells
		)

		create_gift(
			used_cells
		)

	while enemies.size() < enemy_count:

		var x = randi() % COLS

		var y = randi() % ROWS

		var key = "%d_%d" % [x, y]

		if used_cells.has(key):
			continue

		create_enemy(x, y)

		used_cells[key] = true

	while stars.size() < star_count:

		var x = randi() % COLS

		var y = randi() % ROWS

		var key = "%d_%d" % [x, y]

		if used_cells.has(key):
			continue

		create_star(x, y)

		used_cells[key] = true

	while traps.size() < trap_count:

		var x = randi() % COLS

		var y = randi() % ROWS

		var key = "%d_%d" % [x, y]

		if used_cells.has(key):
			continue

		create_trap(x, y)

		used_cells[key] = true

	if is_winter_level() and current_level != LEVEL_3S:

		var wall_rectangles_created = 0

		while wall_rectangles_created < wall_count:

			if create_wall2_rectangle(
				used_cells
			):

				wall_rectangles_created += 1

			else:

				break

	else:

		while walls.size() < wall_count:

			var x = randi() % COLS

			var y = randi() % ROWS

			var key = "%d_%d" % [x, y]

			if used_cells.has(key):
				continue

			create_wall(x, y)

			used_cells[key] = true

	if current_level == LEVEL_3:

		create_enemy2() 


func cell_key(
	x: int,
	y: int
) -> String:

	return "%d_%d" % [
		x,
		y
	]


func cell_for_position(position: Vector2) -> Vector2i:

	return Vector2i(
		int(
			(position.x - LEFT_BORDER) /
			CELL
		),
		int(
			(position.y - TOP_BORDER) /
			CELL
		)
	)


func position_for_cell(cell: Vector2i) -> Vector2:

	return Vector2(
		LEFT_BORDER +
		cell.x * CELL +
		CELL / 2,
		TOP_BORDER +
		cell.y * CELL +
		CELL / 2
	)


func mark_used_cell(
	used_cells: Dictionary,
	cell: Vector2i
):

	used_cells[
		cell_key(
			cell.x,
			cell.y
		)
	] = true


func is_cell_used(
	used_cells: Dictionary,
	cell: Vector2i
) -> bool:

	return used_cells.has(
		cell_key(
			cell.x,
			cell.y
		)
	)


func create_wall2_rectangle(
	used_cells: Dictionary
) -> bool:

	for _attempt in range(300):

		var horizontal = (
			randi() % 2 == 0
		)

		var x = randi() % (
			COLS - 1 if horizontal else COLS
		)

		var y = randi() % (
			ROWS if horizontal else ROWS - 1
		)

		var first_cell = Vector2i(
			x,
			y
		)

		var second_cell = first_cell + (
			Vector2i(1, 0) if horizontal else Vector2i(0, 1)
		)

		var cells = [
			first_cell,
			second_cell
		]

		if not can_place_wall2_rectangle(
			cells,
			used_cells
		):
			continue

		for cell in cells:

			create_wall(
				cell.x,
				cell.y,
				"res://art/wall2.png"
			)

			mark_used_cell(
				used_cells,
				cell
			)

		return true

	return false


func can_place_wall2_rectangle(
	cells: Array,
	used_cells: Dictionary
) -> bool:

	for cell in cells:

		if is_cell_used(
			used_cells,
			cell
		):
			return false

		for wall in walls:

			if wall == null:
				continue

			var wall_cell = cell_for_position(
				wall.position
			)

			var distance = (
				abs(cell.x - wall_cell.x) +
				abs(cell.y - wall_cell.y)
			)

			# A new wall2 rectangle may touch its own second tile, but it must
			# not touch any already placed wall2 rectangle. That keeps the map
			# readable and prevents accidental four-tile blocks.
			if distance == 1:
				return false

	return true


func create_enemy(
	x: int,
	y: int
):

	var enemy = Sprite2D.new()

	enemy.texture = load(
		"res://art/enemy3.png" if is_winter_level() else "res://art/enemy.png"
	)

	enemy.position = Vector2(
		LEFT_BORDER +
		x * CELL +
		CELL / 2,
		TOP_BORDER +
		y * CELL +
		CELL / 2
	)

	enemy.z_index = 50

	add_child(enemy)

	enemies.append(enemy)
	

func create_wall(
	x: int,
	y: int,
	texture_path := "res://art/wall.png"
):

	var wall = Sprite2D.new()

	wall.texture = load(
		texture_path
	)

	wall.position = Vector2(
		LEFT_BORDER +
		x * CELL +
		CELL / 2,
		TOP_BORDER +
		y * CELL +
		CELL / 2
	)

	wall.z_index = 60

	add_child(wall)


	walls.append(wall)

	wall_velocities.append(
		Vector2.ZERO
	)

func create_star(
	x: int,
	y: int
):

	var star = Sprite2D.new()

	star.texture = load(
		"res://art/star.png"
	)

	star.position = Vector2(
		LEFT_BORDER +
		x * CELL +
		CELL / 2,
		TOP_BORDER +
		y * CELL +
		CELL / 2
	)

	star.z_index = 55

	add_child(star)

	stars.append(star)

func create_trap(
	x: int,
	y: int
):

	var trap = Sprite2D.new()

	trap.texture = load(
		"res://art/trap2.png" if is_winter_level() else "res://art/trap.png"
	)

	trap.position = Vector2(
		LEFT_BORDER +
		x * CELL +
		CELL / 2,
		TOP_BORDER +
		y * CELL +
		CELL / 2
	)

	trap.z_index = 55

	add_child(trap)

	traps.append(trap) 
func show_trajectory():

	if player == null:
		return
		
	var pos = (
		get_global_mouse_position()
	)

	if current_character == PLAYER_9:

		var active_penguin = get_active_penguin()

		if active_penguin == null:
			return

		var launch_velocity = get_launch_velocity(
			active_penguin.position,
			pos
		)

		if launch_velocity == Vector2.ZERO:
			return

		draw_trajectory_from(
			penguins[0].position,
			launch_velocity,
			trajectory_dots
		)

		if penguins.size() > 1:

			draw_trajectory_from(
				penguins[1].position,
				launch_velocity,
				penguin_trajectory_dots
			)

		return

	var launch_velocity = get_launch_velocity(
		player.position,
		pos
	)

	if launch_velocity == Vector2.ZERO:
		return

	draw_trajectory_from(
		player.position,
		launch_velocity,
		trajectory_dots
	)


func get_launch_velocity(
	launch_position: Vector2,
	target_position: Vector2
) -> Vector2:

	var dx = (
		launch_position.x -
		target_position.x
	)

	var dy = (
		launch_position.y -
		target_position.y
	)

	var dist = sqrt(
		dx * dx +
		dy * dy
	)

	if dist < 5:
		return Vector2.ZERO

	if dist > MAX_PULL:

		dx *= (
			MAX_PULL / dist
		)

		dy *= (
			MAX_PULL / dist
		)

	return Vector2(
		dx * SHOT_POWER,
		dy * SHOT_POWER
	)


func draw_trajectory_from(
	origin: Vector2,
	initial_velocity: Vector2,
	dots: Array
):

	var tx = origin.x
	var ty = origin.y

	var tvx = initial_velocity.x
	var tvy = initial_velocity.y

	var bounce_count = 0
	var points_after_bounce = 0

	for i in range(
		TRAJECTORY_POINTS
	):

		tx += (
			tvx *
			TRAJECTORY_STEP
		)

		ty += (
			tvy *
			TRAJECTORY_STEP
		)

		var left = (
			LEFT_BORDER +
			PLAYER_SIZE / 2
		)

		var right = (
			RIGHT_BORDER -
			PLAYER_SIZE / 2
		)

		var top = (
			TOP_BORDER +
			PLAYER_SIZE / 2
		)

		var bottom = (
			BOTTOM_BORDER -
			PLAYER_SIZE / 2
		)

		if tx < left:

			tx = left

			tvx *= -0.95

			if bounce_count == 0:
				bounce_count = 1

		if tx > right:

			tx = right

			tvx *= -0.95

			if bounce_count == 0:
				bounce_count = 1

		if ty < top:

			ty = top

			tvy *= -0.95

			if bounce_count == 0:
				bounce_count = 1

		if ty > bottom:

			ty = bottom

			tvy *= -0.95

			if bounce_count == 0:
				bounce_count = 1

		tvx *= FRICTION
		tvy *= FRICTION

		for obstacle in get_solid_obstacles():

			if obstacle == null:
				continue

			if overlap_cell(
				Vector2(tx, ty),
				obstacle.position
			):

				var dx_obstacle = (
					tx -
					obstacle.position.x
				)

				var dy_obstacle = (
					ty -
					obstacle.position.y
				)

				if abs(dx_obstacle) > abs(dy_obstacle):

					tvx *= -1.0

					tx += tvx * 2

				else:

					tvy *= -1.0

					ty += tvy * 2

				if bounce_count == 0:
					bounce_count = 1

		if bounce_count > 0:

			points_after_bounce += 1

			if points_after_bounce > 3:

				for j in range(
					i,
					TRAJECTORY_POINTS
				):
					dots[j].visible = false

				break

		dots[i].position = Vector2(
			tx,
			ty
		)

		dots[i].visible = true


func get_solid_obstacles() -> Array:

	var obstacles = []

	obstacles.append_array(walls)

	obstacles.append_array(crystals)

	return obstacles

func _process(delta):

	if game_over:
		return

	if (
		velocity.length() == 0
		and
		!dragging
		and
		current_character != PLAYER_8
		and
		current_character != PLAYER_9
	):

		if (
			current_character == PLAYER_10
			and
			snail_first_launch_recorded
		):

			handle_snail_trail_input()

		else:

			var move_x = 0.0

			if Input.is_action_pressed("ui_left"):

				move_x -= (
					WALK_SPEED * delta
				)

			if Input.is_action_pressed("ui_right"):

				move_x += (
					WALK_SPEED * delta
				)

			player.position.x += move_x

			var left_limit = (
				LEFT_BORDER +
				PLAYER_SIZE / 2
			)

			var right_limit = (
				RIGHT_BORDER -
				PLAYER_SIZE / 2
			)

			player.position.x = clamp(
				player.position.x,
				left_limit,
				right_limit
			)

	if dragging:

		show_trajectory()

	else:

		hide_trajectory()

		if current_character == PLAYER_9:

			process_penguin_motion()

		elif velocity.length() > 0:

			preview_gorilla_push_animation(
				delta
			)

			player.position += velocity

			velocity *= FRICTION

			check_border_bounce()

			check_wall_bounce()

			if (
				abs(velocity.x) < MIN_SPEED
				and
				abs(velocity.y) < MIN_SPEED
			):

				velocity = Vector2.ZERO

	for i in range(
		acorns.size()
	):

		if i >= acorn_velocities.size():
			continue

		if acorns[i] == null:
			continue

		acorns[i].position += (
			acorn_velocities[i]
		)

		var acorn_left = (
			LEFT_BORDER +
			PLAYER_SIZE / 2
		)

		var acorn_right = (
			RIGHT_BORDER -
			PLAYER_SIZE / 2
		)

		var acorn_top = (
			TOP_BORDER +
			PLAYER_SIZE / 2
		)

		var acorn_bottom = (
			BOTTOM_BORDER -
			PLAYER_SIZE / 2
		)

		if acorns[i].position.x < acorn_left:

			acorns[i].position.x = acorn_left

			acorn_velocities[i].x *= -1.0

		if acorns[i].position.x > acorn_right:

			acorns[i].position.x = acorn_right

			acorn_velocities[i].x *= -1.0

		if acorns[i].position.y < acorn_top:

			acorns[i].position.y = acorn_top

			acorn_velocities[i].y *= -1.0

		if acorns[i].position.y > acorn_bottom:

			acorns[i].position.y = acorn_bottom

			acorn_velocities[i].y *= -1.0

		for wall in walls:

			if wall == null:
				continue

			if overlap_cell(
				acorns[i].position,
				wall.position
			):

				var dx = (
					acorns[i].position.x -
					wall.position.x
				)

				var dy = (
					acorns[i].position.y -
					wall.position.y
				)

				if abs(dx) > abs(dy):

					acorn_velocities[i].x *= -1.0

					acorns[i].position.x += (
						sign(dx) * 8
					)

				else:

					acorn_velocities[i].y *= -1.0

					acorns[i].position.y += (
						sign(dy) * 8
					)

		acorn_velocities[i] *= 0.985

		if acorn_velocities[i].length() < MIN_SPEED:

			acorn_velocities[i] = Vector2.ZERO

	for i in range(
		walls.size()
	):

		if i >= wall_velocities.size():
			continue

		if walls[i] == null:
			continue

		walls[i].position += (
			wall_velocities[i]
		)

		var wall_left = (
			LEFT_BORDER +
			CELL / 2
		)

		var wall_right = (
			RIGHT_BORDER -
			CELL / 2
		)

		var wall_top = (
			TOP_BORDER +
			CELL / 2
		)

		var wall_bottom = (
			BOTTOM_BORDER -
			CELL / 2
		)

		if walls[i].position.x < wall_left:

			walls[i].position.x = wall_left

			wall_velocities[i].x *= -0.7

		if walls[i].position.x > wall_right:

			walls[i].position.x = wall_right

			wall_velocities[i].x *= -0.7

		if walls[i].position.y < wall_top:

			walls[i].position.y = wall_top

			wall_velocities[i].y *= -0.7

		if walls[i].position.y > wall_bottom:

			walls[i].position.y = wall_bottom

			wall_velocities[i].y *= -0.7

		wall_velocities[i] *= 0.96

		if wall_velocities[i].length() < 0.2:

			wall_velocities[i] = Vector2.ZERO

	if not turn_active:
		return

	if current_character == PLAYER_9:

		if not are_penguins_moving():

			turn_active = false

			finish_turn()

	elif current_character == PLAYER_3:

		if velocity == Vector2.ZERO:

			var acorns_moving = false

			for v in acorn_velocities:

				if v.length() > MIN_SPEED:

					acorns_moving = true

					break

			if acorns.size() == 0:

				turn_active = false

				finish_turn()

			elif not acorns_moving:

				turn_active = false

				finish_turn()

	else:

		if velocity == Vector2.ZERO:

			turn_active = false

			finish_turn()
			


func check_border_bounce():

	var left = (
		LEFT_BORDER +
		PLAYER_SIZE / 2
	)

	var right = (
		RIGHT_BORDER -
		PLAYER_SIZE / 2
	)

	var top = (
		TOP_BORDER +
		PLAYER_SIZE / 2
	)

	var bottom = (
		BOTTOM_BORDER -
		PLAYER_SIZE / 2
	)

	if player.position.x < left:

		player.position.x = left

		velocity.x *= -0.8

		if (
			current_character == PLAYER_3
			and
			!acorns_spawned
		):

			create_acorns()

			acorns_spawned = true

	if player.position.x > right:

		player.position.x = right

		velocity.x *= -0.8

		if (
			current_character == PLAYER_3
			and
			!acorns_spawned
		):

			create_acorns()

			acorns_spawned = true

	if player.position.y < top:

		player.position.y = top

		velocity.y *= -0.8

		if (
			current_character == PLAYER_3
			and
			!acorns_spawned
		):

			create_acorns()

			acorns_spawned = true

	if player.position.y > bottom:

		player.position.y = bottom

		velocity.y *= -0.8

		if (
			current_character == PLAYER_3
			and
			!acorns_spawned
		):

			create_acorns()

			acorns_spawned = true

func overlap_cell(
	center: Vector2,
	cell_pos: Vector2
) -> bool:

	return not (

		center.x +
		PLAYER_SIZE / 2 <
		cell_pos.x - CELL / 2

		or

		center.x -
		PLAYER_SIZE / 2 >
		cell_pos.x + CELL / 2

		or

		center.y +
		PLAYER_SIZE / 2 <
		cell_pos.y - CELL / 2

		or

		center.y -
		PLAYER_SIZE / 2 >
		cell_pos.y + CELL / 2
	)


func check_wall_bounce():

	for wall in walls:

		if wall == null:
			continue

		if not overlap_cell(
			player.position,
			wall.position
		):
			continue

		if current_character == PLAYER_2:

			gorilla_hit_wall(
				wall,
				velocity
			)

		if (
			current_character == PLAYER_3
			and
			not acorns_spawned
		):

			create_acorns()

			acorns_spawned = true

		var dx = (
			player.position.x -
			wall.position.x
		)

		var dy = (
			player.position.y -
			wall.position.y
		)

		if abs(dx) > abs(dy):

			velocity.x *= -0.8

			player.position.x += (
				sign(dx) * 4
			)

		else:

			velocity.y *= -0.8

			player.position.y += (
				sign(dy) * 4
			)

	for crystal in crystals:

		if crystal == null:
			continue

		if not overlap_cell(
			player.position,
			crystal.position
		):
			continue

		var dx_crystal = (
			player.position.x -
			crystal.position.x
		)

		var dy_crystal = (
			player.position.y -
			crystal.position.y
		)

		if abs(dx_crystal) > abs(dy_crystal):

			velocity.x *= -0.8

			player.position.x += (
				sign(dx_crystal) * 4
			)

		else:

			velocity.y *= -0.8

			player.position.y += (
				sign(dy_crystal) * 4
			)


func finish_turn():

	if current_character == PLAYER_9:

		finish_penguin_turn()

		return

	if current_character == PLAYER_10:

		record_snail_trail_from_first_launch()

	if is_actor_on_trap(player):

		game_over = true

		show_defeat_popup()

		return

	process_actor_rewards_and_hits(player)

	process_acorn_rewards_and_hits()

	update_move_icons()

	run_end_of_turn_level_effects()

	if are_all_monsters_defeated():

		game_over = true

		show_victory_popup()

		return

	if moves <= 0:

		game_over = true

		show_defeat_popup()

		return

	if (
		current_character != PLAYER_5
		and
		current_character != PLAYER_10
	):

		player.position = Vector2(
			PLAYER_START_X,
			PLAYER_START_Y
		)

	if current_character == PLAYER_8:

		place_sparrow()

	velocity = Vector2.ZERO

	acorns_spawned = false

	clear_acorns()


func finish_penguin_turn():

	for i in range(penguins.size()):

		if not penguin_alive[i]:
			continue

		var penguin = penguins[i]

		if penguin == null:
			continue

		if is_actor_on_trap(penguin):

			penguin_alive[i] = false

			penguin.visible = false

			penguin_velocities[i] = Vector2.ZERO

			continue

		process_actor_rewards_and_hits(penguin)

	update_move_icons()

	run_end_of_turn_level_effects()

	if are_all_monsters_defeated():

		game_over = true

		show_victory_popup()

		return

	if not has_alive_penguin():

		game_over = true

		show_defeat_popup()

		return

	if moves <= 0:

		game_over = true

		show_defeat_popup()

		return

	reset_penguins_for_next_turn()


func process_actor_rewards_and_hits(actor: Sprite2D):

	if actor == null:
		return

	for enemy in enemies:

		if enemy == null:
			continue

		if overlap_cell(
			actor.position,
			enemy.position
		):

			enemy.queue_free()

			score += 1

	if (
		enemy2 != null
		and
		overlap_cell(
			actor.position,
			enemy2.position
		)
	):

		enemy2.queue_free()

		enemy2 = null

		enemy2_alive = false

	for star in stars:

		if star == null:
			continue

		if overlap_cell(
			actor.position,
			star.position
		):

			star.queue_free()

			moves += 2

	collect_gift_if_needed(actor)


func process_acorn_rewards_and_hits():

	for acorn in acorns:

		if acorn == null:
			continue

		process_actor_rewards_and_hits(acorn)


func is_actor_on_trap(actor: Sprite2D) -> bool:

	if actor == null:
		return false

	for trap in traps:

		if trap == null:
			continue

		if overlap_cell(
			actor.position,
			trap.position
		):
			return true

	return false


func run_end_of_turn_level_effects():

	if current_level == LEVEL_3 and enemy2_alive:

		create_random_trap()

		create_random_trap()

	if current_level == LEVEL_3S and enemy2_alive:

		summon_enemy4_wall2_rectangles()


func clear_acorns():

	for acorn in acorns:

		if acorn != null:

			acorn.queue_free()

	acorns.clear()

	acorn_velocities.clear()


func are_all_monsters_defeated() -> bool:

	# Victory depends on the actual monster state, not on remaining moves or a
	# target score. This also covers special monsters that are not counted in
	# the regular score.
	for enemy in enemies:
		if (
			enemy != null
			and
			is_instance_valid(enemy)
			and
			not enemy.is_queued_for_deletion()
		):
			return false

	if (
		enemy2 != null
		and
		is_instance_valid(enemy2)
		and
		not enemy2.is_queued_for_deletion()
	):
		return false

	return not enemy2_alive


func _input(event):

	if event is InputEventMouseMotion:

		mouse_pos = (
			get_global_mouse_position()
		)

	if event is InputEventMouseButton:

		if (
			event.button_index
			!=
			MOUSE_BUTTON_LEFT
		):
			return

		if event.pressed:

			var pos = (
				get_global_mouse_position()
			)

			mouse_pos = pos

			if handle_defeat_retry_click(pos):
				return

			if handle_victory_retry_click(pos):
				return

			if handle_victory_next_click(pos):
				return

			if game_over:
				return

			if restart_button != null:

				if pos.distance_to(
					restart_button.position
				) < 50:

					start_new_game()

					return

			if handle_character_button_click(pos):
				return

			if handle_level_button_click(pos):
				return

			if velocity.length() > 0:
				return

			if (
				current_character == PLAYER_9
				and
				are_penguins_moving()
			):
				return

			for v in acorn_velocities:

				if v.length() > MIN_SPEED:
					return

			var launch_actor = get_launch_actor_at_position(
				pos
			)

			if launch_actor != null:

				dragging = true

				drag_start = pos

			return

		else:

			if not dragging:
				return

			dragging = false

			hide_trajectory()

			mouse_pos = get_global_mouse_position()

			var release_actor = (
				get_active_penguin()
				if current_character == PLAYER_9
				else player
			)

			if release_actor == null:
				return

			launch_from_position(
				release_actor.position
			)


func create_floor():

	var floors = []

	if is_winter_level():

		floors = [
			load("res://art/floor4.png"),
			load("res://art/floor5.png"),
			load("res://art/floor6.png")
		]

	else:

		floors = [
			load("res://art/floor.png"),
			load("res://art/floor2.png"),
			load("res://art/floor3.png")
		]

	for y in range(ROWS):

		for x in range(COLS):

			var tile = Sprite2D.new()

			tile.texture = floors[
				randi() % floors.size()
			]

			tile.position = Vector2(
				LEFT_BORDER +
				x * CELL +
				CELL / 2,

				TOP_BORDER +
				y * CELL +
				CELL / 2
			)

			tile.z_index = 10

			add_child(tile)

			floor_tiles.append(tile)

func create_level_buttons():

	for button in level_buttons:

		if is_instance_valid(button):

			button.queue_free()

	level_buttons.clear()

	var textures = [

		load("res://art/0H.png"),

		load("res://art/1H.png"),

		load("res://art/2H.png"),

		load("res://art/3H.png"),

		load("res://art/1S.png"),

		load("res://art/2S.png"),

		load("res://art/3S.png")

	]

	for i in range(textures.size()):

		var button = Node2D.new()

		if i < 4:

			button.position = Vector2(
				1560 + i * 90,
				235
			)

		else:

			# Winter levels sit directly under levels 1, 2, and 3, so the
			# selector reads as one normal row and one snowy difficulty row.
			button.position = Vector2(
				1560 + (i - 3) * 90,
				325
			)

		button.z_index = 500

		var icon = Sprite2D.new()

		icon.texture = textures[i]

		button.add_child(icon)

		add_child(button)

		level_buttons.append(button)


func create_enemy4_with_crystals(
	used_cells: Dictionary
):

	var possible_rows = [
		2,
		3
	]

	var boss_cell = Vector2i(
		1 + randi() % (COLS - 2),
		possible_rows[
			randi() % possible_rows.size()
		]
	)

	enemy2 = Sprite2D.new()

	enemy2.texture = load(
		"res://art/enemy4.png"
	)

	enemy2.position = position_for_cell(
		boss_cell
	)

	enemy2.z_index = 70

	add_child(enemy2)

	enemy2_alive = true

	mark_used_cell(
		used_cells,
		boss_cell
	)

	for offset_x in range(-1, 2):

		var crystal_cell = Vector2i(
			boss_cell.x + offset_x,
			boss_cell.y + 1
		)

		create_crystal(
			crystal_cell.x,
			crystal_cell.y
		)

		mark_used_cell(
			used_cells,
			crystal_cell
		)


func create_crystal(
	x: int,
	y: int
):

	var crystal = Sprite2D.new()

	crystal.texture = load(
		"res://art/crystal.png"
	)

	crystal.position = position_for_cell(
		Vector2i(
			x,
			y
		)
	)

	crystal.z_index = 65

	add_child(crystal)

	crystals.append(crystal)


func create_gift(
	used_cells: Dictionary
):

	var preferred_cell = Vector2i(
		int(COLS / 2),
		0
	)

	if is_cell_used(
		used_cells,
		preferred_cell
	):

		for x in range(COLS):

			var candidate = Vector2i(
				x,
				0
			)

			if not is_cell_used(
				used_cells,
				candidate
			):

				preferred_cell = candidate

				break

	gift = Sprite2D.new()

	gift.texture = load(
		"res://art/gift.png"
	)

	gift.position = position_for_cell(
		preferred_cell
	)

	gift.z_index = 58

	add_child(gift)

	mark_used_cell(
		used_cells,
		preferred_cell
	)


func collect_gift_if_needed(actor: Sprite2D):

	if gift == null:
		return

	if not is_instance_valid(gift):
		return

	if actor == null:
		return

	if not overlap_cell(
		actor.position,
		gift.position
	):
		return

	gift.queue_free()

	gift = null

	moves += 6

	update_move_icons()


func summon_enemy4_wall2_rectangles():

	if current_level != LEVEL_3S:
		return

	if not enemy2_alive:
		return

	var used_cells = get_current_used_cells()

	var rectangles_created = 0

	while rectangles_created < 2:

		if create_wall2_rectangle(
			used_cells
		):

			rectangles_created += 1

		else:

			return


func get_current_used_cells() -> Dictionary:

	var used_cells = {}

	for enemy in enemies:

		if enemy != null and is_instance_valid(enemy):

			mark_used_cell(
				used_cells,
				cell_for_position(enemy.position)
			)

	for wall in walls:

		if wall != null and is_instance_valid(wall):

			mark_used_cell(
				used_cells,
				cell_for_position(wall.position)
			)

	for trap in traps:

		if trap != null and is_instance_valid(trap):

			mark_used_cell(
				used_cells,
				cell_for_position(trap.position)
			)

	for star in stars:

		if star != null and is_instance_valid(star):

			mark_used_cell(
				used_cells,
				cell_for_position(star.position)
			)

	for crystal in crystals:

		if crystal != null and is_instance_valid(crystal):

			mark_used_cell(
				used_cells,
				cell_for_position(crystal.position)
			)

	if enemy2 != null and is_instance_valid(enemy2):

		mark_used_cell(
			used_cells,
			cell_for_position(enemy2.position)
		)

	if gift != null and is_instance_valid(gift):

		mark_used_cell(
			used_cells,
			cell_for_position(gift.position)
		)

	return used_cells


func create_enemy2():

	var possible_rows = [
		2,
		3
	]

	var x = randi() % COLS

	var y = possible_rows[
		randi() % possible_rows.size()
	]

	enemy2 = Sprite2D.new()

	enemy2.texture = load(
		"res://art/enemy2.png"
	)

	enemy2.position = Vector2(
		LEFT_BORDER +
		x * CELL +
		CELL / 2,

		TOP_BORDER +
		y * CELL +
		CELL / 2
	)

	enemy2.z_index = 70

	add_child(enemy2)

	enemy2_alive = true

func create_random_trap():

	for attempt in range(100):

		var x = randi() % COLS

		var y = randi() % ROWS

		var pos = Vector2(
			LEFT_BORDER +
			x * CELL +
			CELL / 2,

			TOP_BORDER +
			y * CELL +
			CELL / 2
		)

		var blocked = false

		for trap in traps:

			if trap != null and overlap_cell(
				pos,
				trap.position
			):

				blocked = true

		for wall in walls:

			if wall != null and overlap_cell(
				pos,
				wall.position
			):

				blocked = true

		for enemy in enemies:

			if enemy != null and overlap_cell(
				pos,
				enemy.position
			):

				blocked = true

		for star in stars:

			if star != null and overlap_cell(
				pos,
				star.position
			):

				blocked = true

		for crystal in crystals:

			if crystal != null and overlap_cell(
				pos,
				crystal.position
			):

				blocked = true

		if enemy2 != null:

			if overlap_cell(
				pos,
				enemy2.position
			):

				blocked = true

		if gift != null:

			if overlap_cell(
				pos,
				gift.position
			):

				blocked = true

		if not blocked:

			create_trap(
				x,
				y
			)

			return

func create_character_buttons():

	for button in character_buttons:

		if is_instance_valid(button):

			button.queue_free()

	character_buttons.clear()

	var textures = [

		load("res://art/player.png"),

		load("res://art/player2.png"),

		load("res://art/player3.png"),

		load("res://art/player5.png"),

		load("res://art/player7.png"),

		load("res://art/player8.png"),

		load("res://art/player9.png"),

		load("res://art/player10.png")

	]

	for i in range(textures.size()):

		var icon = Sprite2D.new()

		icon.texture = textures[i]

		var col = i % 3

		var row = int(i / 3)

		icon.position = Vector2(
			210 + col * 90,
			235 + row * 90
		)

		icon.z_index = 500

		add_child(icon)

		character_buttons.append(icon)


func get_penguin_start_positions() -> Array:

	var offset = (
		CELL * 1.5
	)

	return [
		Vector2(
			PLAYER_START_X - offset,
			PLAYER_START_Y
		),
		Vector2(
			PLAYER_START_X + offset,
			PLAYER_START_Y
		)
	]


func create_penguins():

	var start_positions = get_penguin_start_positions()

	for start_position in start_positions:

		var penguin = Sprite2D.new()

		penguin.texture = load(
			"res://art/player9.png"
		)

		penguin.position = start_position

		penguin.z_index = 100

		add_child(penguin)

		penguins.append(penguin)

		penguin_velocities.append(
			Vector2.ZERO
		)

		penguin_alive.append(true)


func reset_penguins_for_next_turn():

	var start_positions = get_penguin_start_positions()

	for i in range(penguins.size()):

		if i >= start_positions.size():
			continue

		if penguins[i] == null:
			continue

		if penguin_alive[i]:

			penguins[i].position = start_positions[i]

			penguins[i].visible = true

		penguin_velocities[i] = Vector2.ZERO


func has_alive_penguin() -> bool:

	for alive in penguin_alive:

		if alive:
			return true

	return false


func are_penguins_moving() -> bool:

	for penguin_velocity in penguin_velocities:

		if penguin_velocity.length() > MIN_SPEED:
			return true

	return false


func process_penguin_motion():

	for i in range(penguins.size()):

		if not penguin_alive[i]:
			continue

		if penguins[i] == null:
			continue

		if penguin_velocities[i] == Vector2.ZERO:
			continue

		penguins[i].position += penguin_velocities[i]

		penguin_velocities[i] *= FRICTION

		penguin_velocities[i] = bounce_actor_from_borders(
			penguins[i],
			penguin_velocities[i]
		)

		penguin_velocities[i] = bounce_actor_from_obstacles(
			penguins[i],
			penguin_velocities[i]
		)

		if (
			abs(penguin_velocities[i].x) < MIN_SPEED
			and
			abs(penguin_velocities[i].y) < MIN_SPEED
		):

			penguin_velocities[i] = Vector2.ZERO


func bounce_actor_from_borders(
	actor: Sprite2D,
	actor_velocity: Vector2
) -> Vector2:

	var left = (
		LEFT_BORDER +
		PLAYER_SIZE / 2
	)

	var right = (
		RIGHT_BORDER -
		PLAYER_SIZE / 2
	)

	var top = (
		TOP_BORDER +
		PLAYER_SIZE / 2
	)

	var bottom = (
		BOTTOM_BORDER -
		PLAYER_SIZE / 2
	)

	if actor.position.x < left:

		actor.position.x = left

		actor_velocity.x *= -0.8

	if actor.position.x > right:

		actor.position.x = right

		actor_velocity.x *= -0.8

	if actor.position.y < top:

		actor.position.y = top

		actor_velocity.y *= -0.8

	if actor.position.y > bottom:

		actor.position.y = bottom

		actor_velocity.y *= -0.8

	return actor_velocity


func bounce_actor_from_obstacles(
	actor: Sprite2D,
	actor_velocity: Vector2
) -> Vector2:

	for obstacle in get_solid_obstacles():

		if obstacle == null:
			continue

		if not overlap_cell(
			actor.position,
			obstacle.position
		):
			continue

		var dx = (
			actor.position.x -
			obstacle.position.x
		)

		var dy = (
			actor.position.y -
			obstacle.position.y
		)

		if abs(dx) > abs(dy):

			actor_velocity.x *= -0.8

			actor.position.x += (
				sign(dx) * 4
			)

		else:

			actor_velocity.y *= -0.8

			actor.position.y += (
				sign(dy) * 4
			)

	return actor_velocity


func get_active_penguin():

	if penguins.is_empty():
		return null

	if (
		active_penguin_index >= 0
		and
		active_penguin_index < penguins.size()
		and
		penguin_alive[active_penguin_index]
	):

		return penguins[active_penguin_index]

	for i in range(penguins.size()):

		if penguin_alive[i]:

			active_penguin_index = i

			return penguins[i]

	return null


func get_launch_actor_at_position(
	click_position: Vector2
):

	if current_character == PLAYER_9:

		for i in range(penguins.size()):

			if not penguin_alive[i]:
				continue

			if penguins[i] == null:
				continue

			if click_position.distance_to(
				penguins[i].position
			) <= PLAYER_SIZE / 2:

				active_penguin_index = i

				return penguins[i]

		return null

	var half_x = (
		PLAYER_SIZE / 2
	)

	var half_y = (
		PLAYER_SIZE / 2
	)

	if (
		click_position.x >= player.position.x - half_x
		and
		click_position.x <= player.position.x + half_x
		and
		click_position.y >= player.position.y - half_y
		and
		click_position.y <= player.position.y + half_y
	):

		return player

	return null


func launch_from_position(
	release_launch_pos: Vector2
) -> bool:

	var launch_velocity = get_launch_velocity(
		release_launch_pos,
		mouse_pos
	)

	if launch_velocity == Vector2.ZERO:
		return false

	if current_character == PLAYER_9:

		for i in range(penguin_velocities.size()):

			if penguin_alive[i]:

				penguin_velocities[i] = launch_velocity

	else:

		velocity = launch_velocity

		if current_character == PLAYER_10:

			snail_launch_start_position = player.position

	turn_active = true

	moves -= 1

	update_move_icons()

	return true


func handle_snail_trail_input():

	if Input.is_action_just_pressed("ui_left"):

		move_snail_on_trail(
			Vector2i(-1, 0)
		)

	if Input.is_action_just_pressed("ui_right"):

		move_snail_on_trail(
			Vector2i(1, 0)
		)

	if Input.is_action_just_pressed("ui_up"):

		move_snail_on_trail(
			Vector2i(0, -1)
		)

	if Input.is_action_just_pressed("ui_down"):

		move_snail_on_trail(
			Vector2i(0, 1)
		)


func move_snail_on_trail(direction: Vector2i) -> bool:

	if current_character != PLAYER_10:
		return false

	if snail_trail_cells.is_empty():
		return false

	var current_cell = cell_for_position(
		player.position
	)

	var target_cell = current_cell + direction

	if not snail_trail_cells.has(target_cell):
		return false

	player.position = position_for_cell(
		target_cell
	)

	return true


func record_snail_trail_from_first_launch():

	if current_character != PLAYER_10:
		return

	if snail_first_launch_recorded:
		return

	var start_cell = cell_for_position(
		snail_launch_start_position
	)

	var end_cell = cell_for_position(
		player.position
	)

	var dx = end_cell.x - start_cell.x

	var dy = end_cell.y - start_cell.y

	var steps = maxi(
		abs(dx),
		abs(dy)
	)

	if steps == 0:

		add_snail_trail_cell(
			start_cell
		)

	else:

		for step in range(steps + 1):

			var t = float(step) / float(steps)

			var trail_cell = Vector2i(
				int(round(lerp(start_cell.x, end_cell.x, t))),
				int(round(lerp(start_cell.y, end_cell.y, t)))
			)

			add_snail_trail_cell(
				trail_cell
			)

	snail_first_launch_recorded = true


func add_snail_trail_cell(cell: Vector2i):

	if snail_trail_cells.has(cell):
		return

	snail_trail_cells.append(cell)

	var trail_tile = ColorRect.new()

	trail_tile.size = Vector2(
		CELL * 0.72,
		CELL * 0.72
	)

	# Muted ochre keeps the snail trail visible without fighting the board art.
	trail_tile.color = Color(
		0.78,
		0.58,
		0.26,
		0.42
	)

	trail_tile.position = (
		position_for_cell(cell) -
		trail_tile.size / 2
	)

	trail_tile.z_index = 25

	add_child(trail_tile)

	snail_trail_tiles.append(trail_tile)
		
func setup_character():


	if player == null:
		return

	match current_character:

		PLAYER_1:

			player.texture = load(
				"res://art/player.png"
			)

		PLAYER_2:

			player.texture = load(
				"res://art/player2.png"
			)

		PLAYER_3:

			player.texture = load(
				"res://art/player3.png"
			) 
			

		PLAYER_5:

			player.texture = load(
				"res://art/player5.png"
			)
			
		PLAYER_7:

			player.texture = load(
				"res://art/player7.png"
			)
			
		PLAYER_8:

			player.texture = load(
				"res://art/player8.png"
			)

		PLAYER_9:

			player.texture = load(
				"res://art/player9.png"
			)

		PLAYER_10:

			player.texture = load(
				"res://art/player10.png"
			)

	player.visible = (
		current_character != PLAYER_9
	)
	
func gorilla_hit_wall(
	wall,
	hit_velocity
):

	if wall == null:
		return

	var index = walls.find(wall)

	if index == -1:
		return

	wall_velocities[index] += (
		hit_velocity *
		GORILLA_PUSH_POWER
	)

	play_gorilla_push_animation(
		wall.position,
		true,
		GORILLA_PUSH_POST_COLLISION_SECONDS
	)


func preview_gorilla_push_animation(
	delta: float
):

	if current_character != PLAYER_2:
		return

	if player == null:
		return

	if velocity.length() <= MIN_SPEED:
		return

	var wall_position = get_predicted_gorilla_wall_hit(
		delta
	)

	if wall_position == null:
		return

	play_gorilla_push_animation(
		wall_position,
		false
	)


func get_predicted_gorilla_wall_hit(
	delta: float
):

	if delta <= 0.0:
		return null

	var predicted_position = player.position

	var predicted_velocity = velocity

	var frames_to_check = int(
		ceil(
			GORILLA_PUSH_PRE_COLLISION_SECONDS /
			delta
		)
	)

	for _step in range(
		frames_to_check
	):

		predicted_position += predicted_velocity

		predicted_velocity *= FRICTION

		for wall in walls:

			if wall == null:
				continue

			if overlap_cell(
				predicted_position,
				wall.position
			):
				return wall.position

	return null


func play_gorilla_push_animation(
	wall_position: Vector2,
	restore_after_delay := true,
	restore_delay := GORILLA_PUSH_ANIMATION_SECONDS
):

	if player == null:
		return

	if current_character != PLAYER_2:
		return

	gorilla_push_animation_id += 1

	var animation_id = gorilla_push_animation_id

	player.texture = load(
		get_gorilla_push_texture_path(
			wall_position
		)
	)

	if not restore_after_delay:
		return

	# Each hit shows the directional pushing pose for a short, readable moment.
	# The animation id prevents an older timer from restoring the normal sprite
	# while a newer hit animation is still active.
	var scene_tree = get_tree()

	if scene_tree == null:
		return

	await scene_tree.create_timer(
		restore_delay
	).timeout

	if animation_id != gorilla_push_animation_id:
		return

	if current_character != PLAYER_2:
		return

	setup_character()


func get_gorilla_push_texture_path(
	wall_position: Vector2
) -> String:

	var offset = (
		wall_position -
		player.position
	)

	if abs(offset.x) > abs(offset.y):

		if offset.x < 0:
			return "res://art/gorilla/gorilla_push_left.png"

		return "res://art/gorilla/gorilla_push_right.png"

	if offset.y < 0:
		return "res://art/gorilla/gorilla_push_up.png"

	return "res://art/gorilla/gorilla_push_down.png"

func create_acorns():

	if current_character != PLAYER_3:
		return

	for i in range(2):

		var acorn = Sprite2D.new()

		acorn.texture = load(
			"res://art/acorn.png"
		)

		if i == 0:

			acorn.position = (
				player.position +
				Vector2(-40, -20)
			)

		else:

			acorn.position = (
				player.position +
				Vector2(40, 20)
			)

		acorn.z_index = 120

		add_child(acorn)

		acorns.append(acorn)
		var dir = velocity.normalized()

		if i == 0:

			dir = dir.rotated(
				deg_to_rad(-10)
			)

		else:

			dir = dir.rotated(
				deg_to_rad(10)
			)

		acorn_velocities.append(
			dir * 8.0
		) 
		
func create_tree():

	if tree != null:
		return

	tree = Sprite2D.new()

	tree.centered = true

	tree.texture = load(
		"res://art/tree.png"
	)

	tree.position = player.position + Vector2(
		0,
		-36
	)
	
	tree.z_index = 400

	add_child(tree)

	tree_active = true
	
	bear_tree_turn = true
	
func overlap_tree(
	center: Vector2,
	tree_pos: Vector2
) -> bool:

	return not (

		center.x +
		PLAYER_SIZE / 2 <
		tree_pos.x - 36

		or

		center.x -
		PLAYER_SIZE / 2 >
		tree_pos.x + 36

		or

		center.y +
		PLAYER_SIZE / 2 <
		tree_pos.y - 72

		or

		center.y -
		PLAYER_SIZE / 2 >
		tree_pos.y + 72
	)
	
func place_sparrow():

	var free_cells = []

	for x in range(1, COLS - 1):

		for y in range(1, ROWS - 1):

			var blocked = false

			for wall in walls:

				if wall == null:
					continue

				var wx = int(
					(wall.position.x - LEFT_BORDER)
					/ CELL
				)

				var wy = int(
					(wall.position.y - TOP_BORDER)
					/ CELL
				)

				if wx == x and wy == y:

					blocked = true

					break

			if blocked:
				continue

			for trap in traps:

				if trap == null:
					continue

				var tx = int(
					(trap.position.x - LEFT_BORDER)
					/ CELL
				)

				var ty = int(
					(trap.position.y - TOP_BORDER)
					/ CELL
				)

				if tx == x and ty == y:

					blocked = true

					break

			if blocked:
				continue

			if (
				last_sparrow_cell.x == x
				and
				last_sparrow_cell.y == y
			):
				continue

			free_cells.append(
				Vector2(x, y)
			)

	if free_cells.size() == 0:
		return

	var cell = free_cells[
		randi() % free_cells.size()
	]

	last_sparrow_cell = cell

	player.position = Vector2(
		LEFT_BORDER +
		cell.x * CELL +
		CELL / 2,

		TOP_BORDER +
		cell.y * CELL +
		CELL / 2
	)
