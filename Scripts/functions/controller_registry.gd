extends Node

# Controllers for Windows PC - https://windowsreport.com/pc-gaming-controller-windows-10/

# Used to Determine Type of Controller For Button Hints
enum controller_types {
	unknown = -1,
	xbox = 0,
	dualshock = 1,
	wiimote = 2,
}

# Used to Help Automatically Identify Controller Type for Button Hints
# Left As Variable So It Could Be Added To During Runtime
var controllers : Dictionary = {
	"4c05000000000000cc09000000000000": {
		"type": controller_types.dualshock
	}
}
