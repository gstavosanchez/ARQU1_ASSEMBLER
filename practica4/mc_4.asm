; =============== IMPRIMIR EN PANTALLA ======================
m_print macro string
    mov ah,09h; (09h) Visualizar cadena en pantalla
    lea dx,OFFSET  string ; cambiar
    int 21h
endm
m_clean_screen macro
    mov ah,0fh
    int 10h
    mov ah,0
    int 10h
endm
; ===================================== PAUSE PANTALLA =====================================
m_pause macro
    mov ah,7; Sirve para hacer una pausa al sistema, vuelve funcionar press cualquier tecla
    int 21h
endm
; ===================================== GUARDAR CARACTER =====================================
; Guarda un carcter y lo almecana en la variable opcion
m_save_char macro
    m_print msg_opcion
    mov ah,01h ; instruccion para guardar un carecter
    int 21h
    mov opcion,al ; se mueve a opcion lo que esta en al
    ; Operacion se guarda en la variable opcion
endm

; ===================================== LEER ARCHIVO ====================================
m_open_file macro file_name,handler_file
    local error_open,open_xml,exit_open
    open_xml:
        MOV ah, 3dh
        MOV al, 02h     ; file mode
        LEA dx, file_name
        INT 21h
        jc error_open
        MOV handler_file, ax     ; In AX return the handler
    jmp exit_open
    error_open:
        m_print msg_error_open
        ;m_print msg_space
        m_pause
        m_back_main_menu
    exit_open:

endm
m_read_file macro buffer,handler_file
    MOV ah, 3fh
    MOV bx, handler_file
    MOV cx, SIZEOF buffer
    LEA dx, buffer
    INT 21H
endm
m_close_file macro handler_file
    mov ah,3eh
    mov bx,handler_file
    int 21h
endm
getChar macro
    MOV AH, 01h
    INT 21H
endm
; ===================================== GUARDAR CADENA =====================================
; Guarda una cadena que se pidio en consola se almena en la variable "buffer_read"
m_save_string macro buffer
    LOCAL ObtenerChar, FinOT
    XOR si, si
    m_print msg_opcion
    ObtenerChar:
        getChar
        CMP AL, 0dh
        JE FinOT
        MOV buffer[si], al
        inc si
    jmp ObtenerChar
    FinOT:
    MOV al, 00h
    MOV buffer[si], al
endm
; ===================================== ANALIZADOR =====================================
m_get_number_list macro array_list
    local start,save_,start_save,final_save,final
    xor si,si
    xor di,di
    xor bx,bx ; limpiar variables contadores
    xor ax,ax ; limpiar variables contadores
    start:
        cmp array_list[si],24h; if (array[i] == '$')
        je final
        cmp array_list[si],3eh; if (array[i] == '>')
        je save_
        inc si
    jmp start
    save_:
        inc si
        cmp array_list[si],24h; if (array[i] == '$')
        je start
        cmp array_list[si],0dh; if (array[i] == '\n') -> salto de linea
        je start
    jmp start_save
    start_save:
        cmp array_list[si],3ch; if (array[i] == '<')
        je final_save
        mov al,array_list[si]
        mov number_list[di],al
        inc si
        inc di
    jmp start_save
    final_save:
        mov number_list[di],20h; Agregar un espacio
        inc di
    jmp start

    final:


endm
; ========================== GUARDAR EN ARREGLO ===================
; PARAM array donde se encuentra los valores
; Gurada en el arreglo number_array
m_set_number_array macro array
    local cycle,end_cycle,start_save,final_save
    push bx
    push cx
    push dx
    push si

    ;Limpiando los registros AX, BX, CX, SI
    xor ax, ax
    xor bx,bx
    xor dx, dx
    xor si, si

    mov flag,0d; regresa a su estado inicial
    mov si,0000h; Lleva el contro del array de string
    mov di,0000h; lleva el contro del aux
    cycle:
        cmp array[si],24h; if(array[i] == '$')
        jz end_cycle
    jmp start_save


    start_save:
        cmp array[si],20h ; if (array[i] == ' ')
        jz final_save
        mov al,array[si]
        mov aux_number[di],al
        inc si
        inc di
    jmp start_save

    final_save:
        ; == GUARDAR EN ARREGLO ==
        mov ax,flag
        add ax,bx
        mov bx,ax

        m_str_to_int aux_number ; Se convierte el texto en numero
        mov number_array[bx], al; se mueve a number_array[bx], lo que esta en ax(numero)

        ;m_print msg_opcion
        ;m_print aux_number
        m_clean_str aux_number
        ; == =================== ==
        mov di,0000h;
        inc si
        inc flag; se incrementa el contador del array de numeros
        mov bx,0000h
    jmp cycle
    end_cycle:
        pop si
        pop dx
        pop cx
        pop bx
        ;mov flag,0d
        m_copy_array number_array, init_array_number

endm
; =========== CONVIERTE UNA CADENA A NUMERO, ESTE SE GUARDA EN "AX" =============
m_str_to_int macro numStr
    local ciclo, salida, chkNeg, cfgNeg, signoN
        push bx
        push cx
        push dx
        push si
        ;Limpiando los registros AX, BX, CX, SI
        xor ax, ax
        xor bx,bx
        xor dx, dx
        xor si, si
        mov bx, 000Ah	;multiplicador 10
        ciclo:
            mov cl, numStr[si]
            inc si
            cmp cl, 2Dh ;Si se trata de el signo menos de la cadena 'numero', lo ignoramos
            jz ciclo    ;Se ignora el simbolo '-' del número
            cmp cl, 30h ;Si el caracter es menor a '0', se procede a la verificación de numeros negativos
            jb chkNeg
            cmp cl, 39h ;Si el caracter es mayor a '9',se procede a la verificación de numeros negativos
            ja chkNeg
            sub cl, 30h	;Se le resta el ascii '0' para obtener el número real
            mul bx      ;multplicar ax por
            mov ch, 00h
            add ax, cx  ;sumar lo que tengo mas el siguiente
            jmp ciclo
        cfgNeg:
            neg ax ;Aqui se niega el numero resultante
            jmp salida
        chkNeg:;Verificacion
            cmp numStr[0], 2Dh;Si existe un signo al inicio del numero, negamos el numero
            jz cfgNeg
        salida:
            ;Restaurando los registros AX, BX, CX, SI
            pop si
            pop dx
            pop cx
            pop bx

