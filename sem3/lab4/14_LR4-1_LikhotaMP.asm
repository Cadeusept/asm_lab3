use16
org 100h

Start:
	jmp Init

Interruption:
	sti
	push ax
	push dx
	push ds
	mov ax,cs
	mov ds,ax

	call print_dump; адрес сегмента в di; адрес смещения в bx

	pop ds
	pop dx
	pop ax
	iret


;из программы лаб3-зад3
print_dump:
	pusha

	mov cx,16
	str_lp:
		push cx
		
		mov cx,16
		col_lp:
			mov al,byte[di+bx]
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


Init:
	mov ah,0x25
	mov al,0x8e
	mov dx,Interruption

	int 21h

	mov dx,Init
	int 27h