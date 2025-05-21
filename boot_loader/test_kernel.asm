;*********************************************
;	test_kernel.asm
;		- A simple Test Kernel < 512 bytes that prints "Hello World from Test Kernel!" for testing of the bootloader

;
;	Operating Systems Development
;*********************************************

[org 0x0000]

start:
    mov ax, cs
    mov ds, ax

    mov si, hello_string
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
    ret

hello_string    db  'Hello World from Test Kernel' , 0