.model small
.stack
.data  
    count db 0
    msg db 10,13,7, '!!Hola mundo desde un ciclo','$'
    

.code 
    mov ax,@data 
    mov ds,ax

    ciclo:
        cmp count,10
        je salir ; se activa cuando el origen sea igual al destino

        mov ah,09h
        lea dx,msg
        int 21h

        inc count ; Este incrementa la variable en uno
    jmp ciclo ; Salto no-condincional no depende de ninguna bandera

    salir:
        .exit
end