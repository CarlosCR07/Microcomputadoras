		PROCESSOR 16F877
		INCLUDE <P16F877.INC>
		
valor	equ h'20'			;Registros auxiliares para rutina de retardo
valor1	equ h'21'
valor2	equ h'22'
contadorCentesima equ h'23'	;Registros auxiliares para conversión Hexa - Decimal
contadorDecima equ h'24'
contadorUnidad equ h'25'
aux equ h'27'
regaux equ h'27'			;Registros auxiliares para visualizar en Hexadecimal
regaux2 equ h'28'
conver equ h'29'
resNivel equ h'30'
cte1 equ .83
			ORG 0 ;Vector de reset
			GOTO INICIO
			ORG 5

INICIO:		CLRF PORTA ; Limpia PORTA
			CLRF PORTB ; Limpia PORTB
			CLRF PORTC 	; Limpia PORTC
			CLRF PORTD 	; Limpia PORTD
			CLRF PORTE	; Limpia PORTE
			BSF STATUS,5 ; Cambia a banco 1
			BCF STATUS,6
			MOVLW 0x00
			MOVWF TRISB	;TRISB<- 0x00 configuramos puerto B como salida
			MOVLW H'0'		; CONFIGURA PUERTO C COMO SALIDA
			MOVWF TRISC		; (TRISC) <-- 0h
			MOVLW 0xFF		; CONFIGURA PUERTO D COMO ENTRADA
			MOVWF TRISD		; (TRISD) <-- FFh
			MOVLW 0xFF		; CONFIGURA PUERTO E COMO ENTRADA
			MOVWF TRISE		; (TRISE) <-- FFh
			;MOVLW 0x01	
			;MOVWF TRISA	 ;TRISA <- 0x01, configura puerto A como salida excepto el bit 0 
			CLRF TRISA		;limpia TRISA, todos los pines son salidas
			BSF TRISA,0		;el bit 0 de PORTA es entrada
			MOVLW 0x0E		;1110, hace al bit 0 del puerto A analógico y el resto digitales
			MOVWF ADCON1 	;ADCON1 <- 0x0E, configura puerto A y E como entradas digitales exceptuando el bit 0 del puerto A
			BCF STATUS,5 	;Regresamos al banco 0
			CALL INICIA_LCD
			MOVLW 0x80
			CALL COMANDO
			MOVLW B'00000001' ;ADFM=0,se configura el canal 0 (PORTA.0) como la entrada al convertidor. Frecuencia de oscilador Fosc/2, se enciende el modulo convertidor
			MOVWF ADCON0	;ADCON0<-W
			CALL RETARDO	;retardo de 50us
			
LOOP_P:		CALL RETARDO
			BSF ADCON0,GO	;ADCON0.GO<- 1, iniciamos la conversion
ESPERA:		BTFSC ADCON0,GO	;¿ADCON0.GO==0?
			GOTO ESPERA		;se retiene hasta que termine la conversion	
CONTINUA:	MOVF ADRESH,W	;W<-ADRESH
			MOVWF conver	;(conver)<- W			almacenamos el resultado de la conversion en conver
			MOVF PORTE,W	;W<-- (PORTE)
			ANDLW 7			;W <-- W&00000111
			ADDWF PCL,F		;(PCL)<-- (PCL)+W
			GOTO DECIMAL	;PC+0	-> Switches: 000	Conversión entrada dipswitch de 8 bits a decimal
			GOTO HEXADECIMAL;PC+1	-> Switches: 001	Conversión entrada dipswitch de 8 bits a hexadecimal
			GOTO BINARIO	;PC+2	-> Switches: 010	Conversión entrada dipswitch de 8 bits a binario
			GOTO VOLTAJE	;PC+3	-> Switches: 011	
			GOTO CARGA		;PC+4	-> Switches: 100
			GOTO PRUEBA		;PC+5 -> Switches: 101
			GOTO DEFAULT	;PC+6 -> -> Switches: 110
			GOTO DEFAULT	;PC+7 -> -> Switches: 111

PRUEBA:		MOVLW a'P'
			CALL DATOS
			MOVLW 0x01				;NO, Limpia Display
			CALL COMANDO
			MOVLW 0x80			;regresa a inicio linea 1
			CALL COMANDO
			GOTO LOOP_P
