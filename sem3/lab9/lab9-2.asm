use16
org 100h

mov ax,0x0

init:
	mov ax,0x2501
	mov dx, own_int0x01
	int 21h
	ret

own_int0x01:
	sti
	jmp tracing
	iret
	
start:
call init
push ax
mov dx,buf
mov ah,0x0a
int 21h ;ds:dx
pop ax

mov si,dx
add si,2
mov cx,psswd_size
dec cx
mov di,correct_psswd

jmp check_psswd

check_psswd:
	pusha
	repe cmpsb ;ds:si и es:di

	je correct
	jmp wrong

correct:
	push dx
	push ax
	mov dx,correct_msg
	mov ah,09h
	int 21h
	pop ax
	pop dx
	popa
	jmp finish

wrong:
	push dx
	push ax
	mov dx,wrong_msg
	mov ah,09h
	int 21h
	pop ax
	pop dx
	jmp start

tracing:
	push dx
	push ax
	mov dx,tracing_msg
	mov ah,09h
	int 21h
	pop ax
	pop dx
	popa
	jmp finish

finish:
	mov ax,0x0
	int 16h
	int 20h


correct_psswd db 'IU10-31_Likhota$'
psswd_size = $ - correct_psswd

buf db psswd_size,?,psswd_size dup(?)

endl_msg db 0xA, 0xD, '$'
correct_msg db 0xA, 0xD, 'Correct password', 0xA, 0xD, '$' 
tracing_msg db 0xA, 0xD, 'Tracing detected', 0xA, 0xD, '$' 
wrong_msg db 0xA, 0xD, 'Wrong password', 0xA, 0xD, '$'