		PROCESSOR 16F877
		INCLUDE <P16F877.INC>
		
AUX	equ h'24'
REGA	equ h'25'		;Registros auxiliares para rutina de retardo
REGB	equ h'26'
REGC	equ h'27'
Aval equ .255			; Valor de A en subrutina de retardo
Bval equ .255			; Valor de B en subrutina de retardo	
Cval equ .76			; Valor de C en subrutina de retardo
		
		ORG 0 ;Vector de reset
		GOTO INICIO
		ORG 5
INICIO: CLRF PORTA ; Limpia PORTA
		CLRF PORTB ; Limpia PORTB
		CLRF PORTC ; Limpia PORTC
		CLRF PORTD ; Limpia PORTD
		BSF STATUS,RP0 ; Cambia a banco 1
		BCF STATUS,RP1
		MOVLW 06H ; Define puertos A y E como digitales
		MOVWF ADCON1
		MOVLW H'0'		; CONFIGURA PUERTO A COMO SALIDA
		MOVWF TRISA		; (TRISA) <-- 0h
		MOVLW H'0'		; CONFIGURA PUERTO B COMO SALIDA
		MOVWF TRISB		; (TRISB) <-- 0h
		MOVLW H'0'		; CONFIGURA PUERTO C COMO SALIDA
		MOVWF TRISC		; (TRISC) <-- 0h
		MOVLW H'0'		; CONFIGURA PUERTO D COMO SALIDA
		MOVWF TRISD		; (TRISD) <-- 0h
		BCF STATUS,RP0	; Cambia al banco 0
LOOP:
		MOVLW H'0'		; W<-- 0.  Inicializa AUX (contenido) en 0
		MOVWF AUX		; (AUX)<-- 0
LOOP_1:					; Ejecuta secuencia encendido-apagado seis veces
		MOVF AUX,W		; W<--(AUX)
		SUBLW 0x06		; W<--W-0x06
		BTFSS STATUS,Z  ;¿(CONTA)=0X06?
		GOTO ONOFF 		; NO
		GOTO LOOP_2 	; SI
LOOP_2: 				; Ejecuta secuencia de rotación a la izquierda 3 veces
		MOVF AUX,W		; W<--(AUX)
		SUBLW 0x09		; W<--W-0x09
		BTFSS STATUS,Z  ;¿(CONTA)=0X09?
		GOTO ROTAIZQ	; NO
		GOTO LOOP		; SI
		
ONOFF:					; Enciende y apaga todas las letras con retardo de 1 segundo
		MOVLW H'3F' 	; Configura activar todas las salidas de A
		MOVWF PORTA		; (PORTA)<-- 3F   -> 0011 1111
		MOVLW H'7F' 	; Configura activar todas las salidas de B
		MOVWF PORTB		; (PORTB) <-- 7F	-> 0111 1111
		MOVLW H'7F' 	; Configura activar todas las salidas de C
		MOVWF PORTC		; (PORTC) <-- 7F	-> 0111 1111
		MOVLW H'7F' 	; Configura activar todas las salidas de D
		MOVWF PORTD		; (PORTD) <-- 7F	-> 0111 1111
		CALL RETARDO	; Llamada a la subrutina de retardo (1 segundo aprox.)
		CLRF PORTA 		; Limpia PORTA
		CLRF PORTB		; Limpia PORTB
		CLRF PORTC 		; Limpia PORTC
		CLRF PORTD 		; Limpia PORTD
		CALL RETARDO	; Llamada a la subrutina de retardo (1 segundo aprox.)
		INCF AUX,F		; AUX<-- AUX+1
		GOTO LOOP_1;	
ROTAIZQ:				; Enciende y apaga de letra en letra de izquierda a derecha (1. U	2. N	3. A	4. M)
		MOVLW H'7F' 	; Configura activar todas las salidas de B
		MOVWF PORTB		 ; (PORTB) <-- 7F	-> 0111 1111   ENCIENDE LETRA U
		CALL RETARDO
		CLRF PORTB 		; Limpia PORTB		APAGA LETRA U
		MOVLW H'7F' 	; Configura activar todas las salidas de C
		MOVWF PORTC		; (PORTC) <-- 7F	-> 0111 1111	ENCIENDE LETRA N
		CALL RETARDO	
		CLRF PORTC 		; Limpia PORTC		APAGA LETRA N
		MOVLW H'3F' 	; Configura activar todas las salidas de A
		MOVWF PORTA 	; (PORTA) <-- 3F	-> 0011 1111	ENCIENDE LETRA A
		CALL RETARDO		
		CLRF PORTA 		; Limpia PORTA		APAGA LETRA A
		MOVLW H'7F' 	; Configura activar todas las salidas de D
		MOVWF PORTD		; (PORTD) <-- 7F	-> 0111 1111	ENCIENDE LETRA D
		CALL RETARDO
		CLRF PORTD 		; Limpia PORTD		APAGA LETRA M
		INCF AUX,F 		;AUX<-- AUX+1
		GOTO LOOP_2

RETARDO:MOVLW Cval	;Subrutina de retardo de aproximadamente 1 segundo
		MOVWF REGC
LOOPC:	MOVLW Bval
		MOVWF REGB
LOOPB:	MOVLW Aval
		MOVWF REGA
LOOPA:	DECFSZ REGA
		GOTO LOOPA
		DECFSZ REGB
		GOTO LOOPB
		DECFSZ REGC
		GOTO LOOPC
		RETURN
		END
