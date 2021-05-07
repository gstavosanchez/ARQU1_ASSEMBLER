; ============================================== MACROS =====================================
clean_screen macro
  mov ah,0fh
  int 10h
  mov ah,0
  int 10h
endm
clean_str macro string
  local repetir_loop 
  push cx
  push si

  xor si, si
  xor cx, cx
  mov cx, SIZEOF string

  repetir_loop:
      mov string[si], 24h
      inc si
  Loop repetir_loop
  pop si
  pop cx
endm
; =============== IMPRIMIR EN PANTALLA ======================
print_ MACRO string 
  mov ah,09h; (09h) Visualizar cadena en pantalla
  lea dx,string 
  int 21h 
ENDM 
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
; ======================== SAVE STRING ======================
; SAVE STRING REQUIRED IN CONSOLE
; @param buffer: var where it is stored
save_string macro buffer
  LOCAL ObtenerChar, FinOT
  XOR si, si
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

EXECUTE_MUL MACRO
  LOCAL ciclo,salir_ciclo,verify_neg,ciclo_neg,salir_neg
  PUSH AX
  PUSH BX
  PUSH CX
  XOR ax,ax
  XOR bx,bx
  XOR cx,cx

  MOV cx,0000h
  MOV result,0d

  verify_num:
    CMP number_2,0        ; if
    JGE ciclo             ; if(number >= 0) ->> ciclo

    CMP number_2,0        ; if
    JL ciclo_neg          ; if (number < 0) -<< negativo
  JMP ciclo
  ciclo:
    CMP cx,number_2       ; if
    JE salir_ciclo        ; if (cx == number 2) ->> salir

    MOV ax,result
    ADD ax,number_1
    MOV result,ax
    INC cx
  JMP ciclo

  ciclo_neg:
    CMP cx,number_2       ; if
    JE salir_neg        ; if (cx == number 2) ->> salir

    MOV ax,result
    ADD ax,number_1
    MOV result,ax
    DEC cx
  JMP ciclo_neg

  salir_neg:
    print_ msg_result
    MOV ax,result
    NEG ax
    int_to_string buffer_num
    print_ buffer_num
    POP cx
    POP bx
    POP ax
  JMP main_while

  salir_ciclo:
    print_ msg_result
    MOV ax,result
    int_to_string buffer_num
    print_ buffer_num
    POP cx
    POP bx
    POP ax
ENDM

; ==========================================================================================
.model small
.stack
.data
  msg_cover db '============= EXAMEN FINAL ===========',0dh,0ah
          db '== Arquitectura de Computadoras 1     ==',0dh,0ah
          db '== Seccion  A                         ==',0dh,0ah
          db '== Primer Semestre                    ==',0dh,0ah
          db '== Elmer Gustavo Sanchez Garcia       ==',0dh,0ah
          db '== 201801351                          ==',0dh,0ah
          db '== Examen Final                      ==',0dh,0ah
          db '========================================',0dh,0ah,'$'
  number_1 dw 0d                  ; guarda el primer numero
  number_2 dw 0d                  ; guarda el segundo numero
  result dw 0d                    ; Guarda el resultado de operación
  buffer_str db 20d dup("$")      ; Buffer string ,arreglo de string multiproposito(numeros,datos de consola) 
  buffer_num db 10d dup("$")    
  msg_result db 10,13,7, '>> Resultado: ','$'
  msg_num_1 db 10,13,7, ">> Numero 1: ","$"
  msg_num_2 db 10,13,7, ">> Numero 2: ","$"
.code
  MOV ax,@data
  MOV ds,ax

  clean_screen
  print_ msg_cover
  main_while:
    CALL SAVE_NUM_1
    CALL SAVE_NUM_2
    EXECUTE_MUL
  JMP main_while

  exit_main_menu:
    .exit
 
.exit
SAVE_NUM_1 PROC
  PUSH AX
  XOR AX,AX

  MOV number_1,0d

  print_ msg_num_1
  clean_str buffer_str
  save_string buffer_str
  str_to_int buffer_str
  MOV number_1,ax

  POP AX
  RET
SAVE_NUM_1 ENDP

SAVE_NUM_2 PROC
  PUSH AX
  XOR AX,AX

  MOV number_2,0d
  print_ msg_num_2

  clean_str buffer_str
  save_string buffer_str
  str_to_int buffer_str
  MOV number_2,ax

  POP AX
  RET
SAVE_NUM_2 ENDP

end