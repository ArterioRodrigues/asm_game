.PHONY: all

all: 
	nasm -f bin space_invader.asm -o invader.bin
run:
	qemu-system-x86_64 -drive format=raw,file=invader.bin
	#qemu-system-i386 -drive format=raw, file=invader.bin, if=virtio	
	#qemu-system-x86_64 -drive file=invader.bin, format=raw, if=virtio
	#qemu-system-i386 -drive file=invader.bin,format=raw,if=virtio
