
obj/user/stresssched:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 f2 00 00 00       	call   800123 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 28             	sub    $0x28,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800039:	e8 d0 0f 00 00       	call   80100e <sys_getenvid>
  80003e:	89 45 ec             	mov    %eax,-0x14(%ebp)

	// Fork several environments
	for (i = 0; i < 20; i++)
  800041:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  800048:	eb 0f                	jmp    800059 <umain+0x26>
		if (fork() == 0)
  80004a:	e8 a8 14 00 00       	call   8014f7 <fork>
  80004f:	85 c0                	test   %eax,%eax
  800051:	75 02                	jne    800055 <umain+0x22>
			break;
  800053:	eb 0a                	jmp    80005f <umain+0x2c>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  800055:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  800059:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
  80005d:	7e eb                	jle    80004a <umain+0x17>
		if (fork() == 0)
			break;
	if (i == 20) {
  80005f:	83 7d f4 14          	cmpl   $0x14,-0xc(%ebp)
  800063:	75 0a                	jne    80006f <umain+0x3c>
		sys_yield();
  800065:	e8 e8 0f 00 00       	call   801052 <sys_yield>
		return;
  80006a:	e9 b2 00 00 00       	jmp    800121 <umain+0xee>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006f:	eb 02                	jmp    800073 <umain+0x40>
		asm volatile("pause");
  800071:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800073:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800076:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007b:	c1 e0 02             	shl    $0x2,%eax
  80007e:	89 c2                	mov    %eax,%edx
  800080:	c1 e2 05             	shl    $0x5,%edx
  800083:	29 c2                	sub    %eax,%edx
  800085:	8d 82 54 00 c0 ee    	lea    -0x113fffac(%edx),%eax
  80008b:	8b 00                	mov    (%eax),%eax
  80008d:	85 c0                	test   %eax,%eax
  80008f:	75 e0                	jne    800071 <umain+0x3e>
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  800091:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  800098:	eb 2c                	jmp    8000c6 <umain+0x93>
		sys_yield();
  80009a:	e8 b3 0f 00 00       	call   801052 <sys_yield>
		for (j = 0; j < 10000; j++)
  80009f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8000a6:	eb 11                	jmp    8000b9 <umain+0x86>
			counter++;
  8000a8:	a1 04 20 80 00       	mov    0x802004,%eax
  8000ad:	83 c0 01             	add    $0x1,%eax
  8000b0:	a3 04 20 80 00       	mov    %eax,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000b5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  8000b9:	81 7d f0 0f 27 00 00 	cmpl   $0x270f,-0x10(%ebp)
  8000c0:	7e e6                	jle    8000a8 <umain+0x75>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  8000c6:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
  8000ca:	7e ce                	jle    80009a <umain+0x67>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000cc:	a1 04 20 80 00       	mov    0x802004,%eax
  8000d1:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000d6:	74 25                	je     8000fd <umain+0xca>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000d8:	a1 04 20 80 00       	mov    0x802004,%eax
  8000dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000e1:	c7 44 24 08 e0 19 80 	movl   $0x8019e0,0x8(%esp)
  8000e8:	00 
  8000e9:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000f0:	00 
  8000f1:	c7 04 24 08 1a 80 00 	movl   $0x801a08,(%esp)
  8000f8:	e8 88 00 00 00       	call   800185 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000fd:	a1 08 20 80 00       	mov    0x802008,%eax
  800102:	8b 50 5c             	mov    0x5c(%eax),%edx
  800105:	a1 08 20 80 00       	mov    0x802008,%eax
  80010a:	8b 40 48             	mov    0x48(%eax),%eax
  80010d:	89 54 24 08          	mov    %edx,0x8(%esp)
  800111:	89 44 24 04          	mov    %eax,0x4(%esp)
  800115:	c7 04 24 1b 1a 80 00 	movl   $0x801a1b,(%esp)
  80011c:	e8 7f 01 00 00       	call   8002a0 <cprintf>

}
  800121:	c9                   	leave  
  800122:	c3                   	ret    

00800123 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800129:	e8 e0 0e 00 00       	call   80100e <sys_getenvid>
  80012e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800133:	c1 e0 02             	shl    $0x2,%eax
  800136:	89 c2                	mov    %eax,%edx
  800138:	c1 e2 05             	shl    $0x5,%edx
  80013b:	29 c2                	sub    %eax,%edx
  80013d:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  800143:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800148:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80014c:	7e 0a                	jle    800158 <libmain+0x35>
		binaryname = argv[0];
  80014e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800151:	8b 00                	mov    (%eax),%eax
  800153:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800158:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015f:	8b 45 08             	mov    0x8(%ebp),%eax
  800162:	89 04 24             	mov    %eax,(%esp)
  800165:	e8 c9 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80016a:	e8 02 00 00 00       	call   800171 <exit>
}
  80016f:	c9                   	leave  
  800170:	c3                   	ret    

00800171 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800177:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80017e:	e8 48 0e 00 00       	call   800fcb <sys_env_destroy>
}
  800183:	c9                   	leave  
  800184:	c3                   	ret    

00800185 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	53                   	push   %ebx
  800189:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80018c:	8d 45 14             	lea    0x14(%ebp),%eax
  80018f:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800192:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800198:	e8 71 0e 00 00       	call   80100e <sys_getenvid>
  80019d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001ab:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b3:	c7 04 24 44 1a 80 00 	movl   $0x801a44,(%esp)
  8001ba:	e8 e1 00 00 00       	call   8002a0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c9:	89 04 24             	mov    %eax,(%esp)
  8001cc:	e8 6b 00 00 00       	call   80023c <vcprintf>
	cprintf("\n");
  8001d1:	c7 04 24 67 1a 80 00 	movl   $0x801a67,(%esp)
  8001d8:	e8 c3 00 00 00       	call   8002a0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001dd:	cc                   	int3   
  8001de:	eb fd                	jmp    8001dd <_panic+0x58>

008001e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8001e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e9:	8b 00                	mov    (%eax),%eax
  8001eb:	8d 48 01             	lea    0x1(%eax),%ecx
  8001ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f1:	89 0a                	mov    %ecx,(%edx)
  8001f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f6:	89 d1                	mov    %edx,%ecx
  8001f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fb:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8001ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800202:	8b 00                	mov    (%eax),%eax
  800204:	3d ff 00 00 00       	cmp    $0xff,%eax
  800209:	75 20                	jne    80022b <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  80020b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020e:	8b 00                	mov    (%eax),%eax
  800210:	8b 55 0c             	mov    0xc(%ebp),%edx
  800213:	83 c2 08             	add    $0x8,%edx
  800216:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021a:	89 14 24             	mov    %edx,(%esp)
  80021d:	e8 23 0d 00 00       	call   800f45 <sys_cputs>
		b->idx = 0;
  800222:	8b 45 0c             	mov    0xc(%ebp),%eax
  800225:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80022b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022e:	8b 40 04             	mov    0x4(%eax),%eax
  800231:	8d 50 01             	lea    0x1(%eax),%edx
  800234:	8b 45 0c             	mov    0xc(%ebp),%eax
  800237:	89 50 04             	mov    %edx,0x4(%eax)
}
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800245:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024c:	00 00 00 
	b.cnt = 0;
  80024f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800256:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800259:	8b 45 0c             	mov    0xc(%ebp),%eax
  80025c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800260:	8b 45 08             	mov    0x8(%ebp),%eax
  800263:	89 44 24 08          	mov    %eax,0x8(%esp)
  800267:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80026d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800271:	c7 04 24 e0 01 80 00 	movl   $0x8001e0,(%esp)
  800278:	e8 bd 01 00 00       	call   80043a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80027d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800283:	89 44 24 04          	mov    %eax,0x4(%esp)
  800287:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80028d:	83 c0 08             	add    $0x8,%eax
  800290:	89 04 24             	mov    %eax,(%esp)
  800293:	e8 ad 0c 00 00       	call   800f45 <sys_cputs>

	return b.cnt;
  800298:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a6:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8002ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b6:	89 04 24             	mov    %eax,(%esp)
  8002b9:	e8 7e ff ff ff       	call   80023c <vcprintf>
  8002be:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8002c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8002c4:	c9                   	leave  
  8002c5:	c3                   	ret    

008002c6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	53                   	push   %ebx
  8002ca:	83 ec 34             	sub    $0x34,%esp
  8002cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8002d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002d9:	8b 45 18             	mov    0x18(%ebp),%eax
  8002dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e1:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002e4:	77 72                	ja     800358 <printnum+0x92>
  8002e6:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002e9:	72 05                	jb     8002f0 <printnum+0x2a>
  8002eb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8002ee:	77 68                	ja     800358 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f0:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8002f3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002f6:	8b 45 18             	mov    0x18(%ebp),%eax
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800302:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800306:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800309:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80030c:	89 04 24             	mov    %eax,(%esp)
  80030f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800313:	e8 38 14 00 00       	call   801750 <__udivdi3>
  800318:	8b 4d 20             	mov    0x20(%ebp),%ecx
  80031b:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  80031f:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800323:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800326:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80032a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80032e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800332:	8b 45 0c             	mov    0xc(%ebp),%eax
  800335:	89 44 24 04          	mov    %eax,0x4(%esp)
  800339:	8b 45 08             	mov    0x8(%ebp),%eax
  80033c:	89 04 24             	mov    %eax,(%esp)
  80033f:	e8 82 ff ff ff       	call   8002c6 <printnum>
  800344:	eb 1c                	jmp    800362 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800346:	8b 45 0c             	mov    0xc(%ebp),%eax
  800349:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034d:	8b 45 20             	mov    0x20(%ebp),%eax
  800350:	89 04 24             	mov    %eax,(%esp)
  800353:	8b 45 08             	mov    0x8(%ebp),%eax
  800356:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800358:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  80035c:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800360:	7f e4                	jg     800346 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800362:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800365:	bb 00 00 00 00       	mov    $0x0,%ebx
  80036a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80036d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800370:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800374:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800378:	89 04 24             	mov    %eax,(%esp)
  80037b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80037f:	e8 fc 14 00 00       	call   801880 <__umoddi3>
  800384:	05 48 1b 80 00       	add    $0x801b48,%eax
  800389:	0f b6 00             	movzbl (%eax),%eax
  80038c:	0f be c0             	movsbl %al,%eax
  80038f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800392:	89 54 24 04          	mov    %edx,0x4(%esp)
  800396:	89 04 24             	mov    %eax,(%esp)
  800399:	8b 45 08             	mov    0x8(%ebp),%eax
  80039c:	ff d0                	call   *%eax
}
  80039e:	83 c4 34             	add    $0x34,%esp
  8003a1:	5b                   	pop    %ebx
  8003a2:	5d                   	pop    %ebp
  8003a3:	c3                   	ret    

