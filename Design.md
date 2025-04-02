# System Design Report

# 2D Turn-Based Game
GROUP X
( Daniyal Shami, Davina Gurcharan )

# Table of Contents
1. Introduction ..........................................................................................................................................4
   1.1 Purpose of the system ............................................................................................................................4
   1.2 Design goals........................................................................................................................................4
      1.2.1 Trade-Offs ....................................................................................................................................5
      1.2.2 Criteria..........................................................................................................................................6
   1.3 Definitions...........................................................................................................................................8
2. System Architecture..............................................................................................................................9
   2.1. Subsystem Decomposition............................................................................................................9
   2.2. Hardware/Software Mapping .....................................................................................................12
   2.3. Persistent Data Management.....................................................................................................12
   2.4. Access Control and Security........................................................................................................12
   2.5. Boundary Conditions...................................................................................................................13
3. Subsystem Services.............................................................................................................................14
   3.1. UserInterface Subsystem............................................................................................................14
   3.2. Management Subsystem ............................................................................................................15
   3.3. Model Subsystem........................................................................................................................17
4. Low-level Design .................................................................................................................................18
   4.1. Final object design ......................................................................................................................18
   4.2. Design Decisions-Design Patterns...............................................................................................23
      4.2.1. Model-View-Controller Pattern ............................................................................................23
      4.2.2. Singleton Design Pattern.......................................................................................................24
      4.2.3. Factory Design Pattern .........................................................................................................24
   4.3. Packages......................................................................................................................................25
      4.3.1. Packages Introduced by Developers.....................................................................................25
      4.3.2. External Library Packages .....................................................................................................25
   4.4. Class Interfaces ...........................................................................................................................27
      4.4.1. MainMenu Class...................................................................................................................27
      4.4.2. PauseMenu Class ................................................................................................................29
      4.4.3. World Class..........................................................................................................................30
      4.4.4. Player Class..........................................................................................................................31
      4.4.5. Creature Class......................................................................................................................34
      4.4.6. BattleSystem Class...............................................................................................................36
      4.4.7. DataLoader Class.................................................................................................................38
      4.4.8. GameManager Class............................................................................................................40
      4.4.9. ExperienceSystem Class.......................................................................................................42
      4.4.10. ScoreSystem Class .............................................................................................................44
      4.4.11. SaveSystem Class...............................................................................................................46
      4.4.12. BattleManager Class..........................................................................................................48
      4.4.13. GameOver Class................................................................................................................50
      4.4.14. MainMenuUI Class............................................................................................................51
      4.4.15. AutoloadManager Class....................................................................................................52
5. Improvement Summary .....................................................................................................................53
6. Contributions in Second Iteration.......................................................................................................55

# 1. Introduction

## 1.1 Purpose of the system
The 2D Turn-Based Pokémon-Like Game is designed to provide players with an engaging and strategic gaming experience centered around collecting, training, and battling creatures. The game aims to deliver a nostalgic yet fresh take on the monster-collecting RPG genre, with intuitive controls, visually appealing graphics, and a compelling progression system. The primary goal is to create an entertaining game that challenges players' strategic thinking while offering a sense of achievement through creature collection and battle victories.

The game is designed to be accessible to newcomers while providing sufficient depth for experienced players. It features a turn-based battle system that emphasizes strategic decision-making, a diverse collection of creatures with unique abilities and types, and an exploration component that encourages discovery and adventure. The scoring system adds a competitive element, allowing players to compare their performance with others through a global leaderboard.

## 1.2 Design goals
Design is a crucial step in creating a successful game system. It helps identify the key design goals that should guide development. As mentioned in our analysis report, there are many non-functional requirements that need further clarification in the design phase. The following sections describe the important design goals for our 2D Turn-Based Pokémon-Like Game.

### 1.2.1 Trade-Offs
**Development Time vs Performance:**
While C++ might offer better performance for game development, we've chosen to implement our project using Godot Engine with GDScript. This decision reduces development time as GDScript is more accessible and has built-in memory management, though it may result in slightly lower performance compared to lower-level languages. The trade-off favors faster development and iteration over maximum performance optimization.

