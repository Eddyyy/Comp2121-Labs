.include "m2560def.inc"
; Task D.asm
;
; Created: 14/08/2017 4:48:49 PM
; Author : Zhiwei Cao, Edward Thomson
;


.def i=r21 ;unsigned
.def j=r22 ;unsigned
.def k=r23 ;unsigned
.equ limit=5
.def tmp1=r17 ;signed
.def tmp2=r18 ;signed
.def tmpA=r19 ;signed
.def tmpB=r20 ;signed
.def zero=r8

.dseg
.org 0x200
A: .byte 25
B: .byte 25
C: .byte 50

main:
	.cseg
	ldi r16, 0; r16 is a temporary storage spot
	mov r8, r16;r8 is a register that holds the value 0
	clr i
	clr k
	ldi xl,low(A)
	ldi xh,high(A)
	ldi yl,low(B)
	ldi yh,high(B)
	ldi zl,low(C)
	ldi zh,high(C)

forloop1:
	cpi i,limit
	brsh endloop1;
	clr j
	clr tmp1
	clr tmp2

	forloop2:
		cpi j,limit
		brsh endloop2
		mov tmp1,i
		add tmp1,j
		mov tmp2,i
		sub tmp2,j
		st x+,tmp1
		st y+,tmp2
		st z+, r8
		inc j
		rjmp forloop2
	endloop2:
	inc i
	rjmp forloop1
endloop1:
	clr i
	ldi xl,low(A)
	ldi xh,high(A)
	ldi yl,low(B)
	ldi yh,high(B)
	ldi zl,low(C)
	ldi zh,high(C)

forloop3:
	cpi i,limit
	brsh forloop3_done
	clr j
	forloop4:
		cpi j,limit
		brsh forloop4_done
		
		clr k
		clr tmp1 ;tmp1 and tmp2 are used to store the result of c[i][j] during the forloop5
		clr tmp2

		forloop5:
			cpi k,limit
			brsh forloop5_done
			
			mulitple:
			ld tmpA,x+; A[i][k] -> A[i][k+1]
			ld tmpB,y
			muls tmpA, tmpB ;tempA and tempB are both signed

			add tmp1, r0
			adc tmp2, r1
			inc k
			adiw y,5; B[k][j] is added by 5 each j loop
			rjmp forloop5
		forloop5_done:

		sbiw x,5; initialize A[i+1][0] to A[i][0]
		adiw y,1; B[k][j] -> B[k][j+1] this may not be needed
		sbiw y, 25; initialize B[k][j+1] to B[0][j+1]
		st z+,tmp1
		st z+,tmp2
		inc j
		rjmp forloop4
	forloop4_done:

	inc i
	adiw x,5; move A[i][0] to A[i+1][0]
	sbiw y, 5
	rjmp forloop3
forloop3_done:
	rjmp done

done: rjmp done