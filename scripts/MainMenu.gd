extends Control

# References to UI elements
onready var start_button = $VBoxContainer/StartButton
onready var highscores_button = $VBoxContainer/HighscoresButton
onready var quit_button = $VBoxContainer/QuitButton
onready var title_label = $TitleLabel

func _ready():
    # Connect button signals
    start_button.connect("pressed", self, "_on_start_button_pressed")
    highscores_button.connect("pressed", self, "_on_highscores_button_pressed")
    quit_button.connect("pressed", self, "_on_quit_button_pressed")
    
    # Set game title
    title_label.text = "Creature Battle Arena"

# Start a new game
func _on_start_button_pressed():
    # Initialize a new game using BattleManager
    var battle_manager = get_node("/root/BattleManager")
    if battle_manager:
        battle_manager.start_new_game()
    else:
        push_error("BattleManager not found!")

# Show high scores
func _on_highscores_button_pressed():
    # Show high scores dialog
    var dialog = AcceptDialog.new()
    dialog.window_title = "High Scores"
    
    # Load high scores from file
    var scores = load_high_scores()
    var score_text = "Top Scores:\n"
    
    if scores.empty():
        score_text += "No scores yet!"
    else:
        # Sort scores in descending order
        scores.sort_custom(self, "sort_scores_descending")
        
        # Display top 5 scores
        for i in range(min(5, scores.size())):
            score_text += "%d. %s: %d\n" % [i+1, scores[i].name, scores[i].score]
    
    dialog.dialog_text = score_text
    add_child(dialog)
    dialog.popup_centered()

# Custom sort function for scores
func sort_scores_descending(a, b):
    return a.score > b.score

# Load high scores from file
func load_high_scores():
    var scores = []
    var file = File.new()
    
    if file.file_exists("user://highscores.json"):
        file.open("user://highscores.json", File.READ)
        var text = file.get_as_text()
        file.close()
        
        var result = parse_json(text)
        if result != null and typeof(result) == TYPE_ARRAY:
            scores = result
    
    return scores

# Quit the game
func _on_quit_button_pressed():
    get_tree().quit()