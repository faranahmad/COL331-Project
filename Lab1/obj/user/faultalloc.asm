
obj/user/faultalloc:     file format elf32-i386


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
  80002c:	e8 dc 00 00 00       	call   80010d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 38             	sub    $0x38,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  800039:	8b 45 08             	mov    0x8(%ebp),%eax
  80003c:	8b 00                	mov    (%eax),%eax
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)

	cprintf("fault %x\n", addr);
  800041:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800044:	89 44 24 04          	mov    %eax,0x4(%esp)
  800048:	c7 04 24 80 15 80 00 	movl   $0x801580,(%esp)
  80004f:	e8 36 02 00 00       	call   80028a <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800054:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800057:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80005a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80005d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800062:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800069:	00 
  80006a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800075:	e8 06 10 00 00       	call   801080 <sys_page_alloc>
  80007a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80007d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800081:	79 2a                	jns    8000ad <handler+0x7a>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800083:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800086:	89 44 24 10          	mov    %eax,0x10(%esp)
  80008a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80008d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800091:	c7 44 24 08 8c 15 80 	movl   $0x80158c,0x8(%esp)
  800098:	00 
  800099:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  8000a0:	00 
  8000a1:	c7 04 24 b7 15 80 00 	movl   $0x8015b7,(%esp)
  8000a8:	e8 c2 00 00 00       	call   80016f <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  8000ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b4:	c7 44 24 08 cc 15 80 	movl   $0x8015cc,0x8(%esp)
  8000bb:	00 
  8000bc:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000c3:	00 
  8000c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000c7:	89 04 24             	mov    %eax,(%esp)
  8000ca:	e8 37 08 00 00       	call   800906 <snprintf>
}
  8000cf:	c9                   	leave  
  8000d0:	c3                   	ret    

008000d1 <umain>:

void
umain(int argc, char **argv)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000d7:	c7 04 24 33 00 80 00 	movl   $0x800033,(%esp)
  8000de:	e8 6d 11 00 00       	call   801250 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000e3:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000ea:	de 
  8000eb:	c7 04 24 ed 15 80 00 	movl   $0x8015ed,(%esp)
  8000f2:	e8 93 01 00 00       	call   80028a <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000f7:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000fe:	ca 
  8000ff:	c7 04 24 ed 15 80 00 	movl   $0x8015ed,(%esp)
  800106:	e8 7f 01 00 00       	call   80028a <cprintf>
}
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800113:	e8 e0 0e 00 00       	call   800ff8 <sys_getenvid>
  800118:	25 ff 03 00 00       	and    $0x3ff,%eax
  80011d:	c1 e0 02             	shl    $0x2,%eax
  800120:	89 c2                	mov    %eax,%edx
  800122:	c1 e2 05             	shl    $0x5,%edx
  800125:	29 c2                	sub    %eax,%edx
  800127:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  80012d:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800132:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800136:	7e 0a                	jle    800142 <libmain+0x35>
		binaryname = argv[0];
  800138:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013b:	8b 00                	mov    (%eax),%eax
  80013d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800142:	8b 45 0c             	mov    0xc(%ebp),%eax
  800145:	89 44 24 04          	mov    %eax,0x4(%esp)
  800149:	8b 45 08             	mov    0x8(%ebp),%eax
  80014c:	89 04 24             	mov    %eax,(%esp)
  80014f:	e8 7d ff ff ff       	call   8000d1 <umain>

	// exit gracefully
	exit();
  800154:	e8 02 00 00 00       	call   80015b <exit>
}
  800159:	c9                   	leave  
  80015a:	c3                   	ret    

0080015b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800161:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800168:	e8 48 0e 00 00       	call   800fb5 <sys_env_destroy>
}
  80016d:	c9                   	leave  
  80016e:	c3                   	ret    

0080016f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	53                   	push   %ebx
  800173:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  800176:	8d 45 14             	lea    0x14(%ebp),%eax
  800179:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80017c:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800182:	e8 71 0e 00 00       	call   800ff8 <sys_getenvid>
  800187:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80018e:	8b 55 08             	mov    0x8(%ebp),%edx
  800191:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800195:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800199:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019d:	c7 04 24 fc 15 80 00 	movl   $0x8015fc,(%esp)
  8001a4:	e8 e1 00 00 00       	call   80028a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b3:	89 04 24             	mov    %eax,(%esp)
  8001b6:	e8 6b 00 00 00       	call   800226 <vcprintf>
	cprintf("\n");
  8001bb:	c7 04 24 1f 16 80 00 	movl   $0x80161f,(%esp)
  8001c2:	e8 c3 00 00 00       	call   80028a <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c7:	cc                   	int3   
  8001c8:	eb fd                	jmp    8001c7 <_panic+0x58>

008001ca <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ca:	55                   	push   %ebp
  8001cb:	89 e5                	mov    %esp,%ebp
  8001cd:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8001d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d3:	8b 00                	mov    (%eax),%eax
  8001d5:	8d 48 01             	lea    0x1(%eax),%ecx
  8001d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001db:	89 0a                	mov    %ecx,(%edx)
  8001dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e0:	89 d1                	mov    %edx,%ecx
  8001e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e5:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8001e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ec:	8b 00                	mov    (%eax),%eax
  8001ee:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f3:	75 20                	jne    800215 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8001f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f8:	8b 00                	mov    (%eax),%eax
  8001fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fd:	83 c2 08             	add    $0x8,%edx
  800200:	89 44 24 04          	mov    %eax,0x4(%esp)
  800204:	89 14 24             	mov    %edx,(%esp)
  800207:	e8 23 0d 00 00       	call   800f2f <sys_cputs>
		b->idx = 0;
  80020c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800215:	8b 45 0c             	mov    0xc(%ebp),%eax
  800218:	8b 40 04             	mov    0x4(%eax),%eax
  80021b:	8d 50 01             	lea    0x1(%eax),%edx
  80021e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800221:	89 50 04             	mov    %edx,0x4(%eax)
}
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80022f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800236:	00 00 00 
	b.cnt = 0;
  800239:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800240:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800243:	8b 45 0c             	mov    0xc(%ebp),%eax
  800246:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80024a:	8b 45 08             	mov    0x8(%ebp),%eax
  80024d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800251:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800257:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025b:	c7 04 24 ca 01 80 00 	movl   $0x8001ca,(%esp)
  800262:	e8 bd 01 00 00       	call   800424 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800267:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80026d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800271:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800277:	83 c0 08             	add    $0x8,%eax
  80027a:	89 04 24             	mov    %eax,(%esp)
  80027d:	e8 ad 0c 00 00       	call   800f2f <sys_cputs>

	return b.cnt;
  800282:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800290:	8d 45 0c             	lea    0xc(%ebp),%eax
  800293:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800296:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800299:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029d:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a0:	89 04 24             	mov    %eax,(%esp)
  8002a3:	e8 7e ff ff ff       	call   800226 <vcprintf>
  8002a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8002ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8002ae:	c9                   	leave  
  8002af:	c3                   	ret    

008002b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 34             	sub    $0x34,%esp
  8002b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8002bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8002c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c3:	8b 45 18             	mov    0x18(%ebp),%eax
  8002c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cb:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002ce:	77 72                	ja     800342 <printnum+0x92>
  8002d0:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002d3:	72 05                	jb     8002da <printnum+0x2a>
  8002d5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8002d8:	77 68                	ja     800342 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002da:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8002dd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002e0:	8b 45 18             	mov    0x18(%ebp),%eax
  8002e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8002f6:	89 04 24             	mov    %eax,(%esp)
  8002f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002fd:	e8 ee 0f 00 00       	call   8012f0 <__udivdi3>
  800302:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800305:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800309:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80030d:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800310:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800314:	89 44 24 08          	mov    %eax,0x8(%esp)
  800318:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80031c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80031f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800323:	8b 45 08             	mov    0x8(%ebp),%eax
  800326:	89 04 24             	mov    %eax,(%esp)
  800329:	e8 82 ff ff ff       	call   8002b0 <printnum>
  80032e:	eb 1c                	jmp    80034c <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800330:	8b 45 0c             	mov    0xc(%ebp),%eax
  800333:	89 44 24 04          	mov    %eax,0x4(%esp)
  800337:	8b 45 20             	mov    0x20(%ebp),%eax
  80033a:	89 04 24             	mov    %eax,(%esp)
  80033d:	8b 45 08             	mov    0x8(%ebp),%eax
  800340:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800342:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800346:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  80034a:	7f e4                	jg     800330 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80034c:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80034f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800354:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800357:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80035a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80035e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800362:	89 04 24             	mov    %eax,(%esp)
  800365:	89 54 24 04          	mov    %edx,0x4(%esp)
  800369:	e8 b2 10 00 00       	call   801420 <__umoddi3>
  80036e:	05 08 17 80 00       	add    $0x801708,%eax
  800373:	0f b6 00             	movzbl (%eax),%eax
  800376:	0f be c0             	movsbl %al,%eax
  800379:	8b 55 0c             	mov    0xc(%ebp),%edx
  80037c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800380:	89 04 24             	mov    %eax,(%esp)
  800383:	8b 45 08             	mov    0x8(%ebp),%eax
  800386:	ff d0                	call   *%eax
}
  800388:	83 c4 34             	add    $0x34,%esp
  80038b:	5b                   	pop    %ebx
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800391:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800395:	7e 14                	jle    8003ab <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800397:	8b 45 08             	mov    0x8(%ebp),%eax
  80039a:	8b 00                	mov    (%eax),%eax
  80039c:	8d 48 08             	lea    0x8(%eax),%ecx
  80039f:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a2:	89 0a                	mov    %ecx,(%edx)
  8003a4:	8b 50 04             	mov    0x4(%eax),%edx
  8003a7:	8b 00                	mov    (%eax),%eax
  8003a9:	eb 30                	jmp    8003db <getuint+0x4d>
	else if (lflag)
  8003ab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003af:	74 16                	je     8003c7 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8003b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b4:	8b 00                	mov    (%eax),%eax
  8003b6:	8d 48 04             	lea    0x4(%eax),%ecx
  8003b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003bc:	89 0a                	mov    %ecx,(%edx)
  8003be:	8b 00                	mov    (%eax),%eax
  8003c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c5:	eb 14                	jmp    8003db <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8003c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ca:	8b 00                	mov    (%eax),%eax
  8003cc:	8d 48 04             	lea    0x4(%eax),%ecx
  8003cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d2:	89 0a                	mov    %ecx,(%edx)
  8003d4:	8b 00                	mov    (%eax),%eax
  8003d6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003db:	5d                   	pop    %ebp
  8003dc:	c3                   	ret    

