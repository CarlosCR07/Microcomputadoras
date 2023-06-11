processor 16f877
include<p16f877.inc>

valor1 equ h'21'
valor2 equ h'22'
valor3 equ h'23'
cte1 equ 10h 
cte2 equ 50h
cte3 equ 60h

	org 0
	goto Inicio
	org 5

Inicio
	CLRF PORTB ;Limpia el portB
	BSF STATUS,RP0  ;Cambia la banco 1   
	BCF STATUS,RP1
	CLRF TRISB
	bsf TXSTA, BRGH
	MOVLW D'129' ;Define el baudaje
	MOVWF SPBRG ;A 9600 bauds
	BCF TXSTA, SYNC ;Define la comunicacion asincrona 
	BSF TXSTA, TXEN ;Habilita la transmisión de datos
	BCF STATUS,RP0  ;Cambia la banco 0 
	BSF RCSTA, SPEN ;Habilita el puerto serie
	BSF RCSTA, CREN ;Habilita la recepción de datos

Recibe
	BTFSS PIR1,RCIF ;Comprueba la recepción de datos
	GOTO Recibe
	MOVF RCREG, W ;Pasar el dato recibido a W

Seleccion
	movlw a'A'	 ;Código ASCII del A
	xorwf RCREG,W
	btfsc STATUS,H'02'
	goto Adelante

	movlw a'D' ;Código ASCII del D
	xorwf RCREG,W
	btfsc STATUS,H'02'
	goto Derecha

	movlw a'S' ;Código ASCII del S
	xorwf RCREG,W
	btfsc STATUS,H'02'
	goto Parar

	movlw a'I' ;Código ASCII del I
	xorwf RCREG,W
	btfsc STATUS,H'02'
	goto Izquierda
	
	movlw a'T' ;Código ASCII del T
	xorwf RCREG,W
	btfsc STATUS,H'02'
	goto Atras

Adelante ;Hacia adelante
	movlw b'1010'; M1=Derecha M2=Derecha
	movwf PORTB
	call retardo       
	goto Recibe
Derecha ;Hacia la derecha
	movlw b'1001' ;M1=Derecha M2=Izquierda
	movwf PORTB
	call retardo
	goto Recibe
Parar ;Para
	movlw h'00' ;M1=paro M2=paro
	movwf PORTB
	goto Recibe
Izquierda ;Hacia la izquierda 
	movlw b'0110' ;M1=Izquierda M2=Dercha
	movwf PORTB
	call retardo
	goto Recibe
Atras ;Hacia atrás
	movlw b'0101'  ;M1=Izquierda M2=Izquierda
	movwf PORTB
	call retardo  
	goto Recibe


retardo movlw cte1   ;Rutina que genera un DELAY
     	movwf valor1
tres 	movwf cte2
     	movwf valor2
dos  	movlw cte3
     	movwf valor3
uno  	decfsz valor3 
     	goto uno 
     	decfsz valor2
     	goto dos
     	decfsz valor1   
     	goto tres
     	return

END
