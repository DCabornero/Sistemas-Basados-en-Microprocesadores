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
	INPUTDECOD DB 10, 'Introduzca la string a decodificar (Solo numeros entre 1 y 6): $'
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
; COMIENZO DEL PROCEDIMIENTO PRINCIPah

INICIO PROC
mov ax, DATOS
mov ds, ax
mov ax, PILA
mov ss, ax
mov ax, EXTRA
mov es, ax
initial:
mov ah, 9
mov dx, OFFSET INSTRUCCIONES
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
mov dx, OFFSET INPUT
int 21h
mov ah,0AH
mov dx,OFFSET COMANDO
mov COMANDO[0],10
int 21H
xor ax, ax
call CHECKCOM
cmp ax, 1
jz cod
cmp ax, 2
jz decod
cmp ax, 3
jz fin
mov ah, 9
mov dx, OFFSET ERRSTRING
int 21h
jmp initial
cod:
mov ah, 9h
mov dx, OFFSET INPUTCOD
int 21h
mov ah, 0AH
mov dx,OFFSET STRING
mov STRING[0],99
int 21H
mov ah, 9
mov dx, OFFSET INTRO
int 21H
mov ah, 10H
mov dx, OFFSET STRING[2]
int 57H
mov ah, 9
mov dx, OFFSET INTRO
int 21H
jmp initial
decod:
mov ah, 9h
mov dx, OFFSET INPUTDECOD
int 21h
mov ah, 0AH
mov dx,OFFSET STRING
mov STRING[0],99
int 21H
mov ah, 9
mov dx, OFFSET INTRO
int 21H
mov ah, 11H
mov dx, OFFSET STRING[2]
int 57H
mov ah, 9
mov dx, OFFSET INTRO
int 21H
jmp initial
fin:
mov ax, 4c00h
int 21h
INICIO ENDP

CHECKCOM PROC		;DEVUELVE EN AH 1 SI EL COMANDO ES COD, 2 SI ES DECOD, 3 SI ES QUIT. SI NO, LO DEJA COMO ESTABA (A 0)
push bx
mov bx, 2
buclecod:
mov ah, COMANDO[bx]
cmp ah, 0DH
jz checkcod
cmp COD[bx-2], ah
jnz initdecod
inc bx
jmp buclecod
checkcod:
cmp COD[bx-2], '$'
jz rescod
initdecod:
mov bx, 2
bucledecod:
mov ah, COMANDO[bx]
cmp ah, 0DH
jz checkdecod
cmp DECOD[bx-2], ah
jnz initquit
inc bx
jmp bucledecod
checkdecod:
cmp DECOD[bx-2], '$'
jz resdecod
initquit:
mov bx, 2
buclequit:
mov ah, COMANDO[bx]
cmp ah, 0DH
jz checkquit
cmp QUIT[bx-2], ah
jnz fincheck
inc bx
jmp buclequit
checkquit:
cmp QUIT[bx-2], '$'
jz resquit
jmp fincheck
jmp buclequit
rescod:
mov ax, 1
jmp fincheck
resdecod:
mov ax, 2
jmp fincheck
resquit:
mov ax, 3
fincheck:
pop bx
ret
CHECKCOM ENDP
CODE ENDS
END INICIO

