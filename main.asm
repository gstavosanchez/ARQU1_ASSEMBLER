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
  msg_cmdp db 10,13,7, '>> ejecuntado promedio','$'
  msg_err db 10,13,7, '>> opcion incorrecta','$'
  msg_opcion db 10,13,7, '>> ','$'
  msg_error_open db 10,13,7, ">> Error al abrir el archivo","$"
  ; == == == == == == ==  ==
  aux_number db 3 dup('$')      ; Almacenara el numero momentaneamente para despues guardarlo en un arreglo
  array_num dw 1200 dup(0)      ; Arreglo de tipo numeros   
  buffer_file db 1000 dup('$')  ; Almacena los datos leidos del archivo
  buffer_str db 60d dup("$")    ; Buffer string ,arreglo de string multiproposito(numeros,datos de consola)
  decimal dw 0d                 ; Guarda el numero decimal de cualquier resultado
  entero dw 10d                 ; Guarda el numero entero de la respuesta  
  file_name db 30d dup("$")     ; almacena el nombre del archivo a leer 
  file_handler dw ?             ; Handler file
  flag dw 0d                    ; Contador auxiliar para guardar en arreglo de numeros , TAMAÑO REAL DEL ARREGLO 
  flag_2 dw 0d                  ; Cantidad de numeros en el arreglo 
  number_list db 1200 dup('$')  ; Arreglo de numeros guardados del archivo en formato texto -> AHORA varible auxiliar almacena un numero
  result dw 0d                  ; Guarda el valor de culquier entero 
  dot db '.','$'                ; punto para los decimales
  buffer_num db 10d dup("$")    
  b_size dw 0d;                 ; size aux para el ordenamiento
  b_i dw 0d                     ; var i para el ordenamiento
  b_j dw 0d                     ; var j para el ordenamiento
  b_aux dw 0d                   ; aux = array[k +1]
  b_temp dw 0d                  ; temp = array[k]
  b_aux_f dw 0d                 ; aux_f = array[k +1]
  b_temp_f dw 0d                ; temp_f = array[k]
  
  tflag dw 0
  tfrecuencia dw 1200 dup(0)
  tnum dw 1200 dup(0)           ; guarda numero actual para aumentar su frecuencia
  ;array_frecuencia              ; gurada la frecuencia sin numeros duplicados
  width_bar dw 0d               ; Ancho de la barra
  high_bar dw 0d                ; Alto de barra
  width_bar_init dw 0d          ; Ancho inicial de la barra
  width_bar_end dw 0d           ; Ancho final de la barra
  bigger_num dw 0d              ; numero mas grande 
  ; == == == VARIABLES TO PAINT == == == == 
  axis_y dw 0d                  ; Valor de inicio de la y para pintar el eje y 
  axis_x dw 0d                  ; Valor de inicio de la x para pintar el eje x
  bar_x dw 0d                   ; Valor de inicio de la x para pintar la barra(ancho)
  bar_y dw 0d                   ; valor de inicio de la y para pintar la barra(altura)
  index_column db 0             ; posición del char en la columna para pintar la letra
  ; == == == == == == == == == == == ==  ==
  curr_letter db 0              ; letra actual del interprete
  str_num_2 db 2d dup("$")
  str_num_3 db 3d dup("$")
  scale_result dw 0d            ; Guarda la escala para pintar las palabras

  cursor_row db 0
  cursor_column db 0
  cero_ db '00'
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
  paint_axis_y 40d,430d,32d,4d
  paint_axis_x 32d,600d,430d,4d
  ; == == == == == == == == == =
  RET 
PAINT_AXIS ENDP
end
  ; == == == TEST == == ==
  ;print msg_opcion
  ;mov ax,flag_2
  ;int_to_string buffer_num
  ;print_ buffer_num
  ; == == == =  = == == ==

    ; CALL INIT_VIDEO           ; Iniciar el modo de video
  ; mov ax,numb_tempp
  ; int_to_string str_num_2
  ; paint_word_vertical str_num_2,8d,27d,14d
  ; paint_bar 38d,88d,100d,431d,9d
  ; CALL PAINT_AXIS
  ; MOV ah,01h      ; NO BOTAR EL PROGRAMA
  ; INT 21h
