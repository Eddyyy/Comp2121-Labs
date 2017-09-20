.include "m2560def.inc"
.def temp =r16
.def pattern =r17
.def de0 = r18
.def de1 = r19
.def de2 = r20
.equ origin = 0x0F

.macro wait ;nop 160 ms
    ldi  @0, 13
    ldi  @1, 253
    ldi  @2, 160
L1: dec  @2
    brne L1
    dec  @1
    brne L1
    dec  @0
    brne L1
.endmacro

.cseg
.org 0x0
jmp RESET
.org INT0addr ; Jump to the interrupt handler, INT0addr is the address of EXT_INT0
jmp EXT_INT0
.org INT1addr ; INT1addr is the address of EXT_INT1
jmp EXT_INT1

RESET:
ldi temp, origin
ldi temp, low(RAMEND)
out SPL, temp
ldi temp, high(RAMEND)
out SPH, temp

ldi temp, origin
out PORTC, temp 			; Write ones to all the LEDs
out DDRC, temp 
clr temp
out DDRF, temp
out PORTF, temp
ldi temp, (1 << ISC11) | (1 << ISC01)	;set INT0, 1 as falling-edge triggered interrupt
sts EICRA, temp ; 
in temp, EIMSK	;enable INT0
ori temp, (1<<INT0) | (1<<INT1)
out EIMSK, temp
sei ;enable Global Interrupt

jmp main

EXT_INT0:
;-------------prologue-------------
push temp
in temp, SREG
push temp

;-------------main-------------
wait de0, de1, de2

cpi pattern, 0
breq equal
dec pattern
rjmp epilogue
equal:
	ldi pattern, origin

;--------epilogue-----------
epilogue:
mov temp, pattern
out PORTC, temp
pop temp
out SREG, temp
pop temp
reti

EXT_INT1:
;-------------prologue-------------
push temp
in temp, SREG
push temp

;-------------main-------------
wait de0, de1, de2

cpi pattern, origin
breq equal2
inc pattern
rjmp epilogue2
equal2:
	ldi pattern, 0

;--------epilogue-----------
epilogue2:
mov temp, pattern
out PORTC, temp
pop temp
out SREG, temp
pop temp
reti

main: ; main - does nothing but increment a counter
clr temp
keepgoing:
inc temp
nop
rjmp keepgoing