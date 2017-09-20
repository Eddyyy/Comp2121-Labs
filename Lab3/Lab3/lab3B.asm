.include "m2560def.inc"
.def temp =r16
.def pattern =r17
.def debounce = r18
.def de2 = r19
.equ origin = 0x0F

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
out DDRD, temp
out PORTD, temp
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
loop:
	inc debounce
	loopa:
		inc de2
		nop ;wait
		cpi de2, 255
		brlo loopa
		clr de2
	cpi debounce, 255
	brlo loop
clr debounce

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
push pattern
in yl, SPL
in yh, SPH

;-------------main-------------
loop2:
	inc debounce
	loopb:	;255*255/16MHz
		inc de2
		nop ; wait
		cpi de2, 255
		brlo loopb
		clr de2
	cpi debounce, 255
	brlo loop2
clr debounce

lds pattern, Y
cpi pattern, origin
breq equal2
inc pattern
rjmp epilogue2
equal2:
	ldi pattern, 0

;--------epilogue-----------
epilogue2:
sts Y, pattern
mov temp, pattern
pop pattern
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