**Space vs Speed:**
For a turn-based game, real-time performance is less critical than in action games. However, we've still optimized for speed in critical areas like battle calculations and creature data retrieval. We've chosen to store some redundant data (like pre-calculated stats) to reduce computation time during gameplay, accepting the increased memory usage as a reasonable trade-off for improved responsiveness.

**Functionality vs Usability:**
Our game presents the core fun of collecting and battling creatures without overwhelming complexity. We've prioritized usability over extensive functionality by limiting the number of creature types, moves, and special abilities to ensure the game remains approachable. The inclusion of a comprehensive tutorial and intuitive UI further enhances usability at the cost of some advanced gameplay features.

**Understandability vs Functionality:**
As mentioned above, our system is designed to be easy to learn and understand. We've simplified some game mechanics (like limiting status effects or type interactions) to make the game more accessible to new players, even though this reduces some strategic depth that hardcore fans might appreciate.

**Memory vs Maintainability:**
During design and analysis, we've factored out common elements of game objects and made extensive use of abstraction. Our goal is to maintain game objects as easily as possible. However, this approach means some objects will have methods and attributes they don't strictly need, causing some unnecessary memory allocation. The benefit of improved maintainability and code clarity outweighs this minor inefficiency.

**Development Time vs User Experience:**
We've chosen to implement the game using Godot Engine, which offers excellent 2D capabilities and cross-platform support. While this may increase development time compared to using simpler frameworks, the enhanced graphics, animation capabilities, and built-in physics will significantly improve the user experience. The trade-off favors a better final product over faster development.

### 1.2.2 Criteria
**End User Criteria**

**Usability:**
The 2D Turn-Based Pokémon-Like Game is designed to be entertaining and user-friendly. The interface is intuitive, allowing players to focus on gameplay rather than figuring out controls. The menu system is simple and understandable, with clear navigation paths and consistent design. Input controls are straightforward, using keyboard or gamepad with familiar mapping schemes.

**Ease of Learning:**
While we provide a comprehensive tutorial, the game is designed to be intuitive enough that players can understand core mechanics through exploration. Battle mechanics, creature evolution, and scoring systems are presented with clear visual feedback and explanatory text when needed. Progressive complexity ensures players aren't overwhelmed with information at the start.

**Performance:**
Performance is important even for turn-based games. We've optimized the game to run smoothly on modest hardware, with quick loading times and responsive UI. Battle animations and effects are designed to be visually appealing without causing performance issues.

**Maintenance Criteria**

**Extendibility:**
The game's design allows for future modifications and feature additions based on player feedback. The modular structure makes it easy to add new creatures, moves, areas, or gameplay mechanics without major restructuring. The data-driven approach using JSON files for creature and move definitions facilitates content expansion.

**Modifiability:**
The game is designed with a multi-layered architecture. This structure makes it easy to modify specific components without affecting others. Subsystems are loosely coupled, allowing changes to one area (like the battle system) without impacting others (like the exploration system).

**Reusability:**
Several subsystems (like the UI framework, data loading system, and save/load functionality) are designed to be reusable in other projects. These components are implemented independently from game-specific logic, making them portable to other games or applications.

**Portability:**
Portability is a key advantage of using the Godot Engine. The game can be compiled for multiple platforms including Windows, macOS, Linux, and potentially mobile devices. This cross-platform capability expands the potential player base without requiring significant platform-specific code.

**Performance Criteria**

**Response Time:**
The game is designed to provide immediate feedback to player actions. Menu selections, battle commands, and character movement all respond within milliseconds. Even complex calculations like damage formulas are optimized to complete quickly, ensuring smooth gameplay progression.

## 1.3 Definitions, Acronyms & Abbreviations

**Godot Engine** – An open-source game engine used for developing the game.

