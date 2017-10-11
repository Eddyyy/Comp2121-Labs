;IMPORTANT NOTICE: 
;The labels on PORTL are reversed, i.e., PLi is actually PL7-i (i=0, 1, бн, 7).  

;Board settings: 
;Connect the four columns C0~C3 of the keypad to PL3~PL0 of PORTL and the four rows R0~R3 to PL7~PL4 of PORTL.
;Connect LED0~LED7 of LEDs to PC0~PC7 of PORTC.
    
; For I/O registers located in extended I/O map, "IN", "OUT", "SBIS", "SBIC", 
; "CBI", and "SBI" instructions must be replaced with instructions that allow access to 
; extended I/O. Typically "LDS" and "STS" combined with "SBRS", "SBRC", "SBR", and "CBR".

.include "m2560def.inc"
.def temp =r21
.def row =r17
.def col =r18
.def mask =r19
.def temp2 =r20
.def flag = r22
.def counter = r23
.def sign = r24
.equ PORTLDIR = 0xF0
.equ INITCOLMASK = 0xEF
.equ INITROWMASK = 0x01
.equ ROWMASK = 0x0F


.macro do_lcd_command
	ldi r16, @0
	rcall lcd_command
	rcall lcd_wait
.endmacro
.macro do_lcd_data
	mov r16, @0
	rcall lcd_data
	rcall lcd_wait
.endmacro

.macro doubleNum
	lsl @0
	rol @1
.endmacro

.macro tentimes
	movw @3:@2,@1:@0
	doubleNum @2,@3
	doubleNum @0,@1
	doubleNum @0,@1
	doubleNum @0,@1
	add @0,@2
	adc @1,@3
	clr @2
	clr @3
.endmacro

.macro HalveNum
	lsr @0
	ror @1
.endmacro

.macro DivideTenTimes
	movw @3:@2,@1:@0
	HalveNum @3,@2
	HalveNum @1,@0
	HalveNum @1,@0
	HalveNum @1,@0
	sub @1,@3
	sbc @0,@2
	clr @2
	clr @3
.endmacro


.dseg
.org 0x200
A: .byte 2
B: .byte 2

.cseg
jmp RESET

.org 0x72
RESET:
ldi temp, low(RAMEND)
out SPL, temp
ldi temp, high(RAMEND)
out SPH, temp
ldi temp, PORTLDIR ; columns are outputs, rows are inputs
STS DDRL, temp     ; cannot use out

ser temp
out DDRF, temp
out DDRA, temp
clr temp
out PORTF, temp
out PORTA, temp

clr sign
clr sign2
clr counter
do_lcd_command 0b00111000 ; 2x5x7
rcall sleep_5ms
do_lcd_command 0b00111000 ; 2x5x7
rcall sleep_1ms
do_lcd_command 0b00111000 ; 2x5x7
do_lcd_command 0b00111000 ; 2x5x7
do_lcd_command 0b00001000 ; display off?
do_lcd_command 0b00000001 ; clear display
do_lcd_command 0b00000110 ; increment, no display shift
do_lcd_command 0b00001110 ; Cursor on, bar, no blink


