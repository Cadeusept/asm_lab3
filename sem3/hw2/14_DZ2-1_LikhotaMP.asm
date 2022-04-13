use16
org 100h

init:
	call set_mode

	mov ax,0x3513
	int 21h
	mov [orig_0x15],bx
	mov [orig_0x15 +2],es

	mov ax,0x2515
	mov dx, own_int0x15
	int 21h



own_int0x15:
	pushf
	pusha
	sti
	push cs
	pop ds
	push cs
	pop es

	in al,0x60
	mov cx,buf_size
	mov si,btn_buf
	lp:
		cmp [si],al
		je beep
		inc si
	loop lp

	int_fin:
		popa
		popf

		iret

ret_int0x15:
	mov ax,0x2515
	mov dx, orig_0x15
	int 21h

final:
	int 20h

beep:
	call play_A1
	call turn_on
	
	call Delay_3
	
	call turn_off
	jmp int_fin

play_A1:
	pusha
	mov ax, (1190000/440) 
	out 0x42, al          
	mov al, ah            
	out 0x42, al          
	popa
	ret

turn_on:
	pusha
	in al, 0x61
	or al, 00000011b      ; Установим 2 младших бита
	out 0x61, al          ; Включим динамик
	popa
	ret


turn_off:
	pusha
	in al, 0x61           ; Сбрасываем 2 младших бита
	and al, 11111100b
	out 0x61, al          ; Выключим динамик
	popa
	ret

Delay_3:
	pusha
	mov ah,0
	int 0x1a
	mov si,3
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

set_mode:
	pusha
	mov al, 0xb6
	out 0x43, al          ; Задаем режим работы контроллера
	popa
	ret

orig_0x15: dw 0,0
btn_buf: db 0x1E,0x30,0x2E,0x20,0x12,0x21,0x22,0x23,0x17,0x24,0x25,0x26,0x32,0x31,0x18,0x19,0x10,0x13,0x1F,0x14,0x16,0x2F,0x11,0x2D,0x15,0x2C,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x29,0x0C,0x0D,0x2B,0x1A,0x1B,0x27,0x28,0x33,0x34,0x35,0x39
buf_size = $ - btn_buf