008003a4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a7:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003ab:	7e 14                	jle    8003c1 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8003ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b0:	8b 00                	mov    (%eax),%eax
  8003b2:	8d 48 08             	lea    0x8(%eax),%ecx
  8003b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b8:	89 0a                	mov    %ecx,(%edx)
  8003ba:	8b 50 04             	mov    0x4(%eax),%edx
  8003bd:	8b 00                	mov    (%eax),%eax
  8003bf:	eb 30                	jmp    8003f1 <getuint+0x4d>
	else if (lflag)
  8003c1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003c5:	74 16                	je     8003dd <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8003c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ca:	8b 00                	mov    (%eax),%eax
  8003cc:	8d 48 04             	lea    0x4(%eax),%ecx
  8003cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d2:	89 0a                	mov    %ecx,(%edx)
  8003d4:	8b 00                	mov    (%eax),%eax
  8003d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003db:	eb 14                	jmp    8003f1 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8003dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e0:	8b 00                	mov    (%eax),%eax
  8003e2:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e8:	89 0a                	mov    %ecx,(%edx)
  8003ea:	8b 00                	mov    (%eax),%eax
  8003ec:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003f1:	5d                   	pop    %ebp
  8003f2:	c3                   	ret    

008003f3 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003f3:	55                   	push   %ebp
  8003f4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003f6:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003fa:	7e 14                	jle    800410 <getint+0x1d>
		return va_arg(*ap, long long);
  8003fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ff:	8b 00                	mov    (%eax),%eax
  800401:	8d 48 08             	lea    0x8(%eax),%ecx
  800404:	8b 55 08             	mov    0x8(%ebp),%edx
  800407:	89 0a                	mov    %ecx,(%edx)
  800409:	8b 50 04             	mov    0x4(%eax),%edx
  80040c:	8b 00                	mov    (%eax),%eax
  80040e:	eb 28                	jmp    800438 <getint+0x45>
	else if (lflag)
  800410:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800414:	74 12                	je     800428 <getint+0x35>
		return va_arg(*ap, long);
  800416:	8b 45 08             	mov    0x8(%ebp),%eax
  800419:	8b 00                	mov    (%eax),%eax
  80041b:	8d 48 04             	lea    0x4(%eax),%ecx
  80041e:	8b 55 08             	mov    0x8(%ebp),%edx
  800421:	89 0a                	mov    %ecx,(%edx)
  800423:	8b 00                	mov    (%eax),%eax
  800425:	99                   	cltd   
  800426:	eb 10                	jmp    800438 <getint+0x45>
	else
		return va_arg(*ap, int);
  800428:	8b 45 08             	mov    0x8(%ebp),%eax
  80042b:	8b 00                	mov    (%eax),%eax
  80042d:	8d 48 04             	lea    0x4(%eax),%ecx
  800430:	8b 55 08             	mov    0x8(%ebp),%edx
  800433:	89 0a                	mov    %ecx,(%edx)
  800435:	8b 00                	mov    (%eax),%eax
  800437:	99                   	cltd   
}
  800438:	5d                   	pop    %ebp
  800439:	c3                   	ret    

0080043a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80043a:	55                   	push   %ebp
  80043b:	89 e5                	mov    %esp,%ebp
  80043d:	56                   	push   %esi
  80043e:	53                   	push   %ebx
  80043f:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800442:	eb 18                	jmp    80045c <vprintfmt+0x22>
			if (ch == '\0')
  800444:	85 db                	test   %ebx,%ebx
  800446:	75 05                	jne    80044d <vprintfmt+0x13>
				return;
  800448:	e9 05 04 00 00       	jmp    800852 <vprintfmt+0x418>
			putch(ch, putdat);
  80044d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800450:	89 44 24 04          	mov    %eax,0x4(%esp)
  800454:	89 1c 24             	mov    %ebx,(%esp)
  800457:	8b 45 08             	mov    0x8(%ebp),%eax
  80045a:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80045c:	8b 45 10             	mov    0x10(%ebp),%eax
  80045f:	8d 50 01             	lea    0x1(%eax),%edx
  800462:	89 55 10             	mov    %edx,0x10(%ebp)
  800465:	0f b6 00             	movzbl (%eax),%eax
  800468:	0f b6 d8             	movzbl %al,%ebx
  80046b:	83 fb 25             	cmp    $0x25,%ebx
  80046e:	75 d4                	jne    800444 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800470:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800474:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80047b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800482:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800489:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800490:	8b 45 10             	mov    0x10(%ebp),%eax
  800493:	8d 50 01             	lea    0x1(%eax),%edx
  800496:	89 55 10             	mov    %edx,0x10(%ebp)
  800499:	0f b6 00             	movzbl (%eax),%eax
  80049c:	0f b6 d8             	movzbl %al,%ebx
  80049f:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8004a2:	83 f8 55             	cmp    $0x55,%eax
  8004a5:	0f 87 76 03 00 00    	ja     800821 <vprintfmt+0x3e7>
  8004ab:	8b 04 85 6c 1b 80 00 	mov    0x801b6c(,%eax,4),%eax
  8004b2:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8004b4:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8004b8:	eb d6                	jmp    800490 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004ba:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8004be:	eb d0                	jmp    800490 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8004c7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004ca:	89 d0                	mov    %edx,%eax
  8004cc:	c1 e0 02             	shl    $0x2,%eax
  8004cf:	01 d0                	add    %edx,%eax
  8004d1:	01 c0                	add    %eax,%eax
  8004d3:	01 d8                	add    %ebx,%eax
  8004d5:	83 e8 30             	sub    $0x30,%eax
  8004d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8004db:	8b 45 10             	mov    0x10(%ebp),%eax
  8004de:	0f b6 00             	movzbl (%eax),%eax
  8004e1:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8004e4:	83 fb 2f             	cmp    $0x2f,%ebx
  8004e7:	7e 0b                	jle    8004f4 <vprintfmt+0xba>
  8004e9:	83 fb 39             	cmp    $0x39,%ebx
  8004ec:	7f 06                	jg     8004f4 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ee:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f2:	eb d3                	jmp    8004c7 <vprintfmt+0x8d>
			goto process_precision;
  8004f4:	eb 33                	jmp    800529 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8004f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f9:	8d 50 04             	lea    0x4(%eax),%edx
  8004fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ff:	8b 00                	mov    (%eax),%eax
  800501:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800504:	eb 23                	jmp    800529 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800506:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80050a:	79 0c                	jns    800518 <vprintfmt+0xde>
				width = 0;
  80050c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800513:	e9 78 ff ff ff       	jmp    800490 <vprintfmt+0x56>
  800518:	e9 73 ff ff ff       	jmp    800490 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  80051d:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800524:	e9 67 ff ff ff       	jmp    800490 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800529:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80052d:	79 12                	jns    800541 <vprintfmt+0x107>
				width = precision, precision = -1;
  80052f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800532:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800535:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80053c:	e9 4f ff ff ff       	jmp    800490 <vprintfmt+0x56>
  800541:	e9 4a ff ff ff       	jmp    800490 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800546:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80054a:	e9 41 ff ff ff       	jmp    800490 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 50 04             	lea    0x4(%eax),%edx
  800555:	89 55 14             	mov    %edx,0x14(%ebp)
  800558:	8b 00                	mov    (%eax),%eax
  80055a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80055d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800561:	89 04 24             	mov    %eax,(%esp)
  800564:	8b 45 08             	mov    0x8(%ebp),%eax
  800567:	ff d0                	call   *%eax
			break;
  800569:	e9 de 02 00 00       	jmp    80084c <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80056e:	8b 45 14             	mov    0x14(%ebp),%eax
  800571:	8d 50 04             	lea    0x4(%eax),%edx
  800574:	89 55 14             	mov    %edx,0x14(%ebp)
  800577:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800579:	85 db                	test   %ebx,%ebx
  80057b:	79 02                	jns    80057f <vprintfmt+0x145>
				err = -err;
  80057d:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80057f:	83 fb 09             	cmp    $0x9,%ebx
  800582:	7f 0b                	jg     80058f <vprintfmt+0x155>
  800584:	8b 34 9d 20 1b 80 00 	mov    0x801b20(,%ebx,4),%esi
  80058b:	85 f6                	test   %esi,%esi
  80058d:	75 23                	jne    8005b2 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  80058f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800593:	c7 44 24 08 59 1b 80 	movl   $0x801b59,0x8(%esp)
  80059a:	00 
  80059b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a5:	89 04 24             	mov    %eax,(%esp)
  8005a8:	e8 ac 02 00 00       	call   800859 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8005ad:	e9 9a 02 00 00       	jmp    80084c <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005b2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005b6:	c7 44 24 08 62 1b 80 	movl   $0x801b62,0x8(%esp)
  8005bd:	00 
  8005be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c8:	89 04 24             	mov    %eax,(%esp)
  8005cb:	e8 89 02 00 00       	call   800859 <printfmt>
			break;
  8005d0:	e9 77 02 00 00       	jmp    80084c <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8d 50 04             	lea    0x4(%eax),%edx
  8005db:	89 55 14             	mov    %edx,0x14(%ebp)
  8005de:	8b 30                	mov    (%eax),%esi
  8005e0:	85 f6                	test   %esi,%esi
  8005e2:	75 05                	jne    8005e9 <vprintfmt+0x1af>
				p = "(null)";
  8005e4:	be 65 1b 80 00       	mov    $0x801b65,%esi
			if (width > 0 && padc != '-')
  8005e9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ed:	7e 37                	jle    800626 <vprintfmt+0x1ec>
  8005ef:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8005f3:	74 31                	je     800626 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fc:	89 34 24             	mov    %esi,(%esp)
  8005ff:	e8 72 03 00 00       	call   800976 <strnlen>
  800604:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800607:	eb 17                	jmp    800620 <vprintfmt+0x1e6>
					putch(padc, putdat);
  800609:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80060d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800610:	89 54 24 04          	mov    %edx,0x4(%esp)
  800614:	89 04 24             	mov    %eax,(%esp)
  800617:	8b 45 08             	mov    0x8(%ebp),%eax
  80061a:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80061c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800620:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800624:	7f e3                	jg     800609 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800626:	eb 38                	jmp    800660 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800628:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062c:	74 1f                	je     80064d <vprintfmt+0x213>
  80062e:	83 fb 1f             	cmp    $0x1f,%ebx
  800631:	7e 05                	jle    800638 <vprintfmt+0x1fe>
  800633:	83 fb 7e             	cmp    $0x7e,%ebx
  800636:	7e 15                	jle    80064d <vprintfmt+0x213>
					putch('?', putdat);
  800638:	8b 45 0c             	mov    0xc(%ebp),%eax
  80063b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800646:	8b 45 08             	mov    0x8(%ebp),%eax
  800649:	ff d0                	call   *%eax
  80064b:	eb 0f                	jmp    80065c <vprintfmt+0x222>
				else
					putch(ch, putdat);
  80064d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800650:	89 44 24 04          	mov    %eax,0x4(%esp)
  800654:	89 1c 24             	mov    %ebx,(%esp)
  800657:	8b 45 08             	mov    0x8(%ebp),%eax
  80065a:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800660:	89 f0                	mov    %esi,%eax
  800662:	8d 70 01             	lea    0x1(%eax),%esi
  800665:	0f b6 00             	movzbl (%eax),%eax
  800668:	0f be d8             	movsbl %al,%ebx
  80066b:	85 db                	test   %ebx,%ebx
  80066d:	74 10                	je     80067f <vprintfmt+0x245>
  80066f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800673:	78 b3                	js     800628 <vprintfmt+0x1ee>
  800675:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800679:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80067d:	79 a9                	jns    800628 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80067f:	eb 17                	jmp    800698 <vprintfmt+0x25e>
				putch(' ', putdat);
  800681:	8b 45 0c             	mov    0xc(%ebp),%eax
  800684:	89 44 24 04          	mov    %eax,0x4(%esp)
  800688:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80068f:	8b 45 08             	mov    0x8(%ebp),%eax
  800692:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800694:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800698:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80069c:	7f e3                	jg     800681 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  80069e:	e9 a9 01 00 00       	jmp    80084c <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ad:	89 04 24             	mov    %eax,(%esp)
  8006b0:	e8 3e fd ff ff       	call   8003f3 <getint>
  8006b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006b8:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8006bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006c1:	85 d2                	test   %edx,%edx
  8006c3:	79 26                	jns    8006eb <vprintfmt+0x2b1>
				putch('-', putdat);
  8006c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d6:	ff d0                	call   *%eax
				num = -(long long) num;
  8006d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006de:	f7 d8                	neg    %eax
  8006e0:	83 d2 00             	adc    $0x0,%edx
  8006e3:	f7 da                	neg    %edx
  8006e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006e8:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8006eb:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006f2:	e9 e1 00 00 00       	jmp    8007d8 <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800701:	89 04 24             	mov    %eax,(%esp)
  800704:	e8 9b fc ff ff       	call   8003a4 <getuint>
  800709:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80070c:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  80070f:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800716:	e9 bd 00 00 00       	jmp    8007d8 <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  80071b:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  800722:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800725:	89 44 24 04          	mov    %eax,0x4(%esp)
  800729:	8d 45 14             	lea    0x14(%ebp),%eax
  80072c:	89 04 24             	mov    %eax,(%esp)
  80072f:	e8 70 fc ff ff       	call   8003a4 <getuint>
  800734:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800737:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  80073a:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  80073e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800741:	89 54 24 18          	mov    %edx,0x18(%esp)
  800745:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800748:	89 54 24 14          	mov    %edx,0x14(%esp)
  80074c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800750:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800753:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800756:	89 44 24 08          	mov    %eax,0x8(%esp)
  80075a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80075e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800761:	89 44 24 04          	mov    %eax,0x4(%esp)
  800765:	8b 45 08             	mov    0x8(%ebp),%eax
  800768:	89 04 24             	mov    %eax,(%esp)
  80076b:	e8 56 fb ff ff       	call   8002c6 <printnum>
			break;
  800770:	e9 d7 00 00 00       	jmp    80084c <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  800775:	8b 45 0c             	mov    0xc(%ebp),%eax
  800778:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800783:	8b 45 08             	mov    0x8(%ebp),%eax
  800786:	ff d0                	call   *%eax
			putch('x', putdat);
  800788:	8b 45 0c             	mov    0xc(%ebp),%eax
  80078b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800796:	8b 45 08             	mov    0x8(%ebp),%eax
  800799:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80079b:	8b 45 14             	mov    0x14(%ebp),%eax
  80079e:	8d 50 04             	lea    0x4(%eax),%edx
  8007a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a4:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007b0:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8007b7:	eb 1f                	jmp    8007d8 <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8007bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c0:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c3:	89 04 24             	mov    %eax,(%esp)
  8007c6:	e8 d9 fb ff ff       	call   8003a4 <getuint>
  8007cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007ce:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8007d1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007d8:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8007dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007df:	89 54 24 18          	mov    %edx,0x18(%esp)
  8007e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007e6:	89 54 24 14          	mov    %edx,0x14(%esp)
  8007ea:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	89 04 24             	mov    %eax,(%esp)
  800809:	e8 b8 fa ff ff       	call   8002c6 <printnum>
			break;
  80080e:	eb 3c                	jmp    80084c <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800810:	8b 45 0c             	mov    0xc(%ebp),%eax
  800813:	89 44 24 04          	mov    %eax,0x4(%esp)
  800817:	89 1c 24             	mov    %ebx,(%esp)
  80081a:	8b 45 08             	mov    0x8(%ebp),%eax
  80081d:	ff d0                	call   *%eax
			break;
  80081f:	eb 2b                	jmp    80084c <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800821:	8b 45 0c             	mov    0xc(%ebp),%eax
  800824:	89 44 24 04          	mov    %eax,0x4(%esp)
  800828:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80082f:	8b 45 08             	mov    0x8(%ebp),%eax
  800832:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800834:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800838:	eb 04                	jmp    80083e <vprintfmt+0x404>
  80083a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80083e:	8b 45 10             	mov    0x10(%ebp),%eax
  800841:	83 e8 01             	sub    $0x1,%eax
  800844:	0f b6 00             	movzbl (%eax),%eax
  800847:	3c 25                	cmp    $0x25,%al
  800849:	75 ef                	jne    80083a <vprintfmt+0x400>
				/* do nothing */;
			break;
  80084b:	90                   	nop
		}
	}
  80084c:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80084d:	e9 0a fc ff ff       	jmp    80045c <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800852:	83 c4 40             	add    $0x40,%esp
  800855:	5b                   	pop    %ebx
  800856:	5e                   	pop    %esi
  800857:	5d                   	pop    %ebp
  800858:	c3                   	ret    

