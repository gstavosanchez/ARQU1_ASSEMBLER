;  ================= ========= ========== PUSHER AND POPPER  =============== =========== ==========
PUSHER MACRO 
    PUSH ax
	PUSH bx
	PUSH cx
	PUSH dx
ENDM
POPPER MACRO
    POP dx
	POP cx
	POP bx
	POP ax
ENDM
CLEAN_RECORDS MACRO
  XOR ax,ax
  XOR bx,bx
  XOR cx,cx
  XOR dx,dx
ENDM
;  ================= ========= ========== PUSHER AND POPPER ALL =============== =========== ==========
PUSHER_ALL MACRO
    PUSH ax
	PUSH bx
	PUSH cx
	PUSH dx
	PUSH si
	PUSH di
ENDM
POPPER_ALL MACRO
    POP di
	POP si
	POP dx
	POP cx
	POP bx
	POP ax

ENDM
CLEAN_RECORDS_ALL MACRO
  XOR ax,ax
  XOR bx,bx
  XOR cx,cx
  XOR dx,dx
  XOR di,di
  XOR si,si
ENDM
;  ================= ========= ========== ============================= =============== =========== ==========
; =============== IMPRIMIR EN PANTALLA ======================
print MACRO string 
    mov ah,09h; (09h) Visualizar cadena en pantalla
    lea dx,string 
    int 21h 
ENDM 
; ==================================== INT TO STRING ==============================
int_to_string MACRO numStr 
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
ENDM
; =========== CONVIERTE UNA CADENA A NUMERO, ESTE SE GUARDA EN "AX" =============
str_to_int macro numStr
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
; ===================================== OBTENER NUMEROS =====================================
get_number_list macro array_list
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

ENDM
; ========================== GUARDAR EN ARREGLO ===================
; @param array: donde se encuentra los valores
; @return :gurada en el arreglo array_num
set_number_array macro array
    local cycle,end_cycle,start_save,final_save
    push bx
    push cx
    push dx
    push si

    ;Limpiando los registros AX, BX, CX, SI
    xor ax,ax
    xor bx,bx
    xor dx,dx
    xor si,si

    mov flag,0d                 ; regresa a su estado inicial
    mov flag_2,0d               ; regresa a su estado inicial
    mov si,0000h                ; Lleva el contro del array de string
    mov di,0000h                ; lleva el contro del aux
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

        XOR AX,AX
        str_to_int aux_number         ; Se convierte el texto en numero
        mov array_num[bx],ax            ; se mueve a number_array[bx], lo que esta en ax(numero)

        clean_str aux_number          
        ; == =================== ==
        mov di,0000h;
        inc si
        INC flag_2
        ; === === INCRMENTAR EL CONTAR EN 2 == ==
        XOR ax,ax        
        MOV ax,flag
        ADD ax,2                        ; se incrementa el contador del array de numeros
        MOV flag,ax
        ; == == == == == == == == == == == == == == 
        mov bx,0000h
    jmp cycle
    end_cycle:
        pop si
        pop dx
        pop cx
        pop bx
        ;mov flag,0d
        ;m_copy_array number_array, init_array_number

endm

; ==================================== PAINT PIXEL ==============================
; Paint a pixel on the screen with the set color
; @param row : position in the row a pixel
; @param column : position in the column a pixel
; @param color: color of the pixel 
paint_pixel MACRO row,column,color
    PUSHER
    CLEAN_RECORDS
    MOV ah,0ch      ; ah = 0ch;
    MOV al,color    ; al = valo del color a utilizar
    MOV bh,0        ; bh = pagina de video donde escribir el caracter
    MOV cx,column   ; cx = columna donde escribir el pixel (coordenada grafica x)
    MOV dx,row      ; dx = Fila donde escribir el pixel (coordenada grafica y)
    INT 10h    

    ;MOV ah,01h      ; NO BOTAR EL PROGRAMA
    ;INT 21h
    POPPER
ENDM
; ==================================== PAINT CHAR ==============================
; Paint char on the scrren with the set color
; @param char: char to print
; @param color: color to paint on the screen
paint_char MACRO char,color 
    PUSHER
    CLEAN_RECORDS

    MOV ah,09h      ; ah = 09h para las letras
    MOV al,char     ; al = Codigo del caracter a escribir
    MOV bh,0        ; bh = Pagina de video donde se va escribir
    MOV bl,color    ; bl = Atributo o color que va a tener el caracter
    MOV cx,1        ; Cantidad de caracteres a escribir
    INT 10h         ;

    POPPER
ENDM

; ==================================== CURSOR POSTION ==============================
; Position the cursor where you want to print the chara
; @param row: row the cursor
; @param column: column the cursor
cursor_position MACRO row,column
    PUSHER
    
    CLEAN_RECORDS

    ; XOR ax,ax
    ; MOV al,row
    ; MOV cursor_row,al

    MOV ah,02h      ; ah = 02h
    MOV bh,0        ; bh = Pagina de video
    MOV dh,row      ; dh = Fila o lina donde se situa el cursor
    MOV dl,column   ; dl = columna deonde se situa el cursor
    INT 10h 

    POPPER
ENDM

