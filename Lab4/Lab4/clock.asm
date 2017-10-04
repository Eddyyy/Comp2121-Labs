; Board settings: 1. Connect LCD data pins D0-D7 to PORTF0-7.
; 2. Connect the four LCD control pins BE-RS to PORTA4-7.
  
.include "m2560def.inc"

.def temp = r16
.def second = r17
.def mint = r19
.def second2 = r18
.def mint2 = r20

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
.macro update_lcd
	do_lcd_command 0b00000001 ;clear
	do_lcd_command 0b00000110 ; increment, no display shift
	do_lcd_command 0b00001110 ; Cursor on, bar, no blink
	do_lcd_data @3
	do_lcd_data @2
	ldi r21, ':'
	do_lcd_data r21
	do_lcd_data @1
	do_lcd_data @0
.endmacro
.macro clear
	ldi YL, low(@0)
	ldi YH, high(@0)
	clr temp
	st Y+, temp
	st Y, temp
.endmacro

.dseg
	SecondCounter: .byte 4
	TempCounter: .byte 2
.cseg
.org 0
	jmp RESET
	jmp DEFAULT
	jmp DEFAULT
	.org OVF0addr
	jmp Timer0OVF
	jmp DEFAULT
DEFAULT: reti

RESET:
	ldi r16, low(RAMEND)
	out SPL, r16
	ldi r16, high(RAMEND)
	out SPH, r16

	ser r16
	out DDRF, r16
	out DDRA, r16
	clr r16
	out PORTF, r16
	out PORTA, r16

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

	ldi second, '0'
	ldi second2, '0'
	ldi mint, '0'
	ldi mint2, '0'
	update_lcd second, second2, mint, mint2


	rjmp main

Timer0OVF:
 in temp, SREG

 push temp ; prologue starts

 push YH ; save all conflicting registers in the prologue

 push YL

 push r25

 push r24 ; prologue ends

 ; Load the value of the temporary counter

 lds r24, TempCounter

 lds r25, TempCounter+1

 adiw r25:r24, 1 ; increase the temporary counter by one

 cpi r24, low(7812) ; check if (r25:r24) = 7812

 ldi temp, high(7812) ; 7812 = 106/128

 cpc r25, temp

 brne NotSecond
 

;======count second, the first part===== if (second > '9')
inc1:
inc second
cpi second, ':'  ;number after '9' when second = 10, mint= 59 second, then jump to inc2 which counts minute
breq inc2
rjmp update

;======count second, the second part====== if (second2 > '6')
inc2:
ldi second, '0'
inc second2
cpi second2, '6'
breq inc3
rjmp update

;======count minute, the first part===== if (second > '9')
inc3:
ldi second2, '0'
inc mint
cpi mint, ':'  ;number after '9' when second = 10, mint= 59 second, then jump to inc2 which counts minute
breq inc4
rjmp update

;======count minute, the second part====== if (second2 > '6')
inc4:
ldi mint, '0'
inc mint2
cpi mint2, '6'
breq empty
rjmp update

empty:
ldi second, '0'
ldi second2, '0'
ldi mint, '0'
ldi mint2, '0'
rjmp update

;=======update lcd======
update:
update_lcd second, second2, mint, mint2


;======== counting second loop ========

endinc:
 clear TempCounter ; reset the temporary counter
 ; Load the value of the second counter
 ;lds r24, SecondCounter
 ;lds r25, SecondCounter+1
 ;adiw r25:r24, 1 ; increase the second counter by one
 ;sts SecondCounter, r24
 ;sts SecondCounter+1, r25
 rjmp EndIF

NotSecond: ; store the new value of the temporary counter
 sts TempCounter, r24
 sts TempCounter+1, r25

EndIF:
 pop r24 ; epilogue starts
 pop r25 ; restore all conflicting registers from the stack
 pop YL
 pop YH
 pop temp
 out SREG, temp
 reti ; return from the interrupt
;======== counting second loop ========

main:

halt:
	rjmp halt


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