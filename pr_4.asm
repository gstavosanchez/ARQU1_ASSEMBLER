include mc_4.asm
.model small
.stack 
.data 
    ; ANTES era ml /code/pr_4.asm
    ; masm pr_4.asm
    ; link pr_4.obj;
    ; pr4.exe
    msg_back db '=============== BACK MENU ==============',0dh,0ah
             db '== 1. Salir                           ==',0dh,0ah
             db '== Regresa culaquire tecla.           ==',0dh,0ah
             db '==                                    ==',0dh,0ah
             db '========================================',0dh,0ah,'$'
    msg_bb db 'Ordenamiento: BUBBLE SORT','$'
    msg_num db '52','$'
    ; ================ DATOS DE LA CARATULA ==================================
    msg_cover db '=========== DATA INFORMATION ===========',0dh,0ah
         db '== Universidad de San Carlos          ==',0dh,0ah
         db '== Facultad de Ingenieria             ==',0dh,0ah
         db '== Escuela de Ciencias y Sistemas     ==',0dh,0ah
         db '== Arquitectura de Computadoras 1     ==',0dh,0ah
         db '== Seccion  A                         ==',0dh,0ah
         db '== Primer Semestre                    ==',0dh,0ah
         db '== Elmer Gustavo Sanchez Garcia       ==',0dh,0ah
         db '== 201801351                          ==',0dh,0ah
         db '== Practica No.4                      ==',0dh,0ah
         db '========================================',0dh,0ah,'$'
    ; ================ DATOS DEL MENU =======================================
    msg_menu db '========================================',0dh,0ah
         db '=============== MAIN MENU ==============',0dh,0ah
         db '== 1. Cargar Archivo                  ==',0dh,0ah
         db '== 2. Ordenar                         ==',0dh,0ah
         db '== 3. Generar Reporte                 ==',0dh,0ah
         db '== 4. Salir                           ==',0dh,0ah
         db '========================================',0dh,0ah,'$'
            
    opcion db 0
    msg_opcion db 10,13,7, '>> ','$'
    msg_h db 10,13,7, '>> Inicio','$'
    ; ==================== ======== CARGAR ARCHIVO ======== ======================
    msg_load_file db '=============== LOAD FILE ==============',0dh,0ah
                  db '== Ingrese la ruta                    ==',0dh,0ah
                  db '== Ejemplo [ archivo.xml ]            ==',0dh,0ah
                  db '========================================',0dh,0ah,'$'
    msg_error_open db 10,13,7, ">> Error al abrir el archivo","$"
    msg_error_read db 10,13,7, ">> Error en la lectura del archivo","$"
    ; ==================== ========  ORDENAR ======== ============================
    msg_sort db '=============== SORT MENU ==============',0dh,0ah
             db '== 1. Bubble Sort                     ==',0dh,0ah
             db '== 2. Quick Sort                      ==',0dh,0ah
             db '== 3. Shell Sort                      ==',0dh,0ah
             db '== 4. Regresar                        ==',0dh,0ah
             db '========================================',0dh,0ah,'$'
    ; ==================================== =======================================
    read_handler dw ?
    buffer_read db 50 dup('$'); Para almecenar texto pedido en consola
    read_text_file db 2500 dup('$') ; Almacena los datos leidos del archivo
    number_list db 100 dup('$'); Arreglo de numeros guardados del archivo en formato texto -> AHORA varible auxiliar almacena un numero
    number_array db 25 dup(0); ARREGLO DE NUMEROS <- <<- <- <<-
    aux_number db 10 dup('$'); variabl auxilar para guardar un numero
    flag dw 0d; Contador auxiliar para guardar en arreglo de numeros , TAMAÑO DEL ARREGLO
    aux dw 10d; tamaña del arreglo, tiene que ser dinamico
    ; == == BUBBLE SORT == ==
    bb_p db 0 ; variable auxiliar
    bb_j db 0; variable auxliar
    bb_aux db 0; variable auxiliar;
    ; == == == == == == == ==
    ; == == == PINTAR == == ==
    paint_init dw 0d
    paint_end dw 0d
    paint_size dw 0d
    paint_height dw 0d;
    value_array dw 0d; Guarda el valor actual del array array[i]
    ; == == == == == == ==  ==
    buffer_num db 30d dup("$"); Buffer del numero temporal
    
.code 
    mov ax,@data ;MOVER DONDE IMPIEZA LA DATA;MOV PARAMETRO1, PARAMETRO2; MUEVE LO QUE TENGA EN EL PARAMETRO 2 AL PARAMETRO 1 : AX <- @DATA; ax = @data; 
    mov ds,ax; MOVE VALOR DE AX A DS

    ; ======================= MOSTRAR CARATULA =============================
    m_clean_screen
    m_print msg_cover
    m_pause
    ; =============================== MAIN MENU =============================
    main_menu:
        m_clean_screen
        m_print msg_menu
        m_save_char
        
        ; ======================= OPCION 4  "SALIR" =======================
        cmp opcion,34h ;"5 = ascci 53 -> 34 hexadecimal"
        je exit_main_menu
        ; ======================= OPCION 1 "CARGAR ARCHIVO" =======================
        cmp opcion,31h ; "1 = ascci 49 -> 31 HEXADECIMAL " 
        je load_file 
        ; ======================= OPCION 2 "ORDENAR" =======================
        cmp opcion,32h ; "2 = ascci 50 -> 32 HEXADECIMAL " 
        je sort_data
        ; ======================= OPCION 3 "GENERAR REPORTE" =======================
        cmp opcion,33h; "3 = ascci 50 -> 32 HEXADECIMAL " 
        je generate_report

    jmp main_menu
    exit_main_menu:
        .exit
    

.exit
; =========================== CARGAR ARCHIVO ===============================
load_file:
    m_clean_screen
    m_print msg_load_file
    m_save_string buffer_read
    
    ; ==  LECTURA DE ARCHIVO ==
    m_open_file buffer_read,read_handler ; parametros : ruta del archivo, handler
    m_read_file read_text_file,read_handler; paametros : texto donde se almacena "read_text_file", handler
    m_close_file read_handler; parametros; handler
    ; == == == == == == == == ==
    ; == == CARGAR A ARRAY == ==
    m_get_number_list read_text_file ; guarda en el arreglo "number_list"
    m_set_number_array number_list; recorre el arreglo de string de numeros "10 20 30" y los almacena en arreglo numerico (number_array)    
    m_print_array8 number_array, flag ; imprime el listado de nuemeros del arreglo de numeros
    ; == == == == == == == == ==
    m_back_main_menu
.exit
; =========================== ORDENAR DATOS =================================
sort_data:
    ;m_print msg_opcion
    ;mov ax,flag
    ;m_int_to_str buffer_num
    ;m_print buffer_num
    m_paint_bb number_array
    m_back_main_menu
.exit
; =========================== GENARAR REPORTE  =================================
generate_report:
.exit
; =========================== INICIO-FIN VIDEO  =================================
INIT_VIDEO proc
    mov ax,0013h
    int 10h
    mov ax,0A000h
    mov ds,ax
    ret
INIT_VIDEO endp
END_VIDEO proc
    mov ax,0003h
    int 10h
    mov ax,@data
    mov ds,ax
    ret
END_VIDEO endp
; =========================== MODO DATOS-VIDEO  =================================
DS_DATA proc; REGRESA  al mode de datos
    push ax
    mov ax,@data
    mov ds,ax
    pop ax
    ret
DS_DATA endp 

DS_VIDEO proc; regresa al mode de video
    push ax
    mov ax,0A000h
    mov ds,ax
    pop ax
    ret
DS_VIDEO endp 
end