format pe64 efi
entry main


section ".text" code executable readable

main:
	mov [SystemTable], rdx
	
	mov rcx, [rdx + 64]
	sub rsp, 8 + (4 * 8)
	call qword[rcx + 6 * 8] ; ClearScreen

	mov rdx, [SystemTable]
	mov rcx, [rdx + 64]
	mov rdx, 35
	mov r8, 13
	call qword[rcx + 7 * 8] ; SetCursorPosition
	
	mov rdx, [SystemTable]
	mov rcx, [rdx + 64]
	mov rdx, 0x16
	call qword[rcx + 5 * 8] ; SetAttribute
	
	mov rdx, [SystemTable]
	mov rcx, [rdx + 64]
	mov rdx, string
	call qword[rcx + 1 * 8] ; OutputString

	mov rdx, [SystemTable]
	mov rcx, [rdx + 64]
	mov rdx, 0x07
	call qword[rcx + 5 * 8] ; SetAttribute

	add rsp, 8 + (4 * 8)
	
	mov rax,0
	ret


section ".data" data readable writeable

string du 'Likhota MP', 13, 10, 0
SystemTable dq ?