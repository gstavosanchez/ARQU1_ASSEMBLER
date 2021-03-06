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
; =========== GUARDAR NUMERO 1 CALCULADORA =================
mSaveCalcNum1 macro
    mov calcNum1,0d
    mPrint msgOpcion
    ; Lea la entrada del teclado
    mov ah,3fh ; Lectura de Fichero o dispositivo
    mov bx,00
    mov cx,100
    mov dx,offset[number_str_calc1]
    int 21h

    mStrToInt number_str_calc1
    mov calcNum1,ax
    ;intToString buffer_num
    ;mPrint buffer_num
    

endm
; =========== GUARDAR NUMERO 1 CALCULADORA =================
mSaveCalcNum2 macro
    mov calcNum2,0d
    mPrint msgOpcion
    ; Lea la entrada del teclado
    mov ah,3fh ; Lectura de Fichero o dispositivo
    mov bx,00
    mov cx,100
    mov dx,offset[number_str_calc2]
    int 21h

    mStrToInt number_str_calc2
    mov calcNum2,ax
    ;intToString buffer_num
    ;mPrint buffer_num
    
endm
; =========== CONVIERTE UNA CADENA A NUMERO, ESTE SE GUARDA EN "AX" =============
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
            jz ciclo    ;Se ignora el simbolo '-' del n??mero
            cmp cl, 30h ;Si el caracter es menor a '0', se procede a la verificaci??n de numeros negativos
            jb chkNeg
            cmp cl, 39h ;Si el caracter es mayor a '9',se procede a la verificaci??n de numeros negativos
            ja chkNeg
            sub cl, 30h	;Se le resta el ascii '0' para obtener el n??mero real
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
      xor dx, dx; Se limpia el registro DX; Este simular?? la parte alta del registro
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


