# disconnect

A game based on connect-4 in which you can sabotage your opponents. More than two players are also supported.

(Also on [itch.io](https://draketrought.itch.io/disconnect))

# Installing

You can either download the latest release, or:

- Clone this repository (`git clone https://github.com/kybek/disconnect/`)

- Download [godot](https://godotengine.org/download). (godot doesn't need installation)

- Run godot and select `Import` 

- Open the downloaded directory on the import window

- Select `disconnect/project.godot`

- Press F5 to play

# Rules
## Turns
This is a turn based game. If it is your turn, then you must select a column and place a piece at the bottom-most space that is empty. Before you place the piece, you may also use your chosen "power" (that is, if you have any uses left for that power). After placing the piece, it becomes the next person's turn.

## Scoring
Your score is calculated using the number of "connections" your pieces form. A "connection" is when 4 of your pieces make a continuous line (horizontally, vertically, or diagonally). In the original Connect Four game the game ends when one of the players score a point. In this version the game continues until all of the board is filled. At the end the player with the highest score wins.

## Powers
Keep in mind that new powers will be added & balanced.
- None: You can start without powers.
- Rewind: When it is your turn, you can rewind all of the actions after your last turn (including your last turn so it's still your turn to play).

# Assets
Background image is from https://opengameart.org/content/tile by Jordan Irwin

Checker piece is from https://opengameart.org/content/checkers by Andi Peredri
