.include "m2560def.inc"
; Task C.asm
;
; Created: 14/08/2017 3:16:01 PM
; Author : Zhiwei Cao, Edward Thomson
;


.def i=r16
.def constant=r17
.equ limit=10
.def sum_0=r18
.def sum_1=r19

.dseg
A: .byte 20

main:
	.cseg
	clr i
	ldi zl,low(A)
	ldi zh,high(A)
	ldi constant,200
	clr sum_0
	clr sum_1

forloop1:
	cpi i,10
	brsh endloop1
	mul i,constant
	st z+,r0
	st z+,r1
	inc i
	rjmp forloop1

endloop1:
	clr i
	ldi zl,low(A)
	ldi zh,high(A)	

forloop2:
	cpi i,10
	brsh done
	ld r20,z+
	ld r21,z+
	add sum_0,r20
	adc sum_1,r21
	inc i
	rjmp forloop2

done: rjmp done

