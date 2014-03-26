; AsmGrm
;
; Copyright (C) 2014 Rob Hardwick

; string.h
extern strlen

; time.h
extern clock_gettime
%define CLOCK_PROCESS_CPUTIME_ID 2

; fcgiapp.h
extern FCGX_Accept
extern FCGX_GetParam
extern FCGX_FPrintF
extern FCGX_PutS

; App constants
%define MAX_LENGTH      6

; Stack offsets
%define fcgx_in         0   ; FCGX_Stream *
%define fcgx_out        8   ; FCGX_Stream *
%define fcgx_err        16  ; FCGX_Stream *
%define fcgx_envp       24  ; FCGX_ParamArray
%define tmspec_start    32  ; struct timespec
%define tmspec_end      48  ; struct timespec

; Stack sizes
%define stack_start     64
%define stack_perm      24

; Struct offsets
%define tmspec_nsec     8   ; long int tv_nsec (struct timespec)


;
; Code
;

section .text
    global _start

; Application start
_start:
    sub rsp, stack_start

; Start accept loop
.accept:
    lea rdi, [rsp+fcgx_in]
    lea rsi, [rsp+fcgx_out]
    lea rdx, [rsp+fcgx_err]
    lea rcx, [rsp+fcgx_envp]
    call FCGX_Accept
    test eax, eax
    js .quit

; Get request URI
    mov rsi, qword[rsp+fcgx_envp]
    mov edi, request_uri
    call FCGX_GetParam
    test rax, rax
    je .error

; Remove leading slash
    mov r14, rax
    inc r14

; Get length
    mov rdi, r14
    call strlen
    mov ebx, eax

; Check length < MAX_LENGTH
.maxlen:
    cmp rbx, MAX_LENGTH
    jbe .minlen

; Truncate string
    mov byte[r14+MAX_LENGTH], 0
    mov ebx, MAX_LENGTH

; Check length > 1
.minlen:
    test rbx, rbx
    je .home

; Print permutations header
.response:
    mov rsi, qword[rsp+fcgx_out]
    mov edi, response_head
    call FCGX_PutS

; Get start time
    lea rsi, [rsp+tmspec_start]
    mov edi, CLOCK_PROCESS_CPUTIME_ID
    call clock_gettime

; Print permutations
    mov rdi, qword[rsp+fcgx_out]
    mov ecx, ebx
    xor edx, edx
    mov rsi, r14
    call permutations

; Get end time
    lea rsi, [rsp+tmspec_end]
    mov	edi, CLOCK_PROCESS_CPUTIME_ID
    call clock_gettime

; Calculate elapsed time
    mov rdx, qword[rsp+tmspec_end+tmspec_nsec]
    sub rdx, qword[rsp+tmspec_start+tmspec_nsec]

; Print elapsed time
    mov esi, time_fmt
    mov rdi, qword[rsp+fcgx_out]
    xor	eax, eax
    call FCGX_FPrintF

; Print permutations footer
    mov rsi, qword[rsp+fcgx_out]
    mov edi, response_foot
    call FCGX_PutS
    jmp .accept

; Print home page header
.home:
    mov rsi, qword[rsp+fcgx_out]
    mov edi, response_head
    call FCGX_PutS

; Print home page
    mov rsi, qword[rsp+fcgx_out]
    mov edi, response_home
    call FCGX_PutS

; Print home page footer
    mov rsi, qword[rsp+fcgx_out]
    mov edi, response_foot
    call FCGX_PutS
    jmp .accept

; Print error page
.error:
    mov rsi, qword[rsp+fcgx_out]
    mov edi, response_error
    call FCGX_PutS
    jmp .accept

.quit:
    xor eax, eax
    add rsp, stack_start
    ret

; Print all permutations
permutations:
    push r15
    push r14
    push r13
    push r12
    push rbp
    push rbx
    sub rsp, stack_perm

; Initialise
    mov r14, rsi
    mov r13d, ecx
    mov r12d, edx
    cmp edx, ecx
    mov qword[rsp+fcgx_out], rdi
    je .print

; Print all permutations for first char
    lea r15d, [r12+1]
    mov rdi, qword[rsp+fcgx_out]
    mov edx, r15d
    call permutations
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
    mov rdi, qword[rsp+fcgx_out]
    mov byte[rbp], dl
    mov ecx, r13d
    mov byte[rbx], al
    mov edx, r15d
    mov rsi, r14
    call permutations

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
    add rsp, stack_perm
    pop rbx
    pop rbp
    pop r12
    pop r13
    pop r14
    pop r15
    ret

; Print permutation and return
.print:
    add rsp, stack_perm
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


;
; Data
;

section .data

request_uri:    db `REQUEST_URI\0`

response_head:  db `Content-type: text/html\r\n\r\n`, \
                   `<!DOCTYPE html>\n`, \
                   `<html lang="en">\n<head>\n`, \
                   `<meta charset="utf-8">\n`, \
                   `<meta http-equiv="X-UA-Compatible" content="IE=edge">\n`, \
                   `<title>AsmGrm</title>\n`, \
                   `<meta name="description" content="">\n`, \
                   `<meta name="viewport" content="width=device-width, initial-scale=1">\n`, \
                   `<style type="text/css">\n`, \
                   `html { font-family: Georgia,Cambria,"Times New Roman",Times,serif; font-size: 2em; }\n`, \
                   `h1 { margin: 20px; }\n`, \
                   `h1 a { color: black; text-decoration: none; }\n`, \
                   `p { float: left; margin: 5px 20px; }\n`, \
                   `small { float: right; padding: 20px; font-size: 0.5em; }\n`, \
                   `</style>\n</head>\n<body>\n`, \
                   `<h1><a href="/">AsmGrm</a></h1>\n\0`

response_foot:  db `</body>\n</html>\n\0`

response_home:  db `<p>Find anagrams by entering a word into the URL (maximum 6 characters). `, \
                   `Why not try <a href="/apes">apes</a>, <a href="/pandas">pandas</a> `, \
                   `or <a href="/zebras">zebras</a>?<p>\n\0`

response_error: db `Status: 500\r\nContent-type: text/plain\r\n\r\nAn error occured :(\n\0`

perm_fmt:       db `<p>%s</p>\n\0`
time_fmt:       db `<small>%ldns</small>\n\0`
