/******************************************************************************
    Define symbols
******************************************************************************/
// Proposed stack base addresses
.equ SVC_MODE_STACK_BASE, 0x3FFFFFFF - 3 // set SVC stack to top of DDR3 memory
.equ IRQ_MODE_STACK_BASE, 0xFFFFFFFF - 3 // set IRQ stack to A9 onchip memory

// GIC Base addresses
.equ GIC_CPU_INTERFACE_BASE, 0xFFFEC100
.equ GIC_DISTRIBUTOR_BASE, 0xFFFED000

// Other I/O device base addresses
.equ LED_BASE, 0xff200000
.equ SW_BASE, 0xff200040
.equ BTN_BASE, 0xff200050
.equ DISPLAYS_BASE, 0xff200020
.equ UART_BASE, 0xff201000
.equ UART_DATA_REGISTER, 0xff201000
.equ UART_CONTROL_REGISTER, 0xff201004

.text // Code section
.org 0x00  // Address of interrupt vector
    B _start    // reset vector
    B SERVICE_UND // undefined instruction vector
    B SERVICE_SVC // software interrrupt (supervisor call) vector
    B SERVICE_ABT_INST // aborted prefetch vector
    B SERVICE_ABT_DATA // aborted data vector
    .word 0 // unused vector
    B SERVICE_IRQ // IRQ interrupt vector
    B SERVICE_FIQ // FIQ interrupt vector
	
.global _start
_start:
   /* 1. Set up stack pointers for IRQ and SVC processor modes */
    MSR CPSR_c, #0b11010010 // change to IRQ mode with interrupts disabled
    LDR SP, =IRQ_MODE_STACK_BASE // initiate IRQ mode stack

    MSR CPSR, #0b11010011 // change to supervisor mode, interrupts disabled
    LDR SP, =SVC_MODE_STACK_BASE // initiate supervisor mode stack
	
   /* 2. Configure the Generic Interrupt Controller (GIC). Use the given help function CONFIG_GIC! */
    // R0: The Interrupt ID to enable (only one supported for now)
    MOV R0, #80  // UART Interrupt ID = 80
    BL CONFIG_GIC // configure the ARM GIC
	
	    // Initialize the UART with receive interrupts enabled
    LDR R0, =UART_CONTROL_REGISTER
    MOV R1, #0x1 // enable REceive interrupts
    STR R1, [R0]
	

   /* 4. Change to the processor mode for the main program loop (for example supervisor mode) */
    /* 5. Enable the processor interrupts (IRQ in our case) */
    MSR CPSR_c, #0b01010011  // IRQ unmasked, MODE = SVC
	
_main:
    B _main  // Just wait for interrupts to handle!
 
