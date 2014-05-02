; AsmGrm Tests
;
; Copyright (C) 2014 Rob Hardwick

; stdlib.h
extern malloc

; stdio.h
extern strncmp
extern putchar
extern exit
extern __printf_chk
extern __vsprintf_chk

; permutations.asm
extern asmgrm_permutations


;
; Data
;

section .data
    test_fail:     db `\033[31mTest '%s' FAILED\033[0m\n\0`
    test_pass:     db `%s\n\033[32mTest '%s' PASSED\033[0m\n\n\0`

    test1_result:  db `<p>a</p>\0`
    test1_name:    db `a permutations\0`

    test2_result:  db `<p>ab</p>\n<p>ba</p>\n\0`
    test2_name:    db `ab permutations\0`

    test3_result:  db `<p>abc</p>\n<p>acb</p>\n<p>bac</p>\n<p>bca</p>\n<p>cba</p>\n<p>cab</p>\n\0`
    test3_name:    db `abc permutations\0`

    test4_result:  db `<p>abcd</p>\n<p>abdc</p>\n<p>acbd</p>\n<p>acdb</p>\n<p>adcb</p>\n<p>adbc</p>\n<p>bacd</p>\n<p>badc</p>\n<p>bcad</p>\n<p>bcda</p>\n<p>bdca</p>\n<p>bdac</p>\n<p>cbad</p>\n<p>cbda</p>\n<p>cabd</p>\n<p>cadb</p>\n<p>cdab</p>\n<p>cdba</p>\n<p>dbca</p>\n<p>dbac</p>\n<p>dcba</p>\n<p>dcab</p>\n<p>dacb</p>\n<p>dabc</p>\n\0`
    test4_name:    db `abcd permutations\0`

    test5_result:  db `<p>$\?!</p>\n<p>$!\?</p>\n<p>\?$!</p>\n<p>\?!$</p>\n<p>!\?$</p>\n<p>!$\?</p>\n\0`
    test5_name:    db `$\?! permutations\0`


;
; Code
;

section .text
    global _start, FCGX_FPrintF

;
; Run tests
;

; Stack
%define test_buffer     48
%define test1_input     32
%define test2_input     16
%define test3_input     1088
%define test4_input     1072
%define test5_input     1104
%define start_stack     1128

_start:
    sub rsp, start_stack
    lea rax, [rsp+test_buffer]
    mov qword[rsp], rax

.test1:
    mov word[rsp+test1_input], `a`
    lea rdx, [rsp+test1_input]
    mov ecx, test1_result
    mov esi, test1_name
    mov rdi, rsp
    call test

.test2:
    mov word[rsp+test2_input], `ab`
    mov byte[rsp+test2_input+2], `\0`
    lea rdx, [rsp+test2_input]
    mov ecx, test2_result
    mov esi, test2_name
    mov rdi, rsp
    call test

.test3:
    mov dword[rsp+test3_input], `abc\0`
    lea rdx, [rsp+test3_input]
    mov ecx, test3_result
    mov esi, test3_name
    mov rdi, rsp
    call test

.test4:
    mov dword[rsp+test4_input], `abcd`
    mov byte[rsp+test4_input+4], `\0`
    lea rdx, [rsp+test4_input]
    mov ecx, test4_result
    mov esi, test4_name
    mov rdi, rsp
    call test

.test5:
    mov dword[rsp+test5_input], `$\?!\0`
    lea rdx, [rsp+test5_input]
    mov ecx, test5_result
    mov esi, test5_name
    mov rdi, rsp
    call test

.exit:
    add rsp, start_stack
    xor rdi, rdi
    call exit


;
; Run test
;

; Stack
%define test_stack      40

test:
    mov qword[rsp-40], rbx
    mov qword[rsp-32], rbp
    mov qword[rsp-24], r12
    mov qword[rsp-16], r13
    mov qword[rsp-8], r14
    sub rsp, test_stack

    mov rbx, rdi
    mov r14, rsi
    mov rsi, rdx
    mov rbp, rcx
    mov qword[rdi+8], 0
    mov r12, -1
    mov rdi, rdx
    mov r13d, 0
    mov rcx, r12
    mov eax, r13d
    repnz scasb
    not rcx
    add rcx, r12
    mov edx, 0
    mov rdi, rbx
    call asmgrm_permutations

    mov rdi, rbp
    mov rcx, r12
    mov eax, r13d
    repnz scasb
    mov r12, rcx
    not r12
    lea rdx, [r12-1]
    mov rsi, rbp
    mov rdi, qword[rbx]
    call strncmp
    test eax, eax
    je .pass

.fail:
    mov rdx, r14
    mov esi, test_fail
    mov edi, 1
    mov eax, 0
    call __printf_chk
    jmp .ret

.pass:
    mov rcx, r14
    mov rdx, rbp
    mov esi, test_pass
    mov edi, 1
    mov eax, 0
    call __printf_chk

.ret:
    mov rbx, qword[rsp]
    mov rbp, qword[rsp+8]
    mov r12, qword[rsp+16]
    mov r13, qword[rsp+24]
    mov r14, qword[rsp+32]
    add rsp, test_stack
    ret


;
; Mock FCGX_FPrintF (fcgiapp.h)
;

; Stack
%define fprintf_stack      208

FCGX_FPrintF:
    push rbx
    sub rsp, fprintf_stack
    mov rbx, rdi
    mov qword[rsp+48], rdx
    mov qword[rsp+56], rcx
    mov qword[rsp+64], r8
    mov qword[rsp+72], r9
    test al, al
    je .vsprintf

; Load vargs
    movaps [rsp+80], xmm0
    movaps [rsp+96], xmm1
    movaps [rsp+112], xmm2
    movaps [rsp+128], xmm3
    movaps [rsp+144], xmm4
    movaps [rsp+160], xmm5
    movaps [rsp+176], xmm6
    movaps [rsp+192], xmm7

.vsprintf:
    mov rcx, rsi
    mov dword[rsp+8], 16
    mov dword[rsp+12], 48
    lea rax, [rsp+224]
    mov qword[rsp+16], rax
    lea rax, [rsp+32]
    mov qword[rsp+24], rax
    mov rdi, qword[rbx]
    add rdi, qword[rbx+8]
    lea r8, [rsp+8]
    mov rdx, -1
    mov esi, 1
    call __vsprintf_chk
    test eax, eax
    jle .ret
    cdqe
    add qword[rbx+8], rax

.ret:
    add rsp, fprintf_stack
    pop rbx
    ret
