;**************************************************************************
; SBM 2019. PRACTICA 1C
; Alumnos: David Cabornero Pascual y Sergio Galán Martín
;**************************************************************************
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
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
;MOV AX, DATOS
;MOV DS, AX  Omitimos esto ya que cambiamos DS en nuestro programa
MOV AX, PILA
MOV SS, AX
MOV AX, EXTRA
MOV ES, AX
MOV SP, 64 ; CARGA EL PUNTERO DE PILA CON EL VALOR MAS ALTO
; FIN DE LAS INICIALIZACIONES
; COMIENZO DEL PROGRAMA
; Inicializamos los valores dados
MOV AX, 0535H
MOV DS, AX
MOV BX, 0210H
MOV DI, 1011H
; Fin inicialización
MOV BYTE PTR DS:[1234H], 0BDH ; Guardamos BDh en DS:[1234H]
MOV AL, DS:[1234H] ; Leemos de 6584H = DS:[1234H]
MOV BYTE PTR [BX], 0FAH; Guardamos 0FAH en [BX] 
MOV AX, [BX] ; Leemos de 5560H = [BX]
MOV [DI], AL ; Guardamos AL = BDh en 6361H = [DI]

; FIN DEL PROGRAMA
MOV AX, 4C00H
INT 21H
INICIO ENDP
; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO 