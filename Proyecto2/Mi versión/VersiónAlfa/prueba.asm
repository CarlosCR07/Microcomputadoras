processor 16f877
include <p16f877.inc>

valor equ h'20'
valor1 equ h'21'
valor2 equ h'22'
auxiliar equ h'31'
parteBaja equ h'40'
org 0
  goto inicio
org 5

;configuracion de los puertos y llamado
inicio:	clrf PORTA ;Se limpian los puertos
		clrf PORTB
		clrf PORTD
		bsf STATUS,5 ;Nos cambiamos al banco 1
		bcf STATUS,6
		movlw 0x00
		movwf TRISB ;Asignamos al puerto B como salida
		movlw 0x07
		movwf ADCON1
		movlw 0x00
		movwf TRISA ;Asignamos al puerto A como salida
		movlw H'00'
		movwf TRISC ;Asignamos al puerto C como salida
		movlw H'FF'
		movwf TRISD ;Asignamos al puerto D como entrada
		movlw H'FF'
		movwf TRISE ;Asignamos al puerto D como entrada
		bcf STATUS,5 ;Regresamos al banco 0
		call inicia_lcd; Se inicia el LCD 
		movlw 0x80 ;Se posiciona el cursor en el primer renglón y en la posicion 0
		call comando
		call ret100ms

EntradaTeclado:	movf PORTE,W
				xorlw b'0000' ;Se realiza un XOR para ver si auxiliar es igual al valor binario indicado
				btfsc STATUS,Z ;Si no brinca es porque son iguales ambos valores
				call nombres ;Se manda a llamar a la subrutina del caso 00(Nombres)
				movf PORTE,W ;Se mueve lo que está en entrada a W
				xorlw b'0001' ;Se realiza un XOR para ver si auxiliar es igual al valor binario indicado
				btfsc STATUS,Z ;Si no brinca es porque son iguales ambos valores
				call decimal ;Se manda a llamar a la subrutina del caso 01(Decimal)
				movf PORTE,W ;Se mueve lo que está en auxiliar a W
				xorlw b'0010' ;Se realiza un XOR para ver si auxiliar es igual al valor binario indicado
				btfsc STATUS,Z ;Si no brinca es porque son iguales ambos valores
				call hexadecimal ;Se manda a llamar a la subrutina del caso 02(Hexadecimal)
				movf PORTE,W ;Se mueve lo que está en auxiliar a W
				xorlw b'0011' ;Se realiza un XOR para ver si auxiliar es igual al valor binario indicado
				btfsc STATUS,Z ;Si no brinca es porque son iguales ambos valores
				call binario ;Se manda a llamar a la subrutina del caso 03(Binario)
				movf PORTE,W ;Se mueve lo que está en auxiliar a W
				xorlw b'0100' ;Se realiza un XOR para ver si auxiliar es igual al valor binario indicado
				btfsc STATUS,Z ;Si no brinca es porque son iguales ambos valores
				call caracteres ;Se manda a llamar a la subrutina del caso 04(Caracteres especiales)
				goto inicio

nombres:	movlw a'E'
			call datos
			movlw a'R'
			call datos
			movlw a'I'
			call datos
			movlw a'K'
			call datos
			movlw a' '
			call datos
			movlw a'A'
			call datos
			movlw a'R'
			call datos
			movlw a'E'
			call datos
			movlw a'L'
			call datos
			movlw a'Y'
			call datos
			movlw a' '
			call datos
			movlw a'K'
			call datos
			movlw a'A'
			call datos
			movlw a'R'
			call datos
			movlw a'L'
			call datos
			movlw a'A'
			call datos
			movlw 0xC0 ;Salto al segundo renglon en la posición 0
			call comando
			call ret100ms
			movlw a' '
			call datos
			movlw a' '
			call datos
			movlw a' '
			call datos
			return

binario:	call bit7_cero
			call bit7_uno
			call bit6_cero
			call bit6_uno
			call bit5_cero
			call bit5_uno
			call bit4_cero
			call bit4_uno
			call bit3_cero
			call bit3_uno
			call bit2_cero
			call bit2_uno
			call bit1_cero
			call bit1_uno
			call bit0_cero
			call bit0_uno
			movlw a' '
			call datos
			movlw a' '
			call datos
			movlw a' '
			call datos
			movlw a' '
			call datos
			movlw a' '
			call datos
			movlw a' '
			call datos
			movlw a' '
			call datos
			movlw a' '
			call datos
			movlw a' '
			call datos
			movlw 0xC0 ;Salto al segundo renglon en la posición 0
			call comando
			call ret100ms
			movlw a' '
			call datos
			movlw a' '
			call datos
			movlw a' '
			call datos
			return
			;goto inicio