mCalculator macro
    local operationCycle,operationExit,operationSum,operationSub,operationMul,operationDiv,movRegisterSum,movCycle,movRegisterSub
    local movRegisterMul,movRegisterDiv,operationLimit,valueNegativeNum,valueNegativeResult,saveOperation,yesSave, noSave
    mClearSC
    mPrint msgCalc
    ; ========== CICLO PARARA ESCOGER LA OPCION =============
    operationCycle:

        ;cmp ax,10;Compara si el numero es mayor(>) que DIEZ
        ;ja operationLimit

        cmp calcCount,0
        je movCycle

        mPrint msgCalc2; mostrar mensaje de ingrese +,-...
        mPrint msgOpcion; Mostrar >>
        ; =========== CAPTURA DE UN CARACTER =========== 
        mov ah,01h ; instruccion para guardar un carecter
        int 21h
        mov calcType,al; +,-,*,/,;

        ; =========== COMPARAR SALIDA ";" =========== 
        cmp calcType,59; ";" = ascci 59, Para finalizar 
        je operationExit

        ; =========== COMPARAR SUMA "+" =========== 
        cmp calcType,43; "+" = ascci 43 
        je operationSum
        ; =========== COMPARAR RESTA "-" =========== 
        cmp calcType,45; "-" = ascci 45 
        je operationSub
        ; =========== COMPARAR MULTI "*" =========== 
        cmp calcType,42; "*" = ascci 42 
        je operationMul
        ; =========== COMPARAR DIVISION "/" =========== 
        cmp calcType,47; "/" = ascci 47
        je operationDiv


        mPrint msgCalc4; Mensaje de simbolo invalido
        


        ;inc calcCount; Se incrementa el contador en 1    
    jmp operationCycle
    
    movCycle:
        mPrint msgCalc1 ; mostrar mensaje de ingrese Numero
        mSaveCalcNum1; Guardar el primer numero
        mPrint msgCalc6; mostrar mensaje de ingrese operacion +,-...
        mPrint msgOpcion; Mostrar >>
        ; =========== CAPTURA DE UN CARACTER =========== 
        mov ah,01h ; instruccion para guardar un carecter
        int 21h
        mov calcType,al; +,-,*,/,;

        ; =========== COMPARAR SALIDA ";" =========== 
        cmp calcType,59; ";" = ascci 59, Para finalizar 
        je operationExit

        ; =========== COMPARAR SUMA "+" =========== 
        cmp calcType,43; "+" = ascci 43 
        je operationSum
        ; =========== COMPARAR RESTA "-" =========== 
        cmp calcType,45; "-" = ascci 45 
        je operationSub
        ; =========== COMPARAR MULTI "*" =========== 
        cmp calcType,42; "*" = ascci 42 
        je operationMul
        ; =========== COMPARAR DIVISION "/" =========== 
        cmp calcType,47; "/" = ascci 47
        je operationDiv


        mPrint msgCalc4; Mensaje de simbolo invalido
        


        ;inc calcCount; Se incrementa el contador en 1    
    jmp operationCycle

    ; ======= OPERACI??N SUMA ==============
    operationSum:

        cmp calcCount,0
        je movRegisterSum

        mPrint msgCalc1 ; mostrar mensaje de ingrese Numero
        mSaveCalcNum1; Guardar el primer numero

        mov ax,calcNum1
        add ax,calcResult
        

        ;add ax,calcResult
        mov calcResult,ax
        ;========== JOIN STRING "SUMA"============
        ; === SIMBOLO "+" ===
        mJoinString calc_string,msgCSum

        ; === 1. DIGITO ===
        mov ax,calcNum1
        intToString buffer_num
        mJoinString calc_string,buffer_num

        ;========== === === === === ================


        mov calcNum1,0d
        mov calcNum2,0d

        inc calcCount; Se incrementa el contador en 1    
    jmp operationCycle

    movRegisterSum:
        mPrint msgCalc5; Mostrar Ingrese operador
        mSaveCalcNum2; Guardar el valor del numero2

        mov ax,calcNum1
        add ax,calcNum2
        

        add ax,calcResult
        mov calcResult,ax

        ;========== JOIN STRING "SUMA"============

        ; ============ COLUMNA 1 ===============
        ; === <tr> ===
        mJoinString calc_string,wfTr
        ; === <td> ===
        mJoinString calc_string,tdO
        ; === CONTADOR ===
        mov ax,calcCount
        intToString buffer_num
        mJoinString calc_string,buffer_num
        ; === </td> ===
        mJoinString calc_string,tdC

        ; ============ COLUMNA 2 ===============
        ; === <td> ===
        mJoinString calc_string,tdO
        ; === 1. DIGITO ===
        mov ax,calcNum1
        intToString buffer_num
        mJoinString calc_string,buffer_num

        ; === SIMBOLO "+" ===
        mJoinString calc_string,msgCSum

        ; === 2. DIGITO ===
        mov ax,calcNum2
        intToString buffer_num
        mJoinString calc_string,buffer_num

        ; === </td> ===
        ;mJoinString calc_string,tdC
        ;========== === === === === ================

        mov calcNum1,0d
        mov calcNum2,0d

        inc calcCount; Se incrementa el contador en 1    
    jmp operationCycle
    ; ======= OPERACI??N RESTA ==============
    operationSub:
        cmp calcCount,0
        je movRegisterSub


        mPrint msgCalc1 ; mostrar mensaje de ingrese Numero
        mSaveCalcNum1; Guardar el primer numero



        mov ax,calcResult
        sub ax,calcNum1
        ;add ax,calcResult
        mov calcResult,ax

        ;========== JOIN STRING "RESTA"============
        ; === SIMBOLO "-" ===
        mJoinString calc_string,msgCSub

        ; === 1. DIGITO ===
        mov ax,calcNum1
        intToString buffer_num
        mJoinString calc_string,buffer_num

        ;========== === === === === ================

        ;xor ax
        mov calcNum1,0d
        mov calcNum2,0d

        inc calcCount; Se incrementa el contador en 1    
    jmp operationCycle
    movRegisterSub:
        mPrint msgCalc5; Mostrar Ingrese operador
        mSaveCalcNum2

        mov ax,calcNum1
        sub ax,calcNum2

        add ax,calcResult
        mov calcResult,ax

        ;========== JOIN STRING "RESTA"============

        ; ============ COLUMNA 1 ===============
        ; === <tr> ===
        mJoinString calc_string,wfTr
        ; === <td> ===
        mJoinString calc_string,tdO
        ; === CONTADOR ===
        mov ax,calcCount
        intToString buffer_num
        mJoinString calc_string,buffer_num
        ; === </td> ===
        mJoinString calc_string,tdC

        ; ============ COLUMNA 2 ===============
        ; === <td> ===
        mJoinString calc_string,tdO
        ; === 1. DIGITO ===
        mov ax,calcNum1
        intToString buffer_num
        mJoinString calc_string,buffer_num

        ; === SIMBOLO "-" ===
        mJoinString calc_string,msgCSub

        ; === 2. DIGITO ===
        mov ax,calcNum2
        intToString buffer_num
        mJoinString calc_string,buffer_num

        ; === </td> ===
        ;mJoinString calc_string,tdC
        ;========== === === === === ================



        ;xor ax
        mov calcNum1,0d
        mov calcNum2,0d

        inc calcCount; Se incrementa el contador en 1    
    jmp operationCycle
    ; ======= OPERACI??N MULTI ==============
    operationMul:
        cmp calcCount,0
        je movRegisterMul


        mPrint msgCalc1 ; mostrar mensaje de ingrese Numero
        mSaveCalcNum1; Guardar el primer numero


        mov ax,calcResult; ax = 5
        mov bx,calcNum1; bx = 10
        mul bx; ax = ax * bx

        ;add ax,calcResult
        mov calcResult,ax

        ;========== JOIN STRING "MULTI"============
        ; === SIMBOLO "*" ===
        mJoinString calc_string,msgCMul

        ; === 1. DIGITO ===
        mov ax,calcNum1
        intToString buffer_num
        mJoinString calc_string,buffer_num

        ;========== === === === === ================

        ;xor ax
        mov calcNum1,0d
        mov calcNum2,0d

        inc calcCount; Se incrementa el contador en 1    
    jmp operationCycle
    movRegisterMul:
        mPrint msgCalc5; Mostrar Ingrese operador
        mSaveCalcNum2

        mov ax,calcNum1; ax = 5
        mov bx,calcNum2; bx = 10
        mul bx; ax = ax * bx

        add ax,calcResult
        mov calcResult,ax


        ;========== JOIN STRING "MULTI"============

        ; ============ COLUMNA 1 ===============
        ; === <tr> ===
        mJoinString calc_string,wfTr
        ; === <td> ===
        mJoinString calc_string,tdO
        ; === CONTADOR ===
        mov ax,calcCount
        intToString buffer_num
        mJoinString calc_string,buffer_num
        ; === </td> ===
        mJoinString calc_string,tdC

        ; ============ COLUMNA 2 ===============
        ; === <td> ===
        mJoinString calc_string,tdO
        ; === 1. DIGITO ===
        mov ax,calcNum1
        intToString buffer_num
        mJoinString calc_string,buffer_num

        ; === SIMBOLO "*" ===
        mJoinString calc_string,msgCMul

        ; === 2. DIGITO ===
        mov ax,calcNum2
        intToString buffer_num
        mJoinString calc_string,buffer_num

        ; === </td> ===
        ;mJoinString calc_string,tdC
        ;========== === === === === ================

        ;xor ax
        mov calcNum1,0d
        mov calcNum2,0d

        inc calcCount; Se incrementa el contador en 1    
    jmp operationCycle
    ; ======= OPERACI??N DIVI. ==============
    operationDiv:
        cmp calcCount,0
        je movRegisterDiv

        mPrint msgCalc1 ; mostrar mensaje de ingrese Numero
        mSaveCalcNum1; Guardar el primer numero

        xor ax,ax
        xor bx,bx
        xor dx,dx
        mov ax,calcResult; ax = 10
        mov bx,calcNum1; bx = 2
        div bx; ax = ax / bx

        ;add ax,calcResult
        mov calcResult,ax

        
        ;========== JOIN STRING "DIVISION"============
        ; === SIMBOLO "/" ===
        mJoinString calc_string,msgCDiv

        ; === 1. DIGITO ===
        mov ax,calcNum1
        intToString buffer_num
        mJoinString calc_string,buffer_num

        ;========== === === === === ================

        ;xor ax
        mov calcNum1,0d
        mov calcNum2,0d


        inc calcCount; Se incrementa el contador en 1    
    jmp operationCycle
    movRegisterDiv:
        
        mPrint msgCalc5; Mostrar Ingrese operador
        mSaveCalcNum2

        ;mNegNum calcNum1
        ;mNegNum calcNum2

        xor ax,ax
        xor bx,bx
        xor dx,dx
        mov ax,calcNum1; ax = 10
        mov bx,calcNum2; bx = 2
        div bx; ax = ax / bx
        
        ;cmp calcFlag,1 ; Si es igual a 1, hay un negativo
        ;je valueNegativeNum 

        add ax,calcResult
        mov calcResult,ax

         ;========== JOIN STRING "DIV"============

        ; ============ COLUMNA 1 ===============
        ; === <tr> ===
        mJoinString calc_string,wfTr
        ; === <td> ===
        mJoinString calc_string,tdO
        ; === CONTADOR ===
        mov ax,calcCount
        intToString buffer_num
        mJoinString calc_string,buffer_num
        ; === </td> ===
        mJoinString calc_string,tdC

        ; ============ COLUMNA 2 ===============
        ; === <td> ===
        mJoinString calc_string,tdO
        ; === 1. DIGITO ===
        mov ax,calcNum1
        intToString buffer_num
        mJoinString calc_string,buffer_num

        ; === SIMBOLO "/" ===
        mJoinString calc_string,msgCDiv

        ; === 2. DIGITO ===
        mov ax,calcNum2
        intToString buffer_num
        mJoinString calc_string,buffer_num

        ; === </td> ===
        ;mJoinString calc_string,tdC
        ;========== === === === === ================

        ;xor ax
        mov calcNum1,0d
        mov calcNum2,0d

        inc calcCount; Se incrementa el contador en 1    
    jmp operationCycle
    ; ======= SALIR ==============
    operationExit:
        mov ax,calcResult
        intToString buffer_num
        mPrint msgCalc3
        mPrint buffer_num
        ; ============ COLUMNA 3 ===============
        ; === </td> ===
        mJoinString calc_string,tdC
        ; === <td> ===
        mJoinString calc_string,tdO
        ; === RESULTADO ===
        mov ax,calcResult
        intToString buffer_num
        mJoinString calc_string,buffer_num
        ; === </td> ===
        mJoinString calc_string,tdC
        ;========== === === === === ================
        jmp saveOperation
    
    operationLimit:
        mPrint msgCalc7
        mov ax,calcResult
        intToString buffer_num
        mPrint msgCalc3
        mPrint buffer_num
        mov calcResult,0d
        mov calcCount,0d
        mBackMainMenu
    
    ; =========== GUARDAR RESULTADO =========== 
    saveOperation:
        ; =========== CAPTURA DE UN CARACTER =========== 
        mPrint msgCalc8 ; Preguntar si desea guardar archivo
        mov ah,01h ; instruccion para guardar un carecter
        int 21h
        mov calcType,al; [S/N];

        cmp calcType,115 ; Si es igual "s"
        jz yesSave

        cmp calcType,110; Si es igual "n"
        jz noSave
    

        mPrint msgCalc4; Mensaje de simbolo invalido

    jmp saveOperation

     ; =========== "SI" GUARDAR RESULTADO =========== 
    yesSave:
        mov calcResult,0d
        mov calcCount,0d
        ;==== JOIN STRING ========
        ; === </tr> ===
        mJoinString calc_string,wfCloseTr
        mJoinString report_text,calc_string
        mClearString calc_string
        
        mBackMainMenu

    ; =========== "NO" GUARDAR RESULTADO =========== 
    noSave:
        mov calcResult,0d
        mov calcCount,0d
        mClearString calc_string

        mBackMainMenu
    
     ; =========== ======== ===========  =========== 
    valueNegativeNum:
        neg calcResult

        add ax,calcResult
        mov calcResult,ax

        mov calcNum1,0d
        mov calcNum2,0d
        
        mov calcFlag,0; Cambia de estado la bandera, indicar que no hay un negativo
        inc calcCount; Se incrementa el contador en 1    
    jmp operationCycle

