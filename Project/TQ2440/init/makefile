all : start.O
	arm-linux-ld -Tgboot.ldd -o gboot.elf $^
	arm-linux-objcopy -O binary gboot.elf gboot.bin

%.o : %.S
	arm-wally-gcc -g -c $^

%.o : %.c
	arm-gcc -g -c $^
