;;;
;;; Pong game test for me 
;;;

bits 16
org 0x7C00

jmp gameplay

;; CONSTANSTS =====================================================
VIDMEN 		equ 0xB800
ROW_LENGTH 	equ 160
PLAYERX		equ 4
CPUX		equ 154	
KEY_W		equ 0x11
KEY_S		equ 0x1F
KEY_C		equ 0x2E
KEY_R		equ 0x13
SCREENW		equ 80
SCREENH		equ 24
PADDLEH		equ 5

;; VARIABLES ======================================================
drawColor: 	db 0xF0
playerY:	dw 10 	; Start a row 10
cpuY: 		dw 10

ballX: 		dw 66
ballY: 		dw 12
ballVelY: 	db -1
ballVelX: 	db -1



gameplay:
	;; GAMEPLAY ===================================================
	mov ax, 0x0003		; Setup text mode for x86 
	int 0x10
	
	mov ax, VIDMEN		; Video offset
	mov es, ax 			; DI <- 0xB800
 	

	game_loop:
		
		;; Clear the screen by earsing di values -------------------
		xor ax, ax
		xor di, di
		mov cx, 80*25
		rep stosw
		
		;; Middle dash ---------------------------------------------
		mov ah, [drawColor]

		mov di, 78
		mov cl, 13 			; Counter for loop tell it to go 13 times
		.draw_middle_loop:
			stosw
			add di, 2*ROW_LENGTH - 2
			loop .draw_middle_loop	
		
		;; Draw player/CPU ------------------------------------------
		imul di, [playerY], ROW_LENGTH
		add di, PLAYERX

		imul bx, [cpuY], ROW_LENGTH
		add bx, CPUX
		
		mov cl, PADDLEH

		.draw_player_loop:
			stosw
			mov word [es:bx], ax 

			add bx, ROW_LENGTH 
			add di, ROW_LENGTH - 2
			loop .draw_player_loop

	
		call draw_ball

		;; Get Player Input -----------------------------------------
		mov ah, 1
		int 0x16
		jz move_cpu

		cbw 
		int 0x16

		cmp ah, KEY_W
		je  w_pressed
		cmp ah, KEY_S
		je  s_pressed
		cmp ah, KEY_C
		je  c_pressed
		cmp ah, KEY_R
		je  r_pressed
		
		jmp move_cpu

		;; PRESSED KEYS COMMANDS ------------------------------------
		w_pressed:
			dec word [playerY]
			jge move_cpu
			inc word [playerY]
			jmp move_cpu
			
		s_pressed:				
			cmp word [playerY], SCREENH - PADDLEH
			jg move_cpu
			inc word [playerY]	
			jmp move_cpu

		c_pressed:
			add word [drawColor], 0x10
			jmp move_cpu
		r_pressed:
			int 0x19					; Reloads bootsector
		

		;; Move Cpu --------------------------------------------------
		move_cpu:
			.move_cpu_up:
				mov bx, [cpuY]
				cmp bx, [ballY]
				jle .move_cpu_down
				
				dec word [cpuY]
				jnz move_ball
				inc word [cpuY]

			.move_cpu_down:
				add bx, PADDLEH
				cmp bx, [ballY]
				jg move_ball
				inc word [cpuY]
				cmp word [cpuY], 24

				jl move_ball
				dec word [cpuY]

		;; Move Ball ------------------------------------------------
		move_ball:	
			mov bl, [ballVelX]
			add [ballX], bl
			mov bl, [ballVelY]
			add [ballY], bl

			.chech_hit_top:
				cmp word [ballY], 0
				jg .check_hit_bottom
				neg byte [ballVelY]
				jmp end_collison_check
			
			.check_hit_bottom:
				cmp word[ballY], 24
				jl .check_player_hit
				neg byte [ballVelY]
				jmp end_collison_check
				
			.check_player_hit:
				cmp word [ballX], PLAYERX
				jne .check_cpu_hit

				mov bx, [playerY]
				cmp bx, [ballY]

				jg .check_cpu_hit

				add bx, PADDLEH
				cmp bx, [ballY]

				jl .check_cpu_hit

				neg byte [ballVelX]
				jmp end_collison_check

			
			.check_cpu_hit:
				cmp word [ballX], CPUX
				jne end_collison_check

				mov bx, [cpuY]
				cmp bx, [ballY]

				jg end_collison_check

				add bx, PADDLEH
				cmp bx, [ballY]

				jl end_collison_check

				neg byte [ballVelX]
				jmp end_collison_check


		end_collison_check:
		
		
		call draw_ball
		;;Delay timer based on Clock --------------------------------
		mov bx, [0x46C]
		inc bx
		inc bx
		.delay:
			cmp [0x46C], bx
			jl .delay			;if [0x46C] < bx jump to delay until they are equ(delay 2 tics)
		
	jmp game_loop
draw_ball:
		imul di, [ballY], ROW_LENGTH
		add di, [ballX]
		mov word [es:di], 0x2000
		ret

times 510-($-$$) db 0
dw 0xAA55

