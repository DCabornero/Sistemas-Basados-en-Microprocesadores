;**************************************************************************
; SBM 2019
; PRACTICA 4
; AUTORES: David Cabornero Pascual y Sergio Gahán Martín
;**************************************************************************
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
;CADENAS INICIALES
	INSTRUCCIONES DB 'Comandos:', 10, 'decod: Decodifica una string introducida por teclado usando codificacion Polibio con numero 5', 10, '$'
	INSTRUCCIONES2 DB 'cod: Codifica una string introducida por teclado usando codificacion Polibio con numero 5', 10, '$'
	INSTRUCCIONES3 DB 'quit: sale del programa', 10, 'Aclaraciones: La cadena introducida en decod debera constar de numeros entre 1 y 6', 10, '$'
	INSTRUCCIONES4 DB 'La cadena introducida en cod debera constar exclusivamente de letras en mayuscula y numeros', 10, 'Tamano maximo de la string: 99', 10,'$'
	INSTRUCCIONES5 DB 'Tamano maximo del comando: 10', 10, '$'
	INSTRUCCIONES6 DB 'IMPORTANTE: LA CADENA, TANTO EN COD COMO EN DECOD, TENDRA QUE ACABAR EN UN CARACTER DOLAR (SHIFT+4)',10,'$'
	INPUT DB 'Introduzca el comando: $'
	INPUTCOD DB 10, 'Introduzca la string a codificar (Solo mayusculas y numeros): $'
	INPUTDECOD DB 10, 'Introduzca la string a decodificar (Solo numeros entre 1 y 6, tendran que ser un numero par de ellos): $'
	ERRSTRING DB 10, 'Comando desconocido', 10, '$'
	INTRO DB 10, '$'
	STRING DB 100 dup(?)
	COMANDO DB 15 dup(?)
	COD DB 'cod$'
	DECOD DB 'decod$'
	QUIT DB 'quit$'
	DATOS ENDS
	

;**************************************************************************
; DEFINICION DEL SEGMENTO DE PILA
PILA SEGMENT STACK "STACK"
	DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0
PILA ENDS
;**************************************************************************
; DEFINICION DEL SEGMENTO EXTRA
EXTRA SEGMENT
EXTRA ENDS
;**************************************************************************
; DEFINICION DEL SEGMENTO DE CODIGO
CODE SEGMENT
ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA
; COMIENZO DEL PROCEDIMIENTO PRINCIPAL

INICIO PROC
	mov ax, DATOS					;Movemos los segmentos a su sitio correspondiente
	mov ds, ax
	mov ax, PILA
	mov ss, ax
	mov ax, EXTRA
	mov es, ax
initial:
	mov ah, 9
	mov dx, OFFSET INSTRUCCIONES	;Imprimimos las instrucciones
	int 21h
	mov dx, OFFSET INSTRUCCIONES2
	int 21h
	mov dx, OFFSET INSTRUCCIONES3
	int 21h
	mov dx, OFFSET INSTRUCCIONES4
	int 21h
	mov dx, OFFSET INSTRUCCIONES5
	int 21h
	mov dx, OFFSET INSTRUCCIONES6
	int 21h
	mov dx, OFFSET INPUT			;Solicitamos un comando
	int 21h
	mov ah,0AH						
	mov dx,OFFSET COMANDO			;Leemos el comando introducido
	mov COMANDO[0],10
	int 21H
	xor ax, ax						;Inicializamos ax a 0
	call CHECKCOM					;Checkeamos cual es el comando introducido
	cmp ax, 1						;Saltamos a codificar, ya que 1 representa cod
	jz cod
	cmp ax, 2						;Saltamos a decodificar, ya que 2 representa decod
	jz decod	
	cmp ax, 3						;Saltamos a quit, ya que 3 representa quit
	jz fin
	mov ah, 9
	mov dx, OFFSET ERRSTRING		;Error: el comando introducido no es ninguno de los soportados
	int 21h
	jmp initial						;En tal caso, volvemos al principio
	
