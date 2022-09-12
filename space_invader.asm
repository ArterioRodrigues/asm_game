;;; 
;;; Space Invaders-ish game in 510 bytes or less!! of qemu bootable real mode x86 asm
;;;
org 7C00h

cli
hlt

times 510-($-$$) db 0

;; section boot_signature start=7DFEh
;; Boot signature
dw 0xAA55

