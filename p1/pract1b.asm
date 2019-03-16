;**************************************************************************
; SBM 2019. PRACTICA 1B
; Alumnos: David Cabornero Pascual y Sergio Galán Martín
;**************************************************************************
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
CONTADOR DB ? ; Reservamos un byte vacío
TOME DW 0CAFEH ; Reservamos dos bytes y los rellenamos con CAFEH
TABLA100 DB 100 dup(?) ; Reservamos una tabla de 100 bytes vacía
ERROR1 DB "Atención: Entrada de datos incorrecta." ; Reservamos una tabla de bytes y la rellenamos con una frase
DATOS ENDS
;**************************************************************************
; DEFINICION DEL SEGMENTO DE PILA
PILA SEGMENT STACK "STACK"
DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0
PILA ENDS
;**************************************************************************
; DEFINICION DEL SEGMENTO EXTRA
EXTRA SEGMENT
RESULT DW 0,0 ;ejemplo de inicialización. 2 PALABRAS (4 BYTES)
EXTRA ENDS
;**************************************************************************
; DEFINICION DEL SEGMENTO DE CODIGO
CODE SEGMENT
ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA
; COMIENZO DEL PROCEDIMIENTO PRINCIPAL
INICIO PROC
; INICIALIZA LOS REGISTROS DE SEGMENTO CON SU VALOR
MOV AX, DATOS
MOV DS, AX
MOV AX, PILA
MOV SS, AX
MOV AX, EXTRA
MOV ES, AX
MOV SP, 64 ; CARGA EL PUNTERO DE PILA CON EL VALOR MAS ALTO
; FIN DE LAS INICIALIZACIONES
; COMIENZO DEL PROGRAMA
MOV AL, ERROR1[2H] ; Guardamos temporalmente el 3er byte de ERROR1 en AL
MOV TABLA100[63H], AL ; Guardamos dicho byte en la posición 63H de TABLA100
MOV AX, TOME ; Guardamos temporalmente TOME (2 bytes) en AX
; Descomponemos el guardar TOME en TABLA100 en dos instrucciones
MOV TABLA100[23H], AH ; Guardamos el MSB de AX(TOME) en TABLA100
MOV TABLA100[23H+1H], AL ; Guardamos el MSB de AX(TOME) en TABLA100
MOV CONTADOR, AH ; Guardamos el MSB de AX(TOME) en CONTADOR

; FIN DEL PROGRAMA
MOV AX, 4C00H
INT 21H
INICIO ENDP
; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO 