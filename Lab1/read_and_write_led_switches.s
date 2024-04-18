// Symbolic constants
.equ LEDS_BASE, 0xff200000
.equ SWITCHES_BASE, 0xff200040

.global _start
_start:
    LDR r0, =SWITCHES_BASE   // Base address
	LDR r2, =LEDS_BASE
    LDR r1, [r0]             // Read switches value
	STR r1, [r2]

_halt:
    B _halt
	
	
	
	
