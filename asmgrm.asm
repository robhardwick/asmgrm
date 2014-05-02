; AsmGrm
;
; Copyright (C) 2014 Rob Hardwick

; fcgiapp.h
extern FCGX_Accept

; response.asm
extern asmgrm_response

; Stack
%define start_in    0   ; FCGX_Stream *
%define start_out   8   ; FCGX_Stream *
%define start_err   16  ; FCGX_Stream *
%define start_envp  24  ; FCGX_ParamArray
%define start_stack 32


;
; Code
;

section .text
    global _start

_start:
    sub rsp, start_stack

; Start accept loop
.accept:
    lea rcx, [rsp+start_envp]
    lea rdx, [rsp+start_err]
    lea rsi, [rsp+start_out]
    lea rdi, [rsp+start_in]
    call FCGX_Accept
    test eax, eax
    js .quit

; Ouput response
    mov rsi, qword[rsp+start_envp]
    mov rdi, qword[rsp+start_out]
    call asmgrm_response
    jmp .accept

; Exit app
.quit:
    xor eax, eax
    add rsp, start_stack
    ret
