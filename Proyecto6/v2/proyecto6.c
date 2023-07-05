#include <16F877.h>
#fuses HS,NOWDT,NOPROTECT
#use delay(clock=20000000)
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7) 
#use i2c(MASTER, SDA=PIN_C4, SCL=PIN_C3,SLOW, NOFORCE_SW)//configuraci{on de comunicaci{on maestro y esclavo
#include <i2c_Flex_LCD.c>                                   //LCD


int selection=3;// 0:stop, 1:velocidad 1, 2: velocidad 2: 3:velocidad 3
int control=1;
void cambioEstado();
void movMotores();
int contador=0;//variable global de 8 bits no signado
void escribir_i2c(){
   i2c_start();//inicia comunicaci{on
   i2c_write(0x4F);//direccion recorrida un lugar
   i2c_write(contador);//envia a escribir el contenido de contador
   i2c_stop();//detiene comunicacion
}

void main()
{
   setup_timer_2(t2_div_by_16,255,1);//predivisor de 16, PR2=255,  con esto tenemos un periodo de 0.8192ms y frecuencia de 1.22kHZ
   setup_ccp1(ccp_pwm);
   //output_b(0xFF); //habilitmaos el puerto B como entradas
   set_tris_b(0xF0); //4 bits menos significativos como salida y los 4 bits más significativos como entrada
   //=== LCD ===
   output_d(0x00);             //muestra cero en el display.
   lcd_init(0x4E,16,2);       // Ajustar de acuerdo a las conexiones (consultar imagen)
   lcd_gotoxy(1,1);
   printf(lcd_putc," Bajo \n ");  
   escribir_i2c();
   delay_ms(10000);
   while(true)//loop infinito
   {
      if(!input(PIN_B4)){
         selection=0;   //posicionamos el cursor al origen del menú
         control=1;
         delay_ms(100); //retraso de 100ms para evitar movimientos inesperados
      }
      if(!input(PIN_B5)){
         selection=1;   //posicionamos el cursor al origen del menú
         control=1;
         delay_ms(100); //retraso de 100ms para evitar movimientos inesperados
      }
      if(!input(PIN_B6)){
         selection=2;   //posicionamos el cursor al origen del menú
         control=1;
         delay_ms(100); //retraso de 100ms para evitar movimientos inesperados
      }
      If(!input(PIN_B7)){
         selection=3;   //posicionamos el cursor al origen del menú
         control=1;
         delay_ms(100); //retraso de 100ms para evitar movimientos inesperados
      }
      if(control==1){
         printf(lcd_putc,"\f"); //limpia pantalla LCD
         cambioEstado();
         control=0;
      }
      
      if(selection==0){
         output_b(0x00);
      }else{
         output_bit(PIN_B0,0);
         //output_bit(PIN_B1,input_state(pin_C2));
      }
   }
}
void cambioEstado(){
   switch(selection){
      case 0: 
         output_b(0x00);
         output_bit(PIN_B1,0);
         lcd_gotoxy(1,1);
         printf(lcd_putc," Stop \n ");
         break;
      case 1:
         set_pwm1_duty(20);
         lcd_gotoxy(1,1);
         printf(lcd_putc,"  Alto \n ");
         break;   
      case 2:  
         set_pwm1_duty(60);
         lcd_gotoxy(1,1);
         printf(lcd_putc,"  Medio \n ");
         break;
      case 3:  
         set_pwm1_duty(127);
         lcd_gotoxy(1,1);
         printf(lcd_putc,"  Bajo \n ");
         break;
      default:
         break;
      delay_ms(100);
   }

}
void movMotores(){
   switch(selection){
      case 0: 
         output_b(0x00);
         //lcd_gotoxy(1,1); 
         //printf(lcd_putc,"Alto");
         break;
      case 1:
         set_pwm1_duty(120);
         //printf(lcd_putc,"Nivel 1");
         break;   
      case 2:  
         set_pwm1_duty(180);
         //printf(lcd_putc,"Nivel 2");
         break;
      case 3:  
         set_pwm1_duty(250);
         //printf(lcd_putc,"Nivel 3");
         break;
      default:
         break;
      delay_ms(100);
   }
}