00800859 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80085f:	8d 45 14             	lea    0x14(%ebp),%eax
  800862:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800865:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800868:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80086c:	8b 45 10             	mov    0x10(%ebp),%eax
  80086f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800873:	8b 45 0c             	mov    0xc(%ebp),%eax
  800876:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087a:	8b 45 08             	mov    0x8(%ebp),%eax
  80087d:	89 04 24             	mov    %eax,(%esp)
  800880:	e8 b5 fb ff ff       	call   80043a <vprintfmt>
	va_end(ap);
}
  800885:	c9                   	leave  
  800886:	c3                   	ret    

00800887 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  80088a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088d:	8b 40 08             	mov    0x8(%eax),%eax
  800890:	8d 50 01             	lea    0x1(%eax),%edx
  800893:	8b 45 0c             	mov    0xc(%ebp),%eax
  800896:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800899:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089c:	8b 10                	mov    (%eax),%edx
  80089e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a1:	8b 40 04             	mov    0x4(%eax),%eax
  8008a4:	39 c2                	cmp    %eax,%edx
  8008a6:	73 12                	jae    8008ba <sprintputch+0x33>
		*b->buf++ = ch;
  8008a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ab:	8b 00                	mov    (%eax),%eax
  8008ad:	8d 48 01             	lea    0x1(%eax),%ecx
  8008b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b3:	89 0a                	mov    %ecx,(%edx)
  8008b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8008b8:	88 10                	mov    %dl,(%eax)
}
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cb:	8d 50 ff             	lea    -0x1(%eax),%edx
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	01 d0                	add    %edx,%eax
  8008d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008dd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8008e1:	74 06                	je     8008e9 <vsnprintf+0x2d>
  8008e3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008e7:	7f 07                	jg     8008f0 <vsnprintf+0x34>
		return -E_INVAL;
  8008e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ee:	eb 2a                	jmp    80091a <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8008fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008fe:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800901:	89 44 24 04          	mov    %eax,0x4(%esp)
  800905:	c7 04 24 87 08 80 00 	movl   $0x800887,(%esp)
  80090c:	e8 29 fb ff ff       	call   80043a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800911:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800914:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800917:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80091a:	c9                   	leave  
  80091b:	c3                   	ret    

0080091c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800922:	8d 45 14             	lea    0x14(%ebp),%eax
  800925:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800928:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80092b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80092f:	8b 45 10             	mov    0x10(%ebp),%eax
  800932:	89 44 24 08          	mov    %eax,0x8(%esp)
  800936:	8b 45 0c             	mov    0xc(%ebp),%eax
  800939:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	89 04 24             	mov    %eax,(%esp)
  800943:	e8 74 ff ff ff       	call   8008bc <vsnprintf>
  800948:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  80094b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80094e:	c9                   	leave  
  80094f:	c3                   	ret    

00800950 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800956:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80095d:	eb 08                	jmp    800967 <strlen+0x17>
		n++;
  80095f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800963:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	0f b6 00             	movzbl (%eax),%eax
  80096d:	84 c0                	test   %al,%al
  80096f:	75 ee                	jne    80095f <strlen+0xf>
		n++;
	return n;
  800971:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800974:	c9                   	leave  
  800975:	c3                   	ret    

00800976 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80097c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800983:	eb 0c                	jmp    800991 <strnlen+0x1b>
		n++;
  800985:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800989:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80098d:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800991:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800995:	74 0a                	je     8009a1 <strnlen+0x2b>
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	0f b6 00             	movzbl (%eax),%eax
  80099d:	84 c0                	test   %al,%al
  80099f:	75 e4                	jne    800985 <strnlen+0xf>
		n++;
	return n;
  8009a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009a4:	c9                   	leave  
  8009a5:	c3                   	ret    

008009a6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  8009b2:	90                   	nop
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b6:	8d 50 01             	lea    0x1(%eax),%edx
  8009b9:	89 55 08             	mov    %edx,0x8(%ebp)
  8009bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009c2:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009c5:	0f b6 12             	movzbl (%edx),%edx
  8009c8:	88 10                	mov    %dl,(%eax)
  8009ca:	0f b6 00             	movzbl (%eax),%eax
  8009cd:	84 c0                	test   %al,%al
  8009cf:	75 e2                	jne    8009b3 <strcpy+0xd>
		/* do nothing */;
	return ret;
  8009d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009d4:	c9                   	leave  
  8009d5:	c3                   	ret    

008009d6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	89 04 24             	mov    %eax,(%esp)
  8009e2:	e8 69 ff ff ff       	call   800950 <strlen>
  8009e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  8009ea:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	01 c2                	add    %eax,%edx
  8009f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f9:	89 14 24             	mov    %edx,(%esp)
  8009fc:	e8 a5 ff ff ff       	call   8009a6 <strcpy>
	return dst;
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a04:	c9                   	leave  
  800a05:	c3                   	ret    

00800a06 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800a12:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800a19:	eb 23                	jmp    800a3e <strncpy+0x38>
		*dst++ = *src;
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	8d 50 01             	lea    0x1(%eax),%edx
  800a21:	89 55 08             	mov    %edx,0x8(%ebp)
  800a24:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a27:	0f b6 12             	movzbl (%edx),%edx
  800a2a:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2f:	0f b6 00             	movzbl (%eax),%eax
  800a32:	84 c0                	test   %al,%al
  800a34:	74 04                	je     800a3a <strncpy+0x34>
			src++;
  800a36:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a3a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800a3e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a41:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a44:	72 d5                	jb     800a1b <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800a46:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800a49:	c9                   	leave  
  800a4a:	c3                   	ret    

