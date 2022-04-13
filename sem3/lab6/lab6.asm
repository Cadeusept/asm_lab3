use16
org 100h

mov ax,0x0
mov bx,0x0

;open file
push dx
push ax
push cx
mov cx,0
mov dx,filename
mov ah,3ch
int 21h
mov [1],ax
pop cx
pop ax
pop dx

push si
mov si,buf

call print_dump

pop bx

push ax
push cx
push dx
mov cx,2000
mov ah,40h
mov bx, [1]
mov dx, buf
int 21h
pop dx
pop cx
pop ax

push ax
mov ah,3eh
mov bx, [1]
int 21h
pop ax

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
	mov dl,0x20
	mov byte[si],dl
	lea si,[si+1]
	ret

print_endl:
	mov byte[si], 0xD
	lea si,[si+1]
	mov byte[si],0xA
	lea si,[si+1]
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
		lea si,[si+1]
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

filename db 'LMP.txt',0
buf db 2000 dup(?)
msg_spc db ' '
msg_endl db 0xD, 0xA