; ==================================== PAINT WORD ==============================
; Position the cursor where you want to print the chara
; @param string: word you want to paint
; @param row: row the cursor
; @param column: column the cursor
; @param color: color the word
paint_word MACRO string,row,column,color
    LOCAL cycle,exit_while
    PUSH si
    PUSH ax 
    XOR si,si
    XOR ax,ax

    MOV index_column,0      ; index_column = 0
    MOV ax,column           ; ax = 20
    MOV index_column,al     ; index_column = 20 

    XOR ax,ax
    MOV ax,SIZEOF string

    cycle:
        CMP si,ax      ; if
        JE exit_while   ; if (si == 4) ->> EXIT
        ; == == CURSOR POSITION == == 
        cursor_position row,index_column
        ; == == == == == == == == == =
        ; == == CHAR PAINT == == == ==
        paint_char string[si],color
        ; == == == == == == == == == =
        inc si  
        inc index_column
    jmp cycle 
    exit_while:
        POP ax
        POP si 

ENDM

; ==================================== PAINT WORD ==============================
; Position the cursor where you want to print the chara
; @param string: word you want to paint
; @param column: column the cursor
; @param row: row the cursor
; @param color: color the word
paint_word_vertical MACRO string,row,column,color
    LOCAL cycle,exit_while
    PUSH si
    PUSH ax 
    XOR si,si
    XOR ax,ax

    MOV index_column,0      ; index_column = 0
    MOV ax,column           ; ax = 20
    MOV index_column,al     ; index_column = 20 

    XOR ax,ax
    MOV ax,SIZEOF string

    cycle:
        CMP si,ax      ; if
        JE exit_while   ; if (si == 4) ->> EXIT
        ; == == CURSOR POSITION == == 
        cursor_position index_column,row
        ; == == == == == == == == == =
        ; == == CHAR PAINT == == == ==
        paint_char string[si],color
        ; == == == == == == == == == =
        inc si  
        inc index_column
    jmp cycle 
    exit_while:
        POP ax
        POP si 

ENDM
; ==================================== PAINT AXIS Y ==============================
; Paint a vertical line, maximum vertical size is 480
; @param up: start of the line
; @param down: end of the line
; @param column: colunm of the line
; @param color: color of the line 
paint_axis_y MACRO up,down,column,color
    LOCAL while_y
    MOV axis_y,up
    while_y:
        paint_pixel axis_y,column,color
        INC axis_y 
        CMP axis_y,down     ; if  
    JNE while_y             ; if ( y != down ) ->> saltar a while. Seguir pintando en y
ENDM
; ==================================== PAINT AXIS X ==============================
; Paint a horizontal line,maximum horizontal size is 640
; @param left: start of the line
; @param right: end of the line
; @param row: colunm of the line
; @param color: color of the line
paint_axis_x MACRO left,right,row,color
    LOCAL while_x
    MOV axis_x,left
    while_x:
        paint_pixel row,axis_x,color
        INC axis_x 
        CMP axis_x,right     ; if  
    JNE while_x              ; if ( y != right ) ->> saltar a while. Seguir pintando en x
ENDM
; ==================================== PAINT BAR ==============================
; El ancho inicia 38 y termina en 598,la altura inicia 35 y finaliza en 449
; @param left: start of bar width(ancho)
; @param right: end of bar width
; @param up: start of bar height(altura)
; @param down: end of bar height
; @param color: color of the line
paint_bar MACRO left,right,up,down,color
    LOCAL while_1,while_2
    PUSHER
    CLEAN_RECORDS

    MOV bar_x,0d
    MOV bar_y,0d

    MOV ax,left
    MOV bar_x,ax              ; Inicia en algun lugar de la izquierda 
    while_1:
        XOR ax,ax 
        MOV ax,up
        MOV bar_y,ax            ; Inicia en algun lugar de arriba 
        while_2:
            paint_pixel bar_y,bar_x,color 
            INC bar_y 

            XOR ax,ax
            MOV ax,down
            CMP bar_y,ax        ; Termina en algun lugar de abajo
        JNZ while_2             ; if (y != down) ->> Saltar a while 2

        INC bar_x

        XOR ax,ax
        MOV ax,right
        CMP bar_x,ax            ; if : Termina en algun lugar de la derecha
    JNE while_1                 ; if (x != right) ->> saltar while 1

    POPPER
ENDM 
; ===================================== LEER ARCHIVO ====================================
; Open file 
; @param file_name: name of the file
; @param handler: file handler
open_file MACRO file_name,handler_file
    LOCAL error_open,open_xml,exit_open
    ;print_ file_name
    open_xml:
        MOV ah, 3dh
        MOV al, 02h     ; file mode
        LEA dx, file_name
        INT 21h
        JC error_open
        MOV handler_file, ax     ; In AX return the handler
    JMP exit_open
    error_open:
        print_ msg_error_open
    JMP main_init_while
    exit_open:
ENDM
; READ FILE 
; @param buffer: name of the file
; @param handler: file handler
read_file MACRO buffer,handler_file
    MOV ah, 3fh
    MOV bx, handler_file
    MOV cx, SIZEOF buffer
    LEA dx, buffer
    INT 21H
ENDM
; CLOSE FILE 
; @param handler: file handler
close_file MACRO handler_file
    mov ah,3eh
    mov bx,handler_file
    int 21h
