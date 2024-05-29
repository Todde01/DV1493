.data
null:        .byte   0x00

currentPos:
    .quad 0

currentPos2:
    .quad 0

MAXPOS:    
    .quad   0


.section .bss
inBuffer: 
    .space 64

outBuffer:
    .space 64

.text
.global inImage
.global getInt
.global getText
.global getChar
.global getInPos
.global setInPos
.global outImage
.global putInt
.global putText
.global putChar
.global getOutPos
.global setOutPos


inImage:
    movq $inBuffer, %rdi   # first argument input gets stored in inBuffer
    movq $64,%rsi       # second argument, max 63 characters + 0     
    movq stdin, %rdx    # third argument, input from stdin 
    call fgets          
    movq $0, currentPos(%rip)  # reset current position to 0
    ret

getInt:
   call getInPos
   leaq inBuffer(%rip), %rbx  # Load address of inBuffer into %rbx
   addq %rax, %rbx

   # Check if the buffer is empty or at the end
   movzbl (%rbx), %r8d              # Load the current character into %r8
   test %r8, %r8                    # Test if the character is 0 (end of buffer)
   jz .callInImage2                  # If zero, call inImage to refill the buffer

   xor %rdx, %rdx             # Clear %rdx, will store the final integer value
   xor %rsi, %rsi             # Clear %rsi, will use as flag for negativity
   xor %rcx, %rcx             # Clear %rcx, count of characters processed

   movzbl (%rbx), %r8d        # Load current character into %r8
   inc %rbx                   # Move to the next character
   incq currentPos(%rip)      # Increment position

.readChar:
   cmp $' ', %r8                    # Check if the character is a space
   je .skipWhiteSpace               # If space, skip to the next character
   cmp $'-', %r8              # Check if negative
   je isNegative              # Jump if negative
   cmp $'+', %r8d              # Check if positive explicitly indicated
   je nextChar                 # Skip the '+' sign to start parsing the number


isPositive:
   sub $'0', %r8              # Convert ASCII to integer (0-9)
   cmp $9, %r8                # Compare to 9
   ja finish_parsing           # If above '9', finish parsing
   imul $10, %rdx, %rdx        # Multiply current value by 10
   add %r8, %rdx              # Add new digit
   jmp nextChar                # Prepare to read next character

isNegative:
   mov $1, %rsi               # Set %rsi to 1 to indicate negative number

nextChar:
   movzbl (%rbx), %r8d         # Load next character
   inc %rbx                    # Increment buffer pointer
   incq currentPos(%rip)       # Increment position counter
   jmp isPositive              # Continue parsing as positive unless ended

finish_parsing:
   test %rsi, %rsi             # Test if the flag for negativity is set
   jz parsing_done             # If zero, number is positive
   neg %rdx                    # Negate the result if flag is set

parsing_done:
   mov %rdx, %rax              # Move the result to %rax for return
   ret

.skipWhiteSpace:
    movzbl (%rbx), %r8d              # Load the next character
    inc %rbx                         # Increment buffer pointer
    incq currentPos(%rip)            # Increment position counter
    jmp .readChar                    # Continue reading characters

.callInImage2:
    call inImage                     # Refill the buffer
    call getInt                      # Retry getting the integer
    ret

getText:
    # Assume %rdi = buf, %rsi = n (maximum characters to copy)

    push %rbp            # Save base pointer
    mov %rsp, %rbp       # Set stack pointer

    # Call getInPos to get the current position
    call getInPos        # Return value in %rax (currentPos)
    
    # Calculate current pointer in inBuffer
    leaq inBuffer(%rip), %r9    # Start of inBuffer
    add %rax, %r9               # Current position in inBuffer

    ########### CHECK IF BUFFER IS EMPTY OR AT END ###########

    movzbl (%r9), %eax       # Load byte at current position into %eax
    test %eax, %eax          # Check if byte is zero (end or empty)
    jz .callInImage          # If zero, buffer is empty or at end, need to refill
    
    # Prepare for copying
    mov %rdi, %rdx                # Move the address in %rdi directly to %rdx
    xor %rcx, %rcx              # Counter for number of characters copied

