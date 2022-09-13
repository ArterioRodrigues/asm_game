;;; 
;;; Space Invaders-ish game in 510 bytes or less!! of qemu bootable real mode x86 asm
;;;

;; NOTE: Assuming direction flag is clear, SP initialized to 6EF0h, BP = 0
bits 16
org 7C00h
;; DEFINE VARIABLE AFTER SCREEN MEMORY 320*200 = 64000 FA00h ========================
testfile equ 0FA00h
sprites 			equ	0FA00h
alien1				equ 0FA00h
alien2				equ 0FA04h
ship				equ 0FA08h
barrierarr 			equ 0FA0CH
alienArr 			equ 0FA20h	; 2 words - 32 bits
PlayerX 			equ 0FA24h
shotsArr			equ 0FA25h	; 4 xy shot values - 8 bits
alienY				equ 0FA2Eh
num_aliens			equ 0FA2Fh	; # of aliens alive
direction			equ 0FA30h	; # pixels that aliens move x direction
move_timer			equ 0FA31h	; 2 byte (using BP) # of ticks before a alien move
change_alien		equ 0FA33h	; Change alien sprite

;; CONSTANTS  =======================================================================
SCREEN_HEIGHT 		equ 200		; Screen height
SCREEN_WIDTH		equ 320		; Screen width
VIDEO_MEMORY		equ 0A000h
TIMER				equ 046ch 	; # of timer ticks since midnight
BARRIERX			equ 22
BARRIERY			equ 85
PLAYERY				equ 93
SPRITE_HEIGHT		equ 4		
SPRITE_WIDTH		equ 8		; Width in bits/data pixels
SPRITE_WIDTH_PX			equ 16		; Width in screen pixels

ALIEN_COLOR 		equ 02h		; Green
PLAYER_COLOR 		equ 07h		; Gray
BARRIER_COLOR 		equ 27h		; Red
PLAYER_SHOT_COLOR 	equ 0Bh		; Cyan
ALIEN_SHOT_COLOR 	equ 0Eh		; Yellow


;; SETUP ============================================================================
;; Set up video mode - VGA mode 13h, 320x200, 256 colors, 8bpp, linear framebuffer at address A0000h
mov ax, 0013h
int 10h

;; Set up video memroy
push VIDEO_MEMORY
pop es				; ES -> A0000h

;; Move initial sprite data into memroy
mov di, sprites
mov si, sprite_bitmaps
mov cl, 6
rep movsw

lodsd
mov cl, 5		; Store 5 barriers in memory for barrierArr
rep stosd

;; Set initial varibles
mov cl, 5		; Alien array & playerX
rep movsb

xor ax, ax
mov cl, 4		; Shots array - 8 bytes Y/X values
rep stosw

mov cl, 7		; AlienY/X, # of aliens, direction, move_time, change_alien
rep movsb

push es			; DS = ES
pop ds


;; GAME LOOP ========================================================================
game_loop:
	xor ax, ax	; Clear screen to block first
	xor di, di
	mov cx, SCREEN_WIDTH*SCREEN_HEIGHT
	rep stosb	; mov [E5:DI], al cx # of times
	
	;; TODO: Draw aliens .....................................

	mov si, alienArr
	mov bl, ALIEN_COLOR
	mov ax, [si+13]			;[alienY] == [si+offset]
	cmp byte [si+19], cl	;[change alien]
	mov cl, 4
	jg draw_next_alien_row		; Nope, use normal sprite
	add di, cx				; Yes use alternate sprite (cx = 4)
	
	draw_next_alien_row:
		pusha
		
		mov cl, 8			; # of aliens to check per row
		.check_next_alien:
			pusha
			dec cx
			bt [si], cx		; Bit test - copy bit to carry flag
			jnc .next_alien
			
			mov si, di 		; SI = alien sprite to draw
			call draw_sprite

			.next_alien:
				popa
				add ah, SPRITE_WIDTH + 4
		loop .check_next_alien
		
		popa
		add al, SPRITE_HEIGHT+2
		inc si	
	loop draw_next_alien_row


		;; Delay timer - 1 tick delay (1 tick = 18.2/second)
	delay_timer:
		mov ax, [CS:TIMER]
		inc ax
		.wait:
			cmp [CS:TIMER], ax
			jl .wait

	
jmp game_loop


;; END GAME & REST ==================================================================
game_over:
	cli
	hlt

;; Draw a sprite to the screen
;; Input parameters:
;; 	SI = address of sprite to draw
;;	AL = Y value of sprite
;; 	AH = X value of sprite
;; 	BL = color

draw_sprite:
	call get_screen_position	; Get X/Y postion in DI to draw at
	mov cl, SPRITE_HEIGHT

	.next_line:
		push cx
		lodsb					; AL = next byte of sprite data
		xchg ax, dx 			; save off sprite data
		mov cl, SPRITE_WIDTH	; # of pixels to draw in sprite
		.next_pixel:
			xor ax, ax			; If drawing blank/black pixel
			dec cx
			bt dx, cx			; Is bit in sprite set? Copy to carry
			cmovc ax, bx		; Yes bit is set, move BX into AX(BL = color)
			mov ah, al			; Copy color to fill out AX
			mov [di+SCREEN_WIDTH], ax
			stosw 					
		jnz .next_pixel
		
		add di, SCREEN_WIDTH*2-SPRITE_WIDTH_PX
		pop cx
		loop .next_line
	ret

;; Get X/Y screen position in 
;;	AL = Y value
;; 	AH = X value
;; Clobbers:
;;	DX
get_screen_position:
	mov dx, ax			; Save Y/X values
	cbw					; Convert byte to word - sign extend al into
	imul di, ax, SCREEN_WIDTH*2	; DI = Y value
	mov dl, dh			; AX = X value
	shl ax, 1 			; AX * 2
	add di, ax			; DI = Y value + x value or X/Y postion

	ret

;; CODE SEGMENT DATA ================================================================
sprite_bitmaps:
	db 10011001b	; Alien 1 bitmap
	db 01011010b
	db 00111100b
	db 01000010b

	db 00011000b	; Alien 2 bitmap
	db 01011010b
	db 10111101b
	db 00100100b

	db 00011000b	; Player ship bitmap
	db 00111100b
	db 00100100b
	db 01100110b

	db 00111100b	; Barrier bitmap
	db 01111110b
	db 11100111b
	db 11100111b
	
	;; Initial Variable values
	dw 0FFFFh		; Alien array
	dw 0FFFFh		
	db 70			; PlayerX

	;; times 6 db 0 ; Shots array
	dw 230Ah		; alienY & alienX | 10 = Y, 35 = X
	db 20h			; # of aliens = 32
	db 0FBh	
	dw 18			; Move timer
	db 1 			; Change alien - toggle between
;; Boot signature
times 510-($-$$) db 0
dw 0xAA55

