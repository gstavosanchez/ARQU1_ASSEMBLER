; =============== IMPRIMIR EN PANTALLA ======================
m_print macro string 
    mov ah,09h; (09h) Visualizar cadena en pantalla
    lea dx,string 
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
    MOV ah, 3dh
    MOV al, 02h     ; file mode
    LEA dx, file_name
    INT 21h
    MOV handler_file, ax     ; In AX return the handler
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
; =========================== ORDENAMIENTO BURBUJA ASCENDENTE =================================
bubble_sort macro 
    local cycle_for,exit_for,cycle_while,exit_while
    mov bb_p,1 ; p = 1
    cycle_for: ; for
        cmp bb_p,10; if(p <= array.length) ->> arreglar para diferentes tamños
        je exit_for

        mov bl,bb_p
        mov al,number_array[bx]
        mov bb_aux,al; aux = array[p]

        mov al,bb_p
        mov bb_j,al
        dec bb_j; j = p -1;

        ;== == == CICLO WHILE == == ==
            cycle_while: ; while((j >= 0) && (aux < array[j]))
                cmp bb_j,0; if (j >= 0)
                jnge exit_while ; if (j <= 0) ->> salir del ciclo (si j es menor igual se sale del ciclo) "Salta si NO es más grande que "

                xor bx,bx
                mov bl,bb_j
                mov al,number_array[bx]; array[j]

                cmp bb_aux,al; if (aux < array[j]) ->> al = array[j]
                jge exit_while; if (aux > array[i]) ->> salir del ciclo "Salta si aux es más grande que "

                xor bx,bx
                mov bl,bb_j
                mov al,number_array[bx]; array[j]
                inc bx; j+1
                mov number_array[bx],al; array[j+1] = array[j]
                dec bb_j;j --


            jmp cycle_while

            exit_while:

        ;== == == == == == == == == ==

        mov bl,bb_j
        inc bl
        mov al,bb_aux
        mov number_array[bx],al; array[j + 1] = aux

        inc bb_p; p++
    jmp cycle_for
    exit_for:
        mov bb_p,0d  ; variable auxiliar
        mov bb_j,0d ; variable auxliar
        mov bb_aux,0d
   
endm 

; =========================== ORDENAMIENTO BURBUJA DESCENDENTE =================================
bubble_sort_desc macro 
    local cycle_for_,exit_for_,cycle_while_,exit_while_
    mov bb_p,1 ; p = 1
    cycle_for_: ; for
        cmp bb_p,10; if(p <= array.length) ->> arreglar para diferentes tamños
        je exit_for_

        mov bl,bb_p
        mov al,number_array[bx]
        mov bb_aux,al; aux = array[p]

        mov al,bb_p
        mov bb_j,al
        dec bb_j; j = p -1;

        ;== == == CICLO WHILE == == ==
            cycle_while_: ; while((j >= 0) && (aux < array[j]))
                cmp bb_j,0; if (j >= 0)
                jnge exit_while_ ; if (j <= 0) ->> salir del ciclo (si j es menor igual se sale del ciclo) "Salta si NO es más grande que "

                xor bx,bx
                mov bl,bb_j
                mov al,number_array[bx]; array[j]

                cmp bb_aux,al; if (aux > array[j]) ->> al = array[j]
                jnge exit_while_; if (aux < array[i]) ->> salir del ciclo "Salta si aux NO es más grande que "

                xor bx,bx
                mov bl,bb_j
                mov al,number_array[bx]; array[j]
                inc bx; j+1
                mov number_array[bx],al; array[j+1] = array[j]
                dec bb_j;j --


            jmp cycle_while_

            exit_while_:

        ;== == == == == == == == == ==

        mov bl,bb_j
        inc bl
        mov al,bb_aux
        mov number_array[bx],al; array[j + 1] = aux

        inc bb_p; p++
    jmp cycle_for_
    exit_for_:
        mov bb_p,0  ; variable auxiliar
        mov bb_j,0 ; variable auxliar
        mov bb_aux,0

endm 
; =========================== REGRESAR MENU PRINCIPAL =================================
m_back_main_menu macro
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
m_cursor_position macro row,column,msg ; fila = 20d; columna = 58d
    push ax
    xor ax,ax
    mov ah,02h
    mov bh,00h
    mov dh,row; 23 filas
    mov dl,column;118 columnas
    int 10h
    call DS_DATA
    m_print msg
    call DS_VIDEO

    pop ax
endm

m_paint_bb macro array
    local cycle_while,paint_others,exit_while__,paint_start,red_color,blue_color,yellow_color,green_color,white_color,pick_color

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
    
    call INIT_VIDEO
    m_cursor_position 1d,3d,msg_bb ;fila = 1d; columna = 2d ; IMPRIME ARRIBA DEL MARCO "USAC"
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

        red_color:
            ; == == == ==
            call DS_DATA
                m_paint_bar paint_init,paint_end,paint_height,160d,4d
            call DS_VIDEO
                m_deley 800
            call DS_DATA
            ; == == == == == == == ==  ==  == 
        jmp cycle_while

        blue_color:
            ; == == == ==
            call DS_DATA
                m_paint_bar paint_init,paint_end,paint_height,160d,1d
            call DS_VIDEO
                m_deley 800
            call DS_DATA
            ; == == == == == == == ==  ==  == 
        jmp cycle_while

        yellow_color:
            ; == == == ==
            call DS_DATA
                m_paint_bar paint_init,paint_end,paint_height,160d,14d
            call DS_VIDEO
                m_deley 800
            call DS_DATA
            ; == == == == == == == ==  ==  == 
        jmp cycle_while

        green_color:
            ; == == == ==
            call DS_DATA
                m_paint_bar paint_init,paint_end,paint_height,160d,2d
            call DS_VIDEO
                m_deley 800
            call DS_DATA
            ; == == == == == == == ==  ==  == 
        jmp cycle_while

        white_color:
             ; == == == ==
            call DS_DATA
                m_paint_bar paint_init,paint_end,paint_height,160d,15d
            call DS_VIDEO
                m_deley 800
            call DS_DATA
            ; == == == == == == == ==  ==  == 
        jmp cycle_while



        exit_while__:
            call DS_VIDEO; Regresa a modo video 
            m_deley 3000
            call END_VIDEO
            pop cx
            pop di
            pop dx
            pop ax
            pop bx
endm 
