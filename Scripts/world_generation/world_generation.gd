extends TileMap

# Non-Tilemap Generation - https://www.youtube.com/watch?v=skln7GPdB_A&list=PL0t9iz007UitFwiu33Vx4ZnjYQHH9th2r
# How Many Tilemaps - https://godotengine.org/qa/17780/create-multiple-small-tilemaps-or-just-a-giant
# 2D Tilemaps Chunk Theory - https://www.gamedev.net/forums/topic/653120-2d-tilemaps-chunk-theory/
# Intro Tilemap Procedural Generation (Reddit) - https://www.reddit.com/r/godot/comments/8v2xco/introduction_to_procedural_generation_with_godot/
# Into Tilemap Procedural Generation (Article) - https://steincodes.tumblr.com/post/175407913859/introduction-to-procedural-generation-with-godot
# Large Tilemap Generation - https://godotengine.org/qa/1121/how-go-about-generating-very-large-or-infinite-map-from-tiles
# Tilemap Docs - https://docs.godotengine.org/en/3.0/classes/class_tilemap.html

# Note: I am using a Tilemap to improve performance.
# This does mean world manipulation will be more complicated, but performance cannot be passed up.
# I am using SteinCode's Tumblr Article to help me get started.

# Declare member variables here. Examples:
var grid : Array = []

const block_air = -1 # -1 means no tile exists - there is no such thing as block_air. It is just void.
const block_stone = 0
const block_dirt = 1
const block_grass = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Code Came From SteinCodes Tutorial - Will Severaly Modify and Make Variable Names Meaningful
	randomize()
	
	grid.resize(17)
	
	for n in 17:
		grid[n] = []
		grid[n].resize(17)
		for m in 17:
			if (n%15 == 0 or m%8 == 0) and randi()%20 != 0:
				grid[n][m] = block_stone
			else:
				grid[n][m] = block_air

	for n in range(0,16):
		for m in range(0,16):
			set_cell(n, m, grid[n][m])

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
