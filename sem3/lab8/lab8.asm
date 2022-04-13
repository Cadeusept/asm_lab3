use16
org 100h

call set_mode

call turn_on

call play_A2
call beep_10

call play_E2
call beep_6
call pause_1
call beep_6

call pause_3

call play_A2
call beep_6
call play_C2
call beep_6

call pause_3

call play_A2
call beep_10

call play_E2
call beep_6
call pause_1
call beep_6

call pause_3

call play_G2
call beep_6
call play_B2
call beep_6
call play_D2
call beep_6
call pause_1
call play_D2
call beep_4
call play_B2
call beep_4
call play_A2
call beep_6

call pause_3

call play_E2
call beep_6
call pause_1
call beep_6

call play_A2
call beep_6
call play_C2
call beep_6

call pause_3

call play_F1
call beep_6
call pause_1
call beep_6

call play_C2
call beep_4
call pause_1
call beep_4

call pause_3

call play_G2
call beep_6
call play_B2
call beep_6
call play_D2
call beep_6
call pause_1
call play_D2
call beep_4
call play_B2
call beep_4
call play_A2
call beep_6





call pause_3





call play_A2
call beep_10

call play_E2
call beep_6
call pause_1
call beep_6

call pause_3

call play_A2
call beep_6
call play_C2
call beep_6

call pause_3

call play_A2
call beep_10

call play_E2
call beep_6
call pause_1
call beep_6

call pause_3

call play_G2
call beep_6
call play_B2
call beep_6
call play_D2
call beep_6
call pause_1
call play_D2
call beep_4
call play_B2
call beep_4
call play_A2
call beep_6

call pause_3

call play_E2
call beep_6
call pause_1
call beep_6

call play_A2
call beep_6
call play_C2
call beep_6

call pause_3

call play_F1
call beep_6
call pause_1
call beep_6

call play_C2
call beep_4
call pause_1
call beep_4

call pause_3

call play_G2
call beep_6
call play_B2
call beep_6
call play_D2
call beep_6
call pause_1
call play_D2
call beep_4
call play_B2
call beep_4
call play_A2
call beep_4

call turn_off

int 20h

pause_1:
	pusha
	call turn_off
	call Delay_1
	call turn_on 
	popa
	ret

pause_3:
	pusha
	call turn_off
	call Delay_3
	call turn_on 
	popa
	ret

beep_1:
	pusha
	

	call Delay_1

	
	popa
	ret

beep_2:
	pusha
	

	call Delay_2

	
	popa
	ret

beep_3:
	pusha
	

	call Delay_3

	
	popa
	ret

beep_4:
	pusha
	

	call Delay_4

	
	popa
	ret

beep_5:
	pusha
	

	call Delay_5

	
	popa
	ret

beep_6:
	pusha
	

	call Delay_6

	
	popa
	ret

beep_10:
	pusha
	

	call Delay_5
	call Delay_5
	
	popa
	ret


set_mode:
	pusha
	mov al, 0xb6
	out 0x43, al          ; Задаем режим работы контроллера
	popa
	ret

play_F1:
	pusha
	mov ax, (1190000/349) 
	out 0x42, al          
	mov al, ah            
	out 0x42, al	          
	popa
	ret

play_A2:
	pusha
	mov ax, (1190000/880) 
	out 0x42, al          
	mov al, ah            
	out 0x42, al          
	popa
	ret

play_B2:
	pusha
	mov ax, (1190000/988) 
	out 0x42, al          
	mov al, ah            
	out 0x42, al       
	popa
	ret

play_C2:
	pusha
	mov ax, (1190000/523) 
	out 0x42, al          
	mov al, ah            
	out 0x42, al
	popa
	ret

play_D2:
	pusha
	mov ax, (1190000/587) 
	out 0x42, al          
	mov al, ah            
	out 0x42, al
	popa
	ret

play_E2:
	pusha
	mov ax, (1190000/659) 
	out 0x42, al          
	mov al, ah            
	out 0x42, al          
	popa
	ret

play_G2:
	pusha
	mov ax, (1190000/784) 
	out 0x42, al          
	mov al, ah            
	out 0x42, al	          
	popa
	ret




turn_on:
	pusha
	in al, 0x61
	or al, 00000011b      ; Установим 2 младших бита
	out 0x61, al          ; Включим динамик
	popa
	ret


turn_off:
	pusha
	in al, 0x61           ; Сбрасываем 2 младших бита
	and al, 11111100b
	out 0x61, al          ; Выключим динамик
	popa
	ret



Delay_1:
	pusha
	mov ah,0
	int 0x1a
	mov si,1
	jmp sleep

Delay_2:
	pusha
	mov ah,0
	int 0x1a
	mov si,2
	jmp sleep

Delay_3:
	pusha
	mov ah,0
	int 0x1a
	mov si,3
	jmp sleep

Delay_4:
	pusha
	mov ah,0
	int 0x1a
	mov si,4
	jmp sleep

Delay_5:
	pusha
	mov ah,0
	int 0x1a
	mov si,5
	jmp sleep

Delay_6:
	pusha
	mov ah,0
	int 0x1a
	mov si,5
	jmp sleep

	sleep:
		push dx
		mov ah,0
		int 0x1a
		pop bx
		cmp bx,dx
		jne cnt
		jmp sleep
	
	fin:
		popa
		ret

cnt:
	dec si
	cmp si,0
	je fin
	jmp sleep