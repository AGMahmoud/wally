#include <avr/io.h>
/* #include <util/delay.h> */

int main(int argc, char *argv[])
{
  /* PORTB = 0xff; */
  /* DDRB = 0xff; */
  /* while(1){ */
  /*   PORTB &= ~(1<<PB1); */
  /*   _delay_ms(300); */
  /*   PORTB |= (1<<1); */
  /*   _delay_ms(300); */
  /* } */

  unsigned char i, j, k, led=0;
  DDRB = 0x3f;
  while(1){
    if(led)
      PORTB |= 0x01;
    else
      PORTB &=0xfe;

    led = !led;
    for(i=0; i<255; i++)
      for(j=0; j<255; j++)
    	k++;
  }
  return 0;
}
