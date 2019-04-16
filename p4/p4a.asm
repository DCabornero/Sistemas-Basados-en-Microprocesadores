codigo SEGMENT
	ASSUME cs : codigo
	ORG 256
inicio: jmp instalador

; Variables globales

tabladesc DB '6789AB'
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
			

instruc DB 'Numero grupo: 5, David Cabornero y Sergio Galan.', 0AH
		DB 'Uso del programa: Sin argumentos imprime estas instrucciones,'
		DB ' con /I instala el driver si no esta instalado y con /D desinstala el driver.', 0AH
		DB 'Este driver esta: $'
instal DB 'Instalado.$'
desinstal DB 'Desinstalado.$'
nodes DB 'El driver no esta instalado o no es este driver.$'
firma DW 0DCABH
; Rutina de servicio a la interrupción
rsi PROC FAR
	; Salva registros modificados
	;push ... 
	; Instrucciones de la rutina ... 
	cmp ah, 10h
	;jz cod
	cmp ah, 11h
	;jz decod
	
	; Recupera registros modificados
	;pop ... 
	iret
rsi ENDP

instalador PROC FAR
	xor dh, dh
	mov dl, cs:[80H] ; Número de argumentos
	cmp dl, 0
	jz instrucciones
	cmp dl, 3
	jz instdes
	jmp instrucciones	;Si nos pasan algo no contemplado, imprimimos instrucciones
	instdes:
	mov dl, cs:[80H+3]
	cmp dl, 'D'
	jz desinst
	cmp dl, 'I'
	jnz instrucciones
	;inst:
	mov ax, 0
	mov es, ax
	mov ax, OFFSET rsi
	mov bx, cs
	cli	;TODO
	mov es:[57h*4], ax
	mov es:[57h*4+2], bx
	sti	;TODO
	mov dx, OFFSET instalador
	int 27h ; Acaba y deja residente 
			; PSP, variables y rutina rsi.
	
	desinst:
	;Comprobamos si el driver que está instalado es el nuestro, si es que hay alguno
	mov ax, 0
	mov es, ax
	cmp ax, es:[57h*4]
	jz nodesinst
	mov ax, 0DCABH
	mov si, es:[57h*4]
	mov es, es:[57h*4+2]
	cmp ax, es:[si-2]
	jnz nodesinst
	mov cx, 0		;Desinstalacion
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
	
	nodesinst:
	mov dx, OFFSET nodes
	mov ah, 9
	int 21H
	jmp fin
	
	
	instrucciones:
	mov ah, 9
	mov dx, OFFSET instruc
	int 21H
	mov ax, 0
	mov es, ax
	mov ax, 0DCABH
	mov si, es:[57h*4]
	mov es, es:[57h*4+2]
	cmp ax, es:[si-2]
	jz instalado			;; Solo comprueba la firma
	mov dx, OFFSET desinstal
	mov ah, 9
	int 21H
	jmp fin
	instalado:
	mov dx, OFFSET instal
	mov ah, 9
	int 21H
	fin:
	mov ax, 4c00H
	int 21H
instalador ENDP
codigo ENDS
END inicio