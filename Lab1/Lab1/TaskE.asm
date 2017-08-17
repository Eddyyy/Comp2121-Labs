.include "m2560def.inc"
; Task E.asm
;
; Created: 16/08/2017 2:02:20 PM
; Author : Edward Thomson, Zhiwei Cao
;


.def i=r16
.def j=r17
.def k=r18
.equ limit=5
.def tmp1=r19
.def tmp2=r20
.def tmp3=r21
.def tmp4=r22
.def mult_tmp=r23
.def const_low=r9
.def const_high=r10
.def tempC_low=r11
.def tempC_high=r12

.dseg
A: .byte 50
B: .byte 50
C: .byte 100

.cseg
initial:
	ldi xl, low(A)
	ldi xh, high(A)
	ldi yl, low(B)
	ldi yh, high(B)
	ldi zl, low(C)
	ldi zh, high(C)
	ldi r25,low(1024)
	mov const_low, r25
	ldi r25,high(1024)
	mov const_high, r25
	clr i
main:
	forloop1:
		cpi i, limit
		brsh forloop1_done
		clr j
		forloop2:
			cpi j,limit
			brsh end_loop2
			clr tmp1
			clr tmp2
			operation:
				mov tmp1,i
				mov tmp2,j
				add tmp1,tmp2
				mul const_low,tmp1
				mov tempC_low,r0
				mov tempC_high,r1
				mul const_high, tmp1
				add tempC_high,r0
				st x+,tempC_low
				st x+,tempC_high
				st y+,tempC_low
				st y+,tempC_high
				clr r8
				st z+,r8
				st z+,r8
				st z+,r8
				st z+,r8
			inc j
			rjmp forloop2
		end_loop2:
		inc i
		rjmp forloop1
forloop1_done:
	clr i
	ldi xl, low(A)
	ldi xh, high(A)
	ldi yl, low(B)
	ldi yh, high(B)

forloop3:
	cpi i,limit
	brsh done
	clr j
	ldi zl, low(C)
	ldi zh, high(C)
	forloop4:
		cpi j,limit
		brsh forloop4_done
		clr k
		clr tmp1
		clr tmp2
		clr tmp3
		clr tmp4
		forloop5:
			cpi k,limit
			brsh forloop5_done
			clr mult_tmp
			multiplication:
				
				ld mult_tmp,y
				mul x,y+
				add tmp1,r0
				adc tmp2,r1
				mul x+,y
				add tmp2,r0
				adc tmp3,r1
				mul mult_tmp,x
				add tmp2,r0
				adc tmp3,r1
				mul x+,y+
				add tmp3,r0
				adc tmp4,r1
				sbiw y,2
				adiw y,10
			inc k
			rjmp forloop5
		forloop5_done:
		adiw y,2;
		sbiw y,50
		sbiw x,10
		st z+,tmp1
		st z+,tmp2
		st z+,tmp3
		st z+,tmp4
		inc j
		rjmp forloop4
	forloop4_done:
	adiw x,10
	inc i
	rjmp forloop3

done: rjmp done