ENDM
; ======================== SAVE STRING ======================
; SAVE STRING REQUIRED IN CONSOLE
; @param buffer: var where it is stored
save_string macro buffer
    LOCAL ObtenerChar, FinOT
    XOR si, si
    print_ msg_opcion
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
getChar macro
    MOV AH, 01h
    INT 21H
endm
; =============== IMPRIMIR EN PANTALLA ======================
print_ macro string
    mov ah,09h                  ; (09h) Visualizar cadena en pantalla
    lea dx,OFFSET  string       ; cambiar
    int 21h
endm
clean_screen macro
    mov ah,0fh
    int 10h
    mov ah,0
    int 10h
endm
; ===================================== PAUSE PANTALLA =====================================
pause_ macro
    mov ah,7                        ; Sirve para hacer una pausa al sistema, vuelve funcionar press cualquier tecla
    int 21h
endm
clean_str macro string
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
; ===================================== INTERPRETE =====================================
; @param string: cadena leida en consola 
inteprete MACRO string
    LOCAL main_while,exit_while,cmd_exit,execute_exit,cmd_err,cmd_file,execute_file,save_path,cmd_clean,exec_clean,c_while
    LOCAL cmd_prom,exec_prom
    PUSHER_ALL
    CLEAN_RECORDS_ALL
    clean_str file_name                ;limpiar variable
    main_while:
        CMP string[si],73h          ; if
        JE cmd_exit                 ; if (data[x] == s) ->> ir a comando exit

        CMP string[si],61h          ; if
        JE cmd_file                 ; if (data[x] == a) ->> ir a comando file 

        CMP string[si],6ch          ; if
        JE cmd_clean                ; if (data[x] == l) ->> ir a  comando limpiar

        CMP string[si],63h          ; if
        JE c_while                  ; if (data[x] == c) ->> ir a  while de comandos

        INC si 
        CMP string[si],24h          ; if
        JZ cmd_err                  ; if (data[x] == $) ->> regresar main while 
    JMP cmd_err
    ; == == == == == == COMANDO-C == == == == == ==
    c_while:
        INC si
        MOV al,string[si]
        MOV curr_letter,al 

        CMP curr_letter,70h         ; if
        JE cmd_prom                 ; if (al == p) ->> ir a  while de comandos

        CMP curr_letter,6dh         ; if
        JE c_while                  ; if (al == m) ->> ir a  while de comandos
         
    JMP cmd_err
    ; == == == == == == == == ==  == == == == == ==
    cmd_exit:
        INC si 
        CMP string[si],61h      ; if
        JE cmd_exit             ; if (data == a) ->> regresar cmd_exit

        CMP string[si],6ch      ; if
        JE cmd_exit             ; if (data == l) ->> regresar cmd_exit

        CMP string[si],69h      ; if
        JE cmd_exit             ; if (data == i) ->> regresar cmd_exit

        CMP string[si],72h      ; if
        JE execute_exit         ; if (data == r) ->> ejecuta el comando salir
    JMP cmd_err

    cmd_file:
        INC si
        CMP string[si],62h      ; if
        JE cmd_file             ; if (data == b) ->> regresar cmd_file

        CMP string[si],72h      ; if
        JE cmd_file             ; if (data == r) ->> regresar cmd_file

        CMP string[si],69h      ; if
        JE cmd_file             ; if (data == i) ->> regresar cmd_file

        CMP string[si],5fh      ; if
        JE cmd_file             ; if (data == _) ->> regresar cmd_file

        CMP string[si],3ch      ; if
        JE save_path            ; if (data == <) ->> regresar cmd_file

    JMP cmd_err

    save_path:
        INC si
        mov al,string[si]       ; al = string[x]

        CMP al,3eh              ; if
        JE execute_file         ; if (data == >) ->> ejecutar execute_file

        mov file_name[di],al    ; file_name = al 
        INC di
    JMP save_path

    ; =========== LIMPIAR CONSOLA =============
    cmd_clean:
        INC si 
        CMP string[si],69h          ; if
        JE cmd_clean                ; if (data[x] == i) ->> regresar cmd_clean

        CMP string[si],6dh          ; if
        JE cmd_clean                ; if (data[x] == m) ->> regresar cmd_clean

        CMP string[si],70h          ; if
        JE cmd_clean                ; if (data[x] == p) ->> regresar cmd_clean

        CMP string[si],61h          ; if
        JE cmd_clean                ; if (data[x] == a) ->> regresar cmd_clean

        CMP string[si],72h          ; if
        JE exec_clean               ; if (data[x] == r) ->> ejecuta el comando limpiar consola
    JMP cmd_err
    exec_clean:
       POPPER_ALL
       clean_screen 
    JMP main_init_while
    ; ====== ========================= ==========
    ; =========== ===== PROMEDIO ===== ==========
    cmd_prom:
        XOR ax,ax
        INC si
        MOV al,string[si]
        MOV curr_letter,al 


        CMP curr_letter,72h          ; if
        JE cmd_prom                  ; if (data[x] == r) ->> regresar al ciclo cmd_prom

        CMP curr_letter,6fh          ; if
        JE cmd_prom                  ; if (data[x] == o) ->> regresar al ciclo cmd_prom

        CMP curr_letter,6dh          ; if
        JE exec_prom                 ; if (data[x] == m) ->> regresar al ciclo cmd_prom
    JMP cmd_err
    exec_prom:
        POPPER_ALL
        clean_str buffer_str                    ;limpiar variable
        ;average array_num,flag                  ; ejecuta el promedio
         ; == == == TEST == == ==
        print msg_opcion
        mov ax,flag
        int_to_string buffer_num
        print_ buffer_num
        ; == == == =  = == == ==

    JMP main_init_while
    ; ====== ========================= ==========
    execute_file:
        POPPER_ALL
        clean_str buffer_str                    ;limpiar variable
        ; ==  LECTURA DE ARCHIVO ==
        open_file file_name,file_handler        ; Abrir archivo
        read_file buffer_file,file_handler      ; paametros : texto donde se almacena "read_text_file", handler
        close_file file_handler                 ; parametros; handler
        ; == == == == == == == == ==
        ; == == CARGAR A ARRAY == ==
        get_number_list buffer_file              ; guarda en el arreglo "number_list"
        set_number_array number_list             ; recorre el arreglo de string de numeros "10 20 30" y los almacena en arreglo numerico (number_array)
        bubble_sort array_num                    ; ordemiento burbuja 
        ;print_array_16 array_num, flag           ; imprime el listado de nuemeros del arreglo de numeros
        ;median array_num
        ;execute_moda
        paint_graph_asc
        ; == == == == == == == == ==

    JMP main_init_while

    execute_exit:
        print_ msg_cmd              
        POPPER_ALL
    JMP exit_main_menu
    
    cmd_err:
        clean_str buffer_str    ;limpiar variable
        print_ msg_err
        POPPER_ALL