008003dd <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003dd:	55                   	push   %ebp
  8003de:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e0:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003e4:	7e 14                	jle    8003fa <getint+0x1d>
		return va_arg(*ap, long long);
  8003e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e9:	8b 00                	mov    (%eax),%eax
  8003eb:	8d 48 08             	lea    0x8(%eax),%ecx
  8003ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f1:	89 0a                	mov    %ecx,(%edx)
  8003f3:	8b 50 04             	mov    0x4(%eax),%edx
  8003f6:	8b 00                	mov    (%eax),%eax
  8003f8:	eb 28                	jmp    800422 <getint+0x45>
	else if (lflag)
  8003fa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003fe:	74 12                	je     800412 <getint+0x35>
		return va_arg(*ap, long);
  800400:	8b 45 08             	mov    0x8(%ebp),%eax
  800403:	8b 00                	mov    (%eax),%eax
  800405:	8d 48 04             	lea    0x4(%eax),%ecx
  800408:	8b 55 08             	mov    0x8(%ebp),%edx
  80040b:	89 0a                	mov    %ecx,(%edx)
  80040d:	8b 00                	mov    (%eax),%eax
  80040f:	99                   	cltd   
  800410:	eb 10                	jmp    800422 <getint+0x45>
	else
		return va_arg(*ap, int);
  800412:	8b 45 08             	mov    0x8(%ebp),%eax
  800415:	8b 00                	mov    (%eax),%eax
  800417:	8d 48 04             	lea    0x4(%eax),%ecx
  80041a:	8b 55 08             	mov    0x8(%ebp),%edx
  80041d:	89 0a                	mov    %ecx,(%edx)
  80041f:	8b 00                	mov    (%eax),%eax
  800421:	99                   	cltd   
}
  800422:	5d                   	pop    %ebp
  800423:	c3                   	ret    