**GDScript** – The primary scripting language used in Godot Engine.

**MVC (Model-View-Controller)** – The architectural pattern used to structure the game's codebase.

**JSON (JavaScript Object Notation)** – A lightweight data-interchange format used for storing game data.

**UI (User Interface)** – The visual elements through which players interact with the game.

**NPC (Non-Player Character)** – Computer-controlled characters that populate the game world.

**HP (Hit Points)** – A numerical value representing a creature's health.

**XP (Experience Points)** – Points gained from battles that contribute to a creature's growth.

**PP (Power Points)** – The number of times a move can be used before needing restoration.

# 2. System Architecture

## 2.1. Subsystem Decomposition

![Subsystem Decomposition Diagram]

In this section, we decompose our system into subsystems. The purpose of this decomposition is to reduce coupling between different parts of the system while increasing the coherence of components. This approach makes the game easier to modify and extend when needed.

We've adopted the Model-View-Controller (MVC) architectural pattern for our system design, as it provides a clear separation of concerns and maps well to our game's requirements. The system is divided into three main subsystems:

1. **UserInterface Subsystem (View)**: Contains UI components and provides the visual interface for the player. This includes menus, battle screens, world display, and HUD elements.

2. **Management Subsystem (Controller)**: Includes components for managing the game. This subsystem handles user input, game state, battle logic, data loading, and file operations. It controls the game loop and mediates between the UI and Model subsystems.

3. **Model Subsystem (Model)**: Contains the core game entities and data structures. This includes creatures, moves, player data, and world elements. The Model represents the game state and business logic.

The MVC pattern is suitable for our game for several reasons:

- Our system naturally divides into these three subsystems, with clear responsibilities for each.
- The UserInterface subsystem (View) handles presentation and user interaction.
- The Management subsystem (Controller) processes input, manages game flow, and updates the model.
- The Model subsystem contains the core game data and logic.
- This separation allows for easier testing, maintenance, and extension of the game.

Each subsystem has specific responsibilities and interactions:

- The **UserInterface subsystem** can only request actions from the Management subsystem. Any interaction between UI and Model must go through the Management components. This makes error handling more straightforward and improves stability.

- The **Management subsystem** acts as the controller of the game with several key components:
  - Input Management: Handles user input and translates it into game actions.
  - File Management: Manages saving and loading game data.
  - Game Management: Controls game states, starting/stopping/ending the game.
  - Battle Management: Handles battle mechanics, turn processing, and outcome determination.

- The **Model subsystem** contains game entities that update based on data from the controller. These entities represent the core game objects and their behaviors.

This system decomposition provides high cohesion within subsystems and low coupling between them, making our game more flexible and maintainable.

## 2.2. Hardware/Software Mapping

The 2D Turn-Based Pokémon-Like Game is implemented using the Godot Engine, an open-source game development platform. This choice provides several advantages including cross-platform compatibility, built-in physics, animation systems, and a node-based architecture that simplifies game object management.

As a software requirement, the game needs Godot Engine 3.x or newer to be compiled and run. For players, the compiled game will run as a standalone application without requiring the engine to be installed.

The hardware requirements are modest, making the game accessible to a wide range of players:

- **Processor**: Dual-core CPU at 2.0 GHz or better
- **Memory**: 2 GB RAM minimum, 4 GB recommended
- **Graphics**: OpenGL 2.1 compatible graphics card
- **Storage**: 500 MB available space
- **Input Devices**: Keyboard and mouse or gamepad

The game is designed to run on Windows, macOS, and Linux operating systems, with the potential for mobile platform support in future iterations.

For data storage, the game uses local files rather than a database or internet connection. Game data such as creature definitions, move properties, and type effectiveness are stored in JSON files. Player progress, including captured creatures, game state, and high scores, is saved to the local file system in JSON format.

## 2.3. Persistent Data Management

The 2D Turn-Based Pokémon-Like Game uses a file-based approach for persistent data management. This approach is appropriate for a single-player game that doesn't require complex data relationships or concurrent access.