; main keeps scanning the keypad to find which key is pressed.
main:
ldi mask, INITCOLMASK ; initial column mask
clr col ; initial column
colloop:
STS PORTL, mask ; set column to mask value
; (sets column 0 off)
ldi temp, 0xFF ; implement a delay so the
; hardware can stabilize
delay:
dec temp
brne delay
LDS temp, PINL ; read PORTL. Cannot use in 
andi temp, ROWMASK ; read only the row bits
cpi temp, 0xF ; check if any rows are grounded
breq nextcol ; if not go to the next column
ldi mask, INITROWMASK ; initialise row check
clr row ; initial row
rowloop:      
mov temp2, temp
and temp2, mask ; check masked bit
brne skipconv ; if the result is non-zero,
; we need to look again
rcall convert ; if bit is clear, convert the bitcode
jmp main ; and start again
skipconv:
inc row ; else move to the next row
lsl mask ; shift the mask to the next bit
jmp rowloop          
nextcol:     
cpi col, 3 ; check if we are on the last column
brne Continue ; if so, no buttons were pushed,
; so start again.
clr flag
rjmp main
Continue:
sec ; else shift the column mask:
; We must set the carry bit
rol mask ; and then rotate left by a bit,
; shifting the carry into
; bit zero. We need this to make
; sure all the rows have
; pull-up resistors
inc col ; increment column value
jmp colloop ; and check the next column
; convert function converts the row and column given to a
; binary number and also outputs the value to PORTC.
; Inputs come from registers row and col and output is in
; temp.
convert:
cpi col, 3 ; if column is 3 we have a letter
breq letters
cpi row, 3 ; if row is 3 we have a symbol or 0
breq symbols
mov temp, row ; otherwise we have a number (1-9)
lsl temp ; temp = row * 2
add temp, row ; temp = row * 3
add temp, col ; add the column address
; to get the offset from 1
inc temp ; add 1. Value of switch is
; row*3 + col + 1.
jmp number_convert
letters:
ldi temp, 0b01000001
add temp, row ; increment from 0xA by the row value
jmp convert_end
symbols:
cpi col, 0 ; check if we have a star
breq star
cpi col, 1 ; or if we have zero
breq zero
ldi temp, 0b00100011 ; we'll output 0xF for hash
jmp convert_end
star:
ldi temp, 0b00101010 ; we'll output 0xE for star
jmp convert_end
zero:
clr temp ; set to zero
jmp number_convert


number_convert:
ldi r17, 0x30
add temp, r17

convert_end:
cpi counter,17 ; 16 is maximum number of LCD
brlo not_clean_line
ldi counter, 1

do_lcd_command 0b00000001 ; clear display
do_lcd_command 0b00001110 ; Cursor on, bar, no blink
do_lcd_data temp
rjmp convert_ret
not_clean_line:
cpi flag, 1
breq convert_ret
ldi flag, 1
inc counter
do_lcd_data temp

in yl, SPL
in yh, SPH
sbiw y, 17
rcall Function

convert_ret:
ret ; return to caller

;-------------------------------LCD PART

.equ LCD_RS = 7
.equ LCD_E = 6
.equ LCD_RW = 5
.equ LCD_BE = 4

.macro lcd_set
	sbi PORTA, @0
.endmacro
.macro lcd_clr
	cbi PORTA, @0
.endmacro

;
; Send a command to the LCD (r16)
;

lcd_command:
	out PORTF, r16
	nop
	lcd_set LCD_E
	nop
	nop
	nop
	lcd_clr LCD_E
	nop
	nop
	nop
	ret

lcd_data:
	out PORTF, r16
	lcd_set LCD_RS
	nop
	nop
	nop
	lcd_set LCD_E
	nop
	nop
	nop
	lcd_clr LCD_E
	nop
	nop
	nop
	lcd_clr LCD_RS
	ret

lcd_wait:
	push r16
	clr r16
	out DDRF, r16
	out PORTF, r16
	lcd_set LCD_RW
lcd_wait_loop:
	nop
	lcd_set LCD_E
	nop
	nop
        nop
	in r16, PINF
	lcd_clr LCD_E
	sbrc r16, 7
	rjmp lcd_wait_loop
	lcd_clr LCD_RW
	ser r16
	out DDRF, r16
	pop r16
	ret

.equ F_CPU = 16000000
.equ DELAY_1MS = F_CPU / 4 / 1000 - 4
; 4 cycles per iteration - setup/call-return overhead

sleep_1ms:
	push r24
	push r25
	ldi r25, high(DELAY_1MS)
	ldi r24, low(DELAY_1MS)
delayloop_1ms:
	sbiw r25:r24, 1
	brne delayloop_1ms
	pop r25
	pop r24
	ret

sleep_5ms:
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	ret


;-----------Prologue------------
Function:
	push XL
	push XH
	push YL
	push YH
	push r16
	push r17
	push r18
	push r19
	push r20
	push r21
	push r22;<<<Y+3
	push r23
	push r24
	push r25

	in yl, SPL
	in yh, SPH
