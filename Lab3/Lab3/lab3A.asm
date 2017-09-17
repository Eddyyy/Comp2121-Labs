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

ldi temp, origin				;15 = 0b00001111 = 0x0F
out PORTC, temp
nop
nop
;-----------------------------------------
switch0:
in r19, PIND			; need to store the value of PIND into a register
andi  r19, (1<<0)		; then compare that register with (not pushed)
cpi r19, (1<<0)
brne instruction1			; If not pushed, check the other switch flag
clr flag0
rjmp switch1

instruction0:
cpi flag0, 1
breq switch1

ldi flag0, 1
cpi temp, 0
breq equal0
dec temp
rjmp epilogue0
equal0:
	ldi temp, origin
epilogue0:
	out PORTC, temp

;------------------------------------------
switch1:
in r19, PIND
andi  r19, (1<<1)
cpi r19, (1<<1)
brne instruction0			; If not pushed, check the other switch flag
clr flag1
rjmp switch0


instruction1:
cpi flag1, 1
breq switch0

ldi flag1, 1
cpi temp, origin
breq equal2
inc temp
rjmp epilogue2
equal2:
	ldi temp, 0
epilogue2:
	out PORTC, temp
	rjmp switch0 			; Now check PB0 again

