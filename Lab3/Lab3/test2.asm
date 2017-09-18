.include "m2560def.inc"

.def sec_lim_0 = r16
.def sec_lim_1 = r17
.def tmp = r18
.def inc_0 = r19
.def inc_1 = r20
.def inc_2 = r21
.def empty = r22
.def one = r12
.def second = r13
.def min = r14

.cseg
	.org 0x200
	initial:
	clr empty
	clr inc_0
	clr inc_1
	clr inc_2
	clr one
	inc one
	ldi sec_lim_0, 0b01101010
	ldi sec_lim_1, 0b00011000
	clr min
	clr second

	ser tmp
	out DDRC, tmp
	clr tmp
	out PORTC,tmp

	;00011000 01101010 00000000 = 16MHZ

main:
one_second_loop:
	inc inc_0
	cpi inc_0,255
	brlo one_second_loop
	clr inc_0

	add inc_1, one
	adc inc_2, empty
	cp inc_0, sec_lim_0
	cpc inc_1, sec_lim_1
	brlo one_second_loop

end_one_second:
	inc second
	cpi min, 60
	brlo show;
	clr second
	inc min
show:
	mov tmp, min
	rol tmp ; rotate minutes to bit7:6
	rol tmp
	rol tmp
	rol tmp
	rol tmp
	rol tmp
	or tmp, second; combin minutes and second into tmp
do_show:
	out PORTC,tmp

reset_one_second:
	clr inc_0
	clr inc_1
	clr inc_2
	clr tmp
	rjmp main








