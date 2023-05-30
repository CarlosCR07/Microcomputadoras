	processor 16f877
	include<p16f877.inc>
	ORG 0
	GOTO INICIO
	
	valor1 equ h'21'
valor2 equ h'22'
valor3 equ h'23'
cte1 equ 90h
cte2 equ 90h
cte3 equ 60h
	
	ORG 5
INICIO:BSF STATUS,RP0
	BCF STATUS,RP1
	CLRF PORTB
	MOVLW H'00' ;Configura puerto B como SALIDA
	MOVWF TRISB
	MOVWF H'00'
	MOVWF TRISD
	BSF TXSTA,BRGH
	MOVLW D'129'
	MOVWF SPBRG
	BCF TXSTA,SYNC
	BSF TXSTA,TXEN
	BCF STATUS,RP0
	BSF RCSTA,SPEN
	BSF RCSTA,CREN
RECIBE:BTFSS PIR1,RCIF
	GOTO RECIBE
	MOVF RCREG,W
	SUBLW A'S'
	BTFSC STATUS,Z
	GOTO CERO
	MOVF RCREG,W
	SUBLW A'A'
	BTFSC STATUS,Z
	GOTO UNO
	MOVF RCREG,W
	SUBLW A'R'
	BTFSC STATUS,Z
	GOTO DOS
	MOVF RCREG,W
	SUBLW A'D'
	BTFSC STATUS,Z
	GOTO TRES
	MOVF RCREG,W
	SUBLW A'I'
	BTFSC STATUS,Z
	GOTO CUATRO
	;MOVWF TXREG
	;MOVWF PORTB
	BSF STATUS,RP0
TRASMITE:BTFSS TXSTA,TRMT
	GOTO TRASMITE
	BCF STATUS,RP0
	
	GOTO RECIBE

CERO: 
	MOVLW 0X00
	MOVWF TXREG
	MOVWF TRISD
	BSF STATUS,RP0
	GOTO TRASMITE

UNO: 
	MOVLW 0X03
	MOVWF TXREG
	MOVWF TRISD
	CALL RETARDO
	MOVLW 0X09
	MOVWF TXREG
	MOVWF TRISB
	CALL RETARDO
	BSF STATUS,RP0
	GOTO TRASMITE

DOS: 
	MOVLW 0X03
	MOVWF TXREG
	MOVWF TRISD
	CALL RETARDO
	MOVLW 0X06
	MOVWF TXREG
	MOVWF TRISB
	CALL RETARDO
	BSF STATUS,RP0
	GOTO TRASMITE

TRES: 
	MOVLW 0X01
	MOVWF TXREG
	MOVWF TRISD
	CALL RETARDO
	MOVLW 0X01
	MOVWF TXREG
	MOVWF TRISB
	CALL RETARDO
	BSF STATUS,RP0
	GOTO TRASMITE

CUATRO: 
	MOVLW 0X02
	MOVWF TXREG
	MOVWF TRISD
	CALL RETARDO
	MOVLW 0X08
	MOVWF TXREG
	MOVWF TRISB
	CALL RETARDO
	BSF STATUS,RP0
	GOTO TRASMITE

RETARDO MOVLW cte1
	MOVWF valor1
tres MOVLW cte2
	MOVWF valor2
dos MOVLW cte3
	MOVWF valor3
uno DECFSZ valor3
	GOTO uno
	DECFSZ valor2
	GOTO dos
	DECFSZ valor1
	GOTO tres
	RETURN

END