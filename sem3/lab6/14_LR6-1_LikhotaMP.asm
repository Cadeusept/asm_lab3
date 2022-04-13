use16
org 100h

mov ax,0x0
mov bx,0x0

call open_file

mov si,buf
call buf_dump

call print_buf

call close_file

mov ax,0x0
int 16h
int 20h

open_file:
	push dx
	push ax
	push cx

	mov cx,0
	mov dx,filename
	mov ah,3ch
	int 21h
	mov [file_dscr],ax
	
	pop cx
	pop ax
	pop dx
	ret

buf_dump:
	pusha

	mov cx,16
	str_lp:
		push cx
		
		mov cx,16
		col_lp:

			push ax
			pop es

			mov ax, 0x0
			mov al,byte[es:bx]
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
	mov byte[si],0x20
	inc si
	ret

print_endl:
	mov byte[si],0xD
	inc si
	mov byte[si],0xA
	inc si
	ret

print_al:
	push dx
	push cx
	push ax

	mov dx,0x0
	mov cx,2

	main:
		cmp cx,1
		ja first_letter
		cmp cx,0
		jnz second_letter

		pop ax
		pop cx 
		pop dx
		ret

	print_ascii:
		dec cx
		mov byte[si],dl
		inc si
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


print_buf:
	push ax
	push cx
	push dx

	mov cx,buf_size
	mov ah,40h
	mov bx,[file_dscr]
	mov dx,buf
	int 21h
	
	pop dx
	pop cx
	pop ax
	ret


close_file:
	push ax
	push bx	
	
	mov ah,3eh
	mov bx,[file_dscr]
	int 21h
	
	pop bx
	pop ax
	ret


filename db 'LihotaMP.txt',0
file_dscr rw 1
buf_size=800
buf db buf_size dup(?)