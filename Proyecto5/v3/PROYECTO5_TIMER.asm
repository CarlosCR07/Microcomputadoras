processor 16f877a
include <p16f877.inc>
CBLOCK 0X20 ;DATOS A PARTIR DE LOCALIDAD 0X20
	N1
	N2
	N3
	DATO
	CONTADOR
	CONTADOR2
	CONTADOR3
ENDC


	ORG 0
	GOTO INICIO
	ORG 4
	GOTO INTERRUPCION
	ORG 5

INTERRUPCION:
	DECFSZ CONTADOR,F		;�EL CONTADOR YA LLEG� A 0?
	GOTO SAL_INT			; SI NO, SAL A SEGUIR CON TU EJECUCI�N
	GOTO CUENTA_2			;SI SI, VETE CON EL SIGUIENTE CONTADOR
CUENTA_2:
	DECFSZ CONTADOR2,F		;�EL CONTADOR YA LLEG� A 0?
	GOTO SAL_INT			; SI NO, SAL A SEGUIR CON TU EJECUCI�N
	GOTO SALIR			;SI SI, VETE CON EL SIGUIENTE CONTADOR
SAL_INT:
	MOVLW 0X00				;REGRESAMOS EL TMR0 A 0 PARA QUE CUENTE OTROS 13.10 ms
	BCF INTCON,T0IF 		;VOLVEMOS LA BANDERA DE DESBORDAMIENTO A 0 
	RETFIE					;VOLVEMOS DE LA INTERRUPCION


INICIO:
	BSF STATUS,RP0
	BCF STATUS,RP1
	CLRF TRISD

	;CONFIGURACION DE USART E INTERRUPCIONES
	BCF TRISC,RC6 			;SE HABILITA TX COMO SALIDA
	BSF TRISC,RC7 			;SE HABILITA RX COMO ENTRADA
	BSF TXSTA,BRGH 			;SI BRGH=0, TENEMOS BAUDAJE BAJO
	MOVLW D'129'			;32 DECIMAL
	MOVWF SPBRG				;32 EN SPBRG ES PARA 9600 BAUDIOS SEGUN TABLA
	BCF TXSTA,SYNC 			;SI SYNC=0, TENEMOS COMUNICACION ASINCRONA
	BSF TXSTA,TXEN 			;ACTIVAMOS LA TRANSMISION
	
	MOVLW B'00000111'
	MOVWF OPTION_REG		;PREDIVISOR DEL TMR0 EN 256

	BCF STATUS,RP0			;BANCO 0

	BSF RCSTA,CREN 			;CREN=1 HABILITA RECEPCION CONTINUA
	BSF RCSTA,SPEN 			;SPEN=1 HABILITA EL PUERTO SERIE 
	BCF INTCON,T0IF			;PONEMOS EN 0 LA BANDERA DE DESBORDAMIENTO
	BSF INTCON,T0IE			;HABILITAMOS INTERRUPCIONES POR DESBORDAMIENTO EN EL TIMER 0 	
	BSF INTCON,GIE			;HABILITAMOS INTERRUPCIONES GENERALES
	BSF INTCON,INTE			;HABILITAMOS INTERRUPCIONES EXTERNAS
	BSF INTCON,PEIE			;HABILITAMOS INTERRUPCIONES PERIFERICAS
	
	;NOTA: NO TOCAR PORTC NI RB0 DEL PORTB
	CLRF PORTD

	MOVLW 0X00
	MOVWF TMR0 				;T0IF = (0.2us)(256)(256 - 0) -> 256 DEL PREDIVISOR Y 0 DEL TMR0 = 13.10 MS
	MOVLW 0XFF
	MOVWF CONTADOR			;CONTADOR = 256 -> 256*13.10 = 3.3536 segundos de funcionamiento
	MOVLW 0X1B
	MOVWF CONTADOR2			;CONTADOR2 = 27 -> 27*(3.3536) = 90.5472 segundos de funcionamiento (MINUTO Y MEDIO)

