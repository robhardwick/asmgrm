; AsmGrm
;
; Copyright (C) 2014 Rob Hardwick

; fcgiapp.h
extern FCGX_FPrintF

; Stack
%define perm_out    0   ; FCGX_Stream *
%define perm_stack  8


;
; Data
;

section .data
    perm_fmt: db `<p>%s</p>\n\0`


;
; Code
;

section .text
    global asmgrm_permutations

asmgrm_permutations:
    push r15
    push r14
    push r13
    push r12
    push rbp
    push rbx
    sub rsp, perm_stack

; Initialise
    mov r14, rsi
    mov r13d, ecx
    mov r12d, edx
    cmp edx, ecx
    mov qword[rsp+perm_out], rdi
    je .print

; Print all permutations for first char
    lea r15d, [r12+1]
    mov rdi, qword[rsp+perm_out]
    mov edx, r15d
    call asmgrm_permutations
    cmp r13d, r15d
    jle .exit

; Print subsequent permutations
    mov edx, r13d
    movsx rax, r15d
    movsx rbp, r12d
    sub edx, r12d
    lea rbx, [r14+rax]
    lea rax, [r14+1+rax]
    mov r12d, edx
    add rbp, r14
    sub r12d, 2
    add r12, rax

; Swap byte
.loop:
    movzx eax, byte[rbp]
    movzx edx, byte[rbx]
    cmp al, dl
    je .next

; Recurse
    mov rdi, qword[rsp+perm_out]
    mov byte[rbp], dl
    mov ecx, r13d
    mov byte[rbx], al
    mov edx, r15d
    mov rsi, r14
    call asmgrm_permutations

; Swap byte
    movzx eax, byte[rbp]
    movzx edx, byte[rbx]
    mov byte[rbp], dl
    mov byte[rbx], al

.next:
    add rbx, 1
    cmp rbx, r12
    jne .loop

; Clean-up and return
.exit:
    add rsp, perm_stack
    pop rbx
    pop rbp
    pop r12
    pop r13
    pop r14
    pop r15
    ret

; Print permutation and return
.print:
    add rsp, perm_stack
    mov rdx, rsi
    xor eax, eax
    pop rbx
    pop rbp
    pop r12
    pop r13
    pop r14
    pop r15
    mov esi, perm_fmt
    jmp FCGX_FPrintF
