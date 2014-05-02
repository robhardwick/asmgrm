; AsmGrm
;
; Copyright (C) 2014 Rob Hardwick

; string.h
extern strlen

; time.h
extern clock_gettime
%define tv_nsec                     8   ; struct timespec -> long int tv_nsec
%define CLOCK_PROCESS_CPUTIME_ID    2

; fcgiapp.h
extern FCGX_GetParam
extern FCGX_FPrintF
extern FCGX_PutS

; permutations.asm
extern asmgrm_permutations

; Constants
%define MAX_LENGTH  6

; Stack
%define response_out    0   ; FCGX_Stream *
%define response_envp   8   ; FCGX_ParamArray
%define response_start  24  ; struct timespec
%define response_end    40  ; struct timespec
%define response_stack  56


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
    time_fmt:       db `<small>%ldns</small>\n\0`


;
; Code
;

section .text
    global asmgrm_response

asmgrm_response:
    sub rsp, response_stack

; Setup stack
    mov qword[rsp+response_out], rdi
    mov qword[rsp+response_envp], rsi

; Get request URI
    mov rsi, qword[rsp+response_envp]
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
    jmp .response

; Check length > 1
.minlen:
    test rbx, rbx
    je .home

; Print permutations header
.response:
    mov rsi, qword[rsp+response_out]
    mov edi, response_head
    call FCGX_PutS

; Get start time
    lea rsi, [rsp+response_start]
    mov edi, CLOCK_PROCESS_CPUTIME_ID
    call clock_gettime

; Print permutations
    mov rdi, qword[rsp+response_out]
    mov ecx, ebx
    xor edx, edx
    mov rsi, r14
    call asmgrm_permutations

; Get end time
    lea rsi, [rsp+response_end]
    mov	edi, CLOCK_PROCESS_CPUTIME_ID
    call clock_gettime

; Calculate elapsed time
    mov rdx, qword[rsp+response_end+tv_nsec]
    sub rdx, qword[rsp+response_start+tv_nsec]

; Print elapsed time
    mov esi, time_fmt
    mov rdi, qword[rsp+response_out]
    xor	eax, eax
    call FCGX_FPrintF

; Print permutations footer
    mov rsi, qword[rsp+response_out]
    mov edi, response_foot
    call FCGX_PutS
    jmp .ret

; Print home page header
.home:
    mov rsi, qword[rsp+response_out]
    mov edi, response_head
    call FCGX_PutS

; Print home page
    mov rsi, qword[rsp+response_out]
    mov edi, response_home
    call FCGX_PutS

; Print home page footer
    mov rsi, qword[rsp+response_out]
    mov edi, response_foot
    call FCGX_PutS
    jmp .ret

; Print error page
.error:
    mov rsi, qword[rsp+response_out]
    mov edi, response_error
    call FCGX_PutS

.ret:
    xor eax, eax
    add rsp, response_stack
    ret
