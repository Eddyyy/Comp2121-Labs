; calculate the motor's speed per second and display it every 100ms

.include "m2560def.inc"

.def temp = r16
.def temp1 = r18 
.def temp2 = r19
.def counter = r17
.def lcd = r20	
.def digit = r21			; display decimal numbers
.def digitc = r22			; count the digits
.def show = r23				; the number on the screen

; The macro clears a word (2 bytes) in a memory
; the parameter @0 is the memory address for that word
.macro clear
    ldi YL, low(@0)     ; load the memory address to Y
    ldi YH, high(@0)
    clr temp 
    st Y+, temp         ; clear the two bytes at @0 in SRAM
    st Y, temp
.endmacro

.macro divide_by 
	mov temp, @0
	lsl temp
	lsr @0
	add @0, temp
	clr temp
.endmacro
			            
.dseg
TempCounter: .byte 2              ; Temporary counter. check if 100ms has passed
VoltageFlag: .byte 1
MSCounter: .byte 2				  ; Memory

; LCD macros
.macro do_lcd_command
	ldi lcd, @0
	rcall lcd_command
	rcall lcd_wait
.endmacro
.macro do_lcd_data
	ldi lcd, @0
	rcall lcd_data
	rcall lcd_wait
.endmacro
.macro do_lcd_rdata		; convert given number to decimal
	mov lcd, @0
	subi lcd, -'0'
	rcall lcd_data
	rcall lcd_wait
.endmacro
.macro do_lcd_digits	; convert given number to the show on the screen
	clr digit
	clr digitc
	mov temp, @0		
	rcall convert_digits
.endmacro

.cseg
.org 0x000
   jmp RESET
   jmp DEFAULT          ; No handling for IRQ0.
   jmp DEFAULT          ; No handling for IRQ1.
.org INT2addr			; INT2(TDX2) for external interrupt to count holes
    jmp EXT_INT2
.org OVF0addr
   jmp Timer0OVF        ; time0 to count time
   jmp DEFAULT          
DEFAULT:  reti         ; return from interrupt

RESET: 
    ldi temp, high(RAMEND) ; Initialize
    out SPH, temp
    ldi temp, low(RAMEND)
    out SPL, temp

	sei

	ser temp
	out DDRF, temp
	out DDRA, temp
	clr temp
	out PORTF, temp	; LCD DATA
	out PORTA, temp	; LCD CTRL

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

	rjmp main

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

EXT_INT2:
	in temp, SREG
	push temp
	push temp2

	inc counter		; incline how many times interrupt occurs

END_INT2:
	pop temp2
	pop temp
	out SREG, temp
	reti

Timer0OVF: 
    in temp, SREG
    push temp       ; Prologue
    push YH         ; Save all conflict registers in the prologue.
    push YL
    push r25
    push r24		
	push r27
	push r26		; Prologue ends	

	; load the value of the temp counter
	lds r24, TempCounter
    lds r25, TempCounter+1
    adiw r25:r24, 1 ; Increase the temporary counter by one.
	lds r26, MSCounter
    lds r27, MSCounter+1
    adiw r27:r26, 1

	cpi r24, low(781)
	ldi temp, high(781)
	cpc r25, temp
	brne NotSecond

	do_lcd_command 0b00000001 ; clear display
	do_lcd_command 0b00000110 ; increment, no display shift
	do_lcd_command 0b00001110 ; Cursor on, bar, no blink

	do_lcd_digits show
	clear MSCounter
	;inc r31
	;cpi r31, 10
	;brne ENDIF

	;divide 2.5 here
	divide_by counter
	mov show, counter
	clr counter
	clear TempCounter
	clear MSCounter
	clr r31
	rjmp ENDIF

NotSecond:
	sts MSCounter, r26
	sts MSCounter+1, r27
	sts TempCounter, r24
    sts TempCounter+1, r25 
	
EndIF:
	pop r26
	pop r27
	pop r24         ; Epilogue
    pop r25        
    pop YL
    pop YH
    pop temp
    out SREG, temp
    reti            ; Return from the interrupt.

main:
    clear TempCounter       ; Initialize the temporary counter to 0
	clear MSCounter
	clr show

	ldi temp, 0
	sts VoltageFlag, temp	; Initialize voltageflag

	ldi temp, (2 << ISC20)      ; set INT2 as falling-edge
    sts EICRA, temp             ; edge triggered interrupt
    in temp, EIMSK              ; enable INT2
    ori temp, (1<<INT2)
    out EIMSK, temp

    ldi temp, 0b00000000
    out TCCR0A, temp
    ldi temp, 0b00000010
    out TCCR0B, temp        ; Prescaling value=8, set 128 microseconds
    ldi temp, 1<<TOIE0      
    sts TIMSK0, temp        ; interrupt enable

    sei                     ; Enable global interrupt

loop: rjmp loop				; end

; function: displaying given number by digit in ASCII using stack
convert_digits:
	push digit

	checkHundreds:
		cpi temp, 100			
		brsh hundredsDigit		
		cpi digit, 0			
		brne pushHundredsDigit	
		
	checkTensInit:
		clr digit
	checkTens:
		ldi temp1, 10
		cp temp, temp1			
		brsh tensDigit			
		cpi digitc, 1		
		breq pushTensDigit		
								
		cpi digit, 0			
		brne pushTensDigit				 

	saveOnes:
		clr digit				
		mov digit, temp			
		push digit				
		inc digitc

	cpi digitc, 3
	breq dispThreeDigits
	cpi digitc, 2
	breq dispTwoDigits
	cpi digitc, 1
	breq dispOneDigit

	endDisplayDigits:

	pop digit
	ret

; hundreds digit
hundredsDigit:
	inc digit				
	subi temp, 100			
	rjmp checkHundreds		

; tens digit
tensDigit:
	inc digit				
	subi temp, 10			
	rjmp checkTens			

pushHundredsDigit:
	push digit
	inc digitc
	rjmp checkTensInit

pushTensDigit:
	push digit
	inc digitc
	rjmp saveOnes

dispThreeDigits:
	pop temp2
	pop temp1
	pop temp
	do_lcd_rdata temp
	do_lcd_rdata temp1
	do_lcd_rdata temp2
	rjmp endDisplayDigits

dispTwoDigits:
	pop temp2
	pop temp1
	do_lcd_rdata temp1
	do_lcd_rdata temp2
	rjmp endDisplayDigits

dispOneDigit:
	pop temp
	do_lcd_rdata temp
	rjmp endDisplayDigits

lcd_command:
	out PORTF, lcd
	rcall sleep_1ms
	lcd_set LCD_E
	rcall sleep_1ms
	lcd_clr LCD_E
	rcall sleep_1ms
	ret

lcd_data:
	out PORTF, lcd
	lcd_set LCD_RS
	rcall sleep_1ms
	lcd_set LCD_E
	rcall sleep_1ms
	lcd_clr LCD_E
	rcall sleep_1ms
	lcd_clr LCD_RS
	ret

lcd_wait:
	push lcd
	clr lcd
	out DDRF, lcd
	out PORTF, lcd
	lcd_set LCD_RW
lcd_wait_loop:
	rcall sleep_1ms
	lcd_set LCD_E
	rcall sleep_1ms
	in lcd, PINF
	lcd_clr LCD_E
	sbrc lcd, 7
	rjmp lcd_wait_loop
	lcd_clr LCD_RW
	ser lcd
	out DDRF, lcd
	pop lcd
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