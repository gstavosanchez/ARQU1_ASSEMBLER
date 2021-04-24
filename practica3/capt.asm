.model small
.stack
.data 
    msg db 10,13,7, 'Enter String:','$'
    string db 100 dup(' '),'$'
.code 
    main proc
    mov ax, @data 
    mov ds,ax

    ; Imprime "Enter String" en pantalla
    mov ah,09h ; Visualizacion de una cadena de caracteres en pantalla
    lea dx,msg
    int 21h

    ; Lea la entrada del teclado 
    mov ah,3fh ; Lectura de Fichero o dispositivo
    mov bx,00
    mov cx,100
    mov dx,offset[string]
    int 21h

    ; Imprime la cadena que se typea.
    mov ah,09h ; Visualizacion de una cadena de caracteres en panatalla
    mov dx,offset[string]
    int 21h

    .exit
    main endp
end