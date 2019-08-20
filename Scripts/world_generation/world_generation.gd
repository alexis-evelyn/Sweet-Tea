extends TileMap

# * IDEA: What if I had the game in three dimensions (horizontal and vertical axes plus time). Use 3d rendering to show the time axis with a special in game item...
# * Also build a time manipulating boss!!! Research Spacetime to decide how to implement this.

# Note (IMPORTANT): World Origin is Top Left of Starting Screen - This May Change

# Non-Tilemap Generation - https://www.youtube.com/watch?v=skln7GPdB_A&list=PL0t9iz007UitFwiu33Vx4ZnjYQHH9th2r
# How Many Tilemaps - https://godotengine.org/qa/17780/create-multiple-small-tilemaps-or-just-a-giant
# 2D Tilemaps Chunk Theory - https://www.gamedev.net/forums/topic/653120-2d-tilemaps-chunk-theory/
# Intro Tilemap Procedural Generation (Reddit) - https://www.reddit.com/r/godot/comments/8v2xco/introduction_to_procedural_generation_with_godot/
# Into Tilemap Procedural Generation (Article) - https://steincodes.tumblr.com/post/175407913859/introduction-to-procedural-generation-with-godot
# Large Tilemap Generation - https://godotengine.org/qa/1121/how-go-about-generating-very-large-or-infinite-map-from-tiles
# Tilemap Docs - https://docs.godotengine.org/en/3.1/classes/class_tilemap.html

# World Gen Help
# Studying/Using This May Help - https://github.com/perdugames/SoftNoise-GDScript-
# Builtin Noise Generator - https://godotengine.org/article/simplex-noise-lands-godot-31
# OpenSimplexNoise - https://docs.godotengine.org/en/3.1/classes/class_opensimplexnoise.html

# Saving Data in Scene Files
# Answer to Question I Asked about Saving Variables to Scene - https://www.reddit.com/r/godot/comments/cp8siv/question_how_do_i_save_a_variable_to_a_scene_when/ewo070k/
# Custom Resources - https://github.com/godotengine/godot/issues/7037
# Save Custom Resource - https://godotengine.org/qa/8139/need-help-with-exporting-a-custom-ressource-type?show=8146#a8146
# Embed Resource into Scene - https://www.reddit.com/r/godot/comments/7xw6p9/is_there_any_way_to_embed_resource_into_a_scene/duh1bq0?utm_source=share&utm_medium=web2x
# Save Variables to Scene - https://www.patreon.com/posts/saving-godots-22268842
# Gist From Save Variables to Scene - https://gist.github.com/henriiquecampos/8d98f0660da499967d41c32988cd3612#gistcomment-2743040
# Explains About export(Resource) - https://godotengine.org/qa/8139/need-help-with-exporting-a-custom-ressource-type?show=14398#a14398

# Note: I am using a Tilemap to improve performance.
# This does mean world manipulation will be more complicated, but performance cannot be passed up.
# I am using SteinCode's Tumblr Article to help me get started.

signal chunk_change(chunk_pos) # Allows Other nodes to know when player has entered a new chunk

# Declare member variables here. Examples:
#var world_grid : Dictionary = {} # I use a dictionary so I can have negative coordinates.

# Tilemap uses ints to store tile ids. This means I do not have an infinite number of blocks.
# This will make things difficult if there are 100+ mods (all adding new blocks).
# Mojang used strings to solve this problem, but I don't know if I can make Tilemap use strings.
# I may have to create my own Tilemap from scratch (after release).
# Block IDs (referencing the Tilemap Tile ID)
const block : Dictionary = {
	'air': -1, # -1 means no tile exists - there is no such thing as block_air. It is just void.
	'stone': 0,
	'dirt': 1,
	'grass': 2
}

# Tilesets
var default_tileset : TileSet = load("res://Objects/Blocks/Default.tres")
var debug_tileset : TileSet = load("res://Objects/Blocks/Default-Debug.tres")

# Set's Worldgen size (Tilemap's Origin is Fixed to Same Spot as World Origin - I doubt I am changing this. Not unless changing it improves performance)
var quadrant_size : int = get_quadrant_size() # Default 16
var chunk_size : Vector2 = Vector2(quadrant_size, quadrant_size) # Tilemap is 32x32 (the size of a standard block) pixels per tile.
var world_size : Vector2 = Vector2(10, 10) # These numbers will be split on the negative and positive axes. The chunk gen will favor the negative side of the axes if the numbers are even.
var standard_pixel_size : Vector2 = Vector2(32, 32) # This doesn't mean anything other than calculations, but having it as a variable can help update the equations more easily (say if standard blocks use more/less pixels)

