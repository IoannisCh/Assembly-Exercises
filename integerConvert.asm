;Data declarations

section .data 


NULL            equ     0
EXIT_SUCCESS    equ     0
SYS_exit        equ     60

intNum          dd    1498

section      .bss
strNum          resb 10

section     .text
global  _start
_start:

mov     eax, dword [intNum]
mov     rcx, 0
mov     rbx, 10

divideLoop:
mov     rdx, 0
div     rbx 

push    rdx 
inc     rcx  
cmp     rax, 0  
jne     divideLoop  


popLoop:
pop     rax   

add     al, "0"

mov     [strNum+rdi], al 
inc     rdi  
loop    popLoop   

mov     byte [strNum+rdi], NULL  

last:
mov     rax, SYS_exit
mov     rdi, EXIT_SUCCESS 
syscall  