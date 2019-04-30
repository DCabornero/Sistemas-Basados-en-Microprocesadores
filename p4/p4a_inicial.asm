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

;;Macros
firma DW 0DCABH
codnum equ 10h
decodnum equ 10h
ascii equ 31h
tabledim equ 6
endstring equ '$'
iteraciones equ 18
args equ 80H

; Rutina de servicio a la interrupción
rsi PROC FAR
	; Salva registros modificados
	push ax bx cx dx bp ds di
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
	sal bx, 1
	mov bx, WORD PTR tablacod[bx]	;Obtenemos el primer digito codificado
	mov WORD PTR salida[di], bx		;Guardamos la letra en la cadena codificada
	inc si							;Avanzamos posicion en la String
	add di, 2						;Avanzamos posicion en la cadena codificada
	mov bl, ds:[bp][si]				;Obtenemos el siguiente digito sin codificar
	cmp bl, endstring				;Comprobamos si hemos acabado
	jnz loopcod						;Repetimos el proceso si no es asi
	mov salida[di], endstring		;Finalizamos la cadena codificada
	jmp print						;Saltamos a la impresion por pantalla
	decod:							;Decodificamos una String y la imprimimos
	mov bp, dx
	mov cx, 0
	mov di, 0
	mov bh, 0
	loopdecod:
	mov bl, ds:[bp][di]+1			;Obtenemos la direccion de la letra decodificada de mayor peso
	sub bl, ascii					;Obtenemos el digito del codigo ASCII
	mov si, bx						
	mov bl, ds:[bp][di]				;Obtenemos la direccion de la letra decodificada de menor peso
	sub bl, ascii					;Obtenemos el digito del codigo ASCII 
	mov al, tabledim						
	mul bl							;Obtenemos la posicion de la tabla de decodificacion que necesitamos
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
	;jmp print
	print:						;Impresion por pantalla
	mov ax, cs
	mov ds, ax
	mov dx, OFFSET salida		
	mov ah, 9
	int 21h
	
	
	fin:
	; Recupera registros modificados
	pop di ds bp dx cx bx ax
	iret
rsi ENDP

instalador PROC FAR
	xor dh, dh
	mov dl, cs:[args] ; Número de argumentos
	cmp dl, 0
	jz instrucciones ; Si no hay argumentos, mostramos unas instrucciones, pues no es una opcion valida
	cmp dl, 3
	jz instdes	;Si hay tres letras, PUEDE que haya puesto correctamente las letras
	jmp instrucciones	;Si nos pasan algo no contemplado, imprimimos instrucciones
	instdes:		;Comprobamos si las tres letras son validas
	mov dl, cs:[args+3]
	cmp dl, 'D'		;Si la tercera letra es D, desinstalamos
	jz desinst
	cmp dl, 'I'		;Si la tercera letra es I, instalamos
	jnz instrucciones
	;inst:
	mov ax, 0		
	mov es, ax
	mov ax, OFFSET rsi	;ax tiene el OFFSET del codigo Polibio
	mov bx, cs
	cli					;Se inhabilitan interrupciones
	mov es:[57h*4], ax		;Implementamos una rutina de servicio a la interrupcion 57h
	mov es:[57h*4+2], bx
	sti					;Las interrupciones vuelven a estar habilitadas
	mov dx, OFFSET instalador
	int 27h ; Acaba y deja residente 
			; PSP, variables y rutina rsi.
	
	desinst:
	;Comprobamos si el driver que está instalado es el nuestro, si es que hay alguno
	mov ax, 0
	mov es, ax
	cmp ax, es:[57h*4]			;Comprobamos que haya un driver instalado
	jz nodesinst				
	mov ax, firma				;Firma de nuestro driver
	mov si, es:[57h*4]
	mov es, es:[57h*4+2]
	cmp ax, es:[si-2]			;Comprobamos que esta la firma en nuestro driver
	jnz nodesinst
	mov cx, 0					;Desinstalacion
	mov ds, cx
	mov es, ds:[57h*4+2]		
	mov bx, es:[2Ch]
	
	mov ah, 49h
	int 21h
	mov es, bx
	int 21h
	
	cli ;TODO
	mov ds:[57h*4], cx
	mov ds:[57h*4+2], cx
	sti	;TODO
	jmp fininst
	
	nodesinst:
	mov dx, OFFSET nodes
	mov ah, 9
	int 21H
	jmp fininst
	
	
	instrucciones:		;Imprimimos instrucciones si nos han dado algo no valido
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
	jmp fininst
	instalado:	;Notificamos que esta instalado
	mov dx, OFFSET instal
	mov ah, 9
	int 21H
	fininst:	;Fin del codigo
	mov ax, 4c00H
	int 21H
instalador ENDP
codigo ENDS
END inicio