onready var world_node = self.get_owner() # Gets The Current World's Node
onready var background_tilemap : TileMap = get_node("Background") # Gets The Background Tilemap
var background_shader : ShaderMaterial = load("res://Assets/Materials/background.tres") # ShaderMaterial (for shading background tilemap)

var world_seed : String # World's Seed (used by generator to produce consistent results)
var generated_chunks_foreground : Array # Store Generated Chunks IDs to Make Sure Not To Generate Them Again
var generated_chunks_background : Array # Store Generated Chunks IDs to Make Sure Not To Generate Them Again

# This gives the each instance of the world generator access to its own exclusive random number generator so it will not be interfered with by other generators.
var generator : RandomNumberGenerator = RandomNumberGenerator.new()
var player_chunks : Dictionary = {} # Used to keep track of what chunks a player already has

# TODO (IMPORTANT): Generate chunks array on world load instead of reading from file!!!
# Also, currently seeds aren't loaded from world handler, so they are generated new every time.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("World Generator Seed: ", world_seed)
	
	#gamestate.debug = true # Turns on Debug Camera - Useful for Debugging World Gen
	
	if gamestate.debug:
		self.tile_set = debug_tileset
		background_tilemap.tile_set = debug_tileset.duplicate() # Duplicate makes resource unique (basically makes a copy of it in memory so it can be manipulated separately from other copies of the resource)
	else:
		self.tile_set = default_tileset
		background_tilemap.tile_set = default_tileset.duplicate() # Duplicate makes resource unique (basically makes a copy of it in memory so it can be manipulated separately from other copies of the resource)
	
	set_shader_background_tiles() # Set Shader for Background Tiles
	background_tilemap.set_owner(world_node) # Set world as owner of Background Tilemap (allows saving Tilemap to world when client saves world)
	print("Background TileMap's Owner: ", background_tilemap.get_owner().name) # Debug Statement to list Background TileMap's Owner's Name
	
	# Seed should be set by world loader (if pre-existing world)
	if world_seed.empty():
		print("Generate Seed: ", generate_seed()) # Generates A Random Seed (Int) and Applies to Generator
	else:
		print("Set Seed: ", set_seed(world_seed)) # Converts Seed to Int and Applies to Generator

	#generate_new_world()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float):
#	pass

# Set Shader for Background Tiles
func set_shader_background_tiles():
	# Without explicitly making the resource unique, the same reference is just passed around no matter how many times it is loaded
	# Godot making this an explicit request helps make saving memory easy (as one does not need to handle passing around references).
	#print("FG: ", self.tile_set)
	#print("BG: ", background_tilemap.tile_set)
	
	# Loops Through Tiles in Tileset and Applies Shader(s)
	for tile in background_tilemap.tile_set.get_tiles_ids():
		background_tilemap.tile_set.tile_set_material(tile, background_shader)

