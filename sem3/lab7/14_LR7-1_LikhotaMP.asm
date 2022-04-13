use16
org 100h

mov ax,0x0
mov bx,0x0

call open_file

call buf_mbr

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

buf_mbr:
	pusha

	mov ah,02h
	mov al,1 ;количество читаемых секторов
	mov dl,80h  ;дисковод (жёсткий диск)
	mov dh,0 ;головка
	mov ch,0 ;цилиндр
	mov cl,1 ;начальный сектор
	mov bx,inpt_buf
	int 13h

	call move_to_outpt

	popa
	ret

move_to_outpt:
	mov bx,inpt_buf
	mov si,outpt_buf
	pusha

		mov cx,32
		str_lp:
			push cx
		
			mov cx,16
			col_lp:

				mov al,byte[bx]
				call buf_al
				inc bx
				call print_spc

				loop col_lp
		
			call print_endl
		
			pop cx
			loop str_lp
	
	popa
	ret

buf_al:
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
		mov dl,[bx]
		and dl,0xf0
		shr dl,4
		cmp dl,0x9
		ja word_symbol
		jmp digit_symbol

	second_letter:
		mov dl,[bx]
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

print_buf:
	push ax
	push cx
	push dx

	mov cx,outpt_buf_size
	mov ah,40h
	mov bx,[file_dscr]
	mov dx,outpt_buf
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
inpt_buf_size=512
outpt_buf_size=1598 ;1024 ascii + 512 пробелов + 31 перевод строки
inpt_buf db inpt_buf_size dup(?)
outpt_buf db outpt_buf_size dup(?)