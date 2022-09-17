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
PLAYERBALLSTARTX equ 66
CPUBALLSTARTX 	equ 90
WINCOND		equ 3
BALLSTARTY 	equ 7
;; VARIABLES ======================================================
drawColor: 	db 0xF0
playerY:	dw 10 	; Start a row 10
cpuY: 		dw 10

ballX: 		dw 66
ballY: 		dw 12
ballVelY: 	db -1
ballVelX: 	db -1
playerScore: 	db 0
cpuScore: 	db 0


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

		;; Draw Ball ------------------------------------------------
		imul di, [ballY], ROW_LENGTH
		add di, [ballX]
		mov word [es:di], 0x2000

		;; Draw Scores
		xor bl, bl
		mov di, ROW_LENGTH + 66
		mov bl, 0x30
		add bl, [playerScore]
		mov bh, 0x0C

		mov word [es:di], bx

		add di, 24
		mov bl, 0x30
		add bl, [cpuScore]
		mov word [es:di], bx
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
				jl .move_cpu_down
				
				dec word [cpuY]
				jge move_ball
				inc word [cpuY]
				jmp move_ball

			.move_cpu_down:
				add bx, PADDLEH
				cmp bx, [ballY]
				jg move_ball
				inc word [cpuY]
				cmp word [cpuY], 25

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
				jmp .check_hit_left
			
			.check_hit_bottom:
				cmp word[ballY], 24
				jl .check_player_hit
				neg byte [ballVelY]
				jmp .check_hit_left
				
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
				jmp .check_hit_left

			
			.check_cpu_hit:
				cmp word [ballX], CPUX
				jne .check_hit_left

				mov bx, [cpuY]
				cmp bx, [ballY]

				jg .check_hit_left

				add bx, PADDLEH
				cmp bx, [ballY]

				jl .check_hit_left
				neg byte [ballVelX]
			

			.check_hit_left:
				cmp word [ballX], 0
				jg .check_hit_right
				inc byte [cpuScore]
				cmp byte [cpuScore], WINCOND
				je game_over
				mov word [ballX], PLAYERBALLSTARTX
				jmp rest_ball

			.check_hit_right:
				cmp word [ballX], ROW_LENGTH
				jl end_collison_check
				inc byte [playerScore]
				cmp byte [playerScore], WINCOND
				je game_over
				mov word [ballX], CPUBALLSTARTX
		rest_ball:			
			mov word [ballY], BALLSTARTY

		end_collison_check:

		imul di, [ballY], ROW_LENGTH
		add di, [ballX]
		mov word [es:di], 0x2000
	
		;;Delay timer based on Clock --------------------------------
		mov bx, [0x46C]
		inc bx
		inc bx
		.delay:
			cmp [0x46C], bx
			jl .delay			;if [0x46C] < bx jump to delay until they are equ(delay 2 tics)
		
	jmp game_loop
game_over:
	cmp byte [playerScore], WINCOND
	je game_won 
	jnp game_lost 

game_won:
	mov dword [es:0000], 0F450F57h
	mov dword [es:0004], 0F210F4Eh
game_lost:
	mov dword [es:0000], 0F4F0F4Ch
	mov dword [es:0004], 0F450F53h
	hlt


times 510-($-$$) db 0
dw 0xAA55

