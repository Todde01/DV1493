.data



null:        .byte   0x00


currentPos:
    .quad 0

.section .bss
inBuffer: 
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

   xor %rdx, %rdx             # Clear %rdx, will store the final integer value
   xor %rsi, %rsi             # Clear %rsi, will use as flag for negativity
   xor %rcx, %rcx             # Clear %rcx, count of characters processed

   movzbl (%rbx), %r8d        # Load current character into %r8
   inc %rbx                   # Move to the next character
   incq currentPos(%rip)      # Increment position

readChar:
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


#skipSign:
#   inc %rbx                    # Move to the next character in buffer
#   incq currentPos(%rip)       # Increment position in buffer
#   jmp nextChar                # Jump to read next character without conversion

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
   

#getText:
#    # rdi = inbuffer
#    # rsi = antal characters
#    loop:
#    cmp %rsi, $0
#    je return
#
#
#    movzbl (%rdi), %r8d         # Load next character
#    inc %rdi                    # Increment buffer pointer
#    dec %rsi                    # Decrement character counter
#
#
#    jmp loop
#
#
#
#return:
#    ret
#

#    # rdi = inbuffer
#    # rsi = antal characters

getText:
    call getInPos
    leaq inBuffer(%rip), %r9
    addq currentPos, %r9
    xor %rax, %rax
    xor %rcx, %rcx

getTextLoop:
    movzbl (%r9), %rcx
    cmp null, %rcx
    je getTextEnd
    cmp 


MAX POS = 64 - current pos


getTextEnd: # maybe cancel here instead idk
    call inImage
    ret

getMaxPos:
    call getInPos
    cmp $64, %rax
    jge setMaxPos

setMaxPos:
    movq $64, %rax
    ret


getChar:
    movq currentPos(%rip), %rax
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
    movq $0, %rdi

checkUpperBound:
    movq $64, %rcx
    cmpq %rdi, %rcx
    jle setPos
    movq %rcx, %rdi

setPos:
    movq %rdi, currentPos(%rip)
    ret

outImage:  
    ret

 putText:   
    ret

getOutPos:
    ret

setOutPos:
    ret

putChar:    
    ret


putInt:
    ret


