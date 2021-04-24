; Realizar la caputra de dos digitos
.model small 
.stack 
.data 
    units db 0
    tens db 0
    number db 0
    msg db 10,13,7, 'Enter a number: ','$' 
    msg1 db 10,13,7, 'Numero ingresado: ','$'

.code 
    mov ax,@data 
    mov ds,ax 

    ; Imprimer en pantalla lo que esta en msg
    mov ah, 09h
    lea dx,msg
    int 21h

    ; Captura del digito de las decenas
    mov ah,01h
    int 21h
    sub al,30h
    mov tens,al

    ; Captura del digito de las unidades
    mov ah,01h
    int 21h
    sub al,30h
    mov units,al

    ; Conversion del numero
    mov al,tens ; al = 5
    mov bl,10 ;   bl = 10
    mul bl ;      al = al * bl
    add al,units
    mov number,al

    ; Imprime en pantalla lo que esta en msg1
    mov ah, 09h
    lea dx,msg
    int 21h

    ; Desempaquetado de dos digitos
    mov al,number
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