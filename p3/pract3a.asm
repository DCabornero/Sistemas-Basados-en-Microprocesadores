;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 			SBM 2019. pract3a								;
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
BCLEN EQU 12
COUCLEN EQU 3
COMPCLEN EQU 4
PCLEN EQU 5 

;; SUMATORIO
;; input: ES:[BX] puntero al inicio del código de barras
;; output: AX sumatorio de digitos según el algoritmo
SUMATORIO PROC FAR
	PUSH SI
	PUSH DX								;; Guardamos los valores de los registros implicados
	MOV DX, 0							;; Registro utilizado para realizar el sumatorio
	MOV SI, 0							;; Registro utilizado como contador de posición
	
	BUCLE:
		MOV AL, ES:[BX + SI]
		SUB AL, ASC						;; Convertimos ASCII a binario
		TEST SI, 0000000000000001B		;; Comprobamos si es par o impar
		JZ POSICIONPAR
		MOV AH, 3						;; Si es impar, tenemos que multiplicar por 3
		MUL AH
	POSICIONPAR:						;; Esto se ejecuta tanto si es par como si es impar
		ADD DL, AL						;; Sabemos que no puede haber overflow (cabe en DL)	
		INC SI							;; Incrementamos contador
		CMP SI, BCLEN					;; Si hemos leído todo el código menos el digito de control, terminamos
		JNZ BUCLE
	MOV AL, DL
	MOV AH, 0							;; Guardamos en AX el sumatorio
	POP DX	
	POP SI								;; Restauramos los registros
	
	RET
SUMATORIO ENDP

;; HALLARCONTROL
;; input: AX suma de los digitos del código según el algoritmo
;; output: AX digito de control calculado
HALLARCONTROL PROC FAR
	PUSH BX			;; Guardamos el valor de BX
	
	MOV BX, 10		;; Usamos BX como registro auxiliar para dividir por 10
	DIV BL			;; En AH nos queda el resto de la división
	CMP AH, 0		;; Si es 0 es un caso especial
	JZ CASOCERO
	SUB BL, AH		;; Si no es 0, restamos el resto a 10, lo que nos da el digito de control
	JMP CONTINUE
	CASOCERO:
		MOV BL, 0	;; Si es 0, el digito de control es 0
	CONTINUE:
	MOV AL, BL		
	MOV AH, 0		;; Guardamos el digito en AX
	
	POP BX			;; Restauramos el valor de BX
	RET
HALLARCONTROL ENDP

;; ASCTONUM
;; input: ES:[BX] puntero al inicio del elemento del código de barras a transformar, CX tamaño del elemento
;; output: DX:AX valor numérico del elemento
ASCTONUM PROC FAR
	PUSH BP				;; Guardamos el valor de BP en la pila
	MOV BP, 10			;; Utilizamos BP como registro auxiliar para multiplicar por 10
	MOV AX, 0			;; Inicializamos el acumulador a 0
BUCLE1:
	MUL BP				;; En DX:AX tenemos lo anterior multiplicado por 10
	MOV DH, ES:[BX+DI]	;; En DH ponemos el siguiente digito en ascii (DH siempre está a 0)
	SUB DH, ASC			;; Pasamos el digito a decimal
	ADD AL, DH			;; Sumamos a lo anterior el nuevo número
	ADC AH, 0
	ADC DX, 0			;; Propagamos el acarreo a los registros implicados
	MOV DH, 0			;; Eliminamos el resto que nos había quedado antes
	INC DI
	DEC CX				;; Actualizamos contadores
	JNZ BUCLE1
	POP BP				;; Restauramos valores de registros
	RET

ASCTONUM ENDP
			
;; _computeControlDigit
;; input: dirección a memoria donde está el codigo de barras en ascii
;; output: digito de control calculado en decimal
PUBLIC _computeControlDigit				;; Hacer visible y accesible la función desde C
_computeControlDigit PROC FAR
	PUSH BP 						;; Salvaguardar BP en la pila para poder modificarle sin modificar su valor
	
	MOV BP, SP							;; Igualar BP el contenido de SP
	PUSH BX								;; Guardamos registros en pila para evitar efectos colaterales
	PUSH ES
	LES BX, [BP + 6]					;; Apuntamos con ES:[BX] al inicio de la cadena 

	CALL SUMATORIO						;; Pondrá en AX el valor de sumar todos los digitos siguiendo el algoritmo
	CALL HALLARCONTROL					;; Calculará el digito de control del valor que tenga en AX y lo devolverá en AX
	
	POP ES
	POP BX
	POP BP							;; Restaurar el valor de todos los registros antes de salir
	RET								;; Retorno de la función que nos ha llamado, devolviendo el digito de control en AX
_computeControlDigit ENDP

;; _decodeBarCode
;; input: dirección a memoria donde está el código en ascii, y direcciones donde iremos guardando cada valor numérico (CountryC, PC, CompanyC, CD)
;; output: void, simplemente se rellenaran las direcciones de memoria pasadas por argumento
PUBLIC _decodeBarCode
_decodeBarCode PROC FAR
	PUSH BP
	MOV BP, SP
	PUSH ES
	PUSH BX
	PUSH DS
	PUSH SI
	PUSH CX
	PUSH DI						;; Guardamos los valores de los registros implicados en la función
	LES BX, [BP+6]				;; Apuntamos en ES:[BP] al código de barras en ascii
	LDS SI, [BP+10]				;; Apuntamos en DS:[SI] a la memoria donde almacenaremos el CountryC
	MOV CX, COUCLEN				;; Ponemos en CX el número de digitos del CountryC
	MOV DI, 0					;; Inicializamos el contador(DI) que irá recorriendo el código de barras a 0
	CALL ASCTONUM				;; Tenemos en AX el valor numérico del CountryC (DX es 0)
	MOV DS:[SI], AX				;; Guardamos el valor en la dirección de memoria correspondiente
	LDS SI, [BP+14]				;; Apuntamos en DS:[SI] a donde almacenaremos el CompanyC
	MOV CX, COMPCLEN			;; Ponemos en CX el número de digitos del CompanyC
	CALL ASCTONUM				;; Tenemos en AX el valor numérico del CompanyC (DX es 0)
	MOV DS:[SI], AX				;; Guardamos el valor en la dirección de memoria correspondiente
	LDS SI, [BP+18]				;; Apuntamos en DS:[SI] a donde almacenaremos el PC 
	MOV CX, PCLEN				;; Ponemos en CX el número de digitos del PC
	CALL ASCTONUM				;; Tenemos en DX:AX el valor numérico del PC (Ya que no cabe solo en AX, no como en los casos anteriores)
	MOV DS:[SI], AX			
	MOV DS:[SI+2], DX			;; Guardamos el valor en la dirección de memoria correspondiente
	LDS SI, [BP+22]				;; Apuntamos en DS:[SI] a donde almacenaremos el CD
	MOV AL, ES:[BX+DI]			;; Leemos el CD como ascii en AL
	SUB AL, ASC					;; Lo convertimos en decimal
	MOV DS:[SI], AL				;; Lo almacenamos en la dirección de memoria correspondiente
	POP DI
	POP CX
	POP SI
	POP DS
	POP BX
	POP ES
	POP BP						;; Recuperamos valores de los registros
	RET

_decodeBarCode ENDP
_TEXT ENDS
END