00800a4b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
  800a54:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800a57:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a5b:	74 33                	je     800a90 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800a5d:	eb 17                	jmp    800a76 <strlcpy+0x2b>
			*dst++ = *src++;
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	8d 50 01             	lea    0x1(%eax),%edx
  800a65:	89 55 08             	mov    %edx,0x8(%ebp)
  800a68:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6b:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a6e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a71:	0f b6 12             	movzbl (%edx),%edx
  800a74:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a76:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a7a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a7e:	74 0a                	je     800a8a <strlcpy+0x3f>
  800a80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a83:	0f b6 00             	movzbl (%eax),%eax
  800a86:	84 c0                	test   %al,%al
  800a88:	75 d5                	jne    800a5f <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a90:	8b 55 08             	mov    0x8(%ebp),%edx
  800a93:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a96:	29 c2                	sub    %eax,%edx
  800a98:	89 d0                	mov    %edx,%eax
}
  800a9a:	c9                   	leave  
  800a9b:	c3                   	ret    

00800a9c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a9f:	eb 08                	jmp    800aa9 <strcmp+0xd>
		p++, q++;
  800aa1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800aa5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aac:	0f b6 00             	movzbl (%eax),%eax
  800aaf:	84 c0                	test   %al,%al
  800ab1:	74 10                	je     800ac3 <strcmp+0x27>
  800ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab6:	0f b6 10             	movzbl (%eax),%edx
  800ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abc:	0f b6 00             	movzbl (%eax),%eax
  800abf:	38 c2                	cmp    %al,%dl
  800ac1:	74 de                	je     800aa1 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac6:	0f b6 00             	movzbl (%eax),%eax
  800ac9:	0f b6 d0             	movzbl %al,%edx
  800acc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acf:	0f b6 00             	movzbl (%eax),%eax
  800ad2:	0f b6 c0             	movzbl %al,%eax
  800ad5:	29 c2                	sub    %eax,%edx
  800ad7:	89 d0                	mov    %edx,%eax
}
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800ade:	eb 0c                	jmp    800aec <strncmp+0x11>
		n--, p++, q++;
  800ae0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ae4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ae8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800af0:	74 1a                	je     800b0c <strncmp+0x31>
  800af2:	8b 45 08             	mov    0x8(%ebp),%eax
  800af5:	0f b6 00             	movzbl (%eax),%eax
  800af8:	84 c0                	test   %al,%al
  800afa:	74 10                	je     800b0c <strncmp+0x31>
  800afc:	8b 45 08             	mov    0x8(%ebp),%eax
  800aff:	0f b6 10             	movzbl (%eax),%edx
  800b02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b05:	0f b6 00             	movzbl (%eax),%eax
  800b08:	38 c2                	cmp    %al,%dl
  800b0a:	74 d4                	je     800ae0 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800b0c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b10:	75 07                	jne    800b19 <strncmp+0x3e>
		return 0;
  800b12:	b8 00 00 00 00       	mov    $0x0,%eax
  800b17:	eb 16                	jmp    800b2f <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b19:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1c:	0f b6 00             	movzbl (%eax),%eax
  800b1f:	0f b6 d0             	movzbl %al,%edx
  800b22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b25:	0f b6 00             	movzbl (%eax),%eax
  800b28:	0f b6 c0             	movzbl %al,%eax
  800b2b:	29 c2                	sub    %eax,%edx
  800b2d:	89 d0                	mov    %edx,%eax
}
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	83 ec 04             	sub    $0x4,%esp
  800b37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3a:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b3d:	eb 14                	jmp    800b53 <strchr+0x22>
		if (*s == c)
  800b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b42:	0f b6 00             	movzbl (%eax),%eax
  800b45:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b48:	75 05                	jne    800b4f <strchr+0x1e>
			return (char *) s;
  800b4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4d:	eb 13                	jmp    800b62 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b4f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b53:	8b 45 08             	mov    0x8(%ebp),%eax
  800b56:	0f b6 00             	movzbl (%eax),%eax
  800b59:	84 c0                	test   %al,%al
  800b5b:	75 e2                	jne    800b3f <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800b5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b62:	c9                   	leave  
  800b63:	c3                   	ret    

00800b64 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	83 ec 04             	sub    $0x4,%esp
  800b6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6d:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b70:	eb 11                	jmp    800b83 <strfind+0x1f>
		if (*s == c)
  800b72:	8b 45 08             	mov    0x8(%ebp),%eax
  800b75:	0f b6 00             	movzbl (%eax),%eax
  800b78:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b7b:	75 02                	jne    800b7f <strfind+0x1b>
			break;
  800b7d:	eb 0e                	jmp    800b8d <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b7f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b83:	8b 45 08             	mov    0x8(%ebp),%eax
  800b86:	0f b6 00             	movzbl (%eax),%eax
  800b89:	84 c0                	test   %al,%al
  800b8b:	75 e5                	jne    800b72 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800b8d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b90:	c9                   	leave  
  800b91:	c3                   	ret    

00800b92 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	57                   	push   %edi
	char *p;

	if (n == 0)
  800b96:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b9a:	75 05                	jne    800ba1 <memset+0xf>
		return v;
  800b9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9f:	eb 5c                	jmp    800bfd <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800ba1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba4:	83 e0 03             	and    $0x3,%eax
  800ba7:	85 c0                	test   %eax,%eax
  800ba9:	75 41                	jne    800bec <memset+0x5a>
  800bab:	8b 45 10             	mov    0x10(%ebp),%eax
  800bae:	83 e0 03             	and    $0x3,%eax
  800bb1:	85 c0                	test   %eax,%eax
  800bb3:	75 37                	jne    800bec <memset+0x5a>
		c &= 0xFF;
  800bb5:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbf:	c1 e0 18             	shl    $0x18,%eax
  800bc2:	89 c2                	mov    %eax,%edx
  800bc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc7:	c1 e0 10             	shl    $0x10,%eax
  800bca:	09 c2                	or     %eax,%edx
  800bcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bcf:	c1 e0 08             	shl    $0x8,%eax
  800bd2:	09 d0                	or     %edx,%eax
  800bd4:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bd7:	8b 45 10             	mov    0x10(%ebp),%eax
  800bda:	c1 e8 02             	shr    $0x2,%eax
  800bdd:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800be2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be5:	89 d7                	mov    %edx,%edi
  800be7:	fc                   	cld    
  800be8:	f3 ab                	rep stos %eax,%es:(%edi)
  800bea:	eb 0e                	jmp    800bfa <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bec:	8b 55 08             	mov    0x8(%ebp),%edx
  800bef:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bf5:	89 d7                	mov    %edx,%edi
  800bf7:	fc                   	cld    
  800bf8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800bfa:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800c09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c12:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800c15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c18:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800c1b:	73 6d                	jae    800c8a <memmove+0x8a>
  800c1d:	8b 45 10             	mov    0x10(%ebp),%eax
  800c20:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c23:	01 d0                	add    %edx,%eax
  800c25:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800c28:	76 60                	jbe    800c8a <memmove+0x8a>
		s += n;
  800c2a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c2d:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800c30:	8b 45 10             	mov    0x10(%ebp),%eax
  800c33:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c39:	83 e0 03             	and    $0x3,%eax
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	75 2f                	jne    800c6f <memmove+0x6f>
  800c40:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c43:	83 e0 03             	and    $0x3,%eax
  800c46:	85 c0                	test   %eax,%eax
  800c48:	75 25                	jne    800c6f <memmove+0x6f>
  800c4a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c4d:	83 e0 03             	and    $0x3,%eax
  800c50:	85 c0                	test   %eax,%eax
  800c52:	75 1b                	jne    800c6f <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c54:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c57:	83 e8 04             	sub    $0x4,%eax
  800c5a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c5d:	83 ea 04             	sub    $0x4,%edx
  800c60:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c63:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c66:	89 c7                	mov    %eax,%edi
  800c68:	89 d6                	mov    %edx,%esi
  800c6a:	fd                   	std    
  800c6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c6d:	eb 18                	jmp    800c87 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c72:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c78:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c7b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7e:	89 d7                	mov    %edx,%edi
  800c80:	89 de                	mov    %ebx,%esi
  800c82:	89 c1                	mov    %eax,%ecx
  800c84:	fd                   	std    
  800c85:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c87:	fc                   	cld    
  800c88:	eb 45                	jmp    800ccf <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c8d:	83 e0 03             	and    $0x3,%eax
  800c90:	85 c0                	test   %eax,%eax
  800c92:	75 2b                	jne    800cbf <memmove+0xbf>
  800c94:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c97:	83 e0 03             	and    $0x3,%eax
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	75 21                	jne    800cbf <memmove+0xbf>
  800c9e:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca1:	83 e0 03             	and    $0x3,%eax
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	75 17                	jne    800cbf <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ca8:	8b 45 10             	mov    0x10(%ebp),%eax
  800cab:	c1 e8 02             	shr    $0x2,%eax
  800cae:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cb0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cb3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800cb6:	89 c7                	mov    %eax,%edi
  800cb8:	89 d6                	mov    %edx,%esi
  800cba:	fc                   	cld    
  800cbb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cbd:	eb 10                	jmp    800ccf <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cc2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800cc5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800cc8:	89 c7                	mov    %eax,%edi
  800cca:	89 d6                	mov    %edx,%esi
  800ccc:	fc                   	cld    
  800ccd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800ccf:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cd2:	83 c4 10             	add    $0x10,%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ce0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ce7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cea:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cee:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf1:	89 04 24             	mov    %eax,(%esp)
  800cf4:	e8 07 ff ff ff       	call   800c00 <memmove>
}
  800cf9:	c9                   	leave  
  800cfa:	c3                   	ret    

00800cfb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800d01:	8b 45 08             	mov    0x8(%ebp),%eax
  800d04:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800d07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0a:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800d0d:	eb 30                	jmp    800d3f <memcmp+0x44>
		if (*s1 != *s2)
  800d0f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d12:	0f b6 10             	movzbl (%eax),%edx
  800d15:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d18:	0f b6 00             	movzbl (%eax),%eax
  800d1b:	38 c2                	cmp    %al,%dl
  800d1d:	74 18                	je     800d37 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800d1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d22:	0f b6 00             	movzbl (%eax),%eax
  800d25:	0f b6 d0             	movzbl %al,%edx
  800d28:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d2b:	0f b6 00             	movzbl (%eax),%eax
  800d2e:	0f b6 c0             	movzbl %al,%eax
  800d31:	29 c2                	sub    %eax,%edx
  800d33:	89 d0                	mov    %edx,%eax
  800d35:	eb 1a                	jmp    800d51 <memcmp+0x56>
		s1++, s2++;
  800d37:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d3b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d3f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d42:	8d 50 ff             	lea    -0x1(%eax),%edx
  800d45:	89 55 10             	mov    %edx,0x10(%ebp)
  800d48:	85 c0                	test   %eax,%eax
  800d4a:	75 c3                	jne    800d0f <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d51:	c9                   	leave  
  800d52:	c3                   	ret    

