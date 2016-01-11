@****************************
@File:LED1
@
@功能：用汇编点亮一个LED
@****************************

.equ	WTCON, 0x53000000				@看门狗控制寄存器地址
.equ	GPBCON, 0x56000010				@GPB控制寄存器地址
.equ	GPBDAT, 0x56000014				@GPB数据寄存器地址
.equ	INTMSK, 0x4a000008				@中断屏蔽寄存器地址
.equ	INTSUBMSK, 0x4a00001c			@子中断屏蔽寄存器地址

.text
.global	_start
_start:
@建立中断向量表
		b	reset						@复位
		ldr	pc, _undefined_instruction	@未定义指令向量
		ldr	pc, _software_interrupt		@软件中断向量
		ldr	pc, _prefetch_abort			@预取指令异常向量
		ldr	pc, _data_abort				@数据操作异常向量
		ldr	pc, _not_used				@未使用
		ldr	pc, _irq					@irq中断向量
		ldr	pc, _fiq					@fiq中断向量

_undefined_instruction:
		b .
_software_interrupt:
		b .
_prefetch_abort:
		b .
_data_abort:
		b .
_not_used:
		b .
_irq:
		b .
_fiq:
		b .

reset:
@复位
		bl set_svc
		bl disable_watchdog
		bl disable_irq
		bl init_led
		bl light_led
halt:
		b halt

set_svc:
@设置为管理模式
		mrs	r0,cpsr
		bic	r0,r0,#0x1f
		orr	r0,r0,#0xd3
		msr	cpsr,r0
		mov pc,lr

disable_watchdog:
@关闭看门狗
		ldr r0, =WTCON
		mov r1, #0x0
		str r1, [r0]
		mov pc, lr

disable_irq:
@屏蔽中断
		ldr	r1, =0xffffffff
		ldr	r0, =INTMSK
		str	r1, [r0]

		ldr	r1, =0x7fff
		ldr	r0, =INTSUBMSK
		str	r1, [r0]
		mov	pc, lr

init_led:
@清除GPB5的初始电平
		ldr r0, =GPBDAT
		mov r1, #0x20
		str r1, [r0]
	
@设置GPB5为输出状态
		ldr r0, =GPBCON
		mov r1, #0x400
		str r1, [r0]
		mov pc, lr

light_led:
@点亮LED1
		ldr r0, =GPBDAT
		mov r1, #0x0
		str r1, [r0]
		mov pc, lr
