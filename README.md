# NES Pong

Two-player Pong for the Nintendo Entertainment System, written in 6502 assembly for the ca65 assembler. It runs in any NES emulator. A step-by-step write-up of how the code works is on my blog: [Writing Games for the Nintendo Entertainment System (1985)](https://aliahmadm.vercel.app/blog/nes-pong).

## Controls

Both players use a standard NES controller.

| Button | Action |
| ------ | ------ |
| Up     | Move paddle up |
| Down   | Move paddle down |

Player 1 uses the controller in port 1 and plays the left paddle. Player 2 uses port 2 and plays the right paddle. **Note:** Scores stop counting at 9. There is no winning condition.

## Requirements

- The [cc65](https://cc65.github.io/) toolchain (`cl65` and `ld65`) on your `PATH`
- Windows, since the build script is a batch file
- An NES emulator. Mesen and FCEUX both work.

## Building

Run the build script from the project root:

```
build.bat
```

It does four things:

```bat
@echo off
cl65 -t nes -g -c src/main.asm -o main.o
ld65 -t nes -o game.nes src/main.o --dbgfile game.dbg

del src\main.o
game.nes
```

The last line opens the ROM with whatever program Windows has associated with `.nes` files, so set that to your emulator or start it by hand. The `game.dbg` file lets emulators that understand cc65 debug info, such as Mesen, show labels instead of raw addresses. On Linux or macOS, the same commands work in a shell script. Replace the backslash in the `del` line with a forward slash and use `rm`.

## Project layout

```
assets/
  charset.chr          tile graphics: ball, paddle, digits 0-9
  bgrnd.nam            background nametable
src/
  main.asm             reset routine, NMI handler, vectors
  vblankwait.asm       wait for vblank
  common/
    header.inc         iNES header
    constants.inc      register addresses and wall positions
    zeropage.inc       game variables
  palettes/            palette loading and color data
  nametable/           background loading
  sprites/             sprite data and the loader that copies it to RAM
  controller/          reading controller 1 and 2
  game/
    paddle_1.asm       paddle movement for player 1
    paddle_2.asm       paddle movement for player 2
    pong_ball.asm      ball movement, wall bounces, scoring, serving
    delay_timer.asm    pause between a point and the next serve
    score_point.asm    increments a score digit
```
