;Uses pwm and PB00 and PB01 to control motor speed

.include "m2560def.inc"

.def temp = r16

.org 0x00
jmp RESET



RESET:
ldi temp, 0b00010000
sts DDRE, temp ; set PE4 (OC3B) as output.
ldi temp, 0x4A  ; (it may need to start at 0) 
				; this value and the operation mode determine the PWM duty cycle
sts OCR3BL, temp
clr temp
sts OCR3BH, temp
ldi temp, (1 << CS30) ; CS30=1: no prescaling
sts TCCR3B, temp
ldi temp, (1<< WGM30)|(1<<COM3B1)
; WGM30=1: phase correct PWM, 8 bits
; COM3B1=1: make OC3B override the normal port functionality of the I/O pin PE4
sts TCCR3B, temp

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




main:
halt: rjmp halt
