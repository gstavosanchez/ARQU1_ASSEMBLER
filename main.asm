include macros.asm
.model small 
.stack
.data 
    opcion db 0
    ; ========= VARIABLES PARA ALMACENAR UN NUMERO ==============
    units db 0d; Unidades
    tens db 0d; Decenas 
    number dw 0d; numero genereado 
    buffer_num db 30d dup("$"); Buffer del numero temporal
    number_str db 100 dup(' '),'$'
    ; ========= VARIABLES PARA FACTORIAL UN NUMERO ==============
    factResult dw 1d
    factCount dw 0d
    factCountAux dw 1d
    ; ========= VARIABLES PARA CALCULADORA ==============
    calcNum1 dw 0d;
    calcNum2 dw 0d;
    calcResult dw 0d;
    calcType db 0;
    calcCount db 0;
    number_str_calc1 db 100 dup(' '),'$'
    number_str_calc2 db 100 dup(' '),'$'
    calcFlag db 0;
    ; ========= VARIABLES PARA LEER ARCHIVOS ==============
    file_name db "a.txt",00h; Nombre del archivo
    bufferRead db 500d dup("$"); Buffer de lectura de archivos
    textFile db 5 dup('$')
    handler dw ?
    getPathFile db 100 dup(' '),'$'
    ; ========= VARIABLES PARA LEER ARCHIVOS ==============
    ;concat_string db 100 dup('$')
    concat_string db 100 dup('mundo $')
    contador dw 0000h;
    test1 db 100 dup('hola $')
    ; ========= VARIABLES PARA ESCRIBIR ARCHIVOS ==============
    wFfileName db "report.htm",00h
    msgWfSalto db 0ah, 0dh, '  ', '$' 
    msgWfIng db 0ah, 0dh, '>> Ingrese el nombre archivo: ', 0ah, 0dh, ' Ejemplo: (c:nombre.htm)', '$' 
    wfHandler dw ?
    prueba db 10, '<h1> Hola </h1> </br>',' '
    prueba2 db 10, '<h2> Hola jdkfjdf </h2> </br>',' '
    wFbufferent db 50 dup('$')
    ; ========= VARIABLES   REPORTES ==============
    idList dw 10 dup(0),'$'
    resultList dw 10 dup ('$'),'$'
    ; ================ MENU PRINCIPAL ==================================
    msgM0 db 10,13,7, "=================================","$"
    msgM1 db 10,13,7, "=========== MAIN MENU ===========","$" ; Titulo del menu
    msgM2 db 10,13,7, "== 1. Cargar Archivo           ==","$" ; Opcion 1 del menu Cargar Archivo
    msgM3 db 10,13,7, "== 2. Modo Calculadora         ==","$" ; Opcion 2 del menu Modo Calculadora
    msgM4 db 10,13,7, "== 3. Factorial                ==","$" ; Opcion 3 del menu Modo Calculadora
    msgM5 db 10,13,7, "== 4. Crear Reporte            ==","$" ; Opcion 4 del menu Crear reporte
    msgM6 db 10,13,7, "== 5. Salir                    ==","$" ; Opcion 5 salir
    msgM7 db 10,13,7, "=================================","$"
    msgOpcion db 10,13,7, '>> ','$'
    msgBack db 10,13,7, '>> Salir presione 1, Regresar cualquier tecla','$'

    ; ================ MENU FACTORIAL ==================================
    msgF db 10,13,7, "============ FACTORIAL ============","$"
    msgNum db 10,13,7, ">> Ingrese un Numero","$"
    msgFZero db  "0! = 1","$"
    msgWarinig db 10,13,7, ">> Numero fuera de rango,debe ser 0 <= x <= 7 ","$"
    msgFPor db  "*","$"
    msgFIgual db  "=","$"
    msgFSpace db 10,13,7, ">> ","$"
    msgFDIgual db  "! = ","$"

    ; ================ DATAOS DE LA CARATULA ==================================
    msgC0 db 10,13,7, "=========== DATA INFORMATION ===========","$"
    msgC1 db 10,13,7, "== Universidad de San Carlos          ==","$"
    msgC2 db 10,13,7, "== Facultad de Ingenieria             ==","$"
    msgC3 db 10,13,7, "== Escuela de Ciencias y Sistemas     ==","$"
    msgC4 db 10,13,7, "== Arquitectura de Computadoras 1     ==","$"
    msgC5 db 10,13,7, "== Seccion  A                         ==","$"
    msgC6 db 10,13,7, "== Primer Semestre                    ==","$"
    msgC7 db 10,13,7, "== Elmer Gustavo Sanchez Garcia       ==","$"
    msgC8 db 10,13,7, "== 201801351                          ==","$"
    msgC9 db 10,13,7, "== Primera Practica                   ==","$"
    msgM10 db 10,13,7, "========================================","$"

    ; ================ MENU CALCULADORA ==================================
    msgCalc db 10,13,7, "============ CALCULATOR MODE ============","$"
    msgCalc1 db 10,13,7, ">> Ingrese un Numero, format: 00","$"
    msgCalc2 db 10,13,7, ">> Ingrese un operado o ';' para finalizar","$"
    msgCalc3 db 10,13,7, ">> Resultado: ","$"
    msgCalc4 db 10,13,7, ">> Simbolo Invalido :c ","$"
    msgCalc5 db 10,13,7, ">> Ingrese su 2do Numero, format: 00","$"
    msgCalc6 db 10,13,7, ">> Ingrese un operado","$"
    msgCalc7 db 10,13,7, ">> Solo se acepta 10 operaciones como maximo","$"

    ; ================ LECTURA DE ARCHIVO ==================================
    msgRF db 10,13,7, ">> Error al abrir el archivo","$"
    msgRF1 db 10,13,7, ">> Error en la lectura del archivo","$"



    