ENDM 

PRINT_N MACRO Num
    LOCAL zero
    
    XOR ax,ax
    MOV dl,NUm
    ADD dl,48
    MOV ah,02h
    INT 21h
endm
salto_ macro 
    MOV dl,10 
    MOV ah,02h
    INT 21h
    MOV dl,13 
    MOV ah,02h
    INT 21h
endm
PRINT_16 MACRO Regis
    LOCAL zero,noz

    MOV bx,4
    XOR ax,ax
    MOV ax,Regis
    MOV cx,10
    zero:
        XOR dx,dx
        DIV cx
        PUSH dx
        DEC bx
        JNZ zero
        XOR bx,4
    noz:
        POP dx
        PRINT_N dl
        DEC bx
        JNZ noz
ENDM
; IMPRIME UN ARREGLO DE 16
; @param array: array list of number
; @param size: size of the array
print_array_16 MACRO array,size_
    LOCAL cycle_show
    PUSH si

    XOR si, si
    cycle_show:
        PUSH si

        PRINT_16 array[si]
        salto_
        POP si

        ADD si,2      
        CMP si, size_
    JNE cycle_show        

    POP si
ENDM 
; ==================================== PROMEDIO =====================================
; Calcula el promedio de una lista de valores
; @param array: array list of number
; @param size: size of the array (tamaño real)
average MACRO array,size_
    LOCAL cycle_while 
    PUSHER_ALL
    CLEAN_RECORDS_ALL
    MOV result,0d
    cycle_while:
        MOV ax, array[si]       ; ax = array[x]
        ADD ax,result           ; ax = ax + result

        MOV result,ax           ; result = ax 
        ADD si,2 
        CMP si,size_ 
    JNE cycle_while 
    POPPER_ALL
    division_decimal result,flag_2
ENDM
; ==================================== DIVISIÓN =====================================
; Calcula la división de valores con decimales  10 / 3 = 3.3333
; @param dividendo: Numero el cual se desea dividir
; @param divisor: Numero por el cual se va dividir
division_decimal MACRO dividendo,divisor
    LOCAL while_
    PUSHER
    CLEAN_RECORDS
    MOV ax,dividendo        ; ax = 10
    MOV bx,divisor          ; bx = 3
    DIV bx                  ; ax = ax / bx

    MOV entero,0d           ; Limpiar variables
    MOV decimal,0d          ; Limpiar variables
    MOV entero,ax           ; entero = ax

    while_:
        MOV ax,dx           ; ax = residuo
        XOR dx,dx
        PUSH bx             ; Guardar el numero 
        MOV bx,10
        MUL bx
        POP bx              ; Sacar el numero 

        XOR dx,dx
        DIV bx              ; residuo = residuo * 10

        PUSH ax
        PUSH dx
        PUSH bx

        XOR dx,dx
        MOV ax,decimal
        MOV bx,10
        MUL bx
        MOV decimal,ax

        POP bx
        POP dx
        POP ax

        ADD decimal,ax 
        INC cx
        CMP cx,4
    JNZ while_  
     
    POPPER
    print_ msg_opcion
    PRINT_16 entero
    print_ dot 
    PRINT_16 decimal
ENDM

