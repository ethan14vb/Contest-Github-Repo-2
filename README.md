# Computer Architecture and Assembly - Spring 2026 - Contest 2
by Ethan Van Brunt and Joshua Fernandez-Alvarado
## Overview & Key Features
This is a project created for CSE-3120: Computer Architecture and Assembly in which we created a game engine + demo game.

The game engine features: 
- **Modular core systems** that allow for different components of the engine (such as rendering or resource management) to be quickly updated or swapped.
- **2D Rendering System** with **CPU Rasterization** in 60 FPS that utilizes SIMD techniques for alpha blending
- **Action-Input Abstraction** that separates the input binding from the controller, allowing for more controllers and bindings to be added without changing the underlying gameplay logic. 
- **Resource management** for 2D images and sprite atlasses.
- An **Event callback** system where functions can be connected and disconnected from events
- An **Object Oriented** system for GameObjects that allows for subclassing by embeddeding superclasses into class STRUCTs and virtual tables.
- An **Entity Component System (ECS)** in which components can be attached to GameObjects

For more technical information on the engine, view [ENGINE_DOCS.md](ENGINE_DOCS.md)

## Demo Game: Sketch Knights
Sketch Knights is a 2D strategy "tug-of-war" game with local multiplayer in which players compete on the same device to sack the other player's castle by deploying cartoon knights.
### Objective
- Each player has a Castle, an amount of Cash, and Income per second.
  - Cash is used to purchase knights or buy income upgrades.
  - Income is how much your Cash increases every second.
- The objective is to manage your Cash to buy knights. Knights will walk along the screen towards the other player's Castle.
- When they reach the opponent's Castle, Knights will deal damage to it.
  - You can win by reducing your opponent's Castle HP to 0.
- If two knights meet in the field, they will start attacking each other.
- Manage your economy and be strategic about what you buy to win!

### Controls
- Player 1
  - Move your shop cursor with A and D.
  - Press SPACE to select your choice.
- Player 2
  - Move your shop cursor with LeftArrow and RightArrow.
  - Press ENTER to select your choice.
- Note that although you may hover over a selection, trying to select it without having the required cash will not do anything!
- After a game ends a victory message will appear and the game will automatically close after 5 seconds.

### Gameplay
- Knights come in varying shapes and sizes. In this game, we have three!
   - Sword Knight
     - Lightly armored and wielding a sword, it is well rouded in all aspects. They are the cheapest of the knights and are good for overwhelming the enemy.
   - Archer
     - Nimble and sneaky, they move fast and can attack from a distance! Be careful though, their lack of armor makes them susceptible to attacks.
   - Heavy Knight
     - These heavily armored warriors will tear through ranks while tanking multiple attacks. Their armor does make them quite slow however, and you will need a lot of coin to recruit them!

## How to Compile and Run
- This project was designed for a class in Visual Studio 2015. Clone the repository and open the Project.sln in VS2015
- You may build the project in visual studio and run it there. 

## Credits
Though all team members worked on all aspects of the projects, the primary roles were:

- **Ethan Van Brunt**: Engine Developer and Artist
- **Joshua Fernandez-Alvarado**: Game-Designer and Gameplay Programmer
