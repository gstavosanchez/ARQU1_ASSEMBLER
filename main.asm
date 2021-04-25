include macros.asm
.model small
.stack
.data
  ; ml \code\main.asm
  ;msg_hello db 10,13,7, 'Hola mundo','$'
  ; ====================== ====== DATOS DE LA CARATULA ==================================
  msg_cover db '=========== DATA INFORMATION ===========',0dh,0ah
            db '== Arquitectura de Computadoras 1     ==',0dh,0ah
            db '== Seccion  A                         ==',0dh,0ah
            db '== Primer Semestre                    ==',0dh,0ah
            db '== Elmer Gustavo Sanchez Garcia       ==',0dh,0ah
            db '== 201801351                          ==',0dh,0ah
            db '== Proyecto No.2                      ==',0dh,0ah
            db '========================================',0dh,0ah,'$'
  msg_input db 10,13,7, '>> Ingrese Comando','$'
  msg_cmd db 10,13,7, '>> ejecuntado salir','$'
  msg_err db 10,13,7, '>> opcion incorrecta','$'
  msg_opcion db 10,13,7, '>> ','$'
  msg_error_open db 10,13,7, ">> Error al abrir el archivo","$"
  ; == == == == == == ==  ==
  aux_number db 3 dup('$')      ; Almacenara el numero momentaneamente para despues guardarlo en un arreglo
  array_num dw 1200 dup(0)      ; Arreglo de tipo numeros   
  buffer_file db 1000 dup('$')  ; Almacena los datos leidos del archivo
  buffer_str db 50d dup("$")    ; Buffer string ,arreglo de string multiproposito(numeros,datos de consola)
  file_name db 30d dup("$")     ; almacena el nombre del archivo a leer 
  file_handler dw ?             ; Handler file
  flag dw 0d                    ; Contador auxiliar para guardar en arreglo de numeros , TAMAÑO DEL ARREGLO 
  number_list db 1200 dup('$')  ; Arreglo de numeros guardados del archivo en formato texto -> AHORA varible auxiliar almacena un numero
  ; == == == VARIABLES TO PAINT == == == == 
  axis_y dw 0d                  ; Valor de inicio de la y para pintar el eje y 
  axis_x dw 0d                  ; Valor de inicio de la x para pintar el eje x
  bar_x dw 0d                   ; Valor de inicio de la x para pintar la barra(ancho)
  bar_y dw 0d                   ; valor de inicio de la y para pintar la barra(altura)
  index_column db 0             ; posición del char en la columna para pintar la letra
  ; == == == == == == == == == == == ==  ==
; ----------------------------------------------- SEGMENTO DE CODIGO ----------------------------------------------
.code

  MOV ax,@data
  MOV ds,ax

  ; ======================= MOSTRAR CARATULA =============================
  clean_screen
  print_ msg_cover
  pause_
  clean_screen                    ; limpiar pantalla
  print_ msg_input                ; mensaje de ingresar comando 
  ; ======================= MAIN WHILE =============================
  main_init_while:
    save_string buffer_str        ; guardar string
    inteprete buffer_str          ; instrepretar string

  JMP main_init_while

  exit_main_menu:
    .exit

.exit
INIT_VIDEO PROC
  MOV ax,0012h    ; Entrar en modo video
  INT 10h         ; 
  RET
INIT_VIDEO ENDP
PAINT_AXIS PROC
  ;CALL INIT_VIDEO           ; Iniciar el modo de video
  ;paint_word cadena,2d,1d,14d
  ;paint_bar 38d,88d,100d,449d,9d
  ;CALL PAINT_AXIS

  ;MOV ah,01h      ; NO BOTAR EL PROGRAMA
  ;INT 21h

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