PRUEBA_W:
	BTFSS PIR1,RCIF 		;SI EL DATO SE RECIBI�, RCIF = 1
	GOTO PRUEBA_W
	MOVF RCREG,W			;CARGAMOS EL DATO RECIBIDO EN W
	MOVWF DATO
	MOVLW a'W'
	SUBWF DATO
	BTFSS STATUS,Z
	GOTO PRUEBA_A
	GOTO AVANZA

PRUEBA_A:
	MOVF RCREG,W			;CARGAMOS EL DATO RECIBIDO EN W
	MOVWF DATO
	MOVLW a'A'
	SUBWF DATO
	BTFSS STATUS,Z
	GOTO PRUEBA_S
	GOTO IZQUIERDA

PRUEBA_S:
	MOVF RCREG,W			;CARGAMOS EL DATO RECIBIDO EN W
	MOVWF DATO
	MOVLW a'S'
	SUBWF DATO
	BTFSS STATUS,Z
	GOTO PRUEBA_D
	GOTO ATRAS

PRUEBA_D:
	MOVF RCREG,W			;CARGAMOS EL DATO RECIBIDO EN W
	MOVWF DATO
	MOVLW a'D'
	SUBWF DATO
	BTFSS STATUS,Z
	GOTO PRUEBA_V
	GOTO DERECHA

PRUEBA_V:
	MOVLW a'V'
	SUBLW DATO
	BTFSS STATUS,Z
	GOTO ALTO
	GOTO ALTO

AVANZA:
	MOVLW a'A'
	MOVWF TXREG
	CALL TRANS_INIC
	MOVLW a'V'
	MOVWF TXREG
	CALL TRANS_INIC
	MOVLW a'A'
	MOVWF TXREG
	CALL TRANS_INIC
	MOVLW B'00000110' ; Giran en sentido contrario - Adelante
	MOVWF PORTD
	GOTO PRUEBA_W

IZQUIERDA:
	MOVLW a'I'
	MOVWF TXREG
	CALL TRANS_INIC
	MOVLW a'Z'
	MOVWF TXREG
	CALL TRANS_INIC
	MOVLW a'Q'
	MOVWF TXREG
	CALL TRANS_INIC
	MOVLW B'00000101' ; Giran en mismo sentido - Giro izquierda
	MOVWF PORTD
	GOTO PRUEBA_W

DERECHA:
	MOVLW a'D'
	MOVWF TXREG
	CALL TRANS_INIC
	MOVLW a'E'
	MOVWF TXREG
	CALL TRANS_INIC
	MOVLW a'R'
	MOVWF TXREG
	CALL TRANS_INIC
	MOVLW B'00001010' ; Giran en mismo sentido - Giro derecha
	MOVWF PORTD
	GOTO PRUEBA_W

ATRAS:
	MOVLW a'A'
	MOVWF TXREG
	CALL TRANS_INIC
	MOVLW a'T'
	MOVWF TXREG
	CALL TRANS_INIC
	MOVLW a'R'
	MOVWF TXREG
	CALL TRANS_INIC
	MOVLW B'00001001' ; Giran en sentido contrario - Atras
	MOVWF PORTD
	GOTO PRUEBA_W

ALTO:
	CLRF PORTD
	GOTO PRUEBA_W

TRANS_INIC:
	BSF STATUS,RP0
TRANSMITE:
	BTFSS TXSTA,TRMT
	GOTO TRANSMITE
	BCF STATUS,RP0
	RETURN

DELAY_1SEG
	MOVLW	0X2D
	MOVWF	N1
	MOVLW	0XE7
	MOVWF	N2
	MOVLW	0X0B
	MOVWF	N3
REPITE_1SEG
	DECFSZ	N1, F
	GOTO	$+2
	DECFSZ	N2, F
	GOTO	$+2
	DECFSZ	N3, F
	GOTO	REPITE_1SEG
	RETURN

SALIR:
	CLRF PORTD 		;SE DETIENE EL CARRITO
	NOP				;NO SE HACE NADA M�S
	GOTO $-1		;EL PROGRAMA SE CICLA AQUI PARA QUE NO HAGA COSAS INESPERADAS.

END