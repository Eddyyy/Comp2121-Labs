.include "m2560def.inc"
; Lab2.asm
;
; Created: 23/08/2017 11:31:55 AM
; Author : Edward Thomson, Zhiwei Cao
;
.def dd_l=r15
.def dd_h=r16
.def ds_l=r17
.def ds_h=r18
.def q_l=r19
.def q_h=r20
.def pos=r21
.equ limit=128
.def bit_p_l=r22
.def bit_p_h=r23
.def empty=r8
.def tmpStore=r25

.macro doubleNum ; multiply the number by 2
	lsl @0
	rol @1
.endmacro

.macro halvedNum ; devide the number by 2
	lsr @1
	ror @0
.endmacro

.dseg


.cseg
.org 0x200
ldi r22, 1
clr r23
clr r20
clr r19

store: ;load dividend and divisor
	ldi tmpStore, low(50000)
	mov dd_l,tmpStore
	ldi dd_h,high(50000)
	ldi ds_l,low(500)
	ldi ds_h,high(500)

loop1:
	cp ds_l, dd_l
	cpc ds_h, dd_h
	brsh loop1done
	cpi ds_h, limit  ;making sure that ds is 
	brsh loop1done ;never higher than 0x8000
	doubleNum ds_l, ds_h
	doubleNum bit_p_l, bit_p_h
	rjmp loop1

loop1done:
	clr q_l
	clr q_h
	clr empty

loop2:
	cp empty, bit_p_l
	cpc empty, bit_p_h
	brsh loop2done
	ifsta:
		cp dd_l, ds_l
		cpc dd_h, ds_h
		brlo ifdone
		sub dd_l, ds_l
		sbc dd_h, ds_h
		add q_l, bit_p_l
		adc q_h, bit_p_h
	ifdone:
	halvedNum ds_l, ds_h
	halvedNum bit_p_l, bit_p_h
	rjmp loop2
loop2done:

done: rjmp done