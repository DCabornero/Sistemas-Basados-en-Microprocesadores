;**************************************************************************
; SBM 2019
; PRACTICA 4
; AUTORES: David Cabornero Pascual y Sergio Galán Martín
;**************************************************************************
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
;CADENAS INICIALES
	TOCOD DB 'PRUEBA02498$'
	TODECOD DB '4244512316156163651413$'
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
mov dx, OFFSET TOCOD
mov ah, 10H
int 57H
mov dx, OFFSET TODECOD
mov ah, 11h
int 57h
mov ax, 4c00h
int 21h
INICIO ENDP
CODE ENDS
END INICIO
