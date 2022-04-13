use16
org 100h

mov ax,10
mov di,ax;строка
mov bp,77;столбец


mov si,string;запись ссылки на строку в индексный сегмент
mov ah,0x47;атрибуты

printing:
	push si
	push bp
	push di
	mov cx,string_size
	lp:
		lodsb;читает в al байт из массива, ссылка на который в si
		call print
		inc di
		back_to_loop:
		cmp bp,81
		ja end_of_cols_lp
		cmp di,26
		ja end_of_rows_lp
		loop lp
	pop di
	pop bp
	inc di
cleaning:
	cmp bp,81
	je end_of_cols
	
	cmp di,26
	je end_of_rows
	
	call Delay

	call clear_screen
	pop si
	jmp printing


end_of_rows_lp:
	mov di,0x1
	inc bp
	jmp back_to_loop

end_of_cols_lp:
	mov bp,0x1
	jmp back_to_loop

end_of_rows:
	mov di,0x1
	inc bp
	jmp cleaning

end_of_cols:
	mov bp,0x1
	jmp cleaning

clear_screen:
	pusha

	mov ax, 03
	int 10h

	popa
	ret

Delay:
	pusha
	mov ah,0
	int 0x1a

	.Wait:
		push dx
		mov ah,0
		int 0x1a
		pop bx
		cmp bx,dx
		je .Wait
	
	popa
	ret

print:
	pusha

	push ax
	mov ax,0xb800
	mov es,ax

	mov ax,160
	dec di;пользователь начинает считать с 1
	mul di
	mov di,ax

	mov ax,0x2
	dec bp;пользователь начинает считать с 1
	mul bp
	mov bp,ax
	
	add di,bp

	pop si
	mov word[es:di], si

	popa
	ret

string db 'A','B','O','B','A'
string_size = $ - string