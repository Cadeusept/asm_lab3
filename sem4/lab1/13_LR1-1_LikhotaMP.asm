use16
org 100h

start:
cli
; выключение немаскируемых прерываний
	in	al,70h
	or	al,80h
	out	70h,al

; открываем линию A20:
	in	al,92h
	or	al,2
	out	92h,al

	xor eax,eax
	mov ax,cs
	shl eax,0x04
	mov [CODE_descr+2], al
	mov [CODE16_descr+2], al
	shr eax,0x08
	mov [CODE_descr+3], al
	mov [CODE16_descr+3], al
	mov [CODE_descr+4], ah
	mov [CODE16_descr+4], ah

; вычисление линейного адреса GDT
	xor	eax,eax
	mov	ax,cs
	shl	eax,4
	add	ax, GDT

; линейный адрес GDT кладем в заранее подготовленную переменную
	mov	dword[GDTR+2], eax

; загрузка регистра GDTR
	lgdt fword[GDTR]

; переключение в защищенный режим
	mov	eax,cr0
	or	al,1
	mov	cr0,eax


jmp far fword[ENTER_PROTECTED_PTR]

ENTER_PROTECTED_PTR:
ENTER_PROTECTED_LA: dd ENTRY_POINT
	dw 0x8

; глобальная таблица дескрипторов
align 8
GDT:
NULL_descr db 8 dup(0)
CODE_descr db 0FFh, 0FFh, 00h, 00h, 00h, 10011010b, 11001111b, 00h
DATA_descr db 0FFh, 0FFh, 00h, 00h, 00h, 10010010b, 11001111b, 00h
VIDEO_descr db 0FFh, 0FFh, 20h, 88h, 0Bh, 10010010b, 01000000b, 00h
CODE16_descr db 0FFh, 0FFh, 00h, 00h, 00h, 10011010b, 10001111b, 00h

GDT_size equ $-GDT

GDTR:
	dw GDT_size; 16-битный лимит GDT
	dd 0 ; здесь будет 32-битный линейный адрес GDT

use32
ENTRY_POINT:
;сохраним сегменты реального режима и перезапишем их
	mov	ax,10h ;регистр данных
	mov	bx,ds 
	mov word[real_ptr+2], bx
	mov	ds,ax 
	mov	ax,18h ;регистр видео
	mov	es,ax

mov esi, 0xFFFFFFF0
xor edi, edi
mov cx, 16
m2:
	push cx
	mov cx, 2
	xor ax, ax
	mov al, byte[esi]

	m1:
		push cx

		xor dx, dx
		mov dl, al

		and dl, 0xf0
		shr dl, 4
		add dl, 0x30
		cmp dl, 0x39

		jbe m0
		add dl, 0x7

	m0:
		mov dh, 35h
		mov [es:di], dx
		add di, 0x2
		shl al, 4

		pop cx
	loop m1
add esi, 0x2
mov dx, 0x3520

mov word[es:di], dx
add di, 0x2
pop cx
loop m2
;jmp $

; возврат в Дос
jmp  32:next
next:
use16

mov	eax,cr0
and al, 11111110b
mov	cr0,eax

jmp dword [cs:real_ptr]

real_ptr:
dw back_realm  
dw 0

use16
back_realm:
sti

in	al,0x70
and	al,0x7F
out 0x70,al

int 0x20
