;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 			SBM 2019. practb								;
;   Pareja: David Cabornero y Sergio Galán					;
;	Grupo: 2301												;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DGROUP GROUP _DATA, _BSS				;; Se agrupan segmentos de datos en uno

_DATA SEGMENT WORD PUBLIC 'DATA' 		;; Segmento de datos DATA público

_DATA ENDS

_BSS SEGMENT WORD PUBLIC 'BSS'			;; Segmento de datos BSS público

_BSS ENDS

_TEXT SEGMENT BYTE PUBLIC 'CODE' 		;; Definición del segmento de código
ASSUME CS:_TEXT, DS:DGROUP, SS:DGROUP
			
;; MACROS
ASC EQU 30H
COUCLEN EQU 3
COMPCLEN EQU 4
PCLEN EQU 5

;; NUMTOASC
;; input: DX:AX número a transformar en ascii, ES:[SI] puntero al inicio del campo a rellenar, CX número de dígitos del campo
;; output: ninguno, se va guardando en la memoria directamente
NUMTOASC PROC FAR
	PUSH BP					;; Guardamos registros implicados	
	MOV BP, 10				;; Usamos BP como reg aux para dividir por 10
	ADD BX, CX				;; Para escribir el campo al revés, añadimos al offset la longitud del campo
BUCLE:
	DIV BP					;; El resto se nos guarda en DL
	ADD DL, ASC				;; Convertimos el resto a ascii
	MOV ES:[SI+BX], DL		;; Guardamos el dígito en su posición de memoria
	MOV DX, 0				;; Preparamos DX para la siguiente iteración
	DEC BX
	DEC CX					;; Actualizamos contador y offset
	JNZ BUCLE
	POP BP					;; Recuperamos los registros
	RET	
NUMTOASC ENDP

;; _createBarCode
;; input: CountryC(uint), CompanyC(uint), PC(long int), CD(uchar), puntero a donde escribir el código 
;; output: ninguno
PUBLIC _createBarCode
_createBarCode PROC FAR
	PUSH BP
	MOV BP, SP
	PUSH ES
	PUSH DS
	PUSH BX
	PUSH SI
	PUSH DI
	PUSH DX
	PUSH AX							;; Guardamos los registros implicados
	LES SI, [BP+16]					;; Apuntamos en ES:[SI] a la memoria donde escribiremos el código
	MOV BX, -1 						;; Lo inicializamos a -1 para poder escribir los campos correctamente en la función NUMTOASC
	MOV CX, COUCLEN					;; Ponemos en CX el número de dígitos de CountryC
	MOV AX, [BP+6]					
	MOV DX, 0						;; Ponemos en DX:AX el valor númerico del CountryC
	CALL NUMTOASC					;; La función se encarga de transformar el número a ascii y guardarlo
	ADD BX, COUCLEN					;; Actualizamos el puntero
	MOV CX, COMPCLEN				;; Ponemos en CX el número de dígitos del CompanyC
	MOV AX, [BP+8]
	MOV DX, 0						;; Ponemos en DX:AX el valor númerico del CompanyC
	CALL NUMTOASC					;; La función se encarga de transformar el número a ascii y guardarlo
	ADD BX, COMPCLEN				;; Actualizamos el puntero
	MOV CX, PCLEN					;; Ponemos en CX el número de dígitos del PC
	MOV AX, [BP+10]
	MOV DX, [BP+12]					;; Ponemos en DX:AX el valor numérico del PC
	CALL NUMTOASC					;; La función se encarga de transformar el número a ascii y guardarlo
	ADD BX, PCLEN					;; Actualizamos el puntero
	MOV AL, [BP+14]					;; Guardamos en AL
	ADD AL, ASC						;; Lo pasamos a ascii
	INC BX
	MOV ES:[SI+BX], AL				;; Guardamos el digito de control en su posición
	INC BX
	MOV BYTE PTR ES:[SI+BX], 0		;; Ponemos un /0 al final
	POP AX
	POP DX
	POP DI
	POP SI
	POP BX
	POP DS
	POP ES
	POP BP							;; Recuperamos los registros
	RET	
_createBarCode ENDP
_TEXT ENDS
END