; ==================================== ORDENAMIENTO =====================================
; Ordenamiento Burbuja ascendente
; @param array: arreglo a ordenar  
bubble_sort MACRO array
    LOCAL cycle_i,cycle_j,exit_i,exit_j,continue_j
    PUSHER
    CLEAN_RECORDS

    MOV b_i,0
    MOV b_j,0
    MOV ax,flag
    MOV b_size,ax 
    MOV ax,b_size
    cycle_i:
        ; == == IF (i < SIZE) == ==
        MOV ax,b_i                  ; ax = i
        CMP ax,b_size               ; if
        JGE exit_i                  ; if (i >= size) ->> Salirse 
        ; == == == == == == == == =
        cycle_j:
            ; == == IF (J < SIZE - I) == ==
            MOV ax,b_size                  ; ax = size
            SUB ax,2d                       ; ax = size - 1
            CMP b_j,ax                      ; if
            JGE exit_j                      ; if (j >= size - i) ->> Salir
            ; == == == == == == == == == ==
            ; == == IF (ARRAY[J ] > ARRAY[J +1 ]) == ==
            ;b_aux = array[k +1]
            ;b_temp = array[k]
            XOR ax,ax
            XOR bx,bx

            MOV bx,b_j                                  ; bx = j
            MOV ax,array[bx]                            ; ax = array[j]
            MOV b_temp,ax                               ; temp = array[j]

            XOR ax,ax
            MOV ax,b_j                                  ; ax = j
            ADD ax,2                                    ; ax = ax + 2
            MOV b_j,ax                                  ; j = j + 2

            XOR ax,ax
            XOR bx,bx

            MOV bx,b_j                                  ; bx = j
            MOV ax,array[bx]                            ; ax = array[j+1]
            MOV b_aux,ax                                ; aux = array[j+1]

            XOR ax,ax
            MOV ax,b_j                                  ; ax = j
            SUB ax,2                                    ; ax = ax - 2
            MOV b_j,ax                                  ; j = j - 2

            MOV ax,b_temp                               ; ax = array[j]
            CMP ax,b_aux                                ; if
            JLE continue_j                              ; if (array[j] < array[j + 1]) ->> Continuar

            ; == == == == == == == == == == == == == ==
            ; == == == == == CAMBIO DE VALORES == == ==
            ;b_aux = array[k +1]
            ;b_temp = array[k]
            XOR ax,ax 
            XOR bx,bx

            MOV bx,b_j                                  ; bx = j
            MOV ax,b_aux                                ; ax = aux(array[j + 1])
            MOV array[bx],ax                            ; array[j] = array[j + 1]

            XOR ax,ax
            MOV ax,b_j                                  ; ax = j
            ADD ax,2                                    ; ax = ax + 2
            MOV b_j,ax                                  ; j = j + 2

            XOR ax,ax
            XOR bx,bx

            MOV bx,b_j                                  ; bx = j
            MOV ax,b_temp                               ; ax = aux(array[j])
            MOV array[bx],ax                            ; array[j+1] = array[j]

            XOR ax,ax
            MOV ax,b_j                                  ; ax = j
            SUB ax,2                                    ; ax = ax - 2
            MOV b_j,ax                                  ; j = j - 2
            ; == == == == == == == == == == == == == ==
            XOR ax,ax
            MOV ax,b_j                                  ; ax = j
            ADD ax,2                                    ; ax = ax + 2
            MOV b_j,ax                                  ; j = j + 2

        JMP cycle_j 
    JMP cycle_i 

    continue_j:
        XOR ax,ax
        MOV ax,b_j      ; ax = j
        ADD ax,2        ; ax = ax + 2
        MOV b_j,ax      ; j = j + 2
    JMP cycle_j
    exit_j:
        XOR ax,ax
        MOV ax,b_i      ; ax = i
        ADD ax,2        ; ax = ax + 2
        MOV b_i,ax      ; i = i + 2
        
        MOV b_j,0d      ; j = 0 
    JMP cycle_i 
    exit_i:
        POPPER
ENDM 
; ==================================== MEDIANA =====================================
; CALCULA LA MEDIANA DEL ARREGLO
; @param array: arreglo   de numeros
median MACRO array
    LOCAL par_number, impar_number,impar_cycle,exit_median,par_cycle,continue_par,exit_par
    ;bubble_sort array_num                    ; ordemiento burbuja 
    PUSHER_ALL
    CLEAN_RECORDS_ALL
    MOV b_i,0d
    MOV b_j,0d
    MOV b_aux,0d
    MOV b_temp,0d

    MOV ax,flag_2                           ; ax = contador
    MOV bx,2d                               ; bx = 2
    DIV bx                                  ; ax = ax / 2

    CMP dx,0000h                            ; if
    JE par_number                           ; if (dx == 000) ->> es par

    JMP impar_number                        ; impar

    par_number:
        MOV b_temp,ax                      ; liminte superior
        SUB ax,1                           ; ax = ax + 1
        MOV b_aux,ax                       ; limite inferiro
    JMP par_cycle 

    par_cycle:
        CMP cx,b_aux                        ; if
        JL continue_par                     ; if (cx < aux) ->> continuar

        CMP cx,b_temp                       ; if
        JG exit_par                         ; if (cx > temp) ->> salir

        XOR ax,ax
        MOV ax,array[si]                    ; ax = array[si]
        ADD ax,b_i                          ; ax = ax + i
        MOV b_i,ax                          ; i = ax
        
        INC cx
        ADD si,2                            ; si = si + 2 
    JMP par_cycle

    continue_par:
        INC cx
        ADD si,2                            ; si = si + 2 
    JMP par_cycle
    impar_number:
        ADD ax,1
        MOV b_j,ax
    JMP impar_cycle
    impar_cycle:
        XOR bx,bx
        MOV bx,array[si]    ; bx = array[si]
        MOV b_i,bx          ; i = array[si]

        INC cx              ; cx = cx + 1
        ADD si,2            ; si = si + 2

        CMP b_j,cx           ; if
        JE exit_median      ; if (cx == ax(parte entera))
    JMP impar_cycle
    
    exit_par:
        POPPER_ALL
        division_decimal b_i,2d
    JMP main_init_while

    exit_median:
        POPPER_ALL
        print_ msg_opcion
        PRINT_16 b_i
