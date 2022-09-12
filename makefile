.PHONY: all

all: 
	nasm -f bin space_invader.asm -o invader.bin
run:
	qemu-system-i386 -drive format=raw, file=invader.bin
	
