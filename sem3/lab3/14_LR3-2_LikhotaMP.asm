use16
org 100h


mov ax,0xa
mov bx,0xb
mov cx,0xc
mov dx,0xd

call print_all_regs

mov ax,0x0
int 16h
int 20h


print_all_regs:
	pusha
	
	push ax
	mov ah,09h
	push dx
	mov dx,msg_ax
	int 21h
	pop dx
	pop ax
	call print_ax
	
	mov ah,09h
	push dx
	mov dx,msg_bx
	int 21h
	pop dx
	mov ax,bx
	call print_ax

	mov ah,09h
	push dx
	mov dx,msg_cx
	int 21h
	pop dx
	mov ax,cx
	call print_ax

	mov ah,09h
	push dx
	mov dx,msg_dx
	int 21h
	pop dx
	mov ax,dx
	call print_ax

	mov ah,09h
	mov dx,msg_cs
	int 21h
	mov ax,cs
	call print_ax

	mov ah,09h
	mov dx,msg_ss
	int 21h
	mov ax,ss
	call print_ax

	mov ah,09h
	mov dx,msg_ds
	int 21h
	mov ax,ds
	call print_ax

	mov ah,09h
	mov dx,msg_es
	int 21h
	mov ax,es
	call print_ax

	mov ah,09h
	mov dx,msg_si
	int 21h
	mov ax,si
	call print_ax

	mov ah,09h
	mov dx,msg_di
	int 21h
	mov ax,di
	call print_ax

	mov ah,09h
	mov dx,msg_sp
	int 21h
	mov ax,sp
	add ax,0x13; поправка на увеличение указателя стека ввиду записи туда координат вызова подпрограммы и сохранения всех регистров
	call print_ax

	mov ah,09h
	mov dx,msg_bp
	int 21h
	mov ax,bp
	call print_ax

	mov ah,09h
	mov dx,msg_flags
	int 21h
	pushf
	pop ax
	call print_ax

	popa
	ret


print_ax:
	pusha

	mov dx,0x0
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
		and dx,0xf000
		shr dx,12
		cmp dl,0x9
		ja word_symbol
		jmp digit_symbol

	second_letter:
		mov dx,ax
		and dx,0x0f00
		shr dx,8
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


	digit_symbol:
		add dl,0x30
		jmp print_ascii

	word_symbol:
		add dl,0x37
		jmp print_ascii

msg_ax db 'AX=0x$'
msg_bx db ' BX=0x$'
msg_cx db ' CX=0x$'
msg_dx db ' DX=0x$'
msg_cs db 0xD, 0xA, 'CS=0x$'
msg_ss db ' SS=0x$'
msg_ds db ' DS=0x$'
msg_es db ' ES=0x$'
msg_si db 0xD, 0xA, 'SI=0x$'
msg_di db ' DI=0x$'
msg_sp db 0xD, 0xA, 'SP=0x$'
msg_bp db ' BP=0x$'
msg_flags  db 0xD, 0xA, 'FLAGS=0x$'