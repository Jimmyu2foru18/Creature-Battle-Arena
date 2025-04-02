extends Node

# AutoloadManager - Registers all singleton systems for the game

func _ready():
    # Register systems if they don't already exist
    register_system("ExperienceSystem", "res://scripts/ExperienceSystem.gd")
    register_system("ScoreSystem", "res://scripts/ScoreSystem.gd")
    register_system("SaveSystem", "res://scripts/SaveSystem.gd")
    
    print("AutoloadManager: All systems registered")

# Register a system as an autoload/singleton if it doesn't already exist
func register_system(name, script_path):
    if not has_node("/root/" + name):
        var script = load(script_path)
        if script:
            var node = Node.new()
            node.set_script(script)
            node.name = name
            get_tree().root.add_child(node)
            print("AutoloadManager: Registered " + name)
        else:
            push_error("AutoloadManager: Failed to load script " + script_path)
    else:
        print("AutoloadManager: " + name + " already registered")