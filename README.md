# CSE3120 Computer Architecture and Assembly Programming Spring 2026 - Contest 2
# Sketch Knights
## Ethan Van Brunt (904031060) and Joshua Fernandez-Alvarado (904036400)

## How to Play
**Objective**
- This is a local multiplayer game, so it is meant to be player by two people competing agaisnt each other on the same device.
- Each player has a Castle, an amount of Cash, and Income per second.
  - Cash is used to purchase knights or buy income upgrades.
  - Income is how much your Cash increases every second.
- The objective is to manage your Cash to buy knights. Knights will walk along the screen towards the other player's Castle.
- When they reach the opponent's Castle, Knights will deal damage to it.
  - You can win by reducing your opponent's Castle HP to 0.
- If two knights meet in the field, they will start attacking each other.
- Manage your economy and be strategic about what you buy to win!

**Controls**
- Player 1
  - Move your shop cursor with A and D.
  - Press SPACE to select your choice.
- Player 2
  - Move your shop cursor with LeftArrow and RightArrow.
  - Press ENTER to select your choice.
- Note that although you may hover over a selection, trying to select it without having the required cash will not do anything!
- After a game ends a victory message will appear and the game will automatically close after 5 seconds.

**Gameplay**
- Knights come in varying shapes and sizes. In this game, we have three!
   - Sword Knight
     - Lightly armored and wielding a sword, it is well rouded in all aspects. They are the cheapest of the knights and are good for overwhelming the enemy.
   - Archer
     - Nimble and sneaky, they move fast and can attack from a distance! Be careful though, their lack of armor makes them susceptible to attacks.
   - Heavy Knight
     - These heavily armored warriors will tear through ranks while tanking multiple attacks. Their armor does make them quite slow however, and you will need a lot of coin to recruit them!

## How to Compile and Run
- Checkout a commit and open the Project.sln file in Visual Studio.
- You should be able to compile and run inside Visual Studio.
