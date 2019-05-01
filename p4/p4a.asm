codigo SEGMENT
	ASSUME cs : codigo
	ORG 256
inicio: jmp instalador

; Variables globales

tabladecod DB '6789AB'
		  DB 'CDEFGH'
		  DB 'IJKLMN'
		  DB 'OPQRST'
		  DB 'UVWXYZ'
		  DB '012345'
			 
tablacod DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		 DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		 DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		 DB	36H,31H,36H,32H,36H,33H,36H,34H,36H,35H,36H,36H,31H,31H,31H,32H,31H,33H,31H,34H,0,0,0,0,0,0,0,0,0,0,0,0
		 DB	0,0,31H,35H,31H,36H,32H,31H,32H,32H,32H,33H,32H,34H,32H,35H,32H,36H,33H,31H,33H,32H,33H,33H,33H,34H,33H,35H,33H,36H,34H,31H
		 DB	34H,32H,34H,33H,34H,34H,34H,35H,34H,36H,35H,31H,35H,32H,35H,33H,35H,34H,35H,35H,35H,36H,0,0,0,0,0,0,0,0,0,0
		 DB	0,0,31H,35H,31H,36H,32H,31H,32H,32H,32H,33H,32H,34H,32H,35H,32H,36H,33H,31H,33H,32H,33H,33H,33H,34H,33H,35H,33H,36H,34H,31H
		 DB	34H,32H,34H,33H,34H,34H,34H,35H,34H,36H,35H,31H,35H,32H,35H,33H,35H,34H,35H,35H,35H,36H,0,0,0,0,0,0,0,0,0,0

salida DB 100 dup (?)

instruc DB 'Numero grupo: 5, David Cabornero y Sergio Galan.', 0AH
		DB 'Uso del programa: Sin argumentos imprime estas instrucciones,'
		DB ' con /I instala el driver si no esta instalado y con /D desinstala el driver.', 0AH
		DB 'Este driver esta: $'
instal DB 'Instalado.$'
desinstal DB 'Desinstalado.$'
nodes DB 'El driver no esta instalado o no es este driver.$'
contador DW 0
index DW 0
finished DB 0
off1C DW (?)
seg1C DW (?)
firma DW 0DCABH
;;Macros
codnum equ 10h
decodnum equ 11h
ascii equ 31h
tabledim equ 6
endstring equ '$'
iteraciones equ 18
args equ 80H

; Rutina de servicio a la interrupción
rsi PROC FAR
	sti 	;Habilitamos las interrupciones para que 1Ch se pueda ejecutar
	; Salva registros modificados
	push ax bx cx dx bp ds di si
	; Instrucciones de la rutina ...
	cmp ah, codnum ;Si la interrupcion es 10h, codificamos
	jz cod
	cmp ah, decodnum ;Si la interrupcion es 11h, decodificamos
	jz decod
	jmp fin	; Si no es ninguno de los dos casos no hacemos nada
cod: ;Codificamos una String y la imprimimos
	mov bp, dx
	mov si, 0
	mov di, 0
	mov bl, ds:[bp][si]	;Obtenemos el primer digito sin codificar
loopcod:
	mov bh, 0
	sal bx, 1						;En tablacod cada "información" ocupa dos bytes
	mov bx, WORD PTR tablacod[bx]	;Obtenemos el primer digito codificado
	mov WORD PTR salida[di], bx		;Guardamos la letra en la cadena codificada
	inc si							;Avanzamos posicion en la String
	add di, 2						;Avanzamos posicion en la cadena codificada
	mov bl, ds:[bp][si]				;Obtenemos el siguiente digito sin codificar
	cmp bl, '$'						;Comprobamos si hemos acabado
	jnz loopcod						;Repetimos el proceso si no es asi
	mov salida[di], '$'				;Finalizamos la cadena codificada
	jmp print						;Saltamos a la impresion por pantalla
decod:	;Decodificamos una String y la imprimimos
	mov bp, dx
	mov cx, 0
	mov di, 0
	mov bh, 0
