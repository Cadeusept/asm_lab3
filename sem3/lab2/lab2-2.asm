;mov
;sub
;shr
;and
;add
;loop
;cmp
;jmp,ja,jnz

use16
org 100h

mov ah,0x09

;mov dx, msg1
;int 21h
;mov dx,0

mov ax,0xba12
mov bx,0xde34




mov cx,ax
mov ah,0x02


mov dl,ch
shr dl,4
call get_ascii
call print_ascii

mov dl,ch
and dl,0x0f
call get_ascii 
call print_ascii
mov dx,0x0000

mov dl,cl
shr dl,4
call get_ascii              	
call print_ascii

mov dl,cl
and dl,0x0f
call get_ascii 
call print_ascii
mov dx,0x0000



;mov ah,0x09
;mov dx,endline_msg
;int 21h
;mov dx,0


 ;конец ax	


;mov dx,msg2
;int 21h
;mov dx,0

;mov ah,0x02



;mov dx,endline_msg
;int 21h
;mov dx,0

mov ax,0
int 16h
int 20h

get_ascii:
	cmp dl,0x09              ;Сравнение с символом 9
	ja word_symbol			;Если получилось больше, то прибавляем 7
	jmp digit_symbol

word_symbol:
	add dl,0x37
	ret

digit_symbol:
	add dl,0x30
	ret

print_ascii:
	int 21h
	mov dl,0x0
	ret


msg1 db 'AX=0x$'
msg2 db 'BX=0x$'
endline_msg db 0xd, 0xa, '$'