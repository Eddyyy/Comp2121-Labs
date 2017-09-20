.include "m2560def.inc"
.equ PATTERN = 0b11110000 ; define a pattern for 8 LEDs
.def temp = r16
.def leds = r17 ; r17 stores a LED pattern
.def second = r18
.def mint = r19
.def tmp = r20
; The macro clears a word (2 bytes) in the data memory
; The parameter @0 is the memory address for that word
.macro clear
ldi YL, low(@0) ; load the memory address to Y pointer
ldi YH, high(@0)
clr temp ; set temp to 0
st Y+, temp ; clear the two bytes at @0 in SRAM
st Y, temp
.endmacro

.dseg
SecondCounter: .byte 2 ; two-byte counter for counting seconds.
TempCounter: .byte 2 ; temporary counter used to determine if one second has passed
.cseg
.org 0x0000
jmp RESET
jmp DEFAULT ; no handling for IRQ0.
jmp DEFAULT ; no handling for IRQ1.
.org OVF0addr ; OVF0addr is the address of Timer0 Overflow Interrupt Vector
jmp Timer0OVF ; jump to the interrupt handler for Timer0 overflow.
jmp DEFAULT ; default service for all other interrupts.
DEFAULT: reti ; no interrupt handling 

RESET: ldi temp, high(RAMEND) ; initialize the stack pointer SP
 out SPH, temp
 ldi temp, low(RAMEND)
 out SPL, temp
 ser temp ; set Port C as output
 out DDRC, temp
 rjmp main ; jump to main program

 Timer0OVF: ; interrupt subroutine to Timer0
 in temp, SREG
 push temp ; prologue starts
 push YH ; save all conflicting registers in the prologue
 push YL
 push r25
 push r24 ; prologue ends
 ; Load the value of the temporary counter
 lds r24, TempCounter
 lds r25, TempCounter+1
 adiw r25:r24, 1 ; increase the temporary counter by one

 cpi r24, low(7812) ; check if (r25:r24) = 7812
 ldi temp, high(7812) ; 7812 = 106/128
 cpc r25, temp
 brne NotSecond


lds second, SecondCounter

inc2: 
cpi second, 60  ; when second = 60, mint= 59 second, then jump to inc2 which counts minute
brlo inc1
ldi tmp, 4
add second, tmp  ; mint =0b1000000=64; 2mint = 128; 4min = 256 = 00000000
mov mint, second
out PORTC, mint
rjmp endinc
inc1:
mov mint, second
out PORTC, mint

endinc:
 clear TempCounter ; reset the temporary counter
 ; Load the value of the second counter
 lds r24, SecondCounter
 lds r25, SecondCounter+1
 adiw r25:r24, 1 ; increase the second counter by one
 sts SecondCounter, r24
 sts SecondCounter+1, r25
 rjmp EndIF

NotSecond: ; store the new value of the temporary counter
 sts TempCounter, r24
 sts TempCounter+1, r25
EndIF:
 pop r24 ; epilogue starts
 pop r25 ; restore all conflicting registers from the stack
 pop YL
 pop YH
 pop temp
 out SREG, temp
 reti ; return from the interrupt

 main:

 clear TempCounter ; initialize the temporary counter to 0
 clear SecondCounter ; initialize the second counter to 0
 clr second
 clr mint

 ldi temp, 0b00000000
 out TCCR0A, temp
 ldi temp, 0b00000010
 out TCCR0B, temp ; set prescalar value to 8
 ldi temp, 1<<TOIE0 ; TOIE0 is the bit number of TOIE0 which is 0
 sts TIMSK0, temp ; enable Timer0 Overflow Interrupt
 sei ; enable global interrupt
 loop: rjmp loop ; loop forever