00800d53 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800d59:	8b 45 10             	mov    0x10(%ebp),%eax
  800d5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5f:	01 d0                	add    %edx,%eax
  800d61:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800d64:	eb 13                	jmp    800d79 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d66:	8b 45 08             	mov    0x8(%ebp),%eax
  800d69:	0f b6 10             	movzbl (%eax),%edx
  800d6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d6f:	38 c2                	cmp    %al,%dl
  800d71:	75 02                	jne    800d75 <memfind+0x22>
			break;
  800d73:	eb 0c                	jmp    800d81 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d75:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d79:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800d7f:	72 e5                	jb     800d66 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800d81:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d84:	c9                   	leave  
  800d85:	c3                   	ret    

00800d86 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800d8c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800d93:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d9a:	eb 04                	jmp    800da0 <strtol+0x1a>
		s++;
  800d9c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800da0:	8b 45 08             	mov    0x8(%ebp),%eax
  800da3:	0f b6 00             	movzbl (%eax),%eax
  800da6:	3c 20                	cmp    $0x20,%al
  800da8:	74 f2                	je     800d9c <strtol+0x16>
  800daa:	8b 45 08             	mov    0x8(%ebp),%eax
  800dad:	0f b6 00             	movzbl (%eax),%eax
  800db0:	3c 09                	cmp    $0x9,%al
  800db2:	74 e8                	je     800d9c <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800db4:	8b 45 08             	mov    0x8(%ebp),%eax
  800db7:	0f b6 00             	movzbl (%eax),%eax
  800dba:	3c 2b                	cmp    $0x2b,%al
  800dbc:	75 06                	jne    800dc4 <strtol+0x3e>
		s++;
  800dbe:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dc2:	eb 15                	jmp    800dd9 <strtol+0x53>
	else if (*s == '-')
  800dc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc7:	0f b6 00             	movzbl (%eax),%eax
  800dca:	3c 2d                	cmp    $0x2d,%al
  800dcc:	75 0b                	jne    800dd9 <strtol+0x53>
		s++, neg = 1;
  800dce:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dd2:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dd9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ddd:	74 06                	je     800de5 <strtol+0x5f>
  800ddf:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800de3:	75 24                	jne    800e09 <strtol+0x83>
  800de5:	8b 45 08             	mov    0x8(%ebp),%eax
  800de8:	0f b6 00             	movzbl (%eax),%eax
  800deb:	3c 30                	cmp    $0x30,%al
  800ded:	75 1a                	jne    800e09 <strtol+0x83>
  800def:	8b 45 08             	mov    0x8(%ebp),%eax
  800df2:	83 c0 01             	add    $0x1,%eax
  800df5:	0f b6 00             	movzbl (%eax),%eax
  800df8:	3c 78                	cmp    $0x78,%al
  800dfa:	75 0d                	jne    800e09 <strtol+0x83>
		s += 2, base = 16;
  800dfc:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800e00:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800e07:	eb 2a                	jmp    800e33 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800e09:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e0d:	75 17                	jne    800e26 <strtol+0xa0>
  800e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e12:	0f b6 00             	movzbl (%eax),%eax
  800e15:	3c 30                	cmp    $0x30,%al
  800e17:	75 0d                	jne    800e26 <strtol+0xa0>
		s++, base = 8;
  800e19:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e1d:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800e24:	eb 0d                	jmp    800e33 <strtol+0xad>
	else if (base == 0)
  800e26:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e2a:	75 07                	jne    800e33 <strtol+0xad>
		base = 10;
  800e2c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e33:	8b 45 08             	mov    0x8(%ebp),%eax
  800e36:	0f b6 00             	movzbl (%eax),%eax
  800e39:	3c 2f                	cmp    $0x2f,%al
  800e3b:	7e 1b                	jle    800e58 <strtol+0xd2>
  800e3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e40:	0f b6 00             	movzbl (%eax),%eax
  800e43:	3c 39                	cmp    $0x39,%al
  800e45:	7f 11                	jg     800e58 <strtol+0xd2>
			dig = *s - '0';
  800e47:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4a:	0f b6 00             	movzbl (%eax),%eax
  800e4d:	0f be c0             	movsbl %al,%eax
  800e50:	83 e8 30             	sub    $0x30,%eax
  800e53:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e56:	eb 48                	jmp    800ea0 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800e58:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5b:	0f b6 00             	movzbl (%eax),%eax
  800e5e:	3c 60                	cmp    $0x60,%al
  800e60:	7e 1b                	jle    800e7d <strtol+0xf7>
  800e62:	8b 45 08             	mov    0x8(%ebp),%eax
  800e65:	0f b6 00             	movzbl (%eax),%eax
  800e68:	3c 7a                	cmp    $0x7a,%al
  800e6a:	7f 11                	jg     800e7d <strtol+0xf7>
			dig = *s - 'a' + 10;
  800e6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6f:	0f b6 00             	movzbl (%eax),%eax
  800e72:	0f be c0             	movsbl %al,%eax
  800e75:	83 e8 57             	sub    $0x57,%eax
  800e78:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e7b:	eb 23                	jmp    800ea0 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800e7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e80:	0f b6 00             	movzbl (%eax),%eax
  800e83:	3c 40                	cmp    $0x40,%al
  800e85:	7e 3d                	jle    800ec4 <strtol+0x13e>
  800e87:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8a:	0f b6 00             	movzbl (%eax),%eax
  800e8d:	3c 5a                	cmp    $0x5a,%al
  800e8f:	7f 33                	jg     800ec4 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800e91:	8b 45 08             	mov    0x8(%ebp),%eax
  800e94:	0f b6 00             	movzbl (%eax),%eax
  800e97:	0f be c0             	movsbl %al,%eax
  800e9a:	83 e8 37             	sub    $0x37,%eax
  800e9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea3:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ea6:	7c 02                	jl     800eaa <strtol+0x124>
			break;
  800ea8:	eb 1a                	jmp    800ec4 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800eaa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800eae:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800eb1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800eb5:	89 c2                	mov    %eax,%edx
  800eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eba:	01 d0                	add    %edx,%eax
  800ebc:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800ebf:	e9 6f ff ff ff       	jmp    800e33 <strtol+0xad>

	if (endptr)
  800ec4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ec8:	74 08                	je     800ed2 <strtol+0x14c>
		*endptr = (char *) s;
  800eca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ecd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed0:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ed2:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800ed6:	74 07                	je     800edf <strtol+0x159>
  800ed8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800edb:	f7 d8                	neg    %eax
  800edd:	eb 03                	jmp    800ee2 <strtol+0x15c>
  800edf:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800ee2:	c9                   	leave  
  800ee3:	c3                   	ret    

00800ee4 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	57                   	push   %edi
  800ee8:	56                   	push   %esi
  800ee9:	53                   	push   %ebx
  800eea:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eed:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef0:	8b 55 10             	mov    0x10(%ebp),%edx
  800ef3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800ef6:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800ef9:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800efc:	8b 75 20             	mov    0x20(%ebp),%esi
  800eff:	cd 30                	int    $0x30
  800f01:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f04:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f08:	74 30                	je     800f3a <syscall+0x56>
  800f0a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f0e:	7e 2a                	jle    800f3a <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f13:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f17:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f1e:	c7 44 24 08 c4 1c 80 	movl   $0x801cc4,0x8(%esp)
  800f25:	00 
  800f26:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f2d:	00 
  800f2e:	c7 04 24 e1 1c 80 00 	movl   $0x801ce1,(%esp)
  800f35:	e8 4b f2 ff ff       	call   800185 <_panic>

	return ret;
  800f3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800f3d:	83 c4 3c             	add    $0x3c,%esp
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f55:	00 
  800f56:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f5d:	00 
  800f5e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f65:	00 
  800f66:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f69:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f6d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f71:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f78:	00 
  800f79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f80:	e8 5f ff ff ff       	call   800ee4 <syscall>
}
  800f85:	c9                   	leave  
  800f86:	c3                   	ret    

00800f87 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f8d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f94:	00 
  800f95:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f9c:	00 
  800f9d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fa4:	00 
  800fa5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fac:	00 
  800fad:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fb4:	00 
  800fb5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fbc:	00 
  800fbd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800fc4:	e8 1b ff ff ff       	call   800ee4 <syscall>
}
  800fc9:	c9                   	leave  
  800fca:	c3                   	ret    

00800fcb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800fd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd4:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fdb:	00 
  800fdc:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fe3:	00 
  800fe4:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800feb:	00 
  800fec:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ff3:	00 
  800ff4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ff8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fff:	00 
  801000:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801007:	e8 d8 fe ff ff       	call   800ee4 <syscall>
}
  80100c:	c9                   	leave  
  80100d:	c3                   	ret    

0080100e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80100e:	55                   	push   %ebp
  80100f:	89 e5                	mov    %esp,%ebp
  801011:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  801014:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80101b:	00 
  80101c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801023:	00 
  801024:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80102b:	00 
  80102c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801033:	00 
  801034:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80103b:	00 
  80103c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801043:	00 
  801044:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80104b:	e8 94 fe ff ff       	call   800ee4 <syscall>
}
  801050:	c9                   	leave  
  801051:	c3                   	ret    

00801052 <sys_yield>:

void
sys_yield(void)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801058:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80105f:	00 
  801060:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801067:	00 
  801068:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80106f:	00 
  801070:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801077:	00 
  801078:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80107f:	00 
  801080:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801087:	00 
  801088:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80108f:	e8 50 fe ff ff       	call   800ee4 <syscall>
}
  801094:	c9                   	leave  
  801095:	c3                   	ret    

00801096 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80109c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80109f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010ac:	00 
  8010ad:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010b4:	00 
  8010b5:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8010b9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010c8:	00 
  8010c9:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  8010d0:	e8 0f fe ff ff       	call   800ee4 <syscall>
}
  8010d5:	c9                   	leave  
  8010d6:	c3                   	ret    

008010d7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	56                   	push   %esi
  8010db:	53                   	push   %ebx
  8010dc:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8010df:	8b 75 18             	mov    0x18(%ebp),%esi
  8010e2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ee:	89 74 24 18          	mov    %esi,0x18(%esp)
  8010f2:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8010f6:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8010fa:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801102:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801109:	00 
  80110a:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  801111:	e8 ce fd ff ff       	call   800ee4 <syscall>
}
  801116:	83 c4 20             	add    $0x20,%esp
  801119:	5b                   	pop    %ebx
  80111a:	5e                   	pop    %esi
  80111b:	5d                   	pop    %ebp
  80111c:	c3                   	ret    

0080111d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
  801120:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801123:	8b 55 0c             	mov    0xc(%ebp),%edx
  801126:	8b 45 08             	mov    0x8(%ebp),%eax
  801129:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801130:	00 
  801131:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801138:	00 
  801139:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801140:	00 
  801141:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801145:	89 44 24 08          	mov    %eax,0x8(%esp)
  801149:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801150:	00 
  801151:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801158:	e8 87 fd ff ff       	call   800ee4 <syscall>
}
  80115d:	c9                   	leave  
  80115e:	c3                   	ret    