endm
; =========== GUARDAR RESULTADO EN ARREGLO=========== 
mSaveInArray macro
    local isZero,isMore,getIndex,mainWhile
    mov si,0000h; Lleva el contro de donde de la variable a guardar
    
    mov ax, countReport
    mPrint msgFSpace
    intToString buffer_num
    mPrint buffer_num

    mainWhile:  
        cmp countReport,0
        jz isZero
        
        cmp si,countReport
        jz isMore

        inc si
    jmp mainWhile

    isZero:
        mPrint msgFSpace
        mov dx, calcResult 
        mov [resultList + si ],dx
        ;mov resultList[si],dx
        inc countReport

    isMore:
        ;inc si
        mov dx, calcResult 
        mov [resultList + si ],dx
        ;mov resultList[si],ax
        inc countReport


    
endm

; ============= CONVIERTE A POSITIVO ===================
mNegNum macro intNumber
    local negNumber
    cmp intNumber,0; Comparar si el numero es menor(<) que CERO
    jl negNumber
    
    negNumber:
        neg intNumber; Se niega el numero para que sea positivo
        mov calcFlag,1; Cambia de estado la bandera, indicar que hay un negativo
endm
; ================ LEER ARCHIVO =========================
; Macro personal que lee un archivo de texto y carga su contenido en la 
; variable de salida "buffer_salida"
mReadFile macro file_name, handler_file
    ;org 100h
    local openFile,readFile,exit,errorOpen,closeFile,errorRead,clean_var
    openFile:
        mov ah,3dh
        mov al,0 ; Indicar que abrimos en modo lectura 
        mov dx,offset file_name
        int 21h
        jc errorOpen
        mov handler_file,ax
        jmp readFile
        ;jmp closeFile
    
    readFile:
        mov ah,3fh
        mov bx,handler_file
        mov dx,offset textFile
        mov cx,101; numeros de caracteres a leer
        int 21h
        jc errorRead
        cmp ax,0; si ax = 0 significa EOF(Final del archivo , end of file)
        jz closeFile
        mPrint textFile
    jz readFile
        ;jmp readFile

    clean_var:

    jmp readFile
    closeFile:
        mov ah,3eh
        mov bx,handler_file
        int 21h 
        mBackMainMenu
    errorOpen:
        mPrint msgRF
    
    errorRead:
        mPrint msgRF1