loopdecod:
	mov bl, ds:[bp][di]+1			;Obtenemos la direccion de la letra decodificada con mayor peso
	sub bl, ascii					;Cambiamos la letra de formato ASCII al digito en si
	mov si, bx						
	mov bl, ds:[bp][di]				;Obtenemos la direccion de la letra decodificada con menor peso
	sub bl, ascii					;Cambiamos la letra de formato ASCII al digito en si
	mov al, tabledim				;Obtenemos la posicion de la tabla que corresponde a la decodificacion
	mul bl
	mov bx, ax
	mov bl, tabladecod[bx][si]		;Obtenemos la letra decodificada en nuestra tabla
	mov si, cx
	mov salida[si], bl				;Guardamos la letra en nuestra cadena final
	inc cx					
	add di, 2			
	mov bl, ds:[bp][di]				;Obtenemos el siguiente byte
	cmp bl, endstring				;Comprobamos si hemos finalizado
	jnz loopdecod					;Repetimos el proceso en caso contrario
	mov salida[si]+1, endstring		;Finalizamos la cadena de salida en caso de finalizar
	print:							;Impresion por pantalla
	;mov ax, cs
	;mov ds, ax
	;mov dx, OFFSET salida		
	;mov ah, 9
	;int 21h
	mov finished,1					;Cambiamos la flag para indicar que la decodificacion ha acabado
check:							;Comprobacion de si se ha cambiado la flag de finalizacion
	cmp finished,0					
	jnz check	
fin:
	; Recupera registros modificados
	pop si di ds bp dx cx bx ax
	iret
rsi ENDP

rsi2 PROC FAR
	push bx dx ax ds
	mov ax, cs
	mov ds, ax
	inc contador
	cmp contador, iteraciones	;Cada 18 iteraciones (1 segundo), se escribe una letra
	jnz retorno
	cmp finished, 1			;Si se ha acabado, debemos reiniciar el contador
	jnz reset
	mov bx, index			
	cmp salida[bx], endstring	;Comprobamos si hemos llegado al final de nuestra cadena
	jz terminate
	mov dl, salida[bx]		;Imprimimos la letra que toca
	mov ah, 2
	int 21h
	inc index				;Incrementamos el contador de letra contada
reset:					;Reiniciamos el contador
	mov contador, 0			
	jmp retorno
	terminate:				;Hemos terminado, ponemos todas las flags y contadores a cero
	mov finished, 0
	mov index, 0
	mov contador, 0
retorno:				
	; Recupera registros modificados
	pop ds ax dx bx
	iret

rsi2 ENDP

instalacion PROC FAR
	push cx es bx ax
	mov cx, 0		
	mov es, cx
	mov cx, OFFSET rsi	;ax tiene el OFFSET del codigo Polibio
	mov bx, cs
	;cli					;Se inhabilita la interrupcion temporal
	in ax, 21h
	or ax, 1
	out 21h, ax
	
	mov es:[57h*4], cx		;Ajustamos OFF Y SEG de la 57h
	mov es:[57h*4+2], bx
	
	in ax, 21h
	and ax, 1111111111111110b
	out 21h, ax
	;sti					;Rehabilitamos la interrupcion temporal
	;mov dx, OFFSET instalador
	mov cx, 0		
	mov es, cx
	
	mov bx, es:[1Ch*4]	;Guardamos OFF Y SEG de la rutina de 1Ch anterior
	mov cx, es:[1Ch*4+2]
	mov off1C, bx
	mov seg1C, cx
	
	mov cx, OFFSET rsi2	;ax tiene el OFFSET del codigo Polibio
	mov bx, cs
	;cli					
	;Se inhabilita la interrupcion temporal
	
	in ax, 21h
	or ax, 1
	out 21h, ax
	
	mov es:[1Ch*4], cx		;Ajustamos OFF Y SEG de la 1Ch
	mov es:[1Ch*4+2], bx
	
	in ax, 21h
	and ax, 1111111111111110b
	out 21h, ax
	;sti					;Rehabilitamos la interrupcion temporal
	mov dx, OFFSET instal
	mov ah, 9
	int 21h
	
	mov dx, OFFSET instalacion
	pop ax bx es cx
	ret
instalacion ENDP


