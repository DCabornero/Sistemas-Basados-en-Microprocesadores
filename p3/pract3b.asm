;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 			SBM 2019. practb								;
;   Pareja: David Cabornero y Sergio Galán					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DGROUP GROUP _DATA, _BSS				;; Se agrupan segmentos de datos en uno

_DATA SEGMENT WORD PUBLIC 'DATA' 		;; Segmento de datos DATA público

_DATA ENDS

_BSS SEGMENT WORD PUBLIC 'BSS'			;; Segmento de datos BSS público

_BSS ENDS

_TEXT SEGMENT BYTE PUBLIC 'CODE' 		;; Definición del segmento de código
ASSUME CS:_TEXT, DS:DGROUP, SS:DGROUP
			
			
NUMTOASC PROC FAR	;Va extrayendo los caracteres ASCII de un número en DX:AX y los va guardando en ES:[SI+BX]
	PUSH BP
	MOV BP, 10
	ADD BX, CX
BUCLE:
	DIV BP
	ADD DL, 30H
	MOV ES:[SI+BX], DL
	MOV DX, 0
	DEC BX
	DEC CX
	JNZ BUCLE
	POP BP
	RET	
NUMTOASC ENDP

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
	PUSH AX
	LES SI, [BP+16]
	MOV BX, -1 ; Check this
	MOV CX, 3
	MOV AX, [BP+6]
	MOV DX, 0
	CALL NUMTOASC
	ADD BX, 3
	MOV CX, 4
	MOV AX, [BP+8]
	MOV DX, 0
	CALL NUMTOASC
	ADD BX, 4
	MOV CX, 5
	MOV AX, [BP+10]
	MOV DX, [BP+12]
	CALL NUMTOASC
	ADD BX, 5
	MOV AL, [BP+14]
	ADD AL, 30H
	INC BX
	MOV ES:[SI+BX], AL
	INC BX
	MOV BYTE PTR ES:[SI+BX], 0
	POP AX
	POP DX
	POP DI
	POP SI
	POP BX
	POP DS
	POP ES
	POP BP
	RET	
_createBarCode ENDP
_TEXT ENDS
END