.data
numbers:
    .word 1,2,3,4,5,6,7,8,9,10,0

.global _start
_start:
    LDR r0,=numbers
    LDR r1, [r0]
    

