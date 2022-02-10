section .data

EXIT_SUCCESS equ 0
SYS_exit equ 60

aSides  db  10,     14,     13,     37,     34
        db  31,     13,     20,     61,     36
        db  14,     53,     44,     19,     42
        db  27,     41,     53,     62,     10
        db  19,     18,     14,     10,     15
        db  15,     11,     22,     33,     70
        db  15,     23,     15,     63,     26
        db  24,     33,     10,     61,     15
        db  14,     34,     13,     71,     81
        db  38,     13,     29,     17,     93

aSides  dw  1233,   1114,   1773,   1131,   1675
        dw  1164,   1973,   1974,   1123,   1156
        dw  1344,   1752,   1973,   1142,   1456
        dw  1165,   1754,   1273,   1175,   1546
        dw  1153,   1673,   1453,   1567,   1535
        dw  1144,   1579,   1764,   1567,   1535
        dw  1456,   1563,   1564,   1753,   1165
        dw  1646    1862,   1457,   1167,   1534
        dw  1867,   1864,   1757,   1755,   1453
        dw  1863,   1673,   1275,   1756,   1353

heights dd 14145,   11134,  15123,  15123,  14123
        dd 18454,   15454,  12156,  12164,  12542
        dd 18453,   18453,  11184,  15142,  12354
        dd 14564,   14134,  12156,  12344,  13142
        dd 11153,   18543,  17156,  12352,  15434
        dd 18455,   14134,  12123,  15324,  13453
        dd 11134,   13134,  15156,  15234,  17142
        dd 19567,   14134,  12134,  17546,  16123
        dd 11134,   14134,  14576,  15457,  17142
        dd 13153,   11153,  12184,  15457,  17142

length  dd 50

taMin   dd 0
taMax   dd 0
taSum   dd 0
taAve   dd 0

volMin  dd 0
volMax  dd 0
volSum  dd 0
volAve  dd 0


ddTwo   dd 2
ddThree dd 3

section .bss
totalAreas  resd    50
volumes     resd    50

section .text
global _start
_start:


    mov     ecx, dword [length]
    mov     rci, 0

calculationLoop:

    movzx   r8d, byte [aSides+rsi]
    movzx   r9d, word [aSides+rsi*2]
    mov     eax, r8d
    mul dword [ddTwo]
    mul r9d
    mul r8d
    mov dword [totalAreas+rsi*4],   eax


    movzx   eax, byte [aSides+rsi]
    mul     eax
    mul     dword [heights+rsi*4]
    div     dword [ddThree]
    mov     dword [volumes+rsi*4], eax

    inc rsi
    loop calculationLoop


    mov     eax, dword [totalAreas]
    mov     dword [taMin], eax
    mov     dword [taMax], eax

    mov     eax, dword [volumes]
    mov     dword [volMin], eax
    mov     dword [volMax], eax

    mov     dword [taSum], 0
    mov     dword [volSum], 0

    mov     ecx, dword [length]
    mov     rsi, 0

statsLoop:
    mov     eax, dword [totalAreas+rsi*4]
    add     dword [taSum],  eax

    cmp     eax, dword [taMin]
    jae     notNewTaMin
    mov     dword [taMin],  eax

notNewTaMin:
    cmp     eax, dword [taMax]
    jbe     notNewTaMax
    mov     dword [taMax],  eax

notNewTaMax:
    mov     eax, dword [volumes+rsi*4]
    add     dword [volSum], eax
    cmp     eax, dword [volMin]
    jae     notNewVolMin
    mov     dword [volMin], eax

notNewVolMin:
    cmp     eax, dword [volMax]
    jbe     notNewVolMax
    mov     dword [volMax], eax

notNewVolMax:
    inc     rsi
    loop    statsloop


    mov     eax, dword [taSum]
    mov     edx, 0
    div     dword [length]
    mov     dword [taAve], eax

    mov     eax, dword [volSum]
    mov     edx, 0
    div     dword [length]
    mov     dword [volAve], eax

last:
    mov     rax, SYS_exit
    mov     rdi, EXIT_SUCCESS
    syscall

