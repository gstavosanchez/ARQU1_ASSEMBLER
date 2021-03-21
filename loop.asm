.model small 
.stack 
.data 

.code 
    mov cx,9

    ciclo:
        mov ah,02h
        mov dx,cx
        add dx,30h
        int 21h
    loop ciclo


    .exit
end 