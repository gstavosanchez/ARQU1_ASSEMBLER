.model small
.stack
.data
    mensaje db "Hola mundo :)","$" ;DEFINE BYTE = 8 BITS
.code

    main proc
        mov ax,@data ;MOVER DONDE IMPIEZA LA DATA;MOV PARAMETRO1, PARAMETRO2; MUEVE LO QUE TENGA EN EL PARAMETRO 2 AL PARAMETRO 1 : AX <- @DATA; ax = @data;
        mov ds,ax; MOVER VALOR DE AX A DS

        mov ah,09 ; 09 imprimir un segmento de data ; Tipo de operacion de 21h muestra caractres
        mov dx, offset mensaje; dx, donde impieza el mensaje
        int 21h; Tipo de interrupcion de DOS
        mov ax,4c00h; Tipo de operacion RETORNAR el control al sistema

        int 21h; interrupcion del dos
    main endp

end main
