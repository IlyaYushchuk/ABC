[bits 16]
[org 0x7c00]

mov [BOOT_DISK], dl


CODE_SEG equ GDT_code - GDT_start
DATA_SEG equ GDT_data - GDT_start

cli
in al, 0x70         
or al, 0x80       
out 0x70, al 


lgdt [GDT_descriptor]
mov eax, cr0
or eax, 1
mov cr0, eax
jmp CODE_SEG:start_protected_mode

start_real_mode:
    cli
    in al, 0x70         
    or al, 0x80       
    out 0x70, al 

    mov eax, cr0
    and eax, 0xFFFFFFFE
    mov cr0, eax

    mov al, 0x0D
    out 0x70, al
    in al, 0x21
    and al, 0
    out 0x21, al
    sti

    mov ax, 0x0000
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov sp, 0x7C00

    jmp real_mode_entry
    
real_mode_entry:
    mov ah, 0x0e
    mov al, 'R'
    int 0x10 
    jmp $

GDT_start:
    GDT_null:
        dd 0x0
        dd 0x0

    GDT_code:
        dw 0xFFFF
        dw 0x0
        db 0x0
        db 0b10011010
        db 0b11001111
        db 0x0

    GDT_data:
        dw 0xFFFF
        dw 0x0
        db 0x0
        db 0b10010010
        db 0b11001111
        db 0x0

GDT_end:

GDT_descriptor:
    dw GDT_end - GDT_start - 1
    dd GDT_start

[bits 32]
start_protected_mode:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov ss, ax

print_hello:
    mov esi, message
    mov edi, 0xb8000

print_loop:
    lodsb
    test al, al
    jz done
    mov ah, 0x0d
    stosw
    jmp print_loop

done:
    mov eax, cr0
    and eax, 0xFFFFFFFE
    mov cr0, eax
    jmp start_real_mode

message db "Protected mode!", 0

BOOT_DISK db 0



times 510-($-$$) db 0
dw 0xAA55