endm

mReadXML MACRO
    local mainCycle,catchData,exitData
    exitData:
        mPrint text
     
endm
; =================== ESCRIBIR ARCHIVO =================================
mCreateFile macro buffer,handler
    mov ah, 3ch
    mov cx, 00h
    lea dx, buffer
    int 21h
    mov handler, ax
endm
mGetPath macro path
    LOCAL obtenerChar, finOT 
    xor si,si 
    obtenerChar:
        mGetChar
        cmp al,0dh
        je finOT
        mov path[si],al
        inc si
    jmp obtenerChar

    finOT:
        mov al,00h
        mov path[si],al
endm
mGetChar macro
    MOV AH, 01h
    INT 21H
endm
mWriteFile macro data, handler_file
    local writeData, close

   
    mov ah,40h
    mov bx, handler_file
    mov cx, sizeof data
    lea dx, data
    int 21h

    ;closeFile:

    ;    mBackMainMenu
endm
; =================== UNIR STRING =================================
mJoinString macro destinationSTR,source; "destinationSTR = Destino= mundo", source = Origen = hola
    local exitJoin,joinCycle,sizeOfDestination,exitSizeOf
    xor si,si
    xor di,di
    mov si,0000h; Lleva el contro de donde de la variable a guardar
    mov di,0000h
    xor al,al
    sizeOfDestination:
        mov al,destinationSTR[di]
        cmp al,24h ; Se compara que sea el signo "$", fin de la cadena
        jz exitSizeOf
        inc di 
    jmp sizeOfDestination
    joinCycle:
        mov al,source[si]; Se copia el caracter en la posici??n SI hacia el registro si
        cmp al,24h ; Se compara que sea el signo "$", fin de la cadena
        jz exitJoin
        inc si; Incrementamos el indice de lectura del origen
        mov destinationSTR[di],al; Se copia lo que esta en el origen a destino 
        inc di; Incrementa el contador del destino
    jmp joinCycle
    exitSizeOf:
        mov si,0000h
        xor al,al
    jmp joinCycle
    exitJoin:
        mov si,0000h
        mov di,0000h
        xor al,al
      
endm 

mClearString macro string
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


; =================== FECHA Y HORA =================================
; Para setear las variables 18 = 1-8
guardar_ macro digito1, digito2
    aam           
    mov bx, ax    
    add bx, 3030h 

    mov digito1, bh
    mov digito2, bl
endm