00800424 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	56                   	push   %esi
  800428:	53                   	push   %ebx
  800429:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80042c:	eb 18                	jmp    800446 <vprintfmt+0x22>
			if (ch == '\0')
  80042e:	85 db                	test   %ebx,%ebx
  800430:	75 05                	jne    800437 <vprintfmt+0x13>
				return;
  800432:	e9 05 04 00 00       	jmp    80083c <vprintfmt+0x418>
			putch(ch, putdat);
  800437:	8b 45 0c             	mov    0xc(%ebp),%eax
  80043a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80043e:	89 1c 24             	mov    %ebx,(%esp)
  800441:	8b 45 08             	mov    0x8(%ebp),%eax
  800444:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800446:	8b 45 10             	mov    0x10(%ebp),%eax
  800449:	8d 50 01             	lea    0x1(%eax),%edx
  80044c:	89 55 10             	mov    %edx,0x10(%ebp)
  80044f:	0f b6 00             	movzbl (%eax),%eax
  800452:	0f b6 d8             	movzbl %al,%ebx
  800455:	83 fb 25             	cmp    $0x25,%ebx
  800458:	75 d4                	jne    80042e <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80045a:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80045e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800465:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80046c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800473:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 45 10             	mov    0x10(%ebp),%eax
  80047d:	8d 50 01             	lea    0x1(%eax),%edx
  800480:	89 55 10             	mov    %edx,0x10(%ebp)
  800483:	0f b6 00             	movzbl (%eax),%eax
  800486:	0f b6 d8             	movzbl %al,%ebx
  800489:	8d 43 dd             	lea    -0x23(%ebx),%eax
  80048c:	83 f8 55             	cmp    $0x55,%eax
  80048f:	0f 87 76 03 00 00    	ja     80080b <vprintfmt+0x3e7>
  800495:	8b 04 85 2c 17 80 00 	mov    0x80172c(,%eax,4),%eax
  80049c:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  80049e:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8004a2:	eb d6                	jmp    80047a <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a4:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8004a8:	eb d0                	jmp    80047a <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004aa:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8004b1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004b4:	89 d0                	mov    %edx,%eax
  8004b6:	c1 e0 02             	shl    $0x2,%eax
  8004b9:	01 d0                	add    %edx,%eax
  8004bb:	01 c0                	add    %eax,%eax
  8004bd:	01 d8                	add    %ebx,%eax
  8004bf:	83 e8 30             	sub    $0x30,%eax
  8004c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8004c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8004c8:	0f b6 00             	movzbl (%eax),%eax
  8004cb:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8004ce:	83 fb 2f             	cmp    $0x2f,%ebx
  8004d1:	7e 0b                	jle    8004de <vprintfmt+0xba>
  8004d3:	83 fb 39             	cmp    $0x39,%ebx
  8004d6:	7f 06                	jg     8004de <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d8:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004dc:	eb d3                	jmp    8004b1 <vprintfmt+0x8d>
			goto process_precision;
  8004de:	eb 33                	jmp    800513 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8d 50 04             	lea    0x4(%eax),%edx
  8004e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e9:	8b 00                	mov    (%eax),%eax
  8004eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8004ee:	eb 23                	jmp    800513 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8004f0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f4:	79 0c                	jns    800502 <vprintfmt+0xde>
				width = 0;
  8004f6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8004fd:	e9 78 ff ff ff       	jmp    80047a <vprintfmt+0x56>
  800502:	e9 73 ff ff ff       	jmp    80047a <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800507:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80050e:	e9 67 ff ff ff       	jmp    80047a <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800513:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800517:	79 12                	jns    80052b <vprintfmt+0x107>
				width = precision, precision = -1;
  800519:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80051c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80051f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800526:	e9 4f ff ff ff       	jmp    80047a <vprintfmt+0x56>
  80052b:	e9 4a ff ff ff       	jmp    80047a <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800530:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800534:	e9 41 ff ff ff       	jmp    80047a <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8d 50 04             	lea    0x4(%eax),%edx
  80053f:	89 55 14             	mov    %edx,0x14(%ebp)
  800542:	8b 00                	mov    (%eax),%eax
  800544:	8b 55 0c             	mov    0xc(%ebp),%edx
  800547:	89 54 24 04          	mov    %edx,0x4(%esp)
  80054b:	89 04 24             	mov    %eax,(%esp)
  80054e:	8b 45 08             	mov    0x8(%ebp),%eax
  800551:	ff d0                	call   *%eax
			break;
  800553:	e9 de 02 00 00       	jmp    800836 <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8d 50 04             	lea    0x4(%eax),%edx
  80055e:	89 55 14             	mov    %edx,0x14(%ebp)
  800561:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800563:	85 db                	test   %ebx,%ebx
  800565:	79 02                	jns    800569 <vprintfmt+0x145>
				err = -err;
  800567:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800569:	83 fb 09             	cmp    $0x9,%ebx
  80056c:	7f 0b                	jg     800579 <vprintfmt+0x155>
  80056e:	8b 34 9d e0 16 80 00 	mov    0x8016e0(,%ebx,4),%esi
  800575:	85 f6                	test   %esi,%esi
  800577:	75 23                	jne    80059c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800579:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80057d:	c7 44 24 08 19 17 80 	movl   $0x801719,0x8(%esp)
  800584:	00 
  800585:	8b 45 0c             	mov    0xc(%ebp),%eax
  800588:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058c:	8b 45 08             	mov    0x8(%ebp),%eax
  80058f:	89 04 24             	mov    %eax,(%esp)
  800592:	e8 ac 02 00 00       	call   800843 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800597:	e9 9a 02 00 00       	jmp    800836 <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80059c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005a0:	c7 44 24 08 22 17 80 	movl   $0x801722,0x8(%esp)
  8005a7:	00 
  8005a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005af:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b2:	89 04 24             	mov    %eax,(%esp)
  8005b5:	e8 89 02 00 00       	call   800843 <printfmt>
			break;
  8005ba:	e9 77 02 00 00       	jmp    800836 <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8d 50 04             	lea    0x4(%eax),%edx
  8005c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c8:	8b 30                	mov    (%eax),%esi
  8005ca:	85 f6                	test   %esi,%esi
  8005cc:	75 05                	jne    8005d3 <vprintfmt+0x1af>
				p = "(null)";
  8005ce:	be 25 17 80 00       	mov    $0x801725,%esi
			if (width > 0 && padc != '-')
  8005d3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d7:	7e 37                	jle    800610 <vprintfmt+0x1ec>
  8005d9:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8005dd:	74 31                	je     800610 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005df:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e6:	89 34 24             	mov    %esi,(%esp)
  8005e9:	e8 72 03 00 00       	call   800960 <strnlen>
  8005ee:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8005f1:	eb 17                	jmp    80060a <vprintfmt+0x1e6>
					putch(padc, putdat);
  8005f3:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8005f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005fe:	89 04 24             	mov    %eax,(%esp)
  800601:	8b 45 08             	mov    0x8(%ebp),%eax
  800604:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800606:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80060a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80060e:	7f e3                	jg     8005f3 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800610:	eb 38                	jmp    80064a <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800612:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800616:	74 1f                	je     800637 <vprintfmt+0x213>
  800618:	83 fb 1f             	cmp    $0x1f,%ebx
  80061b:	7e 05                	jle    800622 <vprintfmt+0x1fe>
  80061d:	83 fb 7e             	cmp    $0x7e,%ebx
  800620:	7e 15                	jle    800637 <vprintfmt+0x213>
					putch('?', putdat);
  800622:	8b 45 0c             	mov    0xc(%ebp),%eax
  800625:	89 44 24 04          	mov    %eax,0x4(%esp)
  800629:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800630:	8b 45 08             	mov    0x8(%ebp),%eax
  800633:	ff d0                	call   *%eax
  800635:	eb 0f                	jmp    800646 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800637:	8b 45 0c             	mov    0xc(%ebp),%eax
  80063a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063e:	89 1c 24             	mov    %ebx,(%esp)
  800641:	8b 45 08             	mov    0x8(%ebp),%eax
  800644:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800646:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80064a:	89 f0                	mov    %esi,%eax
  80064c:	8d 70 01             	lea    0x1(%eax),%esi
  80064f:	0f b6 00             	movzbl (%eax),%eax
  800652:	0f be d8             	movsbl %al,%ebx
  800655:	85 db                	test   %ebx,%ebx
  800657:	74 10                	je     800669 <vprintfmt+0x245>
  800659:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80065d:	78 b3                	js     800612 <vprintfmt+0x1ee>
  80065f:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800663:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800667:	79 a9                	jns    800612 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800669:	eb 17                	jmp    800682 <vprintfmt+0x25e>
				putch(' ', putdat);
  80066b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80066e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800672:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800679:	8b 45 08             	mov    0x8(%ebp),%eax
  80067c:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80067e:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800682:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800686:	7f e3                	jg     80066b <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800688:	e9 a9 01 00 00       	jmp    800836 <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80068d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800690:	89 44 24 04          	mov    %eax,0x4(%esp)
  800694:	8d 45 14             	lea    0x14(%ebp),%eax
  800697:	89 04 24             	mov    %eax,(%esp)
  80069a:	e8 3e fd ff ff       	call   8003dd <getint>
  80069f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006a2:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8006a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006ab:	85 d2                	test   %edx,%edx
  8006ad:	79 26                	jns    8006d5 <vprintfmt+0x2b1>
				putch('-', putdat);
  8006af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c0:	ff d0                	call   *%eax
				num = -(long long) num;
  8006c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006c8:	f7 d8                	neg    %eax
  8006ca:	83 d2 00             	adc    $0x0,%edx
  8006cd:	f7 da                	neg    %edx
  8006cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006d2:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8006d5:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006dc:	e9 e1 00 00 00       	jmp    8007c2 <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006eb:	89 04 24             	mov    %eax,(%esp)
  8006ee:	e8 9b fc ff ff       	call   80038e <getuint>
  8006f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006f6:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8006f9:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800700:	e9 bd 00 00 00       	jmp    8007c2 <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  800705:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  80070c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80070f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800713:	8d 45 14             	lea    0x14(%ebp),%eax
  800716:	89 04 24             	mov    %eax,(%esp)
  800719:	e8 70 fc ff ff       	call   80038e <getuint>
  80071e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800721:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  800724:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800728:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072b:	89 54 24 18          	mov    %edx,0x18(%esp)
  80072f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800732:	89 54 24 14          	mov    %edx,0x14(%esp)
  800736:	89 44 24 10          	mov    %eax,0x10(%esp)
  80073a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800740:	89 44 24 08          	mov    %eax,0x8(%esp)
  800744:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800748:	8b 45 0c             	mov    0xc(%ebp),%eax
  80074b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074f:	8b 45 08             	mov    0x8(%ebp),%eax
  800752:	89 04 24             	mov    %eax,(%esp)
  800755:	e8 56 fb ff ff       	call   8002b0 <printnum>
			break;
  80075a:	e9 d7 00 00 00       	jmp    800836 <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  80075f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800762:	89 44 24 04          	mov    %eax,0x4(%esp)
  800766:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80076d:	8b 45 08             	mov    0x8(%ebp),%eax
  800770:	ff d0                	call   *%eax
			putch('x', putdat);
  800772:	8b 45 0c             	mov    0xc(%ebp),%eax
  800775:	89 44 24 04          	mov    %eax,0x4(%esp)
  800779:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800780:	8b 45 08             	mov    0x8(%ebp),%eax
  800783:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800785:	8b 45 14             	mov    0x14(%ebp),%eax
  800788:	8d 50 04             	lea    0x4(%eax),%edx
  80078b:	89 55 14             	mov    %edx,0x14(%ebp)
  80078e:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800790:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800793:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80079a:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8007a1:	eb 1f                	jmp    8007c2 <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8007a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ad:	89 04 24             	mov    %eax,(%esp)
  8007b0:	e8 d9 fb ff ff       	call   80038e <getuint>
  8007b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007b8:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8007bb:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007c2:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8007c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c9:	89 54 24 18          	mov    %edx,0x18(%esp)
  8007cd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d0:	89 54 24 14          	mov    %edx,0x14(%esp)
  8007d4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f0:	89 04 24             	mov    %eax,(%esp)
  8007f3:	e8 b8 fa ff ff       	call   8002b0 <printnum>
			break;
  8007f8:	eb 3c                	jmp    800836 <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800801:	89 1c 24             	mov    %ebx,(%esp)
  800804:	8b 45 08             	mov    0x8(%ebp),%eax
  800807:	ff d0                	call   *%eax
			break;
  800809:	eb 2b                	jmp    800836 <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80080b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80080e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800812:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800819:	8b 45 08             	mov    0x8(%ebp),%eax
  80081c:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  80081e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800822:	eb 04                	jmp    800828 <vprintfmt+0x404>
  800824:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800828:	8b 45 10             	mov    0x10(%ebp),%eax
  80082b:	83 e8 01             	sub    $0x1,%eax
  80082e:	0f b6 00             	movzbl (%eax),%eax
  800831:	3c 25                	cmp    $0x25,%al
  800833:	75 ef                	jne    800824 <vprintfmt+0x400>
				/* do nothing */;
			break;
  800835:	90                   	nop
		}
	}
  800836:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800837:	e9 0a fc ff ff       	jmp    800446 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80083c:	83 c4 40             	add    $0x40,%esp
  80083f:	5b                   	pop    %ebx
  800840:	5e                   	pop    %esi
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800849:	8d 45 14             	lea    0x14(%ebp),%eax
  80084c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80084f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800852:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800856:	8b 45 10             	mov    0x10(%ebp),%eax
  800859:	89 44 24 08          	mov    %eax,0x8(%esp)
  80085d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800860:	89 44 24 04          	mov    %eax,0x4(%esp)
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	89 04 24             	mov    %eax,(%esp)
  80086a:	e8 b5 fb ff ff       	call   800424 <vprintfmt>
	va_end(ap);
}
  80086f:	c9                   	leave  
  800870:	c3                   	ret    

