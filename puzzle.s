        .intel_syntax
        .globl fillPuzzle, showPuzzle, isFinished
        .globl moveUp, moveDown, moveLeft, moveRight
        .equ LINE, 4
        .equ PUZZLE_SIZE, LINE*LINE
        
        ## fillPuzzle will put the right numbers in the puzzle
        ## The register %ebx is preserved
fillPuzzle:
        push %ebp
        mov %ebp, %esp
        mov %eax, 0                     # %eax will contain the index
fstep:  mov %edx, %eax          
        inc %edx                        # %edx = %eax + 1, value to store
        mov [puzzle+%eax*4], %edx       # Put the value in the puzzle
        add %eax, 1
        cmp %eax, PUZZLE_SIZE-1         # If the end is not reached, we continue
        jne fstep
        mov %edx, 0
        mov [puzzle+%eax*4], %edx       # The last cell contains 0
        mov BYTE PTR [pindex], 0xF      # The free space is at index 15 (0xF)
        pop %ebp
        ret

        
        ## This routine return 1 if the puzzle is finished
        ## Else, it returns 0 (by putting 0 in %eax)
isFinished:
        push %ebp
        mov %ebp, %esp
        mov %eax, 0
finloop:
        mov %ecx, [puzzle+%eax*4] # Get the integer in the array
        dec %ecx
        cmp %ecx, %eax          # %eax is the index, so we need ecx-1 == eax
        jne fexit
        inc %eax                # next index
        cmp %eax, PUZZLE_SIZE-1 # The loop is finished before testing the last integer
        jne finloop
ftrue:  mov %eax, 1             # Default return code, 1
end:    pop %ebp
        ret
fexit:  mov %eax, 0     # Exit with false code
        jmp end


        ## This subroutine will move one piece up
        ## Depending on where the blank one (0) is
moveUp: push %ebp
        mov %ebp, %esp
        push %ebx               # Save the register %ebx
        mov %eax, [pindex]      # Store the pindex in eax
        mov %ecx, LINE
        mov %edx, 0
        div %ecx
        ## After this, %eax contains the line number and %edx contains
        ## the column number of the empty cell
        cmp %eax, 0             # If the empty cell is already on the top, do nothing
        je upEnd
        ## Now, we need to put the value of puzzle[pindex-LINE] in puzzle[pindex] (then put 0 in the first)
        mov %eax, [pindex]                      # eax contains the current index
        mov %ecx, [puzzle + 4*(%eax-LINE)]      # ecx contains the value of puzzle[pindex-LINE]
        mov [puzzle + 4*%eax], %ecx             # Putting [pindex - LINE] value in [pindex]
        mov %ecx, 0
        mov [puzzle + 4*(%eax-LINE)], %ecx
        ## Store the new index of the empty cell
        sub %eax, LINE                          # eax has now the new index to store
        mov [pindex], %eax        
upEnd:  pop %ebx
        pop %ebp
        ret

        ## This routine moves the empty piece down
        ## The comments are the same as moveUp routine
moveDown:
        push %ebp
        mov %ebp, %esp
        push %ebx               # Save the register %ebx
        mov %eax, [pindex]      # Store the pindex in eax
        mov %ecx, LINE
        mov %edx, 0
        div %ecx
        ## After this, %eax contains the line number and %edx contains
        ## the column number of the empty cell
        cmp %eax, LINE-1        # If the empty cell is already on the bottom, do nothing
        je dowEnd
        ## Now, we need to put the value of puzzle[pindex+LINE] in puzzle[pindex] (then put 0 in the first)
        mov %eax, [pindex]                      # eax contains the current index
        mov %ecx, [puzzle + 4*(%eax+LINE)]      # ecx contains the value of puzzle[pindex-LINE]
        mov [puzzle + 4*%eax], %ecx             # Putting [pindex + LINE] value in [pindex]
        mov %ecx, 0
        mov [puzzle + 4*(%eax+LINE)], %ecx
        ## Store the new index of the empty cell
        add %eax, LINE                          # eax has now the new index to store
        mov [pindex], %eax        
dowEnd: pop %ebx
        pop %ebp
        ret


        ## This routine moves the empty piece left
        ## The comments are the same as moveUp routine
moveLeft:
        push %ebp
        mov %ebp, %esp
        push %ebx               # Save the register %ebx
        mov %eax, [pindex]      # Store the pindex in eax
        mov %ecx, LINE         
        mov %edx, 0
        div %ecx
        cmp %edx, 0             # If the empty cell is already on the left, exit
        je lefEnd
        ## Now, we need to put the value of puzzle[pindex-1] in puzzle[pindex] (then put 0 in the first)
        mov %eax, [pindex]                      
        mov %ecx, [puzzle + 4*(%eax-1)]         
        mov [puzzle + 4*%eax], %ecx             
        mov %ecx, 0
        mov [puzzle + 4*(%eax-1)], %ecx
        ## Store the new index of the empty cell
        dec %eax                          
        mov [pindex], %eax        
lefEnd: pop %ebx
        pop %ebp
        ret

        ## This routine moves the empty piece right
        ## The comments are the same as moveUp routine
moveRight:
        push %ebp
        mov %ebp, %esp
        push %ebx               # Save the register %ebx
        mov %eax, [pindex]      # Store the pindex in eax
        mov %ecx, LINE
        mov %edx, 0
        div %ecx
        cmp %edx, LINE-1             
        je rigEnd
        ## Now, we need to put the value of puzzle[pindex-1] in puzzle[pindex] (then put 0 in the first)
        mov %eax, [pindex]                      
        mov %ecx, [puzzle + 4*(%eax+1)]         
        mov [puzzle + 4*%eax], %ecx             
        mov %ecx, 0
        mov [puzzle + 4*(%eax+1)], %ecx
        ## Store the new index of the empty cell
        inc %eax                          
        mov [pindex], %eax        
rigEnd: pop %ebx
        pop %ebp
        ret
        
        
        ## This subroutine will show the puzzle
        ## It's a single dimension array
        ## However, will be displayed at a 2-dimension puzzle
showPuzzle:
        push %ebp
        mov %ebp, %esp
        push %ebx               # ebx has to be saves across routines
        ## Show lines
        mov %ebx, 0             # As ebx is saved, it will store the index
puzstep:
        push %ebx
        call showLine
        add %esp, 4             # Pop the argument
        call newline            # Print a newline to the output
        inc %ebx                # index++
        cmp %ebx, LINE          # We check if we ahve reached the end
        jnz puzstep
        pop %ebx
        pop %ebp
        ret

        ## This subroutine shows a line, it is not global
showLine:
        push %ebp
        mov %ebp, %esp
        mov %eax, [%esp+8]      # eax contains the line to show (argument)
        push %ebx               # Save ebx as it should be preserved
        imul %eax, LINE         # eax now contains the index of the first element
        mov %ebx, %eax          # The index of the first element is stored in %ebx
        add %eax, LINE          # ecx contains the final index (exclusive)
        push %eax               # Last index on the stack [%esp]
        ## Beginning of the loop
lstep:  lea %eax, puzzle
        push [%eax+%ebx*4]
        call printInt           # Showing the current integer
        pop %eax
        inc %ebx                # Index++
        cmp %ebx, [%esp]        # If we haven't reached the end, we continue
        jne lstep
        add %esp, 4             # Pop the last index from the stack
        ## End of the loop
        pop %ebx
        pop %ebp
        ret
        
        .bss
puzzle: .space PUZZLE_SIZE*32, 0         # 16 cells of 32 bits
pindex: .space 4, 0                      # This space represents the index of 0