endm
; ==================================== INT TO STRING ==============================
m_int_to_str macro numStr
    local div10, signoN, unDigito, jalar
    ;Realizando backup de los registros BX, CX, SI
    push ax
    push bx
    push cx
    push dx
    push si
    xor si,si
	xor cx,cx
	xor bx,bx
	xor dx,dx
	mov bx,0ah; Divisor: 10
	test ax,1000000000000000 ;Se verifica que el bit mas significativo sea negativo
	jnz signoN
    unDigito:
        cmp ax, 0009h
        ja div10
        mov numStr[si], 30h; Se agrega un CERO para que sea un numero de dos digitos
        inc si
	    jmp div10
	signoN:;Aqui se cambia de signo
  		neg ax; Se niega el numero para que sea positivo
  		mov numStr[si], 2dh; Se agrega el signo negativo a la cadena de salida
  		inc si
  		jmp unDigito
    div10:
      xor dx, dx; Se limpia el registro DX; Este simulará la parte alta del registro
      div bx ;Se divide entre 10
      inc cx ;Se incrementa el contador
      push dx ;Se guarda el residuo DX
      cmp ax,0h ;Si el cociente es CERO
      je jalar
	jmp div10
    jalar:
      pop dx; Obtenemos el top de la pila
      add dl,30h ;Se le suma '0' en su valor ascii
      mov numStr[si],dl; Metemos el numero al buffer de salida
      inc si
      loop jalar
      mov ah, '$'; Se agrega el fin de cadena
      mov numStr[si],ah
      ;Restaurando registros
      pop si
      pop dx
      pop cx
      pop bx
      pop ax
endm

m_clean_str macro string
    local RepeatLoop
    push cx
    push si

    xor si, si
    xor cx, cx
    mov cx, SIZEOF string

    RepeatLoop:
        mov string[si], 24h
        inc si
    Loop RepeatLoop
    pop si
    pop cx
endm
; ================================ PRINT ARRAY8 =========================
; imprime un salto de linea
m_salto macro
    MOV dl,10
    MOV ah,02h
    INT 21h
    MOV dl,13
    MOV ah,02h
    INT 21h
endm

m_print8 MACRO Regis
    LOCAL zero,noz

    MOV bx, 2
    XOR ax, ax
    MOV al, Regis
    MOV cx, 10

    zero:
        XOR dx, dx
        DIV cx
        PUSH dx
        DEC bx
        JNZ zero
        XOR bx, 2

    noz:
        POP dx
        ;PRINT_N dl
        m_print_n dl
        DEC bx
    JNZ noz
ENDM


m_print_array8 MACRO array, counter_size
    LOCAL cycle_show
    PUSH si

    XOR si, si
    cycle_show:
        PUSH si

        m_print8 array[si]
        m_salto
        POP si

        INC si
        CMP si, counter_size
    JNE cycle_show

    POP si
ENDM

m_print_n macro num
    local zero
    xor ax,ax
    mov dl,num
    add dl,48
    mov ah,02h
    int 21h
endm
; =========================== ORDENAMIENTO INSERSION ASCENDENTE =================================
; =========================== ORDENAMIENTO INSERSION ASCENDENTE =================================
; =========================== ORDENAMIENTO BURBUJA ASCENDENTE =================================
m_bubble_sort_asc macro speed_deley,type_sort,text_speed
    local cycle_for,cycle_for2,exit_for,exit_for2,continue_for2
    push ax
    push bx
    push dx

    ; ========== LIMPIAR VARIABLES =============
    xor ax,ax
    xor bx,bx
    xor dx,dx
    ; ========== ===== ======= ====== =============
    mov ax,flag
    mov bb_size,ax
    mov ax,bb_size
    ; == == == == == == == CICLO 1 == == == == == == ==
    cycle_for:
        ; == == IF (i < SIZE) == ==
        mov ax,b_i
        cmp ax,bb_size
        jge exit_for; ->> if ( i >= size) -> salir
        ; == == == == == == == == ==
        ;== == == CICLO 2 == == == ==
        cycle_for2:
            ; == == IF (J < size - i) == ==
            mov ax,bb_size ; size = size -1
            sub ax,1d; ax = size - i
            cmp b_j,ax; if
            jge exit_for2; if (j >= size - i) ->> salir
            ; == == == == == == == == == == ==
            ; == == IF (ARRAY[J ] > ARRAY[J +1 ]) == ==
            xor ax,ax
            xor bx,bx

            mov bx,b_j
            mov al,number_array[bx]; al = array[j]
            mov b_aux,ax; aux = array[j]

            xor ax,ax
            xor bx,bx

            inc b_j
            mov bx,b_j
            mov al,number_array[bx]; al = array[j + 1]
            mov b_temp,ax; temp = array [j + 1]
            dec b_j

            mov ax,b_aux; al = array[j]
            cmp ax,b_temp
            jle continue_for2; if (arra[j] < array[j + 1]) ->> Si es menor salirse(continuar)
            ; == == == == == == == == == == == == == ==
            ; == == == CAMBIO DE VALORES == == ==
            ; aux  = array[j]
            ; temp = array[j + 1]
            xor ax,ax
            xor bx,bx

            mov bx,b_j
            mov ax,b_temp
            mov number_array[bx],al; array[j] = array [j + 1]

            ; == == == GRAFICAR == == ==
            call INIT_VIDEO
                m_paint_number number_array
                m_paint_graph number_array,speed_deley,type_sort,text_speed
            call END_VIDEO
            ; == == == == == == == == ==

            xor ax,ax
            xor bx,bx

            inc b_j
            mov bx,b_j
            mov ax,b_aux
            mov number_array[bx],al; arra[j +1] = array[j]
            dec b_j
            ; == == == == == == == == == == == ==

            inc b_j

            ; == == == GRAFICAR == == ==
            call INIT_VIDEO
                m_paint_number number_array
                m_paint_graph number_array,speed_deley,type_sort,text_speed
            call END_VIDEO
            ; == == == == == == == == ==

        jmp cycle_for2
        ;== == == == == == == == == ==
    jmp cycle_for


    continue_for2:
        inc b_j
    jmp cycle_for2

    exit_for2:
        inc b_i
        mov b_j,0d
    jmp cycle_for
    exit_for:
        pop dx
        pop bx
        pop ax