ENDM 
; ====================================== FRECUENCIA ====================================
table macro array 
    LOCAL fin, formar, esigual, primer_ciclo, cambio
    PUSHER_ALL
    CLEAN_RECORDS
    xor si,si ;puntero de arreglo de numeros 
    xor di,di ;punter de arreglo para tabla

    primer_ciclo: 
        mov ax, array[si]
        mov tnum[di], ax ; tnum[0] = primer numero en la lista
        
        ;mov num_actual, ax

        mov tfrecuencia[di], 1

        inc si 
        inc si 
    formar:
        cmp si, flag 
        je fin
        
        mov ax, array[si] ; actual es igual al anterior ya guradado
        cmp tnum[di], ax 
        je esigual

        jmp cambio
    esigual:
        mov ax,tfrecuencia[di]
        add ax, 1
        mov tfrecuencia[di], ax 
        inc si 
        inc si 
        jmp formar
    cambio:
        inc di
        inc di

        mov tflag, di ; guardando cuando datos han ingresado        

        mov ax, array[si]
        mov tnum[di], ax

        mov tfrecuencia[di], 1 ; frecuencia = 1

        inc si 
        inc si 
        jmp formar
    fin: 
        add tflag, 2 
        POPPER_ALL 
endm
; ====================================== ORDEMAMINETO ====================================
; @param array : array de frecuencias 
; @param array_n : array normal  
bb_arrays MACRO array,array_n
    LOCAL cycle_i,cycle_j,exit_i,exit_j,continue_j
    PUSHER
    CLEAN_RECORDS

    MOV b_i,0
    MOV b_j,0
    MOV ax,tflag
    MOV b_size,ax 
    MOV ax,b_size
    cycle_i:
        ; == == IF (i < SIZE) == ==
        MOV ax,b_i                  ; ax = i
        CMP ax,b_size               ; if
        JGE exit_i                  ; if (i >= size) ->> Salirse 
        ; == == == == == == == == =
        cycle_j:
            ; == == IF (J < SIZE - I) == ==
            MOV ax,b_size                  ; ax = size
            SUB ax,2d                       ; ax = size - 1
            CMP b_j,ax                      ; if
            JGE exit_j                      ; if (j >= size - i) ->> Salir
            ; == == == == == == == == == ==
            ; == == IF (ARRAY[J ] > ARRAY[J +1 ]) == ==
            ;b_aux    = array[k +1]
            ;b_temp   = array[k]
            ;b_aux_f  = array[k +1]
            ;b_temp_f = array[k]
            XOR ax,ax
            XOR bx,bx

            MOV bx,b_j                                  ; bx = j
            MOV ax,array[bx]                            ; ax = array[j]
            MOV b_temp,ax                               ; temp = array[j]

            ;== == == ARRAY_N == == ==
            XOR ax,ax
            MOV ax,array_n[bx]                          ; ax = array[j]
            MOV b_temp_f,ax                             ; temp = array[j]
            ;== == == == == == == == =

            XOR ax,ax
            MOV ax,b_j                                  ; ax = j
            ADD ax,2                                    ; ax = ax + 2
            MOV b_j,ax                                  ; j = j + 2

            XOR ax,ax
            XOR bx,bx

            MOV bx,b_j                                  ; bx = j
            MOV ax,array[bx]                            ; ax = array[j+1]
            MOV b_aux,ax                                ; aux = array[j+1]

            ;== == == ARRAY_N == == ==
            XOR ax,ax
            MOV ax,array_n[bx]                          ; ax = array[j +1]
            MOV b_aux_f,ax                              ; temp = array[j + 1]
            ;== == == == == == == == =

            XOR ax,ax
            MOV ax,b_j                                  ; ax = j
            SUB ax,2                                    ; ax = ax - 2
            MOV b_j,ax                                  ; j = j - 2

            MOV ax,b_temp                               ; ax = array[j]
            CMP ax,b_aux                                ; if
            JLE continue_j                              ; if (array[j] < array[j + 1]) ->> Continuar

            ; == == == == == == == == == == == == == ==
            ; == == == == == CAMBIO DE VALORES == == ==
            ;b_aux = array[k +1]
            ;b_temp = array[k]
            ;b_aux_f  = array[k +1]
            ;b_temp_f = array[k]
            XOR ax,ax 
            XOR bx,bx

            MOV bx,b_j                                  ; bx = j
            MOV ax,b_aux                                ; ax = aux(array[j + 1])
            MOV array[bx],ax                            ; array[j] = array[j + 1]

            ;== == == ARRAY_N == == ==
            XOR ax,ax
            MOV ax,b_aux_f                              ; ax = aux(array[j + 1])
            MOV array_n[bx],ax                          ; array[j] = array[j + 1]
            ;== == == == == == == == =

            XOR ax,ax
            MOV ax,b_j                                  ; ax = j
            ADD ax,2                                    ; ax = ax + 2
            MOV b_j,ax                                  ; j = j + 2

            XOR ax,ax
            XOR bx,bx

            MOV bx,b_j                                  ; bx = j
            MOV ax,b_temp                               ; ax = aux(array[j])
            MOV array[bx],ax                            ; array[j+1] = array[j]

            ;== == == ARRAY_N == == ==
            XOR ax,ax
            MOV ax,b_temp_f                             ; ax = aux(array[j])
            MOV array_n[bx],ax                          ; array[j+1] = array[j]
            ;== == == == == == == == =

            XOR ax,ax
            MOV ax,b_j                                  ; ax = j
            SUB ax,2                                    ; ax = ax - 2
            MOV b_j,ax                                  ; j = j - 2
            ; == == == == == == == == == == == == == ==
            XOR ax,ax
            MOV ax,b_j                                  ; ax = j
            ADD ax,2                                    ; ax = ax + 2
            MOV b_j,ax                                  ; j = j + 2

        JMP cycle_j 
    JMP cycle_i 

    continue_j:
        XOR ax,ax
        MOV ax,b_j      ; ax = j
        ADD ax,2        ; ax = ax + 2
        MOV b_j,ax      ; j = j + 2
    JMP cycle_j
    exit_j:
        XOR ax,ax
        MOV ax,b_i      ; ax = i
        ADD ax,2        ; ax = ax + 2
        MOV b_i,ax      ; i = i + 2
        
        MOV b_j,0d      ; j = 0 
    JMP cycle_i 
    exit_i:
        POPPER
