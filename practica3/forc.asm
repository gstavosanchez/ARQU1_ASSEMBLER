.model small
.stack
.data 
    num1 db 8
    num2 db 8
    msg1 db 'Numeros iguales','$'
    msg2 db 'Numero 1 mayor','$'
    msg3 db 'Numeros 1 menor','$'
.code 
    main:
    ; cmp destino, origen, se activa la bandera
    ; cuando la comparacion es igual( 3 === 3) entonces ZF = 1; CF = 0
    ; Cuando el destino es mayor (>) las dos banderas estan desactivadas ZF = 0 ; CF = 0; 
    ; Cuando el destino es menor (<) las bandera ZF = 0; CF = 1;
    ;mov al,2 ; Mover el registro al <- 2; asignar
    ;cmp al,3  ; Comparar el registro al(2) con 3

    mov ax, @data 
    mov ds,ax

    mov al, num1
    cmp al, num2
    
    jc less ; Cuando el destino sea menor(<) que el origen
    jz equals; Cuando los dos nuemeros sean iguales
    jnz higher; Cuando el destino es mayor(>) que el origen 


.exit

equals:
    mov ah,09h
    lea dx,msg1
    int 21h
.exit
higher:; MAYOR
    mov ah,09h
    lea dx,msg2
    int 21h
.exit
less:; MENOR
    mov ah,09h
    lea dx,msg3
    int 21h
.exit
end