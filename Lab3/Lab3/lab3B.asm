.include "m2560def.inc"
.def temp =r16
.def pattern =r17
.def debounce = r18
.def de2 = r19
.def de3 = r20
.def de4 = r21
.cseg
.org 0x0
jmp RESET
.org INT0addr ; Jump to the interrupt handler, INT0addr is the address of EXT_INT0
jmp EXT_INT0
.org INT1addr ; INT1addr is the address of EXT_INT1
jmp EXT_INT1

RESET:
ldi pattern, 15
ldi temp, low(RAMEND)
out SPL, temp
ldi temp, high(RAMEND)
out SPH, temp

ser temp
out DDRC, temp
clr temp
out PORTC, temp			;activate
out DDRD, temp
out PORTD, temp
ldi temp, (1 << ISC10) | (1 << ISC00)	;set INT0, 1 as falling-edge triggered interrupt
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
	ldi pattern, 15	

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
loop2:
	inc debounce
	loopb:	;255*255/16MHz
		inc de2
		cpi de2, 255
		brlo loopb
		clr de2
	cpi debounce, 255
	brlo loop2
clr debounce

cpi pattern, 15
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
rjmp keepgoing