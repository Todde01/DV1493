// Symbolic constants
.equ UART_BASE, 0xff201000
.equ UART_DATA_REGISTER_ADDRESS, 0xff201000
.equ UART_CONTROL_REGISTER_ADDRESS, 0xff201004
.equ LEDS_BASE, 0xff200000
.equ SWITCHES_BASE, 0xff200040
.equ DISPLAYS_BASE_1, 0xff200020
.equ DISPLAYS_BASE_2, 0xff200030

.data
.align 2
    display_codes:
		.byte 0b00111111
        .byte 0b00000110
        .byte 0b01011011
        .byte 0b01001111
        .byte 0b01100110
        .byte 0b01101101
        .byte 0b01111101
        .byte 0b00000111
        .byte 0b01111111
        .byte 0b01100111
        .byte 0b01110111
        .byte 0b01111100
        .byte 0b00111001
        .byte 0b01011110
        .byte 0b01111001
        .byte 0b01110001
		
.text
.global _start
_start:
    // Initialize registers
    LDR r0, =UART_DATA_REGISTER_ADDRESS
    LDR r5, =DISPLAYS_BASE_1
    LDR r3, =display_codes
    MOV r6, #0   // This register will keep the current index of display_codes

uart_loop:
    // Read data from UART
    LDR r1, [r0]                // Read the data register
    ANDS r2, r1, #0x8000        // Check if data is valid, bit 15
    BEQ uart_loop               // If data is not valid, skip to next iteration of the loop

    // Mask out the character bits (0-7)
    AND r1, r1, #0x00FF         // Isolate the character data

    CMP r1, #'u'                // If 'U' is pressed, increment
    BEQ increment
    CMP r1, #'d'                // If 'D' is pressed, decrement
    BEQ downcrement

increment:
    ADD r6, r6, #1              // Increment index
    AND r6, r6, #0x0F           // Ensure index wraps around after 0xF
    B update_display

downcrement:
    SUB r6, r6, #1              // Decrement index
    AND r6, r6, #0x0F           // Ensure index wraps around after 0x0
    B update_display

update_display:
    LDRB r4, [r3, r6]           // Load the display code from display_codes based on index
    STR r4, [r5]                // Write to the display
    B uart_loop

_halt:
    B _halt
