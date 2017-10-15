bits 16
section .text
global startup
org 0x0

startup:

	mov ax,0x7c0
	add ax,288
	mov ss,ax
	mov sp,4096
	mov ax,0x7c0
	mov ds,ax
	mov si,welcomemessage
	call print
	call securityalgorithm
	call suspend

print:

	xor ah,ah
	lodsb
	and al,al
	jz .endprint
	mov ah,0xe
	int 0x10
	jmp print

	.endprint:

		ret

waitforuser:

	mov si,pressanykey
	call print
	mov ah,0
	int 0x16
	mov si,done
	call print
	mov si,newline
	call print
	ret

suspend:

	nop
	jmp suspend

getkey:

	mov ah,0
	int 0x16
	ret

securityalgorithm:

	mov si,askpw
	call print
	call getkey
	mov ah,0xe
	int 0x10
	mov bl,al
	mov si,newline
	call print
	cmp bl,55
	je .success
	jne .failure

	.success:

		mov si,success
		call print
		ret

	.failure:

		mov si,failure
		call print
		ret

pressanykey:	db "PRESS ANY KEY TO CONTINUE...",10,13,0
welcomemessage:	db "WELCOME TO THE POINTLESS OPERATING SYSTEM!",10,13,0
done:		db "DONE!"
askpw:		db "ENTER THE MAGIC NUMBER:",0
success:	db "SUCCESS!",10,13,0
failure:	db "FAILURE!",10,13,0
newline:	db " ",10,13,0

times 510-($-$$) db 0

dw 0xaa55