The game uses several types of persistent data:

1. **Game Content Data**: Static data defining game elements
   - Creature definitions (creatures.json)
   - Move properties (moves.json)
   - Type effectiveness chart (type_chart.json)
   - These files are read-only and loaded at game startup

2. **Player Save Data**: Dynamic data representing player progress
   - Captured creatures with current stats, levels, and moves
   - Player inventory, badges, and progress markers
   - Current location and game state
   - Saved in a structured JSON format when the player saves the game

3. **Settings Data**: User preferences and configurations
   - Audio settings (volume levels, mute options)
   - Display settings (resolution, fullscreen mode)
   - Control mappings
   - Automatically saved when changed

4. **High Score Data**: Performance records
   - Player names and scores
   - Date and time of achievement
   - Stored in a separate file to maintain integrity

The SaveSystem class handles reading and writing these files, with appropriate error handling to prevent data corruption. Files are stored in user-specific locations according to the operating system's conventions (e.g., AppData on Windows, Application Support on macOS).

The game implements a simple versioning system for save files to maintain compatibility across game updates. When loading, the system checks the save file version and applies any necessary migrations to bring older save formats up to date.

## 2.4. Access Control and Security

As a single-player offline game, the 2D Turn-Based Pokémon-Like Game has relatively simple security requirements compared to online multiplayer games. However, several security considerations are still addressed:

1. **Save File Integrity**: Save files use a simple checksum mechanism to detect tampering or corruption. If a save file fails validation, the game offers the option to load a backup or start a new game.

2. **High Score Protection**: To maintain the integrity of the leaderboard, high score submissions include validation data that makes manual editing difficult. While not foolproof, this deters casual tampering.

3. **File Access Restrictions**: The game only accesses files within its designated directories, following platform-specific best practices for file system access.

4. **Error Handling**: Robust error handling prevents crashes when encountering unexpected data, improving both security and stability.

5. **Input Validation**: All user input is validated before processing to prevent unexpected behavior or crashes.

While these measures are appropriate for a single-player game, they would need significant enhancement if online features were added in the future.

## 2.5. Boundary Conditions

Boundary conditions define how the system behaves during initialization, shutdown, and error situations. Proper handling of these conditions ensures a smooth user experience even in exceptional circumstances.

**Initialization:**
- The game begins with a splash screen while loading essential resources
- System checks for required files and creates default settings if none exist
- Missing game data files trigger appropriate error messages rather than crashes
- Initial loading progress is displayed to provide feedback during longer loads

**Normal Termination:**
- When exiting through the menu, the game prompts to save if changes would be lost
- Settings are automatically saved before exit
- All file handles and resources are properly released
- A brief exit animation provides closure to the session

**Abnormal Termination:**
- The game attempts to create an emergency save if crashed during gameplay
- Error logs are generated to help diagnose issues
- On next startup after a crash, the game offers to restore from the emergency save

**Error Handling:**
- File I/O errors are caught and presented with user-friendly messages
- Network timeouts (for future online features) would include retry options
- Memory allocation failures trigger resource cleanup before presenting an error
- Unexpected game states are logged and handled gracefully when possible

**Resource Limitations:**
- The game monitors memory usage and can reduce visual effects if resources are constrained
- Asset loading is prioritized to ensure essential gameplay elements are available first
- Performance monitoring adjusts detail levels to maintain acceptable frame rates

# 3. Subsystem Services

## 3.1. UserInterface Subsystem

The UserInterface subsystem represents the View component in our MVC architecture. It is responsible for rendering the game state to the screen and capturing user input. This subsystem provides the visual representation of the game world, creatures, battles, and menus, serving as the primary means of interaction between the player and the game.

**Key Components:**

1. **MainMenuUI**: Provides the entry point to the game with options for starting a new game, continuing a saved game, accessing settings, viewing high scores, and exiting.

2. **WorldUI**: Renders the game world, including maps, NPCs, the player character, and environmental elements. It displays the overworld where exploration takes place.

