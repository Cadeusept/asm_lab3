use16
org 100h

mov di,0xe;строка
mov si,0xa;столбец

mov dh,0x1f;атрибуты
mov dl,0x35;ascii

call print

mov ax,0x0
int 16h
int 20h

print:
	pusha

	push dx
	mov ax,0xb800
	mov es,ax

	mov ax,0x00a0	;80*2=160(10)=a0(16)
	dec di
	mul di
	mov di,ax

	mov ax,0x2
	mul si
	mov si,ax
	
	add di,si
	
	pop si
	
	mov word[es:di], si

	popa
	ret