00800871 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800874:	8b 45 0c             	mov    0xc(%ebp),%eax
  800877:	8b 40 08             	mov    0x8(%eax),%eax
  80087a:	8d 50 01             	lea    0x1(%eax),%edx
  80087d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800880:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800883:	8b 45 0c             	mov    0xc(%ebp),%eax
  800886:	8b 10                	mov    (%eax),%edx
  800888:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088b:	8b 40 04             	mov    0x4(%eax),%eax
  80088e:	39 c2                	cmp    %eax,%edx
  800890:	73 12                	jae    8008a4 <sprintputch+0x33>
		*b->buf++ = ch;
  800892:	8b 45 0c             	mov    0xc(%ebp),%eax
  800895:	8b 00                	mov    (%eax),%eax
  800897:	8d 48 01             	lea    0x1(%eax),%ecx
  80089a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089d:	89 0a                	mov    %ecx,(%edx)
  80089f:	8b 55 08             	mov    0x8(%ebp),%edx
  8008a2:	88 10                	mov    %dl,(%eax)
}
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b5:	8d 50 ff             	lea    -0x1(%eax),%edx
  8008b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bb:	01 d0                	add    %edx,%eax
  8008bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008c7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8008cb:	74 06                	je     8008d3 <vsnprintf+0x2d>
  8008cd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008d1:	7f 07                	jg     8008da <vsnprintf+0x34>
		return -E_INVAL;
  8008d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d8:	eb 2a                	jmp    800904 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008da:	8b 45 14             	mov    0x14(%ebp),%eax
  8008dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8008e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008e8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ef:	c7 04 24 71 08 80 00 	movl   $0x800871,(%esp)
  8008f6:	e8 29 fb ff ff       	call   800424 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008fe:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800901:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800904:	c9                   	leave  
  800905:	c3                   	ret    

00800906 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80090c:	8d 45 14             	lea    0x14(%ebp),%eax
  80090f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800912:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800915:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800919:	8b 45 10             	mov    0x10(%ebp),%eax
  80091c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800920:	8b 45 0c             	mov    0xc(%ebp),%eax
  800923:	89 44 24 04          	mov    %eax,0x4(%esp)
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	89 04 24             	mov    %eax,(%esp)
  80092d:	e8 74 ff ff ff       	call   8008a6 <vsnprintf>
  800932:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800935:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800938:	c9                   	leave  
  800939:	c3                   	ret    

0080093a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800940:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800947:	eb 08                	jmp    800951 <strlen+0x17>
		n++;
  800949:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80094d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800951:	8b 45 08             	mov    0x8(%ebp),%eax
  800954:	0f b6 00             	movzbl (%eax),%eax
  800957:	84 c0                	test   %al,%al
  800959:	75 ee                	jne    800949 <strlen+0xf>
		n++;
	return n;
  80095b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80095e:	c9                   	leave  
  80095f:	c3                   	ret    

00800960 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800966:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80096d:	eb 0c                	jmp    80097b <strnlen+0x1b>
		n++;
  80096f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800973:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800977:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  80097b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80097f:	74 0a                	je     80098b <strnlen+0x2b>
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	0f b6 00             	movzbl (%eax),%eax
  800987:	84 c0                	test   %al,%al
  800989:	75 e4                	jne    80096f <strnlen+0xf>
		n++;
	return n;
  80098b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80098e:	c9                   	leave  
  80098f:	c3                   	ret    

00800990 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  80099c:	90                   	nop
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a0:	8d 50 01             	lea    0x1(%eax),%edx
  8009a3:	89 55 08             	mov    %edx,0x8(%ebp)
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009ac:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009af:	0f b6 12             	movzbl (%edx),%edx
  8009b2:	88 10                	mov    %dl,(%eax)
  8009b4:	0f b6 00             	movzbl (%eax),%eax
  8009b7:	84 c0                	test   %al,%al
  8009b9:	75 e2                	jne    80099d <strcpy+0xd>
		/* do nothing */;
	return ret;
  8009bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009be:	c9                   	leave  
  8009bf:	c3                   	ret    

008009c0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	89 04 24             	mov    %eax,(%esp)
  8009cc:	e8 69 ff ff ff       	call   80093a <strlen>
  8009d1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  8009d4:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	01 c2                	add    %eax,%edx
  8009dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e3:	89 14 24             	mov    %edx,(%esp)
  8009e6:	e8 a5 ff ff ff       	call   800990 <strcpy>
	return dst;
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8009ee:	c9                   	leave  
  8009ef:	c3                   	ret    

008009f0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f9:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8009fc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800a03:	eb 23                	jmp    800a28 <strncpy+0x38>
		*dst++ = *src;
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	8d 50 01             	lea    0x1(%eax),%edx
  800a0b:	89 55 08             	mov    %edx,0x8(%ebp)
  800a0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a11:	0f b6 12             	movzbl (%edx),%edx
  800a14:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800a16:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a19:	0f b6 00             	movzbl (%eax),%eax
  800a1c:	84 c0                	test   %al,%al
  800a1e:	74 04                	je     800a24 <strncpy+0x34>
			src++;
  800a20:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a24:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800a28:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a2b:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a2e:	72 d5                	jb     800a05 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800a30:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800a33:	c9                   	leave  
  800a34:	c3                   	ret    

00800a35 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800a41:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a45:	74 33                	je     800a7a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800a47:	eb 17                	jmp    800a60 <strlcpy+0x2b>
			*dst++ = *src++;
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8d 50 01             	lea    0x1(%eax),%edx
  800a4f:	89 55 08             	mov    %edx,0x8(%ebp)
  800a52:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a55:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a58:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a5b:	0f b6 12             	movzbl (%edx),%edx
  800a5e:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a60:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a64:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a68:	74 0a                	je     800a74 <strlcpy+0x3f>
  800a6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6d:	0f b6 00             	movzbl (%eax),%eax
  800a70:	84 c0                	test   %al,%al
  800a72:	75 d5                	jne    800a49 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800a74:	8b 45 08             	mov    0x8(%ebp),%eax
  800a77:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a80:	29 c2                	sub    %eax,%edx
  800a82:	89 d0                	mov    %edx,%eax
}
  800a84:	c9                   	leave  
  800a85:	c3                   	ret    

00800a86 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a89:	eb 08                	jmp    800a93 <strcmp+0xd>
		p++, q++;
  800a8b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a8f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a93:	8b 45 08             	mov    0x8(%ebp),%eax
  800a96:	0f b6 00             	movzbl (%eax),%eax
  800a99:	84 c0                	test   %al,%al
  800a9b:	74 10                	je     800aad <strcmp+0x27>
  800a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa0:	0f b6 10             	movzbl (%eax),%edx
  800aa3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa6:	0f b6 00             	movzbl (%eax),%eax
  800aa9:	38 c2                	cmp    %al,%dl
  800aab:	74 de                	je     800a8b <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aad:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab0:	0f b6 00             	movzbl (%eax),%eax
  800ab3:	0f b6 d0             	movzbl %al,%edx
  800ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab9:	0f b6 00             	movzbl (%eax),%eax
  800abc:	0f b6 c0             	movzbl %al,%eax
  800abf:	29 c2                	sub    %eax,%edx
  800ac1:	89 d0                	mov    %edx,%eax
}
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800ac8:	eb 0c                	jmp    800ad6 <strncmp+0x11>
		n--, p++, q++;
  800aca:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ace:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ad2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ad6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ada:	74 1a                	je     800af6 <strncmp+0x31>
  800adc:	8b 45 08             	mov    0x8(%ebp),%eax
  800adf:	0f b6 00             	movzbl (%eax),%eax
  800ae2:	84 c0                	test   %al,%al
  800ae4:	74 10                	je     800af6 <strncmp+0x31>
  800ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae9:	0f b6 10             	movzbl (%eax),%edx
  800aec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aef:	0f b6 00             	movzbl (%eax),%eax
  800af2:	38 c2                	cmp    %al,%dl
  800af4:	74 d4                	je     800aca <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800af6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800afa:	75 07                	jne    800b03 <strncmp+0x3e>
		return 0;
  800afc:	b8 00 00 00 00       	mov    $0x0,%eax
  800b01:	eb 16                	jmp    800b19 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b03:	8b 45 08             	mov    0x8(%ebp),%eax
  800b06:	0f b6 00             	movzbl (%eax),%eax
  800b09:	0f b6 d0             	movzbl %al,%edx
  800b0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0f:	0f b6 00             	movzbl (%eax),%eax
  800b12:	0f b6 c0             	movzbl %al,%eax
  800b15:	29 c2                	sub    %eax,%edx
  800b17:	89 d0                	mov    %edx,%eax
}
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	83 ec 04             	sub    $0x4,%esp
  800b21:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b24:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b27:	eb 14                	jmp    800b3d <strchr+0x22>
		if (*s == c)
  800b29:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2c:	0f b6 00             	movzbl (%eax),%eax
  800b2f:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b32:	75 05                	jne    800b39 <strchr+0x1e>
			return (char *) s;
  800b34:	8b 45 08             	mov    0x8(%ebp),%eax
  800b37:	eb 13                	jmp    800b4c <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b39:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b40:	0f b6 00             	movzbl (%eax),%eax
  800b43:	84 c0                	test   %al,%al
  800b45:	75 e2                	jne    800b29 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800b47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b4c:	c9                   	leave  
  800b4d:	c3                   	ret    

