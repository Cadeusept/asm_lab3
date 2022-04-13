use16
org 100h

mov ax,0x0
mov ebx,0x0


call print_map

mov ax,0x0
int 16h
int 20h

print_map:
	pusha

	prnt_device_map:
	call read_device_map
	mov si,outpt_buf
	add si,7
	call print_buf

	cmp ebx,0
	jne prnt_device_map

	popa
	ret
	

read_device_map:

	mov ax,0xe820
	mov ecx,outpt_buf_size
	mov edx,0x534d4150
	mov di,outpt_buf
	int 15h

	ret

print_buf:
	pusha
	

	mov cx,20
	col_lp:
		mov al,byte[si]
		call print_al
		dec si

		cmp cx,13
		je prep_size
		cmp cx,5
		je prep_type

		loop col_lp

	call print_endl

	popa
	ret

prep_size:
	call print_spc

	add si,16

	loop col_lp
	
prep_type:
	call print_spc

	add si,12

	loop col_lp

print_spc:
	push ax
	push dx
	mov ah,02h
	mov dx,0x20
	int 21h
	pop dx
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

outpt_buf_size=20
outpt_buf db outpt_buf_size dup(?)