endm
; =========================== ORDENAMIENTO INSERSION DESENDENTE =================================
m_bubble_sort_desc macro speed_deley,type_sort,text_speed
    local cycle_for,cycle_for2,exit_for,exit_for2,continue_for2
    push ax
    push bx
    push dx

    ; ========== LIMPIAR VARIABLES =============
    xor ax,ax
    xor bx,bx
    xor dx,dx
    ; ========== ===== ======= ====== =============
    mov ax,flag
    mov bb_size,ax

    mov ax,bb_size
    ; == == == == == == == CICLO 1 == == == == == == ==
    cycle_for:
        ; == == IF (i < SIZE) == ==
        mov ax,b_i
        cmp ax,bb_size
        jge exit_for        ; ->> if ( i >= size) -> salir
        ; == == == == == == == == ==
        ;== == == CICLO 2 == == == ==
        cycle_for2:
            ; == == IF (J < size - i) == ==
            mov ax,bb_size  ; size = size
            sub ax,1d       ; ax = size - i
            cmp b_j,ax      ; if
            jge exit_for2   ; if (j >= size - i) ->> salir
            ; == == == == == == == == == == ==
            ; == == IF (ARRAY[J ] > ARRAY[J +1 ]) == ==
            xor ax,ax
            xor bx,bx

            mov bx,b_j
            mov al,number_array[bx]     ; al = array[j]
            mov b_aux,ax                ; aux = array[j]

            xor ax,ax
            xor bx,bx

            inc b_j
            mov bx,b_j
            mov al,number_array[bx]     ; al = array[j + 1]
            mov b_temp,ax               ; temp = array [j + 1]
            dec b_j

            mov ax,b_aux                ; al = array[j]
            cmp ax,b_temp
            jge continue_for2           ; if (arra[j] > array[j + 1]) ->> Si es menor salirse(continuar)
            ; == == == == == == == == == == == == == ==
            ; == == == CAMBIO DE VALORES == == ==
            ; aux  = array[j]
            ; temp = array[j + 1]
            xor ax,ax
            xor bx,bx

            mov bx,b_j
            mov ax,b_temp
            mov number_array[bx],al     ; array[j] = array [j + 1]

            ; == == == GRAFICAR == == ==
            call INIT_VIDEO
                m_paint_number number_array
                m_paint_graph number_array,speed_deley,type_sort,text_speed
            call END_VIDEO
            ; == == == == == == == == ==

            xor ax,ax
            xor bx,bx

            inc b_j
            mov bx,b_j
            mov ax,b_aux
            mov number_array[bx],al       ; arra[j +1] = array[j]
            dec b_j
            ; == == == == == == == == == == == ==

            inc b_j

            ; == == == GRAFICAR == == ==
            call INIT_VIDEO
                m_paint_number number_array
                m_paint_graph number_array,speed_deley,type_sort,text_speed
            call END_VIDEO
            ; == == == == == == == == ==

        jmp cycle_for2
        ;== == == == == == == == == ==
    jmp cycle_for


    continue_for2:
        inc b_j
    jmp cycle_for2

    exit_for2:
        inc b_i
        mov b_j,0d
    jmp cycle_for
    exit_for:
        pop dx
        pop bx
        pop ax