00800b4e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	83 ec 04             	sub    $0x4,%esp
  800b54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b57:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b5a:	eb 11                	jmp    800b6d <strfind+0x1f>
		if (*s == c)
  800b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5f:	0f b6 00             	movzbl (%eax),%eax
  800b62:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b65:	75 02                	jne    800b69 <strfind+0x1b>
			break;
  800b67:	eb 0e                	jmp    800b77 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b69:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b70:	0f b6 00             	movzbl (%eax),%eax
  800b73:	84 c0                	test   %al,%al
  800b75:	75 e5                	jne    800b5c <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800b77:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b7a:	c9                   	leave  
  800b7b:	c3                   	ret    

00800b7c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
	char *p;

	if (n == 0)
  800b80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b84:	75 05                	jne    800b8b <memset+0xf>
		return v;
  800b86:	8b 45 08             	mov    0x8(%ebp),%eax
  800b89:	eb 5c                	jmp    800be7 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8e:	83 e0 03             	and    $0x3,%eax
  800b91:	85 c0                	test   %eax,%eax
  800b93:	75 41                	jne    800bd6 <memset+0x5a>
  800b95:	8b 45 10             	mov    0x10(%ebp),%eax
  800b98:	83 e0 03             	and    $0x3,%eax
  800b9b:	85 c0                	test   %eax,%eax
  800b9d:	75 37                	jne    800bd6 <memset+0x5a>
		c &= 0xFF;
  800b9f:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ba6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba9:	c1 e0 18             	shl    $0x18,%eax
  800bac:	89 c2                	mov    %eax,%edx
  800bae:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb1:	c1 e0 10             	shl    $0x10,%eax
  800bb4:	09 c2                	or     %eax,%edx
  800bb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb9:	c1 e0 08             	shl    $0x8,%eax
  800bbc:	09 d0                	or     %edx,%eax
  800bbe:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bc1:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc4:	c1 e8 02             	shr    $0x2,%eax
  800bc7:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bcf:	89 d7                	mov    %edx,%edi
  800bd1:	fc                   	cld    
  800bd2:	f3 ab                	rep stos %eax,%es:(%edi)
  800bd4:	eb 0e                	jmp    800be4 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bdc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bdf:	89 d7                	mov    %edx,%edi
  800be1:	fc                   	cld    
  800be2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800be4:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800be7:	5f                   	pop    %edi
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
  800bf0:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800bf3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf6:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfc:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800bff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c02:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800c05:	73 6d                	jae    800c74 <memmove+0x8a>
  800c07:	8b 45 10             	mov    0x10(%ebp),%eax
  800c0a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c0d:	01 d0                	add    %edx,%eax
  800c0f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800c12:	76 60                	jbe    800c74 <memmove+0x8a>
		s += n;
  800c14:	8b 45 10             	mov    0x10(%ebp),%eax
  800c17:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800c1a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c1d:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c23:	83 e0 03             	and    $0x3,%eax
  800c26:	85 c0                	test   %eax,%eax
  800c28:	75 2f                	jne    800c59 <memmove+0x6f>
  800c2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c2d:	83 e0 03             	and    $0x3,%eax
  800c30:	85 c0                	test   %eax,%eax
  800c32:	75 25                	jne    800c59 <memmove+0x6f>
  800c34:	8b 45 10             	mov    0x10(%ebp),%eax
  800c37:	83 e0 03             	and    $0x3,%eax
  800c3a:	85 c0                	test   %eax,%eax
  800c3c:	75 1b                	jne    800c59 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c41:	83 e8 04             	sub    $0x4,%eax
  800c44:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c47:	83 ea 04             	sub    $0x4,%edx
  800c4a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c4d:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c50:	89 c7                	mov    %eax,%edi
  800c52:	89 d6                	mov    %edx,%esi
  800c54:	fd                   	std    
  800c55:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c57:	eb 18                	jmp    800c71 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c59:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c5c:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c62:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c65:	8b 45 10             	mov    0x10(%ebp),%eax
  800c68:	89 d7                	mov    %edx,%edi
  800c6a:	89 de                	mov    %ebx,%esi
  800c6c:	89 c1                	mov    %eax,%ecx
  800c6e:	fd                   	std    
  800c6f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c71:	fc                   	cld    
  800c72:	eb 45                	jmp    800cb9 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c74:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c77:	83 e0 03             	and    $0x3,%eax
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	75 2b                	jne    800ca9 <memmove+0xbf>
  800c7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c81:	83 e0 03             	and    $0x3,%eax
  800c84:	85 c0                	test   %eax,%eax
  800c86:	75 21                	jne    800ca9 <memmove+0xbf>
  800c88:	8b 45 10             	mov    0x10(%ebp),%eax
  800c8b:	83 e0 03             	and    $0x3,%eax
  800c8e:	85 c0                	test   %eax,%eax
  800c90:	75 17                	jne    800ca9 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c92:	8b 45 10             	mov    0x10(%ebp),%eax
  800c95:	c1 e8 02             	shr    $0x2,%eax
  800c98:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c9d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ca0:	89 c7                	mov    %eax,%edi
  800ca2:	89 d6                	mov    %edx,%esi
  800ca4:	fc                   	cld    
  800ca5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ca7:	eb 10                	jmp    800cb9 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ca9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800caf:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800cb2:	89 c7                	mov    %eax,%edi
  800cb4:	89 d6                	mov    %edx,%esi
  800cb6:	fc                   	cld    
  800cb7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800cb9:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cbc:	83 c4 10             	add    $0x10,%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cca:	8b 45 10             	mov    0x10(%ebp),%eax
  800ccd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdb:	89 04 24             	mov    %eax,(%esp)
  800cde:	e8 07 ff ff ff       	call   800bea <memmove>
}
  800ce3:	c9                   	leave  
  800ce4:	c3                   	ret    

00800ce5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cee:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf4:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800cf7:	eb 30                	jmp    800d29 <memcmp+0x44>
		if (*s1 != *s2)
  800cf9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cfc:	0f b6 10             	movzbl (%eax),%edx
  800cff:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d02:	0f b6 00             	movzbl (%eax),%eax
  800d05:	38 c2                	cmp    %al,%dl
  800d07:	74 18                	je     800d21 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800d09:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d0c:	0f b6 00             	movzbl (%eax),%eax
  800d0f:	0f b6 d0             	movzbl %al,%edx
  800d12:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d15:	0f b6 00             	movzbl (%eax),%eax
  800d18:	0f b6 c0             	movzbl %al,%eax
  800d1b:	29 c2                	sub    %eax,%edx
  800d1d:	89 d0                	mov    %edx,%eax
  800d1f:	eb 1a                	jmp    800d3b <memcmp+0x56>
		s1++, s2++;
  800d21:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d25:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d29:	8b 45 10             	mov    0x10(%ebp),%eax
  800d2c:	8d 50 ff             	lea    -0x1(%eax),%edx
  800d2f:	89 55 10             	mov    %edx,0x10(%ebp)
  800d32:	85 c0                	test   %eax,%eax
  800d34:	75 c3                	jne    800cf9 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d36:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d3b:	c9                   	leave  
  800d3c:	c3                   	ret    

00800d3d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800d43:	8b 45 10             	mov    0x10(%ebp),%eax
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	01 d0                	add    %edx,%eax
  800d4b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800d4e:	eb 13                	jmp    800d63 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d50:	8b 45 08             	mov    0x8(%ebp),%eax
  800d53:	0f b6 10             	movzbl (%eax),%edx
  800d56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d59:	38 c2                	cmp    %al,%dl
  800d5b:	75 02                	jne    800d5f <memfind+0x22>
			break;
  800d5d:	eb 0c                	jmp    800d6b <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d5f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d63:	8b 45 08             	mov    0x8(%ebp),%eax
  800d66:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800d69:	72 e5                	jb     800d50 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800d6b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d6e:	c9                   	leave  
  800d6f:	c3                   	ret    