# Load or Generate New Chunks for Player (Server Side)
# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
var load_chunks_thread : Thread = Thread.new()
func load_chunks(net_id: int, position: Vector2, instant_load: bool = false, render_distance: Vector2 = Vector2(3, 3)):
	# render_distance - This is different from the world_size as this is generating/loading the world from the player's position and won't be halved (will be configurable). Halving it will make it only able to load an even number of chunks.
	
	# How Minecraft's Server-Client Chunk Transmission Works - https://github.com/ORelio/Minecraft-Console-Client/issues/140#issuecomment-207971227
	# Potential Problem With Minecraft's Server-Client Chunk Transmission - https://bugs.mojang.com/plugins/servlet/mobile#issue/MC-145813
	
	# Because the client is not allowed to request chunks (for security and performance reasons), the server has no way of knowing if a client has unloaded chunks.
	# The client could abuse the server if it was allowed to request chunks again, so the server has to keep track of what chunks should be loaded on the client's side.
	# Basically, what this function needs to do (before determining if it should load or generate chunks) is take a given amount of chunks (say world height times 10 chunks horizontally)...
	# and then do math from the client's coordinates (which the server has authority over) to determine which chunks to load/generate and then send to the client.
	# It is the client's job to make sure it doesn't unload chunks that it should keep track of.
	
	# NOTE (IMPORTANT): When using player camera, the player can see at most 3 chunks on one axis. At most 9 chunks total.
	# The server render distance will override the client's distance. If the client has a higher distance, it will just cache the chunks for later.
	# This means that the chunk loader will load and send at least 9 chunks in all directions (providing we did not hit the ceiling or floor - I plan on looping the world on the horizontal axis*).
	# To be help with NPCs moving offscreen, I will make the chunk loader add one chunk to each side of both axes by default (can be configurable). This will result in a total of 13 chunks loaded and sent by server.
	
	# Actually, let's do two extra chunks for the x-axis and 1 extra chunk for the y-axis (results in Vector2(7, 5)).
	
	# Completely toss any math said above, I accidentally made this double on both axes and I am sticking with it.
	
	# * - Looping the world on the horizontal access only applies to non-infinite worlds. Release will only support non-infinite worlds (afterwards if the game does well, I will work on infinite worlds). 
	#print("Player %s has Position %s!!!" % [net_id, position])
	
	#load_chunks.start(self, "load_chunks_threaded", [net_id, position, render_distance, instant_load])
	#load_chunks.wait_to_finish()
	
	load_chunks_threaded([net_id, position, render_distance, instant_load])
	
# Putting Load Chunks on Separate Thread
func load_chunks_threaded(thread_data: Array):
	var net_id: int = thread_data[0]
	var position: Vector2 = thread_data[1]
	var render_distance: Vector2 = thread_data[2]
	var instant_load : bool = false
	
	if thread_data.size() >= 3:
		instant_load = thread_data[3]
		#print("Instant: ", instant_load)
	
	# Make sure player_chunks has player id in database
	if not player_chunks.has(net_id):
		player_chunks[net_id] = {}
	
	var chunk : Vector2
	if net_id != gamestate.net_id:
		chunk = center_chunk(position)
	else:
		chunk = center_chunk(position, true)
		
	#var generate_loc : Vector2 = chunk + render_distance
	#print("Generate: ", generate_loc)
		
	# Generate Chunks (will not override without explicit request)
	for chunk_x in range(-render_distance.x, render_distance.x):
		for chunk_y in range(-render_distance.y, render_distance.y):
			var surrounding_chunk : Vector2 = Vector2(int(chunk.x - chunk_x), int(chunk.y - chunk_y))
			
			if not player_chunks[net_id].has(surrounding_chunk):
#				print("Chunk.x - chunk_x: %s - %s = %s" % [chunk.x, chunk_x, (int(chunk.x - chunk_x))])
#				print("Chunk.y - chunk_y: %s - %s = %s" % [chunk.y, chunk_y, (int(chunk.y - chunk_y))])
#				print("Surrounding Chunk: %s\n" % surrounding_chunk)
				
				# Because of a bug that causes a segfault (when a client causes new chunks to be generated), I am disabling movement based chunk generation for now.
				# The bug does not occur when the server player moves, so I am leaving server player's chunk gen on if debug mode is enabled.
				# Movement Based Chunk Gen Segfault - https://github.com/godotengine/godot/issues/31477
				
				if net_id == 1 and gamestate.debug:
					#print("Generating: ", Vector2(chunk.x - chunk_x, chunk.y - chunk_y))
					# warning-ignore:narrowing_conversion
					# warning-ignore:narrowing_conversion
					generate_foreground(chunk.x - chunk_x, chunk.y - chunk_y) # Generate The Foreground (Tiles Player Can Stand On and Collide With)
					# warning-ignore:narrowing_conversion
					# warning-ignore:narrowing_conversion
					generate_background(chunk.x - chunk_x, chunk.y - chunk_y) # Generate The Background (Tiles Player Can Pass Through)
	
				if net_id != gamestate.net_id:
					send_chunk(net_id, surrounding_chunk)

				player_chunks[net_id][surrounding_chunk] = null
				
				if not instant_load:
					yield(get_tree().create_timer(1.0), "timeout")
					#OS.delay_msec(1000)

