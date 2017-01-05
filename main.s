        .intel_syntax
        .globl _start
        .equ PUZZLE_SIZE, 16

        # Macro for exiting
        .macro EXIT
        mov %eax, 1
        mov %ebx, 0
        int 0x80
        .endm
        
        # Beginning of main
_start:
        lea %eax, welcome       # Load the welcome string
        push %eax
        call printString        # Print the welcome string
        pop %eax
        lea %eax, command
        push %eax
        call printString
        pop %eax
        call fillPuzzle         # Fill the puzzle with array[i] = i+1
        call shufflePuzzle
turn:   call clearScreen
        call showPuzzle
        call isFinished         # Test whether the puzzle is finished
        cmp %eax, 0
        jne wonmsg
        ## Ask player for a command
debug:  lea %eax, whattodo
        push %eax
        call printString
        pop %eax
        call readAndPlay
        jmp turn
wonmsg: lea %eax, won
        push %eax
        call printString
        pop %eax
        EXIT                    # Exit the program

        ## This routine shuffles the puzzle
shufflePuzzle:
        push %ebp
        mov %ebp, %esp
        push %ebx
        ## Now we can generate our integers
        mov %ebx, 50            # We wil generate 150 moves
onemove:
        rdrand %eax             # Put a rand number in eax
        mov %edx, 0
        mov %ecx, 3             # 3 possible moves
        idiv %ecx               # edx has the move to execute (0-2)
        cmp %edx, 0
        je right
        cmp %edx, 1
        je up
        cmp %edx, 2
        je left
up:     call moveUp
        jmp again
right:  call moveRight
        jmp again
left:   call moveLeft
again:  dec %ebx
        cmp %ebx, 0
        jne onemove
        pop %ebx
        pop %ebp
        ret

        ## This routine reads a char from the player
        ## And plays the given move
readAndPlay:
        push %ebp
        mov %ebp, %esp
        push %ebx
        mov %eax, 0
        push %eax
        ## First, call the read syscall
        mov %eax, 3
        mov %ebx, 0
        mov %ecx, %esp
        mov %edx, 3
        int 0x80
        ## Check the given char
        mov %eax, [%esp]
        and %eax, 0x000000ff
        cmp %eax, 'u'
        je pup
        cmp %eax, 'd'
        je pdown
        cmp %eax, 'l'
        je pleft
        cmp %eax, 'r'
        je pright
        jmp playexit             # Unknown char, we exit
pup:    call moveUp
        jmp playexit
pdown:  call moveDown
        jmp playexit
pleft:  call moveLeft
        jmp playexit
pright: call moveRight
playexit:
        add %esp, 4
        pop %ebx
        pop %ebp
        ret

clearScreen:
        push %ebp
        mov %ebp, %esp
        push %ebx
        mov %eax, 4
        mov %ebx, 1
        lea %ecx, clearstr
        mov %edx, 7
        int 0x80
        pop %ebx
        pop %ebp
        ret
        
command:        .asciz "Controls: u (Up), d (Down), l (Left), r (Right)\n"
welcome:        .asciz "Solve the following puzzle:\n"
whattodo:       .asciz "Move:\n"
won:            .asciz "You won!\n"
clearstr:       .byte  0x1b, 0x5b, 0x48, 0x1b, 0x5b, 0x32, 0x4a 
