all: led.o
	arm-wally-linux-gnueabi-ld -Tled.lds -o led.elf led.o
	arm-wally-linux-gnueabi-objcopy -O binary led.elf led.bin

led.o : led.S
	arm-wally-linux-gnueabi-gcc -g -o led.o -c led.S

.PHONY: clean
clean:
	rm *.o led.elf led.bin