func center_chunk(position: Vector2, update_debug: bool = false) -> Vector2:
	# We use world coordinates to spawn blocks. No conversion needed.
	
	# x = 16 + (16 * y)
	# var horizontal : int = chunk_size.x + (quadrant_size * chunk_x)
	
	# 16y = 16 - x
	# y = (16 - x)/16
	var chunk_x : float
	var chunk_y : float
	var chunk : Vector2
	
	if position.x >= 0:
		# warning-ignore:narrowing_conversion
		chunk_x = (position.x / standard_pixel_size.x / chunk_size.x)
	else:
		# warning-ignore:narrowing_conversion
		chunk_x = (position.x / standard_pixel_size.x / chunk_size.x) - 1
		
	if  position.y >= 0:
		# warning-ignore:narrowing_conversion
		chunk_y = (position.y / standard_pixel_size.y / chunk_size.y)
	else:
		# warning-ignore:narrowing_conversion
		chunk_y = (position.y / standard_pixel_size.y / chunk_size.y) - 1
	
	chunk = Vector2(chunk_x, chunk_y)
	
	#print("Player %s is in Chunk %s!!!" % [net_id, Vector2(chunk_x, chunk_y)])
	
	if update_debug:
		emit_signal("chunk_change", chunk) # Used to update Debug Info
		
	return chunk # Used by Calling Function

func send_chunk(net_id: int, chunk: Vector2) -> void:
	var chunk_grid_foreground : Dictionary = {}
	var chunk_grid_background : Dictionary = {}
	
	# warning-ignore:narrowing_conversion
	var horizontal : int = chunk_size.x + (quadrant_size * chunk.x)
	# warning-ignore:narrowing_conversion
	var vertical : int = chunk_size.y + (quadrant_size * chunk.y)
	
	for coor_x in range((horizontal - quadrant_size), horizontal):
		chunk_grid_foreground[coor_x] = {}
		chunk_grid_background[coor_x] = {}
		for coor_y in range((vertical - quadrant_size), vertical):
			chunk_grid_foreground[coor_x][coor_y] = get_cell(coor_x, coor_y)
			chunk_grid_background[coor_x][coor_y] = background_tilemap.get_cell(coor_x, coor_y)

	rpc_unreliable_id(net_id, "receive_chunk", true, chunk_grid_foreground)
	rpc_unreliable_id(net_id, "receive_chunk", false, chunk_grid_background)
	
puppet func receive_chunk(foreground: bool, chunk_grid : Dictionary) -> void:
	# Set's Tile ID in Tilemap from World Grid
	for coor_x in chunk_grid.keys():
		for coor_y in chunk_grid[coor_x].keys():
			#print("Coordinate: (", coor_x, ", ", coor_y, ") - Value: ", world_grid[coor_x][coor_y])
	
			if foreground:
				#print("Chunk Grid (Foreground): ", chunk_grid)
				set_cell(coor_x, coor_y, chunk_grid[coor_x][coor_y])
			else:
				#print("Chunk Grid (Background): ", chunk_grid)
				background_tilemap.set_cell(coor_x, coor_y, chunk_grid[coor_x][coor_y])

# Generate's a New World
func generate_new_world():
	# Convert Vector2 values from floats to integers (as modulus cannot perform on an other type than an integer in GDScript).
	# warning-ignore:narrowing_conversion
	var x_axis : int = world_size.x
	# warning-ignore:narrowing_conversion
	var y_axis : int = world_size.y
	
	# This if statement setup is so an odd number of can be generated (based on world size).
	# This setup favors generating chunks on the negative axes (left and top).
	if x_axis % 2 == 0: # This can either equal 0 or 1. 0 means even and 1 means odd.
		# Even X Axis
		# warning-ignore:integer_division
		# warning-ignore:integer_division
		for chunk_x in range(-x_axis/2, x_axis/2):
			if y_axis % 2 == 0:
				# Even Y Axis (Even X Axis)
				# warning-ignore:integer_division
				# warning-ignore:integer_division
				for chunk_y in range(-y_axis/2, y_axis/2):
					generate_foreground(chunk_x, chunk_y) # Generate The Foreground (Tiles Player Can Stand On and Collide With)
					generate_background(chunk_x, chunk_y) # Generate The Background (Tiles Player Can Pass Through)
			else:
				# Odd X Axis (Even X Axis)
				# warning-ignore:integer_division
				# warning-ignore:integer_division
				for chunk_y in range((-y_axis/2)-1, (y_axis/2)):
					generate_foreground(chunk_x, chunk_y) # Generate The Foreground (Tiles Player Can Stand On and Collide With)
					generate_background(chunk_x, chunk_y) # Generate The Background (Tiles Player Can Pass Through)
	else:
		# Odd X Axis
		# warning-ignore:integer_division
		# warning-ignore:integer_division
		for chunk_x in range((-x_axis/2)-1, (x_axis/2)):
			if y_axis % 2 == 0:
				# Even Y Axis (Odd X Axis)
				# warning-ignore:integer_division
				# warning-ignore:integer_division
				for chunk_y in range(-y_axis/2, y_axis/2):
					generate_foreground(chunk_x, chunk_y) # Generate The Foreground (Tiles Player Can Stand On and Collide With)
					generate_background(chunk_x, chunk_y) # Generate The Background (Tiles Player Can Pass Through)
			else:
				# Odd Y Axis (Odd X Axis)
				# warning-ignore:integer_division
				# warning-ignore:integer_division
				for chunk_y in range((-y_axis/2)-1, (y_axis/2)):
					generate_foreground(chunk_x, chunk_y) # Generate The Foreground (Tiles Player Can Stand On and Collide With)
					generate_background(chunk_x, chunk_y) # Generate The Background (Tiles Player Can Pass Through)

