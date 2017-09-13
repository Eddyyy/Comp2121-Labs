.include "m2560def.inc"
.def temp = r16
.def debounce = r17
.def de2 = r18
.def de3 = r19
.def de4 = r20
.equ origin = 0x0F

.cseg
.org 0x0
ldi temp, origin
out PORTC, temp ; Write ones to all the LEDs
out DDRC, temp ; PORTC is all outputs
ser temp
out PORTD, temp ; Enable pull-up resistors on PORTF
clr temp
out DDRD, temp ; PORTF is all inputs

ldi temp, 15		;15 = 0b00001111
out PORTC, temp

switch0:
sbic PIND, 0 ; Skip the next instruction if PB0 is pushed
rjmp switch1 ; If not pushed, check the other switch
loop:
	inc debounce
	loopa:
		inc de2
			loopi:
				inc de3
						loopc:
						inc de4
						cpi de4, 255
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
dec temp
rjmp epilogue
equal:
	ldi temp, 15
epilogue:
out PORTC, temp

switch1:
sbic PIND, 1 ; Skip the next instruction if PB1 is pushed
rjmp switch0 ; If not pushed, check the other switch


loop2:
	inc debounce
	loopb:	;255*15*15*15*1/16MHz
		inc de2
			loopii:
				inc de3
						loopd:
						inc de4
						cpi de4, 255
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


cpi temp, 15
breq equal2
inc temp
out PORTC, temp
rjmp switch0
equal2:
	ldi temp, 0
	out PORTC, temp
	rjmp switch0 ; Now check PB0 again