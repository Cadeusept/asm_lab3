real_mode:
use16
org 100h

    cli

    in  al,70h
    or  al,80h
    out 70h,al
    
    in  al,92h
    or  al,2
    out 92h,al

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

    xor eax,eax
    mov ax,cs
    shl eax,4
    add ax, GDT

    mov dword[GDTR+2], eax

    xor eax,eax
    mov ax,cs
    shl eax,4
    add ax, IDT

    mov dword[IDTR+2], eax

    lgdt    fword [GDTR]
    sidt    fword [IDTR_bckup];fword 
    lidt    fword [IDTR]

    mov eax,cr0
    or  al,1
    mov cr0,eax


jmp far fword[ENTER_PROTECTED_PTR]

ENTER_PROTECTED_PTR:
ENTER_PROTECTED_LA: dd prot32_mode
    dw 0x8

prot32_mode:
use32
    
    mov ax,10h
    mov bx,ds 
    mov word[real_ptr+2], bx
    mov ds,ax 
    mov ax,18h
    mov es,ax

    sti
    int 0x2d
    cli

jmp  32:next

GP_handler:
    pop eax
    pusha
    push edx
    mov edx,400
    inc word[es:edx]
    pop edx

    mov al, 0x20 ;прерывание обработано
    out 0x20, al
    out 0xA0, al

    popa
    iretd

OWN_handler:
    ;pop eax
    pusha
    
    mov esi, 0xFFFFFFF0
    xor edi, edi
    xor ax, ax
    mov al, 0x2d ;номер

    mov cx, 2
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

    mov al, 0x20 ;прерывание обработано
    out 0x20, al
    out 0xA0, al

    popa
    iretd

align 8
macro DEFINE_GATE _handler, _code_selector, _type
{
    dw _handler and 0x0ffff, _code_selector, _type, _handler shr 16
} 

GDT:
NULL_descr db 8 dup(0)
CODE_descr db 0FFh, 0FFh, 00h, 00h, 00h, 10011010b, 11001111b, 00h
DATA_descr db 0FFh, 0FFh, 00h, 00h, 00h, 10010010b, 11001111b, 00h
VIDEO_descr db 0FFh, 0FFh, 20h, 88h, 0Bh, 10010010b, 01000000b, 00h
CODE16_descr db 0FFh, 0FFh, 00h, 00h, 00h, 10011010b, 10001111b, 00h

GDT_size equ $-GDT

GDTR:
    dw GDT_size
    dd 0

IDT:
    dq  0 ;0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    DEFINE_GATE GP_handler, 8, 1000111000000000b
    dq  0 ;14
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0 ;32
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    dq  0
    DEFINE_GATE OWN_handler, 8, 1000111000000000b ;45 или 0x2d 
IDT_size equ $-IDT

IDTR:
    dw  IDT_size
    dd  0

IDTR_bckup:
    dw  0
    dd  0


next:
use16

mov eax,cr0
and al, 11111110b
mov cr0,eax

jmp dword [cs:real_ptr]

real_ptr:
dw back_realm  
dw 0

use16
back_realm:
lidt fword [cs:IDTR_bckup]

sti

in  al,0x70
and al,0x7F
out 0x70,al

int 0x20