DECIMAL:	CLRF contadorCentesima		;Inicializa en 0
			CLRF contadorDecima			;Inicializa en 0
			CLRF contadorUnidad			;Inicializa en 0
			MOVLW a'D'
			CALL DATOS
			MOVLW 0x3A		;Dos puntos
			CALL DATOS
			MOVF conver,W	;Leer el valor de los switches y lo almacena en aux
			MOVWF aux	
	
LOOP_Centesimas:MOVLW 0x64				;Restar 100
				SUBWF aux
				BTFSC STATUS,C			;Verifica el estado de carry
				GOTO CentesimaEncontrada	;SI hay carry, el resultado es un número positivo				
				MOVLW 0x64
				ADDWF aux 					;NO hay carry, entonces recuperar residuo
LOOP_Decimas:	MOVLW 0x0A
				SUBWF aux				;Restar 10
				BTFSC STATUS,C			;Verifica el estado de carry
				GOTO DecimaEncontrada		;SI hay carry, el resultado es un número positivo
				MOVLW 0x0A
				ADDWF aux 					;NO hay carry, entonces recuperar residuo = Unidades
				MOVF aux,w
				MOVWF contadorUnidad	;Guardar en contador

MostrarDigitos:	MOVF contadorCentesima,W	
				ADDLW 0x30					;Obtener valor ASCII
				CALL DATOS					;Display Centesimas
				MOVF contadorDecima,W		
				ADDLW 0x30					;Obtener valor ASCII
				CALL DATOS					;Display Decimas
				MOVF contadorUnidad,W		
				ADDLW 0x30					;Obtener valor ASCII
				CALL DATOS					;Display Unidades

HOLD_DECIMAL:	MOVF PORTE,W
				SUBLW 0x01 		;W<--W-0x10
				BTFSC STATUS,Z  	;¿(CONTA)=0X10?
				GOTO HOLD_DECIMAL 		;SI			
				MOVLW 0x01				;NO, Limpia Display
				CALL COMANDO
				MOVLW 0x80			;regresa a inicio linea 1
				CALL COMANDO
				CLRF W
				GOTO LOOP_P	

CentesimaEncontrada:INCF contadorCentesima
					GOTO LOOP_Centesimas

DecimaEncontrada:	INCF contadorDecima	
					GOTO LOOP_Decimas

HEXADECIMAL:MOVLW a'H'
			CALL DATOS
			MOVLW 0x3A		;Dos puntos
			CALL DATOS
			CLRF W
			MOVF conver,W
			MOVWF regaux2
			MOVF regaux2,W	;restauramos el valor guardado por si acaso sufriese algun cambio
			ANDLW 0xF0		;extraemos la parte alta
			MOVWF regaux	;regaux <- W
			RRF regaux,f
			RRF regaux,f
			RRF regaux,f
			RRF regaux,f	;convertida en parte baja
			CALL CONVERHEXA
			MOVF regaux2,W	;restauramos el valor guardado por si acaso sufriese algun cambio
			ANDLW 0x0F		;extraemos la parte BAJA
			MOVWF regaux	;regaux <- W
			CALL CONVERHEXA
HOLD_HEX:	MOVF PORTE,W		;FUNCION PARA RETENER EL RESULTADO EN LCD
			SUBLW 0x01 ;  W<--W-0x30
			BTFSC STATUS,Z  ;¿(CONTA)=0X20?
			GOTO HOLD_HEX	;SI			
			MOVLW 0x01		;NO, Limpia Display
			CALL COMANDO
			MOVLW 0x80		;regresa a inicio linea 1
			CALL COMANDO
			CLRF W
			GOTO LOOP_P	
