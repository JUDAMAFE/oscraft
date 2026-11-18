
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00008117          	auipc	sp,0x8
    80000004:	8d010113          	addi	sp,sp,-1840 # 800078d0 <stack0>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	042000ef          	jal	80000058 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    80000024:	30a027f3          	csrr	a5,0x30a
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | MENVCFG_STCE);
    80000028:	577d                	li	a4,-1
    8000002a:	177e                	slli	a4,a4,0x3f
    8000002c:	8fd9                	or	a5,a5,a4

static inline void
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    8000002e:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r"(x));
    80000032:	306027f3          	csrr	a5,mcounteren

  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000036:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r"(x));
    8000003a:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r"(x));
    8000003e:	c01027f3          	rdtime	a5

  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80000042:	000f4737          	lui	a4,0xf4
    80000046:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000004a:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000004c:	14d79073          	csrw	stimecmp,a5
}
    80000050:	60a2                	ld	ra,8(sp)
    80000052:	6402                	ld	s0,0(sp)
    80000054:	0141                	addi	sp,sp,16
    80000056:	8082                	ret

0000000080000058 <start>:
{
    80000058:	1141                	addi	sp,sp,-16
    8000005a:	e406                	sd	ra,8(sp)
    8000005c:	e022                	sd	s0,0(sp)
    8000005e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r"(x));
    80000060:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000064:	7779                	lui	a4,0xffffe
    80000066:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdda0f>
    8000006a:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000006c:	6705                	lui	a4,0x1
    8000006e:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80000072:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r"(x));
    80000074:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r"(x));
    80000078:	00001797          	auipc	a5,0x1
    8000007c:	d8a78793          	addi	a5,a5,-630 # 80000e02 <main>
    80000080:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r"(x));
    80000084:	4781                	li	a5,0
    80000086:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r"(x));
    8000008a:	67c1                	lui	a5,0x10
    8000008c:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000008e:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r"(x));
    80000092:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r"(x));
    80000096:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    8000009a:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r"(x));
    8000009e:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    800000a2:	57fd                	li	a5,-1
    800000a4:	83a9                	srli	a5,a5,0xa
    800000a6:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    800000aa:	47bd                	li	a5,15
    800000ac:	3a079073          	csrw	pmpcfg0,a5
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    800000b0:	30a027f3          	csrr	a5,0x30a
  w_menvcfg(r_menvcfg() | MENVCFG_ADUE);
    800000b4:	4705                	li	a4,1
    800000b6:	1776                	slli	a4,a4,0x3d
    800000b8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    800000ba:	30a79073          	csrw	0x30a,a5
  timerinit();
    800000be:	f5fff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r"(x));
    800000c2:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c6:	2781                	sext.w	a5,a5
}

static inline void
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r"(x));
    800000c8:	823e                	mv	tp,a5
  asm volatile("mret");
    800000ca:	30200073          	mret
}
    800000ce:	60a2                	ld	ra,8(sp)
    800000d0:	6402                	ld	s0,0(sp)
    800000d2:	0141                	addi	sp,sp,16
    800000d4:	8082                	ret

00000000800000d6 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d6:	7119                	addi	sp,sp,-128
    800000d8:	fc86                	sd	ra,120(sp)
    800000da:	f8a2                	sd	s0,112(sp)
    800000dc:	f4a6                	sd	s1,104(sp)
    800000de:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while (i < n) {
    800000e0:	06c05b63          	blez	a2,80000156 <consolewrite+0x80>
    800000e4:	f0ca                	sd	s2,96(sp)
    800000e6:	ecce                	sd	s3,88(sp)
    800000e8:	e8d2                	sd	s4,80(sp)
    800000ea:	e4d6                	sd	s5,72(sp)
    800000ec:	e0da                	sd	s6,64(sp)
    800000ee:	fc5e                	sd	s7,56(sp)
    800000f0:	f862                	sd	s8,48(sp)
    800000f2:	f466                	sd	s9,40(sp)
    800000f4:	f06a                	sd	s10,32(sp)
    800000f6:	8b2a                	mv	s6,a0
    800000f8:	8bae                	mv	s7,a1
    800000fa:	8a32                	mv	s4,a2
  int i = 0;
    800000fc:	4481                	li	s1,0
    int nn = sizeof(buf);
    if (nn > n - i)
    800000fe:	02000c93          	li	s9,32
    80000102:	02000d13          	li	s10,32
      nn = n - i;
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000106:	f8040a93          	addi	s5,s0,-128
    8000010a:	5c7d                	li	s8,-1
    8000010c:	a025                	j	80000134 <consolewrite+0x5e>
    if (nn > n - i)
    8000010e:	0009099b          	sext.w	s3,s2
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000112:	86ce                	mv	a3,s3
    80000114:	01748633          	add	a2,s1,s7
    80000118:	85da                	mv	a1,s6
    8000011a:	8556                	mv	a0,s5
    8000011c:	2c6020ef          	jal	800023e2 <either_copyin>
    80000120:	03850d63          	beq	a0,s8,8000015a <consolewrite+0x84>
      break;
    uartwrite(buf, nn);
    80000124:	85ce                	mv	a1,s3
    80000126:	8556                	mv	a0,s5
    80000128:	77c000ef          	jal	800008a4 <uartwrite>
    i += nn;
    8000012c:	009904bb          	addw	s1,s2,s1
  while (i < n) {
    80000130:	0144d963          	bge	s1,s4,80000142 <consolewrite+0x6c>
    if (nn > n - i)
    80000134:	409a07bb          	subw	a5,s4,s1
    80000138:	893e                	mv	s2,a5
    8000013a:	fcfcdae3          	bge	s9,a5,8000010e <consolewrite+0x38>
    8000013e:	896a                	mv	s2,s10
    80000140:	b7f9                	j	8000010e <consolewrite+0x38>
    80000142:	7906                	ld	s2,96(sp)
    80000144:	69e6                	ld	s3,88(sp)
    80000146:	6a46                	ld	s4,80(sp)
    80000148:	6aa6                	ld	s5,72(sp)
    8000014a:	6b06                	ld	s6,64(sp)
    8000014c:	7be2                	ld	s7,56(sp)
    8000014e:	7c42                	ld	s8,48(sp)
    80000150:	7ca2                	ld	s9,40(sp)
    80000152:	7d02                	ld	s10,32(sp)
    80000154:	a821                	j	8000016c <consolewrite+0x96>
  int i = 0;
    80000156:	4481                	li	s1,0
    80000158:	a811                	j	8000016c <consolewrite+0x96>
    8000015a:	7906                	ld	s2,96(sp)
    8000015c:	69e6                	ld	s3,88(sp)
    8000015e:	6a46                	ld	s4,80(sp)
    80000160:	6aa6                	ld	s5,72(sp)
    80000162:	6b06                	ld	s6,64(sp)
    80000164:	7be2                	ld	s7,56(sp)
    80000166:	7c42                	ld	s8,48(sp)
    80000168:	7ca2                	ld	s9,40(sp)
    8000016a:	7d02                	ld	s10,32(sp)
  }

  return i;
}
    8000016c:	8526                	mv	a0,s1
    8000016e:	70e6                	ld	ra,120(sp)
    80000170:	7446                	ld	s0,112(sp)
    80000172:	74a6                	ld	s1,104(sp)
    80000174:	6109                	addi	sp,sp,128
    80000176:	8082                	ret

0000000080000178 <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000178:	711d                	addi	sp,sp,-96
    8000017a:	ec86                	sd	ra,88(sp)
    8000017c:	e8a2                	sd	s0,80(sp)
    8000017e:	e4a6                	sd	s1,72(sp)
    80000180:	e0ca                	sd	s2,64(sp)
    80000182:	fc4e                	sd	s3,56(sp)
    80000184:	f852                	sd	s4,48(sp)
    80000186:	f456                	sd	s5,40(sp)
    80000188:	f05a                	sd	s6,32(sp)
    8000018a:	1080                	addi	s0,sp,96
    8000018c:	8aaa                	mv	s5,a0
    8000018e:	8a2e                	mv	s4,a1
    80000190:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000192:	8b32                	mv	s6,a2
  acquire(&cons.lock);
    80000194:	0000f517          	auipc	a0,0xf
    80000198:	73c50513          	addi	a0,a0,1852 # 8000f8d0 <cons>
    8000019c:	1f1000ef          	jal	80000b8c <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    800001a0:	0000f497          	auipc	s1,0xf
    800001a4:	73048493          	addi	s1,s1,1840 # 8000f8d0 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a8:	0000f917          	auipc	s2,0xf
    800001ac:	7c090913          	addi	s2,s2,1984 # 8000f968 <cons+0x98>
  while (n > 0) {
    800001b0:	0d305263          	blez	s3,80000274 <consoleread+0xfc>
    while (cons.r == cons.w) {
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	0af71763          	bne	a4,a5,8000026a <consoleread+0xf2>
      if (killed(myproc())) {
    800001c0:	7be010ef          	jal	8000197e <myproc>
    800001c4:	09e020ef          	jal	80002262 <killed>
    800001c8:	e925                	bnez	a0,80000238 <consoleread+0xc0>
      sleep_prepare(&cons.r);
    800001ca:	854a                	mv	a0,s2
    800001cc:	63d010ef          	jal	80002008 <sleep_prepare>
      release(&cons.lock);
    800001d0:	8526                	mv	a0,s1
    800001d2:	243000ef          	jal	80000c14 <release>
      sleep();
    800001d6:	66f010ef          	jal	80002044 <sleep>
      acquire(&cons.lock);
    800001da:	8526                	mv	a0,s1
    800001dc:	1b1000ef          	jal	80000b8c <acquire>
    while (cons.r == cons.w) {
    800001e0:	0984a783          	lw	a5,152(s1)
    800001e4:	09c4a703          	lw	a4,156(s1)
    800001e8:	fcf70ce3          	beq	a4,a5,800001c0 <consoleread+0x48>
    800001ec:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ee:	0000f717          	auipc	a4,0xf
    800001f2:	6e270713          	addi	a4,a4,1762 # 8000f8d0 <cons>
    800001f6:	0017869b          	addiw	a3,a5,1
    800001fa:	08d72c23          	sw	a3,152(a4)
    800001fe:	07f7f693          	andi	a3,a5,127
    80000202:	9736                	add	a4,a4,a3
    80000204:	01874703          	lbu	a4,24(a4)
    80000208:	00070b9b          	sext.w	s7,a4

    if (c == C('D')) { // end-of-file
    8000020c:	4691                	li	a3,4
    8000020e:	04db8663          	beq	s7,a3,8000025a <consoleread+0xe2>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000212:	fae407a3          	sb	a4,-81(s0)
    if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000216:	4685                	li	a3,1
    80000218:	faf40613          	addi	a2,s0,-81
    8000021c:	85d2                	mv	a1,s4
    8000021e:	8556                	mv	a0,s5
    80000220:	176020ef          	jal	80002396 <either_copyout>
    80000224:	57fd                	li	a5,-1
    80000226:	04f50663          	beq	a0,a5,80000272 <consoleread+0xfa>
      break;

    dst++;
    8000022a:	0a05                	addi	s4,s4,1
    --n;
    8000022c:	39fd                	addiw	s3,s3,-1

    if (c == '\n') {
    8000022e:	47a9                	li	a5,10
    80000230:	04fb8b63          	beq	s7,a5,80000286 <consoleread+0x10e>
    80000234:	6be2                	ld	s7,24(sp)
    80000236:	bfad                	j	800001b0 <consoleread+0x38>
        release(&cons.lock);
    80000238:	0000f517          	auipc	a0,0xf
    8000023c:	69850513          	addi	a0,a0,1688 # 8000f8d0 <cons>
    80000240:	1d5000ef          	jal	80000c14 <release>
        return -1;
    80000244:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000246:	60e6                	ld	ra,88(sp)
    80000248:	6446                	ld	s0,80(sp)
    8000024a:	64a6                	ld	s1,72(sp)
    8000024c:	6906                	ld	s2,64(sp)
    8000024e:	79e2                	ld	s3,56(sp)
    80000250:	7a42                	ld	s4,48(sp)
    80000252:	7aa2                	ld	s5,40(sp)
    80000254:	7b02                	ld	s6,32(sp)
    80000256:	6125                	addi	sp,sp,96
    80000258:	8082                	ret
      if (n < target) {
    8000025a:	0169fa63          	bgeu	s3,s6,8000026e <consoleread+0xf6>
        cons.r--;
    8000025e:	0000f717          	auipc	a4,0xf
    80000262:	70f72523          	sw	a5,1802(a4) # 8000f968 <cons+0x98>
    80000266:	6be2                	ld	s7,24(sp)
    80000268:	a031                	j	80000274 <consoleread+0xfc>
    8000026a:	ec5e                	sd	s7,24(sp)
    8000026c:	b749                	j	800001ee <consoleread+0x76>
    8000026e:	6be2                	ld	s7,24(sp)
    80000270:	a011                	j	80000274 <consoleread+0xfc>
    80000272:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000274:	0000f517          	auipc	a0,0xf
    80000278:	65c50513          	addi	a0,a0,1628 # 8000f8d0 <cons>
    8000027c:	199000ef          	jal	80000c14 <release>
  return target - n;
    80000280:	413b053b          	subw	a0,s6,s3
    80000284:	b7c9                	j	80000246 <consoleread+0xce>
    80000286:	6be2                	ld	s7,24(sp)
    80000288:	b7f5                	j	80000274 <consoleread+0xfc>

000000008000028a <consputc>:
{
    8000028a:	1141                	addi	sp,sp,-16
    8000028c:	e406                	sd	ra,8(sp)
    8000028e:	e022                	sd	s0,0(sp)
    80000290:	0800                	addi	s0,sp,16
  if (c == BACKSPACE) {
    80000292:	10000793          	li	a5,256
    80000296:	00f50863          	beq	a0,a5,800002a6 <consputc+0x1c>
    uartputc_sync(c);
    8000029a:	690000ef          	jal	8000092a <uartputc_sync>
}
    8000029e:	60a2                	ld	ra,8(sp)
    800002a0:	6402                	ld	s0,0(sp)
    800002a2:	0141                	addi	sp,sp,16
    800002a4:	8082                	ret
    uartputc_sync('\b');
    800002a6:	4521                	li	a0,8
    800002a8:	682000ef          	jal	8000092a <uartputc_sync>
    uartputc_sync(' ');
    800002ac:	02000513          	li	a0,32
    800002b0:	67a000ef          	jal	8000092a <uartputc_sync>
    uartputc_sync('\b');
    800002b4:	4521                	li	a0,8
    800002b6:	674000ef          	jal	8000092a <uartputc_sync>
    800002ba:	b7d5                	j	8000029e <consputc+0x14>

00000000800002bc <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002bc:	7179                	addi	sp,sp,-48
    800002be:	f406                	sd	ra,40(sp)
    800002c0:	f022                	sd	s0,32(sp)
    800002c2:	ec26                	sd	s1,24(sp)
    800002c4:	1800                	addi	s0,sp,48
    800002c6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c8:	0000f517          	auipc	a0,0xf
    800002cc:	60850513          	addi	a0,a0,1544 # 8000f8d0 <cons>
    800002d0:	0bd000ef          	jal	80000b8c <acquire>

  switch (c) {
    800002d4:	47d5                	li	a5,21
    800002d6:	08f48e63          	beq	s1,a5,80000372 <consoleintr+0xb6>
    800002da:	0297c563          	blt	a5,s1,80000304 <consoleintr+0x48>
    800002de:	47a1                	li	a5,8
    800002e0:	0ef48863          	beq	s1,a5,800003d0 <consoleintr+0x114>
    800002e4:	47c1                	li	a5,16
    800002e6:	10f49963          	bne	s1,a5,800003f8 <consoleintr+0x13c>
  case C('P'): // Print process list.
    procdump();
    800002ea:	144020ef          	jal	8000242e <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ee:	0000f517          	auipc	a0,0xf
    800002f2:	5e250513          	addi	a0,a0,1506 # 8000f8d0 <cons>
    800002f6:	11f000ef          	jal	80000c14 <release>
}
    800002fa:	70a2                	ld	ra,40(sp)
    800002fc:	7402                	ld	s0,32(sp)
    800002fe:	64e2                	ld	s1,24(sp)
    80000300:	6145                	addi	sp,sp,48
    80000302:	8082                	ret
  switch (c) {
    80000304:	07f00793          	li	a5,127
    80000308:	0cf48463          	beq	s1,a5,800003d0 <consoleintr+0x114>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    8000030c:	0000f717          	auipc	a4,0xf
    80000310:	5c470713          	addi	a4,a4,1476 # 8000f8d0 <cons>
    80000314:	0a072783          	lw	a5,160(a4)
    80000318:	09872703          	lw	a4,152(a4)
    8000031c:	9f99                	subw	a5,a5,a4
    8000031e:	07f00713          	li	a4,127
    80000322:	fcf766e3          	bltu	a4,a5,800002ee <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000326:	47b5                	li	a5,13
    80000328:	0cf48b63          	beq	s1,a5,800003fe <consoleintr+0x142>
      consputc(c);
    8000032c:	8526                	mv	a0,s1
    8000032e:	f5dff0ef          	jal	8000028a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000332:	0000f797          	auipc	a5,0xf
    80000336:	59e78793          	addi	a5,a5,1438 # 8000f8d0 <cons>
    8000033a:	0a07a683          	lw	a3,160(a5)
    8000033e:	0016871b          	addiw	a4,a3,1
    80000342:	863a                	mv	a2,a4
    80000344:	0ae7a023          	sw	a4,160(a5)
    80000348:	07f6f693          	andi	a3,a3,127
    8000034c:	97b6                	add	a5,a5,a3
    8000034e:	00978c23          	sb	s1,24(a5)
      if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE) {
    80000352:	47a9                	li	a5,10
    80000354:	0cf48963          	beq	s1,a5,80000426 <consoleintr+0x16a>
    80000358:	4791                	li	a5,4
    8000035a:	0cf48663          	beq	s1,a5,80000426 <consoleintr+0x16a>
    8000035e:	0000f797          	auipc	a5,0xf
    80000362:	60a7a783          	lw	a5,1546(a5) # 8000f968 <cons+0x98>
    80000366:	9f1d                	subw	a4,a4,a5
    80000368:	08000793          	li	a5,128
    8000036c:	f8f711e3          	bne	a4,a5,800002ee <consoleintr+0x32>
    80000370:	a85d                	j	80000426 <consoleintr+0x16a>
    80000372:	e84a                	sd	s2,16(sp)
    80000374:	e44e                	sd	s3,8(sp)
    while (cons.e != cons.w &&
    80000376:	0000f717          	auipc	a4,0xf
    8000037a:	55a70713          	addi	a4,a4,1370 # 8000f8d0 <cons>
    8000037e:	0a072783          	lw	a5,160(a4)
    80000382:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000386:	0000f497          	auipc	s1,0xf
    8000038a:	54a48493          	addi	s1,s1,1354 # 8000f8d0 <cons>
    while (cons.e != cons.w &&
    8000038e:	4929                	li	s2,10
      consputc(BACKSPACE);
    80000390:	10000993          	li	s3,256
    while (cons.e != cons.w &&
    80000394:	02f70863          	beq	a4,a5,800003c4 <consoleintr+0x108>
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000398:	37fd                	addiw	a5,a5,-1
    8000039a:	07f7f713          	andi	a4,a5,127
    8000039e:	9726                	add	a4,a4,s1
    while (cons.e != cons.w &&
    800003a0:	01874703          	lbu	a4,24(a4)
    800003a4:	03270363          	beq	a4,s2,800003ca <consoleintr+0x10e>
      cons.e--;
    800003a8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003ac:	854e                	mv	a0,s3
    800003ae:	eddff0ef          	jal	8000028a <consputc>
    while (cons.e != cons.w &&
    800003b2:	0a04a783          	lw	a5,160(s1)
    800003b6:	09c4a703          	lw	a4,156(s1)
    800003ba:	fcf71fe3          	bne	a4,a5,80000398 <consoleintr+0xdc>
    800003be:	6942                	ld	s2,16(sp)
    800003c0:	69a2                	ld	s3,8(sp)
    800003c2:	b735                	j	800002ee <consoleintr+0x32>
    800003c4:	6942                	ld	s2,16(sp)
    800003c6:	69a2                	ld	s3,8(sp)
    800003c8:	b71d                	j	800002ee <consoleintr+0x32>
    800003ca:	6942                	ld	s2,16(sp)
    800003cc:	69a2                	ld	s3,8(sp)
    800003ce:	b705                	j	800002ee <consoleintr+0x32>
    if (cons.e != cons.w) {
    800003d0:	0000f717          	auipc	a4,0xf
    800003d4:	50070713          	addi	a4,a4,1280 # 8000f8d0 <cons>
    800003d8:	0a072783          	lw	a5,160(a4)
    800003dc:	09c72703          	lw	a4,156(a4)
    800003e0:	f0f707e3          	beq	a4,a5,800002ee <consoleintr+0x32>
      cons.e--;
    800003e4:	37fd                	addiw	a5,a5,-1
    800003e6:	0000f717          	auipc	a4,0xf
    800003ea:	58f72523          	sw	a5,1418(a4) # 8000f970 <cons+0xa0>
      consputc(BACKSPACE);
    800003ee:	10000513          	li	a0,256
    800003f2:	e99ff0ef          	jal	8000028a <consputc>
    800003f6:	bde5                	j	800002ee <consoleintr+0x32>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    800003f8:	ee048be3          	beqz	s1,800002ee <consoleintr+0x32>
    800003fc:	bf01                	j	8000030c <consoleintr+0x50>
      consputc(c);
    800003fe:	4529                	li	a0,10
    80000400:	e8bff0ef          	jal	8000028a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000404:	0000f797          	auipc	a5,0xf
    80000408:	4cc78793          	addi	a5,a5,1228 # 8000f8d0 <cons>
    8000040c:	0a07a703          	lw	a4,160(a5)
    80000410:	0017069b          	addiw	a3,a4,1
    80000414:	8636                	mv	a2,a3
    80000416:	0ad7a023          	sw	a3,160(a5)
    8000041a:	07f77713          	andi	a4,a4,127
    8000041e:	97ba                	add	a5,a5,a4
    80000420:	4729                	li	a4,10
    80000422:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000426:	0000f797          	auipc	a5,0xf
    8000042a:	54c7a323          	sw	a2,1350(a5) # 8000f96c <cons+0x9c>
        wakeup(&cons.r);
    8000042e:	0000f517          	auipc	a0,0xf
    80000432:	53a50513          	addi	a0,a0,1338 # 8000f968 <cons+0x98>
    80000436:	43f010ef          	jal	80002074 <wakeup>
    8000043a:	bd55                	j	800002ee <consoleintr+0x32>

000000008000043c <consoleinit>:

void
consoleinit(void)
{
    8000043c:	1141                	addi	sp,sp,-16
    8000043e:	e406                	sd	ra,8(sp)
    80000440:	e022                	sd	s0,0(sp)
    80000442:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000444:	00007597          	auipc	a1,0x7
    80000448:	bbc58593          	addi	a1,a1,-1092 # 80007000 <etext>
    8000044c:	0000f517          	auipc	a0,0xf
    80000450:	48450513          	addi	a0,a0,1156 # 8000f8d0 <cons>
    80000454:	6be000ef          	jal	80000b12 <initlock>

  uartinit();
    80000458:	3f6000ef          	jal	8000084e <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000045c:	0001f797          	auipc	a5,0x1f
    80000460:	7fc78793          	addi	a5,a5,2044 # 8001fc58 <devsw>
    80000464:	00000717          	auipc	a4,0x0
    80000468:	d1470713          	addi	a4,a4,-748 # 80000178 <consoleread>
    8000046c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000046e:	00000717          	auipc	a4,0x0
    80000472:	c6870713          	addi	a4,a4,-920 # 800000d6 <consolewrite>
    80000476:	ef98                	sd	a4,24(a5)
}
    80000478:	60a2                	ld	ra,8(sp)
    8000047a:	6402                	ld	s0,0(sp)
    8000047c:	0141                	addi	sp,sp,16
    8000047e:	8082                	ret

0000000080000480 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000480:	7139                	addi	sp,sp,-64
    80000482:	fc06                	sd	ra,56(sp)
    80000484:	f822                	sd	s0,48(sp)
    80000486:	f426                	sd	s1,40(sp)
    80000488:	f04a                	sd	s2,32(sp)
    8000048a:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if (sign && (sign = (xx < 0)))
    8000048c:	c219                	beqz	a2,80000492 <printint+0x12>
    8000048e:	06054a63          	bltz	a0,80000502 <printint+0x82>
    x = -xx;
  else
    x = xx;
    80000492:	4e01                	li	t3,0

  i = 0;
    80000494:	fc840313          	addi	t1,s0,-56
    x = xx;
    80000498:	869a                	mv	a3,t1
  i = 0;
    8000049a:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000049c:	00007817          	auipc	a6,0x7
    800004a0:	2c480813          	addi	a6,a6,708 # 80007760 <digits>
    800004a4:	88be                	mv	a7,a5
    800004a6:	0017861b          	addiw	a2,a5,1
    800004aa:	87b2                	mv	a5,a2
    800004ac:	02b57733          	remu	a4,a0,a1
    800004b0:	9742                	add	a4,a4,a6
    800004b2:	00074703          	lbu	a4,0(a4)
    800004b6:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
    800004ba:	872a                	mv	a4,a0
    800004bc:	02b55533          	divu	a0,a0,a1
    800004c0:	0685                	addi	a3,a3,1
    800004c2:	feb771e3          	bgeu	a4,a1,800004a4 <printint+0x24>

  if (sign)
    800004c6:	000e0c63          	beqz	t3,800004de <printint+0x5e>
    buf[i++] = '-';
    800004ca:	fe060793          	addi	a5,a2,-32
    800004ce:	00878633          	add	a2,a5,s0
    800004d2:	02d00793          	li	a5,45
    800004d6:	fef60423          	sb	a5,-24(a2)
    800004da:	0028879b          	addiw	a5,a7,2

  while (--i >= 0)
    800004de:	fff7891b          	addiw	s2,a5,-1
    800004e2:	006784b3          	add	s1,a5,t1
    consputc(buf[i]);
    800004e6:	fff4c503          	lbu	a0,-1(s1)
    800004ea:	da1ff0ef          	jal	8000028a <consputc>
  while (--i >= 0)
    800004ee:	397d                	addiw	s2,s2,-1
    800004f0:	14fd                	addi	s1,s1,-1
    800004f2:	fe095ae3          	bgez	s2,800004e6 <printint+0x66>
}
    800004f6:	70e2                	ld	ra,56(sp)
    800004f8:	7442                	ld	s0,48(sp)
    800004fa:	74a2                	ld	s1,40(sp)
    800004fc:	7902                	ld	s2,32(sp)
    800004fe:	6121                	addi	sp,sp,64
    80000500:	8082                	ret
    x = -xx;
    80000502:	40a00533          	neg	a0,a0
  if (sign && (sign = (xx < 0)))
    80000506:	4e05                	li	t3,1
    x = -xx;
    80000508:	b771                	j	80000494 <printint+0x14>

000000008000050a <printk>:
}

// Print to the console.
int
printk(char *fmt, ...)
{
    8000050a:	7131                	addi	sp,sp,-192
    8000050c:	fc86                	sd	ra,120(sp)
    8000050e:	f8a2                	sd	s0,112(sp)
    80000510:	e8d2                	sd	s4,80(sp)
    80000512:	0100                	addi	s0,sp,128
    80000514:	8a2a                	mv	s4,a0
    80000516:	e40c                	sd	a1,8(s0)
    80000518:	e810                	sd	a2,16(s0)
    8000051a:	ec14                	sd	a3,24(s0)
    8000051c:	f018                	sd	a4,32(s0)
    8000051e:	f41c                	sd	a5,40(s0)
    80000520:	03043823          	sd	a6,48(s0)
    80000524:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if (panicking == 0)
    80000528:	00007797          	auipc	a5,0x7
    8000052c:	37c7a783          	lw	a5,892(a5) # 800078a4 <panicking>
    80000530:	c3a1                	beqz	a5,80000570 <printk+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000532:	00840793          	addi	a5,s0,8
    80000536:	f8f43423          	sd	a5,-120(s0)
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    8000053a:	000a4503          	lbu	a0,0(s4)
    8000053e:	28050663          	beqz	a0,800007ca <printk+0x2c0>
    80000542:	f4a6                	sd	s1,104(sp)
    80000544:	f0ca                	sd	s2,96(sp)
    80000546:	ecce                	sd	s3,88(sp)
    80000548:	e4d6                	sd	s5,72(sp)
    8000054a:	e0da                	sd	s6,64(sp)
    8000054c:	f862                	sd	s8,48(sp)
    8000054e:	f466                	sd	s9,40(sp)
    80000550:	f06a                	sd	s10,32(sp)
    80000552:	ec6e                	sd	s11,24(sp)
    80000554:	4901                	li	s2,0
    if (cx != '%') {
    80000556:	02500a93          	li	s5,37
    c1 = c2 = 0;
    if (c0)
      c1 = fmt[i + 1] & 0xff;
    if (c1)
      c2 = fmt[i + 2] & 0xff;
    if (c0 == 'd') {
    8000055a:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if (c0 == 'l' && c1 == 'd') {
    8000055e:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if (c0 == 'u') {
    80000562:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if (c0 == 'x') {
    80000566:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if (c0 == 'p') {
    8000056a:	07000d93          	li	s11,112
    8000056e:	a015                	j	80000592 <printk+0x88>
    acquire(&pr.lock);
    80000570:	0000f517          	auipc	a0,0xf
    80000574:	40850513          	addi	a0,a0,1032 # 8000f978 <pr>
    80000578:	614000ef          	jal	80000b8c <acquire>
    8000057c:	bf5d                	j	80000532 <printk+0x28>
      consputc(cx);
    8000057e:	d0dff0ef          	jal	8000028a <consputc>
      continue;
    80000582:	84ca                	mv	s1,s2
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    80000584:	2485                	addiw	s1,s1,1
    80000586:	8926                	mv	s2,s1
    80000588:	94d2                	add	s1,s1,s4
    8000058a:	0004c503          	lbu	a0,0(s1)
    8000058e:	20050b63          	beqz	a0,800007a4 <printk+0x29a>
    if (cx != '%') {
    80000592:	ff5516e3          	bne	a0,s5,8000057e <printk+0x74>
    i++;
    80000596:	0019079b          	addiw	a5,s2,1
    8000059a:	84be                	mv	s1,a5
    c0 = fmt[i + 0] & 0xff;
    8000059c:	00fa0733          	add	a4,s4,a5
    800005a0:	00074983          	lbu	s3,0(a4)
    if (c0)
    800005a4:	20098a63          	beqz	s3,800007b8 <printk+0x2ae>
      c1 = fmt[i + 1] & 0xff;
    800005a8:	00174703          	lbu	a4,1(a4)
    c1 = c2 = 0;
    800005ac:	86ba                	mv	a3,a4
    if (c1)
    800005ae:	c701                	beqz	a4,800005b6 <printk+0xac>
      c2 = fmt[i + 2] & 0xff;
    800005b0:	97d2                	add	a5,a5,s4
    800005b2:	0027c683          	lbu	a3,2(a5)
    if (c0 == 'd') {
    800005b6:	03698963          	beq	s3,s6,800005e8 <printk+0xde>
    } else if (c0 == 'l' && c1 == 'd') {
    800005ba:	05898363          	beq	s3,s8,80000600 <printk+0xf6>
    } else if (c0 == 'u') {
    800005be:	0d998663          	beq	s3,s9,8000068a <printk+0x180>
    } else if (c0 == 'x') {
    800005c2:	11a98d63          	beq	s3,s10,800006dc <printk+0x1d2>
    } else if (c0 == 'p') {
    800005c6:	15b98663          	beq	s3,s11,80000712 <printk+0x208>
      printptr(va_arg(ap, uint64));
    } else if (c0 == 'c') {
    800005ca:	06300793          	li	a5,99
    800005ce:	18f98563          	beq	s3,a5,80000758 <printk+0x24e>
      consputc(va_arg(ap, uint));
    } else if (c0 == 's') {
    800005d2:	07300793          	li	a5,115
    800005d6:	18f98b63          	beq	s3,a5,8000076c <printk+0x262>
      if ((s = va_arg(ap, char *)) == 0)
        s = "(null)";
      for (; *s; s++)
        consputc(*s);
    } else if (c0 == '%') {
    800005da:	03599b63          	bne	s3,s5,80000610 <printk+0x106>
      consputc('%');
    800005de:	02500513          	li	a0,37
    800005e2:	ca9ff0ef          	jal	8000028a <consputc>
    800005e6:	bf79                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800005e8:	f8843783          	ld	a5,-120(s0)
    800005ec:	00878713          	addi	a4,a5,8
    800005f0:	f8e43423          	sd	a4,-120(s0)
    800005f4:	4605                	li	a2,1
    800005f6:	45a9                	li	a1,10
    800005f8:	4388                	lw	a0,0(a5)
    800005fa:	e87ff0ef          	jal	80000480 <printint>
    800005fe:	b759                	j	80000584 <printk+0x7a>
    } else if (c0 == 'l' && c1 == 'd') {
    80000600:	01670f63          	beq	a4,s6,8000061e <printk+0x114>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    80000604:	03870b63          	beq	a4,s8,8000063a <printk+0x130>
    } else if (c0 == 'l' && c1 == 'u') {
    80000608:	09970e63          	beq	a4,s9,800006a4 <printk+0x19a>
    } else if (c0 == 'l' && c1 == 'x') {
    8000060c:	0fa70563          	beq	a4,s10,800006f6 <printk+0x1ec>
    } else if (c0 == 0) {
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000610:	8556                	mv	a0,s5
    80000612:	c79ff0ef          	jal	8000028a <consputc>
      consputc(c0);
    80000616:	854e                	mv	a0,s3
    80000618:	c73ff0ef          	jal	8000028a <consputc>
    8000061c:	b7a5                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    8000061e:	f8843783          	ld	a5,-120(s0)
    80000622:	00878713          	addi	a4,a5,8
    80000626:	f8e43423          	sd	a4,-120(s0)
    8000062a:	4605                	li	a2,1
    8000062c:	45a9                	li	a1,10
    8000062e:	6388                	ld	a0,0(a5)
    80000630:	e51ff0ef          	jal	80000480 <printint>
      i += 1;
    80000634:	0029049b          	addiw	s1,s2,2
    80000638:	b7b1                	j	80000584 <printk+0x7a>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    8000063a:	06400793          	li	a5,100
    8000063e:	02f68863          	beq	a3,a5,8000066e <printk+0x164>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
    80000642:	07500793          	li	a5,117
    80000646:	06f68d63          	beq	a3,a5,800006c0 <printk+0x1b6>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
    8000064a:	07800793          	li	a5,120
    8000064e:	fcf691e3          	bne	a3,a5,80000610 <printk+0x106>
      printint(va_arg(ap, uint64), 16, 0);
    80000652:	f8843783          	ld	a5,-120(s0)
    80000656:	00878713          	addi	a4,a5,8
    8000065a:	f8e43423          	sd	a4,-120(s0)
    8000065e:	4601                	li	a2,0
    80000660:	45c1                	li	a1,16
    80000662:	6388                	ld	a0,0(a5)
    80000664:	e1dff0ef          	jal	80000480 <printint>
      i += 2;
    80000668:	0039049b          	addiw	s1,s2,3
    8000066c:	bf21                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    8000066e:	f8843783          	ld	a5,-120(s0)
    80000672:	00878713          	addi	a4,a5,8
    80000676:	f8e43423          	sd	a4,-120(s0)
    8000067a:	4605                	li	a2,1
    8000067c:	45a9                	li	a1,10
    8000067e:	6388                	ld	a0,0(a5)
    80000680:	e01ff0ef          	jal	80000480 <printint>
      i += 2;
    80000684:	0039049b          	addiw	s1,s2,3
    80000688:	bdf5                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000068a:	f8843783          	ld	a5,-120(s0)
    8000068e:	00878713          	addi	a4,a5,8
    80000692:	f8e43423          	sd	a4,-120(s0)
    80000696:	4601                	li	a2,0
    80000698:	45a9                	li	a1,10
    8000069a:	0007e503          	lwu	a0,0(a5)
    8000069e:	de3ff0ef          	jal	80000480 <printint>
    800006a2:	b5cd                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006a4:	f8843783          	ld	a5,-120(s0)
    800006a8:	00878713          	addi	a4,a5,8
    800006ac:	f8e43423          	sd	a4,-120(s0)
    800006b0:	4601                	li	a2,0
    800006b2:	45a9                	li	a1,10
    800006b4:	6388                	ld	a0,0(a5)
    800006b6:	dcbff0ef          	jal	80000480 <printint>
      i += 1;
    800006ba:	0029049b          	addiw	s1,s2,2
    800006be:	b5d9                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006c0:	f8843783          	ld	a5,-120(s0)
    800006c4:	00878713          	addi	a4,a5,8
    800006c8:	f8e43423          	sd	a4,-120(s0)
    800006cc:	4601                	li	a2,0
    800006ce:	45a9                	li	a1,10
    800006d0:	6388                	ld	a0,0(a5)
    800006d2:	dafff0ef          	jal	80000480 <printint>
      i += 2;
    800006d6:	0039049b          	addiw	s1,s2,3
    800006da:	b56d                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800006dc:	f8843783          	ld	a5,-120(s0)
    800006e0:	00878713          	addi	a4,a5,8
    800006e4:	f8e43423          	sd	a4,-120(s0)
    800006e8:	4601                	li	a2,0
    800006ea:	45c1                	li	a1,16
    800006ec:	0007e503          	lwu	a0,0(a5)
    800006f0:	d91ff0ef          	jal	80000480 <printint>
    800006f4:	bd41                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800006f6:	f8843783          	ld	a5,-120(s0)
    800006fa:	00878713          	addi	a4,a5,8
    800006fe:	f8e43423          	sd	a4,-120(s0)
    80000702:	4601                	li	a2,0
    80000704:	45c1                	li	a1,16
    80000706:	6388                	ld	a0,0(a5)
    80000708:	d79ff0ef          	jal	80000480 <printint>
      i += 1;
    8000070c:	0029049b          	addiw	s1,s2,2
    80000710:	bd95                	j	80000584 <printk+0x7a>
    80000712:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80000714:	f8843783          	ld	a5,-120(s0)
    80000718:	00878713          	addi	a4,a5,8
    8000071c:	f8e43423          	sd	a4,-120(s0)
    80000720:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000724:	03000513          	li	a0,48
    80000728:	b63ff0ef          	jal	8000028a <consputc>
  consputc('x');
    8000072c:	07800513          	li	a0,120
    80000730:	b5bff0ef          	jal	8000028a <consputc>
    80000734:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000736:	00007b97          	auipc	s7,0x7
    8000073a:	02ab8b93          	addi	s7,s7,42 # 80007760 <digits>
    8000073e:	03c9d793          	srli	a5,s3,0x3c
    80000742:	97de                	add	a5,a5,s7
    80000744:	0007c503          	lbu	a0,0(a5)
    80000748:	b43ff0ef          	jal	8000028a <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000074c:	0992                	slli	s3,s3,0x4
    8000074e:	397d                	addiw	s2,s2,-1
    80000750:	fe0917e3          	bnez	s2,8000073e <printk+0x234>
    80000754:	7be2                	ld	s7,56(sp)
    80000756:	b53d                	j	80000584 <printk+0x7a>
      consputc(va_arg(ap, uint));
    80000758:	f8843783          	ld	a5,-120(s0)
    8000075c:	00878713          	addi	a4,a5,8
    80000760:	f8e43423          	sd	a4,-120(s0)
    80000764:	4388                	lw	a0,0(a5)
    80000766:	b25ff0ef          	jal	8000028a <consputc>
    8000076a:	bd29                	j	80000584 <printk+0x7a>
      if ((s = va_arg(ap, char *)) == 0)
    8000076c:	f8843783          	ld	a5,-120(s0)
    80000770:	00878713          	addi	a4,a5,8
    80000774:	f8e43423          	sd	a4,-120(s0)
    80000778:	0007b903          	ld	s2,0(a5)
    8000077c:	00090d63          	beqz	s2,80000796 <printk+0x28c>
      for (; *s; s++)
    80000780:	00094503          	lbu	a0,0(s2)
    80000784:	e00500e3          	beqz	a0,80000584 <printk+0x7a>
        consputc(*s);
    80000788:	b03ff0ef          	jal	8000028a <consputc>
      for (; *s; s++)
    8000078c:	0905                	addi	s2,s2,1
    8000078e:	00094503          	lbu	a0,0(s2)
    80000792:	f97d                	bnez	a0,80000788 <printk+0x27e>
    80000794:	bbc5                	j	80000584 <printk+0x7a>
        s = "(null)";
    80000796:	00007917          	auipc	s2,0x7
    8000079a:	87290913          	addi	s2,s2,-1934 # 80007008 <etext+0x8>
      for (; *s; s++)
    8000079e:	02800513          	li	a0,40
    800007a2:	b7dd                	j	80000788 <printk+0x27e>
    800007a4:	74a6                	ld	s1,104(sp)
    800007a6:	7906                	ld	s2,96(sp)
    800007a8:	69e6                	ld	s3,88(sp)
    800007aa:	6aa6                	ld	s5,72(sp)
    800007ac:	6b06                	ld	s6,64(sp)
    800007ae:	7c42                	ld	s8,48(sp)
    800007b0:	7ca2                	ld	s9,40(sp)
    800007b2:	7d02                	ld	s10,32(sp)
    800007b4:	6de2                	ld	s11,24(sp)
    800007b6:	a811                	j	800007ca <printk+0x2c0>
    800007b8:	74a6                	ld	s1,104(sp)
    800007ba:	7906                	ld	s2,96(sp)
    800007bc:	69e6                	ld	s3,88(sp)
    800007be:	6aa6                	ld	s5,72(sp)
    800007c0:	6b06                	ld	s6,64(sp)
    800007c2:	7c42                	ld	s8,48(sp)
    800007c4:	7ca2                	ld	s9,40(sp)
    800007c6:	7d02                	ld	s10,32(sp)
    800007c8:	6de2                	ld	s11,24(sp)
    }
  }
  va_end(ap);

  if (panicking == 0)
    800007ca:	00007797          	auipc	a5,0x7
    800007ce:	0da7a783          	lw	a5,218(a5) # 800078a4 <panicking>
    800007d2:	c799                	beqz	a5,800007e0 <printk+0x2d6>
    release(&pr.lock);

  return 0;
}
    800007d4:	4501                	li	a0,0
    800007d6:	70e6                	ld	ra,120(sp)
    800007d8:	7446                	ld	s0,112(sp)
    800007da:	6a46                	ld	s4,80(sp)
    800007dc:	6129                	addi	sp,sp,192
    800007de:	8082                	ret
    release(&pr.lock);
    800007e0:	0000f517          	auipc	a0,0xf
    800007e4:	19850513          	addi	a0,a0,408 # 8000f978 <pr>
    800007e8:	42c000ef          	jal	80000c14 <release>
  return 0;
    800007ec:	b7e5                	j	800007d4 <printk+0x2ca>

00000000800007ee <panic>:

void
panic(char *s)
{
    800007ee:	1101                	addi	sp,sp,-32
    800007f0:	ec06                	sd	ra,24(sp)
    800007f2:	e822                	sd	s0,16(sp)
    800007f4:	e426                	sd	s1,8(sp)
    800007f6:	e04a                	sd	s2,0(sp)
    800007f8:	1000                	addi	s0,sp,32
    800007fa:	84aa                	mv	s1,a0
  panicking = 1;
    800007fc:	4905                	li	s2,1
    800007fe:	00007797          	auipc	a5,0x7
    80000802:	0b27a323          	sw	s2,166(a5) # 800078a4 <panicking>
  printk("panic: ");
    80000806:	00007517          	auipc	a0,0x7
    8000080a:	81250513          	addi	a0,a0,-2030 # 80007018 <etext+0x18>
    8000080e:	cfdff0ef          	jal	8000050a <printk>
  printk("%s\n", s);
    80000812:	85a6                	mv	a1,s1
    80000814:	00007517          	auipc	a0,0x7
    80000818:	80c50513          	addi	a0,a0,-2036 # 80007020 <etext+0x20>
    8000081c:	cefff0ef          	jal	8000050a <printk>
  panicked = 1; // freeze uart output from other CPUs
    80000820:	00007797          	auipc	a5,0x7
    80000824:	0927a023          	sw	s2,128(a5) # 800078a0 <panicked>
  for (;;)
    80000828:	a001                	j	80000828 <panic+0x3a>

000000008000082a <printkinit>:
    ;
}

void
printkinit(void)
{
    8000082a:	1141                	addi	sp,sp,-16
    8000082c:	e406                	sd	ra,8(sp)
    8000082e:	e022                	sd	s0,0(sp)
    80000830:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000832:	00006597          	auipc	a1,0x6
    80000836:	7f658593          	addi	a1,a1,2038 # 80007028 <etext+0x28>
    8000083a:	0000f517          	auipc	a0,0xf
    8000083e:	13e50513          	addi	a0,a0,318 # 8000f978 <pr>
    80000842:	2d0000ef          	jal	80000b12 <initlock>
}
    80000846:	60a2                	ld	ra,8(sp)
    80000848:	6402                	ld	s0,0(sp)
    8000084a:	0141                	addi	sp,sp,16
    8000084c:	8082                	ret

000000008000084e <uartinit>:
extern volatile int panicking; // from printk.c
extern volatile int panicked;  // from printk.c

void
uartinit(void)
{
    8000084e:	1141                	addi	sp,sp,-16
    80000850:	e406                	sd	ra,8(sp)
    80000852:	e022                	sd	s0,0(sp)
    80000854:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000856:	100007b7          	lui	a5,0x10000
    8000085a:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000085e:	10000737          	lui	a4,0x10000
    80000862:	f8000693          	li	a3,-128
    80000866:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000086a:	468d                	li	a3,3
    8000086c:	10000637          	lui	a2,0x10000
    80000870:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000874:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000878:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000087c:	8732                	mv	a4,a2
    8000087e:	461d                	li	a2,7
    80000880:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000884:	00d780a3          	sb	a3,1(a5)

  initsleeplock(&tx_lock, "uart");
    80000888:	00006597          	auipc	a1,0x6
    8000088c:	7a858593          	addi	a1,a1,1960 # 80007030 <etext+0x30>
    80000890:	0000f517          	auipc	a0,0xf
    80000894:	10050513          	addi	a0,a0,256 # 8000f990 <tx_lock>
    80000898:	0cd030ef          	jal	80004164 <initsleeplock>
}
    8000089c:	60a2                	ld	ra,8(sp)
    8000089e:	6402                	ld	s0,0(sp)
    800008a0:	0141                	addi	sp,sp,16
    800008a2:	8082                	ret

00000000800008a4 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008a4:	7139                	addi	sp,sp,-64
    800008a6:	fc06                	sd	ra,56(sp)
    800008a8:	f822                	sd	s0,48(sp)
    800008aa:	f04a                	sd	s2,32(sp)
    800008ac:	e456                	sd	s5,8(sp)
    800008ae:	0080                	addi	s0,sp,64
    800008b0:	8aaa                	mv	s5,a0
    800008b2:	892e                	mv	s2,a1
  acquiresleep(&tx_lock);
    800008b4:	0000f517          	auipc	a0,0xf
    800008b8:	0dc50513          	addi	a0,a0,220 # 8000f990 <tx_lock>
    800008bc:	0df030ef          	jal	8000419a <acquiresleep>

  int i = 0;
  while (i < n) {
    800008c0:	05205963          	blez	s2,80000912 <uartwrite+0x6e>
    800008c4:	f426                	sd	s1,40(sp)
    800008c6:	ec4e                	sd	s3,24(sp)
    800008c8:	e852                	sd	s4,16(sp)
    800008ca:	e05a                	sd	s6,0(sp)
  int i = 0;
    800008cc:	4481                	li	s1,0
    sleep_prepare(&tx_chan);
    800008ce:	00007a17          	auipc	s4,0x7
    800008d2:	fdaa0a13          	addi	s4,s4,-38 # 800078a8 <tx_chan>
    if (ReadReg(LSR) & LSR_TX_IDLE) {
    800008d6:	100009b7          	lui	s3,0x10000
    800008da:	0995                	addi	s3,s3,5 # 10000005 <_entry-0x6ffffffb>
      WriteReg(THR, buf[i]);
    800008dc:	10000b37          	lui	s6,0x10000
    800008e0:	a029                	j	800008ea <uartwrite+0x46>
      i += 1;
    } else {
      sleep();
    800008e2:	762010ef          	jal	80002044 <sleep>
  while (i < n) {
    800008e6:	0324d263          	bge	s1,s2,8000090a <uartwrite+0x66>
    sleep_prepare(&tx_chan);
    800008ea:	8552                	mv	a0,s4
    800008ec:	71c010ef          	jal	80002008 <sleep_prepare>
    if (ReadReg(LSR) & LSR_TX_IDLE) {
    800008f0:	0009c783          	lbu	a5,0(s3)
    800008f4:	0207f793          	andi	a5,a5,32
    800008f8:	d7ed                	beqz	a5,800008e2 <uartwrite+0x3e>
      WriteReg(THR, buf[i]);
    800008fa:	009a87b3          	add	a5,s5,s1
    800008fe:	0007c783          	lbu	a5,0(a5)
    80000902:	00fb0023          	sb	a5,0(s6) # 10000000 <_entry-0x70000000>
      i += 1;
    80000906:	2485                	addiw	s1,s1,1
    80000908:	bff9                	j	800008e6 <uartwrite+0x42>
    8000090a:	74a2                	ld	s1,40(sp)
    8000090c:	69e2                	ld	s3,24(sp)
    8000090e:	6a42                	ld	s4,16(sp)
    80000910:	6b02                	ld	s6,0(sp)
    }
  }

  releasesleep(&tx_lock);
    80000912:	0000f517          	auipc	a0,0xf
    80000916:	07e50513          	addi	a0,a0,126 # 8000f990 <tx_lock>
    8000091a:	0d5030ef          	jal	800041ee <releasesleep>
}
    8000091e:	70e2                	ld	ra,56(sp)
    80000920:	7442                	ld	s0,48(sp)
    80000922:	7902                	ld	s2,32(sp)
    80000924:	6aa2                	ld	s5,8(sp)
    80000926:	6121                	addi	sp,sp,64
    80000928:	8082                	ret

000000008000092a <uartputc_sync>:
// interrupts, for use by kernel printk() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000092a:	1101                	addi	sp,sp,-32
    8000092c:	ec06                	sd	ra,24(sp)
    8000092e:	e822                	sd	s0,16(sp)
    80000930:	e426                	sd	s1,8(sp)
    80000932:	1000                	addi	s0,sp,32
    80000934:	84aa                	mv	s1,a0
  if (panicking == 0)
    80000936:	00007797          	auipc	a5,0x7
    8000093a:	f6e7a783          	lw	a5,-146(a5) # 800078a4 <panicking>
    8000093e:	cf95                	beqz	a5,8000097a <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    80000940:	00007797          	auipc	a5,0x7
    80000944:	f607a783          	lw	a5,-160(a5) # 800078a0 <panicked>
    80000948:	ef85                	bnez	a5,80000980 <uartputc_sync+0x56>
    for (;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while ((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000094a:	10000737          	lui	a4,0x10000
    8000094e:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000950:	00074783          	lbu	a5,0(a4)
    80000954:	0207f793          	andi	a5,a5,32
    80000958:	dfe5                	beqz	a5,80000950 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000095a:	0ff4f513          	zext.b	a0,s1
    8000095e:	100007b7          	lui	a5,0x10000
    80000962:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if (panicking == 0)
    80000966:	00007797          	auipc	a5,0x7
    8000096a:	f3e7a783          	lw	a5,-194(a5) # 800078a4 <panicking>
    8000096e:	cb91                	beqz	a5,80000982 <uartputc_sync+0x58>
    pop_off();
}
    80000970:	60e2                	ld	ra,24(sp)
    80000972:	6442                	ld	s0,16(sp)
    80000974:	64a2                	ld	s1,8(sp)
    80000976:	6105                	addi	sp,sp,32
    80000978:	8082                	ret
    push_off();
    8000097a:	1dc000ef          	jal	80000b56 <push_off>
    8000097e:	b7c9                	j	80000940 <uartputc_sync+0x16>
    for (;;)
    80000980:	a001                	j	80000980 <uartputc_sync+0x56>
    pop_off();
    80000982:	24a000ef          	jal	80000bcc <pop_off>
}
    80000986:	b7ed                	j	80000970 <uartputc_sync+0x46>

0000000080000988 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000988:	1101                	addi	sp,sp,-32
    8000098a:	ec06                	sd	ra,24(sp)
    8000098c:	e822                	sd	s0,16(sp)
    8000098e:	e426                	sd	s1,8(sp)
    80000990:	e04a                	sd	s2,0(sp)
    80000992:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    80000994:	100007b7          	lui	a5,0x10000
    80000998:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>

  if (ReadReg(LSR) & LSR_TX_IDLE) {
    8000099c:	100007b7          	lui	a5,0x10000
    800009a0:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009a4:	0207f793          	andi	a5,a5,32
    800009a8:	ef99                	bnez	a5,800009c6 <uartintr+0x3e>
  if (ReadReg(LSR) & LSR_RX_READY) {
    800009aa:	100004b7          	lui	s1,0x10000
    800009ae:	0495                	addi	s1,s1,5 # 10000005 <_entry-0x6ffffffb>
    return ReadReg(RHR);
    800009b0:	10000937          	lui	s2,0x10000
  if (ReadReg(LSR) & LSR_RX_READY) {
    800009b4:	0004c783          	lbu	a5,0(s1)
    800009b8:	8b85                	andi	a5,a5,1
    800009ba:	cf89                	beqz	a5,800009d4 <uartintr+0x4c>
    return ReadReg(RHR);
    800009bc:	00094503          	lbu	a0,0(s2) # 10000000 <_entry-0x70000000>
  // read and process incoming characters, if any.
  while (1) {
    int c = uartgetc();
    if (c == -1)
      break;
    consoleintr(c);
    800009c0:	8fdff0ef          	jal	800002bc <consoleintr>
  while (1) {
    800009c4:	bfc5                	j	800009b4 <uartintr+0x2c>
    wakeup(&tx_chan);
    800009c6:	00007517          	auipc	a0,0x7
    800009ca:	ee250513          	addi	a0,a0,-286 # 800078a8 <tx_chan>
    800009ce:	6a6010ef          	jal	80002074 <wakeup>
    800009d2:	bfe1                	j	800009aa <uartintr+0x22>
  }
}
    800009d4:	60e2                	ld	ra,24(sp)
    800009d6:	6442                	ld	s0,16(sp)
    800009d8:	64a2                	ld	s1,8(sp)
    800009da:	6902                	ld	s2,0(sp)
    800009dc:	6105                	addi	sp,sp,32
    800009de:	8082                	ret

00000000800009e0 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e0:	1101                	addi	sp,sp,-32
    800009e2:	ec06                	sd	ra,24(sp)
    800009e4:	e822                	sd	s0,16(sp)
    800009e6:	e426                	sd	s1,8(sp)
    800009e8:	e04a                	sd	s2,0(sp)
    800009ea:	1000                	addi	s0,sp,32
  struct run *r;

  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    800009ec:	03451793          	slli	a5,a0,0x34
    800009f0:	e7a9                	bnez	a5,80000a3a <kfree+0x5a>
    800009f2:	84aa                	mv	s1,a0
    800009f4:	00020797          	auipc	a5,0x20
    800009f8:	3fc78793          	addi	a5,a5,1020 # 80020df0 <end>
    800009fc:	02f56f63          	bltu	a0,a5,80000a3a <kfree+0x5a>
    80000a00:	47c5                	li	a5,17
    80000a02:	07ee                	slli	a5,a5,0x1b
    80000a04:	02f57b63          	bgeu	a0,a5,80000a3a <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a08:	6605                	lui	a2,0x1
    80000a0a:	4585                	li	a1,1
    80000a0c:	240000ef          	jal	80000c4c <memset>

  r = (struct run *)pa;

  acquire(&kmem.lock);
    80000a10:	0000f917          	auipc	s2,0xf
    80000a14:	fb090913          	addi	s2,s2,-80 # 8000f9c0 <kmem>
    80000a18:	854a                	mv	a0,s2
    80000a1a:	172000ef          	jal	80000b8c <acquire>
  r->next = kmem.freelist;
    80000a1e:	01893783          	ld	a5,24(s2)
    80000a22:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a24:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a28:	854a                	mv	a0,s2
    80000a2a:	1ea000ef          	jal	80000c14 <release>
}
    80000a2e:	60e2                	ld	ra,24(sp)
    80000a30:	6442                	ld	s0,16(sp)
    80000a32:	64a2                	ld	s1,8(sp)
    80000a34:	6902                	ld	s2,0(sp)
    80000a36:	6105                	addi	sp,sp,32
    80000a38:	8082                	ret
    panic("kfree");
    80000a3a:	00006517          	auipc	a0,0x6
    80000a3e:	5fe50513          	addi	a0,a0,1534 # 80007038 <etext+0x38>
    80000a42:	dadff0ef          	jal	800007ee <panic>

0000000080000a46 <freerange>:
{
    80000a46:	7179                	addi	sp,sp,-48
    80000a48:	f406                	sd	ra,40(sp)
    80000a4a:	f022                	sd	s0,32(sp)
    80000a4c:	ec26                	sd	s1,24(sp)
    80000a4e:	1800                	addi	s0,sp,48
  p = (char *)PGROUNDUP((uint64)pa_start);
    80000a50:	6785                	lui	a5,0x1
    80000a52:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a56:	00e504b3          	add	s1,a0,a4
    80000a5a:	777d                	lui	a4,0xfffff
    80000a5c:	8cf9                	and	s1,s1,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a5e:	94be                	add	s1,s1,a5
    80000a60:	0295e263          	bltu	a1,s1,80000a84 <freerange+0x3e>
    80000a64:	e84a                	sd	s2,16(sp)
    80000a66:	e44e                	sd	s3,8(sp)
    80000a68:	e052                	sd	s4,0(sp)
    80000a6a:	892e                	mv	s2,a1
    kfree(p);
    80000a6c:	8a3a                	mv	s4,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a6e:	89be                	mv	s3,a5
    kfree(p);
    80000a70:	01448533          	add	a0,s1,s4
    80000a74:	f6dff0ef          	jal	800009e0 <kfree>
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a78:	94ce                	add	s1,s1,s3
    80000a7a:	fe997be3          	bgeu	s2,s1,80000a70 <freerange+0x2a>
    80000a7e:	6942                	ld	s2,16(sp)
    80000a80:	69a2                	ld	s3,8(sp)
    80000a82:	6a02                	ld	s4,0(sp)
}
    80000a84:	70a2                	ld	ra,40(sp)
    80000a86:	7402                	ld	s0,32(sp)
    80000a88:	64e2                	ld	s1,24(sp)
    80000a8a:	6145                	addi	sp,sp,48
    80000a8c:	8082                	ret

0000000080000a8e <kinit>:
{
    80000a8e:	1141                	addi	sp,sp,-16
    80000a90:	e406                	sd	ra,8(sp)
    80000a92:	e022                	sd	s0,0(sp)
    80000a94:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a96:	00006597          	auipc	a1,0x6
    80000a9a:	5aa58593          	addi	a1,a1,1450 # 80007040 <etext+0x40>
    80000a9e:	0000f517          	auipc	a0,0xf
    80000aa2:	f2250513          	addi	a0,a0,-222 # 8000f9c0 <kmem>
    80000aa6:	06c000ef          	jal	80000b12 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000aaa:	45c5                	li	a1,17
    80000aac:	05ee                	slli	a1,a1,0x1b
    80000aae:	00020517          	auipc	a0,0x20
    80000ab2:	34250513          	addi	a0,a0,834 # 80020df0 <end>
    80000ab6:	f91ff0ef          	jal	80000a46 <freerange>
}
    80000aba:	60a2                	ld	ra,8(sp)
    80000abc:	6402                	ld	s0,0(sp)
    80000abe:	0141                	addi	sp,sp,16
    80000ac0:	8082                	ret

0000000080000ac2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ac2:	1101                	addi	sp,sp,-32
    80000ac4:	ec06                	sd	ra,24(sp)
    80000ac6:	e822                	sd	s0,16(sp)
    80000ac8:	e426                	sd	s1,8(sp)
    80000aca:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000acc:	0000f497          	auipc	s1,0xf
    80000ad0:	ef448493          	addi	s1,s1,-268 # 8000f9c0 <kmem>
    80000ad4:	8526                	mv	a0,s1
    80000ad6:	0b6000ef          	jal	80000b8c <acquire>
  r = kmem.freelist;
    80000ada:	6c84                	ld	s1,24(s1)
  if (r)
    80000adc:	c485                	beqz	s1,80000b04 <kalloc+0x42>
    kmem.freelist = r->next;
    80000ade:	609c                	ld	a5,0(s1)
    80000ae0:	0000f517          	auipc	a0,0xf
    80000ae4:	ee050513          	addi	a0,a0,-288 # 8000f9c0 <kmem>
    80000ae8:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000aea:	12a000ef          	jal	80000c14 <release>

  if (r)
    memset((char *)r, 5, PGSIZE); // fill with junk
    80000aee:	6605                	lui	a2,0x1
    80000af0:	4595                	li	a1,5
    80000af2:	8526                	mv	a0,s1
    80000af4:	158000ef          	jal	80000c4c <memset>
  return (void *)r;
}
    80000af8:	8526                	mv	a0,s1
    80000afa:	60e2                	ld	ra,24(sp)
    80000afc:	6442                	ld	s0,16(sp)
    80000afe:	64a2                	ld	s1,8(sp)
    80000b00:	6105                	addi	sp,sp,32
    80000b02:	8082                	ret
  release(&kmem.lock);
    80000b04:	0000f517          	auipc	a0,0xf
    80000b08:	ebc50513          	addi	a0,a0,-324 # 8000f9c0 <kmem>
    80000b0c:	108000ef          	jal	80000c14 <release>
  if (r)
    80000b10:	b7e5                	j	80000af8 <kalloc+0x36>

0000000080000b12 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b12:	1141                	addi	sp,sp,-16
    80000b14:	e406                	sd	ra,8(sp)
    80000b16:	e022                	sd	s0,0(sp)
    80000b18:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b1a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b1c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b20:	00053823          	sd	zero,16(a0)
}
    80000b24:	60a2                	ld	ra,8(sp)
    80000b26:	6402                	ld	s0,0(sp)
    80000b28:	0141                	addi	sp,sp,16
    80000b2a:	8082                	ret

0000000080000b2c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b2c:	411c                	lw	a5,0(a0)
    80000b2e:	e399                	bnez	a5,80000b34 <holding+0x8>
    80000b30:	4501                	li	a0,0
  return r;
}
    80000b32:	8082                	ret
{
    80000b34:	1101                	addi	sp,sp,-32
    80000b36:	ec06                	sd	ra,24(sp)
    80000b38:	e822                	sd	s0,16(sp)
    80000b3a:	e426                	sd	s1,8(sp)
    80000b3c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b3e:	6904                	ld	s1,16(a0)
    80000b40:	61f000ef          	jal	8000195e <mycpu>
    80000b44:	40a48533          	sub	a0,s1,a0
    80000b48:	00153513          	seqz	a0,a0
}
    80000b4c:	60e2                	ld	ra,24(sp)
    80000b4e:	6442                	ld	s0,16(sp)
    80000b50:	64a2                	ld	s1,8(sp)
    80000b52:	6105                	addi	sp,sp,32
    80000b54:	8082                	ret

0000000080000b56 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b56:	1101                	addi	sp,sp,-32
    80000b58:	ec06                	sd	ra,24(sp)
    80000b5a:	e822                	sd	s0,16(sp)
    80000b5c:	e426                	sd	s1,8(sp)
    80000b5e:	1000                	addi	s0,sp,32
  __asm__ __volatile__("csrrc %0, sstatus, %1" : "=r"(x) : "rK"(x) : "memory");
    80000b60:	100174f3          	csrrci	s1,sstatus,2
  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  uint64 flags = rc_sstatus(SSTATUS_SIE);
  int old = !!(flags & SSTATUS_SIE);

  if (mycpu()->noff == 0)
    80000b64:	5fb000ef          	jal	8000195e <mycpu>
    80000b68:	5d3c                	lw	a5,120(a0)
    80000b6a:	cb99                	beqz	a5,80000b80 <push_off+0x2a>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b6c:	5f3000ef          	jal	8000195e <mycpu>
    80000b70:	5d3c                	lw	a5,120(a0)
    80000b72:	2785                	addiw	a5,a5,1
    80000b74:	dd3c                	sw	a5,120(a0)
}
    80000b76:	60e2                	ld	ra,24(sp)
    80000b78:	6442                	ld	s0,16(sp)
    80000b7a:	64a2                	ld	s1,8(sp)
    80000b7c:	6105                	addi	sp,sp,32
    80000b7e:	8082                	ret
    mycpu()->intena = old;
    80000b80:	5df000ef          	jal	8000195e <mycpu>
  int old = !!(flags & SSTATUS_SIE);
    80000b84:	8085                	srli	s1,s1,0x1
    80000b86:	8885                	andi	s1,s1,1
    mycpu()->intena = old;
    80000b88:	dd64                	sw	s1,124(a0)
    80000b8a:	b7cd                	j	80000b6c <push_off+0x16>

0000000080000b8c <acquire>:
{
    80000b8c:	1101                	addi	sp,sp,-32
    80000b8e:	ec06                	sd	ra,24(sp)
    80000b90:	e822                	sd	s0,16(sp)
    80000b92:	e426                	sd	s1,8(sp)
    80000b94:	1000                	addi	s0,sp,32
    80000b96:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000b98:	fbfff0ef          	jal	80000b56 <push_off>
  if (holding(lk))
    80000b9c:	8526                	mv	a0,s1
    80000b9e:	f8fff0ef          	jal	80000b2c <holding>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000ba2:	4705                	li	a4,1
  if (holding(lk))
    80000ba4:	ed11                	bnez	a0,80000bc0 <acquire+0x34>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000ba6:	87ba                	mv	a5,a4
    80000ba8:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bac:	2781                	sext.w	a5,a5
    80000bae:	ffe5                	bnez	a5,80000ba6 <acquire+0x1a>
  lk->cpu = mycpu();
    80000bb0:	5af000ef          	jal	8000195e <mycpu>
    80000bb4:	e888                	sd	a0,16(s1)
}
    80000bb6:	60e2                	ld	ra,24(sp)
    80000bb8:	6442                	ld	s0,16(sp)
    80000bba:	64a2                	ld	s1,8(sp)
    80000bbc:	6105                	addi	sp,sp,32
    80000bbe:	8082                	ret
    panic("acquire");
    80000bc0:	00006517          	auipc	a0,0x6
    80000bc4:	48850513          	addi	a0,a0,1160 # 80007048 <etext+0x48>
    80000bc8:	c27ff0ef          	jal	800007ee <panic>

0000000080000bcc <pop_off>:

void
pop_off(void)
{
    80000bcc:	1141                	addi	sp,sp,-16
    80000bce:	e406                	sd	ra,8(sp)
    80000bd0:	e022                	sd	s0,0(sp)
    80000bd2:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000bd4:	58b000ef          	jal	8000195e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000bd8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000bdc:	8b89                	andi	a5,a5,2
  if (intr_get())
    80000bde:	ef99                	bnez	a5,80000bfc <pop_off+0x30>
    panic("pop_off - interruptible");
  if (c->noff < 1)
    80000be0:	5d3c                	lw	a5,120(a0)
    80000be2:	02f05363          	blez	a5,80000c08 <pop_off+0x3c>
    panic("pop_off");
  c->noff -= 1;
    80000be6:	37fd                	addiw	a5,a5,-1
    80000be8:	dd3c                	sw	a5,120(a0)
  if (c->noff == 0 && c->intena)
    80000bea:	e789                	bnez	a5,80000bf4 <pop_off+0x28>
    80000bec:	5d7c                	lw	a5,124(a0)
    80000bee:	c399                	beqz	a5,80000bf4 <pop_off+0x28>
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80000bf0:	10016073          	csrsi	sstatus,2
    intr_on();
}
    80000bf4:	60a2                	ld	ra,8(sp)
    80000bf6:	6402                	ld	s0,0(sp)
    80000bf8:	0141                	addi	sp,sp,16
    80000bfa:	8082                	ret
    panic("pop_off - interruptible");
    80000bfc:	00006517          	auipc	a0,0x6
    80000c00:	45450513          	addi	a0,a0,1108 # 80007050 <etext+0x50>
    80000c04:	bebff0ef          	jal	800007ee <panic>
    panic("pop_off");
    80000c08:	00006517          	auipc	a0,0x6
    80000c0c:	46050513          	addi	a0,a0,1120 # 80007068 <etext+0x68>
    80000c10:	bdfff0ef          	jal	800007ee <panic>

0000000080000c14 <release>:
{
    80000c14:	1101                	addi	sp,sp,-32
    80000c16:	ec06                	sd	ra,24(sp)
    80000c18:	e822                	sd	s0,16(sp)
    80000c1a:	e426                	sd	s1,8(sp)
    80000c1c:	1000                	addi	s0,sp,32
    80000c1e:	84aa                	mv	s1,a0
  if (!holding(lk))
    80000c20:	f0dff0ef          	jal	80000b2c <holding>
    80000c24:	cd11                	beqz	a0,80000c40 <release+0x2c>
  lk->cpu = 0;
    80000c26:	0004b823          	sd	zero,16(s1)
  __atomic_store_n(&lk->locked, 0, __ATOMIC_RELEASE);
    80000c2a:	0310000f          	fence	rw,w
    80000c2e:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000c32:	f9bff0ef          	jal	80000bcc <pop_off>
}
    80000c36:	60e2                	ld	ra,24(sp)
    80000c38:	6442                	ld	s0,16(sp)
    80000c3a:	64a2                	ld	s1,8(sp)
    80000c3c:	6105                	addi	sp,sp,32
    80000c3e:	8082                	ret
    panic("release");
    80000c40:	00006517          	auipc	a0,0x6
    80000c44:	43050513          	addi	a0,a0,1072 # 80007070 <etext+0x70>
    80000c48:	ba7ff0ef          	jal	800007ee <panic>

0000000080000c4c <memset>:
#include "types.h"

void *
memset(void *dst, int c, uint n)
{
    80000c4c:	1141                	addi	sp,sp,-16
    80000c4e:	e406                	sd	ra,8(sp)
    80000c50:	e022                	sd	s0,0(sp)
    80000c52:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
    80000c54:	ca19                	beqz	a2,80000c6a <memset+0x1e>
    80000c56:	87aa                	mv	a5,a0
    80000c58:	1602                	slli	a2,a2,0x20
    80000c5a:	9201                	srli	a2,a2,0x20
    80000c5c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000c60:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
    80000c64:	0785                	addi	a5,a5,1
    80000c66:	fee79de3          	bne	a5,a4,80000c60 <memset+0x14>
  }
  return dst;
}
    80000c6a:	60a2                	ld	ra,8(sp)
    80000c6c:	6402                	ld	s0,0(sp)
    80000c6e:	0141                	addi	sp,sp,16
    80000c70:	8082                	ret

0000000080000c72 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000c72:	1141                	addi	sp,sp,-16
    80000c74:	e406                	sd	ra,8(sp)
    80000c76:	e022                	sd	s0,0(sp)
    80000c78:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while (n-- > 0) {
    80000c7a:	ca0d                	beqz	a2,80000cac <memcmp+0x3a>
    80000c7c:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000c80:	1682                	slli	a3,a3,0x20
    80000c82:	9281                	srli	a3,a3,0x20
    80000c84:	0685                	addi	a3,a3,1
    80000c86:	96aa                	add	a3,a3,a0
    if (*s1 != *s2)
    80000c88:	00054783          	lbu	a5,0(a0)
    80000c8c:	0005c703          	lbu	a4,0(a1)
    80000c90:	00e79863          	bne	a5,a4,80000ca0 <memcmp+0x2e>
      return *s1 - *s2;
    s1++, s2++;
    80000c94:	0505                	addi	a0,a0,1
    80000c96:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    80000c98:	fed518e3          	bne	a0,a3,80000c88 <memcmp+0x16>
  }

  return 0;
    80000c9c:	4501                	li	a0,0
    80000c9e:	a019                	j	80000ca4 <memcmp+0x32>
      return *s1 - *s2;
    80000ca0:	40e7853b          	subw	a0,a5,a4
}
    80000ca4:	60a2                	ld	ra,8(sp)
    80000ca6:	6402                	ld	s0,0(sp)
    80000ca8:	0141                	addi	sp,sp,16
    80000caa:	8082                	ret
  return 0;
    80000cac:	4501                	li	a0,0
    80000cae:	bfdd                	j	80000ca4 <memcmp+0x32>

0000000080000cb0 <memmove>:

void *
memmove(void *dst, const void *src, uint n)
{
    80000cb0:	1141                	addi	sp,sp,-16
    80000cb2:	e406                	sd	ra,8(sp)
    80000cb4:	e022                	sd	s0,0(sp)
    80000cb6:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if (n == 0)
    80000cb8:	c205                	beqz	a2,80000cd8 <memmove+0x28>
    return dst;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
    80000cba:	02a5e363          	bltu	a1,a0,80000ce0 <memmove+0x30>
    s += n;
    d += n;
    while (n-- > 0)
      *--d = *--s;
  } else
    while (n-- > 0)
    80000cbe:	1602                	slli	a2,a2,0x20
    80000cc0:	9201                	srli	a2,a2,0x20
    80000cc2:	00c587b3          	add	a5,a1,a2
{
    80000cc6:	872a                	mv	a4,a0
      *d++ = *s++;
    80000cc8:	0585                	addi	a1,a1,1
    80000cca:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffde211>
    80000ccc:	fff5c683          	lbu	a3,-1(a1)
    80000cd0:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
    80000cd4:	feb79ae3          	bne	a5,a1,80000cc8 <memmove+0x18>

  return dst;
}
    80000cd8:	60a2                	ld	ra,8(sp)
    80000cda:	6402                	ld	s0,0(sp)
    80000cdc:	0141                	addi	sp,sp,16
    80000cde:	8082                	ret
  if (s < d && s + n > d) {
    80000ce0:	02061693          	slli	a3,a2,0x20
    80000ce4:	9281                	srli	a3,a3,0x20
    80000ce6:	00d58733          	add	a4,a1,a3
    80000cea:	fce57ae3          	bgeu	a0,a4,80000cbe <memmove+0xe>
    d += n;
    80000cee:	96aa                	add	a3,a3,a0
    while (n-- > 0)
    80000cf0:	fff6079b          	addiw	a5,a2,-1
    80000cf4:	1782                	slli	a5,a5,0x20
    80000cf6:	9381                	srli	a5,a5,0x20
    80000cf8:	fff7c793          	not	a5,a5
    80000cfc:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000cfe:	177d                	addi	a4,a4,-1
    80000d00:	16fd                	addi	a3,a3,-1
    80000d02:	00074603          	lbu	a2,0(a4)
    80000d06:	00c68023          	sb	a2,0(a3)
    while (n-- > 0)
    80000d0a:	fee79ae3          	bne	a5,a4,80000cfe <memmove+0x4e>
    80000d0e:	b7e9                	j	80000cd8 <memmove+0x28>

0000000080000d10 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void *
memcpy(void *dst, const void *src, uint n)
{
    80000d10:	1141                	addi	sp,sp,-16
    80000d12:	e406                	sd	ra,8(sp)
    80000d14:	e022                	sd	s0,0(sp)
    80000d16:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d18:	f99ff0ef          	jal	80000cb0 <memmove>
}
    80000d1c:	60a2                	ld	ra,8(sp)
    80000d1e:	6402                	ld	s0,0(sp)
    80000d20:	0141                	addi	sp,sp,16
    80000d22:	8082                	ret

0000000080000d24 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d24:	1141                	addi	sp,sp,-16
    80000d26:	e406                	sd	ra,8(sp)
    80000d28:	e022                	sd	s0,0(sp)
    80000d2a:	0800                	addi	s0,sp,16
  while (n > 0 && *p && *p == *q)
    80000d2c:	ce11                	beqz	a2,80000d48 <strncmp+0x24>
    80000d2e:	00054783          	lbu	a5,0(a0)
    80000d32:	cf89                	beqz	a5,80000d4c <strncmp+0x28>
    80000d34:	0005c703          	lbu	a4,0(a1)
    80000d38:	00f71a63          	bne	a4,a5,80000d4c <strncmp+0x28>
    n--, p++, q++;
    80000d3c:	367d                	addiw	a2,a2,-1
    80000d3e:	0505                	addi	a0,a0,1
    80000d40:	0585                	addi	a1,a1,1
  while (n > 0 && *p && *p == *q)
    80000d42:	f675                	bnez	a2,80000d2e <strncmp+0xa>
  if (n == 0)
    return 0;
    80000d44:	4501                	li	a0,0
    80000d46:	a801                	j	80000d56 <strncmp+0x32>
    80000d48:	4501                	li	a0,0
    80000d4a:	a031                	j	80000d56 <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000d4c:	00054503          	lbu	a0,0(a0)
    80000d50:	0005c783          	lbu	a5,0(a1)
    80000d54:	9d1d                	subw	a0,a0,a5
}
    80000d56:	60a2                	ld	ra,8(sp)
    80000d58:	6402                	ld	s0,0(sp)
    80000d5a:	0141                	addi	sp,sp,16
    80000d5c:	8082                	ret

0000000080000d5e <strncpy>:

char *
strncpy(char *s, const char *t, int n)
{
    80000d5e:	1141                	addi	sp,sp,-16
    80000d60:	e406                	sd	ra,8(sp)
    80000d62:	e022                	sd	s0,0(sp)
    80000d64:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while (n-- > 0 && (*s++ = *t++) != 0)
    80000d66:	87aa                	mv	a5,a0
    80000d68:	86b2                	mv	a3,a2
    80000d6a:	367d                	addiw	a2,a2,-1
    80000d6c:	02d05563          	blez	a3,80000d96 <strncpy+0x38>
    80000d70:	0785                	addi	a5,a5,1
    80000d72:	0005c703          	lbu	a4,0(a1)
    80000d76:	fee78fa3          	sb	a4,-1(a5)
    80000d7a:	0585                	addi	a1,a1,1
    80000d7c:	f775                	bnez	a4,80000d68 <strncpy+0xa>
    ;
  while (n-- > 0)
    80000d7e:	873e                	mv	a4,a5
    80000d80:	00c05b63          	blez	a2,80000d96 <strncpy+0x38>
    80000d84:	9fb5                	addw	a5,a5,a3
    80000d86:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000d88:	0705                	addi	a4,a4,1
    80000d8a:	fe070fa3          	sb	zero,-1(a4)
  while (n-- > 0)
    80000d8e:	40e786bb          	subw	a3,a5,a4
    80000d92:	fed04be3          	bgtz	a3,80000d88 <strncpy+0x2a>
  return os;
}
    80000d96:	60a2                	ld	ra,8(sp)
    80000d98:	6402                	ld	s0,0(sp)
    80000d9a:	0141                	addi	sp,sp,16
    80000d9c:	8082                	ret

0000000080000d9e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char *
safestrcpy(char *s, const char *t, int n)
{
    80000d9e:	1141                	addi	sp,sp,-16
    80000da0:	e406                	sd	ra,8(sp)
    80000da2:	e022                	sd	s0,0(sp)
    80000da4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if (n <= 0)
    80000da6:	02c05363          	blez	a2,80000dcc <safestrcpy+0x2e>
    80000daa:	fff6069b          	addiw	a3,a2,-1
    80000dae:	1682                	slli	a3,a3,0x20
    80000db0:	9281                	srli	a3,a3,0x20
    80000db2:	96ae                	add	a3,a3,a1
    80000db4:	87aa                	mv	a5,a0
    return os;
  while (--n > 0 && (*s++ = *t++) != 0)
    80000db6:	00d58963          	beq	a1,a3,80000dc8 <safestrcpy+0x2a>
    80000dba:	0585                	addi	a1,a1,1
    80000dbc:	0785                	addi	a5,a5,1
    80000dbe:	fff5c703          	lbu	a4,-1(a1)
    80000dc2:	fee78fa3          	sb	a4,-1(a5)
    80000dc6:	fb65                	bnez	a4,80000db6 <safestrcpy+0x18>
    ;
  *s = 0;
    80000dc8:	00078023          	sb	zero,0(a5)
  return os;
}
    80000dcc:	60a2                	ld	ra,8(sp)
    80000dce:	6402                	ld	s0,0(sp)
    80000dd0:	0141                	addi	sp,sp,16
    80000dd2:	8082                	ret

0000000080000dd4 <strlen>:

int
strlen(const char *s)
{
    80000dd4:	1141                	addi	sp,sp,-16
    80000dd6:	e406                	sd	ra,8(sp)
    80000dd8:	e022                	sd	s0,0(sp)
    80000dda:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
    80000ddc:	00054783          	lbu	a5,0(a0)
    80000de0:	cf99                	beqz	a5,80000dfe <strlen+0x2a>
    80000de2:	0505                	addi	a0,a0,1
    80000de4:	87aa                	mv	a5,a0
    80000de6:	86be                	mv	a3,a5
    80000de8:	0785                	addi	a5,a5,1
    80000dea:	fff7c703          	lbu	a4,-1(a5)
    80000dee:	ff65                	bnez	a4,80000de6 <strlen+0x12>
    80000df0:	40a6853b          	subw	a0,a3,a0
    80000df4:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000df6:	60a2                	ld	ra,8(sp)
    80000df8:	6402                	ld	s0,0(sp)
    80000dfa:	0141                	addi	sp,sp,16
    80000dfc:	8082                	ret
  for (n = 0; s[n]; n++)
    80000dfe:	4501                	li	a0,0
    80000e00:	bfdd                	j	80000df6 <strlen+0x22>

0000000080000e02 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e02:	1141                	addi	sp,sp,-16
    80000e04:	e406                	sd	ra,8(sp)
    80000e06:	e022                	sd	s0,0(sp)
    80000e08:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80000e0a:	341000ef          	jal	8000194a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();         // first user process

    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
  } else {
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000e0e:	00007717          	auipc	a4,0x7
    80000e12:	a9e70713          	addi	a4,a4,-1378 # 800078ac <started>
  if (cpuid() == 0) {
    80000e16:	c51d                	beqz	a0,80000e44 <main+0x42>
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000e18:	431c                	lw	a5,0(a4)
    80000e1a:	0230000f          	fence	r,rw
    80000e1e:	2781                	sext.w	a5,a5
    80000e20:	dfe5                	beqz	a5,80000e18 <main+0x16>
      ;

    printk("hart %d starting\n", cpuid());
    80000e22:	329000ef          	jal	8000194a <cpuid>
    80000e26:	85aa                	mv	a1,a0
    80000e28:	00006517          	auipc	a0,0x6
    80000e2c:	27050513          	addi	a0,a0,624 # 80007098 <etext+0x98>
    80000e30:	edaff0ef          	jal	8000050a <printk>
    kvminithart();  // turn on paging
    80000e34:	138000ef          	jal	80000f6c <kvminithart>
    trapinithart(); // install kernel trap vector
    80000e38:	728010ef          	jal	80002560 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000e3c:	20d040ef          	jal	80005848 <plicinithart>
  }

  scheduler();
    80000e40:	02e010ef          	jal	80001e6e <scheduler>
    consoleinit();
    80000e44:	df8ff0ef          	jal	8000043c <consoleinit>
    printkinit();
    80000e48:	9e3ff0ef          	jal	8000082a <printkinit>
    printk("\n");
    80000e4c:	00006517          	auipc	a0,0x6
    80000e50:	22c50513          	addi	a0,a0,556 # 80007078 <etext+0x78>
    80000e54:	eb6ff0ef          	jal	8000050a <printk>
    printk("xv6 kernel is booting\n");
    80000e58:	00006517          	auipc	a0,0x6
    80000e5c:	22850513          	addi	a0,a0,552 # 80007080 <etext+0x80>
    80000e60:	eaaff0ef          	jal	8000050a <printk>
    printk("\n");
    80000e64:	00006517          	auipc	a0,0x6
    80000e68:	21450513          	addi	a0,a0,532 # 80007078 <etext+0x78>
    80000e6c:	e9eff0ef          	jal	8000050a <printk>
    kinit();            // physical page allocator
    80000e70:	c1fff0ef          	jal	80000a8e <kinit>
    kvminit();          // create kernel page table
    80000e74:	386000ef          	jal	800011fa <kvminit>
    kvminithart();      // turn on paging
    80000e78:	0f4000ef          	jal	80000f6c <kvminithart>
    procinit();         // process table
    80000e7c:	21f000ef          	jal	8000189a <procinit>
    trapinit();         // trap vectors
    80000e80:	6bc010ef          	jal	8000253c <trapinit>
    trapinithart();     // install kernel trap vector
    80000e84:	6dc010ef          	jal	80002560 <trapinithart>
    plicinit();         // set up interrupt controller
    80000e88:	1a7040ef          	jal	8000582e <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000e8c:	1bd040ef          	jal	80005848 <plicinithart>
    binit();            // buffer cache
    80000e90:	669010ef          	jal	80002cf8 <binit>
    iinit();            // inode table
    80000e94:	3c8020ef          	jal	8000325c <iinit>
    fileinit();         // file table
    80000e98:	3d8030ef          	jal	80004270 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000e9c:	29d040ef          	jal	80005938 <virtio_disk_init>
    userinit();         // first user process
    80000ea0:	623000ef          	jal	80001cc2 <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000ea4:	00007797          	auipc	a5,0x7
    80000ea8:	a0878793          	addi	a5,a5,-1528 # 800078ac <started>
    80000eac:	4705                	li	a4,1
    80000eae:	0310000f          	fence	rw,w
    80000eb2:	c398                	sw	a4,0(a5)
    80000eb4:	b771                	j	80000e40 <main+0x3e>

0000000080000eb6 <vmprint_rec>:

// Imprime recursivamente las PTEs válidas de una tabla de nivel level
// (2 = raíz). va es la dirección virtual donde empieza la tabla.
static void
vmprint_rec(pagetable_t pagetable, int level, uint64 va)
{
    80000eb6:	7159                	addi	sp,sp,-112
    80000eb8:	f486                	sd	ra,104(sp)
    80000eba:	f0a2                	sd	s0,96(sp)
    80000ebc:	eca6                	sd	s1,88(sp)
    80000ebe:	e8ca                	sd	s2,80(sp)
    80000ec0:	e4ce                	sd	s3,72(sp)
    80000ec2:	e0d2                	sd	s4,64(sp)
    80000ec4:	fc56                	sd	s5,56(sp)
    80000ec6:	f85a                	sd	s6,48(sp)
    80000ec8:	f45e                	sd	s7,40(sp)
    80000eca:	f062                	sd	s8,32(sp)
    80000ecc:	ec66                	sd	s9,24(sp)
    80000ece:	e86a                	sd	s10,16(sp)
    80000ed0:	e46e                	sd	s11,8(sp)
    80000ed2:	1880                	addi	s0,sp,112
    80000ed4:	89ae                	mv	s3,a1
    80000ed6:	8db2                	mv	s11,a2
  for (int i = 0; i < 512; i++) {
    pte_t pte = pagetable[i];
    if ((pte & PTE_V) == 0)
      continue;
    uint64 a = va + ((uint64)i << PXSHIFT(level));
    80000ed8:	00359d1b          	slliw	s10,a1,0x3
    80000edc:	00bd0d3b          	addw	s10,s10,a1
    80000ee0:	2d31                	addiw	s10,s10,12
    80000ee2:	8b2a                	mv	s6,a0
    80000ee4:	4a81                	li	s5,0
    for (int d = 2; d >= level; d--)
    80000ee6:	4c89                	li	s9,2
      printk(" ..");
    80000ee8:	00006a17          	auipc	s4,0x6
    80000eec:	1c8a0a13          	addi	s4,s4,456 # 800070b0 <etext+0xb0>
  for (int i = 0; i < 512; i++) {
    80000ef0:	20000c13          	li	s8,512
    80000ef4:	a029                	j	80000efe <vmprint_rec+0x48>
    80000ef6:	0a85                	addi	s5,s5,1
    80000ef8:	0b21                	addi	s6,s6,8
    80000efa:	058a8a63          	beq	s5,s8,80000f4e <vmprint_rec+0x98>
    pte_t pte = pagetable[i];
    80000efe:	000b3903          	ld	s2,0(s6)
    if ((pte & PTE_V) == 0)
    80000f02:	00197793          	andi	a5,s2,1
    80000f06:	dbe5                	beqz	a5,80000ef6 <vmprint_rec+0x40>
    uint64 a = va + ((uint64)i << PXSHIFT(level));
    80000f08:	01aa9bb3          	sll	s7,s5,s10
    80000f0c:	9bee                	add	s7,s7,s11
    for (int d = 2; d >= level; d--)
    80000f0e:	013cc963          	blt	s9,s3,80000f20 <vmprint_rec+0x6a>
    80000f12:	84e6                	mv	s1,s9
      printk(" ..");
    80000f14:	8552                	mv	a0,s4
    80000f16:	df4ff0ef          	jal	8000050a <printk>
    for (int d = 2; d >= level; d--)
    80000f1a:	34fd                	addiw	s1,s1,-1
    80000f1c:	ff34dce3          	bge	s1,s3,80000f14 <vmprint_rec+0x5e>
    printk("%p: pte %p pa %p\n", (void *)a, (void *)pte, (void *)PTE2PA(pte));
    80000f20:	00a95493          	srli	s1,s2,0xa
    80000f24:	04b2                	slli	s1,s1,0xc
    80000f26:	86a6                	mv	a3,s1
    80000f28:	864a                	mv	a2,s2
    80000f2a:	85de                	mv	a1,s7
    80000f2c:	00006517          	auipc	a0,0x6
    80000f30:	18c50513          	addi	a0,a0,396 # 800070b8 <etext+0xb8>
    80000f34:	dd6ff0ef          	jal	8000050a <printk>
    if ((pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80000f38:	00e97913          	andi	s2,s2,14
    80000f3c:	fa091de3          	bnez	s2,80000ef6 <vmprint_rec+0x40>
      vmprint_rec((pagetable_t)PTE2PA(pte), level - 1, a);
    80000f40:	865e                	mv	a2,s7
    80000f42:	fff9859b          	addiw	a1,s3,-1
    80000f46:	8526                	mv	a0,s1
    80000f48:	f6fff0ef          	jal	80000eb6 <vmprint_rec>
    80000f4c:	b76d                	j	80000ef6 <vmprint_rec+0x40>
  }
}
    80000f4e:	70a6                	ld	ra,104(sp)
    80000f50:	7406                	ld	s0,96(sp)
    80000f52:	64e6                	ld	s1,88(sp)
    80000f54:	6946                	ld	s2,80(sp)
    80000f56:	69a6                	ld	s3,72(sp)
    80000f58:	6a06                	ld	s4,64(sp)
    80000f5a:	7ae2                	ld	s5,56(sp)
    80000f5c:	7b42                	ld	s6,48(sp)
    80000f5e:	7ba2                	ld	s7,40(sp)
    80000f60:	7c02                	ld	s8,32(sp)
    80000f62:	6ce2                	ld	s9,24(sp)
    80000f64:	6d42                	ld	s10,16(sp)
    80000f66:	6da2                	ld	s11,8(sp)
    80000f68:	6165                	addi	sp,sp,112
    80000f6a:	8082                	ret

0000000080000f6c <kvminithart>:
{
    80000f6c:	1141                	addi	sp,sp,-16
    80000f6e:	e406                	sd	ra,8(sp)
    80000f70:	e022                	sd	s0,0(sp)
    80000f72:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000f74:	12000073          	sfence.vma
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f78:	00007797          	auipc	a5,0x7
    80000f7c:	9387b783          	ld	a5,-1736(a5) # 800078b0 <kernel_pagetable>
    80000f80:	83b1                	srli	a5,a5,0xc
    80000f82:	577d                	li	a4,-1
    80000f84:	177e                	slli	a4,a4,0x3f
    80000f86:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r"(x));
    80000f88:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000f8c:	12000073          	sfence.vma
}
    80000f90:	60a2                	ld	ra,8(sp)
    80000f92:	6402                	ld	s0,0(sp)
    80000f94:	0141                	addi	sp,sp,16
    80000f96:	8082                	ret

0000000080000f98 <walk>:
{
    80000f98:	7139                	addi	sp,sp,-64
    80000f9a:	fc06                	sd	ra,56(sp)
    80000f9c:	f822                	sd	s0,48(sp)
    80000f9e:	f426                	sd	s1,40(sp)
    80000fa0:	f04a                	sd	s2,32(sp)
    80000fa2:	ec4e                	sd	s3,24(sp)
    80000fa4:	e852                	sd	s4,16(sp)
    80000fa6:	e456                	sd	s5,8(sp)
    80000fa8:	e05a                	sd	s6,0(sp)
    80000faa:	0080                	addi	s0,sp,64
    80000fac:	84aa                	mv	s1,a0
    80000fae:	89ae                	mv	s3,a1
    80000fb0:	8ab2                	mv	s5,a2
  if (va >= MAXVA)
    80000fb2:	57fd                	li	a5,-1
    80000fb4:	83e9                	srli	a5,a5,0x1a
    80000fb6:	4a79                	li	s4,30
  for (int level = 2; level > 0; level--) {
    80000fb8:	4b31                	li	s6,12
  if (va >= MAXVA)
    80000fba:	04b7e263          	bltu	a5,a1,80000ffe <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000fbe:	0149d933          	srl	s2,s3,s4
    80000fc2:	1ff97913          	andi	s2,s2,511
    80000fc6:	090e                	slli	s2,s2,0x3
    80000fc8:	9926                	add	s2,s2,s1
    if (*pte & PTE_V) {
    80000fca:	00093483          	ld	s1,0(s2)
    80000fce:	0014f793          	andi	a5,s1,1
    80000fd2:	cf85                	beqz	a5,8000100a <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fd4:	80a9                	srli	s1,s1,0xa
    80000fd6:	04b2                	slli	s1,s1,0xc
  for (int level = 2; level > 0; level--) {
    80000fd8:	3a5d                	addiw	s4,s4,-9
    80000fda:	ff6a12e3          	bne	s4,s6,80000fbe <walk+0x26>
  return &pagetable[PX(0, va)];
    80000fde:	00c9d513          	srli	a0,s3,0xc
    80000fe2:	1ff57513          	andi	a0,a0,511
    80000fe6:	050e                	slli	a0,a0,0x3
    80000fe8:	9526                	add	a0,a0,s1
}
    80000fea:	70e2                	ld	ra,56(sp)
    80000fec:	7442                	ld	s0,48(sp)
    80000fee:	74a2                	ld	s1,40(sp)
    80000ff0:	7902                	ld	s2,32(sp)
    80000ff2:	69e2                	ld	s3,24(sp)
    80000ff4:	6a42                	ld	s4,16(sp)
    80000ff6:	6aa2                	ld	s5,8(sp)
    80000ff8:	6b02                	ld	s6,0(sp)
    80000ffa:	6121                	addi	sp,sp,64
    80000ffc:	8082                	ret
    panic("walk");
    80000ffe:	00006517          	auipc	a0,0x6
    80001002:	0d250513          	addi	a0,a0,210 # 800070d0 <etext+0xd0>
    80001006:	fe8ff0ef          	jal	800007ee <panic>
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    8000100a:	020a8263          	beqz	s5,8000102e <walk+0x96>
    8000100e:	ab5ff0ef          	jal	80000ac2 <kalloc>
    80001012:	84aa                	mv	s1,a0
    80001014:	d979                	beqz	a0,80000fea <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    80001016:	6605                	lui	a2,0x1
    80001018:	4581                	li	a1,0
    8000101a:	c33ff0ef          	jal	80000c4c <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000101e:	00c4d793          	srli	a5,s1,0xc
    80001022:	07aa                	slli	a5,a5,0xa
    80001024:	0017e793          	ori	a5,a5,1
    80001028:	00f93023          	sd	a5,0(s2)
    8000102c:	b775                	j	80000fd8 <walk+0x40>
        return 0;
    8000102e:	4501                	li	a0,0
    80001030:	bf6d                	j	80000fea <walk+0x52>

0000000080001032 <walkaddr>:
  if (va >= MAXVA)
    80001032:	57fd                	li	a5,-1
    80001034:	83e9                	srli	a5,a5,0x1a
    80001036:	00b7f463          	bgeu	a5,a1,8000103e <walkaddr+0xc>
    return 0;
    8000103a:	4501                	li	a0,0
}
    8000103c:	8082                	ret
{
    8000103e:	1141                	addi	sp,sp,-16
    80001040:	e406                	sd	ra,8(sp)
    80001042:	e022                	sd	s0,0(sp)
    80001044:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001046:	4601                	li	a2,0
    80001048:	f51ff0ef          	jal	80000f98 <walk>
  if (pte == 0)
    8000104c:	c105                	beqz	a0,8000106c <walkaddr+0x3a>
  if ((*pte & PTE_V) == 0)
    8000104e:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    80001050:	0117f693          	andi	a3,a5,17
    80001054:	4745                	li	a4,17
    return 0;
    80001056:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    80001058:	00e68663          	beq	a3,a4,80001064 <walkaddr+0x32>
}
    8000105c:	60a2                	ld	ra,8(sp)
    8000105e:	6402                	ld	s0,0(sp)
    80001060:	0141                	addi	sp,sp,16
    80001062:	8082                	ret
  pa = PTE2PA(*pte);
    80001064:	83a9                	srli	a5,a5,0xa
    80001066:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000106a:	bfcd                	j	8000105c <walkaddr+0x2a>
    return 0;
    8000106c:	4501                	li	a0,0
    8000106e:	b7fd                	j	8000105c <walkaddr+0x2a>

0000000080001070 <mappages>:
{
    80001070:	715d                	addi	sp,sp,-80
    80001072:	e486                	sd	ra,72(sp)
    80001074:	e0a2                	sd	s0,64(sp)
    80001076:	fc26                	sd	s1,56(sp)
    80001078:	f84a                	sd	s2,48(sp)
    8000107a:	f44e                	sd	s3,40(sp)
    8000107c:	f052                	sd	s4,32(sp)
    8000107e:	ec56                	sd	s5,24(sp)
    80001080:	e85a                	sd	s6,16(sp)
    80001082:	e45e                	sd	s7,8(sp)
    80001084:	e062                	sd	s8,0(sp)
    80001086:	0880                	addi	s0,sp,80
  if ((va % PGSIZE) != 0)
    80001088:	03459793          	slli	a5,a1,0x34
    8000108c:	e7b1                	bnez	a5,800010d8 <mappages+0x68>
    8000108e:	8aaa                	mv	s5,a0
    80001090:	8b3a                	mv	s6,a4
  if ((size % PGSIZE) != 0)
    80001092:	03461793          	slli	a5,a2,0x34
    80001096:	e7b9                	bnez	a5,800010e4 <mappages+0x74>
  if (size == 0)
    80001098:	ce21                	beqz	a2,800010f0 <mappages+0x80>
  last = va + size - PGSIZE;
    8000109a:	77fd                	lui	a5,0xfffff
    8000109c:	963e                	add	a2,a2,a5
    8000109e:	00b609b3          	add	s3,a2,a1
  a = va;
    800010a2:	892e                	mv	s2,a1
    800010a4:	40b68a33          	sub	s4,a3,a1
    if ((pte = walk(pagetable, a, 1)) == 0)
    800010a8:	4b85                	li	s7,1
    a += PGSIZE;
    800010aa:	6c05                	lui	s8,0x1
    800010ac:	014904b3          	add	s1,s2,s4
    if ((pte = walk(pagetable, a, 1)) == 0)
    800010b0:	865e                	mv	a2,s7
    800010b2:	85ca                	mv	a1,s2
    800010b4:	8556                	mv	a0,s5
    800010b6:	ee3ff0ef          	jal	80000f98 <walk>
    800010ba:	c539                	beqz	a0,80001108 <mappages+0x98>
    if (*pte & PTE_V)
    800010bc:	611c                	ld	a5,0(a0)
    800010be:	8b85                	andi	a5,a5,1
    800010c0:	ef95                	bnez	a5,800010fc <mappages+0x8c>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010c2:	80b1                	srli	s1,s1,0xc
    800010c4:	04aa                	slli	s1,s1,0xa
    800010c6:	0164e4b3          	or	s1,s1,s6
    800010ca:	0014e493          	ori	s1,s1,1
    800010ce:	e104                	sd	s1,0(a0)
    if (a == last)
    800010d0:	05390963          	beq	s2,s3,80001122 <mappages+0xb2>
    a += PGSIZE;
    800010d4:	9962                	add	s2,s2,s8
    if ((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	bfd9                	j	800010ac <mappages+0x3c>
    panic("mappages: va not aligned");
    800010d8:	00006517          	auipc	a0,0x6
    800010dc:	00050513          	mv	a0,a0
    800010e0:	f0eff0ef          	jal	800007ee <panic>
    panic("mappages: size not aligned");
    800010e4:	00006517          	auipc	a0,0x6
    800010e8:	01450513          	addi	a0,a0,20 # 800070f8 <etext+0xf8>
    800010ec:	f02ff0ef          	jal	800007ee <panic>
    panic("mappages: size");
    800010f0:	00006517          	auipc	a0,0x6
    800010f4:	02850513          	addi	a0,a0,40 # 80007118 <etext+0x118>
    800010f8:	ef6ff0ef          	jal	800007ee <panic>
      panic("mappages: remap");
    800010fc:	00006517          	auipc	a0,0x6
    80001100:	02c50513          	addi	a0,a0,44 # 80007128 <etext+0x128>
    80001104:	eeaff0ef          	jal	800007ee <panic>
      return -1;
    80001108:	557d                	li	a0,-1
}
    8000110a:	60a6                	ld	ra,72(sp)
    8000110c:	6406                	ld	s0,64(sp)
    8000110e:	74e2                	ld	s1,56(sp)
    80001110:	7942                	ld	s2,48(sp)
    80001112:	79a2                	ld	s3,40(sp)
    80001114:	7a02                	ld	s4,32(sp)
    80001116:	6ae2                	ld	s5,24(sp)
    80001118:	6b42                	ld	s6,16(sp)
    8000111a:	6ba2                	ld	s7,8(sp)
    8000111c:	6c02                	ld	s8,0(sp)
    8000111e:	6161                	addi	sp,sp,80
    80001120:	8082                	ret
  return 0;
    80001122:	4501                	li	a0,0
    80001124:	b7dd                	j	8000110a <mappages+0x9a>

0000000080001126 <kvmmap>:
{
    80001126:	1141                	addi	sp,sp,-16
    80001128:	e406                	sd	ra,8(sp)
    8000112a:	e022                	sd	s0,0(sp)
    8000112c:	0800                	addi	s0,sp,16
    8000112e:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001130:	86b2                	mv	a3,a2
    80001132:	863e                	mv	a2,a5
    80001134:	f3dff0ef          	jal	80001070 <mappages>
    80001138:	e509                	bnez	a0,80001142 <kvmmap+0x1c>
}
    8000113a:	60a2                	ld	ra,8(sp)
    8000113c:	6402                	ld	s0,0(sp)
    8000113e:	0141                	addi	sp,sp,16
    80001140:	8082                	ret
    panic("kvmmap");
    80001142:	00006517          	auipc	a0,0x6
    80001146:	ff650513          	addi	a0,a0,-10 # 80007138 <etext+0x138>
    8000114a:	ea4ff0ef          	jal	800007ee <panic>

000000008000114e <kvmmake>:
{
    8000114e:	1101                	addi	sp,sp,-32
    80001150:	ec06                	sd	ra,24(sp)
    80001152:	e822                	sd	s0,16(sp)
    80001154:	e426                	sd	s1,8(sp)
    80001156:	e04a                	sd	s2,0(sp)
    80001158:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    8000115a:	969ff0ef          	jal	80000ac2 <kalloc>
    8000115e:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001160:	6605                	lui	a2,0x1
    80001162:	4581                	li	a1,0
    80001164:	ae9ff0ef          	jal	80000c4c <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001168:	4719                	li	a4,6
    8000116a:	6685                	lui	a3,0x1
    8000116c:	10000637          	lui	a2,0x10000
    80001170:	85b2                	mv	a1,a2
    80001172:	8526                	mv	a0,s1
    80001174:	fb3ff0ef          	jal	80001126 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001178:	4719                	li	a4,6
    8000117a:	6685                	lui	a3,0x1
    8000117c:	10001637          	lui	a2,0x10001
    80001180:	85b2                	mv	a1,a2
    80001182:	8526                	mv	a0,s1
    80001184:	fa3ff0ef          	jal	80001126 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001188:	4719                	li	a4,6
    8000118a:	040006b7          	lui	a3,0x4000
    8000118e:	0c000637          	lui	a2,0xc000
    80001192:	85b2                	mv	a1,a2
    80001194:	8526                	mv	a0,s1
    80001196:	f91ff0ef          	jal	80001126 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    8000119a:	00006917          	auipc	s2,0x6
    8000119e:	e6690913          	addi	s2,s2,-410 # 80007000 <etext>
    800011a2:	4729                	li	a4,10
    800011a4:	80006697          	auipc	a3,0x80006
    800011a8:	e5c68693          	addi	a3,a3,-420 # 7000 <_entry-0x7fff9000>
    800011ac:	4605                	li	a2,1
    800011ae:	067e                	slli	a2,a2,0x1f
    800011b0:	85b2                	mv	a1,a2
    800011b2:	8526                	mv	a0,s1
    800011b4:	f73ff0ef          	jal	80001126 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext,
    800011b8:	4719                	li	a4,6
    800011ba:	46c5                	li	a3,17
    800011bc:	06ee                	slli	a3,a3,0x1b
    800011be:	412686b3          	sub	a3,a3,s2
    800011c2:	864a                	mv	a2,s2
    800011c4:	85ca                	mv	a1,s2
    800011c6:	8526                	mv	a0,s1
    800011c8:	f5fff0ef          	jal	80001126 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011cc:	4729                	li	a4,10
    800011ce:	6685                	lui	a3,0x1
    800011d0:	00005617          	auipc	a2,0x5
    800011d4:	e3060613          	addi	a2,a2,-464 # 80006000 <_trampoline>
    800011d8:	040005b7          	lui	a1,0x4000
    800011dc:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011de:	05b2                	slli	a1,a1,0xc
    800011e0:	8526                	mv	a0,s1
    800011e2:	f45ff0ef          	jal	80001126 <kvmmap>
  proc_mapstacks(kpgtbl);
    800011e6:	8526                	mv	a0,s1
    800011e8:	614000ef          	jal	800017fc <proc_mapstacks>
}
    800011ec:	8526                	mv	a0,s1
    800011ee:	60e2                	ld	ra,24(sp)
    800011f0:	6442                	ld	s0,16(sp)
    800011f2:	64a2                	ld	s1,8(sp)
    800011f4:	6902                	ld	s2,0(sp)
    800011f6:	6105                	addi	sp,sp,32
    800011f8:	8082                	ret

00000000800011fa <kvminit>:
{
    800011fa:	1141                	addi	sp,sp,-16
    800011fc:	e406                	sd	ra,8(sp)
    800011fe:	e022                	sd	s0,0(sp)
    80001200:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001202:	f4dff0ef          	jal	8000114e <kvmmake>
    80001206:	00006797          	auipc	a5,0x6
    8000120a:	6aa7b523          	sd	a0,1706(a5) # 800078b0 <kernel_pagetable>
}
    8000120e:	60a2                	ld	ra,8(sp)
    80001210:	6402                	ld	s0,0(sp)
    80001212:	0141                	addi	sp,sp,16
    80001214:	8082                	ret

0000000080001216 <uvmcreate>:
{
    80001216:	1101                	addi	sp,sp,-32
    80001218:	ec06                	sd	ra,24(sp)
    8000121a:	e822                	sd	s0,16(sp)
    8000121c:	e426                	sd	s1,8(sp)
    8000121e:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t)kalloc();
    80001220:	8a3ff0ef          	jal	80000ac2 <kalloc>
    80001224:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001226:	c509                	beqz	a0,80001230 <uvmcreate+0x1a>
  memset(pagetable, 0, PGSIZE);
    80001228:	6605                	lui	a2,0x1
    8000122a:	4581                	li	a1,0
    8000122c:	a21ff0ef          	jal	80000c4c <memset>
}
    80001230:	8526                	mv	a0,s1
    80001232:	60e2                	ld	ra,24(sp)
    80001234:	6442                	ld	s0,16(sp)
    80001236:	64a2                	ld	s1,8(sp)
    80001238:	6105                	addi	sp,sp,32
    8000123a:	8082                	ret

000000008000123c <uvmunmap>:
{
    8000123c:	7139                	addi	sp,sp,-64
    8000123e:	fc06                	sd	ra,56(sp)
    80001240:	f822                	sd	s0,48(sp)
    80001242:	0080                	addi	s0,sp,64
  if ((va % PGSIZE) != 0)
    80001244:	03459793          	slli	a5,a1,0x34
    80001248:	e38d                	bnez	a5,8000126a <uvmunmap+0x2e>
    8000124a:	f04a                	sd	s2,32(sp)
    8000124c:	ec4e                	sd	s3,24(sp)
    8000124e:	e852                	sd	s4,16(sp)
    80001250:	e456                	sd	s5,8(sp)
    80001252:	e05a                	sd	s6,0(sp)
    80001254:	8a2a                	mv	s4,a0
    80001256:	892e                	mv	s2,a1
    80001258:	8ab6                	mv	s5,a3
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    8000125a:	0632                	slli	a2,a2,0xc
    8000125c:	00b609b3          	add	s3,a2,a1
    80001260:	6b05                	lui	s6,0x1
    80001262:	0535f963          	bgeu	a1,s3,800012b4 <uvmunmap+0x78>
    80001266:	f426                	sd	s1,40(sp)
    80001268:	a015                	j	8000128c <uvmunmap+0x50>
    8000126a:	f426                	sd	s1,40(sp)
    8000126c:	f04a                	sd	s2,32(sp)
    8000126e:	ec4e                	sd	s3,24(sp)
    80001270:	e852                	sd	s4,16(sp)
    80001272:	e456                	sd	s5,8(sp)
    80001274:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    80001276:	00006517          	auipc	a0,0x6
    8000127a:	eca50513          	addi	a0,a0,-310 # 80007140 <etext+0x140>
    8000127e:	d70ff0ef          	jal	800007ee <panic>
    *pte = 0;
    80001282:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    80001286:	995a                	add	s2,s2,s6
    80001288:	03397563          	bgeu	s2,s3,800012b2 <uvmunmap+0x76>
    if ((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    8000128c:	4601                	li	a2,0
    8000128e:	85ca                	mv	a1,s2
    80001290:	8552                	mv	a0,s4
    80001292:	d07ff0ef          	jal	80000f98 <walk>
    80001296:	84aa                	mv	s1,a0
    80001298:	d57d                	beqz	a0,80001286 <uvmunmap+0x4a>
    if ((*pte & PTE_V) == 0) // has physical page been allocated?
    8000129a:	611c                	ld	a5,0(a0)
    8000129c:	0017f713          	andi	a4,a5,1
    800012a0:	d37d                	beqz	a4,80001286 <uvmunmap+0x4a>
    if (do_free) {
    800012a2:	fe0a80e3          	beqz	s5,80001282 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    800012a6:	83a9                	srli	a5,a5,0xa
      kfree((void *)pa);
    800012a8:	00c79513          	slli	a0,a5,0xc
    800012ac:	f34ff0ef          	jal	800009e0 <kfree>
    800012b0:	bfc9                	j	80001282 <uvmunmap+0x46>
    800012b2:	74a2                	ld	s1,40(sp)
    800012b4:	7902                	ld	s2,32(sp)
    800012b6:	69e2                	ld	s3,24(sp)
    800012b8:	6a42                	ld	s4,16(sp)
    800012ba:	6aa2                	ld	s5,8(sp)
    800012bc:	6b02                	ld	s6,0(sp)
}
    800012be:	70e2                	ld	ra,56(sp)
    800012c0:	7442                	ld	s0,48(sp)
    800012c2:	6121                	addi	sp,sp,64
    800012c4:	8082                	ret

00000000800012c6 <uvmdealloc>:
{
    800012c6:	1101                	addi	sp,sp,-32
    800012c8:	ec06                	sd	ra,24(sp)
    800012ca:	e822                	sd	s0,16(sp)
    800012cc:	e426                	sd	s1,8(sp)
    800012ce:	1000                	addi	s0,sp,32
    return oldsz;
    800012d0:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    800012d2:	00b67d63          	bgeu	a2,a1,800012ec <uvmdealloc+0x26>
    800012d6:	84b2                	mv	s1,a2
  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz)) {
    800012d8:	6785                	lui	a5,0x1
    800012da:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012dc:	00f60733          	add	a4,a2,a5
    800012e0:	76fd                	lui	a3,0xfffff
    800012e2:	8f75                	and	a4,a4,a3
    800012e4:	97ae                	add	a5,a5,a1
    800012e6:	8ff5                	and	a5,a5,a3
    800012e8:	00f76863          	bltu	a4,a5,800012f8 <uvmdealloc+0x32>
}
    800012ec:	8526                	mv	a0,s1
    800012ee:	60e2                	ld	ra,24(sp)
    800012f0:	6442                	ld	s0,16(sp)
    800012f2:	64a2                	ld	s1,8(sp)
    800012f4:	6105                	addi	sp,sp,32
    800012f6:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800012f8:	8f99                	sub	a5,a5,a4
    800012fa:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800012fc:	4685                	li	a3,1
    800012fe:	0007861b          	sext.w	a2,a5
    80001302:	85ba                	mv	a1,a4
    80001304:	f39ff0ef          	jal	8000123c <uvmunmap>
    80001308:	b7d5                	j	800012ec <uvmdealloc+0x26>

000000008000130a <uvmalloc>:
  if (newsz < oldsz)
    8000130a:	0ab66363          	bltu	a2,a1,800013b0 <uvmalloc+0xa6>
{
    8000130e:	715d                	addi	sp,sp,-80
    80001310:	e486                	sd	ra,72(sp)
    80001312:	e0a2                	sd	s0,64(sp)
    80001314:	f052                	sd	s4,32(sp)
    80001316:	ec56                	sd	s5,24(sp)
    80001318:	e85a                	sd	s6,16(sp)
    8000131a:	0880                	addi	s0,sp,80
    8000131c:	8b2a                	mv	s6,a0
    8000131e:	8ab2                	mv	s5,a2
  oldsz = PGROUNDUP(oldsz);
    80001320:	6785                	lui	a5,0x1
    80001322:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001324:	95be                	add	a1,a1,a5
    80001326:	77fd                	lui	a5,0xfffff
    80001328:	00f5fa33          	and	s4,a1,a5
  for (a = oldsz; a < newsz; a += PGSIZE) {
    8000132c:	08ca7463          	bgeu	s4,a2,800013b4 <uvmalloc+0xaa>
    80001330:	fc26                	sd	s1,56(sp)
    80001332:	f84a                	sd	s2,48(sp)
    80001334:	f44e                	sd	s3,40(sp)
    80001336:	e45e                	sd	s7,8(sp)
    80001338:	8952                	mv	s2,s4
    memset(mem, 0, PGSIZE);
    8000133a:	6985                	lui	s3,0x1
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    8000133c:	0126eb93          	ori	s7,a3,18
    mem = kalloc();
    80001340:	f82ff0ef          	jal	80000ac2 <kalloc>
    80001344:	84aa                	mv	s1,a0
    if (mem == 0) {
    80001346:	c515                	beqz	a0,80001372 <uvmalloc+0x68>
    memset(mem, 0, PGSIZE);
    80001348:	864e                	mv	a2,s3
    8000134a:	4581                	li	a1,0
    8000134c:	901ff0ef          	jal	80000c4c <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    80001350:	875e                	mv	a4,s7
    80001352:	86a6                	mv	a3,s1
    80001354:	864e                	mv	a2,s3
    80001356:	85ca                	mv	a1,s2
    80001358:	855a                	mv	a0,s6
    8000135a:	d17ff0ef          	jal	80001070 <mappages>
    8000135e:	e91d                	bnez	a0,80001394 <uvmalloc+0x8a>
  for (a = oldsz; a < newsz; a += PGSIZE) {
    80001360:	994e                	add	s2,s2,s3
    80001362:	fd596fe3          	bltu	s2,s5,80001340 <uvmalloc+0x36>
  return newsz;
    80001366:	8556                	mv	a0,s5
    80001368:	74e2                	ld	s1,56(sp)
    8000136a:	7942                	ld	s2,48(sp)
    8000136c:	79a2                	ld	s3,40(sp)
    8000136e:	6ba2                	ld	s7,8(sp)
    80001370:	a819                	j	80001386 <uvmalloc+0x7c>
      uvmdealloc(pagetable, a, oldsz);
    80001372:	8652                	mv	a2,s4
    80001374:	85ca                	mv	a1,s2
    80001376:	855a                	mv	a0,s6
    80001378:	f4fff0ef          	jal	800012c6 <uvmdealloc>
      return 0;
    8000137c:	4501                	li	a0,0
    8000137e:	74e2                	ld	s1,56(sp)
    80001380:	7942                	ld	s2,48(sp)
    80001382:	79a2                	ld	s3,40(sp)
    80001384:	6ba2                	ld	s7,8(sp)
}
    80001386:	60a6                	ld	ra,72(sp)
    80001388:	6406                	ld	s0,64(sp)
    8000138a:	7a02                	ld	s4,32(sp)
    8000138c:	6ae2                	ld	s5,24(sp)
    8000138e:	6b42                	ld	s6,16(sp)
    80001390:	6161                	addi	sp,sp,80
    80001392:	8082                	ret
      kfree(mem);
    80001394:	8526                	mv	a0,s1
    80001396:	e4aff0ef          	jal	800009e0 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000139a:	8652                	mv	a2,s4
    8000139c:	85ca                	mv	a1,s2
    8000139e:	855a                	mv	a0,s6
    800013a0:	f27ff0ef          	jal	800012c6 <uvmdealloc>
      return 0;
    800013a4:	4501                	li	a0,0
    800013a6:	74e2                	ld	s1,56(sp)
    800013a8:	7942                	ld	s2,48(sp)
    800013aa:	79a2                	ld	s3,40(sp)
    800013ac:	6ba2                	ld	s7,8(sp)
    800013ae:	bfe1                	j	80001386 <uvmalloc+0x7c>
    return oldsz;
    800013b0:	852e                	mv	a0,a1
}
    800013b2:	8082                	ret
  return newsz;
    800013b4:	8532                	mv	a0,a2
    800013b6:	bfc1                	j	80001386 <uvmalloc+0x7c>

00000000800013b8 <freewalk>:
{
    800013b8:	7179                	addi	sp,sp,-48
    800013ba:	f406                	sd	ra,40(sp)
    800013bc:	f022                	sd	s0,32(sp)
    800013be:	ec26                	sd	s1,24(sp)
    800013c0:	e84a                	sd	s2,16(sp)
    800013c2:	e44e                	sd	s3,8(sp)
    800013c4:	e052                	sd	s4,0(sp)
    800013c6:	1800                	addi	s0,sp,48
    800013c8:	8a2a                	mv	s4,a0
  for (int i = 0; i < 512; i++) {
    800013ca:	84aa                	mv	s1,a0
    800013cc:	6905                	lui	s2,0x1
    800013ce:	992a                	add	s2,s2,a0
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    800013d0:	4985                	li	s3,1
    800013d2:	a819                	j	800013e8 <freewalk+0x30>
      uint64 child = PTE2PA(pte);
    800013d4:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800013d6:	00c79513          	slli	a0,a5,0xc
    800013da:	fdfff0ef          	jal	800013b8 <freewalk>
      pagetable[i] = 0;
    800013de:	0004b023          	sd	zero,0(s1)
  for (int i = 0; i < 512; i++) {
    800013e2:	04a1                	addi	s1,s1,8
    800013e4:	01248f63          	beq	s1,s2,80001402 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    800013e8:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    800013ea:	00f7f713          	andi	a4,a5,15
    800013ee:	ff3703e3          	beq	a4,s3,800013d4 <freewalk+0x1c>
    } else if (pte & PTE_V) {
    800013f2:	8b85                	andi	a5,a5,1
    800013f4:	d7fd                	beqz	a5,800013e2 <freewalk+0x2a>
      panic("freewalk: leaf");
    800013f6:	00006517          	auipc	a0,0x6
    800013fa:	d6250513          	addi	a0,a0,-670 # 80007158 <etext+0x158>
    800013fe:	bf0ff0ef          	jal	800007ee <panic>
  kfree((void *)pagetable);
    80001402:	8552                	mv	a0,s4
    80001404:	ddcff0ef          	jal	800009e0 <kfree>
}
    80001408:	70a2                	ld	ra,40(sp)
    8000140a:	7402                	ld	s0,32(sp)
    8000140c:	64e2                	ld	s1,24(sp)
    8000140e:	6942                	ld	s2,16(sp)
    80001410:	69a2                	ld	s3,8(sp)
    80001412:	6a02                	ld	s4,0(sp)
    80001414:	6145                	addi	sp,sp,48
    80001416:	8082                	ret

0000000080001418 <vmprint>:

void
vmprint(pagetable_t pagetable)
{
    80001418:	1101                	addi	sp,sp,-32
    8000141a:	ec06                	sd	ra,24(sp)
    8000141c:	e822                	sd	s0,16(sp)
    8000141e:	e426                	sd	s1,8(sp)
    80001420:	1000                	addi	s0,sp,32
    80001422:	84aa                	mv	s1,a0
  printk("page table %p\n", pagetable);
    80001424:	85aa                	mv	a1,a0
    80001426:	00006517          	auipc	a0,0x6
    8000142a:	d4250513          	addi	a0,a0,-702 # 80007168 <etext+0x168>
    8000142e:	8dcff0ef          	jal	8000050a <printk>
  vmprint_rec(pagetable, 2, 0);
    80001432:	4601                	li	a2,0
    80001434:	4589                	li	a1,2
    80001436:	8526                	mv	a0,s1
    80001438:	a7fff0ef          	jal	80000eb6 <vmprint_rec>
}
    8000143c:	60e2                	ld	ra,24(sp)
    8000143e:	6442                	ld	s0,16(sp)
    80001440:	64a2                	ld	s1,8(sp)
    80001442:	6105                	addi	sp,sp,32
    80001444:	8082                	ret

0000000080001446 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001446:	1101                	addi	sp,sp,-32
    80001448:	ec06                	sd	ra,24(sp)
    8000144a:	e822                	sd	s0,16(sp)
    8000144c:	e426                	sd	s1,8(sp)
    8000144e:	1000                	addi	s0,sp,32
    80001450:	84aa                	mv	s1,a0
  if (sz > 0)
    80001452:	e989                	bnez	a1,80001464 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    80001454:	8526                	mv	a0,s1
    80001456:	f63ff0ef          	jal	800013b8 <freewalk>
}
    8000145a:	60e2                	ld	ra,24(sp)
    8000145c:	6442                	ld	s0,16(sp)
    8000145e:	64a2                	ld	s1,8(sp)
    80001460:	6105                	addi	sp,sp,32
    80001462:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    80001464:	6785                	lui	a5,0x1
    80001466:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001468:	95be                	add	a1,a1,a5
    8000146a:	4685                	li	a3,1
    8000146c:	00c5d613          	srli	a2,a1,0xc
    80001470:	4581                	li	a1,0
    80001472:	dcbff0ef          	jal	8000123c <uvmunmap>
    80001476:	bff9                	j	80001454 <uvmfree+0xe>

0000000080001478 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for (i = 0; i < sz; i += PGSIZE) {
    80001478:	ce59                	beqz	a2,80001516 <uvmcopy+0x9e>
{
    8000147a:	715d                	addi	sp,sp,-80
    8000147c:	e486                	sd	ra,72(sp)
    8000147e:	e0a2                	sd	s0,64(sp)
    80001480:	fc26                	sd	s1,56(sp)
    80001482:	f84a                	sd	s2,48(sp)
    80001484:	f44e                	sd	s3,40(sp)
    80001486:	f052                	sd	s4,32(sp)
    80001488:	ec56                	sd	s5,24(sp)
    8000148a:	e85a                	sd	s6,16(sp)
    8000148c:	e45e                	sd	s7,8(sp)
    8000148e:	e062                	sd	s8,0(sp)
    80001490:	0880                	addi	s0,sp,80
    80001492:	8b2a                	mv	s6,a0
    80001494:	8bae                	mv	s7,a1
    80001496:	8ab2                	mv	s5,a2
  for (i = 0; i < sz; i += PGSIZE) {
    80001498:	4481                	li	s1,0
      continue; // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if ((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    8000149a:	6a05                	lui	s4,0x1
    8000149c:	a021                	j	800014a4 <uvmcopy+0x2c>
  for (i = 0; i < sz; i += PGSIZE) {
    8000149e:	94d2                	add	s1,s1,s4
    800014a0:	0554fe63          	bgeu	s1,s5,800014fc <uvmcopy+0x84>
    if ((pte = walk(old, i, 0)) == 0)
    800014a4:	4601                	li	a2,0
    800014a6:	85a6                	mv	a1,s1
    800014a8:	855a                	mv	a0,s6
    800014aa:	aefff0ef          	jal	80000f98 <walk>
    800014ae:	d965                	beqz	a0,8000149e <uvmcopy+0x26>
    if ((*pte & PTE_V) == 0)
    800014b0:	6118                	ld	a4,0(a0)
    800014b2:	00177793          	andi	a5,a4,1
    800014b6:	d7e5                	beqz	a5,8000149e <uvmcopy+0x26>
    pa = PTE2PA(*pte);
    800014b8:	00a75593          	srli	a1,a4,0xa
    800014bc:	00c59c13          	slli	s8,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014c0:	3ff77913          	andi	s2,a4,1023
    if ((mem = kalloc()) == 0)
    800014c4:	dfeff0ef          	jal	80000ac2 <kalloc>
    800014c8:	89aa                	mv	s3,a0
    800014ca:	c105                	beqz	a0,800014ea <uvmcopy+0x72>
    memmove(mem, (char *)pa, PGSIZE);
    800014cc:	8652                	mv	a2,s4
    800014ce:	85e2                	mv	a1,s8
    800014d0:	fe0ff0ef          	jal	80000cb0 <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0) {
    800014d4:	874a                	mv	a4,s2
    800014d6:	86ce                	mv	a3,s3
    800014d8:	8652                	mv	a2,s4
    800014da:	85a6                	mv	a1,s1
    800014dc:	855e                	mv	a0,s7
    800014de:	b93ff0ef          	jal	80001070 <mappages>
    800014e2:	dd55                	beqz	a0,8000149e <uvmcopy+0x26>
      kfree(mem);
    800014e4:	854e                	mv	a0,s3
    800014e6:	cfaff0ef          	jal	800009e0 <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014ea:	4685                	li	a3,1
    800014ec:	00c4d613          	srli	a2,s1,0xc
    800014f0:	4581                	li	a1,0
    800014f2:	855e                	mv	a0,s7
    800014f4:	d49ff0ef          	jal	8000123c <uvmunmap>
  return -1;
    800014f8:	557d                	li	a0,-1
    800014fa:	a011                	j	800014fe <uvmcopy+0x86>
  return 0;
    800014fc:	4501                	li	a0,0
}
    800014fe:	60a6                	ld	ra,72(sp)
    80001500:	6406                	ld	s0,64(sp)
    80001502:	74e2                	ld	s1,56(sp)
    80001504:	7942                	ld	s2,48(sp)
    80001506:	79a2                	ld	s3,40(sp)
    80001508:	7a02                	ld	s4,32(sp)
    8000150a:	6ae2                	ld	s5,24(sp)
    8000150c:	6b42                	ld	s6,16(sp)
    8000150e:	6ba2                	ld	s7,8(sp)
    80001510:	6c02                	ld	s8,0(sp)
    80001512:	6161                	addi	sp,sp,80
    80001514:	8082                	ret
  return 0;
    80001516:	4501                	li	a0,0
}
    80001518:	8082                	ret

000000008000151a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000151a:	1141                	addi	sp,sp,-16
    8000151c:	e406                	sd	ra,8(sp)
    8000151e:	e022                	sd	s0,0(sp)
    80001520:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    80001522:	4601                	li	a2,0
    80001524:	a75ff0ef          	jal	80000f98 <walk>
  if (pte == 0)
    80001528:	c901                	beqz	a0,80001538 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000152a:	611c                	ld	a5,0(a0)
    8000152c:	9bbd                	andi	a5,a5,-17
    8000152e:	e11c                	sd	a5,0(a0)
}
    80001530:	60a2                	ld	ra,8(sp)
    80001532:	6402                	ld	s0,0(sp)
    80001534:	0141                	addi	sp,sp,16
    80001536:	8082                	ret
    panic("uvmclear");
    80001538:	00006517          	auipc	a0,0x6
    8000153c:	c4050513          	addi	a0,a0,-960 # 80007178 <etext+0x178>
    80001540:	aaeff0ef          	jal	800007ee <panic>

0000000080001544 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    80001544:	1141                	addi	sp,sp,-16
    80001546:	e406                	sd	ra,8(sp)
    80001548:	e022                	sd	s0,0(sp)
    8000154a:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    8000154c:	4601                	li	a2,0
    8000154e:	a4bff0ef          	jal	80000f98 <walk>
  if (pte == 0) {
    80001552:	c519                	beqz	a0,80001560 <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V) {
    80001554:	6108                	ld	a0,0(a0)
    80001556:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001558:	60a2                	ld	ra,8(sp)
    8000155a:	6402                	ld	s0,0(sp)
    8000155c:	0141                	addi	sp,sp,16
    8000155e:	8082                	ret
    return 0;
    80001560:	4501                	li	a0,0
    80001562:	bfdd                	j	80001558 <ismapped+0x14>

0000000080001564 <vmfault>:
{
    80001564:	7179                	addi	sp,sp,-48
    80001566:	f406                	sd	ra,40(sp)
    80001568:	f022                	sd	s0,32(sp)
    8000156a:	e44e                	sd	s3,8(sp)
    8000156c:	1800                	addi	s0,sp,48
    return 0;
    8000156e:	4981                	li	s3,0
  if (va >= psz)
    80001570:	00b66863          	bltu	a2,a1,80001580 <vmfault+0x1c>
}
    80001574:	854e                	mv	a0,s3
    80001576:	70a2                	ld	ra,40(sp)
    80001578:	7402                	ld	s0,32(sp)
    8000157a:	69a2                	ld	s3,8(sp)
    8000157c:	6145                	addi	sp,sp,48
    8000157e:	8082                	ret
    80001580:	ec26                	sd	s1,24(sp)
    80001582:	e84a                	sd	s2,16(sp)
    80001584:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    80001586:	77fd                	lui	a5,0xfffff
    80001588:	00f674b3          	and	s1,a2,a5
  if (ismapped(pagetable, va)) {
    8000158c:	85a6                	mv	a1,s1
    8000158e:	fb7ff0ef          	jal	80001544 <ismapped>
    return 0;
    80001592:	4981                	li	s3,0
  if (ismapped(pagetable, va)) {
    80001594:	c501                	beqz	a0,8000159c <vmfault+0x38>
    80001596:	64e2                	ld	s1,24(sp)
    80001598:	6942                	ld	s2,16(sp)
    8000159a:	bfe9                	j	80001574 <vmfault+0x10>
    8000159c:	e052                	sd	s4,0(sp)
  mem = (uint64)kalloc();
    8000159e:	d24ff0ef          	jal	80000ac2 <kalloc>
    800015a2:	8a2a                	mv	s4,a0
  if (mem == 0)
    800015a4:	c915                	beqz	a0,800015d8 <vmfault+0x74>
  mem = (uint64)kalloc();
    800015a6:	89aa                	mv	s3,a0
  memset((void *)mem, 0, PGSIZE);
    800015a8:	6605                	lui	a2,0x1
    800015aa:	4581                	li	a1,0
    800015ac:	ea0ff0ef          	jal	80000c4c <memset>
  if (mappages(pagetable, va, PGSIZE, mem, PTE_W | PTE_U | PTE_R) != 0) {
    800015b0:	4759                	li	a4,22
    800015b2:	86d2                	mv	a3,s4
    800015b4:	6605                	lui	a2,0x1
    800015b6:	85a6                	mv	a1,s1
    800015b8:	854a                	mv	a0,s2
    800015ba:	ab7ff0ef          	jal	80001070 <mappages>
    800015be:	e509                	bnez	a0,800015c8 <vmfault+0x64>
    800015c0:	64e2                	ld	s1,24(sp)
    800015c2:	6942                	ld	s2,16(sp)
    800015c4:	6a02                	ld	s4,0(sp)
    800015c6:	b77d                	j	80001574 <vmfault+0x10>
    kfree((void *)mem);
    800015c8:	8552                	mv	a0,s4
    800015ca:	c16ff0ef          	jal	800009e0 <kfree>
    return 0;
    800015ce:	4981                	li	s3,0
    800015d0:	64e2                	ld	s1,24(sp)
    800015d2:	6942                	ld	s2,16(sp)
    800015d4:	6a02                	ld	s4,0(sp)
    800015d6:	bf79                	j	80001574 <vmfault+0x10>
    800015d8:	64e2                	ld	s1,24(sp)
    800015da:	6942                	ld	s2,16(sp)
    800015dc:	6a02                	ld	s4,0(sp)
    800015de:	bf59                	j	80001574 <vmfault+0x10>

00000000800015e0 <copyout>:
  while (len > 0) {
    800015e0:	cf49                	beqz	a4,8000167a <copyout+0x9a>
{
    800015e2:	7159                	addi	sp,sp,-112
    800015e4:	f486                	sd	ra,104(sp)
    800015e6:	f0a2                	sd	s0,96(sp)
    800015e8:	eca6                	sd	s1,88(sp)
    800015ea:	e8ca                	sd	s2,80(sp)
    800015ec:	e4ce                	sd	s3,72(sp)
    800015ee:	e0d2                	sd	s4,64(sp)
    800015f0:	fc56                	sd	s5,56(sp)
    800015f2:	f85a                	sd	s6,48(sp)
    800015f4:	f45e                	sd	s7,40(sp)
    800015f6:	f062                	sd	s8,32(sp)
    800015f8:	ec66                	sd	s9,24(sp)
    800015fa:	e86a                	sd	s10,16(sp)
    800015fc:	e46e                	sd	s11,8(sp)
    800015fe:	1880                	addi	s0,sp,112
    80001600:	8baa                	mv	s7,a0
    80001602:	8dae                	mv	s11,a1
    80001604:	8a32                	mv	s4,a2
    80001606:	8b36                	mv	s6,a3
    80001608:	8aba                	mv	s5,a4
    va0 = PGROUNDDOWN(dstva);
    8000160a:	7d7d                	lui	s10,0xfffff
    if (va0 >= MAXVA)
    8000160c:	5cfd                	li	s9,-1
    8000160e:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    80001612:	6c05                	lui	s8,0x1
    80001614:	a005                	j	80001634 <copyout+0x54>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001616:	409a0533          	sub	a0,s4,s1
    8000161a:	0009061b          	sext.w	a2,s2
    8000161e:	85da                	mv	a1,s6
    80001620:	954e                	add	a0,a0,s3
    80001622:	e8eff0ef          	jal	80000cb0 <memmove>
    len -= n;
    80001626:	412a8ab3          	sub	s5,s5,s2
    src += n;
    8000162a:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    8000162c:	01848a33          	add	s4,s1,s8
  while (len > 0) {
    80001630:	040a8363          	beqz	s5,80001676 <copyout+0x96>
    va0 = PGROUNDDOWN(dstva);
    80001634:	01aa74b3          	and	s1,s4,s10
    if (va0 >= MAXVA)
    80001638:	049ce363          	bltu	s9,s1,8000167e <copyout+0x9e>
    pa0 = walkaddr(pagetable, va0);
    8000163c:	85a6                	mv	a1,s1
    8000163e:	855e                	mv	a0,s7
    80001640:	9f3ff0ef          	jal	80001032 <walkaddr>
    80001644:	89aa                	mv	s3,a0
    if (pa0 == 0) {
    80001646:	e909                	bnez	a0,80001658 <copyout+0x78>
      if ((pa0 = vmfault(pagetable, psz, va0, 0)) == 0) {
    80001648:	4681                	li	a3,0
    8000164a:	8626                	mv	a2,s1
    8000164c:	85ee                	mv	a1,s11
    8000164e:	855e                	mv	a0,s7
    80001650:	f15ff0ef          	jal	80001564 <vmfault>
    80001654:	89aa                	mv	s3,a0
    80001656:	c521                	beqz	a0,8000169e <copyout+0xbe>
    pte = walk(pagetable, va0, 0);
    80001658:	4601                	li	a2,0
    8000165a:	85a6                	mv	a1,s1
    8000165c:	855e                	mv	a0,s7
    8000165e:	93bff0ef          	jal	80000f98 <walk>
    if ((*pte & PTE_W) == 0)
    80001662:	611c                	ld	a5,0(a0)
    80001664:	8b91                	andi	a5,a5,4
    80001666:	cf95                	beqz	a5,800016a2 <copyout+0xc2>
    n = PGSIZE - (dstva - va0);
    80001668:	41448933          	sub	s2,s1,s4
    8000166c:	9962                	add	s2,s2,s8
    if (n > len)
    8000166e:	fb2af4e3          	bgeu	s5,s2,80001616 <copyout+0x36>
    80001672:	8956                	mv	s2,s5
    80001674:	b74d                	j	80001616 <copyout+0x36>
  return 0;
    80001676:	4501                	li	a0,0
    80001678:	a021                	j	80001680 <copyout+0xa0>
    8000167a:	4501                	li	a0,0
}
    8000167c:	8082                	ret
      return -1;
    8000167e:	557d                	li	a0,-1
}
    80001680:	70a6                	ld	ra,104(sp)
    80001682:	7406                	ld	s0,96(sp)
    80001684:	64e6                	ld	s1,88(sp)
    80001686:	6946                	ld	s2,80(sp)
    80001688:	69a6                	ld	s3,72(sp)
    8000168a:	6a06                	ld	s4,64(sp)
    8000168c:	7ae2                	ld	s5,56(sp)
    8000168e:	7b42                	ld	s6,48(sp)
    80001690:	7ba2                	ld	s7,40(sp)
    80001692:	7c02                	ld	s8,32(sp)
    80001694:	6ce2                	ld	s9,24(sp)
    80001696:	6d42                	ld	s10,16(sp)
    80001698:	6da2                	ld	s11,8(sp)
    8000169a:	6165                	addi	sp,sp,112
    8000169c:	8082                	ret
        return -1;
    8000169e:	557d                	li	a0,-1
    800016a0:	b7c5                	j	80001680 <copyout+0xa0>
      return -1;
    800016a2:	557d                	li	a0,-1
    800016a4:	bff1                	j	80001680 <copyout+0xa0>

00000000800016a6 <copyin>:
  while (len > 0) {
    800016a6:	cf41                	beqz	a4,8000173e <copyin+0x98>
{
    800016a8:	711d                	addi	sp,sp,-96
    800016aa:	ec86                	sd	ra,88(sp)
    800016ac:	e8a2                	sd	s0,80(sp)
    800016ae:	e4a6                	sd	s1,72(sp)
    800016b0:	e0ca                	sd	s2,64(sp)
    800016b2:	fc4e                	sd	s3,56(sp)
    800016b4:	f852                	sd	s4,48(sp)
    800016b6:	f456                	sd	s5,40(sp)
    800016b8:	f05a                	sd	s6,32(sp)
    800016ba:	ec5e                	sd	s7,24(sp)
    800016bc:	e862                	sd	s8,16(sp)
    800016be:	e466                	sd	s9,8(sp)
    800016c0:	e06a                	sd	s10,0(sp)
    800016c2:	1080                	addi	s0,sp,96
    800016c4:	8baa                	mv	s7,a0
    800016c6:	8cae                	mv	s9,a1
    800016c8:	8ab2                	mv	s5,a2
    800016ca:	8936                	mv	s2,a3
    800016cc:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(srcva);
    800016ce:	7c7d                	lui	s8,0xfffff
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    800016d0:	4d05                	li	s10,1
    n = PGSIZE - (srcva - va0);
    800016d2:	6b05                	lui	s6,0x1
    800016d4:	a035                	j	80001700 <copyin+0x5a>
    800016d6:	412984b3          	sub	s1,s3,s2
    800016da:	94da                	add	s1,s1,s6
    if (n > len)
    800016dc:	009a7363          	bgeu	s4,s1,800016e2 <copyin+0x3c>
    800016e0:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800016e2:	413905b3          	sub	a1,s2,s3
    800016e6:	0004861b          	sext.w	a2,s1
    800016ea:	95aa                	add	a1,a1,a0
    800016ec:	8556                	mv	a0,s5
    800016ee:	dc2ff0ef          	jal	80000cb0 <memmove>
    len -= n;
    800016f2:	409a0a33          	sub	s4,s4,s1
    dst += n;
    800016f6:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    800016f8:	01698933          	add	s2,s3,s6
  while (len > 0) {
    800016fc:	020a0263          	beqz	s4,80001720 <copyin+0x7a>
    va0 = PGROUNDDOWN(srcva);
    80001700:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001704:	85ce                	mv	a1,s3
    80001706:	855e                	mv	a0,s7
    80001708:	92bff0ef          	jal	80001032 <walkaddr>
    if (pa0 == 0) {
    8000170c:	f569                	bnez	a0,800016d6 <copyin+0x30>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    8000170e:	86ea                	mv	a3,s10
    80001710:	864e                	mv	a2,s3
    80001712:	85e6                	mv	a1,s9
    80001714:	855e                	mv	a0,s7
    80001716:	e4fff0ef          	jal	80001564 <vmfault>
    8000171a:	fd55                	bnez	a0,800016d6 <copyin+0x30>
        return -1;
    8000171c:	557d                	li	a0,-1
    8000171e:	a011                	j	80001722 <copyin+0x7c>
  return 0;
    80001720:	4501                	li	a0,0
}
    80001722:	60e6                	ld	ra,88(sp)
    80001724:	6446                	ld	s0,80(sp)
    80001726:	64a6                	ld	s1,72(sp)
    80001728:	6906                	ld	s2,64(sp)
    8000172a:	79e2                	ld	s3,56(sp)
    8000172c:	7a42                	ld	s4,48(sp)
    8000172e:	7aa2                	ld	s5,40(sp)
    80001730:	7b02                	ld	s6,32(sp)
    80001732:	6be2                	ld	s7,24(sp)
    80001734:	6c42                	ld	s8,16(sp)
    80001736:	6ca2                	ld	s9,8(sp)
    80001738:	6d02                	ld	s10,0(sp)
    8000173a:	6125                	addi	sp,sp,96
    8000173c:	8082                	ret
  return 0;
    8000173e:	4501                	li	a0,0
}
    80001740:	8082                	ret

0000000080001742 <copyinstr>:
{
    80001742:	711d                	addi	sp,sp,-96
    80001744:	ec86                	sd	ra,88(sp)
    80001746:	e8a2                	sd	s0,80(sp)
    80001748:	e4a6                	sd	s1,72(sp)
    8000174a:	e0ca                	sd	s2,64(sp)
    8000174c:	fc4e                	sd	s3,56(sp)
    8000174e:	f852                	sd	s4,48(sp)
    80001750:	f456                	sd	s5,40(sp)
    80001752:	f05a                	sd	s6,32(sp)
    80001754:	ec5e                	sd	s7,24(sp)
    80001756:	e862                	sd	s8,16(sp)
    80001758:	e466                	sd	s9,8(sp)
    8000175a:	1080                	addi	s0,sp,96
    8000175c:	8aaa                	mv	s5,a0
    8000175e:	8bae                	mv	s7,a1
    80001760:	89b2                	mv	s3,a2
    80001762:	8cb6                	mv	s9,a3
    80001764:	84ba                	mv	s1,a4
    va0 = PGROUNDDOWN(srcva);
    80001766:	7b7d                	lui	s6,0xfffff
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    80001768:	4c05                	li	s8,1
    n = PGSIZE - (srcva - va0);
    8000176a:	6a05                	lui	s4,0x1
    8000176c:	a081                	j	800017ac <copyinstr+0x6a>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    8000176e:	86e2                	mv	a3,s8
    80001770:	864a                	mv	a2,s2
    80001772:	85de                	mv	a1,s7
    80001774:	8556                	mv	a0,s5
    80001776:	defff0ef          	jal	80001564 <vmfault>
    8000177a:	e129                	bnez	a0,800017bc <copyinstr+0x7a>
        return -1;
    8000177c:	557d                	li	a0,-1
    8000177e:	a801                	j	8000178e <copyinstr+0x4c>
        *dst = '\0';
    80001780:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffde210>
    80001784:	4785                	li	a5,1
  if (got_null) {
    80001786:	0017c793          	xori	a5,a5,1
    8000178a:	40f0053b          	negw	a0,a5
}
    8000178e:	60e6                	ld	ra,88(sp)
    80001790:	6446                	ld	s0,80(sp)
    80001792:	64a6                	ld	s1,72(sp)
    80001794:	6906                	ld	s2,64(sp)
    80001796:	79e2                	ld	s3,56(sp)
    80001798:	7a42                	ld	s4,48(sp)
    8000179a:	7aa2                	ld	s5,40(sp)
    8000179c:	7b02                	ld	s6,32(sp)
    8000179e:	6be2                	ld	s7,24(sp)
    800017a0:	6c42                	ld	s8,16(sp)
    800017a2:	6ca2                	ld	s9,8(sp)
    800017a4:	6125                	addi	sp,sp,96
    800017a6:	8082                	ret
    srcva = va0 + PGSIZE;
    800017a8:	01490cb3          	add	s9,s2,s4
  while (got_null == 0 && max > 0) {
    800017ac:	c4b1                	beqz	s1,800017f8 <copyinstr+0xb6>
    va0 = PGROUNDDOWN(srcva);
    800017ae:	016cf933          	and	s2,s9,s6
    pa0 = walkaddr(pagetable, va0);
    800017b2:	85ca                	mv	a1,s2
    800017b4:	8556                	mv	a0,s5
    800017b6:	87dff0ef          	jal	80001032 <walkaddr>
    if (pa0 == 0) {
    800017ba:	d955                	beqz	a0,8000176e <copyinstr+0x2c>
    n = PGSIZE - (srcva - va0);
    800017bc:	41990733          	sub	a4,s2,s9
    800017c0:	9752                	add	a4,a4,s4
    if (n > max)
    800017c2:	00e4f363          	bgeu	s1,a4,800017c8 <copyinstr+0x86>
    800017c6:	8726                	mv	a4,s1
    char *p = (char *)(pa0 + (srcva - va0));
    800017c8:	412c8cb3          	sub	s9,s9,s2
    800017cc:	9caa                	add	s9,s9,a0
    while (n > 0) {
    800017ce:	df69                	beqz	a4,800017a8 <copyinstr+0x66>
    800017d0:	87ce                	mv	a5,s3
      if (*p == '\0') {
    800017d2:	413c8633          	sub	a2,s9,s3
    while (n > 0) {
    800017d6:	974e                	add	a4,a4,s3
    800017d8:	85be                	mv	a1,a5
      if (*p == '\0') {
    800017da:	00f606b3          	add	a3,a2,a5
    800017de:	0006c683          	lbu	a3,0(a3) # fffffffffffff000 <end+0xffffffff7ffde210>
    800017e2:	ded9                	beqz	a3,80001780 <copyinstr+0x3e>
        *dst = *p;
    800017e4:	00d78023          	sb	a3,0(a5)
      dst++;
    800017e8:	0785                	addi	a5,a5,1
    while (n > 0) {
    800017ea:	fee797e3          	bne	a5,a4,800017d8 <copyinstr+0x96>
    800017ee:	14fd                	addi	s1,s1,-1
    800017f0:	94ce                	add	s1,s1,s3
      --max;
    800017f2:	8c8d                	sub	s1,s1,a1
    800017f4:	89be                	mv	s3,a5
    800017f6:	bf4d                	j	800017a8 <copyinstr+0x66>
    800017f8:	4781                	li	a5,0
    800017fa:	b771                	j	80001786 <copyinstr+0x44>

00000000800017fc <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800017fc:	715d                	addi	sp,sp,-80
    800017fe:	e486                	sd	ra,72(sp)
    80001800:	e0a2                	sd	s0,64(sp)
    80001802:	fc26                	sd	s1,56(sp)
    80001804:	f84a                	sd	s2,48(sp)
    80001806:	f44e                	sd	s3,40(sp)
    80001808:	f052                	sd	s4,32(sp)
    8000180a:	ec56                	sd	s5,24(sp)
    8000180c:	e85a                	sd	s6,16(sp)
    8000180e:	e45e                	sd	s7,8(sp)
    80001810:	e062                	sd	s8,0(sp)
    80001812:	0880                	addi	s0,sp,80
    80001814:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001816:	0000e497          	auipc	s1,0xe
    8000181a:	5fa48493          	addi	s1,s1,1530 # 8000fe10 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    8000181e:	8c26                	mv	s8,s1
    80001820:	e9bd37b7          	lui	a5,0xe9bd3
    80001824:	7a778793          	addi	a5,a5,1959 # ffffffffe9bd37a7 <end+0xffffffff69bb29b7>
    80001828:	d37a7937          	lui	s2,0xd37a7
    8000182c:	f4e90913          	addi	s2,s2,-178 # ffffffffd37a6f4e <end+0xffffffff5378615e>
    80001830:	1902                	slli	s2,s2,0x20
    80001832:	993e                	add	s2,s2,a5
    80001834:	040009b7          	lui	s3,0x4000
    80001838:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000183a:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000183c:	4b99                	li	s7,6
    8000183e:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    80001840:	00014a97          	auipc	s5,0x14
    80001844:	1d0a8a93          	addi	s5,s5,464 # 80015a10 <tickslock>
    char *pa = kalloc();
    80001848:	a7aff0ef          	jal	80000ac2 <kalloc>
    8000184c:	862a                	mv	a2,a0
    if (pa == 0)
    8000184e:	c121                	beqz	a0,8000188e <proc_mapstacks+0x92>
    uint64 va = KSTACK((int)(p - proc));
    80001850:	418485b3          	sub	a1,s1,s8
    80001854:	8591                	srai	a1,a1,0x4
    80001856:	032585b3          	mul	a1,a1,s2
    8000185a:	2585                	addiw	a1,a1,1
    8000185c:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001860:	875e                	mv	a4,s7
    80001862:	86da                	mv	a3,s6
    80001864:	40b985b3          	sub	a1,s3,a1
    80001868:	8552                	mv	a0,s4
    8000186a:	8bdff0ef          	jal	80001126 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000186e:	17048493          	addi	s1,s1,368
    80001872:	fd549be3          	bne	s1,s5,80001848 <proc_mapstacks+0x4c>
  }
}
    80001876:	60a6                	ld	ra,72(sp)
    80001878:	6406                	ld	s0,64(sp)
    8000187a:	74e2                	ld	s1,56(sp)
    8000187c:	7942                	ld	s2,48(sp)
    8000187e:	79a2                	ld	s3,40(sp)
    80001880:	7a02                	ld	s4,32(sp)
    80001882:	6ae2                	ld	s5,24(sp)
    80001884:	6b42                	ld	s6,16(sp)
    80001886:	6ba2                	ld	s7,8(sp)
    80001888:	6c02                	ld	s8,0(sp)
    8000188a:	6161                	addi	sp,sp,80
    8000188c:	8082                	ret
      panic("kalloc");
    8000188e:	00006517          	auipc	a0,0x6
    80001892:	8fa50513          	addi	a0,a0,-1798 # 80007188 <etext+0x188>
    80001896:	f59fe0ef          	jal	800007ee <panic>

000000008000189a <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000189a:	7139                	addi	sp,sp,-64
    8000189c:	fc06                	sd	ra,56(sp)
    8000189e:	f822                	sd	s0,48(sp)
    800018a0:	f426                	sd	s1,40(sp)
    800018a2:	f04a                	sd	s2,32(sp)
    800018a4:	ec4e                	sd	s3,24(sp)
    800018a6:	e852                	sd	s4,16(sp)
    800018a8:	e456                	sd	s5,8(sp)
    800018aa:	e05a                	sd	s6,0(sp)
    800018ac:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800018ae:	00006597          	auipc	a1,0x6
    800018b2:	8e258593          	addi	a1,a1,-1822 # 80007190 <etext+0x190>
    800018b6:	0000e517          	auipc	a0,0xe
    800018ba:	12a50513          	addi	a0,a0,298 # 8000f9e0 <pid_lock>
    800018be:	a54ff0ef          	jal	80000b12 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018c2:	00006597          	auipc	a1,0x6
    800018c6:	8d658593          	addi	a1,a1,-1834 # 80007198 <etext+0x198>
    800018ca:	0000e517          	auipc	a0,0xe
    800018ce:	12e50513          	addi	a0,a0,302 # 8000f9f8 <wait_lock>
    800018d2:	a40ff0ef          	jal	80000b12 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    800018d6:	0000e497          	auipc	s1,0xe
    800018da:	53a48493          	addi	s1,s1,1338 # 8000fe10 <proc>
    initlock(&p->lock, "proc");
    800018de:	00006b17          	auipc	s6,0x6
    800018e2:	8cab0b13          	addi	s6,s6,-1846 # 800071a8 <etext+0x1a8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    800018e6:	8aa6                	mv	s5,s1
    800018e8:	e9bd37b7          	lui	a5,0xe9bd3
    800018ec:	7a778793          	addi	a5,a5,1959 # ffffffffe9bd37a7 <end+0xffffffff69bb29b7>
    800018f0:	d37a7937          	lui	s2,0xd37a7
    800018f4:	f4e90913          	addi	s2,s2,-178 # ffffffffd37a6f4e <end+0xffffffff5378615e>
    800018f8:	1902                	slli	s2,s2,0x20
    800018fa:	993e                	add	s2,s2,a5
    800018fc:	040009b7          	lui	s3,0x4000
    80001900:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001902:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001904:	00014a17          	auipc	s4,0x14
    80001908:	10ca0a13          	addi	s4,s4,268 # 80015a10 <tickslock>
    initlock(&p->lock, "proc");
    8000190c:	85da                	mv	a1,s6
    8000190e:	8526                	mv	a0,s1
    80001910:	a02ff0ef          	jal	80000b12 <initlock>
    p->state = UNUSED;
    80001914:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001918:	415487b3          	sub	a5,s1,s5
    8000191c:	8791                	srai	a5,a5,0x4
    8000191e:	032787b3          	mul	a5,a5,s2
    80001922:	2785                	addiw	a5,a5,1
    80001924:	00d7979b          	slliw	a5,a5,0xd
    80001928:	40f987b3          	sub	a5,s3,a5
    8000192c:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    8000192e:	17048493          	addi	s1,s1,368
    80001932:	fd449de3          	bne	s1,s4,8000190c <procinit+0x72>
  }
}
    80001936:	70e2                	ld	ra,56(sp)
    80001938:	7442                	ld	s0,48(sp)
    8000193a:	74a2                	ld	s1,40(sp)
    8000193c:	7902                	ld	s2,32(sp)
    8000193e:	69e2                	ld	s3,24(sp)
    80001940:	6a42                	ld	s4,16(sp)
    80001942:	6aa2                	ld	s5,8(sp)
    80001944:	6b02                	ld	s6,0(sp)
    80001946:	6121                	addi	sp,sp,64
    80001948:	8082                	ret

000000008000194a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000194a:	1141                	addi	sp,sp,-16
    8000194c:	e406                	sd	ra,8(sp)
    8000194e:	e022                	sd	s0,0(sp)
    80001950:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    80001952:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001954:	2501                	sext.w	a0,a0
    80001956:	60a2                	ld	ra,8(sp)
    80001958:	6402                	ld	s0,0(sp)
    8000195a:	0141                	addi	sp,sp,16
    8000195c:	8082                	ret

000000008000195e <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    8000195e:	1141                	addi	sp,sp,-16
    80001960:	e406                	sd	ra,8(sp)
    80001962:	e022                	sd	s0,0(sp)
    80001964:	0800                	addi	s0,sp,16
    80001966:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001968:	2781                	sext.w	a5,a5
    8000196a:	079e                	slli	a5,a5,0x7
  return c;
}
    8000196c:	0000e517          	auipc	a0,0xe
    80001970:	0a450513          	addi	a0,a0,164 # 8000fa10 <cpus>
    80001974:	953e                	add	a0,a0,a5
    80001976:	60a2                	ld	ra,8(sp)
    80001978:	6402                	ld	s0,0(sp)
    8000197a:	0141                	addi	sp,sp,16
    8000197c:	8082                	ret

000000008000197e <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    8000197e:	1101                	addi	sp,sp,-32
    80001980:	ec06                	sd	ra,24(sp)
    80001982:	e822                	sd	s0,16(sp)
    80001984:	e426                	sd	s1,8(sp)
    80001986:	1000                	addi	s0,sp,32
  push_off();
    80001988:	9ceff0ef          	jal	80000b56 <push_off>
    8000198c:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    8000198e:	2781                	sext.w	a5,a5
    80001990:	079e                	slli	a5,a5,0x7
    80001992:	0000e717          	auipc	a4,0xe
    80001996:	04e70713          	addi	a4,a4,78 # 8000f9e0 <pid_lock>
    8000199a:	97ba                	add	a5,a5,a4
    8000199c:	7b84                	ld	s1,48(a5)
  pop_off();
    8000199e:	a2eff0ef          	jal	80000bcc <pop_off>
  return p;
}
    800019a2:	8526                	mv	a0,s1
    800019a4:	60e2                	ld	ra,24(sp)
    800019a6:	6442                	ld	s0,16(sp)
    800019a8:	64a2                	ld	s1,8(sp)
    800019aa:	6105                	addi	sp,sp,32
    800019ac:	8082                	ret

00000000800019ae <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019ae:	7179                	addi	sp,sp,-48
    800019b0:	f406                	sd	ra,40(sp)
    800019b2:	f022                	sd	s0,32(sp)
    800019b4:	ec26                	sd	s1,24(sp)
    800019b6:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    800019b8:	fc7ff0ef          	jal	8000197e <myproc>
    800019bc:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    800019be:	a56ff0ef          	jal	80000c14 <release>

  if (first) {
    800019c2:	00006797          	auipc	a5,0x6
    800019c6:	ece7a783          	lw	a5,-306(a5) # 80007890 <first.1>
    800019ca:	cb9d                	beqz	a5,80001a00 <forkret+0x52>
    first = 0;
    800019cc:	00006797          	auipc	a5,0x6
    800019d0:	ec07a223          	sw	zero,-316(a5) # 80007890 <first.1>

    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800019d4:	4505                	li	a0,1
    800019d6:	589010ef          	jal	8000375e <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    800019da:	00005517          	auipc	a0,0x5
    800019de:	7d650513          	addi	a0,a0,2006 # 800071b0 <etext+0x1b0>
    800019e2:	fca43823          	sd	a0,-48(s0)
    800019e6:	fc043c23          	sd	zero,-40(s0)
    800019ea:	fd040593          	addi	a1,s0,-48
    800019ee:	7d3020ef          	jal	800049c0 <kexec>
    800019f2:	6cbc                	ld	a5,88(s1)
    800019f4:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    800019f6:	6cbc                	ld	a5,88(s1)
    800019f8:	7bb8                	ld	a4,112(a5)
    800019fa:	57fd                	li	a5,-1
    800019fc:	02f70d63          	beq	a4,a5,80001a36 <forkret+0x88>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001a00:	37d000ef          	jal	8000257c <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001a04:	68a8                	ld	a0,80(s1)
    80001a06:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001a08:	04000737          	lui	a4,0x4000
    80001a0c:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001a0e:	0732                	slli	a4,a4,0xc
    80001a10:	00004797          	auipc	a5,0x4
    80001a14:	68c78793          	addi	a5,a5,1676 # 8000609c <userret>
    80001a18:	00004697          	auipc	a3,0x4
    80001a1c:	5e868693          	addi	a3,a3,1512 # 80006000 <_trampoline>
    80001a20:	8f95                	sub	a5,a5,a3
    80001a22:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001a24:	577d                	li	a4,-1
    80001a26:	177e                	slli	a4,a4,0x3f
    80001a28:	8d59                	or	a0,a0,a4
    80001a2a:	9782                	jalr	a5
}
    80001a2c:	70a2                	ld	ra,40(sp)
    80001a2e:	7402                	ld	s0,32(sp)
    80001a30:	64e2                	ld	s1,24(sp)
    80001a32:	6145                	addi	sp,sp,48
    80001a34:	8082                	ret
      panic("exec");
    80001a36:	00005517          	auipc	a0,0x5
    80001a3a:	78250513          	addi	a0,a0,1922 # 800071b8 <etext+0x1b8>
    80001a3e:	db1fe0ef          	jal	800007ee <panic>

0000000080001a42 <allocpid>:
{
    80001a42:	1101                	addi	sp,sp,-32
    80001a44:	ec06                	sd	ra,24(sp)
    80001a46:	e822                	sd	s0,16(sp)
    80001a48:	e426                	sd	s1,8(sp)
    80001a4a:	e04a                	sd	s2,0(sp)
    80001a4c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a4e:	0000e917          	auipc	s2,0xe
    80001a52:	f9290913          	addi	s2,s2,-110 # 8000f9e0 <pid_lock>
    80001a56:	854a                	mv	a0,s2
    80001a58:	934ff0ef          	jal	80000b8c <acquire>
  pid = nextpid;
    80001a5c:	00006797          	auipc	a5,0x6
    80001a60:	e3878793          	addi	a5,a5,-456 # 80007894 <nextpid>
    80001a64:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a66:	0014871b          	addiw	a4,s1,1
    80001a6a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a6c:	854a                	mv	a0,s2
    80001a6e:	9a6ff0ef          	jal	80000c14 <release>
}
    80001a72:	8526                	mv	a0,s1
    80001a74:	60e2                	ld	ra,24(sp)
    80001a76:	6442                	ld	s0,16(sp)
    80001a78:	64a2                	ld	s1,8(sp)
    80001a7a:	6902                	ld	s2,0(sp)
    80001a7c:	6105                	addi	sp,sp,32
    80001a7e:	8082                	ret

0000000080001a80 <proc_pagetable>:
{
    80001a80:	1101                	addi	sp,sp,-32
    80001a82:	ec06                	sd	ra,24(sp)
    80001a84:	e822                	sd	s0,16(sp)
    80001a86:	e426                	sd	s1,8(sp)
    80001a88:	e04a                	sd	s2,0(sp)
    80001a8a:	1000                	addi	s0,sp,32
    80001a8c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a8e:	f88ff0ef          	jal	80001216 <uvmcreate>
    80001a92:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001a94:	c929                	beqz	a0,80001ae6 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001a96:	4729                	li	a4,10
    80001a98:	00004697          	auipc	a3,0x4
    80001a9c:	56868693          	addi	a3,a3,1384 # 80006000 <_trampoline>
    80001aa0:	6605                	lui	a2,0x1
    80001aa2:	040005b7          	lui	a1,0x4000
    80001aa6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aa8:	05b2                	slli	a1,a1,0xc
    80001aaa:	dc6ff0ef          	jal	80001070 <mappages>
    80001aae:	04054363          	bltz	a0,80001af4 <proc_pagetable+0x74>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001ab2:	4719                	li	a4,6
    80001ab4:	05893683          	ld	a3,88(s2)
    80001ab8:	6605                	lui	a2,0x1
    80001aba:	020005b7          	lui	a1,0x2000
    80001abe:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ac0:	05b6                	slli	a1,a1,0xd
    80001ac2:	8526                	mv	a0,s1
    80001ac4:	dacff0ef          	jal	80001070 <mappages>
    80001ac8:	02054c63          	bltz	a0,80001b00 <proc_pagetable+0x80>
  if (mappages(pagetable, USYSCALL, PGSIZE, (uint64)(p->usyscall),
    80001acc:	4749                	li	a4,18
    80001ace:	06093683          	ld	a3,96(s2)
    80001ad2:	6605                	lui	a2,0x1
    80001ad4:	040005b7          	lui	a1,0x4000
    80001ad8:	15f5                	addi	a1,a1,-3 # 3fffffd <_entry-0x7c000003>
    80001ada:	05b2                	slli	a1,a1,0xc
    80001adc:	8526                	mv	a0,s1
    80001ade:	d92ff0ef          	jal	80001070 <mappages>
    80001ae2:	02054e63          	bltz	a0,80001b1e <proc_pagetable+0x9e>
}
    80001ae6:	8526                	mv	a0,s1
    80001ae8:	60e2                	ld	ra,24(sp)
    80001aea:	6442                	ld	s0,16(sp)
    80001aec:	64a2                	ld	s1,8(sp)
    80001aee:	6902                	ld	s2,0(sp)
    80001af0:	6105                	addi	sp,sp,32
    80001af2:	8082                	ret
    uvmfree(pagetable, 0);
    80001af4:	4581                	li	a1,0
    80001af6:	8526                	mv	a0,s1
    80001af8:	94fff0ef          	jal	80001446 <uvmfree>
    return 0;
    80001afc:	4481                	li	s1,0
    80001afe:	b7e5                	j	80001ae6 <proc_pagetable+0x66>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b00:	4681                	li	a3,0
    80001b02:	4605                	li	a2,1
    80001b04:	040005b7          	lui	a1,0x4000
    80001b08:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b0a:	05b2                	slli	a1,a1,0xc
    80001b0c:	8526                	mv	a0,s1
    80001b0e:	f2eff0ef          	jal	8000123c <uvmunmap>
    uvmfree(pagetable, 0);
    80001b12:	4581                	li	a1,0
    80001b14:	8526                	mv	a0,s1
    80001b16:	931ff0ef          	jal	80001446 <uvmfree>
    return 0;
    80001b1a:	4481                	li	s1,0
    80001b1c:	b7e9                	j	80001ae6 <proc_pagetable+0x66>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b1e:	4681                	li	a3,0
    80001b20:	4605                	li	a2,1
    80001b22:	020005b7          	lui	a1,0x2000
    80001b26:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b28:	05b6                	slli	a1,a1,0xd
    80001b2a:	8526                	mv	a0,s1
    80001b2c:	f10ff0ef          	jal	8000123c <uvmunmap>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b30:	4681                	li	a3,0
    80001b32:	4605                	li	a2,1
    80001b34:	040005b7          	lui	a1,0x4000
    80001b38:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b3a:	05b2                	slli	a1,a1,0xc
    80001b3c:	8526                	mv	a0,s1
    80001b3e:	efeff0ef          	jal	8000123c <uvmunmap>
    uvmfree(pagetable, 0);
    80001b42:	4581                	li	a1,0
    80001b44:	8526                	mv	a0,s1
    80001b46:	901ff0ef          	jal	80001446 <uvmfree>
    return 0;
    80001b4a:	4481                	li	s1,0
    80001b4c:	bf69                	j	80001ae6 <proc_pagetable+0x66>

0000000080001b4e <proc_freepagetable>:
{
    80001b4e:	1101                	addi	sp,sp,-32
    80001b50:	ec06                	sd	ra,24(sp)
    80001b52:	e822                	sd	s0,16(sp)
    80001b54:	e426                	sd	s1,8(sp)
    80001b56:	e04a                	sd	s2,0(sp)
    80001b58:	1000                	addi	s0,sp,32
    80001b5a:	84aa                	mv	s1,a0
    80001b5c:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b5e:	4681                	li	a3,0
    80001b60:	4605                	li	a2,1
    80001b62:	040005b7          	lui	a1,0x4000
    80001b66:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b68:	05b2                	slli	a1,a1,0xc
    80001b6a:	ed2ff0ef          	jal	8000123c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b6e:	4681                	li	a3,0
    80001b70:	4605                	li	a2,1
    80001b72:	020005b7          	lui	a1,0x2000
    80001b76:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b78:	05b6                	slli	a1,a1,0xd
    80001b7a:	8526                	mv	a0,s1
    80001b7c:	ec0ff0ef          	jal	8000123c <uvmunmap>
  uvmunmap(pagetable, USYSCALL, 1, 0);
    80001b80:	4681                	li	a3,0
    80001b82:	4605                	li	a2,1
    80001b84:	040005b7          	lui	a1,0x4000
    80001b88:	15f5                	addi	a1,a1,-3 # 3fffffd <_entry-0x7c000003>
    80001b8a:	05b2                	slli	a1,a1,0xc
    80001b8c:	8526                	mv	a0,s1
    80001b8e:	eaeff0ef          	jal	8000123c <uvmunmap>
  uvmfree(pagetable, sz);
    80001b92:	85ca                	mv	a1,s2
    80001b94:	8526                	mv	a0,s1
    80001b96:	8b1ff0ef          	jal	80001446 <uvmfree>
}
    80001b9a:	60e2                	ld	ra,24(sp)
    80001b9c:	6442                	ld	s0,16(sp)
    80001b9e:	64a2                	ld	s1,8(sp)
    80001ba0:	6902                	ld	s2,0(sp)
    80001ba2:	6105                	addi	sp,sp,32
    80001ba4:	8082                	ret

0000000080001ba6 <freeproc>:
{
    80001ba6:	1101                	addi	sp,sp,-32
    80001ba8:	ec06                	sd	ra,24(sp)
    80001baa:	e822                	sd	s0,16(sp)
    80001bac:	e426                	sd	s1,8(sp)
    80001bae:	1000                	addi	s0,sp,32
    80001bb0:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001bb2:	6d28                	ld	a0,88(a0)
    80001bb4:	c119                	beqz	a0,80001bba <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001bb6:	e2bfe0ef          	jal	800009e0 <kfree>
  p->trapframe = 0;
    80001bba:	0404bc23          	sd	zero,88(s1)
  if (p->usyscall)
    80001bbe:	70a8                	ld	a0,96(s1)
    80001bc0:	c119                	beqz	a0,80001bc6 <freeproc+0x20>
    kfree((void *)p->usyscall);
    80001bc2:	e1ffe0ef          	jal	800009e0 <kfree>
  p->usyscall = 0;
    80001bc6:	0604b023          	sd	zero,96(s1)
  if (p->pagetable)
    80001bca:	68a8                	ld	a0,80(s1)
    80001bcc:	c501                	beqz	a0,80001bd4 <freeproc+0x2e>
    proc_freepagetable(p->pagetable, p->sz);
    80001bce:	64ac                	ld	a1,72(s1)
    80001bd0:	f7fff0ef          	jal	80001b4e <proc_freepagetable>
  p->pagetable = 0;
    80001bd4:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bd8:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bdc:	0204a823          	sw	zero,48(s1)
  p->name[0] = 0;
    80001be0:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001be4:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001be8:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bec:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bf0:	0004ac23          	sw	zero,24(s1)
}
    80001bf4:	60e2                	ld	ra,24(sp)
    80001bf6:	6442                	ld	s0,16(sp)
    80001bf8:	64a2                	ld	s1,8(sp)
    80001bfa:	6105                	addi	sp,sp,32
    80001bfc:	8082                	ret

0000000080001bfe <allocproc>:
{
    80001bfe:	1101                	addi	sp,sp,-32
    80001c00:	ec06                	sd	ra,24(sp)
    80001c02:	e822                	sd	s0,16(sp)
    80001c04:	e426                	sd	s1,8(sp)
    80001c06:	e04a                	sd	s2,0(sp)
    80001c08:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001c0a:	0000e497          	auipc	s1,0xe
    80001c0e:	20648493          	addi	s1,s1,518 # 8000fe10 <proc>
    80001c12:	00014917          	auipc	s2,0x14
    80001c16:	dfe90913          	addi	s2,s2,-514 # 80015a10 <tickslock>
    acquire(&p->lock);
    80001c1a:	8526                	mv	a0,s1
    80001c1c:	f71fe0ef          	jal	80000b8c <acquire>
    if (p->state == UNUSED) {
    80001c20:	4c9c                	lw	a5,24(s1)
    80001c22:	cb91                	beqz	a5,80001c36 <allocproc+0x38>
      release(&p->lock);
    80001c24:	8526                	mv	a0,s1
    80001c26:	feffe0ef          	jal	80000c14 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001c2a:	17048493          	addi	s1,s1,368
    80001c2e:	ff2496e3          	bne	s1,s2,80001c1a <allocproc+0x1c>
  return 0;
    80001c32:	4481                	li	s1,0
    80001c34:	a881                	j	80001c84 <allocproc+0x86>
  p->pid = allocpid();
    80001c36:	e0dff0ef          	jal	80001a42 <allocpid>
    80001c3a:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c3c:	4785                	li	a5,1
    80001c3e:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001c40:	e83fe0ef          	jal	80000ac2 <kalloc>
    80001c44:	892a                	mv	s2,a0
    80001c46:	eca8                	sd	a0,88(s1)
    80001c48:	c529                	beqz	a0,80001c92 <allocproc+0x94>
  if ((p->usyscall = (struct usyscall *)kalloc()) == 0) {
    80001c4a:	e79fe0ef          	jal	80000ac2 <kalloc>
    80001c4e:	892a                	mv	s2,a0
    80001c50:	f0a8                	sd	a0,96(s1)
    80001c52:	c921                	beqz	a0,80001ca2 <allocproc+0xa4>
  p->usyscall->pid = p->pid;
    80001c54:	589c                	lw	a5,48(s1)
    80001c56:	c11c                	sw	a5,0(a0)
  p->pagetable = proc_pagetable(p);
    80001c58:	8526                	mv	a0,s1
    80001c5a:	e27ff0ef          	jal	80001a80 <proc_pagetable>
    80001c5e:	892a                	mv	s2,a0
    80001c60:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001c62:	c921                	beqz	a0,80001cb2 <allocproc+0xb4>
  memset(&p->context, 0, sizeof(p->context));
    80001c64:	07000613          	li	a2,112
    80001c68:	4581                	li	a1,0
    80001c6a:	06848513          	addi	a0,s1,104
    80001c6e:	fdffe0ef          	jal	80000c4c <memset>
  p->context.ra = (uint64)forkret;
    80001c72:	00000797          	auipc	a5,0x0
    80001c76:	d3c78793          	addi	a5,a5,-708 # 800019ae <forkret>
    80001c7a:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c7c:	60bc                	ld	a5,64(s1)
    80001c7e:	6705                	lui	a4,0x1
    80001c80:	97ba                	add	a5,a5,a4
    80001c82:	f8bc                	sd	a5,112(s1)
}
    80001c84:	8526                	mv	a0,s1
    80001c86:	60e2                	ld	ra,24(sp)
    80001c88:	6442                	ld	s0,16(sp)
    80001c8a:	64a2                	ld	s1,8(sp)
    80001c8c:	6902                	ld	s2,0(sp)
    80001c8e:	6105                	addi	sp,sp,32
    80001c90:	8082                	ret
    freeproc(p);
    80001c92:	8526                	mv	a0,s1
    80001c94:	f13ff0ef          	jal	80001ba6 <freeproc>
    release(&p->lock);
    80001c98:	8526                	mv	a0,s1
    80001c9a:	f7bfe0ef          	jal	80000c14 <release>
    return 0;
    80001c9e:	84ca                	mv	s1,s2
    80001ca0:	b7d5                	j	80001c84 <allocproc+0x86>
    freeproc(p);
    80001ca2:	8526                	mv	a0,s1
    80001ca4:	f03ff0ef          	jal	80001ba6 <freeproc>
    release(&p->lock);
    80001ca8:	8526                	mv	a0,s1
    80001caa:	f6bfe0ef          	jal	80000c14 <release>
    return 0;
    80001cae:	84ca                	mv	s1,s2
    80001cb0:	bfd1                	j	80001c84 <allocproc+0x86>
    freeproc(p);
    80001cb2:	8526                	mv	a0,s1
    80001cb4:	ef3ff0ef          	jal	80001ba6 <freeproc>
    release(&p->lock);
    80001cb8:	8526                	mv	a0,s1
    80001cba:	f5bfe0ef          	jal	80000c14 <release>
    return 0;
    80001cbe:	84ca                	mv	s1,s2
    80001cc0:	b7d1                	j	80001c84 <allocproc+0x86>

0000000080001cc2 <userinit>:
{
    80001cc2:	1101                	addi	sp,sp,-32
    80001cc4:	ec06                	sd	ra,24(sp)
    80001cc6:	e822                	sd	s0,16(sp)
    80001cc8:	e426                	sd	s1,8(sp)
    80001cca:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ccc:	f33ff0ef          	jal	80001bfe <allocproc>
    80001cd0:	84aa                	mv	s1,a0
  initproc = p;
    80001cd2:	00006797          	auipc	a5,0x6
    80001cd6:	bea7b323          	sd	a0,-1050(a5) # 800078b8 <initproc>
  p->cwd = namei("/");
    80001cda:	00005517          	auipc	a0,0x5
    80001cde:	4e650513          	addi	a0,a0,1254 # 800071c0 <etext+0x1c0>
    80001ce2:	7cb010ef          	jal	80003cac <namei>
    80001ce6:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001cea:	478d                	li	a5,3
    80001cec:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cee:	8526                	mv	a0,s1
    80001cf0:	f25fe0ef          	jal	80000c14 <release>
}
    80001cf4:	60e2                	ld	ra,24(sp)
    80001cf6:	6442                	ld	s0,16(sp)
    80001cf8:	64a2                	ld	s1,8(sp)
    80001cfa:	6105                	addi	sp,sp,32
    80001cfc:	8082                	ret

0000000080001cfe <growproc>:
{
    80001cfe:	1101                	addi	sp,sp,-32
    80001d00:	ec06                	sd	ra,24(sp)
    80001d02:	e822                	sd	s0,16(sp)
    80001d04:	e426                	sd	s1,8(sp)
    80001d06:	e04a                	sd	s2,0(sp)
    80001d08:	1000                	addi	s0,sp,32
    80001d0a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d0c:	c73ff0ef          	jal	8000197e <myproc>
    80001d10:	892a                	mv	s2,a0
  sz = p->sz;
    80001d12:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001d14:	02905963          	blez	s1,80001d46 <growproc+0x48>
    if (sz + n > USYSCALL) {
    80001d18:	00b48633          	add	a2,s1,a1
    80001d1c:	040007b7          	lui	a5,0x4000
    80001d20:	17f5                	addi	a5,a5,-3 # 3fffffd <_entry-0x7c000003>
    80001d22:	07b2                	slli	a5,a5,0xc
    80001d24:	02c7ea63          	bltu	a5,a2,80001d58 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d28:	4691                	li	a3,4
    80001d2a:	6928                	ld	a0,80(a0)
    80001d2c:	ddeff0ef          	jal	8000130a <uvmalloc>
    80001d30:	85aa                	mv	a1,a0
    80001d32:	c50d                	beqz	a0,80001d5c <growproc+0x5e>
  p->sz = sz;
    80001d34:	04b93423          	sd	a1,72(s2)
  return 0;
    80001d38:	4501                	li	a0,0
}
    80001d3a:	60e2                	ld	ra,24(sp)
    80001d3c:	6442                	ld	s0,16(sp)
    80001d3e:	64a2                	ld	s1,8(sp)
    80001d40:	6902                	ld	s2,0(sp)
    80001d42:	6105                	addi	sp,sp,32
    80001d44:	8082                	ret
  } else if (n < 0) {
    80001d46:	fe04d7e3          	bgez	s1,80001d34 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d4a:	00b48633          	add	a2,s1,a1
    80001d4e:	6928                	ld	a0,80(a0)
    80001d50:	d76ff0ef          	jal	800012c6 <uvmdealloc>
    80001d54:	85aa                	mv	a1,a0
    80001d56:	bff9                	j	80001d34 <growproc+0x36>
      return -1;
    80001d58:	557d                	li	a0,-1
    80001d5a:	b7c5                	j	80001d3a <growproc+0x3c>
      return -1;
    80001d5c:	557d                	li	a0,-1
    80001d5e:	bff1                	j	80001d3a <growproc+0x3c>

0000000080001d60 <kfork>:
{
    80001d60:	7139                	addi	sp,sp,-64
    80001d62:	fc06                	sd	ra,56(sp)
    80001d64:	f822                	sd	s0,48(sp)
    80001d66:	f04a                	sd	s2,32(sp)
    80001d68:	e456                	sd	s5,8(sp)
    80001d6a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d6c:	c13ff0ef          	jal	8000197e <myproc>
    80001d70:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001d72:	e8dff0ef          	jal	80001bfe <allocproc>
    80001d76:	0e050a63          	beqz	a0,80001e6a <kfork+0x10a>
    80001d7a:	e852                	sd	s4,16(sp)
    80001d7c:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001d7e:	048ab603          	ld	a2,72(s5)
    80001d82:	692c                	ld	a1,80(a0)
    80001d84:	050ab503          	ld	a0,80(s5)
    80001d88:	ef0ff0ef          	jal	80001478 <uvmcopy>
    80001d8c:	04054a63          	bltz	a0,80001de0 <kfork+0x80>
    80001d90:	f426                	sd	s1,40(sp)
    80001d92:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001d94:	048ab783          	ld	a5,72(s5)
    80001d98:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001d9c:	058ab683          	ld	a3,88(s5)
    80001da0:	87b6                	mv	a5,a3
    80001da2:	058a3703          	ld	a4,88(s4)
    80001da6:	12068693          	addi	a3,a3,288
    80001daa:	0007b803          	ld	a6,0(a5)
    80001dae:	6788                	ld	a0,8(a5)
    80001db0:	6b8c                	ld	a1,16(a5)
    80001db2:	6f90                	ld	a2,24(a5)
    80001db4:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001db8:	e708                	sd	a0,8(a4)
    80001dba:	eb0c                	sd	a1,16(a4)
    80001dbc:	ef10                	sd	a2,24(a4)
    80001dbe:	02078793          	addi	a5,a5,32
    80001dc2:	02070713          	addi	a4,a4,32
    80001dc6:	fed792e3          	bne	a5,a3,80001daa <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001dca:	058a3783          	ld	a5,88(s4)
    80001dce:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001dd2:	0d8a8493          	addi	s1,s5,216
    80001dd6:	0d8a0913          	addi	s2,s4,216
    80001dda:	158a8993          	addi	s3,s5,344
    80001dde:	a831                	j	80001dfa <kfork+0x9a>
    freeproc(np);
    80001de0:	8552                	mv	a0,s4
    80001de2:	dc5ff0ef          	jal	80001ba6 <freeproc>
    release(&np->lock);
    80001de6:	8552                	mv	a0,s4
    80001de8:	e2dfe0ef          	jal	80000c14 <release>
    return -1;
    80001dec:	597d                	li	s2,-1
    80001dee:	6a42                	ld	s4,16(sp)
    80001df0:	a0b5                	j	80001e5c <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001df2:	04a1                	addi	s1,s1,8
    80001df4:	0921                	addi	s2,s2,8
    80001df6:	01348963          	beq	s1,s3,80001e08 <kfork+0xa8>
    if (p->ofile[i])
    80001dfa:	6088                	ld	a0,0(s1)
    80001dfc:	d97d                	beqz	a0,80001df2 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001dfe:	4f4020ef          	jal	800042f2 <filedup>
    80001e02:	00a93023          	sd	a0,0(s2)
    80001e06:	b7f5                	j	80001df2 <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001e08:	158ab503          	ld	a0,344(s5)
    80001e0c:	5e2010ef          	jal	800033ee <idup>
    80001e10:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e14:	4641                	li	a2,16
    80001e16:	160a8593          	addi	a1,s5,352
    80001e1a:	160a0513          	addi	a0,s4,352
    80001e1e:	f81fe0ef          	jal	80000d9e <safestrcpy>
  pid = np->pid;
    80001e22:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e26:	8552                	mv	a0,s4
    80001e28:	dedfe0ef          	jal	80000c14 <release>
  acquire(&wait_lock);
    80001e2c:	0000e497          	auipc	s1,0xe
    80001e30:	bcc48493          	addi	s1,s1,-1076 # 8000f9f8 <wait_lock>
    80001e34:	8526                	mv	a0,s1
    80001e36:	d57fe0ef          	jal	80000b8c <acquire>
  np->parent = p;
    80001e3a:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e3e:	8526                	mv	a0,s1
    80001e40:	dd5fe0ef          	jal	80000c14 <release>
  acquire(&np->lock);
    80001e44:	8552                	mv	a0,s4
    80001e46:	d47fe0ef          	jal	80000b8c <acquire>
  np->state = RUNNABLE;
    80001e4a:	478d                	li	a5,3
    80001e4c:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e50:	8552                	mv	a0,s4
    80001e52:	dc3fe0ef          	jal	80000c14 <release>
  return pid;
    80001e56:	74a2                	ld	s1,40(sp)
    80001e58:	69e2                	ld	s3,24(sp)
    80001e5a:	6a42                	ld	s4,16(sp)
}
    80001e5c:	854a                	mv	a0,s2
    80001e5e:	70e2                	ld	ra,56(sp)
    80001e60:	7442                	ld	s0,48(sp)
    80001e62:	7902                	ld	s2,32(sp)
    80001e64:	6aa2                	ld	s5,8(sp)
    80001e66:	6121                	addi	sp,sp,64
    80001e68:	8082                	ret
    return -1;
    80001e6a:	597d                	li	s2,-1
    80001e6c:	bfc5                	j	80001e5c <kfork+0xfc>

0000000080001e6e <scheduler>:
{
    80001e6e:	711d                	addi	sp,sp,-96
    80001e70:	ec86                	sd	ra,88(sp)
    80001e72:	e8a2                	sd	s0,80(sp)
    80001e74:	e4a6                	sd	s1,72(sp)
    80001e76:	e0ca                	sd	s2,64(sp)
    80001e78:	fc4e                	sd	s3,56(sp)
    80001e7a:	f852                	sd	s4,48(sp)
    80001e7c:	f456                	sd	s5,40(sp)
    80001e7e:	f05a                	sd	s6,32(sp)
    80001e80:	ec5e                	sd	s7,24(sp)
    80001e82:	e862                	sd	s8,16(sp)
    80001e84:	e466                	sd	s9,8(sp)
    80001e86:	1080                	addi	s0,sp,96
    80001e88:	8792                	mv	a5,tp
  int id = r_tp();
    80001e8a:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001e8c:	00779a93          	slli	s5,a5,0x7
    80001e90:	0000e717          	auipc	a4,0xe
    80001e94:	b5070713          	addi	a4,a4,-1200 # 8000f9e0 <pid_lock>
    80001e98:	9756                	add	a4,a4,s5
    80001e9a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001e9e:	0000e717          	auipc	a4,0xe
    80001ea2:	b7a70713          	addi	a4,a4,-1158 # 8000fa18 <cpus+0x8>
    80001ea6:	9aba                	add	s5,s5,a4
        p->state = RUNNING;
    80001ea8:	4c11                	li	s8,4
        c->proc = p;
    80001eaa:	0000eb17          	auipc	s6,0xe
    80001eae:	b36b0b13          	addi	s6,s6,-1226 # 8000f9e0 <pid_lock>
    80001eb2:	079e                	slli	a5,a5,0x7
    80001eb4:	00fb0a33          	add	s4,s6,a5
        found = 1;
    80001eb8:	4b85                	li	s7,1
    80001eba:	a0a9                	j	80001f04 <scheduler+0x96>
      release(&p->lock);
    80001ebc:	8526                	mv	a0,s1
    80001ebe:	d57fe0ef          	jal	80000c14 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001ec2:	17048493          	addi	s1,s1,368
    80001ec6:	03248b63          	beq	s1,s2,80001efc <scheduler+0x8e>
      acquire(&p->lock);
    80001eca:	8526                	mv	a0,s1
    80001ecc:	cc1fe0ef          	jal	80000b8c <acquire>
      if (p->state == RUNNABLE) {
    80001ed0:	4c9c                	lw	a5,24(s1)
    80001ed2:	ff3795e3          	bne	a5,s3,80001ebc <scheduler+0x4e>
        p->state = RUNNING;
    80001ed6:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001eda:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001ede:	06848593          	addi	a1,s1,104
    80001ee2:	8556                	mv	a0,s5
    80001ee4:	5ee000ef          	jal	800024d2 <swtch>
    80001ee8:	8792                	mv	a5,tp
        mycpu()->intena = 0;
    80001eea:	2781                	sext.w	a5,a5
    80001eec:	079e                	slli	a5,a5,0x7
    80001eee:	97da                	add	a5,a5,s6
    80001ef0:	0a07a623          	sw	zero,172(a5)
        c->proc = 0;
    80001ef4:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001ef8:	8cde                	mv	s9,s7
    80001efa:	b7c9                	j	80001ebc <scheduler+0x4e>
    if (found == 0) {
    80001efc:	000c9463          	bnez	s9,80001f04 <scheduler+0x96>
      asm volatile("wfi");
    80001f00:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001f04:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001f08:	10017073          	csrci	sstatus,2
    int found = 0;
    80001f0c:	4c81                	li	s9,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f0e:	0000e497          	auipc	s1,0xe
    80001f12:	f0248493          	addi	s1,s1,-254 # 8000fe10 <proc>
      if (p->state == RUNNABLE) {
    80001f16:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f18:	00014917          	auipc	s2,0x14
    80001f1c:	af890913          	addi	s2,s2,-1288 # 80015a10 <tickslock>
    80001f20:	b76d                	j	80001eca <scheduler+0x5c>

0000000080001f22 <sched>:
{
    80001f22:	7179                	addi	sp,sp,-48
    80001f24:	f406                	sd	ra,40(sp)
    80001f26:	f022                	sd	s0,32(sp)
    80001f28:	ec26                	sd	s1,24(sp)
    80001f2a:	e84a                	sd	s2,16(sp)
    80001f2c:	e44e                	sd	s3,8(sp)
    80001f2e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f30:	a4fff0ef          	jal	8000197e <myproc>
    80001f34:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001f36:	bf7fe0ef          	jal	80000b2c <holding>
    80001f3a:	c92d                	beqz	a0,80001fac <sched+0x8a>
  asm volatile("mv %0, tp" : "=r"(x));
    80001f3c:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001f3e:	2781                	sext.w	a5,a5
    80001f40:	079e                	slli	a5,a5,0x7
    80001f42:	0000e717          	auipc	a4,0xe
    80001f46:	a9e70713          	addi	a4,a4,-1378 # 8000f9e0 <pid_lock>
    80001f4a:	97ba                	add	a5,a5,a4
    80001f4c:	0a87a703          	lw	a4,168(a5)
    80001f50:	4785                	li	a5,1
    80001f52:	06f71363          	bne	a4,a5,80001fb8 <sched+0x96>
  if (p->state == RUNNING)
    80001f56:	4c98                	lw	a4,24(s1)
    80001f58:	4791                	li	a5,4
    80001f5a:	06f70563          	beq	a4,a5,80001fc4 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001f5e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f62:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001f64:	e7b5                	bnez	a5,80001fd0 <sched+0xae>
  asm volatile("mv %0, tp" : "=r"(x));
    80001f66:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f68:	0000e917          	auipc	s2,0xe
    80001f6c:	a7890913          	addi	s2,s2,-1416 # 8000f9e0 <pid_lock>
    80001f70:	2781                	sext.w	a5,a5
    80001f72:	079e                	slli	a5,a5,0x7
    80001f74:	97ca                	add	a5,a5,s2
    80001f76:	0ac7a983          	lw	s3,172(a5)
    80001f7a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f7c:	2781                	sext.w	a5,a5
    80001f7e:	079e                	slli	a5,a5,0x7
    80001f80:	0000e597          	auipc	a1,0xe
    80001f84:	a9858593          	addi	a1,a1,-1384 # 8000fa18 <cpus+0x8>
    80001f88:	95be                	add	a1,a1,a5
    80001f8a:	06848513          	addi	a0,s1,104
    80001f8e:	544000ef          	jal	800024d2 <swtch>
    80001f92:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001f94:	2781                	sext.w	a5,a5
    80001f96:	079e                	slli	a5,a5,0x7
    80001f98:	993e                	add	s2,s2,a5
    80001f9a:	0b392623          	sw	s3,172(s2)
}
    80001f9e:	70a2                	ld	ra,40(sp)
    80001fa0:	7402                	ld	s0,32(sp)
    80001fa2:	64e2                	ld	s1,24(sp)
    80001fa4:	6942                	ld	s2,16(sp)
    80001fa6:	69a2                	ld	s3,8(sp)
    80001fa8:	6145                	addi	sp,sp,48
    80001faa:	8082                	ret
    panic("sched p->lock");
    80001fac:	00005517          	auipc	a0,0x5
    80001fb0:	21c50513          	addi	a0,a0,540 # 800071c8 <etext+0x1c8>
    80001fb4:	83bfe0ef          	jal	800007ee <panic>
    panic("sched locks");
    80001fb8:	00005517          	auipc	a0,0x5
    80001fbc:	22050513          	addi	a0,a0,544 # 800071d8 <etext+0x1d8>
    80001fc0:	82ffe0ef          	jal	800007ee <panic>
    panic("sched RUNNING");
    80001fc4:	00005517          	auipc	a0,0x5
    80001fc8:	22450513          	addi	a0,a0,548 # 800071e8 <etext+0x1e8>
    80001fcc:	823fe0ef          	jal	800007ee <panic>
    panic("sched interruptible");
    80001fd0:	00005517          	auipc	a0,0x5
    80001fd4:	22850513          	addi	a0,a0,552 # 800071f8 <etext+0x1f8>
    80001fd8:	817fe0ef          	jal	800007ee <panic>

0000000080001fdc <yield>:
{
    80001fdc:	1101                	addi	sp,sp,-32
    80001fde:	ec06                	sd	ra,24(sp)
    80001fe0:	e822                	sd	s0,16(sp)
    80001fe2:	e426                	sd	s1,8(sp)
    80001fe4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001fe6:	999ff0ef          	jal	8000197e <myproc>
    80001fea:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001fec:	ba1fe0ef          	jal	80000b8c <acquire>
  p->state = RUNNABLE;
    80001ff0:	478d                	li	a5,3
    80001ff2:	cc9c                	sw	a5,24(s1)
  sched();
    80001ff4:	f2fff0ef          	jal	80001f22 <sched>
  release(&p->lock);
    80001ff8:	8526                	mv	a0,s1
    80001ffa:	c1bfe0ef          	jal	80000c14 <release>
}
    80001ffe:	60e2                	ld	ra,24(sp)
    80002000:	6442                	ld	s0,16(sp)
    80002002:	64a2                	ld	s1,8(sp)
    80002004:	6105                	addi	sp,sp,32
    80002006:	8082                	ret

0000000080002008 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80002008:	1101                	addi	sp,sp,-32
    8000200a:	ec06                	sd	ra,24(sp)
    8000200c:	e822                	sd	s0,16(sp)
    8000200e:	e426                	sd	s1,8(sp)
    80002010:	e04a                	sd	s2,0(sp)
    80002012:	1000                	addi	s0,sp,32
    80002014:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002016:	969ff0ef          	jal	8000197e <myproc>
    8000201a:	892a                	mv	s2,a0

  acquire(&p->lock);
    8000201c:	b71fe0ef          	jal	80000b8c <acquire>
  if (chan == 0)
    80002020:	cc81                	beqz	s1,80002038 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    80002022:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80002026:	854a                	mv	a0,s2
    80002028:	bedfe0ef          	jal	80000c14 <release>
}
    8000202c:	60e2                	ld	ra,24(sp)
    8000202e:	6442                	ld	s0,16(sp)
    80002030:	64a2                	ld	s1,8(sp)
    80002032:	6902                	ld	s2,0(sp)
    80002034:	6105                	addi	sp,sp,32
    80002036:	8082                	ret
    panic("sleep_prepare: zero chan");
    80002038:	00005517          	auipc	a0,0x5
    8000203c:	1d850513          	addi	a0,a0,472 # 80007210 <etext+0x210>
    80002040:	faefe0ef          	jal	800007ee <panic>

0000000080002044 <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    80002044:	1101                	addi	sp,sp,-32
    80002046:	ec06                	sd	ra,24(sp)
    80002048:	e822                	sd	s0,16(sp)
    8000204a:	e426                	sd	s1,8(sp)
    8000204c:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000204e:	931ff0ef          	jal	8000197e <myproc>
    80002052:	84aa                	mv	s1,a0

  acquire(&p->lock);
    80002054:	b39fe0ef          	jal	80000b8c <acquire>
  if (p->chan != 0) {
    80002058:	709c                	ld	a5,32(s1)
    8000205a:	c789                	beqz	a5,80002064 <sleep+0x20>
    p->state = SLEEPING;
    8000205c:	4789                	li	a5,2
    8000205e:	cc9c                	sw	a5,24(s1)
    sched();
    80002060:	ec3ff0ef          	jal	80001f22 <sched>
  }
  release(&p->lock);
    80002064:	8526                	mv	a0,s1
    80002066:	baffe0ef          	jal	80000c14 <release>
}
    8000206a:	60e2                	ld	ra,24(sp)
    8000206c:	6442                	ld	s0,16(sp)
    8000206e:	64a2                	ld	s1,8(sp)
    80002070:	6105                	addi	sp,sp,32
    80002072:	8082                	ret

0000000080002074 <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    80002074:	7139                	addi	sp,sp,-64
    80002076:	fc06                	sd	ra,56(sp)
    80002078:	f822                	sd	s0,48(sp)
    8000207a:	f426                	sd	s1,40(sp)
    8000207c:	f04a                	sd	s2,32(sp)
    8000207e:	ec4e                	sd	s3,24(sp)
    80002080:	e852                	sd	s4,16(sp)
    80002082:	e456                	sd	s5,8(sp)
    80002084:	0080                	addi	s0,sp,64
    80002086:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002088:	0000e497          	auipc	s1,0xe
    8000208c:	d8848493          	addi	s1,s1,-632 # 8000fe10 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    80002090:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80002092:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80002094:	00014997          	auipc	s3,0x14
    80002098:	97c98993          	addi	s3,s3,-1668 # 80015a10 <tickslock>
    8000209c:	a801                	j	800020ac <wakeup+0x38>
      }
    }
    release(&p->lock);
    8000209e:	8526                	mv	a0,s1
    800020a0:	b75fe0ef          	jal	80000c14 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800020a4:	17048493          	addi	s1,s1,368
    800020a8:	03348063          	beq	s1,s3,800020c8 <wakeup+0x54>
    acquire(&p->lock);
    800020ac:	8526                	mv	a0,s1
    800020ae:	adffe0ef          	jal	80000b8c <acquire>
    if (p->chan == chan) {
    800020b2:	709c                	ld	a5,32(s1)
    800020b4:	ff2795e3          	bne	a5,s2,8000209e <wakeup+0x2a>
      p->chan = 0;
    800020b8:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    800020bc:	4c9c                	lw	a5,24(s1)
    800020be:	ff4790e3          	bne	a5,s4,8000209e <wakeup+0x2a>
        p->state = RUNNABLE;
    800020c2:	0154ac23          	sw	s5,24(s1)
    800020c6:	bfe1                	j	8000209e <wakeup+0x2a>
  }
}
    800020c8:	70e2                	ld	ra,56(sp)
    800020ca:	7442                	ld	s0,48(sp)
    800020cc:	74a2                	ld	s1,40(sp)
    800020ce:	7902                	ld	s2,32(sp)
    800020d0:	69e2                	ld	s3,24(sp)
    800020d2:	6a42                	ld	s4,16(sp)
    800020d4:	6aa2                	ld	s5,8(sp)
    800020d6:	6121                	addi	sp,sp,64
    800020d8:	8082                	ret

00000000800020da <reparent>:
{
    800020da:	7179                	addi	sp,sp,-48
    800020dc:	f406                	sd	ra,40(sp)
    800020de:	f022                	sd	s0,32(sp)
    800020e0:	ec26                	sd	s1,24(sp)
    800020e2:	e84a                	sd	s2,16(sp)
    800020e4:	e44e                	sd	s3,8(sp)
    800020e6:	e052                	sd	s4,0(sp)
    800020e8:	1800                	addi	s0,sp,48
    800020ea:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800020ec:	0000e497          	auipc	s1,0xe
    800020f0:	d2448493          	addi	s1,s1,-732 # 8000fe10 <proc>
      pp->parent = initproc;
    800020f4:	00005a17          	auipc	s4,0x5
    800020f8:	7c4a0a13          	addi	s4,s4,1988 # 800078b8 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800020fc:	00014997          	auipc	s3,0x14
    80002100:	91498993          	addi	s3,s3,-1772 # 80015a10 <tickslock>
    80002104:	a029                	j	8000210e <reparent+0x34>
    80002106:	17048493          	addi	s1,s1,368
    8000210a:	01348b63          	beq	s1,s3,80002120 <reparent+0x46>
    if (pp->parent == p) {
    8000210e:	7c9c                	ld	a5,56(s1)
    80002110:	ff279be3          	bne	a5,s2,80002106 <reparent+0x2c>
      pp->parent = initproc;
    80002114:	000a3503          	ld	a0,0(s4)
    80002118:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000211a:	f5bff0ef          	jal	80002074 <wakeup>
    8000211e:	b7e5                	j	80002106 <reparent+0x2c>
}
    80002120:	70a2                	ld	ra,40(sp)
    80002122:	7402                	ld	s0,32(sp)
    80002124:	64e2                	ld	s1,24(sp)
    80002126:	6942                	ld	s2,16(sp)
    80002128:	69a2                	ld	s3,8(sp)
    8000212a:	6a02                	ld	s4,0(sp)
    8000212c:	6145                	addi	sp,sp,48
    8000212e:	8082                	ret

0000000080002130 <kexit>:
{
    80002130:	7179                	addi	sp,sp,-48
    80002132:	f406                	sd	ra,40(sp)
    80002134:	f022                	sd	s0,32(sp)
    80002136:	ec26                	sd	s1,24(sp)
    80002138:	e84a                	sd	s2,16(sp)
    8000213a:	e44e                	sd	s3,8(sp)
    8000213c:	e052                	sd	s4,0(sp)
    8000213e:	1800                	addi	s0,sp,48
    80002140:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002142:	83dff0ef          	jal	8000197e <myproc>
    80002146:	89aa                	mv	s3,a0
  if (p == initproc)
    80002148:	00005797          	auipc	a5,0x5
    8000214c:	7707b783          	ld	a5,1904(a5) # 800078b8 <initproc>
    80002150:	0d850493          	addi	s1,a0,216
    80002154:	15850913          	addi	s2,a0,344
    80002158:	00a79b63          	bne	a5,a0,8000216e <kexit+0x3e>
    panic("init exiting");
    8000215c:	00005517          	auipc	a0,0x5
    80002160:	0d450513          	addi	a0,a0,212 # 80007230 <etext+0x230>
    80002164:	e8afe0ef          	jal	800007ee <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    80002168:	04a1                	addi	s1,s1,8
    8000216a:	01248963          	beq	s1,s2,8000217c <kexit+0x4c>
    if (p->ofile[fd]) {
    8000216e:	6088                	ld	a0,0(s1)
    80002170:	dd65                	beqz	a0,80002168 <kexit+0x38>
      fileclose(f);
    80002172:	1c6020ef          	jal	80004338 <fileclose>
      p->ofile[fd] = 0;
    80002176:	0004b023          	sd	zero,0(s1)
    8000217a:	b7fd                	j	80002168 <kexit+0x38>
  begin_op();
    8000217c:	50b010ef          	jal	80003e86 <begin_op>
  iput(p->cwd);
    80002180:	1589b503          	ld	a0,344(s3)
    80002184:	422010ef          	jal	800035a6 <iput>
  end_op();
    80002188:	585010ef          	jal	80003f0c <end_op>
  p->cwd = 0;
    8000218c:	1409bc23          	sd	zero,344(s3)
  acquire(&wait_lock);
    80002190:	0000e497          	auipc	s1,0xe
    80002194:	86848493          	addi	s1,s1,-1944 # 8000f9f8 <wait_lock>
    80002198:	8526                	mv	a0,s1
    8000219a:	9f3fe0ef          	jal	80000b8c <acquire>
  reparent(p);
    8000219e:	854e                	mv	a0,s3
    800021a0:	f3bff0ef          	jal	800020da <reparent>
  wakeup(p->parent);
    800021a4:	0389b503          	ld	a0,56(s3)
    800021a8:	ecdff0ef          	jal	80002074 <wakeup>
  acquire(&p->lock);
    800021ac:	854e                	mv	a0,s3
    800021ae:	9dffe0ef          	jal	80000b8c <acquire>
  p->xstate = status;
    800021b2:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800021b6:	4795                	li	a5,5
    800021b8:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800021bc:	8526                	mv	a0,s1
    800021be:	a57fe0ef          	jal	80000c14 <release>
  sched();
    800021c2:	d61ff0ef          	jal	80001f22 <sched>
  panic("zombie exit");
    800021c6:	00005517          	auipc	a0,0x5
    800021ca:	07a50513          	addi	a0,a0,122 # 80007240 <etext+0x240>
    800021ce:	e20fe0ef          	jal	800007ee <panic>

00000000800021d2 <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    800021d2:	c525                	beqz	a0,8000223a <kkill+0x68>
{
    800021d4:	7179                	addi	sp,sp,-48
    800021d6:	f406                	sd	ra,40(sp)
    800021d8:	f022                	sd	s0,32(sp)
    800021da:	ec26                	sd	s1,24(sp)
    800021dc:	e84a                	sd	s2,16(sp)
    800021de:	e44e                	sd	s3,8(sp)
    800021e0:	1800                	addi	s0,sp,48
    800021e2:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    800021e4:	0000e497          	auipc	s1,0xe
    800021e8:	c2c48493          	addi	s1,s1,-980 # 8000fe10 <proc>
    800021ec:	00014997          	auipc	s3,0x14
    800021f0:	82498993          	addi	s3,s3,-2012 # 80015a10 <tickslock>
    acquire(&p->lock);
    800021f4:	8526                	mv	a0,s1
    800021f6:	997fe0ef          	jal	80000b8c <acquire>
    if (p->pid == pid) {
    800021fa:	589c                	lw	a5,48(s1)
    800021fc:	01278b63          	beq	a5,s2,80002212 <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002200:	8526                	mv	a0,s1
    80002202:	a13fe0ef          	jal	80000c14 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002206:	17048493          	addi	s1,s1,368
    8000220a:	ff3495e3          	bne	s1,s3,800021f4 <kkill+0x22>
  }
  return -1;
    8000220e:	557d                	li	a0,-1
    80002210:	a819                	j	80002226 <kkill+0x54>
      p->killed = 1;
    80002212:	4785                	li	a5,1
    80002214:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    80002216:	4c98                	lw	a4,24(s1)
    80002218:	4789                	li	a5,2
    8000221a:	00f70d63          	beq	a4,a5,80002234 <kkill+0x62>
      release(&p->lock);
    8000221e:	8526                	mv	a0,s1
    80002220:	9f5fe0ef          	jal	80000c14 <release>
      return 0;
    80002224:	4501                	li	a0,0
}
    80002226:	70a2                	ld	ra,40(sp)
    80002228:	7402                	ld	s0,32(sp)
    8000222a:	64e2                	ld	s1,24(sp)
    8000222c:	6942                	ld	s2,16(sp)
    8000222e:	69a2                	ld	s3,8(sp)
    80002230:	6145                	addi	sp,sp,48
    80002232:	8082                	ret
        p->state = RUNNABLE;
    80002234:	478d                	li	a5,3
    80002236:	cc9c                	sw	a5,24(s1)
    80002238:	b7dd                	j	8000221e <kkill+0x4c>
    return -1;
    8000223a:	557d                	li	a0,-1
}
    8000223c:	8082                	ret

000000008000223e <setkilled>:

void
setkilled(struct proc *p)
{
    8000223e:	1101                	addi	sp,sp,-32
    80002240:	ec06                	sd	ra,24(sp)
    80002242:	e822                	sd	s0,16(sp)
    80002244:	e426                	sd	s1,8(sp)
    80002246:	1000                	addi	s0,sp,32
    80002248:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000224a:	943fe0ef          	jal	80000b8c <acquire>
  p->killed = 1;
    8000224e:	4785                	li	a5,1
    80002250:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002252:	8526                	mv	a0,s1
    80002254:	9c1fe0ef          	jal	80000c14 <release>
}
    80002258:	60e2                	ld	ra,24(sp)
    8000225a:	6442                	ld	s0,16(sp)
    8000225c:	64a2                	ld	s1,8(sp)
    8000225e:	6105                	addi	sp,sp,32
    80002260:	8082                	ret

0000000080002262 <killed>:

int
killed(struct proc *p)
{
    80002262:	1101                	addi	sp,sp,-32
    80002264:	ec06                	sd	ra,24(sp)
    80002266:	e822                	sd	s0,16(sp)
    80002268:	e426                	sd	s1,8(sp)
    8000226a:	e04a                	sd	s2,0(sp)
    8000226c:	1000                	addi	s0,sp,32
    8000226e:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002270:	91dfe0ef          	jal	80000b8c <acquire>
  k = p->killed;
    80002274:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002278:	8526                	mv	a0,s1
    8000227a:	99bfe0ef          	jal	80000c14 <release>
  return k;
}
    8000227e:	854a                	mv	a0,s2
    80002280:	60e2                	ld	ra,24(sp)
    80002282:	6442                	ld	s0,16(sp)
    80002284:	64a2                	ld	s1,8(sp)
    80002286:	6902                	ld	s2,0(sp)
    80002288:	6105                	addi	sp,sp,32
    8000228a:	8082                	ret

000000008000228c <kwait>:
{
    8000228c:	715d                	addi	sp,sp,-80
    8000228e:	e486                	sd	ra,72(sp)
    80002290:	e0a2                	sd	s0,64(sp)
    80002292:	fc26                	sd	s1,56(sp)
    80002294:	f84a                	sd	s2,48(sp)
    80002296:	f44e                	sd	s3,40(sp)
    80002298:	f052                	sd	s4,32(sp)
    8000229a:	ec56                	sd	s5,24(sp)
    8000229c:	e85a                	sd	s6,16(sp)
    8000229e:	e45e                	sd	s7,8(sp)
    800022a0:	0880                	addi	s0,sp,80
    800022a2:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800022a4:	edaff0ef          	jal	8000197e <myproc>
    800022a8:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800022aa:	0000d517          	auipc	a0,0xd
    800022ae:	74e50513          	addi	a0,a0,1870 # 8000f9f8 <wait_lock>
    800022b2:	8dbfe0ef          	jal	80000b8c <acquire>
        if (pp->state == ZOMBIE) {
    800022b6:	4a15                	li	s4,5
        havekids = 1;
    800022b8:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800022ba:	00013997          	auipc	s3,0x13
    800022be:	75698993          	addi	s3,s3,1878 # 80015a10 <tickslock>
    release(&wait_lock);
    800022c2:	0000db97          	auipc	s7,0xd
    800022c6:	736b8b93          	addi	s7,s7,1846 # 8000f9f8 <wait_lock>
    800022ca:	a845                	j	8000237a <kwait+0xee>
          pid = pp->pid;
    800022cc:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    800022d0:	000b0e63          	beqz	s6,800022ec <kwait+0x60>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    800022d4:	4711                	li	a4,4
    800022d6:	02c48693          	addi	a3,s1,44
    800022da:	865a                	mv	a2,s6
    800022dc:	04893583          	ld	a1,72(s2)
    800022e0:	05093503          	ld	a0,80(s2)
    800022e4:	afcff0ef          	jal	800015e0 <copyout>
          if (addr != 0 &&
    800022e8:	02054c63          	bltz	a0,80002320 <kwait+0x94>
          pp->parent = 0;
    800022ec:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    800022f0:	8526                	mv	a0,s1
    800022f2:	8b5ff0ef          	jal	80001ba6 <freeproc>
          release(&pp->lock);
    800022f6:	8526                	mv	a0,s1
    800022f8:	91dfe0ef          	jal	80000c14 <release>
          release(&wait_lock);
    800022fc:	0000d517          	auipc	a0,0xd
    80002300:	6fc50513          	addi	a0,a0,1788 # 8000f9f8 <wait_lock>
    80002304:	911fe0ef          	jal	80000c14 <release>
}
    80002308:	854e                	mv	a0,s3
    8000230a:	60a6                	ld	ra,72(sp)
    8000230c:	6406                	ld	s0,64(sp)
    8000230e:	74e2                	ld	s1,56(sp)
    80002310:	7942                	ld	s2,48(sp)
    80002312:	79a2                	ld	s3,40(sp)
    80002314:	7a02                	ld	s4,32(sp)
    80002316:	6ae2                	ld	s5,24(sp)
    80002318:	6b42                	ld	s6,16(sp)
    8000231a:	6ba2                	ld	s7,8(sp)
    8000231c:	6161                	addi	sp,sp,80
    8000231e:	8082                	ret
            release(&pp->lock);
    80002320:	8526                	mv	a0,s1
    80002322:	8f3fe0ef          	jal	80000c14 <release>
            release(&wait_lock);
    80002326:	0000d517          	auipc	a0,0xd
    8000232a:	6d250513          	addi	a0,a0,1746 # 8000f9f8 <wait_lock>
    8000232e:	8e7fe0ef          	jal	80000c14 <release>
            return -1;
    80002332:	59fd                	li	s3,-1
    80002334:	bfd1                	j	80002308 <kwait+0x7c>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002336:	17048493          	addi	s1,s1,368
    8000233a:	03348063          	beq	s1,s3,8000235a <kwait+0xce>
      if (pp->parent == p) {
    8000233e:	7c9c                	ld	a5,56(s1)
    80002340:	ff279be3          	bne	a5,s2,80002336 <kwait+0xaa>
        acquire(&pp->lock);
    80002344:	8526                	mv	a0,s1
    80002346:	847fe0ef          	jal	80000b8c <acquire>
        if (pp->state == ZOMBIE) {
    8000234a:	4c9c                	lw	a5,24(s1)
    8000234c:	f94780e3          	beq	a5,s4,800022cc <kwait+0x40>
        release(&pp->lock);
    80002350:	8526                	mv	a0,s1
    80002352:	8c3fe0ef          	jal	80000c14 <release>
        havekids = 1;
    80002356:	8756                	mv	a4,s5
    80002358:	bff9                	j	80002336 <kwait+0xaa>
    if (!havekids || killed(p)) {
    8000235a:	c715                	beqz	a4,80002386 <kwait+0xfa>
    8000235c:	854a                	mv	a0,s2
    8000235e:	f05ff0ef          	jal	80002262 <killed>
    80002362:	e115                	bnez	a0,80002386 <kwait+0xfa>
    sleep_prepare(p); //DOC: wait-sleep
    80002364:	854a                	mv	a0,s2
    80002366:	ca3ff0ef          	jal	80002008 <sleep_prepare>
    release(&wait_lock);
    8000236a:	855e                	mv	a0,s7
    8000236c:	8a9fe0ef          	jal	80000c14 <release>
    sleep();
    80002370:	cd5ff0ef          	jal	80002044 <sleep>
    acquire(&wait_lock);
    80002374:	855e                	mv	a0,s7
    80002376:	817fe0ef          	jal	80000b8c <acquire>
    havekids = 0;
    8000237a:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000237c:	0000e497          	auipc	s1,0xe
    80002380:	a9448493          	addi	s1,s1,-1388 # 8000fe10 <proc>
    80002384:	bf6d                	j	8000233e <kwait+0xb2>
      release(&wait_lock);
    80002386:	0000d517          	auipc	a0,0xd
    8000238a:	67250513          	addi	a0,a0,1650 # 8000f9f8 <wait_lock>
    8000238e:	887fe0ef          	jal	80000c14 <release>
      return -1;
    80002392:	59fd                	li	s3,-1
    80002394:	bf95                	j	80002308 <kwait+0x7c>

0000000080002396 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002396:	7179                	addi	sp,sp,-48
    80002398:	f406                	sd	ra,40(sp)
    8000239a:	f022                	sd	s0,32(sp)
    8000239c:	ec26                	sd	s1,24(sp)
    8000239e:	e84a                	sd	s2,16(sp)
    800023a0:	e44e                	sd	s3,8(sp)
    800023a2:	e052                	sd	s4,0(sp)
    800023a4:	1800                	addi	s0,sp,48
    800023a6:	84aa                	mv	s1,a0
    800023a8:	892e                	mv	s2,a1
    800023aa:	89b2                	mv	s3,a2
    800023ac:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800023ae:	dd0ff0ef          	jal	8000197e <myproc>
  if (user_dst) {
    800023b2:	c085                	beqz	s1,800023d2 <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    800023b4:	8752                	mv	a4,s4
    800023b6:	86ce                	mv	a3,s3
    800023b8:	864a                	mv	a2,s2
    800023ba:	652c                	ld	a1,72(a0)
    800023bc:	6928                	ld	a0,80(a0)
    800023be:	a22ff0ef          	jal	800015e0 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800023c2:	70a2                	ld	ra,40(sp)
    800023c4:	7402                	ld	s0,32(sp)
    800023c6:	64e2                	ld	s1,24(sp)
    800023c8:	6942                	ld	s2,16(sp)
    800023ca:	69a2                	ld	s3,8(sp)
    800023cc:	6a02                	ld	s4,0(sp)
    800023ce:	6145                	addi	sp,sp,48
    800023d0:	8082                	ret
    memmove((char *)dst, src, len);
    800023d2:	000a061b          	sext.w	a2,s4
    800023d6:	85ce                	mv	a1,s3
    800023d8:	854a                	mv	a0,s2
    800023da:	8d7fe0ef          	jal	80000cb0 <memmove>
    return 0;
    800023de:	8526                	mv	a0,s1
    800023e0:	b7cd                	j	800023c2 <either_copyout+0x2c>

00000000800023e2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800023e2:	7179                	addi	sp,sp,-48
    800023e4:	f406                	sd	ra,40(sp)
    800023e6:	f022                	sd	s0,32(sp)
    800023e8:	ec26                	sd	s1,24(sp)
    800023ea:	e84a                	sd	s2,16(sp)
    800023ec:	e44e                	sd	s3,8(sp)
    800023ee:	e052                	sd	s4,0(sp)
    800023f0:	1800                	addi	s0,sp,48
    800023f2:	892a                	mv	s2,a0
    800023f4:	84ae                	mv	s1,a1
    800023f6:	89b2                	mv	s3,a2
    800023f8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800023fa:	d84ff0ef          	jal	8000197e <myproc>
  if (user_src) {
    800023fe:	c085                	beqz	s1,8000241e <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    80002400:	8752                	mv	a4,s4
    80002402:	86ce                	mv	a3,s3
    80002404:	864a                	mv	a2,s2
    80002406:	652c                	ld	a1,72(a0)
    80002408:	6928                	ld	a0,80(a0)
    8000240a:	a9cff0ef          	jal	800016a6 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000240e:	70a2                	ld	ra,40(sp)
    80002410:	7402                	ld	s0,32(sp)
    80002412:	64e2                	ld	s1,24(sp)
    80002414:	6942                	ld	s2,16(sp)
    80002416:	69a2                	ld	s3,8(sp)
    80002418:	6a02                	ld	s4,0(sp)
    8000241a:	6145                	addi	sp,sp,48
    8000241c:	8082                	ret
    memmove(dst, (char *)src, len);
    8000241e:	000a061b          	sext.w	a2,s4
    80002422:	85ce                	mv	a1,s3
    80002424:	854a                	mv	a0,s2
    80002426:	88bfe0ef          	jal	80000cb0 <memmove>
    return 0;
    8000242a:	8526                	mv	a0,s1
    8000242c:	b7cd                	j	8000240e <either_copyin+0x2c>

000000008000242e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000242e:	715d                	addi	sp,sp,-80
    80002430:	e486                	sd	ra,72(sp)
    80002432:	e0a2                	sd	s0,64(sp)
    80002434:	fc26                	sd	s1,56(sp)
    80002436:	f84a                	sd	s2,48(sp)
    80002438:	f44e                	sd	s3,40(sp)
    8000243a:	f052                	sd	s4,32(sp)
    8000243c:	ec56                	sd	s5,24(sp)
    8000243e:	e85a                	sd	s6,16(sp)
    80002440:	e45e                	sd	s7,8(sp)
    80002442:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    80002444:	00005517          	auipc	a0,0x5
    80002448:	c3450513          	addi	a0,a0,-972 # 80007078 <etext+0x78>
    8000244c:	8befe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002450:	0000e497          	auipc	s1,0xe
    80002454:	b2048493          	addi	s1,s1,-1248 # 8000ff70 <proc+0x160>
    80002458:	00013917          	auipc	s2,0x13
    8000245c:	71890913          	addi	s2,s2,1816 # 80015b70 <bcache+0x148>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002460:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002462:	00005997          	auipc	s3,0x5
    80002466:	dee98993          	addi	s3,s3,-530 # 80007250 <etext+0x250>
    printk("%d %s %s", p->pid, state, p->name);
    8000246a:	00005a97          	auipc	s5,0x5
    8000246e:	deea8a93          	addi	s5,s5,-530 # 80007258 <etext+0x258>
    printk("\n");
    80002472:	00005a17          	auipc	s4,0x5
    80002476:	c06a0a13          	addi	s4,s4,-1018 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000247a:	00005b97          	auipc	s7,0x5
    8000247e:	2feb8b93          	addi	s7,s7,766 # 80007778 <states.0>
    80002482:	a829                	j	8000249c <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    80002484:	ed06a583          	lw	a1,-304(a3)
    80002488:	8556                	mv	a0,s5
    8000248a:	880fe0ef          	jal	8000050a <printk>
    printk("\n");
    8000248e:	8552                	mv	a0,s4
    80002490:	87afe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002494:	17048493          	addi	s1,s1,368
    80002498:	03248263          	beq	s1,s2,800024bc <procdump+0x8e>
    if (p->state == UNUSED)
    8000249c:	86a6                	mv	a3,s1
    8000249e:	eb84a783          	lw	a5,-328(s1)
    800024a2:	dbed                	beqz	a5,80002494 <procdump+0x66>
      state = "???";
    800024a4:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024a6:	fcfb6fe3          	bltu	s6,a5,80002484 <procdump+0x56>
    800024aa:	02079713          	slli	a4,a5,0x20
    800024ae:	01d75793          	srli	a5,a4,0x1d
    800024b2:	97de                	add	a5,a5,s7
    800024b4:	6390                	ld	a2,0(a5)
    800024b6:	f679                	bnez	a2,80002484 <procdump+0x56>
      state = "???";
    800024b8:	864e                	mv	a2,s3
    800024ba:	b7e9                	j	80002484 <procdump+0x56>
  }
}
    800024bc:	60a6                	ld	ra,72(sp)
    800024be:	6406                	ld	s0,64(sp)
    800024c0:	74e2                	ld	s1,56(sp)
    800024c2:	7942                	ld	s2,48(sp)
    800024c4:	79a2                	ld	s3,40(sp)
    800024c6:	7a02                	ld	s4,32(sp)
    800024c8:	6ae2                	ld	s5,24(sp)
    800024ca:	6b42                	ld	s6,16(sp)
    800024cc:	6ba2                	ld	s7,8(sp)
    800024ce:	6161                	addi	sp,sp,80
    800024d0:	8082                	ret

00000000800024d2 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800024d2:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800024d6:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800024da:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800024dc:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800024de:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800024e2:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800024e6:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800024ea:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800024ee:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800024f2:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800024f6:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800024fa:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800024fe:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002502:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002506:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000250a:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000250e:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002510:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002512:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002516:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000251a:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000251e:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002522:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002526:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000252a:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    8000252e:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002532:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002536:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000253a:	8082                	ret

000000008000253c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000253c:	1141                	addi	sp,sp,-16
    8000253e:	e406                	sd	ra,8(sp)
    80002540:	e022                	sd	s0,0(sp)
    80002542:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002544:	00005597          	auipc	a1,0x5
    80002548:	d5458593          	addi	a1,a1,-684 # 80007298 <etext+0x298>
    8000254c:	00013517          	auipc	a0,0x13
    80002550:	4c450513          	addi	a0,a0,1220 # 80015a10 <tickslock>
    80002554:	dbefe0ef          	jal	80000b12 <initlock>
}
    80002558:	60a2                	ld	ra,8(sp)
    8000255a:	6402                	ld	s0,0(sp)
    8000255c:	0141                	addi	sp,sp,16
    8000255e:	8082                	ret

0000000080002560 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002560:	1141                	addi	sp,sp,-16
    80002562:	e406                	sd	ra,8(sp)
    80002564:	e022                	sd	s0,0(sp)
    80002566:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002568:	00003797          	auipc	a5,0x3
    8000256c:	26878793          	addi	a5,a5,616 # 800057d0 <kernelvec>
    80002570:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002574:	60a2                	ld	ra,8(sp)
    80002576:	6402                	ld	s0,0(sp)
    80002578:	0141                	addi	sp,sp,16
    8000257a:	8082                	ret

000000008000257c <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000257c:	1141                	addi	sp,sp,-16
    8000257e:	e406                	sd	ra,8(sp)
    80002580:	e022                	sd	s0,0(sp)
    80002582:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002584:	bfaff0ef          	jal	8000197e <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80002588:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000258c:	04000737          	lui	a4,0x4000
    80002590:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002592:	0732                	slli	a4,a4,0xc
    80002594:	00004797          	auipc	a5,0x4
    80002598:	a6c78793          	addi	a5,a5,-1428 # 80006000 <_trampoline>
    8000259c:	00004697          	auipc	a3,0x4
    800025a0:	a6468693          	addi	a3,a3,-1436 # 80006000 <_trampoline>
    800025a4:	8f95                	sub	a5,a5,a3
    800025a6:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    800025a8:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800025ac:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    800025ae:	18002773          	csrr	a4,satp
    800025b2:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800025b4:	6d38                	ld	a4,88(a0)
    800025b6:	613c                	ld	a5,64(a0)
    800025b8:	6685                	lui	a3,0x1
    800025ba:	97b6                	add	a5,a5,a3
    800025bc:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800025be:	6d3c                	ld	a5,88(a0)
    800025c0:	00000717          	auipc	a4,0x0
    800025c4:	0f870713          	addi	a4,a4,248 # 800026b8 <usertrap>
    800025c8:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800025ca:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    800025cc:	8712                	mv	a4,tp
    800025ce:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800025d0:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800025d4:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800025d8:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800025dc:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800025e0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    800025e2:	6f9c                	ld	a5,24(a5)
    800025e4:	14179073          	csrw	sepc,a5
}
    800025e8:	60a2                	ld	ra,8(sp)
    800025ea:	6402                	ld	s0,0(sp)
    800025ec:	0141                	addi	sp,sp,16
    800025ee:	8082                	ret

00000000800025f0 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800025f0:	1101                	addi	sp,sp,-32
    800025f2:	ec06                	sd	ra,24(sp)
    800025f4:	e822                	sd	s0,16(sp)
    800025f6:	1000                	addi	s0,sp,32
  if (cpuid() == 0) {
    800025f8:	b52ff0ef          	jal	8000194a <cpuid>
    800025fc:	cd11                	beqz	a0,80002618 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    800025fe:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002602:	000f4737          	lui	a4,0xf4
    80002606:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000260a:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000260c:	14d79073          	csrw	stimecmp,a5
}
    80002610:	60e2                	ld	ra,24(sp)
    80002612:	6442                	ld	s0,16(sp)
    80002614:	6105                	addi	sp,sp,32
    80002616:	8082                	ret
    80002618:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    8000261a:	00013497          	auipc	s1,0x13
    8000261e:	3f648493          	addi	s1,s1,1014 # 80015a10 <tickslock>
    80002622:	8526                	mv	a0,s1
    80002624:	d68fe0ef          	jal	80000b8c <acquire>
    ticks++;
    80002628:	00005517          	auipc	a0,0x5
    8000262c:	29850513          	addi	a0,a0,664 # 800078c0 <ticks>
    80002630:	411c                	lw	a5,0(a0)
    80002632:	2785                	addiw	a5,a5,1
    80002634:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002636:	a3fff0ef          	jal	80002074 <wakeup>
    release(&tickslock);
    8000263a:	8526                	mv	a0,s1
    8000263c:	dd8fe0ef          	jal	80000c14 <release>
    80002640:	64a2                	ld	s1,8(sp)
    80002642:	bf75                	j	800025fe <clockintr+0xe>

0000000080002644 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002644:	1101                	addi	sp,sp,-32
    80002646:	ec06                	sd	ra,24(sp)
    80002648:	e822                	sd	s0,16(sp)
    8000264a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    8000264c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    80002650:	57fd                	li	a5,-1
    80002652:	17fe                	slli	a5,a5,0x3f
    80002654:	07a5                	addi	a5,a5,9
    80002656:	00f70c63          	beq	a4,a5,8000266e <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    8000265a:	57fd                	li	a5,-1
    8000265c:	17fe                	slli	a5,a5,0x3f
    8000265e:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002660:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    80002662:	04f70763          	beq	a4,a5,800026b0 <devintr+0x6c>
  }
}
    80002666:	60e2                	ld	ra,24(sp)
    80002668:	6442                	ld	s0,16(sp)
    8000266a:	6105                	addi	sp,sp,32
    8000266c:	8082                	ret
    8000266e:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002670:	20c030ef          	jal	8000587c <plic_claim>
    80002674:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    80002676:	47a9                	li	a5,10
    80002678:	00f50963          	beq	a0,a5,8000268a <devintr+0x46>
    } else if (irq == VIRTIO0_IRQ) {
    8000267c:	4785                	li	a5,1
    8000267e:	00f50963          	beq	a0,a5,80002690 <devintr+0x4c>
    return 1;
    80002682:	4505                	li	a0,1
    } else if (irq) {
    80002684:	e889                	bnez	s1,80002696 <devintr+0x52>
    80002686:	64a2                	ld	s1,8(sp)
    80002688:	bff9                	j	80002666 <devintr+0x22>
      uartintr();
    8000268a:	afefe0ef          	jal	80000988 <uartintr>
    if (irq)
    8000268e:	a819                	j	800026a4 <devintr+0x60>
      virtio_disk_intr();
    80002690:	69a030ef          	jal	80005d2a <virtio_disk_intr>
    if (irq)
    80002694:	a801                	j	800026a4 <devintr+0x60>
      printk("unexpected interrupt irq=%d\n", irq);
    80002696:	85a6                	mv	a1,s1
    80002698:	00005517          	auipc	a0,0x5
    8000269c:	c0850513          	addi	a0,a0,-1016 # 800072a0 <etext+0x2a0>
    800026a0:	e6bfd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    800026a4:	8526                	mv	a0,s1
    800026a6:	1f6030ef          	jal	8000589c <plic_complete>
    return 1;
    800026aa:	4505                	li	a0,1
    800026ac:	64a2                	ld	s1,8(sp)
    800026ae:	bf65                	j	80002666 <devintr+0x22>
    clockintr();
    800026b0:	f41ff0ef          	jal	800025f0 <clockintr>
    return 2;
    800026b4:	4509                	li	a0,2
    800026b6:	bf45                	j	80002666 <devintr+0x22>

00000000800026b8 <usertrap>:
{
    800026b8:	1101                	addi	sp,sp,-32
    800026ba:	ec06                	sd	ra,24(sp)
    800026bc:	e822                	sd	s0,16(sp)
    800026be:	e426                	sd	s1,8(sp)
    800026c0:	e04a                	sd	s2,0(sp)
    800026c2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800026c4:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    800026c8:	1007f793          	andi	a5,a5,256
    800026cc:	eba5                	bnez	a5,8000273c <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    800026ce:	00003797          	auipc	a5,0x3
    800026d2:	10278793          	addi	a5,a5,258 # 800057d0 <kernelvec>
    800026d6:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800026da:	aa4ff0ef          	jal	8000197e <myproc>
    800026de:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800026e0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    800026e2:	14102773          	csrr	a4,sepc
    800026e6:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    800026e8:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    800026ec:	47a1                	li	a5,8
    800026ee:	04f70d63          	beq	a4,a5,80002748 <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    800026f2:	f53ff0ef          	jal	80002644 <devintr>
    800026f6:	892a                	mv	s2,a0
    800026f8:	e54d                	bnez	a0,800027a2 <usertrap+0xea>
    800026fa:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    800026fe:	47bd                	li	a5,15
    80002700:	08f70463          	beq	a4,a5,80002788 <usertrap+0xd0>
    80002704:	14202773          	csrr	a4,scause
    80002708:	47b5                	li	a5,13
    8000270a:	06f70f63          	beq	a4,a5,80002788 <usertrap+0xd0>
    8000270e:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002712:	5890                	lw	a2,48(s1)
    80002714:	00005517          	auipc	a0,0x5
    80002718:	bcc50513          	addi	a0,a0,-1076 # 800072e0 <etext+0x2e0>
    8000271c:	deffd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002720:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002724:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002728:	00005517          	auipc	a0,0x5
    8000272c:	be850513          	addi	a0,a0,-1048 # 80007310 <etext+0x310>
    80002730:	ddbfd0ef          	jal	8000050a <printk>
    setkilled(p);
    80002734:	8526                	mv	a0,s1
    80002736:	b09ff0ef          	jal	8000223e <setkilled>
    8000273a:	a015                	j	8000275e <usertrap+0xa6>
    panic("usertrap: not from user mode");
    8000273c:	00005517          	auipc	a0,0x5
    80002740:	b8450513          	addi	a0,a0,-1148 # 800072c0 <etext+0x2c0>
    80002744:	8aafe0ef          	jal	800007ee <panic>
    if (killed(p))
    80002748:	b1bff0ef          	jal	80002262 <killed>
    8000274c:	e915                	bnez	a0,80002780 <usertrap+0xc8>
    p->trapframe->epc += 4;
    8000274e:	6cb8                	ld	a4,88(s1)
    80002750:	6f1c                	ld	a5,24(a4)
    80002752:	0791                	addi	a5,a5,4
    80002754:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80002756:	10016073          	csrsi	sstatus,2
    syscall();
    8000275a:	242000ef          	jal	8000299c <syscall>
  if (killed(p))
    8000275e:	8526                	mv	a0,s1
    80002760:	b03ff0ef          	jal	80002262 <killed>
    80002764:	e521                	bnez	a0,800027ac <usertrap+0xf4>
  prepare_return();
    80002766:	e17ff0ef          	jal	8000257c <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000276a:	68a8                	ld	a0,80(s1)
    8000276c:	8131                	srli	a0,a0,0xc
    8000276e:	57fd                	li	a5,-1
    80002770:	17fe                	slli	a5,a5,0x3f
    80002772:	8d5d                	or	a0,a0,a5
}
    80002774:	60e2                	ld	ra,24(sp)
    80002776:	6442                	ld	s0,16(sp)
    80002778:	64a2                	ld	s1,8(sp)
    8000277a:	6902                	ld	s2,0(sp)
    8000277c:	6105                	addi	sp,sp,32
    8000277e:	8082                	ret
      kexit(-1);
    80002780:	557d                	li	a0,-1
    80002782:	9afff0ef          	jal	80002130 <kexit>
    80002786:	b7e1                	j	8000274e <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    80002788:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    8000278c:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    80002790:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    80002792:	0016b693          	seqz	a3,a3
    80002796:	64ac                	ld	a1,72(s1)
    80002798:	68a8                	ld	a0,80(s1)
    8000279a:	dcbfe0ef          	jal	80001564 <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    8000279e:	f161                	bnez	a0,8000275e <usertrap+0xa6>
    800027a0:	b7bd                	j	8000270e <usertrap+0x56>
  if (killed(p))
    800027a2:	8526                	mv	a0,s1
    800027a4:	abfff0ef          	jal	80002262 <killed>
    800027a8:	c511                	beqz	a0,800027b4 <usertrap+0xfc>
    800027aa:	a011                	j	800027ae <usertrap+0xf6>
    800027ac:	4901                	li	s2,0
    kexit(-1);
    800027ae:	557d                	li	a0,-1
    800027b0:	981ff0ef          	jal	80002130 <kexit>
  if (which_dev == 2)
    800027b4:	4789                	li	a5,2
    800027b6:	faf918e3          	bne	s2,a5,80002766 <usertrap+0xae>
    yield();
    800027ba:	823ff0ef          	jal	80001fdc <yield>
    800027be:	b765                	j	80002766 <usertrap+0xae>

00000000800027c0 <kerneltrap>:
{
    800027c0:	7179                	addi	sp,sp,-48
    800027c2:	f406                	sd	ra,40(sp)
    800027c4:	f022                	sd	s0,32(sp)
    800027c6:	ec26                	sd	s1,24(sp)
    800027c8:	e84a                	sd	s2,16(sp)
    800027ca:	e44e                	sd	s3,8(sp)
    800027cc:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    800027ce:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800027d2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    800027d6:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    800027da:	1004f793          	andi	a5,s1,256
    800027de:	c795                	beqz	a5,8000280a <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800027e0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800027e4:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    800027e6:	eb85                	bnez	a5,80002816 <kerneltrap+0x56>
  if ((which_dev = devintr()) == 0) {
    800027e8:	e5dff0ef          	jal	80002644 <devintr>
    800027ec:	c91d                	beqz	a0,80002822 <kerneltrap+0x62>
  if (which_dev == 2 && myproc() != 0)
    800027ee:	4789                	li	a5,2
    800027f0:	04f50a63          	beq	a0,a5,80002844 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r"(x));
    800027f4:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800027f8:	10049073          	csrw	sstatus,s1
}
    800027fc:	70a2                	ld	ra,40(sp)
    800027fe:	7402                	ld	s0,32(sp)
    80002800:	64e2                	ld	s1,24(sp)
    80002802:	6942                	ld	s2,16(sp)
    80002804:	69a2                	ld	s3,8(sp)
    80002806:	6145                	addi	sp,sp,48
    80002808:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000280a:	00005517          	auipc	a0,0x5
    8000280e:	b2e50513          	addi	a0,a0,-1234 # 80007338 <etext+0x338>
    80002812:	fddfd0ef          	jal	800007ee <panic>
    panic("kerneltrap: interrupts enabled");
    80002816:	00005517          	auipc	a0,0x5
    8000281a:	b4a50513          	addi	a0,a0,-1206 # 80007360 <etext+0x360>
    8000281e:	fd1fd0ef          	jal	800007ee <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002822:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002826:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    8000282a:	85ce                	mv	a1,s3
    8000282c:	00005517          	auipc	a0,0x5
    80002830:	b5450513          	addi	a0,a0,-1196 # 80007380 <etext+0x380>
    80002834:	cd7fd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    80002838:	00005517          	auipc	a0,0x5
    8000283c:	b7050513          	addi	a0,a0,-1168 # 800073a8 <etext+0x3a8>
    80002840:	faffd0ef          	jal	800007ee <panic>
  if (which_dev == 2 && myproc() != 0)
    80002844:	93aff0ef          	jal	8000197e <myproc>
    80002848:	d555                	beqz	a0,800027f4 <kerneltrap+0x34>
    yield();
    8000284a:	f92ff0ef          	jal	80001fdc <yield>
    8000284e:	b75d                	j	800027f4 <kerneltrap+0x34>

0000000080002850 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002850:	1101                	addi	sp,sp,-32
    80002852:	ec06                	sd	ra,24(sp)
    80002854:	e822                	sd	s0,16(sp)
    80002856:	e426                	sd	s1,8(sp)
    80002858:	1000                	addi	s0,sp,32
    8000285a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000285c:	922ff0ef          	jal	8000197e <myproc>
  switch (n) {
    80002860:	4795                	li	a5,5
    80002862:	0497e163          	bltu	a5,s1,800028a4 <argraw+0x54>
    80002866:	048a                	slli	s1,s1,0x2
    80002868:	00005717          	auipc	a4,0x5
    8000286c:	f4070713          	addi	a4,a4,-192 # 800077a8 <states.0+0x30>
    80002870:	94ba                	add	s1,s1,a4
    80002872:	409c                	lw	a5,0(s1)
    80002874:	97ba                	add	a5,a5,a4
    80002876:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002878:	6d3c                	ld	a5,88(a0)
    8000287a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000287c:	60e2                	ld	ra,24(sp)
    8000287e:	6442                	ld	s0,16(sp)
    80002880:	64a2                	ld	s1,8(sp)
    80002882:	6105                	addi	sp,sp,32
    80002884:	8082                	ret
    return p->trapframe->a1;
    80002886:	6d3c                	ld	a5,88(a0)
    80002888:	7fa8                	ld	a0,120(a5)
    8000288a:	bfcd                	j	8000287c <argraw+0x2c>
    return p->trapframe->a2;
    8000288c:	6d3c                	ld	a5,88(a0)
    8000288e:	63c8                	ld	a0,128(a5)
    80002890:	b7f5                	j	8000287c <argraw+0x2c>
    return p->trapframe->a3;
    80002892:	6d3c                	ld	a5,88(a0)
    80002894:	67c8                	ld	a0,136(a5)
    80002896:	b7dd                	j	8000287c <argraw+0x2c>
    return p->trapframe->a4;
    80002898:	6d3c                	ld	a5,88(a0)
    8000289a:	6bc8                	ld	a0,144(a5)
    8000289c:	b7c5                	j	8000287c <argraw+0x2c>
    return p->trapframe->a5;
    8000289e:	6d3c                	ld	a5,88(a0)
    800028a0:	6fc8                	ld	a0,152(a5)
    800028a2:	bfe9                	j	8000287c <argraw+0x2c>
  panic("argraw");
    800028a4:	00005517          	auipc	a0,0x5
    800028a8:	b1450513          	addi	a0,a0,-1260 # 800073b8 <etext+0x3b8>
    800028ac:	f43fd0ef          	jal	800007ee <panic>

00000000800028b0 <fetchaddr>:
{
    800028b0:	1101                	addi	sp,sp,-32
    800028b2:	ec06                	sd	ra,24(sp)
    800028b4:	e822                	sd	s0,16(sp)
    800028b6:	e426                	sd	s1,8(sp)
    800028b8:	e04a                	sd	s2,0(sp)
    800028ba:	1000                	addi	s0,sp,32
    800028bc:	84aa                	mv	s1,a0
    800028be:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800028c0:	8beff0ef          	jal	8000197e <myproc>
  if (addr >= p->sz ||
    800028c4:	652c                	ld	a1,72(a0)
    800028c6:	02b4f663          	bgeu	s1,a1,800028f2 <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800028ca:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    800028ce:	02f5e463          	bltu	a1,a5,800028f6 <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    800028d2:	4721                	li	a4,8
    800028d4:	86a6                	mv	a3,s1
    800028d6:	864a                	mv	a2,s2
    800028d8:	6928                	ld	a0,80(a0)
    800028da:	dcdfe0ef          	jal	800016a6 <copyin>
    800028de:	00a03533          	snez	a0,a0
    800028e2:	40a0053b          	negw	a0,a0
}
    800028e6:	60e2                	ld	ra,24(sp)
    800028e8:	6442                	ld	s0,16(sp)
    800028ea:	64a2                	ld	s1,8(sp)
    800028ec:	6902                	ld	s2,0(sp)
    800028ee:	6105                	addi	sp,sp,32
    800028f0:	8082                	ret
    return -1;
    800028f2:	557d                	li	a0,-1
    800028f4:	bfcd                	j	800028e6 <fetchaddr+0x36>
    800028f6:	557d                	li	a0,-1
    800028f8:	b7fd                	j	800028e6 <fetchaddr+0x36>

00000000800028fa <fetchstr>:
{
    800028fa:	7179                	addi	sp,sp,-48
    800028fc:	f406                	sd	ra,40(sp)
    800028fe:	f022                	sd	s0,32(sp)
    80002900:	ec26                	sd	s1,24(sp)
    80002902:	e84a                	sd	s2,16(sp)
    80002904:	e44e                	sd	s3,8(sp)
    80002906:	1800                	addi	s0,sp,48
    80002908:	892a                	mv	s2,a0
    8000290a:	84ae                	mv	s1,a1
    8000290c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000290e:	870ff0ef          	jal	8000197e <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    80002912:	874e                	mv	a4,s3
    80002914:	86ca                	mv	a3,s2
    80002916:	8626                	mv	a2,s1
    80002918:	652c                	ld	a1,72(a0)
    8000291a:	6928                	ld	a0,80(a0)
    8000291c:	e27fe0ef          	jal	80001742 <copyinstr>
    80002920:	00054c63          	bltz	a0,80002938 <fetchstr+0x3e>
  return strlen(buf);
    80002924:	8526                	mv	a0,s1
    80002926:	caefe0ef          	jal	80000dd4 <strlen>
}
    8000292a:	70a2                	ld	ra,40(sp)
    8000292c:	7402                	ld	s0,32(sp)
    8000292e:	64e2                	ld	s1,24(sp)
    80002930:	6942                	ld	s2,16(sp)
    80002932:	69a2                	ld	s3,8(sp)
    80002934:	6145                	addi	sp,sp,48
    80002936:	8082                	ret
    return -1;
    80002938:	557d                	li	a0,-1
    8000293a:	bfc5                	j	8000292a <fetchstr+0x30>

000000008000293c <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000293c:	1101                	addi	sp,sp,-32
    8000293e:	ec06                	sd	ra,24(sp)
    80002940:	e822                	sd	s0,16(sp)
    80002942:	e426                	sd	s1,8(sp)
    80002944:	1000                	addi	s0,sp,32
    80002946:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002948:	f09ff0ef          	jal	80002850 <argraw>
    8000294c:	c088                	sw	a0,0(s1)
}
    8000294e:	60e2                	ld	ra,24(sp)
    80002950:	6442                	ld	s0,16(sp)
    80002952:	64a2                	ld	s1,8(sp)
    80002954:	6105                	addi	sp,sp,32
    80002956:	8082                	ret

0000000080002958 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002958:	1101                	addi	sp,sp,-32
    8000295a:	ec06                	sd	ra,24(sp)
    8000295c:	e822                	sd	s0,16(sp)
    8000295e:	e426                	sd	s1,8(sp)
    80002960:	1000                	addi	s0,sp,32
    80002962:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002964:	eedff0ef          	jal	80002850 <argraw>
    80002968:	e088                	sd	a0,0(s1)
}
    8000296a:	60e2                	ld	ra,24(sp)
    8000296c:	6442                	ld	s0,16(sp)
    8000296e:	64a2                	ld	s1,8(sp)
    80002970:	6105                	addi	sp,sp,32
    80002972:	8082                	ret

0000000080002974 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002974:	1101                	addi	sp,sp,-32
    80002976:	ec06                	sd	ra,24(sp)
    80002978:	e822                	sd	s0,16(sp)
    8000297a:	e426                	sd	s1,8(sp)
    8000297c:	e04a                	sd	s2,0(sp)
    8000297e:	1000                	addi	s0,sp,32
    80002980:	84ae                	mv	s1,a1
    80002982:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002984:	ecdff0ef          	jal	80002850 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002988:	864a                	mv	a2,s2
    8000298a:	85a6                	mv	a1,s1
    8000298c:	f6fff0ef          	jal	800028fa <fetchstr>
}
    80002990:	60e2                	ld	ra,24(sp)
    80002992:	6442                	ld	s0,16(sp)
    80002994:	64a2                	ld	s1,8(sp)
    80002996:	6902                	ld	s2,0(sp)
    80002998:	6105                	addi	sp,sp,32
    8000299a:	8082                	ret

000000008000299c <syscall>:
  // clang-format on
};

void
syscall(void)
{
    8000299c:	1101                	addi	sp,sp,-32
    8000299e:	ec06                	sd	ra,24(sp)
    800029a0:	e822                	sd	s0,16(sp)
    800029a2:	e426                	sd	s1,8(sp)
    800029a4:	e04a                	sd	s2,0(sp)
    800029a6:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800029a8:	fd7fe0ef          	jal	8000197e <myproc>
    800029ac:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800029ae:	05853903          	ld	s2,88(a0)
    800029b2:	0a893783          	ld	a5,168(s2)
    800029b6:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800029ba:	37fd                	addiw	a5,a5,-1
    800029bc:	475d                	li	a4,23
    800029be:	00f76f63          	bltu	a4,a5,800029dc <syscall+0x40>
    800029c2:	00369713          	slli	a4,a3,0x3
    800029c6:	00005797          	auipc	a5,0x5
    800029ca:	dfa78793          	addi	a5,a5,-518 # 800077c0 <syscalls>
    800029ce:	97ba                	add	a5,a5,a4
    800029d0:	639c                	ld	a5,0(a5)
    800029d2:	c789                	beqz	a5,800029dc <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800029d4:	9782                	jalr	a5
    800029d6:	06a93823          	sd	a0,112(s2)
    800029da:	a829                	j	800029f4 <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    800029dc:	16048613          	addi	a2,s1,352
    800029e0:	588c                	lw	a1,48(s1)
    800029e2:	00005517          	auipc	a0,0x5
    800029e6:	9de50513          	addi	a0,a0,-1570 # 800073c0 <etext+0x3c0>
    800029ea:	b21fd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    800029ee:	6cbc                	ld	a5,88(s1)
    800029f0:	577d                	li	a4,-1
    800029f2:	fbb8                	sd	a4,112(a5)
  }
}
    800029f4:	60e2                	ld	ra,24(sp)
    800029f6:	6442                	ld	s0,16(sp)
    800029f8:	64a2                	ld	s1,8(sp)
    800029fa:	6902                	ld	s2,0(sp)
    800029fc:	6105                	addi	sp,sp,32
    800029fe:	8082                	ret

0000000080002a00 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002a00:	1101                	addi	sp,sp,-32
    80002a02:	ec06                	sd	ra,24(sp)
    80002a04:	e822                	sd	s0,16(sp)
    80002a06:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002a08:	fec40593          	addi	a1,s0,-20
    80002a0c:	4501                	li	a0,0
    80002a0e:	f2fff0ef          	jal	8000293c <argint>
  kexit(n);
    80002a12:	fec42503          	lw	a0,-20(s0)
    80002a16:	f1aff0ef          	jal	80002130 <kexit>
  return 0; // not reached
}
    80002a1a:	4501                	li	a0,0
    80002a1c:	60e2                	ld	ra,24(sp)
    80002a1e:	6442                	ld	s0,16(sp)
    80002a20:	6105                	addi	sp,sp,32
    80002a22:	8082                	ret

0000000080002a24 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002a24:	1141                	addi	sp,sp,-16
    80002a26:	e406                	sd	ra,8(sp)
    80002a28:	e022                	sd	s0,0(sp)
    80002a2a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002a2c:	f53fe0ef          	jal	8000197e <myproc>
}
    80002a30:	5908                	lw	a0,48(a0)
    80002a32:	60a2                	ld	ra,8(sp)
    80002a34:	6402                	ld	s0,0(sp)
    80002a36:	0141                	addi	sp,sp,16
    80002a38:	8082                	ret

0000000080002a3a <sys_fork>:

uint64
sys_fork(void)
{
    80002a3a:	1141                	addi	sp,sp,-16
    80002a3c:	e406                	sd	ra,8(sp)
    80002a3e:	e022                	sd	s0,0(sp)
    80002a40:	0800                	addi	s0,sp,16
  return kfork();
    80002a42:	b1eff0ef          	jal	80001d60 <kfork>
}
    80002a46:	60a2                	ld	ra,8(sp)
    80002a48:	6402                	ld	s0,0(sp)
    80002a4a:	0141                	addi	sp,sp,16
    80002a4c:	8082                	ret

0000000080002a4e <sys_wait>:

uint64
sys_wait(void)
{
    80002a4e:	1101                	addi	sp,sp,-32
    80002a50:	ec06                	sd	ra,24(sp)
    80002a52:	e822                	sd	s0,16(sp)
    80002a54:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002a56:	fe840593          	addi	a1,s0,-24
    80002a5a:	4501                	li	a0,0
    80002a5c:	efdff0ef          	jal	80002958 <argaddr>
  return kwait(p);
    80002a60:	fe843503          	ld	a0,-24(s0)
    80002a64:	829ff0ef          	jal	8000228c <kwait>
}
    80002a68:	60e2                	ld	ra,24(sp)
    80002a6a:	6442                	ld	s0,16(sp)
    80002a6c:	6105                	addi	sp,sp,32
    80002a6e:	8082                	ret

0000000080002a70 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002a70:	7179                	addi	sp,sp,-48
    80002a72:	f406                	sd	ra,40(sp)
    80002a74:	f022                	sd	s0,32(sp)
    80002a76:	ec26                	sd	s1,24(sp)
    80002a78:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002a7a:	fd840593          	addi	a1,s0,-40
    80002a7e:	4501                	li	a0,0
    80002a80:	ebdff0ef          	jal	8000293c <argint>
  argint(1, &t);
    80002a84:	fdc40593          	addi	a1,s0,-36
    80002a88:	4505                	li	a0,1
    80002a8a:	eb3ff0ef          	jal	8000293c <argint>
  addr = myproc()->sz;
    80002a8e:	ef1fe0ef          	jal	8000197e <myproc>
    80002a92:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002a94:	fdc42703          	lw	a4,-36(s0)
    80002a98:	4785                	li	a5,1
    80002a9a:	02f70763          	beq	a4,a5,80002ac8 <sys_sbrk+0x58>
    80002a9e:	fd842783          	lw	a5,-40(s0)
    80002aa2:	0207c363          	bltz	a5,80002ac8 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002aa6:	97a6                	add	a5,a5,s1
    80002aa8:	0297ee63          	bltu	a5,s1,80002ae4 <sys_sbrk+0x74>
      return -1;
    if (addr + n > USYSCALL)
    80002aac:	04000737          	lui	a4,0x4000
    80002ab0:	1775                	addi	a4,a4,-3 # 3fffffd <_entry-0x7c000003>
    80002ab2:	0732                	slli	a4,a4,0xc
    80002ab4:	02f76a63          	bltu	a4,a5,80002ae8 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002ab8:	ec7fe0ef          	jal	8000197e <myproc>
    80002abc:	fd842703          	lw	a4,-40(s0)
    80002ac0:	653c                	ld	a5,72(a0)
    80002ac2:	97ba                	add	a5,a5,a4
    80002ac4:	e53c                	sd	a5,72(a0)
    80002ac6:	a039                	j	80002ad4 <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002ac8:	fd842503          	lw	a0,-40(s0)
    80002acc:	a32ff0ef          	jal	80001cfe <growproc>
    80002ad0:	00054863          	bltz	a0,80002ae0 <sys_sbrk+0x70>
  }
  return addr;
}
    80002ad4:	8526                	mv	a0,s1
    80002ad6:	70a2                	ld	ra,40(sp)
    80002ad8:	7402                	ld	s0,32(sp)
    80002ada:	64e2                	ld	s1,24(sp)
    80002adc:	6145                	addi	sp,sp,48
    80002ade:	8082                	ret
      return -1;
    80002ae0:	54fd                	li	s1,-1
    80002ae2:	bfcd                	j	80002ad4 <sys_sbrk+0x64>
      return -1;
    80002ae4:	54fd                	li	s1,-1
    80002ae6:	b7fd                	j	80002ad4 <sys_sbrk+0x64>
      return -1;
    80002ae8:	54fd                	li	s1,-1
    80002aea:	b7ed                	j	80002ad4 <sys_sbrk+0x64>

0000000080002aec <sys_pause>:

uint64
sys_pause(void)
{
    80002aec:	7139                	addi	sp,sp,-64
    80002aee:	fc06                	sd	ra,56(sp)
    80002af0:	f822                	sd	s0,48(sp)
    80002af2:	ec4e                	sd	s3,24(sp)
    80002af4:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002af6:	fcc40593          	addi	a1,s0,-52
    80002afa:	4501                	li	a0,0
    80002afc:	e41ff0ef          	jal	8000293c <argint>
  if (n < 0)
    80002b00:	fcc42783          	lw	a5,-52(s0)
    80002b04:	0607cf63          	bltz	a5,80002b82 <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002b08:	00013517          	auipc	a0,0x13
    80002b0c:	f0850513          	addi	a0,a0,-248 # 80015a10 <tickslock>
    80002b10:	87cfe0ef          	jal	80000b8c <acquire>
  ticks0 = ticks;
    80002b14:	00005997          	auipc	s3,0x5
    80002b18:	dac9a983          	lw	s3,-596(s3) # 800078c0 <ticks>
  while (ticks - ticks0 < n) {
    80002b1c:	fcc42783          	lw	a5,-52(s0)
    80002b20:	c7a9                	beqz	a5,80002b6a <sys_pause+0x7e>
    80002b22:	f426                	sd	s1,40(sp)
    80002b24:	f04a                	sd	s2,32(sp)
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002b26:	00005917          	auipc	s2,0x5
    80002b2a:	d9a90913          	addi	s2,s2,-614 # 800078c0 <ticks>
    release(&tickslock);
    80002b2e:	00013497          	auipc	s1,0x13
    80002b32:	ee248493          	addi	s1,s1,-286 # 80015a10 <tickslock>
    if (killed(myproc())) {
    80002b36:	e49fe0ef          	jal	8000197e <myproc>
    80002b3a:	f28ff0ef          	jal	80002262 <killed>
    80002b3e:	e529                	bnez	a0,80002b88 <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002b40:	854a                	mv	a0,s2
    80002b42:	cc6ff0ef          	jal	80002008 <sleep_prepare>
    release(&tickslock);
    80002b46:	8526                	mv	a0,s1
    80002b48:	8ccfe0ef          	jal	80000c14 <release>
    sleep();
    80002b4c:	cf8ff0ef          	jal	80002044 <sleep>
    acquire(&tickslock);
    80002b50:	8526                	mv	a0,s1
    80002b52:	83afe0ef          	jal	80000b8c <acquire>
  while (ticks - ticks0 < n) {
    80002b56:	00092783          	lw	a5,0(s2)
    80002b5a:	413787bb          	subw	a5,a5,s3
    80002b5e:	fcc42703          	lw	a4,-52(s0)
    80002b62:	fce7eae3          	bltu	a5,a4,80002b36 <sys_pause+0x4a>
    80002b66:	74a2                	ld	s1,40(sp)
    80002b68:	7902                	ld	s2,32(sp)
  }
  release(&tickslock);
    80002b6a:	00013517          	auipc	a0,0x13
    80002b6e:	ea650513          	addi	a0,a0,-346 # 80015a10 <tickslock>
    80002b72:	8a2fe0ef          	jal	80000c14 <release>
  return 0;
    80002b76:	4501                	li	a0,0
}
    80002b78:	70e2                	ld	ra,56(sp)
    80002b7a:	7442                	ld	s0,48(sp)
    80002b7c:	69e2                	ld	s3,24(sp)
    80002b7e:	6121                	addi	sp,sp,64
    80002b80:	8082                	ret
    n = 0;
    80002b82:	fc042623          	sw	zero,-52(s0)
    80002b86:	b749                	j	80002b08 <sys_pause+0x1c>
      release(&tickslock);
    80002b88:	00013517          	auipc	a0,0x13
    80002b8c:	e8850513          	addi	a0,a0,-376 # 80015a10 <tickslock>
    80002b90:	884fe0ef          	jal	80000c14 <release>
      return -1;
    80002b94:	557d                	li	a0,-1
    80002b96:	74a2                	ld	s1,40(sp)
    80002b98:	7902                	ld	s2,32(sp)
    80002b9a:	bff9                	j	80002b78 <sys_pause+0x8c>

0000000080002b9c <sys_kill>:

uint64
sys_kill(void)
{
    80002b9c:	1101                	addi	sp,sp,-32
    80002b9e:	ec06                	sd	ra,24(sp)
    80002ba0:	e822                	sd	s0,16(sp)
    80002ba2:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002ba4:	fec40593          	addi	a1,s0,-20
    80002ba8:	4501                	li	a0,0
    80002baa:	d93ff0ef          	jal	8000293c <argint>
  return kkill(pid);
    80002bae:	fec42503          	lw	a0,-20(s0)
    80002bb2:	e20ff0ef          	jal	800021d2 <kkill>
}
    80002bb6:	60e2                	ld	ra,24(sp)
    80002bb8:	6442                	ld	s0,16(sp)
    80002bba:	6105                	addi	sp,sp,32
    80002bbc:	8082                	ret

0000000080002bbe <sys_vmprint>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_vmprint(void)
{
    80002bbe:	1141                	addi	sp,sp,-16
    80002bc0:	e406                	sd	ra,8(sp)
    80002bc2:	e022                	sd	s0,0(sp)
    80002bc4:	0800                	addi	s0,sp,16
  vmprint(myproc()->pagetable);
    80002bc6:	db9fe0ef          	jal	8000197e <myproc>
    80002bca:	6928                	ld	a0,80(a0)
    80002bcc:	84dfe0ef          	jal	80001418 <vmprint>
  return 0;
}
    80002bd0:	4501                	li	a0,0
    80002bd2:	60a2                	ld	ra,8(sp)
    80002bd4:	6402                	ld	s0,0(sp)
    80002bd6:	0141                	addi	sp,sp,16
    80002bd8:	8082                	ret

0000000080002bda <sys_pgaccess>:

uint64
sys_pgaccess(void)
{
    80002bda:	715d                	addi	sp,sp,-80
    80002bdc:	e486                	sd	ra,72(sp)
    80002bde:	e0a2                	sd	s0,64(sp)
    80002be0:	f84a                	sd	s2,48(sp)
    80002be2:	0880                	addi	s0,sp,80
  uint64 base, umask, mask = 0;
    80002be4:	fa043c23          	sd	zero,-72(s0)
  int npages;
  struct proc *p = myproc();
    80002be8:	d97fe0ef          	jal	8000197e <myproc>
    80002bec:	892a                	mv	s2,a0

  argaddr(0, &base);
    80002bee:	fc840593          	addi	a1,s0,-56
    80002bf2:	4501                	li	a0,0
    80002bf4:	d65ff0ef          	jal	80002958 <argaddr>
  argint(1, &npages);
    80002bf8:	fb440593          	addi	a1,s0,-76
    80002bfc:	4505                	li	a0,1
    80002bfe:	d3fff0ef          	jal	8000293c <argint>
  argaddr(2, &umask);
    80002c02:	fc040593          	addi	a1,s0,-64
    80002c06:	4509                	li	a0,2
    80002c08:	d51ff0ef          	jal	80002958 <argaddr>
  if (base % PGSIZE != 0 || npages < 1 || npages > 64)
    80002c0c:	fc843703          	ld	a4,-56(s0)
    80002c10:	03471793          	slli	a5,a4,0x34
    return -1;
    80002c14:	557d                	li	a0,-1
  if (base % PGSIZE != 0 || npages < 1 || npages > 64)
    80002c16:	ebd1                	bnez	a5,80002caa <sys_pgaccess+0xd0>
    80002c18:	fc26                	sd	s1,56(sp)
    80002c1a:	0347d493          	srli	s1,a5,0x34
    80002c1e:	fb442783          	lw	a5,-76(s0)
    80002c22:	fff7861b          	addiw	a2,a5,-1
    80002c26:	03f00693          	li	a3,63
    80002c2a:	08c6e563          	bltu	a3,a2,80002cb4 <sys_pgaccess+0xda>
  if (base + (uint64)npages * PGSIZE > p->sz)
    80002c2e:	07b2                	slli	a5,a5,0xc
    80002c30:	97ba                	add	a5,a5,a4
    80002c32:	04893703          	ld	a4,72(s2)
    80002c36:	08f76263          	bltu	a4,a5,80002cba <sys_pgaccess+0xe0>
    80002c3a:	f44e                	sd	s3,40(sp)
    80002c3c:	f052                	sd	s4,32(sp)
  for (int i = 0; i < npages; i++) {
    pte_t *pte = walk(p->pagetable, base + (uint64)i * PGSIZE, 0);
    // páginas sin memoria física (p. ej. perezosas) cuentan como no accedidas
    if (pte == 0 || (*pte & PTE_V) == 0)
      continue;
    if (*pte & PTE_A) {
    80002c3e:	04100993          	li	s3,65
      mask |= 1L << i;
    80002c42:	4a05                	li	s4,1
    80002c44:	a801                	j	80002c54 <sys_pgaccess+0x7a>
  for (int i = 0; i < npages; i++) {
    80002c46:	0485                	addi	s1,s1,1
    80002c48:	fb442703          	lw	a4,-76(s0)
    80002c4c:	0004879b          	sext.w	a5,s1
    80002c50:	02e7de63          	bge	a5,a4,80002c8c <sys_pgaccess+0xb2>
    pte_t *pte = walk(p->pagetable, base + (uint64)i * PGSIZE, 0);
    80002c54:	00c49593          	slli	a1,s1,0xc
    80002c58:	4601                	li	a2,0
    80002c5a:	fc843783          	ld	a5,-56(s0)
    80002c5e:	95be                	add	a1,a1,a5
    80002c60:	05093503          	ld	a0,80(s2)
    80002c64:	b34fe0ef          	jal	80000f98 <walk>
    if (pte == 0 || (*pte & PTE_V) == 0)
    80002c68:	dd79                	beqz	a0,80002c46 <sys_pgaccess+0x6c>
    if (*pte & PTE_A) {
    80002c6a:	611c                	ld	a5,0(a0)
    80002c6c:	0417f793          	andi	a5,a5,65
    80002c70:	fd379be3          	bne	a5,s3,80002c46 <sys_pgaccess+0x6c>
      mask |= 1L << i;
    80002c74:	009a1733          	sll	a4,s4,s1
    80002c78:	fb843783          	ld	a5,-72(s0)
    80002c7c:	8fd9                	or	a5,a5,a4
    80002c7e:	faf43c23          	sd	a5,-72(s0)
      *pte &= ~PTE_A;
    80002c82:	611c                	ld	a5,0(a0)
    80002c84:	fbf7f793          	andi	a5,a5,-65
    80002c88:	e11c                	sd	a5,0(a0)
    80002c8a:	bf75                	j	80002c46 <sys_pgaccess+0x6c>
    }
  }
  if (copyout(p->pagetable, p->sz, umask, (char *)&mask, sizeof(mask)) < 0)
    80002c8c:	4721                	li	a4,8
    80002c8e:	fb840693          	addi	a3,s0,-72
    80002c92:	fc043603          	ld	a2,-64(s0)
    80002c96:	04893583          	ld	a1,72(s2)
    80002c9a:	05093503          	ld	a0,80(s2)
    80002c9e:	943fe0ef          	jal	800015e0 <copyout>
    80002ca2:	957d                	srai	a0,a0,0x3f
    80002ca4:	74e2                	ld	s1,56(sp)
    80002ca6:	79a2                	ld	s3,40(sp)
    80002ca8:	7a02                	ld	s4,32(sp)
    return -1;
  return 0;
}
    80002caa:	60a6                	ld	ra,72(sp)
    80002cac:	6406                	ld	s0,64(sp)
    80002cae:	7942                	ld	s2,48(sp)
    80002cb0:	6161                	addi	sp,sp,80
    80002cb2:	8082                	ret
    return -1;
    80002cb4:	557d                	li	a0,-1
    80002cb6:	74e2                	ld	s1,56(sp)
    80002cb8:	bfcd                	j	80002caa <sys_pgaccess+0xd0>
    80002cba:	74e2                	ld	s1,56(sp)
    80002cbc:	b7fd                	j	80002caa <sys_pgaccess+0xd0>

0000000080002cbe <sys_uptime>:

uint64
sys_uptime(void)
{
    80002cbe:	1101                	addi	sp,sp,-32
    80002cc0:	ec06                	sd	ra,24(sp)
    80002cc2:	e822                	sd	s0,16(sp)
    80002cc4:	e426                	sd	s1,8(sp)
    80002cc6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002cc8:	00013517          	auipc	a0,0x13
    80002ccc:	d4850513          	addi	a0,a0,-696 # 80015a10 <tickslock>
    80002cd0:	ebdfd0ef          	jal	80000b8c <acquire>
  xticks = ticks;
    80002cd4:	00005497          	auipc	s1,0x5
    80002cd8:	bec4a483          	lw	s1,-1044(s1) # 800078c0 <ticks>
  release(&tickslock);
    80002cdc:	00013517          	auipc	a0,0x13
    80002ce0:	d3450513          	addi	a0,a0,-716 # 80015a10 <tickslock>
    80002ce4:	f31fd0ef          	jal	80000c14 <release>
  return xticks;
}
    80002ce8:	02049513          	slli	a0,s1,0x20
    80002cec:	9101                	srli	a0,a0,0x20
    80002cee:	60e2                	ld	ra,24(sp)
    80002cf0:	6442                	ld	s0,16(sp)
    80002cf2:	64a2                	ld	s1,8(sp)
    80002cf4:	6105                	addi	sp,sp,32
    80002cf6:	8082                	ret

0000000080002cf8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002cf8:	7179                	addi	sp,sp,-48
    80002cfa:	f406                	sd	ra,40(sp)
    80002cfc:	f022                	sd	s0,32(sp)
    80002cfe:	ec26                	sd	s1,24(sp)
    80002d00:	e84a                	sd	s2,16(sp)
    80002d02:	e44e                	sd	s3,8(sp)
    80002d04:	e052                	sd	s4,0(sp)
    80002d06:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002d08:	00004597          	auipc	a1,0x4
    80002d0c:	6d858593          	addi	a1,a1,1752 # 800073e0 <etext+0x3e0>
    80002d10:	00013517          	auipc	a0,0x13
    80002d14:	d1850513          	addi	a0,a0,-744 # 80015a28 <bcache>
    80002d18:	dfbfd0ef          	jal	80000b12 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002d1c:	0001b797          	auipc	a5,0x1b
    80002d20:	d0c78793          	addi	a5,a5,-756 # 8001da28 <bcache+0x8000>
    80002d24:	0001b717          	auipc	a4,0x1b
    80002d28:	f6c70713          	addi	a4,a4,-148 # 8001dc90 <bcache+0x8268>
    80002d2c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002d30:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002d34:	00013497          	auipc	s1,0x13
    80002d38:	d0c48493          	addi	s1,s1,-756 # 80015a40 <bcache+0x18>
    b->next = bcache.head.next;
    80002d3c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002d3e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002d40:	00004a17          	auipc	s4,0x4
    80002d44:	6a8a0a13          	addi	s4,s4,1704 # 800073e8 <etext+0x3e8>
    b->next = bcache.head.next;
    80002d48:	2b893783          	ld	a5,696(s2)
    80002d4c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002d4e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002d52:	85d2                	mv	a1,s4
    80002d54:	01048513          	addi	a0,s1,16
    80002d58:	40c010ef          	jal	80004164 <initsleeplock>
    bcache.head.next->prev = b;
    80002d5c:	2b893783          	ld	a5,696(s2)
    80002d60:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002d62:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002d66:	45848493          	addi	s1,s1,1112
    80002d6a:	fd349fe3          	bne	s1,s3,80002d48 <binit+0x50>
  }
}
    80002d6e:	70a2                	ld	ra,40(sp)
    80002d70:	7402                	ld	s0,32(sp)
    80002d72:	64e2                	ld	s1,24(sp)
    80002d74:	6942                	ld	s2,16(sp)
    80002d76:	69a2                	ld	s3,8(sp)
    80002d78:	6a02                	ld	s4,0(sp)
    80002d7a:	6145                	addi	sp,sp,48
    80002d7c:	8082                	ret

0000000080002d7e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002d7e:	7179                	addi	sp,sp,-48
    80002d80:	f406                	sd	ra,40(sp)
    80002d82:	f022                	sd	s0,32(sp)
    80002d84:	ec26                	sd	s1,24(sp)
    80002d86:	e84a                	sd	s2,16(sp)
    80002d88:	e44e                	sd	s3,8(sp)
    80002d8a:	1800                	addi	s0,sp,48
    80002d8c:	892a                	mv	s2,a0
    80002d8e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002d90:	00013517          	auipc	a0,0x13
    80002d94:	c9850513          	addi	a0,a0,-872 # 80015a28 <bcache>
    80002d98:	df5fd0ef          	jal	80000b8c <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002d9c:	0001b497          	auipc	s1,0x1b
    80002da0:	f444b483          	ld	s1,-188(s1) # 8001dce0 <bcache+0x82b8>
    80002da4:	0001b797          	auipc	a5,0x1b
    80002da8:	eec78793          	addi	a5,a5,-276 # 8001dc90 <bcache+0x8268>
    80002dac:	02f48b63          	beq	s1,a5,80002de2 <bread+0x64>
    80002db0:	873e                	mv	a4,a5
    80002db2:	a021                	j	80002dba <bread+0x3c>
    80002db4:	68a4                	ld	s1,80(s1)
    80002db6:	02e48663          	beq	s1,a4,80002de2 <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002dba:	449c                	lw	a5,8(s1)
    80002dbc:	ff279ce3          	bne	a5,s2,80002db4 <bread+0x36>
    80002dc0:	44dc                	lw	a5,12(s1)
    80002dc2:	ff3799e3          	bne	a5,s3,80002db4 <bread+0x36>
      b->refcnt++;
    80002dc6:	40bc                	lw	a5,64(s1)
    80002dc8:	2785                	addiw	a5,a5,1
    80002dca:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002dcc:	00013517          	auipc	a0,0x13
    80002dd0:	c5c50513          	addi	a0,a0,-932 # 80015a28 <bcache>
    80002dd4:	e41fd0ef          	jal	80000c14 <release>
      acquiresleep(&b->lock);
    80002dd8:	01048513          	addi	a0,s1,16
    80002ddc:	3be010ef          	jal	8000419a <acquiresleep>
      return b;
    80002de0:	a889                	j	80002e32 <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002de2:	0001b497          	auipc	s1,0x1b
    80002de6:	ef64b483          	ld	s1,-266(s1) # 8001dcd8 <bcache+0x82b0>
    80002dea:	0001b797          	auipc	a5,0x1b
    80002dee:	ea678793          	addi	a5,a5,-346 # 8001dc90 <bcache+0x8268>
    80002df2:	00f48863          	beq	s1,a5,80002e02 <bread+0x84>
    80002df6:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002df8:	40bc                	lw	a5,64(s1)
    80002dfa:	cb91                	beqz	a5,80002e0e <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002dfc:	64a4                	ld	s1,72(s1)
    80002dfe:	fee49de3          	bne	s1,a4,80002df8 <bread+0x7a>
  panic("bget: no buffers");
    80002e02:	00004517          	auipc	a0,0x4
    80002e06:	5ee50513          	addi	a0,a0,1518 # 800073f0 <etext+0x3f0>
    80002e0a:	9e5fd0ef          	jal	800007ee <panic>
      b->dev = dev;
    80002e0e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002e12:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002e16:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002e1a:	4785                	li	a5,1
    80002e1c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e1e:	00013517          	auipc	a0,0x13
    80002e22:	c0a50513          	addi	a0,a0,-1014 # 80015a28 <bcache>
    80002e26:	deffd0ef          	jal	80000c14 <release>
      acquiresleep(&b->lock);
    80002e2a:	01048513          	addi	a0,s1,16
    80002e2e:	36c010ef          	jal	8000419a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002e32:	409c                	lw	a5,0(s1)
    80002e34:	cb89                	beqz	a5,80002e46 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002e36:	8526                	mv	a0,s1
    80002e38:	70a2                	ld	ra,40(sp)
    80002e3a:	7402                	ld	s0,32(sp)
    80002e3c:	64e2                	ld	s1,24(sp)
    80002e3e:	6942                	ld	s2,16(sp)
    80002e40:	69a2                	ld	s3,8(sp)
    80002e42:	6145                	addi	sp,sp,48
    80002e44:	8082                	ret
    virtio_disk_rw(b, 0);
    80002e46:	4581                	li	a1,0
    80002e48:	8526                	mv	a0,s1
    80002e4a:	4b7020ef          	jal	80005b00 <virtio_disk_rw>
    b->valid = 1;
    80002e4e:	4785                	li	a5,1
    80002e50:	c09c                	sw	a5,0(s1)
  return b;
    80002e52:	b7d5                	j	80002e36 <bread+0xb8>

0000000080002e54 <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002e54:	1101                	addi	sp,sp,-32
    80002e56:	ec06                	sd	ra,24(sp)
    80002e58:	e822                	sd	s0,16(sp)
    80002e5a:	e426                	sd	s1,8(sp)
    80002e5c:	1000                	addi	s0,sp,32
    80002e5e:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002e60:	0541                	addi	a0,a0,16
    80002e62:	3c4010ef          	jal	80004226 <holdingsleep>
    80002e66:	c911                	beqz	a0,80002e7a <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002e68:	4585                	li	a1,1
    80002e6a:	8526                	mv	a0,s1
    80002e6c:	495020ef          	jal	80005b00 <virtio_disk_rw>
}
    80002e70:	60e2                	ld	ra,24(sp)
    80002e72:	6442                	ld	s0,16(sp)
    80002e74:	64a2                	ld	s1,8(sp)
    80002e76:	6105                	addi	sp,sp,32
    80002e78:	8082                	ret
    panic("bwrite");
    80002e7a:	00004517          	auipc	a0,0x4
    80002e7e:	58e50513          	addi	a0,a0,1422 # 80007408 <etext+0x408>
    80002e82:	96dfd0ef          	jal	800007ee <panic>

0000000080002e86 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002e86:	1101                	addi	sp,sp,-32
    80002e88:	ec06                	sd	ra,24(sp)
    80002e8a:	e822                	sd	s0,16(sp)
    80002e8c:	e426                	sd	s1,8(sp)
    80002e8e:	e04a                	sd	s2,0(sp)
    80002e90:	1000                	addi	s0,sp,32
    80002e92:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002e94:	01050913          	addi	s2,a0,16
    80002e98:	854a                	mv	a0,s2
    80002e9a:	38c010ef          	jal	80004226 <holdingsleep>
    80002e9e:	c125                	beqz	a0,80002efe <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002ea0:	854a                	mv	a0,s2
    80002ea2:	34c010ef          	jal	800041ee <releasesleep>

  acquire(&bcache.lock);
    80002ea6:	00013517          	auipc	a0,0x13
    80002eaa:	b8250513          	addi	a0,a0,-1150 # 80015a28 <bcache>
    80002eae:	cdffd0ef          	jal	80000b8c <acquire>
  b->refcnt--;
    80002eb2:	40bc                	lw	a5,64(s1)
    80002eb4:	37fd                	addiw	a5,a5,-1
    80002eb6:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002eb8:	e79d                	bnez	a5,80002ee6 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002eba:	68b8                	ld	a4,80(s1)
    80002ebc:	64bc                	ld	a5,72(s1)
    80002ebe:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002ec0:	68b8                	ld	a4,80(s1)
    80002ec2:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002ec4:	0001b797          	auipc	a5,0x1b
    80002ec8:	b6478793          	addi	a5,a5,-1180 # 8001da28 <bcache+0x8000>
    80002ecc:	2b87b703          	ld	a4,696(a5)
    80002ed0:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002ed2:	0001b717          	auipc	a4,0x1b
    80002ed6:	dbe70713          	addi	a4,a4,-578 # 8001dc90 <bcache+0x8268>
    80002eda:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002edc:	2b87b703          	ld	a4,696(a5)
    80002ee0:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002ee2:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002ee6:	00013517          	auipc	a0,0x13
    80002eea:	b4250513          	addi	a0,a0,-1214 # 80015a28 <bcache>
    80002eee:	d27fd0ef          	jal	80000c14 <release>
}
    80002ef2:	60e2                	ld	ra,24(sp)
    80002ef4:	6442                	ld	s0,16(sp)
    80002ef6:	64a2                	ld	s1,8(sp)
    80002ef8:	6902                	ld	s2,0(sp)
    80002efa:	6105                	addi	sp,sp,32
    80002efc:	8082                	ret
    panic("brelse");
    80002efe:	00004517          	auipc	a0,0x4
    80002f02:	51250513          	addi	a0,a0,1298 # 80007410 <etext+0x410>
    80002f06:	8e9fd0ef          	jal	800007ee <panic>

0000000080002f0a <bpin>:

void
bpin(struct buf *b)
{
    80002f0a:	1101                	addi	sp,sp,-32
    80002f0c:	ec06                	sd	ra,24(sp)
    80002f0e:	e822                	sd	s0,16(sp)
    80002f10:	e426                	sd	s1,8(sp)
    80002f12:	1000                	addi	s0,sp,32
    80002f14:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f16:	00013517          	auipc	a0,0x13
    80002f1a:	b1250513          	addi	a0,a0,-1262 # 80015a28 <bcache>
    80002f1e:	c6ffd0ef          	jal	80000b8c <acquire>
  b->refcnt++;
    80002f22:	40bc                	lw	a5,64(s1)
    80002f24:	2785                	addiw	a5,a5,1
    80002f26:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f28:	00013517          	auipc	a0,0x13
    80002f2c:	b0050513          	addi	a0,a0,-1280 # 80015a28 <bcache>
    80002f30:	ce5fd0ef          	jal	80000c14 <release>
}
    80002f34:	60e2                	ld	ra,24(sp)
    80002f36:	6442                	ld	s0,16(sp)
    80002f38:	64a2                	ld	s1,8(sp)
    80002f3a:	6105                	addi	sp,sp,32
    80002f3c:	8082                	ret

0000000080002f3e <bunpin>:

void
bunpin(struct buf *b)
{
    80002f3e:	1101                	addi	sp,sp,-32
    80002f40:	ec06                	sd	ra,24(sp)
    80002f42:	e822                	sd	s0,16(sp)
    80002f44:	e426                	sd	s1,8(sp)
    80002f46:	1000                	addi	s0,sp,32
    80002f48:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f4a:	00013517          	auipc	a0,0x13
    80002f4e:	ade50513          	addi	a0,a0,-1314 # 80015a28 <bcache>
    80002f52:	c3bfd0ef          	jal	80000b8c <acquire>
  b->refcnt--;
    80002f56:	40bc                	lw	a5,64(s1)
    80002f58:	37fd                	addiw	a5,a5,-1
    80002f5a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f5c:	00013517          	auipc	a0,0x13
    80002f60:	acc50513          	addi	a0,a0,-1332 # 80015a28 <bcache>
    80002f64:	cb1fd0ef          	jal	80000c14 <release>
}
    80002f68:	60e2                	ld	ra,24(sp)
    80002f6a:	6442                	ld	s0,16(sp)
    80002f6c:	64a2                	ld	s1,8(sp)
    80002f6e:	6105                	addi	sp,sp,32
    80002f70:	8082                	ret

0000000080002f72 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002f72:	1101                	addi	sp,sp,-32
    80002f74:	ec06                	sd	ra,24(sp)
    80002f76:	e822                	sd	s0,16(sp)
    80002f78:	e426                	sd	s1,8(sp)
    80002f7a:	e04a                	sd	s2,0(sp)
    80002f7c:	1000                	addi	s0,sp,32
    80002f7e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002f80:	00d5d79b          	srliw	a5,a1,0xd
    80002f84:	0001b597          	auipc	a1,0x1b
    80002f88:	1805a583          	lw	a1,384(a1) # 8001e104 <sb+0x1c>
    80002f8c:	9dbd                	addw	a1,a1,a5
    80002f8e:	df1ff0ef          	jal	80002d7e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002f92:	0074f713          	andi	a4,s1,7
    80002f96:	4785                	li	a5,1
    80002f98:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002f9c:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    80002f9e:	90d9                	srli	s1,s1,0x36
    80002fa0:	00950733          	add	a4,a0,s1
    80002fa4:	05874703          	lbu	a4,88(a4)
    80002fa8:	00e7f6b3          	and	a3,a5,a4
    80002fac:	c29d                	beqz	a3,80002fd2 <bfree+0x60>
    80002fae:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002fb0:	94aa                	add	s1,s1,a0
    80002fb2:	fff7c793          	not	a5,a5
    80002fb6:	8f7d                	and	a4,a4,a5
    80002fb8:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002fbc:	076010ef          	jal	80004032 <log_write>
  brelse(bp);
    80002fc0:	854a                	mv	a0,s2
    80002fc2:	ec5ff0ef          	jal	80002e86 <brelse>
}
    80002fc6:	60e2                	ld	ra,24(sp)
    80002fc8:	6442                	ld	s0,16(sp)
    80002fca:	64a2                	ld	s1,8(sp)
    80002fcc:	6902                	ld	s2,0(sp)
    80002fce:	6105                	addi	sp,sp,32
    80002fd0:	8082                	ret
    panic("freeing free block");
    80002fd2:	00004517          	auipc	a0,0x4
    80002fd6:	44650513          	addi	a0,a0,1094 # 80007418 <etext+0x418>
    80002fda:	815fd0ef          	jal	800007ee <panic>

0000000080002fde <balloc>:
{
    80002fde:	715d                	addi	sp,sp,-80
    80002fe0:	e486                	sd	ra,72(sp)
    80002fe2:	e0a2                	sd	s0,64(sp)
    80002fe4:	fc26                	sd	s1,56(sp)
    80002fe6:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    80002fe8:	0001b797          	auipc	a5,0x1b
    80002fec:	1047a783          	lw	a5,260(a5) # 8001e0ec <sb+0x4>
    80002ff0:	0e078863          	beqz	a5,800030e0 <balloc+0x102>
    80002ff4:	f84a                	sd	s2,48(sp)
    80002ff6:	f44e                	sd	s3,40(sp)
    80002ff8:	f052                	sd	s4,32(sp)
    80002ffa:	ec56                	sd	s5,24(sp)
    80002ffc:	e85a                	sd	s6,16(sp)
    80002ffe:	e45e                	sd	s7,8(sp)
    80003000:	e062                	sd	s8,0(sp)
    80003002:	8baa                	mv	s7,a0
    80003004:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003006:	0001bb17          	auipc	s6,0x1b
    8000300a:	0e2b0b13          	addi	s6,s6,226 # 8001e0e8 <sb>
      m = 1 << (bi % 8);
    8000300e:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003010:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80003012:	6c09                	lui	s8,0x2
    80003014:	a09d                	j	8000307a <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80003016:	97ca                	add	a5,a5,s2
    80003018:	8e55                	or	a2,a2,a3
    8000301a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000301e:	854a                	mv	a0,s2
    80003020:	012010ef          	jal	80004032 <log_write>
        brelse(bp);
    80003024:	854a                	mv	a0,s2
    80003026:	e61ff0ef          	jal	80002e86 <brelse>
  bp = bread(dev, bno);
    8000302a:	85a6                	mv	a1,s1
    8000302c:	855e                	mv	a0,s7
    8000302e:	d51ff0ef          	jal	80002d7e <bread>
    80003032:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003034:	40000613          	li	a2,1024
    80003038:	4581                	li	a1,0
    8000303a:	05850513          	addi	a0,a0,88
    8000303e:	c0ffd0ef          	jal	80000c4c <memset>
  log_write(bp);
    80003042:	854a                	mv	a0,s2
    80003044:	7ef000ef          	jal	80004032 <log_write>
  brelse(bp);
    80003048:	854a                	mv	a0,s2
    8000304a:	e3dff0ef          	jal	80002e86 <brelse>
}
    8000304e:	7942                	ld	s2,48(sp)
    80003050:	79a2                	ld	s3,40(sp)
    80003052:	7a02                	ld	s4,32(sp)
    80003054:	6ae2                	ld	s5,24(sp)
    80003056:	6b42                	ld	s6,16(sp)
    80003058:	6ba2                	ld	s7,8(sp)
    8000305a:	6c02                	ld	s8,0(sp)
}
    8000305c:	8526                	mv	a0,s1
    8000305e:	60a6                	ld	ra,72(sp)
    80003060:	6406                	ld	s0,64(sp)
    80003062:	74e2                	ld	s1,56(sp)
    80003064:	6161                	addi	sp,sp,80
    80003066:	8082                	ret
    brelse(bp);
    80003068:	854a                	mv	a0,s2
    8000306a:	e1dff0ef          	jal	80002e86 <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    8000306e:	015c0abb          	addw	s5,s8,s5
    80003072:	004b2783          	lw	a5,4(s6)
    80003076:	04fafe63          	bgeu	s5,a5,800030d2 <balloc+0xf4>
    bp = bread(dev, BBLOCK(b, sb));
    8000307a:	41fad79b          	sraiw	a5,s5,0x1f
    8000307e:	0137d79b          	srliw	a5,a5,0x13
    80003082:	015787bb          	addw	a5,a5,s5
    80003086:	40d7d79b          	sraiw	a5,a5,0xd
    8000308a:	01cb2583          	lw	a1,28(s6)
    8000308e:	9dbd                	addw	a1,a1,a5
    80003090:	855e                	mv	a0,s7
    80003092:	cedff0ef          	jal	80002d7e <bread>
    80003096:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003098:	004b2503          	lw	a0,4(s6)
    8000309c:	84d6                	mv	s1,s5
    8000309e:	4701                	li	a4,0
    800030a0:	fca4f4e3          	bgeu	s1,a0,80003068 <balloc+0x8a>
      m = 1 << (bi % 8);
    800030a4:	00777693          	andi	a3,a4,7
    800030a8:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    800030ac:	41f7579b          	sraiw	a5,a4,0x1f
    800030b0:	01d7d79b          	srliw	a5,a5,0x1d
    800030b4:	9fb9                	addw	a5,a5,a4
    800030b6:	4037d79b          	sraiw	a5,a5,0x3
    800030ba:	00f90633          	add	a2,s2,a5
    800030be:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    800030c2:	00c6f5b3          	and	a1,a3,a2
    800030c6:	d9a1                	beqz	a1,80003016 <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    800030c8:	2705                	addiw	a4,a4,1
    800030ca:	2485                	addiw	s1,s1,1
    800030cc:	fd471ae3          	bne	a4,s4,800030a0 <balloc+0xc2>
    800030d0:	bf61                	j	80003068 <balloc+0x8a>
    800030d2:	7942                	ld	s2,48(sp)
    800030d4:	79a2                	ld	s3,40(sp)
    800030d6:	7a02                	ld	s4,32(sp)
    800030d8:	6ae2                	ld	s5,24(sp)
    800030da:	6b42                	ld	s6,16(sp)
    800030dc:	6ba2                	ld	s7,8(sp)
    800030de:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    800030e0:	00004517          	auipc	a0,0x4
    800030e4:	35050513          	addi	a0,a0,848 # 80007430 <etext+0x430>
    800030e8:	c22fd0ef          	jal	8000050a <printk>
  return 0;
    800030ec:	4481                	li	s1,0
    800030ee:	b7bd                	j	8000305c <balloc+0x7e>

00000000800030f0 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800030f0:	7179                	addi	sp,sp,-48
    800030f2:	f406                	sd	ra,40(sp)
    800030f4:	f022                	sd	s0,32(sp)
    800030f6:	ec26                	sd	s1,24(sp)
    800030f8:	e84a                	sd	s2,16(sp)
    800030fa:	e44e                	sd	s3,8(sp)
    800030fc:	1800                	addi	s0,sp,48
    800030fe:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    80003100:	47ad                	li	a5,11
    80003102:	02b7e363          	bltu	a5,a1,80003128 <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    80003106:	02059793          	slli	a5,a1,0x20
    8000310a:	01e7d593          	srli	a1,a5,0x1e
    8000310e:	00b504b3          	add	s1,a0,a1
    80003112:	0504a903          	lw	s2,80(s1)
    80003116:	06091363          	bnez	s2,8000317c <bmap+0x8c>
      addr = balloc(ip->dev);
    8000311a:	4108                	lw	a0,0(a0)
    8000311c:	ec3ff0ef          	jal	80002fde <balloc>
    80003120:	892a                	mv	s2,a0
      if (addr == 0)
    80003122:	cd29                	beqz	a0,8000317c <bmap+0x8c>
        return 0;
      ip->addrs[bn] = addr;
    80003124:	c8a8                	sw	a0,80(s1)
    80003126:	a899                	j	8000317c <bmap+0x8c>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003128:	ff45849b          	addiw	s1,a1,-12

  if (bn < NINDIRECT) {
    8000312c:	0ff00793          	li	a5,255
    80003130:	0697e963          	bltu	a5,s1,800031a2 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    80003134:	08052903          	lw	s2,128(a0)
    80003138:	00091b63          	bnez	s2,8000314e <bmap+0x5e>
      addr = balloc(ip->dev);
    8000313c:	4108                	lw	a0,0(a0)
    8000313e:	ea1ff0ef          	jal	80002fde <balloc>
    80003142:	892a                	mv	s2,a0
      if (addr == 0)
    80003144:	cd05                	beqz	a0,8000317c <bmap+0x8c>
    80003146:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003148:	08a9a023          	sw	a0,128(s3)
    8000314c:	a011                	j	80003150 <bmap+0x60>
    8000314e:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003150:	85ca                	mv	a1,s2
    80003152:	0009a503          	lw	a0,0(s3)
    80003156:	c29ff0ef          	jal	80002d7e <bread>
    8000315a:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    8000315c:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    80003160:	02049713          	slli	a4,s1,0x20
    80003164:	01e75593          	srli	a1,a4,0x1e
    80003168:	00b784b3          	add	s1,a5,a1
    8000316c:	0004a903          	lw	s2,0(s1)
    80003170:	00090e63          	beqz	s2,8000318c <bmap+0x9c>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003174:	8552                	mv	a0,s4
    80003176:	d11ff0ef          	jal	80002e86 <brelse>
    return addr;
    8000317a:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000317c:	854a                	mv	a0,s2
    8000317e:	70a2                	ld	ra,40(sp)
    80003180:	7402                	ld	s0,32(sp)
    80003182:	64e2                	ld	s1,24(sp)
    80003184:	6942                	ld	s2,16(sp)
    80003186:	69a2                	ld	s3,8(sp)
    80003188:	6145                	addi	sp,sp,48
    8000318a:	8082                	ret
      addr = balloc(ip->dev);
    8000318c:	0009a503          	lw	a0,0(s3)
    80003190:	e4fff0ef          	jal	80002fde <balloc>
    80003194:	892a                	mv	s2,a0
      if (addr) {
    80003196:	dd79                	beqz	a0,80003174 <bmap+0x84>
        a[bn] = addr;
    80003198:	c088                	sw	a0,0(s1)
        log_write(bp);
    8000319a:	8552                	mv	a0,s4
    8000319c:	697000ef          	jal	80004032 <log_write>
    800031a0:	bfd1                	j	80003174 <bmap+0x84>
    800031a2:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800031a4:	00004517          	auipc	a0,0x4
    800031a8:	2a450513          	addi	a0,a0,676 # 80007448 <etext+0x448>
    800031ac:	e42fd0ef          	jal	800007ee <panic>

00000000800031b0 <iget>:
{
    800031b0:	7179                	addi	sp,sp,-48
    800031b2:	f406                	sd	ra,40(sp)
    800031b4:	f022                	sd	s0,32(sp)
    800031b6:	ec26                	sd	s1,24(sp)
    800031b8:	e84a                	sd	s2,16(sp)
    800031ba:	e44e                	sd	s3,8(sp)
    800031bc:	e052                	sd	s4,0(sp)
    800031be:	1800                	addi	s0,sp,48
    800031c0:	89aa                	mv	s3,a0
    800031c2:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800031c4:	0001b517          	auipc	a0,0x1b
    800031c8:	f4450513          	addi	a0,a0,-188 # 8001e108 <itable>
    800031cc:	9c1fd0ef          	jal	80000b8c <acquire>
  empty = 0;
    800031d0:	4901                	li	s2,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    800031d2:	0001b497          	auipc	s1,0x1b
    800031d6:	f4e48493          	addi	s1,s1,-178 # 8001e120 <itable+0x18>
    800031da:	0001d697          	auipc	a3,0x1d
    800031de:	9d668693          	addi	a3,a3,-1578 # 8001fbb0 <log>
    800031e2:	a039                	j	800031f0 <iget+0x40>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    800031e4:	02090963          	beqz	s2,80003216 <iget+0x66>
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    800031e8:	08848493          	addi	s1,s1,136
    800031ec:	02d48863          	beq	s1,a3,8000321c <iget+0x6c>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    800031f0:	449c                	lw	a5,8(s1)
    800031f2:	fef059e3          	blez	a5,800031e4 <iget+0x34>
    800031f6:	4098                	lw	a4,0(s1)
    800031f8:	ff3716e3          	bne	a4,s3,800031e4 <iget+0x34>
    800031fc:	40d8                	lw	a4,4(s1)
    800031fe:	ff4713e3          	bne	a4,s4,800031e4 <iget+0x34>
      ip->ref++;
    80003202:	2785                	addiw	a5,a5,1
    80003204:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003206:	0001b517          	auipc	a0,0x1b
    8000320a:	f0250513          	addi	a0,a0,-254 # 8001e108 <itable>
    8000320e:	a07fd0ef          	jal	80000c14 <release>
      return ip;
    80003212:	8926                	mv	s2,s1
    80003214:	a02d                	j	8000323e <iget+0x8e>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003216:	fbe9                	bnez	a5,800031e8 <iget+0x38>
      empty = ip;
    80003218:	8926                	mv	s2,s1
    8000321a:	b7f9                	j	800031e8 <iget+0x38>
  if (empty == 0)
    8000321c:	02090a63          	beqz	s2,80003250 <iget+0xa0>
  ip->dev = dev;
    80003220:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003224:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003228:	4785                	li	a5,1
    8000322a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000322e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003232:	0001b517          	auipc	a0,0x1b
    80003236:	ed650513          	addi	a0,a0,-298 # 8001e108 <itable>
    8000323a:	9dbfd0ef          	jal	80000c14 <release>
}
    8000323e:	854a                	mv	a0,s2
    80003240:	70a2                	ld	ra,40(sp)
    80003242:	7402                	ld	s0,32(sp)
    80003244:	64e2                	ld	s1,24(sp)
    80003246:	6942                	ld	s2,16(sp)
    80003248:	69a2                	ld	s3,8(sp)
    8000324a:	6a02                	ld	s4,0(sp)
    8000324c:	6145                	addi	sp,sp,48
    8000324e:	8082                	ret
    panic("iget: no inodes");
    80003250:	00004517          	auipc	a0,0x4
    80003254:	21050513          	addi	a0,a0,528 # 80007460 <etext+0x460>
    80003258:	d96fd0ef          	jal	800007ee <panic>

000000008000325c <iinit>:
{
    8000325c:	7179                	addi	sp,sp,-48
    8000325e:	f406                	sd	ra,40(sp)
    80003260:	f022                	sd	s0,32(sp)
    80003262:	ec26                	sd	s1,24(sp)
    80003264:	e84a                	sd	s2,16(sp)
    80003266:	e44e                	sd	s3,8(sp)
    80003268:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000326a:	00004597          	auipc	a1,0x4
    8000326e:	20658593          	addi	a1,a1,518 # 80007470 <etext+0x470>
    80003272:	0001b517          	auipc	a0,0x1b
    80003276:	e9650513          	addi	a0,a0,-362 # 8001e108 <itable>
    8000327a:	899fd0ef          	jal	80000b12 <initlock>
  for (i = 0; i < NINODE; i++) {
    8000327e:	0001b497          	auipc	s1,0x1b
    80003282:	eb248493          	addi	s1,s1,-334 # 8001e130 <itable+0x28>
    80003286:	0001d997          	auipc	s3,0x1d
    8000328a:	93a98993          	addi	s3,s3,-1734 # 8001fbc0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000328e:	00004917          	auipc	s2,0x4
    80003292:	1ea90913          	addi	s2,s2,490 # 80007478 <etext+0x478>
    80003296:	85ca                	mv	a1,s2
    80003298:	8526                	mv	a0,s1
    8000329a:	6cb000ef          	jal	80004164 <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    8000329e:	08848493          	addi	s1,s1,136
    800032a2:	ff349ae3          	bne	s1,s3,80003296 <iinit+0x3a>
}
    800032a6:	70a2                	ld	ra,40(sp)
    800032a8:	7402                	ld	s0,32(sp)
    800032aa:	64e2                	ld	s1,24(sp)
    800032ac:	6942                	ld	s2,16(sp)
    800032ae:	69a2                	ld	s3,8(sp)
    800032b0:	6145                	addi	sp,sp,48
    800032b2:	8082                	ret

00000000800032b4 <ialloc>:
{
    800032b4:	7139                	addi	sp,sp,-64
    800032b6:	fc06                	sd	ra,56(sp)
    800032b8:	f822                	sd	s0,48(sp)
    800032ba:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    800032bc:	0001b717          	auipc	a4,0x1b
    800032c0:	e3872703          	lw	a4,-456(a4) # 8001e0f4 <sb+0xc>
    800032c4:	4785                	li	a5,1
    800032c6:	06e7f063          	bgeu	a5,a4,80003326 <ialloc+0x72>
    800032ca:	f426                	sd	s1,40(sp)
    800032cc:	f04a                	sd	s2,32(sp)
    800032ce:	ec4e                	sd	s3,24(sp)
    800032d0:	e852                	sd	s4,16(sp)
    800032d2:	e456                	sd	s5,8(sp)
    800032d4:	e05a                	sd	s6,0(sp)
    800032d6:	8aaa                	mv	s5,a0
    800032d8:	8b2e                	mv	s6,a1
    800032da:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800032dc:	0001ba17          	auipc	s4,0x1b
    800032e0:	e0ca0a13          	addi	s4,s4,-500 # 8001e0e8 <sb>
    800032e4:	00495593          	srli	a1,s2,0x4
    800032e8:	018a2783          	lw	a5,24(s4)
    800032ec:	9dbd                	addw	a1,a1,a5
    800032ee:	8556                	mv	a0,s5
    800032f0:	a8fff0ef          	jal	80002d7e <bread>
    800032f4:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    800032f6:	05850993          	addi	s3,a0,88
    800032fa:	00f97793          	andi	a5,s2,15
    800032fe:	079a                	slli	a5,a5,0x6
    80003300:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    80003302:	00099783          	lh	a5,0(s3)
    80003306:	cb9d                	beqz	a5,8000333c <ialloc+0x88>
    brelse(bp);
    80003308:	b7fff0ef          	jal	80002e86 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    8000330c:	0905                	addi	s2,s2,1
    8000330e:	00ca2703          	lw	a4,12(s4)
    80003312:	0009079b          	sext.w	a5,s2
    80003316:	fce7e7e3          	bltu	a5,a4,800032e4 <ialloc+0x30>
    8000331a:	74a2                	ld	s1,40(sp)
    8000331c:	7902                	ld	s2,32(sp)
    8000331e:	69e2                	ld	s3,24(sp)
    80003320:	6a42                	ld	s4,16(sp)
    80003322:	6aa2                	ld	s5,8(sp)
    80003324:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    80003326:	00004517          	auipc	a0,0x4
    8000332a:	15a50513          	addi	a0,a0,346 # 80007480 <etext+0x480>
    8000332e:	9dcfd0ef          	jal	8000050a <printk>
  return 0;
    80003332:	4501                	li	a0,0
}
    80003334:	70e2                	ld	ra,56(sp)
    80003336:	7442                	ld	s0,48(sp)
    80003338:	6121                	addi	sp,sp,64
    8000333a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000333c:	04000613          	li	a2,64
    80003340:	4581                	li	a1,0
    80003342:	854e                	mv	a0,s3
    80003344:	909fd0ef          	jal	80000c4c <memset>
      dip->type = type;
    80003348:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    8000334c:	8526                	mv	a0,s1
    8000334e:	4e5000ef          	jal	80004032 <log_write>
      brelse(bp);
    80003352:	8526                	mv	a0,s1
    80003354:	b33ff0ef          	jal	80002e86 <brelse>
      return iget(dev, inum);
    80003358:	0009059b          	sext.w	a1,s2
    8000335c:	8556                	mv	a0,s5
    8000335e:	e53ff0ef          	jal	800031b0 <iget>
    80003362:	74a2                	ld	s1,40(sp)
    80003364:	7902                	ld	s2,32(sp)
    80003366:	69e2                	ld	s3,24(sp)
    80003368:	6a42                	ld	s4,16(sp)
    8000336a:	6aa2                	ld	s5,8(sp)
    8000336c:	6b02                	ld	s6,0(sp)
    8000336e:	b7d9                	j	80003334 <ialloc+0x80>

0000000080003370 <iupdate>:
{
    80003370:	1101                	addi	sp,sp,-32
    80003372:	ec06                	sd	ra,24(sp)
    80003374:	e822                	sd	s0,16(sp)
    80003376:	e426                	sd	s1,8(sp)
    80003378:	e04a                	sd	s2,0(sp)
    8000337a:	1000                	addi	s0,sp,32
    8000337c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000337e:	415c                	lw	a5,4(a0)
    80003380:	0047d79b          	srliw	a5,a5,0x4
    80003384:	0001b597          	auipc	a1,0x1b
    80003388:	d7c5a583          	lw	a1,-644(a1) # 8001e100 <sb+0x18>
    8000338c:	9dbd                	addw	a1,a1,a5
    8000338e:	4108                	lw	a0,0(a0)
    80003390:	9efff0ef          	jal	80002d7e <bread>
    80003394:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003396:	05850793          	addi	a5,a0,88
    8000339a:	40d8                	lw	a4,4(s1)
    8000339c:	8b3d                	andi	a4,a4,15
    8000339e:	071a                	slli	a4,a4,0x6
    800033a0:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800033a2:	04449703          	lh	a4,68(s1)
    800033a6:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800033aa:	04649703          	lh	a4,70(s1)
    800033ae:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800033b2:	04849703          	lh	a4,72(s1)
    800033b6:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800033ba:	04a49703          	lh	a4,74(s1)
    800033be:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800033c2:	44f8                	lw	a4,76(s1)
    800033c4:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800033c6:	03400613          	li	a2,52
    800033ca:	05048593          	addi	a1,s1,80
    800033ce:	00c78513          	addi	a0,a5,12
    800033d2:	8dffd0ef          	jal	80000cb0 <memmove>
  log_write(bp);
    800033d6:	854a                	mv	a0,s2
    800033d8:	45b000ef          	jal	80004032 <log_write>
  brelse(bp);
    800033dc:	854a                	mv	a0,s2
    800033de:	aa9ff0ef          	jal	80002e86 <brelse>
}
    800033e2:	60e2                	ld	ra,24(sp)
    800033e4:	6442                	ld	s0,16(sp)
    800033e6:	64a2                	ld	s1,8(sp)
    800033e8:	6902                	ld	s2,0(sp)
    800033ea:	6105                	addi	sp,sp,32
    800033ec:	8082                	ret

00000000800033ee <idup>:
{
    800033ee:	1101                	addi	sp,sp,-32
    800033f0:	ec06                	sd	ra,24(sp)
    800033f2:	e822                	sd	s0,16(sp)
    800033f4:	e426                	sd	s1,8(sp)
    800033f6:	1000                	addi	s0,sp,32
    800033f8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800033fa:	0001b517          	auipc	a0,0x1b
    800033fe:	d0e50513          	addi	a0,a0,-754 # 8001e108 <itable>
    80003402:	f8afd0ef          	jal	80000b8c <acquire>
  ip->ref++;
    80003406:	449c                	lw	a5,8(s1)
    80003408:	2785                	addiw	a5,a5,1
    8000340a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000340c:	0001b517          	auipc	a0,0x1b
    80003410:	cfc50513          	addi	a0,a0,-772 # 8001e108 <itable>
    80003414:	801fd0ef          	jal	80000c14 <release>
}
    80003418:	8526                	mv	a0,s1
    8000341a:	60e2                	ld	ra,24(sp)
    8000341c:	6442                	ld	s0,16(sp)
    8000341e:	64a2                	ld	s1,8(sp)
    80003420:	6105                	addi	sp,sp,32
    80003422:	8082                	ret

0000000080003424 <ilock>:
{
    80003424:	1101                	addi	sp,sp,-32
    80003426:	ec06                	sd	ra,24(sp)
    80003428:	e822                	sd	s0,16(sp)
    8000342a:	e426                	sd	s1,8(sp)
    8000342c:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    8000342e:	cd19                	beqz	a0,8000344c <ilock+0x28>
    80003430:	84aa                	mv	s1,a0
    80003432:	451c                	lw	a5,8(a0)
    80003434:	00f05c63          	blez	a5,8000344c <ilock+0x28>
  acquiresleep(&ip->lock);
    80003438:	0541                	addi	a0,a0,16
    8000343a:	561000ef          	jal	8000419a <acquiresleep>
  if (ip->valid == 0) {
    8000343e:	40bc                	lw	a5,64(s1)
    80003440:	cf89                	beqz	a5,8000345a <ilock+0x36>
}
    80003442:	60e2                	ld	ra,24(sp)
    80003444:	6442                	ld	s0,16(sp)
    80003446:	64a2                	ld	s1,8(sp)
    80003448:	6105                	addi	sp,sp,32
    8000344a:	8082                	ret
    8000344c:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000344e:	00004517          	auipc	a0,0x4
    80003452:	04a50513          	addi	a0,a0,74 # 80007498 <etext+0x498>
    80003456:	b98fd0ef          	jal	800007ee <panic>
    8000345a:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000345c:	40dc                	lw	a5,4(s1)
    8000345e:	0047d79b          	srliw	a5,a5,0x4
    80003462:	0001b597          	auipc	a1,0x1b
    80003466:	c9e5a583          	lw	a1,-866(a1) # 8001e100 <sb+0x18>
    8000346a:	9dbd                	addw	a1,a1,a5
    8000346c:	4088                	lw	a0,0(s1)
    8000346e:	911ff0ef          	jal	80002d7e <bread>
    80003472:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003474:	05850593          	addi	a1,a0,88
    80003478:	40dc                	lw	a5,4(s1)
    8000347a:	8bbd                	andi	a5,a5,15
    8000347c:	079a                	slli	a5,a5,0x6
    8000347e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003480:	00059783          	lh	a5,0(a1)
    80003484:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003488:	00259783          	lh	a5,2(a1)
    8000348c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003490:	00459783          	lh	a5,4(a1)
    80003494:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003498:	00659783          	lh	a5,6(a1)
    8000349c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800034a0:	459c                	lw	a5,8(a1)
    800034a2:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800034a4:	03400613          	li	a2,52
    800034a8:	05b1                	addi	a1,a1,12
    800034aa:	05048513          	addi	a0,s1,80
    800034ae:	803fd0ef          	jal	80000cb0 <memmove>
    brelse(bp);
    800034b2:	854a                	mv	a0,s2
    800034b4:	9d3ff0ef          	jal	80002e86 <brelse>
    ip->valid = 1;
    800034b8:	4785                	li	a5,1
    800034ba:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    800034bc:	04449783          	lh	a5,68(s1)
    800034c0:	c399                	beqz	a5,800034c6 <ilock+0xa2>
    800034c2:	6902                	ld	s2,0(sp)
    800034c4:	bfbd                	j	80003442 <ilock+0x1e>
      panic("ilock: no type");
    800034c6:	00004517          	auipc	a0,0x4
    800034ca:	fda50513          	addi	a0,a0,-38 # 800074a0 <etext+0x4a0>
    800034ce:	b20fd0ef          	jal	800007ee <panic>

00000000800034d2 <iunlock>:
{
    800034d2:	1101                	addi	sp,sp,-32
    800034d4:	ec06                	sd	ra,24(sp)
    800034d6:	e822                	sd	s0,16(sp)
    800034d8:	e426                	sd	s1,8(sp)
    800034da:	e04a                	sd	s2,0(sp)
    800034dc:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800034de:	c505                	beqz	a0,80003506 <iunlock+0x34>
    800034e0:	84aa                	mv	s1,a0
    800034e2:	01050913          	addi	s2,a0,16
    800034e6:	854a                	mv	a0,s2
    800034e8:	53f000ef          	jal	80004226 <holdingsleep>
    800034ec:	cd09                	beqz	a0,80003506 <iunlock+0x34>
    800034ee:	449c                	lw	a5,8(s1)
    800034f0:	00f05b63          	blez	a5,80003506 <iunlock+0x34>
  releasesleep(&ip->lock);
    800034f4:	854a                	mv	a0,s2
    800034f6:	4f9000ef          	jal	800041ee <releasesleep>
}
    800034fa:	60e2                	ld	ra,24(sp)
    800034fc:	6442                	ld	s0,16(sp)
    800034fe:	64a2                	ld	s1,8(sp)
    80003500:	6902                	ld	s2,0(sp)
    80003502:	6105                	addi	sp,sp,32
    80003504:	8082                	ret
    panic("iunlock");
    80003506:	00004517          	auipc	a0,0x4
    8000350a:	faa50513          	addi	a0,a0,-86 # 800074b0 <etext+0x4b0>
    8000350e:	ae0fd0ef          	jal	800007ee <panic>

0000000080003512 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003512:	7179                	addi	sp,sp,-48
    80003514:	f406                	sd	ra,40(sp)
    80003516:	f022                	sd	s0,32(sp)
    80003518:	ec26                	sd	s1,24(sp)
    8000351a:	e84a                	sd	s2,16(sp)
    8000351c:	e44e                	sd	s3,8(sp)
    8000351e:	1800                	addi	s0,sp,48
    80003520:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    80003522:	05050493          	addi	s1,a0,80
    80003526:	08050913          	addi	s2,a0,128
    8000352a:	a021                	j	80003532 <itrunc+0x20>
    8000352c:	0491                	addi	s1,s1,4
    8000352e:	01248b63          	beq	s1,s2,80003544 <itrunc+0x32>
    if (ip->addrs[i]) {
    80003532:	408c                	lw	a1,0(s1)
    80003534:	dde5                	beqz	a1,8000352c <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003536:	0009a503          	lw	a0,0(s3)
    8000353a:	a39ff0ef          	jal	80002f72 <bfree>
      ip->addrs[i] = 0;
    8000353e:	0004a023          	sw	zero,0(s1)
    80003542:	b7ed                	j	8000352c <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    80003544:	0809a583          	lw	a1,128(s3)
    80003548:	ed89                	bnez	a1,80003562 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000354a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000354e:	854e                	mv	a0,s3
    80003550:	e21ff0ef          	jal	80003370 <iupdate>
}
    80003554:	70a2                	ld	ra,40(sp)
    80003556:	7402                	ld	s0,32(sp)
    80003558:	64e2                	ld	s1,24(sp)
    8000355a:	6942                	ld	s2,16(sp)
    8000355c:	69a2                	ld	s3,8(sp)
    8000355e:	6145                	addi	sp,sp,48
    80003560:	8082                	ret
    80003562:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003564:	0009a503          	lw	a0,0(s3)
    80003568:	817ff0ef          	jal	80002d7e <bread>
    8000356c:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    8000356e:	05850493          	addi	s1,a0,88
    80003572:	45850913          	addi	s2,a0,1112
    80003576:	a021                	j	8000357e <itrunc+0x6c>
    80003578:	0491                	addi	s1,s1,4
    8000357a:	01248963          	beq	s1,s2,8000358c <itrunc+0x7a>
      if (a[j])
    8000357e:	408c                	lw	a1,0(s1)
    80003580:	dde5                	beqz	a1,80003578 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003582:	0009a503          	lw	a0,0(s3)
    80003586:	9edff0ef          	jal	80002f72 <bfree>
    8000358a:	b7fd                	j	80003578 <itrunc+0x66>
    brelse(bp);
    8000358c:	8552                	mv	a0,s4
    8000358e:	8f9ff0ef          	jal	80002e86 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003592:	0809a583          	lw	a1,128(s3)
    80003596:	0009a503          	lw	a0,0(s3)
    8000359a:	9d9ff0ef          	jal	80002f72 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000359e:	0809a023          	sw	zero,128(s3)
    800035a2:	6a02                	ld	s4,0(sp)
    800035a4:	b75d                	j	8000354a <itrunc+0x38>

00000000800035a6 <iput>:
{
    800035a6:	7179                	addi	sp,sp,-48
    800035a8:	f406                	sd	ra,40(sp)
    800035aa:	f022                	sd	s0,32(sp)
    800035ac:	ec26                	sd	s1,24(sp)
    800035ae:	1800                	addi	s0,sp,48
    800035b0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800035b2:	0001b517          	auipc	a0,0x1b
    800035b6:	b5650513          	addi	a0,a0,-1194 # 8001e108 <itable>
    800035ba:	dd2fd0ef          	jal	80000b8c <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    800035be:	449c                	lw	a5,8(s1)
    800035c0:	4705                	li	a4,1
    800035c2:	00e78f63          	beq	a5,a4,800035e0 <iput+0x3a>
  ip->ref--;
    800035c6:	37fd                	addiw	a5,a5,-1
    800035c8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800035ca:	0001b517          	auipc	a0,0x1b
    800035ce:	b3e50513          	addi	a0,a0,-1218 # 8001e108 <itable>
    800035d2:	e42fd0ef          	jal	80000c14 <release>
}
    800035d6:	70a2                	ld	ra,40(sp)
    800035d8:	7402                	ld	s0,32(sp)
    800035da:	64e2                	ld	s1,24(sp)
    800035dc:	6145                	addi	sp,sp,48
    800035de:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    800035e0:	40b8                	lw	a4,64(s1)
    800035e2:	d375                	beqz	a4,800035c6 <iput+0x20>
    800035e4:	e84a                	sd	s2,16(sp)
    800035e6:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    800035e8:	0004aa03          	lw	s4,0(s1)
    800035ec:	0044a903          	lw	s2,4(s1)
  if (last) {
    800035f0:	04a49703          	lh	a4,74(s1)
    800035f4:	ef35                	bnez	a4,80003670 <iput+0xca>
    800035f6:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    800035f8:	01048993          	addi	s3,s1,16
    800035fc:	854e                	mv	a0,s3
    800035fe:	39d000ef          	jal	8000419a <acquiresleep>
    release(&itable.lock);
    80003602:	0001b517          	auipc	a0,0x1b
    80003606:	b0650513          	addi	a0,a0,-1274 # 8001e108 <itable>
    8000360a:	e0afd0ef          	jal	80000c14 <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    8000360e:	8526                	mv	a0,s1
    80003610:	f03ff0ef          	jal	80003512 <itrunc>
    ip->valid = 0;
    80003614:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003618:	854e                	mv	a0,s3
    8000361a:	3d5000ef          	jal	800041ee <releasesleep>
    acquire(&itable.lock);
    8000361e:	0001b517          	auipc	a0,0x1b
    80003622:	aea50513          	addi	a0,a0,-1302 # 8001e108 <itable>
    80003626:	d66fd0ef          	jal	80000b8c <acquire>
  ip->ref--;
    8000362a:	449c                	lw	a5,8(s1)
    8000362c:	37fd                	addiw	a5,a5,-1
    8000362e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003630:	0001b517          	auipc	a0,0x1b
    80003634:	ad850513          	addi	a0,a0,-1320 # 8001e108 <itable>
    80003638:	ddcfd0ef          	jal	80000c14 <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000363c:	0049579b          	srliw	a5,s2,0x4
    80003640:	0001b597          	auipc	a1,0x1b
    80003644:	ac05a583          	lw	a1,-1344(a1) # 8001e100 <sb+0x18>
    80003648:	9dbd                	addw	a1,a1,a5
    8000364a:	8552                	mv	a0,s4
    8000364c:	f32ff0ef          	jal	80002d7e <bread>
    80003650:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003652:	00f97913          	andi	s2,s2,15
  dip->type = 0;
    80003656:	091a                	slli	s2,s2,0x6
    80003658:	992a                	add	s2,s2,a0
    8000365a:	04091c23          	sh	zero,88(s2)
  log_write(bp);
    8000365e:	1d5000ef          	jal	80004032 <log_write>
  brelse(bp);
    80003662:	8526                	mv	a0,s1
    80003664:	823ff0ef          	jal	80002e86 <brelse>
}
    80003668:	6942                	ld	s2,16(sp)
    8000366a:	69a2                	ld	s3,8(sp)
    8000366c:	6a02                	ld	s4,0(sp)
    8000366e:	b7a5                	j	800035d6 <iput+0x30>
    80003670:	6942                	ld	s2,16(sp)
    80003672:	6a02                	ld	s4,0(sp)
    80003674:	bf89                	j	800035c6 <iput+0x20>

0000000080003676 <iunlockput>:
{
    80003676:	1101                	addi	sp,sp,-32
    80003678:	ec06                	sd	ra,24(sp)
    8000367a:	e822                	sd	s0,16(sp)
    8000367c:	e426                	sd	s1,8(sp)
    8000367e:	1000                	addi	s0,sp,32
    80003680:	84aa                	mv	s1,a0
  iunlock(ip);
    80003682:	e51ff0ef          	jal	800034d2 <iunlock>
  iput(ip);
    80003686:	8526                	mv	a0,s1
    80003688:	f1fff0ef          	jal	800035a6 <iput>
}
    8000368c:	60e2                	ld	ra,24(sp)
    8000368e:	6442                	ld	s0,16(sp)
    80003690:	64a2                	ld	s1,8(sp)
    80003692:	6105                	addi	sp,sp,32
    80003694:	8082                	ret

0000000080003696 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003696:	0001b717          	auipc	a4,0x1b
    8000369a:	a5e72703          	lw	a4,-1442(a4) # 8001e0f4 <sb+0xc>
    8000369e:	4785                	li	a5,1
    800036a0:	0ae7fe63          	bgeu	a5,a4,8000375c <ireclaim+0xc6>
{
    800036a4:	7139                	addi	sp,sp,-64
    800036a6:	fc06                	sd	ra,56(sp)
    800036a8:	f822                	sd	s0,48(sp)
    800036aa:	f426                	sd	s1,40(sp)
    800036ac:	f04a                	sd	s2,32(sp)
    800036ae:	ec4e                	sd	s3,24(sp)
    800036b0:	e852                	sd	s4,16(sp)
    800036b2:	e456                	sd	s5,8(sp)
    800036b4:	e05a                	sd	s6,0(sp)
    800036b6:	0080                	addi	s0,sp,64
    800036b8:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800036ba:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800036bc:	0001ba17          	auipc	s4,0x1b
    800036c0:	a2ca0a13          	addi	s4,s4,-1492 # 8001e0e8 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    800036c4:	00004b17          	auipc	s6,0x4
    800036c8:	df4b0b13          	addi	s6,s6,-524 # 800074b8 <etext+0x4b8>
    800036cc:	a099                	j	80003712 <ireclaim+0x7c>
    800036ce:	85ce                	mv	a1,s3
    800036d0:	855a                	mv	a0,s6
    800036d2:	e39fc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    800036d6:	85ce                	mv	a1,s3
    800036d8:	8556                	mv	a0,s5
    800036da:	ad7ff0ef          	jal	800031b0 <iget>
    800036de:	89aa                	mv	s3,a0
    brelse(bp);
    800036e0:	854a                	mv	a0,s2
    800036e2:	fa4ff0ef          	jal	80002e86 <brelse>
    if (ip) {
    800036e6:	00098f63          	beqz	s3,80003704 <ireclaim+0x6e>
      begin_op();
    800036ea:	79c000ef          	jal	80003e86 <begin_op>
      ilock(ip);
    800036ee:	854e                	mv	a0,s3
    800036f0:	d35ff0ef          	jal	80003424 <ilock>
      iunlock(ip);
    800036f4:	854e                	mv	a0,s3
    800036f6:	dddff0ef          	jal	800034d2 <iunlock>
      iput(ip);
    800036fa:	854e                	mv	a0,s3
    800036fc:	eabff0ef          	jal	800035a6 <iput>
      end_op();
    80003700:	00d000ef          	jal	80003f0c <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003704:	0485                	addi	s1,s1,1
    80003706:	00ca2703          	lw	a4,12(s4)
    8000370a:	0004879b          	sext.w	a5,s1
    8000370e:	02e7fd63          	bgeu	a5,a4,80003748 <ireclaim+0xb2>
    80003712:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003716:	0044d593          	srli	a1,s1,0x4
    8000371a:	018a2783          	lw	a5,24(s4)
    8000371e:	9dbd                	addw	a1,a1,a5
    80003720:	8556                	mv	a0,s5
    80003722:	e5cff0ef          	jal	80002d7e <bread>
    80003726:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003728:	05850793          	addi	a5,a0,88
    8000372c:	00f9f713          	andi	a4,s3,15
    80003730:	071a                	slli	a4,a4,0x6
    80003732:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    80003734:	00079703          	lh	a4,0(a5)
    80003738:	c701                	beqz	a4,80003740 <ireclaim+0xaa>
    8000373a:	00679783          	lh	a5,6(a5)
    8000373e:	dbc1                	beqz	a5,800036ce <ireclaim+0x38>
    brelse(bp);
    80003740:	854a                	mv	a0,s2
    80003742:	f44ff0ef          	jal	80002e86 <brelse>
    if (ip) {
    80003746:	bf7d                	j	80003704 <ireclaim+0x6e>
}
    80003748:	70e2                	ld	ra,56(sp)
    8000374a:	7442                	ld	s0,48(sp)
    8000374c:	74a2                	ld	s1,40(sp)
    8000374e:	7902                	ld	s2,32(sp)
    80003750:	69e2                	ld	s3,24(sp)
    80003752:	6a42                	ld	s4,16(sp)
    80003754:	6aa2                	ld	s5,8(sp)
    80003756:	6b02                	ld	s6,0(sp)
    80003758:	6121                	addi	sp,sp,64
    8000375a:	8082                	ret
    8000375c:	8082                	ret

000000008000375e <fsinit>:
{
    8000375e:	7179                	addi	sp,sp,-48
    80003760:	f406                	sd	ra,40(sp)
    80003762:	f022                	sd	s0,32(sp)
    80003764:	ec26                	sd	s1,24(sp)
    80003766:	e84a                	sd	s2,16(sp)
    80003768:	e44e                	sd	s3,8(sp)
    8000376a:	1800                	addi	s0,sp,48
    8000376c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000376e:	4585                	li	a1,1
    80003770:	e0eff0ef          	jal	80002d7e <bread>
    80003774:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003776:	0001b997          	auipc	s3,0x1b
    8000377a:	97298993          	addi	s3,s3,-1678 # 8001e0e8 <sb>
    8000377e:	02000613          	li	a2,32
    80003782:	05850593          	addi	a1,a0,88
    80003786:	854e                	mv	a0,s3
    80003788:	d28fd0ef          	jal	80000cb0 <memmove>
  brelse(bp);
    8000378c:	8526                	mv	a0,s1
    8000378e:	ef8ff0ef          	jal	80002e86 <brelse>
  if (sb.magic != FSMAGIC)
    80003792:	0009a703          	lw	a4,0(s3)
    80003796:	102037b7          	lui	a5,0x10203
    8000379a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000379e:	02f71363          	bne	a4,a5,800037c4 <fsinit+0x66>
  initlog(dev, &sb);
    800037a2:	0001b597          	auipc	a1,0x1b
    800037a6:	94658593          	addi	a1,a1,-1722 # 8001e0e8 <sb>
    800037aa:	854a                	mv	a0,s2
    800037ac:	65c000ef          	jal	80003e08 <initlog>
  ireclaim(dev);
    800037b0:	854a                	mv	a0,s2
    800037b2:	ee5ff0ef          	jal	80003696 <ireclaim>
}
    800037b6:	70a2                	ld	ra,40(sp)
    800037b8:	7402                	ld	s0,32(sp)
    800037ba:	64e2                	ld	s1,24(sp)
    800037bc:	6942                	ld	s2,16(sp)
    800037be:	69a2                	ld	s3,8(sp)
    800037c0:	6145                	addi	sp,sp,48
    800037c2:	8082                	ret
    panic("invalid file system");
    800037c4:	00004517          	auipc	a0,0x4
    800037c8:	d1450513          	addi	a0,a0,-748 # 800074d8 <etext+0x4d8>
    800037cc:	822fd0ef          	jal	800007ee <panic>

00000000800037d0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800037d0:	1141                	addi	sp,sp,-16
    800037d2:	e406                	sd	ra,8(sp)
    800037d4:	e022                	sd	s0,0(sp)
    800037d6:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800037d8:	411c                	lw	a5,0(a0)
    800037da:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800037dc:	415c                	lw	a5,4(a0)
    800037de:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800037e0:	04451783          	lh	a5,68(a0)
    800037e4:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800037e8:	04a51783          	lh	a5,74(a0)
    800037ec:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800037f0:	04c56783          	lwu	a5,76(a0)
    800037f4:	e99c                	sd	a5,16(a1)
}
    800037f6:	60a2                	ld	ra,8(sp)
    800037f8:	6402                	ld	s0,0(sp)
    800037fa:	0141                	addi	sp,sp,16
    800037fc:	8082                	ret

00000000800037fe <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    800037fe:	457c                	lw	a5,76(a0)
    80003800:	0ed7e663          	bltu	a5,a3,800038ec <readi+0xee>
{
    80003804:	7159                	addi	sp,sp,-112
    80003806:	f486                	sd	ra,104(sp)
    80003808:	f0a2                	sd	s0,96(sp)
    8000380a:	eca6                	sd	s1,88(sp)
    8000380c:	e0d2                	sd	s4,64(sp)
    8000380e:	fc56                	sd	s5,56(sp)
    80003810:	f85a                	sd	s6,48(sp)
    80003812:	f45e                	sd	s7,40(sp)
    80003814:	1880                	addi	s0,sp,112
    80003816:	8b2a                	mv	s6,a0
    80003818:	8bae                	mv	s7,a1
    8000381a:	8a32                	mv	s4,a2
    8000381c:	84b6                	mv	s1,a3
    8000381e:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    80003820:	9f35                	addw	a4,a4,a3
    return 0;
    80003822:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    80003824:	0ad76b63          	bltu	a4,a3,800038da <readi+0xdc>
    80003828:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    8000382a:	00e7f463          	bgeu	a5,a4,80003832 <readi+0x34>
    n = ip->size - off;
    8000382e:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003832:	080a8b63          	beqz	s5,800038c8 <readi+0xca>
    80003836:	e8ca                	sd	s2,80(sp)
    80003838:	f062                	sd	s8,32(sp)
    8000383a:	ec66                	sd	s9,24(sp)
    8000383c:	e86a                	sd	s10,16(sp)
    8000383e:	e46e                	sd	s11,8(sp)
    80003840:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003842:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003846:	5c7d                	li	s8,-1
    80003848:	a80d                	j	8000387a <readi+0x7c>
    8000384a:	020d1d93          	slli	s11,s10,0x20
    8000384e:	020ddd93          	srli	s11,s11,0x20
    80003852:	05890613          	addi	a2,s2,88
    80003856:	86ee                	mv	a3,s11
    80003858:	963e                	add	a2,a2,a5
    8000385a:	85d2                	mv	a1,s4
    8000385c:	855e                	mv	a0,s7
    8000385e:	b39fe0ef          	jal	80002396 <either_copyout>
    80003862:	05850363          	beq	a0,s8,800038a8 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003866:	854a                	mv	a0,s2
    80003868:	e1eff0ef          	jal	80002e86 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    8000386c:	013d09bb          	addw	s3,s10,s3
    80003870:	009d04bb          	addw	s1,s10,s1
    80003874:	9a6e                	add	s4,s4,s11
    80003876:	0559f363          	bgeu	s3,s5,800038bc <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    8000387a:	00a4d59b          	srliw	a1,s1,0xa
    8000387e:	855a                	mv	a0,s6
    80003880:	871ff0ef          	jal	800030f0 <bmap>
    80003884:	85aa                	mv	a1,a0
    if (addr == 0)
    80003886:	c139                	beqz	a0,800038cc <readi+0xce>
    bp = bread(ip->dev, addr);
    80003888:	000b2503          	lw	a0,0(s6)
    8000388c:	cf2ff0ef          	jal	80002d7e <bread>
    80003890:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003892:	3ff4f793          	andi	a5,s1,1023
    80003896:	40fc873b          	subw	a4,s9,a5
    8000389a:	413a86bb          	subw	a3,s5,s3
    8000389e:	8d3a                	mv	s10,a4
    800038a0:	fae6f5e3          	bgeu	a3,a4,8000384a <readi+0x4c>
    800038a4:	8d36                	mv	s10,a3
    800038a6:	b755                	j	8000384a <readi+0x4c>
      brelse(bp);
    800038a8:	854a                	mv	a0,s2
    800038aa:	ddcff0ef          	jal	80002e86 <brelse>
      tot = -1;
    800038ae:	59fd                	li	s3,-1
      break;
    800038b0:	6946                	ld	s2,80(sp)
    800038b2:	7c02                	ld	s8,32(sp)
    800038b4:	6ce2                	ld	s9,24(sp)
    800038b6:	6d42                	ld	s10,16(sp)
    800038b8:	6da2                	ld	s11,8(sp)
    800038ba:	a831                	j	800038d6 <readi+0xd8>
    800038bc:	6946                	ld	s2,80(sp)
    800038be:	7c02                	ld	s8,32(sp)
    800038c0:	6ce2                	ld	s9,24(sp)
    800038c2:	6d42                	ld	s10,16(sp)
    800038c4:	6da2                	ld	s11,8(sp)
    800038c6:	a801                	j	800038d6 <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800038c8:	89d6                	mv	s3,s5
    800038ca:	a031                	j	800038d6 <readi+0xd8>
    800038cc:	6946                	ld	s2,80(sp)
    800038ce:	7c02                	ld	s8,32(sp)
    800038d0:	6ce2                	ld	s9,24(sp)
    800038d2:	6d42                	ld	s10,16(sp)
    800038d4:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800038d6:	854e                	mv	a0,s3
    800038d8:	69a6                	ld	s3,72(sp)
}
    800038da:	70a6                	ld	ra,104(sp)
    800038dc:	7406                	ld	s0,96(sp)
    800038de:	64e6                	ld	s1,88(sp)
    800038e0:	6a06                	ld	s4,64(sp)
    800038e2:	7ae2                	ld	s5,56(sp)
    800038e4:	7b42                	ld	s6,48(sp)
    800038e6:	7ba2                	ld	s7,40(sp)
    800038e8:	6165                	addi	sp,sp,112
    800038ea:	8082                	ret
    return 0;
    800038ec:	4501                	li	a0,0
}
    800038ee:	8082                	ret

00000000800038f0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    800038f0:	457c                	lw	a5,76(a0)
    800038f2:	0ed7ee63          	bltu	a5,a3,800039ee <writei+0xfe>
{
    800038f6:	7159                	addi	sp,sp,-112
    800038f8:	f486                	sd	ra,104(sp)
    800038fa:	f0a2                	sd	s0,96(sp)
    800038fc:	e8ca                	sd	s2,80(sp)
    800038fe:	e0d2                	sd	s4,64(sp)
    80003900:	fc56                	sd	s5,56(sp)
    80003902:	f85a                	sd	s6,48(sp)
    80003904:	f45e                	sd	s7,40(sp)
    80003906:	1880                	addi	s0,sp,112
    80003908:	8aaa                	mv	s5,a0
    8000390a:	8bae                	mv	s7,a1
    8000390c:	8a32                	mv	s4,a2
    8000390e:	8936                	mv	s2,a3
    80003910:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    80003912:	00e687bb          	addw	a5,a3,a4
    80003916:	0cd7ee63          	bltu	a5,a3,800039f2 <writei+0x102>
    return -1;
  if (off + n > MAXFILE * BSIZE)
    8000391a:	00043737          	lui	a4,0x43
    8000391e:	0cf76c63          	bltu	a4,a5,800039f6 <writei+0x106>
    80003922:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003924:	0a0b0d63          	beqz	s6,800039de <writei+0xee>
    80003928:	eca6                	sd	s1,88(sp)
    8000392a:	f062                	sd	s8,32(sp)
    8000392c:	ec66                	sd	s9,24(sp)
    8000392e:	e86a                	sd	s10,16(sp)
    80003930:	e46e                	sd	s11,8(sp)
    80003932:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003934:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003938:	5c7d                	li	s8,-1
    8000393a:	a825                	j	80003972 <writei+0x82>
    8000393c:	020d1d93          	slli	s11,s10,0x20
    80003940:	020ddd93          	srli	s11,s11,0x20
    80003944:	05848513          	addi	a0,s1,88
    80003948:	86ee                	mv	a3,s11
    8000394a:	8652                	mv	a2,s4
    8000394c:	85de                	mv	a1,s7
    8000394e:	953e                	add	a0,a0,a5
    80003950:	a93fe0ef          	jal	800023e2 <either_copyin>
    80003954:	05850663          	beq	a0,s8,800039a0 <writei+0xb0>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    80003958:	8526                	mv	a0,s1
    8000395a:	6d8000ef          	jal	80004032 <log_write>
    brelse(bp);
    8000395e:	8526                	mv	a0,s1
    80003960:	d26ff0ef          	jal	80002e86 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003964:	013d09bb          	addw	s3,s10,s3
    80003968:	012d093b          	addw	s2,s10,s2
    8000396c:	9a6e                	add	s4,s4,s11
    8000396e:	0369ff63          	bgeu	s3,s6,800039ac <writei+0xbc>
    uint addr = bmap(ip, off / BSIZE);
    80003972:	00a9559b          	srliw	a1,s2,0xa
    80003976:	8556                	mv	a0,s5
    80003978:	f78ff0ef          	jal	800030f0 <bmap>
    8000397c:	85aa                	mv	a1,a0
    if (addr == 0)
    8000397e:	c51d                	beqz	a0,800039ac <writei+0xbc>
    bp = bread(ip->dev, addr);
    80003980:	000aa503          	lw	a0,0(s5)
    80003984:	bfaff0ef          	jal	80002d7e <bread>
    80003988:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    8000398a:	3ff97793          	andi	a5,s2,1023
    8000398e:	40fc873b          	subw	a4,s9,a5
    80003992:	413b06bb          	subw	a3,s6,s3
    80003996:	8d3a                	mv	s10,a4
    80003998:	fae6f2e3          	bgeu	a3,a4,8000393c <writei+0x4c>
    8000399c:	8d36                	mv	s10,a3
    8000399e:	bf79                	j	8000393c <writei+0x4c>
      log_write(bp);
    800039a0:	8526                	mv	a0,s1
    800039a2:	690000ef          	jal	80004032 <log_write>
      brelse(bp);
    800039a6:	8526                	mv	a0,s1
    800039a8:	cdeff0ef          	jal	80002e86 <brelse>
  }

  if (off > ip->size)
    800039ac:	04caa783          	lw	a5,76(s5)
    800039b0:	0327f963          	bgeu	a5,s2,800039e2 <writei+0xf2>
    ip->size = off;
    800039b4:	052aa623          	sw	s2,76(s5)
    800039b8:	64e6                	ld	s1,88(sp)
    800039ba:	7c02                	ld	s8,32(sp)
    800039bc:	6ce2                	ld	s9,24(sp)
    800039be:	6d42                	ld	s10,16(sp)
    800039c0:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800039c2:	8556                	mv	a0,s5
    800039c4:	9adff0ef          	jal	80003370 <iupdate>

  return tot;
    800039c8:	854e                	mv	a0,s3
    800039ca:	69a6                	ld	s3,72(sp)
}
    800039cc:	70a6                	ld	ra,104(sp)
    800039ce:	7406                	ld	s0,96(sp)
    800039d0:	6946                	ld	s2,80(sp)
    800039d2:	6a06                	ld	s4,64(sp)
    800039d4:	7ae2                	ld	s5,56(sp)
    800039d6:	7b42                	ld	s6,48(sp)
    800039d8:	7ba2                	ld	s7,40(sp)
    800039da:	6165                	addi	sp,sp,112
    800039dc:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800039de:	89da                	mv	s3,s6
    800039e0:	b7cd                	j	800039c2 <writei+0xd2>
    800039e2:	64e6                	ld	s1,88(sp)
    800039e4:	7c02                	ld	s8,32(sp)
    800039e6:	6ce2                	ld	s9,24(sp)
    800039e8:	6d42                	ld	s10,16(sp)
    800039ea:	6da2                	ld	s11,8(sp)
    800039ec:	bfd9                	j	800039c2 <writei+0xd2>
    return -1;
    800039ee:	557d                	li	a0,-1
}
    800039f0:	8082                	ret
    return -1;
    800039f2:	557d                	li	a0,-1
    800039f4:	bfe1                	j	800039cc <writei+0xdc>
    return -1;
    800039f6:	557d                	li	a0,-1
    800039f8:	bfd1                	j	800039cc <writei+0xdc>

00000000800039fa <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800039fa:	1141                	addi	sp,sp,-16
    800039fc:	e406                	sd	ra,8(sp)
    800039fe:	e022                	sd	s0,0(sp)
    80003a00:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003a02:	4639                	li	a2,14
    80003a04:	b20fd0ef          	jal	80000d24 <strncmp>
}
    80003a08:	60a2                	ld	ra,8(sp)
    80003a0a:	6402                	ld	s0,0(sp)
    80003a0c:	0141                	addi	sp,sp,16
    80003a0e:	8082                	ret

0000000080003a10 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003a10:	711d                	addi	sp,sp,-96
    80003a12:	ec86                	sd	ra,88(sp)
    80003a14:	e8a2                	sd	s0,80(sp)
    80003a16:	e4a6                	sd	s1,72(sp)
    80003a18:	e0ca                	sd	s2,64(sp)
    80003a1a:	fc4e                	sd	s3,56(sp)
    80003a1c:	f852                	sd	s4,48(sp)
    80003a1e:	f456                	sd	s5,40(sp)
    80003a20:	f05a                	sd	s6,32(sp)
    80003a22:	ec5e                	sd	s7,24(sp)
    80003a24:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003a26:	04451703          	lh	a4,68(a0)
    80003a2a:	4785                	li	a5,1
    80003a2c:	00f71f63          	bne	a4,a5,80003a4a <dirlookup+0x3a>
    80003a30:	892a                	mv	s2,a0
    80003a32:	8aae                	mv	s5,a1
    80003a34:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a36:	457c                	lw	a5,76(a0)
    80003a38:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a3a:	fa040a13          	addi	s4,s0,-96
    80003a3e:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    80003a40:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003a44:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a46:	e39d                	bnez	a5,80003a6c <dirlookup+0x5c>
    80003a48:	a8b9                	j	80003aa6 <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003a4a:	00004517          	auipc	a0,0x4
    80003a4e:	aa650513          	addi	a0,a0,-1370 # 800074f0 <etext+0x4f0>
    80003a52:	d9dfc0ef          	jal	800007ee <panic>
      panic("dirlookup read");
    80003a56:	00004517          	auipc	a0,0x4
    80003a5a:	ab250513          	addi	a0,a0,-1358 # 80007508 <etext+0x508>
    80003a5e:	d91fc0ef          	jal	800007ee <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a62:	24c1                	addiw	s1,s1,16
    80003a64:	04c92783          	lw	a5,76(s2)
    80003a68:	02f4fe63          	bgeu	s1,a5,80003aa4 <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a6c:	874e                	mv	a4,s3
    80003a6e:	86a6                	mv	a3,s1
    80003a70:	8652                	mv	a2,s4
    80003a72:	4581                	li	a1,0
    80003a74:	854a                	mv	a0,s2
    80003a76:	d89ff0ef          	jal	800037fe <readi>
    80003a7a:	fd351ee3          	bne	a0,s3,80003a56 <dirlookup+0x46>
    if (de.inum == 0)
    80003a7e:	fa045783          	lhu	a5,-96(s0)
    80003a82:	d3e5                	beqz	a5,80003a62 <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    80003a84:	85da                	mv	a1,s6
    80003a86:	8556                	mv	a0,s5
    80003a88:	f73ff0ef          	jal	800039fa <namecmp>
    80003a8c:	f979                	bnez	a0,80003a62 <dirlookup+0x52>
      if (poff)
    80003a8e:	000b8463          	beqz	s7,80003a96 <dirlookup+0x86>
        *poff = off;
    80003a92:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003a96:	fa045583          	lhu	a1,-96(s0)
    80003a9a:	00092503          	lw	a0,0(s2)
    80003a9e:	f12ff0ef          	jal	800031b0 <iget>
    80003aa2:	a011                	j	80003aa6 <dirlookup+0x96>
  return 0;
    80003aa4:	4501                	li	a0,0
}
    80003aa6:	60e6                	ld	ra,88(sp)
    80003aa8:	6446                	ld	s0,80(sp)
    80003aaa:	64a6                	ld	s1,72(sp)
    80003aac:	6906                	ld	s2,64(sp)
    80003aae:	79e2                	ld	s3,56(sp)
    80003ab0:	7a42                	ld	s4,48(sp)
    80003ab2:	7aa2                	ld	s5,40(sp)
    80003ab4:	7b02                	ld	s6,32(sp)
    80003ab6:	6be2                	ld	s7,24(sp)
    80003ab8:	6125                	addi	sp,sp,96
    80003aba:	8082                	ret

0000000080003abc <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003abc:	711d                	addi	sp,sp,-96
    80003abe:	ec86                	sd	ra,88(sp)
    80003ac0:	e8a2                	sd	s0,80(sp)
    80003ac2:	e4a6                	sd	s1,72(sp)
    80003ac4:	e0ca                	sd	s2,64(sp)
    80003ac6:	fc4e                	sd	s3,56(sp)
    80003ac8:	f852                	sd	s4,48(sp)
    80003aca:	f456                	sd	s5,40(sp)
    80003acc:	f05a                	sd	s6,32(sp)
    80003ace:	ec5e                	sd	s7,24(sp)
    80003ad0:	e862                	sd	s8,16(sp)
    80003ad2:	e466                	sd	s9,8(sp)
    80003ad4:	e06a                	sd	s10,0(sp)
    80003ad6:	1080                	addi	s0,sp,96
    80003ad8:	84aa                	mv	s1,a0
    80003ada:	8b2e                	mv	s6,a1
    80003adc:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003ade:	00054703          	lbu	a4,0(a0)
    80003ae2:	02f00793          	li	a5,47
    80003ae6:	00f70f63          	beq	a4,a5,80003b04 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003aea:	e95fd0ef          	jal	8000197e <myproc>
    80003aee:	15853503          	ld	a0,344(a0)
    80003af2:	8fdff0ef          	jal	800033ee <idup>
    80003af6:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003af8:	02f00913          	li	s2,47
  if (len >= DIRSIZ)
    80003afc:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003afe:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003b00:	4b85                	li	s7,1
    80003b02:	a07d                	j	80003bb0 <namex+0xf4>
    ip = iget(ROOTDEV, ROOTINO);
    80003b04:	4585                	li	a1,1
    80003b06:	852e                	mv	a0,a1
    80003b08:	ea8ff0ef          	jal	800031b0 <iget>
    80003b0c:	8a2a                	mv	s4,a0
    80003b0e:	b7ed                	j	80003af8 <namex+0x3c>
      iunlockput(ip);
    80003b10:	8552                	mv	a0,s4
    80003b12:	b65ff0ef          	jal	80003676 <iunlockput>
      return 0;
    80003b16:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003b18:	8552                	mv	a0,s4
    80003b1a:	60e6                	ld	ra,88(sp)
    80003b1c:	6446                	ld	s0,80(sp)
    80003b1e:	64a6                	ld	s1,72(sp)
    80003b20:	6906                	ld	s2,64(sp)
    80003b22:	79e2                	ld	s3,56(sp)
    80003b24:	7a42                	ld	s4,48(sp)
    80003b26:	7aa2                	ld	s5,40(sp)
    80003b28:	7b02                	ld	s6,32(sp)
    80003b2a:	6be2                	ld	s7,24(sp)
    80003b2c:	6c42                	ld	s8,16(sp)
    80003b2e:	6ca2                	ld	s9,8(sp)
    80003b30:	6d02                	ld	s10,0(sp)
    80003b32:	6125                	addi	sp,sp,96
    80003b34:	8082                	ret
      iunlockput(ip);
    80003b36:	8552                	mv	a0,s4
    80003b38:	b3fff0ef          	jal	80003676 <iunlockput>
      return 0;
    80003b3c:	4a01                	li	s4,0
    80003b3e:	bfe9                	j	80003b18 <namex+0x5c>
      iunlock(ip);
    80003b40:	8552                	mv	a0,s4
    80003b42:	991ff0ef          	jal	800034d2 <iunlock>
      return ip;
    80003b46:	bfc9                	j	80003b18 <namex+0x5c>
      iunlockput(ip);
    80003b48:	8552                	mv	a0,s4
    80003b4a:	b2dff0ef          	jal	80003676 <iunlockput>
      return 0;
    80003b4e:	8a4e                	mv	s4,s3
    80003b50:	b7e1                	j	80003b18 <namex+0x5c>
  len = path - s;
    80003b52:	40998633          	sub	a2,s3,s1
    80003b56:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80003b5a:	09ac5363          	bge	s8,s10,80003be0 <namex+0x124>
    memmove(name, s, DIRSIZ);
    80003b5e:	8666                	mv	a2,s9
    80003b60:	85a6                	mv	a1,s1
    80003b62:	8556                	mv	a0,s5
    80003b64:	94cfd0ef          	jal	80000cb0 <memmove>
    80003b68:	84ce                	mv	s1,s3
  while (*path == '/')
    80003b6a:	0004c783          	lbu	a5,0(s1)
    80003b6e:	01279763          	bne	a5,s2,80003b7c <namex+0xc0>
    path++;
    80003b72:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003b74:	0004c783          	lbu	a5,0(s1)
    80003b78:	ff278de3          	beq	a5,s2,80003b72 <namex+0xb6>
    ilock(ip);
    80003b7c:	8552                	mv	a0,s4
    80003b7e:	8a7ff0ef          	jal	80003424 <ilock>
    if (ip->type != T_DIR) {
    80003b82:	044a1783          	lh	a5,68(s4)
    80003b86:	f97795e3          	bne	a5,s7,80003b10 <namex+0x54>
    if (ip->nlink == 0) {
    80003b8a:	04aa1783          	lh	a5,74(s4)
    80003b8e:	d7c5                	beqz	a5,80003b36 <namex+0x7a>
    if (nameiparent && *path == '\0') {
    80003b90:	000b0563          	beqz	s6,80003b9a <namex+0xde>
    80003b94:	0004c783          	lbu	a5,0(s1)
    80003b98:	d7c5                	beqz	a5,80003b40 <namex+0x84>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003b9a:	4601                	li	a2,0
    80003b9c:	85d6                	mv	a1,s5
    80003b9e:	8552                	mv	a0,s4
    80003ba0:	e71ff0ef          	jal	80003a10 <dirlookup>
    80003ba4:	89aa                	mv	s3,a0
    80003ba6:	d14d                	beqz	a0,80003b48 <namex+0x8c>
    iunlockput(ip);
    80003ba8:	8552                	mv	a0,s4
    80003baa:	acdff0ef          	jal	80003676 <iunlockput>
    ip = next;
    80003bae:	8a4e                	mv	s4,s3
  while (*path == '/')
    80003bb0:	0004c783          	lbu	a5,0(s1)
    80003bb4:	01279763          	bne	a5,s2,80003bc2 <namex+0x106>
    path++;
    80003bb8:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003bba:	0004c783          	lbu	a5,0(s1)
    80003bbe:	ff278de3          	beq	a5,s2,80003bb8 <namex+0xfc>
  if (*path == 0)
    80003bc2:	cb8d                	beqz	a5,80003bf4 <namex+0x138>
  while (*path != '/' && *path != 0)
    80003bc4:	0004c783          	lbu	a5,0(s1)
    80003bc8:	89a6                	mv	s3,s1
  len = path - s;
    80003bca:	4d01                	li	s10,0
    80003bcc:	4601                	li	a2,0
  while (*path != '/' && *path != 0)
    80003bce:	01278963          	beq	a5,s2,80003be0 <namex+0x124>
    80003bd2:	d3c1                	beqz	a5,80003b52 <namex+0x96>
    path++;
    80003bd4:	0985                	addi	s3,s3,1
  while (*path != '/' && *path != 0)
    80003bd6:	0009c783          	lbu	a5,0(s3)
    80003bda:	ff279ce3          	bne	a5,s2,80003bd2 <namex+0x116>
    80003bde:	bf95                	j	80003b52 <namex+0x96>
    memmove(name, s, len);
    80003be0:	2601                	sext.w	a2,a2
    80003be2:	85a6                	mv	a1,s1
    80003be4:	8556                	mv	a0,s5
    80003be6:	8cafd0ef          	jal	80000cb0 <memmove>
    name[len] = 0;
    80003bea:	9d56                	add	s10,s10,s5
    80003bec:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffde210>
    80003bf0:	84ce                	mv	s1,s3
    80003bf2:	bfa5                	j	80003b6a <namex+0xae>
  if (nameiparent) {
    80003bf4:	f20b02e3          	beqz	s6,80003b18 <namex+0x5c>
    iput(ip);
    80003bf8:	8552                	mv	a0,s4
    80003bfa:	9adff0ef          	jal	800035a6 <iput>
    return 0;
    80003bfe:	4a01                	li	s4,0
    80003c00:	bf21                	j	80003b18 <namex+0x5c>

0000000080003c02 <dirlink>:
{
    80003c02:	715d                	addi	sp,sp,-80
    80003c04:	e486                	sd	ra,72(sp)
    80003c06:	e0a2                	sd	s0,64(sp)
    80003c08:	f84a                	sd	s2,48(sp)
    80003c0a:	ec56                	sd	s5,24(sp)
    80003c0c:	e85a                	sd	s6,16(sp)
    80003c0e:	0880                	addi	s0,sp,80
    80003c10:	892a                	mv	s2,a0
    80003c12:	8aae                	mv	s5,a1
    80003c14:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003c16:	4601                	li	a2,0
    80003c18:	df9ff0ef          	jal	80003a10 <dirlookup>
    80003c1c:	ed1d                	bnez	a0,80003c5a <dirlink+0x58>
    80003c1e:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003c20:	04c92483          	lw	s1,76(s2)
    80003c24:	c4b9                	beqz	s1,80003c72 <dirlink+0x70>
    80003c26:	f44e                	sd	s3,40(sp)
    80003c28:	f052                	sd	s4,32(sp)
    80003c2a:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c2c:	fb040a13          	addi	s4,s0,-80
    80003c30:	49c1                	li	s3,16
    80003c32:	874e                	mv	a4,s3
    80003c34:	86a6                	mv	a3,s1
    80003c36:	8652                	mv	a2,s4
    80003c38:	4581                	li	a1,0
    80003c3a:	854a                	mv	a0,s2
    80003c3c:	bc3ff0ef          	jal	800037fe <readi>
    80003c40:	03351163          	bne	a0,s3,80003c62 <dirlink+0x60>
    if (de.inum == 0)
    80003c44:	fb045783          	lhu	a5,-80(s0)
    80003c48:	c39d                	beqz	a5,80003c6e <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003c4a:	24c1                	addiw	s1,s1,16
    80003c4c:	04c92783          	lw	a5,76(s2)
    80003c50:	fef4e1e3          	bltu	s1,a5,80003c32 <dirlink+0x30>
    80003c54:	79a2                	ld	s3,40(sp)
    80003c56:	7a02                	ld	s4,32(sp)
    80003c58:	a829                	j	80003c72 <dirlink+0x70>
    iput(ip);
    80003c5a:	94dff0ef          	jal	800035a6 <iput>
    return -1;
    80003c5e:	557d                	li	a0,-1
    80003c60:	a83d                	j	80003c9e <dirlink+0x9c>
      panic("dirlink read");
    80003c62:	00004517          	auipc	a0,0x4
    80003c66:	8b650513          	addi	a0,a0,-1866 # 80007518 <etext+0x518>
    80003c6a:	b85fc0ef          	jal	800007ee <panic>
    80003c6e:	79a2                	ld	s3,40(sp)
    80003c70:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003c72:	4639                	li	a2,14
    80003c74:	85d6                	mv	a1,s5
    80003c76:	fb240513          	addi	a0,s0,-78
    80003c7a:	8e4fd0ef          	jal	80000d5e <strncpy>
  de.inum = inum;
    80003c7e:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c82:	4741                	li	a4,16
    80003c84:	86a6                	mv	a3,s1
    80003c86:	fb040613          	addi	a2,s0,-80
    80003c8a:	4581                	li	a1,0
    80003c8c:	854a                	mv	a0,s2
    80003c8e:	c63ff0ef          	jal	800038f0 <writei>
    80003c92:	1541                	addi	a0,a0,-16
    80003c94:	00a03533          	snez	a0,a0
    80003c98:	40a0053b          	negw	a0,a0
    80003c9c:	74e2                	ld	s1,56(sp)
}
    80003c9e:	60a6                	ld	ra,72(sp)
    80003ca0:	6406                	ld	s0,64(sp)
    80003ca2:	7942                	ld	s2,48(sp)
    80003ca4:	6ae2                	ld	s5,24(sp)
    80003ca6:	6b42                	ld	s6,16(sp)
    80003ca8:	6161                	addi	sp,sp,80
    80003caa:	8082                	ret

0000000080003cac <namei>:

struct inode *
namei(char *path)
{
    80003cac:	1101                	addi	sp,sp,-32
    80003cae:	ec06                	sd	ra,24(sp)
    80003cb0:	e822                	sd	s0,16(sp)
    80003cb2:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003cb4:	fe040613          	addi	a2,s0,-32
    80003cb8:	4581                	li	a1,0
    80003cba:	e03ff0ef          	jal	80003abc <namex>
}
    80003cbe:	60e2                	ld	ra,24(sp)
    80003cc0:	6442                	ld	s0,16(sp)
    80003cc2:	6105                	addi	sp,sp,32
    80003cc4:	8082                	ret

0000000080003cc6 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003cc6:	1141                	addi	sp,sp,-16
    80003cc8:	e406                	sd	ra,8(sp)
    80003cca:	e022                	sd	s0,0(sp)
    80003ccc:	0800                	addi	s0,sp,16
    80003cce:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003cd0:	4585                	li	a1,1
    80003cd2:	debff0ef          	jal	80003abc <namex>
}
    80003cd6:	60a2                	ld	ra,8(sp)
    80003cd8:	6402                	ld	s0,0(sp)
    80003cda:	0141                	addi	sp,sp,16
    80003cdc:	8082                	ret

0000000080003cde <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003cde:	1101                	addi	sp,sp,-32
    80003ce0:	ec06                	sd	ra,24(sp)
    80003ce2:	e822                	sd	s0,16(sp)
    80003ce4:	e426                	sd	s1,8(sp)
    80003ce6:	e04a                	sd	s2,0(sp)
    80003ce8:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003cea:	0001c917          	auipc	s2,0x1c
    80003cee:	ec690913          	addi	s2,s2,-314 # 8001fbb0 <log>
    80003cf2:	01892583          	lw	a1,24(s2)
    80003cf6:	02492503          	lw	a0,36(s2)
    80003cfa:	884ff0ef          	jal	80002d7e <bread>
    80003cfe:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003d00:	02c92603          	lw	a2,44(s2)
    80003d04:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003d06:	00c05f63          	blez	a2,80003d24 <write_head+0x46>
    80003d0a:	0001c717          	auipc	a4,0x1c
    80003d0e:	ed670713          	addi	a4,a4,-298 # 8001fbe0 <log+0x30>
    80003d12:	87aa                	mv	a5,a0
    80003d14:	060a                	slli	a2,a2,0x2
    80003d16:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003d18:	4314                	lw	a3,0(a4)
    80003d1a:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003d1c:	0711                	addi	a4,a4,4
    80003d1e:	0791                	addi	a5,a5,4
    80003d20:	fec79ce3          	bne	a5,a2,80003d18 <write_head+0x3a>
  }
  bwrite(buf);
    80003d24:	8526                	mv	a0,s1
    80003d26:	92eff0ef          	jal	80002e54 <bwrite>
  brelse(buf);
    80003d2a:	8526                	mv	a0,s1
    80003d2c:	95aff0ef          	jal	80002e86 <brelse>
}
    80003d30:	60e2                	ld	ra,24(sp)
    80003d32:	6442                	ld	s0,16(sp)
    80003d34:	64a2                	ld	s1,8(sp)
    80003d36:	6902                	ld	s2,0(sp)
    80003d38:	6105                	addi	sp,sp,32
    80003d3a:	8082                	ret

0000000080003d3c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d3c:	0001c797          	auipc	a5,0x1c
    80003d40:	ea07a783          	lw	a5,-352(a5) # 8001fbdc <log+0x2c>
    80003d44:	0cf05163          	blez	a5,80003e06 <install_trans+0xca>
{
    80003d48:	715d                	addi	sp,sp,-80
    80003d4a:	e486                	sd	ra,72(sp)
    80003d4c:	e0a2                	sd	s0,64(sp)
    80003d4e:	fc26                	sd	s1,56(sp)
    80003d50:	f84a                	sd	s2,48(sp)
    80003d52:	f44e                	sd	s3,40(sp)
    80003d54:	f052                	sd	s4,32(sp)
    80003d56:	ec56                	sd	s5,24(sp)
    80003d58:	e85a                	sd	s6,16(sp)
    80003d5a:	e45e                	sd	s7,8(sp)
    80003d5c:	e062                	sd	s8,0(sp)
    80003d5e:	0880                	addi	s0,sp,80
    80003d60:	8b2a                	mv	s6,a0
    80003d62:	0001ca97          	auipc	s5,0x1c
    80003d66:	e7ea8a93          	addi	s5,s5,-386 # 8001fbe0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d6a:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d6c:	00003c17          	auipc	s8,0x3
    80003d70:	7bcc0c13          	addi	s8,s8,1980 # 80007528 <etext+0x528>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003d74:	0001ca17          	auipc	s4,0x1c
    80003d78:	e3ca0a13          	addi	s4,s4,-452 # 8001fbb0 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003d7c:	40000b93          	li	s7,1024
    80003d80:	a025                	j	80003da8 <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d82:	000aa603          	lw	a2,0(s5)
    80003d86:	85ce                	mv	a1,s3
    80003d88:	8562                	mv	a0,s8
    80003d8a:	f80fc0ef          	jal	8000050a <printk>
    80003d8e:	a839                	j	80003dac <install_trans+0x70>
    brelse(lbuf);
    80003d90:	854a                	mv	a0,s2
    80003d92:	8f4ff0ef          	jal	80002e86 <brelse>
    brelse(dbuf);
    80003d96:	8526                	mv	a0,s1
    80003d98:	8eeff0ef          	jal	80002e86 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d9c:	2985                	addiw	s3,s3,1
    80003d9e:	0a91                	addi	s5,s5,4
    80003da0:	02ca2783          	lw	a5,44(s4)
    80003da4:	04f9d563          	bge	s3,a5,80003dee <install_trans+0xb2>
    if (recovering) {
    80003da8:	fc0b1de3          	bnez	s6,80003d82 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003dac:	018a2583          	lw	a1,24(s4)
    80003db0:	013585bb          	addw	a1,a1,s3
    80003db4:	2585                	addiw	a1,a1,1
    80003db6:	024a2503          	lw	a0,36(s4)
    80003dba:	fc5fe0ef          	jal	80002d7e <bread>
    80003dbe:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003dc0:	000aa583          	lw	a1,0(s5)
    80003dc4:	024a2503          	lw	a0,36(s4)
    80003dc8:	fb7fe0ef          	jal	80002d7e <bread>
    80003dcc:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003dce:	865e                	mv	a2,s7
    80003dd0:	05890593          	addi	a1,s2,88
    80003dd4:	05850513          	addi	a0,a0,88
    80003dd8:	ed9fc0ef          	jal	80000cb0 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003ddc:	8526                	mv	a0,s1
    80003dde:	876ff0ef          	jal	80002e54 <bwrite>
    if (recovering == 0)
    80003de2:	fa0b17e3          	bnez	s6,80003d90 <install_trans+0x54>
      bunpin(dbuf);
    80003de6:	8526                	mv	a0,s1
    80003de8:	956ff0ef          	jal	80002f3e <bunpin>
    80003dec:	b755                	j	80003d90 <install_trans+0x54>
}
    80003dee:	60a6                	ld	ra,72(sp)
    80003df0:	6406                	ld	s0,64(sp)
    80003df2:	74e2                	ld	s1,56(sp)
    80003df4:	7942                	ld	s2,48(sp)
    80003df6:	79a2                	ld	s3,40(sp)
    80003df8:	7a02                	ld	s4,32(sp)
    80003dfa:	6ae2                	ld	s5,24(sp)
    80003dfc:	6b42                	ld	s6,16(sp)
    80003dfe:	6ba2                	ld	s7,8(sp)
    80003e00:	6c02                	ld	s8,0(sp)
    80003e02:	6161                	addi	sp,sp,80
    80003e04:	8082                	ret
    80003e06:	8082                	ret

0000000080003e08 <initlog>:
{
    80003e08:	7179                	addi	sp,sp,-48
    80003e0a:	f406                	sd	ra,40(sp)
    80003e0c:	f022                	sd	s0,32(sp)
    80003e0e:	ec26                	sd	s1,24(sp)
    80003e10:	e84a                	sd	s2,16(sp)
    80003e12:	e44e                	sd	s3,8(sp)
    80003e14:	1800                	addi	s0,sp,48
    80003e16:	892a                	mv	s2,a0
    80003e18:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003e1a:	0001c497          	auipc	s1,0x1c
    80003e1e:	d9648493          	addi	s1,s1,-618 # 8001fbb0 <log>
    80003e22:	00003597          	auipc	a1,0x3
    80003e26:	72658593          	addi	a1,a1,1830 # 80007548 <etext+0x548>
    80003e2a:	8526                	mv	a0,s1
    80003e2c:	ce7fc0ef          	jal	80000b12 <initlock>
  log.start = sb->logstart;
    80003e30:	0149a583          	lw	a1,20(s3)
    80003e34:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003e36:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003e3a:	854a                	mv	a0,s2
    80003e3c:	f43fe0ef          	jal	80002d7e <bread>
  log.lh.n = lh->n;
    80003e40:	4d30                	lw	a2,88(a0)
    80003e42:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003e44:	00c05f63          	blez	a2,80003e62 <initlog+0x5a>
    80003e48:	87aa                	mv	a5,a0
    80003e4a:	0001c717          	auipc	a4,0x1c
    80003e4e:	d9670713          	addi	a4,a4,-618 # 8001fbe0 <log+0x30>
    80003e52:	060a                	slli	a2,a2,0x2
    80003e54:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003e56:	4ff4                	lw	a3,92(a5)
    80003e58:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e5a:	0791                	addi	a5,a5,4
    80003e5c:	0711                	addi	a4,a4,4
    80003e5e:	fec79ce3          	bne	a5,a2,80003e56 <initlog+0x4e>
  brelse(buf);
    80003e62:	824ff0ef          	jal	80002e86 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003e66:	4505                	li	a0,1
    80003e68:	ed5ff0ef          	jal	80003d3c <install_trans>
  log.lh.n = 0;
    80003e6c:	0001c797          	auipc	a5,0x1c
    80003e70:	d607a823          	sw	zero,-656(a5) # 8001fbdc <log+0x2c>
  write_head(); // clear the log
    80003e74:	e6bff0ef          	jal	80003cde <write_head>
}
    80003e78:	70a2                	ld	ra,40(sp)
    80003e7a:	7402                	ld	s0,32(sp)
    80003e7c:	64e2                	ld	s1,24(sp)
    80003e7e:	6942                	ld	s2,16(sp)
    80003e80:	69a2                	ld	s3,8(sp)
    80003e82:	6145                	addi	sp,sp,48
    80003e84:	8082                	ret

0000000080003e86 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003e86:	1101                	addi	sp,sp,-32
    80003e88:	ec06                	sd	ra,24(sp)
    80003e8a:	e822                	sd	s0,16(sp)
    80003e8c:	e426                	sd	s1,8(sp)
    80003e8e:	e04a                	sd	s2,0(sp)
    80003e90:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003e92:	0001c517          	auipc	a0,0x1c
    80003e96:	d1e50513          	addi	a0,a0,-738 # 8001fbb0 <log>
    80003e9a:	cf3fc0ef          	jal	80000b8c <acquire>
  while (1) {
    if (log.committing) {
    80003e9e:	0001c497          	auipc	s1,0x1c
    80003ea2:	d1248493          	addi	s1,s1,-750 # 8001fbb0 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003ea6:	4979                	li	s2,30
    80003ea8:	a821                	j	80003ec0 <begin_op+0x3a>
      sleep_prepare(&log);
    80003eaa:	8526                	mv	a0,s1
    80003eac:	95cfe0ef          	jal	80002008 <sleep_prepare>
      release(&log.lock);
    80003eb0:	8526                	mv	a0,s1
    80003eb2:	d63fc0ef          	jal	80000c14 <release>
      sleep();
    80003eb6:	98efe0ef          	jal	80002044 <sleep>
      acquire(&log.lock);
    80003eba:	8526                	mv	a0,s1
    80003ebc:	cd1fc0ef          	jal	80000b8c <acquire>
    if (log.committing) {
    80003ec0:	509c                	lw	a5,32(s1)
    80003ec2:	f7e5                	bnez	a5,80003eaa <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003ec4:	4cd8                	lw	a4,28(s1)
    80003ec6:	2705                	addiw	a4,a4,1
    80003ec8:	0027179b          	slliw	a5,a4,0x2
    80003ecc:	9fb9                	addw	a5,a5,a4
    80003ece:	0017979b          	slliw	a5,a5,0x1
    80003ed2:	54d4                	lw	a3,44(s1)
    80003ed4:	9fb5                	addw	a5,a5,a3
    80003ed6:	00f95e63          	bge	s2,a5,80003ef2 <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80003eda:	8526                	mv	a0,s1
    80003edc:	92cfe0ef          	jal	80002008 <sleep_prepare>
      release(&log.lock);
    80003ee0:	8526                	mv	a0,s1
    80003ee2:	d33fc0ef          	jal	80000c14 <release>
      sleep();
    80003ee6:	95efe0ef          	jal	80002044 <sleep>
      acquire(&log.lock);
    80003eea:	8526                	mv	a0,s1
    80003eec:	ca1fc0ef          	jal	80000b8c <acquire>
    80003ef0:	bfc1                	j	80003ec0 <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80003ef2:	0001c517          	auipc	a0,0x1c
    80003ef6:	cbe50513          	addi	a0,a0,-834 # 8001fbb0 <log>
    80003efa:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003efc:	d19fc0ef          	jal	80000c14 <release>
      break;
    }
  }
}
    80003f00:	60e2                	ld	ra,24(sp)
    80003f02:	6442                	ld	s0,16(sp)
    80003f04:	64a2                	ld	s1,8(sp)
    80003f06:	6902                	ld	s2,0(sp)
    80003f08:	6105                	addi	sp,sp,32
    80003f0a:	8082                	ret

0000000080003f0c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003f0c:	7139                	addi	sp,sp,-64
    80003f0e:	fc06                	sd	ra,56(sp)
    80003f10:	f822                	sd	s0,48(sp)
    80003f12:	f426                	sd	s1,40(sp)
    80003f14:	f04a                	sd	s2,32(sp)
    80003f16:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003f18:	0001c497          	auipc	s1,0x1c
    80003f1c:	c9848493          	addi	s1,s1,-872 # 8001fbb0 <log>
    80003f20:	8526                	mv	a0,s1
    80003f22:	c6bfc0ef          	jal	80000b8c <acquire>
  log.outstanding -= 1;
    80003f26:	4cdc                	lw	a5,28(s1)
    80003f28:	37fd                	addiw	a5,a5,-1
    80003f2a:	893e                	mv	s2,a5
    80003f2c:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003f2e:	509c                	lw	a5,32(s1)
    80003f30:	e3b1                	bnez	a5,80003f74 <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003f32:	04091b63          	bnez	s2,80003f88 <end_op+0x7c>
    do_commit = 1;
    log.committing = 1;
    80003f36:	0001c497          	auipc	s1,0x1c
    80003f3a:	c7a48493          	addi	s1,s1,-902 # 8001fbb0 <log>
    80003f3e:	4785                	li	a5,1
    80003f40:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003f42:	8526                	mv	a0,s1
    80003f44:	cd1fc0ef          	jal	80000c14 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003f48:	54dc                	lw	a5,44(s1)
    80003f4a:	04f04f63          	bgtz	a5,80003fa8 <end_op+0x9c>
    acquire(&log.lock);
    80003f4e:	0001c497          	auipc	s1,0x1c
    80003f52:	c6248493          	addi	s1,s1,-926 # 8001fbb0 <log>
    80003f56:	8526                	mv	a0,s1
    80003f58:	c35fc0ef          	jal	80000b8c <acquire>
    log.committing = 0;
    80003f5c:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003f60:	549c                	lw	a5,40(s1)
    80003f62:	2785                	addiw	a5,a5,1
    80003f64:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003f66:	8526                	mv	a0,s1
    80003f68:	90cfe0ef          	jal	80002074 <wakeup>
    release(&log.lock);
    80003f6c:	8526                	mv	a0,s1
    80003f6e:	ca7fc0ef          	jal	80000c14 <release>
}
    80003f72:	a02d                	j	80003f9c <end_op+0x90>
    80003f74:	ec4e                	sd	s3,24(sp)
    80003f76:	e852                	sd	s4,16(sp)
    80003f78:	e456                	sd	s5,8(sp)
    80003f7a:	e05a                	sd	s6,0(sp)
    panic("log.committing");
    80003f7c:	00003517          	auipc	a0,0x3
    80003f80:	5d450513          	addi	a0,a0,1492 # 80007550 <etext+0x550>
    80003f84:	86bfc0ef          	jal	800007ee <panic>
    wakeup(&log);
    80003f88:	0001c497          	auipc	s1,0x1c
    80003f8c:	c2848493          	addi	s1,s1,-984 # 8001fbb0 <log>
    80003f90:	8526                	mv	a0,s1
    80003f92:	8e2fe0ef          	jal	80002074 <wakeup>
  release(&log.lock);
    80003f96:	8526                	mv	a0,s1
    80003f98:	c7dfc0ef          	jal	80000c14 <release>
}
    80003f9c:	70e2                	ld	ra,56(sp)
    80003f9e:	7442                	ld	s0,48(sp)
    80003fa0:	74a2                	ld	s1,40(sp)
    80003fa2:	7902                	ld	s2,32(sp)
    80003fa4:	6121                	addi	sp,sp,64
    80003fa6:	8082                	ret
    80003fa8:	ec4e                	sd	s3,24(sp)
    80003faa:	e852                	sd	s4,16(sp)
    80003fac:	e456                	sd	s5,8(sp)
    80003fae:	e05a                	sd	s6,0(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fb0:	0001ca97          	auipc	s5,0x1c
    80003fb4:	c30a8a93          	addi	s5,s5,-976 # 8001fbe0 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003fb8:	0001ca17          	auipc	s4,0x1c
    80003fbc:	bf8a0a13          	addi	s4,s4,-1032 # 8001fbb0 <log>
    memmove(to->data, from->data, BSIZE);
    80003fc0:	40000b13          	li	s6,1024
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003fc4:	018a2583          	lw	a1,24(s4)
    80003fc8:	012585bb          	addw	a1,a1,s2
    80003fcc:	2585                	addiw	a1,a1,1
    80003fce:	024a2503          	lw	a0,36(s4)
    80003fd2:	dadfe0ef          	jal	80002d7e <bread>
    80003fd6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003fd8:	000aa583          	lw	a1,0(s5)
    80003fdc:	024a2503          	lw	a0,36(s4)
    80003fe0:	d9ffe0ef          	jal	80002d7e <bread>
    80003fe4:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003fe6:	865a                	mv	a2,s6
    80003fe8:	05850593          	addi	a1,a0,88
    80003fec:	05848513          	addi	a0,s1,88
    80003ff0:	cc1fc0ef          	jal	80000cb0 <memmove>
    bwrite(to); // write the log
    80003ff4:	8526                	mv	a0,s1
    80003ff6:	e5ffe0ef          	jal	80002e54 <bwrite>
    brelse(from);
    80003ffa:	854e                	mv	a0,s3
    80003ffc:	e8bfe0ef          	jal	80002e86 <brelse>
    brelse(to);
    80004000:	8526                	mv	a0,s1
    80004002:	e85fe0ef          	jal	80002e86 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004006:	2905                	addiw	s2,s2,1
    80004008:	0a91                	addi	s5,s5,4
    8000400a:	02ca2783          	lw	a5,44(s4)
    8000400e:	faf94be3          	blt	s2,a5,80003fc4 <end_op+0xb8>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80004012:	ccdff0ef          	jal	80003cde <write_head>
    install_trans(0); // Now install writes to home locations
    80004016:	4501                	li	a0,0
    80004018:	d25ff0ef          	jal	80003d3c <install_trans>
    log.lh.n = 0;
    8000401c:	0001c797          	auipc	a5,0x1c
    80004020:	bc07a023          	sw	zero,-1088(a5) # 8001fbdc <log+0x2c>
    write_head(); // Erase the transaction from the log
    80004024:	cbbff0ef          	jal	80003cde <write_head>
    80004028:	69e2                	ld	s3,24(sp)
    8000402a:	6a42                	ld	s4,16(sp)
    8000402c:	6aa2                	ld	s5,8(sp)
    8000402e:	6b02                	ld	s6,0(sp)
    80004030:	bf39                	j	80003f4e <end_op+0x42>

0000000080004032 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004032:	1101                	addi	sp,sp,-32
    80004034:	ec06                	sd	ra,24(sp)
    80004036:	e822                	sd	s0,16(sp)
    80004038:	e426                	sd	s1,8(sp)
    8000403a:	e04a                	sd	s2,0(sp)
    8000403c:	1000                	addi	s0,sp,32
    8000403e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004040:	0001c917          	auipc	s2,0x1c
    80004044:	b7090913          	addi	s2,s2,-1168 # 8001fbb0 <log>
    80004048:	854a                	mv	a0,s2
    8000404a:	b43fc0ef          	jal	80000b8c <acquire>
  if (log.lh.n >= LOGBLOCKS)
    8000404e:	02c92603          	lw	a2,44(s2)
    80004052:	47f5                	li	a5,29
    80004054:	04c7cc63          	blt	a5,a2,800040ac <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004058:	0001c797          	auipc	a5,0x1c
    8000405c:	b747a783          	lw	a5,-1164(a5) # 8001fbcc <log+0x1c>
    80004060:	04f05c63          	blez	a5,800040b8 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004064:	4781                	li	a5,0
    80004066:	04c05f63          	blez	a2,800040c4 <log_write+0x92>
    if (log.lh.block[i] == b->blockno) // log absorption
    8000406a:	44cc                	lw	a1,12(s1)
    8000406c:	0001c717          	auipc	a4,0x1c
    80004070:	b7470713          	addi	a4,a4,-1164 # 8001fbe0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004074:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80004076:	4314                	lw	a3,0(a4)
    80004078:	04b68663          	beq	a3,a1,800040c4 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    8000407c:	2785                	addiw	a5,a5,1
    8000407e:	0711                	addi	a4,a4,4
    80004080:	fef61be3          	bne	a2,a5,80004076 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004084:	0621                	addi	a2,a2,8
    80004086:	060a                	slli	a2,a2,0x2
    80004088:	0001c797          	auipc	a5,0x1c
    8000408c:	b2878793          	addi	a5,a5,-1240 # 8001fbb0 <log>
    80004090:	97b2                	add	a5,a5,a2
    80004092:	44d8                	lw	a4,12(s1)
    80004094:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80004096:	8526                	mv	a0,s1
    80004098:	e73fe0ef          	jal	80002f0a <bpin>
    log.lh.n++;
    8000409c:	0001c717          	auipc	a4,0x1c
    800040a0:	b1470713          	addi	a4,a4,-1260 # 8001fbb0 <log>
    800040a4:	575c                	lw	a5,44(a4)
    800040a6:	2785                	addiw	a5,a5,1
    800040a8:	d75c                	sw	a5,44(a4)
    800040aa:	a80d                	j	800040dc <log_write+0xaa>
    panic("too big a transaction");
    800040ac:	00003517          	auipc	a0,0x3
    800040b0:	4b450513          	addi	a0,a0,1204 # 80007560 <etext+0x560>
    800040b4:	f3afc0ef          	jal	800007ee <panic>
    panic("log_write outside of trans");
    800040b8:	00003517          	auipc	a0,0x3
    800040bc:	4c050513          	addi	a0,a0,1216 # 80007578 <etext+0x578>
    800040c0:	f2efc0ef          	jal	800007ee <panic>
  log.lh.block[i] = b->blockno;
    800040c4:	00878693          	addi	a3,a5,8
    800040c8:	068a                	slli	a3,a3,0x2
    800040ca:	0001c717          	auipc	a4,0x1c
    800040ce:	ae670713          	addi	a4,a4,-1306 # 8001fbb0 <log>
    800040d2:	9736                	add	a4,a4,a3
    800040d4:	44d4                	lw	a3,12(s1)
    800040d6:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    800040d8:	faf60fe3          	beq	a2,a5,80004096 <log_write+0x64>
  }
  release(&log.lock);
    800040dc:	0001c517          	auipc	a0,0x1c
    800040e0:	ad450513          	addi	a0,a0,-1324 # 8001fbb0 <log>
    800040e4:	b31fc0ef          	jal	80000c14 <release>
}
    800040e8:	60e2                	ld	ra,24(sp)
    800040ea:	6442                	ld	s0,16(sp)
    800040ec:	64a2                	ld	s1,8(sp)
    800040ee:	6902                	ld	s2,0(sp)
    800040f0:	6105                	addi	sp,sp,32
    800040f2:	8082                	ret

00000000800040f4 <sys_sync>:

uint64
sys_sync(void)
{
    800040f4:	1101                	addi	sp,sp,-32
    800040f6:	ec06                	sd	ra,24(sp)
    800040f8:	e822                	sd	s0,16(sp)
    800040fa:	e426                	sd	s1,8(sp)
    800040fc:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800040fe:	0001c497          	auipc	s1,0x1c
    80004102:	ab248493          	addi	s1,s1,-1358 # 8001fbb0 <log>
    80004106:	8526                	mv	a0,s1
    80004108:	a85fc0ef          	jal	80000b8c <acquire>
  if (log.committing || log.outstanding > 0) {
    8000410c:	509c                	lw	a5,32(s1)
    8000410e:	e799                	bnez	a5,8000411c <sys_sync+0x28>
    80004110:	0001c797          	auipc	a5,0x1c
    80004114:	abc7a783          	lw	a5,-1348(a5) # 8001fbcc <log+0x1c>
    80004118:	02f05a63          	blez	a5,8000414c <sys_sync+0x58>
    8000411c:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    8000411e:	0001c917          	auipc	s2,0x1c
    80004122:	aba92903          	lw	s2,-1350(s2) # 8001fbd8 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    80004126:	0001c497          	auipc	s1,0x1c
    8000412a:	a8a48493          	addi	s1,s1,-1398 # 8001fbb0 <log>
    8000412e:	8526                	mv	a0,s1
    80004130:	ed9fd0ef          	jal	80002008 <sleep_prepare>
      release(&log.lock);
    80004134:	8526                	mv	a0,s1
    80004136:	adffc0ef          	jal	80000c14 <release>
      sleep();
    8000413a:	f0bfd0ef          	jal	80002044 <sleep>
      acquire(&log.lock);
    8000413e:	8526                	mv	a0,s1
    80004140:	a4dfc0ef          	jal	80000b8c <acquire>
    while (log.ncommit < n) {
    80004144:	549c                	lw	a5,40(s1)
    80004146:	fef954e3          	bge	s2,a5,8000412e <sys_sync+0x3a>
    8000414a:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    8000414c:	0001c517          	auipc	a0,0x1c
    80004150:	a6450513          	addi	a0,a0,-1436 # 8001fbb0 <log>
    80004154:	ac1fc0ef          	jal	80000c14 <release>
  return 0;
}
    80004158:	4501                	li	a0,0
    8000415a:	60e2                	ld	ra,24(sp)
    8000415c:	6442                	ld	s0,16(sp)
    8000415e:	64a2                	ld	s1,8(sp)
    80004160:	6105                	addi	sp,sp,32
    80004162:	8082                	ret

0000000080004164 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004164:	1101                	addi	sp,sp,-32
    80004166:	ec06                	sd	ra,24(sp)
    80004168:	e822                	sd	s0,16(sp)
    8000416a:	e426                	sd	s1,8(sp)
    8000416c:	e04a                	sd	s2,0(sp)
    8000416e:	1000                	addi	s0,sp,32
    80004170:	84aa                	mv	s1,a0
    80004172:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004174:	00003597          	auipc	a1,0x3
    80004178:	42458593          	addi	a1,a1,1060 # 80007598 <etext+0x598>
    8000417c:	0521                	addi	a0,a0,8
    8000417e:	995fc0ef          	jal	80000b12 <initlock>
  lk->name = name;
    80004182:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004186:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000418a:	0204a423          	sw	zero,40(s1)
}
    8000418e:	60e2                	ld	ra,24(sp)
    80004190:	6442                	ld	s0,16(sp)
    80004192:	64a2                	ld	s1,8(sp)
    80004194:	6902                	ld	s2,0(sp)
    80004196:	6105                	addi	sp,sp,32
    80004198:	8082                	ret

000000008000419a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000419a:	1101                	addi	sp,sp,-32
    8000419c:	ec06                	sd	ra,24(sp)
    8000419e:	e822                	sd	s0,16(sp)
    800041a0:	e426                	sd	s1,8(sp)
    800041a2:	e04a                	sd	s2,0(sp)
    800041a4:	1000                	addi	s0,sp,32
    800041a6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800041a8:	00850913          	addi	s2,a0,8
    800041ac:	854a                	mv	a0,s2
    800041ae:	9dffc0ef          	jal	80000b8c <acquire>
  while (lk->locked) {
    800041b2:	409c                	lw	a5,0(s1)
    800041b4:	cf91                	beqz	a5,800041d0 <acquiresleep+0x36>
    sleep_prepare(lk);
    800041b6:	8526                	mv	a0,s1
    800041b8:	e51fd0ef          	jal	80002008 <sleep_prepare>
    release(&lk->lk);
    800041bc:	854a                	mv	a0,s2
    800041be:	a57fc0ef          	jal	80000c14 <release>
    sleep();
    800041c2:	e83fd0ef          	jal	80002044 <sleep>
    acquire(&lk->lk);
    800041c6:	854a                	mv	a0,s2
    800041c8:	9c5fc0ef          	jal	80000b8c <acquire>
  while (lk->locked) {
    800041cc:	409c                	lw	a5,0(s1)
    800041ce:	f7e5                	bnez	a5,800041b6 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800041d0:	4785                	li	a5,1
    800041d2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800041d4:	faafd0ef          	jal	8000197e <myproc>
    800041d8:	591c                	lw	a5,48(a0)
    800041da:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800041dc:	854a                	mv	a0,s2
    800041de:	a37fc0ef          	jal	80000c14 <release>
}
    800041e2:	60e2                	ld	ra,24(sp)
    800041e4:	6442                	ld	s0,16(sp)
    800041e6:	64a2                	ld	s1,8(sp)
    800041e8:	6902                	ld	s2,0(sp)
    800041ea:	6105                	addi	sp,sp,32
    800041ec:	8082                	ret

00000000800041ee <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800041ee:	1101                	addi	sp,sp,-32
    800041f0:	ec06                	sd	ra,24(sp)
    800041f2:	e822                	sd	s0,16(sp)
    800041f4:	e426                	sd	s1,8(sp)
    800041f6:	e04a                	sd	s2,0(sp)
    800041f8:	1000                	addi	s0,sp,32
    800041fa:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800041fc:	00850913          	addi	s2,a0,8
    80004200:	854a                	mv	a0,s2
    80004202:	98bfc0ef          	jal	80000b8c <acquire>
  lk->locked = 0;
    80004206:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000420a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000420e:	8526                	mv	a0,s1
    80004210:	e65fd0ef          	jal	80002074 <wakeup>
  release(&lk->lk);
    80004214:	854a                	mv	a0,s2
    80004216:	9fffc0ef          	jal	80000c14 <release>
}
    8000421a:	60e2                	ld	ra,24(sp)
    8000421c:	6442                	ld	s0,16(sp)
    8000421e:	64a2                	ld	s1,8(sp)
    80004220:	6902                	ld	s2,0(sp)
    80004222:	6105                	addi	sp,sp,32
    80004224:	8082                	ret

0000000080004226 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004226:	7179                	addi	sp,sp,-48
    80004228:	f406                	sd	ra,40(sp)
    8000422a:	f022                	sd	s0,32(sp)
    8000422c:	ec26                	sd	s1,24(sp)
    8000422e:	e84a                	sd	s2,16(sp)
    80004230:	1800                	addi	s0,sp,48
    80004232:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    80004234:	00850913          	addi	s2,a0,8
    80004238:	854a                	mv	a0,s2
    8000423a:	953fc0ef          	jal	80000b8c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000423e:	409c                	lw	a5,0(s1)
    80004240:	ef81                	bnez	a5,80004258 <holdingsleep+0x32>
    80004242:	4481                	li	s1,0
  release(&lk->lk);
    80004244:	854a                	mv	a0,s2
    80004246:	9cffc0ef          	jal	80000c14 <release>
  return r;
}
    8000424a:	8526                	mv	a0,s1
    8000424c:	70a2                	ld	ra,40(sp)
    8000424e:	7402                	ld	s0,32(sp)
    80004250:	64e2                	ld	s1,24(sp)
    80004252:	6942                	ld	s2,16(sp)
    80004254:	6145                	addi	sp,sp,48
    80004256:	8082                	ret
    80004258:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000425a:	0284a983          	lw	s3,40(s1)
    8000425e:	f20fd0ef          	jal	8000197e <myproc>
    80004262:	5904                	lw	s1,48(a0)
    80004264:	413484b3          	sub	s1,s1,s3
    80004268:	0014b493          	seqz	s1,s1
    8000426c:	69a2                	ld	s3,8(sp)
    8000426e:	bfd9                	j	80004244 <holdingsleep+0x1e>

0000000080004270 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004270:	1141                	addi	sp,sp,-16
    80004272:	e406                	sd	ra,8(sp)
    80004274:	e022                	sd	s0,0(sp)
    80004276:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004278:	00003597          	auipc	a1,0x3
    8000427c:	33058593          	addi	a1,a1,816 # 800075a8 <etext+0x5a8>
    80004280:	0001c517          	auipc	a0,0x1c
    80004284:	a7850513          	addi	a0,a0,-1416 # 8001fcf8 <ftable>
    80004288:	88bfc0ef          	jal	80000b12 <initlock>
}
    8000428c:	60a2                	ld	ra,8(sp)
    8000428e:	6402                	ld	s0,0(sp)
    80004290:	0141                	addi	sp,sp,16
    80004292:	8082                	ret

0000000080004294 <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    80004294:	1101                	addi	sp,sp,-32
    80004296:	ec06                	sd	ra,24(sp)
    80004298:	e822                	sd	s0,16(sp)
    8000429a:	e426                	sd	s1,8(sp)
    8000429c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000429e:	0001c517          	auipc	a0,0x1c
    800042a2:	a5a50513          	addi	a0,a0,-1446 # 8001fcf8 <ftable>
    800042a6:	8e7fc0ef          	jal	80000b8c <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    800042aa:	0001c497          	auipc	s1,0x1c
    800042ae:	a6648493          	addi	s1,s1,-1434 # 8001fd10 <ftable+0x18>
    800042b2:	0001d717          	auipc	a4,0x1d
    800042b6:	9fe70713          	addi	a4,a4,-1538 # 80020cb0 <disk>
    if (f->ref == 0) {
    800042ba:	40dc                	lw	a5,4(s1)
    800042bc:	cf89                	beqz	a5,800042d6 <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    800042be:	02848493          	addi	s1,s1,40
    800042c2:	fee49ce3          	bne	s1,a4,800042ba <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800042c6:	0001c517          	auipc	a0,0x1c
    800042ca:	a3250513          	addi	a0,a0,-1486 # 8001fcf8 <ftable>
    800042ce:	947fc0ef          	jal	80000c14 <release>
  return 0;
    800042d2:	4481                	li	s1,0
    800042d4:	a809                	j	800042e6 <filealloc+0x52>
      f->ref = 1;
    800042d6:	4785                	li	a5,1
    800042d8:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800042da:	0001c517          	auipc	a0,0x1c
    800042de:	a1e50513          	addi	a0,a0,-1506 # 8001fcf8 <ftable>
    800042e2:	933fc0ef          	jal	80000c14 <release>
}
    800042e6:	8526                	mv	a0,s1
    800042e8:	60e2                	ld	ra,24(sp)
    800042ea:	6442                	ld	s0,16(sp)
    800042ec:	64a2                	ld	s1,8(sp)
    800042ee:	6105                	addi	sp,sp,32
    800042f0:	8082                	ret

00000000800042f2 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    800042f2:	1101                	addi	sp,sp,-32
    800042f4:	ec06                	sd	ra,24(sp)
    800042f6:	e822                	sd	s0,16(sp)
    800042f8:	e426                	sd	s1,8(sp)
    800042fa:	1000                	addi	s0,sp,32
    800042fc:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800042fe:	0001c517          	auipc	a0,0x1c
    80004302:	9fa50513          	addi	a0,a0,-1542 # 8001fcf8 <ftable>
    80004306:	887fc0ef          	jal	80000b8c <acquire>
  if (f->ref < 1)
    8000430a:	40dc                	lw	a5,4(s1)
    8000430c:	02f05063          	blez	a5,8000432c <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004310:	2785                	addiw	a5,a5,1
    80004312:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004314:	0001c517          	auipc	a0,0x1c
    80004318:	9e450513          	addi	a0,a0,-1564 # 8001fcf8 <ftable>
    8000431c:	8f9fc0ef          	jal	80000c14 <release>
  return f;
}
    80004320:	8526                	mv	a0,s1
    80004322:	60e2                	ld	ra,24(sp)
    80004324:	6442                	ld	s0,16(sp)
    80004326:	64a2                	ld	s1,8(sp)
    80004328:	6105                	addi	sp,sp,32
    8000432a:	8082                	ret
    panic("filedup");
    8000432c:	00003517          	auipc	a0,0x3
    80004330:	28450513          	addi	a0,a0,644 # 800075b0 <etext+0x5b0>
    80004334:	cbafc0ef          	jal	800007ee <panic>

0000000080004338 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004338:	7139                	addi	sp,sp,-64
    8000433a:	fc06                	sd	ra,56(sp)
    8000433c:	f822                	sd	s0,48(sp)
    8000433e:	f426                	sd	s1,40(sp)
    80004340:	0080                	addi	s0,sp,64
    80004342:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004344:	0001c517          	auipc	a0,0x1c
    80004348:	9b450513          	addi	a0,a0,-1612 # 8001fcf8 <ftable>
    8000434c:	841fc0ef          	jal	80000b8c <acquire>
  if (f->ref < 1)
    80004350:	40dc                	lw	a5,4(s1)
    80004352:	04f05863          	blez	a5,800043a2 <fileclose+0x6a>
    panic("fileclose");
  if (--f->ref > 0) {
    80004356:	37fd                	addiw	a5,a5,-1
    80004358:	c0dc                	sw	a5,4(s1)
    8000435a:	04f04e63          	bgtz	a5,800043b6 <fileclose+0x7e>
    8000435e:	f04a                	sd	s2,32(sp)
    80004360:	ec4e                	sd	s3,24(sp)
    80004362:	e852                	sd	s4,16(sp)
    80004364:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004366:	0004a903          	lw	s2,0(s1)
    8000436a:	0094ca83          	lbu	s5,9(s1)
    8000436e:	0104ba03          	ld	s4,16(s1)
    80004372:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004376:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000437a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000437e:	0001c517          	auipc	a0,0x1c
    80004382:	97a50513          	addi	a0,a0,-1670 # 8001fcf8 <ftable>
    80004386:	88ffc0ef          	jal	80000c14 <release>

  if (ff.type == FD_PIPE) {
    8000438a:	4785                	li	a5,1
    8000438c:	04f90063          	beq	s2,a5,800043cc <fileclose+0x94>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    80004390:	3979                	addiw	s2,s2,-2
    80004392:	4785                	li	a5,1
    80004394:	0527f563          	bgeu	a5,s2,800043de <fileclose+0xa6>
    80004398:	7902                	ld	s2,32(sp)
    8000439a:	69e2                	ld	s3,24(sp)
    8000439c:	6a42                	ld	s4,16(sp)
    8000439e:	6aa2                	ld	s5,8(sp)
    800043a0:	a00d                	j	800043c2 <fileclose+0x8a>
    800043a2:	f04a                	sd	s2,32(sp)
    800043a4:	ec4e                	sd	s3,24(sp)
    800043a6:	e852                	sd	s4,16(sp)
    800043a8:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800043aa:	00003517          	auipc	a0,0x3
    800043ae:	20e50513          	addi	a0,a0,526 # 800075b8 <etext+0x5b8>
    800043b2:	c3cfc0ef          	jal	800007ee <panic>
    release(&ftable.lock);
    800043b6:	0001c517          	auipc	a0,0x1c
    800043ba:	94250513          	addi	a0,a0,-1726 # 8001fcf8 <ftable>
    800043be:	857fc0ef          	jal	80000c14 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800043c2:	70e2                	ld	ra,56(sp)
    800043c4:	7442                	ld	s0,48(sp)
    800043c6:	74a2                	ld	s1,40(sp)
    800043c8:	6121                	addi	sp,sp,64
    800043ca:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800043cc:	85d6                	mv	a1,s5
    800043ce:	8552                	mv	a0,s4
    800043d0:	356000ef          	jal	80004726 <pipeclose>
    800043d4:	7902                	ld	s2,32(sp)
    800043d6:	69e2                	ld	s3,24(sp)
    800043d8:	6a42                	ld	s4,16(sp)
    800043da:	6aa2                	ld	s5,8(sp)
    800043dc:	b7dd                	j	800043c2 <fileclose+0x8a>
    begin_op();
    800043de:	aa9ff0ef          	jal	80003e86 <begin_op>
    iput(ff.ip);
    800043e2:	854e                	mv	a0,s3
    800043e4:	9c2ff0ef          	jal	800035a6 <iput>
    end_op();
    800043e8:	b25ff0ef          	jal	80003f0c <end_op>
    800043ec:	7902                	ld	s2,32(sp)
    800043ee:	69e2                	ld	s3,24(sp)
    800043f0:	6a42                	ld	s4,16(sp)
    800043f2:	6aa2                	ld	s5,8(sp)
    800043f4:	b7f9                	j	800043c2 <fileclose+0x8a>

00000000800043f6 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800043f6:	715d                	addi	sp,sp,-80
    800043f8:	e486                	sd	ra,72(sp)
    800043fa:	e0a2                	sd	s0,64(sp)
    800043fc:	fc26                	sd	s1,56(sp)
    800043fe:	f44e                	sd	s3,40(sp)
    80004400:	0880                	addi	s0,sp,80
    80004402:	84aa                	mv	s1,a0
    80004404:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004406:	d78fd0ef          	jal	8000197e <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    8000440a:	409c                	lw	a5,0(s1)
    8000440c:	37f9                	addiw	a5,a5,-2
    8000440e:	4705                	li	a4,1
    80004410:	04f76463          	bltu	a4,a5,80004458 <filestat+0x62>
    80004414:	f84a                	sd	s2,48(sp)
    80004416:	f052                	sd	s4,32(sp)
    80004418:	892a                	mv	s2,a0
    ilock(f->ip);
    8000441a:	6c88                	ld	a0,24(s1)
    8000441c:	808ff0ef          	jal	80003424 <ilock>
    stati(f->ip, &st);
    80004420:	fb840a13          	addi	s4,s0,-72
    80004424:	85d2                	mv	a1,s4
    80004426:	6c88                	ld	a0,24(s1)
    80004428:	ba8ff0ef          	jal	800037d0 <stati>
    iunlock(f->ip);
    8000442c:	6c88                	ld	a0,24(s1)
    8000442e:	8a4ff0ef          	jal	800034d2 <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    80004432:	4761                	li	a4,24
    80004434:	86d2                	mv	a3,s4
    80004436:	864e                	mv	a2,s3
    80004438:	04893583          	ld	a1,72(s2)
    8000443c:	05093503          	ld	a0,80(s2)
    80004440:	9a0fd0ef          	jal	800015e0 <copyout>
    80004444:	41f5551b          	sraiw	a0,a0,0x1f
    80004448:	7942                	ld	s2,48(sp)
    8000444a:	7a02                	ld	s4,32(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000444c:	60a6                	ld	ra,72(sp)
    8000444e:	6406                	ld	s0,64(sp)
    80004450:	74e2                	ld	s1,56(sp)
    80004452:	79a2                	ld	s3,40(sp)
    80004454:	6161                	addi	sp,sp,80
    80004456:	8082                	ret
  return -1;
    80004458:	557d                	li	a0,-1
    8000445a:	bfcd                	j	8000444c <filestat+0x56>

000000008000445c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000445c:	7179                	addi	sp,sp,-48
    8000445e:	f406                	sd	ra,40(sp)
    80004460:	f022                	sd	s0,32(sp)
    80004462:	e84a                	sd	s2,16(sp)
    80004464:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    80004466:	00854783          	lbu	a5,8(a0)
    8000446a:	c3c5                	beqz	a5,8000450a <fileread+0xae>
    8000446c:	ec26                	sd	s1,24(sp)
    8000446e:	e44e                	sd	s3,8(sp)
    80004470:	84aa                	mv	s1,a0
    80004472:	89ae                	mv	s3,a1
    80004474:	8932                	mv	s2,a2
    80004476:	08064c63          	bltz	a2,8000450e <fileread+0xb2>
    return -1;

  if (f->type == FD_PIPE) {
    8000447a:	411c                	lw	a5,0(a0)
    8000447c:	4705                	li	a4,1
    8000447e:	04e78363          	beq	a5,a4,800044c4 <fileread+0x68>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    80004482:	470d                	li	a4,3
    80004484:	04e78763          	beq	a5,a4,800044d2 <fileread+0x76>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004488:	4709                	li	a4,2
    8000448a:	06e79a63          	bne	a5,a4,800044fe <fileread+0xa2>
    ilock(f->ip);
    8000448e:	6d08                	ld	a0,24(a0)
    80004490:	f95fe0ef          	jal	80003424 <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004494:	874a                	mv	a4,s2
    80004496:	5094                	lw	a3,32(s1)
    80004498:	864e                	mv	a2,s3
    8000449a:	4585                	li	a1,1
    8000449c:	6c88                	ld	a0,24(s1)
    8000449e:	b60ff0ef          	jal	800037fe <readi>
    800044a2:	892a                	mv	s2,a0
    800044a4:	00a05563          	blez	a0,800044ae <fileread+0x52>
      f->off += r;
    800044a8:	509c                	lw	a5,32(s1)
    800044aa:	9fa9                	addw	a5,a5,a0
    800044ac:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800044ae:	6c88                	ld	a0,24(s1)
    800044b0:	822ff0ef          	jal	800034d2 <iunlock>
    800044b4:	64e2                	ld	s1,24(sp)
    800044b6:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800044b8:	854a                	mv	a0,s2
    800044ba:	70a2                	ld	ra,40(sp)
    800044bc:	7402                	ld	s0,32(sp)
    800044be:	6942                	ld	s2,16(sp)
    800044c0:	6145                	addi	sp,sp,48
    800044c2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800044c4:	6908                	ld	a0,16(a0)
    800044c6:	3d4000ef          	jal	8000489a <piperead>
    800044ca:	892a                	mv	s2,a0
    800044cc:	64e2                	ld	s1,24(sp)
    800044ce:	69a2                	ld	s3,8(sp)
    800044d0:	b7e5                	j	800044b8 <fileread+0x5c>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800044d2:	02451783          	lh	a5,36(a0)
    800044d6:	03079693          	slli	a3,a5,0x30
    800044da:	92c1                	srli	a3,a3,0x30
    800044dc:	4725                	li	a4,9
    800044de:	02d76c63          	bltu	a4,a3,80004516 <fileread+0xba>
    800044e2:	0792                	slli	a5,a5,0x4
    800044e4:	0001b717          	auipc	a4,0x1b
    800044e8:	77470713          	addi	a4,a4,1908 # 8001fc58 <devsw>
    800044ec:	97ba                	add	a5,a5,a4
    800044ee:	639c                	ld	a5,0(a5)
    800044f0:	c79d                	beqz	a5,8000451e <fileread+0xc2>
    r = devsw[f->major].read(1, addr, n);
    800044f2:	4505                	li	a0,1
    800044f4:	9782                	jalr	a5
    800044f6:	892a                	mv	s2,a0
    800044f8:	64e2                	ld	s1,24(sp)
    800044fa:	69a2                	ld	s3,8(sp)
    800044fc:	bf75                	j	800044b8 <fileread+0x5c>
    panic("fileread");
    800044fe:	00003517          	auipc	a0,0x3
    80004502:	0ca50513          	addi	a0,a0,202 # 800075c8 <etext+0x5c8>
    80004506:	ae8fc0ef          	jal	800007ee <panic>
    return -1;
    8000450a:	597d                	li	s2,-1
    8000450c:	b775                	j	800044b8 <fileread+0x5c>
    8000450e:	597d                	li	s2,-1
    80004510:	64e2                	ld	s1,24(sp)
    80004512:	69a2                	ld	s3,8(sp)
    80004514:	b755                	j	800044b8 <fileread+0x5c>
      return -1;
    80004516:	597d                	li	s2,-1
    80004518:	64e2                	ld	s1,24(sp)
    8000451a:	69a2                	ld	s3,8(sp)
    8000451c:	bf71                	j	800044b8 <fileread+0x5c>
    8000451e:	597d                	li	s2,-1
    80004520:	64e2                	ld	s1,24(sp)
    80004522:	69a2                	ld	s3,8(sp)
    80004524:	bf51                	j	800044b8 <fileread+0x5c>

0000000080004526 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    80004526:	00954783          	lbu	a5,9(a0)
    8000452a:	10078863          	beqz	a5,8000463a <filewrite+0x114>
{
    8000452e:	711d                	addi	sp,sp,-96
    80004530:	ec86                	sd	ra,88(sp)
    80004532:	e8a2                	sd	s0,80(sp)
    80004534:	e0ca                	sd	s2,64(sp)
    80004536:	f456                	sd	s5,40(sp)
    80004538:	f05a                	sd	s6,32(sp)
    8000453a:	1080                	addi	s0,sp,96
    8000453c:	892a                	mv	s2,a0
    8000453e:	8b2e                	mv	s6,a1
    80004540:	8ab2                	mv	s5,a2
  if (f->writable == 0 || n < 0)
    80004542:	0e064e63          	bltz	a2,8000463e <filewrite+0x118>
    return -1;

  if (f->type == FD_PIPE) {
    80004546:	411c                	lw	a5,0(a0)
    80004548:	4705                	li	a4,1
    8000454a:	02e78963          	beq	a5,a4,8000457c <filewrite+0x56>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    8000454e:	470d                	li	a4,3
    80004550:	02e78a63          	beq	a5,a4,80004584 <filewrite+0x5e>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004554:	4709                	li	a4,2
    80004556:	0ce79663          	bne	a5,a4,80004622 <filewrite+0xfc>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    8000455a:	0ec05863          	blez	a2,8000464a <filewrite+0x124>
    8000455e:	e4a6                	sd	s1,72(sp)
    80004560:	fc4e                	sd	s3,56(sp)
    80004562:	f852                	sd	s4,48(sp)
    80004564:	ec5e                	sd	s7,24(sp)
    80004566:	e862                	sd	s8,16(sp)
    80004568:	e466                	sd	s9,8(sp)
    int i = 0;
    8000456a:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    8000456c:	6b85                	lui	s7,0x1
    8000456e:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004572:	6c85                	lui	s9,0x1
    80004574:	c00c8c9b          	addiw	s9,s9,-1024 # c00 <_entry-0x7ffff400>
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004578:	4c05                	li	s8,1
    8000457a:	a8ad                	j	800045f4 <filewrite+0xce>
    ret = pipewrite(f->pipe, addr, n);
    8000457c:	6908                	ld	a0,16(a0)
    8000457e:	200000ef          	jal	8000477e <pipewrite>
    80004582:	a849                	j	80004614 <filewrite+0xee>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004584:	02451783          	lh	a5,36(a0)
    80004588:	03079693          	slli	a3,a5,0x30
    8000458c:	92c1                	srli	a3,a3,0x30
    8000458e:	4725                	li	a4,9
    80004590:	0ad76963          	bltu	a4,a3,80004642 <filewrite+0x11c>
    80004594:	0792                	slli	a5,a5,0x4
    80004596:	0001b717          	auipc	a4,0x1b
    8000459a:	6c270713          	addi	a4,a4,1730 # 8001fc58 <devsw>
    8000459e:	97ba                	add	a5,a5,a4
    800045a0:	679c                	ld	a5,8(a5)
    800045a2:	c3d5                	beqz	a5,80004646 <filewrite+0x120>
    ret = devsw[f->major].write(1, addr, n);
    800045a4:	4505                	li	a0,1
    800045a6:	9782                	jalr	a5
    800045a8:	a0b5                	j	80004614 <filewrite+0xee>
      if (n1 > max)
    800045aa:	2981                	sext.w	s3,s3
      begin_op();
    800045ac:	8dbff0ef          	jal	80003e86 <begin_op>
      ilock(f->ip);
    800045b0:	01893503          	ld	a0,24(s2)
    800045b4:	e71fe0ef          	jal	80003424 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800045b8:	874e                	mv	a4,s3
    800045ba:	02092683          	lw	a3,32(s2)
    800045be:	016a0633          	add	a2,s4,s6
    800045c2:	85e2                	mv	a1,s8
    800045c4:	01893503          	ld	a0,24(s2)
    800045c8:	b28ff0ef          	jal	800038f0 <writei>
    800045cc:	84aa                	mv	s1,a0
    800045ce:	00a05763          	blez	a0,800045dc <filewrite+0xb6>
        f->off += r;
    800045d2:	02092783          	lw	a5,32(s2)
    800045d6:	9fa9                	addw	a5,a5,a0
    800045d8:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800045dc:	01893503          	ld	a0,24(s2)
    800045e0:	ef3fe0ef          	jal	800034d2 <iunlock>
      end_op();
    800045e4:	929ff0ef          	jal	80003f0c <end_op>

      if (r != n1) {
    800045e8:	00999d63          	bne	s3,s1,80004602 <filewrite+0xdc>
        // error from writei
        break;
      }
      i += r;
    800045ec:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    800045f0:	015a5963          	bge	s4,s5,80004602 <filewrite+0xdc>
      int n1 = n - i;
    800045f4:	414a87bb          	subw	a5,s5,s4
    800045f8:	89be                	mv	s3,a5
      if (n1 > max)
    800045fa:	fafbd8e3          	bge	s7,a5,800045aa <filewrite+0x84>
    800045fe:	89e6                	mv	s3,s9
    80004600:	b76d                	j	800045aa <filewrite+0x84>
    }
    ret = (i == n ? n : -1);
    80004602:	054a9663          	bne	s5,s4,8000464e <filewrite+0x128>
    80004606:	8556                	mv	a0,s5
    80004608:	64a6                	ld	s1,72(sp)
    8000460a:	79e2                	ld	s3,56(sp)
    8000460c:	7a42                	ld	s4,48(sp)
    8000460e:	6be2                	ld	s7,24(sp)
    80004610:	6c42                	ld	s8,16(sp)
    80004612:	6ca2                	ld	s9,8(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004614:	60e6                	ld	ra,88(sp)
    80004616:	6446                	ld	s0,80(sp)
    80004618:	6906                	ld	s2,64(sp)
    8000461a:	7aa2                	ld	s5,40(sp)
    8000461c:	7b02                	ld	s6,32(sp)
    8000461e:	6125                	addi	sp,sp,96
    80004620:	8082                	ret
    80004622:	e4a6                	sd	s1,72(sp)
    80004624:	fc4e                	sd	s3,56(sp)
    80004626:	f852                	sd	s4,48(sp)
    80004628:	ec5e                	sd	s7,24(sp)
    8000462a:	e862                	sd	s8,16(sp)
    8000462c:	e466                	sd	s9,8(sp)
    panic("filewrite");
    8000462e:	00003517          	auipc	a0,0x3
    80004632:	faa50513          	addi	a0,a0,-86 # 800075d8 <etext+0x5d8>
    80004636:	9b8fc0ef          	jal	800007ee <panic>
    return -1;
    8000463a:	557d                	li	a0,-1
}
    8000463c:	8082                	ret
    return -1;
    8000463e:	557d                	li	a0,-1
    80004640:	bfd1                	j	80004614 <filewrite+0xee>
      return -1;
    80004642:	557d                	li	a0,-1
    80004644:	bfc1                	j	80004614 <filewrite+0xee>
    80004646:	557d                	li	a0,-1
    80004648:	b7f1                	j	80004614 <filewrite+0xee>
    ret = (i == n ? n : -1);
    8000464a:	8532                	mv	a0,a2
    8000464c:	b7e1                	j	80004614 <filewrite+0xee>
    8000464e:	557d                	li	a0,-1
    80004650:	64a6                	ld	s1,72(sp)
    80004652:	79e2                	ld	s3,56(sp)
    80004654:	7a42                	ld	s4,48(sp)
    80004656:	6be2                	ld	s7,24(sp)
    80004658:	6c42                	ld	s8,16(sp)
    8000465a:	6ca2                	ld	s9,8(sp)
    8000465c:	bf65                	j	80004614 <filewrite+0xee>

000000008000465e <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000465e:	7179                	addi	sp,sp,-48
    80004660:	f406                	sd	ra,40(sp)
    80004662:	f022                	sd	s0,32(sp)
    80004664:	ec26                	sd	s1,24(sp)
    80004666:	e052                	sd	s4,0(sp)
    80004668:	1800                	addi	s0,sp,48
    8000466a:	84aa                	mv	s1,a0
    8000466c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000466e:	0005b023          	sd	zero,0(a1)
    80004672:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004676:	c1fff0ef          	jal	80004294 <filealloc>
    8000467a:	e088                	sd	a0,0(s1)
    8000467c:	c549                	beqz	a0,80004706 <pipealloc+0xa8>
    8000467e:	c17ff0ef          	jal	80004294 <filealloc>
    80004682:	00aa3023          	sd	a0,0(s4)
    80004686:	cd25                	beqz	a0,800046fe <pipealloc+0xa0>
    80004688:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    8000468a:	c38fc0ef          	jal	80000ac2 <kalloc>
    8000468e:	892a                	mv	s2,a0
    80004690:	c12d                	beqz	a0,800046f2 <pipealloc+0x94>
    80004692:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004694:	4985                	li	s3,1
    80004696:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000469a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000469e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800046a2:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800046a6:	00003597          	auipc	a1,0x3
    800046aa:	f4258593          	addi	a1,a1,-190 # 800075e8 <etext+0x5e8>
    800046ae:	c64fc0ef          	jal	80000b12 <initlock>
  (*f0)->type = FD_PIPE;
    800046b2:	609c                	ld	a5,0(s1)
    800046b4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800046b8:	609c                	ld	a5,0(s1)
    800046ba:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800046be:	609c                	ld	a5,0(s1)
    800046c0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800046c4:	609c                	ld	a5,0(s1)
    800046c6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800046ca:	000a3783          	ld	a5,0(s4)
    800046ce:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800046d2:	000a3783          	ld	a5,0(s4)
    800046d6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800046da:	000a3783          	ld	a5,0(s4)
    800046de:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800046e2:	000a3783          	ld	a5,0(s4)
    800046e6:	0127b823          	sd	s2,16(a5)
  return 0;
    800046ea:	4501                	li	a0,0
    800046ec:	6942                	ld	s2,16(sp)
    800046ee:	69a2                	ld	s3,8(sp)
    800046f0:	a01d                	j	80004716 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    800046f2:	6088                	ld	a0,0(s1)
    800046f4:	c119                	beqz	a0,800046fa <pipealloc+0x9c>
    800046f6:	6942                	ld	s2,16(sp)
    800046f8:	a029                	j	80004702 <pipealloc+0xa4>
    800046fa:	6942                	ld	s2,16(sp)
    800046fc:	a029                	j	80004706 <pipealloc+0xa8>
    800046fe:	6088                	ld	a0,0(s1)
    80004700:	c10d                	beqz	a0,80004722 <pipealloc+0xc4>
    fileclose(*f0);
    80004702:	c37ff0ef          	jal	80004338 <fileclose>
  if (*f1)
    80004706:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000470a:	557d                	li	a0,-1
  if (*f1)
    8000470c:	c789                	beqz	a5,80004716 <pipealloc+0xb8>
    fileclose(*f1);
    8000470e:	853e                	mv	a0,a5
    80004710:	c29ff0ef          	jal	80004338 <fileclose>
  return -1;
    80004714:	557d                	li	a0,-1
}
    80004716:	70a2                	ld	ra,40(sp)
    80004718:	7402                	ld	s0,32(sp)
    8000471a:	64e2                	ld	s1,24(sp)
    8000471c:	6a02                	ld	s4,0(sp)
    8000471e:	6145                	addi	sp,sp,48
    80004720:	8082                	ret
  return -1;
    80004722:	557d                	li	a0,-1
    80004724:	bfcd                	j	80004716 <pipealloc+0xb8>

0000000080004726 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004726:	1101                	addi	sp,sp,-32
    80004728:	ec06                	sd	ra,24(sp)
    8000472a:	e822                	sd	s0,16(sp)
    8000472c:	e426                	sd	s1,8(sp)
    8000472e:	e04a                	sd	s2,0(sp)
    80004730:	1000                	addi	s0,sp,32
    80004732:	84aa                	mv	s1,a0
    80004734:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004736:	c56fc0ef          	jal	80000b8c <acquire>
  if (writable) {
    8000473a:	02090763          	beqz	s2,80004768 <pipeclose+0x42>
    pi->writeopen = 0;
    8000473e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004742:	21848513          	addi	a0,s1,536
    80004746:	92ffd0ef          	jal	80002074 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    8000474a:	2204b783          	ld	a5,544(s1)
    8000474e:	e785                	bnez	a5,80004776 <pipeclose+0x50>
    release(&pi->lock);
    80004750:	8526                	mv	a0,s1
    80004752:	cc2fc0ef          	jal	80000c14 <release>
    kfree((char *)pi);
    80004756:	8526                	mv	a0,s1
    80004758:	a88fc0ef          	jal	800009e0 <kfree>
  } else
    release(&pi->lock);
}
    8000475c:	60e2                	ld	ra,24(sp)
    8000475e:	6442                	ld	s0,16(sp)
    80004760:	64a2                	ld	s1,8(sp)
    80004762:	6902                	ld	s2,0(sp)
    80004764:	6105                	addi	sp,sp,32
    80004766:	8082                	ret
    pi->readopen = 0;
    80004768:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000476c:	21c48513          	addi	a0,s1,540
    80004770:	905fd0ef          	jal	80002074 <wakeup>
    80004774:	bfd9                	j	8000474a <pipeclose+0x24>
    release(&pi->lock);
    80004776:	8526                	mv	a0,s1
    80004778:	c9cfc0ef          	jal	80000c14 <release>
}
    8000477c:	b7c5                	j	8000475c <pipeclose+0x36>

000000008000477e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000477e:	7159                	addi	sp,sp,-112
    80004780:	f486                	sd	ra,104(sp)
    80004782:	f0a2                	sd	s0,96(sp)
    80004784:	eca6                	sd	s1,88(sp)
    80004786:	e8ca                	sd	s2,80(sp)
    80004788:	e4ce                	sd	s3,72(sp)
    8000478a:	e0d2                	sd	s4,64(sp)
    8000478c:	fc56                	sd	s5,56(sp)
    8000478e:	1880                	addi	s0,sp,112
    80004790:	84aa                	mv	s1,a0
    80004792:	8aae                	mv	s5,a1
    80004794:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004796:	9e8fd0ef          	jal	8000197e <myproc>
    8000479a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000479c:	8526                	mv	a0,s1
    8000479e:	beefc0ef          	jal	80000b8c <acquire>
  while (i < n) {
    800047a2:	0f405a63          	blez	s4,80004896 <pipewrite+0x118>
    800047a6:	f85a                	sd	s6,48(sp)
    800047a8:	f45e                	sd	s7,40(sp)
    800047aa:	f062                	sd	s8,32(sp)
    800047ac:	ec66                	sd	s9,24(sp)
    800047ae:	e86a                	sd	s10,16(sp)
  int i = 0;
    800047b0:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    800047b2:	f9f40c13          	addi	s8,s0,-97
    800047b6:	4b85                	li	s7,1
    800047b8:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800047ba:	21848d13          	addi	s10,s1,536
      sleep_prepare(&pi->nwrite);
    800047be:	21c48c93          	addi	s9,s1,540
    800047c2:	a0a1                	j	8000480a <pipewrite+0x8c>
      release(&pi->lock);
    800047c4:	8526                	mv	a0,s1
    800047c6:	c4efc0ef          	jal	80000c14 <release>
      return -1;
    800047ca:	597d                	li	s2,-1
    800047cc:	7b42                	ld	s6,48(sp)
    800047ce:	7ba2                	ld	s7,40(sp)
    800047d0:	7c02                	ld	s8,32(sp)
    800047d2:	6ce2                	ld	s9,24(sp)
    800047d4:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800047d6:	854a                	mv	a0,s2
    800047d8:	70a6                	ld	ra,104(sp)
    800047da:	7406                	ld	s0,96(sp)
    800047dc:	64e6                	ld	s1,88(sp)
    800047de:	6946                	ld	s2,80(sp)
    800047e0:	69a6                	ld	s3,72(sp)
    800047e2:	6a06                	ld	s4,64(sp)
    800047e4:	7ae2                	ld	s5,56(sp)
    800047e6:	6165                	addi	sp,sp,112
    800047e8:	8082                	ret
      wakeup(&pi->nread);
    800047ea:	856a                	mv	a0,s10
    800047ec:	889fd0ef          	jal	80002074 <wakeup>
      sleep_prepare(&pi->nwrite);
    800047f0:	8566                	mv	a0,s9
    800047f2:	817fd0ef          	jal	80002008 <sleep_prepare>
      release(&pi->lock);
    800047f6:	8526                	mv	a0,s1
    800047f8:	c1cfc0ef          	jal	80000c14 <release>
      sleep();
    800047fc:	849fd0ef          	jal	80002044 <sleep>
      acquire(&pi->lock);
    80004800:	8526                	mv	a0,s1
    80004802:	b8afc0ef          	jal	80000b8c <acquire>
  while (i < n) {
    80004806:	07495b63          	bge	s2,s4,8000487c <pipewrite+0xfe>
    if (pi->readopen == 0 || killed(pr)) {
    8000480a:	2204a783          	lw	a5,544(s1)
    8000480e:	dbdd                	beqz	a5,800047c4 <pipewrite+0x46>
    80004810:	854e                	mv	a0,s3
    80004812:	a51fd0ef          	jal	80002262 <killed>
    80004816:	f55d                	bnez	a0,800047c4 <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    80004818:	2184a783          	lw	a5,536(s1)
    8000481c:	21c4a703          	lw	a4,540(s1)
    80004820:	2007879b          	addiw	a5,a5,512
    80004824:	fcf703e3          	beq	a4,a5,800047ea <pipewrite+0x6c>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004828:	875e                	mv	a4,s7
    8000482a:	015906b3          	add	a3,s2,s5
    8000482e:	8662                	mv	a2,s8
    80004830:	0489b583          	ld	a1,72(s3)
    80004834:	0509b503          	ld	a0,80(s3)
    80004838:	e6ffc0ef          	jal	800016a6 <copyin>
    8000483c:	03650163          	beq	a0,s6,8000485e <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004840:	21c4a783          	lw	a5,540(s1)
    80004844:	0017871b          	addiw	a4,a5,1
    80004848:	20e4ae23          	sw	a4,540(s1)
    8000484c:	1ff7f793          	andi	a5,a5,511
    80004850:	97a6                	add	a5,a5,s1
    80004852:	f9f44703          	lbu	a4,-97(s0)
    80004856:	00e78c23          	sb	a4,24(a5)
      i++;
    8000485a:	2905                	addiw	s2,s2,1
    8000485c:	b76d                	j	80004806 <pipewrite+0x88>
        if (i == 0)
    8000485e:	00090863          	beqz	s2,8000486e <pipewrite+0xf0>
    80004862:	7b42                	ld	s6,48(sp)
    80004864:	7ba2                	ld	s7,40(sp)
    80004866:	7c02                	ld	s8,32(sp)
    80004868:	6ce2                	ld	s9,24(sp)
    8000486a:	6d42                	ld	s10,16(sp)
    8000486c:	a829                	j	80004886 <pipewrite+0x108>
          i = -1;
    8000486e:	892a                	mv	s2,a0
        break;
    80004870:	7b42                	ld	s6,48(sp)
    80004872:	7ba2                	ld	s7,40(sp)
    80004874:	7c02                	ld	s8,32(sp)
    80004876:	6ce2                	ld	s9,24(sp)
    80004878:	6d42                	ld	s10,16(sp)
    8000487a:	a031                	j	80004886 <pipewrite+0x108>
    8000487c:	7b42                	ld	s6,48(sp)
    8000487e:	7ba2                	ld	s7,40(sp)
    80004880:	7c02                	ld	s8,32(sp)
    80004882:	6ce2                	ld	s9,24(sp)
    80004884:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004886:	21848513          	addi	a0,s1,536
    8000488a:	feafd0ef          	jal	80002074 <wakeup>
  release(&pi->lock);
    8000488e:	8526                	mv	a0,s1
    80004890:	b84fc0ef          	jal	80000c14 <release>
  return i;
    80004894:	b789                	j	800047d6 <pipewrite+0x58>
  int i = 0;
    80004896:	4901                	li	s2,0
    80004898:	b7fd                	j	80004886 <pipewrite+0x108>

000000008000489a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000489a:	711d                	addi	sp,sp,-96
    8000489c:	ec86                	sd	ra,88(sp)
    8000489e:	e8a2                	sd	s0,80(sp)
    800048a0:	e4a6                	sd	s1,72(sp)
    800048a2:	e0ca                	sd	s2,64(sp)
    800048a4:	fc4e                	sd	s3,56(sp)
    800048a6:	f852                	sd	s4,48(sp)
    800048a8:	f456                	sd	s5,40(sp)
    800048aa:	1080                	addi	s0,sp,96
    800048ac:	84aa                	mv	s1,a0
    800048ae:	89ae                	mv	s3,a1
    800048b0:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800048b2:	8ccfd0ef          	jal	8000197e <myproc>
    800048b6:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    800048b8:	8526                	mv	a0,s1
    800048ba:	ad2fc0ef          	jal	80000b8c <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800048be:	2184a703          	lw	a4,536(s1)
    800048c2:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    800048c6:	21848a13          	addi	s4,s1,536
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800048ca:	02f71e63          	bne	a4,a5,80004906 <piperead+0x6c>
    800048ce:	2244a783          	lw	a5,548(s1)
    800048d2:	c3b9                	beqz	a5,80004918 <piperead+0x7e>
    if (killed(pr)) {
    800048d4:	854a                	mv	a0,s2
    800048d6:	98dfd0ef          	jal	80002262 <killed>
    800048da:	e915                	bnez	a0,8000490e <piperead+0x74>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    800048dc:	8552                	mv	a0,s4
    800048de:	f2afd0ef          	jal	80002008 <sleep_prepare>
    release(&pi->lock);
    800048e2:	8526                	mv	a0,s1
    800048e4:	b30fc0ef          	jal	80000c14 <release>
    sleep();
    800048e8:	f5cfd0ef          	jal	80002044 <sleep>
    acquire(&pi->lock);
    800048ec:	8526                	mv	a0,s1
    800048ee:	a9efc0ef          	jal	80000b8c <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800048f2:	2184a703          	lw	a4,536(s1)
    800048f6:	21c4a783          	lw	a5,540(s1)
    800048fa:	fcf70ae3          	beq	a4,a5,800048ce <piperead+0x34>
    800048fe:	f05a                	sd	s6,32(sp)
    80004900:	ec5e                	sd	s7,24(sp)
    80004902:	e862                	sd	s8,16(sp)
    80004904:	a829                	j	8000491e <piperead+0x84>
    80004906:	f05a                	sd	s6,32(sp)
    80004908:	ec5e                	sd	s7,24(sp)
    8000490a:	e862                	sd	s8,16(sp)
    8000490c:	a809                	j	8000491e <piperead+0x84>
      release(&pi->lock);
    8000490e:	8526                	mv	a0,s1
    80004910:	b04fc0ef          	jal	80000c14 <release>
      return -1;
    80004914:	5a7d                	li	s4,-1
    80004916:	a0bd                	j	80004984 <piperead+0xea>
    80004918:	f05a                	sd	s6,32(sp)
    8000491a:	ec5e                	sd	s7,24(sp)
    8000491c:	e862                	sd	s8,16(sp)
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    8000491e:	4a01                	li	s4,0
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004920:	faf40c13          	addi	s8,s0,-81
    80004924:	4b85                	li	s7,1
    80004926:	5b7d                	li	s6,-1
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004928:	05505463          	blez	s5,80004970 <piperead+0xd6>
    if (pi->nread == pi->nwrite)
    8000492c:	2184a783          	lw	a5,536(s1)
    80004930:	21c4a703          	lw	a4,540(s1)
    80004934:	02f70e63          	beq	a4,a5,80004970 <piperead+0xd6>
    ch = pi->data[pi->nread % PIPESIZE];
    80004938:	1ff7f793          	andi	a5,a5,511
    8000493c:	97a6                	add	a5,a5,s1
    8000493e:	0187c783          	lbu	a5,24(a5)
    80004942:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004946:	875e                	mv	a4,s7
    80004948:	86e2                	mv	a3,s8
    8000494a:	864e                	mv	a2,s3
    8000494c:	04893583          	ld	a1,72(s2)
    80004950:	05093503          	ld	a0,80(s2)
    80004954:	c8dfc0ef          	jal	800015e0 <copyout>
    80004958:	05650063          	beq	a0,s6,80004998 <piperead+0xfe>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    8000495c:	2184a783          	lw	a5,536(s1)
    80004960:	2785                	addiw	a5,a5,1
    80004962:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004966:	2a05                	addiw	s4,s4,1
    80004968:	0985                	addi	s3,s3,1
    8000496a:	fd4a91e3          	bne	s5,s4,8000492c <piperead+0x92>
    8000496e:	8a56                	mv	s4,s5
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    80004970:	21c48513          	addi	a0,s1,540
    80004974:	f00fd0ef          	jal	80002074 <wakeup>
  release(&pi->lock);
    80004978:	8526                	mv	a0,s1
    8000497a:	a9afc0ef          	jal	80000c14 <release>
    8000497e:	7b02                	ld	s6,32(sp)
    80004980:	6be2                	ld	s7,24(sp)
    80004982:	6c42                	ld	s8,16(sp)
  return i;
}
    80004984:	8552                	mv	a0,s4
    80004986:	60e6                	ld	ra,88(sp)
    80004988:	6446                	ld	s0,80(sp)
    8000498a:	64a6                	ld	s1,72(sp)
    8000498c:	6906                	ld	s2,64(sp)
    8000498e:	79e2                	ld	s3,56(sp)
    80004990:	7a42                	ld	s4,48(sp)
    80004992:	7aa2                	ld	s5,40(sp)
    80004994:	6125                	addi	sp,sp,96
    80004996:	8082                	ret
      if (i == 0)
    80004998:	fc0a1ce3          	bnez	s4,80004970 <piperead+0xd6>
        i = -1;
    8000499c:	8a2a                	mv	s4,a0
    8000499e:	bfc9                	j	80004970 <piperead+0xd6>

00000000800049a0 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    800049a0:	1141                	addi	sp,sp,-16
    800049a2:	e406                	sd	ra,8(sp)
    800049a4:	e022                	sd	s0,0(sp)
    800049a6:	0800                	addi	s0,sp,16
    800049a8:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    800049aa:	0035151b          	slliw	a0,a0,0x3
    800049ae:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    800049b0:	8b89                	andi	a5,a5,2
    800049b2:	c399                	beqz	a5,800049b8 <flags2perm+0x18>
    perm |= PTE_W;
    800049b4:	00456513          	ori	a0,a0,4
  return perm;
}
    800049b8:	60a2                	ld	ra,8(sp)
    800049ba:	6402                	ld	s0,0(sp)
    800049bc:	0141                	addi	sp,sp,16
    800049be:	8082                	ret

00000000800049c0 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800049c0:	de010113          	addi	sp,sp,-544
    800049c4:	20113c23          	sd	ra,536(sp)
    800049c8:	20813823          	sd	s0,528(sp)
    800049cc:	20913423          	sd	s1,520(sp)
    800049d0:	21213023          	sd	s2,512(sp)
    800049d4:	1400                	addi	s0,sp,544
    800049d6:	892a                	mv	s2,a0
    800049d8:	dea43823          	sd	a0,-528(s0)
    800049dc:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800049e0:	f9ffc0ef          	jal	8000197e <myproc>
    800049e4:	84aa                	mv	s1,a0

  begin_op();
    800049e6:	ca0ff0ef          	jal	80003e86 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    800049ea:	854a                	mv	a0,s2
    800049ec:	ac0ff0ef          	jal	80003cac <namei>
    800049f0:	cd21                	beqz	a0,80004a48 <kexec+0x88>
    800049f2:	fbd2                	sd	s4,496(sp)
    800049f4:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800049f6:	a2ffe0ef          	jal	80003424 <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800049fa:	04000713          	li	a4,64
    800049fe:	4681                	li	a3,0
    80004a00:	e5040613          	addi	a2,s0,-432
    80004a04:	4581                	li	a1,0
    80004a06:	8552                	mv	a0,s4
    80004a08:	df7fe0ef          	jal	800037fe <readi>
    80004a0c:	04000793          	li	a5,64
    80004a10:	00f51a63          	bne	a0,a5,80004a24 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    80004a14:	e5042703          	lw	a4,-432(s0)
    80004a18:	464c47b7          	lui	a5,0x464c4
    80004a1c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004a20:	02f70863          	beq	a4,a5,80004a50 <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    80004a24:	8552                	mv	a0,s4
    80004a26:	c51fe0ef          	jal	80003676 <iunlockput>
    end_op();
    80004a2a:	ce2ff0ef          	jal	80003f0c <end_op>
  }
  return -1;
    80004a2e:	557d                	li	a0,-1
    80004a30:	7a5e                	ld	s4,496(sp)
}
    80004a32:	21813083          	ld	ra,536(sp)
    80004a36:	21013403          	ld	s0,528(sp)
    80004a3a:	20813483          	ld	s1,520(sp)
    80004a3e:	20013903          	ld	s2,512(sp)
    80004a42:	22010113          	addi	sp,sp,544
    80004a46:	8082                	ret
    end_op();
    80004a48:	cc4ff0ef          	jal	80003f0c <end_op>
    return -1;
    80004a4c:	557d                	li	a0,-1
    80004a4e:	b7d5                	j	80004a32 <kexec+0x72>
    80004a50:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80004a52:	8526                	mv	a0,s1
    80004a54:	82cfd0ef          	jal	80001a80 <proc_pagetable>
    80004a58:	8b2a                	mv	s6,a0
    80004a5a:	26050c63          	beqz	a0,80004cd2 <kexec+0x312>
    80004a5e:	ffce                	sd	s3,504(sp)
    80004a60:	f7d6                	sd	s5,488(sp)
    80004a62:	efde                	sd	s7,472(sp)
    80004a64:	ebe2                	sd	s8,464(sp)
    80004a66:	e7e6                	sd	s9,456(sp)
    80004a68:	e3ea                	sd	s10,448(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004a6a:	e7042683          	lw	a3,-400(s0)
    80004a6e:	e8845783          	lhu	a5,-376(s0)
    80004a72:	14078063          	beqz	a5,80004bb2 <kexec+0x1f2>
    80004a76:	ff6e                	sd	s11,440(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a78:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004a7a:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a7c:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    80004a80:	6c85                	lui	s9,0x1
    80004a82:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004a86:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    80004a8a:	6a85                	lui	s5,0x1
    80004a8c:	a085                	j	80004aec <kexec+0x12c>
      panic("loadseg: address should exist");
    80004a8e:	00003517          	auipc	a0,0x3
    80004a92:	b6250513          	addi	a0,a0,-1182 # 800075f0 <etext+0x5f0>
    80004a96:	d59fb0ef          	jal	800007ee <panic>
    if (sz - i < PGSIZE)
    80004a9a:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004a9c:	874a                	mv	a4,s2
    80004a9e:	009c06bb          	addw	a3,s8,s1
    80004aa2:	4581                	li	a1,0
    80004aa4:	8552                	mv	a0,s4
    80004aa6:	d59fe0ef          	jal	800037fe <readi>
    80004aaa:	22a91c63          	bne	s2,a0,80004ce2 <kexec+0x322>
  for (i = 0; i < sz; i += PGSIZE) {
    80004aae:	009a84bb          	addw	s1,s5,s1
    80004ab2:	0334f263          	bgeu	s1,s3,80004ad6 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004ab6:	02049593          	slli	a1,s1,0x20
    80004aba:	9181                	srli	a1,a1,0x20
    80004abc:	95de                	add	a1,a1,s7
    80004abe:	855a                	mv	a0,s6
    80004ac0:	d72fc0ef          	jal	80001032 <walkaddr>
    80004ac4:	862a                	mv	a2,a0
    if (pa == 0)
    80004ac6:	d561                	beqz	a0,80004a8e <kexec+0xce>
    if (sz - i < PGSIZE)
    80004ac8:	409987bb          	subw	a5,s3,s1
    80004acc:	893e                	mv	s2,a5
    80004ace:	fcfcf6e3          	bgeu	s9,a5,80004a9a <kexec+0xda>
    80004ad2:	8956                	mv	s2,s5
    80004ad4:	b7d9                	j	80004a9a <kexec+0xda>
    sz = sz1;
    80004ad6:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004ada:	2d05                	addiw	s10,s10,1
    80004adc:	e0843783          	ld	a5,-504(s0)
    80004ae0:	0387869b          	addiw	a3,a5,56
    80004ae4:	e8845783          	lhu	a5,-376(s0)
    80004ae8:	06fd5d63          	bge	s10,a5,80004b62 <kexec+0x1a2>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004aec:	e0d43423          	sd	a3,-504(s0)
    80004af0:	876e                	mv	a4,s11
    80004af2:	e1840613          	addi	a2,s0,-488
    80004af6:	4581                	li	a1,0
    80004af8:	8552                	mv	a0,s4
    80004afa:	d05fe0ef          	jal	800037fe <readi>
    80004afe:	1fb51063          	bne	a0,s11,80004cde <kexec+0x31e>
    if (ph.type != ELF_PROG_LOAD)
    80004b02:	e1842783          	lw	a5,-488(s0)
    80004b06:	4705                	li	a4,1
    80004b08:	fce799e3          	bne	a5,a4,80004ada <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    80004b0c:	e4043483          	ld	s1,-448(s0)
    80004b10:	e3843783          	ld	a5,-456(s0)
    80004b14:	1ef4e563          	bltu	s1,a5,80004cfe <kexec+0x33e>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004b18:	e2843783          	ld	a5,-472(s0)
    80004b1c:	94be                	add	s1,s1,a5
    80004b1e:	1ef4e363          	bltu	s1,a5,80004d04 <kexec+0x344>
    if (ph.vaddr % PGSIZE != 0)
    80004b22:	de843703          	ld	a4,-536(s0)
    80004b26:	8ff9                	and	a5,a5,a4
    80004b28:	1e079163          	bnez	a5,80004d0a <kexec+0x34a>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004b2c:	e1c42503          	lw	a0,-484(s0)
    80004b30:	e71ff0ef          	jal	800049a0 <flags2perm>
    80004b34:	86aa                	mv	a3,a0
    80004b36:	8626                	mv	a2,s1
    80004b38:	85ca                	mv	a1,s2
    80004b3a:	855a                	mv	a0,s6
    80004b3c:	fcefc0ef          	jal	8000130a <uvmalloc>
    80004b40:	dea43c23          	sd	a0,-520(s0)
    80004b44:	1c050663          	beqz	a0,80004d10 <kexec+0x350>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004b48:	e2843b83          	ld	s7,-472(s0)
    80004b4c:	e2042c03          	lw	s8,-480(s0)
    80004b50:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004b54:	00098463          	beqz	s3,80004b5c <kexec+0x19c>
    80004b58:	4481                	li	s1,0
    80004b5a:	bfb1                	j	80004ab6 <kexec+0xf6>
    sz = sz1;
    80004b5c:	df843903          	ld	s2,-520(s0)
    80004b60:	bfad                	j	80004ada <kexec+0x11a>
    80004b62:	7dfa                	ld	s11,440(sp)
  iunlockput(ip);
    80004b64:	8552                	mv	a0,s4
    80004b66:	b11fe0ef          	jal	80003676 <iunlockput>
  end_op();
    80004b6a:	ba2ff0ef          	jal	80003f0c <end_op>
  p = myproc();
    80004b6e:	e11fc0ef          	jal	8000197e <myproc>
    80004b72:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004b74:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    80004b78:	6c05                	lui	s8,0x1
    80004b7a:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    80004b7c:	9c4a                	add	s8,s8,s2
    80004b7e:	77fd                	lui	a5,0xfffff
    80004b80:	00fc7c33          	and	s8,s8,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004b84:	4691                	li	a3,4
    80004b86:	6609                	lui	a2,0x2
    80004b88:	9662                	add	a2,a2,s8
    80004b8a:	85e2                	mv	a1,s8
    80004b8c:	855a                	mv	a0,s6
    80004b8e:	f7cfc0ef          	jal	8000130a <uvmalloc>
    80004b92:	892a                	mv	s2,a0
    80004b94:	e10d                	bnez	a0,80004bb6 <kexec+0x1f6>
    proc_freepagetable(pagetable, sz);
    80004b96:	85e2                	mv	a1,s8
    80004b98:	855a                	mv	a0,s6
    80004b9a:	fb5fc0ef          	jal	80001b4e <proc_freepagetable>
  return -1;
    80004b9e:	557d                	li	a0,-1
    80004ba0:	79fe                	ld	s3,504(sp)
    80004ba2:	7a5e                	ld	s4,496(sp)
    80004ba4:	7abe                	ld	s5,488(sp)
    80004ba6:	7b1e                	ld	s6,480(sp)
    80004ba8:	6bfe                	ld	s7,472(sp)
    80004baa:	6c5e                	ld	s8,464(sp)
    80004bac:	6cbe                	ld	s9,456(sp)
    80004bae:	6d1e                	ld	s10,448(sp)
    80004bb0:	b549                	j	80004a32 <kexec+0x72>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004bb2:	4901                	li	s2,0
    80004bb4:	bf45                	j	80004b64 <kexec+0x1a4>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004bb6:	75f9                	lui	a1,0xffffe
    80004bb8:	95aa                	add	a1,a1,a0
    80004bba:	855a                	mv	a0,s6
    80004bbc:	95ffc0ef          	jal	8000151a <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004bc0:	7a7d                	lui	s4,0xfffff
    80004bc2:	9a4a                	add	s4,s4,s2
  for (argc = 0; argv[argc]; argc++) {
    80004bc4:	e0043783          	ld	a5,-512(s0)
    80004bc8:	6388                	ld	a0,0(a5)
    80004bca:	c545                	beqz	a0,80004c72 <kexec+0x2b2>
  sp = sz;
    80004bcc:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004bce:	4481                	li	s1,0
    ustack[argc] = sp;
    80004bd0:	e9040b93          	addi	s7,s0,-368
    sp -= strlen(argv[argc]) + 1;
    80004bd4:	a00fc0ef          	jal	80000dd4 <strlen>
    80004bd8:	0015079b          	addiw	a5,a0,1
    80004bdc:	40fc07b3          	sub	a5,s8,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004be0:	ff07fc13          	andi	s8,a5,-16
    if (sp < stackbase)
    80004be4:	0f4c6963          	bltu	s8,s4,80004cd6 <kexec+0x316>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004be8:	e0043d03          	ld	s10,-512(s0)
    80004bec:	000d3c83          	ld	s9,0(s10)
    80004bf0:	8566                	mv	a0,s9
    80004bf2:	9e2fc0ef          	jal	80000dd4 <strlen>
    80004bf6:	0015071b          	addiw	a4,a0,1
    80004bfa:	86e6                	mv	a3,s9
    80004bfc:	8662                	mv	a2,s8
    80004bfe:	85ca                	mv	a1,s2
    80004c00:	855a                	mv	a0,s6
    80004c02:	9dffc0ef          	jal	800015e0 <copyout>
    80004c06:	0c054a63          	bltz	a0,80004cda <kexec+0x31a>
    ustack[argc] = sp;
    80004c0a:	00349793          	slli	a5,s1,0x3
    80004c0e:	97de                	add	a5,a5,s7
    80004c10:	0187b023          	sd	s8,0(a5) # fffffffffffff000 <end+0xffffffff7ffde210>
  for (argc = 0; argv[argc]; argc++) {
    80004c14:	0485                	addi	s1,s1,1
    80004c16:	008d0793          	addi	a5,s10,8
    80004c1a:	e0f43023          	sd	a5,-512(s0)
    80004c1e:	008d3503          	ld	a0,8(s10)
    80004c22:	f94d                	bnez	a0,80004bd4 <kexec+0x214>
  ustack[argc] = 0;
    80004c24:	00349793          	slli	a5,s1,0x3
    80004c28:	f9078793          	addi	a5,a5,-112
    80004c2c:	97a2                	add	a5,a5,s0
    80004c2e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004c32:	00148713          	addi	a4,s1,1
    80004c36:	070e                	slli	a4,a4,0x3
    80004c38:	40ec0bb3          	sub	s7,s8,a4
  sp -= sp % 16;
    80004c3c:	ff0bfb93          	andi	s7,s7,-16
  sz = sz1;
    80004c40:	8c4a                	mv	s8,s2
  if (sp < stackbase)
    80004c42:	f54beae3          	bltu	s7,s4,80004b96 <kexec+0x1d6>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004c46:	e9040693          	addi	a3,s0,-368
    80004c4a:	865e                	mv	a2,s7
    80004c4c:	85ca                	mv	a1,s2
    80004c4e:	855a                	mv	a0,s6
    80004c50:	991fc0ef          	jal	800015e0 <copyout>
    80004c54:	f40541e3          	bltz	a0,80004b96 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004c58:	0589b783          	ld	a5,88(s3)
    80004c5c:	0777bc23          	sd	s7,120(a5)
  for (last = s = path; *s; s++)
    80004c60:	df043783          	ld	a5,-528(s0)
    80004c64:	0007c703          	lbu	a4,0(a5)
    80004c68:	c30d                	beqz	a4,80004c8a <kexec+0x2ca>
    80004c6a:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004c6c:	02f00693          	li	a3,47
    80004c70:	a801                	j	80004c80 <kexec+0x2c0>
  sp = sz;
    80004c72:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004c74:	4481                	li	s1,0
    80004c76:	b77d                	j	80004c24 <kexec+0x264>
  for (last = s = path; *s; s++)
    80004c78:	0785                	addi	a5,a5,1
    80004c7a:	fff7c703          	lbu	a4,-1(a5)
    80004c7e:	c711                	beqz	a4,80004c8a <kexec+0x2ca>
    if (*s == '/')
    80004c80:	fed71ce3          	bne	a4,a3,80004c78 <kexec+0x2b8>
      last = s + 1;
    80004c84:	def43823          	sd	a5,-528(s0)
    80004c88:	bfc5                	j	80004c78 <kexec+0x2b8>
  safestrcpy(p->name, last, sizeof(p->name));
    80004c8a:	4641                	li	a2,16
    80004c8c:	df043583          	ld	a1,-528(s0)
    80004c90:	16098513          	addi	a0,s3,352
    80004c94:	90afc0ef          	jal	80000d9e <safestrcpy>
  oldpagetable = p->pagetable;
    80004c98:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004c9c:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004ca0:	0529b423          	sd	s2,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004ca4:	0589b783          	ld	a5,88(s3)
    80004ca8:	e6843703          	ld	a4,-408(s0)
    80004cac:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004cae:	0589b783          	ld	a5,88(s3)
    80004cb2:	0377b823          	sd	s7,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004cb6:	85d6                	mv	a1,s5
    80004cb8:	e97fc0ef          	jal	80001b4e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004cbc:	0004851b          	sext.w	a0,s1
    80004cc0:	79fe                	ld	s3,504(sp)
    80004cc2:	7a5e                	ld	s4,496(sp)
    80004cc4:	7abe                	ld	s5,488(sp)
    80004cc6:	7b1e                	ld	s6,480(sp)
    80004cc8:	6bfe                	ld	s7,472(sp)
    80004cca:	6c5e                	ld	s8,464(sp)
    80004ccc:	6cbe                	ld	s9,456(sp)
    80004cce:	6d1e                	ld	s10,448(sp)
    80004cd0:	b38d                	j	80004a32 <kexec+0x72>
    80004cd2:	7b1e                	ld	s6,480(sp)
    80004cd4:	bb81                	j	80004a24 <kexec+0x64>
  sz = sz1;
    80004cd6:	8c4a                	mv	s8,s2
    80004cd8:	bd7d                	j	80004b96 <kexec+0x1d6>
    80004cda:	8c4a                	mv	s8,s2
    80004cdc:	bd6d                	j	80004b96 <kexec+0x1d6>
    80004cde:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004ce2:	df843583          	ld	a1,-520(s0)
    80004ce6:	855a                	mv	a0,s6
    80004ce8:	e67fc0ef          	jal	80001b4e <proc_freepagetable>
  if (ip) {
    80004cec:	79fe                	ld	s3,504(sp)
    80004cee:	7abe                	ld	s5,488(sp)
    80004cf0:	7b1e                	ld	s6,480(sp)
    80004cf2:	6bfe                	ld	s7,472(sp)
    80004cf4:	6c5e                	ld	s8,464(sp)
    80004cf6:	6cbe                	ld	s9,456(sp)
    80004cf8:	6d1e                	ld	s10,448(sp)
    80004cfa:	7dfa                	ld	s11,440(sp)
    80004cfc:	b325                	j	80004a24 <kexec+0x64>
    80004cfe:	df243c23          	sd	s2,-520(s0)
    80004d02:	b7c5                	j	80004ce2 <kexec+0x322>
    80004d04:	df243c23          	sd	s2,-520(s0)
    80004d08:	bfe9                	j	80004ce2 <kexec+0x322>
    80004d0a:	df243c23          	sd	s2,-520(s0)
    80004d0e:	bfd1                	j	80004ce2 <kexec+0x322>
    80004d10:	df243c23          	sd	s2,-520(s0)
    80004d14:	b7f9                	j	80004ce2 <kexec+0x322>

0000000080004d16 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004d16:	7179                	addi	sp,sp,-48
    80004d18:	f406                	sd	ra,40(sp)
    80004d1a:	f022                	sd	s0,32(sp)
    80004d1c:	ec26                	sd	s1,24(sp)
    80004d1e:	e84a                	sd	s2,16(sp)
    80004d20:	1800                	addi	s0,sp,48
    80004d22:	892e                	mv	s2,a1
    80004d24:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004d26:	fdc40593          	addi	a1,s0,-36
    80004d2a:	c13fd0ef          	jal	8000293c <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004d2e:	fdc42703          	lw	a4,-36(s0)
    80004d32:	47bd                	li	a5,15
    80004d34:	02e7e963          	bltu	a5,a4,80004d66 <argfd+0x50>
    80004d38:	c47fc0ef          	jal	8000197e <myproc>
    80004d3c:	fdc42703          	lw	a4,-36(s0)
    80004d40:	01a70793          	addi	a5,a4,26
    80004d44:	078e                	slli	a5,a5,0x3
    80004d46:	953e                	add	a0,a0,a5
    80004d48:	651c                	ld	a5,8(a0)
    80004d4a:	c385                	beqz	a5,80004d6a <argfd+0x54>
    return -1;
  if (pfd)
    80004d4c:	00090463          	beqz	s2,80004d54 <argfd+0x3e>
    *pfd = fd;
    80004d50:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004d54:	4501                	li	a0,0
  if (pf)
    80004d56:	c091                	beqz	s1,80004d5a <argfd+0x44>
    *pf = f;
    80004d58:	e09c                	sd	a5,0(s1)
}
    80004d5a:	70a2                	ld	ra,40(sp)
    80004d5c:	7402                	ld	s0,32(sp)
    80004d5e:	64e2                	ld	s1,24(sp)
    80004d60:	6942                	ld	s2,16(sp)
    80004d62:	6145                	addi	sp,sp,48
    80004d64:	8082                	ret
    return -1;
    80004d66:	557d                	li	a0,-1
    80004d68:	bfcd                	j	80004d5a <argfd+0x44>
    80004d6a:	557d                	li	a0,-1
    80004d6c:	b7fd                	j	80004d5a <argfd+0x44>

0000000080004d6e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004d6e:	1101                	addi	sp,sp,-32
    80004d70:	ec06                	sd	ra,24(sp)
    80004d72:	e822                	sd	s0,16(sp)
    80004d74:	e426                	sd	s1,8(sp)
    80004d76:	1000                	addi	s0,sp,32
    80004d78:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004d7a:	c05fc0ef          	jal	8000197e <myproc>
    80004d7e:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004d80:	0d850793          	addi	a5,a0,216
    80004d84:	4501                	li	a0,0
    80004d86:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004d88:	6398                	ld	a4,0(a5)
    80004d8a:	cb19                	beqz	a4,80004da0 <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004d8c:	2505                	addiw	a0,a0,1
    80004d8e:	07a1                	addi	a5,a5,8
    80004d90:	fed51ce3          	bne	a0,a3,80004d88 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004d94:	557d                	li	a0,-1
}
    80004d96:	60e2                	ld	ra,24(sp)
    80004d98:	6442                	ld	s0,16(sp)
    80004d9a:	64a2                	ld	s1,8(sp)
    80004d9c:	6105                	addi	sp,sp,32
    80004d9e:	8082                	ret
      p->ofile[fd] = f;
    80004da0:	01a50793          	addi	a5,a0,26
    80004da4:	078e                	slli	a5,a5,0x3
    80004da6:	963e                	add	a2,a2,a5
    80004da8:	e604                	sd	s1,8(a2)
      return fd;
    80004daa:	b7f5                	j	80004d96 <fdalloc+0x28>

0000000080004dac <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004dac:	715d                	addi	sp,sp,-80
    80004dae:	e486                	sd	ra,72(sp)
    80004db0:	e0a2                	sd	s0,64(sp)
    80004db2:	fc26                	sd	s1,56(sp)
    80004db4:	f84a                	sd	s2,48(sp)
    80004db6:	f44e                	sd	s3,40(sp)
    80004db8:	f052                	sd	s4,32(sp)
    80004dba:	ec56                	sd	s5,24(sp)
    80004dbc:	0880                	addi	s0,sp,80
    80004dbe:	892e                	mv	s2,a1
    80004dc0:	89b2                	mv	s3,a2
    80004dc2:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004dc4:	fb040593          	addi	a1,s0,-80
    80004dc8:	efffe0ef          	jal	80003cc6 <nameiparent>
    80004dcc:	8aaa                	mv	s5,a0
    80004dce:	cd45                	beqz	a0,80004e86 <create+0xda>
    return 0;

  ilock(dp);
    80004dd0:	e54fe0ef          	jal	80003424 <ilock>

  if (dp->nlink == 0) {
    80004dd4:	04aa9783          	lh	a5,74(s5) # 104a <_entry-0x7fffefb6>
    80004dd8:	cf8d                	beqz	a5,80004e12 <create+0x66>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004dda:	4705                	li	a4,1
    80004ddc:	04e91563          	bne	s2,a4,80004e26 <create+0x7a>
    80004de0:	6721                	lui	a4,0x8
    80004de2:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80004de4:	02e78c63          	beq	a5,a4,80004e1c <create+0x70>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004de8:	4601                	li	a2,0
    80004dea:	fb040593          	addi	a1,s0,-80
    80004dee:	8556                	mv	a0,s5
    80004df0:	c21fe0ef          	jal	80003a10 <dirlookup>
    80004df4:	84aa                	mv	s1,a0
    80004df6:	e951                	bnez	a0,80004e8a <create+0xde>
      return ip;
    iunlockput(ip);
    return 0;
  }

  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004df8:	85ca                	mv	a1,s2
    80004dfa:	000aa503          	lw	a0,0(s5)
    80004dfe:	cb6fe0ef          	jal	800032b4 <ialloc>
    80004e02:	84aa                	mv	s1,a0
    80004e04:	0c051e63          	bnez	a0,80004ee0 <create+0x134>
    iunlockput(dp);
    80004e08:	8556                	mv	a0,s5
    80004e0a:	86dfe0ef          	jal	80003676 <iunlockput>
    return 0;
    80004e0e:	4481                	li	s1,0
    80004e10:	a0a1                	j	80004e58 <create+0xac>
    iunlockput(dp);
    80004e12:	8556                	mv	a0,s5
    80004e14:	863fe0ef          	jal	80003676 <iunlockput>
    return 0;
    80004e18:	4481                	li	s1,0
    80004e1a:	a83d                	j	80004e58 <create+0xac>
    iunlockput(dp);
    80004e1c:	8556                	mv	a0,s5
    80004e1e:	859fe0ef          	jal	80003676 <iunlockput>
    return 0;
    80004e22:	4481                	li	s1,0
    80004e24:	a815                	j	80004e58 <create+0xac>
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004e26:	4601                	li	a2,0
    80004e28:	fb040593          	addi	a1,s0,-80
    80004e2c:	8556                	mv	a0,s5
    80004e2e:	be3fe0ef          	jal	80003a10 <dirlookup>
    80004e32:	84aa                	mv	s1,a0
    80004e34:	c535                	beqz	a0,80004ea0 <create+0xf4>
    iunlockput(dp);
    80004e36:	8556                	mv	a0,s5
    80004e38:	83ffe0ef          	jal	80003676 <iunlockput>
    ilock(ip);
    80004e3c:	8526                	mv	a0,s1
    80004e3e:	de6fe0ef          	jal	80003424 <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004e42:	4789                	li	a5,2
    80004e44:	04f91963          	bne	s2,a5,80004e96 <create+0xea>
    80004e48:	0444d783          	lhu	a5,68(s1)
    80004e4c:	37f9                	addiw	a5,a5,-2
    80004e4e:	17c2                	slli	a5,a5,0x30
    80004e50:	93c1                	srli	a5,a5,0x30
    80004e52:	4705                	li	a4,1
    80004e54:	04f76163          	bltu	a4,a5,80004e96 <create+0xea>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004e58:	8526                	mv	a0,s1
    80004e5a:	60a6                	ld	ra,72(sp)
    80004e5c:	6406                	ld	s0,64(sp)
    80004e5e:	74e2                	ld	s1,56(sp)
    80004e60:	7942                	ld	s2,48(sp)
    80004e62:	79a2                	ld	s3,40(sp)
    80004e64:	7a02                	ld	s4,32(sp)
    80004e66:	6ae2                	ld	s5,24(sp)
    80004e68:	6161                	addi	sp,sp,80
    80004e6a:	8082                	ret
  ip->nlink = 0;
    80004e6c:	04049523          	sh	zero,74(s1)
  iupdate(ip);
    80004e70:	8526                	mv	a0,s1
    80004e72:	cfefe0ef          	jal	80003370 <iupdate>
  iunlockput(ip);
    80004e76:	8526                	mv	a0,s1
    80004e78:	ffefe0ef          	jal	80003676 <iunlockput>
  iunlockput(dp);
    80004e7c:	8556                	mv	a0,s5
    80004e7e:	ff8fe0ef          	jal	80003676 <iunlockput>
  return 0;
    80004e82:	4481                	li	s1,0
    80004e84:	bfd1                	j	80004e58 <create+0xac>
    return 0;
    80004e86:	84aa                	mv	s1,a0
    80004e88:	bfc1                	j	80004e58 <create+0xac>
    iunlockput(dp);
    80004e8a:	8556                	mv	a0,s5
    80004e8c:	feafe0ef          	jal	80003676 <iunlockput>
    ilock(ip);
    80004e90:	8526                	mv	a0,s1
    80004e92:	d92fe0ef          	jal	80003424 <ilock>
    iunlockput(ip);
    80004e96:	8526                	mv	a0,s1
    80004e98:	fdefe0ef          	jal	80003676 <iunlockput>
    return 0;
    80004e9c:	4481                	li	s1,0
    80004e9e:	bf6d                	j	80004e58 <create+0xac>
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004ea0:	85ca                	mv	a1,s2
    80004ea2:	000aa503          	lw	a0,0(s5)
    80004ea6:	c0efe0ef          	jal	800032b4 <ialloc>
    80004eaa:	84aa                	mv	s1,a0
    80004eac:	dd31                	beqz	a0,80004e08 <create+0x5c>
  ilock(ip);
    80004eae:	8526                	mv	a0,s1
    80004eb0:	d74fe0ef          	jal	80003424 <ilock>
  ip->major = major;
    80004eb4:	05349323          	sh	s3,70(s1)
  ip->minor = minor;
    80004eb8:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80004ebc:	4785                	li	a5,1
    80004ebe:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004ec2:	8526                	mv	a0,s1
    80004ec4:	cacfe0ef          	jal	80003370 <iupdate>
  if (dirlink(dp, name, ip->inum) < 0)
    80004ec8:	40d0                	lw	a2,4(s1)
    80004eca:	fb040593          	addi	a1,s0,-80
    80004ece:	8556                	mv	a0,s5
    80004ed0:	d33fe0ef          	jal	80003c02 <dirlink>
    80004ed4:	f8054ce3          	bltz	a0,80004e6c <create+0xc0>
  iunlockput(dp);
    80004ed8:	8556                	mv	a0,s5
    80004eda:	f9cfe0ef          	jal	80003676 <iunlockput>
  return ip;
    80004ede:	bfad                	j	80004e58 <create+0xac>
  ilock(ip);
    80004ee0:	8526                	mv	a0,s1
    80004ee2:	d42fe0ef          	jal	80003424 <ilock>
  ip->major = major;
    80004ee6:	05349323          	sh	s3,70(s1)
  ip->minor = minor;
    80004eea:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80004eee:	4785                	li	a5,1
    80004ef0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004ef4:	8526                	mv	a0,s1
    80004ef6:	c7afe0ef          	jal	80003370 <iupdate>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004efa:	40d0                	lw	a2,4(s1)
    80004efc:	00002597          	auipc	a1,0x2
    80004f00:	71c58593          	addi	a1,a1,1820 # 80007618 <etext+0x618>
    80004f04:	8526                	mv	a0,s1
    80004f06:	cfdfe0ef          	jal	80003c02 <dirlink>
    80004f0a:	f60541e3          	bltz	a0,80004e6c <create+0xc0>
    80004f0e:	004aa603          	lw	a2,4(s5)
    80004f12:	00002597          	auipc	a1,0x2
    80004f16:	6fe58593          	addi	a1,a1,1790 # 80007610 <etext+0x610>
    80004f1a:	8526                	mv	a0,s1
    80004f1c:	ce7fe0ef          	jal	80003c02 <dirlink>
    80004f20:	f40546e3          	bltz	a0,80004e6c <create+0xc0>
  if (dirlink(dp, name, ip->inum) < 0)
    80004f24:	40d0                	lw	a2,4(s1)
    80004f26:	fb040593          	addi	a1,s0,-80
    80004f2a:	8556                	mv	a0,s5
    80004f2c:	cd7fe0ef          	jal	80003c02 <dirlink>
    80004f30:	f2054ee3          	bltz	a0,80004e6c <create+0xc0>
    dp->nlink++; // for ".."
    80004f34:	04aad783          	lhu	a5,74(s5)
    80004f38:	2785                	addiw	a5,a5,1
    80004f3a:	04fa9523          	sh	a5,74(s5)
    iupdate(dp);
    80004f3e:	8556                	mv	a0,s5
    80004f40:	c30fe0ef          	jal	80003370 <iupdate>
    80004f44:	bf51                	j	80004ed8 <create+0x12c>

0000000080004f46 <sys_dup>:
{
    80004f46:	7179                	addi	sp,sp,-48
    80004f48:	f406                	sd	ra,40(sp)
    80004f4a:	f022                	sd	s0,32(sp)
    80004f4c:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004f4e:	fd840613          	addi	a2,s0,-40
    80004f52:	4581                	li	a1,0
    80004f54:	4501                	li	a0,0
    80004f56:	dc1ff0ef          	jal	80004d16 <argfd>
    return -1;
    80004f5a:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004f5c:	02054363          	bltz	a0,80004f82 <sys_dup+0x3c>
    80004f60:	ec26                	sd	s1,24(sp)
    80004f62:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004f64:	fd843903          	ld	s2,-40(s0)
    80004f68:	854a                	mv	a0,s2
    80004f6a:	e05ff0ef          	jal	80004d6e <fdalloc>
    80004f6e:	84aa                	mv	s1,a0
    return -1;
    80004f70:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004f72:	00054d63          	bltz	a0,80004f8c <sys_dup+0x46>
  filedup(f);
    80004f76:	854a                	mv	a0,s2
    80004f78:	b7aff0ef          	jal	800042f2 <filedup>
  return fd;
    80004f7c:	87a6                	mv	a5,s1
    80004f7e:	64e2                	ld	s1,24(sp)
    80004f80:	6942                	ld	s2,16(sp)
}
    80004f82:	853e                	mv	a0,a5
    80004f84:	70a2                	ld	ra,40(sp)
    80004f86:	7402                	ld	s0,32(sp)
    80004f88:	6145                	addi	sp,sp,48
    80004f8a:	8082                	ret
    80004f8c:	64e2                	ld	s1,24(sp)
    80004f8e:	6942                	ld	s2,16(sp)
    80004f90:	bfcd                	j	80004f82 <sys_dup+0x3c>

0000000080004f92 <sys_read>:
{
    80004f92:	7179                	addi	sp,sp,-48
    80004f94:	f406                	sd	ra,40(sp)
    80004f96:	f022                	sd	s0,32(sp)
    80004f98:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f9a:	fd840593          	addi	a1,s0,-40
    80004f9e:	4505                	li	a0,1
    80004fa0:	9b9fd0ef          	jal	80002958 <argaddr>
  argint(2, &n);
    80004fa4:	fe440593          	addi	a1,s0,-28
    80004fa8:	4509                	li	a0,2
    80004faa:	993fd0ef          	jal	8000293c <argint>
  if (argfd(0, 0, &f) < 0)
    80004fae:	fe840613          	addi	a2,s0,-24
    80004fb2:	4581                	li	a1,0
    80004fb4:	4501                	li	a0,0
    80004fb6:	d61ff0ef          	jal	80004d16 <argfd>
    80004fba:	87aa                	mv	a5,a0
    return -1;
    80004fbc:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004fbe:	0007ca63          	bltz	a5,80004fd2 <sys_read+0x40>
  return fileread(f, p, n);
    80004fc2:	fe442603          	lw	a2,-28(s0)
    80004fc6:	fd843583          	ld	a1,-40(s0)
    80004fca:	fe843503          	ld	a0,-24(s0)
    80004fce:	c8eff0ef          	jal	8000445c <fileread>
}
    80004fd2:	70a2                	ld	ra,40(sp)
    80004fd4:	7402                	ld	s0,32(sp)
    80004fd6:	6145                	addi	sp,sp,48
    80004fd8:	8082                	ret

0000000080004fda <sys_write>:
{
    80004fda:	7179                	addi	sp,sp,-48
    80004fdc:	f406                	sd	ra,40(sp)
    80004fde:	f022                	sd	s0,32(sp)
    80004fe0:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004fe2:	fd840593          	addi	a1,s0,-40
    80004fe6:	4505                	li	a0,1
    80004fe8:	971fd0ef          	jal	80002958 <argaddr>
  argint(2, &n);
    80004fec:	fe440593          	addi	a1,s0,-28
    80004ff0:	4509                	li	a0,2
    80004ff2:	94bfd0ef          	jal	8000293c <argint>
  if (argfd(0, 0, &f) < 0)
    80004ff6:	fe840613          	addi	a2,s0,-24
    80004ffa:	4581                	li	a1,0
    80004ffc:	4501                	li	a0,0
    80004ffe:	d19ff0ef          	jal	80004d16 <argfd>
    80005002:	87aa                	mv	a5,a0
    return -1;
    80005004:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005006:	0007ca63          	bltz	a5,8000501a <sys_write+0x40>
  return filewrite(f, p, n);
    8000500a:	fe442603          	lw	a2,-28(s0)
    8000500e:	fd843583          	ld	a1,-40(s0)
    80005012:	fe843503          	ld	a0,-24(s0)
    80005016:	d10ff0ef          	jal	80004526 <filewrite>
}
    8000501a:	70a2                	ld	ra,40(sp)
    8000501c:	7402                	ld	s0,32(sp)
    8000501e:	6145                	addi	sp,sp,48
    80005020:	8082                	ret

0000000080005022 <sys_close>:
{
    80005022:	1101                	addi	sp,sp,-32
    80005024:	ec06                	sd	ra,24(sp)
    80005026:	e822                	sd	s0,16(sp)
    80005028:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    8000502a:	fe040613          	addi	a2,s0,-32
    8000502e:	fec40593          	addi	a1,s0,-20
    80005032:	4501                	li	a0,0
    80005034:	ce3ff0ef          	jal	80004d16 <argfd>
    return -1;
    80005038:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    8000503a:	02054063          	bltz	a0,8000505a <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    8000503e:	941fc0ef          	jal	8000197e <myproc>
    80005042:	fec42783          	lw	a5,-20(s0)
    80005046:	07e9                	addi	a5,a5,26
    80005048:	078e                	slli	a5,a5,0x3
    8000504a:	953e                	add	a0,a0,a5
    8000504c:	00053423          	sd	zero,8(a0)
  fileclose(f);
    80005050:	fe043503          	ld	a0,-32(s0)
    80005054:	ae4ff0ef          	jal	80004338 <fileclose>
  return 0;
    80005058:	4781                	li	a5,0
}
    8000505a:	853e                	mv	a0,a5
    8000505c:	60e2                	ld	ra,24(sp)
    8000505e:	6442                	ld	s0,16(sp)
    80005060:	6105                	addi	sp,sp,32
    80005062:	8082                	ret

0000000080005064 <sys_fstat>:
{
    80005064:	1101                	addi	sp,sp,-32
    80005066:	ec06                	sd	ra,24(sp)
    80005068:	e822                	sd	s0,16(sp)
    8000506a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000506c:	fe040593          	addi	a1,s0,-32
    80005070:	4505                	li	a0,1
    80005072:	8e7fd0ef          	jal	80002958 <argaddr>
  if (argfd(0, 0, &f) < 0)
    80005076:	fe840613          	addi	a2,s0,-24
    8000507a:	4581                	li	a1,0
    8000507c:	4501                	li	a0,0
    8000507e:	c99ff0ef          	jal	80004d16 <argfd>
    80005082:	87aa                	mv	a5,a0
    return -1;
    80005084:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005086:	0007c863          	bltz	a5,80005096 <sys_fstat+0x32>
  return filestat(f, st);
    8000508a:	fe043583          	ld	a1,-32(s0)
    8000508e:	fe843503          	ld	a0,-24(s0)
    80005092:	b64ff0ef          	jal	800043f6 <filestat>
}
    80005096:	60e2                	ld	ra,24(sp)
    80005098:	6442                	ld	s0,16(sp)
    8000509a:	6105                	addi	sp,sp,32
    8000509c:	8082                	ret

000000008000509e <sys_link>:
{
    8000509e:	7169                	addi	sp,sp,-304
    800050a0:	f606                	sd	ra,296(sp)
    800050a2:	f222                	sd	s0,288(sp)
    800050a4:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050a6:	08000613          	li	a2,128
    800050aa:	ed040593          	addi	a1,s0,-304
    800050ae:	4501                	li	a0,0
    800050b0:	8c5fd0ef          	jal	80002974 <argstr>
    return -1;
    800050b4:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050b6:	10054163          	bltz	a0,800051b8 <sys_link+0x11a>
    800050ba:	08000613          	li	a2,128
    800050be:	f5040593          	addi	a1,s0,-176
    800050c2:	4505                	li	a0,1
    800050c4:	8b1fd0ef          	jal	80002974 <argstr>
    return -1;
    800050c8:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050ca:	0e054763          	bltz	a0,800051b8 <sys_link+0x11a>
    800050ce:	ee26                	sd	s1,280(sp)
  begin_op();
    800050d0:	db7fe0ef          	jal	80003e86 <begin_op>
  if ((ip = namei(old)) == 0) {
    800050d4:	ed040513          	addi	a0,s0,-304
    800050d8:	bd5fe0ef          	jal	80003cac <namei>
    800050dc:	84aa                	mv	s1,a0
    800050de:	cd35                	beqz	a0,8000515a <sys_link+0xbc>
  ilock(ip);
    800050e0:	b44fe0ef          	jal	80003424 <ilock>
  if (ip->type == T_DIR) {
    800050e4:	04449703          	lh	a4,68(s1)
    800050e8:	4785                	li	a5,1
    800050ea:	06f70d63          	beq	a4,a5,80005164 <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    800050ee:	04a49783          	lh	a5,74(s1)
    800050f2:	6721                	lui	a4,0x8
    800050f4:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    800050f6:	06e78f63          	beq	a5,a4,80005174 <sys_link+0xd6>
    800050fa:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800050fc:	2785                	addiw	a5,a5,1
    800050fe:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005102:	8526                	mv	a0,s1
    80005104:	a6cfe0ef          	jal	80003370 <iupdate>
  iunlock(ip);
    80005108:	8526                	mv	a0,s1
    8000510a:	bc8fe0ef          	jal	800034d2 <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    8000510e:	fd040593          	addi	a1,s0,-48
    80005112:	f5040513          	addi	a0,s0,-176
    80005116:	bb1fe0ef          	jal	80003cc6 <nameiparent>
    8000511a:	892a                	mv	s2,a0
    8000511c:	c93d                	beqz	a0,80005192 <sys_link+0xf4>
  ilock(dp);
    8000511e:	b06fe0ef          	jal	80003424 <ilock>
  if (dp->nlink == 0) {
    80005122:	04a91783          	lh	a5,74(s2)
    80005126:	cfb9                	beqz	a5,80005184 <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    80005128:	00092703          	lw	a4,0(s2)
    8000512c:	409c                	lw	a5,0(s1)
    8000512e:	04f71f63          	bne	a4,a5,8000518c <sys_link+0xee>
    80005132:	40d0                	lw	a2,4(s1)
    80005134:	fd040593          	addi	a1,s0,-48
    80005138:	854a                	mv	a0,s2
    8000513a:	ac9fe0ef          	jal	80003c02 <dirlink>
    8000513e:	04054763          	bltz	a0,8000518c <sys_link+0xee>
  iunlockput(dp);
    80005142:	854a                	mv	a0,s2
    80005144:	d32fe0ef          	jal	80003676 <iunlockput>
  iput(ip);
    80005148:	8526                	mv	a0,s1
    8000514a:	c5cfe0ef          	jal	800035a6 <iput>
  end_op();
    8000514e:	dbffe0ef          	jal	80003f0c <end_op>
  return 0;
    80005152:	4781                	li	a5,0
    80005154:	64f2                	ld	s1,280(sp)
    80005156:	6952                	ld	s2,272(sp)
    80005158:	a085                	j	800051b8 <sys_link+0x11a>
    end_op();
    8000515a:	db3fe0ef          	jal	80003f0c <end_op>
    return -1;
    8000515e:	57fd                	li	a5,-1
    80005160:	64f2                	ld	s1,280(sp)
    80005162:	a899                	j	800051b8 <sys_link+0x11a>
    iunlockput(ip);
    80005164:	8526                	mv	a0,s1
    80005166:	d10fe0ef          	jal	80003676 <iunlockput>
    end_op();
    8000516a:	da3fe0ef          	jal	80003f0c <end_op>
    return -1;
    8000516e:	57fd                	li	a5,-1
    80005170:	64f2                	ld	s1,280(sp)
    80005172:	a099                	j	800051b8 <sys_link+0x11a>
    iunlockput(ip);
    80005174:	8526                	mv	a0,s1
    80005176:	d00fe0ef          	jal	80003676 <iunlockput>
    end_op();
    8000517a:	d93fe0ef          	jal	80003f0c <end_op>
    return -1;
    8000517e:	57fd                	li	a5,-1
    80005180:	64f2                	ld	s1,280(sp)
    80005182:	a81d                	j	800051b8 <sys_link+0x11a>
    iunlockput(dp);
    80005184:	854a                	mv	a0,s2
    80005186:	cf0fe0ef          	jal	80003676 <iunlockput>
    goto bad;
    8000518a:	a021                	j	80005192 <sys_link+0xf4>
    iunlockput(dp);
    8000518c:	854a                	mv	a0,s2
    8000518e:	ce8fe0ef          	jal	80003676 <iunlockput>
  ilock(ip);
    80005192:	8526                	mv	a0,s1
    80005194:	a90fe0ef          	jal	80003424 <ilock>
  ip->nlink--;
    80005198:	04a4d783          	lhu	a5,74(s1)
    8000519c:	37fd                	addiw	a5,a5,-1
    8000519e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800051a2:	8526                	mv	a0,s1
    800051a4:	9ccfe0ef          	jal	80003370 <iupdate>
  iunlockput(ip);
    800051a8:	8526                	mv	a0,s1
    800051aa:	cccfe0ef          	jal	80003676 <iunlockput>
  end_op();
    800051ae:	d5ffe0ef          	jal	80003f0c <end_op>
  return -1;
    800051b2:	57fd                	li	a5,-1
    800051b4:	64f2                	ld	s1,280(sp)
    800051b6:	6952                	ld	s2,272(sp)
}
    800051b8:	853e                	mv	a0,a5
    800051ba:	70b2                	ld	ra,296(sp)
    800051bc:	7412                	ld	s0,288(sp)
    800051be:	6155                	addi	sp,sp,304
    800051c0:	8082                	ret

00000000800051c2 <sys_unlink>:
{
    800051c2:	7111                	addi	sp,sp,-256
    800051c4:	fd86                	sd	ra,248(sp)
    800051c6:	f9a2                	sd	s0,240(sp)
    800051c8:	0200                	addi	s0,sp,256
  if (argstr(0, path, MAXPATH) < 0)
    800051ca:	08000613          	li	a2,128
    800051ce:	f2040593          	addi	a1,s0,-224
    800051d2:	4501                	li	a0,0
    800051d4:	fa0fd0ef          	jal	80002974 <argstr>
    800051d8:	16054663          	bltz	a0,80005344 <sys_unlink+0x182>
    800051dc:	f5a6                	sd	s1,232(sp)
  begin_op();
    800051de:	ca9fe0ef          	jal	80003e86 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    800051e2:	fa040593          	addi	a1,s0,-96
    800051e6:	f2040513          	addi	a0,s0,-224
    800051ea:	addfe0ef          	jal	80003cc6 <nameiparent>
    800051ee:	84aa                	mv	s1,a0
    800051f0:	c955                	beqz	a0,800052a4 <sys_unlink+0xe2>
  ilock(dp);
    800051f2:	a32fe0ef          	jal	80003424 <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800051f6:	00002597          	auipc	a1,0x2
    800051fa:	42258593          	addi	a1,a1,1058 # 80007618 <etext+0x618>
    800051fe:	fa040513          	addi	a0,s0,-96
    80005202:	ff8fe0ef          	jal	800039fa <namecmp>
    80005206:	12050463          	beqz	a0,8000532e <sys_unlink+0x16c>
    8000520a:	00002597          	auipc	a1,0x2
    8000520e:	40658593          	addi	a1,a1,1030 # 80007610 <etext+0x610>
    80005212:	fa040513          	addi	a0,s0,-96
    80005216:	fe4fe0ef          	jal	800039fa <namecmp>
    8000521a:	10050a63          	beqz	a0,8000532e <sys_unlink+0x16c>
    8000521e:	f1ca                	sd	s2,224(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    80005220:	f1c40613          	addi	a2,s0,-228
    80005224:	fa040593          	addi	a1,s0,-96
    80005228:	8526                	mv	a0,s1
    8000522a:	fe6fe0ef          	jal	80003a10 <dirlookup>
    8000522e:	892a                	mv	s2,a0
    80005230:	0e050e63          	beqz	a0,8000532c <sys_unlink+0x16a>
    80005234:	edce                	sd	s3,216(sp)
  ilock(ip);
    80005236:	9eefe0ef          	jal	80003424 <ilock>
  if (ip->nlink < 1)
    8000523a:	04a91783          	lh	a5,74(s2)
    8000523e:	06f05863          	blez	a5,800052ae <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    80005242:	04491703          	lh	a4,68(s2)
    80005246:	4785                	li	a5,1
    80005248:	06f70b63          	beq	a4,a5,800052be <sys_unlink+0xfc>
  memset(&de, 0, sizeof(de));
    8000524c:	fb040993          	addi	s3,s0,-80
    80005250:	4641                	li	a2,16
    80005252:	4581                	li	a1,0
    80005254:	854e                	mv	a0,s3
    80005256:	9f7fb0ef          	jal	80000c4c <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000525a:	4741                	li	a4,16
    8000525c:	f1c42683          	lw	a3,-228(s0)
    80005260:	864e                	mv	a2,s3
    80005262:	4581                	li	a1,0
    80005264:	8526                	mv	a0,s1
    80005266:	e8afe0ef          	jal	800038f0 <writei>
    8000526a:	47c1                	li	a5,16
    8000526c:	08f51f63          	bne	a0,a5,8000530a <sys_unlink+0x148>
  if (ip->type == T_DIR) {
    80005270:	04491703          	lh	a4,68(s2)
    80005274:	4785                	li	a5,1
    80005276:	0af70263          	beq	a4,a5,8000531a <sys_unlink+0x158>
  iunlockput(dp);
    8000527a:	8526                	mv	a0,s1
    8000527c:	bfafe0ef          	jal	80003676 <iunlockput>
  ip->nlink--;
    80005280:	04a95783          	lhu	a5,74(s2)
    80005284:	37fd                	addiw	a5,a5,-1
    80005286:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000528a:	854a                	mv	a0,s2
    8000528c:	8e4fe0ef          	jal	80003370 <iupdate>
  iunlockput(ip);
    80005290:	854a                	mv	a0,s2
    80005292:	be4fe0ef          	jal	80003676 <iunlockput>
  end_op();
    80005296:	c77fe0ef          	jal	80003f0c <end_op>
  return 0;
    8000529a:	4501                	li	a0,0
    8000529c:	74ae                	ld	s1,232(sp)
    8000529e:	790e                	ld	s2,224(sp)
    800052a0:	69ee                	ld	s3,216(sp)
    800052a2:	a869                	j	8000533c <sys_unlink+0x17a>
    end_op();
    800052a4:	c69fe0ef          	jal	80003f0c <end_op>
    return -1;
    800052a8:	557d                	li	a0,-1
    800052aa:	74ae                	ld	s1,232(sp)
    800052ac:	a841                	j	8000533c <sys_unlink+0x17a>
    800052ae:	e9d2                	sd	s4,208(sp)
    800052b0:	e5d6                	sd	s5,200(sp)
    panic("unlink: nlink < 1");
    800052b2:	00002517          	auipc	a0,0x2
    800052b6:	36e50513          	addi	a0,a0,878 # 80007620 <etext+0x620>
    800052ba:	d34fb0ef          	jal	800007ee <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    800052be:	04c92703          	lw	a4,76(s2)
    800052c2:	02000793          	li	a5,32
    800052c6:	f8e7f3e3          	bgeu	a5,a4,8000524c <sys_unlink+0x8a>
    800052ca:	e9d2                	sd	s4,208(sp)
    800052cc:	e5d6                	sd	s5,200(sp)
    800052ce:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800052d0:	f0840a93          	addi	s5,s0,-248
    800052d4:	4a41                	li	s4,16
    800052d6:	8752                	mv	a4,s4
    800052d8:	86ce                	mv	a3,s3
    800052da:	8656                	mv	a2,s5
    800052dc:	4581                	li	a1,0
    800052de:	854a                	mv	a0,s2
    800052e0:	d1efe0ef          	jal	800037fe <readi>
    800052e4:	01451d63          	bne	a0,s4,800052fe <sys_unlink+0x13c>
    if (de.inum != 0)
    800052e8:	f0845783          	lhu	a5,-248(s0)
    800052ec:	efb1                	bnez	a5,80005348 <sys_unlink+0x186>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    800052ee:	29c1                	addiw	s3,s3,16
    800052f0:	04c92783          	lw	a5,76(s2)
    800052f4:	fef9e1e3          	bltu	s3,a5,800052d6 <sys_unlink+0x114>
    800052f8:	6a4e                	ld	s4,208(sp)
    800052fa:	6aae                	ld	s5,200(sp)
    800052fc:	bf81                	j	8000524c <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800052fe:	00002517          	auipc	a0,0x2
    80005302:	33a50513          	addi	a0,a0,826 # 80007638 <etext+0x638>
    80005306:	ce8fb0ef          	jal	800007ee <panic>
    8000530a:	e9d2                	sd	s4,208(sp)
    8000530c:	e5d6                	sd	s5,200(sp)
    panic("unlink: writei");
    8000530e:	00002517          	auipc	a0,0x2
    80005312:	34250513          	addi	a0,a0,834 # 80007650 <etext+0x650>
    80005316:	cd8fb0ef          	jal	800007ee <panic>
    dp->nlink--;
    8000531a:	04a4d783          	lhu	a5,74(s1)
    8000531e:	37fd                	addiw	a5,a5,-1
    80005320:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005324:	8526                	mv	a0,s1
    80005326:	84afe0ef          	jal	80003370 <iupdate>
    8000532a:	bf81                	j	8000527a <sys_unlink+0xb8>
    8000532c:	790e                	ld	s2,224(sp)
  iunlockput(dp);
    8000532e:	8526                	mv	a0,s1
    80005330:	b46fe0ef          	jal	80003676 <iunlockput>
  end_op();
    80005334:	bd9fe0ef          	jal	80003f0c <end_op>
  return -1;
    80005338:	557d                	li	a0,-1
    8000533a:	74ae                	ld	s1,232(sp)
}
    8000533c:	70ee                	ld	ra,248(sp)
    8000533e:	744e                	ld	s0,240(sp)
    80005340:	6111                	addi	sp,sp,256
    80005342:	8082                	ret
    return -1;
    80005344:	557d                	li	a0,-1
    80005346:	bfdd                	j	8000533c <sys_unlink+0x17a>
    iunlockput(ip);
    80005348:	854a                	mv	a0,s2
    8000534a:	b2cfe0ef          	jal	80003676 <iunlockput>
    goto bad;
    8000534e:	790e                	ld	s2,224(sp)
    80005350:	69ee                	ld	s3,216(sp)
    80005352:	6a4e                	ld	s4,208(sp)
    80005354:	6aae                	ld	s5,200(sp)
    80005356:	bfe1                	j	8000532e <sys_unlink+0x16c>

0000000080005358 <sys_open>:

uint64
sys_open(void)
{
    80005358:	7131                	addi	sp,sp,-192
    8000535a:	fd06                	sd	ra,184(sp)
    8000535c:	f922                	sd	s0,176(sp)
    8000535e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005360:	f4c40593          	addi	a1,s0,-180
    80005364:	4505                	li	a0,1
    80005366:	dd6fd0ef          	jal	8000293c <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    8000536a:	08000613          	li	a2,128
    8000536e:	f5040593          	addi	a1,s0,-176
    80005372:	4501                	li	a0,0
    80005374:	e00fd0ef          	jal	80002974 <argstr>
    80005378:	87aa                	mv	a5,a0
    return -1;
    8000537a:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    8000537c:	0a07c363          	bltz	a5,80005422 <sys_open+0xca>
    80005380:	f526                	sd	s1,168(sp)

  begin_op();
    80005382:	b05fe0ef          	jal	80003e86 <begin_op>

  if (omode & O_CREATE) {
    80005386:	f4c42783          	lw	a5,-180(s0)
    8000538a:	2007f793          	andi	a5,a5,512
    8000538e:	c3dd                	beqz	a5,80005434 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80005390:	4681                	li	a3,0
    80005392:	4601                	li	a2,0
    80005394:	4589                	li	a1,2
    80005396:	f5040513          	addi	a0,s0,-176
    8000539a:	a13ff0ef          	jal	80004dac <create>
    8000539e:	84aa                	mv	s1,a0
    if (ip == 0) {
    800053a0:	c549                	beqz	a0,8000542a <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    800053a2:	04449703          	lh	a4,68(s1)
    800053a6:	478d                	li	a5,3
    800053a8:	00f71763          	bne	a4,a5,800053b6 <sys_open+0x5e>
    800053ac:	0464d703          	lhu	a4,70(s1)
    800053b0:	47a5                	li	a5,9
    800053b2:	0ae7ee63          	bltu	a5,a4,8000546e <sys_open+0x116>
    800053b6:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    800053b8:	eddfe0ef          	jal	80004294 <filealloc>
    800053bc:	892a                	mv	s2,a0
    800053be:	c561                	beqz	a0,80005486 <sys_open+0x12e>
    800053c0:	ed4e                	sd	s3,152(sp)
    800053c2:	9adff0ef          	jal	80004d6e <fdalloc>
    800053c6:	89aa                	mv	s3,a0
    800053c8:	0a054b63          	bltz	a0,8000547e <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    800053cc:	04449703          	lh	a4,68(s1)
    800053d0:	478d                	li	a5,3
    800053d2:	0cf70363          	beq	a4,a5,80005498 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800053d6:	4789                	li	a5,2
    800053d8:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800053dc:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800053e0:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800053e4:	f4c42783          	lw	a5,-180(s0)
    800053e8:	0017f713          	andi	a4,a5,1
    800053ec:	00174713          	xori	a4,a4,1
    800053f0:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800053f4:	0037f713          	andi	a4,a5,3
    800053f8:	00e03733          	snez	a4,a4
    800053fc:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    80005400:	4007f793          	andi	a5,a5,1024
    80005404:	c791                	beqz	a5,80005410 <sys_open+0xb8>
    80005406:	04449703          	lh	a4,68(s1)
    8000540a:	4789                	li	a5,2
    8000540c:	08f70d63          	beq	a4,a5,800054a6 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80005410:	8526                	mv	a0,s1
    80005412:	8c0fe0ef          	jal	800034d2 <iunlock>
  end_op();
    80005416:	af7fe0ef          	jal	80003f0c <end_op>

  return fd;
    8000541a:	854e                	mv	a0,s3
    8000541c:	74aa                	ld	s1,168(sp)
    8000541e:	790a                	ld	s2,160(sp)
    80005420:	69ea                	ld	s3,152(sp)
}
    80005422:	70ea                	ld	ra,184(sp)
    80005424:	744a                	ld	s0,176(sp)
    80005426:	6129                	addi	sp,sp,192
    80005428:	8082                	ret
      end_op();
    8000542a:	ae3fe0ef          	jal	80003f0c <end_op>
      return -1;
    8000542e:	557d                	li	a0,-1
    80005430:	74aa                	ld	s1,168(sp)
    80005432:	bfc5                	j	80005422 <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    80005434:	f5040513          	addi	a0,s0,-176
    80005438:	875fe0ef          	jal	80003cac <namei>
    8000543c:	84aa                	mv	s1,a0
    8000543e:	c11d                	beqz	a0,80005464 <sys_open+0x10c>
    ilock(ip);
    80005440:	fe5fd0ef          	jal	80003424 <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    80005444:	04449703          	lh	a4,68(s1)
    80005448:	4785                	li	a5,1
    8000544a:	f4f71ce3          	bne	a4,a5,800053a2 <sys_open+0x4a>
    8000544e:	f4c42783          	lw	a5,-180(s0)
    80005452:	d3b5                	beqz	a5,800053b6 <sys_open+0x5e>
      iunlockput(ip);
    80005454:	8526                	mv	a0,s1
    80005456:	a20fe0ef          	jal	80003676 <iunlockput>
      end_op();
    8000545a:	ab3fe0ef          	jal	80003f0c <end_op>
      return -1;
    8000545e:	557d                	li	a0,-1
    80005460:	74aa                	ld	s1,168(sp)
    80005462:	b7c1                	j	80005422 <sys_open+0xca>
      end_op();
    80005464:	aa9fe0ef          	jal	80003f0c <end_op>
      return -1;
    80005468:	557d                	li	a0,-1
    8000546a:	74aa                	ld	s1,168(sp)
    8000546c:	bf5d                	j	80005422 <sys_open+0xca>
    iunlockput(ip);
    8000546e:	8526                	mv	a0,s1
    80005470:	a06fe0ef          	jal	80003676 <iunlockput>
    end_op();
    80005474:	a99fe0ef          	jal	80003f0c <end_op>
    return -1;
    80005478:	557d                	li	a0,-1
    8000547a:	74aa                	ld	s1,168(sp)
    8000547c:	b75d                	j	80005422 <sys_open+0xca>
      fileclose(f);
    8000547e:	854a                	mv	a0,s2
    80005480:	eb9fe0ef          	jal	80004338 <fileclose>
    80005484:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005486:	8526                	mv	a0,s1
    80005488:	9eefe0ef          	jal	80003676 <iunlockput>
    end_op();
    8000548c:	a81fe0ef          	jal	80003f0c <end_op>
    return -1;
    80005490:	557d                	li	a0,-1
    80005492:	74aa                	ld	s1,168(sp)
    80005494:	790a                	ld	s2,160(sp)
    80005496:	b771                	j	80005422 <sys_open+0xca>
    f->type = FD_DEVICE;
    80005498:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    8000549c:	04649783          	lh	a5,70(s1)
    800054a0:	02f91223          	sh	a5,36(s2)
    800054a4:	bf35                	j	800053e0 <sys_open+0x88>
    itrunc(ip);
    800054a6:	8526                	mv	a0,s1
    800054a8:	86afe0ef          	jal	80003512 <itrunc>
    800054ac:	b795                	j	80005410 <sys_open+0xb8>

00000000800054ae <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800054ae:	7175                	addi	sp,sp,-144
    800054b0:	e506                	sd	ra,136(sp)
    800054b2:	e122                	sd	s0,128(sp)
    800054b4:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800054b6:	9d1fe0ef          	jal	80003e86 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    800054ba:	08000613          	li	a2,128
    800054be:	f7040593          	addi	a1,s0,-144
    800054c2:	4501                	li	a0,0
    800054c4:	cb0fd0ef          	jal	80002974 <argstr>
    800054c8:	02054363          	bltz	a0,800054ee <sys_mkdir+0x40>
    800054cc:	4681                	li	a3,0
    800054ce:	4601                	li	a2,0
    800054d0:	4585                	li	a1,1
    800054d2:	f7040513          	addi	a0,s0,-144
    800054d6:	8d7ff0ef          	jal	80004dac <create>
    800054da:	c911                	beqz	a0,800054ee <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800054dc:	99afe0ef          	jal	80003676 <iunlockput>
  end_op();
    800054e0:	a2dfe0ef          	jal	80003f0c <end_op>
  return 0;
    800054e4:	4501                	li	a0,0
}
    800054e6:	60aa                	ld	ra,136(sp)
    800054e8:	640a                	ld	s0,128(sp)
    800054ea:	6149                	addi	sp,sp,144
    800054ec:	8082                	ret
    end_op();
    800054ee:	a1ffe0ef          	jal	80003f0c <end_op>
    return -1;
    800054f2:	557d                	li	a0,-1
    800054f4:	bfcd                	j	800054e6 <sys_mkdir+0x38>

00000000800054f6 <sys_mknod>:

uint64
sys_mknod(void)
{
    800054f6:	7135                	addi	sp,sp,-160
    800054f8:	ed06                	sd	ra,152(sp)
    800054fa:	e922                	sd	s0,144(sp)
    800054fc:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800054fe:	989fe0ef          	jal	80003e86 <begin_op>
  argint(1, &major);
    80005502:	f6c40593          	addi	a1,s0,-148
    80005506:	4505                	li	a0,1
    80005508:	c34fd0ef          	jal	8000293c <argint>
  argint(2, &minor);
    8000550c:	f6840593          	addi	a1,s0,-152
    80005510:	4509                	li	a0,2
    80005512:	c2afd0ef          	jal	8000293c <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005516:	08000613          	li	a2,128
    8000551a:	f7040593          	addi	a1,s0,-144
    8000551e:	4501                	li	a0,0
    80005520:	c54fd0ef          	jal	80002974 <argstr>
    80005524:	02054563          	bltz	a0,8000554e <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    80005528:	f6841683          	lh	a3,-152(s0)
    8000552c:	f6c41603          	lh	a2,-148(s0)
    80005530:	458d                	li	a1,3
    80005532:	f7040513          	addi	a0,s0,-144
    80005536:	877ff0ef          	jal	80004dac <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    8000553a:	c911                	beqz	a0,8000554e <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000553c:	93afe0ef          	jal	80003676 <iunlockput>
  end_op();
    80005540:	9cdfe0ef          	jal	80003f0c <end_op>
  return 0;
    80005544:	4501                	li	a0,0
}
    80005546:	60ea                	ld	ra,152(sp)
    80005548:	644a                	ld	s0,144(sp)
    8000554a:	610d                	addi	sp,sp,160
    8000554c:	8082                	ret
    end_op();
    8000554e:	9bffe0ef          	jal	80003f0c <end_op>
    return -1;
    80005552:	557d                	li	a0,-1
    80005554:	bfcd                	j	80005546 <sys_mknod+0x50>

0000000080005556 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005556:	7135                	addi	sp,sp,-160
    80005558:	ed06                	sd	ra,152(sp)
    8000555a:	e922                	sd	s0,144(sp)
    8000555c:	e14a                	sd	s2,128(sp)
    8000555e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005560:	c1efc0ef          	jal	8000197e <myproc>
    80005564:	892a                	mv	s2,a0

  begin_op();
    80005566:	921fe0ef          	jal	80003e86 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    8000556a:	08000613          	li	a2,128
    8000556e:	f6040593          	addi	a1,s0,-160
    80005572:	4501                	li	a0,0
    80005574:	c00fd0ef          	jal	80002974 <argstr>
    80005578:	04054363          	bltz	a0,800055be <sys_chdir+0x68>
    8000557c:	e526                	sd	s1,136(sp)
    8000557e:	f6040513          	addi	a0,s0,-160
    80005582:	f2afe0ef          	jal	80003cac <namei>
    80005586:	84aa                	mv	s1,a0
    80005588:	c915                	beqz	a0,800055bc <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000558a:	e9bfd0ef          	jal	80003424 <ilock>
  if (ip->type != T_DIR) {
    8000558e:	04449703          	lh	a4,68(s1)
    80005592:	4785                	li	a5,1
    80005594:	02f71963          	bne	a4,a5,800055c6 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005598:	8526                	mv	a0,s1
    8000559a:	f39fd0ef          	jal	800034d2 <iunlock>
  iput(p->cwd);
    8000559e:	15893503          	ld	a0,344(s2)
    800055a2:	804fe0ef          	jal	800035a6 <iput>
  end_op();
    800055a6:	967fe0ef          	jal	80003f0c <end_op>
  p->cwd = ip;
    800055aa:	14993c23          	sd	s1,344(s2)
  return 0;
    800055ae:	4501                	li	a0,0
    800055b0:	64aa                	ld	s1,136(sp)
}
    800055b2:	60ea                	ld	ra,152(sp)
    800055b4:	644a                	ld	s0,144(sp)
    800055b6:	690a                	ld	s2,128(sp)
    800055b8:	610d                	addi	sp,sp,160
    800055ba:	8082                	ret
    800055bc:	64aa                	ld	s1,136(sp)
    end_op();
    800055be:	94ffe0ef          	jal	80003f0c <end_op>
    return -1;
    800055c2:	557d                	li	a0,-1
    800055c4:	b7fd                	j	800055b2 <sys_chdir+0x5c>
    iunlockput(ip);
    800055c6:	8526                	mv	a0,s1
    800055c8:	8aefe0ef          	jal	80003676 <iunlockput>
    end_op();
    800055cc:	941fe0ef          	jal	80003f0c <end_op>
    return -1;
    800055d0:	557d                	li	a0,-1
    800055d2:	64aa                	ld	s1,136(sp)
    800055d4:	bff9                	j	800055b2 <sys_chdir+0x5c>

00000000800055d6 <sys_exec>:

uint64
sys_exec(void)
{
    800055d6:	7105                	addi	sp,sp,-480
    800055d8:	ef86                	sd	ra,472(sp)
    800055da:	eba2                	sd	s0,464(sp)
    800055dc:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800055de:	e2840593          	addi	a1,s0,-472
    800055e2:	4505                	li	a0,1
    800055e4:	b74fd0ef          	jal	80002958 <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    800055e8:	08000613          	li	a2,128
    800055ec:	f3040593          	addi	a1,s0,-208
    800055f0:	4501                	li	a0,0
    800055f2:	b82fd0ef          	jal	80002974 <argstr>
    800055f6:	87aa                	mv	a5,a0
    return -1;
    800055f8:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    800055fa:	0e07c063          	bltz	a5,800056da <sys_exec+0x104>
    800055fe:	e7a6                	sd	s1,456(sp)
    80005600:	e3ca                	sd	s2,448(sp)
    80005602:	ff4e                	sd	s3,440(sp)
    80005604:	fb52                	sd	s4,432(sp)
    80005606:	f756                	sd	s5,424(sp)
    80005608:	f35a                	sd	s6,416(sp)
    8000560a:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000560c:	e3040a13          	addi	s4,s0,-464
    80005610:	10000613          	li	a2,256
    80005614:	4581                	li	a1,0
    80005616:	8552                	mv	a0,s4
    80005618:	e34fb0ef          	jal	80000c4c <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    8000561c:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    8000561e:	89d2                	mv	s3,s4
    80005620:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    80005622:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005626:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    80005628:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    8000562c:	00391513          	slli	a0,s2,0x3
    80005630:	85d6                	mv	a1,s5
    80005632:	e2843783          	ld	a5,-472(s0)
    80005636:	953e                	add	a0,a0,a5
    80005638:	a78fd0ef          	jal	800028b0 <fetchaddr>
    8000563c:	02054663          	bltz	a0,80005668 <sys_exec+0x92>
    if (uarg == 0) {
    80005640:	e2043783          	ld	a5,-480(s0)
    80005644:	c7a1                	beqz	a5,8000568c <sys_exec+0xb6>
    argv[i] = kalloc();
    80005646:	c7cfb0ef          	jal	80000ac2 <kalloc>
    8000564a:	85aa                	mv	a1,a0
    8000564c:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    80005650:	cd01                	beqz	a0,80005668 <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005652:	865a                	mv	a2,s6
    80005654:	e2043503          	ld	a0,-480(s0)
    80005658:	aa2fd0ef          	jal	800028fa <fetchstr>
    8000565c:	00054663          	bltz	a0,80005668 <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    80005660:	0905                	addi	s2,s2,1
    80005662:	09a1                	addi	s3,s3,8
    80005664:	fd7914e3          	bne	s2,s7,8000562c <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005668:	100a0a13          	addi	s4,s4,256 # fffffffffffff100 <end+0xffffffff7ffde310>
    8000566c:	6088                	ld	a0,0(s1)
    8000566e:	cd31                	beqz	a0,800056ca <sys_exec+0xf4>
    kfree(argv[i]);
    80005670:	b70fb0ef          	jal	800009e0 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005674:	04a1                	addi	s1,s1,8
    80005676:	ff449be3          	bne	s1,s4,8000566c <sys_exec+0x96>
  return -1;
    8000567a:	557d                	li	a0,-1
    8000567c:	64be                	ld	s1,456(sp)
    8000567e:	691e                	ld	s2,448(sp)
    80005680:	79fa                	ld	s3,440(sp)
    80005682:	7a5a                	ld	s4,432(sp)
    80005684:	7aba                	ld	s5,424(sp)
    80005686:	7b1a                	ld	s6,416(sp)
    80005688:	6bfa                	ld	s7,408(sp)
    8000568a:	a881                	j	800056da <sys_exec+0x104>
      argv[i] = 0;
    8000568c:	0009079b          	sext.w	a5,s2
    80005690:	e3040593          	addi	a1,s0,-464
    80005694:	078e                	slli	a5,a5,0x3
    80005696:	97ae                	add	a5,a5,a1
    80005698:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    8000569c:	f3040513          	addi	a0,s0,-208
    800056a0:	b20ff0ef          	jal	800049c0 <kexec>
    800056a4:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800056a6:	100a0a13          	addi	s4,s4,256
    800056aa:	6088                	ld	a0,0(s1)
    800056ac:	c511                	beqz	a0,800056b8 <sys_exec+0xe2>
    kfree(argv[i]);
    800056ae:	b32fb0ef          	jal	800009e0 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800056b2:	04a1                	addi	s1,s1,8
    800056b4:	ff449be3          	bne	s1,s4,800056aa <sys_exec+0xd4>
  return ret;
    800056b8:	854a                	mv	a0,s2
    800056ba:	64be                	ld	s1,456(sp)
    800056bc:	691e                	ld	s2,448(sp)
    800056be:	79fa                	ld	s3,440(sp)
    800056c0:	7a5a                	ld	s4,432(sp)
    800056c2:	7aba                	ld	s5,424(sp)
    800056c4:	7b1a                	ld	s6,416(sp)
    800056c6:	6bfa                	ld	s7,408(sp)
    800056c8:	a809                	j	800056da <sys_exec+0x104>
  return -1;
    800056ca:	557d                	li	a0,-1
    800056cc:	64be                	ld	s1,456(sp)
    800056ce:	691e                	ld	s2,448(sp)
    800056d0:	79fa                	ld	s3,440(sp)
    800056d2:	7a5a                	ld	s4,432(sp)
    800056d4:	7aba                	ld	s5,424(sp)
    800056d6:	7b1a                	ld	s6,416(sp)
    800056d8:	6bfa                	ld	s7,408(sp)
}
    800056da:	60fe                	ld	ra,472(sp)
    800056dc:	645e                	ld	s0,464(sp)
    800056de:	613d                	addi	sp,sp,480
    800056e0:	8082                	ret

00000000800056e2 <sys_pipe>:

uint64
sys_pipe(void)
{
    800056e2:	7139                	addi	sp,sp,-64
    800056e4:	fc06                	sd	ra,56(sp)
    800056e6:	f822                	sd	s0,48(sp)
    800056e8:	f426                	sd	s1,40(sp)
    800056ea:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800056ec:	a92fc0ef          	jal	8000197e <myproc>
    800056f0:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800056f2:	fd840593          	addi	a1,s0,-40
    800056f6:	4501                	li	a0,0
    800056f8:	a60fd0ef          	jal	80002958 <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    800056fc:	fc840593          	addi	a1,s0,-56
    80005700:	fd040513          	addi	a0,s0,-48
    80005704:	f5bfe0ef          	jal	8000465e <pipealloc>
    return -1;
    80005708:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    8000570a:	0a054663          	bltz	a0,800057b6 <sys_pipe+0xd4>
  fd0 = -1;
    8000570e:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    80005712:	fd043503          	ld	a0,-48(s0)
    80005716:	e58ff0ef          	jal	80004d6e <fdalloc>
    8000571a:	fca42223          	sw	a0,-60(s0)
    8000571e:	08054363          	bltz	a0,800057a4 <sys_pipe+0xc2>
    80005722:	fc843503          	ld	a0,-56(s0)
    80005726:	e48ff0ef          	jal	80004d6e <fdalloc>
    8000572a:	fca42023          	sw	a0,-64(s0)
    8000572e:	06054263          	bltz	a0,80005792 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005732:	4711                	li	a4,4
    80005734:	fc440693          	addi	a3,s0,-60
    80005738:	fd843603          	ld	a2,-40(s0)
    8000573c:	64ac                	ld	a1,72(s1)
    8000573e:	68a8                	ld	a0,80(s1)
    80005740:	ea1fb0ef          	jal	800015e0 <copyout>
    80005744:	00054f63          	bltz	a0,80005762 <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    80005748:	4711                	li	a4,4
    8000574a:	fc040693          	addi	a3,s0,-64
    8000574e:	fd843603          	ld	a2,-40(s0)
    80005752:	963a                	add	a2,a2,a4
    80005754:	64ac                	ld	a1,72(s1)
    80005756:	68a8                	ld	a0,80(s1)
    80005758:	e89fb0ef          	jal	800015e0 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000575c:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    8000575e:	04055c63          	bgez	a0,800057b6 <sys_pipe+0xd4>
    p->ofile[fd0] = 0;
    80005762:	fc442783          	lw	a5,-60(s0)
    80005766:	07e9                	addi	a5,a5,26
    80005768:	078e                	slli	a5,a5,0x3
    8000576a:	97a6                	add	a5,a5,s1
    8000576c:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005770:	fc042783          	lw	a5,-64(s0)
    80005774:	07e9                	addi	a5,a5,26
    80005776:	078e                	slli	a5,a5,0x3
    80005778:	94be                	add	s1,s1,a5
    8000577a:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    8000577e:	fd043503          	ld	a0,-48(s0)
    80005782:	bb7fe0ef          	jal	80004338 <fileclose>
    fileclose(wf);
    80005786:	fc843503          	ld	a0,-56(s0)
    8000578a:	baffe0ef          	jal	80004338 <fileclose>
    return -1;
    8000578e:	57fd                	li	a5,-1
    80005790:	a01d                	j	800057b6 <sys_pipe+0xd4>
    if (fd0 >= 0)
    80005792:	fc442783          	lw	a5,-60(s0)
    80005796:	0007c763          	bltz	a5,800057a4 <sys_pipe+0xc2>
      p->ofile[fd0] = 0;
    8000579a:	07e9                	addi	a5,a5,26
    8000579c:	078e                	slli	a5,a5,0x3
    8000579e:	97a6                	add	a5,a5,s1
    800057a0:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    800057a4:	fd043503          	ld	a0,-48(s0)
    800057a8:	b91fe0ef          	jal	80004338 <fileclose>
    fileclose(wf);
    800057ac:	fc843503          	ld	a0,-56(s0)
    800057b0:	b89fe0ef          	jal	80004338 <fileclose>
    return -1;
    800057b4:	57fd                	li	a5,-1
}
    800057b6:	853e                	mv	a0,a5
    800057b8:	70e2                	ld	ra,56(sp)
    800057ba:	7442                	ld	s0,48(sp)
    800057bc:	74a2                	ld	s1,40(sp)
    800057be:	6121                	addi	sp,sp,64
    800057c0:	8082                	ret
	...

00000000800057d0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800057d0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800057d2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800057d4:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    800057d6:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800057d8:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800057da:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800057dc:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800057de:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800057e0:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800057e2:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800057e4:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800057e6:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800057e8:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800057ea:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800057ec:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800057ee:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800057f0:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800057f2:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800057f4:	fcdfc0ef          	jal	800027c0 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800057f8:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800057fa:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800057fc:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800057fe:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005800:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005802:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005804:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005806:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005808:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000580a:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000580c:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    8000580e:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005810:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005812:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005814:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005816:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005818:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000581a:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000581c:	10200073          	sret
    80005820:	0001                	nop
    80005822:	00000013          	nop
    80005826:	00000013          	nop
    8000582a:	00000013          	nop

000000008000582e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000582e:	1141                	addi	sp,sp,-16
    80005830:	e406                	sd	ra,8(sp)
    80005832:	e022                	sd	s0,0(sp)
    80005834:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80005836:	0c000737          	lui	a4,0xc000
    8000583a:	4785                	li	a5,1
    8000583c:	d71c                	sw	a5,40(a4)
  *(uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    8000583e:	c35c                	sw	a5,4(a4)
}
    80005840:	60a2                	ld	ra,8(sp)
    80005842:	6402                	ld	s0,0(sp)
    80005844:	0141                	addi	sp,sp,16
    80005846:	8082                	ret

0000000080005848 <plicinithart>:

void
plicinithart(void)
{
    80005848:	1141                	addi	sp,sp,-16
    8000584a:	e406                	sd	ra,8(sp)
    8000584c:	e022                	sd	s0,0(sp)
    8000584e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005850:	8fafc0ef          	jal	8000194a <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32 *)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005854:	0085171b          	slliw	a4,a0,0x8
    80005858:	0c0027b7          	lui	a5,0xc002
    8000585c:	97ba                	add	a5,a5,a4
    8000585e:	40200713          	li	a4,1026
    80005862:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005866:	00d5151b          	slliw	a0,a0,0xd
    8000586a:	0c2017b7          	lui	a5,0xc201
    8000586e:	97aa                	add	a5,a5,a0
    80005870:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005874:	60a2                	ld	ra,8(sp)
    80005876:	6402                	ld	s0,0(sp)
    80005878:	0141                	addi	sp,sp,16
    8000587a:	8082                	ret

000000008000587c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000587c:	1141                	addi	sp,sp,-16
    8000587e:	e406                	sd	ra,8(sp)
    80005880:	e022                	sd	s0,0(sp)
    80005882:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005884:	8c6fc0ef          	jal	8000194a <cpuid>
  int irq = *(uint32 *)PLIC_SCLAIM(hart);
    80005888:	00d5151b          	slliw	a0,a0,0xd
    8000588c:	0c2017b7          	lui	a5,0xc201
    80005890:	97aa                	add	a5,a5,a0
  return irq;
}
    80005892:	43c8                	lw	a0,4(a5)
    80005894:	60a2                	ld	ra,8(sp)
    80005896:	6402                	ld	s0,0(sp)
    80005898:	0141                	addi	sp,sp,16
    8000589a:	8082                	ret

000000008000589c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000589c:	1101                	addi	sp,sp,-32
    8000589e:	ec06                	sd	ra,24(sp)
    800058a0:	e822                	sd	s0,16(sp)
    800058a2:	e426                	sd	s1,8(sp)
    800058a4:	1000                	addi	s0,sp,32
    800058a6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800058a8:	8a2fc0ef          	jal	8000194a <cpuid>
  *(uint32 *)PLIC_SCLAIM(hart) = irq;
    800058ac:	00d5179b          	slliw	a5,a0,0xd
    800058b0:	0c201737          	lui	a4,0xc201
    800058b4:	97ba                	add	a5,a5,a4
    800058b6:	c3c4                	sw	s1,4(a5)
}
    800058b8:	60e2                	ld	ra,24(sp)
    800058ba:	6442                	ld	s0,16(sp)
    800058bc:	64a2                	ld	s1,8(sp)
    800058be:	6105                	addi	sp,sp,32
    800058c0:	8082                	ret

00000000800058c2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800058c2:	1141                	addi	sp,sp,-16
    800058c4:	e406                	sd	ra,8(sp)
    800058c6:	e022                	sd	s0,0(sp)
    800058c8:	0800                	addi	s0,sp,16
  if (i >= NUM)
    800058ca:	479d                	li	a5,7
    800058cc:	04a7ca63          	blt	a5,a0,80005920 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    800058d0:	0001b797          	auipc	a5,0x1b
    800058d4:	3e078793          	addi	a5,a5,992 # 80020cb0 <disk>
    800058d8:	97aa                	add	a5,a5,a0
    800058da:	0187c783          	lbu	a5,24(a5)
    800058de:	e7b9                	bnez	a5,8000592c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800058e0:	00451693          	slli	a3,a0,0x4
    800058e4:	0001b797          	auipc	a5,0x1b
    800058e8:	3cc78793          	addi	a5,a5,972 # 80020cb0 <disk>
    800058ec:	6398                	ld	a4,0(a5)
    800058ee:	9736                	add	a4,a4,a3
    800058f0:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    800058f4:	6398                	ld	a4,0(a5)
    800058f6:	9736                	add	a4,a4,a3
    800058f8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800058fc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005900:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005904:	97aa                	add	a5,a5,a0
    80005906:	4705                	li	a4,1
    80005908:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000590c:	0001b517          	auipc	a0,0x1b
    80005910:	3bc50513          	addi	a0,a0,956 # 80020cc8 <disk+0x18>
    80005914:	f60fc0ef          	jal	80002074 <wakeup>
}
    80005918:	60a2                	ld	ra,8(sp)
    8000591a:	6402                	ld	s0,0(sp)
    8000591c:	0141                	addi	sp,sp,16
    8000591e:	8082                	ret
    panic("free_desc 1");
    80005920:	00002517          	auipc	a0,0x2
    80005924:	d4050513          	addi	a0,a0,-704 # 80007660 <etext+0x660>
    80005928:	ec7fa0ef          	jal	800007ee <panic>
    panic("free_desc 2");
    8000592c:	00002517          	auipc	a0,0x2
    80005930:	d4450513          	addi	a0,a0,-700 # 80007670 <etext+0x670>
    80005934:	ebbfa0ef          	jal	800007ee <panic>

0000000080005938 <virtio_disk_init>:
{
    80005938:	1101                	addi	sp,sp,-32
    8000593a:	ec06                	sd	ra,24(sp)
    8000593c:	e822                	sd	s0,16(sp)
    8000593e:	e426                	sd	s1,8(sp)
    80005940:	e04a                	sd	s2,0(sp)
    80005942:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005944:	00002597          	auipc	a1,0x2
    80005948:	d3c58593          	addi	a1,a1,-708 # 80007680 <etext+0x680>
    8000594c:	0001b517          	auipc	a0,0x1b
    80005950:	48c50513          	addi	a0,a0,1164 # 80020dd8 <disk+0x128>
    80005954:	9befb0ef          	jal	80000b12 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005958:	100017b7          	lui	a5,0x10001
    8000595c:	4398                	lw	a4,0(a5)
    8000595e:	2701                	sext.w	a4,a4
    80005960:	747277b7          	lui	a5,0x74727
    80005964:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005968:	14f71863          	bne	a4,a5,80005ab8 <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000596c:	100017b7          	lui	a5,0x10001
    80005970:	43dc                	lw	a5,4(a5)
    80005972:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005974:	4709                	li	a4,2
    80005976:	14e79163          	bne	a5,a4,80005ab8 <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000597a:	100017b7          	lui	a5,0x10001
    8000597e:	479c                	lw	a5,8(a5)
    80005980:	2781                	sext.w	a5,a5
    80005982:	12e79b63          	bne	a5,a4,80005ab8 <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    80005986:	100017b7          	lui	a5,0x10001
    8000598a:	47d8                	lw	a4,12(a5)
    8000598c:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000598e:	554d47b7          	lui	a5,0x554d4
    80005992:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005996:	12f71163          	bne	a4,a5,80005ab8 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000599a:	100017b7          	lui	a5,0x10001
    8000599e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800059a2:	4705                	li	a4,1
    800059a4:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800059a6:	470d                	li	a4,3
    800059a8:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800059aa:	10001737          	lui	a4,0x10001
    800059ae:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800059b0:	c7ffe6b7          	lui	a3,0xc7ffe
    800059b4:	55f68693          	addi	a3,a3,1375 # ffffffffc7ffe55f <end+0xffffffff47fdd76f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800059b8:	8f75                	and	a4,a4,a3
    800059ba:	100016b7          	lui	a3,0x10001
    800059be:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800059c0:	472d                	li	a4,11
    800059c2:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800059c4:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800059c8:	439c                	lw	a5,0(a5)
    800059ca:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800059ce:	8ba1                	andi	a5,a5,8
    800059d0:	0e078a63          	beqz	a5,80005ac4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800059d4:	100017b7          	lui	a5,0x10001
    800059d8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    800059dc:	43fc                	lw	a5,68(a5)
    800059de:	2781                	sext.w	a5,a5
    800059e0:	0e079863          	bnez	a5,80005ad0 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800059e4:	100017b7          	lui	a5,0x10001
    800059e8:	5bdc                	lw	a5,52(a5)
    800059ea:	2781                	sext.w	a5,a5
  if (max == 0)
    800059ec:	0e078863          	beqz	a5,80005adc <virtio_disk_init+0x1a4>
  if (max < NUM)
    800059f0:	471d                	li	a4,7
    800059f2:	0ef77b63          	bgeu	a4,a5,80005ae8 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    800059f6:	8ccfb0ef          	jal	80000ac2 <kalloc>
    800059fa:	0001b497          	auipc	s1,0x1b
    800059fe:	2b648493          	addi	s1,s1,694 # 80020cb0 <disk>
    80005a02:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005a04:	8befb0ef          	jal	80000ac2 <kalloc>
    80005a08:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005a0a:	8b8fb0ef          	jal	80000ac2 <kalloc>
    80005a0e:	87aa                	mv	a5,a0
    80005a10:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    80005a12:	6088                	ld	a0,0(s1)
    80005a14:	0e050063          	beqz	a0,80005af4 <virtio_disk_init+0x1bc>
    80005a18:	0001b717          	auipc	a4,0x1b
    80005a1c:	2a073703          	ld	a4,672(a4) # 80020cb8 <disk+0x8>
    80005a20:	cb71                	beqz	a4,80005af4 <virtio_disk_init+0x1bc>
    80005a22:	cbe9                	beqz	a5,80005af4 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005a24:	6605                	lui	a2,0x1
    80005a26:	4581                	li	a1,0
    80005a28:	a24fb0ef          	jal	80000c4c <memset>
  memset(disk.avail, 0, PGSIZE);
    80005a2c:	0001b497          	auipc	s1,0x1b
    80005a30:	28448493          	addi	s1,s1,644 # 80020cb0 <disk>
    80005a34:	6605                	lui	a2,0x1
    80005a36:	4581                	li	a1,0
    80005a38:	6488                	ld	a0,8(s1)
    80005a3a:	a12fb0ef          	jal	80000c4c <memset>
  memset(disk.used, 0, PGSIZE);
    80005a3e:	6605                	lui	a2,0x1
    80005a40:	4581                	li	a1,0
    80005a42:	6888                	ld	a0,16(s1)
    80005a44:	a08fb0ef          	jal	80000c4c <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005a48:	100017b7          	lui	a5,0x10001
    80005a4c:	4721                	li	a4,8
    80005a4e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005a50:	4098                	lw	a4,0(s1)
    80005a52:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005a56:	40d8                	lw	a4,4(s1)
    80005a58:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005a5c:	649c                	ld	a5,8(s1)
    80005a5e:	0007869b          	sext.w	a3,a5
    80005a62:	10001737          	lui	a4,0x10001
    80005a66:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005a6a:	9781                	srai	a5,a5,0x20
    80005a6c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005a70:	689c                	ld	a5,16(s1)
    80005a72:	0007869b          	sext.w	a3,a5
    80005a76:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005a7a:	9781                	srai	a5,a5,0x20
    80005a7c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005a80:	4785                	li	a5,1
    80005a82:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005a84:	00f48c23          	sb	a5,24(s1)
    80005a88:	00f48ca3          	sb	a5,25(s1)
    80005a8c:	00f48d23          	sb	a5,26(s1)
    80005a90:	00f48da3          	sb	a5,27(s1)
    80005a94:	00f48e23          	sb	a5,28(s1)
    80005a98:	00f48ea3          	sb	a5,29(s1)
    80005a9c:	00f48f23          	sb	a5,30(s1)
    80005aa0:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005aa4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005aa8:	07272823          	sw	s2,112(a4)
}
    80005aac:	60e2                	ld	ra,24(sp)
    80005aae:	6442                	ld	s0,16(sp)
    80005ab0:	64a2                	ld	s1,8(sp)
    80005ab2:	6902                	ld	s2,0(sp)
    80005ab4:	6105                	addi	sp,sp,32
    80005ab6:	8082                	ret
    panic("could not find virtio disk");
    80005ab8:	00002517          	auipc	a0,0x2
    80005abc:	bd850513          	addi	a0,a0,-1064 # 80007690 <etext+0x690>
    80005ac0:	d2ffa0ef          	jal	800007ee <panic>
    panic("virtio disk FEATURES_OK unset");
    80005ac4:	00002517          	auipc	a0,0x2
    80005ac8:	bec50513          	addi	a0,a0,-1044 # 800076b0 <etext+0x6b0>
    80005acc:	d23fa0ef          	jal	800007ee <panic>
    panic("virtio disk should not be ready");
    80005ad0:	00002517          	auipc	a0,0x2
    80005ad4:	c0050513          	addi	a0,a0,-1024 # 800076d0 <etext+0x6d0>
    80005ad8:	d17fa0ef          	jal	800007ee <panic>
    panic("virtio disk has no queue 0");
    80005adc:	00002517          	auipc	a0,0x2
    80005ae0:	c1450513          	addi	a0,a0,-1004 # 800076f0 <etext+0x6f0>
    80005ae4:	d0bfa0ef          	jal	800007ee <panic>
    panic("virtio disk max queue too short");
    80005ae8:	00002517          	auipc	a0,0x2
    80005aec:	c2850513          	addi	a0,a0,-984 # 80007710 <etext+0x710>
    80005af0:	cfffa0ef          	jal	800007ee <panic>
    panic("virtio disk kalloc");
    80005af4:	00002517          	auipc	a0,0x2
    80005af8:	c3c50513          	addi	a0,a0,-964 # 80007730 <etext+0x730>
    80005afc:	cf3fa0ef          	jal	800007ee <panic>

0000000080005b00 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005b00:	711d                	addi	sp,sp,-96
    80005b02:	ec86                	sd	ra,88(sp)
    80005b04:	e8a2                	sd	s0,80(sp)
    80005b06:	e4a6                	sd	s1,72(sp)
    80005b08:	e0ca                	sd	s2,64(sp)
    80005b0a:	fc4e                	sd	s3,56(sp)
    80005b0c:	f852                	sd	s4,48(sp)
    80005b0e:	f456                	sd	s5,40(sp)
    80005b10:	f05a                	sd	s6,32(sp)
    80005b12:	ec5e                	sd	s7,24(sp)
    80005b14:	e862                	sd	s8,16(sp)
    80005b16:	1080                	addi	s0,sp,96
    80005b18:	89aa                	mv	s3,a0
    80005b1a:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005b1c:	00c52b83          	lw	s7,12(a0)
    80005b20:	001b9b9b          	slliw	s7,s7,0x1
    80005b24:	1b82                	slli	s7,s7,0x20
    80005b26:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005b2a:	0001b517          	auipc	a0,0x1b
    80005b2e:	2ae50513          	addi	a0,a0,686 # 80020dd8 <disk+0x128>
    80005b32:	85afb0ef          	jal	80000b8c <acquire>
  for (int i = 0; i < NUM; i++) {
    80005b36:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005b38:	0001ba97          	auipc	s5,0x1b
    80005b3c:	178a8a93          	addi	s5,s5,376 # 80020cb0 <disk>
  for (int i = 0; i < 3; i++) {
    80005b40:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005b42:	5c7d                	li	s8,-1
    80005b44:	a895                	j	80005bb8 <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80005b46:	00fa8733          	add	a4,s5,a5
    80005b4a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005b4e:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    80005b50:	0207c563          	bltz	a5,80005b7a <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    80005b54:	2905                	addiw	s2,s2,1
    80005b56:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005b58:	07490463          	beq	s2,s4,80005bc0 <virtio_disk_rw+0xc0>
    idx[i] = alloc_desc();
    80005b5c:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    80005b5e:	0001b717          	auipc	a4,0x1b
    80005b62:	15270713          	addi	a4,a4,338 # 80020cb0 <disk>
    80005b66:	4781                	li	a5,0
    if (disk.free[i]) {
    80005b68:	01874683          	lbu	a3,24(a4)
    80005b6c:	fee9                	bnez	a3,80005b46 <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    80005b6e:	2785                	addiw	a5,a5,1
    80005b70:	0705                	addi	a4,a4,1
    80005b72:	fe979be3          	bne	a5,s1,80005b68 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005b76:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    80005b7a:	01205d63          	blez	s2,80005b94 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005b7e:	fa042503          	lw	a0,-96(s0)
    80005b82:	d41ff0ef          	jal	800058c2 <free_desc>
      for (int j = 0; j < i; j++)
    80005b86:	4785                	li	a5,1
    80005b88:	0127d663          	bge	a5,s2,80005b94 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005b8c:	fa442503          	lw	a0,-92(s0)
    80005b90:	d33ff0ef          	jal	800058c2 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005b94:	0001b517          	auipc	a0,0x1b
    80005b98:	13450513          	addi	a0,a0,308 # 80020cc8 <disk+0x18>
    80005b9c:	c6cfc0ef          	jal	80002008 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005ba0:	0001b917          	auipc	s2,0x1b
    80005ba4:	23890913          	addi	s2,s2,568 # 80020dd8 <disk+0x128>
    80005ba8:	854a                	mv	a0,s2
    80005baa:	86afb0ef          	jal	80000c14 <release>
    sleep();
    80005bae:	c96fc0ef          	jal	80002044 <sleep>
    acquire(&disk.vdisk_lock);
    80005bb2:	854a                	mv	a0,s2
    80005bb4:	fd9fa0ef          	jal	80000b8c <acquire>
  for (int i = 0; i < 3; i++) {
    80005bb8:	fa040613          	addi	a2,s0,-96
    80005bbc:	4901                	li	s2,0
    80005bbe:	bf79                	j	80005b5c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005bc0:	fa042503          	lw	a0,-96(s0)
    80005bc4:	00451693          	slli	a3,a0,0x4

  if (write)
    80005bc8:	0001b797          	auipc	a5,0x1b
    80005bcc:	0e878793          	addi	a5,a5,232 # 80020cb0 <disk>
    80005bd0:	00a50713          	addi	a4,a0,10
    80005bd4:	0712                	slli	a4,a4,0x4
    80005bd6:	973e                	add	a4,a4,a5
    80005bd8:	01603633          	snez	a2,s6
    80005bdc:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005bde:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005be2:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005be6:	6398                	ld	a4,0(a5)
    80005be8:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005bea:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005bee:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005bf0:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005bf2:	6390                	ld	a2,0(a5)
    80005bf4:	00d605b3          	add	a1,a2,a3
    80005bf8:	4741                	li	a4,16
    80005bfa:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005bfc:	4805                	li	a6,1
    80005bfe:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005c02:	fa442703          	lw	a4,-92(s0)
    80005c06:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005c0a:	0712                	slli	a4,a4,0x4
    80005c0c:	963a                	add	a2,a2,a4
    80005c0e:	05898593          	addi	a1,s3,88
    80005c12:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005c14:	0007b883          	ld	a7,0(a5)
    80005c18:	9746                	add	a4,a4,a7
    80005c1a:	40000613          	li	a2,1024
    80005c1e:	c710                	sw	a2,8(a4)
  if (write)
    80005c20:	001b3613          	seqz	a2,s6
    80005c24:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005c28:	01066633          	or	a2,a2,a6
    80005c2c:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005c30:	fa842583          	lw	a1,-88(s0)
    80005c34:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005c38:	00250613          	addi	a2,a0,2
    80005c3c:	0612                	slli	a2,a2,0x4
    80005c3e:	963e                	add	a2,a2,a5
    80005c40:	577d                	li	a4,-1
    80005c42:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005c46:	0592                	slli	a1,a1,0x4
    80005c48:	98ae                	add	a7,a7,a1
    80005c4a:	03068713          	addi	a4,a3,48
    80005c4e:	973e                	add	a4,a4,a5
    80005c50:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005c54:	6398                	ld	a4,0(a5)
    80005c56:	972e                	add	a4,a4,a1
    80005c58:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005c5c:	4689                	li	a3,2
    80005c5e:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005c62:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005c66:	0109a223          	sw	a6,4(s3)
  disk.info[idx[0]].b = b;
    80005c6a:	01363423          	sd	s3,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005c6e:	6794                	ld	a3,8(a5)
    80005c70:	0026d703          	lhu	a4,2(a3)
    80005c74:	8b1d                	andi	a4,a4,7
    80005c76:	0706                	slli	a4,a4,0x1
    80005c78:	96ba                	add	a3,a3,a4
    80005c7a:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005c7e:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005c82:	6798                	ld	a4,8(a5)
    80005c84:	00275783          	lhu	a5,2(a4)
    80005c88:	2785                	addiw	a5,a5,1
    80005c8a:	00f71123          	sh	a5,2(a4)
    80005c8e:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005c92:	100017b7          	lui	a5,0x10001
    80005c96:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005c9a:	0049a783          	lw	a5,4(s3)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005c9e:	0001b497          	auipc	s1,0x1b
    80005ca2:	13a48493          	addi	s1,s1,314 # 80020dd8 <disk+0x128>
  while (b->disk == 1) {
    80005ca6:	8942                	mv	s2,a6
    80005ca8:	03079163          	bne	a5,a6,80005cca <virtio_disk_rw+0x1ca>
    sleep_prepare(b);
    80005cac:	854e                	mv	a0,s3
    80005cae:	b5afc0ef          	jal	80002008 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005cb2:	8526                	mv	a0,s1
    80005cb4:	f61fa0ef          	jal	80000c14 <release>
    sleep();
    80005cb8:	b8cfc0ef          	jal	80002044 <sleep>
    acquire(&disk.vdisk_lock);
    80005cbc:	8526                	mv	a0,s1
    80005cbe:	ecffa0ef          	jal	80000b8c <acquire>
  while (b->disk == 1) {
    80005cc2:	0049a783          	lw	a5,4(s3)
    80005cc6:	ff2783e3          	beq	a5,s2,80005cac <virtio_disk_rw+0x1ac>
  }

  disk.info[idx[0]].b = 0;
    80005cca:	fa042903          	lw	s2,-96(s0)
    80005cce:	00290713          	addi	a4,s2,2
    80005cd2:	0712                	slli	a4,a4,0x4
    80005cd4:	0001b797          	auipc	a5,0x1b
    80005cd8:	fdc78793          	addi	a5,a5,-36 # 80020cb0 <disk>
    80005cdc:	97ba                	add	a5,a5,a4
    80005cde:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005ce2:	0001b997          	auipc	s3,0x1b
    80005ce6:	fce98993          	addi	s3,s3,-50 # 80020cb0 <disk>
    80005cea:	00491713          	slli	a4,s2,0x4
    80005cee:	0009b783          	ld	a5,0(s3)
    80005cf2:	97ba                	add	a5,a5,a4
    80005cf4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005cf8:	854a                	mv	a0,s2
    80005cfa:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005cfe:	bc5ff0ef          	jal	800058c2 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005d02:	8885                	andi	s1,s1,1
    80005d04:	f0fd                	bnez	s1,80005cea <virtio_disk_rw+0x1ea>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005d06:	0001b517          	auipc	a0,0x1b
    80005d0a:	0d250513          	addi	a0,a0,210 # 80020dd8 <disk+0x128>
    80005d0e:	f07fa0ef          	jal	80000c14 <release>
}
    80005d12:	60e6                	ld	ra,88(sp)
    80005d14:	6446                	ld	s0,80(sp)
    80005d16:	64a6                	ld	s1,72(sp)
    80005d18:	6906                	ld	s2,64(sp)
    80005d1a:	79e2                	ld	s3,56(sp)
    80005d1c:	7a42                	ld	s4,48(sp)
    80005d1e:	7aa2                	ld	s5,40(sp)
    80005d20:	7b02                	ld	s6,32(sp)
    80005d22:	6be2                	ld	s7,24(sp)
    80005d24:	6c42                	ld	s8,16(sp)
    80005d26:	6125                	addi	sp,sp,96
    80005d28:	8082                	ret

0000000080005d2a <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005d2a:	1101                	addi	sp,sp,-32
    80005d2c:	ec06                	sd	ra,24(sp)
    80005d2e:	e822                	sd	s0,16(sp)
    80005d30:	e426                	sd	s1,8(sp)
    80005d32:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005d34:	0001b497          	auipc	s1,0x1b
    80005d38:	f7c48493          	addi	s1,s1,-132 # 80020cb0 <disk>
    80005d3c:	0001b517          	auipc	a0,0x1b
    80005d40:	09c50513          	addi	a0,a0,156 # 80020dd8 <disk+0x128>
    80005d44:	e49fa0ef          	jal	80000b8c <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005d48:	100017b7          	lui	a5,0x10001
    80005d4c:	53bc                	lw	a5,96(a5)
    80005d4e:	8b8d                	andi	a5,a5,3
    80005d50:	10001737          	lui	a4,0x10001
    80005d54:	d37c                	sw	a5,100(a4)
    80005d56:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005d5a:	689c                	ld	a5,16(s1)
    80005d5c:	0204d703          	lhu	a4,32(s1)
    80005d60:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005d64:	04f70663          	beq	a4,a5,80005db0 <virtio_disk_intr+0x86>
    80005d68:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005d6c:	6898                	ld	a4,16(s1)
    80005d6e:	0204d783          	lhu	a5,32(s1)
    80005d72:	8b9d                	andi	a5,a5,7
    80005d74:	078e                	slli	a5,a5,0x3
    80005d76:	97ba                	add	a5,a5,a4
    80005d78:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005d7a:	00278713          	addi	a4,a5,2
    80005d7e:	0712                	slli	a4,a4,0x4
    80005d80:	9726                	add	a4,a4,s1
    80005d82:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005d86:	e321                	bnez	a4,80005dc6 <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005d88:	0789                	addi	a5,a5,2
    80005d8a:	0792                	slli	a5,a5,0x4
    80005d8c:	97a6                	add	a5,a5,s1
    80005d8e:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005d90:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005d94:	ae0fc0ef          	jal	80002074 <wakeup>

    disk.used_idx += 1;
    80005d98:	0204d783          	lhu	a5,32(s1)
    80005d9c:	2785                	addiw	a5,a5,1
    80005d9e:	17c2                	slli	a5,a5,0x30
    80005da0:	93c1                	srli	a5,a5,0x30
    80005da2:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005da6:	6898                	ld	a4,16(s1)
    80005da8:	00275703          	lhu	a4,2(a4)
    80005dac:	faf71ee3          	bne	a4,a5,80005d68 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005db0:	0001b517          	auipc	a0,0x1b
    80005db4:	02850513          	addi	a0,a0,40 # 80020dd8 <disk+0x128>
    80005db8:	e5dfa0ef          	jal	80000c14 <release>
}
    80005dbc:	60e2                	ld	ra,24(sp)
    80005dbe:	6442                	ld	s0,16(sp)
    80005dc0:	64a2                	ld	s1,8(sp)
    80005dc2:	6105                	addi	sp,sp,32
    80005dc4:	8082                	ret
      panic("virtio_disk_intr status");
    80005dc6:	00002517          	auipc	a0,0x2
    80005dca:	98250513          	addi	a0,a0,-1662 # 80007748 <etext+0x748>
    80005dce:	a21fa0ef          	jal	800007ee <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	0000100f          	fence.i
    800060a0:	12000073          	sfence.vma
    800060a4:	18051073          	csrw	satp,a0
    800060a8:	12000073          	sfence.vma
    800060ac:	02000537          	lui	a0,0x2000
    800060b0:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060b2:	0536                	slli	a0,a0,0xd
    800060b4:	02853083          	ld	ra,40(a0)
    800060b8:	03053103          	ld	sp,48(a0)
    800060bc:	03853183          	ld	gp,56(a0)
    800060c0:	04053203          	ld	tp,64(a0)
    800060c4:	04853283          	ld	t0,72(a0)
    800060c8:	05053303          	ld	t1,80(a0)
    800060cc:	05853383          	ld	t2,88(a0)
    800060d0:	7120                	ld	s0,96(a0)
    800060d2:	7524                	ld	s1,104(a0)
    800060d4:	7d2c                	ld	a1,120(a0)
    800060d6:	6150                	ld	a2,128(a0)
    800060d8:	6554                	ld	a3,136(a0)
    800060da:	6958                	ld	a4,144(a0)
    800060dc:	6d5c                	ld	a5,152(a0)
    800060de:	0a053803          	ld	a6,160(a0)
    800060e2:	0a853883          	ld	a7,168(a0)
    800060e6:	0b053903          	ld	s2,176(a0)
    800060ea:	0b853983          	ld	s3,184(a0)
    800060ee:	0c053a03          	ld	s4,192(a0)
    800060f2:	0c853a83          	ld	s5,200(a0)
    800060f6:	0d053b03          	ld	s6,208(a0)
    800060fa:	0d853b83          	ld	s7,216(a0)
    800060fe:	0e053c03          	ld	s8,224(a0)
    80006102:	0e853c83          	ld	s9,232(a0)
    80006106:	0f053d03          	ld	s10,240(a0)
    8000610a:	0f853d83          	ld	s11,248(a0)
    8000610e:	10053e03          	ld	t3,256(a0)
    80006112:	10853e83          	ld	t4,264(a0)
    80006116:	11053f03          	ld	t5,272(a0)
    8000611a:	11853f83          	ld	t6,280(a0)
    8000611e:	7928                	ld	a0,112(a0)
    80006120:	10200073          	sret
	...