endm
; =========================== ORDENAMIENTO SHELL ASCENDENTE =================================
m_shell_sort_asc macro speed_deley,type_sort,text_speed
    local cycle_for,cycle_for_2,cycle_for_3,exit_for,exit_for_2,exit_for_3,continue_for_3
    push ax
    push bx
    push dx
    ; ========== LIMPIAR VARIABLES =============
    xor ax,ax
    xor bx,bx
    xor dx,dx
    ; ========== ===== ======= ====== =============
    mov s_i,0d          ; i = 0
    mov s_j,0d          ; j = 0
    mov s_k,0d          ; k = 0
    mov ax,flag
    mov s_size,ax       ; size = flag
    ; == == == == == == == CICLO 1 == == == == == == ==
    mov ax,s_size       ; ax = size
    mov bx,2d;          ; bx = 2
    div bx              ; ax = size / 2
    mov s_i,ax          ; i = size / 2
    cycle_for:
        ; == == IF (i > 0) == ==
        cmp s_i,0d       ; if
        jle exit_for     ; if(i <= 0) ->> Salir del ciclo
        ; == == == == == == == ==
        ; == == INICIALIZACION C.2 == ==
        mov ax,s_i      ; ax = i
        mov s_j,ax      ; j = i
        ; == == == == == == == == ==  ==
        ; == == == == == == == CICLO 2 == == == == == == ==
        cycle_for_2:
            ; == == IF (j < size) == ==
            mov ax,s_size   ; ax = size
            cmp s_j,ax      ; if
            jge exit_for_2  ; if (s_j >= size) ->> salir
            ; == == == == == == == ==
             ; == == INICIALIZACION C.3 == ==
            mov ax,s_j      ; ax = j
            sub ax,s_i      ; ax = ax(j) - i
            mov s_k,ax      ; k = j - i
            ; == == == == == == == CICLO 3 == == == == == == ==
            cycle_for_3:
                ; == == IF (K >= 0) == ==
                cmp s_k,0d      ; if
                jl exit_for_3   ; if (k < 0 ) ->> salir
                ; == == == == == == == ==
                ; == == IF (ARRAY[K + I] < ARRAY[K]) == ==
                ; temp = array[k]
                ; aux = array [k + i]
                xor ax,ax
                xor bx,bx

                mov bx,s_k
                mov al,number_array[bx]     ; al = array[k]
                mov s_temp,ax               ; temp = array[k]

                xor ax,ax
                xor bx,bx

                mov ax,s_k                  ; ax = k
                add ax,s_i                  ; ax = k + i
                mov bx,ax                   ; bx = (k + i)

                xor ax,ax
                mov al,number_array[bx]     ; al = array[k + i]
                mov s_aux,ax                ; aux = array[k + 1]

                mov ax,s_aux                ; ax = aux
                cmp ax,s_temp               ; if
                jge continue_for_3          ; if (array[k + i] >= array[k]) ->> continuar otra iteracion
                ; == == == == == == == == == == == == == =
                ; == == == CAMBIO DE VALORES == == ==
                ; temp = array[k]
                ; aux = array [k + i]
                xor ax,ax
                xor bx,bx

                mov bx,s_k                  ; bx = k
                mov ax,s_aux                ; ax = aux
                mov number_array[bx],al     ; array[k] = aux

                ; == == == GRAFICAR == == ==
                call INIT_VIDEO
                    m_paint_number number_array
                    m_paint_graph number_array,speed_deley,type_sort,text_speed
                call END_VIDEO
                ; == == == == == == == == ==

                xor ax,ax
                xor bx,bx

                mov ax,s_k                  ; ax = k
                add ax,s_i                  ; ax = k + i
                mov bx,ax                   ; bx = (k + i)

                xor ax,ax
                mov ax,s_temp               ; ax = temp
                mov number_array[bx],al     ; array[k + i] = temp

                xor ax,ax
                xor bx,bx

                mov ax,s_k                  ; ax = k
                sub ax,s_i                  ; ax = ax - i
                mov s_k,ax                  ; k = k - i
                ; == == == == == == == == == == == ==
                ; == == == GRAFICAR == == ==
                call INIT_VIDEO
                    m_paint_number number_array
                    m_paint_graph number_array,speed_deley,type_sort,text_speed
                call END_VIDEO
                ; == == == == == == == == ==
            jmp cycle_for_3
        jmp cycle_for_2
    jmp cycle_for

    exit_for_2:
        xor ax,ax
        xor bx,bx
        xor dx,dx

        mov ax,s_i      ; ax = i
        mov bx,2d       ; bx = 2
        div bx          ; ax = ax / 2
        mov s_i,ax      ; i = i / 2
        ;mov s_j,0d      ; j = 0;
    jmp cycle_for
    exit_for_3:
        inc s_j         ; j++
        mov s_k,0d      ; k = 0
    jmp cycle_for_2
    continue_for_3:
        mov ax,s_k                  ; ax = k
        sub ax,s_i                  ; ax = ax - i
        mov s_k,ax                  ; k = k - i
    jmp cycle_for_3
    exit_for:
        pop dx
        pop bx
        pop ax


endm
; =========================== ORDENAMIENTO SHELL DESCENDENTE =================================
m_shell_sort_desc macro speed_deley,type_sort,text_speed
    local cycle_for,cycle_for_2,cycle_for_3,exit_for,exit_for_2,exit_for_3,continue_for_3
    push ax
    push bx
    push dx
    ; ========== LIMPIAR VARIABLES =============
    xor ax,ax
    xor bx,bx
    xor dx,dx
    ; ========== ===== ======= ====== =============
    mov s_i,0d          ; i = 0
    mov s_j,0d          ; j = 0
    mov s_k,0d          ; k = 0
    mov ax,flag
    mov s_size,ax       ; size = flag
    ; == == == == == == == CICLO 1 == == == == == == ==
    mov ax,s_size       ; ax = size
    mov bx,2d;          ; bx = 2
    div bx              ; ax = size / 2
    mov s_i,ax          ; i = size / 2
    cycle_for:
        ; == == IF (i > 0) == ==
        cmp s_i,0d       ; if
        jle exit_for     ; if(i <= 0) ->> Salir del ciclo
        ; == == == == == == == ==
        ; == == INICIALIZACION C.2 == ==
        mov ax,s_i      ; ax = i
        mov s_j,ax      ; j = i
        ; == == == == == == == == ==  ==
        ; == == == == == == == CICLO 2 == == == == == == ==
        cycle_for_2:
            ; == == IF (j < size) == ==
            mov ax,s_size   ; ax = size
            cmp s_j,ax      ; if
            jge exit_for_2  ; if (s_j >= size) ->> salir
            ; == == == == == == == ==
             ; == == INICIALIZACION C.3 == ==
            mov ax,s_j      ; ax = j
            sub ax,s_i      ; ax = ax(j) - i
            mov s_k,ax      ; k = j - i
            ; == == == == == == == CICLO 3 == == == == == == ==
            cycle_for_3:
                ; == == IF (K >= 0) == ==
                cmp s_k,0d      ; if
                jl exit_for_3   ; if (k < 0 ) ->> salir
                ; == == == == == == == ==
                ; == == IF (ARRAY[K + I] > ARRAY[K]) == ==
                ; temp = array[k]
                ; aux = array [k + i]
                xor ax,ax
                xor bx,bx

                mov bx,s_k
                mov al,number_array[bx]     ; al = array[k]
                mov s_temp,ax               ; temp = array[k]

                xor ax,ax
                xor bx,bx

                mov ax,s_k                  ; ax = k
                add ax,s_i                  ; ax = k + i
                mov bx,ax                   ; bx = (k + i)

                xor ax,ax
                mov al,number_array[bx]     ; al = array[k + i]
                mov s_aux,ax                ; aux = array[k + 1]

                mov ax,s_aux                ; ax = aux
                cmp ax,s_temp               ; if
                jle continue_for_3          ; if (array[k + i] <= array[k]) ->> continuar otra iteracion
                ; == == == == == == == == == == == == == =
                ; == == == CAMBIO DE VALORES == == ==
                ; temp = array[k]
                ; aux = array [k + i]
                xor ax,ax
                xor bx,bx

                mov bx,s_k                  ; bx = k
                mov ax,s_aux                ; ax = aux
                mov number_array[bx],al     ; array[k] = aux

                ; == == == GRAFICAR == == ==
                call INIT_VIDEO
                    m_paint_number number_array
                    m_paint_graph number_array,speed_deley,type_sort,text_speed
                call END_VIDEO
                ; == == == == == == == == ==

                xor ax,ax
                xor bx,bx

                mov ax,s_k                  ; ax = k
                add ax,s_i                  ; ax = k + i
                mov bx,ax                   ; bx = (k + i)

                xor ax,ax
                mov ax,s_temp               ; ax = temp
                mov number_array[bx],al     ; array[k + i] = temp

                xor ax,ax
                xor bx,bx

                mov ax,s_k                  ; ax = k
                sub ax,s_i                  ; ax = ax - i
                mov s_k,ax                  ; k = k - i
                ; == == == == == == == == == == == ==
                ; == == == GRAFICAR == == ==
                call INIT_VIDEO
                    m_paint_number number_array
                    m_paint_graph number_array,speed_deley,type_sort,text_speed
                call END_VIDEO
                ; == == == == == == == == ==
            jmp cycle_for_3
        jmp cycle_for_2
    jmp cycle_for

    exit_for_2:
        xor ax,ax
        xor bx,bx
        xor dx,dx

        mov ax,s_i      ; ax = i
        mov bx,2d       ; bx = 2
        div bx          ; ax = ax / 2
        mov s_i,ax      ; i = i / 2
        ;mov s_j,0d      ; j = 0;
    jmp cycle_for
    exit_for_3:
        inc s_j         ; j++
        mov s_k,0d      ; k = 0
    jmp cycle_for_2
    continue_for_3:
        mov ax,s_k                  ; ax = k
        sub ax,s_i                  ; ax = ax - i
        mov s_k,ax                  ; k = k - i
    jmp cycle_for_3
    exit_for:
        pop dx
        pop bx
        pop ax


