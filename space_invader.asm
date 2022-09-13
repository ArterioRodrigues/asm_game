;;; 
;;; Space Invaders-ish game in 510 bytes or less!! of qemu bootable real mode x86 asm
;;;
org 7C00h

;; SETUP ============================================================================
;; Set up video mode - VGA mode 13h, 320x200, 256 colors, 8bpp, linear framebuffer at address A0000h
mov ax, 0013h
int 10h

;; Set up video memroy
push 0A000h
pop es				; ES -> A0000h

;; GAME LOOP ========================================================================

	;; Delay timer - 1 tick delay (1 tick = 18.2/second)
	delay_timer:
		mov ax, [046ch]	; # of timer ticks since midnight
		inc ax
		.wait:
			cmp [046ch], ax
			jl .wait
jmp game_loop


;; END GAME & REST ==================================================================
cli
hlt

times 510-($-$$) db 0
;;section boot_signature start=7DFEh

;; Boot signature
dw 0xAA55

