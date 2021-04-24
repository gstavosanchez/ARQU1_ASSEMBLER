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