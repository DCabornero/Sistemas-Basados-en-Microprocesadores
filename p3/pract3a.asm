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
			
;;Devuelve en AX el sumatorio
SUMATORIO PROC FAR
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
	MOV AL, DL
	MOV AH, 0
	POP DX	
	POP SI
	
	RET
SUMATORIO ENDP

;;Recibe en AX el sumatorio
;;Devuelve en AX el digito de control como entero
HALLARCONTROL PROC FAR
	PUSH BX
	
	MOV BX, 10
	DIV BL
	CMP AH, 0
	JZ CASOCERO
	SUB BL, AH
	JMP CONTINUE
	CASOCERO:
		MOV BL, 0
	CONTINUE:
	MOV AL, BL
	MOV AH, 0
	
	POP BX
	RET
HALLARCONTROL ENDP

;; Convierte el número de caracteres indicado por CX de la cadena indicada por ES:[BX] en número y lo devuelve en DX:AX
ASCTOINT PROC FAR
	PUSH BP
	MOV BP, 10
	MOV AX, 0
BUCLE:
	MUL BP
	MOV DH, ES:[BX+DI]
	SUB DH, 30H
	ADD AL, DH			;Propagamos el acarreo a los registros implicados
	ADC AH, 0
	ADC DX, 0
	INC DI
	DEC CX
	JNZ BUCLE
	POP BP
	RET

ASCTOINT ENDP
			
			
PUBLIC _computeControlDigit				;; Hacer visible y accesible la función desde C
_computeControlDigit PROC FAR 			;; En C es int unsigned long int factorial(unsigned int n)
	PUSH BP 						;; Salvaguardar BP en la pila para poder modificarle sin modificar su valor
	
	MOV BP, SP							;; Igualar BP el contenido de SP
	PUSH BX
	PUSH ES
	LES BX, [BP + 6]

	CALL SUMATORIO						;; Pondrá en la variable SUMA el valor de sumar todos los digitos siguiendo el algoritmo
	CALL HALLARCONTROL
	ADD AX, 30H						;;Conversion a caracter ascii
	
	POP ES
	POP BX
	POP BP							;; Restaurar el valor de BP antes de salir
	RET								;; Retorno de la función que nos ha llamado, devolviendo el resultado del factorial en AX
_computeControlDigit ENDP							;; Termina la funcion factorial

PUBLIC _decodeBarCode
_decodeBarCode PROC FAR
	PUSH BP
	MOV BP, SP
	PUSH ES
	PUSH BX
	PUSH DS
	PUSH SI
	PUSH CX
	PUSH DI
	LES BX, [BP+6]
	LDS SI, [BP+10]
	MOV CX, 3
	MOV DI, 0
	CALL ASCTOINT
	MOV DS:[SI], AX
	LDS SI, [BP+14]
	MOV CX, 4
	CALL ASCTOINT
	MOV DS:[SI], AX
	LDS SI, [BP+18]
	MOV CX, 5
	CALL ASCTOINT
	MOV DS:[SI], AX
	MOV DS:[SI+2], DX
	LDS SI, [BP+22]
	MOV AL, ES:[BX+DI]
	MOV DS:[SI], AL
	POP DI
	POP CX
	POP SI
	POP DS
	POP BX
	POP ES
	POP BP
	RET

_decodeBarCode ENDP
_TEXT ENDS
END