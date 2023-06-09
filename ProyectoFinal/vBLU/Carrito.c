#include <16F877.h>
#fuses HS,NOWDT,NOPROTECT
#use delay(clock=20000000)
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7)              //Puerto Serie ->Bluetoth
#use i2c(MASTER, SDA=PIN_C4, SCL=PIN_C3,SLOW, NOFORCE_SW)   
#include <i2c_Flex_LCD.c>                                   //LCD
#org 0x1F00,0x1FFF void loader16F877(void){}                //Terminal

/// === Vaiable Globales ===
int direccion=0,movCoche=0;
int velocidad=1,changeVel=0;
char b;

#int_RDA       //Se recbio un dato
void direcCarro(){
   b = getchar();
   if(b == 'S'){     //Para: 0
      direccion = 0;
   }
   if(b == 'A'){     //Hacia adelante: 1 
      direccion = 1;        //1010 -> M1=DERECHA M2=DERECHA
   }
   if(b == 'R'){     //Hacia atras: 2
      direccion = 2;         //0101 -> M1=IZQUIERDA M2=IZQUIERDA
   }
   if(b == 'I'){     //Hacia la izquierda: 3
      direccion = 3;         //0110 -> M1=IZQUIERDA M2=DERECHA
   }
   if(b == 'D'){     //Hacia derecha: 4
      direccion = 4;         //1001 -> M1=DERECHA M2=IZQUIERDA
   }
   if(b=='F'){ //aumenta la velocidad
      if(velocidad<3){
         velocidad+=1;
         changeVel=1;
      }
   }
   if(b=='L'){
      if(velocidad>1){
         changeVel=1;
         velocidad-=1;
      }
   }
   delay_ms(100);// retardo de 100ms para que se pueda apreciar el cambio
}
void escribir_i2c(){
   i2c_start();//inicia comunicaci{on
   i2c_write(0x42);//direccion recorrida un lugar
   i2c_write(0); //envia a escribir el contenido de contador
   i2c_stop();//detiene comunicacion
}
void cambioVelocidad();
void movMotores();
void main(){
   //=== Interrupciones ===
   enable_interrupts(INT_RDA);    //Habilita interrupci�n detecci�n por puerto serie
   enable_interrupts(GLOBAL);
   setup_timer_2(t2_div_by_16,255,1);//predivisor de 16, PR2=255,  con esto tenemos un periodo de 0.8192ms y frecuencia de 1.22kHZ
   setup_ccp1(ccp_pwm);
   set_tris_b(0xF0); //4 bits menos significativos como salida y los 4 bits m�s significativos como entrada
   //lcd_init(0x4E,16,2);       // Ajustar de acuerdo a las conexiones (consultar imagen)
   //escribir_i2c();
  
   while(TRUE){
      movMotores();
      if(changeVel==1)cambioVelocidad();
      
   }
}
void movMotores(){
   switch(direccion){
      case 0: //Alto
         output_b(0x0F);   //limpiamos puerto B  0000 0000 no hay movimiento de los motores
         //lcd_gotoxy(1,1);
         //printf(lcd_putc,"  Alto \n ");
         break;   
      case 1:  //Avanza: 1010:  M1:derecha, M2: derecha
         //output_bit(PIN_B0,0);
         output_bit(PIN_B0,input_state(pin_C2));
         output_bit(PIN_B1,1);
         output_bit(PIN_B2,input_state(pin_C2));
         //output_bit(PIN_B2,0);
         output_bit(PIN_B3,1);
         //lcd_gotoxy(1,1);
         //printf(lcd_putc,"  Avanza \n ");
         break;
      case 2:   //Retrocede: 0101:  M1:izquierda, M2: izquierda
         output_bit(PIN_B0,1);
         output_bit(PIN_B1,input_state(pin_C2));
         //output_bit(PIN_B1,0);
         output_bit(PIN_B2,1);
         output_bit(PIN_B3,input_state(pin_C2));
         //output_bit(PIN_B3,0);
         //lcd_gotoxy(1,1);
         //printf(lcd_putc,"  Retrocede \n ");
         break;
      case 3:   //Izquierda: 0110:  M1:izquierda, M2: izquierda
         output_bit(PIN_B0,input_state(pin_C2));
         //output_bit(PIN_B0,0);
         output_bit(PIN_B0,1);
         output_bit(PIN_B2,1);
         output_bit(PIN_B3,input_state(pin_C2));
         //output_bit(PIN_B3,0);
         //lcd_gotoxy(1,1);
         //printf(lcd_putc,"  Retrocede \n ");
         break;
      case 4:  //Derecha: 1001:  M1:derecha, M2: derecha
         output_bit(PIN_B0,1);
         output_bit(PIN_B1,input_state(pin_C2));
         //output_bit(PIN_B1,0);
         output_bit(PIN_B2,input_state(pin_C2));
         //output_bit(PIN_B2,0);
         output_bit(PIN_B3,1);
         //lcd_gotoxy(1,1);
         //printf(lcd_putc,"  Avanza \n ");
         break;      
         
      default:
         break;
   }
}
void cambioVelocidad(){
   switch(velocidad){
      case 1:
         set_pwm1_duty(20);
         //lcd_gotoxy(1,2);
         //printf(lcd_putc,"  Velocidad 3 \n ");
         break;   
      case 2:  
         set_pwm1_duty(60);
         //lcd_gotoxy(1,2);
         //printf(lcd_putc,"  Velocidad 2 \n ");
         break;
      case 3:  
         set_pwm1_duty(127);
         //lcd_gotoxy(1,2);
         //printf(lcd_putc,"  Velocidad 1 \n ");
         break;
      default:
         break;
   }
   changeVel=0; //reiniciamos la bandera de velocidad para permitir otros cambios de velocidad
   delay_ms(100);
   
   
}