.code
    mov ax,@data ;MOVER DONDE IMPIEZA LA DATA;MOV PARAMETRO1, PARAMETRO2; MUEVE LO QUE TENGA EN EL PARAMETRO 2 AL PARAMETRO 1 : AX <- @DATA; ax = @data; 
    mov ds,ax; MOVER VALOR DE AX A DS

    ; =========== INFORMACION DE LOS DATOS ===========
    mClearSC
    mPrint msgM10
    mPrint msgC0
    mPrint msgC1
    mPrint msgC2
    mPrint msgC3
    mPrint msgC4
    mPrint msgC5
    mPrint msgC6
    mPrint msgC7
    mPrint msgC8
    mPrint msgC9
    mPrint msgM10
    mPause

    main:
        ; =========== MENU PRINCIPAL ===========
        mClearSC 
        mPrint msgM0
        mPrint msgM1
        mPrint msgM2
        mPrint msgM3
        mPrint msgM4
        mPrint msgM5
        mPrint msgM6
        mPrint msgM7
        mPrint msgOpcion
        ; =========== CAPTURA DE UN CARACTER =========== 
        mov ah,01h ; instruccion para guardar un carecter
        int 21h
        mov opcion,al ; se mueve a opcion lo que esta en al
        
        ; ======================= OPCION 5  "SALIR" =======================
        cmp opcion,53; "5 = ascci 53"  Compara si es 5 para salir
        je exitCMD ; salto a la etiqueta exitCMD

        ; ======================= OPCION 1 "CARGAR ARCHIVO" =======================
        cmp opcion,49 ; "1 = ascci 49" compara si es 1 == 49(ascci) 
        je loadFile ; salto a la etiqueta loadFile

        ; ======================= OPCION 2 "MODO CALCULADORA" =======================
        cmp opcion,50 ; "2 = ascci 50" compara si es 2 == 50(ascci) 
        je calculatorMode ; salto a la etiqueta calculatorMode

        ; ======================= OPCION 3 "FACTORIAL" =======================
        cmp opcion,51 ; "3 = ascci 51" compara si es 3 == 51(ascci)
        je factorialMode ; salto a la etiqueta factorial

    jmp main ; Regresa al menu principal

    exitCMD:
        .exit



.exit

; =========== OPCION NO.1 "CARGAR ARCHIVO" ===========
loadFile:
    mClearSC
    ;mReadXML
    ;mReadFile file_name,handler
    ;mJoinString concat_string,test1

    xor si,si
    xor cx,cx
    xor ax,ax
    xor bx,bx
    xor di,di
    mov cx,SIZEOF wfBufferent

    ;mPrint msgWfIng
    ;mGetPath wfBufferent
    mCreateFile wFfileName,wfHandler
    ; ========== ESCRIBIR ARCHIVIO ==========
    ;mov ah, 40h
    ;mov bx, wfHandler
    ;mov cx, SIZEOF prueba
    ;lea dx, prueba
    ;int 21H
    mWriteFile prueba,wfHandler
    mWriteFile prueba2,wfHandler

    mov ah,3eh
    mov bx,wfHandler
    int 21h 

    
    mBackMainMenu
.exit

; =========== OPCION NO.2 "MODO CALCULADORA" ===========
calculatorMode:
    mCalculator
.exit
; =========== OPCION NO.3 "FACTORIAL" ===========
factorialMode:
    mClearSC
    mPrint msgF
    mPrint msgNum
    mSaveNumberFact


    cmp factCount,0; Comparar si el numero es menor(<) que CERO
    jl errorFactorial
    je zeroFactorial

    mov ax,factCount
    cmp ax,7;Compara si el numero es mayor(>) que SIETE
    ja errorFactorial

    mov cx,factCount
    ciclo:
        mov ax,factResult
        mov bx,cx
        mul bx
        mov factResult,ax
    loop ciclo

    mov ax,factResult
    intToString buffer_num
    mPrint msgCalc3 
    mPrint buffer_num
    mov factResult,1d


    mPrint msgFSpace ; >>
    mov ax,factCount
    intToString buffer_num
    mPrint buffer_num
    mPrint msgFDIgual

    mov cx,factCount
    mostar:        
        mov ax,factCountAux
        push ax
        intToString buffer_num
        mPrint buffer_num
        pop ax
        
        cmp cx,factCountAux
        jz salirF
        inc factCountAux 
        mPrint msgFPor
        
    jmp mostar

    salirF:
        mov factCountAux,1d
        mov factCount,0d
        mBackMainMenu

    mBackMainMenu
.exit
errorFactorial:
    mPrint msgWarinig
    mBackMainMenu
.exit
zeroFactorial:
    mPrint msgFSpace ; >>
    mPrint msgFZero
    mBackMainMenu
.exit
end


