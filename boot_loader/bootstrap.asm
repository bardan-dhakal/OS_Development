;*********************************************
;	boot_loader.asm
;		- A Simple Bootloader that loads a simple test Kernel
;
;	Operating Systems Development
;*********************************************


[org 0x7C00]
[bits 16]

; Debug to check if Bochs is running the Bootloader
mov ah, 0Eh
mov al, 'B'
int 0x10

start:
    ; *** CRITICAL: Set up stack first ***
    cli 
    mov ax, 0x9000
    mov ss, ax
    mov sp, 0xFFFF
    sti

    ; Set up data segment
    mov ax, 07C0h
    mov ds, ax

    mov si, title_string
    call print_string

    mov si, message_string
    call print_string

    call load_kernel_from_disk
    jmp 0900h:0000

load_kernel_from_disk:
    mov ax, 0900h
    mov es, ax

    mov ah, 02h
    mov al, 01h
    mov ch, 0h
    mov cl, 02h
    mov dh, 0h
    mov dl, 0h
    mov bx, 0h
    int 13h

    jc kernel_load_error

    ret

kernel_load_error:
    mov si, load_error_string
    call print_string

    jmp $


print_string:
    mov ah, 0Eh

print_char:
    lodsb

    cmp al, 0
    je printing_finished

    int 10h

    jmp print_char

printing_finished:
    mov al, 10d ; New Line
    int 10h

    ; Read current cursor Position
    mov ah, 03h
    mov bh, 0
    int 10h

    ; Move the cursor to the beginning
    mov ah, 02h
    mov dl, 0
    int 10h

    ret

title_string        db 'The Bootloader for a Test Kernel.' , 0
message_string      db 'The kernel is loading...' , 0
load_error_string   db 'The kernel cannot be loaded', 0

times 510- ($-$$) db 0

dw 0xAA55







