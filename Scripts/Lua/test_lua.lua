local class = require 'lua.class' -- Import the system class library
godot.Node = require 'godot.Node' -- Make sure to import the base class


local NewScript = class.extends(godot.Node) -- Create the user subclass

function NewScript:_ready()
	print("Hello Lua")
end

function NewScript:_process(delta)

end

function NewScript:command(variable)
	return "Variable: %s" % variable
end

function NewScript:get_class()
	return "Test Lua"
end

return NewScript
