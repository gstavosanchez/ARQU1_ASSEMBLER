.model small
.stack
.data  
    n1 db 0
    n2 db 0
    result db 0
    suma db 10,13,7, 'Sum: ','$'
    subt db 10,13,7, 'Subtraction: ','$'
    mult db 10,13,7, 'Multiplication: ','$'
    divi db 10,13,7, 'Division: ','$'
    msg db 10,13,7, 'Enter a number: ','$'

.code 
    mov ax, @data
    mov ds,ax

    mov ah,09h
    lea dx,msg
    int 21h

    mov ah,01h
    int 21h
    sub al,30h
    mov n1,al 

    mov ah,09h
    lea dx,msg
    int 21h

    mov ah,01h
    int 21h
    sub al,30h
    mov n2,al

    ;Suma
    mov al,n1
    add al,n2
    mov result,al

    mov ah,09h
    lea dx,suma
    int 21h

    ; Muestra el primer digito del resultado
    mov al,result 
    AAM
    mov bx,ax
    mov ah,02h
    mov dl,bh
    add dl,30h
    int 21h

    ; Muestra el segundo digito del resultado
    mov ah,02h
    mov dl,bl
    add dl,30h
    int 21h

    ; Resta

    mov al,n1
    sub al,n2
    mov result,al 


    mov ah,09h
    lea dx,subt
    int 21h

    ; Muestra el primer digito del resultado
    mov al,result 
    AAM
    mov bx,ax
    mov ah,02h
    mov dl,bh
    add dl,30h
    int 21h

    ; Muestra el segundo digito del resultado
    mov ah,02h
    mov dl,bl
    add dl,30h
    int 21h


    ;Multiplicacion
    mov al,n1
    mov bl,n2
    mul bl
    mov result, al


    mov ah,09h
    lea dx,mult
    int 21h

    ; Muestra el primer digito del resultado
    mov al,result 
    AAM
    mov bx,ax
    mov ah,02h
    mov dl,bh
    add dl,30h
    int 21h

    ; Muestra el segundo digito del resultado
    mov ah,02h
    mov dl,bl
    add dl,30h
    int 21h


    ; Division

    xor ax,ax ; Se limpia los registros
    mov bl,n2
    mov al,n1
    div bl ; AL = AL/BL -> AH = RES
    mov result,al 

    mov ah,09h
    lea dx,divi
    int 21h

    ; Muestra el primer digito del resultado
    mov al,result 
    AAM
    mov bx,ax
    mov ah,02h
    mov dl,bh
    add dl,30h
    int 21h

    ; Muestra el segundo digito del resultado
    mov ah,02h
    mov dl,bl
    add dl,30h
    int 21h

    .exit
end