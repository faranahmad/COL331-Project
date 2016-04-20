
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 40 12 00       	mov    $0x124000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 30 12 f0       	mov    $0xf0123000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 ad 00 00 00       	call   f01000eb <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_paddr>:
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 18             	sub    $0x18,%esp
	if ((uint32_t)kva < KERNBASE)
f0100046:	8b 45 10             	mov    0x10(%ebp),%eax
f0100049:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010004e:	77 21                	ja     f0100071 <_paddr+0x31>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100050:	8b 45 10             	mov    0x10(%ebp),%eax
f0100053:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100057:	c7 44 24 08 c0 8c 10 	movl   $0xf0108cc0,0x8(%esp)
f010005e:	f0 
f010005f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100062:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100066:	8b 45 08             	mov    0x8(%ebp),%eax
f0100069:	89 04 24             	mov    %eax,(%esp)
f010006c:	e8 86 02 00 00       	call   f01002f7 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100071:	8b 45 10             	mov    0x10(%ebp),%eax
f0100074:	05 00 00 00 10       	add    $0x10000000,%eax
}
f0100079:	c9                   	leave  
f010007a:	c3                   	ret    

f010007b <_kaddr>:
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f010007b:	55                   	push   %ebp
f010007c:	89 e5                	mov    %esp,%ebp
f010007e:	83 ec 18             	sub    $0x18,%esp
	if (PGNUM(pa) >= npages)
f0100081:	8b 45 10             	mov    0x10(%ebp),%eax
f0100084:	c1 e8 0c             	shr    $0xc,%eax
f0100087:	89 c2                	mov    %eax,%edx
f0100089:	a1 e8 be 23 f0       	mov    0xf023bee8,%eax
f010008e:	39 c2                	cmp    %eax,%edx
f0100090:	72 21                	jb     f01000b3 <_kaddr+0x38>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100092:	8b 45 10             	mov    0x10(%ebp),%eax
f0100095:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100099:	c7 44 24 08 e4 8c 10 	movl   $0xf0108ce4,0x8(%esp)
f01000a0:	f0 
f01000a1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000a4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01000ab:	89 04 24             	mov    %eax,(%esp)
f01000ae:	e8 44 02 00 00       	call   f01002f7 <_panic>
	return (void *)(pa + KERNBASE);
f01000b3:	8b 45 10             	mov    0x10(%ebp),%eax
f01000b6:	2d 00 00 00 10       	sub    $0x10000000,%eax
}
f01000bb:	c9                   	leave  
f01000bc:	c3                   	ret    

f01000bd <xchg>:
	return tsc;
}

static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
f01000bd:	55                   	push   %ebp
f01000be:	89 e5                	mov    %esp,%ebp
f01000c0:	83 ec 10             	sub    $0x10,%esp
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01000c3:	8b 55 08             	mov    0x8(%ebp),%edx
f01000c6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01000cc:	f0 87 02             	lock xchg %eax,(%edx)
f01000cf:	89 45 fc             	mov    %eax,-0x4(%ebp)
			"+m" (*addr), "=a" (result) :
			"1" (newval) :
			"cc");
	return result;
f01000d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f01000d5:	c9                   	leave  
f01000d6:	c3                   	ret    

f01000d7 <lock_kernel>:

extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
f01000d7:	55                   	push   %ebp
f01000d8:	89 e5                	mov    %esp,%ebp
f01000da:	83 ec 18             	sub    $0x18,%esp
	spin_lock(&kernel_lock);
f01000dd:	c7 04 24 e0 55 12 f0 	movl   $0xf01255e0,(%esp)
f01000e4:	e8 58 87 00 00       	call   f0108841 <spin_lock>
}
f01000e9:	c9                   	leave  
f01000ea:	c3                   	ret    

f01000eb <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f01000eb:	55                   	push   %ebp
f01000ec:	89 e5                	mov    %esp,%ebp
f01000ee:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000f1:	ba 08 d0 27 f0       	mov    $0xf027d008,%edx
f01000f6:	b8 61 a9 23 f0       	mov    $0xf023a961,%eax
f01000fb:	29 c2                	sub    %eax,%edx
f01000fd:	89 d0                	mov    %edx,%eax
f01000ff:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100103:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010010a:	00 
f010010b:	c7 04 24 61 a9 23 f0 	movl   $0xf023a961,(%esp)
f0100112:	e8 e5 79 00 00       	call   f0107afc <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100117:	e8 4a 0a 00 00       	call   f0100b66 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010011c:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100123:	00 
f0100124:	c7 04 24 07 8d 10 f0 	movl   $0xf0108d07,(%esp)
f010012b:	e8 8f 4e 00 00       	call   f0104fbf <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100130:	e8 d3 11 00 00       	call   f0101308 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100135:	e8 88 42 00 00       	call   f01043c2 <env_init>
	trap_init();
f010013a:	e8 12 4f 00 00       	call   f0105051 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010013f:	e8 a9 80 00 00       	call   f01081ed <mp_init>
	lapic_init();
f0100144:	e8 f3 82 00 00       	call   f010843c <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100149:	e8 2f 4c 00 00       	call   f0104d7d <pic_init>

	// Acquire the big kernel lock before waking up APs
	// Your code here:
	lock_kernel();
f010014e:	e8 84 ff ff ff       	call   f01000d7 <lock_kernel>
	// Starting non-boot CPUs
	boot_aps();
f0100153:	e8 41 00 00 00       	call   f0100199 <boot_aps>
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	// ENV_CREATE(user_primes, ENV_TYPE_USER);
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f0100158:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010015f:	00 
f0100160:	c7 04 24 44 db 19 f0 	movl   $0xf019db44,(%esp)
f0100167:	e8 f2 47 00 00       	call   f010495e <env_create>
    ENV_CREATE(user_yield, ENV_TYPE_USER);
f010016c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100173:	00 
f0100174:	c7 04 24 44 db 19 f0 	movl   $0xf019db44,(%esp)
f010017b:	e8 de 47 00 00       	call   f010495e <env_create>
    ENV_CREATE(user_yield, ENV_TYPE_USER);
f0100180:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100187:	00 
f0100188:	c7 04 24 44 db 19 f0 	movl   $0xf019db44,(%esp)
f010018f:	e8 ca 47 00 00       	call   f010495e <env_create>
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f0100194:	e8 88 5e 00 00       	call   f0106021 <sched_yield>

f0100199 <boot_aps>:
void *mpentry_kstack;

// Start the non-boot (AP) processors.
static void
boot_aps(void)
{
f0100199:	55                   	push   %ebp
f010019a:	89 e5                	mov    %esp,%ebp
f010019c:	83 ec 28             	sub    $0x28,%esp
	extern unsigned char mpentry_start[], mpentry_end[];
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
f010019f:	c7 44 24 08 00 70 00 	movl   $0x7000,0x8(%esp)
f01001a6:	00 
f01001a7:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01001ae:	00 
f01001af:	c7 04 24 22 8d 10 f0 	movl   $0xf0108d22,(%esp)
f01001b6:	e8 c0 fe ff ff       	call   f010007b <_kaddr>
f01001bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001be:	ba ca 7e 10 f0       	mov    $0xf0107eca,%edx
f01001c3:	b8 50 7e 10 f0       	mov    $0xf0107e50,%eax
f01001c8:	29 c2                	sub    %eax,%edx
f01001ca:	89 d0                	mov    %edx,%eax
f01001cc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001d0:	c7 44 24 04 50 7e 10 	movl   $0xf0107e50,0x4(%esp)
f01001d7:	f0 
f01001d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01001db:	89 04 24             	mov    %eax,(%esp)
f01001de:	e8 87 79 00 00       	call   f0107b6a <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001e3:	c7 45 f4 20 c0 23 f0 	movl   $0xf023c020,-0xc(%ebp)
f01001ea:	eb 79                	jmp    f0100265 <boot_aps+0xcc>
		if (c == cpus + cpunum())  // We've started already.
f01001ec:	e8 d5 83 00 00       	call   f01085c6 <cpunum>
f01001f1:	6b c0 74             	imul   $0x74,%eax,%eax
f01001f4:	05 20 c0 23 f0       	add    $0xf023c020,%eax
f01001f9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f01001fc:	75 02                	jne    f0100200 <boot_aps+0x67>
			continue;
f01001fe:	eb 61                	jmp    f0100261 <boot_aps+0xc8>

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100200:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100203:	b8 20 c0 23 f0       	mov    $0xf023c020,%eax
f0100208:	29 c2                	sub    %eax,%edx
f010020a:	89 d0                	mov    %edx,%eax
f010020c:	c1 f8 02             	sar    $0x2,%eax
f010020f:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100215:	83 c0 01             	add    $0x1,%eax
f0100218:	c1 e0 0f             	shl    $0xf,%eax
f010021b:	05 00 d0 23 f0       	add    $0xf023d000,%eax
f0100220:	a3 e4 be 23 f0       	mov    %eax,0xf023bee4
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100225:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100228:	89 44 24 08          	mov    %eax,0x8(%esp)
f010022c:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
f0100233:	00 
f0100234:	c7 04 24 22 8d 10 f0 	movl   $0xf0108d22,(%esp)
f010023b:	e8 00 fe ff ff       	call   f0100040 <_paddr>
f0100240:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100243:	0f b6 12             	movzbl (%edx),%edx
f0100246:	0f b6 d2             	movzbl %dl,%edx
f0100249:	89 44 24 04          	mov    %eax,0x4(%esp)
f010024d:	89 14 24             	mov    %edx,(%esp)
f0100250:	e8 bd 83 00 00       	call   f0108612 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100255:	90                   	nop
f0100256:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100259:	8b 40 04             	mov    0x4(%eax),%eax
f010025c:	83 f8 01             	cmp    $0x1,%eax
f010025f:	75 f5                	jne    f0100256 <boot_aps+0xbd>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100261:	83 45 f4 74          	addl   $0x74,-0xc(%ebp)
f0100265:	a1 c4 c3 23 f0       	mov    0xf023c3c4,%eax
f010026a:	6b c0 74             	imul   $0x74,%eax,%eax
f010026d:	05 20 c0 23 f0       	add    $0xf023c020,%eax
f0100272:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0100275:	0f 87 71 ff ff ff    	ja     f01001ec <boot_aps+0x53>
		lapic_startap(c->cpu_id, PADDR(code));
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
			;
	}
}
f010027b:	c9                   	leave  
f010027c:	c3                   	ret    

f010027d <mp_main>:

// Setup code for APs
void
mp_main(void)
{
f010027d:	55                   	push   %ebp
f010027e:	89 e5                	mov    %esp,%ebp
f0100280:	83 ec 28             	sub    $0x28,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f0100283:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0100288:	89 44 24 08          	mov    %eax,0x8(%esp)
f010028c:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
f0100293:	00 
f0100294:	c7 04 24 22 8d 10 f0 	movl   $0xf0108d22,(%esp)
f010029b:	e8 a0 fd ff ff       	call   f0100040 <_paddr>
f01002a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01002a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01002a6:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01002a9:	e8 18 83 00 00       	call   f01085c6 <cpunum>
f01002ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01002b2:	c7 04 24 2e 8d 10 f0 	movl   $0xf0108d2e,(%esp)
f01002b9:	e8 01 4d 00 00       	call   f0104fbf <cprintf>

	lapic_init();
f01002be:	e8 79 81 00 00       	call   f010843c <lapic_init>
	env_init_percpu();
f01002c3:	e8 e4 41 00 00       	call   f01044ac <env_init_percpu>
	trap_init_percpu();
f01002c8:	e8 fa 52 00 00       	call   f01055c7 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01002cd:	e8 f4 82 00 00       	call   f01085c6 <cpunum>
f01002d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01002d5:	05 20 c0 23 f0       	add    $0xf023c020,%eax
f01002da:	83 c0 04             	add    $0x4,%eax
f01002dd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01002e4:	00 
f01002e5:	89 04 24             	mov    %eax,(%esp)
f01002e8:	e8 d0 fd ff ff       	call   f01000bd <xchg>
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:

	// Remove this after you finish Exercise 4
	lock_kernel();
f01002ed:	e8 e5 fd ff ff       	call   f01000d7 <lock_kernel>
	sched_yield();
f01002f2:	e8 2a 5d 00 00       	call   f0106021 <sched_yield>

f01002f7 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01002f7:	55                   	push   %ebp
f01002f8:	89 e5                	mov    %esp,%ebp
f01002fa:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	if (panicstr)
f01002fd:	a1 e0 be 23 f0       	mov    0xf023bee0,%eax
f0100302:	85 c0                	test   %eax,%eax
f0100304:	74 02                	je     f0100308 <_panic+0x11>
		goto dead;
f0100306:	eb 51                	jmp    f0100359 <_panic+0x62>
	panicstr = fmt;
f0100308:	8b 45 10             	mov    0x10(%ebp),%eax
f010030b:	a3 e0 be 23 f0       	mov    %eax,0xf023bee0

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100310:	fa                   	cli    
f0100311:	fc                   	cld    

	va_start(ap, fmt);
f0100312:	8d 45 14             	lea    0x14(%ebp),%eax
f0100315:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f0100318:	e8 a9 82 00 00       	call   f01085c6 <cpunum>
f010031d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100320:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100324:	8b 55 08             	mov    0x8(%ebp),%edx
f0100327:	89 54 24 08          	mov    %edx,0x8(%esp)
f010032b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010032f:	c7 04 24 44 8d 10 f0 	movl   $0xf0108d44,(%esp)
f0100336:	e8 84 4c 00 00       	call   f0104fbf <cprintf>
	vcprintf(fmt, ap);
f010033b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010033e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100342:	8b 45 10             	mov    0x10(%ebp),%eax
f0100345:	89 04 24             	mov    %eax,(%esp)
f0100348:	e8 3f 4c 00 00       	call   f0104f8c <vcprintf>
	cprintf("\n");
f010034d:	c7 04 24 66 8d 10 f0 	movl   $0xf0108d66,(%esp)
f0100354:	e8 66 4c 00 00       	call   f0104fbf <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100359:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100360:	e8 ec 0c 00 00       	call   f0101051 <monitor>
f0100365:	eb f2                	jmp    f0100359 <_panic+0x62>

f0100367 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100367:	55                   	push   %ebp
f0100368:	89 e5                	mov    %esp,%ebp
f010036a:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
f010036d:	8d 45 14             	lea    0x14(%ebp),%eax
f0100370:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("kernel warning at %s:%d: ", file, line);
f0100373:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100376:	89 44 24 08          	mov    %eax,0x8(%esp)
f010037a:	8b 45 08             	mov    0x8(%ebp),%eax
f010037d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100381:	c7 04 24 68 8d 10 f0 	movl   $0xf0108d68,(%esp)
f0100388:	e8 32 4c 00 00       	call   f0104fbf <cprintf>
	vcprintf(fmt, ap);
f010038d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100390:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100394:	8b 45 10             	mov    0x10(%ebp),%eax
f0100397:	89 04 24             	mov    %eax,(%esp)
f010039a:	e8 ed 4b 00 00       	call   f0104f8c <vcprintf>
	cprintf("\n");
f010039f:	c7 04 24 66 8d 10 f0 	movl   $0xf0108d66,(%esp)
f01003a6:	e8 14 4c 00 00       	call   f0104fbf <cprintf>
	va_end(ap);
}
f01003ab:	c9                   	leave  
f01003ac:	c3                   	ret    

f01003ad <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01003ad:	55                   	push   %ebp
f01003ae:	89 e5                	mov    %esp,%ebp
f01003b0:	83 ec 20             	sub    $0x20,%esp
f01003b3:	c7 45 fc 84 00 00 00 	movl   $0x84,-0x4(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01003bd:	89 c2                	mov    %eax,%edx
f01003bf:	ec                   	in     (%dx),%al
f01003c0:	88 45 fb             	mov    %al,-0x5(%ebp)
f01003c3:	c7 45 f4 84 00 00 00 	movl   $0x84,-0xc(%ebp)
f01003ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01003cd:	89 c2                	mov    %eax,%edx
f01003cf:	ec                   	in     (%dx),%al
f01003d0:	88 45 f3             	mov    %al,-0xd(%ebp)
f01003d3:	c7 45 ec 84 00 00 00 	movl   $0x84,-0x14(%ebp)
f01003da:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01003dd:	89 c2                	mov    %eax,%edx
f01003df:	ec                   	in     (%dx),%al
f01003e0:	88 45 eb             	mov    %al,-0x15(%ebp)
f01003e3:	c7 45 e4 84 00 00 00 	movl   $0x84,-0x1c(%ebp)
f01003ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01003ed:	89 c2                	mov    %eax,%edx
f01003ef:	ec                   	in     (%dx),%al
f01003f0:	88 45 e3             	mov    %al,-0x1d(%ebp)
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01003f3:	c9                   	leave  
f01003f4:	c3                   	ret    

f01003f5 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01003f5:	55                   	push   %ebp
f01003f6:	89 e5                	mov    %esp,%ebp
f01003f8:	83 ec 10             	sub    $0x10,%esp
f01003fb:	c7 45 fc fd 03 00 00 	movl   $0x3fd,-0x4(%ebp)
f0100402:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0100405:	89 c2                	mov    %eax,%edx
f0100407:	ec                   	in     (%dx),%al
f0100408:	88 45 fb             	mov    %al,-0x5(%ebp)
	return data;
f010040b:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010040f:	0f b6 c0             	movzbl %al,%eax
f0100412:	83 e0 01             	and    $0x1,%eax
f0100415:	85 c0                	test   %eax,%eax
f0100417:	75 07                	jne    f0100420 <serial_proc_data+0x2b>
		return -1;
f0100419:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010041e:	eb 17                	jmp    f0100437 <serial_proc_data+0x42>
f0100420:	c7 45 f4 f8 03 00 00 	movl   $0x3f8,-0xc(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100427:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010042a:	89 c2                	mov    %eax,%edx
f010042c:	ec                   	in     (%dx),%al
f010042d:	88 45 f3             	mov    %al,-0xd(%ebp)
	return data;
f0100430:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
	return inb(COM1+COM_RX);
f0100434:	0f b6 c0             	movzbl %al,%eax
}
f0100437:	c9                   	leave  
f0100438:	c3                   	ret    

f0100439 <serial_intr>:

void
serial_intr(void)
{
f0100439:	55                   	push   %ebp
f010043a:	89 e5                	mov    %esp,%ebp
f010043c:	83 ec 18             	sub    $0x18,%esp
	if (serial_exists)
f010043f:	0f b6 05 00 b0 23 f0 	movzbl 0xf023b000,%eax
f0100446:	84 c0                	test   %al,%al
f0100448:	74 0c                	je     f0100456 <serial_intr+0x1d>
		cons_intr(serial_proc_data);
f010044a:	c7 04 24 f5 03 10 f0 	movl   $0xf01003f5,(%esp)
f0100451:	e8 3e 06 00 00       	call   f0100a94 <cons_intr>
}
f0100456:	c9                   	leave  
f0100457:	c3                   	ret    

f0100458 <serial_putc>:

static void
serial_putc(int c)
{
f0100458:	55                   	push   %ebp
f0100459:	89 e5                	mov    %esp,%ebp
f010045b:	83 ec 20             	sub    $0x20,%esp
	int i;

	for (i = 0;
f010045e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f0100465:	eb 09                	jmp    f0100470 <serial_putc+0x18>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100467:	e8 41 ff ff ff       	call   f01003ad <delay>
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f010046c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
f0100470:	c7 45 f8 fd 03 00 00 	movl   $0x3fd,-0x8(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100477:	8b 45 f8             	mov    -0x8(%ebp),%eax
f010047a:	89 c2                	mov    %eax,%edx
f010047c:	ec                   	in     (%dx),%al
f010047d:	88 45 f7             	mov    %al,-0x9(%ebp)
	return data;
f0100480:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100484:	0f b6 c0             	movzbl %al,%eax
f0100487:	83 e0 20             	and    $0x20,%eax
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010048a:	85 c0                	test   %eax,%eax
f010048c:	75 09                	jne    f0100497 <serial_putc+0x3f>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010048e:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
f0100495:	7e d0                	jle    f0100467 <serial_putc+0xf>
	     i++)
		delay();
	outb(COM1,(uint8_t) c);
f0100497:	8b 45 08             	mov    0x8(%ebp),%eax
f010049a:	0f b6 c0             	movzbl %al,%eax
f010049d:	c7 45 f0 f8 03 00 00 	movl   $0x3f8,-0x10(%ebp)
f01004a4:	88 45 ef             	mov    %al,-0x11(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004a7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
f01004ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01004ae:	ee                   	out    %al,(%dx)
	//printf to shell using serial interface. code to follow

}
f01004af:	c9                   	leave  
f01004b0:	c3                   	ret    

f01004b1 <serial_init>:

static void
serial_init(void)
{
f01004b1:	55                   	push   %ebp
f01004b2:	89 e5                	mov    %esp,%ebp
f01004b4:	83 ec 50             	sub    $0x50,%esp
f01004b7:	c7 45 fc fa 03 00 00 	movl   $0x3fa,-0x4(%ebp)
f01004be:	c6 45 fb 00          	movb   $0x0,-0x5(%ebp)
f01004c2:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
f01004c6:	8b 55 fc             	mov    -0x4(%ebp),%edx
f01004c9:	ee                   	out    %al,(%dx)
f01004ca:	c7 45 f4 fb 03 00 00 	movl   $0x3fb,-0xc(%ebp)
f01004d1:	c6 45 f3 80          	movb   $0x80,-0xd(%ebp)
f01004d5:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f01004d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01004dc:	ee                   	out    %al,(%dx)
f01004dd:	c7 45 ec f8 03 00 00 	movl   $0x3f8,-0x14(%ebp)
f01004e4:	c6 45 eb 0c          	movb   $0xc,-0x15(%ebp)
f01004e8:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
f01004ec:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01004ef:	ee                   	out    %al,(%dx)
f01004f0:	c7 45 e4 f9 03 00 00 	movl   $0x3f9,-0x1c(%ebp)
f01004f7:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
f01004fb:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01004ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100502:	ee                   	out    %al,(%dx)
f0100503:	c7 45 dc fb 03 00 00 	movl   $0x3fb,-0x24(%ebp)
f010050a:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
f010050e:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
f0100512:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100515:	ee                   	out    %al,(%dx)
f0100516:	c7 45 d4 fc 03 00 00 	movl   $0x3fc,-0x2c(%ebp)
f010051d:	c6 45 d3 00          	movb   $0x0,-0x2d(%ebp)
f0100521:	0f b6 45 d3          	movzbl -0x2d(%ebp),%eax
f0100525:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100528:	ee                   	out    %al,(%dx)
f0100529:	c7 45 cc f9 03 00 00 	movl   $0x3f9,-0x34(%ebp)
f0100530:	c6 45 cb 01          	movb   $0x1,-0x35(%ebp)
f0100534:	0f b6 45 cb          	movzbl -0x35(%ebp),%eax
f0100538:	8b 55 cc             	mov    -0x34(%ebp),%edx
f010053b:	ee                   	out    %al,(%dx)
f010053c:	c7 45 c4 fd 03 00 00 	movl   $0x3fd,-0x3c(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100543:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100546:	89 c2                	mov    %eax,%edx
f0100548:	ec                   	in     (%dx),%al
f0100549:	88 45 c3             	mov    %al,-0x3d(%ebp)
	return data;
f010054c:	0f b6 45 c3          	movzbl -0x3d(%ebp),%eax
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100550:	3c ff                	cmp    $0xff,%al
f0100552:	0f 95 c0             	setne  %al
f0100555:	a2 00 b0 23 f0       	mov    %al,0xf023b000
f010055a:	c7 45 bc fa 03 00 00 	movl   $0x3fa,-0x44(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100561:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0100564:	89 c2                	mov    %eax,%edx
f0100566:	ec                   	in     (%dx),%al
f0100567:	88 45 bb             	mov    %al,-0x45(%ebp)
f010056a:	c7 45 b4 f8 03 00 00 	movl   $0x3f8,-0x4c(%ebp)
f0100571:	8b 45 b4             	mov    -0x4c(%ebp),%eax
f0100574:	89 c2                	mov    %eax,%edx
f0100576:	ec                   	in     (%dx),%al
f0100577:	88 45 b3             	mov    %al,-0x4d(%ebp)
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

}
f010057a:	c9                   	leave  
f010057b:	c3                   	ret    

f010057c <lpt_putc>:
// For information on PC parallel port programming, see the class References
// page.

static void
lpt_putc(int c)
{
f010057c:	55                   	push   %ebp
f010057d:	89 e5                	mov    %esp,%ebp
f010057f:	83 ec 30             	sub    $0x30,%esp
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100582:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f0100589:	eb 09                	jmp    f0100594 <lpt_putc+0x18>
		delay();
f010058b:	e8 1d fe ff ff       	call   f01003ad <delay>
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100590:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
f0100594:	c7 45 f8 79 03 00 00 	movl   $0x379,-0x8(%ebp)
f010059b:	8b 45 f8             	mov    -0x8(%ebp),%eax
f010059e:	89 c2                	mov    %eax,%edx
f01005a0:	ec                   	in     (%dx),%al
f01005a1:	88 45 f7             	mov    %al,-0x9(%ebp)
	return data;
f01005a4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
f01005a8:	84 c0                	test   %al,%al
f01005aa:	78 09                	js     f01005b5 <lpt_putc+0x39>
f01005ac:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
f01005b3:	7e d6                	jle    f010058b <lpt_putc+0xf>
		delay();
	outb(0x378+0, c);
f01005b5:	8b 45 08             	mov    0x8(%ebp),%eax
f01005b8:	0f b6 c0             	movzbl %al,%eax
f01005bb:	c7 45 f0 78 03 00 00 	movl   $0x378,-0x10(%ebp)
f01005c2:	88 45 ef             	mov    %al,-0x11(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005c5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
f01005c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01005cc:	ee                   	out    %al,(%dx)
f01005cd:	c7 45 e8 7a 03 00 00 	movl   $0x37a,-0x18(%ebp)
f01005d4:	c6 45 e7 0d          	movb   $0xd,-0x19(%ebp)
f01005d8:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01005dc:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01005df:	ee                   	out    %al,(%dx)
f01005e0:	c7 45 e0 7a 03 00 00 	movl   $0x37a,-0x20(%ebp)
f01005e7:	c6 45 df 08          	movb   $0x8,-0x21(%ebp)
f01005eb:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
f01005ef:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01005f2:	ee                   	out    %al,(%dx)
	outb(0x378+2, 0x08|0x04|0x01);
	outb(0x378+2, 0x08);
}
f01005f3:	c9                   	leave  
f01005f4:	c3                   	ret    

f01005f5 <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

static void
cga_init(void)
{
f01005f5:	55                   	push   %ebp
f01005f6:	89 e5                	mov    %esp,%ebp
f01005f8:	83 ec 30             	sub    $0x30,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005fb:	c7 45 fc 00 80 0b f0 	movl   $0xf00b8000,-0x4(%ebp)
	was = *cp;
f0100602:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0100605:	0f b7 00             	movzwl (%eax),%eax
f0100608:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
	*cp = (uint16_t) 0xA55A;
f010060c:	8b 45 fc             	mov    -0x4(%ebp),%eax
f010060f:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f0100614:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0100617:	0f b7 00             	movzwl (%eax),%eax
f010061a:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010061e:	74 13                	je     f0100633 <cga_init+0x3e>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100620:	c7 45 fc 00 00 0b f0 	movl   $0xf00b0000,-0x4(%ebp)
		addr_6845 = MONO_BASE;
f0100627:	c7 05 04 b0 23 f0 b4 	movl   $0x3b4,0xf023b004
f010062e:	03 00 00 
f0100631:	eb 14                	jmp    f0100647 <cga_init+0x52>
	} else {
		*cp = was;
f0100633:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0100636:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
f010063a:	66 89 10             	mov    %dx,(%eax)
		addr_6845 = CGA_BASE;
f010063d:	c7 05 04 b0 23 f0 d4 	movl   $0x3d4,0xf023b004
f0100644:	03 00 00 
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100647:	a1 04 b0 23 f0       	mov    0xf023b004,%eax
f010064c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010064f:	c6 45 ef 0e          	movb   $0xe,-0x11(%ebp)
f0100653:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
f0100657:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010065a:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010065b:	a1 04 b0 23 f0       	mov    0xf023b004,%eax
f0100660:	83 c0 01             	add    $0x1,%eax
f0100663:	89 45 e8             	mov    %eax,-0x18(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100666:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100669:	89 c2                	mov    %eax,%edx
f010066b:	ec                   	in     (%dx),%al
f010066c:	88 45 e7             	mov    %al,-0x19(%ebp)
	return data;
f010066f:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100673:	0f b6 c0             	movzbl %al,%eax
f0100676:	c1 e0 08             	shl    $0x8,%eax
f0100679:	89 45 f4             	mov    %eax,-0xc(%ebp)
	outb(addr_6845, 15);
f010067c:	a1 04 b0 23 f0       	mov    0xf023b004,%eax
f0100681:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100684:	c6 45 df 0f          	movb   $0xf,-0x21(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100688:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
f010068c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010068f:	ee                   	out    %al,(%dx)
	pos |= inb(addr_6845 + 1);
f0100690:	a1 04 b0 23 f0       	mov    0xf023b004,%eax
f0100695:	83 c0 01             	add    $0x1,%eax
f0100698:	89 45 d8             	mov    %eax,-0x28(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010069b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010069e:	89 c2                	mov    %eax,%edx
f01006a0:	ec                   	in     (%dx),%al
f01006a1:	88 45 d7             	mov    %al,-0x29(%ebp)
	return data;
f01006a4:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
f01006a8:	0f b6 c0             	movzbl %al,%eax
f01006ab:	09 45 f4             	or     %eax,-0xc(%ebp)

	crt_buf = (uint16_t*) cp;
f01006ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01006b1:	a3 08 b0 23 f0       	mov    %eax,0xf023b008
	crt_pos = pos;
f01006b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01006b9:	66 a3 0c b0 23 f0    	mov    %ax,0xf023b00c
}
f01006bf:	c9                   	leave  
f01006c0:	c3                   	ret    

f01006c1 <cga_putc>:



static void
cga_putc(int c)
{
f01006c1:	55                   	push   %ebp
f01006c2:	89 e5                	mov    %esp,%ebp
f01006c4:	53                   	push   %ebx
f01006c5:	83 ec 44             	sub    $0x44,%esp
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01006c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01006cb:	b0 00                	mov    $0x0,%al
f01006cd:	85 c0                	test   %eax,%eax
f01006cf:	75 07                	jne    f01006d8 <cga_putc+0x17>
		c |= 0x0700;
f01006d1:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)

	switch (c & 0xff) {
f01006d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01006db:	0f b6 c0             	movzbl %al,%eax
f01006de:	83 f8 09             	cmp    $0x9,%eax
f01006e1:	0f 84 ac 00 00 00    	je     f0100793 <cga_putc+0xd2>
f01006e7:	83 f8 09             	cmp    $0x9,%eax
f01006ea:	7f 0a                	jg     f01006f6 <cga_putc+0x35>
f01006ec:	83 f8 08             	cmp    $0x8,%eax
f01006ef:	74 14                	je     f0100705 <cga_putc+0x44>
f01006f1:	e9 db 00 00 00       	jmp    f01007d1 <cga_putc+0x110>
f01006f6:	83 f8 0a             	cmp    $0xa,%eax
f01006f9:	74 4e                	je     f0100749 <cga_putc+0x88>
f01006fb:	83 f8 0d             	cmp    $0xd,%eax
f01006fe:	74 59                	je     f0100759 <cga_putc+0x98>
f0100700:	e9 cc 00 00 00       	jmp    f01007d1 <cga_putc+0x110>
	case '\b':
		if (crt_pos > 0) {
f0100705:	0f b7 05 0c b0 23 f0 	movzwl 0xf023b00c,%eax
f010070c:	66 85 c0             	test   %ax,%ax
f010070f:	74 33                	je     f0100744 <cga_putc+0x83>
			crt_pos--;
f0100711:	0f b7 05 0c b0 23 f0 	movzwl 0xf023b00c,%eax
f0100718:	83 e8 01             	sub    $0x1,%eax
f010071b:	66 a3 0c b0 23 f0    	mov    %ax,0xf023b00c
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100721:	a1 08 b0 23 f0       	mov    0xf023b008,%eax
f0100726:	0f b7 15 0c b0 23 f0 	movzwl 0xf023b00c,%edx
f010072d:	0f b7 d2             	movzwl %dx,%edx
f0100730:	01 d2                	add    %edx,%edx
f0100732:	01 c2                	add    %eax,%edx
f0100734:	8b 45 08             	mov    0x8(%ebp),%eax
f0100737:	b0 00                	mov    $0x0,%al
f0100739:	83 c8 20             	or     $0x20,%eax
f010073c:	66 89 02             	mov    %ax,(%edx)
		}
		break;
f010073f:	e9 b3 00 00 00       	jmp    f01007f7 <cga_putc+0x136>
f0100744:	e9 ae 00 00 00       	jmp    f01007f7 <cga_putc+0x136>
	case '\n':
		crt_pos += CRT_COLS;
f0100749:	0f b7 05 0c b0 23 f0 	movzwl 0xf023b00c,%eax
f0100750:	83 c0 50             	add    $0x50,%eax
f0100753:	66 a3 0c b0 23 f0    	mov    %ax,0xf023b00c
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100759:	0f b7 1d 0c b0 23 f0 	movzwl 0xf023b00c,%ebx
f0100760:	0f b7 0d 0c b0 23 f0 	movzwl 0xf023b00c,%ecx
f0100767:	0f b7 c1             	movzwl %cx,%eax
f010076a:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100770:	c1 e8 10             	shr    $0x10,%eax
f0100773:	89 c2                	mov    %eax,%edx
f0100775:	66 c1 ea 06          	shr    $0x6,%dx
f0100779:	89 d0                	mov    %edx,%eax
f010077b:	c1 e0 02             	shl    $0x2,%eax
f010077e:	01 d0                	add    %edx,%eax
f0100780:	c1 e0 04             	shl    $0x4,%eax
f0100783:	29 c1                	sub    %eax,%ecx
f0100785:	89 ca                	mov    %ecx,%edx
f0100787:	89 d8                	mov    %ebx,%eax
f0100789:	29 d0                	sub    %edx,%eax
f010078b:	66 a3 0c b0 23 f0    	mov    %ax,0xf023b00c
		break;
f0100791:	eb 64                	jmp    f01007f7 <cga_putc+0x136>
	case '\t':
		cons_putc(' ');
f0100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010079a:	e8 9e 03 00 00       	call   f0100b3d <cons_putc>
		cons_putc(' ');
f010079f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01007a6:	e8 92 03 00 00       	call   f0100b3d <cons_putc>
		cons_putc(' ');
f01007ab:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01007b2:	e8 86 03 00 00       	call   f0100b3d <cons_putc>
		cons_putc(' ');
f01007b7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01007be:	e8 7a 03 00 00       	call   f0100b3d <cons_putc>
		cons_putc(' ');
f01007c3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01007ca:	e8 6e 03 00 00       	call   f0100b3d <cons_putc>
		break;
f01007cf:	eb 26                	jmp    f01007f7 <cga_putc+0x136>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01007d1:	8b 0d 08 b0 23 f0    	mov    0xf023b008,%ecx
f01007d7:	0f b7 05 0c b0 23 f0 	movzwl 0xf023b00c,%eax
f01007de:	8d 50 01             	lea    0x1(%eax),%edx
f01007e1:	66 89 15 0c b0 23 f0 	mov    %dx,0xf023b00c
f01007e8:	0f b7 c0             	movzwl %ax,%eax
f01007eb:	01 c0                	add    %eax,%eax
f01007ed:	8d 14 01             	lea    (%ecx,%eax,1),%edx
f01007f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01007f3:	66 89 02             	mov    %ax,(%edx)
		break;
f01007f6:	90                   	nop
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01007f7:	0f b7 05 0c b0 23 f0 	movzwl 0xf023b00c,%eax
f01007fe:	66 3d cf 07          	cmp    $0x7cf,%ax
f0100802:	76 5b                	jbe    f010085f <cga_putc+0x19e>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100804:	a1 08 b0 23 f0       	mov    0xf023b008,%eax
f0100809:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010080f:	a1 08 b0 23 f0       	mov    0xf023b008,%eax
f0100814:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010081b:	00 
f010081c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100820:	89 04 24             	mov    %eax,(%esp)
f0100823:	e8 42 73 00 00       	call   f0107b6a <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100828:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
f010082f:	eb 15                	jmp    f0100846 <cga_putc+0x185>
			crt_buf[i] = 0x0700 | ' ';
f0100831:	a1 08 b0 23 f0       	mov    0xf023b008,%eax
f0100836:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100839:	01 d2                	add    %edx,%edx
f010083b:	01 d0                	add    %edx,%eax
f010083d:	66 c7 00 20 07       	movw   $0x720,(%eax)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100842:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0100846:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
f010084d:	7e e2                	jle    f0100831 <cga_putc+0x170>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010084f:	0f b7 05 0c b0 23 f0 	movzwl 0xf023b00c,%eax
f0100856:	83 e8 50             	sub    $0x50,%eax
f0100859:	66 a3 0c b0 23 f0    	mov    %ax,0xf023b00c
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010085f:	a1 04 b0 23 f0       	mov    0xf023b004,%eax
f0100864:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100867:	c6 45 ef 0e          	movb   $0xe,-0x11(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010086b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
f010086f:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100872:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100873:	0f b7 05 0c b0 23 f0 	movzwl 0xf023b00c,%eax
f010087a:	66 c1 e8 08          	shr    $0x8,%ax
f010087e:	0f b6 c0             	movzbl %al,%eax
f0100881:	8b 15 04 b0 23 f0    	mov    0xf023b004,%edx
f0100887:	83 c2 01             	add    $0x1,%edx
f010088a:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010088d:	88 45 e7             	mov    %al,-0x19(%ebp)
f0100890:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100894:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100897:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
f0100898:	a1 04 b0 23 f0       	mov    0xf023b004,%eax
f010089d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01008a0:	c6 45 df 0f          	movb   $0xf,-0x21(%ebp)
f01008a4:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
f01008a8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01008ab:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos);
f01008ac:	0f b7 05 0c b0 23 f0 	movzwl 0xf023b00c,%eax
f01008b3:	0f b6 c0             	movzbl %al,%eax
f01008b6:	8b 15 04 b0 23 f0    	mov    0xf023b004,%edx
f01008bc:	83 c2 01             	add    $0x1,%edx
f01008bf:	89 55 d8             	mov    %edx,-0x28(%ebp)
f01008c2:	88 45 d7             	mov    %al,-0x29(%ebp)
f01008c5:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
f01008c9:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01008cc:	ee                   	out    %al,(%dx)
}
f01008cd:	83 c4 44             	add    $0x44,%esp
f01008d0:	5b                   	pop    %ebx
f01008d1:	5d                   	pop    %ebp
f01008d2:	c3                   	ret    

f01008d3 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01008d3:	55                   	push   %ebp
f01008d4:	89 e5                	mov    %esp,%ebp
f01008d6:	83 ec 38             	sub    $0x38,%esp
f01008d9:	c7 45 ec 64 00 00 00 	movl   $0x64,-0x14(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01008e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01008e3:	89 c2                	mov    %eax,%edx
f01008e5:	ec                   	in     (%dx),%al
f01008e6:	88 45 eb             	mov    %al,-0x15(%ebp)
	return data;
f01008e9:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01008ed:	0f b6 c0             	movzbl %al,%eax
f01008f0:	83 e0 01             	and    $0x1,%eax
f01008f3:	85 c0                	test   %eax,%eax
f01008f5:	75 0a                	jne    f0100901 <kbd_proc_data+0x2e>
		return -1;
f01008f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01008fc:	e9 59 01 00 00       	jmp    f0100a5a <kbd_proc_data+0x187>
f0100901:	c7 45 e4 60 00 00 00 	movl   $0x60,-0x1c(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100908:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010090b:	89 c2                	mov    %eax,%edx
f010090d:	ec                   	in     (%dx),%al
f010090e:	88 45 e3             	mov    %al,-0x1d(%ebp)
	return data;
f0100911:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax

	data = inb(KBDATAP);
f0100915:	88 45 f3             	mov    %al,-0xd(%ebp)

	if (data == 0xE0) {
f0100918:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
f010091c:	75 17                	jne    f0100935 <kbd_proc_data+0x62>
		// E0 escape character
		shift |= E0ESC;
f010091e:	a1 28 b2 23 f0       	mov    0xf023b228,%eax
f0100923:	83 c8 40             	or     $0x40,%eax
f0100926:	a3 28 b2 23 f0       	mov    %eax,0xf023b228
		return 0;
f010092b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100930:	e9 25 01 00 00       	jmp    f0100a5a <kbd_proc_data+0x187>
	} else if (data & 0x80) {
f0100935:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0100939:	84 c0                	test   %al,%al
f010093b:	79 47                	jns    f0100984 <kbd_proc_data+0xb1>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010093d:	a1 28 b2 23 f0       	mov    0xf023b228,%eax
f0100942:	83 e0 40             	and    $0x40,%eax
f0100945:	85 c0                	test   %eax,%eax
f0100947:	75 09                	jne    f0100952 <kbd_proc_data+0x7f>
f0100949:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f010094d:	83 e0 7f             	and    $0x7f,%eax
f0100950:	eb 04                	jmp    f0100956 <kbd_proc_data+0x83>
f0100952:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0100956:	88 45 f3             	mov    %al,-0xd(%ebp)
		shift &= ~(shiftcode[data] | E0ESC);
f0100959:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f010095d:	0f b6 80 00 50 12 f0 	movzbl -0xfedb000(%eax),%eax
f0100964:	83 c8 40             	or     $0x40,%eax
f0100967:	0f b6 c0             	movzbl %al,%eax
f010096a:	f7 d0                	not    %eax
f010096c:	89 c2                	mov    %eax,%edx
f010096e:	a1 28 b2 23 f0       	mov    0xf023b228,%eax
f0100973:	21 d0                	and    %edx,%eax
f0100975:	a3 28 b2 23 f0       	mov    %eax,0xf023b228
		return 0;
f010097a:	b8 00 00 00 00       	mov    $0x0,%eax
f010097f:	e9 d6 00 00 00       	jmp    f0100a5a <kbd_proc_data+0x187>
	} else if (shift & E0ESC) {
f0100984:	a1 28 b2 23 f0       	mov    0xf023b228,%eax
f0100989:	83 e0 40             	and    $0x40,%eax
f010098c:	85 c0                	test   %eax,%eax
f010098e:	74 11                	je     f01009a1 <kbd_proc_data+0xce>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100990:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
		shift &= ~E0ESC;
f0100994:	a1 28 b2 23 f0       	mov    0xf023b228,%eax
f0100999:	83 e0 bf             	and    $0xffffffbf,%eax
f010099c:	a3 28 b2 23 f0       	mov    %eax,0xf023b228
	}

	shift |= shiftcode[data];
f01009a1:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f01009a5:	0f b6 80 00 50 12 f0 	movzbl -0xfedb000(%eax),%eax
f01009ac:	0f b6 d0             	movzbl %al,%edx
f01009af:	a1 28 b2 23 f0       	mov    0xf023b228,%eax
f01009b4:	09 d0                	or     %edx,%eax
f01009b6:	a3 28 b2 23 f0       	mov    %eax,0xf023b228
	shift ^= togglecode[data];
f01009bb:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f01009bf:	0f b6 80 00 51 12 f0 	movzbl -0xfedaf00(%eax),%eax
f01009c6:	0f b6 d0             	movzbl %al,%edx
f01009c9:	a1 28 b2 23 f0       	mov    0xf023b228,%eax
f01009ce:	31 d0                	xor    %edx,%eax
f01009d0:	a3 28 b2 23 f0       	mov    %eax,0xf023b228

	c = charcode[shift & (CTL | SHIFT)][data];
f01009d5:	a1 28 b2 23 f0       	mov    0xf023b228,%eax
f01009da:	83 e0 03             	and    $0x3,%eax
f01009dd:	8b 14 85 00 55 12 f0 	mov    -0xfedab00(,%eax,4),%edx
f01009e4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f01009e8:	01 d0                	add    %edx,%eax
f01009ea:	0f b6 00             	movzbl (%eax),%eax
f01009ed:	0f b6 c0             	movzbl %al,%eax
f01009f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (shift & CAPSLOCK) {
f01009f3:	a1 28 b2 23 f0       	mov    0xf023b228,%eax
f01009f8:	83 e0 08             	and    $0x8,%eax
f01009fb:	85 c0                	test   %eax,%eax
f01009fd:	74 22                	je     f0100a21 <kbd_proc_data+0x14e>
		if ('a' <= c && c <= 'z')
f01009ff:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
f0100a03:	7e 0c                	jle    f0100a11 <kbd_proc_data+0x13e>
f0100a05:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
f0100a09:	7f 06                	jg     f0100a11 <kbd_proc_data+0x13e>
			c += 'A' - 'a';
f0100a0b:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
f0100a0f:	eb 10                	jmp    f0100a21 <kbd_proc_data+0x14e>
		else if ('A' <= c && c <= 'Z')
f0100a11:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
f0100a15:	7e 0a                	jle    f0100a21 <kbd_proc_data+0x14e>
f0100a17:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
f0100a1b:	7f 04                	jg     f0100a21 <kbd_proc_data+0x14e>
			c += 'a' - 'A';
f0100a1d:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100a21:	a1 28 b2 23 f0       	mov    0xf023b228,%eax
f0100a26:	f7 d0                	not    %eax
f0100a28:	83 e0 06             	and    $0x6,%eax
f0100a2b:	85 c0                	test   %eax,%eax
f0100a2d:	75 28                	jne    f0100a57 <kbd_proc_data+0x184>
f0100a2f:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
f0100a36:	75 1f                	jne    f0100a57 <kbd_proc_data+0x184>
		cprintf("Rebooting!\n");
f0100a38:	c7 04 24 82 8d 10 f0 	movl   $0xf0108d82,(%esp)
f0100a3f:	e8 7b 45 00 00       	call   f0104fbf <cprintf>
f0100a44:	c7 45 dc 92 00 00 00 	movl   $0x92,-0x24(%ebp)
f0100a4b:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100a4f:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
f0100a53:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a56:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0100a5a:	c9                   	leave  
f0100a5b:	c3                   	ret    

f0100a5c <kbd_intr>:

void
kbd_intr(void)
{
f0100a5c:	55                   	push   %ebp
f0100a5d:	89 e5                	mov    %esp,%ebp
f0100a5f:	83 ec 18             	sub    $0x18,%esp
	cons_intr(kbd_proc_data);
f0100a62:	c7 04 24 d3 08 10 f0 	movl   $0xf01008d3,(%esp)
f0100a69:	e8 26 00 00 00       	call   f0100a94 <cons_intr>
}
f0100a6e:	c9                   	leave  
f0100a6f:	c3                   	ret    

f0100a70 <kbd_init>:

static void
kbd_init(void)
{
f0100a70:	55                   	push   %ebp
f0100a71:	89 e5                	mov    %esp,%ebp
f0100a73:	83 ec 18             	sub    $0x18,%esp
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f0100a76:	e8 e1 ff ff ff       	call   f0100a5c <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100a7b:	0f b7 05 ce 55 12 f0 	movzwl 0xf01255ce,%eax
f0100a82:	0f b7 c0             	movzwl %ax,%eax
f0100a85:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100a8a:	89 04 24             	mov    %eax,(%esp)
f0100a8d:	e8 26 44 00 00       	call   f0104eb8 <irq_setmask_8259A>
}
f0100a92:	c9                   	leave  
f0100a93:	c3                   	ret    

f0100a94 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100a94:	55                   	push   %ebp
f0100a95:	89 e5                	mov    %esp,%ebp
f0100a97:	83 ec 18             	sub    $0x18,%esp
	int c;

	while ((c = (*proc)()) != -1) {
f0100a9a:	eb 35                	jmp    f0100ad1 <cons_intr+0x3d>
		if (c == 0)
f0100a9c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0100aa0:	75 02                	jne    f0100aa4 <cons_intr+0x10>
			continue;
f0100aa2:	eb 2d                	jmp    f0100ad1 <cons_intr+0x3d>
		cons.buf[cons.wpos++] = c;
f0100aa4:	a1 24 b2 23 f0       	mov    0xf023b224,%eax
f0100aa9:	8d 50 01             	lea    0x1(%eax),%edx
f0100aac:	89 15 24 b2 23 f0    	mov    %edx,0xf023b224
f0100ab2:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100ab5:	88 90 20 b0 23 f0    	mov    %dl,-0xfdc4fe0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f0100abb:	a1 24 b2 23 f0       	mov    0xf023b224,%eax
f0100ac0:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100ac5:	75 0a                	jne    f0100ad1 <cons_intr+0x3d>
			cons.wpos = 0;
f0100ac7:	c7 05 24 b2 23 f0 00 	movl   $0x0,0xf023b224
f0100ace:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100ad1:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ad4:	ff d0                	call   *%eax
f0100ad6:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0100ad9:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
f0100add:	75 bd                	jne    f0100a9c <cons_intr+0x8>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100adf:	c9                   	leave  
f0100ae0:	c3                   	ret    

f0100ae1 <cons_getc>:

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100ae1:	55                   	push   %ebp
f0100ae2:	89 e5                	mov    %esp,%ebp
f0100ae4:	83 ec 18             	sub    $0x18,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100ae7:	e8 4d f9 ff ff       	call   f0100439 <serial_intr>
	kbd_intr();
f0100aec:	e8 6b ff ff ff       	call   f0100a5c <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100af1:	8b 15 20 b2 23 f0    	mov    0xf023b220,%edx
f0100af7:	a1 24 b2 23 f0       	mov    0xf023b224,%eax
f0100afc:	39 c2                	cmp    %eax,%edx
f0100afe:	74 36                	je     f0100b36 <cons_getc+0x55>
		c = cons.buf[cons.rpos++];
f0100b00:	a1 20 b2 23 f0       	mov    0xf023b220,%eax
f0100b05:	8d 50 01             	lea    0x1(%eax),%edx
f0100b08:	89 15 20 b2 23 f0    	mov    %edx,0xf023b220
f0100b0e:	0f b6 80 20 b0 23 f0 	movzbl -0xfdc4fe0(%eax),%eax
f0100b15:	0f b6 c0             	movzbl %al,%eax
f0100b18:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if (cons.rpos == CONSBUFSIZE)
f0100b1b:	a1 20 b2 23 f0       	mov    0xf023b220,%eax
f0100b20:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100b25:	75 0a                	jne    f0100b31 <cons_getc+0x50>
			cons.rpos = 0;
f0100b27:	c7 05 20 b2 23 f0 00 	movl   $0x0,0xf023b220
f0100b2e:	00 00 00 
		return c;
f0100b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b34:	eb 05                	jmp    f0100b3b <cons_getc+0x5a>
	}
	return 0;
f0100b36:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100b3b:	c9                   	leave  
f0100b3c:	c3                   	ret    

f0100b3d <cons_putc>:

// output a character to the console
static void
cons_putc(int c)
{
f0100b3d:	55                   	push   %ebp
f0100b3e:	89 e5                	mov    %esp,%ebp
f0100b40:	83 ec 18             	sub    $0x18,%esp
	serial_putc(c);
f0100b43:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b46:	89 04 24             	mov    %eax,(%esp)
f0100b49:	e8 0a f9 ff ff       	call   f0100458 <serial_putc>
	lpt_putc(c);
f0100b4e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b51:	89 04 24             	mov    %eax,(%esp)
f0100b54:	e8 23 fa ff ff       	call   f010057c <lpt_putc>
	cga_putc(c);
f0100b59:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b5c:	89 04 24             	mov    %eax,(%esp)
f0100b5f:	e8 5d fb ff ff       	call   f01006c1 <cga_putc>
}
f0100b64:	c9                   	leave  
f0100b65:	c3                   	ret    

f0100b66 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100b66:	55                   	push   %ebp
f0100b67:	89 e5                	mov    %esp,%ebp
f0100b69:	83 ec 18             	sub    $0x18,%esp
	cga_init();
f0100b6c:	e8 84 fa ff ff       	call   f01005f5 <cga_init>
	kbd_init();
f0100b71:	e8 fa fe ff ff       	call   f0100a70 <kbd_init>
	serial_init();
f0100b76:	e8 36 f9 ff ff       	call   f01004b1 <serial_init>

	if (!serial_exists)
f0100b7b:	0f b6 05 00 b0 23 f0 	movzbl 0xf023b000,%eax
f0100b82:	83 f0 01             	xor    $0x1,%eax
f0100b85:	84 c0                	test   %al,%al
f0100b87:	74 0c                	je     f0100b95 <cons_init+0x2f>
		cprintf("Serial port does not exist!\n");
f0100b89:	c7 04 24 8e 8d 10 f0 	movl   $0xf0108d8e,(%esp)
f0100b90:	e8 2a 44 00 00       	call   f0104fbf <cprintf>
}
f0100b95:	c9                   	leave  
f0100b96:	c3                   	ret    

f0100b97 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100b97:	55                   	push   %ebp
f0100b98:	89 e5                	mov    %esp,%ebp
f0100b9a:	83 ec 18             	sub    $0x18,%esp
	cons_putc(c);
f0100b9d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ba0:	89 04 24             	mov    %eax,(%esp)
f0100ba3:	e8 95 ff ff ff       	call   f0100b3d <cons_putc>
}
f0100ba8:	c9                   	leave  
f0100ba9:	c3                   	ret    

f0100baa <getchar>:

int
getchar(void)
{
f0100baa:	55                   	push   %ebp
f0100bab:	89 e5                	mov    %esp,%ebp
f0100bad:	83 ec 18             	sub    $0x18,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100bb0:	e8 2c ff ff ff       	call   f0100ae1 <cons_getc>
f0100bb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0100bb8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0100bbc:	74 f2                	je     f0100bb0 <getchar+0x6>
		/* do nothing */;
	return c;
f0100bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0100bc1:	c9                   	leave  
f0100bc2:	c3                   	ret    

f0100bc3 <iscons>:

int
iscons(int fdnum)
{
f0100bc3:	55                   	push   %ebp
f0100bc4:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
f0100bc6:	b8 01 00 00 00       	mov    $0x1,%eax
}
f0100bcb:	5d                   	pop    %ebp
f0100bcc:	c3                   	ret    

f0100bcd <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100bcd:	55                   	push   %ebp
f0100bce:	89 e5                	mov    %esp,%ebp
f0100bd0:	83 ec 28             	sub    $0x28,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100bd3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0100bda:	eb 3f                	jmp    f0100c1b <mon_help+0x4e>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100bdc:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100bdf:	89 d0                	mov    %edx,%eax
f0100be1:	01 c0                	add    %eax,%eax
f0100be3:	01 d0                	add    %edx,%eax
f0100be5:	c1 e0 02             	shl    $0x2,%eax
f0100be8:	05 20 55 12 f0       	add    $0xf0125520,%eax
f0100bed:	8b 48 04             	mov    0x4(%eax),%ecx
f0100bf0:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100bf3:	89 d0                	mov    %edx,%eax
f0100bf5:	01 c0                	add    %eax,%eax
f0100bf7:	01 d0                	add    %edx,%eax
f0100bf9:	c1 e0 02             	shl    $0x2,%eax
f0100bfc:	05 20 55 12 f0       	add    $0xf0125520,%eax
f0100c01:	8b 00                	mov    (%eax),%eax
f0100c03:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100c07:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c0b:	c7 04 24 1f 8e 10 f0 	movl   $0xf0108e1f,(%esp)
f0100c12:	e8 a8 43 00 00       	call   f0104fbf <cprintf>
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100c17:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0100c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100c1e:	83 f8 02             	cmp    $0x2,%eax
f0100c21:	76 b9                	jbe    f0100bdc <mon_help+0xf>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
f0100c23:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100c28:	c9                   	leave  
f0100c29:	c3                   	ret    

f0100c2a <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100c2a:	55                   	push   %ebp
f0100c2b:	89 e5                	mov    %esp,%ebp
f0100c2d:	83 ec 28             	sub    $0x28,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100c30:	c7 04 24 28 8e 10 f0 	movl   $0xf0108e28,(%esp)
f0100c37:	e8 83 43 00 00       	call   f0104fbf <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100c3c:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100c43:	00 
f0100c44:	c7 04 24 44 8e 10 f0 	movl   $0xf0108e44,(%esp)
f0100c4b:	e8 6f 43 00 00       	call   f0104fbf <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100c50:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100c57:	00 
f0100c58:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100c5f:	f0 
f0100c60:	c7 04 24 6c 8e 10 f0 	movl   $0xf0108e6c,(%esp)
f0100c67:	e8 53 43 00 00       	call   f0104fbf <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100c6c:	c7 44 24 08 a7 8c 10 	movl   $0x108ca7,0x8(%esp)
f0100c73:	00 
f0100c74:	c7 44 24 04 a7 8c 10 	movl   $0xf0108ca7,0x4(%esp)
f0100c7b:	f0 
f0100c7c:	c7 04 24 90 8e 10 f0 	movl   $0xf0108e90,(%esp)
f0100c83:	e8 37 43 00 00       	call   f0104fbf <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100c88:	c7 44 24 08 61 a9 23 	movl   $0x23a961,0x8(%esp)
f0100c8f:	00 
f0100c90:	c7 44 24 04 61 a9 23 	movl   $0xf023a961,0x4(%esp)
f0100c97:	f0 
f0100c98:	c7 04 24 b4 8e 10 f0 	movl   $0xf0108eb4,(%esp)
f0100c9f:	e8 1b 43 00 00       	call   f0104fbf <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100ca4:	c7 44 24 08 08 d0 27 	movl   $0x27d008,0x8(%esp)
f0100cab:	00 
f0100cac:	c7 44 24 04 08 d0 27 	movl   $0xf027d008,0x4(%esp)
f0100cb3:	f0 
f0100cb4:	c7 04 24 d8 8e 10 f0 	movl   $0xf0108ed8,(%esp)
f0100cbb:	e8 ff 42 00 00       	call   f0104fbf <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100cc0:	c7 45 f4 00 04 00 00 	movl   $0x400,-0xc(%ebp)
f0100cc7:	b8 0c 00 10 f0       	mov    $0xf010000c,%eax
f0100ccc:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100ccf:	29 c2                	sub    %eax,%edx
f0100cd1:	b8 08 d0 27 f0       	mov    $0xf027d008,%eax
f0100cd6:	83 e8 01             	sub    $0x1,%eax
f0100cd9:	01 d0                	add    %edx,%eax
f0100cdb:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100cde:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100ce1:	ba 00 00 00 00       	mov    $0x0,%edx
f0100ce6:	f7 75 f4             	divl   -0xc(%ebp)
f0100ce9:	89 d0                	mov    %edx,%eax
f0100ceb:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100cee:	29 c2                	sub    %eax,%edx
f0100cf0:	89 d0                	mov    %edx,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100cf2:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100cf8:	85 c0                	test   %eax,%eax
f0100cfa:	0f 48 c2             	cmovs  %edx,%eax
f0100cfd:	c1 f8 0a             	sar    $0xa,%eax
f0100d00:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d04:	c7 04 24 fc 8e 10 f0 	movl   $0xf0108efc,(%esp)
f0100d0b:	e8 af 42 00 00       	call   f0104fbf <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
f0100d10:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100d15:	c9                   	leave  
f0100d16:	c3                   	ret    

f0100d17 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100d17:	55                   	push   %ebp
f0100d18:	89 e5                	mov    %esp,%ebp
f0100d1a:	56                   	push   %esi
f0100d1b:	53                   	push   %ebx
f0100d1c:	83 ec 50             	sub    $0x50,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100d1f:	89 e8                	mov    %ebp,%eax
f0100d21:	89 45 e0             	mov    %eax,-0x20(%ebp)
	return ebp;
f0100d24:	8b 45 e0             	mov    -0x20(%ebp),%eax
	uint32_t ebp = read_ebp();
f0100d27:	89 45 f4             	mov    %eax,-0xc(%ebp)
  	uint32_t eip;
  	uint32_t args;
  	uint32_t t; 
  	int i;
  	cprintf("Stack backtrace:\n");
f0100d2a:	c7 04 24 26 8f 10 f0 	movl   $0xf0108f26,(%esp)
f0100d31:	e8 89 42 00 00       	call   f0104fbf <cprintf>
  	struct Eipdebuginfo info;
  	__asm __volatile("movl $.,%0" : "=r" (eip));
f0100d36:	b8 36 0d 10 f0       	mov    $0xf0100d36,%eax
f0100d3b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  // __asm__volatile("")
  	cprintf("current eip= %08x\n",eip);
f0100d3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100d41:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d45:	c7 04 24 38 8f 10 f0 	movl   $0xf0108f38,(%esp)
f0100d4c:	e8 6e 42 00 00       	call   f0104fbf <cprintf>
  	debuginfo_eip (eip, &info);
f0100d51:	8d 45 c8             	lea    -0x38(%ebp),%eax
f0100d54:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d58:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100d5b:	89 04 24             	mov    %eax,(%esp)
f0100d5e:	e8 9b 5f 00 00       	call   f0106cfe <debuginfo_eip>
  	cprintf ("		%s:%d: ", info.eip_file, info.eip_line);
f0100d63:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0100d66:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0100d69:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100d6d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d71:	c7 04 24 4b 8f 10 f0 	movl   $0xf0108f4b,(%esp)
f0100d78:	e8 42 42 00 00       	call   f0104fbf <cprintf>
    for (i=0; i<info.eip_fn_namelen; i++)
f0100d7d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0100d84:	eb 22                	jmp    f0100da8 <mon_backtrace+0x91>
      		cprintf ("%c", info.eip_fn_name[i]);
f0100d86:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0100d89:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100d8c:	01 d0                	add    %edx,%eax
f0100d8e:	0f b6 00             	movzbl (%eax),%eax
f0100d91:	0f be c0             	movsbl %al,%eax
f0100d94:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d98:	c7 04 24 55 8f 10 f0 	movl   $0xf0108f55,(%esp)
f0100d9f:	e8 1b 42 00 00       	call   f0104fbf <cprintf>
  	__asm __volatile("movl $.,%0" : "=r" (eip));
  // __asm__volatile("")
  	cprintf("current eip= %08x\n",eip);
  	debuginfo_eip (eip, &info);
  	cprintf ("		%s:%d: ", info.eip_file, info.eip_line);
    for (i=0; i<info.eip_fn_namelen; i++)
f0100da4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f0100da8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100dab:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f0100dae:	7f d6                	jg     f0100d86 <mon_backtrace+0x6f>
      		cprintf ("%c", info.eip_fn_name[i]);
    cprintf("+%d",eip-info.eip_fn_addr);
f0100db0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100db3:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0100db6:	29 c2                	sub    %eax,%edx
f0100db8:	89 d0                	mov    %edx,%eax
f0100dba:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dbe:	c7 04 24 58 8f 10 f0 	movl   $0xf0108f58,(%esp)
f0100dc5:	e8 f5 41 00 00       	call   f0104fbf <cprintf>
  	cprintf ("\n");
f0100dca:	c7 04 24 5c 8f 10 f0 	movl   $0xf0108f5c,(%esp)
f0100dd1:	e8 e9 41 00 00       	call   f0104fbf <cprintf>
  	while(ebp != 0) {
f0100dd6:	e9 06 01 00 00       	jmp    f0100ee1 <mon_backtrace+0x1ca>
    t = ebp+4;
f0100ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100dde:	83 c0 04             	add    $0x4,%eax
f0100de1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    eip = *(uint32_t*)t;
f0100de4:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100de7:	8b 00                	mov    (%eax),%eax
f0100de9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    args = t + 4;
f0100dec:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100def:	83 c0 04             	add    $0x4,%eax
f0100df2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  	debuginfo_eip (eip, &info);
f0100df5:	8d 45 c8             	lea    -0x38(%ebp),%eax
f0100df8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dfc:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100dff:	89 04 24             	mov    %eax,(%esp)
f0100e02:	e8 f7 5e 00 00       	call   f0106cfe <debuginfo_eip>
    cprintf ("ebp %08x eip %08x ", ebp, eip);
f0100e07:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100e0a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100e11:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e15:	c7 04 24 5e 8f 10 f0 	movl   $0xf0108f5e,(%esp)
f0100e1c:	e8 9e 41 00 00       	call   f0104fbf <cprintf>
    cprintf("args %08x %08x %08x %08x %08x\n",*(uint32_t*)args,*(uint32_t*)(args+4),*(uint32_t*)(args+8),*(uint32_t*)(args+12),*(uint32_t*)(args+16));
f0100e21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e24:	83 c0 10             	add    $0x10,%eax
f0100e27:	8b 30                	mov    (%eax),%esi
f0100e29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e2c:	83 c0 0c             	add    $0xc,%eax
f0100e2f:	8b 18                	mov    (%eax),%ebx
f0100e31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e34:	83 c0 08             	add    $0x8,%eax
f0100e37:	8b 08                	mov    (%eax),%ecx
f0100e39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e3c:	83 c0 04             	add    $0x4,%eax
f0100e3f:	8b 10                	mov    (%eax),%edx
f0100e41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e44:	8b 00                	mov    (%eax),%eax
f0100e46:	89 74 24 14          	mov    %esi,0x14(%esp)
f0100e4a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0100e4e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100e52:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100e56:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e5a:	c7 04 24 74 8f 10 f0 	movl   $0xf0108f74,(%esp)
f0100e61:	e8 59 41 00 00       	call   f0104fbf <cprintf>
    cprintf ("		%s:%d: ", info.eip_file, info.eip_line);
f0100e66:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0100e69:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0100e6c:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100e70:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e74:	c7 04 24 4b 8f 10 f0 	movl   $0xf0108f4b,(%esp)
f0100e7b:	e8 3f 41 00 00       	call   f0104fbf <cprintf>
    for (i=0; i<info.eip_fn_namelen; i++)
f0100e80:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0100e87:	eb 22                	jmp    f0100eab <mon_backtrace+0x194>
      		cprintf ("%c", info.eip_fn_name[i]);
f0100e89:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0100e8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100e8f:	01 d0                	add    %edx,%eax
f0100e91:	0f b6 00             	movzbl (%eax),%eax
f0100e94:	0f be c0             	movsbl %al,%eax
f0100e97:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e9b:	c7 04 24 55 8f 10 f0 	movl   $0xf0108f55,(%esp)
f0100ea2:	e8 18 41 00 00       	call   f0104fbf <cprintf>
    args = t + 4;
  	debuginfo_eip (eip, &info);
    cprintf ("ebp %08x eip %08x ", ebp, eip);
    cprintf("args %08x %08x %08x %08x %08x\n",*(uint32_t*)args,*(uint32_t*)(args+4),*(uint32_t*)(args+8),*(uint32_t*)(args+12),*(uint32_t*)(args+16));
    cprintf ("		%s:%d: ", info.eip_file, info.eip_line);
    for (i=0; i<info.eip_fn_namelen; i++)
f0100ea7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f0100eab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100eae:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f0100eb1:	7f d6                	jg     f0100e89 <mon_backtrace+0x172>
      		cprintf ("%c", info.eip_fn_name[i]);
    cprintf("+%d",eip-info.eip_fn_addr);
f0100eb3:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100eb6:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0100eb9:	29 c2                	sub    %eax,%edx
f0100ebb:	89 d0                	mov    %edx,%eax
f0100ebd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ec1:	c7 04 24 58 8f 10 f0 	movl   $0xf0108f58,(%esp)
f0100ec8:	e8 f2 40 00 00       	call   f0104fbf <cprintf>
    cprintf ("\n");
f0100ecd:	c7 04 24 5c 8f 10 f0 	movl   $0xf0108f5c,(%esp)
f0100ed4:	e8 e6 40 00 00       	call   f0104fbf <cprintf>

    ebp = *(uint32_t*)ebp;
f0100ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100edc:	8b 00                	mov    (%eax),%eax
f0100ede:	89 45 f4             	mov    %eax,-0xc(%ebp)
  	cprintf ("		%s:%d: ", info.eip_file, info.eip_line);
    for (i=0; i<info.eip_fn_namelen; i++)
      		cprintf ("%c", info.eip_fn_name[i]);
    cprintf("+%d",eip-info.eip_fn_addr);
  	cprintf ("\n");
  	while(ebp != 0) {
f0100ee1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0100ee5:	0f 85 f0 fe ff ff    	jne    f0100ddb <mon_backtrace+0xc4>
    cprintf ("\n");

    ebp = *(uint32_t*)ebp;
  } 
	// Your code here.
	return 0;
f0100eeb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100ef0:	83 c4 50             	add    $0x50,%esp
f0100ef3:	5b                   	pop    %ebx
f0100ef4:	5e                   	pop    %esi
f0100ef5:	5d                   	pop    %ebp
f0100ef6:	c3                   	ret    

f0100ef7 <runcmd>:
#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
f0100ef7:	55                   	push   %ebp
f0100ef8:	89 e5                	mov    %esp,%ebp
f0100efa:	83 ec 68             	sub    $0x68,%esp
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100efd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	argv[argc] = 0;
f0100f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100f07:	c7 44 85 b0 00 00 00 	movl   $0x0,-0x50(%ebp,%eax,4)
f0100f0e:	00 
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100f0f:	eb 0c                	jmp    f0100f1d <runcmd+0x26>
			*buf++ = 0;
f0100f11:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f14:	8d 50 01             	lea    0x1(%eax),%edx
f0100f17:	89 55 08             	mov    %edx,0x8(%ebp)
f0100f1a:	c6 00 00             	movb   $0x0,(%eax)
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100f1d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f20:	0f b6 00             	movzbl (%eax),%eax
f0100f23:	84 c0                	test   %al,%al
f0100f25:	74 1d                	je     f0100f44 <runcmd+0x4d>
f0100f27:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f2a:	0f b6 00             	movzbl (%eax),%eax
f0100f2d:	0f be c0             	movsbl %al,%eax
f0100f30:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f34:	c7 04 24 93 8f 10 f0 	movl   $0xf0108f93,(%esp)
f0100f3b:	e8 5b 6b 00 00       	call   f0107a9b <strchr>
f0100f40:	85 c0                	test   %eax,%eax
f0100f42:	75 cd                	jne    f0100f11 <runcmd+0x1a>
			*buf++ = 0;
		if (*buf == 0)
f0100f44:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f47:	0f b6 00             	movzbl (%eax),%eax
f0100f4a:	84 c0                	test   %al,%al
f0100f4c:	75 14                	jne    f0100f62 <runcmd+0x6b>
			break;
f0100f4e:	90                   	nop
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;
f0100f4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100f52:	c7 44 85 b0 00 00 00 	movl   $0x0,-0x50(%ebp,%eax,4)
f0100f59:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100f5a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0100f5e:	75 70                	jne    f0100fd0 <runcmd+0xd9>
f0100f60:	eb 67                	jmp    f0100fc9 <runcmd+0xd2>
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100f62:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
f0100f66:	75 1e                	jne    f0100f86 <runcmd+0x8f>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100f68:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100f6f:	00 
f0100f70:	c7 04 24 98 8f 10 f0 	movl   $0xf0108f98,(%esp)
f0100f77:	e8 43 40 00 00       	call   f0104fbf <cprintf>
			return 0;
f0100f7c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f81:	e9 c9 00 00 00       	jmp    f010104f <runcmd+0x158>
		}
		argv[argc++] = buf;
f0100f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100f89:	8d 50 01             	lea    0x1(%eax),%edx
f0100f8c:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0100f8f:	8b 55 08             	mov    0x8(%ebp),%edx
f0100f92:	89 54 85 b0          	mov    %edx,-0x50(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100f96:	eb 04                	jmp    f0100f9c <runcmd+0xa5>
			buf++;
f0100f98:	83 45 08 01          	addl   $0x1,0x8(%ebp)
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100f9c:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f9f:	0f b6 00             	movzbl (%eax),%eax
f0100fa2:	84 c0                	test   %al,%al
f0100fa4:	74 1d                	je     f0100fc3 <runcmd+0xcc>
f0100fa6:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fa9:	0f b6 00             	movzbl (%eax),%eax
f0100fac:	0f be c0             	movsbl %al,%eax
f0100faf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fb3:	c7 04 24 93 8f 10 f0 	movl   $0xf0108f93,(%esp)
f0100fba:	e8 dc 6a 00 00       	call   f0107a9b <strchr>
f0100fbf:	85 c0                	test   %eax,%eax
f0100fc1:	74 d5                	je     f0100f98 <runcmd+0xa1>
			buf++;
	}
f0100fc3:	90                   	nop
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100fc4:	e9 54 ff ff ff       	jmp    f0100f1d <runcmd+0x26>
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
f0100fc9:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fce:	eb 7f                	jmp    f010104f <runcmd+0x158>
	for (i = 0; i < NCOMMANDS; i++) {
f0100fd0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0100fd7:	eb 56                	jmp    f010102f <runcmd+0x138>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100fd9:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100fdc:	89 d0                	mov    %edx,%eax
f0100fde:	01 c0                	add    %eax,%eax
f0100fe0:	01 d0                	add    %edx,%eax
f0100fe2:	c1 e0 02             	shl    $0x2,%eax
f0100fe5:	05 20 55 12 f0       	add    $0xf0125520,%eax
f0100fea:	8b 10                	mov    (%eax),%edx
f0100fec:	8b 45 b0             	mov    -0x50(%ebp),%eax
f0100fef:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100ff3:	89 04 24             	mov    %eax,(%esp)
f0100ff6:	e8 0b 6a 00 00       	call   f0107a06 <strcmp>
f0100ffb:	85 c0                	test   %eax,%eax
f0100ffd:	75 2c                	jne    f010102b <runcmd+0x134>
			return commands[i].func(argc, argv, tf);
f0100fff:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101002:	89 d0                	mov    %edx,%eax
f0101004:	01 c0                	add    %eax,%eax
f0101006:	01 d0                	add    %edx,%eax
f0101008:	c1 e0 02             	shl    $0x2,%eax
f010100b:	05 20 55 12 f0       	add    $0xf0125520,%eax
f0101010:	8b 40 08             	mov    0x8(%eax),%eax
f0101013:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101016:	89 54 24 08          	mov    %edx,0x8(%esp)
f010101a:	8d 55 b0             	lea    -0x50(%ebp),%edx
f010101d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101021:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101024:	89 14 24             	mov    %edx,(%esp)
f0101027:	ff d0                	call   *%eax
f0101029:	eb 24                	jmp    f010104f <runcmd+0x158>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f010102b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f010102f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101032:	83 f8 02             	cmp    $0x2,%eax
f0101035:	76 a2                	jbe    f0100fd9 <runcmd+0xe2>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0101037:	8b 45 b0             	mov    -0x50(%ebp),%eax
f010103a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010103e:	c7 04 24 b5 8f 10 f0 	movl   $0xf0108fb5,(%esp)
f0101045:	e8 75 3f 00 00       	call   f0104fbf <cprintf>
	return 0;
f010104a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010104f:	c9                   	leave  
f0101050:	c3                   	ret    

f0101051 <monitor>:

void
monitor(struct Trapframe *tf)
{
f0101051:	55                   	push   %ebp
f0101052:	89 e5                	mov    %esp,%ebp
f0101054:	83 ec 28             	sub    $0x28,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0101057:	c7 04 24 cc 8f 10 f0 	movl   $0xf0108fcc,(%esp)
f010105e:	e8 5c 3f 00 00       	call   f0104fbf <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0101063:	c7 04 24 f0 8f 10 f0 	movl   $0xf0108ff0,(%esp)
f010106a:	e8 50 3f 00 00       	call   f0104fbf <cprintf>

	if (tf != NULL)
f010106f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0101073:	74 0b                	je     f0101080 <monitor+0x2f>
		print_trapframe(tf);
f0101075:	8b 45 08             	mov    0x8(%ebp),%eax
f0101078:	89 04 24             	mov    %eax,(%esp)
f010107b:	e8 0b 47 00 00       	call   f010578b <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0101080:	c7 04 24 15 90 10 f0 	movl   $0xf0109015,(%esp)
f0101087:	e8 39 67 00 00       	call   f01077c5 <readline>
f010108c:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if (buf != NULL)
f010108f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0101093:	74 18                	je     f01010ad <monitor+0x5c>
			if (runcmd(buf, tf) < 0)
f0101095:	8b 45 08             	mov    0x8(%ebp),%eax
f0101098:	89 44 24 04          	mov    %eax,0x4(%esp)
f010109c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010109f:	89 04 24             	mov    %eax,(%esp)
f01010a2:	e8 50 fe ff ff       	call   f0100ef7 <runcmd>
f01010a7:	85 c0                	test   %eax,%eax
f01010a9:	79 02                	jns    f01010ad <monitor+0x5c>
				break;
f01010ab:	eb 02                	jmp    f01010af <monitor+0x5e>
	}
f01010ad:	eb d1                	jmp    f0101080 <monitor+0x2f>
}
f01010af:	c9                   	leave  
f01010b0:	c3                   	ret    

f01010b1 <_paddr>:
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f01010b1:	55                   	push   %ebp
f01010b2:	89 e5                	mov    %esp,%ebp
f01010b4:	83 ec 18             	sub    $0x18,%esp
	if ((uint32_t)kva < KERNBASE)
f01010b7:	8b 45 10             	mov    0x10(%ebp),%eax
f01010ba:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01010bf:	77 21                	ja     f01010e2 <_paddr+0x31>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01010c1:	8b 45 10             	mov    0x10(%ebp),%eax
f01010c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01010c8:	c7 44 24 08 1c 90 10 	movl   $0xf010901c,0x8(%esp)
f01010cf:	f0 
f01010d0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010d3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01010d7:	8b 45 08             	mov    0x8(%ebp),%eax
f01010da:	89 04 24             	mov    %eax,(%esp)
f01010dd:	e8 15 f2 ff ff       	call   f01002f7 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01010e2:	8b 45 10             	mov    0x10(%ebp),%eax
f01010e5:	05 00 00 00 10       	add    $0x10000000,%eax
}
f01010ea:	c9                   	leave  
f01010eb:	c3                   	ret    

f01010ec <_kaddr>:
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f01010ec:	55                   	push   %ebp
f01010ed:	89 e5                	mov    %esp,%ebp
f01010ef:	83 ec 18             	sub    $0x18,%esp
	if (PGNUM(pa) >= npages)
f01010f2:	8b 45 10             	mov    0x10(%ebp),%eax
f01010f5:	c1 e8 0c             	shr    $0xc,%eax
f01010f8:	89 c2                	mov    %eax,%edx
f01010fa:	a1 e8 be 23 f0       	mov    0xf023bee8,%eax
f01010ff:	39 c2                	cmp    %eax,%edx
f0101101:	72 21                	jb     f0101124 <_kaddr+0x38>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101103:	8b 45 10             	mov    0x10(%ebp),%eax
f0101106:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010110a:	c7 44 24 08 40 90 10 	movl   $0xf0109040,0x8(%esp)
f0101111:	f0 
f0101112:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101115:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101119:	8b 45 08             	mov    0x8(%ebp),%eax
f010111c:	89 04 24             	mov    %eax,(%esp)
f010111f:	e8 d3 f1 ff ff       	call   f01002f7 <_panic>
	return (void *)(pa + KERNBASE);
f0101124:	8b 45 10             	mov    0x10(%ebp),%eax
f0101127:	2d 00 00 00 10       	sub    $0x10000000,%eax
}
f010112c:	c9                   	leave  
f010112d:	c3                   	ret    

f010112e <page2pa>:
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
f010112e:	55                   	push   %ebp
f010112f:	89 e5                	mov    %esp,%ebp
	return (pp - pages) << PGSHIFT;
f0101131:	8b 55 08             	mov    0x8(%ebp),%edx
f0101134:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f0101139:	29 c2                	sub    %eax,%edx
f010113b:	89 d0                	mov    %edx,%eax
f010113d:	c1 f8 03             	sar    $0x3,%eax
f0101140:	c1 e0 0c             	shl    $0xc,%eax
}
f0101143:	5d                   	pop    %ebp
f0101144:	c3                   	ret    

f0101145 <pa2page>:

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
f0101145:	55                   	push   %ebp
f0101146:	89 e5                	mov    %esp,%ebp
f0101148:	83 ec 18             	sub    $0x18,%esp
	if (PGNUM(pa) >= npages)
f010114b:	8b 45 08             	mov    0x8(%ebp),%eax
f010114e:	c1 e8 0c             	shr    $0xc,%eax
f0101151:	89 c2                	mov    %eax,%edx
f0101153:	a1 e8 be 23 f0       	mov    0xf023bee8,%eax
f0101158:	39 c2                	cmp    %eax,%edx
f010115a:	72 1c                	jb     f0101178 <pa2page+0x33>
		panic("pa2page called with invalid pa");
f010115c:	c7 44 24 08 64 90 10 	movl   $0xf0109064,0x8(%esp)
f0101163:	f0 
f0101164:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f010116b:	00 
f010116c:	c7 04 24 83 90 10 f0 	movl   $0xf0109083,(%esp)
f0101173:	e8 7f f1 ff ff       	call   f01002f7 <_panic>
	return &pages[PGNUM(pa)];
f0101178:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f010117d:	8b 55 08             	mov    0x8(%ebp),%edx
f0101180:	c1 ea 0c             	shr    $0xc,%edx
f0101183:	c1 e2 03             	shl    $0x3,%edx
f0101186:	01 d0                	add    %edx,%eax
}
f0101188:	c9                   	leave  
f0101189:	c3                   	ret    

f010118a <page2kva>:

static inline void*
page2kva(struct PageInfo *pp)
{
f010118a:	55                   	push   %ebp
f010118b:	89 e5                	mov    %esp,%ebp
f010118d:	83 ec 18             	sub    $0x18,%esp
	return KADDR(page2pa(pp));
f0101190:	8b 45 08             	mov    0x8(%ebp),%eax
f0101193:	89 04 24             	mov    %eax,(%esp)
f0101196:	e8 93 ff ff ff       	call   f010112e <page2pa>
f010119b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010119f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01011a6:	00 
f01011a7:	c7 04 24 83 90 10 f0 	movl   $0xf0109083,(%esp)
f01011ae:	e8 39 ff ff ff       	call   f01010ec <_kaddr>
}
f01011b3:	c9                   	leave  
f01011b4:	c3                   	ret    

f01011b5 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f01011b5:	55                   	push   %ebp
f01011b6:	89 e5                	mov    %esp,%ebp
f01011b8:	53                   	push   %ebx
f01011b9:	83 ec 14             	sub    $0x14,%esp
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01011bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01011bf:	89 04 24             	mov    %eax,(%esp)
f01011c2:	e8 47 3b 00 00       	call   f0104d0e <mc146818_read>
f01011c7:	89 c3                	mov    %eax,%ebx
f01011c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01011cc:	83 c0 01             	add    $0x1,%eax
f01011cf:	89 04 24             	mov    %eax,(%esp)
f01011d2:	e8 37 3b 00 00       	call   f0104d0e <mc146818_read>
f01011d7:	c1 e0 08             	shl    $0x8,%eax
f01011da:	09 d8                	or     %ebx,%eax
}
f01011dc:	83 c4 14             	add    $0x14,%esp
f01011df:	5b                   	pop    %ebx
f01011e0:	5d                   	pop    %ebp
f01011e1:	c3                   	ret    

f01011e2 <i386_detect_memory>:

static void
i386_detect_memory(void)
{
f01011e2:	55                   	push   %ebp
f01011e3:	89 e5                	mov    %esp,%ebp
f01011e5:	83 ec 28             	sub    $0x28,%esp
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01011e8:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f01011ef:	e8 c1 ff ff ff       	call   f01011b5 <nvram_read>
f01011f4:	c1 e0 0a             	shl    $0xa,%eax
f01011f7:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01011fd:	85 c0                	test   %eax,%eax
f01011ff:	0f 48 c2             	cmovs  %edx,%eax
f0101202:	c1 f8 0c             	sar    $0xc,%eax
f0101205:	a3 2c b2 23 f0       	mov    %eax,0xf023b22c
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010120a:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101211:	e8 9f ff ff ff       	call   f01011b5 <nvram_read>
f0101216:	c1 e0 0a             	shl    $0xa,%eax
f0101219:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010121f:	85 c0                	test   %eax,%eax
f0101221:	0f 48 c2             	cmovs  %edx,%eax
f0101224:	c1 f8 0c             	sar    $0xc,%eax
f0101227:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010122a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010122e:	74 0f                	je     f010123f <i386_detect_memory+0x5d>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101230:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101233:	05 00 01 00 00       	add    $0x100,%eax
f0101238:	a3 e8 be 23 f0       	mov    %eax,0xf023bee8
f010123d:	eb 0a                	jmp    f0101249 <i386_detect_memory+0x67>
	else
		npages = npages_basemem;
f010123f:	a1 2c b2 23 f0       	mov    0xf023b22c,%eax
f0101244:	a3 e8 be 23 f0       	mov    %eax,0xf023bee8

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101249:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010124c:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010124f:	c1 e8 0a             	shr    $0xa,%eax
f0101252:	89 c1                	mov    %eax,%ecx
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101254:	a1 2c b2 23 f0       	mov    0xf023b22c,%eax
f0101259:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010125c:	c1 e8 0a             	shr    $0xa,%eax
f010125f:	89 c2                	mov    %eax,%edx
		npages * PGSIZE / 1024,
f0101261:	a1 e8 be 23 f0       	mov    0xf023bee8,%eax
f0101266:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101269:	c1 e8 0a             	shr    $0xa,%eax
f010126c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101270:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101274:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101278:	c7 04 24 94 90 10 f0 	movl   $0xf0109094,(%esp)
f010127f:	e8 3b 3d 00 00       	call   f0104fbf <cprintf>
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
}
f0101284:	c9                   	leave  
f0101285:	c3                   	ret    

f0101286 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0101286:	55                   	push   %ebp
f0101287:	89 e5                	mov    %esp,%ebp
f0101289:	83 ec 20             	sub    $0x20,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f010128c:	a1 38 b2 23 f0       	mov    0xf023b238,%eax
f0101291:	85 c0                	test   %eax,%eax
f0101293:	75 30                	jne    f01012c5 <boot_alloc+0x3f>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0101295:	c7 45 fc 00 10 00 00 	movl   $0x1000,-0x4(%ebp)
f010129c:	b8 08 d0 27 f0       	mov    $0xf027d008,%eax
f01012a1:	8d 50 ff             	lea    -0x1(%eax),%edx
f01012a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01012a7:	01 d0                	add    %edx,%eax
f01012a9:	89 45 f8             	mov    %eax,-0x8(%ebp)
f01012ac:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01012af:	ba 00 00 00 00       	mov    $0x0,%edx
f01012b4:	f7 75 fc             	divl   -0x4(%ebp)
f01012b7:	89 d0                	mov    %edx,%eax
f01012b9:	8b 55 f8             	mov    -0x8(%ebp),%edx
f01012bc:	29 c2                	sub    %eax,%edx
f01012be:	89 d0                	mov    %edx,%eax
f01012c0:	a3 38 b2 23 f0       	mov    %eax,0xf023b238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f01012c5:	a1 38 b2 23 f0       	mov    0xf023b238,%eax
f01012ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
	nextfree += ROUNDUP(n,PGSIZE);
f01012cd:	8b 0d 38 b2 23 f0    	mov    0xf023b238,%ecx
f01012d3:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
f01012da:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01012dd:	8b 55 08             	mov    0x8(%ebp),%edx
f01012e0:	01 d0                	add    %edx,%eax
f01012e2:	83 e8 01             	sub    $0x1,%eax
f01012e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01012e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01012eb:	ba 00 00 00 00       	mov    $0x0,%edx
f01012f0:	f7 75 f0             	divl   -0x10(%ebp)
f01012f3:	89 d0                	mov    %edx,%eax
f01012f5:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01012f8:	29 c2                	sub    %eax,%edx
f01012fa:	89 d0                	mov    %edx,%eax
f01012fc:	01 c8                	add    %ecx,%eax
f01012fe:	a3 38 b2 23 f0       	mov    %eax,0xf023b238
	return result;
f0101303:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0101306:	c9                   	leave  
f0101307:	c3                   	ret    

f0101308 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101308:	55                   	push   %ebp
f0101309:	89 e5                	mov    %esp,%ebp
f010130b:	53                   	push   %ebx
f010130c:	83 ec 44             	sub    $0x44,%esp
	uint32_t cr0;
	size_t n;

	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();
f010130f:	e8 ce fe ff ff       	call   f01011e2 <i386_detect_memory>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101314:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
f010131b:	e8 66 ff ff ff       	call   f0101286 <boot_alloc>
f0101320:	a3 ec be 23 f0       	mov    %eax,0xf023beec
	memset(kern_pgdir, 0, PGSIZE);
f0101325:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f010132a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101331:	00 
f0101332:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101339:	00 
f010133a:	89 04 24             	mov    %eax,(%esp)
f010133d:	e8 ba 67 00 00       	call   f0107afc <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101342:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0101347:	8d 98 f4 0e 00 00    	lea    0xef4(%eax),%ebx
f010134d:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0101352:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101356:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
f010135d:	00 
f010135e:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0101365:	e8 47 fd ff ff       	call   f01010b1 <_paddr>
f010136a:	83 c8 05             	or     $0x5,%eax
f010136d:	89 03                	mov    %eax,(%ebx)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	size_t page_info_size = sizeof(struct PageInfo);
f010136f:	c7 45 f4 08 00 00 00 	movl   $0x8,-0xc(%ebp)
	uint32_t memoryallocate = (uint32_t)(npages*page_info_size);
f0101376:	a1 e8 be 23 f0       	mov    0xf023bee8,%eax
f010137b:	0f af 45 f4          	imul   -0xc(%ebp),%eax
f010137f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	pages = (struct PageInfo *) boot_alloc(memoryallocate);
f0101382:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101385:	89 04 24             	mov    %eax,(%esp)
f0101388:	e8 f9 fe ff ff       	call   f0101286 <boot_alloc>
f010138d:	a3 f0 be 23 f0       	mov    %eax,0xf023bef0
 	memset(pages, 0, memoryallocate);
f0101392:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f0101397:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010139a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010139e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01013a5:	00 
f01013a6:	89 04 24             	mov    %eax,(%esp)
f01013a9:	e8 4e 67 00 00       	call   f0107afc <memset>
	// pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
 // 	memset(pages, 0, npages * sizeof(struct PageInfo));
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
 	envs = (struct Env *)boot_alloc(NENV * sizeof(struct Env));
f01013ae:	c7 04 24 00 f0 01 00 	movl   $0x1f000,(%esp)
f01013b5:	e8 cc fe ff ff       	call   f0101286 <boot_alloc>
f01013ba:	a3 3c b2 23 f0       	mov    %eax,0xf023b23c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01013bf:	e8 2e 02 00 00       	call   f01015f2 <page_init>

	// panic("here yippppeeee");
	check_page_free_list(1);
f01013c4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01013cb:	e8 21 0a 00 00       	call   f0101df1 <check_page_free_list>
	check_page_alloc();
f01013d0:	e8 c0 0d 00 00       	call   f0102195 <check_page_alloc>
	// panic("hereeeeeeeeeeeeeeee");
	check_page();
f01013d5:	e8 05 18 00 00       	call   f0102bdf <check_page>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir,UPAGES,ROUNDUP(memoryallocate,PGSIZE),PADDR(pages),(PTE_U | PTE_P));
f01013da:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f01013df:	89 44 24 08          	mov    %eax,0x8(%esp)
f01013e3:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
f01013ea:	00 
f01013eb:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01013f2:	e8 ba fc ff ff       	call   f01010b1 <_paddr>
f01013f7:	89 c1                	mov    %eax,%ecx
f01013f9:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%ebp)
f0101400:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101403:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101406:	01 d0                	add    %edx,%eax
f0101408:	83 e8 01             	sub    $0x1,%eax
f010140b:	89 45 e8             	mov    %eax,-0x18(%ebp)
f010140e:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101411:	ba 00 00 00 00       	mov    $0x0,%edx
f0101416:	f7 75 ec             	divl   -0x14(%ebp)
f0101419:	89 d0                	mov    %edx,%eax
f010141b:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010141e:	29 c2                	sub    %eax,%edx
f0101420:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0101425:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
f010142c:	00 
f010142d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101431:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101435:	c7 44 24 04 00 00 00 	movl   $0xef000000,0x4(%esp)
f010143c:	ef 
f010143d:	89 04 24             	mov    %eax,(%esp)
f0101440:	e8 9a 05 00 00       	call   f01019df <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U | PTE_P);
f0101445:	a1 3c b2 23 f0       	mov    0xf023b23c,%eax
f010144a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010144e:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
f0101455:	00 
f0101456:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010145d:	e8 4f fc ff ff       	call   f01010b1 <_paddr>
f0101462:	8b 15 ec be 23 f0    	mov    0xf023beec,%edx
f0101468:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
f010146f:	00 
f0101470:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101474:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f010147b:	00 
f010147c:	c7 44 24 04 00 00 c0 	movl   $0xeec00000,0x4(%esp)
f0101483:	ee 
f0101484:	89 14 24             	mov    %edx,(%esp)
f0101487:	e8 53 05 00 00       	call   f01019df <boot_map_region>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE,KSTKSIZE,PADDR(bootstack),(PTE_W|PTE_P)); 
f010148c:	c7 44 24 08 00 b0 11 	movl   $0xf011b000,0x8(%esp)
f0101493:	f0 
f0101494:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
f010149b:	00 
f010149c:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01014a3:	e8 09 fc ff ff       	call   f01010b1 <_paddr>
f01014a8:	8b 15 ec be 23 f0    	mov    0xf023beec,%edx
f01014ae:	c7 44 24 10 03 00 00 	movl   $0x3,0x10(%esp)
f01014b5:	00 
f01014b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01014ba:	c7 44 24 08 00 80 00 	movl   $0x8000,0x8(%esp)
f01014c1:	00 
f01014c2:	c7 44 24 04 00 80 ff 	movl   $0xefff8000,0x4(%esp)
f01014c9:	ef 
f01014ca:	89 14 24             	mov    %edx,(%esp)
f01014cd:	e8 0d 05 00 00       	call   f01019df <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir,KERNBASE,0xFFFFFFFF-KERNBASE,0,(PTE_W | PTE_P));
f01014d2:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f01014d7:	c7 44 24 10 03 00 00 	movl   $0x3,0x10(%esp)
f01014de:	00 
f01014df:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01014e6:	00 
f01014e7:	c7 44 24 08 ff ff ff 	movl   $0xfffffff,0x8(%esp)
f01014ee:	0f 
f01014ef:	c7 44 24 04 00 00 00 	movl   $0xf0000000,0x4(%esp)
f01014f6:	f0 
f01014f7:	89 04 24             	mov    %eax,(%esp)
f01014fa:	e8 e0 04 00 00       	call   f01019df <boot_map_region>

	// Initialize the SMP-related parts of the memory map
	mem_init_mp();
f01014ff:	e8 65 00 00 00       	call   f0101569 <mem_init_mp>

	// Check that the initial page directory has been set up correctly.
	check_kern_pgdir();
f0101504:	e8 3e 12 00 00       	call   f0102747 <check_kern_pgdir>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0101509:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f010150e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101512:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
f0101519:	00 
f010151a:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0101521:	e8 8b fb ff ff       	call   f01010b1 <_paddr>
f0101526:	89 45 e0             	mov    %eax,-0x20(%ebp)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0101529:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010152c:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010152f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101536:	e8 b6 08 00 00       	call   f0101df1 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f010153b:	0f 20 c0             	mov    %cr0,%eax
f010153e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	return val;
f0101541:	8b 45 dc             	mov    -0x24(%ebp),%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
f0101544:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0101547:	81 4d e4 23 00 05 80 	orl    $0x80050023,-0x1c(%ebp)
	cr0 &= ~(CR0_TS|CR0_EM);
f010154e:	83 65 e4 f3          	andl   $0xfffffff3,-0x1c(%ebp)
f0101552:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101555:	89 45 d8             	mov    %eax,-0x28(%ebp)
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0101558:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010155b:	0f 22 c0             	mov    %eax,%cr0
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
f010155e:	e8 f3 28 00 00       	call   f0103e56 <check_page_installed_pgdir>
}
f0101563:	83 c4 44             	add    $0x44,%esp
f0101566:	5b                   	pop    %ebx
f0101567:	5d                   	pop    %ebp
f0101568:	c3                   	ret    

f0101569 <mem_init_mp>:
// Modify mappings in kern_pgdir to support SMP
//   - Map the per-CPU stacks in the region [KSTACKTOP-PTSIZE, KSTACKTOP)
//
static void
mem_init_mp(void)
{
f0101569:	55                   	push   %ebp
f010156a:	89 e5                	mov    %esp,%ebp
f010156c:	53                   	push   %ebx
f010156d:	83 ec 34             	sub    $0x34,%esp
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for(i = 0;i<NCPU;i++)
f0101570:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0101577:	eb 6d                	jmp    f01015e6 <mem_init_mp+0x7d>
	{
		boot_map_region(kern_pgdir,KSTACKTOP - (i+1)*KSTKSIZE - i*KSTKGAP,KSTKSIZE,PADDR(percpu_kstacks[i]),PTE_W|PTE_P);
f0101579:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010157c:	c1 e0 0f             	shl    $0xf,%eax
f010157f:	05 00 d0 23 f0       	add    $0xf023d000,%eax
f0101584:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101588:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
f010158f:	00 
f0101590:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0101597:	e8 15 fb ff ff       	call   f01010b1 <_paddr>
f010159c:	89 c2                	mov    %eax,%edx
f010159e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01015a1:	f7 d0                	not    %eax
f01015a3:	c1 e0 0f             	shl    $0xf,%eax
f01015a6:	89 c1                	mov    %eax,%ecx
f01015a8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01015ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01015b0:	29 d8                	sub    %ebx,%eax
f01015b2:	c1 e0 0f             	shl    $0xf,%eax
f01015b5:	01 c8                	add    %ecx,%eax
f01015b7:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f01015bd:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f01015c2:	c7 44 24 10 03 00 00 	movl   $0x3,0x10(%esp)
f01015c9:	00 
f01015ca:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01015ce:	c7 44 24 08 00 80 00 	movl   $0x8000,0x8(%esp)
f01015d5:	00 
f01015d6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01015da:	89 04 24             	mov    %eax,(%esp)
f01015dd:	e8 fd 03 00 00       	call   f01019df <boot_map_region>
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for(i = 0;i<NCPU;i++)
f01015e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f01015e6:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
f01015ea:	7e 8d                	jle    f0101579 <mem_init_mp+0x10>
	{
		boot_map_region(kern_pgdir,KSTACKTOP - (i+1)*KSTKSIZE - i*KSTKGAP,KSTKSIZE,PADDR(percpu_kstacks[i]),PTE_W|PTE_P);
	}

}
f01015ec:	83 c4 34             	add    $0x34,%esp
f01015ef:	5b                   	pop    %ebx
f01015f0:	5d                   	pop    %ebp
f01015f1:	c3                   	ret    

f01015f2 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01015f2:	55                   	push   %ebp
f01015f3:	89 e5                	mov    %esp,%ebp
f01015f5:	83 ec 14             	sub    $0x14,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	uint32_t kernel_pages = (((uint32_t) boot_alloc(0)) - KERNBASE) / PGSIZE;
f01015f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015ff:	e8 82 fc ff ff       	call   f0101286 <boot_alloc>
f0101604:	05 00 00 00 10       	add    $0x10000000,%eax
f0101609:	c1 e8 0c             	shr    $0xc,%eax
f010160c:	89 45 f8             	mov    %eax,-0x8(%ebp)
	size_t mppg = MPENTRY_PADDR/PGSIZE;
f010160f:	c7 45 f4 07 00 00 00 	movl   $0x7,-0xc(%ebp)
	for (i = 0; i < npages; i++) {
f0101616:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f010161d:	e9 90 01 00 00       	jmp    f01017b2 <page_init+0x1c0>
		if(i == 0)
f0101622:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
f0101626:	75 2b                	jne    f0101653 <page_init+0x61>
		{
			pages[i].pp_ref = 1;
f0101628:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f010162d:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0101630:	c1 e2 03             	shl    $0x3,%edx
f0101633:	01 d0                	add    %edx,%eax
f0101635:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f010163b:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f0101640:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0101643:	c1 e2 03             	shl    $0x3,%edx
f0101646:	01 d0                	add    %edx,%eax
f0101648:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f010164e:	e9 5b 01 00 00       	jmp    f01017ae <page_init+0x1bc>
		}
		else if(i == mppg)
f0101653:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0101656:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0101659:	75 2b                	jne    f0101686 <page_init+0x94>
		{
			pages[i].pp_ref = 1;
f010165b:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f0101660:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0101663:	c1 e2 03             	shl    $0x3,%edx
f0101666:	01 d0                	add    %edx,%eax
f0101668:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f010166e:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f0101673:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0101676:	c1 e2 03             	shl    $0x3,%edx
f0101679:	01 d0                	add    %edx,%eax
f010167b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0101681:	e9 28 01 00 00       	jmp    f01017ae <page_init+0x1bc>
			
		}
		else if(i > 0 && i < npages_basemem)
f0101686:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
f010168a:	74 48                	je     f01016d4 <page_init+0xe2>
f010168c:	a1 2c b2 23 f0       	mov    0xf023b22c,%eax
f0101691:	39 45 fc             	cmp    %eax,-0x4(%ebp)
f0101694:	73 3e                	jae    f01016d4 <page_init+0xe2>
		{
			pages[i].pp_ref = 0;
f0101696:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f010169b:	8b 55 fc             	mov    -0x4(%ebp),%edx
f010169e:	c1 e2 03             	shl    $0x3,%edx
f01016a1:	01 d0                	add    %edx,%eax
f01016a3:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f01016a9:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f01016ae:	8b 55 fc             	mov    -0x4(%ebp),%edx
f01016b1:	c1 e2 03             	shl    $0x3,%edx
f01016b4:	01 c2                	add    %eax,%edx
f01016b6:	a1 30 b2 23 f0       	mov    0xf023b230,%eax
f01016bb:	89 02                	mov    %eax,(%edx)
			page_free_list = &pages[i];
f01016bd:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f01016c2:	8b 55 fc             	mov    -0x4(%ebp),%edx
f01016c5:	c1 e2 03             	shl    $0x3,%edx
f01016c8:	01 d0                	add    %edx,%eax
f01016ca:	a3 30 b2 23 f0       	mov    %eax,0xf023b230
f01016cf:	e9 da 00 00 00       	jmp    f01017ae <page_init+0x1bc>
		}
		else if(i >= IOPHYSMEM/PGSIZE && i < EXTPHYSMEM/PGSIZE)
f01016d4:	81 7d fc 9f 00 00 00 	cmpl   $0x9f,-0x4(%ebp)
f01016db:	76 47                	jbe    f0101724 <page_init+0x132>
f01016dd:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
f01016e4:	77 3e                	ja     f0101724 <page_init+0x132>
		{
			pages[i].pp_ref += 1;
f01016e6:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f01016eb:	8b 55 fc             	mov    -0x4(%ebp),%edx
f01016ee:	c1 e2 03             	shl    $0x3,%edx
f01016f1:	01 d0                	add    %edx,%eax
f01016f3:	8b 15 f0 be 23 f0    	mov    0xf023bef0,%edx
f01016f9:	8b 4d fc             	mov    -0x4(%ebp),%ecx
f01016fc:	c1 e1 03             	shl    $0x3,%ecx
f01016ff:	01 ca                	add    %ecx,%edx
f0101701:	0f b7 52 04          	movzwl 0x4(%edx),%edx
f0101705:	83 c2 01             	add    $0x1,%edx
f0101708:	66 89 50 04          	mov    %dx,0x4(%eax)
			pages[i].pp_link = NULL;
f010170c:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f0101711:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0101714:	c1 e2 03             	shl    $0x3,%edx
f0101717:	01 d0                	add    %edx,%eax
f0101719:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f010171f:	e9 8a 00 00 00       	jmp    f01017ae <page_init+0x1bc>
		}	
		else if(i >= EXTPHYSMEM/PGSIZE && i < EXTPHYSMEM/PGSIZE + kernel_pages)
f0101724:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
f010172b:	76 48                	jbe    f0101775 <page_init+0x183>
f010172d:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0101730:	05 00 01 00 00       	add    $0x100,%eax
f0101735:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f0101738:	76 3b                	jbe    f0101775 <page_init+0x183>
		{
			pages[i].pp_ref += 1;
f010173a:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f010173f:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0101742:	c1 e2 03             	shl    $0x3,%edx
f0101745:	01 d0                	add    %edx,%eax
f0101747:	8b 15 f0 be 23 f0    	mov    0xf023bef0,%edx
f010174d:	8b 4d fc             	mov    -0x4(%ebp),%ecx
f0101750:	c1 e1 03             	shl    $0x3,%ecx
f0101753:	01 ca                	add    %ecx,%edx
f0101755:	0f b7 52 04          	movzwl 0x4(%edx),%edx
f0101759:	83 c2 01             	add    $0x1,%edx
f010175c:	66 89 50 04          	mov    %dx,0x4(%eax)
			pages[i].pp_link = NULL;
f0101760:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f0101765:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0101768:	c1 e2 03             	shl    $0x3,%edx
f010176b:	01 d0                	add    %edx,%eax
f010176d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0101773:	eb 39                	jmp    f01017ae <page_init+0x1bc>
		}
		else
		{
			pages[i].pp_ref = 0;
f0101775:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f010177a:	8b 55 fc             	mov    -0x4(%ebp),%edx
f010177d:	c1 e2 03             	shl    $0x3,%edx
f0101780:	01 d0                	add    %edx,%eax
f0101782:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0101788:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f010178d:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0101790:	c1 e2 03             	shl    $0x3,%edx
f0101793:	01 c2                	add    %eax,%edx
f0101795:	a1 30 b2 23 f0       	mov    0xf023b230,%eax
f010179a:	89 02                	mov    %eax,(%edx)
			page_free_list = &pages[i];	
f010179c:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f01017a1:	8b 55 fc             	mov    -0x4(%ebp),%edx
f01017a4:	c1 e2 03             	shl    $0x3,%edx
f01017a7:	01 d0                	add    %edx,%eax
f01017a9:	a3 30 b2 23 f0       	mov    %eax,0xf023b230
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	uint32_t kernel_pages = (((uint32_t) boot_alloc(0)) - KERNBASE) / PGSIZE;
	size_t mppg = MPENTRY_PADDR/PGSIZE;
	for (i = 0; i < npages; i++) {
f01017ae:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
f01017b2:	a1 e8 be 23 f0       	mov    0xf023bee8,%eax
f01017b7:	39 45 fc             	cmp    %eax,-0x4(%ebp)
f01017ba:	0f 82 62 fe ff ff    	jb     f0101622 <page_init+0x30>
			pages[i].pp_ref = 0;
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];	
		}
	}
}
f01017c0:	c9                   	leave  
f01017c1:	c3                   	ret    

f01017c2 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01017c2:	55                   	push   %ebp
f01017c3:	89 e5                	mov    %esp,%ebp
f01017c5:	83 ec 28             	sub    $0x28,%esp
	// Fill this function in
	struct PageInfo* new_page = page_free_list;
f01017c8:	a1 30 b2 23 f0       	mov    0xf023b230,%eax
f01017cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(!page_free_list)
f01017d0:	a1 30 b2 23 f0       	mov    0xf023b230,%eax
f01017d5:	85 c0                	test   %eax,%eax
f01017d7:	75 07                	jne    f01017e0 <page_alloc+0x1e>
	{
		return NULL;
f01017d9:	b8 00 00 00 00       	mov    $0x0,%eax
f01017de:	eb 45                	jmp    f0101825 <page_alloc+0x63>
	}
	page_free_list = page_free_list->pp_link;
f01017e0:	a1 30 b2 23 f0       	mov    0xf023b230,%eax
f01017e5:	8b 00                	mov    (%eax),%eax
f01017e7:	a3 30 b2 23 f0       	mov    %eax,0xf023b230
	if (alloc_flags & ALLOC_ZERO)
f01017ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01017ef:	83 e0 01             	and    $0x1,%eax
f01017f2:	85 c0                	test   %eax,%eax
f01017f4:	74 23                	je     f0101819 <page_alloc+0x57>
	{
		memset(page2kva(new_page), 0, PGSIZE);
f01017f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01017f9:	89 04 24             	mov    %eax,(%esp)
f01017fc:	e8 89 f9 ff ff       	call   f010118a <page2kva>
f0101801:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101808:	00 
f0101809:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101810:	00 
f0101811:	89 04 24             	mov    %eax,(%esp)
f0101814:	e8 e3 62 00 00       	call   f0107afc <memset>
	}
	new_page->pp_link = NULL;
f0101819:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010181c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return new_page;
f0101822:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0101825:	c9                   	leave  
f0101826:	c3                   	ret    

f0101827 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101827:	55                   	push   %ebp
f0101828:	89 e5                	mov    %esp,%ebp
f010182a:	83 ec 18             	sub    $0x18,%esp
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_ref != 0)
f010182d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101830:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0101834:	66 85 c0             	test   %ax,%ax
f0101837:	74 1c                	je     f0101855 <page_free+0x2e>
	{
		panic("ppref of page link is not 0");
f0101839:	c7 44 24 08 dc 90 10 	movl   $0xf01090dc,0x8(%esp)
f0101840:	f0 
f0101841:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
f0101848:	00 
f0101849:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0101850:	e8 a2 ea ff ff       	call   f01002f7 <_panic>
	}
	if(pp->pp_link != NULL)
f0101855:	8b 45 08             	mov    0x8(%ebp),%eax
f0101858:	8b 00                	mov    (%eax),%eax
f010185a:	85 c0                	test   %eax,%eax
f010185c:	74 1c                	je     f010187a <page_free+0x53>
	{
		panic("pplink is not null");
f010185e:	c7 44 24 08 f8 90 10 	movl   $0xf01090f8,0x8(%esp)
f0101865:	f0 
f0101866:	c7 44 24 04 8e 01 00 	movl   $0x18e,0x4(%esp)
f010186d:	00 
f010186e:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0101875:	e8 7d ea ff ff       	call   f01002f7 <_panic>
	}
  	pp->pp_link = page_free_list;
f010187a:	8b 15 30 b2 23 f0    	mov    0xf023b230,%edx
f0101880:	8b 45 08             	mov    0x8(%ebp),%eax
f0101883:	89 10                	mov    %edx,(%eax)
  	page_free_list = pp;
f0101885:	8b 45 08             	mov    0x8(%ebp),%eax
f0101888:	a3 30 b2 23 f0       	mov    %eax,0xf023b230
}
f010188d:	c9                   	leave  
f010188e:	c3                   	ret    

f010188f <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010188f:	55                   	push   %ebp
f0101890:	89 e5                	mov    %esp,%ebp
f0101892:	83 ec 18             	sub    $0x18,%esp
	if (--pp->pp_ref == 0)
f0101895:	8b 45 08             	mov    0x8(%ebp),%eax
f0101898:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f010189c:	8d 50 ff             	lea    -0x1(%eax),%edx
f010189f:	8b 45 08             	mov    0x8(%ebp),%eax
f01018a2:	66 89 50 04          	mov    %dx,0x4(%eax)
f01018a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01018a9:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01018ad:	66 85 c0             	test   %ax,%ax
f01018b0:	75 0b                	jne    f01018bd <page_decref+0x2e>
		page_free(pp);
f01018b2:	8b 45 08             	mov    0x8(%ebp),%eax
f01018b5:	89 04 24             	mov    %eax,(%esp)
f01018b8:	e8 6a ff ff ff       	call   f0101827 <page_free>
}
f01018bd:	c9                   	leave  
f01018be:	c3                   	ret    

f01018bf <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.

pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01018bf:	55                   	push   %ebp
f01018c0:	89 e5                	mov    %esp,%ebp
f01018c2:	83 ec 38             	sub    $0x38,%esp
	size_t page_dir_index = PDX(va);
f01018c5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01018c8:	c1 e8 16             	shr    $0x16,%eax
f01018cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
	size_t pg_table_index = PTX(va);
f01018ce:	8b 45 0c             	mov    0xc(%ebp),%eax
f01018d1:	c1 e8 0c             	shr    $0xc,%eax
f01018d4:	25 ff 03 00 00       	and    $0x3ff,%eax
f01018d9:	89 45 f0             	mov    %eax,-0x10(%ebp)

	pde_t *pg_dir_entry = &pgdir[page_dir_index];
f01018dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01018df:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01018e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01018e9:	01 d0                	add    %edx,%eax
f01018eb:	89 45 ec             	mov    %eax,-0x14(%ebp)

	if (!(*pg_dir_entry & PTE_P) && !create)
f01018ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01018f1:	8b 00                	mov    (%eax),%eax
f01018f3:	83 e0 01             	and    $0x1,%eax
f01018f6:	85 c0                	test   %eax,%eax
f01018f8:	75 10                	jne    f010190a <pgdir_walk+0x4b>
f01018fa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01018fe:	75 0a                	jne    f010190a <pgdir_walk+0x4b>
	{
  		return NULL;
f0101900:	b8 00 00 00 00       	mov    $0x0,%eax
f0101905:	e9 d3 00 00 00       	jmp    f01019dd <pgdir_walk+0x11e>
	}
  	else if (!(*pg_dir_entry & PTE_P) && create) 
f010190a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010190d:	8b 00                	mov    (%eax),%eax
f010190f:	83 e0 01             	and    $0x1,%eax
f0101912:	85 c0                	test   %eax,%eax
f0101914:	0f 85 8f 00 00 00    	jne    f01019a9 <pgdir_walk+0xea>
f010191a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010191e:	0f 84 85 00 00 00    	je     f01019a9 <pgdir_walk+0xea>
  	{
  		struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
f0101924:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010192b:	e8 92 fe ff ff       	call   f01017c2 <page_alloc>
f0101930:	89 45 e8             	mov    %eax,-0x18(%ebp)
		if (new_page == NULL)
f0101933:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0101937:	75 0a                	jne    f0101943 <pgdir_walk+0x84>
		{ 
			return NULL;
f0101939:	b8 00 00 00 00       	mov    $0x0,%eax
f010193e:	e9 9a 00 00 00       	jmp    f01019dd <pgdir_walk+0x11e>
		}
		new_page->pp_ref += 1;
f0101943:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101946:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f010194a:	8d 50 01             	lea    0x1(%eax),%edx
f010194d:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101950:	66 89 50 04          	mov    %dx,0x4(%eax)
		*pg_dir_entry = page2pa(new_page);
f0101954:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101957:	89 04 24             	mov    %eax,(%esp)
f010195a:	e8 cf f7 ff ff       	call   f010112e <page2pa>
f010195f:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0101962:	89 02                	mov    %eax,(%edx)
		*pg_dir_entry |= PTE_P | PTE_U | PTE_W;
f0101964:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101967:	8b 00                	mov    (%eax),%eax
f0101969:	83 c8 07             	or     $0x7,%eax
f010196c:	89 c2                	mov    %eax,%edx
f010196e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101971:	89 10                	mov    %edx,(%eax)
  		pte_t *pte = KADDR(PTE_ADDR(*pg_dir_entry));
f0101973:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101976:	8b 00                	mov    (%eax),%eax
f0101978:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010197d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101981:	c7 44 24 04 cb 01 00 	movl   $0x1cb,0x4(%esp)
f0101988:	00 
f0101989:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0101990:	e8 57 f7 ff ff       	call   f01010ec <_kaddr>
f0101995:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  		return &pte[pg_table_index];
f0101998:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010199b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01019a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01019a5:	01 d0                	add    %edx,%eax
f01019a7:	eb 34                	jmp    f01019dd <pgdir_walk+0x11e>
  	}
  	else
  	{
  		pte_t *pte = KADDR(PTE_ADDR(*pg_dir_entry));
f01019a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01019ac:	8b 00                	mov    (%eax),%eax
f01019ae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01019b3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01019b7:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
f01019be:	00 
f01019bf:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01019c6:	e8 21 f7 ff ff       	call   f01010ec <_kaddr>
f01019cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  		return &pte[pg_table_index];
f01019ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01019d1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01019d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01019db:	01 d0                	add    %edx,%eax
  	}
}
f01019dd:	c9                   	leave  
f01019de:	c3                   	ret    

f01019df <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01019df:	55                   	push   %ebp
f01019e0:	89 e5                	mov    %esp,%ebp
f01019e2:	83 ec 28             	sub    $0x28,%esp
	uintptr_t va1 = va;
f01019e5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01019e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	physaddr_t pa1 = pa;
f01019eb:	8b 45 14             	mov    0x14(%ebp),%eax
f01019ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
	size_t i;
	for(i = 0;i < size;i += PGSIZE)
f01019f1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f01019f8:	eb 64                	jmp    f0101a5e <boot_map_region+0x7f>
	{
		pte_t *x = pgdir_walk(pgdir,(void *)va1,1);
f01019fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01019fd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101a04:	00 
f0101a05:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101a09:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a0c:	89 04 24             	mov    %eax,(%esp)
f0101a0f:	e8 ab fe ff ff       	call   f01018bf <pgdir_walk>
f0101a14:	89 45 e8             	mov    %eax,-0x18(%ebp)
		if(x == NULL)
f0101a17:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0101a1b:	75 1c                	jne    f0101a39 <boot_map_region+0x5a>
		{
			panic("allocation of page failed");
f0101a1d:	c7 44 24 08 0b 91 10 	movl   $0xf010910b,0x8(%esp)
f0101a24:	f0 
f0101a25:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
f0101a2c:	00 
f0101a2d:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0101a34:	e8 be e8 ff ff       	call   f01002f7 <_panic>
		}
		*x = pa1 | perm | PTE_P;
f0101a39:	8b 45 18             	mov    0x18(%ebp),%eax
f0101a3c:	0b 45 f0             	or     -0x10(%ebp),%eax
f0101a3f:	83 c8 01             	or     $0x1,%eax
f0101a42:	89 c2                	mov    %eax,%edx
f0101a44:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101a47:	89 10                	mov    %edx,(%eax)
		va1 += PGSIZE;
f0101a49:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
		pa1 += PGSIZE;
f0101a50:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	uintptr_t va1 = va;
	physaddr_t pa1 = pa;
	size_t i;
	for(i = 0;i < size;i += PGSIZE)
f0101a57:	81 45 ec 00 10 00 00 	addl   $0x1000,-0x14(%ebp)
f0101a5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101a61:	3b 45 10             	cmp    0x10(%ebp),%eax
f0101a64:	72 94                	jb     f01019fa <boot_map_region+0x1b>
		va1 += PGSIZE;
		pa1 += PGSIZE;
	}
	// Fill this function in

}
f0101a66:	c9                   	leave  
f0101a67:	c3                   	ret    

f0101a68 <page_insert>:
		// 	pp->pp_ref += 1;
		// 	return 0;
		// }
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101a68:	55                   	push   %ebp
f0101a69:	89 e5                	mov    %esp,%ebp
f0101a6b:	83 ec 28             	sub    $0x28,%esp
	pte_t *pg_table_entry = pgdir_walk(pgdir,va,1);
f0101a6e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101a75:	00 
f0101a76:	8b 45 10             	mov    0x10(%ebp),%eax
f0101a79:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101a7d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a80:	89 04 24             	mov    %eax,(%esp)
f0101a83:	e8 37 fe ff ff       	call   f01018bf <pgdir_walk>
f0101a88:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(!pg_table_entry)
f0101a8b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0101a8f:	75 07                	jne    f0101a98 <page_insert+0x30>
	{
		return -E_NO_MEM;
f0101a91:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101a96:	eb 7f                	jmp    f0101b17 <page_insert+0xaf>
	}
	pp->pp_ref += 1;
f0101a98:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101a9b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0101a9f:	8d 50 01             	lea    0x1(%eax),%edx
f0101aa2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101aa5:	66 89 50 04          	mov    %dx,0x4(%eax)
	if((*pg_table_entry & PTE_P))
f0101aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101aac:	8b 00                	mov    (%eax),%eax
f0101aae:	83 e0 01             	and    $0x1,%eax
f0101ab1:	85 c0                	test   %eax,%eax
f0101ab3:	74 12                	je     f0101ac7 <page_insert+0x5f>
	{
		page_remove(pgdir,va);
f0101ab5:	8b 45 10             	mov    0x10(%ebp),%eax
f0101ab8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101abc:	8b 45 08             	mov    0x8(%ebp),%eax
f0101abf:	89 04 24             	mov    %eax,(%esp)
f0101ac2:	e8 b7 00 00 00       	call   f0101b7e <page_remove>
	}
	pgdir[PDX(va)] |= perm;
f0101ac7:	8b 45 10             	mov    0x10(%ebp),%eax
f0101aca:	c1 e8 16             	shr    $0x16,%eax
f0101acd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0101ad4:	8b 45 08             	mov    0x8(%ebp),%eax
f0101ad7:	01 d0                	add    %edx,%eax
f0101ad9:	8b 55 10             	mov    0x10(%ebp),%edx
f0101adc:	c1 ea 16             	shr    $0x16,%edx
f0101adf:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
f0101ae6:	8b 55 08             	mov    0x8(%ebp),%edx
f0101ae9:	01 ca                	add    %ecx,%edx
f0101aeb:	8b 0a                	mov    (%edx),%ecx
f0101aed:	8b 55 14             	mov    0x14(%ebp),%edx
f0101af0:	09 ca                	or     %ecx,%edx
f0101af2:	89 10                	mov    %edx,(%eax)
	physaddr_t phy_addr = page2pa(pp);
f0101af4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101af7:	89 04 24             	mov    %eax,(%esp)
f0101afa:	e8 2f f6 ff ff       	call   f010112e <page2pa>
f0101aff:	89 45 f0             	mov    %eax,-0x10(%ebp)
	*pg_table_entry = phy_addr | perm | PTE_P;
f0101b02:	8b 45 14             	mov    0x14(%ebp),%eax
f0101b05:	0b 45 f0             	or     -0x10(%ebp),%eax
f0101b08:	83 c8 01             	or     $0x1,%eax
f0101b0b:	89 c2                	mov    %eax,%edx
f0101b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101b10:	89 10                	mov    %edx,(%eax)
	// Fill this function in
	return 0;
f0101b12:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101b17:	c9                   	leave  
f0101b18:	c3                   	ret    

f0101b19 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101b19:	55                   	push   %ebp
f0101b1a:	89 e5                	mov    %esp,%ebp
f0101b1c:	83 ec 28             	sub    $0x28,%esp
	// Fill this function in
	pte_t *pg_table_entry = pgdir_walk(pgdir,va,0);
f0101b1f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101b26:	00 
f0101b27:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101b2a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b31:	89 04 24             	mov    %eax,(%esp)
f0101b34:	e8 86 fd ff ff       	call   f01018bf <pgdir_walk>
f0101b39:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(pg_table_entry == NULL)
f0101b3c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0101b40:	75 07                	jne    f0101b49 <page_lookup+0x30>
	{
		return NULL;
f0101b42:	b8 00 00 00 00       	mov    $0x0,%eax
f0101b47:	eb 33                	jmp    f0101b7c <page_lookup+0x63>
	}
	if(!(*pg_table_entry & PTE_P))
f0101b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101b4c:	8b 00                	mov    (%eax),%eax
f0101b4e:	83 e0 01             	and    $0x1,%eax
f0101b51:	85 c0                	test   %eax,%eax
f0101b53:	75 07                	jne    f0101b5c <page_lookup+0x43>
	{
		return NULL;
f0101b55:	b8 00 00 00 00       	mov    $0x0,%eax
f0101b5a:	eb 20                	jmp    f0101b7c <page_lookup+0x63>
	}
	if(pte_store != NULL)
f0101b5c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101b60:	74 08                	je     f0101b6a <page_lookup+0x51>
	{
		*pte_store = pg_table_entry;
f0101b62:	8b 45 10             	mov    0x10(%ebp),%eax
f0101b65:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101b68:	89 10                	mov    %edx,(%eax)
	}
	return pa2page(PTE_ADDR(*pg_table_entry));
f0101b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101b6d:	8b 00                	mov    (%eax),%eax
f0101b6f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101b74:	89 04 24             	mov    %eax,(%esp)
f0101b77:	e8 c9 f5 ff ff       	call   f0101145 <pa2page>
}
f0101b7c:	c9                   	leave  
f0101b7d:	c3                   	ret    

f0101b7e <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101b7e:	55                   	push   %ebp
f0101b7f:	89 e5                	mov    %esp,%ebp
f0101b81:	83 ec 28             	sub    $0x28,%esp
	pte_t* x;
	pte_t **store = &x;
f0101b84:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101b87:	89 45 f4             	mov    %eax,-0xc(%ebp)
	struct PageInfo *page = page_lookup(pgdir,va,store);
f0101b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101b8d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101b91:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101b94:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b98:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b9b:	89 04 24             	mov    %eax,(%esp)
f0101b9e:	e8 76 ff ff ff       	call   f0101b19 <page_lookup>
f0101ba3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (!x)
f0101ba6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101ba9:	85 c0                	test   %eax,%eax
f0101bab:	75 02                	jne    f0101baf <page_remove+0x31>
		return;
f0101bad:	eb 36                	jmp    f0101be5 <page_remove+0x67>
	if(!(*x & PTE_P))
f0101baf:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101bb2:	8b 00                	mov    (%eax),%eax
f0101bb4:	83 e0 01             	and    $0x1,%eax
f0101bb7:	85 c0                	test   %eax,%eax
f0101bb9:	75 02                	jne    f0101bbd <page_remove+0x3f>
		return;
f0101bbb:	eb 28                	jmp    f0101be5 <page_remove+0x67>
	page_decref(page);
f0101bbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101bc0:	89 04 24             	mov    %eax,(%esp)
f0101bc3:	e8 c7 fc ff ff       	call   f010188f <page_decref>
	**store = 0;
f0101bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101bcb:	8b 00                	mov    (%eax),%eax
f0101bcd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f0101bd3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101bd6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101bda:	8b 45 08             	mov    0x8(%ebp),%eax
f0101bdd:	89 04 24             	mov    %eax,(%esp)
f0101be0:	e8 02 00 00 00       	call   f0101be7 <tlb_invalidate>
}
f0101be5:	c9                   	leave  
f0101be6:	c3                   	ret    

f0101be7 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101be7:	55                   	push   %ebp
f0101be8:	89 e5                	mov    %esp,%ebp
f0101bea:	83 ec 18             	sub    $0x18,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101bed:	e8 d4 69 00 00       	call   f01085c6 <cpunum>
f0101bf2:	6b c0 74             	imul   $0x74,%eax,%eax
f0101bf5:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0101bfa:	8b 00                	mov    (%eax),%eax
f0101bfc:	85 c0                	test   %eax,%eax
f0101bfe:	74 17                	je     f0101c17 <tlb_invalidate+0x30>
f0101c00:	e8 c1 69 00 00       	call   f01085c6 <cpunum>
f0101c05:	6b c0 74             	imul   $0x74,%eax,%eax
f0101c08:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0101c0d:	8b 00                	mov    (%eax),%eax
f0101c0f:	8b 40 60             	mov    0x60(%eax),%eax
f0101c12:	3b 45 08             	cmp    0x8(%ebp),%eax
f0101c15:	75 0c                	jne    f0101c23 <tlb_invalidate+0x3c>
f0101c17:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101c1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101c20:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101c23:	c9                   	leave  
f0101c24:	c3                   	ret    

f0101c25 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101c25:	55                   	push   %ebp
f0101c26:	89 e5                	mov    %esp,%ebp
f0101c28:	83 ec 38             	sub    $0x38,%esp
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	
	size_t size1 = ROUNDUP(size,PGSIZE);
f0101c2b:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
f0101c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101c35:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101c38:	01 d0                	add    %edx,%eax
f0101c3a:	83 e8 01             	sub    $0x1,%eax
f0101c3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101c40:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101c43:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c48:	f7 75 f4             	divl   -0xc(%ebp)
f0101c4b:	89 d0                	mov    %edx,%eax
f0101c4d:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101c50:	29 c2                	sub    %eax,%edx
f0101c52:	89 d0                	mov    %edx,%eax
f0101c54:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	if(base + size1 > MMIOLIM)
f0101c57:	8b 15 44 55 12 f0    	mov    0xf0125544,%edx
f0101c5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101c60:	01 d0                	add    %edx,%eax
f0101c62:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f0101c67:	76 1c                	jbe    f0101c85 <mmio_map_region+0x60>
		panic("overflow in MMIO\n");
f0101c69:	c7 44 24 08 25 91 10 	movl   $0xf0109125,0x8(%esp)
f0101c70:	f0 
f0101c71:	c7 44 24 04 96 02 00 	movl   $0x296,0x4(%esp)
f0101c78:	00 
f0101c79:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0101c80:	e8 72 e6 ff ff       	call   f01002f7 <_panic>
	boot_map_region(kern_pgdir,base,size1,pa,(PTE_PCD|PTE_PWT|PTE_W|PTE_P));
f0101c85:	8b 15 44 55 12 f0    	mov    0xf0125544,%edx
f0101c8b:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0101c90:	c7 44 24 10 1b 00 00 	movl   $0x1b,0x10(%esp)
f0101c97:	00 
f0101c98:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101c9b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101c9f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0101ca2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101ca6:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101caa:	89 04 24             	mov    %eax,(%esp)
f0101cad:	e8 2d fd ff ff       	call   f01019df <boot_map_region>
	uintptr_t base1 = base;
f0101cb2:	a1 44 55 12 f0       	mov    0xf0125544,%eax
f0101cb7:	89 45 e8             	mov    %eax,-0x18(%ebp)
	base = base + size1;
f0101cba:	8b 15 44 55 12 f0    	mov    0xf0125544,%edx
f0101cc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101cc3:	01 d0                	add    %edx,%eax
f0101cc5:	a3 44 55 12 f0       	mov    %eax,0xf0125544
	return (void *) base1;
f0101cca:	8b 45 e8             	mov    -0x18(%ebp),%eax
	// panic("mmio_map_region not implemented");
}
f0101ccd:	c9                   	leave  
f0101cce:	c3                   	ret    

f0101ccf <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0101ccf:	55                   	push   %ebp
f0101cd0:	89 e5                	mov    %esp,%ebp
f0101cd2:	83 ec 38             	sub    $0x38,%esp
	// LAB 3: Your code here.
	perm = perm | PTE_P;
f0101cd5:	83 4d 14 01          	orl    $0x1,0x14(%ebp)
	uintptr_t start = ROUNDDOWN((uintptr_t)va, PGSIZE);
f0101cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101cdc:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101cdf:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101ce2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101ce7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uintptr_t end = start + len;
f0101cea:	8b 45 10             	mov    0x10(%ebp),%eax
f0101ced:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101cf0:	01 d0                	add    %edx,%eax
f0101cf2:	89 45 e8             	mov    %eax,-0x18(%ebp)
	while(start < end)
f0101cf5:	e9 8a 00 00 00       	jmp    f0101d84 <user_mem_check+0xb5>
	{
		uintptr_t t;
		if(start < (uintptr_t)va)
f0101cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101cfd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0101d00:	76 08                	jbe    f0101d0a <user_mem_check+0x3b>
		{
			t = (uintptr_t)va;
f0101d02:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101d05:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101d08:	eb 06                	jmp    f0101d10 <user_mem_check+0x41>
		}
		else
		{
			t = start;
f0101d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101d0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
		}
		pte_t *pg = pgdir_walk(env->env_pgdir, (void *)start, 0);
f0101d10:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101d13:	8b 45 08             	mov    0x8(%ebp),%eax
f0101d16:	8b 40 60             	mov    0x60(%eax),%eax
f0101d19:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d20:	00 
f0101d21:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101d25:	89 04 24             	mov    %eax,(%esp)
f0101d28:	e8 92 fb ff ff       	call   f01018bf <pgdir_walk>
f0101d2d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if(pg == NULL)
f0101d30:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101d34:	75 0f                	jne    f0101d45 <user_mem_check+0x76>
		{
			user_mem_check_addr = t;
f0101d36:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101d39:	a3 34 b2 23 f0       	mov    %eax,0xf023b234
			return -E_FAULT;
f0101d3e:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0101d43:	eb 50                	jmp    f0101d95 <user_mem_check+0xc6>
		}
		if((uintptr_t)start > ULIM)
f0101d45:	81 7d f4 00 00 80 ef 	cmpl   $0xef800000,-0xc(%ebp)
f0101d4c:	76 0f                	jbe    f0101d5d <user_mem_check+0x8e>
		{
			user_mem_check_addr = t;
f0101d4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101d51:	a3 34 b2 23 f0       	mov    %eax,0xf023b234
			return -E_FAULT;
f0101d56:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0101d5b:	eb 38                	jmp    f0101d95 <user_mem_check+0xc6>
		}
		if((*pg & perm) != perm)
f0101d5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101d60:	8b 10                	mov    (%eax),%edx
f0101d62:	8b 45 14             	mov    0x14(%ebp),%eax
f0101d65:	21 c2                	and    %eax,%edx
f0101d67:	8b 45 14             	mov    0x14(%ebp),%eax
f0101d6a:	39 c2                	cmp    %eax,%edx
f0101d6c:	74 0f                	je     f0101d7d <user_mem_check+0xae>
		{
			user_mem_check_addr = t;
f0101d6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101d71:	a3 34 b2 23 f0       	mov    %eax,0xf023b234
			return -E_FAULT;
f0101d76:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0101d7b:	eb 18                	jmp    f0101d95 <user_mem_check+0xc6>
		}
		start += PGSIZE;	
f0101d7d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
{
	// LAB 3: Your code here.
	perm = perm | PTE_P;
	uintptr_t start = ROUNDDOWN((uintptr_t)va, PGSIZE);
	uintptr_t end = start + len;
	while(start < end)
f0101d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101d87:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0101d8a:	0f 82 6a ff ff ff    	jb     f0101cfa <user_mem_check+0x2b>
			return -E_FAULT;
		}
		start += PGSIZE;	

	}
	return 0;
f0101d90:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101d95:	c9                   	leave  
f0101d96:	c3                   	ret    

f0101d97 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0101d97:	55                   	push   %ebp
f0101d98:	89 e5                	mov    %esp,%ebp
f0101d9a:	83 ec 18             	sub    $0x18,%esp
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0101d9d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101da0:	83 c8 04             	or     $0x4,%eax
f0101da3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101da7:	8b 45 10             	mov    0x10(%ebp),%eax
f0101daa:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101dae:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101db1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101db5:	8b 45 08             	mov    0x8(%ebp),%eax
f0101db8:	89 04 24             	mov    %eax,(%esp)
f0101dbb:	e8 0f ff ff ff       	call   f0101ccf <user_mem_check>
f0101dc0:	85 c0                	test   %eax,%eax
f0101dc2:	79 2b                	jns    f0101def <user_mem_assert+0x58>
		cprintf("[%08x] user_mem_check assertion failure for "
f0101dc4:	8b 15 34 b2 23 f0    	mov    0xf023b234,%edx
f0101dca:	8b 45 08             	mov    0x8(%ebp),%eax
f0101dcd:	8b 40 48             	mov    0x48(%eax),%eax
f0101dd0:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101dd4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101dd8:	c7 04 24 38 91 10 f0 	movl   $0xf0109138,(%esp)
f0101ddf:	e8 db 31 00 00       	call   f0104fbf <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0101de4:	8b 45 08             	mov    0x8(%ebp),%eax
f0101de7:	89 04 24             	mov    %eax,(%esp)
f0101dea:	e8 9b 2d 00 00       	call   f0104b8a <env_destroy>
	}
}
f0101def:	c9                   	leave  
f0101df0:	c3                   	ret    

f0101df1 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0101df1:	55                   	push   %ebp
f0101df2:	89 e5                	mov    %esp,%ebp
f0101df4:	83 ec 58             	sub    $0x58,%esp
f0101df7:	8b 45 08             	mov    0x8(%ebp),%eax
f0101dfa:	88 45 c4             	mov    %al,-0x3c(%ebp)
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101dfd:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0101e01:	74 07                	je     f0101e0a <check_page_free_list+0x19>
f0101e03:	b8 01 00 00 00       	mov    $0x1,%eax
f0101e08:	eb 05                	jmp    f0101e0f <check_page_free_list+0x1e>
f0101e0a:	b8 00 04 00 00       	mov    $0x400,%eax
f0101e0f:	89 45 e8             	mov    %eax,-0x18(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0101e12:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0101e19:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	char *first_free_page;

	if (!page_free_list)
f0101e20:	a1 30 b2 23 f0       	mov    0xf023b230,%eax
f0101e25:	85 c0                	test   %eax,%eax
f0101e27:	75 1c                	jne    f0101e45 <check_page_free_list+0x54>
		panic("'page_free_list' is a null pointer!");
f0101e29:	c7 44 24 08 70 91 10 	movl   $0xf0109170,0x8(%esp)
f0101e30:	f0 
f0101e31:	c7 44 24 04 fc 02 00 	movl   $0x2fc,0x4(%esp)
f0101e38:	00 
f0101e39:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0101e40:	e8 b2 e4 ff ff       	call   f01002f7 <_panic>

	if (only_low_memory) {
f0101e45:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0101e49:	74 6d                	je     f0101eb8 <check_page_free_list+0xc7>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101e4b:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0101e4e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101e51:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0101e54:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101e57:	a1 30 b2 23 f0       	mov    0xf023b230,%eax
f0101e5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101e5f:	eb 38                	jmp    f0101e99 <check_page_free_list+0xa8>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101e64:	89 04 24             	mov    %eax,(%esp)
f0101e67:	e8 c2 f2 ff ff       	call   f010112e <page2pa>
f0101e6c:	c1 e8 16             	shr    $0x16,%eax
f0101e6f:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0101e72:	0f 93 c0             	setae  %al
f0101e75:	0f b6 c0             	movzbl %al,%eax
f0101e78:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			*tp[pagetype] = pp;
f0101e7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101e7e:	8b 44 85 d0          	mov    -0x30(%ebp,%eax,4),%eax
f0101e82:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101e85:	89 10                	mov    %edx,(%eax)
			tp[pagetype] = &pp->pp_link;
f0101e87:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101e8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101e8d:	89 54 85 d0          	mov    %edx,-0x30(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101e94:	8b 00                	mov    (%eax),%eax
f0101e96:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101e99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0101e9d:	75 c2                	jne    f0101e61 <check_page_free_list+0x70>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0101e9f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ea2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101ea8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101eab:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101eae:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101eb0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101eb3:	a3 30 b2 23 f0       	mov    %eax,0xf023b230
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101eb8:	a1 30 b2 23 f0       	mov    0xf023b230,%eax
f0101ebd:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101ec0:	eb 3e                	jmp    f0101f00 <check_page_free_list+0x10f>
		if (PDX(page2pa(pp)) < pdx_limit)
f0101ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101ec5:	89 04 24             	mov    %eax,(%esp)
f0101ec8:	e8 61 f2 ff ff       	call   f010112e <page2pa>
f0101ecd:	c1 e8 16             	shr    $0x16,%eax
f0101ed0:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0101ed3:	73 23                	jae    f0101ef8 <check_page_free_list+0x107>
			memset(page2kva(pp), 0x97, 128);
f0101ed5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101ed8:	89 04 24             	mov    %eax,(%esp)
f0101edb:	e8 aa f2 ff ff       	call   f010118a <page2kva>
f0101ee0:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0101ee7:	00 
f0101ee8:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101eef:	00 
f0101ef0:	89 04 24             	mov    %eax,(%esp)
f0101ef3:	e8 04 5c 00 00       	call   f0107afc <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101efb:	8b 00                	mov    (%eax),%eax
f0101efd:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101f00:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0101f04:	75 bc                	jne    f0101ec2 <check_page_free_list+0xd1>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0101f06:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f0d:	e8 74 f3 ff ff       	call   f0101286 <boot_alloc>
f0101f12:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101f15:	a1 30 b2 23 f0       	mov    0xf023b230,%eax
f0101f1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101f1d:	e9 13 02 00 00       	jmp    f0102135 <check_page_free_list+0x344>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101f22:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f0101f27:	39 45 f4             	cmp    %eax,-0xc(%ebp)
f0101f2a:	73 24                	jae    f0101f50 <check_page_free_list+0x15f>
f0101f2c:	c7 44 24 0c 94 91 10 	movl   $0xf0109194,0xc(%esp)
f0101f33:	f0 
f0101f34:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0101f3b:	f0 
f0101f3c:	c7 44 24 04 16 03 00 	movl   $0x316,0x4(%esp)
f0101f43:	00 
f0101f44:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0101f4b:	e8 a7 e3 ff ff       	call   f01002f7 <_panic>
		assert(pp < pages + npages);
f0101f50:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f0101f55:	8b 15 e8 be 23 f0    	mov    0xf023bee8,%edx
f0101f5b:	c1 e2 03             	shl    $0x3,%edx
f0101f5e:	01 d0                	add    %edx,%eax
f0101f60:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0101f63:	77 24                	ja     f0101f89 <check_page_free_list+0x198>
f0101f65:	c7 44 24 0c b5 91 10 	movl   $0xf01091b5,0xc(%esp)
f0101f6c:	f0 
f0101f6d:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0101f74:	f0 
f0101f75:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f0101f7c:	00 
f0101f7d:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0101f84:	e8 6e e3 ff ff       	call   f01002f7 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101f89:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101f8c:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f0101f91:	29 c2                	sub    %eax,%edx
f0101f93:	89 d0                	mov    %edx,%eax
f0101f95:	83 e0 07             	and    $0x7,%eax
f0101f98:	85 c0                	test   %eax,%eax
f0101f9a:	74 24                	je     f0101fc0 <check_page_free_list+0x1cf>
f0101f9c:	c7 44 24 0c cc 91 10 	movl   $0xf01091cc,0xc(%esp)
f0101fa3:	f0 
f0101fa4:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0101fab:	f0 
f0101fac:	c7 44 24 04 18 03 00 	movl   $0x318,0x4(%esp)
f0101fb3:	00 
f0101fb4:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0101fbb:	e8 37 e3 ff ff       	call   f01002f7 <_panic>

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101fc3:	89 04 24             	mov    %eax,(%esp)
f0101fc6:	e8 63 f1 ff ff       	call   f010112e <page2pa>
f0101fcb:	85 c0                	test   %eax,%eax
f0101fcd:	75 24                	jne    f0101ff3 <check_page_free_list+0x202>
f0101fcf:	c7 44 24 0c fe 91 10 	movl   $0xf01091fe,0xc(%esp)
f0101fd6:	f0 
f0101fd7:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0101fde:	f0 
f0101fdf:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f0101fe6:	00 
f0101fe7:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0101fee:	e8 04 e3 ff ff       	call   f01002f7 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101ff6:	89 04 24             	mov    %eax,(%esp)
f0101ff9:	e8 30 f1 ff ff       	call   f010112e <page2pa>
f0101ffe:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0102003:	75 24                	jne    f0102029 <check_page_free_list+0x238>
f0102005:	c7 44 24 0c 0f 92 10 	movl   $0xf010920f,0xc(%esp)
f010200c:	f0 
f010200d:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102014:	f0 
f0102015:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f010201c:	00 
f010201d:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102024:	e8 ce e2 ff ff       	call   f01002f7 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0102029:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010202c:	89 04 24             	mov    %eax,(%esp)
f010202f:	e8 fa f0 ff ff       	call   f010112e <page2pa>
f0102034:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0102039:	75 24                	jne    f010205f <check_page_free_list+0x26e>
f010203b:	c7 44 24 0c 28 92 10 	movl   $0xf0109228,0xc(%esp)
f0102042:	f0 
f0102043:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f010204a:	f0 
f010204b:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f0102052:	00 
f0102053:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010205a:	e8 98 e2 ff ff       	call   f01002f7 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f010205f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102062:	89 04 24             	mov    %eax,(%esp)
f0102065:	e8 c4 f0 ff ff       	call   f010112e <page2pa>
f010206a:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010206f:	75 24                	jne    f0102095 <check_page_free_list+0x2a4>
f0102071:	c7 44 24 0c 4b 92 10 	movl   $0xf010924b,0xc(%esp)
f0102078:	f0 
f0102079:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102080:	f0 
f0102081:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f0102088:	00 
f0102089:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102090:	e8 62 e2 ff ff       	call   f01002f7 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0102095:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102098:	89 04 24             	mov    %eax,(%esp)
f010209b:	e8 8e f0 ff ff       	call   f010112e <page2pa>
f01020a0:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f01020a5:	76 34                	jbe    f01020db <check_page_free_list+0x2ea>
f01020a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01020aa:	89 04 24             	mov    %eax,(%esp)
f01020ad:	e8 d8 f0 ff ff       	call   f010118a <page2kva>
f01020b2:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01020b5:	73 24                	jae    f01020db <check_page_free_list+0x2ea>
f01020b7:	c7 44 24 0c 68 92 10 	movl   $0xf0109268,0xc(%esp)
f01020be:	f0 
f01020bf:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01020c6:	f0 
f01020c7:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f01020ce:	00 
f01020cf:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01020d6:	e8 1c e2 ff ff       	call   f01002f7 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01020db:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01020de:	89 04 24             	mov    %eax,(%esp)
f01020e1:	e8 48 f0 ff ff       	call   f010112e <page2pa>
f01020e6:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01020eb:	75 24                	jne    f0102111 <check_page_free_list+0x320>
f01020ed:	c7 44 24 0c ad 92 10 	movl   $0xf01092ad,0xc(%esp)
f01020f4:	f0 
f01020f5:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01020fc:	f0 
f01020fd:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f0102104:	00 
f0102105:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010210c:	e8 e6 e1 ff ff       	call   f01002f7 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f0102111:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102114:	89 04 24             	mov    %eax,(%esp)
f0102117:	e8 12 f0 ff ff       	call   f010112e <page2pa>
f010211c:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0102121:	77 06                	ja     f0102129 <check_page_free_list+0x338>
			++nfree_basemem;
f0102123:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f0102127:	eb 04                	jmp    f010212d <check_page_free_list+0x33c>
		else
			++nfree_extmem;
f0102129:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010212d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102130:	8b 00                	mov    (%eax),%eax
f0102132:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0102135:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0102139:	0f 85 e3 fd ff ff    	jne    f0101f22 <check_page_free_list+0x131>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f010213f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0102143:	7f 24                	jg     f0102169 <check_page_free_list+0x378>
f0102145:	c7 44 24 0c ca 92 10 	movl   $0xf01092ca,0xc(%esp)
f010214c:	f0 
f010214d:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102154:	f0 
f0102155:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f010215c:	00 
f010215d:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102164:	e8 8e e1 ff ff       	call   f01002f7 <_panic>
	assert(nfree_extmem > 0);
f0102169:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f010216d:	7f 24                	jg     f0102193 <check_page_free_list+0x3a2>
f010216f:	c7 44 24 0c dc 92 10 	movl   $0xf01092dc,0xc(%esp)
f0102176:	f0 
f0102177:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f010217e:	f0 
f010217f:	c7 44 24 04 2a 03 00 	movl   $0x32a,0x4(%esp)
f0102186:	00 
f0102187:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010218e:	e8 64 e1 ff ff       	call   f01002f7 <_panic>
}
f0102193:	c9                   	leave  
f0102194:	c3                   	ret    

f0102195 <check_page_alloc>:
// Check the physical page allocator (page_alloc(), page_free(),
// and page_init()).
//
static void
check_page_alloc(void)
{
f0102195:	55                   	push   %ebp
f0102196:	89 e5                	mov    %esp,%ebp
f0102198:	83 ec 38             	sub    $0x38,%esp
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010219b:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f01021a0:	85 c0                	test   %eax,%eax
f01021a2:	75 1c                	jne    f01021c0 <check_page_alloc+0x2b>
		panic("'pages' is a null pointer!");
f01021a4:	c7 44 24 08 ed 92 10 	movl   $0xf01092ed,0x8(%esp)
f01021ab:	f0 
f01021ac:	c7 44 24 04 3b 03 00 	movl   $0x33b,0x4(%esp)
f01021b3:	00 
f01021b4:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01021bb:	e8 37 e1 ff ff       	call   f01002f7 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01021c0:	a1 30 b2 23 f0       	mov    0xf023b230,%eax
f01021c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01021c8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01021cf:	eb 0c                	jmp    f01021dd <check_page_alloc+0x48>
		++nfree;
f01021d1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01021d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01021d8:	8b 00                	mov    (%eax),%eax
f01021da:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01021dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f01021e1:	75 ee                	jne    f01021d1 <check_page_alloc+0x3c>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f01021e3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f01021ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01021ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01021f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01021f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
	assert((pp0 = page_alloc(0)));
f01021f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01021fd:	e8 c0 f5 ff ff       	call   f01017c2 <page_alloc>
f0102202:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102205:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102209:	75 24                	jne    f010222f <check_page_alloc+0x9a>
f010220b:	c7 44 24 0c 08 93 10 	movl   $0xf0109308,0xc(%esp)
f0102212:	f0 
f0102213:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f010221a:	f0 
f010221b:	c7 44 24 04 43 03 00 	movl   $0x343,0x4(%esp)
f0102222:	00 
f0102223:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010222a:	e8 c8 e0 ff ff       	call   f01002f7 <_panic>
	assert((pp1 = page_alloc(0)));
f010222f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102236:	e8 87 f5 ff ff       	call   f01017c2 <page_alloc>
f010223b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010223e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0102242:	75 24                	jne    f0102268 <check_page_alloc+0xd3>
f0102244:	c7 44 24 0c 1e 93 10 	movl   $0xf010931e,0xc(%esp)
f010224b:	f0 
f010224c:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102253:	f0 
f0102254:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
f010225b:	00 
f010225c:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102263:	e8 8f e0 ff ff       	call   f01002f7 <_panic>
	assert((pp2 = page_alloc(0)));
f0102268:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010226f:	e8 4e f5 ff ff       	call   f01017c2 <page_alloc>
f0102274:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0102277:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010227b:	75 24                	jne    f01022a1 <check_page_alloc+0x10c>
f010227d:	c7 44 24 0c 34 93 10 	movl   $0xf0109334,0xc(%esp)
f0102284:	f0 
f0102285:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f010228c:	f0 
f010228d:	c7 44 24 04 45 03 00 	movl   $0x345,0x4(%esp)
f0102294:	00 
f0102295:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010229c:	e8 56 e0 ff ff       	call   f01002f7 <_panic>

	assert(pp0);
f01022a1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01022a5:	75 24                	jne    f01022cb <check_page_alloc+0x136>
f01022a7:	c7 44 24 0c 4a 93 10 	movl   $0xf010934a,0xc(%esp)
f01022ae:	f0 
f01022af:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01022b6:	f0 
f01022b7:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f01022be:	00 
f01022bf:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01022c6:	e8 2c e0 ff ff       	call   f01002f7 <_panic>
	assert(pp1 && pp1 != pp0);
f01022cb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01022cf:	74 08                	je     f01022d9 <check_page_alloc+0x144>
f01022d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01022d4:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01022d7:	75 24                	jne    f01022fd <check_page_alloc+0x168>
f01022d9:	c7 44 24 0c 4e 93 10 	movl   $0xf010934e,0xc(%esp)
f01022e0:	f0 
f01022e1:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01022e8:	f0 
f01022e9:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f01022f0:	00 
f01022f1:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01022f8:	e8 fa df ff ff       	call   f01002f7 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01022fd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102301:	74 10                	je     f0102313 <check_page_alloc+0x17e>
f0102303:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102306:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
f0102309:	74 08                	je     f0102313 <check_page_alloc+0x17e>
f010230b:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010230e:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0102311:	75 24                	jne    f0102337 <check_page_alloc+0x1a2>
f0102313:	c7 44 24 0c 60 93 10 	movl   $0xf0109360,0xc(%esp)
f010231a:	f0 
f010231b:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102322:	f0 
f0102323:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f010232a:	00 
f010232b:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102332:	e8 c0 df ff ff       	call   f01002f7 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0102337:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010233a:	89 04 24             	mov    %eax,(%esp)
f010233d:	e8 ec ed ff ff       	call   f010112e <page2pa>
f0102342:	8b 15 e8 be 23 f0    	mov    0xf023bee8,%edx
f0102348:	c1 e2 0c             	shl    $0xc,%edx
f010234b:	39 d0                	cmp    %edx,%eax
f010234d:	72 24                	jb     f0102373 <check_page_alloc+0x1de>
f010234f:	c7 44 24 0c 80 93 10 	movl   $0xf0109380,0xc(%esp)
f0102356:	f0 
f0102357:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f010235e:	f0 
f010235f:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
f0102366:	00 
f0102367:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010236e:	e8 84 df ff ff       	call   f01002f7 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0102373:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102376:	89 04 24             	mov    %eax,(%esp)
f0102379:	e8 b0 ed ff ff       	call   f010112e <page2pa>
f010237e:	8b 15 e8 be 23 f0    	mov    0xf023bee8,%edx
f0102384:	c1 e2 0c             	shl    $0xc,%edx
f0102387:	39 d0                	cmp    %edx,%eax
f0102389:	72 24                	jb     f01023af <check_page_alloc+0x21a>
f010238b:	c7 44 24 0c 9d 93 10 	movl   $0xf010939d,0xc(%esp)
f0102392:	f0 
f0102393:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f010239a:	f0 
f010239b:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f01023a2:	00 
f01023a3:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01023aa:	e8 48 df ff ff       	call   f01002f7 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01023af:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01023b2:	89 04 24             	mov    %eax,(%esp)
f01023b5:	e8 74 ed ff ff       	call   f010112e <page2pa>
f01023ba:	8b 15 e8 be 23 f0    	mov    0xf023bee8,%edx
f01023c0:	c1 e2 0c             	shl    $0xc,%edx
f01023c3:	39 d0                	cmp    %edx,%eax
f01023c5:	72 24                	jb     f01023eb <check_page_alloc+0x256>
f01023c7:	c7 44 24 0c ba 93 10 	movl   $0xf01093ba,0xc(%esp)
f01023ce:	f0 
f01023cf:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01023d6:	f0 
f01023d7:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f01023de:	00 
f01023df:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01023e6:	e8 0c df ff ff       	call   f01002f7 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01023eb:	a1 30 b2 23 f0       	mov    0xf023b230,%eax
f01023f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
	page_free_list = 0;
f01023f3:	c7 05 30 b2 23 f0 00 	movl   $0x0,0xf023b230
f01023fa:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01023fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102404:	e8 b9 f3 ff ff       	call   f01017c2 <page_alloc>
f0102409:	85 c0                	test   %eax,%eax
f010240b:	74 24                	je     f0102431 <check_page_alloc+0x29c>
f010240d:	c7 44 24 0c d7 93 10 	movl   $0xf01093d7,0xc(%esp)
f0102414:	f0 
f0102415:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f010241c:	f0 
f010241d:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0102424:	00 
f0102425:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010242c:	e8 c6 de ff ff       	call   f01002f7 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0102431:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102434:	89 04 24             	mov    %eax,(%esp)
f0102437:	e8 eb f3 ff ff       	call   f0101827 <page_free>
	page_free(pp1);
f010243c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010243f:	89 04 24             	mov    %eax,(%esp)
f0102442:	e8 e0 f3 ff ff       	call   f0101827 <page_free>
	page_free(pp2);
f0102447:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010244a:	89 04 24             	mov    %eax,(%esp)
f010244d:	e8 d5 f3 ff ff       	call   f0101827 <page_free>
	pp0 = pp1 = pp2 = 0;
f0102452:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f0102459:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010245c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010245f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102462:	89 45 e0             	mov    %eax,-0x20(%ebp)
	assert((pp0 = page_alloc(0)));
f0102465:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010246c:	e8 51 f3 ff ff       	call   f01017c2 <page_alloc>
f0102471:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102474:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102478:	75 24                	jne    f010249e <check_page_alloc+0x309>
f010247a:	c7 44 24 0c 08 93 10 	movl   $0xf0109308,0xc(%esp)
f0102481:	f0 
f0102482:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102489:	f0 
f010248a:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f0102491:	00 
f0102492:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102499:	e8 59 de ff ff       	call   f01002f7 <_panic>
	assert((pp1 = page_alloc(0)));
f010249e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01024a5:	e8 18 f3 ff ff       	call   f01017c2 <page_alloc>
f01024aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01024ad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01024b1:	75 24                	jne    f01024d7 <check_page_alloc+0x342>
f01024b3:	c7 44 24 0c 1e 93 10 	movl   $0xf010931e,0xc(%esp)
f01024ba:	f0 
f01024bb:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01024c2:	f0 
f01024c3:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f01024ca:	00 
f01024cb:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01024d2:	e8 20 de ff ff       	call   f01002f7 <_panic>
	assert((pp2 = page_alloc(0)));
f01024d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01024de:	e8 df f2 ff ff       	call   f01017c2 <page_alloc>
f01024e3:	89 45 e8             	mov    %eax,-0x18(%ebp)
f01024e6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01024ea:	75 24                	jne    f0102510 <check_page_alloc+0x37b>
f01024ec:	c7 44 24 0c 34 93 10 	movl   $0xf0109334,0xc(%esp)
f01024f3:	f0 
f01024f4:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01024fb:	f0 
f01024fc:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f0102503:	00 
f0102504:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010250b:	e8 e7 dd ff ff       	call   f01002f7 <_panic>
	assert(pp0);
f0102510:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102514:	75 24                	jne    f010253a <check_page_alloc+0x3a5>
f0102516:	c7 44 24 0c 4a 93 10 	movl   $0xf010934a,0xc(%esp)
f010251d:	f0 
f010251e:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102525:	f0 
f0102526:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f010252d:	00 
f010252e:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102535:	e8 bd dd ff ff       	call   f01002f7 <_panic>
	assert(pp1 && pp1 != pp0);
f010253a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010253e:	74 08                	je     f0102548 <check_page_alloc+0x3b3>
f0102540:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102543:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0102546:	75 24                	jne    f010256c <check_page_alloc+0x3d7>
f0102548:	c7 44 24 0c 4e 93 10 	movl   $0xf010934e,0xc(%esp)
f010254f:	f0 
f0102550:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102557:	f0 
f0102558:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f010255f:	00 
f0102560:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102567:	e8 8b dd ff ff       	call   f01002f7 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010256c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102570:	74 10                	je     f0102582 <check_page_alloc+0x3ed>
f0102572:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102575:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
f0102578:	74 08                	je     f0102582 <check_page_alloc+0x3ed>
f010257a:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010257d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0102580:	75 24                	jne    f01025a6 <check_page_alloc+0x411>
f0102582:	c7 44 24 0c 60 93 10 	movl   $0xf0109360,0xc(%esp)
f0102589:	f0 
f010258a:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102591:	f0 
f0102592:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f0102599:	00 
f010259a:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01025a1:	e8 51 dd ff ff       	call   f01002f7 <_panic>
	assert(!page_alloc(0));
f01025a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01025ad:	e8 10 f2 ff ff       	call   f01017c2 <page_alloc>
f01025b2:	85 c0                	test   %eax,%eax
f01025b4:	74 24                	je     f01025da <check_page_alloc+0x445>
f01025b6:	c7 44 24 0c d7 93 10 	movl   $0xf01093d7,0xc(%esp)
f01025bd:	f0 
f01025be:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01025c5:	f0 
f01025c6:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f01025cd:	00 
f01025ce:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01025d5:	e8 1d dd ff ff       	call   f01002f7 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01025da:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01025dd:	89 04 24             	mov    %eax,(%esp)
f01025e0:	e8 a5 eb ff ff       	call   f010118a <page2kva>
f01025e5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01025ec:	00 
f01025ed:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01025f4:	00 
f01025f5:	89 04 24             	mov    %eax,(%esp)
f01025f8:	e8 ff 54 00 00       	call   f0107afc <memset>
	page_free(pp0);
f01025fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102600:	89 04 24             	mov    %eax,(%esp)
f0102603:	e8 1f f2 ff ff       	call   f0101827 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0102608:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010260f:	e8 ae f1 ff ff       	call   f01017c2 <page_alloc>
f0102614:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0102617:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010261b:	75 24                	jne    f0102641 <check_page_alloc+0x4ac>
f010261d:	c7 44 24 0c e6 93 10 	movl   $0xf01093e6,0xc(%esp)
f0102624:	f0 
f0102625:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f010262c:	f0 
f010262d:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0102634:	00 
f0102635:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010263c:	e8 b6 dc ff ff       	call   f01002f7 <_panic>
	assert(pp && pp0 == pp);
f0102641:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0102645:	74 08                	je     f010264f <check_page_alloc+0x4ba>
f0102647:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010264a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f010264d:	74 24                	je     f0102673 <check_page_alloc+0x4de>
f010264f:	c7 44 24 0c 04 94 10 	movl   $0xf0109404,0xc(%esp)
f0102656:	f0 
f0102657:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f010265e:	f0 
f010265f:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0102666:	00 
f0102667:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010266e:	e8 84 dc ff ff       	call   f01002f7 <_panic>
	c = page2kva(pp);
f0102673:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102676:	89 04 24             	mov    %eax,(%esp)
f0102679:	e8 0c eb ff ff       	call   f010118a <page2kva>
f010267e:	89 45 d8             	mov    %eax,-0x28(%ebp)
	for (i = 0; i < PGSIZE; i++)
f0102681:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f0102688:	eb 37                	jmp    f01026c1 <check_page_alloc+0x52c>
		assert(c[i] == 0);
f010268a:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010268d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102690:	01 d0                	add    %edx,%eax
f0102692:	0f b6 00             	movzbl (%eax),%eax
f0102695:	84 c0                	test   %al,%al
f0102697:	74 24                	je     f01026bd <check_page_alloc+0x528>
f0102699:	c7 44 24 0c 14 94 10 	movl   $0xf0109414,0xc(%esp)
f01026a0:	f0 
f01026a1:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01026a8:	f0 
f01026a9:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f01026b0:	00 
f01026b1:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01026b8:	e8 3a dc ff ff       	call   f01002f7 <_panic>
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01026bd:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
f01026c1:	81 7d ec ff 0f 00 00 	cmpl   $0xfff,-0x14(%ebp)
f01026c8:	7e c0                	jle    f010268a <check_page_alloc+0x4f5>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01026ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01026cd:	a3 30 b2 23 f0       	mov    %eax,0xf023b230

	// free the pages we took
	page_free(pp0);
f01026d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01026d5:	89 04 24             	mov    %eax,(%esp)
f01026d8:	e8 4a f1 ff ff       	call   f0101827 <page_free>
	page_free(pp1);
f01026dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01026e0:	89 04 24             	mov    %eax,(%esp)
f01026e3:	e8 3f f1 ff ff       	call   f0101827 <page_free>
	page_free(pp2);
f01026e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01026eb:	89 04 24             	mov    %eax,(%esp)
f01026ee:	e8 34 f1 ff ff       	call   f0101827 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01026f3:	a1 30 b2 23 f0       	mov    0xf023b230,%eax
f01026f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01026fb:	eb 0c                	jmp    f0102709 <check_page_alloc+0x574>
		--nfree;
f01026fd:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102701:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102704:	8b 00                	mov    (%eax),%eax
f0102706:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0102709:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010270d:	75 ee                	jne    f01026fd <check_page_alloc+0x568>
		--nfree;
	assert(nfree == 0);
f010270f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0102713:	74 24                	je     f0102739 <check_page_alloc+0x5a4>
f0102715:	c7 44 24 0c 1e 94 10 	movl   $0xf010941e,0xc(%esp)
f010271c:	f0 
f010271d:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102724:	f0 
f0102725:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
f010272c:	00 
f010272d:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102734:	e8 be db ff ff       	call   f01002f7 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0102739:	c7 04 24 2c 94 10 f0 	movl   $0xf010942c,(%esp)
f0102740:	e8 7a 28 00 00       	call   f0104fbf <cprintf>
}
f0102745:	c9                   	leave  
f0102746:	c3                   	ret    

f0102747 <check_kern_pgdir>:
// but it is a pretty good sanity check.
//

static void
check_kern_pgdir(void)
{
f0102747:	55                   	push   %ebp
f0102748:	89 e5                	mov    %esp,%ebp
f010274a:	53                   	push   %ebx
f010274b:	83 ec 34             	sub    $0x34,%esp
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010274e:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0102753:	89 45 ec             	mov    %eax,-0x14(%ebp)

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102756:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
f010275d:	a1 e8 be 23 f0       	mov    0xf023bee8,%eax
f0102762:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0102769:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010276c:	01 d0                	add    %edx,%eax
f010276e:	83 e8 01             	sub    $0x1,%eax
f0102771:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102774:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102777:	ba 00 00 00 00       	mov    $0x0,%edx
f010277c:	f7 75 e8             	divl   -0x18(%ebp)
f010277f:	89 d0                	mov    %edx,%eax
f0102781:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102784:	29 c2                	sub    %eax,%edx
f0102786:	89 d0                	mov    %edx,%eax
f0102788:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f010278b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0102792:	eb 6a                	jmp    f01027fe <check_kern_pgdir+0xb7>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102794:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102797:	2d 00 00 00 11       	sub    $0x11000000,%eax
f010279c:	89 44 24 04          	mov    %eax,0x4(%esp)
f01027a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01027a3:	89 04 24             	mov    %eax,(%esp)
f01027a6:	e8 a3 03 00 00       	call   f0102b4e <check_va2pa>
f01027ab:	89 c3                	mov    %eax,%ebx
f01027ad:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f01027b2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01027b6:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f01027bd:	00 
f01027be:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01027c5:	e8 e7 e8 ff ff       	call   f01010b1 <_paddr>
f01027ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01027cd:	01 d0                	add    %edx,%eax
f01027cf:	39 c3                	cmp    %eax,%ebx
f01027d1:	74 24                	je     f01027f7 <check_kern_pgdir+0xb0>
f01027d3:	c7 44 24 0c 4c 94 10 	movl   $0xf010944c,0xc(%esp)
f01027da:	f0 
f01027db:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01027e2:	f0 
f01027e3:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f01027ea:	00 
f01027eb:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01027f2:	e8 00 db ff ff       	call   f01002f7 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027f7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f01027fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102801:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f0102804:	72 8e                	jb     f0102794 <check_kern_pgdir+0x4d>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
f0102806:	c7 45 e0 00 10 00 00 	movl   $0x1000,-0x20(%ebp)
f010280d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102810:	05 ff ef 01 00       	add    $0x1efff,%eax
f0102815:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102818:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010281b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102820:	f7 75 e0             	divl   -0x20(%ebp)
f0102823:	89 d0                	mov    %edx,%eax
f0102825:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102828:	29 c2                	sub    %eax,%edx
f010282a:	89 d0                	mov    %edx,%eax
f010282c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f010282f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0102836:	eb 6a                	jmp    f01028a2 <check_kern_pgdir+0x15b>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102838:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010283b:	2d 00 00 40 11       	sub    $0x11400000,%eax
f0102840:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102844:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102847:	89 04 24             	mov    %eax,(%esp)
f010284a:	e8 ff 02 00 00       	call   f0102b4e <check_va2pa>
f010284f:	89 c3                	mov    %eax,%ebx
f0102851:	a1 3c b2 23 f0       	mov    0xf023b23c,%eax
f0102856:	89 44 24 08          	mov    %eax,0x8(%esp)
f010285a:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f0102861:	00 
f0102862:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102869:	e8 43 e8 ff ff       	call   f01010b1 <_paddr>
f010286e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0102871:	01 d0                	add    %edx,%eax
f0102873:	39 c3                	cmp    %eax,%ebx
f0102875:	74 24                	je     f010289b <check_kern_pgdir+0x154>
f0102877:	c7 44 24 0c 80 94 10 	movl   $0xf0109480,0xc(%esp)
f010287e:	f0 
f010287f:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102886:	f0 
f0102887:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f010288e:	00 
f010288f:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102896:	e8 5c da ff ff       	call   f01002f7 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010289b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f01028a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01028a5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f01028a8:	72 8e                	jb     f0102838 <check_kern_pgdir+0xf1>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01028aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f01028b1:	eb 47                	jmp    f01028fa <check_kern_pgdir+0x1b3>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01028b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01028b6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01028bb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01028bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01028c2:	89 04 24             	mov    %eax,(%esp)
f01028c5:	e8 84 02 00 00       	call   f0102b4e <check_va2pa>
f01028ca:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f01028cd:	74 24                	je     f01028f3 <check_kern_pgdir+0x1ac>
f01028cf:	c7 44 24 0c b4 94 10 	movl   $0xf01094b4,0xc(%esp)
f01028d6:	f0 
f01028d7:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01028de:	f0 
f01028df:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f01028e6:	00 
f01028e7:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01028ee:	e8 04 da ff ff       	call   f01002f7 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01028f3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f01028fa:	a1 e8 be 23 f0       	mov    0xf023bee8,%eax
f01028ff:	c1 e0 0c             	shl    $0xc,%eax
f0102902:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0102905:	77 ac                	ja     f01028b3 <check_kern_pgdir+0x16c>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102907:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f010290e:	e9 f9 00 00 00       	jmp    f0102a0c <check_kern_pgdir+0x2c5>
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
f0102913:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0102916:	b8 00 00 00 00       	mov    $0x0,%eax
f010291b:	29 d0                	sub    %edx,%eax
f010291d:	c1 e0 10             	shl    $0x10,%eax
f0102920:	2d 00 00 01 10       	sub    $0x10010000,%eax
f0102925:	89 45 d8             	mov    %eax,-0x28(%ebp)
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102928:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f010292f:	eb 75                	jmp    f01029a6 <check_kern_pgdir+0x25f>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102931:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102934:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102937:	01 d0                	add    %edx,%eax
f0102939:	05 00 80 00 00       	add    $0x8000,%eax
f010293e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102942:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102945:	89 04 24             	mov    %eax,(%esp)
f0102948:	e8 01 02 00 00       	call   f0102b4e <check_va2pa>
f010294d:	89 c3                	mov    %eax,%ebx
f010294f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102952:	c1 e0 0f             	shl    $0xf,%eax
f0102955:	05 00 d0 23 f0       	add    $0xf023d000,%eax
f010295a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010295e:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f0102965:	00 
f0102966:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010296d:	e8 3f e7 ff ff       	call   f01010b1 <_paddr>
f0102972:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0102975:	01 d0                	add    %edx,%eax
f0102977:	39 c3                	cmp    %eax,%ebx
f0102979:	74 24                	je     f010299f <check_kern_pgdir+0x258>
f010297b:	c7 44 24 0c dc 94 10 	movl   $0xf01094dc,0xc(%esp)
f0102982:	f0 
f0102983:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f010298a:	f0 
f010298b:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f0102992:	00 
f0102993:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010299a:	e8 58 d9 ff ff       	call   f01002f7 <_panic>

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010299f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f01029a6:	81 7d f4 ff 7f 00 00 	cmpl   $0x7fff,-0xc(%ebp)
f01029ad:	76 82                	jbe    f0102931 <check_kern_pgdir+0x1ea>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01029af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f01029b6:	eb 47                	jmp    f01029ff <check_kern_pgdir+0x2b8>
			assert(check_va2pa(pgdir, base + i) == ~0);
f01029b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01029bb:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01029be:	01 d0                	add    %edx,%eax
f01029c0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01029c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01029c7:	89 04 24             	mov    %eax,(%esp)
f01029ca:	e8 7f 01 00 00       	call   f0102b4e <check_va2pa>
f01029cf:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029d2:	74 24                	je     f01029f8 <check_kern_pgdir+0x2b1>
f01029d4:	c7 44 24 0c 24 95 10 	movl   $0xf0109524,0xc(%esp)
f01029db:	f0 
f01029dc:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01029e3:	f0 
f01029e4:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f01029eb:	00 
f01029ec:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01029f3:	e8 ff d8 ff ff       	call   f01002f7 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01029f8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f01029ff:	81 7d f4 ff 7f 00 00 	cmpl   $0x7fff,-0xc(%ebp)
f0102a06:	76 b0                	jbe    f01029b8 <check_kern_pgdir+0x271>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102a08:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f0102a0c:	83 7d f0 07          	cmpl   $0x7,-0x10(%ebp)
f0102a10:	0f 86 fd fe ff ff    	jbe    f0102913 <check_kern_pgdir+0x1cc>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102a16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0102a1d:	e9 0d 01 00 00       	jmp    f0102b2f <check_kern_pgdir+0x3e8>
		switch (i) {
f0102a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102a25:	2d bb 03 00 00       	sub    $0x3bb,%eax
f0102a2a:	83 f8 04             	cmp    $0x4,%eax
f0102a2d:	77 41                	ja     f0102a70 <check_kern_pgdir+0x329>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102a32:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102a39:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102a3c:	01 d0                	add    %edx,%eax
f0102a3e:	8b 00                	mov    (%eax),%eax
f0102a40:	83 e0 01             	and    $0x1,%eax
f0102a43:	85 c0                	test   %eax,%eax
f0102a45:	75 24                	jne    f0102a6b <check_kern_pgdir+0x324>
f0102a47:	c7 44 24 0c 47 95 10 	movl   $0xf0109547,0xc(%esp)
f0102a4e:	f0 
f0102a4f:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102a56:	f0 
f0102a57:	c7 44 24 04 ac 03 00 	movl   $0x3ac,0x4(%esp)
f0102a5e:	00 
f0102a5f:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102a66:	e8 8c d8 ff ff       	call   f01002f7 <_panic>
			break;
f0102a6b:	e9 bb 00 00 00       	jmp    f0102b2b <check_kern_pgdir+0x3e4>
		default:
			if (i >= PDX(KERNBASE)) {
f0102a70:	81 7d f4 bf 03 00 00 	cmpl   $0x3bf,-0xc(%ebp)
f0102a77:	76 78                	jbe    f0102af1 <check_kern_pgdir+0x3aa>
				assert(pgdir[i] & PTE_P);
f0102a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102a7c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102a83:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102a86:	01 d0                	add    %edx,%eax
f0102a88:	8b 00                	mov    (%eax),%eax
f0102a8a:	83 e0 01             	and    $0x1,%eax
f0102a8d:	85 c0                	test   %eax,%eax
f0102a8f:	75 24                	jne    f0102ab5 <check_kern_pgdir+0x36e>
f0102a91:	c7 44 24 0c 47 95 10 	movl   $0xf0109547,0xc(%esp)
f0102a98:	f0 
f0102a99:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102aa0:	f0 
f0102aa1:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0102aa8:	00 
f0102aa9:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102ab0:	e8 42 d8 ff ff       	call   f01002f7 <_panic>
				assert(pgdir[i] & PTE_W);
f0102ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102ab8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102abf:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102ac2:	01 d0                	add    %edx,%eax
f0102ac4:	8b 00                	mov    (%eax),%eax
f0102ac6:	83 e0 02             	and    $0x2,%eax
f0102ac9:	85 c0                	test   %eax,%eax
f0102acb:	75 5d                	jne    f0102b2a <check_kern_pgdir+0x3e3>
f0102acd:	c7 44 24 0c 58 95 10 	movl   $0xf0109558,0xc(%esp)
f0102ad4:	f0 
f0102ad5:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102adc:	f0 
f0102add:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f0102ae4:	00 
f0102ae5:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102aec:	e8 06 d8 ff ff       	call   f01002f7 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102af4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102afb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102afe:	01 d0                	add    %edx,%eax
f0102b00:	8b 00                	mov    (%eax),%eax
f0102b02:	85 c0                	test   %eax,%eax
f0102b04:	74 24                	je     f0102b2a <check_kern_pgdir+0x3e3>
f0102b06:	c7 44 24 0c 69 95 10 	movl   $0xf0109569,0xc(%esp)
f0102b0d:	f0 
f0102b0e:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102b15:	f0 
f0102b16:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f0102b1d:	00 
f0102b1e:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102b25:	e8 cd d7 ff ff       	call   f01002f7 <_panic>
			break;
f0102b2a:	90                   	nop
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102b2b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0102b2f:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
f0102b36:	0f 86 e6 fe ff ff    	jbe    f0102a22 <check_kern_pgdir+0x2db>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b3c:	c7 04 24 78 95 10 f0 	movl   $0xf0109578,(%esp)
f0102b43:	e8 77 24 00 00       	call   f0104fbf <cprintf>
}
f0102b48:	83 c4 34             	add    $0x34,%esp
f0102b4b:	5b                   	pop    %ebx
f0102b4c:	5d                   	pop    %ebp
f0102b4d:	c3                   	ret    

f0102b4e <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0102b4e:	55                   	push   %ebp
f0102b4f:	89 e5                	mov    %esp,%ebp
f0102b51:	83 ec 28             	sub    $0x28,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0102b54:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b57:	c1 e8 16             	shr    $0x16,%eax
f0102b5a:	c1 e0 02             	shl    $0x2,%eax
f0102b5d:	01 45 08             	add    %eax,0x8(%ebp)
	if (!(*pgdir & PTE_P))
f0102b60:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b63:	8b 00                	mov    (%eax),%eax
f0102b65:	83 e0 01             	and    $0x1,%eax
f0102b68:	85 c0                	test   %eax,%eax
f0102b6a:	75 07                	jne    f0102b73 <check_va2pa+0x25>
		return ~0;
f0102b6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102b71:	eb 6a                	jmp    f0102bdd <check_va2pa+0x8f>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0102b73:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b76:	8b 00                	mov    (%eax),%eax
f0102b78:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102b7d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102b81:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0102b88:	00 
f0102b89:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102b90:	e8 57 e5 ff ff       	call   f01010ec <_kaddr>
f0102b95:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (!(p[PTX(va)] & PTE_P))
f0102b98:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b9b:	c1 e8 0c             	shr    $0xc,%eax
f0102b9e:	25 ff 03 00 00       	and    $0x3ff,%eax
f0102ba3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102bad:	01 d0                	add    %edx,%eax
f0102baf:	8b 00                	mov    (%eax),%eax
f0102bb1:	83 e0 01             	and    $0x1,%eax
f0102bb4:	85 c0                	test   %eax,%eax
f0102bb6:	75 07                	jne    f0102bbf <check_va2pa+0x71>
		return ~0;
f0102bb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102bbd:	eb 1e                	jmp    f0102bdd <check_va2pa+0x8f>
	return PTE_ADDR(p[PTX(va)]);
f0102bbf:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102bc2:	c1 e8 0c             	shr    $0xc,%eax
f0102bc5:	25 ff 03 00 00       	and    $0x3ff,%eax
f0102bca:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102bd4:	01 d0                	add    %edx,%eax
f0102bd6:	8b 00                	mov    (%eax),%eax
f0102bd8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
}
f0102bdd:	c9                   	leave  
f0102bde:	c3                   	ret    

f0102bdf <check_page>:


// check page_insert, page_remove, &c
static void
check_page(void)
{
f0102bdf:	55                   	push   %ebp
f0102be0:	89 e5                	mov    %esp,%ebp
f0102be2:	53                   	push   %ebx
f0102be3:	83 ec 44             	sub    $0x44,%esp
	uintptr_t mm1, mm2;
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f0102be6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0102bed:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102bf0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102bf3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102bf6:	89 45 e8             	mov    %eax,-0x18(%ebp)
	assert((pp0 = page_alloc(0)));
f0102bf9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c00:	e8 bd eb ff ff       	call   f01017c2 <page_alloc>
f0102c05:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0102c08:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102c0c:	75 24                	jne    f0102c32 <check_page+0x53>
f0102c0e:	c7 44 24 0c 08 93 10 	movl   $0xf0109308,0xc(%esp)
f0102c15:	f0 
f0102c16:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102c1d:	f0 
f0102c1e:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0102c25:	00 
f0102c26:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102c2d:	e8 c5 d6 ff ff       	call   f01002f7 <_panic>
	assert((pp1 = page_alloc(0)));
f0102c32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c39:	e8 84 eb ff ff       	call   f01017c2 <page_alloc>
f0102c3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102c41:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0102c45:	75 24                	jne    f0102c6b <check_page+0x8c>
f0102c47:	c7 44 24 0c 1e 93 10 	movl   $0xf010931e,0xc(%esp)
f0102c4e:	f0 
f0102c4f:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102c56:	f0 
f0102c57:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f0102c5e:	00 
f0102c5f:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102c66:	e8 8c d6 ff ff       	call   f01002f7 <_panic>
	assert((pp2 = page_alloc(0)));
f0102c6b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c72:	e8 4b eb ff ff       	call   f01017c2 <page_alloc>
f0102c77:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102c7a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0102c7e:	75 24                	jne    f0102ca4 <check_page+0xc5>
f0102c80:	c7 44 24 0c 34 93 10 	movl   $0xf0109334,0xc(%esp)
f0102c87:	f0 
f0102c88:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102c8f:	f0 
f0102c90:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f0102c97:	00 
f0102c98:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102c9f:	e8 53 d6 ff ff       	call   f01002f7 <_panic>

	assert(pp0);
f0102ca4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102ca8:	75 24                	jne    f0102cce <check_page+0xef>
f0102caa:	c7 44 24 0c 4a 93 10 	movl   $0xf010934a,0xc(%esp)
f0102cb1:	f0 
f0102cb2:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102cb9:	f0 
f0102cba:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0102cc1:	00 
f0102cc2:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102cc9:	e8 29 d6 ff ff       	call   f01002f7 <_panic>
	assert(pp1 && pp1 != pp0);
f0102cce:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0102cd2:	74 08                	je     f0102cdc <check_page+0xfd>
f0102cd4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102cd7:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0102cda:	75 24                	jne    f0102d00 <check_page+0x121>
f0102cdc:	c7 44 24 0c 4e 93 10 	movl   $0xf010934e,0xc(%esp)
f0102ce3:	f0 
f0102ce4:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102ceb:	f0 
f0102cec:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f0102cf3:	00 
f0102cf4:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102cfb:	e8 f7 d5 ff ff       	call   f01002f7 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102d00:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0102d04:	74 10                	je     f0102d16 <check_page+0x137>
f0102d06:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102d09:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f0102d0c:	74 08                	je     f0102d16 <check_page+0x137>
f0102d0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102d11:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0102d14:	75 24                	jne    f0102d3a <check_page+0x15b>
f0102d16:	c7 44 24 0c 60 93 10 	movl   $0xf0109360,0xc(%esp)
f0102d1d:	f0 
f0102d1e:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102d25:	f0 
f0102d26:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0102d2d:	00 
f0102d2e:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102d35:	e8 bd d5 ff ff       	call   f01002f7 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102d3a:	a1 30 b2 23 f0       	mov    0xf023b230,%eax
f0102d3f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	page_free_list = 0;
f0102d42:	c7 05 30 b2 23 f0 00 	movl   $0x0,0xf023b230
f0102d49:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102d4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d53:	e8 6a ea ff ff       	call   f01017c2 <page_alloc>
f0102d58:	85 c0                	test   %eax,%eax
f0102d5a:	74 24                	je     f0102d80 <check_page+0x1a1>
f0102d5c:	c7 44 24 0c d7 93 10 	movl   $0xf01093d7,0xc(%esp)
f0102d63:	f0 
f0102d64:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102d6b:	f0 
f0102d6c:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f0102d73:	00 
f0102d74:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102d7b:	e8 77 d5 ff ff       	call   f01002f7 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102d80:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0102d85:	8d 55 cc             	lea    -0x34(%ebp),%edx
f0102d88:	89 54 24 08          	mov    %edx,0x8(%esp)
f0102d8c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102d93:	00 
f0102d94:	89 04 24             	mov    %eax,(%esp)
f0102d97:	e8 7d ed ff ff       	call   f0101b19 <page_lookup>
f0102d9c:	85 c0                	test   %eax,%eax
f0102d9e:	74 24                	je     f0102dc4 <check_page+0x1e5>
f0102da0:	c7 44 24 0c 98 95 10 	movl   $0xf0109598,0xc(%esp)
f0102da7:	f0 
f0102da8:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102daf:	f0 
f0102db0:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f0102db7:	00 
f0102db8:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102dbf:	e8 33 d5 ff ff       	call   f01002f7 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102dc4:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0102dc9:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102dd0:	00 
f0102dd1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102dd8:	00 
f0102dd9:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0102ddc:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102de0:	89 04 24             	mov    %eax,(%esp)
f0102de3:	e8 80 ec ff ff       	call   f0101a68 <page_insert>
f0102de8:	85 c0                	test   %eax,%eax
f0102dea:	78 24                	js     f0102e10 <check_page+0x231>
f0102dec:	c7 44 24 0c d0 95 10 	movl   $0xf01095d0,0xc(%esp)
f0102df3:	f0 
f0102df4:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102dfb:	f0 
f0102dfc:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f0102e03:	00 
f0102e04:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102e0b:	e8 e7 d4 ff ff       	call   f01002f7 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0102e10:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102e13:	89 04 24             	mov    %eax,(%esp)
f0102e16:	e8 0c ea ff ff       	call   f0101827 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102e1b:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0102e20:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102e27:	00 
f0102e28:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102e2f:	00 
f0102e30:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0102e33:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102e37:	89 04 24             	mov    %eax,(%esp)
f0102e3a:	e8 29 ec ff ff       	call   f0101a68 <page_insert>
f0102e3f:	85 c0                	test   %eax,%eax
f0102e41:	74 24                	je     f0102e67 <check_page+0x288>
f0102e43:	c7 44 24 0c 00 96 10 	movl   $0xf0109600,0xc(%esp)
f0102e4a:	f0 
f0102e4b:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102e52:	f0 
f0102e53:	c7 44 24 04 f3 03 00 	movl   $0x3f3,0x4(%esp)
f0102e5a:	00 
f0102e5b:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102e62:	e8 90 d4 ff ff       	call   f01002f7 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e67:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0102e6c:	8b 00                	mov    (%eax),%eax
f0102e6e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102e73:	89 c3                	mov    %eax,%ebx
f0102e75:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102e78:	89 04 24             	mov    %eax,(%esp)
f0102e7b:	e8 ae e2 ff ff       	call   f010112e <page2pa>
f0102e80:	39 c3                	cmp    %eax,%ebx
f0102e82:	74 24                	je     f0102ea8 <check_page+0x2c9>
f0102e84:	c7 44 24 0c 30 96 10 	movl   $0xf0109630,0xc(%esp)
f0102e8b:	f0 
f0102e8c:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102e93:	f0 
f0102e94:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f0102e9b:	00 
f0102e9c:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102ea3:	e8 4f d4 ff ff       	call   f01002f7 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102ea8:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0102ead:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102eb4:	00 
f0102eb5:	89 04 24             	mov    %eax,(%esp)
f0102eb8:	e8 91 fc ff ff       	call   f0102b4e <check_va2pa>
f0102ebd:	89 c3                	mov    %eax,%ebx
f0102ebf:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102ec2:	89 04 24             	mov    %eax,(%esp)
f0102ec5:	e8 64 e2 ff ff       	call   f010112e <page2pa>
f0102eca:	39 c3                	cmp    %eax,%ebx
f0102ecc:	74 24                	je     f0102ef2 <check_page+0x313>
f0102ece:	c7 44 24 0c 58 96 10 	movl   $0xf0109658,0xc(%esp)
f0102ed5:	f0 
f0102ed6:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102edd:	f0 
f0102ede:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f0102ee5:	00 
f0102ee6:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102eed:	e8 05 d4 ff ff       	call   f01002f7 <_panic>
	assert(pp0->pp_ref == 1);
f0102ef2:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102ef5:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0102ef9:	66 83 f8 01          	cmp    $0x1,%ax
f0102efd:	74 24                	je     f0102f23 <check_page+0x344>
f0102eff:	c7 44 24 0c 85 96 10 	movl   $0xf0109685,0xc(%esp)
f0102f06:	f0 
f0102f07:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102f0e:	f0 
f0102f0f:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0102f16:	00 
f0102f17:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102f1e:	e8 d4 d3 ff ff       	call   f01002f7 <_panic>
	assert(pp1->pp_ref == 1);
f0102f23:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102f26:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0102f2a:	66 83 f8 01          	cmp    $0x1,%ax
f0102f2e:	74 24                	je     f0102f54 <check_page+0x375>
f0102f30:	c7 44 24 0c 96 96 10 	movl   $0xf0109696,0xc(%esp)
f0102f37:	f0 
f0102f38:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102f3f:	f0 
f0102f40:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0102f47:	00 
f0102f48:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102f4f:	e8 a3 d3 ff ff       	call   f01002f7 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102f54:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0102f59:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102f60:	00 
f0102f61:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102f68:	00 
f0102f69:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0102f6c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102f70:	89 04 24             	mov    %eax,(%esp)
f0102f73:	e8 f0 ea ff ff       	call   f0101a68 <page_insert>
f0102f78:	85 c0                	test   %eax,%eax
f0102f7a:	74 24                	je     f0102fa0 <check_page+0x3c1>
f0102f7c:	c7 44 24 0c a8 96 10 	movl   $0xf01096a8,0xc(%esp)
f0102f83:	f0 
f0102f84:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102f8b:	f0 
f0102f8c:	c7 44 24 04 fa 03 00 	movl   $0x3fa,0x4(%esp)
f0102f93:	00 
f0102f94:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102f9b:	e8 57 d3 ff ff       	call   f01002f7 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102fa0:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0102fa5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102fac:	00 
f0102fad:	89 04 24             	mov    %eax,(%esp)
f0102fb0:	e8 99 fb ff ff       	call   f0102b4e <check_va2pa>
f0102fb5:	89 c3                	mov    %eax,%ebx
f0102fb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102fba:	89 04 24             	mov    %eax,(%esp)
f0102fbd:	e8 6c e1 ff ff       	call   f010112e <page2pa>
f0102fc2:	39 c3                	cmp    %eax,%ebx
f0102fc4:	74 24                	je     f0102fea <check_page+0x40b>
f0102fc6:	c7 44 24 0c e4 96 10 	movl   $0xf01096e4,0xc(%esp)
f0102fcd:	f0 
f0102fce:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0102fd5:	f0 
f0102fd6:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f0102fdd:	00 
f0102fde:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0102fe5:	e8 0d d3 ff ff       	call   f01002f7 <_panic>
	assert(pp2->pp_ref == 1);
f0102fea:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102fed:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0102ff1:	66 83 f8 01          	cmp    $0x1,%ax
f0102ff5:	74 24                	je     f010301b <check_page+0x43c>
f0102ff7:	c7 44 24 0c 14 97 10 	movl   $0xf0109714,0xc(%esp)
f0102ffe:	f0 
f0102fff:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103006:	f0 
f0103007:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f010300e:	00 
f010300f:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103016:	e8 dc d2 ff ff       	call   f01002f7 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010301b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103022:	e8 9b e7 ff ff       	call   f01017c2 <page_alloc>
f0103027:	85 c0                	test   %eax,%eax
f0103029:	74 24                	je     f010304f <check_page+0x470>
f010302b:	c7 44 24 0c d7 93 10 	movl   $0xf01093d7,0xc(%esp)
f0103032:	f0 
f0103033:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f010303a:	f0 
f010303b:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f0103042:	00 
f0103043:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010304a:	e8 a8 d2 ff ff       	call   f01002f7 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010304f:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0103054:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010305b:	00 
f010305c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103063:	00 
f0103064:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103067:	89 54 24 04          	mov    %edx,0x4(%esp)
f010306b:	89 04 24             	mov    %eax,(%esp)
f010306e:	e8 f5 e9 ff ff       	call   f0101a68 <page_insert>
f0103073:	85 c0                	test   %eax,%eax
f0103075:	74 24                	je     f010309b <check_page+0x4bc>
f0103077:	c7 44 24 0c a8 96 10 	movl   $0xf01096a8,0xc(%esp)
f010307e:	f0 
f010307f:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103086:	f0 
f0103087:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f010308e:	00 
f010308f:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103096:	e8 5c d2 ff ff       	call   f01002f7 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010309b:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f01030a0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01030a7:	00 
f01030a8:	89 04 24             	mov    %eax,(%esp)
f01030ab:	e8 9e fa ff ff       	call   f0102b4e <check_va2pa>
f01030b0:	89 c3                	mov    %eax,%ebx
f01030b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01030b5:	89 04 24             	mov    %eax,(%esp)
f01030b8:	e8 71 e0 ff ff       	call   f010112e <page2pa>
f01030bd:	39 c3                	cmp    %eax,%ebx
f01030bf:	74 24                	je     f01030e5 <check_page+0x506>
f01030c1:	c7 44 24 0c e4 96 10 	movl   $0xf01096e4,0xc(%esp)
f01030c8:	f0 
f01030c9:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01030d0:	f0 
f01030d1:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f01030d8:	00 
f01030d9:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01030e0:	e8 12 d2 ff ff       	call   f01002f7 <_panic>
	assert(pp2->pp_ref == 1);
f01030e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01030e8:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01030ec:	66 83 f8 01          	cmp    $0x1,%ax
f01030f0:	74 24                	je     f0103116 <check_page+0x537>
f01030f2:	c7 44 24 0c 14 97 10 	movl   $0xf0109714,0xc(%esp)
f01030f9:	f0 
f01030fa:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103101:	f0 
f0103102:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f0103109:	00 
f010310a:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103111:	e8 e1 d1 ff ff       	call   f01002f7 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0103116:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010311d:	e8 a0 e6 ff ff       	call   f01017c2 <page_alloc>
f0103122:	85 c0                	test   %eax,%eax
f0103124:	74 24                	je     f010314a <check_page+0x56b>
f0103126:	c7 44 24 0c d7 93 10 	movl   $0xf01093d7,0xc(%esp)
f010312d:	f0 
f010312e:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103135:	f0 
f0103136:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f010313d:	00 
f010313e:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103145:	e8 ad d1 ff ff       	call   f01002f7 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010314a:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f010314f:	8b 00                	mov    (%eax),%eax
f0103151:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103156:	89 44 24 08          	mov    %eax,0x8(%esp)
f010315a:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f0103161:	00 
f0103162:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103169:	e8 7e df ff ff       	call   f01010ec <_kaddr>
f010316e:	89 45 cc             	mov    %eax,-0x34(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0103171:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0103176:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010317d:	00 
f010317e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103185:	00 
f0103186:	89 04 24             	mov    %eax,(%esp)
f0103189:	e8 31 e7 ff ff       	call   f01018bf <pgdir_walk>
f010318e:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0103191:	83 c2 04             	add    $0x4,%edx
f0103194:	39 d0                	cmp    %edx,%eax
f0103196:	74 24                	je     f01031bc <check_page+0x5dd>
f0103198:	c7 44 24 0c 28 97 10 	movl   $0xf0109728,0xc(%esp)
f010319f:	f0 
f01031a0:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01031a7:	f0 
f01031a8:	c7 44 24 04 0c 04 00 	movl   $0x40c,0x4(%esp)
f01031af:	00 
f01031b0:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01031b7:	e8 3b d1 ff ff       	call   f01002f7 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01031bc:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f01031c1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01031c8:	00 
f01031c9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01031d0:	00 
f01031d1:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01031d4:	89 54 24 04          	mov    %edx,0x4(%esp)
f01031d8:	89 04 24             	mov    %eax,(%esp)
f01031db:	e8 88 e8 ff ff       	call   f0101a68 <page_insert>
f01031e0:	85 c0                	test   %eax,%eax
f01031e2:	74 24                	je     f0103208 <check_page+0x629>
f01031e4:	c7 44 24 0c 68 97 10 	movl   $0xf0109768,0xc(%esp)
f01031eb:	f0 
f01031ec:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01031f3:	f0 
f01031f4:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f01031fb:	00 
f01031fc:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103203:	e8 ef d0 ff ff       	call   f01002f7 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0103208:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f010320d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103214:	00 
f0103215:	89 04 24             	mov    %eax,(%esp)
f0103218:	e8 31 f9 ff ff       	call   f0102b4e <check_va2pa>
f010321d:	89 c3                	mov    %eax,%ebx
f010321f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103222:	89 04 24             	mov    %eax,(%esp)
f0103225:	e8 04 df ff ff       	call   f010112e <page2pa>
f010322a:	39 c3                	cmp    %eax,%ebx
f010322c:	74 24                	je     f0103252 <check_page+0x673>
f010322e:	c7 44 24 0c e4 96 10 	movl   $0xf01096e4,0xc(%esp)
f0103235:	f0 
f0103236:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f010323d:	f0 
f010323e:	c7 44 24 04 10 04 00 	movl   $0x410,0x4(%esp)
f0103245:	00 
f0103246:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010324d:	e8 a5 d0 ff ff       	call   f01002f7 <_panic>
	assert(pp2->pp_ref == 1);
f0103252:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103255:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0103259:	66 83 f8 01          	cmp    $0x1,%ax
f010325d:	74 24                	je     f0103283 <check_page+0x6a4>
f010325f:	c7 44 24 0c 14 97 10 	movl   $0xf0109714,0xc(%esp)
f0103266:	f0 
f0103267:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f010326e:	f0 
f010326f:	c7 44 24 04 11 04 00 	movl   $0x411,0x4(%esp)
f0103276:	00 
f0103277:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010327e:	e8 74 d0 ff ff       	call   f01002f7 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0103283:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0103288:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010328f:	00 
f0103290:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103297:	00 
f0103298:	89 04 24             	mov    %eax,(%esp)
f010329b:	e8 1f e6 ff ff       	call   f01018bf <pgdir_walk>
f01032a0:	8b 00                	mov    (%eax),%eax
f01032a2:	83 e0 04             	and    $0x4,%eax
f01032a5:	85 c0                	test   %eax,%eax
f01032a7:	75 24                	jne    f01032cd <check_page+0x6ee>
f01032a9:	c7 44 24 0c a8 97 10 	movl   $0xf01097a8,0xc(%esp)
f01032b0:	f0 
f01032b1:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01032b8:	f0 
f01032b9:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f01032c0:	00 
f01032c1:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01032c8:	e8 2a d0 ff ff       	call   f01002f7 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01032cd:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f01032d2:	8b 00                	mov    (%eax),%eax
f01032d4:	83 e0 04             	and    $0x4,%eax
f01032d7:	85 c0                	test   %eax,%eax
f01032d9:	75 24                	jne    f01032ff <check_page+0x720>
f01032db:	c7 44 24 0c db 97 10 	movl   $0xf01097db,0xc(%esp)
f01032e2:	f0 
f01032e3:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01032ea:	f0 
f01032eb:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f01032f2:	00 
f01032f3:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01032fa:	e8 f8 cf ff ff       	call   f01002f7 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01032ff:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0103304:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010330b:	00 
f010330c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103313:	00 
f0103314:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103317:	89 54 24 04          	mov    %edx,0x4(%esp)
f010331b:	89 04 24             	mov    %eax,(%esp)
f010331e:	e8 45 e7 ff ff       	call   f0101a68 <page_insert>
f0103323:	85 c0                	test   %eax,%eax
f0103325:	74 24                	je     f010334b <check_page+0x76c>
f0103327:	c7 44 24 0c a8 96 10 	movl   $0xf01096a8,0xc(%esp)
f010332e:	f0 
f010332f:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103336:	f0 
f0103337:	c7 44 24 04 16 04 00 	movl   $0x416,0x4(%esp)
f010333e:	00 
f010333f:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103346:	e8 ac cf ff ff       	call   f01002f7 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010334b:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0103350:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103357:	00 
f0103358:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010335f:	00 
f0103360:	89 04 24             	mov    %eax,(%esp)
f0103363:	e8 57 e5 ff ff       	call   f01018bf <pgdir_walk>
f0103368:	8b 00                	mov    (%eax),%eax
f010336a:	83 e0 02             	and    $0x2,%eax
f010336d:	85 c0                	test   %eax,%eax
f010336f:	75 24                	jne    f0103395 <check_page+0x7b6>
f0103371:	c7 44 24 0c f4 97 10 	movl   $0xf01097f4,0xc(%esp)
f0103378:	f0 
f0103379:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103380:	f0 
f0103381:	c7 44 24 04 17 04 00 	movl   $0x417,0x4(%esp)
f0103388:	00 
f0103389:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103390:	e8 62 cf ff ff       	call   f01002f7 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0103395:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f010339a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01033a1:	00 
f01033a2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01033a9:	00 
f01033aa:	89 04 24             	mov    %eax,(%esp)
f01033ad:	e8 0d e5 ff ff       	call   f01018bf <pgdir_walk>
f01033b2:	8b 00                	mov    (%eax),%eax
f01033b4:	83 e0 04             	and    $0x4,%eax
f01033b7:	85 c0                	test   %eax,%eax
f01033b9:	74 24                	je     f01033df <check_page+0x800>
f01033bb:	c7 44 24 0c 28 98 10 	movl   $0xf0109828,0xc(%esp)
f01033c2:	f0 
f01033c3:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01033ca:	f0 
f01033cb:	c7 44 24 04 18 04 00 	movl   $0x418,0x4(%esp)
f01033d2:	00 
f01033d3:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01033da:	e8 18 cf ff ff       	call   f01002f7 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01033df:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f01033e4:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01033eb:	00 
f01033ec:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01033f3:	00 
f01033f4:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01033f7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01033fb:	89 04 24             	mov    %eax,(%esp)
f01033fe:	e8 65 e6 ff ff       	call   f0101a68 <page_insert>
f0103403:	85 c0                	test   %eax,%eax
f0103405:	78 24                	js     f010342b <check_page+0x84c>
f0103407:	c7 44 24 0c 60 98 10 	movl   $0xf0109860,0xc(%esp)
f010340e:	f0 
f010340f:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103416:	f0 
f0103417:	c7 44 24 04 1b 04 00 	movl   $0x41b,0x4(%esp)
f010341e:	00 
f010341f:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103426:	e8 cc ce ff ff       	call   f01002f7 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010342b:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0103430:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103437:	00 
f0103438:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010343f:	00 
f0103440:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0103443:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103447:	89 04 24             	mov    %eax,(%esp)
f010344a:	e8 19 e6 ff ff       	call   f0101a68 <page_insert>
f010344f:	85 c0                	test   %eax,%eax
f0103451:	74 24                	je     f0103477 <check_page+0x898>
f0103453:	c7 44 24 0c 98 98 10 	movl   $0xf0109898,0xc(%esp)
f010345a:	f0 
f010345b:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103462:	f0 
f0103463:	c7 44 24 04 1e 04 00 	movl   $0x41e,0x4(%esp)
f010346a:	00 
f010346b:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103472:	e8 80 ce ff ff       	call   f01002f7 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0103477:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f010347c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103483:	00 
f0103484:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010348b:	00 
f010348c:	89 04 24             	mov    %eax,(%esp)
f010348f:	e8 2b e4 ff ff       	call   f01018bf <pgdir_walk>
f0103494:	8b 00                	mov    (%eax),%eax
f0103496:	83 e0 04             	and    $0x4,%eax
f0103499:	85 c0                	test   %eax,%eax
f010349b:	74 24                	je     f01034c1 <check_page+0x8e2>
f010349d:	c7 44 24 0c 28 98 10 	movl   $0xf0109828,0xc(%esp)
f01034a4:	f0 
f01034a5:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01034ac:	f0 
f01034ad:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f01034b4:	00 
f01034b5:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01034bc:	e8 36 ce ff ff       	call   f01002f7 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01034c1:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f01034c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01034cd:	00 
f01034ce:	89 04 24             	mov    %eax,(%esp)
f01034d1:	e8 78 f6 ff ff       	call   f0102b4e <check_va2pa>
f01034d6:	89 c3                	mov    %eax,%ebx
f01034d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01034db:	89 04 24             	mov    %eax,(%esp)
f01034de:	e8 4b dc ff ff       	call   f010112e <page2pa>
f01034e3:	39 c3                	cmp    %eax,%ebx
f01034e5:	74 24                	je     f010350b <check_page+0x92c>
f01034e7:	c7 44 24 0c d4 98 10 	movl   $0xf01098d4,0xc(%esp)
f01034ee:	f0 
f01034ef:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01034f6:	f0 
f01034f7:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f01034fe:	00 
f01034ff:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103506:	e8 ec cd ff ff       	call   f01002f7 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010350b:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0103510:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103517:	00 
f0103518:	89 04 24             	mov    %eax,(%esp)
f010351b:	e8 2e f6 ff ff       	call   f0102b4e <check_va2pa>
f0103520:	89 c3                	mov    %eax,%ebx
f0103522:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103525:	89 04 24             	mov    %eax,(%esp)
f0103528:	e8 01 dc ff ff       	call   f010112e <page2pa>
f010352d:	39 c3                	cmp    %eax,%ebx
f010352f:	74 24                	je     f0103555 <check_page+0x976>
f0103531:	c7 44 24 0c 00 99 10 	movl   $0xf0109900,0xc(%esp)
f0103538:	f0 
f0103539:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103540:	f0 
f0103541:	c7 44 24 04 23 04 00 	movl   $0x423,0x4(%esp)
f0103548:	00 
f0103549:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103550:	e8 a2 cd ff ff       	call   f01002f7 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0103555:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103558:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f010355c:	66 83 f8 02          	cmp    $0x2,%ax
f0103560:	74 24                	je     f0103586 <check_page+0x9a7>
f0103562:	c7 44 24 0c 30 99 10 	movl   $0xf0109930,0xc(%esp)
f0103569:	f0 
f010356a:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103571:	f0 
f0103572:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f0103579:	00 
f010357a:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103581:	e8 71 cd ff ff       	call   f01002f7 <_panic>
	assert(pp2->pp_ref == 0);
f0103586:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103589:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f010358d:	66 85 c0             	test   %ax,%ax
f0103590:	74 24                	je     f01035b6 <check_page+0x9d7>
f0103592:	c7 44 24 0c 41 99 10 	movl   $0xf0109941,0xc(%esp)
f0103599:	f0 
f010359a:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01035a1:	f0 
f01035a2:	c7 44 24 04 26 04 00 	movl   $0x426,0x4(%esp)
f01035a9:	00 
f01035aa:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01035b1:	e8 41 cd ff ff       	call   f01002f7 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01035b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035bd:	e8 00 e2 ff ff       	call   f01017c2 <page_alloc>
f01035c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01035c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01035c9:	74 08                	je     f01035d3 <check_page+0x9f4>
f01035cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01035ce:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f01035d1:	74 24                	je     f01035f7 <check_page+0xa18>
f01035d3:	c7 44 24 0c 54 99 10 	movl   $0xf0109954,0xc(%esp)
f01035da:	f0 
f01035db:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01035e2:	f0 
f01035e3:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f01035ea:	00 
f01035eb:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01035f2:	e8 00 cd ff ff       	call   f01002f7 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01035f7:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f01035fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103603:	00 
f0103604:	89 04 24             	mov    %eax,(%esp)
f0103607:	e8 72 e5 ff ff       	call   f0101b7e <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010360c:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0103611:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103618:	00 
f0103619:	89 04 24             	mov    %eax,(%esp)
f010361c:	e8 2d f5 ff ff       	call   f0102b4e <check_va2pa>
f0103621:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103624:	74 24                	je     f010364a <check_page+0xa6b>
f0103626:	c7 44 24 0c 78 99 10 	movl   $0xf0109978,0xc(%esp)
f010362d:	f0 
f010362e:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103635:	f0 
f0103636:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f010363d:	00 
f010363e:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103645:	e8 ad cc ff ff       	call   f01002f7 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010364a:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f010364f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103656:	00 
f0103657:	89 04 24             	mov    %eax,(%esp)
f010365a:	e8 ef f4 ff ff       	call   f0102b4e <check_va2pa>
f010365f:	89 c3                	mov    %eax,%ebx
f0103661:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103664:	89 04 24             	mov    %eax,(%esp)
f0103667:	e8 c2 da ff ff       	call   f010112e <page2pa>
f010366c:	39 c3                	cmp    %eax,%ebx
f010366e:	74 24                	je     f0103694 <check_page+0xab5>
f0103670:	c7 44 24 0c 00 99 10 	movl   $0xf0109900,0xc(%esp)
f0103677:	f0 
f0103678:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f010367f:	f0 
f0103680:	c7 44 24 04 2e 04 00 	movl   $0x42e,0x4(%esp)
f0103687:	00 
f0103688:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010368f:	e8 63 cc ff ff       	call   f01002f7 <_panic>
	assert(pp1->pp_ref == 1);
f0103694:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103697:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f010369b:	66 83 f8 01          	cmp    $0x1,%ax
f010369f:	74 24                	je     f01036c5 <check_page+0xae6>
f01036a1:	c7 44 24 0c 96 96 10 	movl   $0xf0109696,0xc(%esp)
f01036a8:	f0 
f01036a9:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01036b0:	f0 
f01036b1:	c7 44 24 04 2f 04 00 	movl   $0x42f,0x4(%esp)
f01036b8:	00 
f01036b9:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01036c0:	e8 32 cc ff ff       	call   f01002f7 <_panic>
	assert(pp2->pp_ref == 0);
f01036c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01036c8:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01036cc:	66 85 c0             	test   %ax,%ax
f01036cf:	74 24                	je     f01036f5 <check_page+0xb16>
f01036d1:	c7 44 24 0c 41 99 10 	movl   $0xf0109941,0xc(%esp)
f01036d8:	f0 
f01036d9:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01036e0:	f0 
f01036e1:	c7 44 24 04 30 04 00 	movl   $0x430,0x4(%esp)
f01036e8:	00 
f01036e9:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01036f0:	e8 02 cc ff ff       	call   f01002f7 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01036f5:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f01036fa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103701:	00 
f0103702:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103709:	00 
f010370a:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010370d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103711:	89 04 24             	mov    %eax,(%esp)
f0103714:	e8 4f e3 ff ff       	call   f0101a68 <page_insert>
f0103719:	85 c0                	test   %eax,%eax
f010371b:	74 24                	je     f0103741 <check_page+0xb62>
f010371d:	c7 44 24 0c 9c 99 10 	movl   $0xf010999c,0xc(%esp)
f0103724:	f0 
f0103725:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f010372c:	f0 
f010372d:	c7 44 24 04 33 04 00 	movl   $0x433,0x4(%esp)
f0103734:	00 
f0103735:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010373c:	e8 b6 cb ff ff       	call   f01002f7 <_panic>
	assert(pp1->pp_ref);
f0103741:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103744:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0103748:	66 85 c0             	test   %ax,%ax
f010374b:	75 24                	jne    f0103771 <check_page+0xb92>
f010374d:	c7 44 24 0c d1 99 10 	movl   $0xf01099d1,0xc(%esp)
f0103754:	f0 
f0103755:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f010375c:	f0 
f010375d:	c7 44 24 04 34 04 00 	movl   $0x434,0x4(%esp)
f0103764:	00 
f0103765:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010376c:	e8 86 cb ff ff       	call   f01002f7 <_panic>
	assert(pp1->pp_link == NULL);
f0103771:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103774:	8b 00                	mov    (%eax),%eax
f0103776:	85 c0                	test   %eax,%eax
f0103778:	74 24                	je     f010379e <check_page+0xbbf>
f010377a:	c7 44 24 0c dd 99 10 	movl   $0xf01099dd,0xc(%esp)
f0103781:	f0 
f0103782:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103789:	f0 
f010378a:	c7 44 24 04 35 04 00 	movl   $0x435,0x4(%esp)
f0103791:	00 
f0103792:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103799:	e8 59 cb ff ff       	call   f01002f7 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010379e:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f01037a3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01037aa:	00 
f01037ab:	89 04 24             	mov    %eax,(%esp)
f01037ae:	e8 cb e3 ff ff       	call   f0101b7e <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01037b3:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f01037b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01037bf:	00 
f01037c0:	89 04 24             	mov    %eax,(%esp)
f01037c3:	e8 86 f3 ff ff       	call   f0102b4e <check_va2pa>
f01037c8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01037cb:	74 24                	je     f01037f1 <check_page+0xc12>
f01037cd:	c7 44 24 0c 78 99 10 	movl   $0xf0109978,0xc(%esp)
f01037d4:	f0 
f01037d5:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01037dc:	f0 
f01037dd:	c7 44 24 04 39 04 00 	movl   $0x439,0x4(%esp)
f01037e4:	00 
f01037e5:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01037ec:	e8 06 cb ff ff       	call   f01002f7 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01037f1:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f01037f6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01037fd:	00 
f01037fe:	89 04 24             	mov    %eax,(%esp)
f0103801:	e8 48 f3 ff ff       	call   f0102b4e <check_va2pa>
f0103806:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103809:	74 24                	je     f010382f <check_page+0xc50>
f010380b:	c7 44 24 0c f4 99 10 	movl   $0xf01099f4,0xc(%esp)
f0103812:	f0 
f0103813:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f010381a:	f0 
f010381b:	c7 44 24 04 3a 04 00 	movl   $0x43a,0x4(%esp)
f0103822:	00 
f0103823:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010382a:	e8 c8 ca ff ff       	call   f01002f7 <_panic>
	assert(pp1->pp_ref == 0);
f010382f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103832:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0103836:	66 85 c0             	test   %ax,%ax
f0103839:	74 24                	je     f010385f <check_page+0xc80>
f010383b:	c7 44 24 0c 1a 9a 10 	movl   $0xf0109a1a,0xc(%esp)
f0103842:	f0 
f0103843:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f010384a:	f0 
f010384b:	c7 44 24 04 3b 04 00 	movl   $0x43b,0x4(%esp)
f0103852:	00 
f0103853:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010385a:	e8 98 ca ff ff       	call   f01002f7 <_panic>
	assert(pp2->pp_ref == 0);
f010385f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103862:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0103866:	66 85 c0             	test   %ax,%ax
f0103869:	74 24                	je     f010388f <check_page+0xcb0>
f010386b:	c7 44 24 0c 41 99 10 	movl   $0xf0109941,0xc(%esp)
f0103872:	f0 
f0103873:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f010387a:	f0 
f010387b:	c7 44 24 04 3c 04 00 	movl   $0x43c,0x4(%esp)
f0103882:	00 
f0103883:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010388a:	e8 68 ca ff ff       	call   f01002f7 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010388f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103896:	e8 27 df ff ff       	call   f01017c2 <page_alloc>
f010389b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010389e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01038a2:	74 08                	je     f01038ac <check_page+0xccd>
f01038a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01038a7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f01038aa:	74 24                	je     f01038d0 <check_page+0xcf1>
f01038ac:	c7 44 24 0c 2c 9a 10 	movl   $0xf0109a2c,0xc(%esp)
f01038b3:	f0 
f01038b4:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01038bb:	f0 
f01038bc:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f01038c3:	00 
f01038c4:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01038cb:	e8 27 ca ff ff       	call   f01002f7 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01038d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01038d7:	e8 e6 de ff ff       	call   f01017c2 <page_alloc>
f01038dc:	85 c0                	test   %eax,%eax
f01038de:	74 24                	je     f0103904 <check_page+0xd25>
f01038e0:	c7 44 24 0c d7 93 10 	movl   $0xf01093d7,0xc(%esp)
f01038e7:	f0 
f01038e8:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01038ef:	f0 
f01038f0:	c7 44 24 04 42 04 00 	movl   $0x442,0x4(%esp)
f01038f7:	00 
f01038f8:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01038ff:	e8 f3 c9 ff ff       	call   f01002f7 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103904:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0103909:	8b 00                	mov    (%eax),%eax
f010390b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103910:	89 c3                	mov    %eax,%ebx
f0103912:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103915:	89 04 24             	mov    %eax,(%esp)
f0103918:	e8 11 d8 ff ff       	call   f010112e <page2pa>
f010391d:	39 c3                	cmp    %eax,%ebx
f010391f:	74 24                	je     f0103945 <check_page+0xd66>
f0103921:	c7 44 24 0c 30 96 10 	movl   $0xf0109630,0xc(%esp)
f0103928:	f0 
f0103929:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103930:	f0 
f0103931:	c7 44 24 04 45 04 00 	movl   $0x445,0x4(%esp)
f0103938:	00 
f0103939:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103940:	e8 b2 c9 ff ff       	call   f01002f7 <_panic>
	kern_pgdir[0] = 0;
f0103945:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f010394a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103950:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103953:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0103957:	66 83 f8 01          	cmp    $0x1,%ax
f010395b:	74 24                	je     f0103981 <check_page+0xda2>
f010395d:	c7 44 24 0c 85 96 10 	movl   $0xf0109685,0xc(%esp)
f0103964:	f0 
f0103965:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f010396c:	f0 
f010396d:	c7 44 24 04 47 04 00 	movl   $0x447,0x4(%esp)
f0103974:	00 
f0103975:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010397c:	e8 76 c9 ff ff       	call   f01002f7 <_panic>
	pp0->pp_ref = 0;
f0103981:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103984:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010398a:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010398d:	89 04 24             	mov    %eax,(%esp)
f0103990:	e8 92 de ff ff       	call   f0101827 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
f0103995:	c7 45 dc 00 10 40 00 	movl   $0x401000,-0x24(%ebp)
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010399c:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f01039a1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01039a8:	00 
f01039a9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01039ac:	89 54 24 04          	mov    %edx,0x4(%esp)
f01039b0:	89 04 24             	mov    %eax,(%esp)
f01039b3:	e8 07 df ff ff       	call   f01018bf <pgdir_walk>
f01039b8:	89 45 cc             	mov    %eax,-0x34(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01039bb:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f01039c0:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01039c3:	c1 ea 16             	shr    $0x16,%edx
f01039c6:	c1 e2 02             	shl    $0x2,%edx
f01039c9:	01 d0                	add    %edx,%eax
f01039cb:	8b 00                	mov    (%eax),%eax
f01039cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01039d2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039d6:	c7 44 24 04 4e 04 00 	movl   $0x44e,0x4(%esp)
f01039dd:	00 
f01039de:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01039e5:	e8 02 d7 ff ff       	call   f01010ec <_kaddr>
f01039ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
	assert(ptep == ptep1 + PTX(va));
f01039ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01039f0:	c1 e8 0c             	shr    $0xc,%eax
f01039f3:	25 ff 03 00 00       	and    $0x3ff,%eax
f01039f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01039ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103a02:	01 c2                	add    %eax,%edx
f0103a04:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103a07:	39 c2                	cmp    %eax,%edx
f0103a09:	74 24                	je     f0103a2f <check_page+0xe50>
f0103a0b:	c7 44 24 0c 4e 9a 10 	movl   $0xf0109a4e,0xc(%esp)
f0103a12:	f0 
f0103a13:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103a1a:	f0 
f0103a1b:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f0103a22:	00 
f0103a23:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103a2a:	e8 c8 c8 ff ff       	call   f01002f7 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0103a2f:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0103a34:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103a37:	c1 ea 16             	shr    $0x16,%edx
f0103a3a:	c1 e2 02             	shl    $0x2,%edx
f0103a3d:	01 d0                	add    %edx,%eax
f0103a3f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0103a45:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103a48:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0103a4e:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103a51:	89 04 24             	mov    %eax,(%esp)
f0103a54:	e8 31 d7 ff ff       	call   f010118a <page2kva>
f0103a59:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103a60:	00 
f0103a61:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0103a68:	00 
f0103a69:	89 04 24             	mov    %eax,(%esp)
f0103a6c:	e8 8b 40 00 00       	call   f0107afc <memset>
	page_free(pp0);
f0103a71:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103a74:	89 04 24             	mov    %eax,(%esp)
f0103a77:	e8 ab dd ff ff       	call   f0101827 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0103a7c:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0103a81:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103a88:	00 
f0103a89:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103a90:	00 
f0103a91:	89 04 24             	mov    %eax,(%esp)
f0103a94:	e8 26 de ff ff       	call   f01018bf <pgdir_walk>
	ptep = (pte_t *) page2kva(pp0);
f0103a99:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103a9c:	89 04 24             	mov    %eax,(%esp)
f0103a9f:	e8 e6 d6 ff ff       	call   f010118a <page2kva>
f0103aa4:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for(i=0; i<NPTENTRIES; i++)
f0103aa7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0103aae:	eb 3c                	jmp    f0103aec <check_page+0xf0d>
		assert((ptep[i] & PTE_P) == 0);
f0103ab0:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103ab3:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103ab6:	c1 e2 02             	shl    $0x2,%edx
f0103ab9:	01 d0                	add    %edx,%eax
f0103abb:	8b 00                	mov    (%eax),%eax
f0103abd:	83 e0 01             	and    $0x1,%eax
f0103ac0:	85 c0                	test   %eax,%eax
f0103ac2:	74 24                	je     f0103ae8 <check_page+0xf09>
f0103ac4:	c7 44 24 0c 66 9a 10 	movl   $0xf0109a66,0xc(%esp)
f0103acb:	f0 
f0103acc:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103ad3:	f0 
f0103ad4:	c7 44 24 04 59 04 00 	movl   $0x459,0x4(%esp)
f0103adb:	00 
f0103adc:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103ae3:	e8 0f c8 ff ff       	call   f01002f7 <_panic>
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0103ae8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0103aec:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
f0103af3:	7e bb                	jle    f0103ab0 <check_page+0xed1>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0103af5:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0103afa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0103b00:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103b03:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0103b09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b0c:	a3 30 b2 23 f0       	mov    %eax,0xf023b230

	// free the pages we took
	page_free(pp0);
f0103b11:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103b14:	89 04 24             	mov    %eax,(%esp)
f0103b17:	e8 0b dd ff ff       	call   f0101827 <page_free>
	page_free(pp1);
f0103b1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103b1f:	89 04 24             	mov    %eax,(%esp)
f0103b22:	e8 00 dd ff ff       	call   f0101827 <page_free>
	page_free(pp2);
f0103b27:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103b2a:	89 04 24             	mov    %eax,(%esp)
f0103b2d:	e8 f5 dc ff ff       	call   f0101827 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0103b32:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0103b39:	00 
f0103b3a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103b41:	e8 df e0 ff ff       	call   f0101c25 <mmio_map_region>
f0103b46:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0103b49:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103b50:	00 
f0103b51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103b58:	e8 c8 e0 ff ff       	call   f0101c25 <mmio_map_region>
f0103b5d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0103b60:	81 7d d4 ff ff 7f ef 	cmpl   $0xef7fffff,-0x2c(%ebp)
f0103b67:	76 0f                	jbe    f0103b78 <check_page+0xf99>
f0103b69:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103b6c:	05 a0 1f 00 00       	add    $0x1fa0,%eax
f0103b71:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0103b76:	76 24                	jbe    f0103b9c <check_page+0xfbd>
f0103b78:	c7 44 24 0c 80 9a 10 	movl   $0xf0109a80,0xc(%esp)
f0103b7f:	f0 
f0103b80:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103b87:	f0 
f0103b88:	c7 44 24 04 69 04 00 	movl   $0x469,0x4(%esp)
f0103b8f:	00 
f0103b90:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103b97:	e8 5b c7 ff ff       	call   f01002f7 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0103b9c:	81 7d d0 ff ff 7f ef 	cmpl   $0xef7fffff,-0x30(%ebp)
f0103ba3:	76 0f                	jbe    f0103bb4 <check_page+0xfd5>
f0103ba5:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103ba8:	05 a0 1f 00 00       	add    $0x1fa0,%eax
f0103bad:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0103bb2:	76 24                	jbe    f0103bd8 <check_page+0xff9>
f0103bb4:	c7 44 24 0c a8 9a 10 	movl   $0xf0109aa8,0xc(%esp)
f0103bbb:	f0 
f0103bbc:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103bc3:	f0 
f0103bc4:	c7 44 24 04 6a 04 00 	movl   $0x46a,0x4(%esp)
f0103bcb:	00 
f0103bcc:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103bd3:	e8 1f c7 ff ff       	call   f01002f7 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0103bd8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103bdb:	25 ff 0f 00 00       	and    $0xfff,%eax
f0103be0:	85 c0                	test   %eax,%eax
f0103be2:	75 0c                	jne    f0103bf0 <check_page+0x1011>
f0103be4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103be7:	25 ff 0f 00 00       	and    $0xfff,%eax
f0103bec:	85 c0                	test   %eax,%eax
f0103bee:	74 24                	je     f0103c14 <check_page+0x1035>
f0103bf0:	c7 44 24 0c d0 9a 10 	movl   $0xf0109ad0,0xc(%esp)
f0103bf7:	f0 
f0103bf8:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103bff:	f0 
f0103c00:	c7 44 24 04 6c 04 00 	movl   $0x46c,0x4(%esp)
f0103c07:	00 
f0103c08:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103c0f:	e8 e3 c6 ff ff       	call   f01002f7 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0103c14:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103c17:	05 a0 1f 00 00       	add    $0x1fa0,%eax
f0103c1c:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0103c1f:	76 24                	jbe    f0103c45 <check_page+0x1066>
f0103c21:	c7 44 24 0c f7 9a 10 	movl   $0xf0109af7,0xc(%esp)
f0103c28:	f0 
f0103c29:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103c30:	f0 
f0103c31:	c7 44 24 04 6e 04 00 	movl   $0x46e,0x4(%esp)
f0103c38:	00 
f0103c39:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103c40:	e8 b2 c6 ff ff       	call   f01002f7 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0103c45:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0103c4a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103c4d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103c51:	89 04 24             	mov    %eax,(%esp)
f0103c54:	e8 f5 ee ff ff       	call   f0102b4e <check_va2pa>
f0103c59:	85 c0                	test   %eax,%eax
f0103c5b:	74 24                	je     f0103c81 <check_page+0x10a2>
f0103c5d:	c7 44 24 0c 0c 9b 10 	movl   $0xf0109b0c,0xc(%esp)
f0103c64:	f0 
f0103c65:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103c6c:	f0 
f0103c6d:	c7 44 24 04 70 04 00 	movl   $0x470,0x4(%esp)
f0103c74:	00 
f0103c75:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103c7c:	e8 76 c6 ff ff       	call   f01002f7 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0103c81:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103c84:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
f0103c8a:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0103c8f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103c93:	89 04 24             	mov    %eax,(%esp)
f0103c96:	e8 b3 ee ff ff       	call   f0102b4e <check_va2pa>
f0103c9b:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103ca0:	74 24                	je     f0103cc6 <check_page+0x10e7>
f0103ca2:	c7 44 24 0c 30 9b 10 	movl   $0xf0109b30,0xc(%esp)
f0103ca9:	f0 
f0103caa:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103cb1:	f0 
f0103cb2:	c7 44 24 04 71 04 00 	movl   $0x471,0x4(%esp)
f0103cb9:	00 
f0103cba:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103cc1:	e8 31 c6 ff ff       	call   f01002f7 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0103cc6:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0103ccb:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103cce:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103cd2:	89 04 24             	mov    %eax,(%esp)
f0103cd5:	e8 74 ee ff ff       	call   f0102b4e <check_va2pa>
f0103cda:	85 c0                	test   %eax,%eax
f0103cdc:	74 24                	je     f0103d02 <check_page+0x1123>
f0103cde:	c7 44 24 0c 60 9b 10 	movl   $0xf0109b60,0xc(%esp)
f0103ce5:	f0 
f0103ce6:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103ced:	f0 
f0103cee:	c7 44 24 04 72 04 00 	movl   $0x472,0x4(%esp)
f0103cf5:	00 
f0103cf6:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103cfd:	e8 f5 c5 ff ff       	call   f01002f7 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0103d02:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103d05:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
f0103d0b:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0103d10:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103d14:	89 04 24             	mov    %eax,(%esp)
f0103d17:	e8 32 ee ff ff       	call   f0102b4e <check_va2pa>
f0103d1c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103d1f:	74 24                	je     f0103d45 <check_page+0x1166>
f0103d21:	c7 44 24 0c 84 9b 10 	movl   $0xf0109b84,0xc(%esp)
f0103d28:	f0 
f0103d29:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103d30:	f0 
f0103d31:	c7 44 24 04 73 04 00 	movl   $0x473,0x4(%esp)
f0103d38:	00 
f0103d39:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103d40:	e8 b2 c5 ff ff       	call   f01002f7 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0103d45:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103d48:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0103d4d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103d54:	00 
f0103d55:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103d59:	89 04 24             	mov    %eax,(%esp)
f0103d5c:	e8 5e db ff ff       	call   f01018bf <pgdir_walk>
f0103d61:	8b 00                	mov    (%eax),%eax
f0103d63:	83 e0 1a             	and    $0x1a,%eax
f0103d66:	85 c0                	test   %eax,%eax
f0103d68:	75 24                	jne    f0103d8e <check_page+0x11af>
f0103d6a:	c7 44 24 0c b0 9b 10 	movl   $0xf0109bb0,0xc(%esp)
f0103d71:	f0 
f0103d72:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103d79:	f0 
f0103d7a:	c7 44 24 04 75 04 00 	movl   $0x475,0x4(%esp)
f0103d81:	00 
f0103d82:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103d89:	e8 69 c5 ff ff       	call   f01002f7 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0103d8e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103d91:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0103d96:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103d9d:	00 
f0103d9e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103da2:	89 04 24             	mov    %eax,(%esp)
f0103da5:	e8 15 db ff ff       	call   f01018bf <pgdir_walk>
f0103daa:	8b 00                	mov    (%eax),%eax
f0103dac:	83 e0 04             	and    $0x4,%eax
f0103daf:	85 c0                	test   %eax,%eax
f0103db1:	74 24                	je     f0103dd7 <check_page+0x11f8>
f0103db3:	c7 44 24 0c f4 9b 10 	movl   $0xf0109bf4,0xc(%esp)
f0103dba:	f0 
f0103dbb:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103dc2:	f0 
f0103dc3:	c7 44 24 04 76 04 00 	movl   $0x476,0x4(%esp)
f0103dca:	00 
f0103dcb:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103dd2:	e8 20 c5 ff ff       	call   f01002f7 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0103dd7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103dda:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0103ddf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103de6:	00 
f0103de7:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103deb:	89 04 24             	mov    %eax,(%esp)
f0103dee:	e8 cc da ff ff       	call   f01018bf <pgdir_walk>
f0103df3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0103df9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103dfc:	05 00 10 00 00       	add    $0x1000,%eax
f0103e01:	89 c2                	mov    %eax,%edx
f0103e03:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0103e08:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103e0f:	00 
f0103e10:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103e14:	89 04 24             	mov    %eax,(%esp)
f0103e17:	e8 a3 da ff ff       	call   f01018bf <pgdir_walk>
f0103e1c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0103e22:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103e25:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0103e2a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103e31:	00 
f0103e32:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103e36:	89 04 24             	mov    %eax,(%esp)
f0103e39:	e8 81 da ff ff       	call   f01018bf <pgdir_walk>
f0103e3e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0103e44:	c7 04 24 27 9c 10 f0 	movl   $0xf0109c27,(%esp)
f0103e4b:	e8 6f 11 00 00       	call   f0104fbf <cprintf>
}
f0103e50:	83 c4 44             	add    $0x44,%esp
f0103e53:	5b                   	pop    %ebx
f0103e54:	5d                   	pop    %ebp
f0103e55:	c3                   	ret    

f0103e56 <check_page_installed_pgdir>:

// check page_insert, page_remove, &c, with an installed kern_pgdir
static void
check_page_installed_pgdir(void)
{
f0103e56:	55                   	push   %ebp
f0103e57:	89 e5                	mov    %esp,%ebp
f0103e59:	53                   	push   %ebx
f0103e5a:	83 ec 24             	sub    $0x24,%esp
	pte_t *ptep, *ptep1;
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
f0103e5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0103e64:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103e67:	89 45 f0             	mov    %eax,-0x10(%ebp)
	assert((pp0 = page_alloc(0)));
f0103e6a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103e71:	e8 4c d9 ff ff       	call   f01017c2 <page_alloc>
f0103e76:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103e79:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0103e7d:	75 24                	jne    f0103ea3 <check_page_installed_pgdir+0x4d>
f0103e7f:	c7 44 24 0c 08 93 10 	movl   $0xf0109308,0xc(%esp)
f0103e86:	f0 
f0103e87:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103e8e:	f0 
f0103e8f:	c7 44 24 04 8b 04 00 	movl   $0x48b,0x4(%esp)
f0103e96:	00 
f0103e97:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103e9e:	e8 54 c4 ff ff       	call   f01002f7 <_panic>
	assert((pp1 = page_alloc(0)));
f0103ea3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103eaa:	e8 13 d9 ff ff       	call   f01017c2 <page_alloc>
f0103eaf:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103eb2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0103eb6:	75 24                	jne    f0103edc <check_page_installed_pgdir+0x86>
f0103eb8:	c7 44 24 0c 1e 93 10 	movl   $0xf010931e,0xc(%esp)
f0103ebf:	f0 
f0103ec0:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103ec7:	f0 
f0103ec8:	c7 44 24 04 8c 04 00 	movl   $0x48c,0x4(%esp)
f0103ecf:	00 
f0103ed0:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103ed7:	e8 1b c4 ff ff       	call   f01002f7 <_panic>
	assert((pp2 = page_alloc(0)));
f0103edc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103ee3:	e8 da d8 ff ff       	call   f01017c2 <page_alloc>
f0103ee8:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0103eeb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0103eef:	75 24                	jne    f0103f15 <check_page_installed_pgdir+0xbf>
f0103ef1:	c7 44 24 0c 34 93 10 	movl   $0xf0109334,0xc(%esp)
f0103ef8:	f0 
f0103ef9:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103f00:	f0 
f0103f01:	c7 44 24 04 8d 04 00 	movl   $0x48d,0x4(%esp)
f0103f08:	00 
f0103f09:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103f10:	e8 e2 c3 ff ff       	call   f01002f7 <_panic>
	page_free(pp0);
f0103f15:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103f18:	89 04 24             	mov    %eax,(%esp)
f0103f1b:	e8 07 d9 ff ff       	call   f0101827 <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f0103f20:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103f23:	89 04 24             	mov    %eax,(%esp)
f0103f26:	e8 5f d2 ff ff       	call   f010118a <page2kva>
f0103f2b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103f32:	00 
f0103f33:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103f3a:	00 
f0103f3b:	89 04 24             	mov    %eax,(%esp)
f0103f3e:	e8 b9 3b 00 00       	call   f0107afc <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0103f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f46:	89 04 24             	mov    %eax,(%esp)
f0103f49:	e8 3c d2 ff ff       	call   f010118a <page2kva>
f0103f4e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103f55:	00 
f0103f56:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103f5d:	00 
f0103f5e:	89 04 24             	mov    %eax,(%esp)
f0103f61:	e8 96 3b 00 00       	call   f0107afc <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103f66:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0103f6b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103f72:	00 
f0103f73:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103f7a:	00 
f0103f7b:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103f7e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103f82:	89 04 24             	mov    %eax,(%esp)
f0103f85:	e8 de da ff ff       	call   f0101a68 <page_insert>
	assert(pp1->pp_ref == 1);
f0103f8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103f8d:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0103f91:	66 83 f8 01          	cmp    $0x1,%ax
f0103f95:	74 24                	je     f0103fbb <check_page_installed_pgdir+0x165>
f0103f97:	c7 44 24 0c 96 96 10 	movl   $0xf0109696,0xc(%esp)
f0103f9e:	f0 
f0103f9f:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103fa6:	f0 
f0103fa7:	c7 44 24 04 92 04 00 	movl   $0x492,0x4(%esp)
f0103fae:	00 
f0103faf:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103fb6:	e8 3c c3 ff ff       	call   f01002f7 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103fbb:	b8 00 10 00 00       	mov    $0x1000,%eax
f0103fc0:	8b 00                	mov    (%eax),%eax
f0103fc2:	3d 01 01 01 01       	cmp    $0x1010101,%eax
f0103fc7:	74 24                	je     f0103fed <check_page_installed_pgdir+0x197>
f0103fc9:	c7 44 24 0c 40 9c 10 	movl   $0xf0109c40,0xc(%esp)
f0103fd0:	f0 
f0103fd1:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0103fd8:	f0 
f0103fd9:	c7 44 24 04 93 04 00 	movl   $0x493,0x4(%esp)
f0103fe0:	00 
f0103fe1:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0103fe8:	e8 0a c3 ff ff       	call   f01002f7 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0103fed:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0103ff2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103ff9:	00 
f0103ffa:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0104001:	00 
f0104002:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104005:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104009:	89 04 24             	mov    %eax,(%esp)
f010400c:	e8 57 da ff ff       	call   f0101a68 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0104011:	b8 00 10 00 00       	mov    $0x1000,%eax
f0104016:	8b 00                	mov    (%eax),%eax
f0104018:	3d 02 02 02 02       	cmp    $0x2020202,%eax
f010401d:	74 24                	je     f0104043 <check_page_installed_pgdir+0x1ed>
f010401f:	c7 44 24 0c 64 9c 10 	movl   $0xf0109c64,0xc(%esp)
f0104026:	f0 
f0104027:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f010402e:	f0 
f010402f:	c7 44 24 04 95 04 00 	movl   $0x495,0x4(%esp)
f0104036:	00 
f0104037:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010403e:	e8 b4 c2 ff ff       	call   f01002f7 <_panic>
	assert(pp2->pp_ref == 1);
f0104043:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104046:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f010404a:	66 83 f8 01          	cmp    $0x1,%ax
f010404e:	74 24                	je     f0104074 <check_page_installed_pgdir+0x21e>
f0104050:	c7 44 24 0c 14 97 10 	movl   $0xf0109714,0xc(%esp)
f0104057:	f0 
f0104058:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f010405f:	f0 
f0104060:	c7 44 24 04 96 04 00 	movl   $0x496,0x4(%esp)
f0104067:	00 
f0104068:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010406f:	e8 83 c2 ff ff       	call   f01002f7 <_panic>
	assert(pp1->pp_ref == 0);
f0104074:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104077:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f010407b:	66 85 c0             	test   %ax,%ax
f010407e:	74 24                	je     f01040a4 <check_page_installed_pgdir+0x24e>
f0104080:	c7 44 24 0c 1a 9a 10 	movl   $0xf0109a1a,0xc(%esp)
f0104087:	f0 
f0104088:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f010408f:	f0 
f0104090:	c7 44 24 04 97 04 00 	movl   $0x497,0x4(%esp)
f0104097:	00 
f0104098:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f010409f:	e8 53 c2 ff ff       	call   f01002f7 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01040a4:	b8 00 10 00 00       	mov    $0x1000,%eax
f01040a9:	c7 00 03 03 03 03    	movl   $0x3030303,(%eax)
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01040af:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01040b2:	89 04 24             	mov    %eax,(%esp)
f01040b5:	e8 d0 d0 ff ff       	call   f010118a <page2kva>
f01040ba:	8b 00                	mov    (%eax),%eax
f01040bc:	3d 03 03 03 03       	cmp    $0x3030303,%eax
f01040c1:	74 24                	je     f01040e7 <check_page_installed_pgdir+0x291>
f01040c3:	c7 44 24 0c 88 9c 10 	movl   $0xf0109c88,0xc(%esp)
f01040ca:	f0 
f01040cb:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f01040d2:	f0 
f01040d3:	c7 44 24 04 99 04 00 	movl   $0x499,0x4(%esp)
f01040da:	00 
f01040db:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01040e2:	e8 10 c2 ff ff       	call   f01002f7 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01040e7:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f01040ec:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01040f3:	00 
f01040f4:	89 04 24             	mov    %eax,(%esp)
f01040f7:	e8 82 da ff ff       	call   f0101b7e <page_remove>
	assert(pp2->pp_ref == 0);
f01040fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01040ff:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0104103:	66 85 c0             	test   %ax,%ax
f0104106:	74 24                	je     f010412c <check_page_installed_pgdir+0x2d6>
f0104108:	c7 44 24 0c 41 99 10 	movl   $0xf0109941,0xc(%esp)
f010410f:	f0 
f0104110:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0104117:	f0 
f0104118:	c7 44 24 04 9b 04 00 	movl   $0x49b,0x4(%esp)
f010411f:	00 
f0104120:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0104127:	e8 cb c1 ff ff       	call   f01002f7 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010412c:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0104131:	8b 00                	mov    (%eax),%eax
f0104133:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104138:	89 c3                	mov    %eax,%ebx
f010413a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010413d:	89 04 24             	mov    %eax,(%esp)
f0104140:	e8 e9 cf ff ff       	call   f010112e <page2pa>
f0104145:	39 c3                	cmp    %eax,%ebx
f0104147:	74 24                	je     f010416d <check_page_installed_pgdir+0x317>
f0104149:	c7 44 24 0c 30 96 10 	movl   $0xf0109630,0xc(%esp)
f0104150:	f0 
f0104151:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0104158:	f0 
f0104159:	c7 44 24 04 9e 04 00 	movl   $0x49e,0x4(%esp)
f0104160:	00 
f0104161:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0104168:	e8 8a c1 ff ff       	call   f01002f7 <_panic>
	kern_pgdir[0] = 0;
f010416d:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0104172:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0104178:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010417b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f010417f:	66 83 f8 01          	cmp    $0x1,%ax
f0104183:	74 24                	je     f01041a9 <check_page_installed_pgdir+0x353>
f0104185:	c7 44 24 0c 85 96 10 	movl   $0xf0109685,0xc(%esp)
f010418c:	f0 
f010418d:	c7 44 24 08 a0 91 10 	movl   $0xf01091a0,0x8(%esp)
f0104194:	f0 
f0104195:	c7 44 24 04 a0 04 00 	movl   $0x4a0,0x4(%esp)
f010419c:	00 
f010419d:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f01041a4:	e8 4e c1 ff ff       	call   f01002f7 <_panic>
	pp0->pp_ref = 0;
f01041a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01041ac:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// free the pages we took
	page_free(pp0);
f01041b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01041b5:	89 04 24             	mov    %eax,(%esp)
f01041b8:	e8 6a d6 ff ff       	call   f0101827 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01041bd:	c7 04 24 b4 9c 10 f0 	movl   $0xf0109cb4,(%esp)
f01041c4:	e8 f6 0d 00 00       	call   f0104fbf <cprintf>
}
f01041c9:	83 c4 24             	add    $0x24,%esp
f01041cc:	5b                   	pop    %ebx
f01041cd:	5d                   	pop    %ebp
f01041ce:	c3                   	ret    

f01041cf <lgdt>:
	__asm __volatile("lidt (%0)" : : "r" (p));
}

static __inline void
lgdt(void *p)
{
f01041cf:	55                   	push   %ebp
f01041d0:	89 e5                	mov    %esp,%ebp
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01041d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01041d5:	0f 01 10             	lgdtl  (%eax)
}
f01041d8:	5d                   	pop    %ebp
f01041d9:	c3                   	ret    

f01041da <_paddr>:
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f01041da:	55                   	push   %ebp
f01041db:	89 e5                	mov    %esp,%ebp
f01041dd:	83 ec 18             	sub    $0x18,%esp
	if ((uint32_t)kva < KERNBASE)
f01041e0:	8b 45 10             	mov    0x10(%ebp),%eax
f01041e3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01041e8:	77 21                	ja     f010420b <_paddr+0x31>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01041ea:	8b 45 10             	mov    0x10(%ebp),%eax
f01041ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01041f1:	c7 44 24 08 e0 9c 10 	movl   $0xf0109ce0,0x8(%esp)
f01041f8:	f0 
f01041f9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01041fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104200:	8b 45 08             	mov    0x8(%ebp),%eax
f0104203:	89 04 24             	mov    %eax,(%esp)
f0104206:	e8 ec c0 ff ff       	call   f01002f7 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010420b:	8b 45 10             	mov    0x10(%ebp),%eax
f010420e:	05 00 00 00 10       	add    $0x10000000,%eax
}
f0104213:	c9                   	leave  
f0104214:	c3                   	ret    

f0104215 <_kaddr>:
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f0104215:	55                   	push   %ebp
f0104216:	89 e5                	mov    %esp,%ebp
f0104218:	83 ec 18             	sub    $0x18,%esp
	if (PGNUM(pa) >= npages)
f010421b:	8b 45 10             	mov    0x10(%ebp),%eax
f010421e:	c1 e8 0c             	shr    $0xc,%eax
f0104221:	89 c2                	mov    %eax,%edx
f0104223:	a1 e8 be 23 f0       	mov    0xf023bee8,%eax
f0104228:	39 c2                	cmp    %eax,%edx
f010422a:	72 21                	jb     f010424d <_kaddr+0x38>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010422c:	8b 45 10             	mov    0x10(%ebp),%eax
f010422f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104233:	c7 44 24 08 04 9d 10 	movl   $0xf0109d04,0x8(%esp)
f010423a:	f0 
f010423b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010423e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104242:	8b 45 08             	mov    0x8(%ebp),%eax
f0104245:	89 04 24             	mov    %eax,(%esp)
f0104248:	e8 aa c0 ff ff       	call   f01002f7 <_panic>
	return (void *)(pa + KERNBASE);
f010424d:	8b 45 10             	mov    0x10(%ebp),%eax
f0104250:	2d 00 00 00 10       	sub    $0x10000000,%eax
}
f0104255:	c9                   	leave  
f0104256:	c3                   	ret    

f0104257 <page2pa>:
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
f0104257:	55                   	push   %ebp
f0104258:	89 e5                	mov    %esp,%ebp
	return (pp - pages) << PGSHIFT;
f010425a:	8b 55 08             	mov    0x8(%ebp),%edx
f010425d:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f0104262:	29 c2                	sub    %eax,%edx
f0104264:	89 d0                	mov    %edx,%eax
f0104266:	c1 f8 03             	sar    $0x3,%eax
f0104269:	c1 e0 0c             	shl    $0xc,%eax
}
f010426c:	5d                   	pop    %ebp
f010426d:	c3                   	ret    

f010426e <pa2page>:

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
f010426e:	55                   	push   %ebp
f010426f:	89 e5                	mov    %esp,%ebp
f0104271:	83 ec 18             	sub    $0x18,%esp
	if (PGNUM(pa) >= npages)
f0104274:	8b 45 08             	mov    0x8(%ebp),%eax
f0104277:	c1 e8 0c             	shr    $0xc,%eax
f010427a:	89 c2                	mov    %eax,%edx
f010427c:	a1 e8 be 23 f0       	mov    0xf023bee8,%eax
f0104281:	39 c2                	cmp    %eax,%edx
f0104283:	72 1c                	jb     f01042a1 <pa2page+0x33>
		panic("pa2page called with invalid pa");
f0104285:	c7 44 24 08 28 9d 10 	movl   $0xf0109d28,0x8(%esp)
f010428c:	f0 
f010428d:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0104294:	00 
f0104295:	c7 04 24 47 9d 10 f0 	movl   $0xf0109d47,(%esp)
f010429c:	e8 56 c0 ff ff       	call   f01002f7 <_panic>
	return &pages[PGNUM(pa)];
f01042a1:	a1 f0 be 23 f0       	mov    0xf023bef0,%eax
f01042a6:	8b 55 08             	mov    0x8(%ebp),%edx
f01042a9:	c1 ea 0c             	shr    $0xc,%edx
f01042ac:	c1 e2 03             	shl    $0x3,%edx
f01042af:	01 d0                	add    %edx,%eax
}
f01042b1:	c9                   	leave  
f01042b2:	c3                   	ret    

f01042b3 <page2kva>:

static inline void*
page2kva(struct PageInfo *pp)
{
f01042b3:	55                   	push   %ebp
f01042b4:	89 e5                	mov    %esp,%ebp
f01042b6:	83 ec 18             	sub    $0x18,%esp
	return KADDR(page2pa(pp));
f01042b9:	8b 45 08             	mov    0x8(%ebp),%eax
f01042bc:	89 04 24             	mov    %eax,(%esp)
f01042bf:	e8 93 ff ff ff       	call   f0104257 <page2pa>
f01042c4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01042c8:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01042cf:	00 
f01042d0:	c7 04 24 47 9d 10 f0 	movl   $0xf0109d47,(%esp)
f01042d7:	e8 39 ff ff ff       	call   f0104215 <_kaddr>
}
f01042dc:	c9                   	leave  
f01042dd:	c3                   	ret    

f01042de <unlock_kernel>:

static inline void
unlock_kernel(void)
{
f01042de:	55                   	push   %ebp
f01042df:	89 e5                	mov    %esp,%ebp
f01042e1:	83 ec 18             	sub    $0x18,%esp
	spin_unlock(&kernel_lock);
f01042e4:	c7 04 24 e0 55 12 f0 	movl   $0xf01255e0,(%esp)
f01042eb:	e8 d9 45 00 00       	call   f01088c9 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01042f0:	f3 90                	pause  
}
f01042f2:	c9                   	leave  
f01042f3:	c3                   	ret    

f01042f4 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01042f4:	55                   	push   %ebp
f01042f5:	89 e5                	mov    %esp,%ebp
f01042f7:	53                   	push   %ebx
f01042f8:	83 ec 24             	sub    $0x24,%esp
f01042fb:	8b 45 10             	mov    0x10(%ebp),%eax
f01042fe:	88 45 e4             	mov    %al,-0x1c(%ebp)
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0104301:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0104305:	75 1e                	jne    f0104325 <envid2env+0x31>
		*env_store = curenv;
f0104307:	e8 ba 42 00 00       	call   f01085c6 <cpunum>
f010430c:	6b c0 74             	imul   $0x74,%eax,%eax
f010430f:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0104314:	8b 10                	mov    (%eax),%edx
f0104316:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104319:	89 10                	mov    %edx,(%eax)
		return 0;
f010431b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104320:	e9 97 00 00 00       	jmp    f01043bc <envid2env+0xc8>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0104325:	8b 15 3c b2 23 f0    	mov    0xf023b23c,%edx
f010432b:	8b 45 08             	mov    0x8(%ebp),%eax
f010432e:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104333:	c1 e0 02             	shl    $0x2,%eax
f0104336:	89 c1                	mov    %eax,%ecx
f0104338:	c1 e1 05             	shl    $0x5,%ecx
f010433b:	29 c1                	sub    %eax,%ecx
f010433d:	89 c8                	mov    %ecx,%eax
f010433f:	01 d0                	add    %edx,%eax
f0104341:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0104344:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104347:	8b 40 54             	mov    0x54(%eax),%eax
f010434a:	85 c0                	test   %eax,%eax
f010434c:	74 0b                	je     f0104359 <envid2env+0x65>
f010434e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104351:	8b 40 48             	mov    0x48(%eax),%eax
f0104354:	3b 45 08             	cmp    0x8(%ebp),%eax
f0104357:	74 10                	je     f0104369 <envid2env+0x75>
		*env_store = 0;
f0104359:	8b 45 0c             	mov    0xc(%ebp),%eax
f010435c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0104362:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104367:	eb 53                	jmp    f01043bc <envid2env+0xc8>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0104369:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
f010436d:	74 40                	je     f01043af <envid2env+0xbb>
f010436f:	e8 52 42 00 00       	call   f01085c6 <cpunum>
f0104374:	6b c0 74             	imul   $0x74,%eax,%eax
f0104377:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f010437c:	8b 00                	mov    (%eax),%eax
f010437e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0104381:	74 2c                	je     f01043af <envid2env+0xbb>
f0104383:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104386:	8b 58 4c             	mov    0x4c(%eax),%ebx
f0104389:	e8 38 42 00 00       	call   f01085c6 <cpunum>
f010438e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104391:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0104396:	8b 00                	mov    (%eax),%eax
f0104398:	8b 40 48             	mov    0x48(%eax),%eax
f010439b:	39 c3                	cmp    %eax,%ebx
f010439d:	74 10                	je     f01043af <envid2env+0xbb>
		*env_store = 0;
f010439f:	8b 45 0c             	mov    0xc(%ebp),%eax
f01043a2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01043a8:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01043ad:	eb 0d                	jmp    f01043bc <envid2env+0xc8>
	}

	*env_store = e;
f01043af:	8b 45 0c             	mov    0xc(%ebp),%eax
f01043b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01043b5:	89 10                	mov    %edx,(%eax)
	return 0;
f01043b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01043bc:	83 c4 24             	add    $0x24,%esp
f01043bf:	5b                   	pop    %ebx
f01043c0:	5d                   	pop    %ebp
f01043c1:	c3                   	ret    

f01043c2 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01043c2:	55                   	push   %ebp
f01043c3:	89 e5                	mov    %esp,%ebp
f01043c5:	53                   	push   %ebx
f01043c6:	83 ec 14             	sub    $0x14,%esp
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = 0;i < NENV; i++)
f01043c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f01043d0:	e9 bf 00 00 00       	jmp    f0104494 <env_init+0xd2>
	{
		envs[i].env_status = ENV_FREE;
f01043d5:	8b 15 3c b2 23 f0    	mov    0xf023b23c,%edx
f01043db:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01043de:	c1 e0 02             	shl    $0x2,%eax
f01043e1:	89 c1                	mov    %eax,%ecx
f01043e3:	c1 e1 05             	shl    $0x5,%ecx
f01043e6:	29 c1                	sub    %eax,%ecx
f01043e8:	89 c8                	mov    %ecx,%eax
f01043ea:	01 d0                	add    %edx,%eax
f01043ec:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f01043f3:	8b 15 3c b2 23 f0    	mov    0xf023b23c,%edx
f01043f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01043fc:	c1 e0 02             	shl    $0x2,%eax
f01043ff:	89 c1                	mov    %eax,%ecx
f0104401:	c1 e1 05             	shl    $0x5,%ecx
f0104404:	29 c1                	sub    %eax,%ecx
f0104406:	89 c8                	mov    %ecx,%eax
f0104408:	01 d0                	add    %edx,%eax
f010440a:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		if(i == 0)
f0104411:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0104415:	75 1e                	jne    f0104435 <env_init+0x73>
		{
			env_free_list = &envs[i];
f0104417:	8b 15 3c b2 23 f0    	mov    0xf023b23c,%edx
f010441d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104420:	c1 e0 02             	shl    $0x2,%eax
f0104423:	89 c1                	mov    %eax,%ecx
f0104425:	c1 e1 05             	shl    $0x5,%ecx
f0104428:	29 c1                	sub    %eax,%ecx
f010442a:	89 c8                	mov    %ecx,%eax
f010442c:	01 d0                	add    %edx,%eax
f010442e:	a3 40 b2 23 f0       	mov    %eax,0xf023b240
f0104433:	eb 34                	jmp    f0104469 <env_init+0xa7>
		}
		else
		{
			envs[i-1].env_link = &envs[i];
f0104435:	8b 15 3c b2 23 f0    	mov    0xf023b23c,%edx
f010443b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010443e:	c1 e0 02             	shl    $0x2,%eax
f0104441:	89 c1                	mov    %eax,%ecx
f0104443:	c1 e1 05             	shl    $0x5,%ecx
f0104446:	29 c1                	sub    %eax,%ecx
f0104448:	89 c8                	mov    %ecx,%eax
f010444a:	83 e8 7c             	sub    $0x7c,%eax
f010444d:	01 c2                	add    %eax,%edx
f010444f:	8b 0d 3c b2 23 f0    	mov    0xf023b23c,%ecx
f0104455:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104458:	c1 e0 02             	shl    $0x2,%eax
f010445b:	89 c3                	mov    %eax,%ebx
f010445d:	c1 e3 05             	shl    $0x5,%ebx
f0104460:	29 c3                	sub    %eax,%ebx
f0104462:	89 d8                	mov    %ebx,%eax
f0104464:	01 c8                	add    %ecx,%eax
f0104466:	89 42 44             	mov    %eax,0x44(%edx)
		}
		if( i == NENV - 1)
f0104469:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
f0104470:	75 1e                	jne    f0104490 <env_init+0xce>
		{
			envs[i].env_link = NULL;
f0104472:	8b 15 3c b2 23 f0    	mov    0xf023b23c,%edx
f0104478:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010447b:	c1 e0 02             	shl    $0x2,%eax
f010447e:	89 c1                	mov    %eax,%ecx
f0104480:	c1 e1 05             	shl    $0x5,%ecx
f0104483:	29 c1                	sub    %eax,%ecx
f0104485:	89 c8                	mov    %ecx,%eax
f0104487:	01 d0                	add    %edx,%eax
f0104489:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = 0;i < NENV; i++)
f0104490:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0104494:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
f010449b:	0f 8e 34 ff ff ff    	jle    f01043d5 <env_init+0x13>
			envs[i].env_link = NULL;
		}
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f01044a1:	e8 06 00 00 00       	call   f01044ac <env_init_percpu>
}
f01044a6:	83 c4 14             	add    $0x14,%esp
f01044a9:	5b                   	pop    %ebx
f01044aa:	5d                   	pop    %ebp
f01044ab:	c3                   	ret    

f01044ac <env_init_percpu>:

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01044ac:	55                   	push   %ebp
f01044ad:	89 e5                	mov    %esp,%ebp
f01044af:	83 ec 14             	sub    $0x14,%esp
	lgdt(&gdt_pd);
f01044b2:	c7 04 24 c8 55 12 f0 	movl   $0xf01255c8,(%esp)
f01044b9:	e8 11 fd ff ff       	call   f01041cf <lgdt>
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01044be:	b8 23 00 00 00       	mov    $0x23,%eax
f01044c3:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01044c5:	b8 23 00 00 00       	mov    $0x23,%eax
f01044ca:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01044cc:	b8 10 00 00 00       	mov    $0x10,%eax
f01044d1:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01044d3:	b8 10 00 00 00       	mov    $0x10,%eax
f01044d8:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01044da:	b8 10 00 00 00       	mov    $0x10,%eax
f01044df:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01044e1:	ea e8 44 10 f0 08 00 	ljmp   $0x8,$0xf01044e8
f01044e8:	66 c7 45 fe 00 00    	movw   $0x0,-0x2(%ebp)

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01044ee:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
f01044f2:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01044f5:	c9                   	leave  
f01044f6:	c3                   	ret    

f01044f7 <env_setup_vm>:
// Returns 0 on success, < 0 on error.  Errors include:
//	-E_NO_MEM if page directory or table could not be allocated.
//
static int
env_setup_vm(struct Env *e)
{
f01044f7:	55                   	push   %ebp
f01044f8:	89 e5                	mov    %esp,%ebp
f01044fa:	53                   	push   %ebx
f01044fb:	83 ec 24             	sub    $0x24,%esp
	int i;
	struct PageInfo *p = NULL;
f01044fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0104505:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010450c:	e8 b1 d2 ff ff       	call   f01017c2 <page_alloc>
f0104511:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0104514:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0104518:	75 07                	jne    f0104521 <env_setup_vm+0x2a>
		return -E_NO_MEM;
f010451a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010451f:	eb 76                	jmp    f0104597 <env_setup_vm+0xa0>
	//	is an exception- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref += 1;
f0104521:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104524:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0104528:	8d 50 01             	lea    0x1(%eax),%edx
f010452b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010452e:	66 89 50 04          	mov    %dx,0x4(%eax)
	e->env_pgdir = (pde_t *)page2kva(p);
f0104532:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104535:	89 04 24             	mov    %eax,(%esp)
f0104538:	e8 76 fd ff ff       	call   f01042b3 <page2kva>
f010453d:	8b 55 08             	mov    0x8(%ebp),%edx
f0104540:	89 42 60             	mov    %eax,0x60(%edx)
	
	memcpy(e->env_pgdir,kern_pgdir,PGSIZE);
f0104543:	8b 15 ec be 23 f0    	mov    0xf023beec,%edx
f0104549:	8b 45 08             	mov    0x8(%ebp),%eax
f010454c:	8b 40 60             	mov    0x60(%eax),%eax
f010454f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0104556:	00 
f0104557:	89 54 24 04          	mov    %edx,0x4(%esp)
f010455b:	89 04 24             	mov    %eax,(%esp)
f010455e:	e8 e1 36 00 00       	call   f0107c44 <memcpy>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0104563:	8b 45 08             	mov    0x8(%ebp),%eax
f0104566:	8b 40 60             	mov    0x60(%eax),%eax
f0104569:	8d 98 f4 0e 00 00    	lea    0xef4(%eax),%ebx
f010456f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104572:	8b 40 60             	mov    0x60(%eax),%eax
f0104575:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104579:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
f0104580:	00 
f0104581:	c7 04 24 55 9d 10 f0 	movl   $0xf0109d55,(%esp)
f0104588:	e8 4d fc ff ff       	call   f01041da <_paddr>
f010458d:	83 c8 05             	or     $0x5,%eax
f0104590:	89 03                	mov    %eax,(%ebx)

	return 0;
f0104592:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104597:	83 c4 24             	add    $0x24,%esp
f010459a:	5b                   	pop    %ebx
f010459b:	5d                   	pop    %ebp
f010459c:	c3                   	ret    

f010459d <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010459d:	55                   	push   %ebp
f010459e:	89 e5                	mov    %esp,%ebp
f01045a0:	53                   	push   %ebx
f01045a1:	83 ec 24             	sub    $0x24,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01045a4:	a1 40 b2 23 f0       	mov    0xf023b240,%eax
f01045a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01045ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f01045b0:	75 0a                	jne    f01045bc <env_alloc+0x1f>
		return -E_NO_FREE_ENV;
f01045b2:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01045b7:	e9 4c 01 00 00       	jmp    f0104708 <env_alloc+0x16b>

	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
f01045bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01045bf:	89 04 24             	mov    %eax,(%esp)
f01045c2:	e8 30 ff ff ff       	call   f01044f7 <env_setup_vm>
f01045c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01045ca:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01045ce:	79 08                	jns    f01045d8 <env_alloc+0x3b>
		return r;
f01045d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01045d3:	e9 30 01 00 00       	jmp    f0104708 <env_alloc+0x16b>

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01045d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01045db:	8b 40 48             	mov    0x48(%eax),%eax
f01045de:	05 00 10 00 00       	add    $0x1000,%eax
f01045e3:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01045e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (generation <= 0)	// Don't create a negative env_id.
f01045eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f01045ef:	7f 07                	jg     f01045f8 <env_alloc+0x5b>
		generation = 1 << ENVGENSHIFT;
f01045f1:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
	e->env_id = generation | (e - envs);
f01045f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01045fb:	a1 3c b2 23 f0       	mov    0xf023b23c,%eax
f0104600:	29 c2                	sub    %eax,%edx
f0104602:	89 d0                	mov    %edx,%eax
f0104604:	c1 f8 02             	sar    $0x2,%eax
f0104607:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
f010460d:	0b 45 f4             	or     -0xc(%ebp),%eax
f0104610:	89 c2                	mov    %eax,%edx
f0104612:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104615:	89 50 48             	mov    %edx,0x48(%eax)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0104618:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010461b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010461e:	89 50 4c             	mov    %edx,0x4c(%eax)
	e->env_type = ENV_TYPE_USER;
f0104621:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104624:	c7 40 50 00 00 00 00 	movl   $0x0,0x50(%eax)
	e->env_status = ENV_RUNNABLE;
f010462b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010462e:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	e->env_runs = 0;
f0104635:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104638:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010463f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104642:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0104649:	00 
f010464a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104651:	00 
f0104652:	89 04 24             	mov    %eax,(%esp)
f0104655:	e8 a2 34 00 00       	call   f0107afc <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010465a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010465d:	66 c7 40 24 23 00    	movw   $0x23,0x24(%eax)
	e->env_tf.tf_es = GD_UD | 3;
f0104663:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104666:	66 c7 40 20 23 00    	movw   $0x23,0x20(%eax)
	e->env_tf.tf_ss = GD_UD | 3;
f010466c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010466f:	66 c7 40 40 23 00    	movw   $0x23,0x40(%eax)
	e->env_tf.tf_esp = USTACKTOP;
f0104675:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104678:	c7 40 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%eax)
	e->env_tf.tf_cs = GD_UT | 3;
f010467f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104682:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0104688:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010468b:	8b 40 38             	mov    0x38(%eax),%eax
f010468e:	80 cc 02             	or     $0x2,%ah
f0104691:	89 c2                	mov    %eax,%edx
f0104693:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104696:	89 50 38             	mov    %edx,0x38(%eax)
	// e->env_tf.tf_eflags |= FL_IF;

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0104699:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010469c:	c7 40 64 00 00 00 00 	movl   $0x0,0x64(%eax)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01046a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01046a6:	c6 40 68 00          	movb   $0x0,0x68(%eax)

	// commit the allocation
	env_free_list = e->env_link;
f01046aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01046ad:	8b 40 44             	mov    0x44(%eax),%eax
f01046b0:	a3 40 b2 23 f0       	mov    %eax,0xf023b240
	*newenv_store = e;
f01046b5:	8b 45 08             	mov    0x8(%ebp),%eax
f01046b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01046bb:	89 10                	mov    %edx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01046bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01046c0:	8b 58 48             	mov    0x48(%eax),%ebx
f01046c3:	e8 fe 3e 00 00       	call   f01085c6 <cpunum>
f01046c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01046cb:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f01046d0:	8b 00                	mov    (%eax),%eax
f01046d2:	85 c0                	test   %eax,%eax
f01046d4:	74 14                	je     f01046ea <env_alloc+0x14d>
f01046d6:	e8 eb 3e 00 00       	call   f01085c6 <cpunum>
f01046db:	6b c0 74             	imul   $0x74,%eax,%eax
f01046de:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f01046e3:	8b 00                	mov    (%eax),%eax
f01046e5:	8b 40 48             	mov    0x48(%eax),%eax
f01046e8:	eb 05                	jmp    f01046ef <env_alloc+0x152>
f01046ea:	b8 00 00 00 00       	mov    $0x0,%eax
f01046ef:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01046f3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046f7:	c7 04 24 60 9d 10 f0 	movl   $0xf0109d60,(%esp)
f01046fe:	e8 bc 08 00 00       	call   f0104fbf <cprintf>
	return 0;
f0104703:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104708:	83 c4 24             	add    $0x24,%esp
f010470b:	5b                   	pop    %ebx
f010470c:	5d                   	pop    %ebp
f010470d:	c3                   	ret    

f010470e <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010470e:	55                   	push   %ebp
f010470f:	89 e5                	mov    %esp,%ebp
f0104711:	83 ec 38             	sub    $0x38,%esp
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	uintptr_t start = ROUNDDOWN((uintptr_t)va, PGSIZE);
f0104714:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104717:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010471a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010471d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104722:	89 45 ec             	mov    %eax,-0x14(%ebp)
	uintptr_t end = ROUNDUP((uintptr_t)va + (uintptr_t)len, PGSIZE);
f0104725:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
f010472c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010472f:	8b 45 10             	mov    0x10(%ebp),%eax
f0104732:	01 c2                	add    %eax,%edx
f0104734:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104737:	01 d0                	add    %edx,%eax
f0104739:	83 e8 01             	sub    $0x1,%eax
f010473c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010473f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104742:	ba 00 00 00 00       	mov    $0x0,%edx
f0104747:	f7 75 e8             	divl   -0x18(%ebp)
f010474a:	89 d0                	mov    %edx,%eax
f010474c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010474f:	29 c2                	sub    %eax,%edx
f0104751:	89 d0                	mov    %edx,%eax
f0104753:	89 45 e0             	mov    %eax,-0x20(%ebp)
	uintptr_t i;
	for(i = start;i<end;i+=PGSIZE)
f0104756:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104759:	89 45 f4             	mov    %eax,-0xc(%ebp)
f010475c:	e9 81 00 00 00       	jmp    f01047e2 <region_alloc+0xd4>
	{
		struct PageInfo *pg = page_alloc(0);
f0104761:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104768:	e8 55 d0 ff ff       	call   f01017c2 <page_alloc>
f010476d:	89 45 dc             	mov    %eax,-0x24(%ebp)
		if(pg == NULL)
f0104770:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104774:	75 1c                	jne    f0104792 <region_alloc+0x84>
		{
			panic("not enough memory avilable for region alloc\n");
f0104776:	c7 44 24 08 78 9d 10 	movl   $0xf0109d78,0x8(%esp)
f010477d:	f0 
f010477e:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
f0104785:	00 
f0104786:	c7 04 24 55 9d 10 f0 	movl   $0xf0109d55,(%esp)
f010478d:	e8 65 bb ff ff       	call   f01002f7 <_panic>
		}
		int t = page_insert(e->env_pgdir, pg, (void*)i, PTE_W | PTE_U);
f0104792:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104795:	8b 45 08             	mov    0x8(%ebp),%eax
f0104798:	8b 40 60             	mov    0x60(%eax),%eax
f010479b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01047a2:	00 
f01047a3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01047a7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01047aa:	89 54 24 04          	mov    %edx,0x4(%esp)
f01047ae:	89 04 24             	mov    %eax,(%esp)
f01047b1:	e8 b2 d2 ff ff       	call   f0101a68 <page_insert>
f01047b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
		if(t != 0)
f01047b9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01047bd:	74 1c                	je     f01047db <region_alloc+0xcd>
		{
			panic("Page table cant be allocated\n");
f01047bf:	c7 44 24 08 a5 9d 10 	movl   $0xf0109da5,0x8(%esp)
f01047c6:	f0 
f01047c7:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
f01047ce:	00 
f01047cf:	c7 04 24 55 9d 10 f0 	movl   $0xf0109d55,(%esp)
f01047d6:	e8 1c bb ff ff       	call   f01002f7 <_panic>
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	uintptr_t start = ROUNDDOWN((uintptr_t)va, PGSIZE);
	uintptr_t end = ROUNDUP((uintptr_t)va + (uintptr_t)len, PGSIZE);
	uintptr_t i;
	for(i = start;i<end;i+=PGSIZE)
f01047db:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f01047e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01047e5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01047e8:	0f 82 73 ff ff ff    	jb     f0104761 <region_alloc+0x53>
		{
			panic("Page table cant be allocated\n");
		}
	}

}
f01047ee:	c9                   	leave  
f01047ef:	c3                   	ret    

f01047f0 <load_icode>:
// load_icode panics if it encounters problems.
//  - How might load_icode fail?  What might be wrong with the given input?
//
static void
load_icode(struct Env *e, uint8_t *binary)
{
f01047f0:	55                   	push   %ebp
f01047f1:	89 e5                	mov    %esp,%ebp
f01047f3:	83 ec 28             	sub    $0x28,%esp
	//  You must also do something with the program's entry point,
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	struct Elf * elfheader = (struct Elf *) binary;
f01047f6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01047f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (elfheader->e_magic != ELF_MAGIC)
f01047fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01047ff:	8b 00                	mov    (%eax),%eax
f0104801:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
f0104806:	74 1c                	je     f0104824 <load_icode+0x34>
		panic("elf header magic not correct\n");
f0104808:	c7 44 24 08 c3 9d 10 	movl   $0xf0109dc3,0x8(%esp)
f010480f:	f0 
f0104810:	c7 44 24 04 7d 01 00 	movl   $0x17d,0x4(%esp)
f0104817:	00 
f0104818:	c7 04 24 55 9d 10 f0 	movl   $0xf0109d55,(%esp)
f010481f:	e8 d3 ba ff ff       	call   f01002f7 <_panic>
	struct Proghdr *ph_start = (struct Proghdr *)(binary + ((struct Elf*)binary)->e_phoff);
f0104824:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104827:	8b 50 1c             	mov    0x1c(%eax),%edx
f010482a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010482d:	01 d0                	add    %edx,%eax
f010482f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	struct Proghdr *ph_end = ph_start + elfheader->e_phnum;
f0104832:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104835:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
f0104839:	0f b7 c0             	movzwl %ax,%eax
f010483c:	c1 e0 05             	shl    $0x5,%eax
f010483f:	89 c2                	mov    %eax,%edx
f0104841:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104844:	01 d0                	add    %edx,%eax
f0104846:	89 45 ec             	mov    %eax,-0x14(%ebp)
	lcr3(PADDR(e->env_pgdir));
f0104849:	8b 45 08             	mov    0x8(%ebp),%eax
f010484c:	8b 40 60             	mov    0x60(%eax),%eax
f010484f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104853:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
f010485a:	00 
f010485b:	c7 04 24 55 9d 10 f0 	movl   $0xf0109d55,(%esp)
f0104862:	e8 73 f9 ff ff       	call   f01041da <_paddr>
f0104867:	89 45 e8             	mov    %eax,-0x18(%ebp)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010486a:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010486d:	0f 22 d8             	mov    %eax,%cr3
	for (; ph_start < ph_end; ph_start++) 
f0104870:	e9 b4 00 00 00       	jmp    f0104929 <load_icode+0x139>
	{
        if (ph_start->p_type == ELF_PROG_LOAD) 
f0104875:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104878:	8b 00                	mov    (%eax),%eax
f010487a:	83 f8 01             	cmp    $0x1,%eax
f010487d:	0f 85 a2 00 00 00    	jne    f0104925 <load_icode+0x135>
        {
            if (ph_start->p_filesz > ph_start->p_memsz)
f0104883:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104886:	8b 50 10             	mov    0x10(%eax),%edx
f0104889:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010488c:	8b 40 14             	mov    0x14(%eax),%eax
f010488f:	39 c2                	cmp    %eax,%edx
f0104891:	76 1c                	jbe    f01048af <load_icode+0xbf>
                panic("file size should be smaller than memory size\n");
f0104893:	c7 44 24 08 e4 9d 10 	movl   $0xf0109de4,0x8(%esp)
f010489a:	f0 
f010489b:	c7 44 24 04 86 01 00 	movl   $0x186,0x4(%esp)
f01048a2:	00 
f01048a3:	c7 04 24 55 9d 10 f0 	movl   $0xf0109d55,(%esp)
f01048aa:	e8 48 ba ff ff       	call   f01002f7 <_panic>
            
            region_alloc(e, (void *)ph_start->p_va, ph_start->p_memsz);
f01048af:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01048b2:	8b 50 14             	mov    0x14(%eax),%edx
f01048b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01048b8:	8b 40 08             	mov    0x8(%eax),%eax
f01048bb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01048bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048c3:	8b 45 08             	mov    0x8(%ebp),%eax
f01048c6:	89 04 24             	mov    %eax,(%esp)
f01048c9:	e8 40 fe ff ff       	call   f010470e <region_alloc>
            memcpy((void *)ph_start->p_va, binary + ph_start->p_offset, ph_start->p_filesz);
f01048ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01048d1:	8b 50 10             	mov    0x10(%eax),%edx
f01048d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01048d7:	8b 48 04             	mov    0x4(%eax),%ecx
f01048da:	8b 45 0c             	mov    0xc(%ebp),%eax
f01048dd:	01 c1                	add    %eax,%ecx
f01048df:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01048e2:	8b 40 08             	mov    0x8(%eax),%eax
f01048e5:	89 54 24 08          	mov    %edx,0x8(%esp)
f01048e9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01048ed:	89 04 24             	mov    %eax,(%esp)
f01048f0:	e8 4f 33 00 00       	call   f0107c44 <memcpy>
            memset((void *)(ph_start->p_va + ph_start->p_filesz), 0, ph_start->p_memsz - ph_start->p_filesz);
f01048f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01048f8:	8b 50 14             	mov    0x14(%eax),%edx
f01048fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01048fe:	8b 40 10             	mov    0x10(%eax),%eax
f0104901:	29 c2                	sub    %eax,%edx
f0104903:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104906:	8b 48 08             	mov    0x8(%eax),%ecx
f0104909:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010490c:	8b 40 10             	mov    0x10(%eax),%eax
f010490f:	01 c8                	add    %ecx,%eax
f0104911:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104915:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010491c:	00 
f010491d:	89 04 24             	mov    %eax,(%esp)
f0104920:	e8 d7 31 00 00       	call   f0107afc <memset>
	if (elfheader->e_magic != ELF_MAGIC)
		panic("elf header magic not correct\n");
	struct Proghdr *ph_start = (struct Proghdr *)(binary + ((struct Elf*)binary)->e_phoff);
	struct Proghdr *ph_end = ph_start + elfheader->e_phnum;
	lcr3(PADDR(e->env_pgdir));
	for (; ph_start < ph_end; ph_start++) 
f0104925:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
f0104929:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010492c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f010492f:	0f 82 40 ff ff ff    	jb     f0104875 <load_icode+0x85>
            memcpy((void *)ph_start->p_va, binary + ph_start->p_offset, ph_start->p_filesz);
            memset((void *)(ph_start->p_va + ph_start->p_filesz), 0, ph_start->p_memsz - ph_start->p_filesz);
        }
    }

    e->env_tf.tf_eip = elfheader->e_entry;
f0104935:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104938:	8b 50 18             	mov    0x18(%eax),%edx
f010493b:	8b 45 08             	mov    0x8(%ebp),%eax
f010493e:	89 50 30             	mov    %edx,0x30(%eax)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0104941:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0104948:	00 
f0104949:	c7 44 24 04 00 d0 bf 	movl   $0xeebfd000,0x4(%esp)
f0104950:	ee 
f0104951:	8b 45 08             	mov    0x8(%ebp),%eax
f0104954:	89 04 24             	mov    %eax,(%esp)
f0104957:	e8 b2 fd ff ff       	call   f010470e <region_alloc>
}
f010495c:	c9                   	leave  
f010495d:	c3                   	ret    

f010495e <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010495e:	55                   	push   %ebp
f010495f:	89 e5                	mov    %esp,%ebp
f0104961:	83 ec 28             	sub    $0x28,%esp
	// LAB 3: Your code here.
	struct Env *e;
	int t = env_alloc(&e,0);
f0104964:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010496b:	00 
f010496c:	8d 45 f0             	lea    -0x10(%ebp),%eax
f010496f:	89 04 24             	mov    %eax,(%esp)
f0104972:	e8 26 fc ff ff       	call   f010459d <env_alloc>
f0104977:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(t < 0)
f010497a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010497e:	79 1c                	jns    f010499c <env_create+0x3e>
	{
		panic("cant create environment\n");
f0104980:	c7 44 24 08 12 9e 10 	movl   $0xf0109e12,0x8(%esp)
f0104987:	f0 
f0104988:	c7 44 24 04 a5 01 00 	movl   $0x1a5,0x4(%esp)
f010498f:	00 
f0104990:	c7 04 24 55 9d 10 f0 	movl   $0xf0109d55,(%esp)
f0104997:	e8 5b b9 ff ff       	call   f01002f7 <_panic>
	}
	load_icode(e,binary);
f010499c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010499f:	8b 55 08             	mov    0x8(%ebp),%edx
f01049a2:	89 54 24 04          	mov    %edx,0x4(%esp)
f01049a6:	89 04 24             	mov    %eax,(%esp)
f01049a9:	e8 42 fe ff ff       	call   f01047f0 <load_icode>
	e->env_type = type;
f01049ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01049b1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01049b4:	89 50 50             	mov    %edx,0x50(%eax)
}
f01049b7:	c9                   	leave  
f01049b8:	c3                   	ret    

f01049b9 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01049b9:	55                   	push   %ebp
f01049ba:	89 e5                	mov    %esp,%ebp
f01049bc:	53                   	push   %ebx
f01049bd:	83 ec 34             	sub    $0x34,%esp
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01049c0:	e8 01 3c 00 00       	call   f01085c6 <cpunum>
f01049c5:	6b c0 74             	imul   $0x74,%eax,%eax
f01049c8:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f01049cd:	8b 00                	mov    (%eax),%eax
f01049cf:	3b 45 08             	cmp    0x8(%ebp),%eax
f01049d2:	75 26                	jne    f01049fa <env_free+0x41>
		lcr3(PADDR(kern_pgdir));
f01049d4:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f01049d9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01049dd:	c7 44 24 04 b9 01 00 	movl   $0x1b9,0x4(%esp)
f01049e4:	00 
f01049e5:	c7 04 24 55 9d 10 f0 	movl   $0xf0109d55,(%esp)
f01049ec:	e8 e9 f7 ff ff       	call   f01041da <_paddr>
f01049f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01049f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049f7:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01049fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01049fd:	8b 58 48             	mov    0x48(%eax),%ebx
f0104a00:	e8 c1 3b 00 00       	call   f01085c6 <cpunum>
f0104a05:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a08:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0104a0d:	8b 00                	mov    (%eax),%eax
f0104a0f:	85 c0                	test   %eax,%eax
f0104a11:	74 14                	je     f0104a27 <env_free+0x6e>
f0104a13:	e8 ae 3b 00 00       	call   f01085c6 <cpunum>
f0104a18:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a1b:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0104a20:	8b 00                	mov    (%eax),%eax
f0104a22:	8b 40 48             	mov    0x48(%eax),%eax
f0104a25:	eb 05                	jmp    f0104a2c <env_free+0x73>
f0104a27:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a2c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104a30:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a34:	c7 04 24 2b 9e 10 f0 	movl   $0xf0109e2b,(%esp)
f0104a3b:	e8 7f 05 00 00       	call   f0104fbf <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0104a40:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0104a47:	e9 cf 00 00 00       	jmp    f0104b1b <env_free+0x162>

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0104a4c:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a4f:	8b 40 60             	mov    0x60(%eax),%eax
f0104a52:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104a55:	c1 e2 02             	shl    $0x2,%edx
f0104a58:	01 d0                	add    %edx,%eax
f0104a5a:	8b 00                	mov    (%eax),%eax
f0104a5c:	83 e0 01             	and    $0x1,%eax
f0104a5f:	85 c0                	test   %eax,%eax
f0104a61:	75 05                	jne    f0104a68 <env_free+0xaf>
			continue;
f0104a63:	e9 af 00 00 00       	jmp    f0104b17 <env_free+0x15e>

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0104a68:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a6b:	8b 40 60             	mov    0x60(%eax),%eax
f0104a6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104a71:	c1 e2 02             	shl    $0x2,%edx
f0104a74:	01 d0                	add    %edx,%eax
f0104a76:	8b 00                	mov    (%eax),%eax
f0104a78:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104a7d:	89 45 ec             	mov    %eax,-0x14(%ebp)
		pt = (pte_t*) KADDR(pa);
f0104a80:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104a83:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104a87:	c7 44 24 04 c8 01 00 	movl   $0x1c8,0x4(%esp)
f0104a8e:	00 
f0104a8f:	c7 04 24 55 9d 10 f0 	movl   $0xf0109d55,(%esp)
f0104a96:	e8 7a f7 ff ff       	call   f0104215 <_kaddr>
f0104a9b:	89 45 e8             	mov    %eax,-0x18(%ebp)

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0104a9e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0104aa5:	eb 40                	jmp    f0104ae7 <env_free+0x12e>
			if (pt[pteno] & PTE_P)
f0104aa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104aaa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0104ab1:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104ab4:	01 d0                	add    %edx,%eax
f0104ab6:	8b 00                	mov    (%eax),%eax
f0104ab8:	83 e0 01             	and    $0x1,%eax
f0104abb:	85 c0                	test   %eax,%eax
f0104abd:	74 24                	je     f0104ae3 <env_free+0x12a>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0104abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104ac2:	c1 e0 16             	shl    $0x16,%eax
f0104ac5:	89 c2                	mov    %eax,%edx
f0104ac7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104aca:	c1 e0 0c             	shl    $0xc,%eax
f0104acd:	09 d0                	or     %edx,%eax
f0104acf:	89 c2                	mov    %eax,%edx
f0104ad1:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ad4:	8b 40 60             	mov    0x60(%eax),%eax
f0104ad7:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104adb:	89 04 24             	mov    %eax,(%esp)
f0104ade:	e8 9b d0 ff ff       	call   f0101b7e <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0104ae3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f0104ae7:	81 7d f0 ff 03 00 00 	cmpl   $0x3ff,-0x10(%ebp)
f0104aee:	76 b7                	jbe    f0104aa7 <env_free+0xee>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0104af0:	8b 45 08             	mov    0x8(%ebp),%eax
f0104af3:	8b 40 60             	mov    0x60(%eax),%eax
f0104af6:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104af9:	c1 e2 02             	shl    $0x2,%edx
f0104afc:	01 d0                	add    %edx,%eax
f0104afe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		page_decref(pa2page(pa));
f0104b04:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104b07:	89 04 24             	mov    %eax,(%esp)
f0104b0a:	e8 5f f7 ff ff       	call   f010426e <pa2page>
f0104b0f:	89 04 24             	mov    %eax,(%esp)
f0104b12:	e8 78 cd ff ff       	call   f010188f <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0104b17:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0104b1b:	81 7d f4 ba 03 00 00 	cmpl   $0x3ba,-0xc(%ebp)
f0104b22:	0f 86 24 ff ff ff    	jbe    f0104a4c <env_free+0x93>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0104b28:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b2b:	8b 40 60             	mov    0x60(%eax),%eax
f0104b2e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104b32:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
f0104b39:	00 
f0104b3a:	c7 04 24 55 9d 10 f0 	movl   $0xf0109d55,(%esp)
f0104b41:	e8 94 f6 ff ff       	call   f01041da <_paddr>
f0104b46:	89 45 ec             	mov    %eax,-0x14(%ebp)
	e->env_pgdir = 0;
f0104b49:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b4c:	c7 40 60 00 00 00 00 	movl   $0x0,0x60(%eax)
	page_decref(pa2page(pa));
f0104b53:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104b56:	89 04 24             	mov    %eax,(%esp)
f0104b59:	e8 10 f7 ff ff       	call   f010426e <pa2page>
f0104b5e:	89 04 24             	mov    %eax,(%esp)
f0104b61:	e8 29 cd ff ff       	call   f010188f <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0104b66:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b69:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0104b70:	8b 15 40 b2 23 f0    	mov    0xf023b240,%edx
f0104b76:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b79:	89 50 44             	mov    %edx,0x44(%eax)
	env_free_list = e;
f0104b7c:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b7f:	a3 40 b2 23 f0       	mov    %eax,0xf023b240
}
f0104b84:	83 c4 34             	add    $0x34,%esp
f0104b87:	5b                   	pop    %ebx
f0104b88:	5d                   	pop    %ebp
f0104b89:	c3                   	ret    

f0104b8a <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0104b8a:	55                   	push   %ebp
f0104b8b:	89 e5                	mov    %esp,%ebp
f0104b8d:	83 ec 18             	sub    $0x18,%esp
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0104b90:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b93:	8b 40 54             	mov    0x54(%eax),%eax
f0104b96:	83 f8 03             	cmp    $0x3,%eax
f0104b99:	75 20                	jne    f0104bbb <env_destroy+0x31>
f0104b9b:	e8 26 3a 00 00       	call   f01085c6 <cpunum>
f0104ba0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ba3:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0104ba8:	8b 00                	mov    (%eax),%eax
f0104baa:	3b 45 08             	cmp    0x8(%ebp),%eax
f0104bad:	74 0c                	je     f0104bbb <env_destroy+0x31>
		e->env_status = ENV_DYING;
f0104baf:	8b 45 08             	mov    0x8(%ebp),%eax
f0104bb2:	c7 40 54 01 00 00 00 	movl   $0x1,0x54(%eax)
		return;
f0104bb9:	eb 37                	jmp    f0104bf2 <env_destroy+0x68>
	}

	env_free(e);
f0104bbb:	8b 45 08             	mov    0x8(%ebp),%eax
f0104bbe:	89 04 24             	mov    %eax,(%esp)
f0104bc1:	e8 f3 fd ff ff       	call   f01049b9 <env_free>

	if (curenv == e) {
f0104bc6:	e8 fb 39 00 00       	call   f01085c6 <cpunum>
f0104bcb:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bce:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0104bd3:	8b 00                	mov    (%eax),%eax
f0104bd5:	3b 45 08             	cmp    0x8(%ebp),%eax
f0104bd8:	75 18                	jne    f0104bf2 <env_destroy+0x68>
		curenv = NULL;
f0104bda:	e8 e7 39 00 00       	call   f01085c6 <cpunum>
f0104bdf:	6b c0 74             	imul   $0x74,%eax,%eax
f0104be2:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0104be7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		sched_yield();
f0104bed:	e8 2f 14 00 00       	call   f0106021 <sched_yield>
	}
}
f0104bf2:	c9                   	leave  
f0104bf3:	c3                   	ret    

f0104bf4 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0104bf4:	55                   	push   %ebp
f0104bf5:	89 e5                	mov    %esp,%ebp
f0104bf7:	53                   	push   %ebx
f0104bf8:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0104bfb:	e8 c6 39 00 00       	call   f01085c6 <cpunum>
f0104c00:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c03:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0104c08:	8b 18                	mov    (%eax),%ebx
f0104c0a:	e8 b7 39 00 00       	call   f01085c6 <cpunum>
f0104c0f:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0104c12:	8b 65 08             	mov    0x8(%ebp),%esp
f0104c15:	61                   	popa   
f0104c16:	07                   	pop    %es
f0104c17:	1f                   	pop    %ds
f0104c18:	83 c4 08             	add    $0x8,%esp
f0104c1b:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0104c1c:	c7 44 24 08 41 9e 10 	movl   $0xf0109e41,0x8(%esp)
f0104c23:	f0 
f0104c24:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
f0104c2b:	00 
f0104c2c:	c7 04 24 55 9d 10 f0 	movl   $0xf0109d55,(%esp)
f0104c33:	e8 bf b6 ff ff       	call   f01002f7 <_panic>

f0104c38 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0104c38:	55                   	push   %ebp
f0104c39:	89 e5                	mov    %esp,%ebp
f0104c3b:	83 ec 28             	sub    $0x28,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104c3e:	e8 83 39 00 00       	call   f01085c6 <cpunum>
f0104c43:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c46:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0104c4b:	8b 00                	mov    (%eax),%eax
f0104c4d:	85 c0                	test   %eax,%eax
f0104c4f:	74 2d                	je     f0104c7e <env_run+0x46>
f0104c51:	e8 70 39 00 00       	call   f01085c6 <cpunum>
f0104c56:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c59:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0104c5e:	8b 00                	mov    (%eax),%eax
f0104c60:	8b 40 54             	mov    0x54(%eax),%eax
f0104c63:	83 f8 03             	cmp    $0x3,%eax
f0104c66:	75 16                	jne    f0104c7e <env_run+0x46>
		curenv->env_status = ENV_RUNNABLE;
f0104c68:	e8 59 39 00 00       	call   f01085c6 <cpunum>
f0104c6d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c70:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0104c75:	8b 00                	mov    (%eax),%eax
f0104c77:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

	curenv = e;
f0104c7e:	e8 43 39 00 00       	call   f01085c6 <cpunum>
f0104c83:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c86:	8d 90 28 c0 23 f0    	lea    -0xfdc3fd8(%eax),%edx
f0104c8c:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c8f:	89 02                	mov    %eax,(%edx)
	curenv->env_status = ENV_RUNNING;
f0104c91:	e8 30 39 00 00       	call   f01085c6 <cpunum>
f0104c96:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c99:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0104c9e:	8b 00                	mov    (%eax),%eax
f0104ca0:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0104ca7:	e8 1a 39 00 00       	call   f01085c6 <cpunum>
f0104cac:	6b c0 74             	imul   $0x74,%eax,%eax
f0104caf:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0104cb4:	8b 00                	mov    (%eax),%eax
f0104cb6:	8b 50 58             	mov    0x58(%eax),%edx
f0104cb9:	83 c2 01             	add    $0x1,%edx
f0104cbc:	89 50 58             	mov    %edx,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f0104cbf:	e8 02 39 00 00       	call   f01085c6 <cpunum>
f0104cc4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cc7:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0104ccc:	8b 00                	mov    (%eax),%eax
f0104cce:	8b 40 60             	mov    0x60(%eax),%eax
f0104cd1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104cd5:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
f0104cdc:	00 
f0104cdd:	c7 04 24 55 9d 10 f0 	movl   $0xf0109d55,(%esp)
f0104ce4:	e8 f1 f4 ff ff       	call   f01041da <_paddr>
f0104ce9:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0104cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104cef:	0f 22 d8             	mov    %eax,%cr3

	unlock_kernel();
f0104cf2:	e8 e7 f5 ff ff       	call   f01042de <unlock_kernel>

	env_pop_tf(&(curenv->env_tf));
f0104cf7:	e8 ca 38 00 00       	call   f01085c6 <cpunum>
f0104cfc:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cff:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0104d04:	8b 00                	mov    (%eax),%eax
f0104d06:	89 04 24             	mov    %eax,(%esp)
f0104d09:	e8 e6 fe ff ff       	call   f0104bf4 <env_pop_tf>

f0104d0e <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0104d0e:	55                   	push   %ebp
f0104d0f:	89 e5                	mov    %esp,%ebp
f0104d11:	83 ec 10             	sub    $0x10,%esp
	outb(IO_RTC, reg);
f0104d14:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d17:	0f b6 c0             	movzbl %al,%eax
f0104d1a:	c7 45 fc 70 00 00 00 	movl   $0x70,-0x4(%ebp)
f0104d21:	88 45 fb             	mov    %al,-0x5(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104d24:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
f0104d28:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0104d2b:	ee                   	out    %al,(%dx)
f0104d2c:	c7 45 f4 71 00 00 00 	movl   $0x71,-0xc(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0104d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104d36:	89 c2                	mov    %eax,%edx
f0104d38:	ec                   	in     (%dx),%al
f0104d39:	88 45 f3             	mov    %al,-0xd(%ebp)
	return data;
f0104d3c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
	return inb(IO_RTC+1);
f0104d40:	0f b6 c0             	movzbl %al,%eax
}
f0104d43:	c9                   	leave  
f0104d44:	c3                   	ret    

f0104d45 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0104d45:	55                   	push   %ebp
f0104d46:	89 e5                	mov    %esp,%ebp
f0104d48:	83 ec 10             	sub    $0x10,%esp
	outb(IO_RTC, reg);
f0104d4b:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d4e:	0f b6 c0             	movzbl %al,%eax
f0104d51:	c7 45 fc 70 00 00 00 	movl   $0x70,-0x4(%ebp)
f0104d58:	88 45 fb             	mov    %al,-0x5(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104d5b:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
f0104d5f:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0104d62:	ee                   	out    %al,(%dx)
	outb(IO_RTC+1, datum);
f0104d63:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d66:	0f b6 c0             	movzbl %al,%eax
f0104d69:	c7 45 f4 71 00 00 00 	movl   $0x71,-0xc(%ebp)
f0104d70:	88 45 f3             	mov    %al,-0xd(%ebp)
f0104d73:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0104d77:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104d7a:	ee                   	out    %al,(%dx)
}
f0104d7b:	c9                   	leave  
f0104d7c:	c3                   	ret    

f0104d7d <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0104d7d:	55                   	push   %ebp
f0104d7e:	89 e5                	mov    %esp,%ebp
f0104d80:	81 ec 88 00 00 00    	sub    $0x88,%esp
	didinit = 1;
f0104d86:	c6 05 44 b2 23 f0 01 	movb   $0x1,0xf023b244
f0104d8d:	c7 45 f4 21 00 00 00 	movl   $0x21,-0xc(%ebp)
f0104d94:	c6 45 f3 ff          	movb   $0xff,-0xd(%ebp)
f0104d98:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0104d9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104d9f:	ee                   	out    %al,(%dx)
f0104da0:	c7 45 ec a1 00 00 00 	movl   $0xa1,-0x14(%ebp)
f0104da7:	c6 45 eb ff          	movb   $0xff,-0x15(%ebp)
f0104dab:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
f0104daf:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0104db2:	ee                   	out    %al,(%dx)
f0104db3:	c7 45 e4 20 00 00 00 	movl   $0x20,-0x1c(%ebp)
f0104dba:	c6 45 e3 11          	movb   $0x11,-0x1d(%ebp)
f0104dbe:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f0104dc2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104dc5:	ee                   	out    %al,(%dx)
f0104dc6:	c7 45 dc 21 00 00 00 	movl   $0x21,-0x24(%ebp)
f0104dcd:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
f0104dd1:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
f0104dd5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104dd8:	ee                   	out    %al,(%dx)
f0104dd9:	c7 45 d4 21 00 00 00 	movl   $0x21,-0x2c(%ebp)
f0104de0:	c6 45 d3 04          	movb   $0x4,-0x2d(%ebp)
f0104de4:	0f b6 45 d3          	movzbl -0x2d(%ebp),%eax
f0104de8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104deb:	ee                   	out    %al,(%dx)
f0104dec:	c7 45 cc 21 00 00 00 	movl   $0x21,-0x34(%ebp)
f0104df3:	c6 45 cb 03          	movb   $0x3,-0x35(%ebp)
f0104df7:	0f b6 45 cb          	movzbl -0x35(%ebp),%eax
f0104dfb:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104dfe:	ee                   	out    %al,(%dx)
f0104dff:	c7 45 c4 a0 00 00 00 	movl   $0xa0,-0x3c(%ebp)
f0104e06:	c6 45 c3 11          	movb   $0x11,-0x3d(%ebp)
f0104e0a:	0f b6 45 c3          	movzbl -0x3d(%ebp),%eax
f0104e0e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104e11:	ee                   	out    %al,(%dx)
f0104e12:	c7 45 bc a1 00 00 00 	movl   $0xa1,-0x44(%ebp)
f0104e19:	c6 45 bb 28          	movb   $0x28,-0x45(%ebp)
f0104e1d:	0f b6 45 bb          	movzbl -0x45(%ebp),%eax
f0104e21:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104e24:	ee                   	out    %al,(%dx)
f0104e25:	c7 45 b4 a1 00 00 00 	movl   $0xa1,-0x4c(%ebp)
f0104e2c:	c6 45 b3 02          	movb   $0x2,-0x4d(%ebp)
f0104e30:	0f b6 45 b3          	movzbl -0x4d(%ebp),%eax
f0104e34:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0104e37:	ee                   	out    %al,(%dx)
f0104e38:	c7 45 ac a1 00 00 00 	movl   $0xa1,-0x54(%ebp)
f0104e3f:	c6 45 ab 01          	movb   $0x1,-0x55(%ebp)
f0104e43:	0f b6 45 ab          	movzbl -0x55(%ebp),%eax
f0104e47:	8b 55 ac             	mov    -0x54(%ebp),%edx
f0104e4a:	ee                   	out    %al,(%dx)
f0104e4b:	c7 45 a4 20 00 00 00 	movl   $0x20,-0x5c(%ebp)
f0104e52:	c6 45 a3 68          	movb   $0x68,-0x5d(%ebp)
f0104e56:	0f b6 45 a3          	movzbl -0x5d(%ebp),%eax
f0104e5a:	8b 55 a4             	mov    -0x5c(%ebp),%edx
f0104e5d:	ee                   	out    %al,(%dx)
f0104e5e:	c7 45 9c 20 00 00 00 	movl   $0x20,-0x64(%ebp)
f0104e65:	c6 45 9b 0a          	movb   $0xa,-0x65(%ebp)
f0104e69:	0f b6 45 9b          	movzbl -0x65(%ebp),%eax
f0104e6d:	8b 55 9c             	mov    -0x64(%ebp),%edx
f0104e70:	ee                   	out    %al,(%dx)
f0104e71:	c7 45 94 a0 00 00 00 	movl   $0xa0,-0x6c(%ebp)
f0104e78:	c6 45 93 68          	movb   $0x68,-0x6d(%ebp)
f0104e7c:	0f b6 45 93          	movzbl -0x6d(%ebp),%eax
f0104e80:	8b 55 94             	mov    -0x6c(%ebp),%edx
f0104e83:	ee                   	out    %al,(%dx)
f0104e84:	c7 45 8c a0 00 00 00 	movl   $0xa0,-0x74(%ebp)
f0104e8b:	c6 45 8b 0a          	movb   $0xa,-0x75(%ebp)
f0104e8f:	0f b6 45 8b          	movzbl -0x75(%ebp),%eax
f0104e93:	8b 55 8c             	mov    -0x74(%ebp),%edx
f0104e96:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0104e97:	0f b7 05 ce 55 12 f0 	movzwl 0xf01255ce,%eax
f0104e9e:	66 83 f8 ff          	cmp    $0xffff,%ax
f0104ea2:	74 12                	je     f0104eb6 <pic_init+0x139>
		irq_setmask_8259A(irq_mask_8259A);
f0104ea4:	0f b7 05 ce 55 12 f0 	movzwl 0xf01255ce,%eax
f0104eab:	0f b7 c0             	movzwl %ax,%eax
f0104eae:	89 04 24             	mov    %eax,(%esp)
f0104eb1:	e8 02 00 00 00       	call   f0104eb8 <irq_setmask_8259A>
}
f0104eb6:	c9                   	leave  
f0104eb7:	c3                   	ret    

f0104eb8 <irq_setmask_8259A>:

void
irq_setmask_8259A(uint16_t mask)
{
f0104eb8:	55                   	push   %ebp
f0104eb9:	89 e5                	mov    %esp,%ebp
f0104ebb:	83 ec 38             	sub    $0x38,%esp
f0104ebe:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ec1:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
	int i;
	irq_mask_8259A = mask;
f0104ec5:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
f0104ec9:	66 a3 ce 55 12 f0    	mov    %ax,0xf01255ce
	if (!didinit)
f0104ecf:	0f b6 05 44 b2 23 f0 	movzbl 0xf023b244,%eax
f0104ed6:	83 f0 01             	xor    $0x1,%eax
f0104ed9:	84 c0                	test   %al,%al
f0104edb:	74 05                	je     f0104ee2 <irq_setmask_8259A+0x2a>
		return;
f0104edd:	e9 8c 00 00 00       	jmp    f0104f6e <irq_setmask_8259A+0xb6>
	outb(IO_PIC1+1, (char)mask);
f0104ee2:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
f0104ee6:	0f b6 c0             	movzbl %al,%eax
f0104ee9:	c7 45 f0 21 00 00 00 	movl   $0x21,-0x10(%ebp)
f0104ef0:	88 45 ef             	mov    %al,-0x11(%ebp)
f0104ef3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
f0104ef7:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104efa:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f0104efb:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
f0104eff:	66 c1 e8 08          	shr    $0x8,%ax
f0104f03:	0f b6 c0             	movzbl %al,%eax
f0104f06:	c7 45 e8 a1 00 00 00 	movl   $0xa1,-0x18(%ebp)
f0104f0d:	88 45 e7             	mov    %al,-0x19(%ebp)
f0104f10:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0104f14:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104f17:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0104f18:	c7 04 24 4d 9e 10 f0 	movl   $0xf0109e4d,(%esp)
f0104f1f:	e8 9b 00 00 00       	call   f0104fbf <cprintf>
	for (i = 0; i < 16; i++)
f0104f24:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0104f2b:	eb 2f                	jmp    f0104f5c <irq_setmask_8259A+0xa4>
		if (~mask & (1<<i))
f0104f2d:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
f0104f31:	f7 d0                	not    %eax
f0104f33:	89 c2                	mov    %eax,%edx
f0104f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104f38:	89 c1                	mov    %eax,%ecx
f0104f3a:	d3 fa                	sar    %cl,%edx
f0104f3c:	89 d0                	mov    %edx,%eax
f0104f3e:	83 e0 01             	and    $0x1,%eax
f0104f41:	85 c0                	test   %eax,%eax
f0104f43:	74 13                	je     f0104f58 <irq_setmask_8259A+0xa0>
			cprintf(" %d", i);
f0104f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104f48:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f4c:	c7 04 24 61 9e 10 f0 	movl   $0xf0109e61,(%esp)
f0104f53:	e8 67 00 00 00       	call   f0104fbf <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0104f58:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0104f5c:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
f0104f60:	7e cb                	jle    f0104f2d <irq_setmask_8259A+0x75>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0104f62:	c7 04 24 65 9e 10 f0 	movl   $0xf0109e65,(%esp)
f0104f69:	e8 51 00 00 00       	call   f0104fbf <cprintf>
}
f0104f6e:	c9                   	leave  
f0104f6f:	c3                   	ret    

f0104f70 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0104f70:	55                   	push   %ebp
f0104f71:	89 e5                	mov    %esp,%ebp
f0104f73:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0104f76:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f79:	89 04 24             	mov    %eax,(%esp)
f0104f7c:	e8 16 bc ff ff       	call   f0100b97 <cputchar>
	*cnt++;
f0104f81:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f84:	83 c0 04             	add    $0x4,%eax
f0104f87:	89 45 0c             	mov    %eax,0xc(%ebp)
}
f0104f8a:	c9                   	leave  
f0104f8b:	c3                   	ret    

f0104f8c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0104f8c:	55                   	push   %ebp
f0104f8d:	89 e5                	mov    %esp,%ebp
f0104f8f:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0104f92:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0104f99:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f9c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104fa0:	8b 45 08             	mov    0x8(%ebp),%eax
f0104fa3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104fa7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104faa:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fae:	c7 04 24 70 4f 10 f0 	movl   $0xf0104f70,(%esp)
f0104fb5:	e8 f5 22 00 00       	call   f01072af <vprintfmt>
	return cnt;
f0104fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0104fbd:	c9                   	leave  
f0104fbe:	c3                   	ret    

f0104fbf <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0104fbf:	55                   	push   %ebp
f0104fc0:	89 e5                	mov    %esp,%ebp
f0104fc2:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0104fc5:	8d 45 0c             	lea    0xc(%ebp),%eax
f0104fc8:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
f0104fcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104fce:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fd2:	8b 45 08             	mov    0x8(%ebp),%eax
f0104fd5:	89 04 24             	mov    %eax,(%esp)
f0104fd8:	e8 af ff ff ff       	call   f0104f8c <vcprintf>
f0104fdd:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
f0104fe0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0104fe3:	c9                   	leave  
f0104fe4:	c3                   	ret    

f0104fe5 <xchg>:
	return tsc;
}

static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
f0104fe5:	55                   	push   %ebp
f0104fe6:	89 e5                	mov    %esp,%ebp
f0104fe8:	83 ec 10             	sub    $0x10,%esp
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104feb:	8b 55 08             	mov    0x8(%ebp),%edx
f0104fee:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104ff1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104ff4:	f0 87 02             	lock xchg %eax,(%edx)
f0104ff7:	89 45 fc             	mov    %eax,-0x4(%ebp)
			"+m" (*addr), "=a" (result) :
			"1" (newval) :
			"cc");
	return result;
f0104ffa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f0104ffd:	c9                   	leave  
f0104ffe:	c3                   	ret    

f0104fff <lock_kernel>:

extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
f0104fff:	55                   	push   %ebp
f0105000:	89 e5                	mov    %esp,%ebp
f0105002:	83 ec 18             	sub    $0x18,%esp
	spin_lock(&kernel_lock);
f0105005:	c7 04 24 e0 55 12 f0 	movl   $0xf01255e0,(%esp)
f010500c:	e8 30 38 00 00       	call   f0108841 <spin_lock>
}
f0105011:	c9                   	leave  
f0105012:	c3                   	ret    

f0105013 <trapname>:
	sizeof(idt) - 1, (uint32_t) idt
};


static const char *trapname(int trapno)
{
f0105013:	55                   	push   %ebp
f0105014:	89 e5                	mov    %esp,%ebp
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0105016:	8b 45 08             	mov    0x8(%ebp),%eax
f0105019:	83 f8 13             	cmp    $0x13,%eax
f010501c:	77 0c                	ja     f010502a <trapname+0x17>
		return excnames[trapno];
f010501e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105021:	8b 04 85 20 a2 10 f0 	mov    -0xfef5de0(,%eax,4),%eax
f0105028:	eb 25                	jmp    f010504f <trapname+0x3c>
	if (trapno == T_SYSCALL)
f010502a:	83 7d 08 30          	cmpl   $0x30,0x8(%ebp)
f010502e:	75 07                	jne    f0105037 <trapname+0x24>
		return "System call";
f0105030:	b8 80 9e 10 f0       	mov    $0xf0109e80,%eax
f0105035:	eb 18                	jmp    f010504f <trapname+0x3c>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0105037:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
f010503b:	7e 0d                	jle    f010504a <trapname+0x37>
f010503d:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
f0105041:	7f 07                	jg     f010504a <trapname+0x37>
		return "Hardware Interrupt";
f0105043:	b8 8c 9e 10 f0       	mov    $0xf0109e8c,%eax
f0105048:	eb 05                	jmp    f010504f <trapname+0x3c>
	return "(unknown trap)";
f010504a:	b8 9f 9e 10 f0       	mov    $0xf0109e9f,%eax
}
f010504f:	5d                   	pop    %ebp
f0105050:	c3                   	ret    

f0105051 <trap_init>:

void
trap_init(void)
{
f0105051:	55                   	push   %ebp
f0105052:	89 e5                	mov    %esp,%ebp
f0105054:	83 ec 18             	sub    $0x18,%esp
	extern struct Segdesc gdt[];
	extern long idt_table[];
	// LAB 3: Your code here.
	int i;
	for (i = 0; i <= 14; i++) 
f0105057:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f010505e:	e9 5b 01 00 00       	jmp    f01051be <trap_init+0x16d>
	{
		if(i == T_BRKPT)
f0105063:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
f0105067:	0f 85 8e 00 00 00    	jne    f01050fb <trap_init+0xaa>
		{
			SETGATE(idt[T_BRKPT], 0, GD_KT, idt_table[i], 3)			
f010506d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105070:	8b 04 85 48 5f 10 f0 	mov    -0xfefa0b8(,%eax,4),%eax
f0105077:	66 a3 78 b2 23 f0    	mov    %ax,0xf023b278
f010507d:	66 c7 05 7a b2 23 f0 	movw   $0x8,0xf023b27a
f0105084:	08 00 
f0105086:	0f b6 05 7c b2 23 f0 	movzbl 0xf023b27c,%eax
f010508d:	83 e0 e0             	and    $0xffffffe0,%eax
f0105090:	a2 7c b2 23 f0       	mov    %al,0xf023b27c
f0105095:	0f b6 05 7c b2 23 f0 	movzbl 0xf023b27c,%eax
f010509c:	83 e0 1f             	and    $0x1f,%eax
f010509f:	a2 7c b2 23 f0       	mov    %al,0xf023b27c
f01050a4:	0f b6 05 7d b2 23 f0 	movzbl 0xf023b27d,%eax
f01050ab:	83 e0 f0             	and    $0xfffffff0,%eax
f01050ae:	83 c8 0e             	or     $0xe,%eax
f01050b1:	a2 7d b2 23 f0       	mov    %al,0xf023b27d
f01050b6:	0f b6 05 7d b2 23 f0 	movzbl 0xf023b27d,%eax
f01050bd:	83 e0 ef             	and    $0xffffffef,%eax
f01050c0:	a2 7d b2 23 f0       	mov    %al,0xf023b27d
f01050c5:	0f b6 05 7d b2 23 f0 	movzbl 0xf023b27d,%eax
f01050cc:	83 c8 60             	or     $0x60,%eax
f01050cf:	a2 7d b2 23 f0       	mov    %al,0xf023b27d
f01050d4:	0f b6 05 7d b2 23 f0 	movzbl 0xf023b27d,%eax
f01050db:	83 c8 80             	or     $0xffffff80,%eax
f01050de:	a2 7d b2 23 f0       	mov    %al,0xf023b27d
f01050e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01050e6:	8b 04 85 48 5f 10 f0 	mov    -0xfefa0b8(,%eax,4),%eax
f01050ed:	c1 e8 10             	shr    $0x10,%eax
f01050f0:	66 a3 7e b2 23 f0    	mov    %ax,0xf023b27e
f01050f6:	e9 bf 00 00 00       	jmp    f01051ba <trap_init+0x169>
		}
		else
			SETGATE(idt[i], 0, GD_KT, idt_table[i], 0);
f01050fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01050fe:	8b 04 85 48 5f 10 f0 	mov    -0xfefa0b8(,%eax,4),%eax
f0105105:	89 c2                	mov    %eax,%edx
f0105107:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010510a:	66 89 14 c5 60 b2 23 	mov    %dx,-0xfdc4da0(,%eax,8)
f0105111:	f0 
f0105112:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105115:	66 c7 04 c5 62 b2 23 	movw   $0x8,-0xfdc4d9e(,%eax,8)
f010511c:	f0 08 00 
f010511f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105122:	0f b6 14 c5 64 b2 23 	movzbl -0xfdc4d9c(,%eax,8),%edx
f0105129:	f0 
f010512a:	83 e2 e0             	and    $0xffffffe0,%edx
f010512d:	88 14 c5 64 b2 23 f0 	mov    %dl,-0xfdc4d9c(,%eax,8)
f0105134:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105137:	0f b6 14 c5 64 b2 23 	movzbl -0xfdc4d9c(,%eax,8),%edx
f010513e:	f0 
f010513f:	83 e2 1f             	and    $0x1f,%edx
f0105142:	88 14 c5 64 b2 23 f0 	mov    %dl,-0xfdc4d9c(,%eax,8)
f0105149:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010514c:	0f b6 14 c5 65 b2 23 	movzbl -0xfdc4d9b(,%eax,8),%edx
f0105153:	f0 
f0105154:	83 e2 f0             	and    $0xfffffff0,%edx
f0105157:	83 ca 0e             	or     $0xe,%edx
f010515a:	88 14 c5 65 b2 23 f0 	mov    %dl,-0xfdc4d9b(,%eax,8)
f0105161:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105164:	0f b6 14 c5 65 b2 23 	movzbl -0xfdc4d9b(,%eax,8),%edx
f010516b:	f0 
f010516c:	83 e2 ef             	and    $0xffffffef,%edx
f010516f:	88 14 c5 65 b2 23 f0 	mov    %dl,-0xfdc4d9b(,%eax,8)
f0105176:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105179:	0f b6 14 c5 65 b2 23 	movzbl -0xfdc4d9b(,%eax,8),%edx
f0105180:	f0 
f0105181:	83 e2 9f             	and    $0xffffff9f,%edx
f0105184:	88 14 c5 65 b2 23 f0 	mov    %dl,-0xfdc4d9b(,%eax,8)
f010518b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010518e:	0f b6 14 c5 65 b2 23 	movzbl -0xfdc4d9b(,%eax,8),%edx
f0105195:	f0 
f0105196:	83 ca 80             	or     $0xffffff80,%edx
f0105199:	88 14 c5 65 b2 23 f0 	mov    %dl,-0xfdc4d9b(,%eax,8)
f01051a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01051a3:	8b 04 85 48 5f 10 f0 	mov    -0xfefa0b8(,%eax,4),%eax
f01051aa:	c1 e8 10             	shr    $0x10,%eax
f01051ad:	89 c2                	mov    %eax,%edx
f01051af:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01051b2:	66 89 14 c5 66 b2 23 	mov    %dx,-0xfdc4d9a(,%eax,8)
f01051b9:	f0 
{
	extern struct Segdesc gdt[];
	extern long idt_table[];
	// LAB 3: Your code here.
	int i;
	for (i = 0; i <= 14; i++) 
f01051ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f01051be:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
f01051c2:	0f 8e 9b fe ff ff    	jle    f0105063 <trap_init+0x12>
			SETGATE(idt[T_BRKPT], 0, GD_KT, idt_table[i], 3)			
		}
		else
			SETGATE(idt[i], 0, GD_KT, idt_table[i], 0);
	}
	SETGATE(idt[16], 0, GD_KT, idt_table[15], 0);
f01051c8:	a1 84 5f 10 f0       	mov    0xf0105f84,%eax
f01051cd:	66 a3 e0 b2 23 f0    	mov    %ax,0xf023b2e0
f01051d3:	66 c7 05 e2 b2 23 f0 	movw   $0x8,0xf023b2e2
f01051da:	08 00 
f01051dc:	0f b6 05 e4 b2 23 f0 	movzbl 0xf023b2e4,%eax
f01051e3:	83 e0 e0             	and    $0xffffffe0,%eax
f01051e6:	a2 e4 b2 23 f0       	mov    %al,0xf023b2e4
f01051eb:	0f b6 05 e4 b2 23 f0 	movzbl 0xf023b2e4,%eax
f01051f2:	83 e0 1f             	and    $0x1f,%eax
f01051f5:	a2 e4 b2 23 f0       	mov    %al,0xf023b2e4
f01051fa:	0f b6 05 e5 b2 23 f0 	movzbl 0xf023b2e5,%eax
f0105201:	83 e0 f0             	and    $0xfffffff0,%eax
f0105204:	83 c8 0e             	or     $0xe,%eax
f0105207:	a2 e5 b2 23 f0       	mov    %al,0xf023b2e5
f010520c:	0f b6 05 e5 b2 23 f0 	movzbl 0xf023b2e5,%eax
f0105213:	83 e0 ef             	and    $0xffffffef,%eax
f0105216:	a2 e5 b2 23 f0       	mov    %al,0xf023b2e5
f010521b:	0f b6 05 e5 b2 23 f0 	movzbl 0xf023b2e5,%eax
f0105222:	83 e0 9f             	and    $0xffffff9f,%eax
f0105225:	a2 e5 b2 23 f0       	mov    %al,0xf023b2e5
f010522a:	0f b6 05 e5 b2 23 f0 	movzbl 0xf023b2e5,%eax
f0105231:	83 c8 80             	or     $0xffffff80,%eax
f0105234:	a2 e5 b2 23 f0       	mov    %al,0xf023b2e5
f0105239:	a1 84 5f 10 f0       	mov    0xf0105f84,%eax
f010523e:	c1 e8 10             	shr    $0x10,%eax
f0105241:	66 a3 e6 b2 23 f0    	mov    %ax,0xf023b2e6
	SETGATE(idt[48], 0, GD_KT, idt_table[16], 3);
f0105247:	a1 88 5f 10 f0       	mov    0xf0105f88,%eax
f010524c:	66 a3 e0 b3 23 f0    	mov    %ax,0xf023b3e0
f0105252:	66 c7 05 e2 b3 23 f0 	movw   $0x8,0xf023b3e2
f0105259:	08 00 
f010525b:	0f b6 05 e4 b3 23 f0 	movzbl 0xf023b3e4,%eax
f0105262:	83 e0 e0             	and    $0xffffffe0,%eax
f0105265:	a2 e4 b3 23 f0       	mov    %al,0xf023b3e4
f010526a:	0f b6 05 e4 b3 23 f0 	movzbl 0xf023b3e4,%eax
f0105271:	83 e0 1f             	and    $0x1f,%eax
f0105274:	a2 e4 b3 23 f0       	mov    %al,0xf023b3e4
f0105279:	0f b6 05 e5 b3 23 f0 	movzbl 0xf023b3e5,%eax
f0105280:	83 e0 f0             	and    $0xfffffff0,%eax
f0105283:	83 c8 0e             	or     $0xe,%eax
f0105286:	a2 e5 b3 23 f0       	mov    %al,0xf023b3e5
f010528b:	0f b6 05 e5 b3 23 f0 	movzbl 0xf023b3e5,%eax
f0105292:	83 e0 ef             	and    $0xffffffef,%eax
f0105295:	a2 e5 b3 23 f0       	mov    %al,0xf023b3e5
f010529a:	0f b6 05 e5 b3 23 f0 	movzbl 0xf023b3e5,%eax
f01052a1:	83 c8 60             	or     $0x60,%eax
f01052a4:	a2 e5 b3 23 f0       	mov    %al,0xf023b3e5
f01052a9:	0f b6 05 e5 b3 23 f0 	movzbl 0xf023b3e5,%eax
f01052b0:	83 c8 80             	or     $0xffffff80,%eax
f01052b3:	a2 e5 b3 23 f0       	mov    %al,0xf023b3e5
f01052b8:	a1 88 5f 10 f0       	mov    0xf0105f88,%eax
f01052bd:	c1 e8 10             	shr    $0x10,%eax
f01052c0:	66 a3 e6 b3 23 f0    	mov    %ax,0xf023b3e6
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER],0,GD_KT,idt_table[17],0);
f01052c6:	a1 8c 5f 10 f0       	mov    0xf0105f8c,%eax
f01052cb:	66 a3 60 b3 23 f0    	mov    %ax,0xf023b360
f01052d1:	66 c7 05 62 b3 23 f0 	movw   $0x8,0xf023b362
f01052d8:	08 00 
f01052da:	0f b6 05 64 b3 23 f0 	movzbl 0xf023b364,%eax
f01052e1:	83 e0 e0             	and    $0xffffffe0,%eax
f01052e4:	a2 64 b3 23 f0       	mov    %al,0xf023b364
f01052e9:	0f b6 05 64 b3 23 f0 	movzbl 0xf023b364,%eax
f01052f0:	83 e0 1f             	and    $0x1f,%eax
f01052f3:	a2 64 b3 23 f0       	mov    %al,0xf023b364
f01052f8:	0f b6 05 65 b3 23 f0 	movzbl 0xf023b365,%eax
f01052ff:	83 e0 f0             	and    $0xfffffff0,%eax
f0105302:	83 c8 0e             	or     $0xe,%eax
f0105305:	a2 65 b3 23 f0       	mov    %al,0xf023b365
f010530a:	0f b6 05 65 b3 23 f0 	movzbl 0xf023b365,%eax
f0105311:	83 e0 ef             	and    $0xffffffef,%eax
f0105314:	a2 65 b3 23 f0       	mov    %al,0xf023b365
f0105319:	0f b6 05 65 b3 23 f0 	movzbl 0xf023b365,%eax
f0105320:	83 e0 9f             	and    $0xffffff9f,%eax
f0105323:	a2 65 b3 23 f0       	mov    %al,0xf023b365
f0105328:	0f b6 05 65 b3 23 f0 	movzbl 0xf023b365,%eax
f010532f:	83 c8 80             	or     $0xffffff80,%eax
f0105332:	a2 65 b3 23 f0       	mov    %al,0xf023b365
f0105337:	a1 8c 5f 10 f0       	mov    0xf0105f8c,%eax
f010533c:	c1 e8 10             	shr    $0x10,%eax
f010533f:	66 a3 66 b3 23 f0    	mov    %ax,0xf023b366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD],0,GD_KT,idt_table[18],0);
f0105345:	a1 90 5f 10 f0       	mov    0xf0105f90,%eax
f010534a:	66 a3 68 b3 23 f0    	mov    %ax,0xf023b368
f0105350:	66 c7 05 6a b3 23 f0 	movw   $0x8,0xf023b36a
f0105357:	08 00 
f0105359:	0f b6 05 6c b3 23 f0 	movzbl 0xf023b36c,%eax
f0105360:	83 e0 e0             	and    $0xffffffe0,%eax
f0105363:	a2 6c b3 23 f0       	mov    %al,0xf023b36c
f0105368:	0f b6 05 6c b3 23 f0 	movzbl 0xf023b36c,%eax
f010536f:	83 e0 1f             	and    $0x1f,%eax
f0105372:	a2 6c b3 23 f0       	mov    %al,0xf023b36c
f0105377:	0f b6 05 6d b3 23 f0 	movzbl 0xf023b36d,%eax
f010537e:	83 e0 f0             	and    $0xfffffff0,%eax
f0105381:	83 c8 0e             	or     $0xe,%eax
f0105384:	a2 6d b3 23 f0       	mov    %al,0xf023b36d
f0105389:	0f b6 05 6d b3 23 f0 	movzbl 0xf023b36d,%eax
f0105390:	83 e0 ef             	and    $0xffffffef,%eax
f0105393:	a2 6d b3 23 f0       	mov    %al,0xf023b36d
f0105398:	0f b6 05 6d b3 23 f0 	movzbl 0xf023b36d,%eax
f010539f:	83 e0 9f             	and    $0xffffff9f,%eax
f01053a2:	a2 6d b3 23 f0       	mov    %al,0xf023b36d
f01053a7:	0f b6 05 6d b3 23 f0 	movzbl 0xf023b36d,%eax
f01053ae:	83 c8 80             	or     $0xffffff80,%eax
f01053b1:	a2 6d b3 23 f0       	mov    %al,0xf023b36d
f01053b6:	a1 90 5f 10 f0       	mov    0xf0105f90,%eax
f01053bb:	c1 e8 10             	shr    $0x10,%eax
f01053be:	66 a3 6e b3 23 f0    	mov    %ax,0xf023b36e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL],0,GD_KT,idt_table[19],0);
f01053c4:	a1 94 5f 10 f0       	mov    0xf0105f94,%eax
f01053c9:	66 a3 80 b3 23 f0    	mov    %ax,0xf023b380
f01053cf:	66 c7 05 82 b3 23 f0 	movw   $0x8,0xf023b382
f01053d6:	08 00 
f01053d8:	0f b6 05 84 b3 23 f0 	movzbl 0xf023b384,%eax
f01053df:	83 e0 e0             	and    $0xffffffe0,%eax
f01053e2:	a2 84 b3 23 f0       	mov    %al,0xf023b384
f01053e7:	0f b6 05 84 b3 23 f0 	movzbl 0xf023b384,%eax
f01053ee:	83 e0 1f             	and    $0x1f,%eax
f01053f1:	a2 84 b3 23 f0       	mov    %al,0xf023b384
f01053f6:	0f b6 05 85 b3 23 f0 	movzbl 0xf023b385,%eax
f01053fd:	83 e0 f0             	and    $0xfffffff0,%eax
f0105400:	83 c8 0e             	or     $0xe,%eax
f0105403:	a2 85 b3 23 f0       	mov    %al,0xf023b385
f0105408:	0f b6 05 85 b3 23 f0 	movzbl 0xf023b385,%eax
f010540f:	83 e0 ef             	and    $0xffffffef,%eax
f0105412:	a2 85 b3 23 f0       	mov    %al,0xf023b385
f0105417:	0f b6 05 85 b3 23 f0 	movzbl 0xf023b385,%eax
f010541e:	83 e0 9f             	and    $0xffffff9f,%eax
f0105421:	a2 85 b3 23 f0       	mov    %al,0xf023b385
f0105426:	0f b6 05 85 b3 23 f0 	movzbl 0xf023b385,%eax
f010542d:	83 c8 80             	or     $0xffffff80,%eax
f0105430:	a2 85 b3 23 f0       	mov    %al,0xf023b385
f0105435:	a1 94 5f 10 f0       	mov    0xf0105f94,%eax
f010543a:	c1 e8 10             	shr    $0x10,%eax
f010543d:	66 a3 86 b3 23 f0    	mov    %ax,0xf023b386
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS],0,GD_KT,idt_table[20],0);
f0105443:	a1 98 5f 10 f0       	mov    0xf0105f98,%eax
f0105448:	66 a3 98 b3 23 f0    	mov    %ax,0xf023b398
f010544e:	66 c7 05 9a b3 23 f0 	movw   $0x8,0xf023b39a
f0105455:	08 00 
f0105457:	0f b6 05 9c b3 23 f0 	movzbl 0xf023b39c,%eax
f010545e:	83 e0 e0             	and    $0xffffffe0,%eax
f0105461:	a2 9c b3 23 f0       	mov    %al,0xf023b39c
f0105466:	0f b6 05 9c b3 23 f0 	movzbl 0xf023b39c,%eax
f010546d:	83 e0 1f             	and    $0x1f,%eax
f0105470:	a2 9c b3 23 f0       	mov    %al,0xf023b39c
f0105475:	0f b6 05 9d b3 23 f0 	movzbl 0xf023b39d,%eax
f010547c:	83 e0 f0             	and    $0xfffffff0,%eax
f010547f:	83 c8 0e             	or     $0xe,%eax
f0105482:	a2 9d b3 23 f0       	mov    %al,0xf023b39d
f0105487:	0f b6 05 9d b3 23 f0 	movzbl 0xf023b39d,%eax
f010548e:	83 e0 ef             	and    $0xffffffef,%eax
f0105491:	a2 9d b3 23 f0       	mov    %al,0xf023b39d
f0105496:	0f b6 05 9d b3 23 f0 	movzbl 0xf023b39d,%eax
f010549d:	83 e0 9f             	and    $0xffffff9f,%eax
f01054a0:	a2 9d b3 23 f0       	mov    %al,0xf023b39d
f01054a5:	0f b6 05 9d b3 23 f0 	movzbl 0xf023b39d,%eax
f01054ac:	83 c8 80             	or     $0xffffff80,%eax
f01054af:	a2 9d b3 23 f0       	mov    %al,0xf023b39d
f01054b4:	a1 98 5f 10 f0       	mov    0xf0105f98,%eax
f01054b9:	c1 e8 10             	shr    $0x10,%eax
f01054bc:	66 a3 9e b3 23 f0    	mov    %ax,0xf023b39e
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE],0,GD_KT,idt_table[21],0);
f01054c2:	a1 9c 5f 10 f0       	mov    0xf0105f9c,%eax
f01054c7:	66 a3 d0 b3 23 f0    	mov    %ax,0xf023b3d0
f01054cd:	66 c7 05 d2 b3 23 f0 	movw   $0x8,0xf023b3d2
f01054d4:	08 00 
f01054d6:	0f b6 05 d4 b3 23 f0 	movzbl 0xf023b3d4,%eax
f01054dd:	83 e0 e0             	and    $0xffffffe0,%eax
f01054e0:	a2 d4 b3 23 f0       	mov    %al,0xf023b3d4
f01054e5:	0f b6 05 d4 b3 23 f0 	movzbl 0xf023b3d4,%eax
f01054ec:	83 e0 1f             	and    $0x1f,%eax
f01054ef:	a2 d4 b3 23 f0       	mov    %al,0xf023b3d4
f01054f4:	0f b6 05 d5 b3 23 f0 	movzbl 0xf023b3d5,%eax
f01054fb:	83 e0 f0             	and    $0xfffffff0,%eax
f01054fe:	83 c8 0e             	or     $0xe,%eax
f0105501:	a2 d5 b3 23 f0       	mov    %al,0xf023b3d5
f0105506:	0f b6 05 d5 b3 23 f0 	movzbl 0xf023b3d5,%eax
f010550d:	83 e0 ef             	and    $0xffffffef,%eax
f0105510:	a2 d5 b3 23 f0       	mov    %al,0xf023b3d5
f0105515:	0f b6 05 d5 b3 23 f0 	movzbl 0xf023b3d5,%eax
f010551c:	83 e0 9f             	and    $0xffffff9f,%eax
f010551f:	a2 d5 b3 23 f0       	mov    %al,0xf023b3d5
f0105524:	0f b6 05 d5 b3 23 f0 	movzbl 0xf023b3d5,%eax
f010552b:	83 c8 80             	or     $0xffffff80,%eax
f010552e:	a2 d5 b3 23 f0       	mov    %al,0xf023b3d5
f0105533:	a1 9c 5f 10 f0       	mov    0xf0105f9c,%eax
f0105538:	c1 e8 10             	shr    $0x10,%eax
f010553b:	66 a3 d6 b3 23 f0    	mov    %ax,0xf023b3d6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR],0,GD_KT,idt_table[22],0);
f0105541:	a1 a0 5f 10 f0       	mov    0xf0105fa0,%eax
f0105546:	66 a3 f8 b3 23 f0    	mov    %ax,0xf023b3f8
f010554c:	66 c7 05 fa b3 23 f0 	movw   $0x8,0xf023b3fa
f0105553:	08 00 
f0105555:	0f b6 05 fc b3 23 f0 	movzbl 0xf023b3fc,%eax
f010555c:	83 e0 e0             	and    $0xffffffe0,%eax
f010555f:	a2 fc b3 23 f0       	mov    %al,0xf023b3fc
f0105564:	0f b6 05 fc b3 23 f0 	movzbl 0xf023b3fc,%eax
f010556b:	83 e0 1f             	and    $0x1f,%eax
f010556e:	a2 fc b3 23 f0       	mov    %al,0xf023b3fc
f0105573:	0f b6 05 fd b3 23 f0 	movzbl 0xf023b3fd,%eax
f010557a:	83 e0 f0             	and    $0xfffffff0,%eax
f010557d:	83 c8 0e             	or     $0xe,%eax
f0105580:	a2 fd b3 23 f0       	mov    %al,0xf023b3fd
f0105585:	0f b6 05 fd b3 23 f0 	movzbl 0xf023b3fd,%eax
f010558c:	83 e0 ef             	and    $0xffffffef,%eax
f010558f:	a2 fd b3 23 f0       	mov    %al,0xf023b3fd
f0105594:	0f b6 05 fd b3 23 f0 	movzbl 0xf023b3fd,%eax
f010559b:	83 e0 9f             	and    $0xffffff9f,%eax
f010559e:	a2 fd b3 23 f0       	mov    %al,0xf023b3fd
f01055a3:	0f b6 05 fd b3 23 f0 	movzbl 0xf023b3fd,%eax
f01055aa:	83 c8 80             	or     $0xffffff80,%eax
f01055ad:	a2 fd b3 23 f0       	mov    %al,0xf023b3fd
f01055b2:	a1 a0 5f 10 f0       	mov    0xf0105fa0,%eax
f01055b7:	c1 e8 10             	shr    $0x10,%eax
f01055ba:	66 a3 fe b3 23 f0    	mov    %ax,0xf023b3fe
	// Per-CPU setup 
	trap_init_percpu();
f01055c0:	e8 02 00 00 00       	call   f01055c7 <trap_init_percpu>
}
f01055c5:	c9                   	leave  
f01055c6:	c3                   	ret    

f01055c7 <trap_init_percpu>:

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01055c7:	55                   	push   %ebp
f01055c8:	89 e5                	mov    %esp,%ebp
f01055ca:	57                   	push   %edi
f01055cb:	56                   	push   %esi
f01055cc:	53                   	push   %ebx
f01055cd:	83 ec 1c             	sub    $0x1c,%esp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	
	//ts.ts_esp0 = KSTACKTOP;
	// ts.ts_ss0 = GD_KD;
	thiscpu->cpu_ts.ts_esp0 = (uintptr_t)percpu_kstacks[thiscpu->cpu_id];
f01055d0:	e8 f1 2f 00 00       	call   f01085c6 <cpunum>
f01055d5:	89 c3                	mov    %eax,%ebx
f01055d7:	e8 ea 2f 00 00       	call   f01085c6 <cpunum>
f01055dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01055df:	05 20 c0 23 f0       	add    $0xf023c020,%eax
f01055e4:	0f b6 00             	movzbl (%eax),%eax
f01055e7:	0f b6 c0             	movzbl %al,%eax
f01055ea:	c1 e0 0f             	shl    $0xf,%eax
f01055ed:	05 00 d0 23 f0       	add    $0xf023d000,%eax
f01055f2:	6b d3 74             	imul   $0x74,%ebx,%edx
f01055f5:	81 c2 30 c0 23 f0    	add    $0xf023c030,%edx
f01055fb:	89 02                	mov    %eax,(%edx)
    thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01055fd:	e8 c4 2f 00 00       	call   f01085c6 <cpunum>
f0105602:	6b c0 74             	imul   $0x74,%eax,%eax
f0105605:	05 20 c0 23 f0       	add    $0xf023c020,%eax
f010560a:	66 c7 40 14 10 00    	movw   $0x10,0x14(%eax)


	// Initialize the TSS slot of the gdt.
	// gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
					// sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f0105610:	e8 b1 2f 00 00       	call   f01085c6 <cpunum>
f0105615:	6b c0 74             	imul   $0x74,%eax,%eax
f0105618:	05 20 c0 23 f0       	add    $0xf023c020,%eax
f010561d:	0f b6 00             	movzbl (%eax),%eax
f0105620:	0f b6 c0             	movzbl %al,%eax
f0105623:	8d 58 05             	lea    0x5(%eax),%ebx
f0105626:	e8 9b 2f 00 00       	call   f01085c6 <cpunum>
f010562b:	6b c0 74             	imul   $0x74,%eax,%eax
f010562e:	05 20 c0 23 f0       	add    $0xf023c020,%eax
f0105633:	83 c0 0c             	add    $0xc,%eax
f0105636:	89 c7                	mov    %eax,%edi
f0105638:	e8 89 2f 00 00       	call   f01085c6 <cpunum>
f010563d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105640:	05 20 c0 23 f0       	add    $0xf023c020,%eax
f0105645:	83 c0 0c             	add    $0xc,%eax
f0105648:	c1 e8 10             	shr    $0x10,%eax
f010564b:	89 c6                	mov    %eax,%esi
f010564d:	e8 74 2f 00 00       	call   f01085c6 <cpunum>
f0105652:	6b c0 74             	imul   $0x74,%eax,%eax
f0105655:	05 20 c0 23 f0       	add    $0xf023c020,%eax
f010565a:	83 c0 0c             	add    $0xc,%eax
f010565d:	c1 e8 18             	shr    $0x18,%eax
f0105660:	66 c7 04 dd 60 55 12 	movw   $0x67,-0xfedaaa0(,%ebx,8)
f0105667:	f0 67 00 
f010566a:	66 89 3c dd 62 55 12 	mov    %di,-0xfedaa9e(,%ebx,8)
f0105671:	f0 
f0105672:	89 f1                	mov    %esi,%ecx
f0105674:	88 0c dd 64 55 12 f0 	mov    %cl,-0xfedaa9c(,%ebx,8)
f010567b:	0f b6 14 dd 65 55 12 	movzbl -0xfedaa9b(,%ebx,8),%edx
f0105682:	f0 
f0105683:	83 e2 f0             	and    $0xfffffff0,%edx
f0105686:	83 ca 09             	or     $0x9,%edx
f0105689:	88 14 dd 65 55 12 f0 	mov    %dl,-0xfedaa9b(,%ebx,8)
f0105690:	0f b6 14 dd 65 55 12 	movzbl -0xfedaa9b(,%ebx,8),%edx
f0105697:	f0 
f0105698:	83 ca 10             	or     $0x10,%edx
f010569b:	88 14 dd 65 55 12 f0 	mov    %dl,-0xfedaa9b(,%ebx,8)
f01056a2:	0f b6 14 dd 65 55 12 	movzbl -0xfedaa9b(,%ebx,8),%edx
f01056a9:	f0 
f01056aa:	83 e2 9f             	and    $0xffffff9f,%edx
f01056ad:	88 14 dd 65 55 12 f0 	mov    %dl,-0xfedaa9b(,%ebx,8)
f01056b4:	0f b6 14 dd 65 55 12 	movzbl -0xfedaa9b(,%ebx,8),%edx
f01056bb:	f0 
f01056bc:	83 ca 80             	or     $0xffffff80,%edx
f01056bf:	88 14 dd 65 55 12 f0 	mov    %dl,-0xfedaa9b(,%ebx,8)
f01056c6:	0f b6 14 dd 66 55 12 	movzbl -0xfedaa9a(,%ebx,8),%edx
f01056cd:	f0 
f01056ce:	83 e2 f0             	and    $0xfffffff0,%edx
f01056d1:	88 14 dd 66 55 12 f0 	mov    %dl,-0xfedaa9a(,%ebx,8)
f01056d8:	0f b6 14 dd 66 55 12 	movzbl -0xfedaa9a(,%ebx,8),%edx
f01056df:	f0 
f01056e0:	83 e2 ef             	and    $0xffffffef,%edx
f01056e3:	88 14 dd 66 55 12 f0 	mov    %dl,-0xfedaa9a(,%ebx,8)
f01056ea:	0f b6 14 dd 66 55 12 	movzbl -0xfedaa9a(,%ebx,8),%edx
f01056f1:	f0 
f01056f2:	83 e2 df             	and    $0xffffffdf,%edx
f01056f5:	88 14 dd 66 55 12 f0 	mov    %dl,-0xfedaa9a(,%ebx,8)
f01056fc:	0f b6 14 dd 66 55 12 	movzbl -0xfedaa9a(,%ebx,8),%edx
f0105703:	f0 
f0105704:	83 ca 40             	or     $0x40,%edx
f0105707:	88 14 dd 66 55 12 f0 	mov    %dl,-0xfedaa9a(,%ebx,8)
f010570e:	0f b6 14 dd 66 55 12 	movzbl -0xfedaa9a(,%ebx,8),%edx
f0105715:	f0 
f0105716:	83 e2 7f             	and    $0x7f,%edx
f0105719:	88 14 dd 66 55 12 f0 	mov    %dl,-0xfedaa9a(,%ebx,8)
f0105720:	88 04 dd 67 55 12 f0 	mov    %al,-0xfedaa99(,%ebx,8)
                    sizeof(struct Taskstate) - 1, 0);

	// gdt[GD_TSS0 >> 3].sd_s = 0;
	// gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id].sd_s = 0;
	 gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id].sd_s = 0;
f0105727:	e8 9a 2e 00 00       	call   f01085c6 <cpunum>
f010572c:	6b c0 74             	imul   $0x74,%eax,%eax
f010572f:	05 20 c0 23 f0       	add    $0xf023c020,%eax
f0105734:	0f b6 00             	movzbl (%eax),%eax
f0105737:	0f b6 c0             	movzbl %al,%eax
f010573a:	83 c0 05             	add    $0x5,%eax
f010573d:	0f b6 14 c5 65 55 12 	movzbl -0xfedaa9b(,%eax,8),%edx
f0105744:	f0 
f0105745:	83 e2 ef             	and    $0xffffffef,%edx
f0105748:	88 14 c5 65 55 12 f0 	mov    %dl,-0xfedaa9b(,%eax,8)
	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	
	// ltr(GD_TSS0);
	 ltr(GD_TSS0 + (thiscpu->cpu_id)*sizeof(struct Segdesc));
f010574f:	e8 72 2e 00 00       	call   f01085c6 <cpunum>
f0105754:	6b c0 74             	imul   $0x74,%eax,%eax
f0105757:	05 20 c0 23 f0       	add    $0xf023c020,%eax
f010575c:	0f b6 00             	movzbl (%eax),%eax
f010575f:	0f b6 c0             	movzbl %al,%eax
f0105762:	83 c0 05             	add    $0x5,%eax
f0105765:	c1 e0 03             	shl    $0x3,%eax
f0105768:	0f b7 c0             	movzwl %ax,%eax
f010576b:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010576f:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
f0105773:	0f 00 d8             	ltr    %ax
f0105776:	c7 45 e0 d0 55 12 f0 	movl   $0xf01255d0,-0x20(%ebp)
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f010577d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105780:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0105783:	83 c4 1c             	add    $0x1c,%esp
f0105786:	5b                   	pop    %ebx
f0105787:	5e                   	pop    %esi
f0105788:	5f                   	pop    %edi
f0105789:	5d                   	pop    %ebp
f010578a:	c3                   	ret    

f010578b <print_trapframe>:

void
print_trapframe(struct Trapframe *tf)
{
f010578b:	55                   	push   %ebp
f010578c:	89 e5                	mov    %esp,%ebp
f010578e:	83 ec 28             	sub    $0x28,%esp
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0105791:	e8 30 2e 00 00       	call   f01085c6 <cpunum>
f0105796:	89 44 24 08          	mov    %eax,0x8(%esp)
f010579a:	8b 45 08             	mov    0x8(%ebp),%eax
f010579d:	89 44 24 04          	mov    %eax,0x4(%esp)
f01057a1:	c7 04 24 ae 9e 10 f0 	movl   $0xf0109eae,(%esp)
f01057a8:	e8 12 f8 ff ff       	call   f0104fbf <cprintf>
	print_regs(&tf->tf_regs);
f01057ad:	8b 45 08             	mov    0x8(%ebp),%eax
f01057b0:	89 04 24             	mov    %eax,(%esp)
f01057b3:	e8 a5 01 00 00       	call   f010595d <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01057b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01057bb:	0f b7 40 20          	movzwl 0x20(%eax),%eax
f01057bf:	0f b7 c0             	movzwl %ax,%eax
f01057c2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01057c6:	c7 04 24 cc 9e 10 f0 	movl   $0xf0109ecc,(%esp)
f01057cd:	e8 ed f7 ff ff       	call   f0104fbf <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01057d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01057d5:	0f b7 40 24          	movzwl 0x24(%eax),%eax
f01057d9:	0f b7 c0             	movzwl %ax,%eax
f01057dc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01057e0:	c7 04 24 df 9e 10 f0 	movl   $0xf0109edf,(%esp)
f01057e7:	e8 d3 f7 ff ff       	call   f0104fbf <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01057ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01057ef:	8b 40 28             	mov    0x28(%eax),%eax
f01057f2:	89 04 24             	mov    %eax,(%esp)
f01057f5:	e8 19 f8 ff ff       	call   f0105013 <trapname>
f01057fa:	8b 55 08             	mov    0x8(%ebp),%edx
f01057fd:	8b 52 28             	mov    0x28(%edx),%edx
f0105800:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105804:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105808:	c7 04 24 f2 9e 10 f0 	movl   $0xf0109ef2,(%esp)
f010580f:	e8 ab f7 ff ff       	call   f0104fbf <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0105814:	a1 c8 ba 23 f0       	mov    0xf023bac8,%eax
f0105819:	39 45 08             	cmp    %eax,0x8(%ebp)
f010581c:	75 24                	jne    f0105842 <print_trapframe+0xb7>
f010581e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105821:	8b 40 28             	mov    0x28(%eax),%eax
f0105824:	83 f8 0e             	cmp    $0xe,%eax
f0105827:	75 19                	jne    f0105842 <print_trapframe+0xb7>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0105829:	0f 20 d0             	mov    %cr2,%eax
f010582c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	return val;
f010582f:	8b 45 f4             	mov    -0xc(%ebp),%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0105832:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105836:	c7 04 24 04 9f 10 f0 	movl   $0xf0109f04,(%esp)
f010583d:	e8 7d f7 ff ff       	call   f0104fbf <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0105842:	8b 45 08             	mov    0x8(%ebp),%eax
f0105845:	8b 40 2c             	mov    0x2c(%eax),%eax
f0105848:	89 44 24 04          	mov    %eax,0x4(%esp)
f010584c:	c7 04 24 13 9f 10 f0 	movl   $0xf0109f13,(%esp)
f0105853:	e8 67 f7 ff ff       	call   f0104fbf <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0105858:	8b 45 08             	mov    0x8(%ebp),%eax
f010585b:	8b 40 28             	mov    0x28(%eax),%eax
f010585e:	83 f8 0e             	cmp    $0xe,%eax
f0105861:	75 65                	jne    f01058c8 <print_trapframe+0x13d>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0105863:	8b 45 08             	mov    0x8(%ebp),%eax
f0105866:	8b 40 2c             	mov    0x2c(%eax),%eax
f0105869:	83 e0 01             	and    $0x1,%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010586c:	85 c0                	test   %eax,%eax
f010586e:	74 07                	je     f0105877 <print_trapframe+0xec>
f0105870:	b9 21 9f 10 f0       	mov    $0xf0109f21,%ecx
f0105875:	eb 05                	jmp    f010587c <print_trapframe+0xf1>
f0105877:	b9 2c 9f 10 f0       	mov    $0xf0109f2c,%ecx
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
f010587c:	8b 45 08             	mov    0x8(%ebp),%eax
f010587f:	8b 40 2c             	mov    0x2c(%eax),%eax
f0105882:	83 e0 02             	and    $0x2,%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0105885:	85 c0                	test   %eax,%eax
f0105887:	74 07                	je     f0105890 <print_trapframe+0x105>
f0105889:	ba 38 9f 10 f0       	mov    $0xf0109f38,%edx
f010588e:	eb 05                	jmp    f0105895 <print_trapframe+0x10a>
f0105890:	ba 3e 9f 10 f0       	mov    $0xf0109f3e,%edx
			tf->tf_err & 4 ? "user" : "kernel",
f0105895:	8b 45 08             	mov    0x8(%ebp),%eax
f0105898:	8b 40 2c             	mov    0x2c(%eax),%eax
f010589b:	83 e0 04             	and    $0x4,%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010589e:	85 c0                	test   %eax,%eax
f01058a0:	74 07                	je     f01058a9 <print_trapframe+0x11e>
f01058a2:	b8 43 9f 10 f0       	mov    $0xf0109f43,%eax
f01058a7:	eb 05                	jmp    f01058ae <print_trapframe+0x123>
f01058a9:	b8 48 9f 10 f0       	mov    $0xf0109f48,%eax
f01058ae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01058b2:	89 54 24 08          	mov    %edx,0x8(%esp)
f01058b6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01058ba:	c7 04 24 4f 9f 10 f0 	movl   $0xf0109f4f,(%esp)
f01058c1:	e8 f9 f6 ff ff       	call   f0104fbf <cprintf>
f01058c6:	eb 0c                	jmp    f01058d4 <print_trapframe+0x149>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01058c8:	c7 04 24 5e 9f 10 f0 	movl   $0xf0109f5e,(%esp)
f01058cf:	e8 eb f6 ff ff       	call   f0104fbf <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01058d4:	8b 45 08             	mov    0x8(%ebp),%eax
f01058d7:	8b 40 30             	mov    0x30(%eax),%eax
f01058da:	89 44 24 04          	mov    %eax,0x4(%esp)
f01058de:	c7 04 24 60 9f 10 f0 	movl   $0xf0109f60,(%esp)
f01058e5:	e8 d5 f6 ff ff       	call   f0104fbf <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01058ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01058ed:	0f b7 40 34          	movzwl 0x34(%eax),%eax
f01058f1:	0f b7 c0             	movzwl %ax,%eax
f01058f4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01058f8:	c7 04 24 6f 9f 10 f0 	movl   $0xf0109f6f,(%esp)
f01058ff:	e8 bb f6 ff ff       	call   f0104fbf <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0105904:	8b 45 08             	mov    0x8(%ebp),%eax
f0105907:	8b 40 38             	mov    0x38(%eax),%eax
f010590a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010590e:	c7 04 24 82 9f 10 f0 	movl   $0xf0109f82,(%esp)
f0105915:	e8 a5 f6 ff ff       	call   f0104fbf <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010591a:	8b 45 08             	mov    0x8(%ebp),%eax
f010591d:	0f b7 40 34          	movzwl 0x34(%eax),%eax
f0105921:	0f b7 c0             	movzwl %ax,%eax
f0105924:	83 e0 03             	and    $0x3,%eax
f0105927:	85 c0                	test   %eax,%eax
f0105929:	74 30                	je     f010595b <print_trapframe+0x1d0>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010592b:	8b 45 08             	mov    0x8(%ebp),%eax
f010592e:	8b 40 3c             	mov    0x3c(%eax),%eax
f0105931:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105935:	c7 04 24 91 9f 10 f0 	movl   $0xf0109f91,(%esp)
f010593c:	e8 7e f6 ff ff       	call   f0104fbf <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0105941:	8b 45 08             	mov    0x8(%ebp),%eax
f0105944:	0f b7 40 40          	movzwl 0x40(%eax),%eax
f0105948:	0f b7 c0             	movzwl %ax,%eax
f010594b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010594f:	c7 04 24 a0 9f 10 f0 	movl   $0xf0109fa0,(%esp)
f0105956:	e8 64 f6 ff ff       	call   f0104fbf <cprintf>
	}
}
f010595b:	c9                   	leave  
f010595c:	c3                   	ret    

f010595d <print_regs>:

void
print_regs(struct PushRegs *regs)
{
f010595d:	55                   	push   %ebp
f010595e:	89 e5                	mov    %esp,%ebp
f0105960:	83 ec 18             	sub    $0x18,%esp
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0105963:	8b 45 08             	mov    0x8(%ebp),%eax
f0105966:	8b 00                	mov    (%eax),%eax
f0105968:	89 44 24 04          	mov    %eax,0x4(%esp)
f010596c:	c7 04 24 b3 9f 10 f0 	movl   $0xf0109fb3,(%esp)
f0105973:	e8 47 f6 ff ff       	call   f0104fbf <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0105978:	8b 45 08             	mov    0x8(%ebp),%eax
f010597b:	8b 40 04             	mov    0x4(%eax),%eax
f010597e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105982:	c7 04 24 c2 9f 10 f0 	movl   $0xf0109fc2,(%esp)
f0105989:	e8 31 f6 ff ff       	call   f0104fbf <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010598e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105991:	8b 40 08             	mov    0x8(%eax),%eax
f0105994:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105998:	c7 04 24 d1 9f 10 f0 	movl   $0xf0109fd1,(%esp)
f010599f:	e8 1b f6 ff ff       	call   f0104fbf <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01059a4:	8b 45 08             	mov    0x8(%ebp),%eax
f01059a7:	8b 40 0c             	mov    0xc(%eax),%eax
f01059aa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01059ae:	c7 04 24 e0 9f 10 f0 	movl   $0xf0109fe0,(%esp)
f01059b5:	e8 05 f6 ff ff       	call   f0104fbf <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01059ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01059bd:	8b 40 10             	mov    0x10(%eax),%eax
f01059c0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01059c4:	c7 04 24 ef 9f 10 f0 	movl   $0xf0109fef,(%esp)
f01059cb:	e8 ef f5 ff ff       	call   f0104fbf <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01059d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01059d3:	8b 40 14             	mov    0x14(%eax),%eax
f01059d6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01059da:	c7 04 24 fe 9f 10 f0 	movl   $0xf0109ffe,(%esp)
f01059e1:	e8 d9 f5 ff ff       	call   f0104fbf <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01059e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01059e9:	8b 40 18             	mov    0x18(%eax),%eax
f01059ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01059f0:	c7 04 24 0d a0 10 f0 	movl   $0xf010a00d,(%esp)
f01059f7:	e8 c3 f5 ff ff       	call   f0104fbf <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01059fc:	8b 45 08             	mov    0x8(%ebp),%eax
f01059ff:	8b 40 1c             	mov    0x1c(%eax),%eax
f0105a02:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a06:	c7 04 24 1c a0 10 f0 	movl   $0xf010a01c,(%esp)
f0105a0d:	e8 ad f5 ff ff       	call   f0104fbf <cprintf>
}
f0105a12:	c9                   	leave  
f0105a13:	c3                   	ret    

f0105a14 <trap_dispatch>:

static void
trap_dispatch(struct Trapframe *tf)
{
f0105a14:	55                   	push   %ebp
f0105a15:	89 e5                	mov    %esp,%ebp
f0105a17:	57                   	push   %edi
f0105a18:	56                   	push   %esi
f0105a19:	53                   	push   %ebx
f0105a1a:	83 ec 2c             	sub    $0x2c,%esp
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if(tf->tf_trapno == T_PGFLT)
f0105a1d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a20:	8b 40 28             	mov    0x28(%eax),%eax
f0105a23:	83 f8 0e             	cmp    $0xe,%eax
f0105a26:	75 10                	jne    f0105a38 <trap_dispatch+0x24>
	{
		page_fault_handler(tf);
f0105a28:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a2b:	89 04 24             	mov    %eax,(%esp)
f0105a2e:	e8 9b 02 00 00       	call   f0105cce <page_fault_handler>
		return;
f0105a33:	e9 f7 00 00 00       	jmp    f0105b2f <trap_dispatch+0x11b>
	}
	else if(tf->tf_trapno == T_BRKPT)
f0105a38:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a3b:	8b 40 28             	mov    0x28(%eax),%eax
f0105a3e:	83 f8 03             	cmp    $0x3,%eax
f0105a41:	75 10                	jne    f0105a53 <trap_dispatch+0x3f>
	{
		monitor(tf);
f0105a43:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a46:	89 04 24             	mov    %eax,(%esp)
f0105a49:	e8 03 b6 ff ff       	call   f0101051 <monitor>
		return;
f0105a4e:	e9 dc 00 00 00       	jmp    f0105b2f <trap_dispatch+0x11b>
	}
	else if(tf->tf_trapno == T_SYSCALL)
f0105a53:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a56:	8b 40 28             	mov    0x28(%eax),%eax
f0105a59:	83 f8 30             	cmp    $0x30,%eax
f0105a5c:	75 4c                	jne    f0105aaa <trap_dispatch+0x96>
	{
		tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax,tf->tf_regs.reg_edx,tf->tf_regs.reg_ecx,tf->tf_regs.reg_ebx,tf->tf_regs.reg_edi,tf->tf_regs.reg_esi);
f0105a5e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a61:	8b 78 04             	mov    0x4(%eax),%edi
f0105a64:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a67:	8b 30                	mov    (%eax),%esi
f0105a69:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a6c:	8b 58 10             	mov    0x10(%eax),%ebx
f0105a6f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a72:	8b 48 18             	mov    0x18(%eax),%ecx
f0105a75:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a78:	8b 50 14             	mov    0x14(%eax),%edx
f0105a7b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a7e:	8b 40 1c             	mov    0x1c(%eax),%eax
f0105a81:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0105a85:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105a89:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105a8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105a91:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105a95:	89 04 24             	mov    %eax,(%esp)
f0105a98:	e8 d0 0f 00 00       	call   f0106a6d <syscall>
f0105a9d:	89 c2                	mov    %eax,%edx
f0105a9f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105aa2:	89 50 1c             	mov    %edx,0x1c(%eax)
		return;	
f0105aa5:	e9 85 00 00 00       	jmp    f0105b2f <trap_dispatch+0x11b>
	}
	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0105aaa:	8b 45 08             	mov    0x8(%ebp),%eax
f0105aad:	8b 40 28             	mov    0x28(%eax),%eax
f0105ab0:	83 f8 27             	cmp    $0x27,%eax
f0105ab3:	75 19                	jne    f0105ace <trap_dispatch+0xba>
		cprintf("Spurious interrupt on irq 7\n");
f0105ab5:	c7 04 24 2b a0 10 f0 	movl   $0xf010a02b,(%esp)
f0105abc:	e8 fe f4 ff ff       	call   f0104fbf <cprintf>
		print_trapframe(tf);
f0105ac1:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ac4:	89 04 24             	mov    %eax,(%esp)
f0105ac7:	e8 bf fc ff ff       	call   f010578b <print_trapframe>
		return;
f0105acc:	eb 61                	jmp    f0105b2f <trap_dispatch+0x11b>


	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) 
f0105ace:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ad1:	8b 40 28             	mov    0x28(%eax),%eax
f0105ad4:	83 f8 20             	cmp    $0x20,%eax
f0105ad7:	75 0a                	jne    f0105ae3 <trap_dispatch+0xcf>
	{
		lapic_eoi();
f0105ad9:	e8 0a 2b 00 00       	call   f01085e8 <lapic_eoi>
		sched_yield();
f0105ade:	e8 3e 05 00 00       	call   f0106021 <sched_yield>
		return;
	}
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0105ae3:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ae6:	89 04 24             	mov    %eax,(%esp)
f0105ae9:	e8 9d fc ff ff       	call   f010578b <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0105aee:	8b 45 08             	mov    0x8(%ebp),%eax
f0105af1:	0f b7 40 34          	movzwl 0x34(%eax),%eax
f0105af5:	66 83 f8 08          	cmp    $0x8,%ax
f0105af9:	75 1c                	jne    f0105b17 <trap_dispatch+0x103>
		panic("unhandled trap in kernel");
f0105afb:	c7 44 24 08 48 a0 10 	movl   $0xf010a048,0x8(%esp)
f0105b02:	f0 
f0105b03:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
f0105b0a:	00 
f0105b0b:	c7 04 24 61 a0 10 f0 	movl   $0xf010a061,(%esp)
f0105b12:	e8 e0 a7 ff ff       	call   f01002f7 <_panic>
	else {
		env_destroy(curenv);
f0105b17:	e8 aa 2a 00 00       	call   f01085c6 <cpunum>
f0105b1c:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b1f:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0105b24:	8b 00                	mov    (%eax),%eax
f0105b26:	89 04 24             	mov    %eax,(%esp)
f0105b29:	e8 5c f0 ff ff       	call   f0104b8a <env_destroy>
		return;
f0105b2e:	90                   	nop
	}
	

	
}
f0105b2f:	83 c4 2c             	add    $0x2c,%esp
f0105b32:	5b                   	pop    %ebx
f0105b33:	5e                   	pop    %esi
f0105b34:	5f                   	pop    %edi
f0105b35:	5d                   	pop    %ebp
f0105b36:	c3                   	ret    

f0105b37 <trap>:

void
trap(struct Trapframe *tf)
{
f0105b37:	55                   	push   %ebp
f0105b38:	89 e5                	mov    %esp,%ebp
f0105b3a:	57                   	push   %edi
f0105b3b:	56                   	push   %esi
f0105b3c:	53                   	push   %ebx
f0105b3d:	83 ec 2c             	sub    $0x2c,%esp
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0105b40:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0105b41:	a1 e0 be 23 f0       	mov    0xf023bee0,%eax
f0105b46:	85 c0                	test   %eax,%eax
f0105b48:	74 01                	je     f0105b4b <trap+0x14>
		asm volatile("hlt");
f0105b4a:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0105b4b:	e8 76 2a 00 00       	call   f01085c6 <cpunum>
f0105b50:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b53:	05 20 c0 23 f0       	add    $0xf023c020,%eax
f0105b58:	83 c0 04             	add    $0x4,%eax
f0105b5b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0105b62:	00 
f0105b63:	89 04 24             	mov    %eax,(%esp)
f0105b66:	e8 7a f4 ff ff       	call   f0104fe5 <xchg>
f0105b6b:	83 f8 02             	cmp    $0x2,%eax
f0105b6e:	75 05                	jne    f0105b75 <trap+0x3e>
		lock_kernel();
f0105b70:	e8 8a f4 ff ff       	call   f0104fff <lock_kernel>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0105b75:	9c                   	pushf  
f0105b76:	58                   	pop    %eax
f0105b77:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	return eflags;
f0105b7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0105b7d:	25 00 02 00 00       	and    $0x200,%eax
f0105b82:	85 c0                	test   %eax,%eax
f0105b84:	74 24                	je     f0105baa <trap+0x73>
f0105b86:	c7 44 24 0c 6d a0 10 	movl   $0xf010a06d,0xc(%esp)
f0105b8d:	f0 
f0105b8e:	c7 44 24 08 86 a0 10 	movl   $0xf010a086,0x8(%esp)
f0105b95:	f0 
f0105b96:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
f0105b9d:	00 
f0105b9e:	c7 04 24 61 a0 10 f0 	movl   $0xf010a061,(%esp)
f0105ba5:	e8 4d a7 ff ff       	call   f01002f7 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0105baa:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bad:	0f b7 40 34          	movzwl 0x34(%eax),%eax
f0105bb1:	0f b7 c0             	movzwl %ax,%eax
f0105bb4:	83 e0 03             	and    $0x3,%eax
f0105bb7:	83 f8 03             	cmp    $0x3,%eax
f0105bba:	0f 85 b5 00 00 00    	jne    f0105c75 <trap+0x13e>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
f0105bc0:	e8 3a f4 ff ff       	call   f0104fff <lock_kernel>
		assert(curenv);
f0105bc5:	e8 fc 29 00 00       	call   f01085c6 <cpunum>
f0105bca:	6b c0 74             	imul   $0x74,%eax,%eax
f0105bcd:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0105bd2:	8b 00                	mov    (%eax),%eax
f0105bd4:	85 c0                	test   %eax,%eax
f0105bd6:	75 24                	jne    f0105bfc <trap+0xc5>
f0105bd8:	c7 44 24 0c 9b a0 10 	movl   $0xf010a09b,0xc(%esp)
f0105bdf:	f0 
f0105be0:	c7 44 24 08 86 a0 10 	movl   $0xf010a086,0x8(%esp)
f0105be7:	f0 
f0105be8:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
f0105bef:	00 
f0105bf0:	c7 04 24 61 a0 10 f0 	movl   $0xf010a061,(%esp)
f0105bf7:	e8 fb a6 ff ff       	call   f01002f7 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0105bfc:	e8 c5 29 00 00       	call   f01085c6 <cpunum>
f0105c01:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c04:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0105c09:	8b 00                	mov    (%eax),%eax
f0105c0b:	8b 40 54             	mov    0x54(%eax),%eax
f0105c0e:	83 f8 01             	cmp    $0x1,%eax
f0105c11:	75 2f                	jne    f0105c42 <trap+0x10b>
			env_free(curenv);
f0105c13:	e8 ae 29 00 00       	call   f01085c6 <cpunum>
f0105c18:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c1b:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0105c20:	8b 00                	mov    (%eax),%eax
f0105c22:	89 04 24             	mov    %eax,(%esp)
f0105c25:	e8 8f ed ff ff       	call   f01049b9 <env_free>
			curenv = NULL;
f0105c2a:	e8 97 29 00 00       	call   f01085c6 <cpunum>
f0105c2f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c32:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0105c37:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			sched_yield();
f0105c3d:	e8 df 03 00 00       	call   f0106021 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0105c42:	e8 7f 29 00 00       	call   f01085c6 <cpunum>
f0105c47:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c4a:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0105c4f:	8b 10                	mov    (%eax),%edx
f0105c51:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c54:	89 c3                	mov    %eax,%ebx
f0105c56:	b8 11 00 00 00       	mov    $0x11,%eax
f0105c5b:	89 d7                	mov    %edx,%edi
f0105c5d:	89 de                	mov    %ebx,%esi
f0105c5f:	89 c1                	mov    %eax,%ecx
f0105c61:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0105c63:	e8 5e 29 00 00       	call   f01085c6 <cpunum>
f0105c68:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c6b:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0105c70:	8b 00                	mov    (%eax),%eax
f0105c72:	89 45 08             	mov    %eax,0x8(%ebp)
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0105c75:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c78:	a3 c8 ba 23 f0       	mov    %eax,0xf023bac8

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
f0105c7d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c80:	89 04 24             	mov    %eax,(%esp)
f0105c83:	e8 8c fd ff ff       	call   f0105a14 <trap_dispatch>

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0105c88:	e8 39 29 00 00       	call   f01085c6 <cpunum>
f0105c8d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c90:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0105c95:	8b 00                	mov    (%eax),%eax
f0105c97:	85 c0                	test   %eax,%eax
f0105c99:	74 2e                	je     f0105cc9 <trap+0x192>
f0105c9b:	e8 26 29 00 00       	call   f01085c6 <cpunum>
f0105ca0:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ca3:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0105ca8:	8b 00                	mov    (%eax),%eax
f0105caa:	8b 40 54             	mov    0x54(%eax),%eax
f0105cad:	83 f8 03             	cmp    $0x3,%eax
f0105cb0:	75 17                	jne    f0105cc9 <trap+0x192>
		env_run(curenv);
f0105cb2:	e8 0f 29 00 00       	call   f01085c6 <cpunum>
f0105cb7:	6b c0 74             	imul   $0x74,%eax,%eax
f0105cba:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0105cbf:	8b 00                	mov    (%eax),%eax
f0105cc1:	89 04 24             	mov    %eax,(%esp)
f0105cc4:	e8 6f ef ff ff       	call   f0104c38 <env_run>
	else
		sched_yield();
f0105cc9:	e8 53 03 00 00       	call   f0106021 <sched_yield>

f0105cce <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0105cce:	55                   	push   %ebp
f0105ccf:	89 e5                	mov    %esp,%ebp
f0105cd1:	53                   	push   %ebx
f0105cd2:	83 ec 24             	sub    $0x24,%esp

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0105cd5:	0f 20 d0             	mov    %cr2,%eax
f0105cd8:	89 45 ec             	mov    %eax,-0x14(%ebp)
	return val;
f0105cdb:	8b 45 ec             	mov    -0x14(%ebp),%eax
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();
f0105cde:	89 45 f0             	mov    %eax,-0x10(%ebp)


	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if((tf->tf_cs & 3) == 0)
f0105ce1:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ce4:	0f b7 40 34          	movzwl 0x34(%eax),%eax
f0105ce8:	0f b7 c0             	movzwl %ax,%eax
f0105ceb:	83 e0 03             	and    $0x3,%eax
f0105cee:	85 c0                	test   %eax,%eax
f0105cf0:	75 1c                	jne    f0105d0e <page_fault_handler+0x40>
	{
		panic("Kernel Page Fault");
f0105cf2:	c7 44 24 08 a2 a0 10 	movl   $0xf010a0a2,0x8(%esp)
f0105cf9:	f0 
f0105cfa:	c7 44 24 04 47 01 00 	movl   $0x147,0x4(%esp)
f0105d01:	00 
f0105d02:	c7 04 24 61 a0 10 f0 	movl   $0xf010a061,(%esp)
f0105d09:	e8 e9 a5 ff ff       	call   f01002f7 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	if(curenv->env_pgfault_upcall != NULL)
f0105d0e:	e8 b3 28 00 00       	call   f01085c6 <cpunum>
f0105d13:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d16:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0105d1b:	8b 00                	mov    (%eax),%eax
f0105d1d:	8b 40 64             	mov    0x64(%eax),%eax
f0105d20:	85 c0                	test   %eax,%eax
f0105d22:	0f 84 04 01 00 00    	je     f0105e2c <page_fault_handler+0x15e>
	{
		struct UTrapframe* utf;
		if(tf->tf_esp>= UXSTACKTOP-PGSIZE && tf->tf_esp< UXSTACKTOP-1)
f0105d28:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d2b:	8b 40 3c             	mov    0x3c(%eax),%eax
f0105d2e:	3d ff ef bf ee       	cmp    $0xeebfefff,%eax
f0105d33:	76 1b                	jbe    f0105d50 <page_fault_handler+0x82>
f0105d35:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d38:	8b 40 3c             	mov    0x3c(%eax),%eax
f0105d3b:	3d fe ff bf ee       	cmp    $0xeebffffe,%eax
f0105d40:	77 0e                	ja     f0105d50 <page_fault_handler+0x82>
		{
			utf = (struct UTrapframe*)(tf->tf_esp - 4- sizeof(struct UTrapframe));
f0105d42:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d45:	8b 40 3c             	mov    0x3c(%eax),%eax
f0105d48:	83 e8 38             	sub    $0x38,%eax
f0105d4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0105d4e:	eb 07                	jmp    f0105d57 <page_fault_handler+0x89>
		}
		else
		{
			utf = (struct UTrapframe*)(UXSTACKTOP - sizeof(struct UTrapframe));
f0105d50:	c7 45 f4 cc ff bf ee 	movl   $0xeebfffcc,-0xc(%ebp)
		}
		user_mem_assert(curenv , (void*)utf , sizeof(struct UTrapframe) , PTE_W);
f0105d57:	e8 6a 28 00 00       	call   f01085c6 <cpunum>
f0105d5c:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d5f:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0105d64:	8b 00                	mov    (%eax),%eax
f0105d66:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0105d6d:	00 
f0105d6e:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f0105d75:	00 
f0105d76:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0105d79:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105d7d:	89 04 24             	mov    %eax,(%esp)
f0105d80:	e8 12 c0 ff ff       	call   f0101d97 <user_mem_assert>
		utf->utf_fault_va = fault_va;
f0105d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105d88:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0105d8b:	89 10                	mov    %edx,(%eax)
		utf->utf_err = tf->tf_err;
f0105d8d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d90:	8b 50 2c             	mov    0x2c(%eax),%edx
f0105d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105d96:	89 50 04             	mov    %edx,0x4(%eax)
		utf->utf_regs = tf->tf_regs;
f0105d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105d9c:	8b 55 08             	mov    0x8(%ebp),%edx
f0105d9f:	8b 0a                	mov    (%edx),%ecx
f0105da1:	89 48 08             	mov    %ecx,0x8(%eax)
f0105da4:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105da7:	89 48 0c             	mov    %ecx,0xc(%eax)
f0105daa:	8b 4a 08             	mov    0x8(%edx),%ecx
f0105dad:	89 48 10             	mov    %ecx,0x10(%eax)
f0105db0:	8b 4a 0c             	mov    0xc(%edx),%ecx
f0105db3:	89 48 14             	mov    %ecx,0x14(%eax)
f0105db6:	8b 4a 10             	mov    0x10(%edx),%ecx
f0105db9:	89 48 18             	mov    %ecx,0x18(%eax)
f0105dbc:	8b 4a 14             	mov    0x14(%edx),%ecx
f0105dbf:	89 48 1c             	mov    %ecx,0x1c(%eax)
f0105dc2:	8b 4a 18             	mov    0x18(%edx),%ecx
f0105dc5:	89 48 20             	mov    %ecx,0x20(%eax)
f0105dc8:	8b 52 1c             	mov    0x1c(%edx),%edx
f0105dcb:	89 50 24             	mov    %edx,0x24(%eax)
		utf->utf_eip = tf->tf_eip;
f0105dce:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dd1:	8b 50 30             	mov    0x30(%eax),%edx
f0105dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105dd7:	89 50 28             	mov    %edx,0x28(%eax)
		utf->utf_eflags = tf->tf_eflags;
f0105dda:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ddd:	8b 50 38             	mov    0x38(%eax),%edx
f0105de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105de3:	89 50 2c             	mov    %edx,0x2c(%eax)
		utf->utf_esp = tf->tf_esp;
f0105de6:	8b 45 08             	mov    0x8(%ebp),%eax
f0105de9:	8b 50 3c             	mov    0x3c(%eax),%edx
f0105dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105def:	89 50 30             	mov    %edx,0x30(%eax)
		tf->tf_esp = (uintptr_t)utf;
f0105df2:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0105df5:	8b 45 08             	mov    0x8(%ebp),%eax
f0105df8:	89 50 3c             	mov    %edx,0x3c(%eax)
		tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0105dfb:	e8 c6 27 00 00       	call   f01085c6 <cpunum>
f0105e00:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e03:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0105e08:	8b 00                	mov    (%eax),%eax
f0105e0a:	8b 40 64             	mov    0x64(%eax),%eax
f0105e0d:	89 c2                	mov    %eax,%edx
f0105e0f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e12:	89 50 30             	mov    %edx,0x30(%eax)
		env_run(curenv);
f0105e15:	e8 ac 27 00 00       	call   f01085c6 <cpunum>
f0105e1a:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e1d:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0105e22:	8b 00                	mov    (%eax),%eax
f0105e24:	89 04 24             	mov    %eax,(%esp)
f0105e27:	e8 0c ee ff ff       	call   f0104c38 <env_run>
	}
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0105e2c:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e2f:	8b 58 30             	mov    0x30(%eax),%ebx
		curenv->env_id, fault_va, tf->tf_eip);
f0105e32:	e8 8f 27 00 00       	call   f01085c6 <cpunum>
f0105e37:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e3a:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0105e3f:	8b 00                	mov    (%eax),%eax
		tf->tf_esp = (uintptr_t)utf;
		tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
		env_run(curenv);
	}
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0105e41:	8b 40 48             	mov    0x48(%eax),%eax
f0105e44:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105e48:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0105e4b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105e4f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e53:	c7 04 24 b4 a0 10 f0 	movl   $0xf010a0b4,(%esp)
f0105e5a:	e8 60 f1 ff ff       	call   f0104fbf <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0105e5f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e62:	89 04 24             	mov    %eax,(%esp)
f0105e65:	e8 21 f9 ff ff       	call   f010578b <print_trapframe>
	env_destroy(curenv);
f0105e6a:	e8 57 27 00 00       	call   f01085c6 <cpunum>
f0105e6f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e72:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0105e77:	8b 00                	mov    (%eax),%eax
f0105e79:	89 04 24             	mov    %eax,(%esp)
f0105e7c:	e8 09 ed ff ff       	call   f0104b8a <env_destroy>
}
f0105e81:	83 c4 24             	add    $0x24,%esp
f0105e84:	5b                   	pop    %ebx
f0105e85:	5d                   	pop    %ebp
f0105e86:	c3                   	ret    
f0105e87:	90                   	nop

f0105e88 <traphandler0>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
.text
TRAPHANDLER_NOEC(traphandler0,0)
f0105e88:	6a 00                	push   $0x0
f0105e8a:	6a 00                	push   $0x0
f0105e8c:	e9 13 01 00 00       	jmp    f0105fa4 <_alltraps>
f0105e91:	90                   	nop

f0105e92 <traphandler1>:
TRAPHANDLER_NOEC(traphandler1,1)
f0105e92:	6a 00                	push   $0x0
f0105e94:	6a 01                	push   $0x1
f0105e96:	e9 09 01 00 00       	jmp    f0105fa4 <_alltraps>
f0105e9b:	90                   	nop

f0105e9c <traphandler2>:
TRAPHANDLER_NOEC(traphandler2,2)
f0105e9c:	6a 00                	push   $0x0
f0105e9e:	6a 02                	push   $0x2
f0105ea0:	e9 ff 00 00 00       	jmp    f0105fa4 <_alltraps>
f0105ea5:	90                   	nop

f0105ea6 <traphandler3>:
TRAPHANDLER_NOEC(traphandler3,3)
f0105ea6:	6a 00                	push   $0x0
f0105ea8:	6a 03                	push   $0x3
f0105eaa:	e9 f5 00 00 00       	jmp    f0105fa4 <_alltraps>
f0105eaf:	90                   	nop

f0105eb0 <traphandler4>:
TRAPHANDLER_NOEC(traphandler4,4)
f0105eb0:	6a 00                	push   $0x0
f0105eb2:	6a 04                	push   $0x4
f0105eb4:	e9 eb 00 00 00       	jmp    f0105fa4 <_alltraps>
f0105eb9:	90                   	nop

f0105eba <traphandler5>:
TRAPHANDLER_NOEC(traphandler5,5)
f0105eba:	6a 00                	push   $0x0
f0105ebc:	6a 05                	push   $0x5
f0105ebe:	e9 e1 00 00 00       	jmp    f0105fa4 <_alltraps>
f0105ec3:	90                   	nop

f0105ec4 <traphandler6>:
TRAPHANDLER_NOEC(traphandler6,6)
f0105ec4:	6a 00                	push   $0x0
f0105ec6:	6a 06                	push   $0x6
f0105ec8:	e9 d7 00 00 00       	jmp    f0105fa4 <_alltraps>
f0105ecd:	90                   	nop

f0105ece <traphandler7>:
TRAPHANDLER_NOEC(traphandler7,7)
f0105ece:	6a 00                	push   $0x0
f0105ed0:	6a 07                	push   $0x7
f0105ed2:	e9 cd 00 00 00       	jmp    f0105fa4 <_alltraps>
f0105ed7:	90                   	nop

f0105ed8 <traphandler8>:
TRAPHANDLER(traphandler8,8)
f0105ed8:	6a 08                	push   $0x8
f0105eda:	e9 c5 00 00 00       	jmp    f0105fa4 <_alltraps>
f0105edf:	90                   	nop

f0105ee0 <traphandler9>:
TRAPHANDLER(traphandler9,9)
f0105ee0:	6a 09                	push   $0x9
f0105ee2:	e9 bd 00 00 00       	jmp    f0105fa4 <_alltraps>
f0105ee7:	90                   	nop

f0105ee8 <traphandler10>:
TRAPHANDLER(traphandler10,10)
f0105ee8:	6a 0a                	push   $0xa
f0105eea:	e9 b5 00 00 00       	jmp    f0105fa4 <_alltraps>
f0105eef:	90                   	nop

f0105ef0 <traphandler11>:
TRAPHANDLER(traphandler11,11)
f0105ef0:	6a 0b                	push   $0xb
f0105ef2:	e9 ad 00 00 00       	jmp    f0105fa4 <_alltraps>
f0105ef7:	90                   	nop

f0105ef8 <traphandler12>:
TRAPHANDLER(traphandler12,12)
f0105ef8:	6a 0c                	push   $0xc
f0105efa:	e9 a5 00 00 00       	jmp    f0105fa4 <_alltraps>
f0105eff:	90                   	nop

f0105f00 <traphandler13>:
TRAPHANDLER(traphandler13,13)
f0105f00:	6a 0d                	push   $0xd
f0105f02:	e9 9d 00 00 00       	jmp    f0105fa4 <_alltraps>
f0105f07:	90                   	nop

f0105f08 <traphandler14>:
TRAPHANDLER(traphandler14,14)
f0105f08:	6a 0e                	push   $0xe
f0105f0a:	e9 95 00 00 00       	jmp    f0105fa4 <_alltraps>
f0105f0f:	90                   	nop

f0105f10 <traphandler16>:
TRAPHANDLER_NOEC(traphandler16,16)
f0105f10:	6a 00                	push   $0x0
f0105f12:	6a 10                	push   $0x10
f0105f14:	e9 8b 00 00 00       	jmp    f0105fa4 <_alltraps>
f0105f19:	90                   	nop

f0105f1a <traphandler48>:
TRAPHANDLER_NOEC(traphandler48,48)
f0105f1a:	6a 00                	push   $0x0
f0105f1c:	6a 30                	push   $0x30
f0105f1e:	e9 81 00 00 00       	jmp    f0105fa4 <_alltraps>
f0105f23:	90                   	nop

f0105f24 <traphandler49>:
TRAPHANDLER_NOEC(traphandler49,IRQ_OFFSET + IRQ_TIMER)
f0105f24:	6a 00                	push   $0x0
f0105f26:	6a 20                	push   $0x20
f0105f28:	eb 7a                	jmp    f0105fa4 <_alltraps>

f0105f2a <traphandler50>:
TRAPHANDLER_NOEC(traphandler50,IRQ_OFFSET + IRQ_KBD)
f0105f2a:	6a 00                	push   $0x0
f0105f2c:	6a 21                	push   $0x21
f0105f2e:	eb 74                	jmp    f0105fa4 <_alltraps>

f0105f30 <traphandler51>:
TRAPHANDLER_NOEC(traphandler51,IRQ_OFFSET + IRQ_SERIAL)
f0105f30:	6a 00                	push   $0x0
f0105f32:	6a 24                	push   $0x24
f0105f34:	eb 6e                	jmp    f0105fa4 <_alltraps>

f0105f36 <traphandler52>:
TRAPHANDLER_NOEC(traphandler52,IRQ_OFFSET + IRQ_SPURIOUS)
f0105f36:	6a 00                	push   $0x0
f0105f38:	6a 27                	push   $0x27
f0105f3a:	eb 68                	jmp    f0105fa4 <_alltraps>

f0105f3c <traphandler53>:
TRAPHANDLER_NOEC(traphandler53,IRQ_OFFSET + IRQ_IDE)
f0105f3c:	6a 00                	push   $0x0
f0105f3e:	6a 2e                	push   $0x2e
f0105f40:	eb 62                	jmp    f0105fa4 <_alltraps>

f0105f42 <traphandler54>:
TRAPHANDLER_NOEC(traphandler54,IRQ_OFFSET + IRQ_ERROR)
f0105f42:	6a 00                	push   $0x0
f0105f44:	6a 33                	push   $0x33
f0105f46:	eb 5c                	jmp    f0105fa4 <_alltraps>

f0105f48 <idt_table>:
f0105f48:	88 5e 10             	mov    %bl,0x10(%esi)
f0105f4b:	f0 92                	lock xchg %eax,%edx
f0105f4d:	5e                   	pop    %esi
f0105f4e:	10 f0                	adc    %dh,%al
f0105f50:	9c                   	pushf  
f0105f51:	5e                   	pop    %esi
f0105f52:	10 f0                	adc    %dh,%al
f0105f54:	a6                   	cmpsb  %es:(%edi),%ds:(%esi)
f0105f55:	5e                   	pop    %esi
f0105f56:	10 f0                	adc    %dh,%al
f0105f58:	b0 5e                	mov    $0x5e,%al
f0105f5a:	10 f0                	adc    %dh,%al
f0105f5c:	ba 5e 10 f0 c4       	mov    $0xc4f0105e,%edx
f0105f61:	5e                   	pop    %esi
f0105f62:	10 f0                	adc    %dh,%al
f0105f64:	ce                   	into   
f0105f65:	5e                   	pop    %esi
f0105f66:	10 f0                	adc    %dh,%al
f0105f68:	d8 5e 10             	fcomps 0x10(%esi)
f0105f6b:	f0 e0 5e             	lock loopne f0105fcc <xchg+0x16>
f0105f6e:	10 f0                	adc    %dh,%al
f0105f70:	e8 5e 10 f0 f0       	call   e1006fd3 <_start+0xe0f06fc7>
f0105f75:	5e                   	pop    %esi
f0105f76:	10 f0                	adc    %dh,%al
f0105f78:	f8                   	clc    
f0105f79:	5e                   	pop    %esi
f0105f7a:	10 f0                	adc    %dh,%al
f0105f7c:	00 5f 10             	add    %bl,0x10(%edi)
f0105f7f:	f0 08 5f 10          	lock or %bl,0x10(%edi)
f0105f83:	f0 10 5f 10          	lock adc %bl,0x10(%edi)
f0105f87:	f0 1a 5f 10          	lock sbb 0x10(%edi),%bl
f0105f8b:	f0 24 5f             	lock and $0x5f,%al
f0105f8e:	10 f0                	adc    %dh,%al
f0105f90:	2a 5f 10             	sub    0x10(%edi),%bl
f0105f93:	f0 30 5f 10          	lock xor %bl,0x10(%edi)
f0105f97:	f0                   	lock
f0105f98:	36                   	ss
f0105f99:	5f                   	pop    %edi
f0105f9a:	10 f0                	adc    %dh,%al
f0105f9c:	3c 5f                	cmp    $0x5f,%al
f0105f9e:	10 f0                	adc    %dh,%al
f0105fa0:	42                   	inc    %edx
f0105fa1:	5f                   	pop    %edi
f0105fa2:	10 f0                	adc    %dh,%al

f0105fa4 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
.text
_alltraps:
	pushl %ds
f0105fa4:	1e                   	push   %ds
	pushl %es
f0105fa5:	06                   	push   %es
	pushal
f0105fa6:	60                   	pusha  
	movl $GD_KD, %eax
f0105fa7:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f0105fac:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0105fae:	8e c0                	mov    %eax,%es
	pushl %esp
f0105fb0:	54                   	push   %esp
	call trap
f0105fb1:	e8 81 fb ff ff       	call   f0105b37 <trap>

f0105fb6 <xchg>:
	return tsc;
}

static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
f0105fb6:	55                   	push   %ebp
f0105fb7:	89 e5                	mov    %esp,%ebp
f0105fb9:	83 ec 10             	sub    $0x10,%esp
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105fbc:	8b 55 08             	mov    0x8(%ebp),%edx
f0105fbf:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105fc2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105fc5:	f0 87 02             	lock xchg %eax,(%edx)
f0105fc8:	89 45 fc             	mov    %eax,-0x4(%ebp)
			"+m" (*addr), "=a" (result) :
			"1" (newval) :
			"cc");
	return result;
f0105fcb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f0105fce:	c9                   	leave  
f0105fcf:	c3                   	ret    

f0105fd0 <unlock_kernel>:

static inline void
unlock_kernel(void)
{
f0105fd0:	55                   	push   %ebp
f0105fd1:	89 e5                	mov    %esp,%ebp
f0105fd3:	83 ec 18             	sub    $0x18,%esp
	spin_unlock(&kernel_lock);
f0105fd6:	c7 04 24 e0 55 12 f0 	movl   $0xf01255e0,(%esp)
f0105fdd:	e8 e7 28 00 00       	call   f01088c9 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0105fe2:	f3 90                	pause  
}
f0105fe4:	c9                   	leave  
f0105fe5:	c3                   	ret    

f0105fe6 <_paddr>:
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0105fe6:	55                   	push   %ebp
f0105fe7:	89 e5                	mov    %esp,%ebp
f0105fe9:	83 ec 18             	sub    $0x18,%esp
	if ((uint32_t)kva < KERNBASE)
f0105fec:	8b 45 10             	mov    0x10(%ebp),%eax
f0105fef:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0105ff4:	77 21                	ja     f0106017 <_paddr+0x31>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0105ff6:	8b 45 10             	mov    0x10(%ebp),%eax
f0105ff9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105ffd:	c7 44 24 08 70 a2 10 	movl   $0xf010a270,0x8(%esp)
f0106004:	f0 
f0106005:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106008:	89 44 24 04          	mov    %eax,0x4(%esp)
f010600c:	8b 45 08             	mov    0x8(%ebp),%eax
f010600f:	89 04 24             	mov    %eax,(%esp)
f0106012:	e8 e0 a2 ff ff       	call   f01002f7 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0106017:	8b 45 10             	mov    0x10(%ebp),%eax
f010601a:	05 00 00 00 10       	add    $0x10000000,%eax
}
f010601f:	c9                   	leave  
f0106020:	c3                   	ret    

f0106021 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0106021:	55                   	push   %ebp
f0106022:	89 e5                	mov    %esp,%ebp
f0106024:	83 ec 28             	sub    $0x28,%esp
	// below to halt the cpu.

	// LAB 4: Your code here.

	int index;
	bool t = false;
f0106027:	c6 45 f3 00          	movb   $0x0,-0xd(%ebp)
	if(curenv == NULL)
f010602b:	e8 96 25 00 00       	call   f01085c6 <cpunum>
f0106030:	6b c0 74             	imul   $0x74,%eax,%eax
f0106033:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0106038:	8b 00                	mov    (%eax),%eax
f010603a:	85 c0                	test   %eax,%eax
f010603c:	75 0d                	jne    f010604b <sched_yield+0x2a>
	{
		t = true;
f010603e:	c6 45 f3 01          	movb   $0x1,-0xd(%ebp)
		index = 0;
f0106042:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0106049:	eb 1a                	jmp    f0106065 <sched_yield+0x44>
	}
	else 
	{
		index = ENVX(curenv->env_id);
f010604b:	e8 76 25 00 00       	call   f01085c6 <cpunum>
f0106050:	6b c0 74             	imul   $0x74,%eax,%eax
f0106053:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0106058:	8b 00                	mov    (%eax),%eax
f010605a:	8b 40 48             	mov    0x48(%eax),%eax
f010605d:	25 ff 03 00 00       	and    $0x3ff,%eax
f0106062:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
	if(t == false)
f0106065:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0106069:	83 f0 01             	xor    $0x1,%eax
f010606c:	84 c0                	test   %al,%al
f010606e:	0f 84 84 00 00 00    	je     f01060f8 <sched_yield+0xd7>
	{
		int i = (index + 1)%NENV;
f0106074:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106077:	8d 50 01             	lea    0x1(%eax),%edx
f010607a:	89 d0                	mov    %edx,%eax
f010607c:	c1 f8 1f             	sar    $0x1f,%eax
f010607f:	c1 e8 16             	shr    $0x16,%eax
f0106082:	01 c2                	add    %eax,%edx
f0106084:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010608a:	29 c2                	sub    %eax,%edx
f010608c:	89 d0                	mov    %edx,%eax
f010608e:	89 45 ec             	mov    %eax,-0x14(%ebp)
		while(i != index)
f0106091:	eb 5b                	jmp    f01060ee <sched_yield+0xcd>
		{
			if(envs[i].env_status == ENV_RUNNABLE)
f0106093:	8b 15 3c b2 23 f0    	mov    0xf023b23c,%edx
f0106099:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010609c:	c1 e0 02             	shl    $0x2,%eax
f010609f:	89 c1                	mov    %eax,%ecx
f01060a1:	c1 e1 05             	shl    $0x5,%ecx
f01060a4:	29 c1                	sub    %eax,%ecx
f01060a6:	89 c8                	mov    %ecx,%eax
f01060a8:	01 d0                	add    %edx,%eax
f01060aa:	8b 40 54             	mov    0x54(%eax),%eax
f01060ad:	83 f8 02             	cmp    $0x2,%eax
f01060b0:	75 1f                	jne    f01060d1 <sched_yield+0xb0>
			{
				env_run(&envs[i]);
f01060b2:	8b 15 3c b2 23 f0    	mov    0xf023b23c,%edx
f01060b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01060bb:	c1 e0 02             	shl    $0x2,%eax
f01060be:	89 c1                	mov    %eax,%ecx
f01060c0:	c1 e1 05             	shl    $0x5,%ecx
f01060c3:	29 c1                	sub    %eax,%ecx
f01060c5:	89 c8                	mov    %ecx,%eax
f01060c7:	01 d0                	add    %edx,%eax
f01060c9:	89 04 24             	mov    %eax,(%esp)
f01060cc:	e8 67 eb ff ff       	call   f0104c38 <env_run>
			}
			i = (i+1)%NENV;
f01060d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01060d4:	8d 50 01             	lea    0x1(%eax),%edx
f01060d7:	89 d0                	mov    %edx,%eax
f01060d9:	c1 f8 1f             	sar    $0x1f,%eax
f01060dc:	c1 e8 16             	shr    $0x16,%eax
f01060df:	01 c2                	add    %eax,%edx
f01060e1:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01060e7:	29 c2                	sub    %eax,%edx
f01060e9:	89 d0                	mov    %edx,%eax
f01060eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
		index = ENVX(curenv->env_id);
	}
	if(t == false)
	{
		int i = (index + 1)%NENV;
		while(i != index)
f01060ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01060f1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f01060f4:	75 9d                	jne    f0106093 <sched_yield+0x72>
f01060f6:	eb 54                	jmp    f010614c <sched_yield+0x12b>
		}
	}
	else
	{
		int i;
		for(i = 0; i < NENV ; i++)
f01060f8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f01060ff:	eb 42                	jmp    f0106143 <sched_yield+0x122>
		{
			if(envs[i].env_status == ENV_RUNNABLE)
f0106101:	8b 15 3c b2 23 f0    	mov    0xf023b23c,%edx
f0106107:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010610a:	c1 e0 02             	shl    $0x2,%eax
f010610d:	89 c1                	mov    %eax,%ecx
f010610f:	c1 e1 05             	shl    $0x5,%ecx
f0106112:	29 c1                	sub    %eax,%ecx
f0106114:	89 c8                	mov    %ecx,%eax
f0106116:	01 d0                	add    %edx,%eax
f0106118:	8b 40 54             	mov    0x54(%eax),%eax
f010611b:	83 f8 02             	cmp    $0x2,%eax
f010611e:	75 1f                	jne    f010613f <sched_yield+0x11e>
			{
				env_run(&envs[i]);
f0106120:	8b 15 3c b2 23 f0    	mov    0xf023b23c,%edx
f0106126:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106129:	c1 e0 02             	shl    $0x2,%eax
f010612c:	89 c1                	mov    %eax,%ecx
f010612e:	c1 e1 05             	shl    $0x5,%ecx
f0106131:	29 c1                	sub    %eax,%ecx
f0106133:	89 c8                	mov    %ecx,%eax
f0106135:	01 d0                	add    %edx,%eax
f0106137:	89 04 24             	mov    %eax,(%esp)
f010613a:	e8 f9 ea ff ff       	call   f0104c38 <env_run>
		}
	}
	else
	{
		int i;
		for(i = 0; i < NENV ; i++)
f010613f:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
f0106143:	81 7d e8 ff 03 00 00 	cmpl   $0x3ff,-0x18(%ebp)
f010614a:	7e b5                	jle    f0106101 <sched_yield+0xe0>
			{
				env_run(&envs[i]);
			}
		}
	}
	if(curenv && curenv->env_status == ENV_RUNNING)
f010614c:	e8 75 24 00 00       	call   f01085c6 <cpunum>
f0106151:	6b c0 74             	imul   $0x74,%eax,%eax
f0106154:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0106159:	8b 00                	mov    (%eax),%eax
f010615b:	85 c0                	test   %eax,%eax
f010615d:	74 2e                	je     f010618d <sched_yield+0x16c>
f010615f:	e8 62 24 00 00       	call   f01085c6 <cpunum>
f0106164:	6b c0 74             	imul   $0x74,%eax,%eax
f0106167:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f010616c:	8b 00                	mov    (%eax),%eax
f010616e:	8b 40 54             	mov    0x54(%eax),%eax
f0106171:	83 f8 03             	cmp    $0x3,%eax
f0106174:	75 17                	jne    f010618d <sched_yield+0x16c>
	{
		env_run(curenv);
f0106176:	e8 4b 24 00 00       	call   f01085c6 <cpunum>
f010617b:	6b c0 74             	imul   $0x74,%eax,%eax
f010617e:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0106183:	8b 00                	mov    (%eax),%eax
f0106185:	89 04 24             	mov    %eax,(%esp)
f0106188:	e8 ab ea ff ff       	call   f0104c38 <env_run>
	}
	
	sched_halt();
f010618d:	e8 02 00 00 00       	call   f0106194 <sched_halt>
}
f0106192:	c9                   	leave  
f0106193:	c3                   	ret    

f0106194 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0106194:	55                   	push   %ebp
f0106195:	89 e5                	mov    %esp,%ebp
f0106197:	83 ec 28             	sub    $0x28,%esp
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010619a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f01061a1:	eb 61                	jmp    f0106204 <sched_halt+0x70>
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01061a3:	8b 15 3c b2 23 f0    	mov    0xf023b23c,%edx
f01061a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01061ac:	c1 e0 02             	shl    $0x2,%eax
f01061af:	89 c1                	mov    %eax,%ecx
f01061b1:	c1 e1 05             	shl    $0x5,%ecx
f01061b4:	29 c1                	sub    %eax,%ecx
f01061b6:	89 c8                	mov    %ecx,%eax
f01061b8:	01 d0                	add    %edx,%eax
f01061ba:	8b 40 54             	mov    0x54(%eax),%eax
f01061bd:	83 f8 02             	cmp    $0x2,%eax
f01061c0:	74 4b                	je     f010620d <sched_halt+0x79>
		     envs[i].env_status == ENV_RUNNING ||
f01061c2:	8b 15 3c b2 23 f0    	mov    0xf023b23c,%edx
f01061c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01061cb:	c1 e0 02             	shl    $0x2,%eax
f01061ce:	89 c1                	mov    %eax,%ecx
f01061d0:	c1 e1 05             	shl    $0x5,%ecx
f01061d3:	29 c1                	sub    %eax,%ecx
f01061d5:	89 c8                	mov    %ecx,%eax
f01061d7:	01 d0                	add    %edx,%eax
f01061d9:	8b 40 54             	mov    0x54(%eax),%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01061dc:	83 f8 03             	cmp    $0x3,%eax
f01061df:	74 2c                	je     f010620d <sched_halt+0x79>
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
f01061e1:	8b 15 3c b2 23 f0    	mov    0xf023b23c,%edx
f01061e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01061ea:	c1 e0 02             	shl    $0x2,%eax
f01061ed:	89 c1                	mov    %eax,%ecx
f01061ef:	c1 e1 05             	shl    $0x5,%ecx
f01061f2:	29 c1                	sub    %eax,%ecx
f01061f4:	89 c8                	mov    %ecx,%eax
f01061f6:	01 d0                	add    %edx,%eax
f01061f8:	8b 40 54             	mov    0x54(%eax),%eax

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f01061fb:	83 f8 01             	cmp    $0x1,%eax
f01061fe:	74 0d                	je     f010620d <sched_halt+0x79>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0106200:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0106204:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
f010620b:	7e 96                	jle    f01061a3 <sched_halt+0xf>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f010620d:	81 7d f4 00 04 00 00 	cmpl   $0x400,-0xc(%ebp)
f0106214:	75 1a                	jne    f0106230 <sched_halt+0x9c>
		cprintf("No runnable environments in the system!\n");
f0106216:	c7 04 24 94 a2 10 f0 	movl   $0xf010a294,(%esp)
f010621d:	e8 9d ed ff ff       	call   f0104fbf <cprintf>
		while (1)
			monitor(NULL);
f0106222:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0106229:	e8 23 ae ff ff       	call   f0101051 <monitor>
f010622e:	eb f2                	jmp    f0106222 <sched_halt+0x8e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0106230:	e8 91 23 00 00       	call   f01085c6 <cpunum>
f0106235:	6b c0 74             	imul   $0x74,%eax,%eax
f0106238:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f010623d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	lcr3(PADDR(kern_pgdir));
f0106243:	a1 ec be 23 f0       	mov    0xf023beec,%eax
f0106248:	89 44 24 08          	mov    %eax,0x8(%esp)
f010624c:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
f0106253:	00 
f0106254:	c7 04 24 bd a2 10 f0 	movl   $0xf010a2bd,(%esp)
f010625b:	e8 86 fd ff ff       	call   f0105fe6 <_paddr>
f0106260:	89 45 f0             	mov    %eax,-0x10(%ebp)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0106263:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106266:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0106269:	e8 58 23 00 00       	call   f01085c6 <cpunum>
f010626e:	6b c0 74             	imul   $0x74,%eax,%eax
f0106271:	05 20 c0 23 f0       	add    $0xf023c020,%eax
f0106276:	83 c0 04             	add    $0x4,%eax
f0106279:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0106280:	00 
f0106281:	89 04 24             	mov    %eax,(%esp)
f0106284:	e8 2d fd ff ff       	call   f0105fb6 <xchg>

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();
f0106289:	e8 42 fd ff ff       	call   f0105fd0 <unlock_kernel>
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010628e:	e8 33 23 00 00       	call   f01085c6 <cpunum>
f0106293:	6b c0 74             	imul   $0x74,%eax,%eax
f0106296:	05 30 c0 23 f0       	add    $0xf023c030,%eax
f010629b:	8b 00                	mov    (%eax),%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f010629d:	bd 00 00 00 00       	mov    $0x0,%ebp
f01062a2:	89 c4                	mov    %eax,%esp
f01062a4:	6a 00                	push   $0x0
f01062a6:	6a 00                	push   $0x0
f01062a8:	fb                   	sti    
f01062a9:	f4                   	hlt    
f01062aa:	eb fd                	jmp    f01062a9 <sched_halt+0x115>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f01062ac:	c9                   	leave  
f01062ad:	c3                   	ret    

f01062ae <sys_cputs>:
// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void
sys_cputs(const char *s, size_t len)
{
f01062ae:	55                   	push   %ebp
f01062af:	89 e5                	mov    %esp,%ebp
f01062b1:	83 ec 18             	sub    $0x18,%esp

	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);
f01062b4:	e8 0d 23 00 00       	call   f01085c6 <cpunum>
f01062b9:	6b c0 74             	imul   $0x74,%eax,%eax
f01062bc:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f01062c1:	8b 00                	mov    (%eax),%eax
f01062c3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01062ca:	00 
f01062cb:	8b 55 0c             	mov    0xc(%ebp),%edx
f01062ce:	89 54 24 08          	mov    %edx,0x8(%esp)
f01062d2:	8b 55 08             	mov    0x8(%ebp),%edx
f01062d5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01062d9:	89 04 24             	mov    %eax,(%esp)
f01062dc:	e8 b6 ba ff ff       	call   f0101d97 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01062e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01062e4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01062e8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01062eb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01062ef:	c7 04 24 cc a2 10 f0 	movl   $0xf010a2cc,(%esp)
f01062f6:	e8 c4 ec ff ff       	call   f0104fbf <cprintf>
}
f01062fb:	c9                   	leave  
f01062fc:	c3                   	ret    

f01062fd <sys_cgetc>:

// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
f01062fd:	55                   	push   %ebp
f01062fe:	89 e5                	mov    %esp,%ebp
f0106300:	83 ec 08             	sub    $0x8,%esp
	return cons_getc();
f0106303:	e8 d9 a7 ff ff       	call   f0100ae1 <cons_getc>
}
f0106308:	c9                   	leave  
f0106309:	c3                   	ret    

f010630a <sys_getenvid>:

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
f010630a:	55                   	push   %ebp
f010630b:	89 e5                	mov    %esp,%ebp
f010630d:	83 ec 08             	sub    $0x8,%esp
	return curenv->env_id;
f0106310:	e8 b1 22 00 00       	call   f01085c6 <cpunum>
f0106315:	6b c0 74             	imul   $0x74,%eax,%eax
f0106318:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f010631d:	8b 00                	mov    (%eax),%eax
f010631f:	8b 40 48             	mov    0x48(%eax),%eax
}
f0106322:	c9                   	leave  
f0106323:	c3                   	ret    

f0106324 <sys_env_destroy>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_destroy(envid_t envid)
{
f0106324:	55                   	push   %ebp
f0106325:	89 e5                	mov    %esp,%ebp
f0106327:	53                   	push   %ebx
f0106328:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010632b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106332:	00 
f0106333:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0106336:	89 44 24 04          	mov    %eax,0x4(%esp)
f010633a:	8b 45 08             	mov    0x8(%ebp),%eax
f010633d:	89 04 24             	mov    %eax,(%esp)
f0106340:	e8 af df ff ff       	call   f01042f4 <envid2env>
f0106345:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0106348:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010634c:	79 05                	jns    f0106353 <sys_env_destroy+0x2f>
		return r;
f010634e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106351:	eb 76                	jmp    f01063c9 <sys_env_destroy+0xa5>
	if (e == curenv)
f0106353:	e8 6e 22 00 00       	call   f01085c6 <cpunum>
f0106358:	6b c0 74             	imul   $0x74,%eax,%eax
f010635b:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0106360:	8b 10                	mov    (%eax),%edx
f0106362:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106365:	39 c2                	cmp    %eax,%edx
f0106367:	75 24                	jne    f010638d <sys_env_destroy+0x69>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0106369:	e8 58 22 00 00       	call   f01085c6 <cpunum>
f010636e:	6b c0 74             	imul   $0x74,%eax,%eax
f0106371:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0106376:	8b 00                	mov    (%eax),%eax
f0106378:	8b 40 48             	mov    0x48(%eax),%eax
f010637b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010637f:	c7 04 24 d1 a2 10 f0 	movl   $0xf010a2d1,(%esp)
f0106386:	e8 34 ec ff ff       	call   f0104fbf <cprintf>
f010638b:	eb 2c                	jmp    f01063b9 <sys_env_destroy+0x95>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010638d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106390:	8b 58 48             	mov    0x48(%eax),%ebx
f0106393:	e8 2e 22 00 00       	call   f01085c6 <cpunum>
f0106398:	6b c0 74             	imul   $0x74,%eax,%eax
f010639b:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f01063a0:	8b 00                	mov    (%eax),%eax
f01063a2:	8b 40 48             	mov    0x48(%eax),%eax
f01063a5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01063a9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01063ad:	c7 04 24 ec a2 10 f0 	movl   $0xf010a2ec,(%esp)
f01063b4:	e8 06 ec ff ff       	call   f0104fbf <cprintf>
	env_destroy(e);
f01063b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01063bc:	89 04 24             	mov    %eax,(%esp)
f01063bf:	e8 c6 e7 ff ff       	call   f0104b8a <env_destroy>
	return 0;
f01063c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01063c9:	83 c4 24             	add    $0x24,%esp
f01063cc:	5b                   	pop    %ebx
f01063cd:	5d                   	pop    %ebp
f01063ce:	c3                   	ret    

f01063cf <sys_yield>:

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
f01063cf:	55                   	push   %ebp
f01063d0:	89 e5                	mov    %esp,%ebp
f01063d2:	83 ec 08             	sub    $0x8,%esp
	sched_yield();
f01063d5:	e8 47 fc ff ff       	call   f0106021 <sched_yield>

f01063da <sys_exofork>:
// Returns envid of new environment, or < 0 on error.  Errors are:
//	-E_NO_FREE_ENV if no free environment is available.
//	-E_NO_MEM on memory exhaustion.
static envid_t
sys_exofork(void)
{
f01063da:	55                   	push   %ebp
f01063db:	89 e5                	mov    %esp,%ebp
f01063dd:	57                   	push   %edi
f01063de:	56                   	push   %esi
f01063df:	53                   	push   %ebx
f01063e0:	83 ec 2c             	sub    $0x2c,%esp
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env *e;
	int r = env_alloc(&e,curenv->env_id);
f01063e3:	e8 de 21 00 00       	call   f01085c6 <cpunum>
f01063e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01063eb:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f01063f0:	8b 00                	mov    (%eax),%eax
f01063f2:	8b 40 48             	mov    0x48(%eax),%eax
f01063f5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01063f9:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01063fc:	89 04 24             	mov    %eax,(%esp)
f01063ff:	e8 99 e1 ff ff       	call   f010459d <env_alloc>
f0106404:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if(r < 0)
f0106407:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010640b:	79 05                	jns    f0106412 <sys_exofork+0x38>
	{
		return r;
f010640d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106410:	eb 3d                	jmp    f010644f <sys_exofork+0x75>
	}
	else
	{
		e->env_status = ENV_NOT_RUNNABLE;
f0106412:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106415:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
		e->env_tf = curenv->env_tf;
f010641c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010641f:	e8 a2 21 00 00       	call   f01085c6 <cpunum>
f0106424:	6b c0 74             	imul   $0x74,%eax,%eax
f0106427:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f010642c:	8b 00                	mov    (%eax),%eax
f010642e:	89 da                	mov    %ebx,%edx
f0106430:	89 c3                	mov    %eax,%ebx
f0106432:	b8 11 00 00 00       	mov    $0x11,%eax
f0106437:	89 d7                	mov    %edx,%edi
f0106439:	89 de                	mov    %ebx,%esi
f010643b:	89 c1                	mov    %eax,%ecx
f010643d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		e->env_tf.tf_regs.reg_eax = 0;
f010643f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106442:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
		return e->env_id;
f0106449:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010644c:	8b 40 48             	mov    0x48(%eax),%eax
	}

	// panic("sys_exofork not implemented");
}
f010644f:	83 c4 2c             	add    $0x2c,%esp
f0106452:	5b                   	pop    %ebx
f0106453:	5e                   	pop    %esi
f0106454:	5f                   	pop    %edi
f0106455:	5d                   	pop    %ebp
f0106456:	c3                   	ret    

f0106457 <sys_env_set_status>:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if status is not a valid status for an environment.
static int
sys_env_set_status(envid_t envid, int status)
{
f0106457:	55                   	push   %ebp
f0106458:	89 e5                	mov    %esp,%ebp
f010645a:	83 ec 28             	sub    $0x28,%esp
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if(status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE)
f010645d:	83 7d 0c 04          	cmpl   $0x4,0xc(%ebp)
f0106461:	74 0d                	je     f0106470 <sys_env_set_status+0x19>
f0106463:	83 7d 0c 02          	cmpl   $0x2,0xc(%ebp)
f0106467:	74 07                	je     f0106470 <sys_env_set_status+0x19>
	{
		return -E_INVAL;
f0106469:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010646e:	eb 38                	jmp    f01064a8 <sys_env_set_status+0x51>
	}
	struct Env *e;
	int r = envid2env(envid,&e,1);
f0106470:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106477:	00 
f0106478:	8d 45 f0             	lea    -0x10(%ebp),%eax
f010647b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010647f:	8b 45 08             	mov    0x8(%ebp),%eax
f0106482:	89 04 24             	mov    %eax,(%esp)
f0106485:	e8 6a de ff ff       	call   f01042f4 <envid2env>
f010648a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(r == -E_BAD_ENV)
f010648d:	83 7d f4 fe          	cmpl   $0xfffffffe,-0xc(%ebp)
f0106491:	75 07                	jne    f010649a <sys_env_set_status+0x43>
	{
		return -E_BAD_ENV;
f0106493:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0106498:	eb 0e                	jmp    f01064a8 <sys_env_set_status+0x51>
	}
	e->env_status = status;
f010649a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010649d:	8b 55 0c             	mov    0xc(%ebp),%edx
f01064a0:	89 50 54             	mov    %edx,0x54(%eax)
	return 0;
f01064a3:	b8 00 00 00 00       	mov    $0x0,%eax

	// panic("sys_env_set_status not implemented");
}
f01064a8:	c9                   	leave  
f01064a9:	c3                   	ret    

f01064aa <sys_env_set_pgfault_upcall>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
f01064aa:	55                   	push   %ebp
f01064ab:	89 e5                	mov    %esp,%ebp
f01064ad:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	struct Env *e;
	int r = envid2env(envid,&e,1);
f01064b0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01064b7:	00 
f01064b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
f01064bb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01064bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01064c2:	89 04 24             	mov    %eax,(%esp)
f01064c5:	e8 2a de ff ff       	call   f01042f4 <envid2env>
f01064ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(r == -E_BAD_ENV)
f01064cd:	83 7d f4 fe          	cmpl   $0xfffffffe,-0xc(%ebp)
f01064d1:	75 07                	jne    f01064da <sys_env_set_pgfault_upcall+0x30>
	{
		return -E_BAD_ENV;
f01064d3:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01064d8:	eb 0e                	jmp    f01064e8 <sys_env_set_pgfault_upcall+0x3e>
	}
	e->env_pgfault_upcall = func;
f01064da:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01064dd:	8b 55 0c             	mov    0xc(%ebp),%edx
f01064e0:	89 50 64             	mov    %edx,0x64(%eax)
	return 0;
f01064e3:	b8 00 00 00 00       	mov    $0x0,%eax
	// panic("sys_env_set_pgfault_upcall not implemented");
}
f01064e8:	c9                   	leave  
f01064e9:	c3                   	ret    

f01064ea <sys_page_alloc>:
//	-E_INVAL if perm is inappropriate (see above).
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
f01064ea:	55                   	push   %ebp
f01064eb:	89 e5                	mov    %esp,%ebp
f01064ed:	83 ec 38             	sub    $0x38,%esp
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	if ((perm & PTE_U) != PTE_U || (perm & PTE_P) != PTE_P || (perm & ~PTE_SYSCALL) != 0)
f01064f0:	8b 45 10             	mov    0x10(%ebp),%eax
f01064f3:	83 e0 04             	and    $0x4,%eax
f01064f6:	85 c0                	test   %eax,%eax
f01064f8:	74 16                	je     f0106510 <sys_page_alloc+0x26>
f01064fa:	8b 45 10             	mov    0x10(%ebp),%eax
f01064fd:	83 e0 01             	and    $0x1,%eax
f0106500:	85 c0                	test   %eax,%eax
f0106502:	74 0c                	je     f0106510 <sys_page_alloc+0x26>
f0106504:	8b 45 10             	mov    0x10(%ebp),%eax
f0106507:	25 f8 f1 ff ff       	and    $0xfffff1f8,%eax
f010650c:	85 c0                	test   %eax,%eax
f010650e:	74 0a                	je     f010651a <sys_page_alloc+0x30>
	{
		return -E_INVAL;
f0106510:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106515:	e9 cd 00 00 00       	jmp    f01065e7 <sys_page_alloc+0xfd>
	}
	struct Env *e;
	int r = envid2env(envid,&e,1);
f010651a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106521:	00 
f0106522:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0106525:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106529:	8b 45 08             	mov    0x8(%ebp),%eax
f010652c:	89 04 24             	mov    %eax,(%esp)
f010652f:	e8 c0 dd ff ff       	call   f01042f4 <envid2env>
f0106534:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(r == -E_BAD_ENV)
f0106537:	83 7d f4 fe          	cmpl   $0xfffffffe,-0xc(%ebp)
f010653b:	75 0a                	jne    f0106547 <sys_page_alloc+0x5d>
	{
		return -E_BAD_ENV;
f010653d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0106542:	e9 a0 00 00 00       	jmp    f01065e7 <sys_page_alloc+0xfd>
	}
	else if((uintptr_t)va >= UTOP || (uintptr_t)va != ROUNDUP((uintptr_t)va,PGSIZE))
f0106547:	8b 45 0c             	mov    0xc(%ebp),%eax
f010654a:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f010654f:	77 30                	ja     f0106581 <sys_page_alloc+0x97>
f0106551:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106554:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
f010655b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010655e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106561:	01 d0                	add    %edx,%eax
f0106563:	83 e8 01             	sub    $0x1,%eax
f0106566:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106569:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010656c:	ba 00 00 00 00       	mov    $0x0,%edx
f0106571:	f7 75 f0             	divl   -0x10(%ebp)
f0106574:	89 d0                	mov    %edx,%eax
f0106576:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0106579:	29 c2                	sub    %eax,%edx
f010657b:	89 d0                	mov    %edx,%eax
f010657d:	39 c1                	cmp    %eax,%ecx
f010657f:	74 07                	je     f0106588 <sys_page_alloc+0x9e>
	{
		return -E_INVAL;
f0106581:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106586:	eb 5f                	jmp    f01065e7 <sys_page_alloc+0xfd>
	}
	else
	{
		struct PageInfo *new_page = page_alloc(0);
f0106588:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010658f:	e8 2e b2 ff ff       	call   f01017c2 <page_alloc>
f0106594:	89 45 e8             	mov    %eax,-0x18(%ebp)
		if(new_page == NULL)
f0106597:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010659b:	75 07                	jne    f01065a4 <sys_page_alloc+0xba>
		{
			return -E_NO_MEM;
f010659d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01065a2:	eb 43                	jmp    f01065e7 <sys_page_alloc+0xfd>
		}
		int ins = page_insert(e->env_pgdir,new_page,va,perm);
f01065a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01065a7:	8b 40 60             	mov    0x60(%eax),%eax
f01065aa:	8b 55 10             	mov    0x10(%ebp),%edx
f01065ad:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01065b1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01065b4:	89 54 24 08          	mov    %edx,0x8(%esp)
f01065b8:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01065bb:	89 54 24 04          	mov    %edx,0x4(%esp)
f01065bf:	89 04 24             	mov    %eax,(%esp)
f01065c2:	e8 a1 b4 ff ff       	call   f0101a68 <page_insert>
f01065c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if(ins == -E_NO_MEM)
f01065ca:	83 7d e4 fc          	cmpl   $0xfffffffc,-0x1c(%ebp)
f01065ce:	75 12                	jne    f01065e2 <sys_page_alloc+0xf8>
		{
			page_free(new_page);
f01065d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01065d3:	89 04 24             	mov    %eax,(%esp)
f01065d6:	e8 4c b2 ff ff       	call   f0101827 <page_free>
			return -E_NO_MEM;
f01065db:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01065e0:	eb 05                	jmp    f01065e7 <sys_page_alloc+0xfd>
		}
	}
	return 0;
f01065e2:	b8 00 00 00 00       	mov    $0x0,%eax

	// panic("sys_page_alloc not implemented");
}
f01065e7:	c9                   	leave  
f01065e8:	c3                   	ret    

f01065e9 <sys_page_map>:
//		address space.
//	-E_NO_MEM if there's no memory to allocate any necessary page tables.
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
f01065e9:	55                   	push   %ebp
f01065ea:	89 e5                	mov    %esp,%ebp
f01065ec:	83 ec 48             	sub    $0x48,%esp
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	struct Env *e1;
	struct Env *e2;
	int r1 = envid2env(srcenvid,&e1,1);
f01065ef:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01065f6:	00 
f01065f7:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01065fa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01065fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0106601:	89 04 24             	mov    %eax,(%esp)
f0106604:	e8 eb dc ff ff       	call   f01042f4 <envid2env>
f0106609:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int r2 = envid2env(dstenvid,&e2,1);
f010660c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106613:	00 
f0106614:	8d 45 cc             	lea    -0x34(%ebp),%eax
f0106617:	89 44 24 04          	mov    %eax,0x4(%esp)
f010661b:	8b 45 10             	mov    0x10(%ebp),%eax
f010661e:	89 04 24             	mov    %eax,(%esp)
f0106621:	e8 ce dc ff ff       	call   f01042f4 <envid2env>
f0106626:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(r1 == -E_BAD_ENV || r2 == -E_BAD_ENV)
f0106629:	83 7d f4 fe          	cmpl   $0xfffffffe,-0xc(%ebp)
f010662d:	74 06                	je     f0106635 <sys_page_map+0x4c>
f010662f:	83 7d f0 fe          	cmpl   $0xfffffffe,-0x10(%ebp)
f0106633:	75 0a                	jne    f010663f <sys_page_map+0x56>
	{
		return -E_BAD_ENV;
f0106635:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010663a:	e9 43 01 00 00       	jmp    f0106782 <sys_page_map+0x199>
	}
	if((uintptr_t)srcva >= UTOP || (uintptr_t)dstva >= UTOP)
f010663f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106642:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0106647:	77 0a                	ja     f0106653 <sys_page_map+0x6a>
f0106649:	8b 45 14             	mov    0x14(%ebp),%eax
f010664c:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0106651:	76 0a                	jbe    f010665d <sys_page_map+0x74>
	{
		return -E_INVAL;
f0106653:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106658:	e9 25 01 00 00       	jmp    f0106782 <sys_page_map+0x199>
	}
	if((uintptr_t)srcva != ROUNDUP((uintptr_t)srcva,PGSIZE))
f010665d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106660:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%ebp)
f0106667:	8b 55 0c             	mov    0xc(%ebp),%edx
f010666a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010666d:	01 d0                	add    %edx,%eax
f010666f:	83 e8 01             	sub    $0x1,%eax
f0106672:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0106675:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106678:	ba 00 00 00 00       	mov    $0x0,%edx
f010667d:	f7 75 ec             	divl   -0x14(%ebp)
f0106680:	89 d0                	mov    %edx,%eax
f0106682:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0106685:	29 c2                	sub    %eax,%edx
f0106687:	89 d0                	mov    %edx,%eax
f0106689:	39 c1                	cmp    %eax,%ecx
f010668b:	74 0a                	je     f0106697 <sys_page_map+0xae>
	{
		return -E_INVAL;
f010668d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106692:	e9 eb 00 00 00       	jmp    f0106782 <sys_page_map+0x199>
	}
	if((uintptr_t)dstva != ROUNDUP((uintptr_t)dstva,PGSIZE))
f0106697:	8b 4d 14             	mov    0x14(%ebp),%ecx
f010669a:	c7 45 e4 00 10 00 00 	movl   $0x1000,-0x1c(%ebp)
f01066a1:	8b 55 14             	mov    0x14(%ebp),%edx
f01066a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01066a7:	01 d0                	add    %edx,%eax
f01066a9:	83 e8 01             	sub    $0x1,%eax
f01066ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01066af:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01066b2:	ba 00 00 00 00       	mov    $0x0,%edx
f01066b7:	f7 75 e4             	divl   -0x1c(%ebp)
f01066ba:	89 d0                	mov    %edx,%eax
f01066bc:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01066bf:	29 c2                	sub    %eax,%edx
f01066c1:	89 d0                	mov    %edx,%eax
f01066c3:	39 c1                	cmp    %eax,%ecx
f01066c5:	74 0a                	je     f01066d1 <sys_page_map+0xe8>
	{
		return -E_INVAL;
f01066c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01066cc:	e9 b1 00 00 00       	jmp    f0106782 <sys_page_map+0x199>
	}
	if ((perm & PTE_U) != PTE_U || (perm & PTE_P) != PTE_P || (perm & ~PTE_SYSCALL) != 0)
f01066d1:	8b 45 18             	mov    0x18(%ebp),%eax
f01066d4:	83 e0 04             	and    $0x4,%eax
f01066d7:	85 c0                	test   %eax,%eax
f01066d9:	74 16                	je     f01066f1 <sys_page_map+0x108>
f01066db:	8b 45 18             	mov    0x18(%ebp),%eax
f01066de:	83 e0 01             	and    $0x1,%eax
f01066e1:	85 c0                	test   %eax,%eax
f01066e3:	74 0c                	je     f01066f1 <sys_page_map+0x108>
f01066e5:	8b 45 18             	mov    0x18(%ebp),%eax
f01066e8:	25 f8 f1 ff ff       	and    $0xfffff1f8,%eax
f01066ed:	85 c0                	test   %eax,%eax
f01066ef:	74 0a                	je     f01066fb <sys_page_map+0x112>
	{
		return -E_INVAL;
f01066f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01066f6:	e9 87 00 00 00       	jmp    f0106782 <sys_page_map+0x199>
	}
	pte_t *x;
	pte_t **store = &x;
f01066fb:	8d 45 c8             	lea    -0x38(%ebp),%eax
f01066fe:	89 45 dc             	mov    %eax,-0x24(%ebp)
	struct PageInfo *l1 = page_lookup(e1->env_pgdir,srcva,store);
f0106701:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0106704:	8b 40 60             	mov    0x60(%eax),%eax
f0106707:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010670a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010670e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106711:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106715:	89 04 24             	mov    %eax,(%esp)
f0106718:	e8 fc b3 ff ff       	call   f0101b19 <page_lookup>
f010671d:	89 45 d8             	mov    %eax,-0x28(%ebp)
	if(l1 == NULL)
f0106720:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0106724:	75 07                	jne    f010672d <sys_page_map+0x144>
	{
		return -E_INVAL;
f0106726:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010672b:	eb 55                	jmp    f0106782 <sys_page_map+0x199>
	}
	if((perm & PTE_W) != 0)
f010672d:	8b 45 18             	mov    0x18(%ebp),%eax
f0106730:	83 e0 02             	and    $0x2,%eax
f0106733:	85 c0                	test   %eax,%eax
f0106735:	74 13                	je     f010674a <sys_page_map+0x161>
	{
		if((*x & PTE_W) == 0)
f0106737:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010673a:	8b 00                	mov    (%eax),%eax
f010673c:	83 e0 02             	and    $0x2,%eax
f010673f:	85 c0                	test   %eax,%eax
f0106741:	75 07                	jne    f010674a <sys_page_map+0x161>
		{
			return -E_INVAL;
f0106743:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106748:	eb 38                	jmp    f0106782 <sys_page_map+0x199>
		}
	}
	int w  = page_insert(e2->env_pgdir,l1,dstva,perm);
f010674a:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010674d:	8b 40 60             	mov    0x60(%eax),%eax
f0106750:	8b 55 18             	mov    0x18(%ebp),%edx
f0106753:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106757:	8b 55 14             	mov    0x14(%ebp),%edx
f010675a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010675e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106761:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106765:	89 04 24             	mov    %eax,(%esp)
f0106768:	e8 fb b2 ff ff       	call   f0101a68 <page_insert>
f010676d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if(w != 0)
f0106770:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0106774:	74 07                	je     f010677d <sys_page_map+0x194>
	{
		return -E_NO_MEM;
f0106776:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010677b:	eb 05                	jmp    f0106782 <sys_page_map+0x199>
	}
	return 0;
f010677d:	b8 00 00 00 00       	mov    $0x0,%eax
	// panic("sys_page_map not implemented");
}
f0106782:	c9                   	leave  
f0106783:	c3                   	ret    

f0106784 <sys_page_unmap>:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int
sys_page_unmap(envid_t envid, void *va)
{
f0106784:	55                   	push   %ebp
f0106785:	89 e5                	mov    %esp,%ebp
f0106787:	83 ec 28             	sub    $0x28,%esp
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env *e;
	int r = envid2env(envid,&e,1);
f010678a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106791:	00 
f0106792:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106795:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106799:	8b 45 08             	mov    0x8(%ebp),%eax
f010679c:	89 04 24             	mov    %eax,(%esp)
f010679f:	e8 50 db ff ff       	call   f01042f4 <envid2env>
f01067a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(r == -E_BAD_ENV)
f01067a7:	83 7d f4 fe          	cmpl   $0xfffffffe,-0xc(%ebp)
f01067ab:	75 07                	jne    f01067b4 <sys_page_unmap+0x30>
	{
		return -E_BAD_ENV;
f01067ad:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01067b2:	eb 62                	jmp    f0106816 <sys_page_unmap+0x92>
	}
	if((uintptr_t)va >= UTOP)
f01067b4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01067b7:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f01067bc:	76 07                	jbe    f01067c5 <sys_page_unmap+0x41>
	{
		return -E_INVAL;
f01067be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01067c3:	eb 51                	jmp    f0106816 <sys_page_unmap+0x92>
	}
	if((uintptr_t)va != ROUNDUP((uintptr_t)va,PGSIZE))
f01067c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01067c8:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
f01067cf:	8b 55 0c             	mov    0xc(%ebp),%edx
f01067d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01067d5:	01 d0                	add    %edx,%eax
f01067d7:	83 e8 01             	sub    $0x1,%eax
f01067da:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01067dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01067e0:	ba 00 00 00 00       	mov    $0x0,%edx
f01067e5:	f7 75 f0             	divl   -0x10(%ebp)
f01067e8:	89 d0                	mov    %edx,%eax
f01067ea:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01067ed:	29 c2                	sub    %eax,%edx
f01067ef:	89 d0                	mov    %edx,%eax
f01067f1:	39 c1                	cmp    %eax,%ecx
f01067f3:	74 07                	je     f01067fc <sys_page_unmap+0x78>
	{
		return -E_INVAL;
f01067f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01067fa:	eb 1a                	jmp    f0106816 <sys_page_unmap+0x92>
	}
	page_remove(e->env_pgdir,va);
f01067fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01067ff:	8b 40 60             	mov    0x60(%eax),%eax
f0106802:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106805:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106809:	89 04 24             	mov    %eax,(%esp)
f010680c:	e8 6d b3 ff ff       	call   f0101b7e <page_remove>
	return 0;
f0106811:	b8 00 00 00 00       	mov    $0x0,%eax

	// panic("sys_page_unmap not implemented");
}
f0106816:	c9                   	leave  
f0106817:	c3                   	ret    

f0106818 <sys_ipc_try_send>:
//		current environment's address space.
//	-E_NO_MEM if there's not enough memory to map srcva in envid's
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
f0106818:	55                   	push   %ebp
f0106819:	89 e5                	mov    %esp,%ebp
f010681b:	53                   	push   %ebx
f010681c:	83 ec 34             	sub    $0x34,%esp
	// LAB 4: Your code here.
	struct Env *e;
	int r = envid2env(envid,&e,0);
f010681f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0106826:	00 
f0106827:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010682a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010682e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106831:	89 04 24             	mov    %eax,(%esp)
f0106834:	e8 bb da ff ff       	call   f01042f4 <envid2env>
f0106839:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(r == -E_BAD_ENV)
f010683c:	83 7d f4 fe          	cmpl   $0xfffffffe,-0xc(%ebp)
f0106840:	75 0a                	jne    f010684c <sys_ipc_try_send+0x34>
	{
		return -E_BAD_ENV;
f0106842:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0106847:	e9 61 01 00 00       	jmp    f01069ad <sys_ipc_try_send+0x195>
	}
	if(e -> env_ipc_recving == 0)
f010684c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010684f:	0f b6 40 68          	movzbl 0x68(%eax),%eax
f0106853:	83 f0 01             	xor    $0x1,%eax
f0106856:	84 c0                	test   %al,%al
f0106858:	74 0a                	je     f0106864 <sys_ipc_try_send+0x4c>
	{
		return -E_IPC_NOT_RECV;
f010685a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
f010685f:	e9 49 01 00 00       	jmp    f01069ad <sys_ipc_try_send+0x195>
	}

	pte_t *x;
	pte_t **store = &x;
f0106864:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0106867:	89 45 f0             	mov    %eax,-0x10(%ebp)
	struct PageInfo *l1;
	if((uintptr_t)srcva < UTOP)
f010686a:	8b 45 10             	mov    0x10(%ebp),%eax
f010686d:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0106872:	0f 87 f4 00 00 00    	ja     f010696c <sys_ipc_try_send+0x154>
	{
		if((uintptr_t)srcva != ROUNDUP((uintptr_t)srcva,PGSIZE))
f0106878:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010687b:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%ebp)
f0106882:	8b 55 10             	mov    0x10(%ebp),%edx
f0106885:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106888:	01 d0                	add    %edx,%eax
f010688a:	83 e8 01             	sub    $0x1,%eax
f010688d:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0106890:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106893:	ba 00 00 00 00       	mov    $0x0,%edx
f0106898:	f7 75 ec             	divl   -0x14(%ebp)
f010689b:	89 d0                	mov    %edx,%eax
f010689d:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01068a0:	29 c2                	sub    %eax,%edx
f01068a2:	89 d0                	mov    %edx,%eax
f01068a4:	39 c1                	cmp    %eax,%ecx
f01068a6:	74 0a                	je     f01068b2 <sys_ipc_try_send+0x9a>
		{
			return -E_INVAL;
f01068a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01068ad:	e9 fb 00 00 00       	jmp    f01069ad <sys_ipc_try_send+0x195>
		}
		if ((perm & PTE_U) != PTE_U || (perm & PTE_P) != PTE_P || (perm & ~PTE_SYSCALL) != 0)
f01068b2:	8b 45 14             	mov    0x14(%ebp),%eax
f01068b5:	83 e0 04             	and    $0x4,%eax
f01068b8:	85 c0                	test   %eax,%eax
f01068ba:	74 16                	je     f01068d2 <sys_ipc_try_send+0xba>
f01068bc:	8b 45 14             	mov    0x14(%ebp),%eax
f01068bf:	83 e0 01             	and    $0x1,%eax
f01068c2:	85 c0                	test   %eax,%eax
f01068c4:	74 0c                	je     f01068d2 <sys_ipc_try_send+0xba>
f01068c6:	8b 45 14             	mov    0x14(%ebp),%eax
f01068c9:	25 f8 f1 ff ff       	and    $0xfffff1f8,%eax
f01068ce:	85 c0                	test   %eax,%eax
f01068d0:	74 0a                	je     f01068dc <sys_ipc_try_send+0xc4>
		{
			return -E_INVAL;
f01068d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01068d7:	e9 d1 00 00 00       	jmp    f01069ad <sys_ipc_try_send+0x195>
		}	
		l1 = page_lookup(e->env_pgdir,srcva,store);
f01068dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01068df:	8b 40 60             	mov    0x60(%eax),%eax
f01068e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01068e5:	89 54 24 08          	mov    %edx,0x8(%esp)
f01068e9:	8b 55 10             	mov    0x10(%ebp),%edx
f01068ec:	89 54 24 04          	mov    %edx,0x4(%esp)
f01068f0:	89 04 24             	mov    %eax,(%esp)
f01068f3:	e8 21 b2 ff ff       	call   f0101b19 <page_lookup>
f01068f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if(l1 == NULL)
f01068fb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01068ff:	75 0a                	jne    f010690b <sys_ipc_try_send+0xf3>
		{
			return -E_INVAL;
f0106901:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106906:	e9 a2 00 00 00       	jmp    f01069ad <sys_ipc_try_send+0x195>
		}
		if((perm & PTE_W) != 0)
f010690b:	8b 45 14             	mov    0x14(%ebp),%eax
f010690e:	83 e0 02             	and    $0x2,%eax
f0106911:	85 c0                	test   %eax,%eax
f0106913:	74 16                	je     f010692b <sys_ipc_try_send+0x113>
		{
			if((*x & PTE_W) == 0)
f0106915:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0106918:	8b 00                	mov    (%eax),%eax
f010691a:	83 e0 02             	and    $0x2,%eax
f010691d:	85 c0                	test   %eax,%eax
f010691f:	75 0a                	jne    f010692b <sys_ipc_try_send+0x113>
			{
				return -E_INVAL;
f0106921:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106926:	e9 82 00 00 00       	jmp    f01069ad <sys_ipc_try_send+0x195>
			}
		}
		int w = page_insert(e->env_pgdir, l1, e->env_ipc_dstva, perm) ;
f010692b:	8b 4d 14             	mov    0x14(%ebp),%ecx
f010692e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106931:	8b 50 6c             	mov    0x6c(%eax),%edx
f0106934:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106937:	8b 40 60             	mov    0x60(%eax),%eax
f010693a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010693e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106942:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0106945:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106949:	89 04 24             	mov    %eax,(%esp)
f010694c:	e8 17 b1 ff ff       	call   f0101a68 <page_insert>
f0106951:	89 45 e0             	mov    %eax,-0x20(%ebp)
		if(w != 0)
f0106954:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0106958:	74 07                	je     f0106961 <sys_ipc_try_send+0x149>
		{
			return -E_NO_MEM;
f010695a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010695f:	eb 4c                	jmp    f01069ad <sys_ipc_try_send+0x195>
		}
		e->env_ipc_perm = perm;
f0106961:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106964:	8b 55 14             	mov    0x14(%ebp),%edx
f0106967:	89 50 78             	mov    %edx,0x78(%eax)
f010696a:	eb 0a                	jmp    f0106976 <sys_ipc_try_send+0x15e>
	}
	else
	{
		e->env_ipc_perm = 0;
f010696c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010696f:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	}



	e->env_ipc_recving = 0;
f0106976:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106979:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	e->env_ipc_from = curenv->env_id;
f010697d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0106980:	e8 41 1c 00 00       	call   f01085c6 <cpunum>
f0106985:	6b c0 74             	imul   $0x74,%eax,%eax
f0106988:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f010698d:	8b 00                	mov    (%eax),%eax
f010698f:	8b 40 48             	mov    0x48(%eax),%eax
f0106992:	89 43 74             	mov    %eax,0x74(%ebx)
	e->env_ipc_value = value;
f0106995:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106998:	8b 55 0c             	mov    0xc(%ebp),%edx
f010699b:	89 50 70             	mov    %edx,0x70(%eax)
	e->env_status = ENV_RUNNABLE;
f010699e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01069a1:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

	return 0;
f01069a8:	b8 00 00 00 00       	mov    $0x0,%eax

	// panic("sys_ipc_try_send not implemented");
}
f01069ad:	83 c4 34             	add    $0x34,%esp
f01069b0:	5b                   	pop    %ebx
f01069b1:	5d                   	pop    %ebp
f01069b2:	c3                   	ret    

f01069b3 <sys_ipc_recv>:
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
f01069b3:	55                   	push   %ebp
f01069b4:	89 e5                	mov    %esp,%ebp
f01069b6:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	if((uintptr_t)dstva < UTOP)
f01069b9:	8b 45 08             	mov    0x8(%ebp),%eax
f01069bc:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f01069c1:	77 4e                	ja     f0106a11 <sys_ipc_recv+0x5e>
	{
		if((uintptr_t)dstva != ROUNDUP((uintptr_t)dstva,PGSIZE))
f01069c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01069c6:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
f01069cd:	8b 55 08             	mov    0x8(%ebp),%edx
f01069d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01069d3:	01 d0                	add    %edx,%eax
f01069d5:	83 e8 01             	sub    $0x1,%eax
f01069d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01069db:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01069de:	ba 00 00 00 00       	mov    $0x0,%edx
f01069e3:	f7 75 f4             	divl   -0xc(%ebp)
f01069e6:	89 d0                	mov    %edx,%eax
f01069e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01069eb:	29 c2                	sub    %eax,%edx
f01069ed:	89 d0                	mov    %edx,%eax
f01069ef:	39 c1                	cmp    %eax,%ecx
f01069f1:	74 07                	je     f01069fa <sys_ipc_recv+0x47>
		{
			return -E_INVAL;
f01069f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01069f8:	eb 71                	jmp    f0106a6b <sys_ipc_recv+0xb8>
		}
		curenv->env_ipc_dstva = dstva;	
f01069fa:	e8 c7 1b 00 00       	call   f01085c6 <cpunum>
f01069ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0106a02:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0106a07:	8b 00                	mov    (%eax),%eax
f0106a09:	8b 55 08             	mov    0x8(%ebp),%edx
f0106a0c:	89 50 6c             	mov    %edx,0x6c(%eax)
f0106a0f:	eb 16                	jmp    f0106a27 <sys_ipc_recv+0x74>
	}
	else
	{
		curenv->env_ipc_dstva = (void *)KERNBASE;
f0106a11:	e8 b0 1b 00 00       	call   f01085c6 <cpunum>
f0106a16:	6b c0 74             	imul   $0x74,%eax,%eax
f0106a19:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0106a1e:	8b 00                	mov    (%eax),%eax
f0106a20:	c7 40 6c 00 00 00 f0 	movl   $0xf0000000,0x6c(%eax)
	}
	curenv->env_ipc_recving = true;
f0106a27:	e8 9a 1b 00 00       	call   f01085c6 <cpunum>
f0106a2c:	6b c0 74             	imul   $0x74,%eax,%eax
f0106a2f:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0106a34:	8b 00                	mov    (%eax),%eax
f0106a36:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0106a3a:	e8 87 1b 00 00       	call   f01085c6 <cpunum>
f0106a3f:	6b c0 74             	imul   $0x74,%eax,%eax
f0106a42:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0106a47:	8b 00                	mov    (%eax),%eax
f0106a49:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_tf.tf_regs.reg_eax = 0;
f0106a50:	e8 71 1b 00 00       	call   f01085c6 <cpunum>
f0106a55:	6b c0 74             	imul   $0x74,%eax,%eax
f0106a58:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0106a5d:	8b 00                	mov    (%eax),%eax
f0106a5f:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	sched_yield();
f0106a66:	e8 b6 f5 ff ff       	call   f0106021 <sched_yield>

	// panic("sys_ipc_recv not implemented");
	return 0;
}
f0106a6b:	c9                   	leave  
f0106a6c:	c3                   	ret    

f0106a6d <syscall>:


// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0106a6d:	55                   	push   %ebp
f0106a6e:	89 e5                	mov    %esp,%ebp
f0106a70:	56                   	push   %esi
f0106a71:	53                   	push   %ebx
f0106a72:	83 ec 20             	sub    $0x20,%esp
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) 
f0106a75:	83 7d 08 0c          	cmpl   $0xc,0x8(%ebp)
f0106a79:	0f 87 1d 01 00 00    	ja     f0106b9c <syscall+0x12f>
f0106a7f:	8b 45 08             	mov    0x8(%ebp),%eax
f0106a82:	c1 e0 02             	shl    $0x2,%eax
f0106a85:	05 04 a3 10 f0       	add    $0xf010a304,%eax
f0106a8a:	8b 00                	mov    (%eax),%eax
f0106a8c:	ff e0                	jmp    *%eax
	{
		case SYS_cputs:
   			sys_cputs((char *)a1,(size_t) a2);
f0106a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106a91:	8b 55 10             	mov    0x10(%ebp),%edx
f0106a94:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106a98:	89 04 24             	mov    %eax,(%esp)
f0106a9b:	e8 0e f8 ff ff       	call   f01062ae <sys_cputs>
   			return 0;
f0106aa0:	b8 00 00 00 00       	mov    $0x0,%eax
f0106aa5:	e9 f7 00 00 00       	jmp    f0106ba1 <syscall+0x134>
 		case SYS_cgetc:
   			return sys_cgetc();
f0106aaa:	e8 4e f8 ff ff       	call   f01062fd <sys_cgetc>
f0106aaf:	e9 ed 00 00 00       	jmp    f0106ba1 <syscall+0x134>
 		case SYS_getenvid:
   			return sys_getenvid();
f0106ab4:	e8 51 f8 ff ff       	call   f010630a <sys_getenvid>
f0106ab9:	e9 e3 00 00 00       	jmp    f0106ba1 <syscall+0x134>
 		case SYS_env_destroy:
   			return sys_env_destroy((envid_t)a1);
f0106abe:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106ac1:	89 04 24             	mov    %eax,(%esp)
f0106ac4:	e8 5b f8 ff ff       	call   f0106324 <sys_env_destroy>
f0106ac9:	e9 d3 00 00 00       	jmp    f0106ba1 <syscall+0x134>
   		case SYS_yield:
			sys_yield();
f0106ace:	e8 fc f8 ff ff       	call   f01063cf <sys_yield>
			return 0;
f0106ad3:	b8 00 00 00 00       	mov    $0x0,%eax
f0106ad8:	e9 c4 00 00 00       	jmp    f0106ba1 <syscall+0x134>
		case SYS_exofork:
			return sys_exofork();
f0106add:	e8 f8 f8 ff ff       	call   f01063da <sys_exofork>
f0106ae2:	e9 ba 00 00 00       	jmp    f0106ba1 <syscall+0x134>
		case SYS_env_set_status:
			return sys_env_set_status(a1, a2);
f0106ae7:	8b 55 10             	mov    0x10(%ebp),%edx
f0106aea:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106aed:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106af1:	89 04 24             	mov    %eax,(%esp)
f0106af4:	e8 5e f9 ff ff       	call   f0106457 <sys_env_set_status>
f0106af9:	e9 a3 00 00 00       	jmp    f0106ba1 <syscall+0x134>
		case SYS_page_alloc:
			return sys_page_alloc(a1, (void *)a2, a3);
f0106afe:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0106b01:	8b 55 10             	mov    0x10(%ebp),%edx
f0106b04:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106b07:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106b0b:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106b0f:	89 04 24             	mov    %eax,(%esp)
f0106b12:	e8 d3 f9 ff ff       	call   f01064ea <sys_page_alloc>
f0106b17:	e9 85 00 00 00       	jmp    f0106ba1 <syscall+0x134>
		case SYS_page_map:
			return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
f0106b1c:	8b 75 1c             	mov    0x1c(%ebp),%esi
f0106b1f:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0106b22:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0106b25:	8b 55 10             	mov    0x10(%ebp),%edx
f0106b28:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106b2b:	89 74 24 10          	mov    %esi,0x10(%esp)
f0106b2f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106b33:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106b37:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106b3b:	89 04 24             	mov    %eax,(%esp)
f0106b3e:	e8 a6 fa ff ff       	call   f01065e9 <sys_page_map>
f0106b43:	eb 5c                	jmp    f0106ba1 <syscall+0x134>
		case SYS_page_unmap:
			return sys_page_unmap(a1, (void *)a2);
f0106b45:	8b 55 10             	mov    0x10(%ebp),%edx
f0106b48:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106b4b:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106b4f:	89 04 24             	mov    %eax,(%esp)
f0106b52:	e8 2d fc ff ff       	call   f0106784 <sys_page_unmap>
f0106b57:	eb 48                	jmp    f0106ba1 <syscall+0x134>
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void *) a2);
f0106b59:	8b 55 10             	mov    0x10(%ebp),%edx
f0106b5c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106b5f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106b63:	89 04 24             	mov    %eax,(%esp)
f0106b66:	e8 3f f9 ff ff       	call   f01064aa <sys_env_set_pgfault_upcall>
f0106b6b:	eb 34                	jmp    f0106ba1 <syscall+0x134>
		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void *)a3, a4);
f0106b6d:	8b 55 14             	mov    0x14(%ebp),%edx
f0106b70:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106b73:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0106b76:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0106b7a:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106b7e:	8b 55 10             	mov    0x10(%ebp),%edx
f0106b81:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106b85:	89 04 24             	mov    %eax,(%esp)
f0106b88:	e8 8b fc ff ff       	call   f0106818 <sys_ipc_try_send>
f0106b8d:	eb 12                	jmp    f0106ba1 <syscall+0x134>
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
f0106b8f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106b92:	89 04 24             	mov    %eax,(%esp)
f0106b95:	e8 19 fe ff ff       	call   f01069b3 <sys_ipc_recv>
f0106b9a:	eb 05                	jmp    f0106ba1 <syscall+0x134>
  		default:
    		return -E_INVAL;
f0106b9c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
}
f0106ba1:	83 c4 20             	add    $0x20,%esp
f0106ba4:	5b                   	pop    %ebx
f0106ba5:	5e                   	pop    %esi
f0106ba6:	5d                   	pop    %ebp
f0106ba7:	c3                   	ret    

f0106ba8 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0106ba8:	55                   	push   %ebp
f0106ba9:	89 e5                	mov    %esp,%ebp
f0106bab:	83 ec 20             	sub    $0x20,%esp
	int l = *region_left, r = *region_right, any_matches = 0;
f0106bae:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106bb1:	8b 00                	mov    (%eax),%eax
f0106bb3:	89 45 fc             	mov    %eax,-0x4(%ebp)
f0106bb6:	8b 45 10             	mov    0x10(%ebp),%eax
f0106bb9:	8b 00                	mov    (%eax),%eax
f0106bbb:	89 45 f8             	mov    %eax,-0x8(%ebp)
f0106bbe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	while (l <= r) {
f0106bc5:	e9 d2 00 00 00       	jmp    f0106c9c <stab_binsearch+0xf4>
		int true_m = (l + r) / 2, m = true_m;
f0106bca:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0106bcd:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0106bd0:	01 d0                	add    %edx,%eax
f0106bd2:	89 c2                	mov    %eax,%edx
f0106bd4:	c1 ea 1f             	shr    $0x1f,%edx
f0106bd7:	01 d0                	add    %edx,%eax
f0106bd9:	d1 f8                	sar    %eax
f0106bdb:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106bde:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106be1:	89 45 f0             	mov    %eax,-0x10(%ebp)

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0106be4:	eb 04                	jmp    f0106bea <stab_binsearch+0x42>
			m--;
f0106be6:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0106bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106bed:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f0106bf0:	7c 1f                	jl     f0106c11 <stab_binsearch+0x69>
f0106bf2:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106bf5:	89 d0                	mov    %edx,%eax
f0106bf7:	01 c0                	add    %eax,%eax
f0106bf9:	01 d0                	add    %edx,%eax
f0106bfb:	c1 e0 02             	shl    $0x2,%eax
f0106bfe:	89 c2                	mov    %eax,%edx
f0106c00:	8b 45 08             	mov    0x8(%ebp),%eax
f0106c03:	01 d0                	add    %edx,%eax
f0106c05:	0f b6 40 04          	movzbl 0x4(%eax),%eax
f0106c09:	0f b6 c0             	movzbl %al,%eax
f0106c0c:	3b 45 14             	cmp    0x14(%ebp),%eax
f0106c0f:	75 d5                	jne    f0106be6 <stab_binsearch+0x3e>
			m--;
		if (m < l) {	// no match in [l, m]
f0106c11:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106c14:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f0106c17:	7d 0b                	jge    f0106c24 <stab_binsearch+0x7c>
			l = true_m + 1;
f0106c19:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106c1c:	83 c0 01             	add    $0x1,%eax
f0106c1f:	89 45 fc             	mov    %eax,-0x4(%ebp)
			continue;
f0106c22:	eb 78                	jmp    f0106c9c <stab_binsearch+0xf4>
		}

		// actual binary search
		any_matches = 1;
f0106c24:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
		if (stabs[m].n_value < addr) {
f0106c2b:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106c2e:	89 d0                	mov    %edx,%eax
f0106c30:	01 c0                	add    %eax,%eax
f0106c32:	01 d0                	add    %edx,%eax
f0106c34:	c1 e0 02             	shl    $0x2,%eax
f0106c37:	89 c2                	mov    %eax,%edx
f0106c39:	8b 45 08             	mov    0x8(%ebp),%eax
f0106c3c:	01 d0                	add    %edx,%eax
f0106c3e:	8b 40 08             	mov    0x8(%eax),%eax
f0106c41:	3b 45 18             	cmp    0x18(%ebp),%eax
f0106c44:	73 13                	jae    f0106c59 <stab_binsearch+0xb1>
			*region_left = m;
f0106c46:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106c49:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106c4c:	89 10                	mov    %edx,(%eax)
			l = true_m + 1;
f0106c4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106c51:	83 c0 01             	add    $0x1,%eax
f0106c54:	89 45 fc             	mov    %eax,-0x4(%ebp)
f0106c57:	eb 43                	jmp    f0106c9c <stab_binsearch+0xf4>
		} else if (stabs[m].n_value > addr) {
f0106c59:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106c5c:	89 d0                	mov    %edx,%eax
f0106c5e:	01 c0                	add    %eax,%eax
f0106c60:	01 d0                	add    %edx,%eax
f0106c62:	c1 e0 02             	shl    $0x2,%eax
f0106c65:	89 c2                	mov    %eax,%edx
f0106c67:	8b 45 08             	mov    0x8(%ebp),%eax
f0106c6a:	01 d0                	add    %edx,%eax
f0106c6c:	8b 40 08             	mov    0x8(%eax),%eax
f0106c6f:	3b 45 18             	cmp    0x18(%ebp),%eax
f0106c72:	76 16                	jbe    f0106c8a <stab_binsearch+0xe2>
			*region_right = m - 1;
f0106c74:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106c77:	8d 50 ff             	lea    -0x1(%eax),%edx
f0106c7a:	8b 45 10             	mov    0x10(%ebp),%eax
f0106c7d:	89 10                	mov    %edx,(%eax)
			r = m - 1;
f0106c7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106c82:	83 e8 01             	sub    $0x1,%eax
f0106c85:	89 45 f8             	mov    %eax,-0x8(%ebp)
f0106c88:	eb 12                	jmp    f0106c9c <stab_binsearch+0xf4>
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0106c8a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106c8d:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106c90:	89 10                	mov    %edx,(%eax)
			l = m;
f0106c92:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106c95:	89 45 fc             	mov    %eax,-0x4(%ebp)
			addr++;
f0106c98:	83 45 18 01          	addl   $0x1,0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0106c9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0106c9f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
f0106ca2:	0f 8e 22 ff ff ff    	jle    f0106bca <stab_binsearch+0x22>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0106ca8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0106cac:	75 0f                	jne    f0106cbd <stab_binsearch+0x115>
		*region_right = *region_left - 1;
f0106cae:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106cb1:	8b 00                	mov    (%eax),%eax
f0106cb3:	8d 50 ff             	lea    -0x1(%eax),%edx
f0106cb6:	8b 45 10             	mov    0x10(%ebp),%eax
f0106cb9:	89 10                	mov    %edx,(%eax)
f0106cbb:	eb 3f                	jmp    f0106cfc <stab_binsearch+0x154>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0106cbd:	8b 45 10             	mov    0x10(%ebp),%eax
f0106cc0:	8b 00                	mov    (%eax),%eax
f0106cc2:	89 45 fc             	mov    %eax,-0x4(%ebp)
f0106cc5:	eb 04                	jmp    f0106ccb <stab_binsearch+0x123>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0106cc7:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0106ccb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106cce:	8b 00                	mov    (%eax),%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0106cd0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f0106cd3:	7d 1f                	jge    f0106cf4 <stab_binsearch+0x14c>
		     l > *region_left && stabs[l].n_type != type;
f0106cd5:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0106cd8:	89 d0                	mov    %edx,%eax
f0106cda:	01 c0                	add    %eax,%eax
f0106cdc:	01 d0                	add    %edx,%eax
f0106cde:	c1 e0 02             	shl    $0x2,%eax
f0106ce1:	89 c2                	mov    %eax,%edx
f0106ce3:	8b 45 08             	mov    0x8(%ebp),%eax
f0106ce6:	01 d0                	add    %edx,%eax
f0106ce8:	0f b6 40 04          	movzbl 0x4(%eax),%eax
f0106cec:	0f b6 c0             	movzbl %al,%eax
f0106cef:	3b 45 14             	cmp    0x14(%ebp),%eax
f0106cf2:	75 d3                	jne    f0106cc7 <stab_binsearch+0x11f>
		     l--)
			/* do nothing */;
		*region_left = l;
f0106cf4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106cf7:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0106cfa:	89 10                	mov    %edx,(%eax)
	}
}
f0106cfc:	c9                   	leave  
f0106cfd:	c3                   	ret    

f0106cfe <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0106cfe:	55                   	push   %ebp
f0106cff:	89 e5                	mov    %esp,%ebp
f0106d01:	53                   	push   %ebx
f0106d02:	83 ec 54             	sub    $0x54,%esp
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0106d05:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106d08:	c7 00 38 a3 10 f0    	movl   $0xf010a338,(%eax)
	info->eip_line = 0;
f0106d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106d11:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	info->eip_fn_name = "<unknown>";
f0106d18:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106d1b:	c7 40 08 38 a3 10 f0 	movl   $0xf010a338,0x8(%eax)
	info->eip_fn_namelen = 9;
f0106d22:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106d25:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
	info->eip_fn_addr = addr;
f0106d2c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106d2f:	8b 55 08             	mov    0x8(%ebp),%edx
f0106d32:	89 50 10             	mov    %edx,0x10(%eax)
	info->eip_fn_narg = 0;
f0106d35:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106d38:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0106d3f:	81 7d 08 ff ff 7f ef 	cmpl   $0xef7fffff,0x8(%ebp)
f0106d46:	76 21                	jbe    f0106d69 <debuginfo_eip+0x6b>
		stabs = __STAB_BEGIN__;
f0106d48:	c7 45 f4 80 a8 10 f0 	movl   $0xf010a880,-0xc(%ebp)
		stab_end = __STAB_END__;
f0106d4f:	c7 45 f0 b8 69 11 f0 	movl   $0xf01169b8,-0x10(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0106d56:	c7 45 ec b9 69 11 f0 	movl   $0xf01169b9,-0x14(%ebp)
		stabstr_end = __STABSTR_END__;
f0106d5d:	c7 45 e8 f2 a7 11 f0 	movl   $0xf011a7f2,-0x18(%ebp)
f0106d64:	e9 ed 00 00 00       	jmp    f0106e56 <debuginfo_eip+0x158>
		// The user-application linker script, user/user.ld,
		// puts information about the application's stabs (equivalent
		// to __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__, and
		// __STABSTR_END__) in a structure located at virtual address
		// USTABDATA.
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;
f0106d69:	c7 45 e4 00 00 20 00 	movl   $0x200000,-0x1c(%ebp)

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if(user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U | PTE_P))
f0106d70:	e8 51 18 00 00       	call   f01085c6 <cpunum>
f0106d75:	6b c0 74             	imul   $0x74,%eax,%eax
f0106d78:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0106d7d:	8b 00                	mov    (%eax),%eax
f0106d7f:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0106d86:	00 
f0106d87:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0106d8e:	00 
f0106d8f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0106d92:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106d96:	89 04 24             	mov    %eax,(%esp)
f0106d99:	e8 31 af ff ff       	call   f0101ccf <user_mem_check>
f0106d9e:	85 c0                	test   %eax,%eax
f0106da0:	74 0a                	je     f0106dac <debuginfo_eip+0xae>
			return -1; 
f0106da2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0106da7:	e9 89 03 00 00       	jmp    f0107135 <debuginfo_eip+0x437>

		stabs = usd->stabs;
f0106dac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106daf:	8b 00                	mov    (%eax),%eax
f0106db1:	89 45 f4             	mov    %eax,-0xc(%ebp)
		stab_end = usd->stab_end;
f0106db4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106db7:	8b 40 04             	mov    0x4(%eax),%eax
f0106dba:	89 45 f0             	mov    %eax,-0x10(%ebp)
		stabstr = usd->stabstr;
f0106dbd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106dc0:	8b 40 08             	mov    0x8(%eax),%eax
f0106dc3:	89 45 ec             	mov    %eax,-0x14(%ebp)
		stabstr_end = usd->stabstr_end;
f0106dc6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106dc9:	8b 40 0c             	mov    0xc(%eax),%eax
f0106dcc:	89 45 e8             	mov    %eax,-0x18(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.

		if ((user_mem_check(curenv, stabs, stab_end - stabs, PTE_U | PTE_P)) ||
f0106dcf:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106dd5:	29 c2                	sub    %eax,%edx
f0106dd7:	89 d0                	mov    %edx,%eax
f0106dd9:	c1 f8 02             	sar    $0x2,%eax
f0106ddc:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0106de2:	89 c3                	mov    %eax,%ebx
f0106de4:	e8 dd 17 00 00       	call   f01085c6 <cpunum>
f0106de9:	6b c0 74             	imul   $0x74,%eax,%eax
f0106dec:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0106df1:	8b 00                	mov    (%eax),%eax
f0106df3:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0106dfa:	00 
f0106dfb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106dff:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0106e02:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106e06:	89 04 24             	mov    %eax,(%esp)
f0106e09:	e8 c1 ae ff ff       	call   f0101ccf <user_mem_check>
f0106e0e:	85 c0                	test   %eax,%eax
f0106e10:	75 3a                	jne    f0106e4c <debuginfo_eip+0x14e>
		    (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U | PTE_P)) )
f0106e12:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0106e15:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106e18:	29 c2                	sub    %eax,%edx
f0106e1a:	89 d0                	mov    %edx,%eax
f0106e1c:	89 c3                	mov    %eax,%ebx
f0106e1e:	e8 a3 17 00 00       	call   f01085c6 <cpunum>
f0106e23:	6b c0 74             	imul   $0x74,%eax,%eax
f0106e26:	05 28 c0 23 f0       	add    $0xf023c028,%eax
f0106e2b:	8b 00                	mov    (%eax),%eax
f0106e2d:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0106e34:	00 
f0106e35:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106e39:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0106e3c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106e40:	89 04 24             	mov    %eax,(%esp)
f0106e43:	e8 87 ae ff ff       	call   f0101ccf <user_mem_check>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.

		if ((user_mem_check(curenv, stabs, stab_end - stabs, PTE_U | PTE_P)) ||
f0106e48:	85 c0                	test   %eax,%eax
f0106e4a:	74 0a                	je     f0106e56 <debuginfo_eip+0x158>
		    (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U | PTE_P)) )
			return -1; 
f0106e4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0106e51:	e9 df 02 00 00       	jmp    f0107135 <debuginfo_eip+0x437>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0106e56:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106e59:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f0106e5c:	76 0d                	jbe    f0106e6b <debuginfo_eip+0x16d>
f0106e5e:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106e61:	83 e8 01             	sub    $0x1,%eax
f0106e64:	0f b6 00             	movzbl (%eax),%eax
f0106e67:	84 c0                	test   %al,%al
f0106e69:	74 0a                	je     f0106e75 <debuginfo_eip+0x177>
		return -1;
f0106e6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0106e70:	e9 c0 02 00 00       	jmp    f0107135 <debuginfo_eip+0x437>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0106e75:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	rfile = (stab_end - stabs) - 1;
f0106e7c:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106e82:	29 c2                	sub    %eax,%edx
f0106e84:	89 d0                	mov    %edx,%eax
f0106e86:	c1 f8 02             	sar    $0x2,%eax
f0106e89:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0106e8f:	83 e8 01             	sub    $0x1,%eax
f0106e92:	89 45 dc             	mov    %eax,-0x24(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0106e95:	8b 45 08             	mov    0x8(%ebp),%eax
f0106e98:	89 44 24 10          	mov    %eax,0x10(%esp)
f0106e9c:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
f0106ea3:	00 
f0106ea4:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0106ea7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106eab:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0106eae:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106eb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106eb5:	89 04 24             	mov    %eax,(%esp)
f0106eb8:	e8 eb fc ff ff       	call   f0106ba8 <stab_binsearch>
	if (lfile == 0)
f0106ebd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106ec0:	85 c0                	test   %eax,%eax
f0106ec2:	75 0a                	jne    f0106ece <debuginfo_eip+0x1d0>
		return -1;
f0106ec4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0106ec9:	e9 67 02 00 00       	jmp    f0107135 <debuginfo_eip+0x437>

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0106ece:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106ed1:	89 45 d8             	mov    %eax,-0x28(%ebp)
	rfun = rfile;
f0106ed4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106ed7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0106eda:	8b 45 08             	mov    0x8(%ebp),%eax
f0106edd:	89 44 24 10          	mov    %eax,0x10(%esp)
f0106ee1:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
f0106ee8:	00 
f0106ee9:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f0106eec:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106ef0:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0106ef3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106efa:	89 04 24             	mov    %eax,(%esp)
f0106efd:	e8 a6 fc ff ff       	call   f0106ba8 <stab_binsearch>

	if (lfun <= rfun) {
f0106f02:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106f05:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0106f08:	39 c2                	cmp    %eax,%edx
f0106f0a:	7f 7c                	jg     f0106f88 <debuginfo_eip+0x28a>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0106f0c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0106f0f:	89 c2                	mov    %eax,%edx
f0106f11:	89 d0                	mov    %edx,%eax
f0106f13:	01 c0                	add    %eax,%eax
f0106f15:	01 d0                	add    %edx,%eax
f0106f17:	c1 e0 02             	shl    $0x2,%eax
f0106f1a:	89 c2                	mov    %eax,%edx
f0106f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106f1f:	01 d0                	add    %edx,%eax
f0106f21:	8b 10                	mov    (%eax),%edx
f0106f23:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0106f26:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106f29:	29 c1                	sub    %eax,%ecx
f0106f2b:	89 c8                	mov    %ecx,%eax
f0106f2d:	39 c2                	cmp    %eax,%edx
f0106f2f:	73 22                	jae    f0106f53 <debuginfo_eip+0x255>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0106f31:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0106f34:	89 c2                	mov    %eax,%edx
f0106f36:	89 d0                	mov    %edx,%eax
f0106f38:	01 c0                	add    %eax,%eax
f0106f3a:	01 d0                	add    %edx,%eax
f0106f3c:	c1 e0 02             	shl    $0x2,%eax
f0106f3f:	89 c2                	mov    %eax,%edx
f0106f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106f44:	01 d0                	add    %edx,%eax
f0106f46:	8b 10                	mov    (%eax),%edx
f0106f48:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106f4b:	01 c2                	add    %eax,%edx
f0106f4d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106f50:	89 50 08             	mov    %edx,0x8(%eax)
		info->eip_fn_addr = stabs[lfun].n_value;
f0106f53:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0106f56:	89 c2                	mov    %eax,%edx
f0106f58:	89 d0                	mov    %edx,%eax
f0106f5a:	01 c0                	add    %eax,%eax
f0106f5c:	01 d0                	add    %edx,%eax
f0106f5e:	c1 e0 02             	shl    $0x2,%eax
f0106f61:	89 c2                	mov    %eax,%edx
f0106f63:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106f66:	01 d0                	add    %edx,%eax
f0106f68:	8b 50 08             	mov    0x8(%eax),%edx
f0106f6b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106f6e:	89 50 10             	mov    %edx,0x10(%eax)
		addr -= info->eip_fn_addr;
f0106f71:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106f74:	8b 40 10             	mov    0x10(%eax),%eax
f0106f77:	29 45 08             	sub    %eax,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0106f7a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0106f7d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		rline = rfun;
f0106f80:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0106f83:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0106f86:	eb 15                	jmp    f0106f9d <debuginfo_eip+0x29f>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0106f88:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106f8b:	8b 55 08             	mov    0x8(%ebp),%edx
f0106f8e:	89 50 10             	mov    %edx,0x10(%eax)
		lline = lfile;
f0106f91:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106f94:	89 45 d0             	mov    %eax,-0x30(%ebp)
		rline = rfile;
f0106f97:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106f9a:	89 45 cc             	mov    %eax,-0x34(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0106f9d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106fa0:	8b 40 08             	mov    0x8(%eax),%eax
f0106fa3:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0106faa:	00 
f0106fab:	89 04 24             	mov    %eax,(%esp)
f0106fae:	e8 1b 0b 00 00       	call   f0107ace <strfind>
f0106fb3:	89 c2                	mov    %eax,%edx
f0106fb5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106fb8:	8b 40 08             	mov    0x8(%eax),%eax
f0106fbb:	29 c2                	sub    %eax,%edx
f0106fbd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106fc0:	89 50 0c             	mov    %edx,0xc(%eax)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0106fc3:	8b 45 08             	mov    0x8(%ebp),%eax
f0106fc6:	89 44 24 10          	mov    %eax,0x10(%esp)
f0106fca:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
f0106fd1:	00 
f0106fd2:	8d 45 cc             	lea    -0x34(%ebp),%eax
f0106fd5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106fd9:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0106fdc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106fe0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106fe3:	89 04 24             	mov    %eax,(%esp)
f0106fe6:	e8 bd fb ff ff       	call   f0106ba8 <stab_binsearch>
	if (lline == rline) 
f0106feb:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0106fee:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0106ff1:	39 c2                	cmp    %eax,%edx
f0106ff3:	75 24                	jne    f0107019 <debuginfo_eip+0x31b>
	  info->eip_line = stabs[rline].n_desc;
f0106ff5:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0106ff8:	89 c2                	mov    %eax,%edx
f0106ffa:	89 d0                	mov    %edx,%eax
f0106ffc:	01 c0                	add    %eax,%eax
f0106ffe:	01 d0                	add    %edx,%eax
f0107000:	c1 e0 02             	shl    $0x2,%eax
f0107003:	89 c2                	mov    %eax,%edx
f0107005:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107008:	01 d0                	add    %edx,%eax
f010700a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
f010700e:	0f b7 d0             	movzwl %ax,%edx
f0107011:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107014:	89 50 04             	mov    %edx,0x4(%eax)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0107017:	eb 13                	jmp    f010702c <debuginfo_eip+0x32e>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == rline) 
	  info->eip_line = stabs[rline].n_desc;
	else
	  return -1;
f0107019:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010701e:	e9 12 01 00 00       	jmp    f0107135 <debuginfo_eip+0x437>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0107023:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0107026:	83 e8 01             	sub    $0x1,%eax
f0107029:	89 45 d0             	mov    %eax,-0x30(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010702c:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010702f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107032:	39 c2                	cmp    %eax,%edx
f0107034:	7c 56                	jl     f010708c <debuginfo_eip+0x38e>
	       && stabs[lline].n_type != N_SOL
f0107036:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0107039:	89 c2                	mov    %eax,%edx
f010703b:	89 d0                	mov    %edx,%eax
f010703d:	01 c0                	add    %eax,%eax
f010703f:	01 d0                	add    %edx,%eax
f0107041:	c1 e0 02             	shl    $0x2,%eax
f0107044:	89 c2                	mov    %eax,%edx
f0107046:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107049:	01 d0                	add    %edx,%eax
f010704b:	0f b6 40 04          	movzbl 0x4(%eax),%eax
f010704f:	3c 84                	cmp    $0x84,%al
f0107051:	74 39                	je     f010708c <debuginfo_eip+0x38e>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0107053:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0107056:	89 c2                	mov    %eax,%edx
f0107058:	89 d0                	mov    %edx,%eax
f010705a:	01 c0                	add    %eax,%eax
f010705c:	01 d0                	add    %edx,%eax
f010705e:	c1 e0 02             	shl    $0x2,%eax
f0107061:	89 c2                	mov    %eax,%edx
f0107063:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107066:	01 d0                	add    %edx,%eax
f0107068:	0f b6 40 04          	movzbl 0x4(%eax),%eax
f010706c:	3c 64                	cmp    $0x64,%al
f010706e:	75 b3                	jne    f0107023 <debuginfo_eip+0x325>
f0107070:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0107073:	89 c2                	mov    %eax,%edx
f0107075:	89 d0                	mov    %edx,%eax
f0107077:	01 c0                	add    %eax,%eax
f0107079:	01 d0                	add    %edx,%eax
f010707b:	c1 e0 02             	shl    $0x2,%eax
f010707e:	89 c2                	mov    %eax,%edx
f0107080:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107083:	01 d0                	add    %edx,%eax
f0107085:	8b 40 08             	mov    0x8(%eax),%eax
f0107088:	85 c0                	test   %eax,%eax
f010708a:	74 97                	je     f0107023 <debuginfo_eip+0x325>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010708c:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010708f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107092:	39 c2                	cmp    %eax,%edx
f0107094:	7c 46                	jl     f01070dc <debuginfo_eip+0x3de>
f0107096:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0107099:	89 c2                	mov    %eax,%edx
f010709b:	89 d0                	mov    %edx,%eax
f010709d:	01 c0                	add    %eax,%eax
f010709f:	01 d0                	add    %edx,%eax
f01070a1:	c1 e0 02             	shl    $0x2,%eax
f01070a4:	89 c2                	mov    %eax,%edx
f01070a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01070a9:	01 d0                	add    %edx,%eax
f01070ab:	8b 10                	mov    (%eax),%edx
f01070ad:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01070b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01070b3:	29 c1                	sub    %eax,%ecx
f01070b5:	89 c8                	mov    %ecx,%eax
f01070b7:	39 c2                	cmp    %eax,%edx
f01070b9:	73 21                	jae    f01070dc <debuginfo_eip+0x3de>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01070bb:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01070be:	89 c2                	mov    %eax,%edx
f01070c0:	89 d0                	mov    %edx,%eax
f01070c2:	01 c0                	add    %eax,%eax
f01070c4:	01 d0                	add    %edx,%eax
f01070c6:	c1 e0 02             	shl    $0x2,%eax
f01070c9:	89 c2                	mov    %eax,%edx
f01070cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01070ce:	01 d0                	add    %edx,%eax
f01070d0:	8b 10                	mov    (%eax),%edx
f01070d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01070d5:	01 c2                	add    %eax,%edx
f01070d7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01070da:	89 10                	mov    %edx,(%eax)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01070dc:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01070df:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01070e2:	39 c2                	cmp    %eax,%edx
f01070e4:	7d 4a                	jge    f0107130 <debuginfo_eip+0x432>
		for (lline = lfun + 1;
f01070e6:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01070e9:	83 c0 01             	add    $0x1,%eax
f01070ec:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01070ef:	eb 18                	jmp    f0107109 <debuginfo_eip+0x40b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01070f1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01070f4:	8b 40 14             	mov    0x14(%eax),%eax
f01070f7:	8d 50 01             	lea    0x1(%eax),%edx
f01070fa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01070fd:	89 50 14             	mov    %edx,0x14(%eax)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0107100:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0107103:	83 c0 01             	add    $0x1,%eax
f0107106:	89 45 d0             	mov    %eax,-0x30(%ebp)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0107109:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010710c:	8b 45 d4             	mov    -0x2c(%ebp),%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010710f:	39 c2                	cmp    %eax,%edx
f0107111:	7d 1d                	jge    f0107130 <debuginfo_eip+0x432>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0107113:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0107116:	89 c2                	mov    %eax,%edx
f0107118:	89 d0                	mov    %edx,%eax
f010711a:	01 c0                	add    %eax,%eax
f010711c:	01 d0                	add    %edx,%eax
f010711e:	c1 e0 02             	shl    $0x2,%eax
f0107121:	89 c2                	mov    %eax,%edx
f0107123:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107126:	01 d0                	add    %edx,%eax
f0107128:	0f b6 40 04          	movzbl 0x4(%eax),%eax
f010712c:	3c a0                	cmp    $0xa0,%al
f010712e:	74 c1                	je     f01070f1 <debuginfo_eip+0x3f3>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0107130:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0107135:	83 c4 54             	add    $0x54,%esp
f0107138:	5b                   	pop    %ebx
f0107139:	5d                   	pop    %ebp
f010713a:	c3                   	ret    

f010713b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010713b:	55                   	push   %ebp
f010713c:	89 e5                	mov    %esp,%ebp
f010713e:	53                   	push   %ebx
f010713f:	83 ec 34             	sub    $0x34,%esp
f0107142:	8b 45 10             	mov    0x10(%ebp),%eax
f0107145:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0107148:	8b 45 14             	mov    0x14(%ebp),%eax
f010714b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010714e:	8b 45 18             	mov    0x18(%ebp),%eax
f0107151:	ba 00 00 00 00       	mov    $0x0,%edx
f0107156:	3b 55 f4             	cmp    -0xc(%ebp),%edx
f0107159:	77 72                	ja     f01071cd <printnum+0x92>
f010715b:	3b 55 f4             	cmp    -0xc(%ebp),%edx
f010715e:	72 05                	jb     f0107165 <printnum+0x2a>
f0107160:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f0107163:	77 68                	ja     f01071cd <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0107165:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0107168:	8d 58 ff             	lea    -0x1(%eax),%ebx
f010716b:	8b 45 18             	mov    0x18(%ebp),%eax
f010716e:	ba 00 00 00 00       	mov    $0x0,%edx
f0107173:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107177:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010717b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010717e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0107181:	89 04 24             	mov    %eax,(%esp)
f0107184:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107188:	e8 93 18 00 00       	call   f0108a20 <__udivdi3>
f010718d:	8b 4d 20             	mov    0x20(%ebp),%ecx
f0107190:	89 4c 24 18          	mov    %ecx,0x18(%esp)
f0107194:	89 5c 24 14          	mov    %ebx,0x14(%esp)
f0107198:	8b 4d 18             	mov    0x18(%ebp),%ecx
f010719b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f010719f:	89 44 24 08          	mov    %eax,0x8(%esp)
f01071a3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01071a7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01071aa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01071ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01071b1:	89 04 24             	mov    %eax,(%esp)
f01071b4:	e8 82 ff ff ff       	call   f010713b <printnum>
f01071b9:	eb 1c                	jmp    f01071d7 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01071bb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01071be:	89 44 24 04          	mov    %eax,0x4(%esp)
f01071c2:	8b 45 20             	mov    0x20(%ebp),%eax
f01071c5:	89 04 24             	mov    %eax,(%esp)
f01071c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01071cb:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01071cd:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
f01071d1:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
f01071d5:	7f e4                	jg     f01071bb <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01071d7:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01071da:	bb 00 00 00 00       	mov    $0x0,%ebx
f01071df:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01071e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01071e5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01071e9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01071ed:	89 04 24             	mov    %eax,(%esp)
f01071f0:	89 54 24 04          	mov    %edx,0x4(%esp)
f01071f4:	e8 57 19 00 00       	call   f0108b50 <__umoddi3>
f01071f9:	05 28 a4 10 f0       	add    $0xf010a428,%eax
f01071fe:	0f b6 00             	movzbl (%eax),%eax
f0107201:	0f be c0             	movsbl %al,%eax
f0107204:	8b 55 0c             	mov    0xc(%ebp),%edx
f0107207:	89 54 24 04          	mov    %edx,0x4(%esp)
f010720b:	89 04 24             	mov    %eax,(%esp)
f010720e:	8b 45 08             	mov    0x8(%ebp),%eax
f0107211:	ff d0                	call   *%eax
}
f0107213:	83 c4 34             	add    $0x34,%esp
f0107216:	5b                   	pop    %ebx
f0107217:	5d                   	pop    %ebp
f0107218:	c3                   	ret    

f0107219 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0107219:	55                   	push   %ebp
f010721a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010721c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f0107220:	7e 14                	jle    f0107236 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
f0107222:	8b 45 08             	mov    0x8(%ebp),%eax
f0107225:	8b 00                	mov    (%eax),%eax
f0107227:	8d 48 08             	lea    0x8(%eax),%ecx
f010722a:	8b 55 08             	mov    0x8(%ebp),%edx
f010722d:	89 0a                	mov    %ecx,(%edx)
f010722f:	8b 50 04             	mov    0x4(%eax),%edx
f0107232:	8b 00                	mov    (%eax),%eax
f0107234:	eb 30                	jmp    f0107266 <getuint+0x4d>
	else if (lflag)
f0107236:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010723a:	74 16                	je     f0107252 <getuint+0x39>
		return va_arg(*ap, unsigned long);
f010723c:	8b 45 08             	mov    0x8(%ebp),%eax
f010723f:	8b 00                	mov    (%eax),%eax
f0107241:	8d 48 04             	lea    0x4(%eax),%ecx
f0107244:	8b 55 08             	mov    0x8(%ebp),%edx
f0107247:	89 0a                	mov    %ecx,(%edx)
f0107249:	8b 00                	mov    (%eax),%eax
f010724b:	ba 00 00 00 00       	mov    $0x0,%edx
f0107250:	eb 14                	jmp    f0107266 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
f0107252:	8b 45 08             	mov    0x8(%ebp),%eax
f0107255:	8b 00                	mov    (%eax),%eax
f0107257:	8d 48 04             	lea    0x4(%eax),%ecx
f010725a:	8b 55 08             	mov    0x8(%ebp),%edx
f010725d:	89 0a                	mov    %ecx,(%edx)
f010725f:	8b 00                	mov    (%eax),%eax
f0107261:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0107266:	5d                   	pop    %ebp
f0107267:	c3                   	ret    

f0107268 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0107268:	55                   	push   %ebp
f0107269:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010726b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f010726f:	7e 14                	jle    f0107285 <getint+0x1d>
		return va_arg(*ap, long long);
f0107271:	8b 45 08             	mov    0x8(%ebp),%eax
f0107274:	8b 00                	mov    (%eax),%eax
f0107276:	8d 48 08             	lea    0x8(%eax),%ecx
f0107279:	8b 55 08             	mov    0x8(%ebp),%edx
f010727c:	89 0a                	mov    %ecx,(%edx)
f010727e:	8b 50 04             	mov    0x4(%eax),%edx
f0107281:	8b 00                	mov    (%eax),%eax
f0107283:	eb 28                	jmp    f01072ad <getint+0x45>
	else if (lflag)
f0107285:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0107289:	74 12                	je     f010729d <getint+0x35>
		return va_arg(*ap, long);
f010728b:	8b 45 08             	mov    0x8(%ebp),%eax
f010728e:	8b 00                	mov    (%eax),%eax
f0107290:	8d 48 04             	lea    0x4(%eax),%ecx
f0107293:	8b 55 08             	mov    0x8(%ebp),%edx
f0107296:	89 0a                	mov    %ecx,(%edx)
f0107298:	8b 00                	mov    (%eax),%eax
f010729a:	99                   	cltd   
f010729b:	eb 10                	jmp    f01072ad <getint+0x45>
	else
		return va_arg(*ap, int);
f010729d:	8b 45 08             	mov    0x8(%ebp),%eax
f01072a0:	8b 00                	mov    (%eax),%eax
f01072a2:	8d 48 04             	lea    0x4(%eax),%ecx
f01072a5:	8b 55 08             	mov    0x8(%ebp),%edx
f01072a8:	89 0a                	mov    %ecx,(%edx)
f01072aa:	8b 00                	mov    (%eax),%eax
f01072ac:	99                   	cltd   
}
f01072ad:	5d                   	pop    %ebp
f01072ae:	c3                   	ret    

f01072af <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01072af:	55                   	push   %ebp
f01072b0:	89 e5                	mov    %esp,%ebp
f01072b2:	56                   	push   %esi
f01072b3:	53                   	push   %ebx
f01072b4:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01072b7:	eb 18                	jmp    f01072d1 <vprintfmt+0x22>
			if (ch == '\0')
f01072b9:	85 db                	test   %ebx,%ebx
f01072bb:	75 05                	jne    f01072c2 <vprintfmt+0x13>
				return;
f01072bd:	e9 05 04 00 00       	jmp    f01076c7 <vprintfmt+0x418>
			putch(ch, putdat);
f01072c2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01072c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01072c9:	89 1c 24             	mov    %ebx,(%esp)
f01072cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01072cf:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01072d1:	8b 45 10             	mov    0x10(%ebp),%eax
f01072d4:	8d 50 01             	lea    0x1(%eax),%edx
f01072d7:	89 55 10             	mov    %edx,0x10(%ebp)
f01072da:	0f b6 00             	movzbl (%eax),%eax
f01072dd:	0f b6 d8             	movzbl %al,%ebx
f01072e0:	83 fb 25             	cmp    $0x25,%ebx
f01072e3:	75 d4                	jne    f01072b9 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
f01072e5:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
f01072e9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
f01072f0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f01072f7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
f01072fe:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0107305:	8b 45 10             	mov    0x10(%ebp),%eax
f0107308:	8d 50 01             	lea    0x1(%eax),%edx
f010730b:	89 55 10             	mov    %edx,0x10(%ebp)
f010730e:	0f b6 00             	movzbl (%eax),%eax
f0107311:	0f b6 d8             	movzbl %al,%ebx
f0107314:	8d 43 dd             	lea    -0x23(%ebx),%eax
f0107317:	83 f8 55             	cmp    $0x55,%eax
f010731a:	0f 87 76 03 00 00    	ja     f0107696 <vprintfmt+0x3e7>
f0107320:	8b 04 85 4c a4 10 f0 	mov    -0xfef5bb4(,%eax,4),%eax
f0107327:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
f0107329:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
f010732d:	eb d6                	jmp    f0107305 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f010732f:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
f0107333:	eb d0                	jmp    f0107305 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0107335:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
f010733c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010733f:	89 d0                	mov    %edx,%eax
f0107341:	c1 e0 02             	shl    $0x2,%eax
f0107344:	01 d0                	add    %edx,%eax
f0107346:	01 c0                	add    %eax,%eax
f0107348:	01 d8                	add    %ebx,%eax
f010734a:	83 e8 30             	sub    $0x30,%eax
f010734d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
f0107350:	8b 45 10             	mov    0x10(%ebp),%eax
f0107353:	0f b6 00             	movzbl (%eax),%eax
f0107356:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
f0107359:	83 fb 2f             	cmp    $0x2f,%ebx
f010735c:	7e 0b                	jle    f0107369 <vprintfmt+0xba>
f010735e:	83 fb 39             	cmp    $0x39,%ebx
f0107361:	7f 06                	jg     f0107369 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0107363:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0107367:	eb d3                	jmp    f010733c <vprintfmt+0x8d>
			goto process_precision;
f0107369:	eb 33                	jmp    f010739e <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
f010736b:	8b 45 14             	mov    0x14(%ebp),%eax
f010736e:	8d 50 04             	lea    0x4(%eax),%edx
f0107371:	89 55 14             	mov    %edx,0x14(%ebp)
f0107374:	8b 00                	mov    (%eax),%eax
f0107376:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
f0107379:	eb 23                	jmp    f010739e <vprintfmt+0xef>

		case '.':
			if (width < 0)
f010737b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010737f:	79 0c                	jns    f010738d <vprintfmt+0xde>
				width = 0;
f0107381:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
f0107388:	e9 78 ff ff ff       	jmp    f0107305 <vprintfmt+0x56>
f010738d:	e9 73 ff ff ff       	jmp    f0107305 <vprintfmt+0x56>

		case '#':
			altflag = 1;
f0107392:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0107399:	e9 67 ff ff ff       	jmp    f0107305 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
f010739e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01073a2:	79 12                	jns    f01073b6 <vprintfmt+0x107>
				width = precision, precision = -1;
f01073a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01073a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01073aa:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
f01073b1:	e9 4f ff ff ff       	jmp    f0107305 <vprintfmt+0x56>
f01073b6:	e9 4a ff ff ff       	jmp    f0107305 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01073bb:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
f01073bf:	e9 41 ff ff ff       	jmp    f0107305 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01073c4:	8b 45 14             	mov    0x14(%ebp),%eax
f01073c7:	8d 50 04             	lea    0x4(%eax),%edx
f01073ca:	89 55 14             	mov    %edx,0x14(%ebp)
f01073cd:	8b 00                	mov    (%eax),%eax
f01073cf:	8b 55 0c             	mov    0xc(%ebp),%edx
f01073d2:	89 54 24 04          	mov    %edx,0x4(%esp)
f01073d6:	89 04 24             	mov    %eax,(%esp)
f01073d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01073dc:	ff d0                	call   *%eax
			break;
f01073de:	e9 de 02 00 00       	jmp    f01076c1 <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01073e3:	8b 45 14             	mov    0x14(%ebp),%eax
f01073e6:	8d 50 04             	lea    0x4(%eax),%edx
f01073e9:	89 55 14             	mov    %edx,0x14(%ebp)
f01073ec:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
f01073ee:	85 db                	test   %ebx,%ebx
f01073f0:	79 02                	jns    f01073f4 <vprintfmt+0x145>
				err = -err;
f01073f2:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01073f4:	83 fb 09             	cmp    $0x9,%ebx
f01073f7:	7f 0b                	jg     f0107404 <vprintfmt+0x155>
f01073f9:	8b 34 9d 00 a4 10 f0 	mov    -0xfef5c00(,%ebx,4),%esi
f0107400:	85 f6                	test   %esi,%esi
f0107402:	75 23                	jne    f0107427 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
f0107404:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0107408:	c7 44 24 08 39 a4 10 	movl   $0xf010a439,0x8(%esp)
f010740f:	f0 
f0107410:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107413:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107417:	8b 45 08             	mov    0x8(%ebp),%eax
f010741a:	89 04 24             	mov    %eax,(%esp)
f010741d:	e8 ac 02 00 00       	call   f01076ce <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
f0107422:	e9 9a 02 00 00       	jmp    f01076c1 <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0107427:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010742b:	c7 44 24 08 42 a4 10 	movl   $0xf010a442,0x8(%esp)
f0107432:	f0 
f0107433:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107436:	89 44 24 04          	mov    %eax,0x4(%esp)
f010743a:	8b 45 08             	mov    0x8(%ebp),%eax
f010743d:	89 04 24             	mov    %eax,(%esp)
f0107440:	e8 89 02 00 00       	call   f01076ce <printfmt>
			break;
f0107445:	e9 77 02 00 00       	jmp    f01076c1 <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010744a:	8b 45 14             	mov    0x14(%ebp),%eax
f010744d:	8d 50 04             	lea    0x4(%eax),%edx
f0107450:	89 55 14             	mov    %edx,0x14(%ebp)
f0107453:	8b 30                	mov    (%eax),%esi
f0107455:	85 f6                	test   %esi,%esi
f0107457:	75 05                	jne    f010745e <vprintfmt+0x1af>
				p = "(null)";
f0107459:	be 45 a4 10 f0       	mov    $0xf010a445,%esi
			if (width > 0 && padc != '-')
f010745e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0107462:	7e 37                	jle    f010749b <vprintfmt+0x1ec>
f0107464:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
f0107468:	74 31                	je     f010749b <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
f010746a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010746d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107471:	89 34 24             	mov    %esi,(%esp)
f0107474:	e8 67 04 00 00       	call   f01078e0 <strnlen>
f0107479:	29 45 e4             	sub    %eax,-0x1c(%ebp)
f010747c:	eb 17                	jmp    f0107495 <vprintfmt+0x1e6>
					putch(padc, putdat);
f010747e:	0f be 45 db          	movsbl -0x25(%ebp),%eax
f0107482:	8b 55 0c             	mov    0xc(%ebp),%edx
f0107485:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107489:	89 04 24             	mov    %eax,(%esp)
f010748c:	8b 45 08             	mov    0x8(%ebp),%eax
f010748f:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0107491:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0107495:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0107499:	7f e3                	jg     f010747e <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010749b:	eb 38                	jmp    f01074d5 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
f010749d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01074a1:	74 1f                	je     f01074c2 <vprintfmt+0x213>
f01074a3:	83 fb 1f             	cmp    $0x1f,%ebx
f01074a6:	7e 05                	jle    f01074ad <vprintfmt+0x1fe>
f01074a8:	83 fb 7e             	cmp    $0x7e,%ebx
f01074ab:	7e 15                	jle    f01074c2 <vprintfmt+0x213>
					putch('?', putdat);
f01074ad:	8b 45 0c             	mov    0xc(%ebp),%eax
f01074b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01074b4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01074bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01074be:	ff d0                	call   *%eax
f01074c0:	eb 0f                	jmp    f01074d1 <vprintfmt+0x222>
				else
					putch(ch, putdat);
f01074c2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01074c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01074c9:	89 1c 24             	mov    %ebx,(%esp)
f01074cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01074cf:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01074d1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f01074d5:	89 f0                	mov    %esi,%eax
f01074d7:	8d 70 01             	lea    0x1(%eax),%esi
f01074da:	0f b6 00             	movzbl (%eax),%eax
f01074dd:	0f be d8             	movsbl %al,%ebx
f01074e0:	85 db                	test   %ebx,%ebx
f01074e2:	74 10                	je     f01074f4 <vprintfmt+0x245>
f01074e4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01074e8:	78 b3                	js     f010749d <vprintfmt+0x1ee>
f01074ea:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f01074ee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01074f2:	79 a9                	jns    f010749d <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01074f4:	eb 17                	jmp    f010750d <vprintfmt+0x25e>
				putch(' ', putdat);
f01074f6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01074f9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01074fd:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0107504:	8b 45 08             	mov    0x8(%ebp),%eax
f0107507:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0107509:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f010750d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0107511:	7f e3                	jg     f01074f6 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
f0107513:	e9 a9 01 00 00       	jmp    f01076c1 <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0107518:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010751b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010751f:	8d 45 14             	lea    0x14(%ebp),%eax
f0107522:	89 04 24             	mov    %eax,(%esp)
f0107525:	e8 3e fd ff ff       	call   f0107268 <getint>
f010752a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010752d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
f0107530:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107533:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0107536:	85 d2                	test   %edx,%edx
f0107538:	79 26                	jns    f0107560 <vprintfmt+0x2b1>
				putch('-', putdat);
f010753a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010753d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107541:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0107548:	8b 45 08             	mov    0x8(%ebp),%eax
f010754b:	ff d0                	call   *%eax
				num = -(long long) num;
f010754d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107550:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0107553:	f7 d8                	neg    %eax
f0107555:	83 d2 00             	adc    $0x0,%edx
f0107558:	f7 da                	neg    %edx
f010755a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010755d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
f0107560:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
f0107567:	e9 e1 00 00 00       	jmp    f010764d <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010756c:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010756f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107573:	8d 45 14             	lea    0x14(%ebp),%eax
f0107576:	89 04 24             	mov    %eax,(%esp)
f0107579:	e8 9b fc ff ff       	call   f0107219 <getuint>
f010757e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0107581:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
f0107584:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
f010758b:	e9 bd 00 00 00       	jmp    f010764d <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
f0107590:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
f0107597:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010759a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010759e:	8d 45 14             	lea    0x14(%ebp),%eax
f01075a1:	89 04 24             	mov    %eax,(%esp)
f01075a4:	e8 70 fc ff ff       	call   f0107219 <getuint>
f01075a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01075ac:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
f01075af:	0f be 55 db          	movsbl -0x25(%ebp),%edx
f01075b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01075b6:	89 54 24 18          	mov    %edx,0x18(%esp)
f01075ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01075bd:	89 54 24 14          	mov    %edx,0x14(%esp)
f01075c1:	89 44 24 10          	mov    %eax,0x10(%esp)
f01075c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01075c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01075cb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01075cf:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01075d3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01075d6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01075da:	8b 45 08             	mov    0x8(%ebp),%eax
f01075dd:	89 04 24             	mov    %eax,(%esp)
f01075e0:	e8 56 fb ff ff       	call   f010713b <printnum>
			break;
f01075e5:	e9 d7 00 00 00       	jmp    f01076c1 <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
f01075ea:	8b 45 0c             	mov    0xc(%ebp),%eax
f01075ed:	89 44 24 04          	mov    %eax,0x4(%esp)
f01075f1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01075f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01075fb:	ff d0                	call   *%eax
			putch('x', putdat);
f01075fd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107600:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107604:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010760b:	8b 45 08             	mov    0x8(%ebp),%eax
f010760e:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0107610:	8b 45 14             	mov    0x14(%ebp),%eax
f0107613:	8d 50 04             	lea    0x4(%eax),%edx
f0107616:	89 55 14             	mov    %edx,0x14(%ebp)
f0107619:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010761b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010761e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0107625:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
f010762c:	eb 1f                	jmp    f010764d <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010762e:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0107631:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107635:	8d 45 14             	lea    0x14(%ebp),%eax
f0107638:	89 04 24             	mov    %eax,(%esp)
f010763b:	e8 d9 fb ff ff       	call   f0107219 <getuint>
f0107640:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0107643:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
f0107646:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
f010764d:	0f be 55 db          	movsbl -0x25(%ebp),%edx
f0107651:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107654:	89 54 24 18          	mov    %edx,0x18(%esp)
f0107658:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010765b:	89 54 24 14          	mov    %edx,0x14(%esp)
f010765f:	89 44 24 10          	mov    %eax,0x10(%esp)
f0107663:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107666:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0107669:	89 44 24 08          	mov    %eax,0x8(%esp)
f010766d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0107671:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107674:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107678:	8b 45 08             	mov    0x8(%ebp),%eax
f010767b:	89 04 24             	mov    %eax,(%esp)
f010767e:	e8 b8 fa ff ff       	call   f010713b <printnum>
			break;
f0107683:	eb 3c                	jmp    f01076c1 <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0107685:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107688:	89 44 24 04          	mov    %eax,0x4(%esp)
f010768c:	89 1c 24             	mov    %ebx,(%esp)
f010768f:	8b 45 08             	mov    0x8(%ebp),%eax
f0107692:	ff d0                	call   *%eax
			break;
f0107694:	eb 2b                	jmp    f01076c1 <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0107696:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107699:	89 44 24 04          	mov    %eax,0x4(%esp)
f010769d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01076a4:	8b 45 08             	mov    0x8(%ebp),%eax
f01076a7:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
f01076a9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
f01076ad:	eb 04                	jmp    f01076b3 <vprintfmt+0x404>
f01076af:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
f01076b3:	8b 45 10             	mov    0x10(%ebp),%eax
f01076b6:	83 e8 01             	sub    $0x1,%eax
f01076b9:	0f b6 00             	movzbl (%eax),%eax
f01076bc:	3c 25                	cmp    $0x25,%al
f01076be:	75 ef                	jne    f01076af <vprintfmt+0x400>
				/* do nothing */;
			break;
f01076c0:	90                   	nop
		}
	}
f01076c1:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01076c2:	e9 0a fc ff ff       	jmp    f01072d1 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f01076c7:	83 c4 40             	add    $0x40,%esp
f01076ca:	5b                   	pop    %ebx
f01076cb:	5e                   	pop    %esi
f01076cc:	5d                   	pop    %ebp
f01076cd:	c3                   	ret    

f01076ce <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01076ce:	55                   	push   %ebp
f01076cf:	89 e5                	mov    %esp,%ebp
f01076d1:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
f01076d4:	8d 45 14             	lea    0x14(%ebp),%eax
f01076d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
f01076da:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01076dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01076e1:	8b 45 10             	mov    0x10(%ebp),%eax
f01076e4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01076e8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01076eb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01076ef:	8b 45 08             	mov    0x8(%ebp),%eax
f01076f2:	89 04 24             	mov    %eax,(%esp)
f01076f5:	e8 b5 fb ff ff       	call   f01072af <vprintfmt>
	va_end(ap);
}
f01076fa:	c9                   	leave  
f01076fb:	c3                   	ret    

f01076fc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01076fc:	55                   	push   %ebp
f01076fd:	89 e5                	mov    %esp,%ebp
	b->cnt++;
f01076ff:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107702:	8b 40 08             	mov    0x8(%eax),%eax
f0107705:	8d 50 01             	lea    0x1(%eax),%edx
f0107708:	8b 45 0c             	mov    0xc(%ebp),%eax
f010770b:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
f010770e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107711:	8b 10                	mov    (%eax),%edx
f0107713:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107716:	8b 40 04             	mov    0x4(%eax),%eax
f0107719:	39 c2                	cmp    %eax,%edx
f010771b:	73 12                	jae    f010772f <sprintputch+0x33>
		*b->buf++ = ch;
f010771d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107720:	8b 00                	mov    (%eax),%eax
f0107722:	8d 48 01             	lea    0x1(%eax),%ecx
f0107725:	8b 55 0c             	mov    0xc(%ebp),%edx
f0107728:	89 0a                	mov    %ecx,(%edx)
f010772a:	8b 55 08             	mov    0x8(%ebp),%edx
f010772d:	88 10                	mov    %dl,(%eax)
}
f010772f:	5d                   	pop    %ebp
f0107730:	c3                   	ret    

f0107731 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0107731:	55                   	push   %ebp
f0107732:	89 e5                	mov    %esp,%ebp
f0107734:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
f0107737:	8b 45 08             	mov    0x8(%ebp),%eax
f010773a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010773d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107740:	8d 50 ff             	lea    -0x1(%eax),%edx
f0107743:	8b 45 08             	mov    0x8(%ebp),%eax
f0107746:	01 d0                	add    %edx,%eax
f0107748:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010774b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0107752:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0107756:	74 06                	je     f010775e <vsnprintf+0x2d>
f0107758:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010775c:	7f 07                	jg     f0107765 <vsnprintf+0x34>
		return -E_INVAL;
f010775e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0107763:	eb 2a                	jmp    f010778f <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0107765:	8b 45 14             	mov    0x14(%ebp),%eax
f0107768:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010776c:	8b 45 10             	mov    0x10(%ebp),%eax
f010776f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107773:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0107776:	89 44 24 04          	mov    %eax,0x4(%esp)
f010777a:	c7 04 24 fc 76 10 f0 	movl   $0xf01076fc,(%esp)
f0107781:	e8 29 fb ff ff       	call   f01072af <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0107786:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107789:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010778c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f010778f:	c9                   	leave  
f0107790:	c3                   	ret    

f0107791 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0107791:	55                   	push   %ebp
f0107792:	89 e5                	mov    %esp,%ebp
f0107794:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0107797:	8d 45 14             	lea    0x14(%ebp),%eax
f010779a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
f010779d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01077a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01077a4:	8b 45 10             	mov    0x10(%ebp),%eax
f01077a7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01077ab:	8b 45 0c             	mov    0xc(%ebp),%eax
f01077ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01077b2:	8b 45 08             	mov    0x8(%ebp),%eax
f01077b5:	89 04 24             	mov    %eax,(%esp)
f01077b8:	e8 74 ff ff ff       	call   f0107731 <vsnprintf>
f01077bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
f01077c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f01077c3:	c9                   	leave  
f01077c4:	c3                   	ret    

f01077c5 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01077c5:	55                   	push   %ebp
f01077c6:	89 e5                	mov    %esp,%ebp
f01077c8:	83 ec 28             	sub    $0x28,%esp
	int i, c, echoing;

	if (prompt != NULL)
f01077cb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01077cf:	74 13                	je     f01077e4 <readline+0x1f>
		cprintf("%s", prompt);
f01077d1:	8b 45 08             	mov    0x8(%ebp),%eax
f01077d4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01077d8:	c7 04 24 a4 a5 10 f0 	movl   $0xf010a5a4,(%esp)
f01077df:	e8 db d7 ff ff       	call   f0104fbf <cprintf>

	i = 0;
f01077e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	echoing = iscons(0);
f01077eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01077f2:	e8 cc 93 ff ff       	call   f0100bc3 <iscons>
f01077f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while (1) {
		c = getchar();
f01077fa:	e8 ab 93 ff ff       	call   f0100baa <getchar>
f01077ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if (c < 0) {
f0107802:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0107806:	79 1d                	jns    f0107825 <readline+0x60>
			cprintf("read error: %e\n", c);
f0107808:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010780b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010780f:	c7 04 24 a7 a5 10 f0 	movl   $0xf010a5a7,(%esp)
f0107816:	e8 a4 d7 ff ff       	call   f0104fbf <cprintf>
			return NULL;
f010781b:	b8 00 00 00 00       	mov    $0x0,%eax
f0107820:	e9 93 00 00 00       	jmp    f01078b8 <readline+0xf3>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0107825:	83 7d ec 08          	cmpl   $0x8,-0x14(%ebp)
f0107829:	74 06                	je     f0107831 <readline+0x6c>
f010782b:	83 7d ec 7f          	cmpl   $0x7f,-0x14(%ebp)
f010782f:	75 1e                	jne    f010784f <readline+0x8a>
f0107831:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0107835:	7e 18                	jle    f010784f <readline+0x8a>
			if (echoing)
f0107837:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010783b:	74 0c                	je     f0107849 <readline+0x84>
				cputchar('\b');
f010783d:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0107844:	e8 4e 93 ff ff       	call   f0100b97 <cputchar>
			i--;
f0107849:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
f010784d:	eb 64                	jmp    f01078b3 <readline+0xee>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010784f:	83 7d ec 1f          	cmpl   $0x1f,-0x14(%ebp)
f0107853:	7e 2e                	jle    f0107883 <readline+0xbe>
f0107855:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
f010785c:	7f 25                	jg     f0107883 <readline+0xbe>
			if (echoing)
f010785e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0107862:	74 0b                	je     f010786f <readline+0xaa>
				cputchar(c);
f0107864:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107867:	89 04 24             	mov    %eax,(%esp)
f010786a:	e8 28 93 ff ff       	call   f0100b97 <cputchar>
			buf[i++] = c;
f010786f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107872:	8d 50 01             	lea    0x1(%eax),%edx
f0107875:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0107878:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010787b:	88 90 e0 ba 23 f0    	mov    %dl,-0xfdc4520(%eax)
f0107881:	eb 30                	jmp    f01078b3 <readline+0xee>
		} else if (c == '\n' || c == '\r') {
f0107883:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
f0107887:	74 06                	je     f010788f <readline+0xca>
f0107889:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
f010788d:	75 24                	jne    f01078b3 <readline+0xee>
			if (echoing)
f010788f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0107893:	74 0c                	je     f01078a1 <readline+0xdc>
				cputchar('\n');
f0107895:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f010789c:	e8 f6 92 ff ff       	call   f0100b97 <cputchar>
			buf[i] = 0;
f01078a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01078a4:	05 e0 ba 23 f0       	add    $0xf023bae0,%eax
f01078a9:	c6 00 00             	movb   $0x0,(%eax)
			return buf;
f01078ac:	b8 e0 ba 23 f0       	mov    $0xf023bae0,%eax
f01078b1:	eb 05                	jmp    f01078b8 <readline+0xf3>
		}
	}
f01078b3:	e9 42 ff ff ff       	jmp    f01077fa <readline+0x35>
}
f01078b8:	c9                   	leave  
f01078b9:	c3                   	ret    

f01078ba <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01078ba:	55                   	push   %ebp
f01078bb:	89 e5                	mov    %esp,%ebp
f01078bd:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
f01078c0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f01078c7:	eb 08                	jmp    f01078d1 <strlen+0x17>
		n++;
f01078c9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01078cd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f01078d1:	8b 45 08             	mov    0x8(%ebp),%eax
f01078d4:	0f b6 00             	movzbl (%eax),%eax
f01078d7:	84 c0                	test   %al,%al
f01078d9:	75 ee                	jne    f01078c9 <strlen+0xf>
		n++;
	return n;
f01078db:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f01078de:	c9                   	leave  
f01078df:	c3                   	ret    

f01078e0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01078e0:	55                   	push   %ebp
f01078e1:	89 e5                	mov    %esp,%ebp
f01078e3:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01078e6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f01078ed:	eb 0c                	jmp    f01078fb <strnlen+0x1b>
		n++;
f01078ef:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01078f3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f01078f7:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
f01078fb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01078ff:	74 0a                	je     f010790b <strnlen+0x2b>
f0107901:	8b 45 08             	mov    0x8(%ebp),%eax
f0107904:	0f b6 00             	movzbl (%eax),%eax
f0107907:	84 c0                	test   %al,%al
f0107909:	75 e4                	jne    f01078ef <strnlen+0xf>
		n++;
	return n;
f010790b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f010790e:	c9                   	leave  
f010790f:	c3                   	ret    

f0107910 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0107910:	55                   	push   %ebp
f0107911:	89 e5                	mov    %esp,%ebp
f0107913:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
f0107916:	8b 45 08             	mov    0x8(%ebp),%eax
f0107919:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
f010791c:	90                   	nop
f010791d:	8b 45 08             	mov    0x8(%ebp),%eax
f0107920:	8d 50 01             	lea    0x1(%eax),%edx
f0107923:	89 55 08             	mov    %edx,0x8(%ebp)
f0107926:	8b 55 0c             	mov    0xc(%ebp),%edx
f0107929:	8d 4a 01             	lea    0x1(%edx),%ecx
f010792c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
f010792f:	0f b6 12             	movzbl (%edx),%edx
f0107932:	88 10                	mov    %dl,(%eax)
f0107934:	0f b6 00             	movzbl (%eax),%eax
f0107937:	84 c0                	test   %al,%al
f0107939:	75 e2                	jne    f010791d <strcpy+0xd>
		/* do nothing */;
	return ret;
f010793b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f010793e:	c9                   	leave  
f010793f:	c3                   	ret    

f0107940 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0107940:	55                   	push   %ebp
f0107941:	89 e5                	mov    %esp,%ebp
f0107943:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
f0107946:	8b 45 08             	mov    0x8(%ebp),%eax
f0107949:	89 04 24             	mov    %eax,(%esp)
f010794c:	e8 69 ff ff ff       	call   f01078ba <strlen>
f0107951:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
f0107954:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0107957:	8b 45 08             	mov    0x8(%ebp),%eax
f010795a:	01 c2                	add    %eax,%edx
f010795c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010795f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107963:	89 14 24             	mov    %edx,(%esp)
f0107966:	e8 a5 ff ff ff       	call   f0107910 <strcpy>
	return dst;
f010796b:	8b 45 08             	mov    0x8(%ebp),%eax
}
f010796e:	c9                   	leave  
f010796f:	c3                   	ret    

f0107970 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0107970:	55                   	push   %ebp
f0107971:	89 e5                	mov    %esp,%ebp
f0107973:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
f0107976:	8b 45 08             	mov    0x8(%ebp),%eax
f0107979:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
f010797c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f0107983:	eb 23                	jmp    f01079a8 <strncpy+0x38>
		*dst++ = *src;
f0107985:	8b 45 08             	mov    0x8(%ebp),%eax
f0107988:	8d 50 01             	lea    0x1(%eax),%edx
f010798b:	89 55 08             	mov    %edx,0x8(%ebp)
f010798e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0107991:	0f b6 12             	movzbl (%edx),%edx
f0107994:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f0107996:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107999:	0f b6 00             	movzbl (%eax),%eax
f010799c:	84 c0                	test   %al,%al
f010799e:	74 04                	je     f01079a4 <strncpy+0x34>
			src++;
f01079a0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01079a4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
f01079a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01079ab:	3b 45 10             	cmp    0x10(%ebp),%eax
f01079ae:	72 d5                	jb     f0107985 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
f01079b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
f01079b3:	c9                   	leave  
f01079b4:	c3                   	ret    

f01079b5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01079b5:	55                   	push   %ebp
f01079b6:	89 e5                	mov    %esp,%ebp
f01079b8:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
f01079bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01079be:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
f01079c1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01079c5:	74 33                	je     f01079fa <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f01079c7:	eb 17                	jmp    f01079e0 <strlcpy+0x2b>
			*dst++ = *src++;
f01079c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01079cc:	8d 50 01             	lea    0x1(%eax),%edx
f01079cf:	89 55 08             	mov    %edx,0x8(%ebp)
f01079d2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01079d5:	8d 4a 01             	lea    0x1(%edx),%ecx
f01079d8:	89 4d 0c             	mov    %ecx,0xc(%ebp)
f01079db:	0f b6 12             	movzbl (%edx),%edx
f01079de:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01079e0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
f01079e4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01079e8:	74 0a                	je     f01079f4 <strlcpy+0x3f>
f01079ea:	8b 45 0c             	mov    0xc(%ebp),%eax
f01079ed:	0f b6 00             	movzbl (%eax),%eax
f01079f0:	84 c0                	test   %al,%al
f01079f2:	75 d5                	jne    f01079c9 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
f01079f4:	8b 45 08             	mov    0x8(%ebp),%eax
f01079f7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01079fa:	8b 55 08             	mov    0x8(%ebp),%edx
f01079fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0107a00:	29 c2                	sub    %eax,%edx
f0107a02:	89 d0                	mov    %edx,%eax
}
f0107a04:	c9                   	leave  
f0107a05:	c3                   	ret    

f0107a06 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0107a06:	55                   	push   %ebp
f0107a07:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
f0107a09:	eb 08                	jmp    f0107a13 <strcmp+0xd>
		p++, q++;
f0107a0b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0107a0f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0107a13:	8b 45 08             	mov    0x8(%ebp),%eax
f0107a16:	0f b6 00             	movzbl (%eax),%eax
f0107a19:	84 c0                	test   %al,%al
f0107a1b:	74 10                	je     f0107a2d <strcmp+0x27>
f0107a1d:	8b 45 08             	mov    0x8(%ebp),%eax
f0107a20:	0f b6 10             	movzbl (%eax),%edx
f0107a23:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107a26:	0f b6 00             	movzbl (%eax),%eax
f0107a29:	38 c2                	cmp    %al,%dl
f0107a2b:	74 de                	je     f0107a0b <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0107a2d:	8b 45 08             	mov    0x8(%ebp),%eax
f0107a30:	0f b6 00             	movzbl (%eax),%eax
f0107a33:	0f b6 d0             	movzbl %al,%edx
f0107a36:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107a39:	0f b6 00             	movzbl (%eax),%eax
f0107a3c:	0f b6 c0             	movzbl %al,%eax
f0107a3f:	29 c2                	sub    %eax,%edx
f0107a41:	89 d0                	mov    %edx,%eax
}
f0107a43:	5d                   	pop    %ebp
f0107a44:	c3                   	ret    

f0107a45 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0107a45:	55                   	push   %ebp
f0107a46:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
f0107a48:	eb 0c                	jmp    f0107a56 <strncmp+0x11>
		n--, p++, q++;
f0107a4a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
f0107a4e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0107a52:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0107a56:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0107a5a:	74 1a                	je     f0107a76 <strncmp+0x31>
f0107a5c:	8b 45 08             	mov    0x8(%ebp),%eax
f0107a5f:	0f b6 00             	movzbl (%eax),%eax
f0107a62:	84 c0                	test   %al,%al
f0107a64:	74 10                	je     f0107a76 <strncmp+0x31>
f0107a66:	8b 45 08             	mov    0x8(%ebp),%eax
f0107a69:	0f b6 10             	movzbl (%eax),%edx
f0107a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107a6f:	0f b6 00             	movzbl (%eax),%eax
f0107a72:	38 c2                	cmp    %al,%dl
f0107a74:	74 d4                	je     f0107a4a <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
f0107a76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0107a7a:	75 07                	jne    f0107a83 <strncmp+0x3e>
		return 0;
f0107a7c:	b8 00 00 00 00       	mov    $0x0,%eax
f0107a81:	eb 16                	jmp    f0107a99 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0107a83:	8b 45 08             	mov    0x8(%ebp),%eax
f0107a86:	0f b6 00             	movzbl (%eax),%eax
f0107a89:	0f b6 d0             	movzbl %al,%edx
f0107a8c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107a8f:	0f b6 00             	movzbl (%eax),%eax
f0107a92:	0f b6 c0             	movzbl %al,%eax
f0107a95:	29 c2                	sub    %eax,%edx
f0107a97:	89 d0                	mov    %edx,%eax
}
f0107a99:	5d                   	pop    %ebp
f0107a9a:	c3                   	ret    

f0107a9b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0107a9b:	55                   	push   %ebp
f0107a9c:	89 e5                	mov    %esp,%ebp
f0107a9e:	83 ec 04             	sub    $0x4,%esp
f0107aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107aa4:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
f0107aa7:	eb 14                	jmp    f0107abd <strchr+0x22>
		if (*s == c)
f0107aa9:	8b 45 08             	mov    0x8(%ebp),%eax
f0107aac:	0f b6 00             	movzbl (%eax),%eax
f0107aaf:	3a 45 fc             	cmp    -0x4(%ebp),%al
f0107ab2:	75 05                	jne    f0107ab9 <strchr+0x1e>
			return (char *) s;
f0107ab4:	8b 45 08             	mov    0x8(%ebp),%eax
f0107ab7:	eb 13                	jmp    f0107acc <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0107ab9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0107abd:	8b 45 08             	mov    0x8(%ebp),%eax
f0107ac0:	0f b6 00             	movzbl (%eax),%eax
f0107ac3:	84 c0                	test   %al,%al
f0107ac5:	75 e2                	jne    f0107aa9 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
f0107ac7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0107acc:	c9                   	leave  
f0107acd:	c3                   	ret    

f0107ace <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0107ace:	55                   	push   %ebp
f0107acf:	89 e5                	mov    %esp,%ebp
f0107ad1:	83 ec 04             	sub    $0x4,%esp
f0107ad4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107ad7:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
f0107ada:	eb 11                	jmp    f0107aed <strfind+0x1f>
		if (*s == c)
f0107adc:	8b 45 08             	mov    0x8(%ebp),%eax
f0107adf:	0f b6 00             	movzbl (%eax),%eax
f0107ae2:	3a 45 fc             	cmp    -0x4(%ebp),%al
f0107ae5:	75 02                	jne    f0107ae9 <strfind+0x1b>
			break;
f0107ae7:	eb 0e                	jmp    f0107af7 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0107ae9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0107aed:	8b 45 08             	mov    0x8(%ebp),%eax
f0107af0:	0f b6 00             	movzbl (%eax),%eax
f0107af3:	84 c0                	test   %al,%al
f0107af5:	75 e5                	jne    f0107adc <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
f0107af7:	8b 45 08             	mov    0x8(%ebp),%eax
}
f0107afa:	c9                   	leave  
f0107afb:	c3                   	ret    

f0107afc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0107afc:	55                   	push   %ebp
f0107afd:	89 e5                	mov    %esp,%ebp
f0107aff:	57                   	push   %edi
	char *p;

	if (n == 0)
f0107b00:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0107b04:	75 05                	jne    f0107b0b <memset+0xf>
		return v;
f0107b06:	8b 45 08             	mov    0x8(%ebp),%eax
f0107b09:	eb 5c                	jmp    f0107b67 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
f0107b0b:	8b 45 08             	mov    0x8(%ebp),%eax
f0107b0e:	83 e0 03             	and    $0x3,%eax
f0107b11:	85 c0                	test   %eax,%eax
f0107b13:	75 41                	jne    f0107b56 <memset+0x5a>
f0107b15:	8b 45 10             	mov    0x10(%ebp),%eax
f0107b18:	83 e0 03             	and    $0x3,%eax
f0107b1b:	85 c0                	test   %eax,%eax
f0107b1d:	75 37                	jne    f0107b56 <memset+0x5a>
		c &= 0xFF;
f0107b1f:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0107b26:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107b29:	c1 e0 18             	shl    $0x18,%eax
f0107b2c:	89 c2                	mov    %eax,%edx
f0107b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107b31:	c1 e0 10             	shl    $0x10,%eax
f0107b34:	09 c2                	or     %eax,%edx
f0107b36:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107b39:	c1 e0 08             	shl    $0x8,%eax
f0107b3c:	09 d0                	or     %edx,%eax
f0107b3e:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0107b41:	8b 45 10             	mov    0x10(%ebp),%eax
f0107b44:	c1 e8 02             	shr    $0x2,%eax
f0107b47:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0107b49:	8b 55 08             	mov    0x8(%ebp),%edx
f0107b4c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107b4f:	89 d7                	mov    %edx,%edi
f0107b51:	fc                   	cld    
f0107b52:	f3 ab                	rep stos %eax,%es:(%edi)
f0107b54:	eb 0e                	jmp    f0107b64 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0107b56:	8b 55 08             	mov    0x8(%ebp),%edx
f0107b59:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107b5c:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0107b5f:	89 d7                	mov    %edx,%edi
f0107b61:	fc                   	cld    
f0107b62:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
f0107b64:	8b 45 08             	mov    0x8(%ebp),%eax
}
f0107b67:	5f                   	pop    %edi
f0107b68:	5d                   	pop    %ebp
f0107b69:	c3                   	ret    

f0107b6a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0107b6a:	55                   	push   %ebp
f0107b6b:	89 e5                	mov    %esp,%ebp
f0107b6d:	57                   	push   %edi
f0107b6e:	56                   	push   %esi
f0107b6f:	53                   	push   %ebx
f0107b70:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
f0107b73:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107b76:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
f0107b79:	8b 45 08             	mov    0x8(%ebp),%eax
f0107b7c:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
f0107b7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107b82:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f0107b85:	73 6d                	jae    f0107bf4 <memmove+0x8a>
f0107b87:	8b 45 10             	mov    0x10(%ebp),%eax
f0107b8a:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107b8d:	01 d0                	add    %edx,%eax
f0107b8f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f0107b92:	76 60                	jbe    f0107bf4 <memmove+0x8a>
		s += n;
f0107b94:	8b 45 10             	mov    0x10(%ebp),%eax
f0107b97:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
f0107b9a:	8b 45 10             	mov    0x10(%ebp),%eax
f0107b9d:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0107ba0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107ba3:	83 e0 03             	and    $0x3,%eax
f0107ba6:	85 c0                	test   %eax,%eax
f0107ba8:	75 2f                	jne    f0107bd9 <memmove+0x6f>
f0107baa:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107bad:	83 e0 03             	and    $0x3,%eax
f0107bb0:	85 c0                	test   %eax,%eax
f0107bb2:	75 25                	jne    f0107bd9 <memmove+0x6f>
f0107bb4:	8b 45 10             	mov    0x10(%ebp),%eax
f0107bb7:	83 e0 03             	and    $0x3,%eax
f0107bba:	85 c0                	test   %eax,%eax
f0107bbc:	75 1b                	jne    f0107bd9 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0107bbe:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107bc1:	83 e8 04             	sub    $0x4,%eax
f0107bc4:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107bc7:	83 ea 04             	sub    $0x4,%edx
f0107bca:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0107bcd:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0107bd0:	89 c7                	mov    %eax,%edi
f0107bd2:	89 d6                	mov    %edx,%esi
f0107bd4:	fd                   	std    
f0107bd5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0107bd7:	eb 18                	jmp    f0107bf1 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0107bd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107bdc:	8d 50 ff             	lea    -0x1(%eax),%edx
f0107bdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107be2:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0107be5:	8b 45 10             	mov    0x10(%ebp),%eax
f0107be8:	89 d7                	mov    %edx,%edi
f0107bea:	89 de                	mov    %ebx,%esi
f0107bec:	89 c1                	mov    %eax,%ecx
f0107bee:	fd                   	std    
f0107bef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0107bf1:	fc                   	cld    
f0107bf2:	eb 45                	jmp    f0107c39 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0107bf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107bf7:	83 e0 03             	and    $0x3,%eax
f0107bfa:	85 c0                	test   %eax,%eax
f0107bfc:	75 2b                	jne    f0107c29 <memmove+0xbf>
f0107bfe:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107c01:	83 e0 03             	and    $0x3,%eax
f0107c04:	85 c0                	test   %eax,%eax
f0107c06:	75 21                	jne    f0107c29 <memmove+0xbf>
f0107c08:	8b 45 10             	mov    0x10(%ebp),%eax
f0107c0b:	83 e0 03             	and    $0x3,%eax
f0107c0e:	85 c0                	test   %eax,%eax
f0107c10:	75 17                	jne    f0107c29 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0107c12:	8b 45 10             	mov    0x10(%ebp),%eax
f0107c15:	c1 e8 02             	shr    $0x2,%eax
f0107c18:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0107c1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107c1d:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107c20:	89 c7                	mov    %eax,%edi
f0107c22:	89 d6                	mov    %edx,%esi
f0107c24:	fc                   	cld    
f0107c25:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0107c27:	eb 10                	jmp    f0107c39 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0107c29:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107c2c:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107c2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0107c32:	89 c7                	mov    %eax,%edi
f0107c34:	89 d6                	mov    %edx,%esi
f0107c36:	fc                   	cld    
f0107c37:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
f0107c39:	8b 45 08             	mov    0x8(%ebp),%eax
}
f0107c3c:	83 c4 10             	add    $0x10,%esp
f0107c3f:	5b                   	pop    %ebx
f0107c40:	5e                   	pop    %esi
f0107c41:	5f                   	pop    %edi
f0107c42:	5d                   	pop    %ebp
f0107c43:	c3                   	ret    

f0107c44 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0107c44:	55                   	push   %ebp
f0107c45:	89 e5                	mov    %esp,%ebp
f0107c47:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0107c4a:	8b 45 10             	mov    0x10(%ebp),%eax
f0107c4d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107c51:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107c54:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107c58:	8b 45 08             	mov    0x8(%ebp),%eax
f0107c5b:	89 04 24             	mov    %eax,(%esp)
f0107c5e:	e8 07 ff ff ff       	call   f0107b6a <memmove>
}
f0107c63:	c9                   	leave  
f0107c64:	c3                   	ret    

f0107c65 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0107c65:	55                   	push   %ebp
f0107c66:	89 e5                	mov    %esp,%ebp
f0107c68:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
f0107c6b:	8b 45 08             	mov    0x8(%ebp),%eax
f0107c6e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
f0107c71:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107c74:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
f0107c77:	eb 30                	jmp    f0107ca9 <memcmp+0x44>
		if (*s1 != *s2)
f0107c79:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0107c7c:	0f b6 10             	movzbl (%eax),%edx
f0107c7f:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0107c82:	0f b6 00             	movzbl (%eax),%eax
f0107c85:	38 c2                	cmp    %al,%dl
f0107c87:	74 18                	je     f0107ca1 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
f0107c89:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0107c8c:	0f b6 00             	movzbl (%eax),%eax
f0107c8f:	0f b6 d0             	movzbl %al,%edx
f0107c92:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0107c95:	0f b6 00             	movzbl (%eax),%eax
f0107c98:	0f b6 c0             	movzbl %al,%eax
f0107c9b:	29 c2                	sub    %eax,%edx
f0107c9d:	89 d0                	mov    %edx,%eax
f0107c9f:	eb 1a                	jmp    f0107cbb <memcmp+0x56>
		s1++, s2++;
f0107ca1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
f0107ca5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0107ca9:	8b 45 10             	mov    0x10(%ebp),%eax
f0107cac:	8d 50 ff             	lea    -0x1(%eax),%edx
f0107caf:	89 55 10             	mov    %edx,0x10(%ebp)
f0107cb2:	85 c0                	test   %eax,%eax
f0107cb4:	75 c3                	jne    f0107c79 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0107cb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0107cbb:	c9                   	leave  
f0107cbc:	c3                   	ret    

f0107cbd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0107cbd:	55                   	push   %ebp
f0107cbe:	89 e5                	mov    %esp,%ebp
f0107cc0:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
f0107cc3:	8b 45 10             	mov    0x10(%ebp),%eax
f0107cc6:	8b 55 08             	mov    0x8(%ebp),%edx
f0107cc9:	01 d0                	add    %edx,%eax
f0107ccb:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
f0107cce:	eb 13                	jmp    f0107ce3 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
f0107cd0:	8b 45 08             	mov    0x8(%ebp),%eax
f0107cd3:	0f b6 10             	movzbl (%eax),%edx
f0107cd6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107cd9:	38 c2                	cmp    %al,%dl
f0107cdb:	75 02                	jne    f0107cdf <memfind+0x22>
			break;
f0107cdd:	eb 0c                	jmp    f0107ceb <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0107cdf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0107ce3:	8b 45 08             	mov    0x8(%ebp),%eax
f0107ce6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f0107ce9:	72 e5                	jb     f0107cd0 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
f0107ceb:	8b 45 08             	mov    0x8(%ebp),%eax
}
f0107cee:	c9                   	leave  
f0107cef:	c3                   	ret    

f0107cf0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0107cf0:	55                   	push   %ebp
f0107cf1:	89 e5                	mov    %esp,%ebp
f0107cf3:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
f0107cf6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
f0107cfd:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0107d04:	eb 04                	jmp    f0107d0a <strtol+0x1a>
		s++;
f0107d06:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0107d0a:	8b 45 08             	mov    0x8(%ebp),%eax
f0107d0d:	0f b6 00             	movzbl (%eax),%eax
f0107d10:	3c 20                	cmp    $0x20,%al
f0107d12:	74 f2                	je     f0107d06 <strtol+0x16>
f0107d14:	8b 45 08             	mov    0x8(%ebp),%eax
f0107d17:	0f b6 00             	movzbl (%eax),%eax
f0107d1a:	3c 09                	cmp    $0x9,%al
f0107d1c:	74 e8                	je     f0107d06 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
f0107d1e:	8b 45 08             	mov    0x8(%ebp),%eax
f0107d21:	0f b6 00             	movzbl (%eax),%eax
f0107d24:	3c 2b                	cmp    $0x2b,%al
f0107d26:	75 06                	jne    f0107d2e <strtol+0x3e>
		s++;
f0107d28:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0107d2c:	eb 15                	jmp    f0107d43 <strtol+0x53>
	else if (*s == '-')
f0107d2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0107d31:	0f b6 00             	movzbl (%eax),%eax
f0107d34:	3c 2d                	cmp    $0x2d,%al
f0107d36:	75 0b                	jne    f0107d43 <strtol+0x53>
		s++, neg = 1;
f0107d38:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0107d3c:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0107d43:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0107d47:	74 06                	je     f0107d4f <strtol+0x5f>
f0107d49:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
f0107d4d:	75 24                	jne    f0107d73 <strtol+0x83>
f0107d4f:	8b 45 08             	mov    0x8(%ebp),%eax
f0107d52:	0f b6 00             	movzbl (%eax),%eax
f0107d55:	3c 30                	cmp    $0x30,%al
f0107d57:	75 1a                	jne    f0107d73 <strtol+0x83>
f0107d59:	8b 45 08             	mov    0x8(%ebp),%eax
f0107d5c:	83 c0 01             	add    $0x1,%eax
f0107d5f:	0f b6 00             	movzbl (%eax),%eax
f0107d62:	3c 78                	cmp    $0x78,%al
f0107d64:	75 0d                	jne    f0107d73 <strtol+0x83>
		s += 2, base = 16;
f0107d66:	83 45 08 02          	addl   $0x2,0x8(%ebp)
f0107d6a:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f0107d71:	eb 2a                	jmp    f0107d9d <strtol+0xad>
	else if (base == 0 && s[0] == '0')
f0107d73:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0107d77:	75 17                	jne    f0107d90 <strtol+0xa0>
f0107d79:	8b 45 08             	mov    0x8(%ebp),%eax
f0107d7c:	0f b6 00             	movzbl (%eax),%eax
f0107d7f:	3c 30                	cmp    $0x30,%al
f0107d81:	75 0d                	jne    f0107d90 <strtol+0xa0>
		s++, base = 8;
f0107d83:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0107d87:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f0107d8e:	eb 0d                	jmp    f0107d9d <strtol+0xad>
	else if (base == 0)
f0107d90:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0107d94:	75 07                	jne    f0107d9d <strtol+0xad>
		base = 10;
f0107d96:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0107d9d:	8b 45 08             	mov    0x8(%ebp),%eax
f0107da0:	0f b6 00             	movzbl (%eax),%eax
f0107da3:	3c 2f                	cmp    $0x2f,%al
f0107da5:	7e 1b                	jle    f0107dc2 <strtol+0xd2>
f0107da7:	8b 45 08             	mov    0x8(%ebp),%eax
f0107daa:	0f b6 00             	movzbl (%eax),%eax
f0107dad:	3c 39                	cmp    $0x39,%al
f0107daf:	7f 11                	jg     f0107dc2 <strtol+0xd2>
			dig = *s - '0';
f0107db1:	8b 45 08             	mov    0x8(%ebp),%eax
f0107db4:	0f b6 00             	movzbl (%eax),%eax
f0107db7:	0f be c0             	movsbl %al,%eax
f0107dba:	83 e8 30             	sub    $0x30,%eax
f0107dbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0107dc0:	eb 48                	jmp    f0107e0a <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
f0107dc2:	8b 45 08             	mov    0x8(%ebp),%eax
f0107dc5:	0f b6 00             	movzbl (%eax),%eax
f0107dc8:	3c 60                	cmp    $0x60,%al
f0107dca:	7e 1b                	jle    f0107de7 <strtol+0xf7>
f0107dcc:	8b 45 08             	mov    0x8(%ebp),%eax
f0107dcf:	0f b6 00             	movzbl (%eax),%eax
f0107dd2:	3c 7a                	cmp    $0x7a,%al
f0107dd4:	7f 11                	jg     f0107de7 <strtol+0xf7>
			dig = *s - 'a' + 10;
f0107dd6:	8b 45 08             	mov    0x8(%ebp),%eax
f0107dd9:	0f b6 00             	movzbl (%eax),%eax
f0107ddc:	0f be c0             	movsbl %al,%eax
f0107ddf:	83 e8 57             	sub    $0x57,%eax
f0107de2:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0107de5:	eb 23                	jmp    f0107e0a <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
f0107de7:	8b 45 08             	mov    0x8(%ebp),%eax
f0107dea:	0f b6 00             	movzbl (%eax),%eax
f0107ded:	3c 40                	cmp    $0x40,%al
f0107def:	7e 3d                	jle    f0107e2e <strtol+0x13e>
f0107df1:	8b 45 08             	mov    0x8(%ebp),%eax
f0107df4:	0f b6 00             	movzbl (%eax),%eax
f0107df7:	3c 5a                	cmp    $0x5a,%al
f0107df9:	7f 33                	jg     f0107e2e <strtol+0x13e>
			dig = *s - 'A' + 10;
f0107dfb:	8b 45 08             	mov    0x8(%ebp),%eax
f0107dfe:	0f b6 00             	movzbl (%eax),%eax
f0107e01:	0f be c0             	movsbl %al,%eax
f0107e04:	83 e8 37             	sub    $0x37,%eax
f0107e07:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
f0107e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107e0d:	3b 45 10             	cmp    0x10(%ebp),%eax
f0107e10:	7c 02                	jl     f0107e14 <strtol+0x124>
			break;
f0107e12:	eb 1a                	jmp    f0107e2e <strtol+0x13e>
		s++, val = (val * base) + dig;
f0107e14:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0107e18:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0107e1b:	0f af 45 10          	imul   0x10(%ebp),%eax
f0107e1f:	89 c2                	mov    %eax,%edx
f0107e21:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107e24:	01 d0                	add    %edx,%eax
f0107e26:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
f0107e29:	e9 6f ff ff ff       	jmp    f0107d9d <strtol+0xad>

	if (endptr)
f0107e2e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0107e32:	74 08                	je     f0107e3c <strtol+0x14c>
		*endptr = (char *) s;
f0107e34:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107e37:	8b 55 08             	mov    0x8(%ebp),%edx
f0107e3a:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f0107e3c:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
f0107e40:	74 07                	je     f0107e49 <strtol+0x159>
f0107e42:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0107e45:	f7 d8                	neg    %eax
f0107e47:	eb 03                	jmp    f0107e4c <strtol+0x15c>
f0107e49:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
f0107e4c:	c9                   	leave  
f0107e4d:	c3                   	ret    
f0107e4e:	66 90                	xchg   %ax,%ax

f0107e50 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0107e50:	fa                   	cli    

	xorw    %ax, %ax
f0107e51:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0107e53:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0107e55:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0107e57:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0107e59:	0f 01 16             	lgdtl  (%esi)
f0107e5c:	74 70                	je     f0107ece <_kaddr+0x3>
	movl    %cr0, %eax
f0107e5e:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0107e61:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0107e65:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0107e68:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0107e6e:	08 00                	or     %al,(%eax)

f0107e70 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0107e70:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0107e74:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0107e76:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0107e78:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0107e7a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0107e7e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0107e80:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0107e82:	b8 00 40 12 00       	mov    $0x124000,%eax
	movl    %eax, %cr3
f0107e87:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0107e8a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0107e8d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0107e92:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0107e95:	8b 25 e4 be 23 f0    	mov    0xf023bee4,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0107e9b:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0107ea0:	b8 7d 02 10 f0       	mov    $0xf010027d,%eax
	call    *%eax
f0107ea5:	ff d0                	call   *%eax

f0107ea7 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0107ea7:	eb fe                	jmp    f0107ea7 <spin>
f0107ea9:	8d 76 00             	lea    0x0(%esi),%esi

f0107eac <gdt>:
	...
f0107eb4:	ff                   	(bad)  
f0107eb5:	ff 00                	incl   (%eax)
f0107eb7:	00 00                	add    %al,(%eax)
f0107eb9:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0107ec0:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0107ec4 <gdtdesc>:
f0107ec4:	17                   	pop    %ss
f0107ec5:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0107eca <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0107eca:	90                   	nop

f0107ecb <_kaddr>:
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f0107ecb:	55                   	push   %ebp
f0107ecc:	89 e5                	mov    %esp,%ebp
f0107ece:	83 ec 18             	sub    $0x18,%esp
	if (PGNUM(pa) >= npages)
f0107ed1:	8b 45 10             	mov    0x10(%ebp),%eax
f0107ed4:	c1 e8 0c             	shr    $0xc,%eax
f0107ed7:	89 c2                	mov    %eax,%edx
f0107ed9:	a1 e8 be 23 f0       	mov    0xf023bee8,%eax
f0107ede:	39 c2                	cmp    %eax,%edx
f0107ee0:	72 21                	jb     f0107f03 <_kaddr+0x38>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0107ee2:	8b 45 10             	mov    0x10(%ebp),%eax
f0107ee5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107ee9:	c7 44 24 08 b8 a5 10 	movl   $0xf010a5b8,0x8(%esp)
f0107ef0:	f0 
f0107ef1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107ef4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107ef8:	8b 45 08             	mov    0x8(%ebp),%eax
f0107efb:	89 04 24             	mov    %eax,(%esp)
f0107efe:	e8 f4 83 ff ff       	call   f01002f7 <_panic>
	return (void *)(pa + KERNBASE);
f0107f03:	8b 45 10             	mov    0x10(%ebp),%eax
f0107f06:	2d 00 00 00 10       	sub    $0x10000000,%eax
}
f0107f0b:	c9                   	leave  
f0107f0c:	c3                   	ret    

f0107f0d <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0107f0d:	55                   	push   %ebp
f0107f0e:	89 e5                	mov    %esp,%ebp
f0107f10:	83 ec 10             	sub    $0x10,%esp
	int i, sum;

	sum = 0;
f0107f13:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	for (i = 0; i < len; i++)
f0107f1a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f0107f21:	eb 15                	jmp    f0107f38 <sum+0x2b>
		sum += ((uint8_t *)addr)[i];
f0107f23:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0107f26:	8b 45 08             	mov    0x8(%ebp),%eax
f0107f29:	01 d0                	add    %edx,%eax
f0107f2b:	0f b6 00             	movzbl (%eax),%eax
f0107f2e:	0f b6 c0             	movzbl %al,%eax
f0107f31:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0107f34:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
f0107f38:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0107f3b:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0107f3e:	7c e3                	jl     f0107f23 <sum+0x16>
		sum += ((uint8_t *)addr)[i];
	return sum;
f0107f40:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
f0107f43:	c9                   	leave  
f0107f44:	c3                   	ret    

f0107f45 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0107f45:	55                   	push   %ebp
f0107f46:	89 e5                	mov    %esp,%ebp
f0107f48:	83 ec 28             	sub    $0x28,%esp
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0107f4b:	8b 45 08             	mov    0x8(%ebp),%eax
f0107f4e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107f52:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0107f59:	00 
f0107f5a:	c7 04 24 db a5 10 f0 	movl   $0xf010a5db,(%esp)
f0107f61:	e8 65 ff ff ff       	call   f0107ecb <_kaddr>
f0107f66:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0107f69:	8b 55 0c             	mov    0xc(%ebp),%edx
f0107f6c:	8b 45 08             	mov    0x8(%ebp),%eax
f0107f6f:	01 d0                	add    %edx,%eax
f0107f71:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107f75:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0107f7c:	00 
f0107f7d:	c7 04 24 db a5 10 f0 	movl   $0xf010a5db,(%esp)
f0107f84:	e8 42 ff ff ff       	call   f0107ecb <_kaddr>
f0107f89:	89 45 f0             	mov    %eax,-0x10(%ebp)

	for (; mp < end; mp++)
f0107f8c:	eb 3f                	jmp    f0107fcd <mpsearch1+0x88>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0107f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107f91:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0107f98:	00 
f0107f99:	c7 44 24 04 eb a5 10 	movl   $0xf010a5eb,0x4(%esp)
f0107fa0:	f0 
f0107fa1:	89 04 24             	mov    %eax,(%esp)
f0107fa4:	e8 bc fc ff ff       	call   f0107c65 <memcmp>
f0107fa9:	85 c0                	test   %eax,%eax
f0107fab:	75 1c                	jne    f0107fc9 <mpsearch1+0x84>
		    sum(mp, sizeof(*mp)) == 0)
f0107fad:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0107fb4:	00 
f0107fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107fb8:	89 04 24             	mov    %eax,(%esp)
f0107fbb:	e8 4d ff ff ff       	call   f0107f0d <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0107fc0:	84 c0                	test   %al,%al
f0107fc2:	75 05                	jne    f0107fc9 <mpsearch1+0x84>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
f0107fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107fc7:	eb 11                	jmp    f0107fda <mpsearch1+0x95>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0107fc9:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
f0107fcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107fd0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f0107fd3:	72 b9                	jb     f0107f8e <mpsearch1+0x49>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0107fd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0107fda:	c9                   	leave  
f0107fdb:	c3                   	ret    

f0107fdc <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) if there is no EBDA, in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp *
mpsearch(void)
{
f0107fdc:	55                   	push   %ebp
f0107fdd:	89 e5                	mov    %esp,%ebp
f0107fdf:	83 ec 28             	sub    $0x28,%esp
	struct mp *mp;

	static_assert(sizeof(*mp) == 16);

	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);
f0107fe2:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
f0107fe9:	00 
f0107fea:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0107ff1:	00 
f0107ff2:	c7 04 24 db a5 10 f0 	movl   $0xf010a5db,(%esp)
f0107ff9:	e8 cd fe ff ff       	call   f0107ecb <_kaddr>
f0107ffe:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0108001:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108004:	83 c0 0e             	add    $0xe,%eax
f0108007:	0f b7 00             	movzwl (%eax),%eax
f010800a:	0f b7 c0             	movzwl %ax,%eax
f010800d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0108010:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0108014:	74 25                	je     f010803b <mpsearch+0x5f>
		p <<= 4;	// Translate from segment to PA
f0108016:	c1 65 f0 04          	shll   $0x4,-0x10(%ebp)
		if ((mp = mpsearch1(p, 1024)))
f010801a:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0108021:	00 
f0108022:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108025:	89 04 24             	mov    %eax,(%esp)
f0108028:	e8 18 ff ff ff       	call   f0107f45 <mpsearch1>
f010802d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0108030:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0108034:	74 3d                	je     f0108073 <mpsearch+0x97>
			return mp;
f0108036:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108039:	eb 4c                	jmp    f0108087 <mpsearch+0xab>
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f010803b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010803e:	83 c0 13             	add    $0x13,%eax
f0108041:	0f b7 00             	movzwl (%eax),%eax
f0108044:	0f b7 c0             	movzwl %ax,%eax
f0108047:	c1 e0 0a             	shl    $0xa,%eax
f010804a:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if ((mp = mpsearch1(p - 1024, 1024)))
f010804d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108050:	2d 00 04 00 00       	sub    $0x400,%eax
f0108055:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f010805c:	00 
f010805d:	89 04 24             	mov    %eax,(%esp)
f0108060:	e8 e0 fe ff ff       	call   f0107f45 <mpsearch1>
f0108065:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0108068:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f010806c:	74 05                	je     f0108073 <mpsearch+0x97>
			return mp;
f010806e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108071:	eb 14                	jmp    f0108087 <mpsearch+0xab>
	}
	return mpsearch1(0xF0000, 0x10000);
f0108073:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
f010807a:	00 
f010807b:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
f0108082:	e8 be fe ff ff       	call   f0107f45 <mpsearch1>
}
f0108087:	c9                   	leave  
f0108088:	c3                   	ret    

f0108089 <mpconfig>:
// Search for an MP configuration table.  For now, don't accept the
// default configurations (physaddr == 0).
// Check for the correct signature, checksum, and version.
static struct mpconf *
mpconfig(struct mp **pmp)
{
f0108089:	55                   	push   %ebp
f010808a:	89 e5                	mov    %esp,%ebp
f010808c:	83 ec 28             	sub    $0x28,%esp
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f010808f:	e8 48 ff ff ff       	call   f0107fdc <mpsearch>
f0108094:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0108097:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010809b:	75 0a                	jne    f01080a7 <mpconfig+0x1e>
		return NULL;
f010809d:	b8 00 00 00 00       	mov    $0x0,%eax
f01080a2:	e9 44 01 00 00       	jmp    f01081eb <mpconfig+0x162>
	if (mp->physaddr == 0 || mp->type != 0) {
f01080a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01080aa:	8b 40 04             	mov    0x4(%eax),%eax
f01080ad:	85 c0                	test   %eax,%eax
f01080af:	74 0b                	je     f01080bc <mpconfig+0x33>
f01080b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01080b4:	0f b6 40 0b          	movzbl 0xb(%eax),%eax
f01080b8:	84 c0                	test   %al,%al
f01080ba:	74 16                	je     f01080d2 <mpconfig+0x49>
		cprintf("SMP: Default configurations not implemented\n");
f01080bc:	c7 04 24 f0 a5 10 f0 	movl   $0xf010a5f0,(%esp)
f01080c3:	e8 f7 ce ff ff       	call   f0104fbf <cprintf>
		return NULL;
f01080c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01080cd:	e9 19 01 00 00       	jmp    f01081eb <mpconfig+0x162>
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
f01080d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01080d5:	8b 40 04             	mov    0x4(%eax),%eax
f01080d8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01080dc:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f01080e3:	00 
f01080e4:	c7 04 24 db a5 10 f0 	movl   $0xf010a5db,(%esp)
f01080eb:	e8 db fd ff ff       	call   f0107ecb <_kaddr>
f01080f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (memcmp(conf, "PCMP", 4) != 0) {
f01080f3:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01080fa:	00 
f01080fb:	c7 44 24 04 1d a6 10 	movl   $0xf010a61d,0x4(%esp)
f0108102:	f0 
f0108103:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108106:	89 04 24             	mov    %eax,(%esp)
f0108109:	e8 57 fb ff ff       	call   f0107c65 <memcmp>
f010810e:	85 c0                	test   %eax,%eax
f0108110:	74 16                	je     f0108128 <mpconfig+0x9f>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0108112:	c7 04 24 24 a6 10 f0 	movl   $0xf010a624,(%esp)
f0108119:	e8 a1 ce ff ff       	call   f0104fbf <cprintf>
		return NULL;
f010811e:	b8 00 00 00 00       	mov    $0x0,%eax
f0108123:	e9 c3 00 00 00       	jmp    f01081eb <mpconfig+0x162>
	}
	if (sum(conf, conf->length) != 0) {
f0108128:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010812b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f010812f:	0f b7 c0             	movzwl %ax,%eax
f0108132:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108136:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108139:	89 04 24             	mov    %eax,(%esp)
f010813c:	e8 cc fd ff ff       	call   f0107f0d <sum>
f0108141:	84 c0                	test   %al,%al
f0108143:	74 16                	je     f010815b <mpconfig+0xd2>
		cprintf("SMP: Bad MP configuration checksum\n");
f0108145:	c7 04 24 58 a6 10 f0 	movl   $0xf010a658,(%esp)
f010814c:	e8 6e ce ff ff       	call   f0104fbf <cprintf>
		return NULL;
f0108151:	b8 00 00 00 00       	mov    $0x0,%eax
f0108156:	e9 90 00 00 00       	jmp    f01081eb <mpconfig+0x162>
	}
	if (conf->version != 1 && conf->version != 4) {
f010815b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010815e:	0f b6 40 06          	movzbl 0x6(%eax),%eax
f0108162:	3c 01                	cmp    $0x1,%al
f0108164:	74 2c                	je     f0108192 <mpconfig+0x109>
f0108166:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108169:	0f b6 40 06          	movzbl 0x6(%eax),%eax
f010816d:	3c 04                	cmp    $0x4,%al
f010816f:	74 21                	je     f0108192 <mpconfig+0x109>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0108171:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108174:	0f b6 40 06          	movzbl 0x6(%eax),%eax
f0108178:	0f b6 c0             	movzbl %al,%eax
f010817b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010817f:	c7 04 24 7c a6 10 f0 	movl   $0xf010a67c,(%esp)
f0108186:	e8 34 ce ff ff       	call   f0104fbf <cprintf>
		return NULL;
f010818b:	b8 00 00 00 00       	mov    $0x0,%eax
f0108190:	eb 59                	jmp    f01081eb <mpconfig+0x162>
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0108192:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108195:	0f b7 40 28          	movzwl 0x28(%eax),%eax
f0108199:	0f b7 c0             	movzwl %ax,%eax
f010819c:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010819f:	0f b7 52 04          	movzwl 0x4(%edx),%edx
f01081a3:	0f b7 ca             	movzwl %dx,%ecx
f01081a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01081a9:	01 ca                	add    %ecx,%edx
f01081ab:	89 44 24 04          	mov    %eax,0x4(%esp)
f01081af:	89 14 24             	mov    %edx,(%esp)
f01081b2:	e8 56 fd ff ff       	call   f0107f0d <sum>
f01081b7:	0f b6 d0             	movzbl %al,%edx
f01081ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01081bd:	0f b6 40 2a          	movzbl 0x2a(%eax),%eax
f01081c1:	0f b6 c0             	movzbl %al,%eax
f01081c4:	01 d0                	add    %edx,%eax
f01081c6:	0f b6 c0             	movzbl %al,%eax
f01081c9:	85 c0                	test   %eax,%eax
f01081cb:	74 13                	je     f01081e0 <mpconfig+0x157>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01081cd:	c7 04 24 9c a6 10 f0 	movl   $0xf010a69c,(%esp)
f01081d4:	e8 e6 cd ff ff       	call   f0104fbf <cprintf>
		return NULL;
f01081d9:	b8 00 00 00 00       	mov    $0x0,%eax
f01081de:	eb 0b                	jmp    f01081eb <mpconfig+0x162>
	}
	*pmp = mp;
f01081e0:	8b 45 08             	mov    0x8(%ebp),%eax
f01081e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01081e6:	89 10                	mov    %edx,(%eax)
	return conf;
f01081e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
f01081eb:	c9                   	leave  
f01081ec:	c3                   	ret    

f01081ed <mp_init>:

void
mp_init(void)
{
f01081ed:	55                   	push   %ebp
f01081ee:	89 e5                	mov    %esp,%ebp
f01081f0:	83 ec 48             	sub    $0x48,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01081f3:	c7 05 c0 c3 23 f0 20 	movl   $0xf023c020,0xf023c3c0
f01081fa:	c0 23 f0 
	if ((conf = mpconfig(&mp)) == 0)
f01081fd:	8d 45 cc             	lea    -0x34(%ebp),%eax
f0108200:	89 04 24             	mov    %eax,(%esp)
f0108203:	e8 81 fe ff ff       	call   f0108089 <mpconfig>
f0108208:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010820b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f010820f:	75 05                	jne    f0108216 <mp_init+0x29>
		return;
f0108211:	e9 c1 01 00 00       	jmp    f01083d7 <mp_init+0x1ea>
	ismp = 1;
f0108216:	c7 05 00 c0 23 f0 01 	movl   $0x1,0xf023c000
f010821d:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0108220:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108223:	8b 40 24             	mov    0x24(%eax),%eax
f0108226:	a3 00 d0 27 f0       	mov    %eax,0xf027d000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010822b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010822e:	83 c0 2c             	add    $0x2c,%eax
f0108231:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0108234:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f010823b:	e9 d2 00 00 00       	jmp    f0108312 <mp_init+0x125>
		switch (*p) {
f0108240:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108243:	0f b6 00             	movzbl (%eax),%eax
f0108246:	0f b6 c0             	movzbl %al,%eax
f0108249:	85 c0                	test   %eax,%eax
f010824b:	74 13                	je     f0108260 <mp_init+0x73>
f010824d:	85 c0                	test   %eax,%eax
f010824f:	0f 88 89 00 00 00    	js     f01082de <mp_init+0xf1>
f0108255:	83 f8 04             	cmp    $0x4,%eax
f0108258:	0f 8f 80 00 00 00    	jg     f01082de <mp_init+0xf1>
f010825e:	eb 78                	jmp    f01082d8 <mp_init+0xeb>
		case MPPROC:
			proc = (struct mpproc *)p;
f0108260:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108263:	89 45 e8             	mov    %eax,-0x18(%ebp)
			if (proc->flags & MPPROC_BOOT)
f0108266:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0108269:	0f b6 40 03          	movzbl 0x3(%eax),%eax
f010826d:	0f b6 c0             	movzbl %al,%eax
f0108270:	83 e0 02             	and    $0x2,%eax
f0108273:	85 c0                	test   %eax,%eax
f0108275:	74 12                	je     f0108289 <mp_init+0x9c>
				bootcpu = &cpus[ncpu];
f0108277:	a1 c4 c3 23 f0       	mov    0xf023c3c4,%eax
f010827c:	6b c0 74             	imul   $0x74,%eax,%eax
f010827f:	05 20 c0 23 f0       	add    $0xf023c020,%eax
f0108284:	a3 c0 c3 23 f0       	mov    %eax,0xf023c3c0
			if (ncpu < NCPU) {
f0108289:	a1 c4 c3 23 f0       	mov    0xf023c3c4,%eax
f010828e:	83 f8 07             	cmp    $0x7,%eax
f0108291:	7f 25                	jg     f01082b8 <mp_init+0xcb>
				cpus[ncpu].cpu_id = ncpu;
f0108293:	8b 15 c4 c3 23 f0    	mov    0xf023c3c4,%edx
f0108299:	a1 c4 c3 23 f0       	mov    0xf023c3c4,%eax
f010829e:	6b d2 74             	imul   $0x74,%edx,%edx
f01082a1:	81 c2 20 c0 23 f0    	add    $0xf023c020,%edx
f01082a7:	88 02                	mov    %al,(%edx)
				ncpu++;
f01082a9:	a1 c4 c3 23 f0       	mov    0xf023c3c4,%eax
f01082ae:	83 c0 01             	add    $0x1,%eax
f01082b1:	a3 c4 c3 23 f0       	mov    %eax,0xf023c3c4
f01082b6:	eb 1a                	jmp    f01082d2 <mp_init+0xe5>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
f01082b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01082bb:	0f b6 40 01          	movzbl 0x1(%eax),%eax
				bootcpu = &cpus[ncpu];
			if (ncpu < NCPU) {
				cpus[ncpu].cpu_id = ncpu;
				ncpu++;
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01082bf:	0f b6 c0             	movzbl %al,%eax
f01082c2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01082c6:	c7 04 24 cc a6 10 f0 	movl   $0xf010a6cc,(%esp)
f01082cd:	e8 ed cc ff ff       	call   f0104fbf <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01082d2:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
			continue;
f01082d6:	eb 36                	jmp    f010830e <mp_init+0x121>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01082d8:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
			continue;
f01082dc:	eb 30                	jmp    f010830e <mp_init+0x121>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01082de:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01082e1:	0f b6 00             	movzbl (%eax),%eax
f01082e4:	0f b6 c0             	movzbl %al,%eax
f01082e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01082eb:	c7 04 24 f4 a6 10 f0 	movl   $0xf010a6f4,(%esp)
f01082f2:	e8 c8 cc ff ff       	call   f0104fbf <cprintf>
			ismp = 0;
f01082f7:	c7 05 00 c0 23 f0 00 	movl   $0x0,0xf023c000
f01082fe:	00 00 00 
			i = conf->entry;
f0108301:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108304:	0f b7 40 22          	movzwl 0x22(%eax),%eax
f0108308:	0f b7 c0             	movzwl %ax,%eax
f010830b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010830e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f0108312:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108315:	0f b7 40 22          	movzwl 0x22(%eax),%eax
f0108319:	0f b7 c0             	movzwl %ax,%eax
f010831c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f010831f:	0f 87 1b ff ff ff    	ja     f0108240 <mp_init+0x53>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0108325:	a1 c0 c3 23 f0       	mov    0xf023c3c0,%eax
f010832a:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0108331:	a1 00 c0 23 f0       	mov    0xf023c000,%eax
f0108336:	85 c0                	test   %eax,%eax
f0108338:	75 22                	jne    f010835c <mp_init+0x16f>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f010833a:	c7 05 c4 c3 23 f0 01 	movl   $0x1,0xf023c3c4
f0108341:	00 00 00 
		lapicaddr = 0;
f0108344:	c7 05 00 d0 27 f0 00 	movl   $0x0,0xf027d000
f010834b:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f010834e:	c7 04 24 14 a7 10 f0 	movl   $0xf010a714,(%esp)
f0108355:	e8 65 cc ff ff       	call   f0104fbf <cprintf>
		return;
f010835a:	eb 7b                	jmp    f01083d7 <mp_init+0x1ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010835c:	8b 15 c4 c3 23 f0    	mov    0xf023c3c4,%edx
f0108362:	a1 c0 c3 23 f0       	mov    0xf023c3c0,%eax
f0108367:	0f b6 00             	movzbl (%eax),%eax
f010836a:	0f b6 c0             	movzbl %al,%eax
f010836d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0108371:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108375:	c7 04 24 40 a7 10 f0 	movl   $0xf010a740,(%esp)
f010837c:	e8 3e cc ff ff       	call   f0104fbf <cprintf>

	if (mp->imcrp) {
f0108381:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0108384:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
f0108388:	84 c0                	test   %al,%al
f010838a:	74 4b                	je     f01083d7 <mp_init+0x1ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f010838c:	c7 04 24 60 a7 10 f0 	movl   $0xf010a760,(%esp)
f0108393:	e8 27 cc ff ff       	call   f0104fbf <cprintf>
f0108398:	c7 45 e4 22 00 00 00 	movl   $0x22,-0x1c(%ebp)
f010839f:	c6 45 e3 70          	movb   $0x70,-0x1d(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01083a3:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01083a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01083aa:	ee                   	out    %al,(%dx)
f01083ab:	c7 45 dc 23 00 00 00 	movl   $0x23,-0x24(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01083b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01083b5:	89 c2                	mov    %eax,%edx
f01083b7:	ec                   	in     (%dx),%al
f01083b8:	88 45 db             	mov    %al,-0x25(%ebp)
	return data;
f01083bb:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01083bf:	83 c8 01             	or     $0x1,%eax
f01083c2:	0f b6 c0             	movzbl %al,%eax
f01083c5:	c7 45 d4 23 00 00 00 	movl   $0x23,-0x2c(%ebp)
f01083cc:	88 45 d3             	mov    %al,-0x2d(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01083cf:	0f b6 45 d3          	movzbl -0x2d(%ebp),%eax
f01083d3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01083d6:	ee                   	out    %al,(%dx)
	}
}
f01083d7:	c9                   	leave  
f01083d8:	c3                   	ret    

f01083d9 <_kaddr>:
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f01083d9:	55                   	push   %ebp
f01083da:	89 e5                	mov    %esp,%ebp
f01083dc:	83 ec 18             	sub    $0x18,%esp
	if (PGNUM(pa) >= npages)
f01083df:	8b 45 10             	mov    0x10(%ebp),%eax
f01083e2:	c1 e8 0c             	shr    $0xc,%eax
f01083e5:	89 c2                	mov    %eax,%edx
f01083e7:	a1 e8 be 23 f0       	mov    0xf023bee8,%eax
f01083ec:	39 c2                	cmp    %eax,%edx
f01083ee:	72 21                	jb     f0108411 <_kaddr+0x38>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01083f0:	8b 45 10             	mov    0x10(%ebp),%eax
f01083f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01083f7:	c7 44 24 08 a4 a7 10 	movl   $0xf010a7a4,0x8(%esp)
f01083fe:	f0 
f01083ff:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108402:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108406:	8b 45 08             	mov    0x8(%ebp),%eax
f0108409:	89 04 24             	mov    %eax,(%esp)
f010840c:	e8 e6 7e ff ff       	call   f01002f7 <_panic>
	return (void *)(pa + KERNBASE);
f0108411:	8b 45 10             	mov    0x10(%ebp),%eax
f0108414:	2d 00 00 00 10       	sub    $0x10000000,%eax
}
f0108419:	c9                   	leave  
f010841a:	c3                   	ret    

f010841b <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f010841b:	55                   	push   %ebp
f010841c:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f010841e:	a1 04 d0 27 f0       	mov    0xf027d004,%eax
f0108423:	8b 55 08             	mov    0x8(%ebp),%edx
f0108426:	c1 e2 02             	shl    $0x2,%edx
f0108429:	01 c2                	add    %eax,%edx
f010842b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010842e:	89 02                	mov    %eax,(%edx)
	lapic[ID];  // wait for write to finish, by reading
f0108430:	a1 04 d0 27 f0       	mov    0xf027d004,%eax
f0108435:	83 c0 20             	add    $0x20,%eax
f0108438:	8b 00                	mov    (%eax),%eax
}
f010843a:	5d                   	pop    %ebp
f010843b:	c3                   	ret    

f010843c <lapic_init>:

void
lapic_init(void)
{
f010843c:	55                   	push   %ebp
f010843d:	89 e5                	mov    %esp,%ebp
f010843f:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f0108442:	a1 00 d0 27 f0       	mov    0xf027d000,%eax
f0108447:	85 c0                	test   %eax,%eax
f0108449:	75 05                	jne    f0108450 <lapic_init+0x14>
		return;
f010844b:	e9 74 01 00 00       	jmp    f01085c4 <lapic_init+0x188>

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0108450:	a1 00 d0 27 f0       	mov    0xf027d000,%eax
f0108455:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010845c:	00 
f010845d:	89 04 24             	mov    %eax,(%esp)
f0108460:	e8 c0 97 ff ff       	call   f0101c25 <mmio_map_region>
f0108465:	a3 04 d0 27 f0       	mov    %eax,0xf027d004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010846a:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
f0108471:	00 
f0108472:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
f0108479:	e8 9d ff ff ff       	call   f010841b <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010847e:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
f0108485:	00 
f0108486:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
f010848d:	e8 89 ff ff ff       	call   f010841b <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0108492:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
f0108499:	00 
f010849a:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
f01084a1:	e8 75 ff ff ff       	call   f010841b <lapicw>
	lapicw(TICR, 10000000); 
f01084a6:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
f01084ad:	00 
f01084ae:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
f01084b5:	e8 61 ff ff ff       	call   f010841b <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f01084ba:	e8 07 01 00 00       	call   f01085c6 <cpunum>
f01084bf:	6b c0 74             	imul   $0x74,%eax,%eax
f01084c2:	8d 90 20 c0 23 f0    	lea    -0xfdc3fe0(%eax),%edx
f01084c8:	a1 c0 c3 23 f0       	mov    0xf023c3c0,%eax
f01084cd:	39 c2                	cmp    %eax,%edx
f01084cf:	74 14                	je     f01084e5 <lapic_init+0xa9>
		lapicw(LINT0, MASKED);
f01084d1:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
f01084d8:	00 
f01084d9:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
f01084e0:	e8 36 ff ff ff       	call   f010841b <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01084e5:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
f01084ec:	00 
f01084ed:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
f01084f4:	e8 22 ff ff ff       	call   f010841b <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01084f9:	a1 04 d0 27 f0       	mov    0xf027d004,%eax
f01084fe:	83 c0 30             	add    $0x30,%eax
f0108501:	8b 00                	mov    (%eax),%eax
f0108503:	c1 e8 10             	shr    $0x10,%eax
f0108506:	0f b6 c0             	movzbl %al,%eax
f0108509:	83 f8 03             	cmp    $0x3,%eax
f010850c:	76 14                	jbe    f0108522 <lapic_init+0xe6>
		lapicw(PCINT, MASKED);
f010850e:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
f0108515:	00 
f0108516:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
f010851d:	e8 f9 fe ff ff       	call   f010841b <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0108522:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
f0108529:	00 
f010852a:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
f0108531:	e8 e5 fe ff ff       	call   f010841b <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0108536:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010853d:	00 
f010853e:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
f0108545:	e8 d1 fe ff ff       	call   f010841b <lapicw>
	lapicw(ESR, 0);
f010854a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0108551:	00 
f0108552:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
f0108559:	e8 bd fe ff ff       	call   f010841b <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f010855e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0108565:	00 
f0108566:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
f010856d:	e8 a9 fe ff ff       	call   f010841b <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0108572:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0108579:	00 
f010857a:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
f0108581:	e8 95 fe ff ff       	call   f010841b <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0108586:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
f010858d:	00 
f010858e:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
f0108595:	e8 81 fe ff ff       	call   f010841b <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010859a:	90                   	nop
f010859b:	a1 04 d0 27 f0       	mov    0xf027d004,%eax
f01085a0:	05 00 03 00 00       	add    $0x300,%eax
f01085a5:	8b 00                	mov    (%eax),%eax
f01085a7:	25 00 10 00 00       	and    $0x1000,%eax
f01085ac:	85 c0                	test   %eax,%eax
f01085ae:	75 eb                	jne    f010859b <lapic_init+0x15f>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01085b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01085b7:	00 
f01085b8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01085bf:	e8 57 fe ff ff       	call   f010841b <lapicw>
}
f01085c4:	c9                   	leave  
f01085c5:	c3                   	ret    

f01085c6 <cpunum>:

int
cpunum(void)
{
f01085c6:	55                   	push   %ebp
f01085c7:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01085c9:	a1 04 d0 27 f0       	mov    0xf027d004,%eax
f01085ce:	85 c0                	test   %eax,%eax
f01085d0:	74 0f                	je     f01085e1 <cpunum+0x1b>
		return lapic[ID] >> 24;
f01085d2:	a1 04 d0 27 f0       	mov    0xf027d004,%eax
f01085d7:	83 c0 20             	add    $0x20,%eax
f01085da:	8b 00                	mov    (%eax),%eax
f01085dc:	c1 e8 18             	shr    $0x18,%eax
f01085df:	eb 05                	jmp    f01085e6 <cpunum+0x20>
	return 0;
f01085e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01085e6:	5d                   	pop    %ebp
f01085e7:	c3                   	ret    

f01085e8 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01085e8:	55                   	push   %ebp
f01085e9:	89 e5                	mov    %esp,%ebp
f01085eb:	83 ec 08             	sub    $0x8,%esp
	if (lapic)
f01085ee:	a1 04 d0 27 f0       	mov    0xf027d004,%eax
f01085f3:	85 c0                	test   %eax,%eax
f01085f5:	74 14                	je     f010860b <lapic_eoi+0x23>
		lapicw(EOI, 0);
f01085f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01085fe:	00 
f01085ff:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
f0108606:	e8 10 fe ff ff       	call   f010841b <lapicw>
}
f010860b:	c9                   	leave  
f010860c:	c3                   	ret    

f010860d <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
static void
microdelay(int us)
{
f010860d:	55                   	push   %ebp
f010860e:	89 e5                	mov    %esp,%ebp
}
f0108610:	5d                   	pop    %ebp
f0108611:	c3                   	ret    

f0108612 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0108612:	55                   	push   %ebp
f0108613:	89 e5                	mov    %esp,%ebp
f0108615:	83 ec 38             	sub    $0x38,%esp
f0108618:	8b 45 08             	mov    0x8(%ebp),%eax
f010861b:	88 45 d4             	mov    %al,-0x2c(%ebp)
f010861e:	c7 45 ec 70 00 00 00 	movl   $0x70,-0x14(%ebp)
f0108625:	c6 45 eb 0f          	movb   $0xf,-0x15(%ebp)
f0108629:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
f010862d:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0108630:	ee                   	out    %al,(%dx)
f0108631:	c7 45 e4 71 00 00 00 	movl   $0x71,-0x1c(%ebp)
f0108638:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
f010863c:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f0108640:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0108643:	ee                   	out    %al,(%dx)
	// "The BSP must initialize CMOS shutdown code to 0AH
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
f0108644:	c7 44 24 08 67 04 00 	movl   $0x467,0x8(%esp)
f010864b:	00 
f010864c:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0108653:	00 
f0108654:	c7 04 24 c7 a7 10 f0 	movl   $0xf010a7c7,(%esp)
f010865b:	e8 79 fd ff ff       	call   f01083d9 <_kaddr>
f0108660:	89 45 f0             	mov    %eax,-0x10(%ebp)
	wrv[0] = 0;
f0108663:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108666:	66 c7 00 00 00       	movw   $0x0,(%eax)
	wrv[1] = addr >> 4;
f010866b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010866e:	8d 50 02             	lea    0x2(%eax),%edx
f0108671:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108674:	c1 e8 04             	shr    $0x4,%eax
f0108677:	66 89 02             	mov    %ax,(%edx)

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f010867a:	0f b6 45 d4          	movzbl -0x2c(%ebp),%eax
f010867e:	c1 e0 18             	shl    $0x18,%eax
f0108681:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108685:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
f010868c:	e8 8a fd ff ff       	call   f010841b <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0108691:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
f0108698:	00 
f0108699:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
f01086a0:	e8 76 fd ff ff       	call   f010841b <lapicw>
	microdelay(200);
f01086a5:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
f01086ac:	e8 5c ff ff ff       	call   f010860d <microdelay>
	lapicw(ICRLO, INIT | LEVEL);
f01086b1:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
f01086b8:	00 
f01086b9:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
f01086c0:	e8 56 fd ff ff       	call   f010841b <lapicw>
	microdelay(100);    // should be 10ms, but too slow in Bochs!
f01086c5:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01086cc:	e8 3c ff ff ff       	call   f010860d <microdelay>
	// Send startup IPI (twice!) to enter code.
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
f01086d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f01086d8:	eb 40                	jmp    f010871a <lapic_startap+0x108>
		lapicw(ICRHI, apicid << 24);
f01086da:	0f b6 45 d4          	movzbl -0x2c(%ebp),%eax
f01086de:	c1 e0 18             	shl    $0x18,%eax
f01086e1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01086e5:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
f01086ec:	e8 2a fd ff ff       	call   f010841b <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01086f1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01086f4:	c1 e8 0c             	shr    $0xc,%eax
f01086f7:	80 cc 06             	or     $0x6,%ah
f01086fa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01086fe:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
f0108705:	e8 11 fd ff ff       	call   f010841b <lapicw>
		microdelay(200);
f010870a:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
f0108711:	e8 f7 fe ff ff       	call   f010860d <microdelay>
	// Send startup IPI (twice!) to enter code.
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
f0108716:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f010871a:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
f010871e:	7e ba                	jle    f01086da <lapic_startap+0xc8>
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
		microdelay(200);
	}
}
f0108720:	c9                   	leave  
f0108721:	c3                   	ret    

f0108722 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0108722:	55                   	push   %ebp
f0108723:	89 e5                	mov    %esp,%ebp
f0108725:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0108728:	8b 45 08             	mov    0x8(%ebp),%eax
f010872b:	0d 00 00 0c 00       	or     $0xc0000,%eax
f0108730:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108734:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
f010873b:	e8 db fc ff ff       	call   f010841b <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0108740:	90                   	nop
f0108741:	a1 04 d0 27 f0       	mov    0xf027d004,%eax
f0108746:	05 00 03 00 00       	add    $0x300,%eax
f010874b:	8b 00                	mov    (%eax),%eax
f010874d:	25 00 10 00 00       	and    $0x1000,%eax
f0108752:	85 c0                	test   %eax,%eax
f0108754:	75 eb                	jne    f0108741 <lapic_ipi+0x1f>
		;
}
f0108756:	c9                   	leave  
f0108757:	c3                   	ret    

f0108758 <xchg>:
	return tsc;
}

static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
f0108758:	55                   	push   %ebp
f0108759:	89 e5                	mov    %esp,%ebp
f010875b:	83 ec 10             	sub    $0x10,%esp
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010875e:	8b 55 08             	mov    0x8(%ebp),%edx
f0108761:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108764:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0108767:	f0 87 02             	lock xchg %eax,(%edx)
f010876a:	89 45 fc             	mov    %eax,-0x4(%ebp)
			"+m" (*addr), "=a" (result) :
			"1" (newval) :
			"cc");
	return result;
f010876d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f0108770:	c9                   	leave  
f0108771:	c3                   	ret    

f0108772 <get_caller_pcs>:

#ifdef DEBUG_SPINLOCK
// Record the current call stack in pcs[] by following the %ebp chain.
static void
get_caller_pcs(uint32_t pcs[])
{
f0108772:	55                   	push   %ebp
f0108773:	89 e5                	mov    %esp,%ebp
f0108775:	83 ec 10             	sub    $0x10,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0108778:	89 e8                	mov    %ebp,%eax
f010877a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	return ebp;
f010877d:	8b 45 f4             	mov    -0xc(%ebp),%eax
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0108780:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (i = 0; i < 10; i++){
f0108783:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
f010878a:	eb 32                	jmp    f01087be <get_caller_pcs+0x4c>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f010878c:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
f0108790:	74 32                	je     f01087c4 <get_caller_pcs+0x52>
f0108792:	81 7d fc ff ff 7f ef 	cmpl   $0xef7fffff,-0x4(%ebp)
f0108799:	76 29                	jbe    f01087c4 <get_caller_pcs+0x52>
			break;
		pcs[i] = ebp[1];          // saved %eip
f010879b:	8b 45 f8             	mov    -0x8(%ebp),%eax
f010879e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01087a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01087a8:	01 c2                	add    %eax,%edx
f01087aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01087ad:	8b 40 04             	mov    0x4(%eax),%eax
f01087b0:	89 02                	mov    %eax,(%edx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01087b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01087b5:	8b 00                	mov    (%eax),%eax
f01087b7:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01087ba:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
f01087be:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
f01087c2:	7e c8                	jle    f010878c <get_caller_pcs+0x1a>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01087c4:	eb 19                	jmp    f01087df <get_caller_pcs+0x6d>
		pcs[i] = 0;
f01087c6:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01087c9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01087d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01087d3:	01 d0                	add    %edx,%eax
f01087d5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01087db:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
f01087df:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
f01087e3:	7e e1                	jle    f01087c6 <get_caller_pcs+0x54>
		pcs[i] = 0;
}
f01087e5:	c9                   	leave  
f01087e6:	c3                   	ret    

f01087e7 <holding>:

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f01087e7:	55                   	push   %ebp
f01087e8:	89 e5                	mov    %esp,%ebp
f01087ea:	53                   	push   %ebx
f01087eb:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f01087ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01087f1:	8b 00                	mov    (%eax),%eax
f01087f3:	85 c0                	test   %eax,%eax
f01087f5:	74 1e                	je     f0108815 <holding+0x2e>
f01087f7:	8b 45 08             	mov    0x8(%ebp),%eax
f01087fa:	8b 58 08             	mov    0x8(%eax),%ebx
f01087fd:	e8 c4 fd ff ff       	call   f01085c6 <cpunum>
f0108802:	6b c0 74             	imul   $0x74,%eax,%eax
f0108805:	05 20 c0 23 f0       	add    $0xf023c020,%eax
f010880a:	39 c3                	cmp    %eax,%ebx
f010880c:	75 07                	jne    f0108815 <holding+0x2e>
f010880e:	b8 01 00 00 00       	mov    $0x1,%eax
f0108813:	eb 05                	jmp    f010881a <holding+0x33>
f0108815:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010881a:	83 c4 04             	add    $0x4,%esp
f010881d:	5b                   	pop    %ebx
f010881e:	5d                   	pop    %ebp
f010881f:	c3                   	ret    

f0108820 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0108820:	55                   	push   %ebp
f0108821:	89 e5                	mov    %esp,%ebp
	lk->locked = 0;
f0108823:	8b 45 08             	mov    0x8(%ebp),%eax
f0108826:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010882c:	8b 45 08             	mov    0x8(%ebp),%eax
f010882f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0108832:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0108835:	8b 45 08             	mov    0x8(%ebp),%eax
f0108838:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f010883f:	5d                   	pop    %ebp
f0108840:	c3                   	ret    

f0108841 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0108841:	55                   	push   %ebp
f0108842:	89 e5                	mov    %esp,%ebp
f0108844:	53                   	push   %ebx
f0108845:	83 ec 24             	sub    $0x24,%esp
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0108848:	8b 45 08             	mov    0x8(%ebp),%eax
f010884b:	89 04 24             	mov    %eax,(%esp)
f010884e:	e8 94 ff ff ff       	call   f01087e7 <holding>
f0108853:	85 c0                	test   %eax,%eax
f0108855:	74 2f                	je     f0108886 <spin_lock+0x45>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0108857:	8b 45 08             	mov    0x8(%ebp),%eax
f010885a:	8b 58 04             	mov    0x4(%eax),%ebx
f010885d:	e8 64 fd ff ff       	call   f01085c6 <cpunum>
f0108862:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0108866:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010886a:	c7 44 24 08 e0 a7 10 	movl   $0xf010a7e0,0x8(%esp)
f0108871:	f0 
f0108872:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0108879:	00 
f010887a:	c7 04 24 0a a8 10 f0 	movl   $0xf010a80a,(%esp)
f0108881:	e8 71 7a ff ff       	call   f01002f7 <_panic>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0108886:	eb 02                	jmp    f010888a <spin_lock+0x49>
		asm volatile ("pause");
f0108888:	f3 90                	pause  
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f010888a:	8b 45 08             	mov    0x8(%ebp),%eax
f010888d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0108894:	00 
f0108895:	89 04 24             	mov    %eax,(%esp)
f0108898:	e8 bb fe ff ff       	call   f0108758 <xchg>
f010889d:	85 c0                	test   %eax,%eax
f010889f:	75 e7                	jne    f0108888 <spin_lock+0x47>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01088a1:	e8 20 fd ff ff       	call   f01085c6 <cpunum>
f01088a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01088a9:	8d 90 20 c0 23 f0    	lea    -0xfdc3fe0(%eax),%edx
f01088af:	8b 45 08             	mov    0x8(%ebp),%eax
f01088b2:	89 50 08             	mov    %edx,0x8(%eax)
	get_caller_pcs(lk->pcs);
f01088b5:	8b 45 08             	mov    0x8(%ebp),%eax
f01088b8:	83 c0 0c             	add    $0xc,%eax
f01088bb:	89 04 24             	mov    %eax,(%esp)
f01088be:	e8 af fe ff ff       	call   f0108772 <get_caller_pcs>
#endif
}
f01088c3:	83 c4 24             	add    $0x24,%esp
f01088c6:	5b                   	pop    %ebx
f01088c7:	5d                   	pop    %ebp
f01088c8:	c3                   	ret    

f01088c9 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01088c9:	55                   	push   %ebp
f01088ca:	89 e5                	mov    %esp,%ebp
f01088cc:	57                   	push   %edi
f01088cd:	56                   	push   %esi
f01088ce:	53                   	push   %ebx
f01088cf:	83 ec 7c             	sub    $0x7c,%esp
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01088d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01088d5:	89 04 24             	mov    %eax,(%esp)
f01088d8:	e8 0a ff ff ff       	call   f01087e7 <holding>
f01088dd:	85 c0                	test   %eax,%eax
f01088df:	0f 85 02 01 00 00    	jne    f01089e7 <spin_unlock+0x11e>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01088e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01088e8:	83 c0 0c             	add    $0xc,%eax
f01088eb:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f01088f2:	00 
f01088f3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01088f7:	8d 45 a4             	lea    -0x5c(%ebp),%eax
f01088fa:	89 04 24             	mov    %eax,(%esp)
f01088fd:	e8 68 f2 ff ff       	call   f0107b6a <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0108902:	8b 45 08             	mov    0x8(%ebp),%eax
f0108905:	8b 40 08             	mov    0x8(%eax),%eax
f0108908:	0f b6 00             	movzbl (%eax),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010890b:	0f b6 f0             	movzbl %al,%esi
f010890e:	8b 45 08             	mov    0x8(%ebp),%eax
f0108911:	8b 58 04             	mov    0x4(%eax),%ebx
f0108914:	e8 ad fc ff ff       	call   f01085c6 <cpunum>
f0108919:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010891d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0108921:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108925:	c7 04 24 1c a8 10 f0 	movl   $0xf010a81c,(%esp)
f010892c:	e8 8e c6 ff ff       	call   f0104fbf <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0108931:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0108938:	eb 7c                	jmp    f01089b6 <spin_unlock+0xed>
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010893a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010893d:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
f0108941:	8d 55 cc             	lea    -0x34(%ebp),%edx
f0108944:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108948:	89 04 24             	mov    %eax,(%esp)
f010894b:	e8 ae e3 ff ff       	call   f0106cfe <debuginfo_eip>
f0108950:	85 c0                	test   %eax,%eax
f0108952:	78 47                	js     f010899b <spin_unlock+0xd2>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0108954:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0108957:	8b 54 85 a4          	mov    -0x5c(%ebp,%eax,4),%edx
f010895b:	8b 45 dc             	mov    -0x24(%ebp),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010895e:	89 d7                	mov    %edx,%edi
f0108960:	29 c7                	sub    %eax,%edi
f0108962:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0108965:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0108968:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010896b:	8b 55 cc             	mov    -0x34(%ebp),%edx
f010896e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0108971:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
f0108975:	89 7c 24 18          	mov    %edi,0x18(%esp)
f0108979:	89 74 24 14          	mov    %esi,0x14(%esp)
f010897d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0108981:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0108985:	89 54 24 08          	mov    %edx,0x8(%esp)
f0108989:	89 44 24 04          	mov    %eax,0x4(%esp)
f010898d:	c7 04 24 52 a8 10 f0 	movl   $0xf010a852,(%esp)
f0108994:	e8 26 c6 ff ff       	call   f0104fbf <cprintf>
f0108999:	eb 17                	jmp    f01089b2 <spin_unlock+0xe9>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f010899b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010899e:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
f01089a2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01089a6:	c7 04 24 69 a8 10 f0 	movl   $0xf010a869,(%esp)
f01089ad:	e8 0d c6 ff ff       	call   f0104fbf <cprintf>
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01089b2:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
f01089b6:	83 7d e4 09          	cmpl   $0x9,-0x1c(%ebp)
f01089ba:	7f 0f                	jg     f01089cb <spin_unlock+0x102>
f01089bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01089bf:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
f01089c3:	85 c0                	test   %eax,%eax
f01089c5:	0f 85 6f ff ff ff    	jne    f010893a <spin_unlock+0x71>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01089cb:	c7 44 24 08 71 a8 10 	movl   $0xf010a871,0x8(%esp)
f01089d2:	f0 
f01089d3:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f01089da:	00 
f01089db:	c7 04 24 0a a8 10 f0 	movl   $0xf010a80a,(%esp)
f01089e2:	e8 10 79 ff ff       	call   f01002f7 <_panic>
	}

	lk->pcs[0] = 0;
f01089e7:	8b 45 08             	mov    0x8(%ebp),%eax
f01089ea:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	lk->cpu = 0;
f01089f1:	8b 45 08             	mov    0x8(%ebp),%eax
f01089f4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	// But the 2007 Intel 64 Architecture Memory Ordering White
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
f01089fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01089fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0108a05:	00 
f0108a06:	89 04 24             	mov    %eax,(%esp)
f0108a09:	e8 4a fd ff ff       	call   f0108758 <xchg>
}
f0108a0e:	83 c4 7c             	add    $0x7c,%esp
f0108a11:	5b                   	pop    %ebx
f0108a12:	5e                   	pop    %esi
f0108a13:	5f                   	pop    %edi
f0108a14:	5d                   	pop    %ebp
f0108a15:	c3                   	ret    
f0108a16:	66 90                	xchg   %ax,%ax
f0108a18:	66 90                	xchg   %ax,%ax
f0108a1a:	66 90                	xchg   %ax,%ax
f0108a1c:	66 90                	xchg   %ax,%ax
f0108a1e:	66 90                	xchg   %ax,%ax

f0108a20 <__udivdi3>:
f0108a20:	55                   	push   %ebp
f0108a21:	57                   	push   %edi
f0108a22:	56                   	push   %esi
f0108a23:	83 ec 0c             	sub    $0xc,%esp
f0108a26:	8b 44 24 28          	mov    0x28(%esp),%eax
f0108a2a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f0108a2e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0108a32:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0108a36:	85 c0                	test   %eax,%eax
f0108a38:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0108a3c:	89 ea                	mov    %ebp,%edx
f0108a3e:	89 0c 24             	mov    %ecx,(%esp)
f0108a41:	75 2d                	jne    f0108a70 <__udivdi3+0x50>
f0108a43:	39 e9                	cmp    %ebp,%ecx
f0108a45:	77 61                	ja     f0108aa8 <__udivdi3+0x88>
f0108a47:	85 c9                	test   %ecx,%ecx
f0108a49:	89 ce                	mov    %ecx,%esi
f0108a4b:	75 0b                	jne    f0108a58 <__udivdi3+0x38>
f0108a4d:	b8 01 00 00 00       	mov    $0x1,%eax
f0108a52:	31 d2                	xor    %edx,%edx
f0108a54:	f7 f1                	div    %ecx
f0108a56:	89 c6                	mov    %eax,%esi
f0108a58:	31 d2                	xor    %edx,%edx
f0108a5a:	89 e8                	mov    %ebp,%eax
f0108a5c:	f7 f6                	div    %esi
f0108a5e:	89 c5                	mov    %eax,%ebp
f0108a60:	89 f8                	mov    %edi,%eax
f0108a62:	f7 f6                	div    %esi
f0108a64:	89 ea                	mov    %ebp,%edx
f0108a66:	83 c4 0c             	add    $0xc,%esp
f0108a69:	5e                   	pop    %esi
f0108a6a:	5f                   	pop    %edi
f0108a6b:	5d                   	pop    %ebp
f0108a6c:	c3                   	ret    
f0108a6d:	8d 76 00             	lea    0x0(%esi),%esi
f0108a70:	39 e8                	cmp    %ebp,%eax
f0108a72:	77 24                	ja     f0108a98 <__udivdi3+0x78>
f0108a74:	0f bd e8             	bsr    %eax,%ebp
f0108a77:	83 f5 1f             	xor    $0x1f,%ebp
f0108a7a:	75 3c                	jne    f0108ab8 <__udivdi3+0x98>
f0108a7c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0108a80:	39 34 24             	cmp    %esi,(%esp)
f0108a83:	0f 86 9f 00 00 00    	jbe    f0108b28 <__udivdi3+0x108>
f0108a89:	39 d0                	cmp    %edx,%eax
f0108a8b:	0f 82 97 00 00 00    	jb     f0108b28 <__udivdi3+0x108>
f0108a91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0108a98:	31 d2                	xor    %edx,%edx
f0108a9a:	31 c0                	xor    %eax,%eax
f0108a9c:	83 c4 0c             	add    $0xc,%esp
f0108a9f:	5e                   	pop    %esi
f0108aa0:	5f                   	pop    %edi
f0108aa1:	5d                   	pop    %ebp
f0108aa2:	c3                   	ret    
f0108aa3:	90                   	nop
f0108aa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0108aa8:	89 f8                	mov    %edi,%eax
f0108aaa:	f7 f1                	div    %ecx
f0108aac:	31 d2                	xor    %edx,%edx
f0108aae:	83 c4 0c             	add    $0xc,%esp
f0108ab1:	5e                   	pop    %esi
f0108ab2:	5f                   	pop    %edi
f0108ab3:	5d                   	pop    %ebp
f0108ab4:	c3                   	ret    
f0108ab5:	8d 76 00             	lea    0x0(%esi),%esi
f0108ab8:	89 e9                	mov    %ebp,%ecx
f0108aba:	8b 3c 24             	mov    (%esp),%edi
f0108abd:	d3 e0                	shl    %cl,%eax
f0108abf:	89 c6                	mov    %eax,%esi
f0108ac1:	b8 20 00 00 00       	mov    $0x20,%eax
f0108ac6:	29 e8                	sub    %ebp,%eax
f0108ac8:	89 c1                	mov    %eax,%ecx
f0108aca:	d3 ef                	shr    %cl,%edi
f0108acc:	89 e9                	mov    %ebp,%ecx
f0108ace:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0108ad2:	8b 3c 24             	mov    (%esp),%edi
f0108ad5:	09 74 24 08          	or     %esi,0x8(%esp)
f0108ad9:	89 d6                	mov    %edx,%esi
f0108adb:	d3 e7                	shl    %cl,%edi
f0108add:	89 c1                	mov    %eax,%ecx
f0108adf:	89 3c 24             	mov    %edi,(%esp)
f0108ae2:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0108ae6:	d3 ee                	shr    %cl,%esi
f0108ae8:	89 e9                	mov    %ebp,%ecx
f0108aea:	d3 e2                	shl    %cl,%edx
f0108aec:	89 c1                	mov    %eax,%ecx
f0108aee:	d3 ef                	shr    %cl,%edi
f0108af0:	09 d7                	or     %edx,%edi
f0108af2:	89 f2                	mov    %esi,%edx
f0108af4:	89 f8                	mov    %edi,%eax
f0108af6:	f7 74 24 08          	divl   0x8(%esp)
f0108afa:	89 d6                	mov    %edx,%esi
f0108afc:	89 c7                	mov    %eax,%edi
f0108afe:	f7 24 24             	mull   (%esp)
f0108b01:	39 d6                	cmp    %edx,%esi
f0108b03:	89 14 24             	mov    %edx,(%esp)
f0108b06:	72 30                	jb     f0108b38 <__udivdi3+0x118>
f0108b08:	8b 54 24 04          	mov    0x4(%esp),%edx
f0108b0c:	89 e9                	mov    %ebp,%ecx
f0108b0e:	d3 e2                	shl    %cl,%edx
f0108b10:	39 c2                	cmp    %eax,%edx
f0108b12:	73 05                	jae    f0108b19 <__udivdi3+0xf9>
f0108b14:	3b 34 24             	cmp    (%esp),%esi
f0108b17:	74 1f                	je     f0108b38 <__udivdi3+0x118>
f0108b19:	89 f8                	mov    %edi,%eax
f0108b1b:	31 d2                	xor    %edx,%edx
f0108b1d:	e9 7a ff ff ff       	jmp    f0108a9c <__udivdi3+0x7c>
f0108b22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0108b28:	31 d2                	xor    %edx,%edx
f0108b2a:	b8 01 00 00 00       	mov    $0x1,%eax
f0108b2f:	e9 68 ff ff ff       	jmp    f0108a9c <__udivdi3+0x7c>
f0108b34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0108b38:	8d 47 ff             	lea    -0x1(%edi),%eax
f0108b3b:	31 d2                	xor    %edx,%edx
f0108b3d:	83 c4 0c             	add    $0xc,%esp
f0108b40:	5e                   	pop    %esi
f0108b41:	5f                   	pop    %edi
f0108b42:	5d                   	pop    %ebp
f0108b43:	c3                   	ret    
f0108b44:	66 90                	xchg   %ax,%ax
f0108b46:	66 90                	xchg   %ax,%ax
f0108b48:	66 90                	xchg   %ax,%ax
f0108b4a:	66 90                	xchg   %ax,%ax
f0108b4c:	66 90                	xchg   %ax,%ax
f0108b4e:	66 90                	xchg   %ax,%ax

f0108b50 <__umoddi3>:
f0108b50:	55                   	push   %ebp
f0108b51:	57                   	push   %edi
f0108b52:	56                   	push   %esi
f0108b53:	83 ec 14             	sub    $0x14,%esp
f0108b56:	8b 44 24 28          	mov    0x28(%esp),%eax
f0108b5a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0108b5e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0108b62:	89 c7                	mov    %eax,%edi
f0108b64:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108b68:	8b 44 24 30          	mov    0x30(%esp),%eax
f0108b6c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0108b70:	89 34 24             	mov    %esi,(%esp)
f0108b73:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0108b77:	85 c0                	test   %eax,%eax
f0108b79:	89 c2                	mov    %eax,%edx
f0108b7b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0108b7f:	75 17                	jne    f0108b98 <__umoddi3+0x48>
f0108b81:	39 fe                	cmp    %edi,%esi
f0108b83:	76 4b                	jbe    f0108bd0 <__umoddi3+0x80>
f0108b85:	89 c8                	mov    %ecx,%eax
f0108b87:	89 fa                	mov    %edi,%edx
f0108b89:	f7 f6                	div    %esi
f0108b8b:	89 d0                	mov    %edx,%eax
f0108b8d:	31 d2                	xor    %edx,%edx
f0108b8f:	83 c4 14             	add    $0x14,%esp
f0108b92:	5e                   	pop    %esi
f0108b93:	5f                   	pop    %edi
f0108b94:	5d                   	pop    %ebp
f0108b95:	c3                   	ret    
f0108b96:	66 90                	xchg   %ax,%ax
f0108b98:	39 f8                	cmp    %edi,%eax
f0108b9a:	77 54                	ja     f0108bf0 <__umoddi3+0xa0>
f0108b9c:	0f bd e8             	bsr    %eax,%ebp
f0108b9f:	83 f5 1f             	xor    $0x1f,%ebp
f0108ba2:	75 5c                	jne    f0108c00 <__umoddi3+0xb0>
f0108ba4:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0108ba8:	39 3c 24             	cmp    %edi,(%esp)
f0108bab:	0f 87 e7 00 00 00    	ja     f0108c98 <__umoddi3+0x148>
f0108bb1:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0108bb5:	29 f1                	sub    %esi,%ecx
f0108bb7:	19 c7                	sbb    %eax,%edi
f0108bb9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0108bbd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0108bc1:	8b 44 24 08          	mov    0x8(%esp),%eax
f0108bc5:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0108bc9:	83 c4 14             	add    $0x14,%esp
f0108bcc:	5e                   	pop    %esi
f0108bcd:	5f                   	pop    %edi
f0108bce:	5d                   	pop    %ebp
f0108bcf:	c3                   	ret    
f0108bd0:	85 f6                	test   %esi,%esi
f0108bd2:	89 f5                	mov    %esi,%ebp
f0108bd4:	75 0b                	jne    f0108be1 <__umoddi3+0x91>
f0108bd6:	b8 01 00 00 00       	mov    $0x1,%eax
f0108bdb:	31 d2                	xor    %edx,%edx
f0108bdd:	f7 f6                	div    %esi
f0108bdf:	89 c5                	mov    %eax,%ebp
f0108be1:	8b 44 24 04          	mov    0x4(%esp),%eax
f0108be5:	31 d2                	xor    %edx,%edx
f0108be7:	f7 f5                	div    %ebp
f0108be9:	89 c8                	mov    %ecx,%eax
f0108beb:	f7 f5                	div    %ebp
f0108bed:	eb 9c                	jmp    f0108b8b <__umoddi3+0x3b>
f0108bef:	90                   	nop
f0108bf0:	89 c8                	mov    %ecx,%eax
f0108bf2:	89 fa                	mov    %edi,%edx
f0108bf4:	83 c4 14             	add    $0x14,%esp
f0108bf7:	5e                   	pop    %esi
f0108bf8:	5f                   	pop    %edi
f0108bf9:	5d                   	pop    %ebp
f0108bfa:	c3                   	ret    
f0108bfb:	90                   	nop
f0108bfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0108c00:	8b 04 24             	mov    (%esp),%eax
f0108c03:	be 20 00 00 00       	mov    $0x20,%esi
f0108c08:	89 e9                	mov    %ebp,%ecx
f0108c0a:	29 ee                	sub    %ebp,%esi
f0108c0c:	d3 e2                	shl    %cl,%edx
f0108c0e:	89 f1                	mov    %esi,%ecx
f0108c10:	d3 e8                	shr    %cl,%eax
f0108c12:	89 e9                	mov    %ebp,%ecx
f0108c14:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108c18:	8b 04 24             	mov    (%esp),%eax
f0108c1b:	09 54 24 04          	or     %edx,0x4(%esp)
f0108c1f:	89 fa                	mov    %edi,%edx
f0108c21:	d3 e0                	shl    %cl,%eax
f0108c23:	89 f1                	mov    %esi,%ecx
f0108c25:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108c29:	8b 44 24 10          	mov    0x10(%esp),%eax
f0108c2d:	d3 ea                	shr    %cl,%edx
f0108c2f:	89 e9                	mov    %ebp,%ecx
f0108c31:	d3 e7                	shl    %cl,%edi
f0108c33:	89 f1                	mov    %esi,%ecx
f0108c35:	d3 e8                	shr    %cl,%eax
f0108c37:	89 e9                	mov    %ebp,%ecx
f0108c39:	09 f8                	or     %edi,%eax
f0108c3b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0108c3f:	f7 74 24 04          	divl   0x4(%esp)
f0108c43:	d3 e7                	shl    %cl,%edi
f0108c45:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0108c49:	89 d7                	mov    %edx,%edi
f0108c4b:	f7 64 24 08          	mull   0x8(%esp)
f0108c4f:	39 d7                	cmp    %edx,%edi
f0108c51:	89 c1                	mov    %eax,%ecx
f0108c53:	89 14 24             	mov    %edx,(%esp)
f0108c56:	72 2c                	jb     f0108c84 <__umoddi3+0x134>
f0108c58:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f0108c5c:	72 22                	jb     f0108c80 <__umoddi3+0x130>
f0108c5e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0108c62:	29 c8                	sub    %ecx,%eax
f0108c64:	19 d7                	sbb    %edx,%edi
f0108c66:	89 e9                	mov    %ebp,%ecx
f0108c68:	89 fa                	mov    %edi,%edx
f0108c6a:	d3 e8                	shr    %cl,%eax
f0108c6c:	89 f1                	mov    %esi,%ecx
f0108c6e:	d3 e2                	shl    %cl,%edx
f0108c70:	89 e9                	mov    %ebp,%ecx
f0108c72:	d3 ef                	shr    %cl,%edi
f0108c74:	09 d0                	or     %edx,%eax
f0108c76:	89 fa                	mov    %edi,%edx
f0108c78:	83 c4 14             	add    $0x14,%esp
f0108c7b:	5e                   	pop    %esi
f0108c7c:	5f                   	pop    %edi
f0108c7d:	5d                   	pop    %ebp
f0108c7e:	c3                   	ret    
f0108c7f:	90                   	nop
f0108c80:	39 d7                	cmp    %edx,%edi
f0108c82:	75 da                	jne    f0108c5e <__umoddi3+0x10e>
f0108c84:	8b 14 24             	mov    (%esp),%edx
f0108c87:	89 c1                	mov    %eax,%ecx
f0108c89:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f0108c8d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0108c91:	eb cb                	jmp    f0108c5e <__umoddi3+0x10e>
f0108c93:	90                   	nop
f0108c94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0108c98:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0108c9c:	0f 82 0f ff ff ff    	jb     f0108bb1 <__umoddi3+0x61>
f0108ca2:	e9 1a ff ff ff       	jmp    f0108bc1 <__umoddi3+0x71>