endm
m_back_main_menu macro
    m_clean_screen
    m_print msg_back
    m_save_char

    ; =========== REGRESAR ===========
    cmp opcion,49; Si  presiona 1 salir
    je exit_main_menu; salir
    jmp main_menu
endm

; ============================================ DELEY  =================================
m_deley macro value ; Retardo
    local cycle_while,exit_while,cycle_while2
    push ax
    push bx

    xor ax,ax
    xor bx,bx

    mov ax,value
    cycle_while:
        dec ax
        jz exit_while
        mov bx,value

        cycle_while2:
            dec bx
        jnz cycle_while2

    jmp cycle_while

    exit_while:
        pop bx
        pop ax
endm
; ================================= ===== MODO VIDEO  =================================
; ================================= ===== =============================================

; ================================= ===== PINTAR PIXEL  =================================
; Pinta un pixel en pantalla
m_paint_pixel macro i,j,color; i(y) = fila, j(x) = columna
    push ax
    push bx
    push di

    xor ax,ax
    xor bx,bx
    xor di,di

    mov ax,320d
    mov bx,i
    mul bx
    add ax,j ; 320 * i + j
    mov di,ax
    mov [di],color

    pop di
    pop bx
    pop ax
endm
; ================================= ===== PINTAR MARCO  =================================
; Pinta un marco en pantalla
m_paint_frame macro left,right,up,down,color ; izquerda,derecha, arriba,abajo, color
    local while1, while2
    push si
    xor si,si

    mov si,left; Inicia en algun lugar de la izquierda
    while1:; Primer ciclo pinta las barras horizontales --  ->>(Indica el ancho)
        m_paint_pixel up,si,color; Pinta la barra horizonta de arriba
        m_paint_pixel down,si,color; Pinta la barra horizonta de abajo
        inc si
        cmp si,right; Termina en algun lugar de la deracha
    jne while1 ; si no es igual al final que hago lo de adentro !=

    xor si,si
    mov si,up; Inicia en algun lugar de arriba
    while2:; Segundo ciclo pinta las barras verticales | | ->> (Indica el alto)
        m_paint_pixel si,left,color; Pinta la barra vertical de la izquierda
        m_paint_pixel si,right,color; Pinta la barra vertical de la derecha
        inc si
        cmp si,down; Termina en algun lugar de la abajo
    jne while2 ; si no es igual al final que hago lo de adentro !=

    pop si

endm
; ================================= ===== PINTAR BARRA  =================================
m_paint_bar macro left,right,up,down,color ; izquierda = 150, derecha = 170, arriba  = 25, abajo = 160 color = azul (9)
    local while1, while2
    push cx ; controla el alto (columna)
    push si ; contrla el ancho (fila)

    xor cx,cx
    xor si,si

    mov si,left ;inicia en algun lugar de la izquierda
    while1:;Primer ciclo pinta las barras horizontales --  ->>(Indica el ancho)
        xor cx,cx
        mov cx,up ; Inicia en algun lugar de arriba

            while2: ;Segundo ciclo pinta las barras verticales | | ->> (Indica el alto)
                call DS_VIDEO
                    m_paint_pixel cx,si,color
                call DS_DATA
                inc cx
                cmp cx,down;Termina en algun lugar de la abajo
            jnz while2


        inc si
        cmp si,right ; Termina en algun lugar de la derecha
    jne while1

    push si
    push cx

endm

; ================================= ===== POSICIONAR EL CURSOR  =================================
; Imprime un mensaje en la posicion del curos que le indicamos
m_cursor_position macro row,column,msg_data ; fila = 20d; columna = 58d
    PUSH ax
    PUSH bx
    PUSH cx

    XOR ax, ax
    XOR bx, bx


    mov ah,02h
    mov bh,00h
    mov dh,row; 23 filas
    mov dl,column;118 columnas
    int 10h
    call DS_DATA
    m_print msg_data
    ;call DS_VIDEO

    POP cx
    POP bx
    POP ax
endm

