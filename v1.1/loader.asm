%define LoadSegment 0x1000
bits 16
section .text
global main
org 0x0

main:

	jmp Start
	nop

BootSector:

	OEM:			dq "P_OS    "
	BytesPerSector:		dw 512
	SectorsPerCluster:	db 1
	ReservedSectors:	dw 1
	FatTables:		db 2
	RootDirectories:	dw 2
	TotalSectors:		dw 2880
	MediaDescriptor:	db 0xf0
	SectorsPerFAT:		dw 9
	TrackSectors:		dw 9
	Heads:			dw 9
	HiddenSectors:		dw 0
	HighWordHidden:		dw 0
	LogicalDriveNum:	db 0
	Reserved:		db 0
	ExtendedSign:		db 0x29
	SerialNumber:		dd "v1.1"
	VolumeLabel:		dt "MYVOLUME"
	FileSystem:		dq "FAT16"

SystemReboot:

	mov si,RebootPrompt
	call PrintStr
	xor ah,ah
	int 0x16
	db 0xea
	dw 0x0000
	dw 0xffff

GetInputString:

	pusha
	mov bp,sp
	mov di,[bp+18]

	.Input:

		xor ah,ah
		int 0x16
		inc byte [StringLength]
		cmp al,0xd
		je .Done
		mov ah,0xe
		int 0x10
		stosb
		jmp .Input
		

	.Done:

		mov [InputString],di
		xor al,al
		mov esi,StringLength
		mov [esi+InputString],al
		mov ah,0xe
		mov al,0xd
		int 0x10
		mov al,0xa
		int 0x10
		mov sp,bp
		popa
		ret

Login:
	
	.Prompt:
	
		mov si,LoginPrompt
		call PrintStr
		call GetInputString
		cmp word [InputString],Password
		je .Success
		jne .Failure

	.Success:

		mov si,SuccessLogin
		call PrintStr
		call NopLoop

	.Failure:

		mov si,LoginFailure
		call PrintStr
		jmp .Prompt

NopLoop:

	nop
	jmp NopLoop
		
PrintStr:
	
	lodsb
	or al,al
	jz .EndPrint
	mov ah,0xe
	mov bx,9
	int 0x10
	jmp PrintStr
	
	.EndPrint:

		ret

Start:	
	
	mov [LogicalDriveNum], dl
	mov ax,0x7c0
	add ax,288
	mov ss,ax
	mov sp,4096
	mov ax,0x7c0
	mov ds,ax
	mov si,LoadingMessage
	call PrintStr
	mov dl,LogicalDriveNum
	xor ax,ax
	int 0x13
	push InputString
	call Login

BootFailure:

	mov si,DiskError
	call PrintStr
	call SystemReboot

LoadingMessage:	db "Starting P_OS...",10,13,0
DiskError:	db "Disk Failure!",10,13,0
RebootPrompt:	db "Press Any Key to Reboot..",10,13,0
BufferCount:	db 0
Buffer:		db 0
StringLength:	db 0
InputString:	dw 0
LoginPrompt:	db "Enter Password:",10,13,0
LoginFailure:	db "Wrong Password!",10,13,0
SuccessLogin:	db "Welcome!",10,13,0
Password:	dw "password"

times 510-($-$$) db 0

dw 0xaa55
