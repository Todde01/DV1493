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

    leaq inBuffer(%rip), %rbx

    xor %rdx, %rdx
    xor %rcx, %rcx

readChar:
    movzbl (%rbx), %r8d            # Load current character
    inc %rbx                       # Move to the next character
    inc currentPos(%rip)           # Increment position

    cmp $'-', %r8                  # Check if negative
    je isNegative
    cmp $'+', %r8                  # Check if positive
    je isPositive

isPositive:
    inc %rcx
    movzbl (%rbx), %r8d               # Load current character
    sub $'0', %r8                     # Convert ASCII to integer
    cmp $9, %r8                       # Compare to 9
    ja finish_parsing                 # If above '9', finish parsing
    imul $10, %rdx, %rdx              # Multiply current value by 10
    add %r8, %rdx                     # Add new digit
    inc %rbx                          # Move to the next character
    inc %rcx                          # Increment position count
    jmp parse_number                  # Continue parsing



isNegative:
    not %rdx



parseNumber:
    





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

getText:
    ret



