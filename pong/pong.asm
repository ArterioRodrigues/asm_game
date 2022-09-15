;;;
;;; Pong game test for me 
;;;

bits 16
org 0x7C00
	
mov ax, 0x0003		; Setup text mode for x86 
int 0x10
	
mov ax, 0xB800		; Video offset
mov es, ax 			; DI <- 0xB800
 	

game_loop:
		
	;; Clear the screen by earsing di values 
	xor ax, ax
	xor di, di
	mov cx, 80*25
	rep stosw
		
	;; Middle dash 
	mov al, 0xF0
	mov di, 79
	mov cl, 13 			; Counter for loop tell it to go 13 times
	.draw_middle_loop:
		stosw
		add di, 320 - 2
		loop .draw_middle_loop	
		
	;;Delay timer based on the clock ticker
	mov bx, [0x46C]
	inc bx
	inc bx
	.delay:
		cmp [0x46C], bx
		jl .delay			;if [0x46C] < bx jump to delay until they are equ(delay 2 tics)

jmp game_loop

times 510-($-$$) db 0
dw 0xAA55
