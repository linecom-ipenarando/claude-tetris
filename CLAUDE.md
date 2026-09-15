# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Vanilla JavaScript Tetris implementation using HTML5 Canvas. No dependencies, no build process, no package.json. Three files: `index.html`, `style.css`, `game.js`.

## Running

No install/build step. Either:

```bash
start index.html      # open directly in browser (Windows)
```

or serve statically (needed if the browser blocks local file access):

```bash
python3 -m http.server 8000
npx serve .
```

There is no test suite or linter configured in this repo.

## Architecture

All game logic lives in `game.js` as top-level functions operating on module-level mutable state (`board`, `current`, `next`, `score`, `lines`, `level`, `paused`, `gameOver`, `dropInterval`, etc.) — there are no classes or modules.

- **Board model**: `board` is a `ROWS × COLS` (20×10) matrix; each cell is `0` (empty) or a color index 1–7 identifying which piece locked there.
- **Pieces**: `PIECES` defines the 7 tetrominoes as square matrices of color indices. Rotation (`rotateCW`) is a matrix transpose + row reverse, not precomputed rotation states.
- **Collision** (`collide`): checks a shape against board bounds and existing locked cells.
- **Wall kicks** (`tryRotate`): after rotating, tries offsets `[0, -1, 1, -2, 2]` columns until a non-colliding position is found, else the rotation is discarded.
- **Game loop** (`loop`): driven by `requestAnimationFrame`; accumulates elapsed time in `dropAccum` and advances the piece down one row once `dropInterval` is exceeded, otherwise calls `lockPiece()`.
- **Line clearing** (`clearLines`): scans bottom-to-top, splicing out full rows and unshifting empty rows at the top.
- **Scoring**: `LINE_SCORES` (`[0,100,300,500,800]`) multiplied by `level` for line clears; hard drop adds 2 points/cell, soft drop 1 point/row.
- **Leveling/speed**: level increases every 10 lines; `dropInterval = max(100, 1000 - (level-1)*90)` ms.
- **Ghost piece** (`ghostY`): projects the current piece straight down to its landing row, drawn at `globalAlpha = 0.2`.
- **Rendering**: `draw()` redraws the full board canvas each frame (grid, locked blocks, ghost, current piece); `drawNext()` renders the next-piece preview canvas separately.
- Game over is triggered in `spawn()` when a freshly spawned piece immediately collides.

Tunable constants at the top of `game.js`: `COLS`, `ROWS`, `BLOCK`, `COLORS`, `LINE_SCORES`, initial `dropInterval`. If `COLS`/`ROWS`/`BLOCK` change, update the `<canvas id="board">` `width`/`height` in `index.html` to match (`COLS × BLOCK`, `ROWS × BLOCK`).

## Controls

`←`/`→` move, `↑`/`X` rotate, `↓` soft drop, `Space` hard drop, `P` pause.