m_paint_graph macro array,speed_deley,type_sort,text_speed
    local cycle_while,paint_others,exit_while__,paint_start,red_color,blue_color,yellow_color,green_color,white_color,pick_color,range_0_,range_1_2_,range_3_4_,range_5_6_,range_7_8_,range_9_,pick_speed_

    push bx
    push ax
    push dx
    push di
    push cx

    xor bx,bx
    xor ax,ax
    xor dx,dx
    xor di,di
    xor cx,cx; push y popo


    m_cursor_position 1d,3d,type_sort ;fila = 1d; columna = 2d ; IMPRIME TIPO DE ORDENAMIENTO
    call DS_VIDEO
    m_cursor_position 1d,22d,msg_velocity ;fila = 1d; columna = 2d ; IMPRIME 'VELOCIDAD'
    call DS_VIDEO
    m_cursor_position 1d,26d,text_speed ;fila = 1d; columna = 2d ; IMPRIME NO.VELOCIDAD '05'
    m_paint_frame 8d,309d,20d,180d,15d ; izquerda = 20; derecha = 299; arriba = 20 ; abajo = 180; color = blanco (15)
    call DS_DATA
        ; == == CALCULAR TAMAÑO == ==
        mov ax,299d
        mov bx,flag ; bx = tamaño arreglo
        div bx ; ax = 299 / (bx)
        sub ax,5d; ax = [299/size] -5
        mov paint_size,ax
        ; == == == == == == ==  == ==
        ;mov cx,0000h
        cycle_while:
            call DS_DATA
                cmp di,flag; if
                je exit_while__ ; if (cx == array.size) ->> Salir
                cmp di,0d ; if
                je paint_start ; if (cx == 0) ->> Salta a pintar inicio
        jmp paint_others

        paint_start:
            ; == == PINTAR INICIO BARRA == ==
            xor ax,ax
            xor bx,bx
            xor cx,cx
            mov paint_init,10d ; inicio = 10d
            mov ax,paint_size ; ax = tamaño
            add ax,paint_init; ax = tamaño + inicio
            mov paint_end,ax ; fin = tamaño + inicio

            ;mov ax,paint_init; ax = inicio
            ;mov bx,paint_end; bx = fin

            ; == ALTURA ==
            xor ax,ax
            xor dx,dx

            mov al,array[di] ; ax = array[i]
            mov paint_height,ax
            mov value_array,ax;; value = array[i]

            mov ax,paint_height
            mov bx,140d
            mul bx ; ax = 50*140
            mov paint_height,ax ; tamaño = 50 * 140

            mov ax,paint_height
            mov bx,100d
            div bx ; ax = (50 *140) / 100
            mov paint_height,ax ; tamaño = (50 *140) / 100

            mov ax,160d
            sub ax,paint_height
            mov paint_height,ax ; tamañp = 160 - (50 * 140)/100d

            ; == == ==  ==
            mov ax,paint_init; ax = inicio
            mov bx,paint_end; bx = fin
            ; == == == ==
            inc di
           ;== == SELECT COLOR == ==
            jmp pick_color
            ;== == == == ==  == == ==
        jmp cycle_while

        paint_others:
            ; == == PINTAR OTROS BARRA == ==
                xor ax,ax
                xor bx,bx
                mov ax,paint_end; bx = fin
                add ax,5d; ax = fin + 5
                mov paint_init,ax; inicio = fin + 5

                mov ax,paint_init; ax = inicio
                add ax,paint_size; ax = inicio + tamaño
                mov paint_end,ax ; fin = inicio + tamaño

                ; == ALTURA ==
                xor ax,ax
                xor dx,dx

                mov al,array[di] ; ax = array[i]
                mov paint_height,ax
                mov value_array,ax;; value = array[i]

                mov ax,paint_height
                mov bx,140d
                mul bx ; ax = 50*140
                mov paint_height,ax ; tamaño = 50 * 140

                mov ax,paint_height
                mov bx,100d
                div bx ; ax = (50 *140) / 100
                mov paint_height,ax ; tamaño = (50 *140) / 100

                mov ax,160d
                sub ax,paint_height
                mov paint_height,ax ; tamañp = 160 - (50 * 140)/100d
                ; == == ==  ==
                mov ax,paint_init; ax = inicio
                mov bx,paint_end; bx = fin
                inc di
                ;== == SELECT COLOR == ==
                jmp pick_color
                ;== == == == ==  == == ==


        jmp cycle_while

        pick_color:
            cmp value_array,20d ; if
            jle red_color ; if (value <= 20) ->> salta si es menor igual; color ROJO

            cmp value_array,40d; if
            jle blue_color; if (value <= 40) ->>Salta si es menor igual; color AZUL

            cmp value_array,60d; if
            jle yellow_color; if (value <= 60) ->> Salta si es menor igual; AMARILLO

            cmp value_array,80d; if
            jle green_color; if (value <= 80) ->> Salta si es menor igual ; VERDE

            cmp value_array,100d; if
            jle white_color; if (value <= 100) ;BLANCO
        jmp white_color

        pick_speed_:
            call DS_DATA
            cmp speed_deley,0d       ; if
            je range_0_          ; if (number == 0) ->> Salta para velocidad 1000

            cmp speed_deley,2d       ; if
            jle range_1_2_       ; if (number <= 2) ->> Salta para velocidad 800

            cmp speed_deley,6d       ; if
            jle range_3_4_       ; if (number <= 4) ->> Salta para velocidad 600

            cmp speed_deley,8d       ; if
            jle range_5_6_       ; if (number <= 6) ->> Salta para velocidad 400

            cmp speed_deley,8d       ; if
            jle range_7_8_       ; if (number <= 8) ->> Salta para velocidad 100

            cmp speed_deley,9d       ; if
            jle range_9_         ; if (number == 8) ->> Salta para velocidad 50
        jmp range_9_

        red_color:
            ; == == == ==
            call DS_DATA
                m_paint_bar paint_init,paint_end,paint_height,160d,4d
            call DS_DATA
            ; == == == == == == == ==  ==  ==
        jmp pick_speed_

        blue_color:
            ; == == == ==
            call DS_DATA
                m_paint_bar paint_init,paint_end,paint_height,160d,1d
            call DS_DATA
            ; == == == == == == == ==  ==  ==
        jmp pick_speed_

        yellow_color:
            ; == == == ==
            call DS_DATA
                m_paint_bar paint_init,paint_end,paint_height,160d,14d
            call DS_DATA
            ; == == == == == == == ==  ==  ==
        jmp pick_speed_

        green_color:
            ; == == == ==
            call DS_DATA
                m_paint_bar paint_init,paint_end,paint_height,160d,2d
            call DS_DATA
            ; == == == == == == == ==  ==  ==
        jmp pick_speed_

        white_color:
             ; == == == ==
            call DS_DATA
                m_paint_bar paint_init,paint_end,paint_height,160d,15d
            call DS_DATA
            ; == == == == == == == ==  ==  ==
        jmp pick_speed_


             ; == == == VELOCIDAD 0(speed = 1000) == == ==
        range_0_:
            call DS_VIDEO
                m_deley 1000
            call DS_DATA
        jmp cycle_while
        ; == == == == == == == == == ==
        ; == == == VELOCIDAD 1-2(speed = 800) == == ==
        range_1_2_:
            call DS_VIDEO
                m_deley 800
            call DS_DATA
        jmp cycle_while
        ; == == == == == == == == == ==
        ; == == == VELOCIDAD 3-4(speed = 600) == == ==
        range_3_4_:
            call DS_VIDEO
                m_deley 600
            call DS_DATA
        jmp cycle_while
        ; == == == == == == == == == ==
        ; == == == VELOCIDAD 5-6(speed = 400) == == ==
        range_5_6_:
            call DS_VIDEO
                m_deley 400
            call DS_DATA
        jmp cycle_while
        ; == == == == == == == == == ==
        ; == == == VELOCIDAD 7-8(speed = 100) == == ==
        range_7_8_:
            call DS_VIDEO
                m_deley 150
            call DS_DATA
        jmp cycle_while
        ; == == == == == == == == == ==
        ; == == == VELOCIDAD 9(speed = 65) == == ==
        range_9_:
            call DS_VIDEO
                m_deley 95
            call DS_DATA
        jmp cycle_while

        exit_while__:
            call DS_VIDEO; Regresa a modo video
                m_deley 900
            call DS_VIDEO
            pop cx
            pop di
            pop dx
            pop ax
            pop bx