CONVERHEXA:	MOVF regaux,W	; W<- (regaux)
			;ANDLW 15			;W <-- W&00001111, el cuarto bit siempre está activo para las letras
			ADDWF PCL,F		;(PCL)<-- (PCL)+W
			GOTO CASO0		;PC+0	Caso 0000: Numero 0
			GOTO CASO1		;PC+1	Caso 0001: Numero 1
			GOTO CASO2		;PC+2	Caso 0010: Numero 2
			GOTO CASO3		;PC+3	Caso 0011: Numero 3
			GOTO CASO4		;PC+4	Caso 0100: Numero 4
			GOTO CASO5		;PC+5	Caso 0101: Numero 5
			GOTO CASO6		;PC+6	Caso 0110: Numero 6
			GOTO CASO7		;PC+7 	Caso 0111: Numero 7
			GOTO CASO8		;PC+8	Caso 1000: Numero 8
			GOTO CASO9		;PC+9	Caso 1001: Numero 9
			GOTO CASOA		;PC+10	Caso 1010: Letra A 
			GOTO CASOB		;PC+11	Caso 1011: Letra B 
			GOTO CASOC		;PC+12	Caso 1100: Letra C 
			GOTO CASOD		;PC+13	Caso 1101: Letra D 
			GOTO CASOE		;PC+14	Caso 1110: Letra E 
			GOTO CASOF		;PC+15	Caso 1111: Letra F 
CASO0:		MOVLW a'0'
			GOTO CONVEND
CASO1:		MOVLW a'1'
			GOTO CONVEND
CASO2:		MOVLW a'2'
			GOTO CONVEND
CASO3:		MOVLW a'3'
			GOTO CONVEND
CASO4:		MOVLW a'4'
			GOTO CONVEND
CASO5:		MOVLW a'5'
			GOTO CONVEND
CASO6:		MOVLW a'6'
			GOTO CONVEND
CASO7:		MOVLW a'7'
			GOTO CONVEND
CASO8:		MOVLW a'8'
			GOTO CONVEND
CASO9:		MOVLW a'9'
			GOTO CONVEND
CASOA:		MOVLW a'A'
			GOTO CONVEND
CASOB:		MOVLW a'B'
			GOTO CONVEND
CASOC:		MOVLW a'C'
			GOTO CONVEND
CASOD:		MOVLW a'D'
			GOTO CONVEND
CASOE:		MOVLW a'E'
			GOTO CONVEND
CASOF:		MOVLW a'F'
			GOTO CONVEND

CONVEND:	CALL DATOS		; Imprimimos el simbolo en el LCD
			CLRF W
			RETURN

BINARIO:	MOVF conver,W
			MOVLW a'B'
			CALL DATOS
			MOVLW 0x3A		;Dos puntos
			CALL DATOS
			;CLRF conver		;PRUEBA DE FUNCIÓN
			BTFSC conver,7
			CALL ES_UNO
			BTFSS conver,7
			CALL ES_CERO
			BTFSC conver,6
			CALL ES_UNO
			BTFSS conver,6
			CALL ES_CERO
			BTFSC conver,5
			CALL ES_UNO
			BTFSS conver,5
			CALL ES_CERO
			BTFSC conver,4
			CALL ES_UNO
			BTFSS conver,4
			CALL ES_CERO
			BTFSC conver,3
			CALL ES_UNO
			BTFSS conver,3
			CALL ES_CERO
			BTFSC conver,2
			CALL ES_UNO
			BTFSS conver,2
			CALL ES_CERO
			BTFSC conver,1
			CALL ES_UNO
			BTFSS conver,1
			CALL ES_CERO
			BTFSC conver,0
			CALL ES_UNO
			BTFSS conver,0
			CALL ES_CERO
HOLD_BIN:	MOVF PORTE,W
			SUBLW 0x02 ;  W<--W-0x30
			BTFSC STATUS,Z  ;¿(CONTA)=0X30?
			GOTO HOLD_BIN ;SI			
			MOVLW 0x01		;Limpia Display
			CALL COMANDO
			MOVLW 0x80		;regresa a inicio linea 1
			CALL COMANDO
			CLRF W
			GOTO LOOP_P		
ES_UNO:		MOVLW a'1'
			CALL DATOS
			RETURN
ES_CERO		MOVLW a'0'
			CALL DATOS
			RETURN

VOLTAJE:	CALL UNIVOLT	;Caso para mostrar Voltaje leído en decimal. Resolucion de 1
			MOVLW a'.'
			CALL DATOS
			CALL DECVOLT
			CALL CENVOLT
			MOVLW a' '
			CALL DATOS
			MOVLW a'V'
			CALL DATOS
			MOVLW a'o'
			CALL DATOS
			MOVLW a'l'
			CALL DATOS
			MOVLW a's'
			CALL DATOS
