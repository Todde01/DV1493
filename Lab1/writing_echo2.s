// Symbolic constants
.equ UART_BASE, 0xff201000
.equ UART_DATA_REGISTER_ADDRESS, 0xff201000
.equ UART_CONTROL_REGISTER_ADDRESS, 0xff201004

.data

.text
.global _start
_start:
    LDR r0, =UART_DATA_REGISTER_ADDRESS  // UART data register address

echo_loop:
    LDR r1, [r0]                // Read the data register
    ANDS r2, r1, #0x8000        // Check if data is valid, bit 15 (Data Ready bit)
    BEQ echo_loop               // If no valid data, loop back and check again

    AND r1, r1, #0xFF           // Mask out everything except the data bits (0-7)
    STRB r1, [r0]               // Write the character back to the UART

    B echo_loop                 // Repeat the loop indefinitely

_halt:
    B _halt                     // A safety halt if ever needed