caracteres:
movlw 0x40 ;Permite crear los caracteres y almacenarlos en la CGRAM
call comando
call ret100ms	
;CARACTER UNO
movlw b'00000'
call datos
movlw b'00001'
call datos
movlw b'00011'
call datos
movlw b'00111'
call datos
movlw b'01001'
call datos
movlw b'01001'
call datos
movlw b'01001'
call datos
movlw b'01011'
call datos

;CARACTER DOS
movlw b'01110'
call datos
movlw b'11111'
call datos
movlw b'10001'
call datos
movlw b'00000'
call datos
movlw b'00000'
call datos
movlw b'10001'
call datos
movlw b'11111'
call datos
movlw b'11111'
call datos

;CARACTER TRES
movlw b'00000'
call datos
movlw b'10000'
call datos
movlw b'11000'
call datos
movlw b'11100'
call datos
movlw b'10010'
call datos
movlw b'10010'
call datos
movlw b'10010'
call datos
movlw b'11010'
call datos

;CARACTER CUATRO
movlw b'01111'
call datos
movlw b'00111'
call datos
movlw b'00010'
call datos
movlw b'00010'
call datos
movlw b'00010'
call datos
movlw b'00011'
call datos
movlw b'00000'
call datos
movlw b'00000'
call datos

;CARACTER CINCO
movlw b'11111'
call datos
movlw b'11111'
call datos
movlw b'01010'
call datos
movlw b'01010'
call datos
movlw b'00000'
call datos
movlw b'00000'
call datos
movlw b'11111'
call datos
movlw b'00000'
call datos

;CARACTER SEIS
movlw b'11110'
call datos
movlw b'11100'
call datos
movlw b'01000'
call datos
movlw b'01000'
call datos
movlw b'01000'
call datos
movlw b'11000'
call datos
movlw b'00000'
call datos
movlw b'00000'
call datos



movlw 0x80 ;Posiciona el cursor en la primera posicion dell primer renglón
call comando
call ret100ms

;Se imprimen los carácteres del primer renglón
movlw 0x00
call datos
movlw 0x01
call datos
movlw 0x02
call datos
movlw a' ' 
call datos
movlw a' ' 
call datos
movlw a' ' 
call datos
movlw a' ' 
call datos
movlw a' ' 
call datos
movlw a' ' 
call datos
movlw a' ' 
call datos
movlw a' ' 
call datos
movlw a' ' 
call datos
movlw a' ' 
call datos
movlw a' ' 
call datos
movlw a' ' 
call datos
movlw a' ' 
call datos


movlw 0xC0 ;Salto al segundo renglon en la posición 0
call comando
call ret100ms

;Comando que permite confirmar que se esta haciendo uso del segundo renglón
movlw 0x38
call comando
call ret100ms

;Se imprimen los caracteres del segundo renglón
movlw 0x03
call datos
movlw 0x04
call datos
movlw 0x05
call datos
return
hexadecimal:	movf PORTD,W ;Mueve lo que hay en el puerto D a W
				movwf auxiliar ;Se mueve lo que está en W a auxiliar
				movf auxiliar,W ;Se mueve lo que está en W a auxiliar (paso opcional)
				andlw b'00001111' ;Se ponen en ceros los 4 bits más significativos
				movwf parteBaja ;Se mueve lo que está en W a parteBaja
				movf auxiliar,W ;Se mueve lo que está en auxiliar a W
				andlw b'11110000' ;Se ponen en ceros los 4 bits menos significativos
				movwf auxiliar ;Se mueve el valor de W a auxiliar
				RRF auxiliar,1 ;Corrimiento de 1 bit hacia la derecha de auxiliar
				RRF auxiliar,1 ;Corrimiento de 1 bit hacia la derecha de auxiliar
				RRF auxiliar,1 ;Corrimiento de 1 bit hacia la derecha de auxiliar
				RRF auxiliar,1 ;Corrimiento de 1 bit hacia la derecha de auxiliar
				call Comparacion ;Se realiza la comparación
				movf parteBaja,W ;Se almacena en W lo que está en parteBaja
				movwf auxiliar ;Se almacena lo que está en W en auxiliar
				call Comparacion ;Se realiza la comparación
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw 0xC0 ;Salto al segundo renglon en la posición 0
				call comando
				call ret100ms
				movlw a' '
				call datos
				movlw a' '
				call datos
				movlw a' '
				call datos
				return