endm

; ================================= ===== DIBUJAR NUMEROS  =================================
; Pinta los nuemros debajo de las barras
m_paint_number macro array
    local cycle_while,exit_while
    push bx
    push ax
    push dx
    push di
    push cx
    push si

    xor bx,bx
    xor ax,ax
    xor dx,dx
    xor di,di
    xor cx,cx
    xor si,si

    mov p_index,2

    cycle_while:
         call DS_DATA
        CMP si, flag
        JE exit_while

        XOR ax, ax
        XOR bx, bx

        MOV al, array[si]
        m_int_to_str buffer_num

        MOV bl, buffer_num[0]
        MOV bh, buffer_num[1]

        MOV p_num_1[0], bl
        MOV p_num_2[0], bh

        ;PRINT_CONSOLE buffer1[0], 20d, counter_footer
        ;PRINT_CONSOLE buffer2[0], 21d, counter_footer


        m_cursor_position 20d,p_index,p_num_1[0]          ; fila = 20d; columna = 2d
        m_cursor_position 21d,p_index,p_num_2[0]          ; fila = 20d; columna = 2d

        INC p_index
        INC p_index
        INC si
        ;call DS_VIDEO
    jmp cycle_while

    exit_while:
        push si
        pop cx
        pop di
        pop dx
        pop ax
        pop bx
        call DS_VIDEO
            ;m_deley 4000
         ;call DS_VIDEO

