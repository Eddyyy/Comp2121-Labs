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
.org INT0addr ; INT0addr is the address of EXT_INT0
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
ldi temp, (2 << ISC10) | (2 << ISC00)
sts EICRA, temp
in temp, EIMSK
ori temp, (1<<INT0) | (1<<INT1)
out EIMSK, temp
sei

jmp main

EXT_INT0:
push temp
in temp, SREG
push temp
loop:
	inc debounce
	loopa:
		inc de2
			loopi:
				inc de3
					loopc:
						inc de4
						cpi de4, 15
						brlo loopc
						clr de4
				cpi de3, 15
				brlo loopi
				clr de3
		cpi de2, 15
		brlo loopa
		clr de2
	cpi debounce, 15
	brlo loop
clr debounce
clr de2
clr de3
cpi pattern, 0
breq equal
dec pattern
rjmp epilogue
equal:
	ldi pattern, 15	
epilogue:
mov temp, pattern
out PORTC, temp
pop temp
out SREG, temp
pop temp
reti

EXT_INT1:
push temp
in temp, SREG
push temp
loop2:
	inc debounce
	loopb:
		inc de2
			loopii:
				inc de3
						loopd:
						inc de4
						cpi de4, 15
						brlo loopd
						clr de4
				cpi de3, 15
				brlo loopii
				clr de3
		cpi de2, 15
		brlo loopb
		clr de2
	cpi debounce, 15	
	brlo loop2
clr debounce
clr de2
clr de3
cpi pattern, 15
breq equal2
inc pattern
rjmp epilogue2
equal2:
	ldi pattern, 0

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