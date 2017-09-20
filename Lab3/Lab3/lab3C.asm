.include "m2560def.inc" 
.def second =r16 
.def count=r17
.def num=r18
.def fin=r19
.def mint=r20
.def temp=r21
.def tmp=r22
.cseg 
.org 0x0 

ser tmp
ldi mint, 0
ldi second,0
out DDRC, tmp	; Write ones to all the LEDs 
nop
out PORTC, mint                
             ; PORTC is all outputs 
ldi temp, 4

ldi num, 0
ldi fin, 0
ldi count,0

loop: 
loop2:
inc num
cpi num, 255
brne loop4	
rjmp inc1 

loop4:
inc count
cpi count, 255
brne loop6
clr count
rjmp loop2

loop6:
inc fin
cpi fin, 58
brne loop6
clr fin
rjmp loop4  

inc1:
cpi second,60  ; when second = 60, mint= 59 second, then jump to inc2 which counts minute
breq inc2
inc second
mov mint, second  ;when second = 59, mint = 59
out PORTC, mint
rjmp loop
inc2: 
add second, temp  ; mint =0b1000000=64; 2mint = 128; 4min = 256 = 00000000
mov mint, second
out PORTC, mint
rjmp loop