decimal:		movlw a'0' 
				call datos
				movlw a'0' 
				call datos
				movlw a'0' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw a' ' 
				call datos
				movlw 0xC0 ;Salto al segundo renglon en la posición 0
				call comando
				call ret100ms
				movlw a' '
				call datos
				movlw a' '
				call datos
				movlw a' '
				call datos
				return
Comparacion:	movf auxiliar,W ;Se mueve lo que está en auxiliar a W
				xorlw b'00000000' ;Se realiza un XOR para ver si auxiliar es igual al valor binario indicado
				btfsc STATUS,Z ;Si no brinca es porque son iguales ambos valores
				call caso0 ;Se manda a llamar a la subrutina del caso 0
				movf auxiliar,W ;Se mueve lo que está en auxiliar a W
				xorlw b'00000001' ;Se realiza un XOR para ver si auxiliar es igual al valor binario indicado
				btfsc STATUS,Z ;Si no brinca es porque son iguales ambos valores
				call caso1 ;Se manda a llamar a la subrutina del caso 1
				movf auxiliar,W ;Se mueve lo que está en auxiliar a W
				xorlw b'00000010' ;Se realiza un XOR para ver si auxiliar es igual al valor binario indicado
				btfsc STATUS,Z ;Si no brinca es porque son iguales ambos valores
				call caso2 ;Se manda a llamar a la subrutina del caso 2
				movf auxiliar,W ;Se mueve lo que está en auxiliar a W
				xorlw b'00000011' ;Se realiza un XOR para ver si auxiliar es igual al valor binario indicado
				btfsc STATUS,Z ;Si no brinca es porque son iguales ambos valores
				call caso3 ;Se manda a llamar a la subrutina del caso 3
				movf auxiliar,W ;Se mueve lo que está en auxiliar a W
				xorlw b'00000100' ;Se realiza un XOR para ver si auxiliar es igual al valor binario indicado
				btfsc STATUS,Z ;Si no brinca es porque son iguales ambos valores
				call caso4 ;Se manda a llamar a la subrutina del caso 4
				movf auxiliar,W ;Se mueve lo que está en auxiliar a W
				xorlw b'00000101' ;Se realiza un XOR para ver si auxiliar es igual al valor binario indicado
				btfsc STATUS,Z ;Si no brinca es porque son iguales ambos valores
				call caso5 ;Se manda a llamar a la subrutina del caso 5
				movf auxiliar,W ;Se mueve lo que está en auxiliar a W
				xorlw b'00000110' ;Se realiza un XOR para ver si auxiliar es igual al valor binario indicado
				btfsc STATUS,Z ;Si no brinca es porque son iguales ambos valores
				call caso6 ;Se manda a llamar a la subrutina del caso 6
				movf auxiliar,W ;Se mueve lo que está en auxiliar a W
				xorlw b'00000111' ;Se realiza un XOR para ver si auxiliar es igual al valor binario indicado
				btfsc STATUS,Z ;Si no brinca es porque son iguales ambos valores
				call caso7 ;Se manda a llamar a la subrutina del caso 7
				movf auxiliar,W ;Se mueve lo que está en auxiliar a W
				xorlw b'00001000' ;Se realiza un XOR para ver si auxiliar es igual al valor binario indicado
				btfsc STATUS,Z ;Si no brinca es porque son iguales ambos valores
				call caso8 ;Se manda a llamar a la subrutina del caso 8
				movf auxiliar,W ;Se mueve lo que está en auxiliar a W
				xorlw b'00001001' ;Se realiza un XOR para ver si auxiliar es igual al valor binario indicado
				btfsc STATUS,Z ;Si no brinca es porque son iguales ambos valores
				call caso9 ;Se manda a llamar a la subrutina del caso 9
				movf auxiliar,W ;Se mueve lo que está en auxiliar a W
				xorlw b'00001010' ;Se realiza un XOR para ver si auxiliar es igual al valor binario indicado
				btfsc STATUS,Z ;Si no brinca es porque son iguales ambos valores
				call casoA ;Se manda a llamar a la subrutina del caso A
				movf auxiliar,W ;Se mueve lo que está en auxiliar a W
				xorlw b'00001011' ;Se realiza un XOR para ver si auxiliar es igual al valor binario indicado
				btfsc STATUS,Z ;Si no brinca es porque son iguales ambos valores
				call casoB ;Se manda a llamar a la subrutina del caso B
				movf auxiliar,W ;Se mueve lo que está en auxiliar a W
				xorlw b'00001100' ;Se realiza un XOR para ver si auxiliar es igual al valor binario indicado
				btfsc STATUS,Z ;Si no brinca es porque son iguales ambos valores
				call casoC ;Se manda a llamar a la subrutina del caso C
				movf auxiliar,W ;Se mueve lo que está en auxiliar a W
				xorlw b'00001101' ;Se realiza un XOR para ver si auxiliar es igual al valor binario indicado
				btfsc STATUS,Z ;Si no brinca es porque son iguales ambos valores
				call casoD ;Se manda a llamar a la subrutina del caso D
				movf auxiliar,W ;Se mueve lo que está en auxiliar a W
				xorlw b'00001110' ;Se realiza un XOR para ver si auxiliar es igual al valor binario indicado
				btfsc STATUS,Z ;Si no brinca es porque son iguales ambos valores
				call casoE ;Se manda a llamar a la subrutina del caso E
				movf auxiliar,W ;Se mueve lo que está en auxiliar a W
				xorlw b'00001111' ;Se realiza un XOR para ver si auxiliar es igual al valor binario indicado
				btfsc STATUS,Z ;Si no brinca es porque son iguales ambos valores
				call casoF
				return