00800d70 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800d76:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800d7d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d84:	eb 04                	jmp    800d8a <strtol+0x1a>
		s++;
  800d86:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8d:	0f b6 00             	movzbl (%eax),%eax
  800d90:	3c 20                	cmp    $0x20,%al
  800d92:	74 f2                	je     800d86 <strtol+0x16>
  800d94:	8b 45 08             	mov    0x8(%ebp),%eax
  800d97:	0f b6 00             	movzbl (%eax),%eax
  800d9a:	3c 09                	cmp    $0x9,%al
  800d9c:	74 e8                	je     800d86 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800da1:	0f b6 00             	movzbl (%eax),%eax
  800da4:	3c 2b                	cmp    $0x2b,%al
  800da6:	75 06                	jne    800dae <strtol+0x3e>
		s++;
  800da8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dac:	eb 15                	jmp    800dc3 <strtol+0x53>
	else if (*s == '-')
  800dae:	8b 45 08             	mov    0x8(%ebp),%eax
  800db1:	0f b6 00             	movzbl (%eax),%eax
  800db4:	3c 2d                	cmp    $0x2d,%al
  800db6:	75 0b                	jne    800dc3 <strtol+0x53>
		s++, neg = 1;
  800db8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dbc:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dc3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dc7:	74 06                	je     800dcf <strtol+0x5f>
  800dc9:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800dcd:	75 24                	jne    800df3 <strtol+0x83>
  800dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd2:	0f b6 00             	movzbl (%eax),%eax
  800dd5:	3c 30                	cmp    $0x30,%al
  800dd7:	75 1a                	jne    800df3 <strtol+0x83>
  800dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddc:	83 c0 01             	add    $0x1,%eax
  800ddf:	0f b6 00             	movzbl (%eax),%eax
  800de2:	3c 78                	cmp    $0x78,%al
  800de4:	75 0d                	jne    800df3 <strtol+0x83>
		s += 2, base = 16;
  800de6:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800dea:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800df1:	eb 2a                	jmp    800e1d <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800df3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800df7:	75 17                	jne    800e10 <strtol+0xa0>
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfc:	0f b6 00             	movzbl (%eax),%eax
  800dff:	3c 30                	cmp    $0x30,%al
  800e01:	75 0d                	jne    800e10 <strtol+0xa0>
		s++, base = 8;
  800e03:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e07:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800e0e:	eb 0d                	jmp    800e1d <strtol+0xad>
	else if (base == 0)
  800e10:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e14:	75 07                	jne    800e1d <strtol+0xad>
		base = 10;
  800e16:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e20:	0f b6 00             	movzbl (%eax),%eax
  800e23:	3c 2f                	cmp    $0x2f,%al
  800e25:	7e 1b                	jle    800e42 <strtol+0xd2>
  800e27:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2a:	0f b6 00             	movzbl (%eax),%eax
  800e2d:	3c 39                	cmp    $0x39,%al
  800e2f:	7f 11                	jg     800e42 <strtol+0xd2>
			dig = *s - '0';
  800e31:	8b 45 08             	mov    0x8(%ebp),%eax
  800e34:	0f b6 00             	movzbl (%eax),%eax
  800e37:	0f be c0             	movsbl %al,%eax
  800e3a:	83 e8 30             	sub    $0x30,%eax
  800e3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e40:	eb 48                	jmp    800e8a <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800e42:	8b 45 08             	mov    0x8(%ebp),%eax
  800e45:	0f b6 00             	movzbl (%eax),%eax
  800e48:	3c 60                	cmp    $0x60,%al
  800e4a:	7e 1b                	jle    800e67 <strtol+0xf7>
  800e4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4f:	0f b6 00             	movzbl (%eax),%eax
  800e52:	3c 7a                	cmp    $0x7a,%al
  800e54:	7f 11                	jg     800e67 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800e56:	8b 45 08             	mov    0x8(%ebp),%eax
  800e59:	0f b6 00             	movzbl (%eax),%eax
  800e5c:	0f be c0             	movsbl %al,%eax
  800e5f:	83 e8 57             	sub    $0x57,%eax
  800e62:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e65:	eb 23                	jmp    800e8a <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800e67:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6a:	0f b6 00             	movzbl (%eax),%eax
  800e6d:	3c 40                	cmp    $0x40,%al
  800e6f:	7e 3d                	jle    800eae <strtol+0x13e>
  800e71:	8b 45 08             	mov    0x8(%ebp),%eax
  800e74:	0f b6 00             	movzbl (%eax),%eax
  800e77:	3c 5a                	cmp    $0x5a,%al
  800e79:	7f 33                	jg     800eae <strtol+0x13e>
			dig = *s - 'A' + 10;
  800e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7e:	0f b6 00             	movzbl (%eax),%eax
  800e81:	0f be c0             	movsbl %al,%eax
  800e84:	83 e8 37             	sub    $0x37,%eax
  800e87:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e8d:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e90:	7c 02                	jl     800e94 <strtol+0x124>
			break;
  800e92:	eb 1a                	jmp    800eae <strtol+0x13e>
		s++, val = (val * base) + dig;
  800e94:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e98:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e9b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e9f:	89 c2                	mov    %eax,%edx
  800ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea4:	01 d0                	add    %edx,%eax
  800ea6:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800ea9:	e9 6f ff ff ff       	jmp    800e1d <strtol+0xad>

	if (endptr)
  800eae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800eb2:	74 08                	je     800ebc <strtol+0x14c>
		*endptr = (char *) s;
  800eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eba:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ebc:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800ec0:	74 07                	je     800ec9 <strtol+0x159>
  800ec2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ec5:	f7 d8                	neg    %eax
  800ec7:	eb 03                	jmp    800ecc <strtol+0x15c>
  800ec9:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800ecc:	c9                   	leave  
  800ecd:	c3                   	ret    

00800ece <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	57                   	push   %edi
  800ed2:	56                   	push   %esi
  800ed3:	53                   	push   %ebx
  800ed4:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eda:	8b 55 10             	mov    0x10(%ebp),%edx
  800edd:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800ee0:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800ee3:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800ee6:	8b 75 20             	mov    0x20(%ebp),%esi
  800ee9:	cd 30                	int    $0x30
  800eeb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ef2:	74 30                	je     800f24 <syscall+0x56>
  800ef4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ef8:	7e 2a                	jle    800f24 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800efa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800efd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f01:	8b 45 08             	mov    0x8(%ebp),%eax
  800f04:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f08:	c7 44 24 08 84 18 80 	movl   $0x801884,0x8(%esp)
  800f0f:	00 
  800f10:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f17:	00 
  800f18:	c7 04 24 a1 18 80 00 	movl   $0x8018a1,(%esp)
  800f1f:	e8 4b f2 ff ff       	call   80016f <_panic>

	return ret;
  800f24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800f27:	83 c4 3c             	add    $0x3c,%esp
  800f2a:	5b                   	pop    %ebx
  800f2b:	5e                   	pop    %esi
  800f2c:	5f                   	pop    %edi
  800f2d:	5d                   	pop    %ebp
  800f2e:	c3                   	ret    

00800f2f <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800f35:	8b 45 08             	mov    0x8(%ebp),%eax
  800f38:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f3f:	00 
  800f40:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f47:	00 
  800f48:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f4f:	00 
  800f50:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f53:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f57:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f5b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f62:	00 
  800f63:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f6a:	e8 5f ff ff ff       	call   800ece <syscall>
}
  800f6f:	c9                   	leave  
  800f70:	c3                   	ret    

00800f71 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f77:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f7e:	00 
  800f7f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f86:	00 
  800f87:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f8e:	00 
  800f8f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f96:	00 
  800f97:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f9e:	00 
  800f9f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fa6:	00 
  800fa7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800fae:	e8 1b ff ff ff       	call   800ece <syscall>
}
  800fb3:	c9                   	leave  
  800fb4:	c3                   	ret    

00800fb5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbe:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fc5:	00 
  800fc6:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fcd:	00 
  800fce:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fd5:	00 
  800fd6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fdd:	00 
  800fde:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fe2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fe9:	00 
  800fea:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800ff1:	e8 d8 fe ff ff       	call   800ece <syscall>
}
  800ff6:	c9                   	leave  
  800ff7:	c3                   	ret    

00800ff8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800ffe:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801005:	00 
  801006:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80100d:	00 
  80100e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801015:	00 
  801016:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80101d:	00 
  80101e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801025:	00 
  801026:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80102d:	00 
  80102e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801035:	e8 94 fe ff ff       	call   800ece <syscall>
}
  80103a:	c9                   	leave  
  80103b:	c3                   	ret    

0080103c <sys_yield>:

void
sys_yield(void)
{
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801042:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801049:	00 
  80104a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801051:	00 
  801052:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801059:	00 
  80105a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801061:	00 
  801062:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801069:	00 
  80106a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801071:	00 
  801072:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  801079:	e8 50 fe ff ff       	call   800ece <syscall>
}
  80107e:	c9                   	leave  
  80107f:	c3                   	ret    

00801080 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801086:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801089:	8b 55 0c             	mov    0xc(%ebp),%edx
  80108c:	8b 45 08             	mov    0x8(%ebp),%eax
  80108f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801096:	00 
  801097:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80109e:	00 
  80109f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8010a3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010ab:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010b2:	00 
  8010b3:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  8010ba:	e8 0f fe ff ff       	call   800ece <syscall>
}
  8010bf:	c9                   	leave  
  8010c0:	c3                   	ret    

008010c1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	56                   	push   %esi
  8010c5:	53                   	push   %ebx
  8010c6:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8010c9:	8b 75 18             	mov    0x18(%ebp),%esi
  8010cc:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8010dc:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8010e0:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8010e4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010ec:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010f3:	00 
  8010f4:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8010fb:	e8 ce fd ff ff       	call   800ece <syscall>
}
  801100:	83 c4 20             	add    $0x20,%esp
  801103:	5b                   	pop    %ebx
  801104:	5e                   	pop    %esi
  801105:	5d                   	pop    %ebp
  801106:	c3                   	ret    

