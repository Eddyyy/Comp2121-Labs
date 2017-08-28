.include "m2560def.inc"
; Lab2.asm
;
; Created: 23/08/2017 11:31:55 AM
; Author : Edward Thomson, Zhiwei Cao
;

.equ n=10
.equ x_const=3
.def i=r8
.def res_l=r16
.def res_h=r17
.def sum_0=r18
.def sum_1=r19
.def sum_2=r20
.def tmp1=r9
.def tmp2=r10

.macro multiplication ; multiply
	mov @1 ,@3 ; copy r24 to r18  @1 and @2 is num_before
	mov @2 ,@4 ; copy r25 to r19
	mul @0, @1 ; @0 is number
	mov @3, r0 
	mov @4, r1 
	mul @0, @2
	add @4, r0 ; put the result in r24, r25

.endmacro

.dseg
.org 0x200
A: .byte n

.cseg
initial:
	ldi xl,low(A)
	ldi xh,high(A)
	ldi yl,low(RAMEND)
	ldi yh,high(RAMEND)
	out SPL,yl
	out SPH,yh
	clr i
	clr res_l
	clr res_h
	clr sum_0
	clr sum_1
	clr sum_2

main:

forloop1:
	mov r21, i
	cpi r21, n
	brsh forloop1_done
	clr r21
	
	st x, i
	;get result from power
	rcall power
	mov res_l, r24
	mov res_h, r25
	
	ld r21, x+
	mul r21,res_l
	add sum_0,r0
	adc sum_1,r1
	mul r21,res_h
	add sum_1,r0
	adc sum_2,r1

	inc i;
	rjmp forloop1
forloop1_done:

end_main: rjmp end_main



power:
;-----------Prologue------------
push yl
push yh
in yl, SPL
in yh, SPH
sbiw y, 3
out SPL, yl
out SPH, yh
std Y+1, sum_0
std Y+2, sum_1
std Y+3, sum_2
;-----------main Function-------
mov r18, i
clr r19
clr r20
clr r24
clr r25
loop:
	cp r18, i
	brsh loopdone
	mov r11,r21
	ld r21, x
	multiplication r21, r19, r20, r24, r25
	st x, r21
	mov r21,r11
	clr r11
	inc r18
	jmp loop
loopdone:

;-----------Epilogue------------
	ldd sum_0, Y+1
	ldd sum_1, Y+2
	ldd sum_2, Y+3
	adiw y,3
	out SPH, yh
	out SPL, yl
	pop r29
	pop r28
	ret
