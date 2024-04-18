section .text 
global _start 

extern print_string 
extern draw_char 

_start:
    ; Initialize game 

    call clear_screen
    call init_snake
    call place_food

game_loop:
    ; Game logic

    call read_input 
    call update_snake
    call check_collision
    call draw 

    ; Delay for gameplay improvement
    call delay 

    cmp byte [game_over], 1 
    je game_over_message 

    jmp game_loop 

game_over_message:
    ; Display Game Over message
    call clear_screen 
    mov edx, game_over_message

    ; Display Score
    ; call cleaniup routine 

    ; End Program 
    mov eax, 1      ;Exit syscall number 
    xor ebx, ebx    ;Error code 0
    int 0x80        ;Invoke Syscall

; Game Functions

clear_screen:

    mov ah, 0x06 
    mov al, 0x00 
    mov bh, 0x07 
    mov cx, 0x0000
    mov dx, 0x184F
    int 0x10 
    ret 

init_snake:
    mov dword [snake_head], 0 
    mov dword [snake_length], 1
    mov byte [snake_dir], 0x04
    ret 

place_food:
    mov ah, 0x2C
    int 0x21
    movzx ecx, cx 
    mov eax, ecx 

    xor edx, edx 
    mov ecx, 80 
    div ecx 
    mov byte [food_pos_x], al 

    xor edx, edx 
    mov ecx, 25 
    div ecx 
    mov byte [food_pos_y], al 

    ret 

read_input:
    mov ah, 0
    int 0x16
    cmp al, 'w'
    je .up 
    cmp al, 's'
    je .down
    cmp al, 'a'
    je .left
    cmp al, 'd'
    je .right
    jmp .cont 

.up:
    cmp byte [snake_dir], 0x02
    je .cont 
    mov byte [snake_dir], 0x01
    je .cont 

.down:
    cmp byte [snake_dir], 0x01
    je .cont 
    mov byte [snake_dir], 0x02
    jmp .cont

.left:
    cmp byte [snake_dir], 0x04
    je .cont
    mov byte [snake_dir], 0x03
    jmp .cont

.right:
    cmp byte [snake_dir], 0x03
    je .cont
    mov byte [snake_dir], 0x04

.cont:
    ret 

update_snake:
    mov esi, [snake_length]
    mov edi, snake_segments
    add edi, esi 
    dec edi 

    cmp dl, 0x01 
    je .move_up

    cmp dl, 0x02
    je .move_down

    cmp dl, 0x03
    je .move_left

    cmp dl, 0x04
    je .move_right

.move_up:
    sub eax, 80
    jmp .update_done

.move_down:
    add eax, 80
    jmp .update_done

.move_left:
    dec eax
    jmp .update_done

.move_right:
    inc eax

.update_done:
    mov [snake_head], eax 

.move_loop:
    dec esi 
    test esi, esi 
    jz .move_loop_exit 

    mov edx, [edi - 1]
    mov [edi], edx 
    dec edi 

    jmp .move_loop 

.move_loop_exit:
    ret 

check_collision:
    mov eax, [snake_head]

    mov esi, [snake_segments]
    mov ecx, [snake_length]

.check_self_collision:
    cmp ecx, 1 
    jle .check_boundary_collision 

    mov eax, [esi + ecx * 4]
    cmp eax, edx 
    je .snake_collided 

    dec ecx 
    jmp .check_self_collision 

.check_boundary_collision:
    movzx edx, byte [food_pos_x]
    imul edx, edx, 80
    

    cmp eax, 0
    jl .snake_collided

    movzx ebx, byte [food_pos_x]
    movzx ecx, byte [food_pos_y]
    imul ebx, ebx, 80
    add ecx, ebx
    cmp eax, ecx
    jge .snake_collided

    cmp eax, 0
    jp .check_bottom_boundary

    jmp .no_collision

.snake_collided:
    mov byte [game_over], 1 
    ret 

.check_bottom_boundary:
    movzx edx, byte [food_pos_x]
    imul edx, edx, 80
    add edx, 25
    cmp eax, edx
    jl .snake_collided

.no_collision:
    ret 

draw:
    call clear_screen

    mov esi, [snake_segments]
    mov ecx, [snake_length]

.draw_snake:
    mov eax, [esi + ecx + 4]
    call draw_char 
    dec ecx 
    jnz .draw_snake

    mov eax, [food_pos_x]
    mov ebx, [food_pos_y]
    call draw_char 

    ret 

draw_char:
    push eax 
    push ebx

    mov ah, 0x0E
    mov bh, 0 
    mov bl, 0x07

    add eax, 0x0020
    mov al, byte [eax]
    mov bh, 0 
    mov cx, 1 
    int 0x10 

    pop ebx 
    pop eax 
    ret 

delay:
    mov ecx, 1000000

.delay_loop:
    dec ecx 
    jnz .delay_loop 

    ret 


; Data section
section .data 
    game_over_msg db "Game Over", 0
    game_over db 0 
    snake_head dd 0
    snake_length dd 0
    snake_dir dd 0
    snake_segments dd 100 dup(0)
    food_pos dd 0
    food_pos_x dd 0
    food_pos_y dd 0
    UP db 'w'
    DOWN db 's'
    LEFT db 'a'
    RIGHT db 'd' 






    print_newline:
    mov eax, 0x0A0D
    mov ebx, 1
    mov ecx, eax
    mov edx, 2
    int 0x80
    ret

print_hex:
    push eax
    push ebx
    push ecx
    push edx

    mov eax, ebx
    mov ecx, 16
    mov ebx, 0
    mov edx, 0

.next_digit:
    mov edx, eax
    and edx, 0x0F
    add dl, '0'
    cmp dl, '9'
    jbe .skip_alpha
    add dl, 7

.skip_alpha:
    mov [esp], dl
    mov eax, 4
    mov ebx, 1
    lea ecx, [esp]
    int 0x80

    shr ebx, 4
    test ebx, ebx
    jnz .next_digit

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

print_string:
    push eax
    push ebx
    push ecx
    push edx

    mov eax, 4
    mov ebx, 1
    lea ecx, [esp + 16]
    mov edx, 4
    int 0x80

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