func generate_foreground(chunk_x: int, chunk_y: int, regenerate: bool = false) -> void:
	"""
		Generate Tiles for Foreground Tilemap
		
		Dumps Tiles to World Grid
	"""
	var world_grid : Dictionary = {}
	
	if generated_chunks_foreground.has(Vector2(chunk_x, chunk_y)) and not regenerate:
		# Chunk already exists, do not generate it again.
		# I may add an override if someone wants to regenerate it later.
		
		# A different function will handle loading the world from save.
		return
		
	generated_chunks_foreground.append(Vector2(chunk_x, chunk_y))
	
	var noise = OpenSimplexNoise.new() # Create New SimplexNoise Generator
	
	# Get Chunk Generation Coordinates (allows finding where to spawn chunk)
	# warning-ignore:narrowing_conversion
	var horizontal : int = chunk_size.x + (quadrant_size * chunk_x)
	# warning-ignore:narrowing_conversion
	var vertical : int = chunk_size.y + (quadrant_size * chunk_y)
	
	# World Gen Code
	for coor_x in range((horizontal - quadrant_size), horizontal):
		# Configure Simplex Noise Generator (runs every x coordinate)
		noise.seed = generator.randi()
		noise.octaves = 4
		noise.period = 20.0
		noise.lacunarity = 1.5
		noise.persistence = 0.8
		
		# How do I force this to be in the chunk? Should I force this to a chunk? I think yes.
		var noise_output : int = int(floor(noise.get_noise_2d(vertical, vertical + quadrant_size) * 5)) + 15
		#var noise_output : int = int(floor(noise.get_noise_2d((get_global_transform().origin.x + coor_x) * 0.1, 0) * vertical * 0.2)) - Modified From Non-Tilemap Generation Video (does not translate well :P)
		
		world_grid[coor_x] = {} # I set the Dictionary here because I may move away from the coor_x variable for custom worldgen types
		
		if noise_output < 0:
			world_grid[coor_x][noise_output] = block.grass
		else:
			world_grid[coor_x][noise_output] = block.dirt
		
		#print(noise_output)

	apply_foreground(world_grid) # Apply World Grid to TileMap

# Generates The Background Tiles
func generate_background(chunk_x: int, chunk_y: int, regenerate: bool = false):
	"""
		Generate Tiles for Background Tilemap
		
		Dumps Tiles to World Grid
	"""
	var world_grid : Dictionary = {}
	
	if generated_chunks_background.has(Vector2(chunk_x, chunk_y)) and not regenerate:
		# Chunk already exists, do not generate it again.
		# I may add an override if someone wants to regenerate it later.
		
		# A different function will handle loading the world from save.
		return
		
	generated_chunks_background.append(Vector2(chunk_x, chunk_y))
	
	# Get Chunk Generation Coordinates (allows finding where to spawn chunk)
	# warning-ignore:narrowing_conversion
	var horizontal : int = chunk_size.x + (quadrant_size * chunk_x)
	# warning-ignore:narrowing_conversion
	var vertical : int = chunk_size.y + (quadrant_size * chunk_y)

	# NOTE (Important): This is for testing the chunk selection process
	var random_block : int = generator.randi() % (block.size() - 1)

	# World Gen Code
	for coor_x in range((horizontal - quadrant_size), horizontal):
		world_grid[coor_x] = {}

		for coor_y in range((vertical - quadrant_size), vertical):
			world_grid[coor_x][coor_y] = random_block

	apply_background(world_grid) # Apply World Grid to TileMap

