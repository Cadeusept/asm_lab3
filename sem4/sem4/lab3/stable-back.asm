use16
org 100h


	in	al,92h  
	or	al,2   
	out	92h,al 
     
	xor	eax,eax 
	mov	ax,ds	
	shl	eax,4	
	mov	ebp,eax 
	mov	word [gdt_data+2],ax	
	rol	eax,16	
	mov	[gdt_data+4],al 
	
	mov	ax,ds	
	shl	eax,4
	add eax,long_start
	mov [jmp_instr],eax
	
	mov ax,cs
	shl eax,4
        mov [prog_base],eax

	xor	eax,eax 
	mov	ax,cs	

	shl	eax,4	
	mov	word [gdt_code+2],ax
	rol	eax,16	
	mov	[gdt_code+4],al 

    add ebp,gdt_null
	mov	dword	[pdescr+2],ebp	
	mov	word	[pdescr],gdt_size-1
	

	lgdt	pword [pdescr]	

	cli		
	mov	al,80h
	mov	eax,cr0 
	or	eax,1	
	mov	cr0,eax
	jmp	16:continue
continue:
use32

mov	eax,8	; load 4 GB data descriptor
	mov	ds,ax
	mov	ss,ax	; to all data segment registers
	mov	ax,32
	mov es,ax
	mov	fs,ax
	mov	gs,ax
	
	mov byte [ds:0xB8300],"A"
	mov byte [ds:0xB8400],"B"
	jmp $

	mov	eax,cr4
	or	eax,1 shl 5
	mov	cr4,eax 		; enable physical-address extensions

	mov	edi,71000h
	mov	ecx,4000h shr 2
	xor	eax,eax
	rep	stosd			; clear the page tables

	
	mov	dword [es:71000h],72000h + 7h ; first page directory
	
	mov ecx,4
	mov eax,73007h
	mov edi,72000h
make_tables:
	mov	dword [es:edi],eax ; first page table
    mov dword [es:edi+4], 0
	add eax,1000h
	add edi,8h
	loop make_tables
	

	
	mov	edi,73000h		; address of first page table
	mov	eax,0 + 87h
	mov	ecx,2048 		; number of pages to map (1 MB)
	
  make_page_entries:
	stosd
	mov dword [es:edi+4], 0
	add	eax,2*1024*1024
	add	edi,8h
	loop	make_page_entries

	mov	eax,71000h
	mov	cr3,eax 		; load page-map level-4 base

	mov	ecx,0C0000080h		; EFER MSR
	rdmsr
	or	eax,1 shl 8		; enable long mode
	wrmsr

	mov	eax,cr0
	or	eax,1 shl 31
	mov	cr0,eax 		; enable paging

	mov eax,[prog_base]
	add eax,long_start
	push word 24
	push eax
	jmp far [ss:esp] 


	
	jmp	far fword [jmp_instr]

	USE64
jmp_instr:
dd 0
dw 24

long_start:
mov ax,24
mov ds,ax
mov rdi,0xb8000 + 158
mov word [rdi],0x1F30
jmp $
mov ecx,str_len

mov edi,0
mov esi,string
;push ecx


cycle:
movsb 
inc edi
loop cycle
;pop ecx
		
	jmp $

	align	8
	;b8640

gdt_null	db	00h,00h,00h,00h,00h,00h,00h,00h
gdt_data	db	0FFh,0FFh,0,0,0,92h,0CFh,0
gdt_code	db	0FFh,0FFh,0,0,0,9Ah,0CFh,0
gdt_long    	db 	0FFh,0FFh,0,0,0,9Ah,0AFh,0
gdt_data2   	db	0FFh,0FFh,0,0,0,92h,0CFh,0
gdt_size=$-gdt_null	

pdescr	dq	0	
prog_base dd 0
str_begin:

string db 'Hello,my name is Fedor'
str_len =$-str_begin