00801107 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80110d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801110:	8b 45 08             	mov    0x8(%ebp),%eax
  801113:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80111a:	00 
  80111b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801122:	00 
  801123:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80112a:	00 
  80112b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80112f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801133:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80113a:	00 
  80113b:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801142:	e8 87 fd ff ff       	call   800ece <syscall>
}
  801147:	c9                   	leave  
  801148:	c3                   	ret    

00801149 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80114f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801152:	8b 45 08             	mov    0x8(%ebp),%eax
  801155:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80115c:	00 
  80115d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801164:	00 
  801165:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80116c:	00 
  80116d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801171:	89 44 24 08          	mov    %eax,0x8(%esp)
  801175:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80117c:	00 
  80117d:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801184:	e8 45 fd ff ff       	call   800ece <syscall>
}
  801189:	c9                   	leave  
  80118a:	c3                   	ret    

0080118b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80118b:	55                   	push   %ebp
  80118c:	89 e5                	mov    %esp,%ebp
  80118e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801191:	8b 55 0c             	mov    0xc(%ebp),%edx
  801194:	8b 45 08             	mov    0x8(%ebp),%eax
  801197:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80119e:	00 
  80119f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011a6:	00 
  8011a7:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011ae:	00 
  8011af:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011be:	00 
  8011bf:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8011c6:	e8 03 fd ff ff       	call   800ece <syscall>
}
  8011cb:	c9                   	leave  
  8011cc:	c3                   	ret    

008011cd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8011d3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8011d6:	8b 55 10             	mov    0x10(%ebp),%edx
  8011d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011dc:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011e3:	00 
  8011e4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8011e8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011fe:	00 
  8011ff:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  801206:	e8 c3 fc ff ff       	call   800ece <syscall>
}
  80120b:	c9                   	leave  
  80120c:	c3                   	ret    

0080120d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801213:	8b 45 08             	mov    0x8(%ebp),%eax
  801216:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80121d:	00 
  80121e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801225:	00 
  801226:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80122d:	00 
  80122e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801235:	00 
  801236:	89 44 24 08          	mov    %eax,0x8(%esp)
  80123a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801241:	00 
  801242:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801249:	e8 80 fc ff ff       	call   800ece <syscall>
}
  80124e:	c9                   	leave  
  80124f:	c3                   	ret    

