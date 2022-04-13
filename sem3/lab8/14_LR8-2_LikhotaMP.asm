use16
org 100h

call cycle
call cycle
call cycle
call cycle
call cycle
call cycle
call cycle
call cycle
call cycle
call cycle
call turn_off
;pop ax
;mov ds,ax
;mov word[ds:417h],ax

int 20h

cycle:
	call turn_on
	call Delay_1
	call turn_off
	call Delay_1
	ret


turn_on:
	pusha
	mov al, 0xED
	out 0x60,al
	mov al, 00000111b      ; Установим 3 младших бита
	out 0x60, al          
	popa
	ret


turn_off:
	pusha
	mov al, 0xED
	out 0x60,al
	mov al, 00000000b      ; Установим 3 младших бита
	out 0x60, al          
	popa
	ret



Delay_1:
	pusha
	mov ah,0
	int 0x1a
	mov si,1
	jmp sleep

	sleep:
		push dx
		mov ah,0
		int 0x1a
		pop bx
		cmp bx,dx
		jne cnt
		jmp sleep
	
	fin:
		popa
		ret

cnt:
	dec si
	cmp si,0
	je fin
	jmp sleep