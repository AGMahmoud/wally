OUTPUT_ARCH(arm)		/* arch */
ENTRY(_start)			/* 入口 */
SECTIONS{

	. = 0x30000000;			/* 起始地址 */

	. = ALIGN(4)			/*  */
	.text:
	{
	start.o(.text)
	*(.text)
	}

	. = ALIGN(4)
	.data:
	{
	}

	. = ALIGN(4)
	bss_start = .;
	.bss:
	{
	*{.bss}
	}
	bss_end = .;
}