ENDM
; ====================================== EJECUTAR MODA ====================================
execute_moda MACRO 
    PUSH BX
    PUSH AX

    XOR AX,AX                           ; limpiar variables 
    XOR BX,BX                           ; limpiar variables

    MOV b_i,0d                          ; limpiar variables

    table array_num                     ; calcula la frecuencia y lo guarda en el arreglo "tfrecuencia"
    bb_arrays tfrecuencia,tnum          ; Ordena los arreglos para que cabal cuadren en el mismo orden 

    ; print_ msg_opcion   
    ; print_array_16 tnum, tflag        ; imprime el listado de nuemeros del arreglo de numeros

    MOV bx,tflag                        ; bx = contador
    SUB bx,2                            ; bx = bx - 2 
    MOV ax,tnum[bx]                     ; ax = array[bx]
    MOV b_i,ax                          ; i = ax
    
    print_ msg_opcion
    PRINT_16 b_i

    POP AX
    POP BX
ENDM 
; ====================================== pintar barras ====================================
; @param array : array de frecuencias 
; @param array_n : array de numeros-frecuencia
; width_bar                        ; Ancho de la barra
; high_bar                         ; Alto de barra
;array,array_n
paint_graph_asc MACRO 
    LOCAL first_cycle,exit_cycle__ ,paint_init,paint_other
    PUSHER_ALL
    CLEAN_RECORDS_ALL

    clean_screen
    table array_num                     ; calcula la frecuencia y lo guarda en el arreglo "tfrecuencia"
    bb_arrays tfrecuencia,tnum          ; Ordena los arreglos para que cabal cuadren en el mismo orden 

    MOV b_aux,0d        
    MOV b_temp,0d                       ; variable auxialar para calcular altura
    CALL INIT_VIDEO
    CALL PAINT_AXIS

    ; == == == CALCULAR ANCHO-MAX BARRA == ==
    MOV ax,560d                         ; Ancho de maximo de la pantalla
    MOV bx,12                       ; 12 barras en total
    DIV bx                              ; ax = ax/bx ->> ax = 560/12
    SUB ax,5d                           ; ax = ax - 5
    MOV width_bar,ax                    ; ancho = ax
    ; == == == == == == == == == == == == ==

    first_cycle:
        CMP si,24
        JE exit_cycle__
        CMP si,0d
        JE paint_init
    JMP paint_other

    paint_init:
        ; == == == ANCHO INCIAL == == ==
        XOR ax,ax 
        XOR bx,bx
        XOR cx,cx 
        MOV width_bar_init,38d          ; anchoInicial = 38d
        MOV ax,width_bar                ; ax = anchoBarra
        ADD ax,width_bar_init           ; ax = ax + anchoInicial
        MOV width_bar_end,ax            ; anchoFinal = ax
        ; == == == == == == == == ==  == 
        ; == == == ALTURA INCIAL == == ==
        XOR ax,ax
        XOR dx,dx 
        
        MOV ax,tfrecuencia[si]          ; ax = frecuencia[i]
        MOV high_bar,ax                 ; alto = ax
        MOV b_temp,ax                   ; temp = frecuencia[i]

        MOV ax,high_bar                 ; ax = altura
        MOV bx,329d                     ; bx = 329
        MUL bx                          ; ax = ax * bx -<< 329 * altura
        MOV high_bar,ax                 ; altura = ax

        MOV ax,high_bar                 ; ax = altura
        MOV bx,100d                     ; bx = 100d ->> cambiar
        DIV bx                          ; ax = altura/100 -<< (329 * altura) / 100d
        MOV high_bar,ax                 ; altura = ax 

        MOV ax,429d                     ; ax = 429
        SUB ax,high_bar                 ; ax = ax - altura
        MOV high_bar,ax                 ; altura = ax
        ; == == == == == == == == == == =
        ; paint_bar width_bar_init,width_bar_end,100d,429d,9d
        paint_bar width_bar_init,width_bar_end,high_bar,429d,9d         ; PINTAR BARRA
        ; == == == PINTAR PALABRA == == ==
        XOR ax,ax
        MOV b_aux,0d                            ; aux = 0
        MOV ax,tnum[si]                         ; ax = array[i]
        MOV b_aux,ax                            ; aux = ax
        graph_word_vertical b_aux,width_bar_end
        ADD si,2
        ; == == == == == == == == == == ==
    JMP first_cycle

    paint_other:
        ; == == == ANCHO OTROS == == ==
        XOR ax,ax 
        XOR bx,bx
        XOR cx,cx 
        MOV ax,width_bar_end            ; ax = anchoFinal
        ADD ax,5d                       ; ax = ax + 5
        MOV width_bar_init,ax           ; anchoInicial = ax

        MOV ax,width_bar_init           ; ax = anchoInicial
        ADD ax,width_bar                ; ax = ax + anchoBarra
        MOV width_bar_end,ax            ; anchoFinal = ax
        ; == == == == == == == == ==  ==
        ; == == == ALTURA INCIAL == == ==
        XOR ax,ax
        XOR dx,dx 
        
        MOV ax,tfrecuencia[si]          ; ax = frecuencia[i]
        MOV high_bar,ax                 ; alto = ax
        MOV b_temp,ax                   ; temp = frecuencia[i]

        MOV ax,high_bar                 ; ax = altura
        MOV bx,329d                     ; bx = 329
        MUL bx                          ; ax = ax * bx -<< 329 * altura
        MOV high_bar,ax                 ; altura = ax

        MOV ax,high_bar                 ; ax = altura
        MOV bx,100d                     ; bx = 100d ->> cambiar
        DIV bx                          ; ax = altura/100 -<< (329 * altura) / 100d
        MOV high_bar,ax                 ; altura = ax 

        MOV ax,429d                     ; ax = 429
        SUB ax,high_bar                 ; ax = ax - altura
        MOV high_bar,ax                 ; altura = ax
        ; == == == == == == == == == == =
        paint_bar width_bar_init,width_bar_end,high_bar,429d,9d 
        ; == == == PINTAR PALABRA == == ==
        XOR ax,ax
        MOV b_aux,0d                            ; aux = 0
        MOV ax,tnum[si]                         ; ax = array[i]
        MOV b_aux,ax                            ; aux = ax
        graph_word_vertical b_aux,width_bar_end
        ADD si,2
        ; == == == == == == == == == == ==
    JMP first_cycle


    exit_cycle__:
        POPPER_ALL
        pause_
        MOV ah,01h      ; NO BOTAR EL PROGRAMA
        INT 21h
