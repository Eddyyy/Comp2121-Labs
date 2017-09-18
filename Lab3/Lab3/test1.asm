/*
 * test1.asm
 * a program to purely explore the buttons  and LEDs
 *  Created: 17/09/2017 9:38:21 PM
 *   Author: Edward
 */ 
.include "m2560def.inc"
.def temp = r16
.def debl = r17
.def debh = r18
.def templ = r20
.def temph = r21
.equ origin = 0x0F

.cseg
.org 0x0

ldi temp, origin
out PORTC, temp
ser temp
out DDRC, temp
out PORTF, temp
clr temp
out DDRF, temp 

ldi temp, origin
out PORTC, temp

;)

;----------------button0----------------
button0:
	sbic PINF, 0
	rjmp button1

clr debl
clr debh
ldi templ, 1
clr temph
wait0:
	cpi debh, 255
	breq endWait0

	add debl, templ
	adc debh, temph
	nop
rjmp wait0
endWait0:


cpi temp, 0		; if temp ==0
breq equal0
dec temp		; else temp--;
rjmp displayLED0
equal0:			; set temp back to 15 or 0x0F or 0b00001111
	ldi temp, origin

displayLED0:
	out PORTC, temp

testButtonReleased0:
	sbis PINF, 0
	rjmp testButtonReleased0

buttonReleased0:
	rjmp button1


;------------------button1------------------
button1:
	sbic PINF, 1
	rjmp button0

clr debl
clr debh
ldi templ, 1
clr temph
wait1:
	cpi debh, 255
	breq endWait1

	add debl, templ
	adc debh, temph
	nop
rjmp wait1
endWait1:


cpi temp, origin		; if temp == 0b00001111
breq equal1
inc temp		; else temp++;
rjmp displayLED1
equal1:			; set temp back to 0
	ldi temp, 0

displayLED1:
	out PORTC, temp

testButtonReleased1:
	sbis PINF, 1
	rjmp testButtonReleased1
	
buttonReleased1:
	rjmp button0




end: rjmp end