3. **BattleUI**: Presents the battle screen with creature sprites, health bars, move selection options, and battle status information. This component visualizes the turn-based combat system.

4. **DialogueUI**: Displays conversations with NPCs, tutorial information, and narrative elements through text boxes and character portraits.

5. **InventoryUI**: Shows the player's collected items, creatures, and badges in an organized interface with filtering and sorting options.

6. **HUD (Heads-Up Display)**: Overlays persistent information during gameplay, such as current score, active creature status, and navigation aids.

7. **SettingsUI**: Allows players to configure game options including audio volume, display settings, and control mappings.

**Services Provided:**

- **Visual Rendering**: Transforms game state data into graphical representations
- **Animation Management**: Handles sprite animations, transitions, and visual effects
- **Input Capture**: Detects and processes player input from keyboard, mouse, or gamepad
- **Feedback Provision**: Communicates game events through visual and audio cues
- **Layout Management**: Organizes UI elements appropriately across different screen sizes

**Interactions:**

The UserInterface subsystem communicates primarily with the Management subsystem. It receives game state updates to display and forwards user input for processing. This subsystem never directly modifies the Model; instead, it requests actions through the Management components, which then update the Model as appropriate.

For example, when a player selects a move in battle:
1. BattleUI captures the selection
2. The input is forwarded to BattleSystem in the Management subsystem
3. BattleSystem processes the move and updates creature states in the Model
4. BattleSystem notifies BattleUI to update the display
5. BattleUI renders the new state with appropriate animations

This separation ensures that the UI remains focused on presentation while game logic stays in the appropriate subsystems.

## 3.2. Management Subsystem

The Management subsystem serves as the Controller in our MVC architecture. It mediates between the UserInterface (View) and Model subsystems, handling game logic, processing input, managing state transitions, and coordinating the various components of the game.

**Key Components:**

1. **GameManager**: The central coordinator that maintains the overall game state, handles transitions between different game modes (exploration, battle, menu), and manages the player's progress through the game.

2. **BattleManager**: Controls the battle system, processing turn-based combat, calculating damage, applying status effects, and determining battle outcomes.

3. **InputController**: Processes raw input from the UI subsystem and translates it into game actions based on the current context.

4. **DataLoader**: Loads and parses game data from JSON files, providing access to creature definitions, move properties, and type effectiveness information.

5. **SaveSystem**: Handles saving and loading game state, including player progress, captured creatures, and settings.

6. **ScoreSystem**: Tracks player performance, calculates scores based on various achievements, and manages the high score leaderboard.

7. **ExperienceSystem**: Manages creature growth, including experience gain, level-up calculations, stat increases, and evolution.

8. **AutoloadManager**: Initializes and manages singleton systems that need to persist throughout the game session.

**Services Provided:**

- **Game State Management**: Maintains and transitions between different game states
- **Battle Logic**: Implements the rules and mechanics of the turn-based combat system
- **Data Access**: Provides structured access to game data and player information
- **Persistence**: Saves and loads game state to enable progress across sessions
- **Scoring**: Tracks and evaluates player performance against defined metrics
- **Progression Systems**: Manages experience, leveling, and evolution mechanics

**Interactions:**

The Management subsystem interacts with both the UserInterface and Model subsystems:

- It receives input and requests from the UserInterface, processes them according to game rules, and updates the Model accordingly.
- It observes changes in the Model and notifies the UserInterface to update its display.
- It handles complex game logic that doesn't belong in either the UI or Model layers.

For example, when a creature gains enough experience to level up:
1. ExperienceSystem detects the threshold being reached
2. It updates the creature's level and stats in the Model
3. It checks for potential evolution or new moves
4. It notifies GameManager of the level-up event
5. GameManager instructs the UI to display the level-up animation and information

This subsystem is crucial for maintaining separation of concerns, ensuring that presentation logic remains in the UI while data structures remain in the Model.

## 3.3. Model Subsystem