00801250 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  801256:	a1 08 20 80 00       	mov    0x802008,%eax
  80125b:	85 c0                	test   %eax,%eax
  80125d:	75 55                	jne    8012b4 <set_pgfault_handler+0x64>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE),PTE_U|PTE_P|PTE_W);
  80125f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801266:	00 
  801267:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80126e:	ee 
  80126f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801276:	e8 05 fe ff ff       	call   801080 <sys_page_alloc>
  80127b:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(r < 0)
  80127e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801282:	79 1c                	jns    8012a0 <set_pgfault_handler+0x50>
		{
			panic("sys_page_alloc_failed");
  801284:	c7 44 24 08 af 18 80 	movl   $0x8018af,0x8(%esp)
  80128b:	00 
  80128c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801293:	00 
  801294:	c7 04 24 c5 18 80 00 	movl   $0x8018c5,(%esp)
  80129b:	e8 cf ee ff ff       	call   80016f <_panic>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8012a0:	c7 44 24 04 be 12 80 	movl   $0x8012be,0x4(%esp)
  8012a7:	00 
  8012a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012af:	e8 d7 fe ff ff       	call   80118b <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b7:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8012bc:	c9                   	leave  
  8012bd:	c3                   	ret    

008012be <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012be:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012bf:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8012c4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012c6:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x30(%esp), %eax
  8012c9:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  8012cd:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8012d0:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 0x28(%esp), %ecx
  8012d4:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	movl %ecx, (%eax)
  8012d8:	89 08                	mov    %ecx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	//add $8, %esp
	popl %edx 
  8012da:	5a                   	pop    %edx
	popl %edx
  8012db:	5a                   	pop    %edx
	popal
  8012dc:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp
  8012dd:	83 c4 04             	add    $0x4,%esp
	popf
  8012e0:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8012e1:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8012e2:	c3                   	ret    
  8012e3:	66 90                	xchg   %ax,%ax
  8012e5:	66 90                	xchg   %ax,%ax
  8012e7:	66 90                	xchg   %ax,%ax
  8012e9:	66 90                	xchg   %ax,%ax
  8012eb:	66 90                	xchg   %ax,%ax
  8012ed:	66 90                	xchg   %ax,%ax
  8012ef:	90                   	nop

008012f0 <__udivdi3>:
  8012f0:	55                   	push   %ebp
  8012f1:	57                   	push   %edi
  8012f2:	56                   	push   %esi
  8012f3:	83 ec 0c             	sub    $0xc,%esp
  8012f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012fa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8012fe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801302:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801306:	85 c0                	test   %eax,%eax
  801308:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80130c:	89 ea                	mov    %ebp,%edx
  80130e:	89 0c 24             	mov    %ecx,(%esp)
  801311:	75 2d                	jne    801340 <__udivdi3+0x50>
  801313:	39 e9                	cmp    %ebp,%ecx
  801315:	77 61                	ja     801378 <__udivdi3+0x88>
  801317:	85 c9                	test   %ecx,%ecx
  801319:	89 ce                	mov    %ecx,%esi
  80131b:	75 0b                	jne    801328 <__udivdi3+0x38>
  80131d:	b8 01 00 00 00       	mov    $0x1,%eax
  801322:	31 d2                	xor    %edx,%edx
  801324:	f7 f1                	div    %ecx
  801326:	89 c6                	mov    %eax,%esi
  801328:	31 d2                	xor    %edx,%edx
  80132a:	89 e8                	mov    %ebp,%eax
  80132c:	f7 f6                	div    %esi
  80132e:	89 c5                	mov    %eax,%ebp
  801330:	89 f8                	mov    %edi,%eax
  801332:	f7 f6                	div    %esi
  801334:	89 ea                	mov    %ebp,%edx
  801336:	83 c4 0c             	add    $0xc,%esp
  801339:	5e                   	pop    %esi
  80133a:	5f                   	pop    %edi
  80133b:	5d                   	pop    %ebp
  80133c:	c3                   	ret    
  80133d:	8d 76 00             	lea    0x0(%esi),%esi
  801340:	39 e8                	cmp    %ebp,%eax
  801342:	77 24                	ja     801368 <__udivdi3+0x78>
  801344:	0f bd e8             	bsr    %eax,%ebp
  801347:	83 f5 1f             	xor    $0x1f,%ebp
  80134a:	75 3c                	jne    801388 <__udivdi3+0x98>
  80134c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801350:	39 34 24             	cmp    %esi,(%esp)
  801353:	0f 86 9f 00 00 00    	jbe    8013f8 <__udivdi3+0x108>
  801359:	39 d0                	cmp    %edx,%eax
  80135b:	0f 82 97 00 00 00    	jb     8013f8 <__udivdi3+0x108>
  801361:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801368:	31 d2                	xor    %edx,%edx
  80136a:	31 c0                	xor    %eax,%eax
  80136c:	83 c4 0c             	add    $0xc,%esp
  80136f:	5e                   	pop    %esi
  801370:	5f                   	pop    %edi
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    
  801373:	90                   	nop
  801374:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801378:	89 f8                	mov    %edi,%eax
  80137a:	f7 f1                	div    %ecx
  80137c:	31 d2                	xor    %edx,%edx
  80137e:	83 c4 0c             	add    $0xc,%esp
  801381:	5e                   	pop    %esi
  801382:	5f                   	pop    %edi
  801383:	5d                   	pop    %ebp
  801384:	c3                   	ret    
  801385:	8d 76 00             	lea    0x0(%esi),%esi
  801388:	89 e9                	mov    %ebp,%ecx
  80138a:	8b 3c 24             	mov    (%esp),%edi
  80138d:	d3 e0                	shl    %cl,%eax
  80138f:	89 c6                	mov    %eax,%esi
  801391:	b8 20 00 00 00       	mov    $0x20,%eax
  801396:	29 e8                	sub    %ebp,%eax
  801398:	89 c1                	mov    %eax,%ecx
  80139a:	d3 ef                	shr    %cl,%edi
  80139c:	89 e9                	mov    %ebp,%ecx
  80139e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8013a2:	8b 3c 24             	mov    (%esp),%edi
  8013a5:	09 74 24 08          	or     %esi,0x8(%esp)
  8013a9:	89 d6                	mov    %edx,%esi
  8013ab:	d3 e7                	shl    %cl,%edi
  8013ad:	89 c1                	mov    %eax,%ecx
  8013af:	89 3c 24             	mov    %edi,(%esp)
  8013b2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013b6:	d3 ee                	shr    %cl,%esi
  8013b8:	89 e9                	mov    %ebp,%ecx
  8013ba:	d3 e2                	shl    %cl,%edx
  8013bc:	89 c1                	mov    %eax,%ecx
  8013be:	d3 ef                	shr    %cl,%edi
  8013c0:	09 d7                	or     %edx,%edi
  8013c2:	89 f2                	mov    %esi,%edx
  8013c4:	89 f8                	mov    %edi,%eax
  8013c6:	f7 74 24 08          	divl   0x8(%esp)
  8013ca:	89 d6                	mov    %edx,%esi
  8013cc:	89 c7                	mov    %eax,%edi
  8013ce:	f7 24 24             	mull   (%esp)
  8013d1:	39 d6                	cmp    %edx,%esi
  8013d3:	89 14 24             	mov    %edx,(%esp)
  8013d6:	72 30                	jb     801408 <__udivdi3+0x118>
  8013d8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013dc:	89 e9                	mov    %ebp,%ecx
  8013de:	d3 e2                	shl    %cl,%edx
  8013e0:	39 c2                	cmp    %eax,%edx
  8013e2:	73 05                	jae    8013e9 <__udivdi3+0xf9>
  8013e4:	3b 34 24             	cmp    (%esp),%esi
  8013e7:	74 1f                	je     801408 <__udivdi3+0x118>
  8013e9:	89 f8                	mov    %edi,%eax
  8013eb:	31 d2                	xor    %edx,%edx
  8013ed:	e9 7a ff ff ff       	jmp    80136c <__udivdi3+0x7c>
  8013f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013f8:	31 d2                	xor    %edx,%edx
  8013fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8013ff:	e9 68 ff ff ff       	jmp    80136c <__udivdi3+0x7c>
  801404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801408:	8d 47 ff             	lea    -0x1(%edi),%eax
  80140b:	31 d2                	xor    %edx,%edx
  80140d:	83 c4 0c             	add    $0xc,%esp
  801410:	5e                   	pop    %esi
  801411:	5f                   	pop    %edi
  801412:	5d                   	pop    %ebp
  801413:	c3                   	ret    
  801414:	66 90                	xchg   %ax,%ax
  801416:	66 90                	xchg   %ax,%ax
  801418:	66 90                	xchg   %ax,%ax
  80141a:	66 90                	xchg   %ax,%ax
  80141c:	66 90                	xchg   %ax,%ax
  80141e:	66 90                	xchg   %ax,%ax

00801420 <__umoddi3>:
  801420:	55                   	push   %ebp
  801421:	57                   	push   %edi
  801422:	56                   	push   %esi
  801423:	83 ec 14             	sub    $0x14,%esp
  801426:	8b 44 24 28          	mov    0x28(%esp),%eax
  80142a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80142e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801432:	89 c7                	mov    %eax,%edi
  801434:	89 44 24 04          	mov    %eax,0x4(%esp)
  801438:	8b 44 24 30          	mov    0x30(%esp),%eax
  80143c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801440:	89 34 24             	mov    %esi,(%esp)
  801443:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801447:	85 c0                	test   %eax,%eax
  801449:	89 c2                	mov    %eax,%edx
  80144b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80144f:	75 17                	jne    801468 <__umoddi3+0x48>
  801451:	39 fe                	cmp    %edi,%esi
  801453:	76 4b                	jbe    8014a0 <__umoddi3+0x80>
  801455:	89 c8                	mov    %ecx,%eax
  801457:	89 fa                	mov    %edi,%edx
  801459:	f7 f6                	div    %esi
  80145b:	89 d0                	mov    %edx,%eax
  80145d:	31 d2                	xor    %edx,%edx
  80145f:	83 c4 14             	add    $0x14,%esp
  801462:	5e                   	pop    %esi
  801463:	5f                   	pop    %edi
  801464:	5d                   	pop    %ebp
  801465:	c3                   	ret    
  801466:	66 90                	xchg   %ax,%ax
  801468:	39 f8                	cmp    %edi,%eax
  80146a:	77 54                	ja     8014c0 <__umoddi3+0xa0>
  80146c:	0f bd e8             	bsr    %eax,%ebp
  80146f:	83 f5 1f             	xor    $0x1f,%ebp
  801472:	75 5c                	jne    8014d0 <__umoddi3+0xb0>
  801474:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801478:	39 3c 24             	cmp    %edi,(%esp)
  80147b:	0f 87 e7 00 00 00    	ja     801568 <__umoddi3+0x148>
  801481:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801485:	29 f1                	sub    %esi,%ecx
  801487:	19 c7                	sbb    %eax,%edi
  801489:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80148d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801491:	8b 44 24 08          	mov    0x8(%esp),%eax
  801495:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801499:	83 c4 14             	add    $0x14,%esp
  80149c:	5e                   	pop    %esi
  80149d:	5f                   	pop    %edi
  80149e:	5d                   	pop    %ebp
  80149f:	c3                   	ret    
  8014a0:	85 f6                	test   %esi,%esi
  8014a2:	89 f5                	mov    %esi,%ebp
  8014a4:	75 0b                	jne    8014b1 <__umoddi3+0x91>
  8014a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ab:	31 d2                	xor    %edx,%edx
  8014ad:	f7 f6                	div    %esi
  8014af:	89 c5                	mov    %eax,%ebp
  8014b1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8014b5:	31 d2                	xor    %edx,%edx
  8014b7:	f7 f5                	div    %ebp
  8014b9:	89 c8                	mov    %ecx,%eax
  8014bb:	f7 f5                	div    %ebp
  8014bd:	eb 9c                	jmp    80145b <__umoddi3+0x3b>
  8014bf:	90                   	nop
  8014c0:	89 c8                	mov    %ecx,%eax
  8014c2:	89 fa                	mov    %edi,%edx
  8014c4:	83 c4 14             	add    $0x14,%esp
  8014c7:	5e                   	pop    %esi
  8014c8:	5f                   	pop    %edi
  8014c9:	5d                   	pop    %ebp
  8014ca:	c3                   	ret    
  8014cb:	90                   	nop
  8014cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014d0:	8b 04 24             	mov    (%esp),%eax
  8014d3:	be 20 00 00 00       	mov    $0x20,%esi
  8014d8:	89 e9                	mov    %ebp,%ecx
  8014da:	29 ee                	sub    %ebp,%esi
  8014dc:	d3 e2                	shl    %cl,%edx
  8014de:	89 f1                	mov    %esi,%ecx
  8014e0:	d3 e8                	shr    %cl,%eax
  8014e2:	89 e9                	mov    %ebp,%ecx
  8014e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e8:	8b 04 24             	mov    (%esp),%eax
  8014eb:	09 54 24 04          	or     %edx,0x4(%esp)
  8014ef:	89 fa                	mov    %edi,%edx
  8014f1:	d3 e0                	shl    %cl,%eax
  8014f3:	89 f1                	mov    %esi,%ecx
  8014f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014f9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8014fd:	d3 ea                	shr    %cl,%edx
  8014ff:	89 e9                	mov    %ebp,%ecx
  801501:	d3 e7                	shl    %cl,%edi
  801503:	89 f1                	mov    %esi,%ecx
  801505:	d3 e8                	shr    %cl,%eax
  801507:	89 e9                	mov    %ebp,%ecx
  801509:	09 f8                	or     %edi,%eax
  80150b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80150f:	f7 74 24 04          	divl   0x4(%esp)
  801513:	d3 e7                	shl    %cl,%edi
  801515:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801519:	89 d7                	mov    %edx,%edi
  80151b:	f7 64 24 08          	mull   0x8(%esp)
  80151f:	39 d7                	cmp    %edx,%edi
  801521:	89 c1                	mov    %eax,%ecx
  801523:	89 14 24             	mov    %edx,(%esp)
  801526:	72 2c                	jb     801554 <__umoddi3+0x134>
  801528:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80152c:	72 22                	jb     801550 <__umoddi3+0x130>
  80152e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801532:	29 c8                	sub    %ecx,%eax
  801534:	19 d7                	sbb    %edx,%edi
  801536:	89 e9                	mov    %ebp,%ecx
  801538:	89 fa                	mov    %edi,%edx
  80153a:	d3 e8                	shr    %cl,%eax
  80153c:	89 f1                	mov    %esi,%ecx
  80153e:	d3 e2                	shl    %cl,%edx
  801540:	89 e9                	mov    %ebp,%ecx
  801542:	d3 ef                	shr    %cl,%edi
  801544:	09 d0                	or     %edx,%eax
  801546:	89 fa                	mov    %edi,%edx
  801548:	83 c4 14             	add    $0x14,%esp
  80154b:	5e                   	pop    %esi
  80154c:	5f                   	pop    %edi
  80154d:	5d                   	pop    %ebp
  80154e:	c3                   	ret    
  80154f:	90                   	nop
  801550:	39 d7                	cmp    %edx,%edi
  801552:	75 da                	jne    80152e <__umoddi3+0x10e>
  801554:	8b 14 24             	mov    (%esp),%edx
  801557:	89 c1                	mov    %eax,%ecx
  801559:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80155d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801561:	eb cb                	jmp    80152e <__umoddi3+0x10e>
  801563:	90                   	nop
  801564:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801568:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80156c:	0f 82 0f ff ff ff    	jb     801481 <__umoddi3+0x61>
  801572:	e9 1a ff ff ff       	jmp    801491 <__umoddi3+0x71>
