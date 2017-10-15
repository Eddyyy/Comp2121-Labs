;Uses pwm and PB00 and PB01 to control motor speed

.include "m2560def.inc"
.def temp = r16
ldi temp, 0b00001000
sts DDRL, temp ; set PL3 (OC5A) as output.
ldi temp, 0x4A ; this value and the operation mode determine the PWM duty cycle
sts OCR5AL, temp
clr temp
sts OCR5AH, temp
ldi temp, (1 << CS50) ; CS50=1: no prescaling
sts TCCR5B, temp
ldi temp, (1<< WGM50)|(1<<COM5A1)
; WGM50=1: phase correct PWM, 8 bits
; COM5A1=1: make OC5A override the normal port functionality of the I/O pin PL3
sts TCCR5A, temp
halt: rjmp halt