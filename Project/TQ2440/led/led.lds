SECTIONS {
	. = 0x30008000;
	
	. = ALIGN(4);
	.text :
	{
	led.o (.text)
	*(.text)
	}

	. = ALIGN(4);
	.rodata : {*(.rodata)}

	. = ALIGN(4);
	.data : {*(.data)}
	
	. = ALIGN(4);
	bss_start = .;
	.bss : {*(.bss) *(COMMON)}
	bss_end = .;
}
