.include "m2560def.inc"

.def sec_lim_0 = r15
.def sec_lim_1 = r16
.def sec_lim_2 = r17
.def tmp = r23
.def inc_0 = r19
.def inc_1 = r20
.def inc_2 = r21
.def empty = r12
.def one = r13
.def second = r18
.def min = r22

.cseg
	.org 0x0
	jmp RESET

	.org 0x200
	RESET:
	clr empty
	clr inc_0
	clr inc_1
	clr inc_2
	clr one
	inc one
	clr sec_lim_0	;equivalent of ldi sec_lim_0, 0b00000000
	ldi sec_lim_1, 0b01101010
	ldi sec_lim_2, 0b00000000
	clr min
	clr second

	ser tmp
	out DDRC, tmp
	clr tmp
	out PORTC,tmp


	;00011000 01101010 00000000 = 1.6MHz
	;11110100 00100100 00000000 = 16MHz

main:
one_second_loop: ;run for one single second
	add inc_0, one
	adc inc_1, empty
	adc inc_2, empty
	out PORTC, inc_0
	cp inc_0, sec_lim_0
	cpc inc_1, sec_lim_1
	cpc inc_2, sec_lim_2
	brlo one_second_loop

end_one_second:
	inc second
	cpi second, 60
	brlo show;
	clr second
	inc min
show:
	mov tmp, min
	;clr r24
	;rol tmp  rotate minutes to bit7:6
	;ldi r24,64
	;mul tmp, r24
	;add tmp, r0
	clr tmp
	or second, tmp; combin minutes and second into tmp
do_show:
	out PORTC,tmp
	nop
	nop

reset_one_second:
	clr inc_0
	clr inc_1
	clr inc_2
	clr tmp
	rjmp main

forever:
rjmp forever







