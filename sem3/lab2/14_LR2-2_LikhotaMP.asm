use16
org 100h

start:
	mov ah,09h
	mov dx,ax_msg
	int 21h
	mov dx,0x0
	mov di,0x0
	
	mov ax,0x0
	mov bx,0x0

	mov cx,4
main:
	cmp cx,3
	ja first_letter
	cmp cx,2
	ja second_letter
	cmp cx,1
	ja third_letter
	cmp cx,0
	jnz fourth_letter

	cmp di,0xffff
	jnz prepare_bx
	mov ax,0
	int 16h
	int 20h

print_ascii:
	mov si,ax
	mov ah,02h
	int 21h
	mov ax,si
	sub cx,1
	jmp main
	

digit_symbol:
	add dl,0x30
	jmp print_ascii

word_symbol:
	add dl,0x37
	jmp print_ascii


first_letter:
	mov dx,ax
	and dx,0xf000
	or dl,dh
	mov dh,0
	shr dl,4
	cmp dl,0x09
	ja word_symbol
	jmp digit_symbol

second_letter:
	mov dx,ax
	and dx,0x0f00
	or dl,dh
	mov dh,0
	cmp dl,0x9
	ja word_symbol
	jmp digit_symbol

third_letter:
	mov dx,ax
	and dx,0x00f0
	shr dl,4
	cmp dl,0x9
	ja word_symbol
	jmp digit_symbol

fourth_letter:
	mov dx,ax
	and dx,0x000f
	cmp dl,0x9
	ja word_symbol
	jmp digit_symbol

prepare_bx:
	mov ah,09h
	mov dx,endline_msg
	int 21h

	mov ah,09h
	mov dx,bx_msg
	int 21h

	mov ax,bx
	mov bx,0
	mov cx,4
	mov di,0xffff
	jmp main

ax_msg db 'AX=0x$'
endline_msg db 0xD, 0xA, '$'
bx_msg db 'BX=0x$'