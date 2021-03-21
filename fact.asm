.model small
.stack
.data 
    result db 1
.code

    mov dx,@data
    mov ds,dx

    mov cx,3 ; Registro contador(Registro completo) "CX",Implementado instrucicones de ciclo,
             ; almecan el número de veces que se repite una instruccion

    ciclo:
        mov al,result ; Se mueve al registro "AL", lo que es la variable result
        mov bl,cl ; Se mueve  al registro "BL", lo que tenga "CX" pero como esta en la parte baja "CL" que es el contador
        mul bl ; se multilica lo que tenga el  registro bl en este caso 3
        mov result, al ; Se mueve a restult, lo que tenga el registro al (a qui se guarda el resultado de la multiplicacion) 
    loop ciclo

    ; Mostrar el resultado max 2 digitos
    mov al,result
    AAM
    mov bx,ax
    mov ah,02h ; Se mueve al registro "AH", el registro 02h(Impresion de un caracter)
    mov dl,bh
    add dl,30h ; Se hace el ajuste de 30h(para convertir de ascci a numero)
    int 21h

    mov ah,02h
    mov dl,bl
    add dl,30h
    int 21h

    .exit
end