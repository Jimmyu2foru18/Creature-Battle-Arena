# 2D Turn-Based Pokémon-Like Game Design Document

## Game Overview
A 2D turn-based game inspired by Pokémon, featuring creature collection, battling, and exploration with a leveling system and score tracking.

## Core Features

### Creature System
- **Creatures**: Various monsters with unique stats, abilities, and types
- **Types**: Elemental types with strengths/weaknesses (Fire, Water, Grass, etc.)
- **Abilities**: Special moves with different effects and power levels
- **Evolution**: Creatures evolve at specific levels or conditions

### Battle System
- **Turn-based Combat**: Players and opponents take alternating turns
- **Move Selection**: Each creature has 4 moves to choose from
- **Type Effectiveness**: Damage multipliers based on type matchups
- **Status Effects**: Conditions like poison, sleep, paralysis affecting creatures
- **Battle Rewards**: Experience points, items, and score points

### World & Exploration
- **Overworld Map**: 2D top-down view with various environments
- **NPCs**: Trainers to battle and characters to interact with
- **Items**: Collectibles for healing, capturing creatures, and enhancing stats
- **Obstacles**: Puzzles and barriers requiring specific abilities to overcome

### Progression System
- **Experience Points**: Gained from battles to level up creatures
- **Levels**: Increasing stats and unlocking new abilities
- **Badges/Achievements**: Rewards for completing significant challenges
- **Story Progression**: Main quest line with multiple objectives

### Score System
- **Battle Performance**: Points based on efficiency and strategy
- **Collection Completion**: Bonus points for discovering all creatures
- **Time Challenges**: Speed-based achievements
- **Combo System**: Bonus points for consecutive successful actions
- **Global Leaderboard**: Compare scores with other players

## Technical Implementation

### Asset Structure
```
/assets
  /creatures
    /creature1
      idle.png
      attack.png
      hurt.png
    /creature2
      ...
  /characters
    /player
      walk_up.png
      walk_down.png
      walk_left.png
      walk_right.png
    /npcs
      ...
  /environments
    /grass
    /water
    /cave
    ...
  /ui
    /battle
    /menu
    /hud
    ...
  /effects
    ...
```

### Dynamic Sprite Loading
- System will scan the `/creatures` directory to automatically load available creatures
- Each creature folder should contain standard animation states (idle, attack, hurt)
- Support for both PNG and JPG formats
- Automatic scaling and positioning based on sprite dimensions

### Data Structure
- **Creature Data**: JSON files defining stats, moves, evolution paths
- **Move Database**: Effects, power, accuracy, and type information
- **Type Chart**: Matrix of effectiveness multipliers
- **Map Data**: Tile-based layouts with event triggers

### Game States
1. **Exploration Mode**: Moving through the world map
2. **Battle Mode**: Turn-based combat interface
3. **Menu Mode**: Inventory, creature management, save/load
4. **Dialogue Mode**: Conversations with NPCs

## User Interface

### Main HUD
- Current score display
- Active creature health and level
- Mini-map for navigation
- Notification area for events

### Battle Screen
- Creature sprites with health bars
- Move selection menu
- Battle log displaying recent actions
- Options for items, switching creatures, or fleeing

### Menu System
- Creature roster with stats and abilities
- Inventory management
- Save/Load functionality
- Options and settings

## Development Roadmap

### Phase 1: Core Systems
- Basic game engine setup
- Creature data structure implementation
- Simple battle mechanics
- Dynamic sprite loading system

### Phase 2: Content Development
- Create initial set of creatures
- Design starting map areas
- Implement basic NPC interactions
- Add preliminary scoring system

### Phase 3: Refinement
- Balance creature stats and abilities
- Enhance battle animations and effects
- Implement advanced scoring features
- Add sound effects and music

### Phase 4: Polish & Expansion
- Bug fixing and performance optimization
- Additional creatures and areas
- Advanced battle mechanics
- Leaderboard implementation

## Technical Requirements
- Game engine with 2D sprite support
- JSON parsing for data management
- File system access for dynamic asset loading
- User input handling for controls
- Save/load functionality for game state persistence

## Tech Stack

### Game Engine
- **Godot Engine**: Free, open-source engine with excellent 2D support
  - GDScript (Python-like) for easier learning curve
  - Built-in physics and collision detection
  - Node-based architecture for intuitive game object management
  - Cross-platform capabilities

### Frontend
- **Godot UI System**: Built-in UI controls and theming
- **Tween Nodes**: For simple animations and transitions
- **ViewportContainer**: For managing different game views

### Backend & Data Management
- **JSON**: Simple text-based data format for game data
- **File I/O**: Basic file operations for save/load functionality
- **Dictionary and Array**: Native data structures for game state management
- **Directory class**: For scanning folders to load creature sprites dynamically

### Asset Creation & Management
- **GIMP** or **Krita**: Free alternatives for sprite creation
- **Piskel**: Browser-based sprite editor for simple animations
- **Tiled**: Free map editor that exports to common formats
- **Audacity**: Free audio recording and editing

### Version Control & Project Management
- **Git**: Basic version control
- **GitHub**: Free repository hosting with student benefits
- **Trello**: Free project management board for task tracking

### Testing
- **Print statements**: For basic debugging
- **Godot's built-in debugger**: For runtime inspection
- **Manual testing**: Playtesting with peers for feedback

### Build & Deployment
- **Godot Export Templates**: For creating executable builds
- **itch.io**: Free game hosting platform for sharing projects
- **GitHub Pages**: For hosting web builds of the game

This tech stack is designed to be accessible for undergraduate students with limited prior experience in game development. The tools are mostly free or have educational licenses available, and the learning resources for these technologies are abundant online.