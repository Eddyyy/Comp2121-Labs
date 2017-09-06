.include "m2560def.inc"
; Lab2.asm
;
; Created: 23/08/2017 11:31:55 AM
; Author : Edward Thomson, Zhiwei Cao
;

.equ n_const=10 ;global
.equ x_const=3 ;global
.def i=r8 ;main
.def res_l=r16 ;main
.def res_h=r17 ;main
.def sum_0=r18 ;main
.def sum_1=r19 ;main
.def sum_2=r20 ;main
.def tmp1=r9 ;main
.def tmp2=r10 ;main


;@0 const to multiply with
;@1 temp to stored previous
;@2 value of result
;@3 resultl
;@4 resulth
.macro multiplication ; multiply
	mov @1 ,@3 
	mov @2 ,@4
	mul @0, @1
	mov @3, r0 
	mov @4, r1 
	mul @0, @2
	add @4, r0

.endmacro

.dseg
.org 0x200
A: .byte n_const

.cseg
rjmp initial
n: .db n_const
x_c: .db x_const
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
	ldi zl, low(n<<1)
	ldi zh, high(n<<1)
	lpm r21, z
	cp r21, i
	brlo forloop1_done
	clr r21
	
	st x, i
	;get result from power
	in yl, SPL
	in yh, SPH
	sbiw Y, 17

	ldi zl, low(x_c<<1)
	ldi zh, high(x_c<<1)
	lpm r22, z ;store x_const
	std Y+1, r22 ;pass number to the function

	std Y+2, i ;pass powerto the function

	rcall power

	ldd r24, Y+4
	ldd r25, Y+3

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
	push YL
	push YH
	push i
	push res_l
	push res_h
	push sum_0
	push sum_1
	push sum_2
	push tmp1
	push tmp2

	in yl, SPL
	in yh, SPH
	sbiw y, 9
	out SPL, yl
	out SPH, yh

	;initialize variables

	clr r19 ; templ
	std Y+3, r19 ;initialize temp to 0
	clr r20 ; temph
	std Y+2, r20 ;^^

	clr r18
	ldi r18,1 ;r18 is function i
	std Y+1, r18 ;initialize funtion i to 1

	clr r24 ; numl
	clr r25 ; numh
	ldi r24,1 ;num = 1
	std Y+5, r24 ;initialize num to 1
	std Y+4, r25

;-----------main Function-------
	ldd r19, Y+3 ;templ
	ldd r20, Y+2 ;temph
	ldd r18, Y+1 ;i
	ldd r24, Y+5 ;numl
	ldd r25, Y+4 ;numh
	ldd r16, Y+6 ;number
	ldd r17, Y+7 ;power

	loop:
		cp r17, r18
		brlo loopdone
		multiplication r16, r19, r20, r24, r25
		inc r18
		jmp loop
	loopdone:

	std Y+9, r24
	std Y+8, r25

;-----------Epilogue------------
	in yl, SPL
	in yh, SPH
	adiw y, 9
	out SPH, yh
	out SPL, yl

	pop tmp2
	pop tmp1
	pop sum_2
	pop sum_1
	pop sum_0
	pop res_h
	pop res_l
	pop i
	pop YH
	pop YL
	
	ret
