extends TileMap

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
const block_air : int = -1 # -1 means no tile exists - there is no such thing as block_air. It is just void.
const block_stone : int = 0
const block_dirt : int = 1
const block_grass : int = 2

# Set's Worldgen size (Tilemap's Origin is Fixed to Same Spot as World Origin - I doubt I am changing this. Not unless changing it improves performance)
const world_size : Vector2 = Vector2(100, 100) # Tilemap is 32x32 (the size of a standard block) pixels per tile.
var quadrant_size : int = get_quadrant_size() # Default 16
var world_seed : String # World Seed Variable

onready var background_tilemap : TileMap = get_node("Background") # Gets The Background Tilemap

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gamestate.debug_camera = true # Turns on Debug Camera - Useful for Debugging World Gen
	
	#seed(generate_seed()) # Takes an Integer and Seed's the random number generator (allows reproducing a previously discovered world)
	seed(set_seed("Test Seed"))
	
	generate_foreground() # Generate The Foreground (Tiles Player Can Stand On and Collide With)
	generate_background() # Generate The Background (Tiles Player Can Pass Through)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float):
#	pass

func generate_foreground() -> void:
	world_grid.clear() # Empty World_Grid for New Data
	var noise = OpenSimplexNoise.new() # Create New SimplexNoise Generator
	
	# Get World Generation Size
	var horizontal : int = world_size.x
	var vertical : int = world_size.y
	
	# World Gen Code
	for coor_x in horizontal:
		# Configure Simplex Noise Generator (runs every x coordinate)
		noise.seed = randi()
		noise.octaves = 4
		noise.period = 20.0
		noise.persistence = 0.8
		
		var noise_output : float = int(floor(noise.get_noise_2d(0, vertical)))
		world_grid[coor_x] = {} # I set the Dictionary here because I may move away from the coor_x variable for custom worldgen types
		
		if noise_output < 0:
			world_grid[coor_x][noise_output] = block_grass
		else:
			world_grid[coor_x][noise_output] = block_dirt
		
		#print(noise_output)

	apply_foreground() # Apply World Grid to TileMap

# Generates The Background Tiles
func generate_background():
	world_grid.clear() # Empty World_Grid for New Data
	
	# Code Came From SteinCodes Tutorial - Will Severely Modify and Make Variable Names Meaningful
	var horizontal : int = world_size.x
	var vertical : int = world_size.y

	# World Gen Code
	for coor_x in horizontal:
		world_grid[coor_x] = {}

		for coor_y in vertical:
			# Just Playing Around With World Gen Code - This Experimentation May Take A While (I am going to research existing algorithms that I can start from (legally))
			if (coor_y > (vertical/2)):
				world_grid[coor_x][coor_y] = block_stone
			elif (coor_y > (vertical/3)):
				if randi() % 100 == 0:
					world_grid[coor_x][coor_y] = block_stone
				else:
					world_grid[coor_x][coor_y] = block_dirt
			else:
				world_grid[coor_x][coor_y] = block_air

	apply_background() # Apply World Grid to TileMap

# Takes World Grid and Applies Grid to TileMap
func apply_foreground() -> void:
	# Set's Tile ID in Tilemap from World Grid
	for coor_x in world_grid.keys():
		for coor_y in world_grid[coor_x].keys():
			#print("Coordinate: (", coor_x, ", ", coor_y, ") - Value: ", world_grid[coor_x][coor_y])
			set_cell(coor_x, coor_y, world_grid[coor_x][coor_y])

# Takes World Grid and Applies Grid to TileMap
func apply_background() -> void:
	# Set's Tile ID in Tilemap from World Grid
	for coor_x in world_grid.keys():
		for coor_y in world_grid[coor_x].keys():
			#print("Coordinate: (", coor_x, ", ", coor_y, ") - Value: ", world_grid[coor_x][coor_y])
			background_tilemap.set_cell(coor_x, coor_y, world_grid[coor_x][coor_y])

# Generates A Seed if One Was Not Specified
func generate_seed() -> int:
	randomize() # This is void, and I cannot get the seed directly, so I have to improvise.
	
	return randi() # Generate a random int to use as a seed (and returns it for saving for player and inputting into generator later)

# Sets World's Seed
func set_seed(random_seed: String) -> int:
	world_seed = random_seed
	#seed(random_seed.hash())
	return world_seed.hash()