ENDM 
; ====================================== PAIN WORD GRAPH ====================================
; @param num: numbero a imprimir
; @param bar_end: posición donde termina la barra
graph_word_vertical MACRO number,bar_end
    LOCAL verify_num,two_digits,exit_verify,three_digits 
    PUSHER
    CLEAN_RECORDS

    clean_str str_num_3
    MOV ax,number
    int_to_string str_num_3

    XOR ax,ax
    MOV scale_result,0d
    MOV ax,bar_end          ; AX = finBarra
    MOV bx,73d              ; bx = 73 ->> columna donde termina el apuntador para pintar la palabra
    MUL bx                  ; ax = finBarra * 73
    MOV scale_result,ax     ; escala = ax

    MOV bx,598d             ; ax = 598 ->> columna donde termina el espacio para pintar la barra
    MOV ax,scale_result     ; ax = escala
    DIV bx                  ; ax = ax / bx
    SUB ax,2d               ; ax = ax - 2
    MOV scale_result,ax     ; scala = ax

    verify_num:
        CMP number,99       ; if
        JLE two_digits      ; if (number <= 99) ->> salta si es menor que 99

        CMP number,100
        JGE three_digits
       
    JMP three_digits      

    two_digits:
        clean_str str_num_2
        XOR ax,ax 
        mov ax,number
        int_to_string str_num_2

        xor ax,ax
        mov ax,scale_result
        mov cursor_column,al
        paint_word_vertical str_num_2,cursor_column,27d,15d
    JMP exit_verify 

    three_digits:
        ; == == TRES DIGITOS == ==
        xor ax,ax
        mov ax,scale_result
        mov cursor_column,al
        paint_word_vertical str_num_3,cursor_column,27d,15d
        ; == == == == == == == == =
    JMP exit_verify    

    exit_verify:
        POPPER
ENDM


; ====================================== FRECUENCIA-SIN DUPLICADOS ====================================
; GUARDA EN NUEVO ARREGLO LA FRECUENCIA SIN DATOS DUPLICADOS
; @param array : array de frecuencias 
frecuencia MACRO array
    LOCAL exit_cycle,struct,is_equal,first_cycle
    PUSHER_ALL
    CLEAN_RECORDS

    first_cycle:


ENDM 