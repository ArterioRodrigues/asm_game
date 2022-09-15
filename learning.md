# Learning assemble

1. bits 16 - lets the assembler know that we are using a 16 bit format and all the corresponding registers including {
    AX, BX, CX, DX
    These general purpose registers can also be addressed as 8-bit registers. So AX = AH (high 8-bit) and AL (low 8-bit).
    SI, DI
    These registers are usually used as offsets into data space. By default, SI is offset from the DS data segment, DI is offset from the ES extra segment, but either or both of these can be overridden.
    SP
    This is the stack pointer, offset usually from the stack segment SS. Data is pushed onto the stack for temporary storage, and popped off the stack when it is needed again.
    BP
    The stack frame, usually treated as an offset from the stack segment SS. Parameters for subroutines are commonly pushed onto the stack when the subroutine is called, and BP is set to the value of SP when a subroutine starts. BP can then be used to find the parameters on the stack, no matter how much the stack is used in the meanwhile.
    CS, DS, SS, ES
    The segment pointers. These are the offset in memory of the current code segment, data segment, stack segment and extra segment respectively.
    IP
    The instruction pointer. Offset from the code segment CS, this points at the instruction currently being executed.
    FLAGS (F)
    A number of single-bit flags that indicate (or sometimes set) the current status of the processor.
}

2. org 7c00h - this tells the assembler to start the binary code at memory location 0x7c00h which will offset the code to that point and all of the labels will also use 0x7c00h as    
    reference for address

3. varible equ value - equ assign a value to varible and the varible is stored as an offset of the org

sprites             equ 0FA00h
alien1              equ 0FA00h  
alien2              equ 0FA04h
ship                equ 0FA08h
barrierarr          equ 0FA0CH
alienArr            equ 0FA20h  ; 2 words - 32 bits
PlayerX             equ 0FA24h
shotsArr            equ 0FA25h  ; 4 xy shot values - 8 bits
alienY              equ 0FA2Eh
num_aliens          equ 0FA2Fh  ; # of aliens alive
direction           equ 0FA30h  ; # pixels that aliens move x direction
move_timer          equ 0FA31h  ; 2 byte (using BP) # of ticks before a alien     move
change_alien        equ 0FA33h  ; Change alien sprite


4. To enter mode 13h just use the screen interupt

     mov ax,0013h 
     int 10h

To exit mode 13h simply return the screen to textmode

     mov ax,0003h 
     int 10h

To put a pixel on the screen simply you write something to the screen memory. 
Here's a fast way to put a pixel at x,y

    mov ax,0a000h 
    mov es,ax 
    mov ax,y 
    mov bx,y 
    shl ax,8 
    shl bx,6 
    add ax,bx 
    add ax,x 
    mov di,ax 
    mov al,color 
    mov es:[di],al

4. movsw, movsb, movsd, movsq are instructions used to copy data from the source location DS:(ER)SI to destination location ES:(ER)DI.

They are useful because there is no mem-to-mem move instruction in IA32e.

They are meant to be used in cycles (for example by using the rep prefix), so besides moving the data they also increments (if DF flag, Direction Flag, is 0) or decrements (if DF flag is 1) the pointers to the source and destination locations, i.e. the (ER)SI and (ER)DI registers.

From the assembly programmer perspective the memory is byte-addressable, it means that each address store one byte.

movsb moves a byte, so the register are incremented/decremented by 1.
movsw moves a WORD (2 bytes), so the register are incremented/decremented by 2.
movsd moves a DWORD (Double Word, 2 Word, 4 bytes), so the register are incremented/decremented by 4.
movsq moves a QWORD (Quad Word, 4 words, 8 bytes), so the register are incremented/decremented by 8.