SERVICE_IRQ:
    PUSH {R0-R7, LR}
    /* 1. Read and acknowledge the interrupt at the GIC.The GIC returns the interrupt ID. */
    /* Read and acknowledge the interrupt at the GIC: Read the ICCIAR from the CPU Interface */
    LDR R4, =GIC_CPU_INTERFACE_BASE  // 0xFFFEC100
    LDR R5, [R4, #0x0C] // read current Interrupt ID from ICCIAR

    /* 2. Check which device raised the interrupt */
CHECK_UART_INTERRUPT:
    CMP R5, #80  // UART Interrupt ID

    BNE SERVICE_IRQ_DONE // if not recognized, some error handling or just return from interrupt

    /*
        3. Handle the specific device interrupt
        and
        4. Acknowledge the specific device interrupt
    */
    BL UART_INTERRUPT_HANDLER
	
SERVICE_IRQ_DONE:
    /* 5. Inform the GIC that the interrupt is handled */
    STR R5, [R4, #0x10] // write to ICCEOIR
	    /* 6. Return from interrupt */
    POP {R0-R7, LR}
    SUBS PC, LR, #4
	
UART_INTERRUPT_HANDLER:
    PUSH {LR}
    LDR R0, =UART_DATA_REGISTER
    LDR R1, [R0]  // read from uart, also clears the interrupt

    AND R1, R1, #0xFF // mask out the character

    // Do something with the character...
    STR R1, [R0] // echo the character back to the terminal

    POP {PC}
	
	
   /* Undefined instructions */
SERVICE_UND:
    B SERVICE_UND
    /* Software interrupts */
SERVICE_SVC:
    B SERVICE_SVC
    /* Aborted data reads */
SERVICE_ABT_DATA:
    B SERVICE_ABT_DATA
    /* Aborted instruction fetch */
SERVICE_ABT_INST:
    B SERVICE_ABT_INST
    /* FIQ */
SERVICE_FIQ:
    B SERVICE_FIQ
	
	
	
/*******************************************************************
    HELP FUNCTION!
    --------------
Configures the Generic Interrupt Controller (GIC)

Arguments:
    R0: Interrupt ID
*******************************************************************/
CONFIG_GIC:
    PUSH {LR}
    /* To configure a specific interrupt ID:
    * 1. set the target to cpu0 in the ICDIPTRn register
    * 2. enable the interrupt in the ICDISERn register */
    /* CONFIG_INTERRUPT (int_ID (R0), CPU_target (R1)); */
    MOV R1, #1 // this field is a bit-mask; bit 0 targets cpu0
    BL CONFIG_INTERRUPT
    /* configure the GIC CPU Interface */
    LDR R0, =GIC_CPU_INTERFACE_BASE // base address of CPU Interface, 0xFFFEC100
    /* Set Interrupt Priority Mask Register (ICCPMR) */
    LDR R1, =0xFFFF // enable interrupts of all priorities levels
    STR R1, [R0, #0x04]
    /* Set the enable bit in the CPU Interface Control Register (ICCICR).
    * This allows interrupts to be forwarded to the CPU(s) */
    MOV R1, #1
    STR R1, [R0]
    /* Set the enable bit in the Distributor Control Register (ICDDCR).
    * This enables forwarding of interrupts to the CPU Interface(s) */
    LDR R0, =GIC_DISTRIBUTOR_BASE   // 0xFFFED000
    STR R1, [R0]
    POP {PC}


/*********************************************************************
    HELP FUNCTION!
    --------------
Configure registers in the GIC for an individual Interrupt ID.

We configure only the Interrupt Set Enable Registers (ICDISERn) and
Interrupt Processor Target Registers (ICDIPTRn). The default (reset)
values are used for other registers in the GIC.

Arguments:
    R0 = Interrupt ID, N
    R1 = CPU target
*********************************************************************/
CONFIG_INTERRUPT:
    PUSH {R4-R5, LR}
    /* Configure Interrupt Set-Enable Registers (ICDISERn).
     * reg_offset = (integer_div(N / 32) * 4
     * value = 1 << (N mod 32) */
    LSR R4, R0, #3 // calculate reg_offset
    BIC R4, R4, #3 // R4 = reg_offset
    LDR R2, =0xFFFED100 // Base address of ICDISERn
    ADD R4, R2, R4 // R4 = address of ICDISER
    AND R2, R0, #0x1F // N mod 32
    MOV R5, #1 // enable
    LSL R2, R5, R2 // R2 = value
    /* Using the register address in R4 and the value in R2 set the
     * correct bit in the GIC register */
    LDR R3, [R4] // read current register value
    ORR R3, R3, R2 // set the enable bit
    STR R3, [R4] // store the new register value
    /* Configure Interrupt Processor Targets Register (ICDIPTRn)
     * reg_offset = integer_div(N / 4) * 4
     * index = N mod 4 */
    BIC R4, R0, #3 // R4 = reg_offset
    LDR R2, =0xFFFED800 // Base address of ICDIPTRn
    ADD R4, R2, R4 // R4 = word address of ICDIPTR
    AND R2, R0, #0x3 // N mod 4
    ADD R4, R2, R4 // R4 = byte address in ICDIPTR
    /* Using register address in R4 and the value in R2 write to
     * (only) the appropriate byte */
    STRB R1, [R4]
    POP {R4-R5, PC}
	
	
	

	
	