func apply_foreground(world_grid: Dictionary) -> void:
	"""
		Applies World Grid to Foreground TileMap
		
		Not Meant To Be Called Directly
	"""
	
	# Set's Tile ID in Tilemap from World Grid
	for coor_x in world_grid.keys():
		for coor_y in world_grid[coor_x].keys():
			#print("Coordinate: (", coor_x, ", ", coor_y, ") - Value: ", world_grid[coor_x][coor_y])
			if self != null:
				set_cell(coor_x, coor_y, world_grid[coor_x][coor_y])

func apply_background(world_grid: Dictionary) -> void:
	"""
		Applies World Grid to Background TileMap
		
		Not Meant To Be Called Directly
	"""
	
	# Z-Index for Background is -1 (Foreground is 0).
	# This Makes Foreground Cover Up Background
	
	# Set's Tile ID in Tilemap from World Grid
	for coor_x in world_grid.keys():
		for coor_y in world_grid[coor_x].keys():
			print("Coordinate: (", coor_x, ", ", coor_y, ") - Value: ", world_grid[coor_x][coor_y])
			
			# The null check does not work on either foreground or background
			# https://www.reddit.com/r/godot/comments/csbptd/help_tracking_down_cause_of_two_errors_which/
			
			# Errors That Cause Segfault with set_cell(...) caused by client and crashes server
			# E 0:01:20:0414 Condition ' p_elem->_static && p_with->_static ' is true. <C Source> servers/physics_2d/broad_phase_2d_hash_grid.cpp:40 @ _pair_attempt() - https://github.com/godotengine/godot/blob/3cbd4337ce5bd3d589cd96e1a371d417be781841/servers/physics_2d/broad_phase_2d_hash_grid.cpp#L40
			# ERROR: set_static: Condition ' !E ' is true. At: servers/physics_2d/broad_phase_2d_hash_grid.cpp:364 - https://github.com/godotengine/godot/blob/12ae7a4c02c186e9f136a7d4a8ea9f6f4805f718/servers/physics_2d/broad_phase_2d_hash_grid.cpp#L364
			
			print("Background Tilemap: ", background_tilemap)
			if background_tilemap != null:
				print("Set Cell!!!")
				#background_tilemap.set_cell(coor_x, coor_y, world_grid[coor_x][coor_y])
				# Number of Tiles in WorldGrid is 16^16 (16 chunks)
				var cell = world_grid[coor_x][coor_y]
				background_tilemap.set_cell(coor_x, coor_y, cell)
				pass

# This will be replaced by a chunk loading system later.
func load_foreground(tiles: Dictionary):
	var world_grid : Dictionary = {}
	
#	# Chunk Coordinates (not same as world coordinates)
#	var chunk_x : int
#	var chunk_y : int
#
#	# Convert Coordinates From Save to Vector2
	var coor : Vector2
	
	for tile in tiles:
		# I have to explicitly specify that it is a Vector2 - https://github.com/godotengine/godot/issues/11438#issuecomment-330821814
		coor = str2var("Vector2" + tile)

#		# I was going to use this to dynamically create chunk data, then I realized "What if the user manually cleared the chunk?"
#		chunk_x = (coor.x - chunk_size.x) / quadrant_size
#		chunk_y = (coor.y - chunk_size.y) / quadrant_size
#
#		#print("Foreground Chunk Load: (%s, %s)" % [chunk_x, chunk_y])
#
#		if not generated_chunks_foreground.has(Vector2(chunk_x, chunk_y)):
#			generated_chunks_foreground.append(Vector2(chunk_x, chunk_y))
		
		if not world_grid.has(coor.x):
			world_grid[coor.x] = {}
		
		world_grid[coor.x][coor.y] = tiles[str(tile)]
		#print("Tile: ", world_grid[coor.x][coor.y])
	
	apply_foreground(world_grid)
	
# This will be replaced by a chunk loading system later.
func load_background(tiles: Dictionary):
	var world_grid : Dictionary = {}
	
