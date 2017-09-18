;I almost copy everything from lecture note, Some of them that I did not really understand
;I does not really understand How the timer0 working, So the basic structure of timer0 is same as the lecture note
.include "m2560def.inc"
.def temp= r16
.def output = r17

.macro clear
ldi YL, low(@0)
ldi YH, high(@0)
clr temp
st Y+, temp st Y, temp
.endmacro

.dseg
SecondCounter: .byte 1
TempCounter: .byte 2
MinuteCounter: .byte 1

.cseg
.org 0x0000
jmp RESET
.org OVF0addr
jmp Timer0OVF
jmp DEFAULT 
DEFAULT: reti


RESET: 
	ldi temp, high(RAMEND) ; initialize the stack pointer SP out SPH, temp
	ldi temp, low(RAMEND)
	clr output
	out SPL, temp
	ser temp ; set Port C as output out 
	DDRC, temp
	clr temp
	out PORTC, temp
	sts SecondCounter, temp
	sts MinuteCounter, temp
	clear TempCounter
	rjmp main 

Timer0OVF:
	in temp, SREG
	push temp 
	push YH 
	push YL 
	push r25 
	push r24
	lds r24, TempCounter
	adiw r25:r24, 1
	cpi r24, low(7812)
	ldi temp, high(7812)
	cpc r25, temp
	brne NotSecond

	clear TempCounter
	; Load the value of the second counter
	lds r24, SecondCounter
	inc r24
	cpi r24, 60
	brlo NotMinute
	clr r24; initialize The SecondCounter
	lds r25, MinuteCounter
	inc r25
	sts MinuteCounter, r25
NotMinute:
	sts SecondCounter, r24 
Show:
	clr output
	lds output, MinuteCounter
	rot output
	rot output
	rot output
	rot output
	rot output
	rot output
	lds temp, SecondCounter
	or output, temp
	out PORTC, output
	rjmp EndIF
NotSecond: ; store the new value of the temporary counter 
	sts TempCounter, r24
	sts TempCounter+1, r25
EndIF:
	pop r24
	pop r25
	pop YL
	pop YH
	pop temp
	out SREG, temp
	reti

main:
	; I don't really understand the following part, So I just copy from lecture note and keep the same process for one second
	ldi temp, 0b00000000 
	out TCCR0A, temp 
	ldi temp, 0b00000010 
	out TCCR0B, temp 
	ldi temp, 1<<TOIE0 
	sts TIMSK0, temp
	sei
loop:rjmp loop