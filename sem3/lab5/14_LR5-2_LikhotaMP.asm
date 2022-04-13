format MZ
entry code_seg:start
stack 200h
;--------------
segment data_seg

correct_psswd db 'IU10-31_Likhota$'
psswd_size = $ - correct_psswd

buf db psswd_size,?,psswd_size dup(?)

endl_msg db 0xA, 0xD, '$'
correct_msg db 0xA, 0xD, 'Correct password', 0xA, 0xD, '$' 
wrong_msg db 0xA, 0xD, 'Wrong password', 0xA, 0xD, '$'
;--------------
segment code_seg

start:
mov ax,data_seg
mov ds,ax
mov es,ax
mov ax,0x0
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
	popa
	jmp start

finish:
	mov ax,0x0
	int 16h
	mov ax,0x4c00
	int 21h