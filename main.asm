include macros.asm
.model small
.stack
.data
  ; ml \code\main.asm
  ;msg_hello db 10,13,7, 'Hola mundo','$'
  ; == == == == == == ==  ==
  buffer_num db 30d dup("$")    ; Buffer del numero temporal,lo guarda en un arreglo de string
  cadena db '10'
  index_column db 0             ; posición del char en la columna para pintar la letra
  axis_y dw 0d                  ; Valor de inicio de la y para pintar el eje y 
  axis_x dw 0d                  ; Valor de inicio de la y para pintar el eje y 
.code

  MOV ax,@data
  MOV ds,ax

  ;mov ax,4c00h            ; Tipo de operacion RETORNAR el control al sistema
  ;int 21h                 ; interrupcion del dos

  CALL INIT_VIDEO           ; Iniciar el modo de video
  paint_word cadena,2d,1d,14d
  CALL PAINT_AXIS

  MOV ah,01h      ; NO BOTAR EL PROGRAMA
  INT 21h

  

.exit
INIT_VIDEO PROC
  MOV ax,0012h    ; Entrar en modo video
  INT 10h         ; 
  RET
INIT_VIDEO ENDP
PAINT_AXIS PROC
  ; == == == PAINT AXIS == == ==
  paint_axis_y 35d,450d,32d,4d
  paint_axis_x 32d,600d,450d,4d
  ; == == == == == == == == == =
  RET 
PAINT_AXIS ENDP
end

;m_print msg_opcion
    ;mov ax,flag
    ;m_int_to_str buffer_num
    ;m_print buffer_num