#	# Chunk Coordinates (not same as world coordinates)
#	var chunk_x : int
#	var chunk_y : int
	
	# Convert Coordinates From Save to Vector2
	var coor : Vector2
	
	for tile in tiles:
		# I have to explicitly specify that it is a Vector2 - https://github.com/godotengine/godot/issues/11438#issuecomment-330821814
		coor = str2var("Vector2" + tile)
		
		# I was going to use this to dynamically create chunk data, then I realized "What if the user manually cleared the chunk?"
#		chunk_x = (coor.x - chunk_size.x) / quadrant_size
#		chunk_y = (coor.y - chunk_size.y) / quadrant_size
#
#		#print("Background Chunk Load: (%s, %s)" % [chunk_x, chunk_y])
#
#		if not generated_chunks_background.has(Vector2(chunk_x, chunk_y)):
#			generated_chunks_background.append(Vector2(chunk_x, chunk_y))
		
		if not world_grid.has(coor.x):
			world_grid[coor.x] = {}
		
		world_grid[coor.x][coor.y] = tiles[str(tile)]
		#print("Tile: ", world_grid[coor.x][coor.y])
	
	apply_background(world_grid)

func generate_seed() -> int:
	"""
		Generates a Seed and Set as World's Seed
	"""
	
	generator.randomize() # This is void, and I cannot get the seed directly, so I have to improvise.
	var random_seed : int = generator.randi() # Generate a random int to use as a seed
	
	world_seed = str(random_seed)
	generator.seed = random_seed # Activate Random Generator With Seed
	
	return random_seed # Returns seed for saving for player and inputting into generator later

func set_seed(random_seed: String) -> int:
	"""
		Sets World's Seed
	"""
	
	world_seed = random_seed
	
	# If Not A Pure Integer (in String form), then Hash String To Integer
	if not world_seed.is_valid_integer():
		generator.seed = world_seed.hash() # Activate Random Generator With Seed
		return world_seed.hash()
		
	# If Pure Integer (in String form), then convert to Integer Type
	generator.seed = int(world_seed) # Activate Random Generator With Seed
	return int(world_seed)

# Convert Chunks From File to Vector2
func load_chunks_foreground(chunks: Array) -> void:
	var chunk_coor : Vector2
	
	for chunk in chunks:
		chunk_coor = str2var("Vector2" + chunk)
		
		if not generated_chunks_foreground.has(chunk_coor):
			generated_chunks_foreground.append(chunk_coor)

# Convert Chunks From File to Vector2
func load_chunks_background(chunks: Array) -> void:
	var chunk_coor : Vector2
	
	for chunk in chunks:
		chunk_coor = str2var("Vector2" + chunk)
		
		if not generated_chunks_background.has(chunk_coor):
			generated_chunks_background.append(chunk_coor)

# Find safe spawn location - bound to change with world gen code
func find_safe_spawn(position: Vector2) -> Vector2:
	# This function will take a random player's position (chosen by any spawn code) and return a vector2 which is considered safe.
	# The vector2 is the new set of coordinates to use for spawning the player.
	# Since gravity will be enabled in the released game, the goal is to spawn the player right above the safe block.
	var player_cell : Vector2 = self.world_to_map(position)
	var unsafe : bool = true
	var count : int = 0
	
	# return Vector2(-2532, 192) # Useful for debugging camera positioning
	
	# Spawn below 440 y-axis (up).
	
	print("Position: ", position)
	print("Cell Position: ", player_cell)
	
	while unsafe and count < 100:
		count = count + 1 # Keeps from infinite loop
		
		for coor_x in range(player_cell.x - 2, player_cell.x + 2):
			for coor_y in range(player_cell.y, player_cell.y + 2):
				#print("Cell (%s, %s): %s" % [coor_x, coor_y, self.get_cell(coor_x, coor_y)])
				
				if self.get_cell(coor_x, coor_y) != -1:
					# This is a start to picking a decent spawn location
					player_cell = player_cell + Vector2(rand_range(-5, 5), rand_range(-2, 0)) # Remember, the y axis is inverted (not my choice).
					unsafe = true
					break
				else:
					unsafe = false
	
#		if get_cellv(player_cell - Vector2(0, -1)) == -1:
#			unsafe = true
	
	position = map_to_world(player_cell)
	return position

func clear_player_chunks(net_id: int) -> bool:
	if not player_chunks.has(net_id):
		return false
		
	player_chunks.erase(net_id)
	return true