endm
; ================================= ===== MENU ORDENAMIENTO  =================================
; Muestra el menu de ordenamiento
m_menu_sort macro
    local main_sort,bubble_opcion,shell_opcion,exit_sort,bb_asc_opcion,bb_desc_opcion,shell_asc_opcion,shell_desc_opcion
    main_sort:
        m_clean_screen
        m_print msg_sort
        m_save_char
        ; ======================= OPCION 1 "BUBBLE SORT" =======================
        cmp opcion,31h      ; "1 = ascci 49 -> 31 HEXADECIMAL "
        JE bubble_opcion
        ; ======================= OPCION 2 "QUICK SORT" =======================
        ;cmp opcion,32h      ; "2 = ascci 50 -> 32 HEXADECIMAL "

        ; ======================= OPCION 3 "SHELL SORT" =======================
        cmp opcion,33h      ; "3 = ascci 51 -> 33 HEXADECIMAL "
        je shell_opcion

        ; ======================= OPCION 4  "SALIR" =======================
        cmp opcion,34h      ;"4 = ascci 52 -> 34 hexadecimal"
        je exit_sort

    jmp main_sort
    ; ============================ BUBBLE SORT ============================
    bubble_opcion:
        m_clean_screen              ; Limpia la pantalla
        m_print msg_speed           ; Imprime un mesanje en consola "Selecciona su velocidad"
        m_save_string buffer_read   ; Guarda un numero en el arreglo de string mandado
        m_str_to_int buffer_read    ; Convierte un numero de string a int y lo guarda en ax
        mov number_speed,ax         ; number = ax
        cmp number_speed,10d        ; if
        jge bubble_opcion           ; if (numero >= 10) ->> vuelve a pedir el numero

        m_clean_screen              ; Limpia la pantalla
        m_print msg_asc_desc        ; Imprime un mesanje en consola "Selecciona su velocidad"
        m_save_char                 ; Pide un carater y lo guarda en  "opcion"

        ; ======================= OPCION 1 "BUBBLE ASCENDENTE" =======================
        cmp opcion,31h      ; "1 = ascci 49 -> 31 HEXADECIMAL "
        JE bb_asc_opcion
        ; ======================= OPCION 1 "BUBBLE DESCENDENTE" =======================
        cmp opcion,32h      ; "2 = ascci 50 -> 32 HEXADECIMAL "
        JE bb_desc_opcion

    jmp main_sort
    ; ============================ BUBBLE SORT ============================
    ; == == == BUBBLE ASC == == ==
    bb_asc_opcion:
        ; == == == CONVERT == == ==
        mov ax,number_speed                                       ; ax = speed
        m_int_to_str buffer_num                             ; convierte a string el numero y guarda buffer_num
        ; == == == ==   == == ==
        m_bubble_sort_asc number_speed,msg_bb,buffer_num            ; inicia el metodo burbuja con el graficar
        list_wf
        ;call bb_asc_opcion
    jmp main_sort
    ; == == == == == == == == == =
    ; == == == BUBBLE DESC == == =
    bb_desc_opcion:
        ; == == == CONVERT == == ==
        mov ax,number_speed                                       ; ax = speed
        m_int_to_str buffer_num                             ; convierte a string el numero y guarda buffer_num
        ; == == == ==   == == ==
        m_bubble_sort_desc number_speed,msg_bb,buffer_num              ; inicia el metodo burbuja con el graficar
        list_wf
        ;call bb_desc_opcion
    jmp main_sort
    ; == == == == == == == == == =
    ; ============================ SHELL SORT ============================
    shell_opcion:
        m_clean_screen              ; Limpia la pantalla
        m_print msg_speed           ; Imprime un mesanje en consola "Selecciona su velocidad"
        m_save_string buffer_read   ; Guarda un numero en el arreglo de string mandado
        m_str_to_int buffer_read    ; Convierte un numero de string a int y lo guarda en ax
        mov number_speed,ax         ; number = ax
        cmp number_speed,10d        ; if
        jge shell_opcion           ; if (numero >= 10) ->> vuelve a pedir el numero

        m_clean_screen              ; Limpia la pantalla
        m_print msg_asc_desc        ; Imprime un mesanje en consola "Selecciona su velocidad"
        m_save_char                 ; Pide un carater y lo guarda en  "opcion"

        ; ======================= OPCION 1 "SHELL ASCENDENTE" =======================
        cmp opcion,31h      ; "1 = ascci 49 -> 31 HEXADECIMAL "
        JE shell_asc_opcion
        ; ======================= OPCION 1 "SHELL DESCENDENTE" =======================
        cmp opcion,32h      ; "2 = ascci 50 -> 32 HEXADECIMAL "
        JE shell_desc_opcion
    jmp main_sort
    ; == == == SHELL ASC == == ==
    shell_asc_opcion:
        ; == == == CONVERT == == ==
        mov ax,number_speed                                       ; ax = speed
        m_int_to_str buffer_num                             ; convierte a string el numero y guarda buffer_num
        ; == == == ==   == == ==
        m_shell_sort_asc number_speed,msg_ss,buffer_num            ; inicia el metodo burbuja con el graficar
        list_wf
        ;call ss_asc_wf
    jmp main_sort
    ; == == == == == == == == == =
    ; == == == SHELL DESC == == ==
    shell_desc_opcion:
        ; == == == CONVERT == == ==
        mov ax,number_speed                                       ; ax = speed
        m_int_to_str buffer_num                             ; convierte a string el numero y guarda buffer_num
        ; == == == ==   == == ==
        m_shell_sort_desc number_speed,msg_ss,buffer_num            ; inicia el metodo burbuja con el graficar
        list_wf
        ;call ss_desc_wf
    jmp main_sort
    ; == == == == == == == == == =
    exit_sort:
        m_back_main_menu
endm


m_create_file macro buffer,handler
    mov ah, 3ch
    mov cx, 00h
    lea dx, buffer
    int 21h
    mov handler, ax
endm
m_write_file macro handler_file,data
    local writeData, close


    mov ah,40h
    mov bx, handler_file
    mov cx, sizeof data
    lea dx, data
    int 21h

    ;closeFile:

    ;    mBackMainMenu
endm
m_close_file macro handler
    mov ah,3eh
    mov bx,handler
    int 21h
endm

m_join_array MACRO array_param,buffer_num_,handleent  ; array
    LOCAL cycle_report, CEROS, CONTINUE_NO_CEROS, end_cycle_report
    push si

    XOR si, si
    MOV si, 0

    cycle_report:
        CMP si, SIZEOF array_param
        JE end_cycle_report

        CMP array_param[si], 0
        JE CEROS

        CEROS:
            CMP array_param[si+1], 0
            JE end_cycle_report
            JNE CONTINUE_NO_CEROS

        CONTINUE_NO_CEROS:
            MOV al, array_param[si]
            m_int_to_str buffer_num_

            m_write_file handleent, buffer_num_
            m_write_file handleent, coma
            m_clean_str buffer_num_

            INC si
            JMP cycle_report
    end_cycle_report:
        MOV al, array_param[si]
        m_int_to_str buffer_num_

        m_write_file handleent, buffer_num_
        m_clean_str buffer_num_

        pop si
ENDM

m_copy_array macro fuente, destino
   LOCAL INICIO, FIN
   xor si,si
   xor bx,bx
   INICIO:
      mov bl, SIZEOF fuente
      cmp si, bx
      je FIN
      mov al, fuente[si]
      mov destino[si],al
      inc si
      jmp INICIO
  FIN:
ENDM
header_wf macro
    m_create_file write_file_name,write_file_handler    ; Crear el archivo
    m_write_file write_file_handler, wf_studen_name      ; '<ARQUI_1>'
    m_write_file write_file_handler, wf_id_name      ; '<ARQUI_1>'
endm
list_wf macro
    m_write_file write_file_handler, wf_sort_list_open      ; '    <Lista_Ordenada>',' '
    m_join_array number_array,buffer_temp_wf,write_file_handler
    m_write_file write_file_handler, wf_sort_list_close     ; '    </Lista_Ordenada>',' '

    m_write_file write_file_handler, wf_input_list_open      ; '    <Lista_Ordenada>',' '
    m_join_array init_array_number,buffer_temp_wf,write_file_handler
    m_write_file write_file_handler, wf_input_list_close     ; '    </Lista_Ordenada>',' '
endm
close_wf macro
    m_close_file write_file_handler
endm
