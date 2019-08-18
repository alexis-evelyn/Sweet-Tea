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

# Declare member variables here. Examples:
var world_grid : Dictionary = {} # I use a dictionary so I can have negative coordinates.

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
var world_size : Vector2 = Vector2(10, 10) # (Whole numbers) Odd numbers will be rounded down to the nearest (Whole) even number.

onready var world_node = self.get_owner() # Gets The Current World's Node
onready var background_tilemap : TileMap = get_node("Background") # Gets The Background Tilemap
var background_shader : ShaderMaterial = load("res://Assets/Materials/background.tres") # ShaderMaterial (for shading background tilemap)

export(String) var world_seed : String # World's Seed (used by generator to produce consistent results)
export(Array) var generated_chunks_foreground : Array # Store Generated Chunks IDs to Make Sure Not To Generate Them Again
export(Array) var generated_chunks_background : Array # Store Generated Chunks IDs to Make Sure Not To Generate Them Again

# This gives the each instance of the world generator access to its own exclusive random number generator so it will not be interfered with by other generators.
var generator : RandomNumberGenerator = RandomNumberGenerator.new()

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
	
	# TODO (IMPORTANT): How Do I Make Background and Foreground Use Different Instances of the Same Tileset???
	# Right now, the shader sets for both foreground and background because of sharing same tileset and using load(...) twice does not solve the issue.
	
	# Loops Through Tiles in Tileset and Applies Shader(s)
	for tile in background_tilemap.tile_set.get_tiles_ids():
		background_tilemap.tile_set.tile_set_material(tile, background_shader)

# Load or Generate New Chunks for Player (Server Side)
# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func load_chunks(net_id: int, position: Vector2, render_distance: Vector2 = Vector2(7, 5)):
	# render_distance - This is different from the world_size as this is generating/loading the world from the player's position and won't be halved (will be configurable). Halving it will make it only able to load an even number of chunks.
	
	# How Minecraft's Server-Client Chunk Transmission Works - https://github.com/ORelio/Minecraft-Console-Client/issues/140#issuecomment-207971227
	# Potential Problem With Minecraft's Server-Client Chunk Transmission - https://bugs.mojang.com/plugins/servlet/mobile#issue/MC-145813
	
	# Because the client is not allowed to request chunks (for security and performance reasons), the server has no way of knowing if a client has unloaded chunks.
	# The client could abuse the server if it was allowed to request chunks again, so the server has to keep track of what chunks should be loaded on the client's side.
	# Basically, what this function needs to do (before determining if it should load or generate chunks) is take a given amount of chunks (say world height times 10 chunks horizontally)...
	# and then do math from the client's coordinates (which the server has authority over) to determine which chunks to load/generate and then send to the client.
	# It is the client's job to make sure it doesn't unload chunks that it should keep track of.
	
	# NOTE (IMPORTANT): When using player camera, the player can see at most 3 chunks on one axis. At most 9 chunks total.
	# Render distance does not exist because this is a 2D game. The server render distance will override the client's distance. If the client has a higher distance, it will just cache the chunks for later.
	# This means that the chunk loader will load and send at least 9 chunks in all directions (providing we did not hit the ceiling or floor - I plan on looping the world on the horizontal axis*).
	# To be help with NPCs moving offscreen, I will make the chunk loader add one chunk to each side of both axes by default (can be configurable). This will result in a total of 13 chunks loaded and sent by server.
	
	# Actually, let's do two extra chunks for the x-axis and 1 extra chunk for the y-axis (results in Vector2(7, 5)).
	
	# * - Looping the world on the horizontal access only applies to non-infinite worlds. Release will only support non-infinite worlds (afterwards if the game does well, I will work on infinite worlds). 
	#print("Player %s has Position %s!!!" % [net_id, position])
	pass

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
	
	if generated_chunks_foreground.has(Vector2(chunk_x, chunk_y)) and not regenerate:
		# Chunk already exists, do not generate it again.
		# I may add an override if someone wants to regenerate it later.
		
		# A different function will handle loading the world from save.
		return
		
	generated_chunks_foreground.append(Vector2(chunk_x, chunk_y))
	
	world_grid.clear() # Empty World_Grid for New Data
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

	apply_foreground() # Apply World Grid to TileMap

# Generates The Background Tiles
func generate_background(chunk_x: int, chunk_y: int, regenerate: bool = false):
	"""
		Generate Tiles for Background Tilemap
		
		Dumps Tiles to World Grid
	"""
	
	if generated_chunks_background.has(Vector2(chunk_x, chunk_y)) and not regenerate:
		# Chunk already exists, do not generate it again.
		# I may add an override if someone wants to regenerate it later.
		
		# A different function will handle loading the world from save.
		print("Ran 2!!!")
		return
		
	generated_chunks_background.append(Vector2(chunk_x, chunk_y))
	
	world_grid.clear() # Empty World_Grid for New Data
	
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

	apply_background() # Apply World Grid to TileMap

func apply_foreground() -> void:
	"""
		Applies World Grid to Foreground TileMap
		
		Not Meant To Be Called Directly
	"""
	
	# Set's Tile ID in Tilemap from World Grid
	for coor_x in world_grid.keys():
		for coor_y in world_grid[coor_x].keys():
			#print("Coordinate: (", coor_x, ", ", coor_y, ") - Value: ", world_grid[coor_x][coor_y])
			set_cell(coor_x, coor_y, world_grid[coor_x][coor_y])

func apply_background() -> void:
	"""
		Applies World Grid to Background TileMap
		
		Not Meant To Be Called Directly
	"""
	
	# Z-Index for Background is -1 (Foreground is 0).
	# This Makes Foreground Cover Up Background
	
	# Set's Tile ID in Tilemap from World Grid
	for coor_x in world_grid.keys():
		for coor_y in world_grid[coor_x].keys():
			#print("Coordinate: (", coor_x, ", ", coor_y, ") - Value: ", world_grid[coor_x][coor_y])
			background_tilemap.set_cell(coor_x, coor_y, world_grid[coor_x][coor_y])

# This will be replaced by a chunk loading system later.
func load_foreground(tiles: Dictionary):
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
	
	apply_foreground()
	
# This will be replaced by a chunk loading system later.
func load_background(tiles: Dictionary):
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
	
	apply_background()

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