HOLD_VOL:	MOVF PORTE,W
			SUBLW 0x03 ;  W<--W-0x30
			BTFSC STATUS,Z  ;¿(CONTA)=0X30?
			GOTO HOLD_VOL ;SI			
			MOVLW 0x01		;Limpia Display
			CALL COMANDO
			MOVLW 0x80		;regresa a inicio linea 1
			CALL COMANDO
			CLRF W
			GOTO LOOP_P				
UNIVOLT:	MOVF conver,W	; Caso para obtener el nivel entero de volt leido (1-5)
			SUBLW 0x33		; 0x33-W			51 niveles	(el caso 0 tiene realmente 52 casos con el nivel 0, pero no lo contamos
			BTFSS STATUS,C	;¿STATUS.C==1?	-> 0x33<W
			GOTO CASO1A		;NO, ES MAYOR EL NUMERO
			GOTO CASO0B		;SI, ES MENOR EL NUMERO
CASO0B:		CALL V0			;0.00-0.99V: 0	la condicion de pertenencia (al haberse evaluado la clase 0) es ser menor de 2
			MOVLW 0x00
			MOVWF regaux2	
			GOTO RETOMAV
CASO1A:		MOVF conver,W
			SUBLW 0x66		;0110 0110  NIVEL 102
			BTFSS STATUS,C	;¿STATUS.C==1?	-> 0x66<W
			GOTO CASO2A			;NO, ES MAYOR EL NUMERO
			GOTO CASO1B			;SI, ES MENOR EL NUMERO
			
CASO1B:		CALL V1	;1.00-1.99V: 1	la condicion de pertenencia (al haberse evaluado la clase 0) es ser menor de 2
			MOVLW 0x33
			MOVWF regaux2
			GOTO RETOMAV

CASO2A:		MOVF conver,W
			SUBLW 0x99		;1001 1001  NIVEL 153
			BTFSS STATUS,C	;¿STATUS.C==1?	-> 0x99<W
			GOTO CASO3A			;NO, ES MAYOR EL NUMERO
			GOTO CASO2B			;SI, ES MENOR EL NUMERO
CASO2B:		CALL V2			;2.00-2.99V: 2	la condicion de pertenencia (al haberse evaluado la clase 0) es ser menor de 2
			MOVLW 0x66
			MOVWF regaux2
			GOTO RETOMAV
CASO3A:		MOVF conver,W
			SUBLW 0xCC		;1001 1001  NIVEL 204
			BTFSS STATUS,C	;¿STATUS.C==1?	-> 0xcc<W
			GOTO CASO4A			;NO, ES MAYOR EL NUMERO
			GOTO CASO3B			;SI, ES MENOR EL NUMERO
CASO3B:		CALL V3			;3.00-3.99V: 1	la condicion de pertenencia (al haberse evaluado la clase 0) es ser menor de 2
			MOVLW 0x99
			MOVWF regaux2
			GOTO RETOMAV
CASO4A:		MOVF conver,W
			SUBLW 0xFF		;1111 1010  NIVEL 255
			BTFSS STATUS,C	;¿STATUS.C==1?	-> 0xFF<W
			GOTO CASO5A		;NO, ES MAYOR EL NUMERO
			GOTO CASO4B		;SI, ES MENOR EL NUMERO
CASO4B:		CALL V4			;4.00-4.99V: 4	la condicion de pertenencia (al haberse evaluado la clase 0) es ser menor de 2
			MOVLW 0xCC
			MOVWF regaux2
			GOTO RETOMAV
CASO5A:		CALL V5			;5V: 5	la condicion de pertenencia (al haberse evaluado la clase 0) es ser menor de 2
			MOVLW 0xFF
			MOVWF regaux2
			GOTO RETOMAV
RETOMAV:	RETURN
;EVALUAMOS EL CASO DE LAS DECIMAS, SE RESTA LA UNIDAD
DECVOLT:	MOVF regaux2,W	;CASO DE DECIMAS.  
			SUBWF conver,W	; Restamos a la conversión el nivel base (la unidad del voltaje. Asi, por ejemplo: 1.99 -> 0.99,  4.32 -> 0.32
			;MOVF conver,W	; Caso para obtener el nivel entero de volt leido (1-5)
			MOVWF regaux	; Guardamos el valor para restaurarlo en cada caso
			SUBLW 0x06		; 0x06-W			5 niveles	(0.0 - 0.09)
			BTFSS STATUS,C	;¿STATUS.C==1?	-> 0x66<W
			GOTO CASO1AD		;NO, ES MAYOR EL NUMERO
			GOTO CASO0BD		;SI, ES MENOR EL NUMERO
CASO0BD:	CALL V0			;0.00-0.99V: 0	la condicion de pertenencia (al haberse evaluado la clase 0) es ser menor de 2
			MOVLW 0x00
			MOVWF regaux2
			GOTO RETOMADV
CASO1AD:	MOVF regaux,W
			SUBLW 0x0B		;0x0B-W   10 niveles (0.1-0.19)
			BTFSS STATUS,C	;¿STATUS.C==1?	-> 0x66<W
			GOTO CASO2AD			;NO, ES MAYOR EL NUMERO
			GOTO CASO1BD			;SI, ES MENOR EL NUMERO
			
CASO1BD:	CALL V1	;1.00-1.99V: 1	la condicion de pertenencia (al haberse evaluado la clase 0) es ser menor de 2
			MOVLW 0x06
			MOVWF regaux2
			GOTO RETOMADV

CASO2AD:	MOVF regaux,W
			SUBLW 0x10		;0x10-W  15 niveles (0.2-0.29)
			BTFSS STATUS,C	;¿STATUS.C==1?	-> 0x99<W
			GOTO CASO3AD		;NO, ES MAYOR EL NUMERO
			GOTO CASO2BD		;SI, ES MENOR EL NUMERO
CASO2BD:	CALL V2			;2.00-2.99V: 2	la condicion de pertenencia (al haberse evaluado la clase 0) es ser menor de 2
			MOVLW 0x0B
			MOVWF regaux2
			GOTO RETOMADV
CASO3AD:	MOVF regaux,W
			SUBLW 0x15		;0x15-W  20 niveles (0.3-0.39)
			BTFSS STATUS,C	;¿STATUS.C==1?	-> 0xcc<W
			GOTO CASO4AD			;NO, ES MAYOR EL NUMERO
			GOTO CASO3BD			;SI, ES MENOR EL NUMERO
CASO3BD:	CALL V3			;3.00-3.99V: 1	la condicion de pertenencia (al haberse evaluado la clase 0) es ser menor de 2
			MOVLW 0x10
			MOVWF regaux2
			GOTO RETOMADV
CASO4AD:	MOVF regaux,W
			SUBLW 0x1A		;0x1A-W  25 niveles (0.4-0.49)
			BTFSS STATUS,C	;¿STATUS.C==1?	-> 0xFF<W
			GOTO CASO5AD		;NO, ES MAYOR EL NUMERO
			GOTO CASO4BD		;SI, ES MENOR EL NUMERO
CASO4BD:	CALL V4			;4.00-4.99V: 4	la condicion de pertenencia (al haberse evaluado la clase 0) es ser menor de 2
			MOVLW 0x15
			MOVWF regaux2
			GOTO RETOMADV
CASO5AD:	MOVF regaux,W
			SUBLW 0x1F		;0x1F-W  30 niveles (0.5-0.59)
			BTFSS STATUS,C	;¿STATUS.C==1?	-> 0xFF<W
			GOTO CASO6AD		;NO, ES MAYOR EL NUMERO
			GOTO CASO5BD		;SI, ES MENOR EL NUMERO
CASO5BD:	CALL V5			
			MOVLW 0x1A
			MOVWF regaux2
			GOTO RETOMADV
CASO6AD:	MOVF regaux,W
			SUBLW 0x24		;0x24-W  35 niveles (0.6-0.69)
			BTFSS STATUS,C	;¿STATUS.C==1?	-> 0xFF<W
			GOTO CASO7AD		;NO, ES MAYOR EL NUMERO
			GOTO CASO6BD		;SI, ES MENOR EL NUMERO
CASO6BD:	CALL V6			
			MOVLW 0x1F
			MOVWF regaux2
			GOTO RETOMADV
CASO7AD:	MOVF regaux,W
			SUBLW 0x29		;0x29-W  40 niveles (0.7-0.79)
			BTFSS STATUS,C	;¿STATUS.C==1?	-> 0xFF<W
			GOTO CASO8AD		;NO, ES MAYOR EL NUMERO
			GOTO CASO7BD		;SI, ES MENOR EL NUMERO
CASO7BD:	CALL V7			
			MOVLW 0x24
			MOVWF regaux2
			GOTO RETOMADV
CASO8AD:	MOVF regaux,W
			SUBLW 0x2E		;0x1A-W  45 niveles (0.8-0.89)
			BTFSS STATUS,C	;¿STATUS.C==1?	-> 0xFF<W
			GOTO CASO9AD		;NO, ES MAYOR EL NUMERO
			GOTO CASO8BD		;SI, ES MENOR EL NUMERO
CASO8BD:	CALL V8			
			MOVLW 0x29
			MOVWF regaux2
			GOTO RETOMADV
CASO9AD:	CALL V9
			MOVLW 0x2E
			MOVWF regaux2		
			GOTO RETOMADV
RETOMADV:	RETURN
;EVALUAMOS LAS CENTESIMAS, SE RESTA LAS DECENAS
CENVOLT:	MOVF regaux2,W	;CASO DE CENTESIMAS.  
			SUBWF regaux,W	; Restamos a la conversión el nivel base (la unidad del voltaje. Asi, por ejemplo: 1.99 -> 0.99,  4.32 -> 0.32
			;MOVF conver,W	; Caso para obtener el nivel entero de volt leido (1-5)
			MOVWF regaux	; Guardamos el valor para restaurarlo en cada caso
			SUBLW 0x01		; 0x01-W			1 niveles	(0.0)
			BTFSS STATUS,C	;¿STATUS.C==1?	-> 0x01<W
			GOTO CASO1AC		;NO, ES MAYOR EL NUMERO
			GOTO CASO0BC		;SI, ES MENOR EL NUMERO
CASO0BC:	CALL V0			;0.00-0.99V: 0	la condicion de pertenencia (al haberse evaluado la clase 0) es ser menor de 2
			GOTO RETOMACV
CASO1AC:	MOVF regaux,W
			SUBLW 0x02		;0x02-W   1 niveles (0.02)
			BTFSS STATUS,C	;¿STATUS.C==1?	-> 0x66<W
			GOTO CASO2AC			;NO, ES MAYOR EL NUMERO
			GOTO CASO1BC			;SI, ES MENOR EL NUMERO
			
CASO1BC:	CALL V2			;Se imprime 2, la resolución minima para las centésimas es de 0.02
			GOTO RETOMACV

CASO2AC:	MOVF regaux,W
			SUBLW 0x03		;0x03-W  1 niveles (0.04)
			BTFSS STATUS,C	;¿STATUS.C==1?	-> 0x03<W
			GOTO CASO3AC		;NO, ES MAYOR EL NUMERO
			GOTO CASO2BC		;SI, ES MENOR EL NUMERO
CASO2BC:	CALL V4		
			GOTO RETOMACV
CASO3AC:	MOVF regaux,W
			SUBLW 0x04		;0x04-W  1 niveles (0.06)
			BTFSS STATUS,C	;¿STATUS.C==1?	-> 0x04<W
			GOTO CASO4AC	;NO, ES MAYOR EL NUMERO
			GOTO CASO3BC	;SI, ES MENOR EL NUMERO
CASO3BC:	CALL V6			;3.00-3.99V: 1	la condicion de pertenencia (al haberse evaluado la clase 0) es ser menor de 2
			GOTO RETOMACV
CASO4AC:	CALL V8
			GOTO RETOMACV
RETOMACV:	RETURN


V0:			MOVLW a'0'		;Imprime el valor 0 en el LCD
			CALL DATOS
			MOVWF resNivel	;Almacenamos el nivel entero para evaluar en carga de pila o voltaje
			RETURN
V1:			MOVLW a'1'		;Imprime el valor 1 en el LCD
			CALL DATOS
			MOVWF resNivel	;Almacenamos el nivel entero para evaluar en carga de pila o voltaje
			RETURN
V2:			MOVLW a'2'		;Imprime el valor 2 en el LCD
			CALL DATOS
			MOVWF resNivel	;Almacenamos el nivel entero para evaluar en carga de pila o voltaje
			RETURN
V3:			MOVLW a'3'		;Imprime el valor 3 en el LCD
			CALL DATOS
			MOVWF resNivel	;Almacenamos el nivel entero para evaluar en carga de pila o voltaje
			RETURN
V4:			MOVLW a'4'		;Imprime el valor 4 en el LCD
			CALL DATOS
			MOVWF resNivel	;Almacenamos el nivel entero para evaluar en carga de pila o voltaje
			RETURN
V5:			MOVLW a'5'		;Imprime el valor 5 en el LCD
			CALL DATOS
			MOVWF resNivel	;Almacenamos el nivel entero para evaluar en carga de pila o voltaje
			RETURN
V6:			MOVLW a'6'		;Imprime el valor 6 en el LCD
			CALL DATOS
			MOVWF resNivel	;Almacenamos el nivel entero para evaluar en carga de pila o voltaje
			RETURN
V7:			MOVLW a'7'		;Imprime el valor 7 en el LCD
			CALL DATOS
			MOVWF resNivel	;Almacenamos el nivel entero para evaluar en carga de pila o voltaje
			RETURN
V8:			MOVLW a'8'		;Imprime el valor 8 en el LCD
			CALL DATOS
			MOVWF resNivel	;Almacenamos el nivel entero para evaluar en carga de pila o voltaje
			RETURN
V9:			MOVLW a'9'		;Imprime el valor 9 en el LCD
			CALL DATOS
			MOVWF resNivel	;Almacenamos el nivel entero para evaluar en carga de pila o voltaje
			RETURN
CARGA:	MOVLW 0X40 ;ALMACENAR CARACTERES EN CGRAM
		CALL COMANDO
		CALL RET100MS
		
		;IF resNivel  = 0
		;CUADRO 0 - ALMACENANDO - Vacio
		MOVLW b'01110'
		CALL DATOS
		MOVLW b'01010'
		CALL DATOS
		MOVLW b'01010'
		CALL DATOS
		MOVLW b'01010'
		CALL DATOS
		MOVLW b'10001'
		CALL DATOS
		MOVLW b'10001'
		CALL DATOS
		MOVLW b'11111'
		CALL DATOS

		;IF resNivel  = 1
		;CUADRO 1 - ALMACENANDO - Nivel 1
		MOVLW b'01110'
		CALL DATOS
		MOVLW b'01010'
		CALL DATOS
		MOVLW b'01010'
		CALL DATOS
		MOVLW b'01010'
		CALL DATOS
		MOVLW b'10001'
		CALL DATOS
		MOVLW b'11111'
		CALL DATOS
		MOVLW b'11111'
		CALL DATOS		

		;IF resNivel  = 2
		;CUADRO 2 - ALMACENANDO - Nivel 2
		MOVLW b'01110'
		CALL DATOS
		MOVLW b'01010'
		CALL DATOS
		MOVLW b'01010'
		CALL DATOS
		MOVLW b'01010'
		CALL DATOS
		MOVLW b'11111'
		CALL DATOS
		MOVLW b'11111'
		CALL DATOS
		MOVLW b'11111'
		CALL DATOS	

		;IF resNivel  = 3
		;CUADRO 3 - ALMACENANDO - Nivel 3
		MOVLW b'01110'
		CALL DATOS
		MOVLW b'01010'
		CALL DATOS
		MOVLW b'01010'
		CALL DATOS
		MOVLW b'01110'
		CALL DATOS
		MOVLW b'11111'
		CALL DATOS
		MOVLW b'11111'
		CALL DATOS
		MOVLW b'11111'
		CALL DATOS	

		;IF resNivel  = 4
		;CUADRO 4 - ALMACENANDO - Nivel 4
		MOVLW b'01110'
		CALL DATOS
		MOVLW b'01010'
		CALL DATOS
		MOVLW b'01110'
		CALL DATOS
		MOVLW b'01110'
		CALL DATOS
		MOVLW b'11111'
		CALL DATOS
		MOVLW b'11111'
		CALL DATOS
		MOVLW b'11111'
		CALL DATOS	

		;IF resNivel  = 5
		;CUADRO 5 - ALMACENANDO - Nivel 5
		MOVLW b'01110'
		CALL DATOS
		MOVLW b'01110'
		CALL DATOS
		MOVLW b'01110'
		CALL DATOS
		MOVLW b'01110'
		CALL DATOS
		MOVLW b'11111'
		CALL DATOS
		MOVLW b'11111'
		CALL DATOS
		MOVLW b'11111'
		CALL DATOS		
		
		;COLOCA EN PRIMERA LINEA DEL DISPLAY
		MOVLW 0X80
		CALL COMANDO
		CALL RET100MS

		CALL UNIVOLT		;Caso para ver la "carga de pila"
		MOVF resNivel,w
		ADDWF PCL,F		;(PCL)<-- (PCL)+W
		GOTO BATERIA0		;PC+0	Caso 000: Numero 0
		GOTO BATERIA1		;PC+1	Caso 001: Numero 1
		GOTO BATERIA2		;PC+2	Caso 010: Numero 2
		GOTO BATERIA3		;PC+3	Caso 011: Numero 3
		GOTO BATERIA4		;PC+4	Caso 100: Numero 4
		GOTO BATERIA5		;PC+5	Caso 101: Numero 5

BATERIA0: MOVLW 0X00 ;Cuadro 0 - Vacio
		  CALL DATOS
		  GOTO HOLD_CAR

BATERIA1: MOVLW 0X01 ;Cuadro 1 - Nivel 1
		  CALL DATOS
		  GOTO HOLD_CAR

BATERIA2: MOVLW 0X02 ;Cuadro 2 - Nivel 2
		  CALL DATOS
		  GOTO HOLD_CAR

BATERIA3: MOVLW 0X03 ;Cuadro 3 - Nivel 3
		  CALL DATOS
		  GOTO HOLD_CAR

BATERIA4: MOVLW 0X04 ;Cuadro 4 - Nivel 4
		  CALL DATOS
		  GOTO HOLD_CAR

BATERIA5: MOVLW 0X05 ;Cuadro 5 - Nivel 5
		  CALL DATOS
		  GOTO HOLD_CAR

HOLD_CAR:	MOVF PORTE,W
			SUBLW 0x04 ;  W<--W-0x40
			BTFSC STATUS,Z  ;¿(CONTA)=0X40?
			GOTO HOLD_CAR ;SI			
			MOVLW 0x01		;Limpia Display
			CALL COMANDO
			MOVLW 0x80		;regresa a inicio linea 1
			CALL COMANDO
			CLRF W
			GOTO LOOP_P	

			
DEFAULT: 	GOTO LOOP_P		;Caso por defecto, no hace nada, retorna al loop para evaluar los bits de control

INICIA_LCD:	MOVLW 0x30
			CALL COMANDO
			CALL RET100MS
			MOVLW 0x30
			CALL COMANDO
			CALL RET100MS
			MOVLW 0x38
			CALL COMANDO
			MOVLW 0x0C
			CALL COMANDO
			MOVLW 0x01
			CALL COMANDO
			MOVLW 0x06
			CALL COMANDO
			MOVLW 0x02
			CALL COMANDO
			RETURN
COMANDO:	MOVWF PORTB
			CALL RET200
			BCF PORTA,1
			BSF	PORTA,2
			CALL RET200
			BCF PORTA,2
			RETURN
DATOS:		MOVWF PORTB
			CALL RET200
			BSF PORTA,1
			BSF	PORTA,2
			CALL RET200
			BCF PORTA,2
			CALL RET200
			CALL RET200
			RETURN
RET200:		MOVLW 0xAA
			MOVWF valor1
LOOP:		MOVLW d'164'
			MOVWF valor
LOOP1:		DECFSZ valor,1
			GOTO LOOP1
			DECFSZ valor1,1
			GOTO LOOP
			RETURN
RET100MS:	MOVLW 0x03
			MOVWF valor
TRES:		MOVLW 0xFF
			MOVWF valor1
DOS:		MOVLW 0xFF
			MOVWF valor2
UNO:		DECFSZ valor2
			GOTO UNO
			DECFSZ valor1
			GOTO DOS
			DECFSZ valor
			GOTO TRES
			RETURN

RETARDO:	MOVLW cte1		;SUBRUTINA DE RETARDO DE 50us	--valido
			MOVWF valor1
LOOPR:	 	DECFSZ valor1
			GOTO LOOPR
			RETURN
		END
			END			
		