cod:							;Procedemos a la codificacion
	mov ah, 9h
	mov dx, OFFSET INPUTCOD			;Solicitamos una string
	int 21h
	mov ah, 0AH
	mov dx,OFFSET STRING			;Leemos la string
	mov STRING[0],99
	int 21H
	mov ah, 9
	mov dx, OFFSET INTRO			;Imprimimos un salto de linea
	int 21H
	mov ah, 10H
	mov dx, OFFSET STRING[2]
	int 57H							;Llamamos al driver para imprimir la string codificada
	mov ah, 9
	mov dx, OFFSET INTRO			;Imprimimos un salto de linea
	int 21H
	jmp initial						;Volvemos al principio
	
decod:							;Procedemos a la decodificacion
	mov ah, 9h
	mov dx, OFFSET INPUTDECOD		;Solicitamos una string a decodificar
	int 21h
	mov ah, 0AH
	mov dx,OFFSET STRING			;Leemos la string que nos han dado
	mov STRING[0],99
	int 21H
	mov ah, 9
	mov dx, OFFSET INTRO			;Imprimimos un salto de linea
	int 21H
	mov ah, 11H
	mov dx, OFFSET STRING[2]
	int 57H							;Llamamos al driver para imprimir la string decodificada
	mov ah, 9
	mov dx, OFFSET INTRO			;Imprimimos un salto de linea
	int 21H
	jmp initial						;Volvemos al inicio
fin:
	mov ax, 4c00h					;Fin del programa
	int 21h
INICIO ENDP

CHECKCOM PROC		;DEVUELVE EN AX 1 SI EL COMANDO ES COD, 2 SI ES DECOD, 3 SI ES QUIT. SI NO, LO DEJA COMO ESTABA (A 0)
	push bx
	mov bx, 2				;bx ira recorriendo los caracteres utiles de COMANDO, omitiendo los 2 primeros bytes
							;bx tambien nos sirve para ir recorriendo la string a comparar de memoria con 2 bytes menos
buclecod:				
	mov ah, COMANDO[bx]		
	cmp ah, 0DH				;Si es retorno de carro, ya ha terminado la string introducida
	jz checkcod				;Saltamos a comprobar si la otra string tambien ha terminado
	cmp COD[bx-2], ah		;Si no, comparemos los caracteres de las dos cadenas
	jnz initdecod			;Si no son iguales, no es el comando cod
	inc bx					
	jmp buclecod			;Si son iguales seguimos comprobando hasta llegar al retorno de carro
checkcod:
	cmp COD[bx-2], '$'	
	jz rescod				;Si la string con la que comparamos también ha terminado, marcaremos que el comando es cod
							;Si no, comparamos COMANDO con otro posible comando
initdecod:
	mov bx, 2				;Inicializamos el índice
bucledecod:
	mov ah, COMANDO[bx]
	cmp ah, 0DH				
	jz checkdecod			;Si es retorno de carro, hay que comprobar que la otra string tambien ha acabado
	cmp DECOD[bx-2], ah		;Si no, comparamos los caracteres de las dos cadenas
	jnz initquit			;Si no son iguales, no es el comando decod
	inc bx
	jmp bucledecod			;Si son iguales seguimos comprobando
checkdecod:
	cmp DECOD[bx-2], '$'	
	jz resdecod				;Si la string con la que comparamos tambien ha terminado, marcaremos que el comando es decod
initquit:
	mov bx, 2				;Si no, comparamos COMANDO con otro posible comando
buclequit:
	mov ah, COMANDO[bx]
	cmp ah, 0DH				
	jz checkquit			;Si es retorno de carro, hay que comprobar que la otra string tambien ha acabado
	cmp QUIT[bx-2], ah		;Si no, comparamos los caracteres de las dos cadenas
	jnz fincheck			;Si no son iguales, no es el comando quit
	inc bx
	jmp buclequit			;Si son iguales seguimos comprobando
checkquit:
	cmp QUIT[bx-2], '$'	
	jz resquit				;Si la otra string tambien ha terminado, marcaremos que el comando es quit
	jmp fincheck
rescod:
	mov ax, 1				;Ponemos ax a 1 indicando que el comando es cod
	jmp fincheck
resdecod:
	mov ax, 2				;Ponemos ax a 2 indicando que el comando es decod
	jmp fincheck
resquit:
	mov ax, 3				;Ponemos ax a 3 indicando que el comando es quit
fincheck:
	pop bx
	ret
CHECKCOM ENDP
CODE ENDS
END INICIO

