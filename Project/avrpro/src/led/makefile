led1.o:led1.c
	avr-gcc -mmcu=atmega16 -c led1.c
led1.elf:led1.o
	avr-gcc -mmcu=atmega16 -o led1.elf led1.o
led1.hex:led1.elf
	avr-objcopy -j .text -j .data -O ihex led1.elf led1.hex
.PHONY:upload
upload:led1.hex
	sudo avrdude -p m16 -c usbasp -e -U flash:w:"led1.hex"
