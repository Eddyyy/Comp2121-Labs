.include "m2560def.inc"
;
;Lab 1 task B.asm
;
; Created: 9/08/2017
; Author : Edward Thomson, Zhiwei Cao
;

.def i = r20
.def n_2 = r19
.def n_1 = r18
.def n_0 = r17
.def zero = r21
.def empty = r22
.def tmp_0 = r23
.def tmp_1 = r24
.def tmp_2 = r25
.equ limit = 6

.dseg
	result: .byte 3

.macro doubleNum
	lsl @0
	rol @1
	rol @2
.endmacro

.cseg
;main:
	rjmp bypass
		String:.db "325658"
	bypass:

	clr n_2
	clr n_1
	clr n_0
	clr i
	clr zero
	clr empty

	ldi zl,low(String<<1) ;make z point to the string
	ldi zh,high(String<<1)
	ldi yl,low(result) ;make y point to the result
	ldi yh,high(result)
	ldi zero,48	; load the ascii value of 0 to zero
	;ldi limit,6 ; load size of string

forloop:
	cpi i,limit ;compare i with size of strinb
	brsh store 

addDigit:

AddN10:
	
	mov tmp_0, n_0 ;tmp=n
	mov tmp_1, n_1
	mov tmp_2, n_2

	doubleNum tmp_0,tmp_1,tmp_2 ;tmp*2

	doubleNum n_0,n_1,n_2 ;n*8
	doubleNum n_0,n_1,n_2
	doubleNum n_0,n_1,n_2

	add n_0,tmp_0
	adc n_1,tmp_1
	adc n_2,tmp_2

	clr tmp_0
	clr tmp_1
	clr tmp_2
	
evaluateAscii:	
	lpm r16, z+
	sub r16, zero

	add n_0, r16
	adc n_1, empty
	adc n_2, empty
	
endLoop:
	inc i
	rjmp forloop

store:
	st y+, n_0
	st y+, n_1
	st y+, n_2

done: rjmp done


