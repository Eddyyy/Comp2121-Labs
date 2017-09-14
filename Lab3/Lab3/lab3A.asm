.include "m2560def.inc"
.def temp = r16
.def flag0 = r17
.def flag1 = r18
.equ origin = 0x0F

.cseg
.org 0x0
clr flag0
clr flag1

ldi temp, origin
out PORTC, temp 			; Write ones to all the LEDs
out DDRC, temp 				; PORTC is all outputs
ser temp
out PORTD, temp 			; Enable pull-up resistors on PORTF
clr temp
out DDRD, temp 				; PORTF is all inputs

ldi temp, 15				;15 = 0b00001111
out PORTC, temp

;-----------------------------------------
switch0:
cpi PIND0, 0 				; I'm not sure, But I thinks that PIND0 indicate that the value on bit0 of PIND.
breq instruction0			; If not pushed, check the other switch
clr flag0
rjmp switch1

instruction0:
cpi flag0, 1
breq switch1

ldi flag0, 1

dec temp
rjmp epilogue
equal:
	ldi temp, 15
epilogue:
out PORTC, temp

;------------------------------------------
switch1:
cpi PIND1, 0
breq instruction1			; If not pushed, check the other switch
clr flag1
rjmp switch0


instruction1:
cpi flag1, 1
breq switch0

ldi flag1, 1

cpi temp, 15
breq equal2
inc temp
out PORTC, temp
rjmp switch0
equal2:
	ldi temp, 0
	out PORTC, temp
	rjmp switch0 			; Now check PB0 again

