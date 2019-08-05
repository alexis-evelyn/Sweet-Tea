# 3.2.dev export template download (2 files needed) - https://hugo.pro/projects/godot-builds/
# Actually, you need to compile the export template (because of custom modules)
# http://docs.godotengine.org/en/stable/development/compiling/compiling_for_windows.html#creating-windows-export-templates
# https://docs.godotengine.org/en/3.1/development/compiling/compiling_for_x11.html#building-export-templates
# OSX does not have explicit instructions on how to compile export templates - http://docs.godotengine.org/en/stable/development/compiling/compiling_for_osx.html

# Since I Use Mac, I Am Leaving A Link About Cross Compiling Godot
# http://docs.godotengine.org/en/stable/development/compiling/compiling_for_windows.html#cross-compiling-for-windows-from-other-operating-systems
# It appears I cannot cross compile for Linux from Mac, so I will have to install a Linux VM when I get close to releasing the game
# Cross Compiling for Windows is not working for my Mac either, so I will need to reinstall Windows in a VM at the same time I reinstall the Linux VM

# On the other hand, I uploaded the custom version of Godot I modified to https://github.com/SenorContento/Godot-3.2-Sweet-Tea.
# There's a script in the project root that is meant to be compiled on a Mac with Homebrew installed.
# You will have to install scons via homebrew and make sure that your working directory is the project root before you execute the script.