.copyLoop:
    # Check if we have copied n characters
    cmp %rsi, %rcx
    je .doneCopying

    # Load byte from inBuffer, check for buffer end
    movzbl (%r9), %eax          # Load byte into %eax
    test %al, %al               # Check if it's 0 (end of inBuffer)
    je .doneCopying             # If it's zero, we're done

    # Store byte in buf, increment pointers and counter
    mov %al, (%rdx)
    inc %r9
    inc %rdx
    inc %rcx

    jmp .copyLoop

.callInImage:
    # Call inImage to refill the buffer
    call inImage
    # After refilling, reset current pointer position and retry getting text
    xor %rax, %rax           # Reset position to start of buffer
    mov %rax, currentPos(%rip)
    jmp getText              # Restart getText function

.doneCopying:
    # Null terminate the string in buf
    movb $0x00, (%rdx)

    # Update currentPos
    mov %rcx, %rax              # Move count to %rax
    add currentPos(%rip), %rax  # Update currentPos with count
    mov %rax, currentPos(%rip)
    mov %rcx, %rax              # Move count to %rax for return value (ugly code :))

    # Restore stack and base pointers, return
    mov %rbp, %rsp
    pop %rbp
    ret

#    # rdi = adress till minnesutrymme
#    # rsi = antal characters


emptyBuffer:
    call inImage
    jmp getText


#getMaxPos:
#    call getInPos
#    cmp $64, %rax
#    jge setMaxPos
#
#setMaxPos:
#    movq $64, %rax
#    ret


getChar:
    call getInPos
    movzbl inBuffer(%rax), %eax
    incq currentPos(%rip)
    ret

# Function: getInPos
# Description: Returns the current buffer position from currentPos
# Return: Current buffer position (index) in %rax
getInPos:
    movq currentPos(%rip), %rax
    ret

setInPos:
    cmp 0, %rdi
    jge checkUpperBound
    movq $0, currentPos(%rip)

checkUpperBound:
    movq $64, %rcx
    cmpq %rdi, %rcx
    jle setPos
    movq $64, currentPos(%rip)

setPos:
    movq %rdi, currentPos(%rip)
    ret

outImage:
    # Load the address of the output buffer into %rdi (the first argument for puts)
    leaq outBuffer(%rip), %rdi



    
    # Call puts to output the string in the output buffer
    call puts
    
    # Reset the buffer position to indicate the buffer is now empty
    movq $0, %rdi
    call setOutPos
    
    ret

putText:
    push %rbp               # Save the base pointer
    mov %rsp, %rbp          # Set the stack pointer as the new base pointer

    mov %rdi, %rsi          # Copy the source address (buf) to %rsi
    call getOutPos          # Get the current position in the output buffer
    leaq outBuffer(%rip), %rbx  # Calculate the base of the output buffer
    add %rax, %rbx          # Move %rbx to point to the current position in the output buffer

.copy_loop:
    movb (%rsi), %al        # Load the byte from the source buffer into %al
    test %al, %al           # Check if the byte is zero (end of the string)
    je .done2               # If zero, we're done copying

    movq currentPos2(%rip), %rcx  # Get the current output buffer position
    cmp $63, %rcx           # Check if the output buffer is full (max 63 bytes, as the buffer has 64 bytes)
    jge .flush_buffer2      # If the buffer is full, flush it

    movb %al, (%rbx)        # Store the byte in the output buffer
    inc %rbx                # Increment the output buffer pointer
    inc %rsi                # Increment the source buffer pointer
    incq currentPos2(%rip)  # Increment the current output buffer position
    jmp .copy_loop          # Continue copying the next byte

.flush_buffer2:
    call outImage           # Flush the output buffer
    movq $0, currentPos2(%rip)  # Reset the output buffer position counter
    leaq outBuffer(%rip), %rbx  # Reset %rbx to the start of the output buffer
    jmp .copy_loop          # Continue copying after flushing

.done2:
    movb $0, (%rbx)         # Null-terminate the output buffer  
    pop %rbp                # Restore the base pointer
    ret                     # Return from the function


getOutPos:
    movq currentPos2(%rip), %rax
    ret

setOutPos:
    cmpq $0, %rdi
    jle setOutPosZero    # Set to zero if input is less than zero

    cmpq $63, %rdi
    jl setPosition     # If input is within the buffer bounds, set it

    # If the input position is an underflow or overflow, reset it to 0
    # This catches cases like 4294967295 which result from unsigned underflows.
    jmp setOutPosZero

