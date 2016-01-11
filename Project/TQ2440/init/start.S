.text
.global
_start:
	;; 异常向量表
	b reset
	ldr pc, _undefined_instruction ; 传给PC
	ldr pc, _software_interrupt
	ldr pc, _software_interrupt
	ldr pc, _not_used
	ldr pc, _irq
	ldr pc, _fiq
	ldr pc, _reset

_undefined_instruction:	.word undefined_instruction ; 存放地址
_software_interrupt:	.word software_interrupt
_prefetch_abort:	.word prefetch_abort
_not_used:	.word not_used
_irq:	.word irq
_fiq:	.word fiq
_reset:	.word reset

undefined_instruction:		; 标号, 地址
	nop

software_interrupt:
	nop

prefetch_abort:
	nop

not_used:
	nop

irq:
	nop

fiq:
	nop

reset:
	bl set_svc
	bl disable_watchdog
	bl disable_interrupt
	bl disable_mmu
	mov pc,lr

set_svc:
	mrc r0, cpsr
	bic r0, r0, #0x1f	; 清零
	orr r0, r0, #0xd3	; 置一
	msr cpsr, r0
	mov pc,lr

#define pWTCON 0x53000000	; address of watch dog
disable_watchdog:
	ldr r0, =pWTCON
	mv r1, #0x0
	str r1, [r0]
	mov pc,lr

disable_interrupt:
	mvn r1, #0x0		; 取反传递
	ldr r0, =0x4a000008
	str r1, [r0]
	mov pc,lr

disable_mmu:
	mcr p15,0,r0,c7,c7,0
	mrc p15,0,r0,c1,c0,0
	bic r0,r0,#0x00000007
	mcr p15,0,r0,c1,c0,0
	mov pc,lr
