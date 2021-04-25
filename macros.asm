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

        str_to_int aux_number         ; Se convierte el texto en numero
        mov array_num[bx],ax            ; se mueve a number_array[bx], lo que esta en ax(numero)

        clean_str aux_number          
        ; == =================== ==
        mov di,0000h;
        inc si
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

    ; MOV AX,COLUMN

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
    MOV bar_x,0d
    MOV bar_y,0d

    MOV bar_x,left              ; Inicia en algun lugar de la izquierda 
    while_1:
        MOV bar_y,up            ; Inicia en algun lugar de arriba 
        while_2:
            paint_pixel bar_y,bar_x,color 
            INC bar_y 
            CMP bar_y,down      ; Termina en algun lugar de abajo
        JNZ while_2             ; if (y != down) ->> Saltar a while 2

        INC bar_x
        CMP bar_x,right         ; if : Termina en algun lugar de la derecha
    JNE while_1                 ; if (x != right) ->> saltar while 1
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
    LOCAL main_while,exit_while,cmd_exit,execute_exit,cmd_err,cmd_file,execute_file,save_path
    PUSHER_ALL
    CLEAN_RECORDS_ALL
    clean_str file_name                ;limpiar variable
    main_while:
        CMP string[si],73h          ; if
        JE cmd_exit                 ; if (data[x] == s) ->> ir a comando exit

        CMP string[si],61h          ; if
        JE cmd_file                 ; if (data[x] == a) ->> ir a comando file 

        INC si 
        CMP string[si],24h          ; if
        JZ cmd_err                  ; if (data[x] == $) ->> regresar main while 
    JMP cmd_err
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
        print_array_16 array_num, flag           ; imprime el listado de nuemeros del arreglo de numeros
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