setPosition:
    movq %rdi, currentPos2(%rip)  # Set the buffer position if within bounds
    ret

setOutPosZero:
    movq $0, currentPos2(%rip)
    ret


putChar:
    push %rbp                  # Save the base pointer
    mov %rsp, %rbp             # Set up the new base pointer

    # Load the current output buffer position
    call getOutPos
    leaq outBuffer(%rip), %rbx # Load the base address of the output buffer
    add %rax, %rbx             # Move %rbx to the current position in the output buffer

    # Check if the buffer is full (63 characters used, leaving space for null terminator)
    movq currentPos2(%rip), %rcx # Get the current output buffer position
    cmp $63, %rcx               # Compare with the maximum buffer size (63 characters)
    jl .store_char              # If less than 63, jump to store the character

    # If buffer is full, flush it
    call outImage               # Flush the output buffer

.store_char:
    mov %dil, (%rbx)            # Store the character in the output buffer
    incq currentPos2(%rip)      # Increment the current output buffer position

    pop %rbp                    # Restore the base pointer
    ret                         # Return from the function




# rdi = talet som ska skrivas ut
putInt:
    call getOutPos              # Get the current output buffer position
    leaq outBuffer(%rip), %rbx  # Calculate base of output buffer
    add %rax, %rbx              # Move %rbx to point to the current position in output buffer

    push %rbp                   # Save base pointer
    mov %rsp, %rbp              # Set up new base pointer

    push $0                   # push null for null termination at the end

    xor %rsi, %rsi              # Clear %rsi for negative flag

    # Check if the number is negative
    test %rdi, %rdi
    jge .convert                # If non-negative, jump to convert
    neg %rdi                    # Negate the number if negative
    mov $1, %rsi                # Set flag to indicate negative number

.convert:
    mov %rdi, %rax              # Move the number to %rax for division
    mov $10, %rcx               # Set divisor for base 10

.reverse_loop:
    xor %rdx, %rdx              # Clear %rdx for division remainder
    div %rcx                    # Divide %rax by 10, remainder in %rdx
    add $'0', %rdx              # Convert the remainder to ASCII
    push %rdx                   # Push ASCII character onto the stack

    test %rax, %rax             # Test quotient
    jnz .reverse_loop           # Continue loop if quotient is not zero

    # If the original number was negative, add a negative sign
    mov %rbx, %rax              # Move the saved original %rdi
    cmp $0, %rax
    jl .add_negative            # Jump to add negative sign if original number was negative

.stack_to_buffer:
    # Pop digits off the stack and store them in the output buffer
    test %rsi, %rsi             # Check if the number was negative
    jnz negativeCheck           # Check if the number was negative
    cmp %rsp, %rbp              # Compare stack pointer with base pointer
    je .done                    # If equal, all digits have been moved
    pop %rax                    # Pop next digit (ASCII char)



    # Check buffer space before writing the character
    movq currentPos2(%rip), %rcx # Current buffer position
    cmp $63, %rcx               # Check if buffer is full
    jge .flush_buffer           # Flush buffer if full

    mov %al, (%rbx)             # Store it at the current buffer position
    cmp $0, %rax
    je .done                    # If null, we're done
    inc %rbx                    # Increment buffer position
    jmp .stack_to_buffer        # Repeat until stack is empty

.add_negative:
    movb $'-', (%rbx)           # Store negative sign
    inc %rbx                    # Increment buffer position
    jmp .stack_to_buffer        # Continue moving digits

.flush_buffer:
    call outImage               # Flush the buffer
    movq $0, currentPos2(%rip)  # Reset the output buffer position counter
    leaq outBuffer(%rip), %rbx  # Reset %rbx to the start of the output buffer
    jmp .stack_to_buffer        # Continue processing stack

negativeCheck:
    push $'-'                   # Push negative sign if number was negative
    mov $0, %rsi                # Reset flag
    jmp .stack_to_buffer        # Continue processing stack

.done:
    leaq outBuffer(%rip), %rax  # Load address of output buffer
    sub %rax, %rbx              # Calculate new output buffer position
    mov %rbx, %rdi              # Move the offset to %rdi
    call setOutPos              # Set the new output position

    pop %rcx                    # Restore %rcx
    mov %rbp, %rsp              # Restore stack pointer
    pop %rbp                    # Restore base pointer
    ret   