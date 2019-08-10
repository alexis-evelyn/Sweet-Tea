extends TileMap

# Non-Tilemap Generation - https://www.youtube.com/watch?v=skln7GPdB_A&list=PL0t9iz007UitFwiu33Vx4ZnjYQHH9th2r
# How Many Tilemaps - https://godotengine.org/qa/17780/create-multiple-small-tilemaps-or-just-a-giant
# 2D Tilemaps Chunk Theory - https://www.gamedev.net/forums/topic/653120-2d-tilemaps-chunk-theory/
# Intro Tilemap Procedural Generation (Reddit) - https://www.reddit.com/r/godot/comments/8v2xco/introduction_to_procedural_generation_with_godot/
# Into Tilemap Procedural Generation (Article) - https://steincodes.tumblr.com/post/175407913859/introduction-to-procedural-generation-with-godot

# Note: I am using a Tilemap to improve performance.
# This does mean world manipulation will be more complicated, but performance cannot be passed up.
# I am using SteinCode's Tumblr Article to help me get started.

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var grid : Array = []

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
				grid[n][m] = 0
			else:
				grid[n][m] = 1

	for n in range(0,16):
		for m in range(0,16):
			set_cell(n, m, grid[n][m])

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
