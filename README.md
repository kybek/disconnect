# disconnect

A game based on 4-connect which you can sabotage your opponents.

# Installing

Clone this repository 
`git clone https://github.com/EnoughSensei/disconnect/`
or download the latest release.

Download godot from https://godotengine.org/download

Run godot, and select `Import` then open the downloaded directory and select `project.godot`
Press F5 to play

# Rules
## Turns
This is a turn based game. If it is your turn, then you must select a column and place a piece at the bottom-most space that is empty. Before you place the piece, you may also use your chosen "power" (that is, if you have any uses left). After placing the piece, it becomes the next person's turn.

## Scoring
Your score is calculated by number of "connections" your pieces form. A "connection" is when 4 of your pieces, make a continuous line (horizontally, vertically, or diagonally). In the original Connect Four game, the game ends when one of the players score a point. But in this game, the game continues until all of the board is filled and at the end, the player with the highest score wins.

## Powers
WIP - new powers will be added and balanced.
- None: You can start without powers.
- Rewind: When it is your turn, you can rewind all of the actions after your last turn and your last turn.

# Assets
Grass tile is from https://opengameart.org/content/map-tile

Background is from https://opengameart.org/content/tiling-pattern-64x64-px-various-shades

Checker piece is from https://opengameart.org/content/checkers

# To-do List
Before Beta Version 6, the following will be discussed and/or implemented.
## GUI Overhaul
- [X] #16 (Some kind of indicator about how many power uses left)
- [X] #17 (See other players' power types (and possibly remaining uses))
- [X] #18 (Scoreboard is blocked by the board when board size is 16x9)
- [X] Option to change the color of oneself
- [ ] Option to change the color of highlighting
- [ ] Option to change the background
- [ ] Option to change the font size, font style, font color
- [ ] Option to change the appearance of the pieces of oneself
- [X] Board borders
- [X] Scoreboard (viewed via TAB button)
- [ ] Old screen effect (optional, with shader)
