use16
org 100h

mov ax,0x0
mov bx,0x8c

call print_dump

mov ax,0x0
int 16h
int 20h

print_dump:
	pusha

	mov cx,16
	str_lp:
		push cx
		
		mov cx,16
		col_lp:
			mov al,byte[0x0+bx]
			call print_al
			inc bx
			call print_spc

			loop col_lp
		
		call print_endl
		
		pop cx
		loop str_lp

	popa
	ret


print_spc:
	push ax
	mov ah,02h
	mov dx,0x20
	int 21h
	pop ax
	ret

print_endl:
	push ax
	push dx
	mov ah,02h
	mov dx,0xd
	int 21h
	mov dx,0xa
	int 21h
	pop dx
	pop ax

	ret

print_al:
	pusha

	mov dx,0x0
	mov cx,2

	main:
		cmp cx,1
		ja first_letter
		cmp cx,0
		jnz second_letter

		popa
		ret

	print_ascii:
		push ax
		mov ah,02h
		int 21h
		pop ax
		dec cx
		jmp main
	
	first_letter:
		mov dx,ax
		and dl,0xf0
		shr dl,4
		cmp dl,0x9
		ja word_symbol
		jmp digit_symbol

	second_letter:
		mov dx,ax
		and dl,0x0f
		cmp dl,0x9
		ja word_symbol
		jmp digit_symbol

	digit_symbol:
		add dl,0x30
		jmp print_ascii

	word_symbol:
		add dl,0x37
		jmp print_ascii

msg_spc db ' '
msg_endl db 0xD, 0xA