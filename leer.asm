;include mac.asm

mostrar macro buffer
    MOV AX, @data
    MOV DS, AX
    MOV AH, 09h
    MOV DX, offset buffer
    INT 21H
endm

ObtenerRuta macro buffer
    LOCAL ObtenerChar, FinOT
    XOR si, si
    ObtenerChar:
    getChar
    CMP al, 0dh
    JE FinOT
    MOV buffer[si], al
    inc si
    jmp ObtenerChar
    FinOT:
    MOV al, 00h
    MOV buffer[si], al
endm 


ObtenerTexto macro buffer
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
    MOV al, 24h
    MOV buffer[si], al
endm


Crear macro buffer, handler
    mov ah, 3ch
    mov cx, 00h
    lea dx, buffer
    int 21h
    mov handler, ax
endm

getChar macro
    MOV AH, 01h
    INT 21H
endm

.model small
.stack
.data
    salto       db 0ah, 0dh, '  ', '$'
    ing         db 0ah, 0dh, 'Ingrese una ruta: ', 0ah, 0dh, ' Ejemplo: (c:entrada.htm)', '$'
    ing2        db 0ah, 0dh, 'Ingrese un texto a escribir', '$'  

    bufferent      db 50 dup('$') ; Variable de la ruta
    handleent      dw ?
    bufferinf      db 200 dup('$'); datos a escribir

    prueba1 db 10,13, 'hola','$'
    prueba2 db 10,13, 'mundo','$'

.code
    MOV AX, @data
    MOV DS, AX
    
    ;Crear archivo
    mostrar salto
    mostrar ing
    mostrar salto

    ;===LIMPIANDO===
    xor si,si
    xor cx,cx
    mov cx,SIZEOF bufferent
    Repetir:
        mov bufferent[si],24h
        inc si
    Loop Repetir
    ;===LIMPIANDO===
    ObtenerRuta bufferent
    Crear bufferent, handleent
    
    ;Escribiendo archivo
    ;mostrar salto
    ;Limpiar buffer_informacion, SIZEOF buffer_informacion, 24H
    ;mostrar ing2
    ;ObtenerTexto bufferinf
    ;Escribir handleent,bufferinf,SIZEOF bufferinf
    ;===ESCRIBIR===
    ;mostrar salto
    ;mostrar ing2
    ;ObtenerTexto bufferinf
    mov ah, 40h
    mov bx, handleent
    mov cx, SIZEOF prueba1
    lea dx, prueba1
    int 21H
    ;mostrar salto

    .exit   
end