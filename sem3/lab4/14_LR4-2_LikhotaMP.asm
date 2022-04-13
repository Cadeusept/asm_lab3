use16
org 100h

mov ax,ds
mov di,ax
mov bx,0x100

int 0x8e;вызов прервывания

mov ax,0x0
int 16h
int 20h