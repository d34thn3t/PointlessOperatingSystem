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
	
	cli
	mov [LogicalDriveNum], dl
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov si,LoadingMessage
	call PrintStr
	mov dl,LogicalDriveNum
	xor ax,ax
	int 0x13
	jc BootFailure
	call SystemReboot

BootFailure:

	mov si,DiskError
	call PrintStr
	call SystemReboot

LoadingMessage:	db "Starting The Pointless Operating System...",10,13,0
DiskError:	db "Disk Failure!",10,13,0
RebootPrompt:	db "Press Any Key to Reboot..",10,13,0

times 510-($-$$) db 0

dw 0xaa55
