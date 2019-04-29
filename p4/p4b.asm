;**************************************************************************
; SBM 2019
; PRACTICA 4
; AUTORES: David Cabornero Pascual y Sergio Galán Martín
;**************************************************************************
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
;CADENAS INICIALES
	FRASE1 DB 'El mensaje a cifrar es: $'
	FRASE2 DB 10, 'El mensaje a descifrar es: $'
	FRASE3 DB 10, 'El mensaje cifrado es: $'
	FRASE4 DB 10, 'El mensaje descifrado es: $'
	TOCOD DB 'PRUEBA02498$'
	TODECOD DB '4244512316156163651413$'
	INTRO DB 'La matriz Polibio utilizada es:', 10, '$'
	INTERLINEADO DB '-*---*---*---*---*---*---*', 10, '$'
	FILA1 DB ' | 1 | 2 | 3 | 4 | 5 | 6 |', 10, '$'
	FILA2 DB '1| 6 | 7 | 8 | 9 | A | B |', 10, '$'
	FILA3 DB '2| C | D | E | F | G | H |', 10, '$'
	FILA4 DB '3| I | J | K | L | M | N |', 10, '$'
	FILA5 DB '4| O | P | Q | R | S | T |', 10, '$'
	FILA6 DB '5| U | V | W | X | Y | Z |', 10, '$'
	FILA7 DB '6| 0 | 1 | 2 | 3 | 4 | 5 |', 10, '$'
	
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
mov ax, DATOS						;Movemos los segmentos al su sitio
mov ds, ax
mov ax, PILA
mov ss, ax
mov ax, EXTRA
mov es, ax
mov ah, 9
mov dx, OFFSET INTRO			;Imprimimos nuestra tabla de Polibio
int 21h
mov dx, OFFSET INTERLINEADO
int 21h
mov dx, OFFSET FILA1
int 21h
mov dx, OFFSET INTERLINEADO
int 21h
mov dx, OFFSET FILA2
int 21h
mov dx, OFFSET INTERLINEADO
int 21h
mov dx, OFFSET FILA3
int 21h
mov dx, OFFSET INTERLINEADO
int 21h
mov dx, OFFSET FILA4
int 21h
mov dx, OFFSET INTERLINEADO
int 21h
mov dx, OFFSET FILA5
int 21h
mov dx, OFFSET INTERLINEADO
int 21h
mov dx, OFFSET FILA6
int 21h
mov dx, OFFSET INTERLINEADO
int 21h
mov dx, OFFSET FILA7
int 21h
mov dx, OFFSET INTERLINEADO
int 21h
mov dx, OFFSET FRASE1			;Ponemos el mensaje a cifrar
int 21h
mov dx, OFFSET TOCOD
int 21h
mov dx, OFFSET FRASE3			;Ponemos el mensaje cifrado
int 21h
mov dx, OFFSET TOCOD
mov ah, 10H
int 57H							;Imprimimos el mensaje cifrado con las letras de una en una
mov dx, OFFSET FRASE2
mov ah, 9
int 21h
mov dx, OFFSET TODECOD			;Imprimimos el mensaje decodificado
int 21h
mov dx, OFFSET FRASE4
int 21h
mov dx, OFFSET TODECOD			
mov ah, 11h
int 57h							;Imprimimos el mensaje decodificado con las letras de una en una
mov ax, 4c00h
int 21h
INICIO ENDP
CODE ENDS
END INICIO