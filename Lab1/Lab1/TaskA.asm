;
;Lab 1 task A.asm
;
; Created: 7/08/2017 3:11:56 PM
; Author : Edward Thomson, Zhiwei Cao
;
.def a_l=r16
.def a_h=r17
.def b_l=r18
.def b_h=r19

.dseg

.cseg

ldi r16,low(1500)
ldi r17,high(1500)
ldi r18,low(3300)
ldi r19,high(3300)


while: 
	cp a_l,b_l
	cpc a_h,b_h
	breq return
if:	
	cp a_l,b_l
	cpc a_h,b_h
	brlo else

	sub a_l,b_l
	sbc a_h,b_h

	jmp endLoop
else:
	
	sub b_l,a_l
	sbc b_h,a_h

endLoop:
	rjmp while

return:
	rjmp return