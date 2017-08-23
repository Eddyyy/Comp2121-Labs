.include "m2560def.inc"
; Lab2.asm
;
; Created: 23/08/2017 11:31:55 AM
; Author : Edward Thomson, Zhiwei Cao
;
.def dividend_L=r15
.def dividend_H=r16
.def divisor_L=r17
.def divisor_H=r18
.def quot_L=r19
.def quot_H=r20


.dseg


.cseg

Loop1:
cp
cpc
bs


rmjump Loop1
Loop1_end:

done: rjmp done