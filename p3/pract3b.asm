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
BUCLE:
	DIV BP
	ADD DL, 30H
	MOV ES:[SI+BX], DL
	MOV DX, 0
	INC BX
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
	PUSH BX
	PUSH AX
	LES SI, [BP+22]
	LDS DI, [BP+6]
	;MOV AL, DS:[DI]
	;ADD AL, 30H
	;MOV BX, 13
	MOV BX, 0
	;MOV BYTE PTR ES:[SI+BX], 0	;Escribimos el fin de string
	;DEC BX
	;MOV ES:[SI+BX], AL  ;Escribimos el dígito de control
	
	MOV CX, 3
	MOV AX, DS:[DI]
	MOV DX, 0
	CALL NUMTOASC
	LDS DI, [BP+10]
	MOV CX, 4
	MOV AX, DS:[DI]
	MOV DX, 0
	CALL NUMTOASC
	LDS DI, [BP+14]
	MOV CX, 5
	MOV AX, DS:[DI]
	MOV DX, DS:[DI+2]
	CALL NUMTOASC
	LDS DI, [BP+18]
	MOV AL, DS:[DI]
	ADD AL, 30H
	MOV ES:[SI+BX], AL
	INC BX
	MOV BYTE PTR ES:[SI+BX], 0
	
	
	;LDS DI, [BP+14]		;Apuntamos en DS al Product Code
	;MOV CX, 5			;Longitud Product Code
	;MOV AX, DS:[DI]
	;MOV DX, DS:[DI+2]	;Ponemos en DX:AX el valor del Product Code
	;CALL NUMTOASC
	;LDS DI, [BP+18] 	;Apuntamos en DS al Company Code
	;MOV CX, 4			;Longitud Company Code
	;MOV AX, DS:[DI]
	;MOV DX, 0			;Ponemos en DX:AX el valor del Company Code
	;CALL NUMTOASC
	;LDS DI, [BP+22]		;Apuntamos en DS al Country Code
	;MOV CX, 3			;Longitud Country Code
	;MOV AX, DS:[DI]
	;MOV DX, 0			;Ponemos en DX:AX el valor del Country Code
	;CALL NUMTOASC
	;POP AX
	;POP BX
	;POP DX
	;POP DI
	;POP SI
	;POP DS
	;POP ES
	;POP BP
	;RET	
_createBarCode ENDP
_TEXT ENDS
END