caso0:	movlw a'0' ;Se pasa a W el caracter en ASCII de '0'
		call datos ;Se manda a llamar a la subrutina datos para imprimir
		movlw 0x00 ;Se pasa a W un 0x00 para limpiar el registro
		return
caso1:	movlw a'1' ;Se pasa a W el caracter en ASCII de '1'
		call datos ;Se manda a llamar a la subrutina datos para imprimir
		movlw 0x00 ;Se pasa a W un 0x00 para limpiar el registro
		return
caso2:	movlw a'2' ;Se pasa a W el caracter en ASCII de '2'
		call datos ;Se manda a llamar a la subrutina datos para imprimir
		movlw 0x00 ;Se pasa a W un 0x00 para limpiar el registro
		return
caso3:	movlw a'3' ;Se pasa a W el caracter en ASCII de '3'
		call datos ;Se manda a llamar a la subrutina datos para imprimir
		movlw 0x00 ;Se pasa a W un 0x00 para limpiar el registro
		return
caso4:	movlw a'4' ;Se pasa a W el caracter en ASCII de '4'
		call datos ;Se manda a llamar a la subrutina datos para imprimir
		movlw 0x00 ;Se pasa a W un 0x00 para limpiar el registro
		return
caso5:	movlw a'5' ;Se pasa a W el caracter en ASCII de '5'
		call datos ;Se manda a llamar a la subrutina datos para imprimir
		movlw 0x00 ;Se pasa a W un 0x00 para limpiar el registro
		return
caso6:	movlw a'6' ;Se pasa a W el caracter en ASCII de '6'
		call datos ;Se manda a llamar a la subrutina datos para imprimir
		movlw 0x00 ;Se pasa a W un 0x00 para limpiar el registro
		return
caso7:	movlw a'7' ;Se pasa a W el caracter en ASCII de '7'
		call datos ;Se manda a llamar a la subrutina datos para imprimir
		movlw 0x00 ;Se pasa a W un 0x00 para limpiar el registro
		return
caso8:	movlw a'8' ;Se pasa a W el caracter en ASCII de '8'
		call datos ;Se manda a llamar a la subrutina datos para imprimir
		movlw 0x00 ;Se pasa a W un 0x00 para limpiar el registro
		return
caso9:	movlw a'9' ;Se pasa a W el caracter en ASCII de '9'
		call datos ;Se manda a llamar a la subrutina datos para imprimir
		movlw 0x00 ;Se pasa a W un 0x00 para limpiar el registro
		return
