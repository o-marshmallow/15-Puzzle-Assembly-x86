# 15-Puzzle-Assembly-x86

## Introduction:
   This is an implementation of the 15-Puzzle game written in x86 assembly. x86 assembly has been used for a full compatibility with Intel 32-bit processors.

## Assembling:
   You simply need to execute the following command:
   ```
        make
   ```

## Files:
   - `printing.s` contains the routine for printing strings, numbers, ...
   - `puzzle.s` contains the main routines for manipulating the puzzle. For example, `moveUp` will move the empty piece up. 
   - `main.s` contains the routines for the main game, like reading an entry from the player, shuffling the puzzle