desinstalacion PROC FAR
	push bp dx cx ds es bx ax
	mov bp, es:[si-6]
	mov dx, es:[si-4]		;Obtenemos OFF Y SEG de la rsi original de 1Ch
	
	mov cx, 0				;Desinstalacion primer driver
	mov ds, cx
	mov es, ds:[57h*4+2]
	mov bx, es:[2Ch]
	
	mov ah, 49h
	int 21h
	mov es, bx
	int 21h
	
	cli
	mov ds:[57h*4], cx
	mov ds:[57h*4+2], cx
	sti
	
	mov cx, 0
	mov ds, cx
	mov es, ds:[1Ch*4+2]	;Desisntalacion segundo driver
	mov bx, es:[2Ch]
	
	mov ah, 49h
	int 21h
	mov es, bx
	int 21h
	
	cli	;Recuperamos OFF Y SEG de la rsi original de 1Ch
	mov ds:[1Ch*4], bp
	mov ds:[1Ch*4+2], dx
	sti	
	
	mov dx, cs
	mov ds, dx
	mov dx, OFFSET desinstal
	mov ah, 9
	int 21h
	pop ax bx es ds cx dx bp
	ret
desinstalacion ENDP

instrucciones PROC FAR
	push ax dx es si
	mov ah, 9
	mov dx, OFFSET instruc	
	int 21H
	mov ax, 0			;Iniciamos comprobacion de firma
	mov es, ax
	mov ax, firma
	mov si, es:[57h*4]
	mov es, es:[57h*4+2]
	cmp ax, es:[si-2]
	jz instalado			;El programa esta firmado, por lo que asumimos que esta instalado nuestro programa
	mov dx, OFFSET desinstal	;En caso contrario, notificamos que no esta instalado
	mov ah, 9
	int 21H
	jmp fininstrucciones
instalado:
	mov dx, OFFSET instal
	mov ah, 9
	int 21h
fininstrucciones:
	pop si es dx ax
	ret
instrucciones ENDP

instalador PROC FAR
	xor dh, dh
	mov dl, cs:[args] ; Número de argumentos
	cmp dl, 0
	jnz cont1 ; Si no hay argumentos, mostramos unas instrucciones, pues no es una opcion valida
	call instrucciones
	jmp fininst
cont1:
	cmp dl, 3
	jz instdes	;Si hay tres letras, PUEDE que haya puesto correctamente las letras
	;aux:
	;jmp instrucciones	;Si nos pasan algo no contemplado, imprimimos instrucciones
	call instrucciones
	jmp fininst
instdes:		;Comprobamos si las tres letras son validas
	mov dl, cs:[args+2]
	cmp dl, '/'	;Si la el segundo caracter no es /, mostramos instrucciones
	jz cont2
	call instrucciones
	jmp fininst
cont2:
	mov dl, cs:[args+3]
	cmp dl, 'D'		;Si la tercera letra es D, desinstalamos
	jz desinst
	cmp dl, 'I'		;Si la tercera letra es I, instalamos
	jz cont3			;Si no, imprimimos instrucciones
	call instrucciones
	jmp fininst
	;inst:
cont3:
	call instalacion	;Si el comando es /I, instalamos el driver
	int 27h ; Acaba y deja residente 
			; PSP, variables y rutina rsi.
desinst:
	;Comprobamos si el driver que está instalado es el nuestro, si es que hay alguno
	mov ax, 0				
	mov es, ax				
	cmp ax, es:[57h*4]	;Comprobamos si hay un driver instalado	
	jz nodesinst		
	mov ax, firma		;Firma de nuestro driver
	mov si, es:[57h*4]
	mov es, es:[57h*4+2]
	cmp ax, es:[si-2]	;Comprobamos si la firma de nuestro driver es la que debe ser
	jnz nodesinst	
	
	call desinstalacion	;Si nuestro driver esta instalado, lo desinstalamos
	
	jmp fininst
	
nodesinst:
	mov dx, OFFSET nodes
	mov ah, 9
	int 21H
	jmp fininst
	
fininst:	;Fin del codigo
	mov ax, 4c00H
	int 21H
instalador ENDP

codigo ENDS
END inicio