0080115f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801165:	8b 55 0c             	mov    0xc(%ebp),%edx
  801168:	8b 45 08             	mov    0x8(%ebp),%eax
  80116b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801172:	00 
  801173:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80117a:	00 
  80117b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801182:	00 
  801183:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801187:	89 44 24 08          	mov    %eax,0x8(%esp)
  80118b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801192:	00 
  801193:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  80119a:	e8 45 fd ff ff       	call   800ee4 <syscall>
}
  80119f:	c9                   	leave  
  8011a0:	c3                   	ret    

008011a1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
  8011a4:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8011a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ad:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011b4:	00 
  8011b5:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011bc:	00 
  8011bd:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011c4:	00 
  8011c5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011cd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011d4:	00 
  8011d5:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8011dc:	e8 03 fd ff ff       	call   800ee4 <syscall>
}
  8011e1:	c9                   	leave  
  8011e2:	c3                   	ret    

008011e3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8011e9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8011ec:	8b 55 10             	mov    0x10(%ebp),%edx
  8011ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f2:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011f9:	00 
  8011fa:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8011fe:	89 54 24 10          	mov    %edx,0x10(%esp)
  801202:	8b 55 0c             	mov    0xc(%ebp),%edx
  801205:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801209:	89 44 24 08          	mov    %eax,0x8(%esp)
  80120d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801214:	00 
  801215:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  80121c:	e8 c3 fc ff ff       	call   800ee4 <syscall>
}
  801221:	c9                   	leave  
  801222:	c3                   	ret    

00801223 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801223:	55                   	push   %ebp
  801224:	89 e5                	mov    %esp,%ebp
  801226:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801229:	8b 45 08             	mov    0x8(%ebp),%eax
  80122c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801233:	00 
  801234:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80123b:	00 
  80123c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801243:	00 
  801244:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80124b:	00 
  80124c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801250:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801257:	00 
  801258:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80125f:	e8 80 fc ff ff       	call   800ee4 <syscall>
}
  801264:	c9                   	leave  
  801265:	c3                   	ret    

00801266 <pgfault>:
// map in our own private writable copy.
//

static void
pgfault(struct UTrapframe *utf)
{
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  80126c:	8b 45 08             	mov    0x8(%ebp),%eax
  80126f:	8b 00                	mov    (%eax),%eax
  801271:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  801274:	8b 45 08             	mov    0x8(%ebp),%eax
  801277:	8b 40 04             	mov    0x4(%eax),%eax
  80127a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	uint32_t t = PGNUM(addr);
  80127d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801280:	c1 e8 0c             	shr    $0xc,%eax
  801283:	89 45 ec             	mov    %eax,-0x14(%ebp)
	pte_t pte = uvpt[t];
  801286:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801289:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801290:	89 45 e8             	mov    %eax,-0x18(%ebp)
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  801293:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801296:	83 e0 02             	and    $0x2,%eax
  801299:	85 c0                	test   %eax,%eax
  80129b:	74 0c                	je     8012a9 <pgfault+0x43>
  80129d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8012a0:	25 00 08 00 00       	and    $0x800,%eax
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	75 1c                	jne    8012c5 <pgfault+0x5f>
		panic("permission denied in copy on write pgfault handler\n");
  8012a9:	c7 44 24 08 f0 1c 80 	movl   $0x801cf0,0x8(%esp)
  8012b0:	00 
  8012b1:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8012b8:	00 
  8012b9:	c7 04 24 24 1d 80 00 	movl   $0x801d24,(%esp)
  8012c0:	e8 c0 ee ff ff       	call   800185 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	r = sys_page_alloc(0,PFTEMP,PTE_P|PTE_U|PTE_W);
  8012c5:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012cc:	00 
  8012cd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012d4:	00 
  8012d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012dc:	e8 b5 fd ff ff       	call   801096 <sys_page_alloc>
  8012e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if(r < 0)
  8012e4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012e8:	79 1c                	jns    801306 <pgfault+0xa0>
	{
		panic("page cant be allocated\n");
  8012ea:	c7 44 24 08 2f 1d 80 	movl   $0x801d2f,0x8(%esp)
  8012f1:	00 
  8012f2:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8012f9:	00 
  8012fa:	c7 04 24 24 1d 80 00 	movl   $0x801d24,(%esp)
  801301:	e8 7f ee ff ff       	call   800185 <_panic>
	}
	memmove(PFTEMP, ROUNDDOWN(addr,PGSIZE), PGSIZE);
  801306:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801309:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80130c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80130f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801314:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80131b:	00 
  80131c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801320:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801327:	e8 d4 f8 ff ff       	call   800c00 <memmove>
	int r1 = sys_page_map(0,PFTEMP,0,ROUNDDOWN(addr,PGSIZE),PTE_W|PTE_U|PTE_P);
  80132c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801332:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801335:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80133a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801341:	00 
  801342:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801346:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80134d:	00 
  80134e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801355:	00 
  801356:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80135d:	e8 75 fd ff ff       	call   8010d7 <sys_page_map>
  801362:	89 45 d8             	mov    %eax,-0x28(%ebp)
	if(r1 < 0)
  801365:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801369:	79 1c                	jns    801387 <pgfault+0x121>
	{
		panic("page cant be mapped\n");
  80136b:	c7 44 24 08 47 1d 80 	movl   $0x801d47,0x8(%esp)
  801372:	00 
  801373:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  80137a:	00 
  80137b:	c7 04 24 24 1d 80 00 	movl   $0x801d24,(%esp)
  801382:	e8 fe ed ff ff       	call   800185 <_panic>
	}	

	// panic("pgfault not implemented");
}
  801387:	c9                   	leave  
  801388:	c3                   	ret    

00801389 <duppage>:
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
static int
duppage(envid_t envid, unsigned pn)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	83 ec 48             	sub    $0x48,%esp
	int r;
	
	// LAB 4: Your code here.
	uint32_t t = uvpt[pn];
  80138f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801392:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801399:	89 45 f4             	mov    %eax,-0xc(%ebp)
	void *va_pn = (void *)(pn*PGSIZE);
  80139c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80139f:	c1 e0 0c             	shl    $0xc,%eax
  8013a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if((t && PTE_W) || (t && PTE_COW))
  8013a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8013a9:	75 0a                	jne    8013b5 <duppage+0x2c>
  8013ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8013af:	0f 84 ed 00 00 00    	je     8014a2 <duppage+0x119>
	{
		r = sys_page_map(0,va_pn,envid,va_pn,PTE_P|PTE_U|PTE_COW);
  8013b5:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8013bc:	00 
  8013bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013d9:	e8 f9 fc ff ff       	call   8010d7 <sys_page_map>
  8013de:	89 45 e8             	mov    %eax,-0x18(%ebp)
		if(r < 0)
  8013e1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8013e5:	79 1c                	jns    801403 <duppage+0x7a>
		{
			panic("error in page map\n");
  8013e7:	c7 44 24 08 5c 1d 80 	movl   $0x801d5c,0x8(%esp)
  8013ee:	00 
  8013ef:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  8013f6:	00 
  8013f7:	c7 04 24 24 1d 80 00 	movl   $0x801d24,(%esp)
  8013fe:	e8 82 ed ff ff       	call   800185 <_panic>
		}
		int r1 = sys_page_map(envid,va_pn,0,va_pn,PTE_P|PTE_U|PTE_COW);
  801403:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80140a:	00 
  80140b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801412:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801419:	00 
  80141a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801421:	8b 45 08             	mov    0x8(%ebp),%eax
  801424:	89 04 24             	mov    %eax,(%esp)
  801427:	e8 ab fc ff ff       	call   8010d7 <sys_page_map>
  80142c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if(r1 < 0)
  80142f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801433:	79 1c                	jns    801451 <duppage+0xc8>
		{
			panic("error in page map\n");
  801435:	c7 44 24 08 5c 1d 80 	movl   $0x801d5c,0x8(%esp)
  80143c:	00 
  80143d:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801444:	00 
  801445:	c7 04 24 24 1d 80 00 	movl   $0x801d24,(%esp)
  80144c:	e8 34 ed ff ff       	call   800185 <_panic>
		}
		int r2 = sys_page_map(0,va_pn,0,va_pn,PTE_P|PTE_U|PTE_COW);
  801451:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801458:	00 
  801459:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801460:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801467:	00 
  801468:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801476:	e8 5c fc ff ff       	call   8010d7 <sys_page_map>
  80147b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		if(r2 < 0)
  80147e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801482:	79 1c                	jns    8014a0 <duppage+0x117>
		{
			panic("error in page map\n");
  801484:	c7 44 24 08 5c 1d 80 	movl   $0x801d5c,0x8(%esp)
  80148b:	00 
  80148c:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  801493:	00 
  801494:	c7 04 24 24 1d 80 00 	movl   $0x801d24,(%esp)
  80149b:	e8 e5 ec ff ff       	call   800185 <_panic>
	
	// LAB 4: Your code here.
	uint32_t t = uvpt[pn];
	void *va_pn = (void *)(pn*PGSIZE);
	if((t && PTE_W) || (t && PTE_COW))
	{
  8014a0:	eb 4e                	jmp    8014f0 <duppage+0x167>
			panic("error in page map\n");
		}
	}
	else
	{
		int r3 = sys_page_map(0,va_pn,envid,va_pn,PTE_U|PTE_P);
  8014a2:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8014a9:	00 
  8014aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014c6:	e8 0c fc ff ff       	call   8010d7 <sys_page_map>
  8014cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if(r3 < 0)
  8014ce:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8014d2:	79 1c                	jns    8014f0 <duppage+0x167>
		{
			panic("error in page map\n");
  8014d4:	c7 44 24 08 5c 1d 80 	movl   $0x801d5c,0x8(%esp)
  8014db:	00 
  8014dc:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  8014e3:	00 
  8014e4:	c7 04 24 24 1d 80 00 	movl   $0x801d24,(%esp)
  8014eb:	e8 95 ec ff ff       	call   800185 <_panic>
		}
	}
	// panic("duppage not implemented");
	return 0;
  8014f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f5:	c9                   	leave  
  8014f6:	c3                   	ret    

008014f7 <fork>:


envid_t
fork(void)
{
  8014f7:	55                   	push   %ebp
  8014f8:	89 e5                	mov    %esp,%ebp
  8014fa:	83 ec 38             	sub    $0x38,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8014fd:	c7 04 24 66 12 80 00 	movl   $0x801266,(%esp)
  801504:	e8 b0 01 00 00       	call   8016b9 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801509:	b8 07 00 00 00       	mov    $0x7,%eax
  80150e:	cd 30                	int    $0x30
  801510:	89 45 e0             	mov    %eax,-0x20(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  801513:	8b 45 e0             	mov    -0x20(%ebp),%eax
	envid_t envid = sys_exofork();
  801516:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (envid < 0)
  801519:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80151d:	79 1c                	jns    80153b <fork+0x44>
	{
		panic("sys_exofork not succeeded\n");
  80151f:	c7 44 24 08 6f 1d 80 	movl   $0x801d6f,0x8(%esp)
  801526:	00 
  801527:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
  80152e:	00 
  80152f:	c7 04 24 24 1d 80 00 	movl   $0x801d24,(%esp)
  801536:	e8 4a ec ff ff       	call   800185 <_panic>
	}
	if (envid == 0)
  80153b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80153f:	75 29                	jne    80156a <fork+0x73>
	{	
		thisenv = &envs[ENVX(sys_getenvid())];
  801541:	e8 c8 fa ff ff       	call   80100e <sys_getenvid>
  801546:	25 ff 03 00 00       	and    $0x3ff,%eax
  80154b:	c1 e0 02             	shl    $0x2,%eax
  80154e:	89 c2                	mov    %eax,%edx
  801550:	c1 e2 05             	shl    $0x5,%edx
  801553:	29 c2                	sub    %eax,%edx
  801555:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  80155b:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  801560:	b8 00 00 00 00       	mov    $0x0,%eax
  801565:	e9 2b 01 00 00       	jmp    801695 <fork+0x19e>
	}
	else
	{
		int p;
		for (p = 0; p < PGNUM(UTOP); p++) 
  80156a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  801571:	e9 9a 00 00 00       	jmp    801610 <fork+0x119>
		{
			if(p == PGNUM(UTOP) - 1)
  801576:	81 7d f4 ff eb 0e 00 	cmpl   $0xeebff,-0xc(%ebp)
  80157d:	75 42                	jne    8015c1 <fork+0xca>
			{
				int r1 = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE), PTE_P|PTE_W|PTE_U);
  80157f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801586:	00 
  801587:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80158e:	ee 
  80158f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801592:	89 04 24             	mov    %eax,(%esp)
  801595:	e8 fc fa ff ff       	call   801096 <sys_page_alloc>
  80159a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  				if(r1 < 0)
  80159d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8015a1:	79 1c                	jns    8015bf <fork+0xc8>
  				{
    				panic("sys_page_alloc failed\n");
  8015a3:	c7 44 24 08 8a 1d 80 	movl   $0x801d8a,0x8(%esp)
  8015aa:	00 
  8015ab:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  8015b2:	00 
  8015b3:	c7 04 24 24 1d 80 00 	movl   $0x801d24,(%esp)
  8015ba:	e8 c6 eb ff ff       	call   800185 <_panic>
				}
				break;
  8015bf:	eb 5d                	jmp    80161e <fork+0x127>
			}
			if((uvpd[PDX(p*PGSIZE)]&PTE_P))
  8015c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c4:	c1 e0 0c             	shl    $0xc,%eax
  8015c7:	c1 e8 16             	shr    $0x16,%eax
  8015ca:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015d1:	83 e0 01             	and    $0x1,%eax
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	74 34                	je     80160c <fork+0x115>
			{
				if((uvpt[p]&PTE_P) && (uvpt[p] & PTE_U))
  8015d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015db:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015e2:	83 e0 01             	and    $0x1,%eax
  8015e5:	85 c0                	test   %eax,%eax
  8015e7:	74 23                	je     80160c <fork+0x115>
  8015e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015f3:	83 e0 04             	and    $0x4,%eax
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	74 12                	je     80160c <fork+0x115>
				{
					duppage(envid, p);
  8015fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801601:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801604:	89 04 24             	mov    %eax,(%esp)
  801607:	e8 7d fd ff ff       	call   801389 <duppage>
		return 0;
	}
	else
	{
		int p;
		for (p = 0; p < PGNUM(UTOP); p++) 
  80160c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  801610:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801613:	3d ff eb 0e 00       	cmp    $0xeebff,%eax
  801618:	0f 86 58 ff ff ff    	jbe    801576 <fork+0x7f>
				}
			}	
		}
  		
		extern void _pgfault_upcall();
		int r = sys_env_set_pgfault_upcall(envid,thisenv->env_pgfault_upcall);
  80161e:	a1 08 20 80 00       	mov    0x802008,%eax
  801623:	8b 40 64             	mov    0x64(%eax),%eax
  801626:	89 44 24 04          	mov    %eax,0x4(%esp)
  80162a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162d:	89 04 24             	mov    %eax,(%esp)
  801630:	e8 6c fb ff ff       	call   8011a1 <sys_env_set_pgfault_upcall>
  801635:	89 45 e8             	mov    %eax,-0x18(%ebp)
    	if(r < 0)
  801638:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80163c:	79 1c                	jns    80165a <fork+0x163>
    	{
    		panic("sys_env_set_pgfault_upcall failed\n");
  80163e:	c7 44 24 08 a4 1d 80 	movl   $0x801da4,0x8(%esp)
  801645:	00 
  801646:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  80164d:	00 
  80164e:	c7 04 24 24 1d 80 00 	movl   $0x801d24,(%esp)
  801655:	e8 2b eb ff ff       	call   800185 <_panic>
    	}
  		int r2 = sys_env_set_status(envid, ENV_RUNNABLE);
  80165a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801661:	00 
  801662:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801665:	89 04 24             	mov    %eax,(%esp)
  801668:	e8 f2 fa ff ff       	call   80115f <sys_env_set_status>
  80166d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  		if(r2 < 0)
  801670:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801674:	79 1c                	jns    801692 <fork+0x19b>
  		{
    		panic("sys_env_set_status failes\n");
  801676:	c7 44 24 08 c7 1d 80 	movl   $0x801dc7,0x8(%esp)
  80167d:	00 
  80167e:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  801685:	00 
  801686:	c7 04 24 24 1d 80 00 	movl   $0x801d24,(%esp)
  80168d:	e8 f3 ea ff ff       	call   800185 <_panic>
    	}
  		return envid;
  801692:	8b 45 f0             	mov    -0x10(%ebp),%eax
	}


	// panic("fork not implemented");
}
  801695:	c9                   	leave  
  801696:	c3                   	ret    

