segment code
..start:
    mov 	ax,data
    mov 	ds,ax
    mov 	ax,stack
    mov 	ss,ax
    mov 	sp,stacktop
	XOR 	AX, AX
    MOV 	ES, AX
    MOV     AX, [ES:intr*4];carregou AX com offset anterior
    MOV     [offset_dos], AX        ; offset_dos guarda o end. para qual ip de int 9 estava apontando anteriormente
    MOV     AX, [ES:intr*4+2]     ; cs_dos guarda o end. anterior de CS
    MOV     [cs_dos], AX
    CLI     
    MOV     [ES:intr*4+2], CS
    MOV     WORD [ES:intr*4],relogio
    STI
    jmp     desenhar_tela

print_string:
    mov ah, 02h
    mov bh, 0
    int 10h
    mov ah, 0Eh
.print_char:
    lodsb
    cmp al, 0
    je .done
    int 10h
    jmp .print_char
.done:
    ret

desenhar_tela:
    mov ah, 06h
    xor al, al            ; AL = 0 (scroll entire window)
    mov bh, 07h           ; BH = attribute (black background, white foreground)
    xor cx, cx            ; CH = 0, CL = 0 (start at upper left corner)
    mov dh, 18h           ; DH = 24 (bottom row)
    mov dl, 4Fh           ; DL = 79 (rightmost column)
    int 10h

    mov si, msg_title
    mov dh, 1
    mov dl, 11
    call print_string

    mov si, msg_menu
    mov dh, 14
    mov dl, 32
    call print_string

    mov si, msg_q
    mov dh, 16
    mov dl, 36
    call print_string

    mov si, msg_s
    mov dh, 17
    mov dl, 13
    call print_string

    mov si, msg_m
    mov dh, 18
    mov dl, 13
    call print_string

    mov si, msg_h
    mov dh, 19
    mov dl, 15
    call print_string

l1:
    cmp 	byte [tique], 0
	jne 	ab
	call 	converte
ab: mov 	ah,0bh		
    int 	21h			; Le buffer de teclado
    cmp 	al,0
    jne 	pressionado
    jmp 	l1
pressionado:
    call    limpar_input_invalido
    mov     ah, 08h
    int     21h
    cmp     al, 'q'
    je      fim
    cmp     al, 's'
    je      tecla_segundo
    cmp     al, 'm'
    je      tecla_minuto
    cmp     al, 'h'
    je      tecla_hora
    jmp     l1

fim:
	CLI
    XOR     AX, AX
    MOV     ES, AX
    MOV     AX, [cs_dos]
    MOV     [ES:intr*4+2], AX
    MOV     AX, [offset_dos]
    MOV     [ES:intr*4], AX 
    MOV     AH, 4Ch
    int     21h

tecla_segundo:
    mov     ah, 08h
    int     21h
    cmp     al, '0'
    jl      input_invalido
    cmp     al, '5'
    jg      input_invalido
    sub     al, '0'
    mov     bh, 10
    mul     bh
    mov     bh, al
    mov     ah, 08h
    int     21h
    cmp     al, '0'
    jl      input_invalido
    cmp     al, '9'
    jg      input_invalido
    sub     al, '0'
    add     al, bh
    mov     byte[segundo], al
    jmp     l1

tecla_minuto:
    mov     ah, 08h
    int     21h
    cmp     al, '0'
    jl      input_invalido
    cmp     al, '5'
    jg      input_invalido
    sub     al, '0'
    mov     bh, 10
    mul     bh
    mov     bh, al
    mov     ah, 08h
    int     21h
    cmp     al, '0'
    jl      input_invalido
    cmp     al, '9'
    jg      input_invalido
    sub     al, '0'
    add     al, bh
    mov     byte[minuto], al
    jmp     l1

tecla_hora:
    mov     ah, 08h
    int     21h
    cmp     al, '0'
    jl      input_invalido
    cmp     al, '2'
    jg      input_invalido
    sub     al, '0'
    mov     bh, 10
    mul     bh
    mov     bh, al
    mov     ah, 08h
    int     21h
    cmp     al, '0'
    jl      input_invalido
    cmp     al, '9'
    jg      input_invalido
    sub     al, '0'
    add     al, bh
    cmp     al, 23
    jg      input_invalido
    mov     byte[hora], al
    jmp     l1

input_invalido:
    mov si, msg_error
    mov dh, 10
    mov dl, 32
    call print_string
    jmp     l1

limpar_input_invalido:
    mov si, msg_clear
    mov dh, 10
    mov dl, 32
    call print_string
    ret

relogio:
	push	ax
	push	ds
	mov     ax,data	
	mov     ds,ax	
    
    inc	byte [tique]
    cmp	byte[tique], 18	
    jb		Fimrel
	mov byte [tique], 0
	inc byte [segundo]
	cmp byte [segundo], 60
	jb   	Fimrel
	mov byte [segundo], 0
	inc byte [minuto]
	cmp byte [minuto], 60
	jb   	Fimrel
	mov byte [minuto], 0
	inc byte [hora]
	cmp byte [hora], 24
	jb   	Fimrel
	mov byte [hora], 0	
Fimrel:
    mov		al,20h
	out		20h,al
	pop		ds
	pop		ax
	iret
	
converte:
    push 	ax
	push    ds
	mov     ax, data
	mov     ds, ax
	xor 	ah, ah
	MOV     BL, 10
	mov 	al, byte [segundo]
    DIV     BL
    ADD     AL, 30h                                                                                          
    MOV     byte [horario+6], AL
    ADD     AH, 30h
    mov 	byte [horario+7], AH
    
	xor 	ah, ah
	mov 	al, byte [minuto]
    DIV     BL
    ADD     AL, 30h                                                                                          
    MOV     byte [horario+3], AL
    ADD     AH, 30h
    mov 	byte [horario+4], AH
	
	xor 	ah, ah
	mov 	al, byte [hora]
    DIV     BL
    ADD     AL, 30h                                                                                          
    MOV     byte [horario], AL
    ADD     AH, 30h
    mov 	byte [horario+1], AH

    mov ah, 02h
    mov bh, 0
    mov dh, 8
    mov dl, 36
    int 10h

	mov 	ah, 09h
	mov 	dx, horario
	int 	21h

	pop     ds
	pop     ax
	ret  

segment data
	eoi     	EQU 20h
    intr	   	EQU 08h
	char		db	0
	offset_dos	dw	0
	cs_dos		dw	0
	tique		db  0
	segundo		db  0
	minuto 		db  0
	hora 		db  0
	horario		db  0,0,':',0,0,':',0,0,' ', 13,'$'
    msg_title db 'TL_2024/1, Breno Uliana de Angelo, Sistemas Embarcados I.', 0
    msg_menu db 'Menu de teclas:', 0
    msg_q db 'q: sair', 0
    msg_s db 's: para o contador dos segundos e aguarda novo valor.', 0
    msg_m db 'm: para o contador dos minutos e aguarda novo valor.', 0
    msg_h db 'h: para o contador das horas e aguarda novo valor.', 0
    msg_error db 'Input Invalido!', 0
    msg_clear times 60 db ' '
    db 0

segment stack stack
    resb 256
stacktop:
