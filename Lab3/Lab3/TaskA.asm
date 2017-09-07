;Board settings: Connect PB0 and PB1 (push buttons) to PF0 and PF1
;Connect LED0:LED7 to PC0:PC7  
 
; led.asm
;
; Created: 9/4/2017 10:32:15 AM
; Author : HuiWu

.include "m2560def.inc"
.def temp =r16
.equ PATTERN1 = 0x00
.equ PATTERN2 = 0xFF
.equ PATTERN3 = 0x1F

.cseg
INT0_exit:			;pb0

sbi
INT1_exit:			;pb1

ser temp
out PORTC, temp ; Write ones to all the LEDs
out DDRC, temp
out PORTF, temp ; Enable pull-up resistors on PORTF
clr temp

out DDRF, temp ; PORTF is all inputs

switch0:
sbic PINF, 0 ; Skip the next instruction if PB0 is pushed
rjmp switch1 ; If not pushed, check the other switch
dec temp ; subtract 1 to the LEDs if the switch was pushed
out PORTC, temp

switch1:
sbic PINF, 1 ; Skip the next instruction if PB1 is pushed
rjmp switch0 ; If not pushed, check the other switch
inc temp  ; Add 1 to the LEDs if the switch was pushed
out PORTC, temp
rjmp switch0 ; Now check PB0 again