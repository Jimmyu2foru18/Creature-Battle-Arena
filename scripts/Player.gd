extends KinematicBody2D

export var speed = 200
var velocity = Vector2.ZERO
var facing_direction = Vector2.DOWN

# Animation states
enum AnimState {IDLE, WALK}
var current_anim_state = AnimState.IDLE

# References
onready var animation_player = $AnimationPlayer
onready var sprite = $Sprite
onready var collision_shape = $CollisionShape2D
onready var interaction_area = $InteractionArea

func _ready():
    update_animation()

func _physics_process(delta):
    # Don't process movement if not in exploration mode
    if GameManager.current_state != GameManager.GameState.EXPLORATION:
        velocity = Vector2.ZERO
        update_animation()
        return
    
    # Get input direction
    var input_direction = Vector2.ZERO
    input_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    input_direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
    input_direction = input_direction.normalized()
    
    # Update velocity
    velocity = input_direction * speed
    
    # Update facing direction if moving
    if input_direction != Vector2.ZERO:
        facing_direction = input_direction
    
    # Move the character
    velocity = move_and_slide(velocity)
    
    # Update animation state
    if velocity.length() > 0:
        current_anim_state = AnimState.WALK
    else:
        current_anim_state = AnimState.IDLE
    
    update_animation()
    
    # Check for interaction input
    if Input.is_action_just_pressed("interact"):
        interact()
    
    # Check for menu input
    if Input.is_action_just_pressed("menu"):
        open_menu()

# Update the character's animation based on state and direction
func update_animation():
    var anim_name = "idle_down"  # Default animation
    
    # Determine direction suffix
    var dir_suffix = ""
    if abs(facing_direction.x) > abs(facing_direction.y):
        # Horizontal movement is dominant
        dir_suffix = "_right" if facing_direction.x > 0 else "_left"
    else:
        # Vertical movement is dominant
        dir_suffix = "_down" if facing_direction.y > 0 else "_up"
    
    # Determine animation prefix based on state
    var anim_prefix = "idle" if current_anim_state == AnimState.IDLE else "walk"
    
    # Combine to get full animation name
    anim_name = anim_prefix + dir_suffix
    
    # Play the animation if it's not already playing
    if animation_player.current_animation != anim_name:
        animation_player.play(anim_name)

# Interact with objects or NPCs in front of the player
func interact():
    # Position the interaction area in front of the player
    interaction_area.position = facing_direction * 32  # Adjust based on tile size
    
    # Check for interactable objects
    var overlapping_bodies = interaction_area.get_overlapping_bodies()
    for body in overlapping_bodies:
        if body.has_method("interact"):
            body.interact(self)
            return

# Open the game menu
func open_menu():
    GameManager.change_state(GameManager.GameState.MENU)
    # Here you would show the menu UI
    # $UI/Menu.show()

# Check for wild creature encounters when walking in tall grass
func check_for_wild_encounter():
    # This would be called when the player steps on a "tall grass" tile
    if randf() < GameManager.wild_encounter_rate:
        # Determine which creature to encounter based on the current area
        var creature_id = "creature1"  # For simplicity, always encounter Leafling
        var level = randi() % 5 + 1  # Random level between 1 and 5
        
        var wild_creature = GameManager.create_creature(creature_id, level)
        if wild_creature != null:
            GameManager.start_battle(wild_creature)