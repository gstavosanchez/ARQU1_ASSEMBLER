mPrint macro string
  mov ah,09h; (09h)Sirve para visualizadr una cadena de caracteres
  lea dx,string
  int 21h
endm

mClearSC macro ; Sirve para limpiar pantalla
    mov ah,0fh
    int 10h
    mov ah,0
    int 10h
endm

mPause macro ; Sirve para hacer una pausa al sistema, vuelve funcionar press cualquier tecla
    mov ah,7
    int 21h
endm

mBackMainMenu macro; Sirve para regresar al menu principal
    mPrint msgBack
    mPrint msgOpcion
    ; =========== CAPTURA DE UN CARACTER =========== 
    mov ah,01h ; instruccion para guardar un carecter
    int 21h
    mov opcion,al ; se mueve a opcion lo que esta en al
    ; =========== REGRESAR =========== 
    cmp opcion,49; Si  presiona 1 salir
    je exitCMD
    jmp main
endm

mSaveNumberFact macro; Sirve para guardar un numero en memoria
    mPrint msgOpcion
    ; Lea la entrada del teclado 
    mov ah,3fh ; Lectura de Fichero o dispositivo
    mov bx,00
    mov cx,100
    mov dx,offset[number_str]
    int 21h

    mStrToInt number_str
    mov factCount,ax
    ;intToString buffer_num
    ;mPrint buffer_num

endm
;convierte una cadena a numero, este es guardado en AX.
mStrToInt macro numStr
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

intToString macro numStr 
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

