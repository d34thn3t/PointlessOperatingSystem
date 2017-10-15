AS&nbsp; := nasm
LD&nbsp; := ld
 
all: boot.bin 2ndstage.bin
 
boot.bin: boot.out
	objcopy -O binary -j .text boot.out boot.bin
 
boot.out: boot.o
	$(LD) -o boot.out boot.o -Ttext 0x7c00
 
boot.o: loader.asm bootsector.asm functions.asm macros.asm
	$(AS) -o boot.o loader.asm -f bin
 
2ndstage.bin: 2ndstage.out
	objcopy -O binary -j .text 2ndstage.out 2ndstage.bin
 
2ndstage.out: 2ndstage.o
	$(LD) -o 2ndstage.out 2ndstage.o -Ttext 0x0
 
2ndstage.o: 2ndstage.s bootsector.asm functions.asm macros.asm
	$(AS) -o 2ndstage.o 2ndstage.asm -f bin
 
clean:
	rm *.o
	rm *.out
	rm *.bin
