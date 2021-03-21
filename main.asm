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
    ; ========= VARIABLES PARA CALCULADORA ==============
    calcNum1 dw 0d;
    calcNum2 dw 0d;
    calcResult dw 0d;
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
    msgFZero db 10,13,7, "1","$"
    msgWarinig db 10,13,7, ">> Numero fuera de rango,debe ser 0 <= x <= 7 ","$"


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

    mBackMainMenu
.exit

; =========== OPCION NO.2 "MODO CALCULADORA" ===========
calculatorMode:
    mClearSC

    mBackMainMenu
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
    mPrint buffer_num
    mov factResult,1d
    mBackMainMenu
.exit
errorFactorial:
    mPrint msgWarinig
    mBackMainMenu
.exit
zeroFactorial:
    mPrint msgFZero
    mBackMainMenu
.exit
end


