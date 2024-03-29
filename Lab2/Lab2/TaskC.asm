 .include "m2560def.inc"
/*
 * AsmFile1.asm
 *
 *  Created: 28/08/2017 3:05:27 PM
 *   Author: Edward Thomson, Zhiwei Cao
 */

.cseg 
.org 0x200
.def counter=r16
.def n=r17
.def A=r18
.def B=r19
.def C=r20
.def tmp=r21
main:
ldi n, 8
ldi A, 1
ldi B, 3
ldi C, 2
ldi yl,low(RAMEND)
ldi yh,high(RAMEND)
out SPL,yl
out SPH,yh
clr counter
rcall move

done: rjmp done


move:
;-----------Prologue------------
push yl
push yh
in yl, SPL
in yh, SPH
sbiw y, 4
out SPL, yl
out SPH, yh
std Y+1, n ; Y+1 store n in Y+1
std Y+2, A ; Y+2 represent A in function
std Y+3, B ; Y+3 represent C in function
std Y+4, C ; Y+4 represent B in function

;-----------main Function-------
	cpi n,1
	breq increment

	ldd n, Y+1
	dec n;
	ldd A, Y+2 ;A represent first input 
	ldd B, Y+4 ;B represent second input
	ldd C, Y+3 ;C represent third input 
	rcall move

	ldi n, 1
	ldd A, Y+2
	ldd B, Y+3
	ldd C, Y+4	
	rcall move

	ldd n, Y+1
	dec n;
	ldd A, Y+4
	ldd B, Y+3
	ldd C, Y+2
	rcall move

	rjmp functionDone
increment:
	inc counter;
functiondone:
;-----------Epilogue------------
	ldd n, Y+1
	ldd A, Y+2
	ldd B, Y+3
	ldd C, Y+4
	adiw y,4
	out SPH, yh
	out SPL, yl
	pop yh
	pop yl
	ret