The Model subsystem represents the data and business logic layer of our MVC architecture. It contains the core game entities, their attributes, and the rules that govern their behavior. This subsystem maintains the authoritative state of the game world and provides methods for querying and modifying that state.

**Key Components:**

1. **Creature**: Represents the collectible monsters with their stats, types, moves, and evolution paths. This component encapsulates all creature-related data and behaviors.

2. **Player**: Maintains player information including captured creatures, inventory, progress markers, and current location.

3. **World**: Represents the game world with its maps, NPCs, items, and interactive elements. It defines the environment where exploration takes place.

4. **Move**: Defines the actions creatures can perform in battle, including damage calculations, status effects, and special properties.

5. **Item**: Represents collectible objects with various effects such as healing, capturing creatures, or boosting stats.

6. **TypeChart**: Defines the effectiveness relationships between different creature types, determining damage multipliers in battle.

**Services Provided:**

- **State Representation**: Maintains the current state of all game entities
- **Business Rules**: Implements the core mechanics and rules of the game
- **Data Validation**: Ensures that state changes follow game rules and maintain consistency
- **Calculation Logic**: Performs game-specific calculations like damage, experience, and stat derivation
- **Entity Relationships**: Manages connections between different game elements

**Interactions:**

The Model subsystem primarily interacts with the Management subsystem, which mediates between the Model and UserInterface:

- It provides data to the Management subsystem when requested
- It receives update commands from the Management subsystem and modifies its state accordingly
- It notifies the Management subsystem of significant state changes through events or callbacks

The Model never directly communicates with the UserInterface subsystem, maintaining a clean separation of concerns. This isolation ensures that the core game logic remains independent of presentation concerns, making it easier to test, modify, and extend.

For example, when a creature takes damage in battle:
1. The BattleSystem (in Management) calls the creature's take_damage() method
2. The Creature (in Model) updates its current_hp value and checks for fainting
3. If the creature faints, it triggers a state change notification
4. The BattleSystem receives this notification and updates the battle state
5. The BattleSystem then instructs the BattleUI to update the visual representation

This approach keeps the Model focused on maintaining accurate game state without concerning itself with how that state is displayed to the player.

# 4. Low-level Design

## 4.1. Final object design

The final object design for our 2D Turn-Based Pokémon-Like Game represents the detailed structure of classes, their relationships, and interactions. This design expands on the high-level architecture to provide a comprehensive blueprint for implementation.

**Core Game Objects Hierarchy:**

```
Node (Godot base class)
├── Node2D
│   ├── World
│   │   ├── Player
│   │   ├── NPC
│   │   └── InteractiveObject
│   │       ├── Item
│   │       └── Portal
│   └── BattleScene
│       ├── CreatureSprite
│       └── BattleEffects
├── Control (UI base class)
│   ├── MainMenu
│   ├── PauseMenu
│   ├── BattleUI
│   ├── InventoryUI
│   └── DialogueUI
└── AutoloadNode (Singletons)
    ├── GameManager
    ├── DataLoader
    ├── SaveSystem
    ├── ScoreSystem
    ├── ExperienceSystem
    └── BattleManager
```

**Resource Objects:**

```
Resource (Godot base class)
├── Creature
├── Move
├── Item
└── MapData
```

**Key Relationships:**

1. **Player and Creatures**:
   - Player maintains a collection of Creature instances
   - Active creature is referenced for world abilities and as the first battler

2. **Creatures and Moves**:
   - Each Creature has an array of Move references
   - Moves are defined in the moves.json data but instantiated as objects

3. **World and Interactive Elements**:
   - World contains various interactive elements including NPCs, items, and portals
   - Collision layers determine interaction possibilities

4. **Battle Relationships**:
   - BattleSystem manages two opposing Creatures
   - Turn execution follows a state machine pattern
   - Move effects are applied through a command pattern

