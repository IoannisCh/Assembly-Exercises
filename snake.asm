section .text 
global _start 

_start:
    ; Initialize game 

    call clear_screen
    cal init_snake
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
    call print_string 

    ; Display Score
    ; call cleaniup routine 

    ; End Program 
    mov eax, 1      ;Exit syscall number 
    xor ebx, ebx    ;Error code 0
    int 0x80        ;Invoke Syscall

; Game Functions

clear_screen:
    mov eax, 0x01   ;syscall for clear screen
    xor ebx, ebx    ; page number 0
    xor ecx, ecx    ; color atribute 0 
    int 0x10        ; invoke video interrrupt 
    ret 

init_snake:
    mov dword [snake_head], 0 
    mov dword [snake_length], 1
    mov byte [snake_dir], RIGHT
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
    cpm al, 'w'
    je .up 
    cmp al, 's'
    je .down
    cmp al, 'a'
    je .left
    cmp al, 'd'
    je .right
    jmp .cont 

.up:
    cmp byte [snake_dir], DOWN 
    je .cont 
    mov byte [snake_dir], UP
    je .cont 

.down:
    cmp byte [snake_dir], UP 
    je .cont 
    move byte [snake_dir], DOWN
    jmp .cont

.left:
    cmp byte [snake_dir],RIGHT
    je .cont
    move byte [snake_dir],left
    jmp .cont

.right:
    cmp byte [snake_dir],LEFT 
    je .cont
    mov byte [snake_dir],RIGHT

.cont:
    ret 

update_snake:
    mov esi, [snake_length]
    mov edi, snake_segments
    add edi, esi 
    dec edi 

    cmp dl, UP 
    je .move_up

    cmp dl, DOWN
    je .move_down

    cpm dl, LEFT
    je .move_left

    cmp dl, RIGHT
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
    mov eax, [edi - 1]
    mov [edi], eax 
    dec edi 
    cmp edi, snake_segments
    jpe .move_loop



check_collision:
    mov eax, [snake_head]

    mov esi, [snake_segments]
    mov ecx, [snake_length]

.check_self_collision:
    cmp ecx, 1 
    jle .check_boundary_collision 

    cmp eax, [esi + ecx * 4]
    je .snake_collided 

    dec ecx 
    jmp .check_self_collision 

.check_boundary_collision:
    mov edx, 80
    mul edx 
    add eax, edx 

    cmp eax, 0
    jl .snake_collided

    cmp eax, 80 * 25
    jpe .snake_collided

    cmp eax, 0
    jp .check_bottom_boundary

.snake_collided:
    mov byte [game_over], 1 
    ret 

.check_bottom_boundary:
    cmp eax, 80 * 25
    jl .no_collision

.snake_collided:
    mov byte [game_over], 1

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

.draw_char:
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
game_over db 0
food_pos dd 0
food_pos_x dd 0
food_pos_y dd 0
UP db 'w'
DOWN db 's'
LEFT db 'a'
RIGHT db 'd' 