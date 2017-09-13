.include "m2560def.inc"
.def temp = r16
.def debounce = r17
.def de2 = r18
.def temp1 = r19
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

;wait:
;in temp1, PIND
;andi temp1, (1<<0)
;cpi temp1, (1<<0)
;breq wait

loop:
	inc debounce
	loopa:
		inc de2
		cpi de2, 255	;255*255*1/16MHz= 0.004s
		brlo loopa
		clr de2
	cpi debounce, 255
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

;wait2:
;in temp1, PIND
;andi temp1, (1<<1)
;cpi temp1, (1<<1)
;breq wait2


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


cpi temp, 15
breq equal2
inc temp
out PORTC, temp
rjmp switch0
equal2:
	ldi temp, 0
	out PORTC, temp
	rjmp switch0 ; Now check PB0 again