;-----------main Function-------
	ldd r16, Y+4; temp = r21
	;r16 = temp

	cpi r16, 0b00110000 ;'0'
	brlo gotoEndFunction ;too far for a relative jump to go straight to endfunction
	cpi r16, 0b01000100 ;'D'
	brsh gotoEndFunction
	cpi r16, 0b01000001 ; 'A'
	brsh signtest2

signtest2:
	cpi sign,0
	brne CalculateFirstSign
setsign:
	cpi r16, 0b01000011 ;'C'
	breq gotoResult ;too far for a relative jump to go straight to result
	ldi r17,0b01000000 ;'A'-1
	sub r16,r17
	mov sign, r16
	rjmp endfunction

rjmp ignore
gotoEndFunction:
	jmp endfunction
gotoResult:
	jmp result
ignore:

Loadtest:
	ldd r25, Y+2
	ldd r24, Y+1

	cpi sign, 0; initial, 1 + 2 -
	breq loadA


CalculateFirstSign:
	ldi xl,low(A)
	ldi xh,high(A)
	ld r16,x+
	ld r17,x
	ldi xl,low(B)
	ldi xh,high(B)
	ld r18,x+
	ld r19,x
	cpi sign, 1
	brne subtract
	add r16,r18
	adc r17,r19
	rjmp endCalculate
	subtract:
	sub r16,r18
	sbc r17,r19
	rjmp endCalculate

endCalculate:
	;mov the sign position
	mov sign, sign2
	ldi xl,low(A)
	ldi xh,high(A) 
	st xl,r16
	st xh,r17
	;initial B
	clr r18
	ldi xl,low(B)
	ldi xh,high(B)
	st xl,r18
	st xh,r18
	rjmp setsign

LoadB:
	ldi xl,low(B)
	ldi xh,high(B)
	ld r16,x+
	ld r17,x
	tentimes r16, r17, r18, r19
	sbi temp, 5 ; 0x30 == 0b00110000
	sbi temp, 6 ; might be better to do ldi temp, (1<<5)||(1<<6)
	add r16,temp

	ldi xl,low(B)
	ldi xh,high(B)
	st xl,r16
	st xh,r17
	rjmp endfunction
loadA:
	ldi xl,low(A)
	ldi xh,high(A)
	ld r16,x+
	ld r17,x
	tentimes r16,r17,r18,r19
	sbi temp, 5 ; 0x30 == 0b00110000
	sbi temp, 6 ; might be better to do ldi temp, (1<<5)||(1<<6)
	add r16,temp

	ldi xl,low(A)
	ldi xh,high(A)
	st xl,r16
	st xh,r17
	rjmp endfunction

result:
	ldi xl,low(A)
	ldi xh,high(A)
	ld r16,x+
	ld r17,x
	clr r4
	clr r5
	clr r20
	clr r21

Forloop1:;reverse order
	movw r19:r18, r17:r16
	DivideTenTimes r18,r19,r24,r25
	tentimes r18,r19,r24,r25
	movw r5:r4,r17:r16
	sub r5,r19
	sbc r4,r18
	DivideTenTimes r18,r19,r24,r25
	movw r17:r16,r19:r18
	tentimes r20,r21,r24,r25
	add r21,r5
	adc r20,r4
	cpi r16, 1
	brsh Forloop1
	movw r17:r16,r21:r20
	movw r19:r18, r17:r16
display:
	do_lcd_command 0b00000001 ; clear display
	do_lcd_command 0b00001110 ; Cursor on, bar, no blink

displayloop:
	DivideTenTimes r18,r19,r24,r25
	tentimes r18,r19,r24,r25	
	movw r5:r4,r17:r16
	sub r5,r19
	sbc r4,r18
	ldi r20,0x30
	add r4,r20
	do_lcd_data r4
	DivideTenTimes r18,r19,r24,r25
	movw r17:r16,r19:r18
	cpi r16, 1
	brsh displayloop
	
endfunction:
	pop r25
	pop r24
	pop r23
	pop r22
	pop r21
	pop r20
	pop r19
	pop r18
	pop r17
	pop r16

	pop YH
	pop YL
	pop XH
	pop XL
	ret