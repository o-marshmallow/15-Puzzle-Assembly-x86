        .intel_syntax
        .globl printInt, readInt, newline, printString
        .equ SIZE, 0xF
        .text

        ## In the following subroutine, %eax, %ecx, %edx are not preserved
        ## %eax = High number
        ## %edx = current digit
        ## %ecx = index for buffer
        ## %ebx = 10 (for the div)
printInt:
        push %ebp                       # Save the EBP
        mov %ebp, %esp                  # Put the SP inside
        mov %eax, [%ebp + 8]            # Get argument
        push %ebx                       # Save ebx, to use it freely
        mov BYTE PTR [buffer+SIZE-1], '\t'  # Put \n at the end of the buffer
        mov %ecx, SIZE-2                # ecx stores the index of buffer, so 98 (99 is \n)
        mov %ebx, 10                    # Value to divide by
loop:   mov %edx, 0                     # The loop starts here, with eax containing the quotient
        div %ebx                        # eax /= 10 (ecx) edx=eax%10
        add %edx, '0'                   # Convert int to char
        ## From now, edx has the second digit to show
        mov [buffer+%ecx], %dl          # Move the char into the buffer
        sub %ecx, 1
        cmp %eax, 0
        jnz loop
        ## Call write syscall
        mov %edx, SIZE
        sub %edx, %ecx          # Size = 100 - %ecx (index)
        lea %eax, buffer
        add %eax, %ecx
        inc %eax
        mov %ecx, %eax          # ecx = &buffer + ecx + 1
        mov %eax, 4
        mov %ebx, 1
        int 0x80
        pop %ebx                # Get the saved value of ebx
        pop %ebp                # Exit the function 
        ret              

        ## This subroutine preserves %ebx only
readInt:
        push %ebp               
        mov %ebp, %esp          # Making the stack fram
        push %ebx               # Saving ebx (calling conventions)
        ## First, call read syscall
        mov %eax, 3             # Read syscall code
        mov %ebx, 0             # Stdin file descriptor
        lea %ecx, buffer        # Buffer for read
        mov %edx, SIZE          # Size of the buffer
        int 0x80
        ## eax now contains the length read on the stdin, let's put it ecx
        mov %ecx, %eax
        sub %ecx, 1
        ## %eax = final result, %ebx = current index, %ecx = length, %edx = temporary register
        mov %edx, 0             # This register will be storing chars during the loop
        mov %ebx, 0             # Current index, so starts at 0, max value is 9
        mov %eax, 0             # This register contains the final result
nextd:  
        imul %eax, 10           # eax = eax * 10
        mov %edx, 0
        mov %dl, [buffer+%ebx]  # char from buffer in dl
        sub %edx, '0'           # char to int
        add %eax, %edx          # eax += edx
        add %ebx, 1
        cmp %ebx, %ecx
        jne nextd
        pop %ebx                # Getting back ebx
        pop %ebp                # Returning from the subroutine
        ret

        ## This routine prints the given string
printString:
        push %ebp
        mov %ebp, %esp
        push %ebx
        mov %ecx, [%esp + 12]   # ebx cotnains the pointer to the string
        push %ecx               # Argumen of the routine
        call strlen
        mov %edx, %eax          # edx has now the length of the str
        pop %ecx                # ecx has the address of the str
        mov %ebx, 1
        mov %eax, 4
        int 0x80                # call write syscall
        pop %ebx
        pop %ebp
        ret

        ## This routine takes a string as parameter and returns
        ## the length of it
strlen: push %ebp
        mov %ebp, %esp
        mov %eax, [%esp+8]      # Address of the string
cchar:  mov %ecx, [%eax]        # Current char
        inc %eax
        and %ecx, 0xff          # Get the lowest byte
        cmp %ecx, 0
        jne cchar               # If char != 0, continue
        mov %ecx, [%esp+8]      # Address of the first char
        sub %eax, %ecx          # eax is the address of the last char
        pop %ebp
        ret

        ## This subroutine only prints a newline
newline:
        push %ebp
        mov %ebp, %esp
        push %ebx               # Save ebx
        mov %eax, '\n'
        push %eax               # \n is on the stack now
        ## Write syscall
        mov %eax, 4
        mov %ebx, 1
        mov %ecx, %esp          # Address of the string is the SP
        mov %edx, 1             # Size 1 (one char)
        int 0x80
        pop %eax
        pop %ebx                # Get the value back
        pop %ebp
        ret
        
        .bss
buffer: .space SIZE,0              # 100 bytes for the buffer
