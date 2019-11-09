extends Node
class_name Vaccine # It's a joke, but it really is like having a vaccine.

# I MAY IMPLEMENT A VIRUS SCANNER FOR THE VIRTUAL COMPUTERS
# Use https://www.virustotal.com/gui/home/upload to test the EICAR Test Virus (NOT A REAL VIRUS, BUT SHOULD TRIGGER VIRUS SCANNER ANYWAY)!!!

# Declare member variables here. Examples:
var enabled = true # Enable Virus And Spam Scanner

# Because EICAR is Escaped, It Won't Trigger Your Virus Scanner turn 4\\P into 4\P to Trigger Virus Scanner.
# Here's the interesting part, when testing the compiled version on virustotal.com, only five scanners picked up the EICAR string.
# So, most scanners don't work when I just straight up put the string in the file. I split the EICAR test string into two variables
# to prevent a host virus scanner from detecting it (causing my game to look like a virus) as opposed to my in game scanner using it for a test.

# EICAR Explanation Wikipedia - https://en.wikipedia.org/wiki/EICAR_test_file
# EICAR Explanation (Developer's Website) - http://2016.eicar.org/86-0-Intended-use.html
const eicar_part_one = "X5O!P%@AP[4\\PZX54(P^)7CC)7}$EICAR-"
const eicar_part_two = "STANDARD-ANTIVIRUS-TEST-FILE!$H+H*" # EICAR Test File - ¡¡¡NOT A REAL VIRUS!!!

# GTube Explanation Wikipedia - https://en.wikipedia.org/wiki/GTUBE
# GTube Explanation (Developer's Website) - https://spamassassin.apache.org/gtube/
const gtube_part_one = "XJS*C4JDBQADN1.NSBN3*2IDNEN*GTUBE"
const gtube_part_two = "-STANDARD-ANTI-UBE-TEST-EMAIL*C.34X" # GTube Test Line - ¡¡¡NOT REAL SPAM!!!

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)

	print_eicar() # Print EICAR Test Virus
	print_gtube() # Print GTube Test Spam

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func print_eicar() -> void:
	logger.superverbose("EICAR (Test Anti-Malware): %s%s" % [eicar_part_one, eicar_part_two])

func print_gtube() -> void:
	logger.superverbose("GTube (Test Spam Filter): %s%s" % [gtube_part_one, gtube_part_two])

func get_class() -> String:
	return "Vaccine"
