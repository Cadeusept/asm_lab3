use16
org 100h

start:
cli
; выключение немаскируемых прерываний
    in  al,70h
    or  al,80h
    out 70h,al

; открываем линию A20:
    in  al,92h
    or  al,2
    out 92h,al

    xor eax,eax
    mov ax,cs
    shl eax,0x04
    mov [CODE_descr+2], al
    mov [CODE16_descr+2], al
    mov [DATAM_descr+2], al
    shr eax,0x08
    mov [CODE_descr+3], al
    mov [CODE16_descr+3], al
    mov [DATAM_descr+3], al
    mov [CODE_descr+4], ah
    mov [CODE16_descr+4], ah
    mov [DATAM_descr+4], ah

; вычисление линейного адреса GDT
    xor eax,eax
    mov ax,cs
    shl eax,4
    add ax, GDT

; линейный адрес GDT кладем в заранее подготовленную переменную
    mov dword[GDTR+2], eax

; загрузка регистра GDTR
    lgdt fword[GDTR]

; переключение в защищенный режим
    mov eax,cr0
    or  al,1
    mov cr0,eax


jmp far fword[ENTER_PROTECTED_PTR]

ENTER_PROTECTED_PTR:
ENTER_PROTECTED_LA: dd ENTRY_PROTECTED
    dw 0x8

; глобальная таблица дескрипторов
align 8
GDT:
NULL_descr db 8 dup(0)
CODE_descr db   0FFh, 0FFh, 00h, 00h, 00h, 10011010b, 11001111b, 00h
DATA_descr db   0FFh, 0FFh, 00h, 00h, 00h, 10010010b, 11001111b, 00h
VIDEO_descr db  0FFh, 0FFh, 20h, 88h, 0Bh, 10010010b, 01000000b, 00h
CODE16_descr db 0FFh, 0FFh, 00h, 00h, 00h, 10011010b, 10001111b, 00h
CODE64_descr db 000h, 000h, 00h, 00h, 00h, 10011010b, 00100000b, 00h
DATA64_descr db 000h, 000h, 00h, 00h, 00h, 10010010b, 00100000b, 00h
DATAM_descr db  0FFh, 0FFh, 00h, 00h, 00h, 10010010b, 11001111b, 00h

GDT_size equ $-GDT
mov dword[edi + 4], 0
GDTR:
    dw GDT_size; 16-битный лимит GDT
    dd 0 ; здесь будет 32-битный линейный адрес GDT

use32
ENTRY_PROTECTED:
    mov bx, ds
    mov word[BCKUP_REAL_PTR+2], bx
    
    mov ax,16  ; load 4 GB data descriptor
    mov ds,ax           ; to all data segment registers
    mov es,ax

    mov eax,cr4
    or  eax,1 shl 5
    mov cr4,eax         ; enable physical-address extensions

    mov eax, 170000h
    mov cr3, eax            ; Загрузка адреса PML4 в cr3

    mov edi, 170000h        ; заполняем одну запись PDPT
    mov dword[edi], 171007h
    mov dword[edi + 4], 0

    ; заполнение каталога страниц
    mov edi, 171000h        ; запись о 1 таблице
    mov dword[edi], 172007h
    mov dword[edi + 4], 0  ; очистка

    add edi, 8
    mov dword[edi], 173007h ; запись о 2 таблице
    mov dword[edi + 4], 0  ; очистка

    add edi, 8
    mov dword[edi], 174007h ; запись о 3 таблице
    mov dword[edi + 4], 0  ; очистка

    add edi, 8
    mov dword[edi], 175007h ; запись о 4 таблице
    mov dword[edi + 4], 0  ; очистка

    ; заполнение таблиц страниц
    mov edi, 172000h    ; адрес первой таблицы страниц 
    mov ecx, 512*4      ; число страниц в 4 таблицах
    mov eax, 0 + 87h    ; 0 - адрес нулевой страницы, 87h - атрибуты

    ; генерируем страницы
    cycle:
        stosd
        mov dword[edi], 0
        add edi, 4
        add eax, 200000h ; плюс 2Mb
        loop cycle 

    mov eax,170000h
    mov cr3,eax         ; load page-map level-4 base

    mov ecx,0C0000080h      ; EFER MSR
    rdmsr
    or  eax,1 shl 8     ; enable long mode
    wrmsr

    mov eax,cr0
    or  eax,1 shl 31
    mov cr0,eax         ; enable paging

    mov ax, 0x38        ; ПЕРЕСЧЁТ АДРЕСА
    mov es, ax
    xor eax, eax
    mov ax , bx
    shl eax, 4
    add eax, ENTRY_LONG_POINT
    mov dword[es:ENTER_LONG_PTR], eax

    jmp fword[es:ENTER_LONG_PTR]

ENTER_LONG_PTR:
 dd 0x0
 dw 0x28

use64
ENTRY_LONG_POINT:
mov ax,0x30
mov ds,ax
mov es,ax

mov rax, '2 D '
mov rdi,0x0B8000 + 0x820
mov [rdi],rax



xor rdi,rdi


; возврат в Дос
jmp tbyte[BCKUP_PROT_PTR]

BCKUP_PROT_PTR:
 dq BCKUP_PROT
 dw 0x8

BCKUP_PROT:
use32

mov eax, cr0
btr eax, 31
mov cr0, eax

mov ecx, 0x0C0000080 
rdmsr
btr eax, 8 
wrmsr

mov eax, cr4
btr eax, 5 
mov cr4, eax

jmp  32:next

next:
use16

mov eax,cr0
and al, 11111110b
mov cr0,eax

jmp dword [cs:BCKUP_REAL_PTR]

BCKUP_REAL_PTR:
dw BCKUP_REAL  
dw 0

use16
BCKUP_REAL:
sti

mov ax, cs
mov es, ax
mov ds, ax

in  al,0x70
and al,0x7F
out 0x70,al

int 0x20