00801697 <sfork>:


// Challenge!
int
sfork(void)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80169d:	c7 44 24 08 e2 1d 80 	movl   $0x801de2,0x8(%esp)
  8016a4:	00 
  8016a5:	c7 44 24 04 a8 00 00 	movl   $0xa8,0x4(%esp)
  8016ac:	00 
  8016ad:	c7 04 24 24 1d 80 00 	movl   $0x801d24,(%esp)
  8016b4:	e8 cc ea ff ff       	call   800185 <_panic>

008016b9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  8016bf:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	75 55                	jne    80171d <set_pgfault_handler+0x64>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE),PTE_U|PTE_P|PTE_W);
  8016c8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8016cf:	00 
  8016d0:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8016d7:	ee 
  8016d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016df:	e8 b2 f9 ff ff       	call   801096 <sys_page_alloc>
  8016e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(r < 0)
  8016e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8016eb:	79 1c                	jns    801709 <set_pgfault_handler+0x50>
		{
			panic("sys_page_alloc_failed");
  8016ed:	c7 44 24 08 f8 1d 80 	movl   $0x801df8,0x8(%esp)
  8016f4:	00 
  8016f5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8016fc:	00 
  8016fd:	c7 04 24 0e 1e 80 00 	movl   $0x801e0e,(%esp)
  801704:	e8 7c ea ff ff       	call   800185 <_panic>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801709:	c7 44 24 04 27 17 80 	movl   $0x801727,0x4(%esp)
  801710:	00 
  801711:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801718:	e8 84 fa ff ff       	call   8011a1 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80171d:	8b 45 08             	mov    0x8(%ebp),%eax
  801720:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  801725:	c9                   	leave  
  801726:	c3                   	ret    

00801727 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801727:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801728:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80172d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80172f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x30(%esp), %eax
  801732:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  801736:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801739:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 0x28(%esp), %ecx
  80173d:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	movl %ecx, (%eax)
  801741:	89 08                	mov    %ecx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	//add $8, %esp
	popl %edx 
  801743:	5a                   	pop    %edx
	popl %edx
  801744:	5a                   	pop    %edx
	popal
  801745:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp
  801746:	83 c4 04             	add    $0x4,%esp
	popf
  801749:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80174a:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80174b:	c3                   	ret    
  80174c:	66 90                	xchg   %ax,%ax
  80174e:	66 90                	xchg   %ax,%ax

00801750 <__udivdi3>:
  801750:	55                   	push   %ebp
  801751:	57                   	push   %edi
  801752:	56                   	push   %esi
  801753:	83 ec 0c             	sub    $0xc,%esp
  801756:	8b 44 24 28          	mov    0x28(%esp),%eax
  80175a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80175e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801762:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801766:	85 c0                	test   %eax,%eax
  801768:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80176c:	89 ea                	mov    %ebp,%edx
  80176e:	89 0c 24             	mov    %ecx,(%esp)
  801771:	75 2d                	jne    8017a0 <__udivdi3+0x50>
  801773:	39 e9                	cmp    %ebp,%ecx
  801775:	77 61                	ja     8017d8 <__udivdi3+0x88>
  801777:	85 c9                	test   %ecx,%ecx
  801779:	89 ce                	mov    %ecx,%esi
  80177b:	75 0b                	jne    801788 <__udivdi3+0x38>
  80177d:	b8 01 00 00 00       	mov    $0x1,%eax
  801782:	31 d2                	xor    %edx,%edx
  801784:	f7 f1                	div    %ecx
  801786:	89 c6                	mov    %eax,%esi
  801788:	31 d2                	xor    %edx,%edx
  80178a:	89 e8                	mov    %ebp,%eax
  80178c:	f7 f6                	div    %esi
  80178e:	89 c5                	mov    %eax,%ebp
  801790:	89 f8                	mov    %edi,%eax
  801792:	f7 f6                	div    %esi
  801794:	89 ea                	mov    %ebp,%edx
  801796:	83 c4 0c             	add    $0xc,%esp
  801799:	5e                   	pop    %esi
  80179a:	5f                   	pop    %edi
  80179b:	5d                   	pop    %ebp
  80179c:	c3                   	ret    
  80179d:	8d 76 00             	lea    0x0(%esi),%esi
  8017a0:	39 e8                	cmp    %ebp,%eax
  8017a2:	77 24                	ja     8017c8 <__udivdi3+0x78>
  8017a4:	0f bd e8             	bsr    %eax,%ebp
  8017a7:	83 f5 1f             	xor    $0x1f,%ebp
  8017aa:	75 3c                	jne    8017e8 <__udivdi3+0x98>
  8017ac:	8b 74 24 04          	mov    0x4(%esp),%esi
  8017b0:	39 34 24             	cmp    %esi,(%esp)
  8017b3:	0f 86 9f 00 00 00    	jbe    801858 <__udivdi3+0x108>
  8017b9:	39 d0                	cmp    %edx,%eax
  8017bb:	0f 82 97 00 00 00    	jb     801858 <__udivdi3+0x108>
  8017c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8017c8:	31 d2                	xor    %edx,%edx
  8017ca:	31 c0                	xor    %eax,%eax
  8017cc:	83 c4 0c             	add    $0xc,%esp
  8017cf:	5e                   	pop    %esi
  8017d0:	5f                   	pop    %edi
  8017d1:	5d                   	pop    %ebp
  8017d2:	c3                   	ret    
  8017d3:	90                   	nop
  8017d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8017d8:	89 f8                	mov    %edi,%eax
  8017da:	f7 f1                	div    %ecx
  8017dc:	31 d2                	xor    %edx,%edx
  8017de:	83 c4 0c             	add    $0xc,%esp
  8017e1:	5e                   	pop    %esi
  8017e2:	5f                   	pop    %edi
  8017e3:	5d                   	pop    %ebp
  8017e4:	c3                   	ret    
  8017e5:	8d 76 00             	lea    0x0(%esi),%esi
  8017e8:	89 e9                	mov    %ebp,%ecx
  8017ea:	8b 3c 24             	mov    (%esp),%edi
  8017ed:	d3 e0                	shl    %cl,%eax
  8017ef:	89 c6                	mov    %eax,%esi
  8017f1:	b8 20 00 00 00       	mov    $0x20,%eax
  8017f6:	29 e8                	sub    %ebp,%eax
  8017f8:	89 c1                	mov    %eax,%ecx
  8017fa:	d3 ef                	shr    %cl,%edi
  8017fc:	89 e9                	mov    %ebp,%ecx
  8017fe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801802:	8b 3c 24             	mov    (%esp),%edi
  801805:	09 74 24 08          	or     %esi,0x8(%esp)
  801809:	89 d6                	mov    %edx,%esi
  80180b:	d3 e7                	shl    %cl,%edi
  80180d:	89 c1                	mov    %eax,%ecx
  80180f:	89 3c 24             	mov    %edi,(%esp)
  801812:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801816:	d3 ee                	shr    %cl,%esi
  801818:	89 e9                	mov    %ebp,%ecx
  80181a:	d3 e2                	shl    %cl,%edx
  80181c:	89 c1                	mov    %eax,%ecx
  80181e:	d3 ef                	shr    %cl,%edi
  801820:	09 d7                	or     %edx,%edi
  801822:	89 f2                	mov    %esi,%edx
  801824:	89 f8                	mov    %edi,%eax
  801826:	f7 74 24 08          	divl   0x8(%esp)
  80182a:	89 d6                	mov    %edx,%esi
  80182c:	89 c7                	mov    %eax,%edi
  80182e:	f7 24 24             	mull   (%esp)
  801831:	39 d6                	cmp    %edx,%esi
  801833:	89 14 24             	mov    %edx,(%esp)
  801836:	72 30                	jb     801868 <__udivdi3+0x118>
  801838:	8b 54 24 04          	mov    0x4(%esp),%edx
  80183c:	89 e9                	mov    %ebp,%ecx
  80183e:	d3 e2                	shl    %cl,%edx
  801840:	39 c2                	cmp    %eax,%edx
  801842:	73 05                	jae    801849 <__udivdi3+0xf9>
  801844:	3b 34 24             	cmp    (%esp),%esi
  801847:	74 1f                	je     801868 <__udivdi3+0x118>
  801849:	89 f8                	mov    %edi,%eax
  80184b:	31 d2                	xor    %edx,%edx
  80184d:	e9 7a ff ff ff       	jmp    8017cc <__udivdi3+0x7c>
  801852:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801858:	31 d2                	xor    %edx,%edx
  80185a:	b8 01 00 00 00       	mov    $0x1,%eax
  80185f:	e9 68 ff ff ff       	jmp    8017cc <__udivdi3+0x7c>
  801864:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801868:	8d 47 ff             	lea    -0x1(%edi),%eax
  80186b:	31 d2                	xor    %edx,%edx
  80186d:	83 c4 0c             	add    $0xc,%esp
  801870:	5e                   	pop    %esi
  801871:	5f                   	pop    %edi
  801872:	5d                   	pop    %ebp
  801873:	c3                   	ret    
  801874:	66 90                	xchg   %ax,%ax
  801876:	66 90                	xchg   %ax,%ax
  801878:	66 90                	xchg   %ax,%ax
  80187a:	66 90                	xchg   %ax,%ax
  80187c:	66 90                	xchg   %ax,%ax
  80187e:	66 90                	xchg   %ax,%ax

00801880 <__umoddi3>:
  801880:	55                   	push   %ebp
  801881:	57                   	push   %edi
  801882:	56                   	push   %esi
  801883:	83 ec 14             	sub    $0x14,%esp
  801886:	8b 44 24 28          	mov    0x28(%esp),%eax
  80188a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80188e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801892:	89 c7                	mov    %eax,%edi
  801894:	89 44 24 04          	mov    %eax,0x4(%esp)
  801898:	8b 44 24 30          	mov    0x30(%esp),%eax
  80189c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8018a0:	89 34 24             	mov    %esi,(%esp)
  8018a3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018a7:	85 c0                	test   %eax,%eax
  8018a9:	89 c2                	mov    %eax,%edx
  8018ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8018af:	75 17                	jne    8018c8 <__umoddi3+0x48>
  8018b1:	39 fe                	cmp    %edi,%esi
  8018b3:	76 4b                	jbe    801900 <__umoddi3+0x80>
  8018b5:	89 c8                	mov    %ecx,%eax
  8018b7:	89 fa                	mov    %edi,%edx
  8018b9:	f7 f6                	div    %esi
  8018bb:	89 d0                	mov    %edx,%eax
  8018bd:	31 d2                	xor    %edx,%edx
  8018bf:	83 c4 14             	add    $0x14,%esp
  8018c2:	5e                   	pop    %esi
  8018c3:	5f                   	pop    %edi
  8018c4:	5d                   	pop    %ebp
  8018c5:	c3                   	ret    
  8018c6:	66 90                	xchg   %ax,%ax
  8018c8:	39 f8                	cmp    %edi,%eax
  8018ca:	77 54                	ja     801920 <__umoddi3+0xa0>
  8018cc:	0f bd e8             	bsr    %eax,%ebp
  8018cf:	83 f5 1f             	xor    $0x1f,%ebp
  8018d2:	75 5c                	jne    801930 <__umoddi3+0xb0>
  8018d4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8018d8:	39 3c 24             	cmp    %edi,(%esp)
  8018db:	0f 87 e7 00 00 00    	ja     8019c8 <__umoddi3+0x148>
  8018e1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8018e5:	29 f1                	sub    %esi,%ecx
  8018e7:	19 c7                	sbb    %eax,%edi
  8018e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018ed:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8018f1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8018f5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8018f9:	83 c4 14             	add    $0x14,%esp
  8018fc:	5e                   	pop    %esi
  8018fd:	5f                   	pop    %edi
  8018fe:	5d                   	pop    %ebp
  8018ff:	c3                   	ret    
  801900:	85 f6                	test   %esi,%esi
  801902:	89 f5                	mov    %esi,%ebp
  801904:	75 0b                	jne    801911 <__umoddi3+0x91>
  801906:	b8 01 00 00 00       	mov    $0x1,%eax
  80190b:	31 d2                	xor    %edx,%edx
  80190d:	f7 f6                	div    %esi
  80190f:	89 c5                	mov    %eax,%ebp
  801911:	8b 44 24 04          	mov    0x4(%esp),%eax
  801915:	31 d2                	xor    %edx,%edx
  801917:	f7 f5                	div    %ebp
  801919:	89 c8                	mov    %ecx,%eax
  80191b:	f7 f5                	div    %ebp
  80191d:	eb 9c                	jmp    8018bb <__umoddi3+0x3b>
  80191f:	90                   	nop
  801920:	89 c8                	mov    %ecx,%eax
  801922:	89 fa                	mov    %edi,%edx
  801924:	83 c4 14             	add    $0x14,%esp
  801927:	5e                   	pop    %esi
  801928:	5f                   	pop    %edi
  801929:	5d                   	pop    %ebp
  80192a:	c3                   	ret    
  80192b:	90                   	nop
  80192c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801930:	8b 04 24             	mov    (%esp),%eax
  801933:	be 20 00 00 00       	mov    $0x20,%esi
  801938:	89 e9                	mov    %ebp,%ecx
  80193a:	29 ee                	sub    %ebp,%esi
  80193c:	d3 e2                	shl    %cl,%edx
  80193e:	89 f1                	mov    %esi,%ecx
  801940:	d3 e8                	shr    %cl,%eax
  801942:	89 e9                	mov    %ebp,%ecx
  801944:	89 44 24 04          	mov    %eax,0x4(%esp)
  801948:	8b 04 24             	mov    (%esp),%eax
  80194b:	09 54 24 04          	or     %edx,0x4(%esp)
  80194f:	89 fa                	mov    %edi,%edx
  801951:	d3 e0                	shl    %cl,%eax
  801953:	89 f1                	mov    %esi,%ecx
  801955:	89 44 24 08          	mov    %eax,0x8(%esp)
  801959:	8b 44 24 10          	mov    0x10(%esp),%eax
  80195d:	d3 ea                	shr    %cl,%edx
  80195f:	89 e9                	mov    %ebp,%ecx
  801961:	d3 e7                	shl    %cl,%edi
  801963:	89 f1                	mov    %esi,%ecx
  801965:	d3 e8                	shr    %cl,%eax
  801967:	89 e9                	mov    %ebp,%ecx
  801969:	09 f8                	or     %edi,%eax
  80196b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80196f:	f7 74 24 04          	divl   0x4(%esp)
  801973:	d3 e7                	shl    %cl,%edi
  801975:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801979:	89 d7                	mov    %edx,%edi
  80197b:	f7 64 24 08          	mull   0x8(%esp)
  80197f:	39 d7                	cmp    %edx,%edi
  801981:	89 c1                	mov    %eax,%ecx
  801983:	89 14 24             	mov    %edx,(%esp)
  801986:	72 2c                	jb     8019b4 <__umoddi3+0x134>
  801988:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80198c:	72 22                	jb     8019b0 <__umoddi3+0x130>
  80198e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801992:	29 c8                	sub    %ecx,%eax
  801994:	19 d7                	sbb    %edx,%edi
  801996:	89 e9                	mov    %ebp,%ecx
  801998:	89 fa                	mov    %edi,%edx
  80199a:	d3 e8                	shr    %cl,%eax
  80199c:	89 f1                	mov    %esi,%ecx
  80199e:	d3 e2                	shl    %cl,%edx
  8019a0:	89 e9                	mov    %ebp,%ecx
  8019a2:	d3 ef                	shr    %cl,%edi
  8019a4:	09 d0                	or     %edx,%eax
  8019a6:	89 fa                	mov    %edi,%edx
  8019a8:	83 c4 14             	add    $0x14,%esp
  8019ab:	5e                   	pop    %esi
  8019ac:	5f                   	pop    %edi
  8019ad:	5d                   	pop    %ebp
  8019ae:	c3                   	ret    
  8019af:	90                   	nop
  8019b0:	39 d7                	cmp    %edx,%edi
  8019b2:	75 da                	jne    80198e <__umoddi3+0x10e>
  8019b4:	8b 14 24             	mov    (%esp),%edx
  8019b7:	89 c1                	mov    %eax,%ecx
  8019b9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8019bd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8019c1:	eb cb                	jmp    80198e <__umoddi3+0x10e>
  8019c3:	90                   	nop
  8019c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8019c8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8019cc:	0f 82 0f ff ff ff    	jb     8018e1 <__umoddi3+0x61>
  8019d2:	e9 1a ff ff ff       	jmp    8018f1 <__umoddi3+0x71>
