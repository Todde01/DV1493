// Symbolic constants
.equ UART_BASE, 0xff201000
.equ UART_DATA_REGISTER_ADDRESS, 0xff201000
.equ UART_CONTROL_REGISTER_ADDRESS, 0xff201004

.data

.text
.global _start
_start:
    // UART read
    LDR r0, =UART_DATA_REGISTER_ADDRESS

    // Do something with the data...

	
uart_loop:
    // Read data from UART
    LDR r1, [r0]                // Read the data register
    ANDS r2, r1, #0x8000        // Check if data is valid, bit 15
    BEQ uart_loop               // If data is not valid, skip to next iteration of the loop

    // Mask out the character bits (0-7)
    AND r1, r1, #0x00FF         // Isolate the character data

    // Write character back to UART
    STRB r1, [r0]               // Write the character back to the UART

    // Continue the loop
    B uart_loop
	


_halt:
    B _halt