casoA:	movlw a'A' ;Se pasa a W el caracter en ASCII de 'A'
		call datos ;Se manda a llamar a la subrutina datos para imprimir
		movlw 0x00 ;Se pasa a W un 0x00 para limpiar el registro
		return
casoB:	movlw a'B' ;Se pasa a W el caracter en ASCII de 'B'
		call datos ;Se manda a llamar a la subrutina datos para imprimir
		movlw 0x00 ;Se pasa a W un 0x00 para limpiar el registro
		return
casoC:	movlw a'C' ;Se pasa a W el caracter en ASCII de 'C'
		call datos ;Se manda a llamar a la subrutina datos para imprimir
		movlw 0x00 ;Se pasa a W un 0x00 para limpiar el registro
		return
casoD:	movlw a'D' ;Se pasa a W el caracter en ASCII de 'D'
		call datos ;Se manda a llamar a la subrutina datos para imprimir
		movlw 0x00 ;Se pasa a W un 0x00 para limpiar el registro
		return
casoE:	movlw a'E' ;Se pasa a W el caracter en ASCII de 'E'
		call datos ;Se manda a llamar a la subrutina datos para imprimir
		movlw 0x00 ;Se pasa a W un 0x00 para limpiar el registro
		return
casoF:	movlw a'F' ;Se pasa a W el caracter en ASCII de 'F'
		call datos ;Se manda a llamar a la subrutina datos para imprimir
		movlw 0x00 ;Se pasa a W un 0x00 para limpiar el registro
		return


inicia_lcd:
movlw 0x38 ;Interfaz de 8 bits, dos renglones del display y letras de 5x8
call comando
call ret100ms
movlw 0x06 ;Que no se desplace el texto 
call comando
call ret100ms
movlw 0x0c ;Prende el display, apaga el cursor y el parpadeo
call comando
call ret100ms
return

comando:
movwf PORTB ;manda el comando al PORTB
call ret200ms
bcf PORTA,0 ;PONE RS EN CERO
bsf PORTA,1 ;PONE E EN UNO
call ret200ms
bcf PORTA,1 ;PONE E EN CERO
return

datos:
movwf PORTB
call ret200ms
bsf PORTA,0 ;pone en 1 a rs
bsf PORTA,1 ;PONE EN 1 a E
call ret200ms
bcf PORTA,1 ;pone en 0 a E
call ret200ms
call ret200ms
return 

ret200ms:
movlw 0x02
movwf valor1
loop: movlw d'164'
movwf valor
loop1: decfsz valor,1
goto loop1
decfsz valor1,1
goto loop
return 

;Permiten escribir uno o cero según sea el caso
escribe_uno:
movlw a'1'
call datos
movlw 0x00
return

escribe_cero:
movlw a'0'
call datos
movlw 0x00
return


;Se analiza el contenido bit por bit
bit0_cero:
btfss PORTD,0
call escribe_cero
return

bit1_cero:
btfss PORTD,1
call escribe_cero
return

bit2_cero:
btfss PORTD,2
call escribe_cero
return

bit3_cero:
btfss PORTD,3
call escribe_cero
return

bit4_cero:
btfss PORTD,4
call escribe_cero
return

bit5_cero:
btfss PORTD,5
call escribe_cero
return

bit6_cero:
btfss PORTD,6
call escribe_cero
return

bit7_cero:
btfss PORTD,7
call escribe_cero
return



bit0_uno:
btfsc PORTD,0
call escribe_uno
return

bit1_uno:
btfsc PORTD,1
call escribe_uno
return

bit2_uno:
btfsc PORTD,2
call escribe_uno
return

bit3_uno:
btfsc PORTD,3
call escribe_uno
return

bit4_uno:
btfsc PORTD,4
call escribe_uno
return

bit5_uno:
btfsc PORTD,5
call escribe_uno
return

bit6_uno:
btfsc PORTD,6
call escribe_uno
return

bit7_uno:
btfsc PORTD,7
call escribe_uno
return


ret100ms:
movlw 0x03
movwf valor
tres: movlw 0xFF
      movwf valor1
dos:  movlw 0xFF
      movwf valor2
uno:  decfsz valor2
      goto uno
      decfsz valor1
      goto dos
      decfsz valor
      goto tres
      return

end