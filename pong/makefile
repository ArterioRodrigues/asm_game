.PHONY: all

all: 
	nasm -f bin pong.asm -o pong.bin
run:
	qemu-system-x86_64 -drive format=raw,file=pong.bin
	#qemu-system-i386 -drive format=raw,file=invader.bin	
	#qemu-system-x86_64 -drive file=invader.bin, format=raw, if=virtio
	#qemu-system-i386 -drive file=invader.bin,format=raw,if=virtio