5. **Manager Interconnections**:
   - GameManager coordinates other managers
   - Each manager has a specific domain of responsibility
   - Communication occurs through method calls and signals (Godot's event system)

**State Management:**

The game uses several state machines to manage different aspects of gameplay:

1. **Game State Machine**:
   - MAIN_MENU: Initial state showing title screen and options
   - EXPLORATION: Player navigating the world map
   - BATTLE: Turn-based combat sequence
   - DIALOGUE: Conversation with NPCs
   - MENU: Player accessing inventory, creatures, or settings
   - GAME_OVER: End state after victory or defeat

2. **Battle State Machine**:
   - INTRO: Battle initialization and animations
   - PLAYER_TURN: Player selecting actions
   - ENEMY_TURN: AI determining and executing moves
   - TURN_EXECUTION: Applying move effects and animations
   - TURN_END: Checking battle conditions
   - BATTLE_END: Determining outcome and rewards

3. **Creature State Machine**:
   - IDLE: Default state
   - ATTACKING: Executing a move
   - HURT: Receiving damage
   - FAINTED: Zero HP condition
   - EVOLVING: Transformation sequence

**Data Flow:**

The data flow in the system follows these general patterns:

1. **Input Processing**:
   - UI captures raw input
   - InputController translates to game actions
   - Appropriate manager processes the action
   - Model updates based on action results
   - UI refreshes to reflect new state

2. **Battle Sequence**:
   - Player selects move through BattleUI
   - BattleSystem processes move selection
   - Damage calculation applies type effectiveness
   - Target Creature updates health and status
   - BattleUI animates the results
   - Battle state advances to next phase

3. **Save/Load Process**:
   - SaveSystem serializes game state to JSON
   - File is written with error handling
   - On load, JSON is parsed and validated
   - Objects are reconstructed from data
   - Game state is restored to saved point

This detailed object design provides a comprehensive blueprint for implementing the game's components while maintaining the architectural principles established in the high-level design.

## 4.2. Design Decisions-Design Patterns

### 4.2.1. Model-View-Controller Pattern

The Model-View-Controller (MVC) architectural pattern forms the foundation of our game's structure, providing clear separation of concerns and improving maintainability.

**Implementation:**

- **Model**: Represented by classes like Creature, Move, and Player that contain the core game data and business logic. These classes are independent of the presentation layer and focus on maintaining the game state.

- **View**: Implemented through UI classes such as MainMenuUI, BattleUI, and WorldUI. These components handle the visual representation of the game state and capture user input without containing game logic.

- **Controller**: Realized through manager classes like GameManager, BattleSystem, and InputController. These components process input from the View, update the Model accordingly, and notify the View of changes to display.

**Benefits:**

1. **Separation of Concerns**: Each component has a clear, single responsibility, making the codebase easier to understand and maintain.

2. **Parallel Development**: UI designers can work on the View while programmers develop the Model and Controller components simultaneously.

3. **Testability**: The Model can be tested independently of the UI, allowing for more thorough unit testing.

4. **Flexibility**: Changes to the UI don't affect the underlying game logic, and vice versa.

**Example:**

In our battle system:
- The **Model** includes Creature objects with stats, moves, and health values
- The **View** is the BattleUI that displays creatures, health bars, and move buttons
- The **Controller** is the BattleSystem that processes move selection, calculates damage, and updates creature states

When a player selects a move, the View notifies the Controller, which updates the Model and then instructs the View to display the results.

### 4.2.2. Singleton Design Pattern

The Singleton pattern ensures that certain classes have only one instance throughout the game's execution, providing global access to that instance.

**Implementation:**

In Godot, we implement Singletons using the AutoLoad feature, which instantiates specified scenes or scripts at the start of the game and makes them accessible from anywhere. Our key Singleton classes include:

- GameManager
- DataLoader
- SaveSystem
- ScoreSystem
- ExperienceSystem
- BattleManager

**Benefits:**

1. **Global Access**: These managers can be accessed from any part of the code without passing references.

2. **State Persistence**: Singletons maintain their state throughout the game session,
