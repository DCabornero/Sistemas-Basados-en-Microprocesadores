;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 			SBM 2016. Practica 3 - Ejemplo					;
;   Pareja													;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DGROUP GROUP _DATA, _BSS				;; Se agrupan segmentos de datos en uno

_DATA SEGMENT WORD PUBLIC 'DATA' 		;; Segmento de datos DATA público
SUMA DB (?)
CONTROLDIGIT DB (?)
_DATA ENDS

_BSS SEGMENT WORD PUBLIC 'BSS'			;; Segmento de datos BSS público

_BSS ENDS

_TEXT SEGMENT BYTE PUBLIC 'CODE' 		;; Definición del segmento de código
ASSUME CS:_TEXT, DS:DGROUP, SS:DGROUP
			
SUMATORIO PROC FAR
	PUSH AX
	PUSH SI
	PUSH DX
	MOV DX, 0							;; Registro utilizado para realizar el sumatorio
	MOV SI, 0							;; Registro utilizado como contador de posición
	
	BUCLE:
		MOV AL, ES:[BX + SI]
		SUB AL, 30H						;; Convertimos ASCII a binario
		TEST SI, 0000000000000001B
		JZ POSICIONPAR
		MOV AH, 3						;; Tenemos que multiplicar por 3
		MUL AH
	POSICIONPAR:						;; Esto se ejecuta tanto si es par como si es impar
		ADD DL, AL						;; Sabemos que no puede haber overflow (cabe en DL)	
		INC SI
		CMP SI, 12
		JNZ BUCLE
	MOV SUMA, DL
	POP DX	
	POP SI
	POP AX
	
	RET
SUMATORIO ENDP


HALLARCONTROL PROC FAR
	PUSH AX
	PUSH BX
	
	MOV AL, SUMA
	MOV AH, 0
	MOV BX, 10
	DIV BL
	CMP AH, 0
	JZ CASOCERO
	SUB BL, AH
	JMP CONTINUE
	CASOCERO:
		MOV BL, 0
	CONTINUE:
	MOV CONTROLDIGIT, BL
	
	POP BX
	POP AX
	RET
HALLARCONTROL ENDP
			
			
PUBLIC _computeControlDigit				;; Hacer visible y accesible la función desde C
_computeControlDigit PROC FAR 			;; En C es int unsigned long int factorial(unsigned int n)
	PUSH BP 						;; Salvaguardar BP en la pila para poder modificarle sin modificar su valor
	
	MOV BP, SP							;; Igualar BP el contenido de SP
	PUSH BX
	LES BX, [BP + 6]

	CALL SUMATORIO						;; Pondrá en la variable SUMA el valor de sumar todos los digitos siguiendo el algoritmo
	CALL HALLARCONTROL
	MOV AL, CONTROLDIGIT
	ADD AL, 30H
	MOV AH, 0
	
	POP BX
	POP BP							;; Restaurar el valor de BP antes de salir
	RET								;; Retorno de la función que nos ha llamado, devolviendo el resultado del factorial en AX
_computeControlDigit ENDP							;; Termina la funcion factorial


_TEXT ENDS
END