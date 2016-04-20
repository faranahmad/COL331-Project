
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 c8 00 00 00       	call   8000f9 <libmain>
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
  800048:	c7 04 24 60 15 80 00 	movl   $0x801560,(%esp)
  80004f:	e8 22 02 00 00       	call   800276 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800054:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800057:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80005a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80005d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800062:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800069:	00 
  80006a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800075:	e8 f2 0f 00 00       	call   80106c <sys_page_alloc>
  80007a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80007d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800081:	79 2a                	jns    8000ad <handler+0x7a>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800083:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800086:	89 44 24 10          	mov    %eax,0x10(%esp)
  80008a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80008d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800091:	c7 44 24 08 6c 15 80 	movl   $0x80156c,0x8(%esp)
  800098:	00 
  800099:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000a0:	00 
  8000a1:	c7 04 24 97 15 80 00 	movl   $0x801597,(%esp)
  8000a8:	e8 ae 00 00 00       	call   80015b <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  8000ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b4:	c7 44 24 08 ac 15 80 	movl   $0x8015ac,0x8(%esp)
  8000bb:	00 
  8000bc:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000c3:	00 
  8000c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000c7:	89 04 24             	mov    %eax,(%esp)
  8000ca:	e8 23 08 00 00       	call   8008f2 <snprintf>
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
  8000de:	e8 59 11 00 00       	call   80123c <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000e3:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000ea:	00 
  8000eb:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000f2:	e8 24 0e 00 00       	call   800f1b <sys_cputs>
}
  8000f7:	c9                   	leave  
  8000f8:	c3                   	ret    

008000f9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ff:	e8 e0 0e 00 00       	call   800fe4 <sys_getenvid>
  800104:	25 ff 03 00 00       	and    $0x3ff,%eax
  800109:	c1 e0 02             	shl    $0x2,%eax
  80010c:	89 c2                	mov    %eax,%edx
  80010e:	c1 e2 05             	shl    $0x5,%edx
  800111:	29 c2                	sub    %eax,%edx
  800113:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  800119:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800122:	7e 0a                	jle    80012e <libmain+0x35>
		binaryname = argv[0];
  800124:	8b 45 0c             	mov    0xc(%ebp),%eax
  800127:	8b 00                	mov    (%eax),%eax
  800129:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800131:	89 44 24 04          	mov    %eax,0x4(%esp)
  800135:	8b 45 08             	mov    0x8(%ebp),%eax
  800138:	89 04 24             	mov    %eax,(%esp)
  80013b:	e8 91 ff ff ff       	call   8000d1 <umain>

	// exit gracefully
	exit();
  800140:	e8 02 00 00 00       	call   800147 <exit>
}
  800145:	c9                   	leave  
  800146:	c3                   	ret    

00800147 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80014d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800154:	e8 48 0e 00 00       	call   800fa1 <sys_env_destroy>
}
  800159:	c9                   	leave  
  80015a:	c3                   	ret    

0080015b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  800162:	8d 45 14             	lea    0x14(%ebp),%eax
  800165:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800168:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80016e:	e8 71 0e 00 00       	call   800fe4 <sys_getenvid>
  800173:	8b 55 0c             	mov    0xc(%ebp),%edx
  800176:	89 54 24 10          	mov    %edx,0x10(%esp)
  80017a:	8b 55 08             	mov    0x8(%ebp),%edx
  80017d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800181:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800185:	89 44 24 04          	mov    %eax,0x4(%esp)
  800189:	c7 04 24 d8 15 80 00 	movl   $0x8015d8,(%esp)
  800190:	e8 e1 00 00 00       	call   800276 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800195:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019c:	8b 45 10             	mov    0x10(%ebp),%eax
  80019f:	89 04 24             	mov    %eax,(%esp)
  8001a2:	e8 6b 00 00 00       	call   800212 <vcprintf>
	cprintf("\n");
  8001a7:	c7 04 24 fb 15 80 00 	movl   $0x8015fb,(%esp)
  8001ae:	e8 c3 00 00 00       	call   800276 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b3:	cc                   	int3   
  8001b4:	eb fd                	jmp    8001b3 <_panic+0x58>

008001b6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8001bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001bf:	8b 00                	mov    (%eax),%eax
  8001c1:	8d 48 01             	lea    0x1(%eax),%ecx
  8001c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c7:	89 0a                	mov    %ecx,(%edx)
  8001c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cc:	89 d1                	mov    %edx,%ecx
  8001ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d1:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8001d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d8:	8b 00                	mov    (%eax),%eax
  8001da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001df:	75 20                	jne    800201 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8001e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e4:	8b 00                	mov    (%eax),%eax
  8001e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e9:	83 c2 08             	add    $0x8,%edx
  8001ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f0:	89 14 24             	mov    %edx,(%esp)
  8001f3:	e8 23 0d 00 00       	call   800f1b <sys_cputs>
		b->idx = 0;
  8001f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001fb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800201:	8b 45 0c             	mov    0xc(%ebp),%eax
  800204:	8b 40 04             	mov    0x4(%eax),%eax
  800207:	8d 50 01             	lea    0x1(%eax),%edx
  80020a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020d:	89 50 04             	mov    %edx,0x4(%eax)
}
  800210:	c9                   	leave  
  800211:	c3                   	ret    

00800212 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80021b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800222:	00 00 00 
	b.cnt = 0;
  800225:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800232:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800236:	8b 45 08             	mov    0x8(%ebp),%eax
  800239:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800243:	89 44 24 04          	mov    %eax,0x4(%esp)
  800247:	c7 04 24 b6 01 80 00 	movl   $0x8001b6,(%esp)
  80024e:	e8 bd 01 00 00       	call   800410 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800253:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800259:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800263:	83 c0 08             	add    $0x8,%eax
  800266:	89 04 24             	mov    %eax,(%esp)
  800269:	e8 ad 0c 00 00       	call   800f1b <sys_cputs>

	return b.cnt;
  80026e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800274:	c9                   	leave  
  800275:	c3                   	ret    

00800276 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
  800279:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80027c:	8d 45 0c             	lea    0xc(%ebp),%eax
  80027f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800282:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800285:	89 44 24 04          	mov    %eax,0x4(%esp)
  800289:	8b 45 08             	mov    0x8(%ebp),%eax
  80028c:	89 04 24             	mov    %eax,(%esp)
  80028f:	e8 7e ff ff ff       	call   800212 <vcprintf>
  800294:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800297:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80029a:	c9                   	leave  
  80029b:	c3                   	ret    

0080029c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	53                   	push   %ebx
  8002a0:	83 ec 34             	sub    $0x34,%esp
  8002a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8002a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002af:	8b 45 18             	mov    0x18(%ebp),%eax
  8002b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b7:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002ba:	77 72                	ja     80032e <printnum+0x92>
  8002bc:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002bf:	72 05                	jb     8002c6 <printnum+0x2a>
  8002c1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8002c4:	77 68                	ja     80032e <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c6:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8002c9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002cc:	8b 45 18             	mov    0x18(%ebp),%eax
  8002cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8002e2:	89 04 24             	mov    %eax,(%esp)
  8002e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e9:	e8 e2 0f 00 00       	call   8012d0 <__udivdi3>
  8002ee:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8002f1:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8002f5:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002f9:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002fc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800300:	89 44 24 08          	mov    %eax,0x8(%esp)
  800304:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800308:	8b 45 0c             	mov    0xc(%ebp),%eax
  80030b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030f:	8b 45 08             	mov    0x8(%ebp),%eax
  800312:	89 04 24             	mov    %eax,(%esp)
  800315:	e8 82 ff ff ff       	call   80029c <printnum>
  80031a:	eb 1c                	jmp    800338 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80031c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80031f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800323:	8b 45 20             	mov    0x20(%ebp),%eax
  800326:	89 04 24             	mov    %eax,(%esp)
  800329:	8b 45 08             	mov    0x8(%ebp),%eax
  80032c:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80032e:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800332:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800336:	7f e4                	jg     80031c <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800338:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80033b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800340:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800343:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800346:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80034a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80034e:	89 04 24             	mov    %eax,(%esp)
  800351:	89 54 24 04          	mov    %edx,0x4(%esp)
  800355:	e8 a6 10 00 00       	call   801400 <__umoddi3>
  80035a:	05 c8 16 80 00       	add    $0x8016c8,%eax
  80035f:	0f b6 00             	movzbl (%eax),%eax
  800362:	0f be c0             	movsbl %al,%eax
  800365:	8b 55 0c             	mov    0xc(%ebp),%edx
  800368:	89 54 24 04          	mov    %edx,0x4(%esp)
  80036c:	89 04 24             	mov    %eax,(%esp)
  80036f:	8b 45 08             	mov    0x8(%ebp),%eax
  800372:	ff d0                	call   *%eax
}
  800374:	83 c4 34             	add    $0x34,%esp
  800377:	5b                   	pop    %ebx
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80037d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800381:	7e 14                	jle    800397 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800383:	8b 45 08             	mov    0x8(%ebp),%eax
  800386:	8b 00                	mov    (%eax),%eax
  800388:	8d 48 08             	lea    0x8(%eax),%ecx
  80038b:	8b 55 08             	mov    0x8(%ebp),%edx
  80038e:	89 0a                	mov    %ecx,(%edx)
  800390:	8b 50 04             	mov    0x4(%eax),%edx
  800393:	8b 00                	mov    (%eax),%eax
  800395:	eb 30                	jmp    8003c7 <getuint+0x4d>
	else if (lflag)
  800397:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80039b:	74 16                	je     8003b3 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  80039d:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a0:	8b 00                	mov    (%eax),%eax
  8003a2:	8d 48 04             	lea    0x4(%eax),%ecx
  8003a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a8:	89 0a                	mov    %ecx,(%edx)
  8003aa:	8b 00                	mov    (%eax),%eax
  8003ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b1:	eb 14                	jmp    8003c7 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8003b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b6:	8b 00                	mov    (%eax),%eax
  8003b8:	8d 48 04             	lea    0x4(%eax),%ecx
  8003bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8003be:	89 0a                	mov    %ecx,(%edx)
  8003c0:	8b 00                	mov    (%eax),%eax
  8003c2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c7:	5d                   	pop    %ebp
  8003c8:	c3                   	ret    

008003c9 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003c9:	55                   	push   %ebp
  8003ca:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003cc:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003d0:	7e 14                	jle    8003e6 <getint+0x1d>
		return va_arg(*ap, long long);
  8003d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d5:	8b 00                	mov    (%eax),%eax
  8003d7:	8d 48 08             	lea    0x8(%eax),%ecx
  8003da:	8b 55 08             	mov    0x8(%ebp),%edx
  8003dd:	89 0a                	mov    %ecx,(%edx)
  8003df:	8b 50 04             	mov    0x4(%eax),%edx
  8003e2:	8b 00                	mov    (%eax),%eax
  8003e4:	eb 28                	jmp    80040e <getint+0x45>
	else if (lflag)
  8003e6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003ea:	74 12                	je     8003fe <getint+0x35>
		return va_arg(*ap, long);
  8003ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ef:	8b 00                	mov    (%eax),%eax
  8003f1:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f7:	89 0a                	mov    %ecx,(%edx)
  8003f9:	8b 00                	mov    (%eax),%eax
  8003fb:	99                   	cltd   
  8003fc:	eb 10                	jmp    80040e <getint+0x45>
	else
		return va_arg(*ap, int);
  8003fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800401:	8b 00                	mov    (%eax),%eax
  800403:	8d 48 04             	lea    0x4(%eax),%ecx
  800406:	8b 55 08             	mov    0x8(%ebp),%edx
  800409:	89 0a                	mov    %ecx,(%edx)
  80040b:	8b 00                	mov    (%eax),%eax
  80040d:	99                   	cltd   
}
  80040e:	5d                   	pop    %ebp
  80040f:	c3                   	ret    

00800410 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	56                   	push   %esi
  800414:	53                   	push   %ebx
  800415:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800418:	eb 18                	jmp    800432 <vprintfmt+0x22>
			if (ch == '\0')
  80041a:	85 db                	test   %ebx,%ebx
  80041c:	75 05                	jne    800423 <vprintfmt+0x13>
				return;
  80041e:	e9 05 04 00 00       	jmp    800828 <vprintfmt+0x418>
			putch(ch, putdat);
  800423:	8b 45 0c             	mov    0xc(%ebp),%eax
  800426:	89 44 24 04          	mov    %eax,0x4(%esp)
  80042a:	89 1c 24             	mov    %ebx,(%esp)
  80042d:	8b 45 08             	mov    0x8(%ebp),%eax
  800430:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800432:	8b 45 10             	mov    0x10(%ebp),%eax
  800435:	8d 50 01             	lea    0x1(%eax),%edx
  800438:	89 55 10             	mov    %edx,0x10(%ebp)
  80043b:	0f b6 00             	movzbl (%eax),%eax
  80043e:	0f b6 d8             	movzbl %al,%ebx
  800441:	83 fb 25             	cmp    $0x25,%ebx
  800444:	75 d4                	jne    80041a <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800446:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80044a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800451:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800458:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80045f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 45 10             	mov    0x10(%ebp),%eax
  800469:	8d 50 01             	lea    0x1(%eax),%edx
  80046c:	89 55 10             	mov    %edx,0x10(%ebp)
  80046f:	0f b6 00             	movzbl (%eax),%eax
  800472:	0f b6 d8             	movzbl %al,%ebx
  800475:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800478:	83 f8 55             	cmp    $0x55,%eax
  80047b:	0f 87 76 03 00 00    	ja     8007f7 <vprintfmt+0x3e7>
  800481:	8b 04 85 ec 16 80 00 	mov    0x8016ec(,%eax,4),%eax
  800488:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  80048a:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80048e:	eb d6                	jmp    800466 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800490:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800494:	eb d0                	jmp    800466 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800496:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  80049d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004a0:	89 d0                	mov    %edx,%eax
  8004a2:	c1 e0 02             	shl    $0x2,%eax
  8004a5:	01 d0                	add    %edx,%eax
  8004a7:	01 c0                	add    %eax,%eax
  8004a9:	01 d8                	add    %ebx,%eax
  8004ab:	83 e8 30             	sub    $0x30,%eax
  8004ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8004b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8004b4:	0f b6 00             	movzbl (%eax),%eax
  8004b7:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8004ba:	83 fb 2f             	cmp    $0x2f,%ebx
  8004bd:	7e 0b                	jle    8004ca <vprintfmt+0xba>
  8004bf:	83 fb 39             	cmp    $0x39,%ebx
  8004c2:	7f 06                	jg     8004ca <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c4:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004c8:	eb d3                	jmp    80049d <vprintfmt+0x8d>
			goto process_precision;
  8004ca:	eb 33                	jmp    8004ff <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8004cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cf:	8d 50 04             	lea    0x4(%eax),%edx
  8004d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d5:	8b 00                	mov    (%eax),%eax
  8004d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8004da:	eb 23                	jmp    8004ff <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8004dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e0:	79 0c                	jns    8004ee <vprintfmt+0xde>
				width = 0;
  8004e2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8004e9:	e9 78 ff ff ff       	jmp    800466 <vprintfmt+0x56>
  8004ee:	e9 73 ff ff ff       	jmp    800466 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8004f3:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004fa:	e9 67 ff ff ff       	jmp    800466 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8004ff:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800503:	79 12                	jns    800517 <vprintfmt+0x107>
				width = precision, precision = -1;
  800505:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800508:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80050b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800512:	e9 4f ff ff ff       	jmp    800466 <vprintfmt+0x56>
  800517:	e9 4a ff ff ff       	jmp    800466 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80051c:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800520:	e9 41 ff ff ff       	jmp    800466 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8d 50 04             	lea    0x4(%eax),%edx
  80052b:	89 55 14             	mov    %edx,0x14(%ebp)
  80052e:	8b 00                	mov    (%eax),%eax
  800530:	8b 55 0c             	mov    0xc(%ebp),%edx
  800533:	89 54 24 04          	mov    %edx,0x4(%esp)
  800537:	89 04 24             	mov    %eax,(%esp)
  80053a:	8b 45 08             	mov    0x8(%ebp),%eax
  80053d:	ff d0                	call   *%eax
			break;
  80053f:	e9 de 02 00 00       	jmp    800822 <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800544:	8b 45 14             	mov    0x14(%ebp),%eax
  800547:	8d 50 04             	lea    0x4(%eax),%edx
  80054a:	89 55 14             	mov    %edx,0x14(%ebp)
  80054d:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80054f:	85 db                	test   %ebx,%ebx
  800551:	79 02                	jns    800555 <vprintfmt+0x145>
				err = -err;
  800553:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800555:	83 fb 09             	cmp    $0x9,%ebx
  800558:	7f 0b                	jg     800565 <vprintfmt+0x155>
  80055a:	8b 34 9d a0 16 80 00 	mov    0x8016a0(,%ebx,4),%esi
  800561:	85 f6                	test   %esi,%esi
  800563:	75 23                	jne    800588 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800565:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800569:	c7 44 24 08 d9 16 80 	movl   $0x8016d9,0x8(%esp)
  800570:	00 
  800571:	8b 45 0c             	mov    0xc(%ebp),%eax
  800574:	89 44 24 04          	mov    %eax,0x4(%esp)
  800578:	8b 45 08             	mov    0x8(%ebp),%eax
  80057b:	89 04 24             	mov    %eax,(%esp)
  80057e:	e8 ac 02 00 00       	call   80082f <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800583:	e9 9a 02 00 00       	jmp    800822 <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800588:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80058c:	c7 44 24 08 e2 16 80 	movl   $0x8016e2,0x8(%esp)
  800593:	00 
  800594:	8b 45 0c             	mov    0xc(%ebp),%eax
  800597:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059b:	8b 45 08             	mov    0x8(%ebp),%eax
  80059e:	89 04 24             	mov    %eax,(%esp)
  8005a1:	e8 89 02 00 00       	call   80082f <printfmt>
			break;
  8005a6:	e9 77 02 00 00       	jmp    800822 <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ae:	8d 50 04             	lea    0x4(%eax),%edx
  8005b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b4:	8b 30                	mov    (%eax),%esi
  8005b6:	85 f6                	test   %esi,%esi
  8005b8:	75 05                	jne    8005bf <vprintfmt+0x1af>
				p = "(null)";
  8005ba:	be e5 16 80 00       	mov    $0x8016e5,%esi
			if (width > 0 && padc != '-')
  8005bf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005c3:	7e 37                	jle    8005fc <vprintfmt+0x1ec>
  8005c5:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8005c9:	74 31                	je     8005fc <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d2:	89 34 24             	mov    %esi,(%esp)
  8005d5:	e8 72 03 00 00       	call   80094c <strnlen>
  8005da:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8005dd:	eb 17                	jmp    8005f6 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8005df:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8005e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ea:	89 04 24             	mov    %eax,(%esp)
  8005ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f0:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f2:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005f6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005fa:	7f e3                	jg     8005df <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005fc:	eb 38                	jmp    800636 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8005fe:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800602:	74 1f                	je     800623 <vprintfmt+0x213>
  800604:	83 fb 1f             	cmp    $0x1f,%ebx
  800607:	7e 05                	jle    80060e <vprintfmt+0x1fe>
  800609:	83 fb 7e             	cmp    $0x7e,%ebx
  80060c:	7e 15                	jle    800623 <vprintfmt+0x213>
					putch('?', putdat);
  80060e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800611:	89 44 24 04          	mov    %eax,0x4(%esp)
  800615:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80061c:	8b 45 08             	mov    0x8(%ebp),%eax
  80061f:	ff d0                	call   *%eax
  800621:	eb 0f                	jmp    800632 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800623:	8b 45 0c             	mov    0xc(%ebp),%eax
  800626:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062a:	89 1c 24             	mov    %ebx,(%esp)
  80062d:	8b 45 08             	mov    0x8(%ebp),%eax
  800630:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800632:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800636:	89 f0                	mov    %esi,%eax
  800638:	8d 70 01             	lea    0x1(%eax),%esi
  80063b:	0f b6 00             	movzbl (%eax),%eax
  80063e:	0f be d8             	movsbl %al,%ebx
  800641:	85 db                	test   %ebx,%ebx
  800643:	74 10                	je     800655 <vprintfmt+0x245>
  800645:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800649:	78 b3                	js     8005fe <vprintfmt+0x1ee>
  80064b:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80064f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800653:	79 a9                	jns    8005fe <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800655:	eb 17                	jmp    80066e <vprintfmt+0x25e>
				putch(' ', putdat);
  800657:	8b 45 0c             	mov    0xc(%ebp),%eax
  80065a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800665:	8b 45 08             	mov    0x8(%ebp),%eax
  800668:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80066a:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80066e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800672:	7f e3                	jg     800657 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800674:	e9 a9 01 00 00       	jmp    800822 <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800679:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80067c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800680:	8d 45 14             	lea    0x14(%ebp),%eax
  800683:	89 04 24             	mov    %eax,(%esp)
  800686:	e8 3e fd ff ff       	call   8003c9 <getint>
  80068b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80068e:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800691:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800694:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800697:	85 d2                	test   %edx,%edx
  800699:	79 26                	jns    8006c1 <vprintfmt+0x2b1>
				putch('-', putdat);
  80069b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ac:	ff d0                	call   *%eax
				num = -(long long) num;
  8006ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006b4:	f7 d8                	neg    %eax
  8006b6:	83 d2 00             	adc    $0x0,%edx
  8006b9:	f7 da                	neg    %edx
  8006bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006be:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8006c1:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006c8:	e9 e1 00 00 00       	jmp    8007ae <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d7:	89 04 24             	mov    %eax,(%esp)
  8006da:	e8 9b fc ff ff       	call   80037a <getuint>
  8006df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006e2:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8006e5:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006ec:	e9 bd 00 00 00       	jmp    8007ae <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  8006f1:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  8006f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800702:	89 04 24             	mov    %eax,(%esp)
  800705:	e8 70 fc ff ff       	call   80037a <getuint>
  80070a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80070d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  800710:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800714:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800717:	89 54 24 18          	mov    %edx,0x18(%esp)
  80071b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80071e:	89 54 24 14          	mov    %edx,0x14(%esp)
  800722:	89 44 24 10          	mov    %eax,0x10(%esp)
  800726:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800729:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80072c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800730:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800734:	8b 45 0c             	mov    0xc(%ebp),%eax
  800737:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073b:	8b 45 08             	mov    0x8(%ebp),%eax
  80073e:	89 04 24             	mov    %eax,(%esp)
  800741:	e8 56 fb ff ff       	call   80029c <printnum>
			break;
  800746:	e9 d7 00 00 00       	jmp    800822 <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  80074b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80074e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800752:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800759:	8b 45 08             	mov    0x8(%ebp),%eax
  80075c:	ff d0                	call   *%eax
			putch('x', putdat);
  80075e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800761:	89 44 24 04          	mov    %eax,0x4(%esp)
  800765:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800771:	8b 45 14             	mov    0x14(%ebp),%eax
  800774:	8d 50 04             	lea    0x4(%eax),%edx
  800777:	89 55 14             	mov    %edx,0x14(%ebp)
  80077a:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80077c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80077f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800786:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  80078d:	eb 1f                	jmp    8007ae <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80078f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800792:	89 44 24 04          	mov    %eax,0x4(%esp)
  800796:	8d 45 14             	lea    0x14(%ebp),%eax
  800799:	89 04 24             	mov    %eax,(%esp)
  80079c:	e8 d9 fb ff ff       	call   80037a <getuint>
  8007a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007a4:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8007a7:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007ae:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8007b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b5:	89 54 24 18          	mov    %edx,0x18(%esp)
  8007b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007bc:	89 54 24 14          	mov    %edx,0x14(%esp)
  8007c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dc:	89 04 24             	mov    %eax,(%esp)
  8007df:	e8 b8 fa ff ff       	call   80029c <printnum>
			break;
  8007e4:	eb 3c                	jmp    800822 <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ed:	89 1c 24             	mov    %ebx,(%esp)
  8007f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f3:	ff d0                	call   *%eax
			break;
  8007f5:	eb 2b                	jmp    800822 <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007fe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800805:	8b 45 08             	mov    0x8(%ebp),%eax
  800808:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  80080a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80080e:	eb 04                	jmp    800814 <vprintfmt+0x404>
  800810:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800814:	8b 45 10             	mov    0x10(%ebp),%eax
  800817:	83 e8 01             	sub    $0x1,%eax
  80081a:	0f b6 00             	movzbl (%eax),%eax
  80081d:	3c 25                	cmp    $0x25,%al
  80081f:	75 ef                	jne    800810 <vprintfmt+0x400>
				/* do nothing */;
			break;
  800821:	90                   	nop
		}
	}
  800822:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800823:	e9 0a fc ff ff       	jmp    800432 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800828:	83 c4 40             	add    $0x40,%esp
  80082b:	5b                   	pop    %ebx
  80082c:	5e                   	pop    %esi
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800835:	8d 45 14             	lea    0x14(%ebp),%eax
  800838:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80083b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800842:	8b 45 10             	mov    0x10(%ebp),%eax
  800845:	89 44 24 08          	mov    %eax,0x8(%esp)
  800849:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	89 04 24             	mov    %eax,(%esp)
  800856:	e8 b5 fb ff ff       	call   800410 <vprintfmt>
	va_end(ap);
}
  80085b:	c9                   	leave  
  80085c:	c3                   	ret    

0080085d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800860:	8b 45 0c             	mov    0xc(%ebp),%eax
  800863:	8b 40 08             	mov    0x8(%eax),%eax
  800866:	8d 50 01             	lea    0x1(%eax),%edx
  800869:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086c:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  80086f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800872:	8b 10                	mov    (%eax),%edx
  800874:	8b 45 0c             	mov    0xc(%ebp),%eax
  800877:	8b 40 04             	mov    0x4(%eax),%eax
  80087a:	39 c2                	cmp    %eax,%edx
  80087c:	73 12                	jae    800890 <sprintputch+0x33>
		*b->buf++ = ch;
  80087e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800881:	8b 00                	mov    (%eax),%eax
  800883:	8d 48 01             	lea    0x1(%eax),%ecx
  800886:	8b 55 0c             	mov    0xc(%ebp),%edx
  800889:	89 0a                	mov    %ecx,(%edx)
  80088b:	8b 55 08             	mov    0x8(%ebp),%edx
  80088e:	88 10                	mov    %dl,(%eax)
}
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800898:	8b 45 08             	mov    0x8(%ebp),%eax
  80089b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80089e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a1:	8d 50 ff             	lea    -0x1(%eax),%edx
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	01 d0                	add    %edx,%eax
  8008a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008b3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8008b7:	74 06                	je     8008bf <vsnprintf+0x2d>
  8008b9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008bd:	7f 07                	jg     8008c6 <vsnprintf+0x34>
		return -E_INVAL;
  8008bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008c4:	eb 2a                	jmp    8008f0 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8008d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008db:	c7 04 24 5d 08 80 00 	movl   $0x80085d,(%esp)
  8008e2:	e8 29 fb ff ff       	call   800410 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008ea:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    

008008f2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8008fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800901:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800905:	8b 45 10             	mov    0x10(%ebp),%eax
  800908:	89 44 24 08          	mov    %eax,0x8(%esp)
  80090c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800913:	8b 45 08             	mov    0x8(%ebp),%eax
  800916:	89 04 24             	mov    %eax,(%esp)
  800919:	e8 74 ff ff ff       	call   800892 <vsnprintf>
  80091e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800921:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800924:	c9                   	leave  
  800925:	c3                   	ret    

00800926 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  80092c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800933:	eb 08                	jmp    80093d <strlen+0x17>
		n++;
  800935:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800939:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	0f b6 00             	movzbl (%eax),%eax
  800943:	84 c0                	test   %al,%al
  800945:	75 ee                	jne    800935 <strlen+0xf>
		n++;
	return n;
  800947:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80094a:	c9                   	leave  
  80094b:	c3                   	ret    

0080094c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800952:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800959:	eb 0c                	jmp    800967 <strnlen+0x1b>
		n++;
  80095b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80095f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800963:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800967:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80096b:	74 0a                	je     800977 <strnlen+0x2b>
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	0f b6 00             	movzbl (%eax),%eax
  800973:	84 c0                	test   %al,%al
  800975:	75 e4                	jne    80095b <strnlen+0xf>
		n++;
	return n;
  800977:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80097a:	c9                   	leave  
  80097b:	c3                   	ret    

0080097c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800988:	90                   	nop
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8d 50 01             	lea    0x1(%eax),%edx
  80098f:	89 55 08             	mov    %edx,0x8(%ebp)
  800992:	8b 55 0c             	mov    0xc(%ebp),%edx
  800995:	8d 4a 01             	lea    0x1(%edx),%ecx
  800998:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  80099b:	0f b6 12             	movzbl (%edx),%edx
  80099e:	88 10                	mov    %dl,(%eax)
  8009a0:	0f b6 00             	movzbl (%eax),%eax
  8009a3:	84 c0                	test   %al,%al
  8009a5:	75 e2                	jne    800989 <strcpy+0xd>
		/* do nothing */;
	return ret;
  8009a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009aa:	c9                   	leave  
  8009ab:	c3                   	ret    

008009ac <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b5:	89 04 24             	mov    %eax,(%esp)
  8009b8:	e8 69 ff ff ff       	call   800926 <strlen>
  8009bd:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  8009c0:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	01 c2                	add    %eax,%edx
  8009c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009cf:	89 14 24             	mov    %edx,(%esp)
  8009d2:	e8 a5 ff ff ff       	call   80097c <strcpy>
	return dst;
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8009da:	c9                   	leave  
  8009db:	c3                   	ret    

008009dc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e5:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8009e8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009ef:	eb 23                	jmp    800a14 <strncpy+0x38>
		*dst++ = *src;
  8009f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f4:	8d 50 01             	lea    0x1(%eax),%edx
  8009f7:	89 55 08             	mov    %edx,0x8(%ebp)
  8009fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fd:	0f b6 12             	movzbl (%edx),%edx
  800a00:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800a02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a05:	0f b6 00             	movzbl (%eax),%eax
  800a08:	84 c0                	test   %al,%al
  800a0a:	74 04                	je     800a10 <strncpy+0x34>
			src++;
  800a0c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a10:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800a14:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a17:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a1a:	72 d5                	jb     8009f1 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800a1c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800a1f:	c9                   	leave  
  800a20:	c3                   	ret    

00800a21 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800a2d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a31:	74 33                	je     800a66 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800a33:	eb 17                	jmp    800a4c <strlcpy+0x2b>
			*dst++ = *src++;
  800a35:	8b 45 08             	mov    0x8(%ebp),%eax
  800a38:	8d 50 01             	lea    0x1(%eax),%edx
  800a3b:	89 55 08             	mov    %edx,0x8(%ebp)
  800a3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a41:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a44:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a47:	0f b6 12             	movzbl (%edx),%edx
  800a4a:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a4c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a50:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a54:	74 0a                	je     800a60 <strlcpy+0x3f>
  800a56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a59:	0f b6 00             	movzbl (%eax),%eax
  800a5c:	84 c0                	test   %al,%al
  800a5e:	75 d5                	jne    800a35 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800a60:	8b 45 08             	mov    0x8(%ebp),%eax
  800a63:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a66:	8b 55 08             	mov    0x8(%ebp),%edx
  800a69:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a6c:	29 c2                	sub    %eax,%edx
  800a6e:	89 d0                	mov    %edx,%eax
}
  800a70:	c9                   	leave  
  800a71:	c3                   	ret    

00800a72 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a75:	eb 08                	jmp    800a7f <strcmp+0xd>
		p++, q++;
  800a77:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a7b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a82:	0f b6 00             	movzbl (%eax),%eax
  800a85:	84 c0                	test   %al,%al
  800a87:	74 10                	je     800a99 <strcmp+0x27>
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	0f b6 10             	movzbl (%eax),%edx
  800a8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a92:	0f b6 00             	movzbl (%eax),%eax
  800a95:	38 c2                	cmp    %al,%dl
  800a97:	74 de                	je     800a77 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a99:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9c:	0f b6 00             	movzbl (%eax),%eax
  800a9f:	0f b6 d0             	movzbl %al,%edx
  800aa2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa5:	0f b6 00             	movzbl (%eax),%eax
  800aa8:	0f b6 c0             	movzbl %al,%eax
  800aab:	29 c2                	sub    %eax,%edx
  800aad:	89 d0                	mov    %edx,%eax
}
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800ab4:	eb 0c                	jmp    800ac2 <strncmp+0x11>
		n--, p++, q++;
  800ab6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800aba:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800abe:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ac2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ac6:	74 1a                	je     800ae2 <strncmp+0x31>
  800ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  800acb:	0f b6 00             	movzbl (%eax),%eax
  800ace:	84 c0                	test   %al,%al
  800ad0:	74 10                	je     800ae2 <strncmp+0x31>
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	0f b6 10             	movzbl (%eax),%edx
  800ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800adb:	0f b6 00             	movzbl (%eax),%eax
  800ade:	38 c2                	cmp    %al,%dl
  800ae0:	74 d4                	je     800ab6 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800ae2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ae6:	75 07                	jne    800aef <strncmp+0x3e>
		return 0;
  800ae8:	b8 00 00 00 00       	mov    $0x0,%eax
  800aed:	eb 16                	jmp    800b05 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aef:	8b 45 08             	mov    0x8(%ebp),%eax
  800af2:	0f b6 00             	movzbl (%eax),%eax
  800af5:	0f b6 d0             	movzbl %al,%edx
  800af8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afb:	0f b6 00             	movzbl (%eax),%eax
  800afe:	0f b6 c0             	movzbl %al,%eax
  800b01:	29 c2                	sub    %eax,%edx
  800b03:	89 d0                	mov    %edx,%eax
}
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	83 ec 04             	sub    $0x4,%esp
  800b0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b10:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b13:	eb 14                	jmp    800b29 <strchr+0x22>
		if (*s == c)
  800b15:	8b 45 08             	mov    0x8(%ebp),%eax
  800b18:	0f b6 00             	movzbl (%eax),%eax
  800b1b:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b1e:	75 05                	jne    800b25 <strchr+0x1e>
			return (char *) s;
  800b20:	8b 45 08             	mov    0x8(%ebp),%eax
  800b23:	eb 13                	jmp    800b38 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b25:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b29:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2c:	0f b6 00             	movzbl (%eax),%eax
  800b2f:	84 c0                	test   %al,%al
  800b31:	75 e2                	jne    800b15 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800b33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b38:	c9                   	leave  
  800b39:	c3                   	ret    

00800b3a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	83 ec 04             	sub    $0x4,%esp
  800b40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b43:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b46:	eb 11                	jmp    800b59 <strfind+0x1f>
		if (*s == c)
  800b48:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4b:	0f b6 00             	movzbl (%eax),%eax
  800b4e:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b51:	75 02                	jne    800b55 <strfind+0x1b>
			break;
  800b53:	eb 0e                	jmp    800b63 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b55:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b59:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5c:	0f b6 00             	movzbl (%eax),%eax
  800b5f:	84 c0                	test   %al,%al
  800b61:	75 e5                	jne    800b48 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800b63:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b66:	c9                   	leave  
  800b67:	c3                   	ret    

00800b68 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	57                   	push   %edi
	char *p;

	if (n == 0)
  800b6c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b70:	75 05                	jne    800b77 <memset+0xf>
		return v;
  800b72:	8b 45 08             	mov    0x8(%ebp),%eax
  800b75:	eb 5c                	jmp    800bd3 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800b77:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7a:	83 e0 03             	and    $0x3,%eax
  800b7d:	85 c0                	test   %eax,%eax
  800b7f:	75 41                	jne    800bc2 <memset+0x5a>
  800b81:	8b 45 10             	mov    0x10(%ebp),%eax
  800b84:	83 e0 03             	and    $0x3,%eax
  800b87:	85 c0                	test   %eax,%eax
  800b89:	75 37                	jne    800bc2 <memset+0x5a>
		c &= 0xFF;
  800b8b:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b95:	c1 e0 18             	shl    $0x18,%eax
  800b98:	89 c2                	mov    %eax,%edx
  800b9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9d:	c1 e0 10             	shl    $0x10,%eax
  800ba0:	09 c2                	or     %eax,%edx
  800ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba5:	c1 e0 08             	shl    $0x8,%eax
  800ba8:	09 d0                	or     %edx,%eax
  800baa:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bad:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb0:	c1 e8 02             	shr    $0x2,%eax
  800bb3:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbb:	89 d7                	mov    %edx,%edi
  800bbd:	fc                   	cld    
  800bbe:	f3 ab                	rep stos %eax,%es:(%edi)
  800bc0:	eb 0e                	jmp    800bd0 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bcb:	89 d7                	mov    %edx,%edi
  800bcd:	fc                   	cld    
  800bce:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800bd0:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
  800bdc:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800bdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800be5:	8b 45 08             	mov    0x8(%ebp),%eax
  800be8:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bee:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800bf1:	73 6d                	jae    800c60 <memmove+0x8a>
  800bf3:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bf9:	01 d0                	add    %edx,%eax
  800bfb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800bfe:	76 60                	jbe    800c60 <memmove+0x8a>
		s += n;
  800c00:	8b 45 10             	mov    0x10(%ebp),%eax
  800c03:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800c06:	8b 45 10             	mov    0x10(%ebp),%eax
  800c09:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c0f:	83 e0 03             	and    $0x3,%eax
  800c12:	85 c0                	test   %eax,%eax
  800c14:	75 2f                	jne    800c45 <memmove+0x6f>
  800c16:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c19:	83 e0 03             	and    $0x3,%eax
  800c1c:	85 c0                	test   %eax,%eax
  800c1e:	75 25                	jne    800c45 <memmove+0x6f>
  800c20:	8b 45 10             	mov    0x10(%ebp),%eax
  800c23:	83 e0 03             	and    $0x3,%eax
  800c26:	85 c0                	test   %eax,%eax
  800c28:	75 1b                	jne    800c45 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c2d:	83 e8 04             	sub    $0x4,%eax
  800c30:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c33:	83 ea 04             	sub    $0x4,%edx
  800c36:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c39:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c3c:	89 c7                	mov    %eax,%edi
  800c3e:	89 d6                	mov    %edx,%esi
  800c40:	fd                   	std    
  800c41:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c43:	eb 18                	jmp    800c5d <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c45:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c48:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c4e:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c51:	8b 45 10             	mov    0x10(%ebp),%eax
  800c54:	89 d7                	mov    %edx,%edi
  800c56:	89 de                	mov    %ebx,%esi
  800c58:	89 c1                	mov    %eax,%ecx
  800c5a:	fd                   	std    
  800c5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c5d:	fc                   	cld    
  800c5e:	eb 45                	jmp    800ca5 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c63:	83 e0 03             	and    $0x3,%eax
  800c66:	85 c0                	test   %eax,%eax
  800c68:	75 2b                	jne    800c95 <memmove+0xbf>
  800c6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c6d:	83 e0 03             	and    $0x3,%eax
  800c70:	85 c0                	test   %eax,%eax
  800c72:	75 21                	jne    800c95 <memmove+0xbf>
  800c74:	8b 45 10             	mov    0x10(%ebp),%eax
  800c77:	83 e0 03             	and    $0x3,%eax
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	75 17                	jne    800c95 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c7e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c81:	c1 e8 02             	shr    $0x2,%eax
  800c84:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c86:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c89:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c8c:	89 c7                	mov    %eax,%edi
  800c8e:	89 d6                	mov    %edx,%esi
  800c90:	fc                   	cld    
  800c91:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c93:	eb 10                	jmp    800ca5 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c95:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c98:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c9b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c9e:	89 c7                	mov    %eax,%edi
  800ca0:	89 d6                	mov    %edx,%esi
  800ca2:	fc                   	cld    
  800ca3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800ca5:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ca8:	83 c4 10             	add    $0x10,%esp
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cb6:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc7:	89 04 24             	mov    %eax,(%esp)
  800cca:	e8 07 ff ff ff       	call   800bd6 <memmove>
}
  800ccf:	c9                   	leave  
  800cd0:	c3                   	ret    

00800cd1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800cd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cda:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800cdd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce0:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800ce3:	eb 30                	jmp    800d15 <memcmp+0x44>
		if (*s1 != *s2)
  800ce5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ce8:	0f b6 10             	movzbl (%eax),%edx
  800ceb:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800cee:	0f b6 00             	movzbl (%eax),%eax
  800cf1:	38 c2                	cmp    %al,%dl
  800cf3:	74 18                	je     800d0d <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800cf5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cf8:	0f b6 00             	movzbl (%eax),%eax
  800cfb:	0f b6 d0             	movzbl %al,%edx
  800cfe:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d01:	0f b6 00             	movzbl (%eax),%eax
  800d04:	0f b6 c0             	movzbl %al,%eax
  800d07:	29 c2                	sub    %eax,%edx
  800d09:	89 d0                	mov    %edx,%eax
  800d0b:	eb 1a                	jmp    800d27 <memcmp+0x56>
		s1++, s2++;
  800d0d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d11:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d15:	8b 45 10             	mov    0x10(%ebp),%eax
  800d18:	8d 50 ff             	lea    -0x1(%eax),%edx
  800d1b:	89 55 10             	mov    %edx,0x10(%ebp)
  800d1e:	85 c0                	test   %eax,%eax
  800d20:	75 c3                	jne    800ce5 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d22:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d27:	c9                   	leave  
  800d28:	c3                   	ret    

00800d29 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800d2f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	01 d0                	add    %edx,%eax
  800d37:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800d3a:	eb 13                	jmp    800d4f <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3f:	0f b6 10             	movzbl (%eax),%edx
  800d42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d45:	38 c2                	cmp    %al,%dl
  800d47:	75 02                	jne    800d4b <memfind+0x22>
			break;
  800d49:	eb 0c                	jmp    800d57 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d4b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d52:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800d55:	72 e5                	jb     800d3c <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800d57:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d5a:	c9                   	leave  
  800d5b:	c3                   	ret    

00800d5c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800d62:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800d69:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d70:	eb 04                	jmp    800d76 <strtol+0x1a>
		s++;
  800d72:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d76:	8b 45 08             	mov    0x8(%ebp),%eax
  800d79:	0f b6 00             	movzbl (%eax),%eax
  800d7c:	3c 20                	cmp    $0x20,%al
  800d7e:	74 f2                	je     800d72 <strtol+0x16>
  800d80:	8b 45 08             	mov    0x8(%ebp),%eax
  800d83:	0f b6 00             	movzbl (%eax),%eax
  800d86:	3c 09                	cmp    $0x9,%al
  800d88:	74 e8                	je     800d72 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8d:	0f b6 00             	movzbl (%eax),%eax
  800d90:	3c 2b                	cmp    $0x2b,%al
  800d92:	75 06                	jne    800d9a <strtol+0x3e>
		s++;
  800d94:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d98:	eb 15                	jmp    800daf <strtol+0x53>
	else if (*s == '-')
  800d9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9d:	0f b6 00             	movzbl (%eax),%eax
  800da0:	3c 2d                	cmp    $0x2d,%al
  800da2:	75 0b                	jne    800daf <strtol+0x53>
		s++, neg = 1;
  800da4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800da8:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800daf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800db3:	74 06                	je     800dbb <strtol+0x5f>
  800db5:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800db9:	75 24                	jne    800ddf <strtol+0x83>
  800dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbe:	0f b6 00             	movzbl (%eax),%eax
  800dc1:	3c 30                	cmp    $0x30,%al
  800dc3:	75 1a                	jne    800ddf <strtol+0x83>
  800dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc8:	83 c0 01             	add    $0x1,%eax
  800dcb:	0f b6 00             	movzbl (%eax),%eax
  800dce:	3c 78                	cmp    $0x78,%al
  800dd0:	75 0d                	jne    800ddf <strtol+0x83>
		s += 2, base = 16;
  800dd2:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800dd6:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800ddd:	eb 2a                	jmp    800e09 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800ddf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800de3:	75 17                	jne    800dfc <strtol+0xa0>
  800de5:	8b 45 08             	mov    0x8(%ebp),%eax
  800de8:	0f b6 00             	movzbl (%eax),%eax
  800deb:	3c 30                	cmp    $0x30,%al
  800ded:	75 0d                	jne    800dfc <strtol+0xa0>
		s++, base = 8;
  800def:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800df3:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800dfa:	eb 0d                	jmp    800e09 <strtol+0xad>
	else if (base == 0)
  800dfc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e00:	75 07                	jne    800e09 <strtol+0xad>
		base = 10;
  800e02:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e09:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0c:	0f b6 00             	movzbl (%eax),%eax
  800e0f:	3c 2f                	cmp    $0x2f,%al
  800e11:	7e 1b                	jle    800e2e <strtol+0xd2>
  800e13:	8b 45 08             	mov    0x8(%ebp),%eax
  800e16:	0f b6 00             	movzbl (%eax),%eax
  800e19:	3c 39                	cmp    $0x39,%al
  800e1b:	7f 11                	jg     800e2e <strtol+0xd2>
			dig = *s - '0';
  800e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e20:	0f b6 00             	movzbl (%eax),%eax
  800e23:	0f be c0             	movsbl %al,%eax
  800e26:	83 e8 30             	sub    $0x30,%eax
  800e29:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e2c:	eb 48                	jmp    800e76 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800e2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e31:	0f b6 00             	movzbl (%eax),%eax
  800e34:	3c 60                	cmp    $0x60,%al
  800e36:	7e 1b                	jle    800e53 <strtol+0xf7>
  800e38:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3b:	0f b6 00             	movzbl (%eax),%eax
  800e3e:	3c 7a                	cmp    $0x7a,%al
  800e40:	7f 11                	jg     800e53 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800e42:	8b 45 08             	mov    0x8(%ebp),%eax
  800e45:	0f b6 00             	movzbl (%eax),%eax
  800e48:	0f be c0             	movsbl %al,%eax
  800e4b:	83 e8 57             	sub    $0x57,%eax
  800e4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e51:	eb 23                	jmp    800e76 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800e53:	8b 45 08             	mov    0x8(%ebp),%eax
  800e56:	0f b6 00             	movzbl (%eax),%eax
  800e59:	3c 40                	cmp    $0x40,%al
  800e5b:	7e 3d                	jle    800e9a <strtol+0x13e>
  800e5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e60:	0f b6 00             	movzbl (%eax),%eax
  800e63:	3c 5a                	cmp    $0x5a,%al
  800e65:	7f 33                	jg     800e9a <strtol+0x13e>
			dig = *s - 'A' + 10;
  800e67:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6a:	0f b6 00             	movzbl (%eax),%eax
  800e6d:	0f be c0             	movsbl %al,%eax
  800e70:	83 e8 37             	sub    $0x37,%eax
  800e73:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e79:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e7c:	7c 02                	jl     800e80 <strtol+0x124>
			break;
  800e7e:	eb 1a                	jmp    800e9a <strtol+0x13e>
		s++, val = (val * base) + dig;
  800e80:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e84:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e87:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e8b:	89 c2                	mov    %eax,%edx
  800e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e90:	01 d0                	add    %edx,%eax
  800e92:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800e95:	e9 6f ff ff ff       	jmp    800e09 <strtol+0xad>

	if (endptr)
  800e9a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e9e:	74 08                	je     800ea8 <strtol+0x14c>
		*endptr = (char *) s;
  800ea0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea6:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ea8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800eac:	74 07                	je     800eb5 <strtol+0x159>
  800eae:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800eb1:	f7 d8                	neg    %eax
  800eb3:	eb 03                	jmp    800eb8 <strtol+0x15c>
  800eb5:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800eb8:	c9                   	leave  
  800eb9:	c3                   	ret    

00800eba <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	57                   	push   %edi
  800ebe:	56                   	push   %esi
  800ebf:	53                   	push   %ebx
  800ec0:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec6:	8b 55 10             	mov    0x10(%ebp),%edx
  800ec9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800ecc:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800ecf:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800ed2:	8b 75 20             	mov    0x20(%ebp),%esi
  800ed5:	cd 30                	int    $0x30
  800ed7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eda:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ede:	74 30                	je     800f10 <syscall+0x56>
  800ee0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ee4:	7e 2a                	jle    800f10 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ee9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eed:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ef4:	c7 44 24 08 44 18 80 	movl   $0x801844,0x8(%esp)
  800efb:	00 
  800efc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f03:	00 
  800f04:	c7 04 24 61 18 80 00 	movl   $0x801861,(%esp)
  800f0b:	e8 4b f2 ff ff       	call   80015b <_panic>

	return ret;
  800f10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800f13:	83 c4 3c             	add    $0x3c,%esp
  800f16:	5b                   	pop    %ebx
  800f17:	5e                   	pop    %esi
  800f18:	5f                   	pop    %edi
  800f19:	5d                   	pop    %ebp
  800f1a:	c3                   	ret    

00800f1b <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800f21:	8b 45 08             	mov    0x8(%ebp),%eax
  800f24:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f2b:	00 
  800f2c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f33:	00 
  800f34:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f3b:	00 
  800f3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f3f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f43:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f4e:	00 
  800f4f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f56:	e8 5f ff ff ff       	call   800eba <syscall>
}
  800f5b:	c9                   	leave  
  800f5c:	c3                   	ret    

00800f5d <sys_cgetc>:

int
sys_cgetc(void)
{
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
  800f60:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f63:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f6a:	00 
  800f6b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f72:	00 
  800f73:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f7a:	00 
  800f7b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f82:	00 
  800f83:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f8a:	00 
  800f8b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f92:	00 
  800f93:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800f9a:	e8 1b ff ff ff       	call   800eba <syscall>
}
  800f9f:	c9                   	leave  
  800fa0:	c3                   	ret    

00800fa1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800fa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800faa:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fb1:	00 
  800fb2:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fb9:	00 
  800fba:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fc1:	00 
  800fc2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fc9:	00 
  800fca:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fce:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fd5:	00 
  800fd6:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800fdd:	e8 d8 fe ff ff       	call   800eba <syscall>
}
  800fe2:	c9                   	leave  
  800fe3:	c3                   	ret    

00800fe4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800fea:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ff1:	00 
  800ff2:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ff9:	00 
  800ffa:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801001:	00 
  801002:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801009:	00 
  80100a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801011:	00 
  801012:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801019:	00 
  80101a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801021:	e8 94 fe ff ff       	call   800eba <syscall>
}
  801026:	c9                   	leave  
  801027:	c3                   	ret    

00801028 <sys_yield>:

void
sys_yield(void)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80102e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801035:	00 
  801036:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80103d:	00 
  80103e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801045:	00 
  801046:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80104d:	00 
  80104e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801055:	00 
  801056:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80105d:	00 
  80105e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  801065:	e8 50 fe ff ff       	call   800eba <syscall>
}
  80106a:	c9                   	leave  
  80106b:	c3                   	ret    

0080106c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801072:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801075:	8b 55 0c             	mov    0xc(%ebp),%edx
  801078:	8b 45 08             	mov    0x8(%ebp),%eax
  80107b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801082:	00 
  801083:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80108a:	00 
  80108b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80108f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801093:	89 44 24 08          	mov    %eax,0x8(%esp)
  801097:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80109e:	00 
  80109f:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  8010a6:	e8 0f fe ff ff       	call   800eba <syscall>
}
  8010ab:	c9                   	leave  
  8010ac:	c3                   	ret    

008010ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010ad:	55                   	push   %ebp
  8010ae:	89 e5                	mov    %esp,%ebp
  8010b0:	56                   	push   %esi
  8010b1:	53                   	push   %ebx
  8010b2:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8010b5:	8b 75 18             	mov    0x18(%ebp),%esi
  8010b8:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010bb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c4:	89 74 24 18          	mov    %esi,0x18(%esp)
  8010c8:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8010cc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8010d0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010d8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010df:	00 
  8010e0:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8010e7:	e8 ce fd ff ff       	call   800eba <syscall>
}
  8010ec:	83 c4 20             	add    $0x20,%esp
  8010ef:	5b                   	pop    %ebx
  8010f0:	5e                   	pop    %esi
  8010f1:	5d                   	pop    %ebp
  8010f2:	c3                   	ret    

008010f3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010f3:	55                   	push   %ebp
  8010f4:	89 e5                	mov    %esp,%ebp
  8010f6:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8010f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ff:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801106:	00 
  801107:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80110e:	00 
  80110f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801116:	00 
  801117:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80111b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80111f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801126:	00 
  801127:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  80112e:	e8 87 fd ff ff       	call   800eba <syscall>
}
  801133:	c9                   	leave  
  801134:	c3                   	ret    

00801135 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80113b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80113e:	8b 45 08             	mov    0x8(%ebp),%eax
  801141:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801148:	00 
  801149:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801150:	00 
  801151:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801158:	00 
  801159:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80115d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801161:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801168:	00 
  801169:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801170:	e8 45 fd ff ff       	call   800eba <syscall>
}
  801175:	c9                   	leave  
  801176:	c3                   	ret    

00801177 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80117d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801180:	8b 45 08             	mov    0x8(%ebp),%eax
  801183:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80118a:	00 
  80118b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801192:	00 
  801193:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80119a:	00 
  80119b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80119f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011a3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011aa:	00 
  8011ab:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8011b2:	e8 03 fd ff ff       	call   800eba <syscall>
}
  8011b7:	c9                   	leave  
  8011b8:	c3                   	ret    

008011b9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8011bf:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8011c2:	8b 55 10             	mov    0x10(%ebp),%edx
  8011c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c8:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011cf:	00 
  8011d0:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8011d4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011e3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011ea:	00 
  8011eb:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8011f2:	e8 c3 fc ff ff       	call   800eba <syscall>
}
  8011f7:	c9                   	leave  
  8011f8:	c3                   	ret    

008011f9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8011ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801202:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801209:	00 
  80120a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801211:	00 
  801212:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801219:	00 
  80121a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801221:	00 
  801222:	89 44 24 08          	mov    %eax,0x8(%esp)
  801226:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80122d:	00 
  80122e:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801235:	e8 80 fc ff ff       	call   800eba <syscall>
}
  80123a:	c9                   	leave  
  80123b:	c3                   	ret    

0080123c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  801242:	a1 08 20 80 00       	mov    0x802008,%eax
  801247:	85 c0                	test   %eax,%eax
  801249:	75 55                	jne    8012a0 <set_pgfault_handler+0x64>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE),PTE_U|PTE_P|PTE_W);
  80124b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801252:	00 
  801253:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80125a:	ee 
  80125b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801262:	e8 05 fe ff ff       	call   80106c <sys_page_alloc>
  801267:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(r < 0)
  80126a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80126e:	79 1c                	jns    80128c <set_pgfault_handler+0x50>
		{
			panic("sys_page_alloc_failed");
  801270:	c7 44 24 08 6f 18 80 	movl   $0x80186f,0x8(%esp)
  801277:	00 
  801278:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80127f:	00 
  801280:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  801287:	e8 cf ee ff ff       	call   80015b <_panic>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80128c:	c7 44 24 04 aa 12 80 	movl   $0x8012aa,0x4(%esp)
  801293:	00 
  801294:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80129b:	e8 d7 fe ff ff       	call   801177 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a3:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8012a8:	c9                   	leave  
  8012a9:	c3                   	ret    

008012aa <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012aa:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012ab:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8012b0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012b2:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x30(%esp), %eax
  8012b5:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  8012b9:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8012bc:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 0x28(%esp), %ecx
  8012c0:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	movl %ecx, (%eax)
  8012c4:	89 08                	mov    %ecx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	//add $8, %esp
	popl %edx 
  8012c6:	5a                   	pop    %edx
	popl %edx
  8012c7:	5a                   	pop    %edx
	popal
  8012c8:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp
  8012c9:	83 c4 04             	add    $0x4,%esp
	popf
  8012cc:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8012cd:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8012ce:	c3                   	ret    
  8012cf:	90                   	nop

008012d0 <__udivdi3>:
  8012d0:	55                   	push   %ebp
  8012d1:	57                   	push   %edi
  8012d2:	56                   	push   %esi
  8012d3:	83 ec 0c             	sub    $0xc,%esp
  8012d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012da:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8012de:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8012e2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8012e6:	85 c0                	test   %eax,%eax
  8012e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012ec:	89 ea                	mov    %ebp,%edx
  8012ee:	89 0c 24             	mov    %ecx,(%esp)
  8012f1:	75 2d                	jne    801320 <__udivdi3+0x50>
  8012f3:	39 e9                	cmp    %ebp,%ecx
  8012f5:	77 61                	ja     801358 <__udivdi3+0x88>
  8012f7:	85 c9                	test   %ecx,%ecx
  8012f9:	89 ce                	mov    %ecx,%esi
  8012fb:	75 0b                	jne    801308 <__udivdi3+0x38>
  8012fd:	b8 01 00 00 00       	mov    $0x1,%eax
  801302:	31 d2                	xor    %edx,%edx
  801304:	f7 f1                	div    %ecx
  801306:	89 c6                	mov    %eax,%esi
  801308:	31 d2                	xor    %edx,%edx
  80130a:	89 e8                	mov    %ebp,%eax
  80130c:	f7 f6                	div    %esi
  80130e:	89 c5                	mov    %eax,%ebp
  801310:	89 f8                	mov    %edi,%eax
  801312:	f7 f6                	div    %esi
  801314:	89 ea                	mov    %ebp,%edx
  801316:	83 c4 0c             	add    $0xc,%esp
  801319:	5e                   	pop    %esi
  80131a:	5f                   	pop    %edi
  80131b:	5d                   	pop    %ebp
  80131c:	c3                   	ret    
  80131d:	8d 76 00             	lea    0x0(%esi),%esi
  801320:	39 e8                	cmp    %ebp,%eax
  801322:	77 24                	ja     801348 <__udivdi3+0x78>
  801324:	0f bd e8             	bsr    %eax,%ebp
  801327:	83 f5 1f             	xor    $0x1f,%ebp
  80132a:	75 3c                	jne    801368 <__udivdi3+0x98>
  80132c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801330:	39 34 24             	cmp    %esi,(%esp)
  801333:	0f 86 9f 00 00 00    	jbe    8013d8 <__udivdi3+0x108>
  801339:	39 d0                	cmp    %edx,%eax
  80133b:	0f 82 97 00 00 00    	jb     8013d8 <__udivdi3+0x108>
  801341:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801348:	31 d2                	xor    %edx,%edx
  80134a:	31 c0                	xor    %eax,%eax
  80134c:	83 c4 0c             	add    $0xc,%esp
  80134f:	5e                   	pop    %esi
  801350:	5f                   	pop    %edi
  801351:	5d                   	pop    %ebp
  801352:	c3                   	ret    
  801353:	90                   	nop
  801354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801358:	89 f8                	mov    %edi,%eax
  80135a:	f7 f1                	div    %ecx
  80135c:	31 d2                	xor    %edx,%edx
  80135e:	83 c4 0c             	add    $0xc,%esp
  801361:	5e                   	pop    %esi
  801362:	5f                   	pop    %edi
  801363:	5d                   	pop    %ebp
  801364:	c3                   	ret    
  801365:	8d 76 00             	lea    0x0(%esi),%esi
  801368:	89 e9                	mov    %ebp,%ecx
  80136a:	8b 3c 24             	mov    (%esp),%edi
  80136d:	d3 e0                	shl    %cl,%eax
  80136f:	89 c6                	mov    %eax,%esi
  801371:	b8 20 00 00 00       	mov    $0x20,%eax
  801376:	29 e8                	sub    %ebp,%eax
  801378:	89 c1                	mov    %eax,%ecx
  80137a:	d3 ef                	shr    %cl,%edi
  80137c:	89 e9                	mov    %ebp,%ecx
  80137e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801382:	8b 3c 24             	mov    (%esp),%edi
  801385:	09 74 24 08          	or     %esi,0x8(%esp)
  801389:	89 d6                	mov    %edx,%esi
  80138b:	d3 e7                	shl    %cl,%edi
  80138d:	89 c1                	mov    %eax,%ecx
  80138f:	89 3c 24             	mov    %edi,(%esp)
  801392:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801396:	d3 ee                	shr    %cl,%esi
  801398:	89 e9                	mov    %ebp,%ecx
  80139a:	d3 e2                	shl    %cl,%edx
  80139c:	89 c1                	mov    %eax,%ecx
  80139e:	d3 ef                	shr    %cl,%edi
  8013a0:	09 d7                	or     %edx,%edi
  8013a2:	89 f2                	mov    %esi,%edx
  8013a4:	89 f8                	mov    %edi,%eax
  8013a6:	f7 74 24 08          	divl   0x8(%esp)
  8013aa:	89 d6                	mov    %edx,%esi
  8013ac:	89 c7                	mov    %eax,%edi
  8013ae:	f7 24 24             	mull   (%esp)
  8013b1:	39 d6                	cmp    %edx,%esi
  8013b3:	89 14 24             	mov    %edx,(%esp)
  8013b6:	72 30                	jb     8013e8 <__udivdi3+0x118>
  8013b8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013bc:	89 e9                	mov    %ebp,%ecx
  8013be:	d3 e2                	shl    %cl,%edx
  8013c0:	39 c2                	cmp    %eax,%edx
  8013c2:	73 05                	jae    8013c9 <__udivdi3+0xf9>
  8013c4:	3b 34 24             	cmp    (%esp),%esi
  8013c7:	74 1f                	je     8013e8 <__udivdi3+0x118>
  8013c9:	89 f8                	mov    %edi,%eax
  8013cb:	31 d2                	xor    %edx,%edx
  8013cd:	e9 7a ff ff ff       	jmp    80134c <__udivdi3+0x7c>
  8013d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013d8:	31 d2                	xor    %edx,%edx
  8013da:	b8 01 00 00 00       	mov    $0x1,%eax
  8013df:	e9 68 ff ff ff       	jmp    80134c <__udivdi3+0x7c>
  8013e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013e8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8013eb:	31 d2                	xor    %edx,%edx
  8013ed:	83 c4 0c             	add    $0xc,%esp
  8013f0:	5e                   	pop    %esi
  8013f1:	5f                   	pop    %edi
  8013f2:	5d                   	pop    %ebp
  8013f3:	c3                   	ret    
  8013f4:	66 90                	xchg   %ax,%ax
  8013f6:	66 90                	xchg   %ax,%ax
  8013f8:	66 90                	xchg   %ax,%ax
  8013fa:	66 90                	xchg   %ax,%ax
  8013fc:	66 90                	xchg   %ax,%ax
  8013fe:	66 90                	xchg   %ax,%ax

00801400 <__umoddi3>:
  801400:	55                   	push   %ebp
  801401:	57                   	push   %edi
  801402:	56                   	push   %esi
  801403:	83 ec 14             	sub    $0x14,%esp
  801406:	8b 44 24 28          	mov    0x28(%esp),%eax
  80140a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80140e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801412:	89 c7                	mov    %eax,%edi
  801414:	89 44 24 04          	mov    %eax,0x4(%esp)
  801418:	8b 44 24 30          	mov    0x30(%esp),%eax
  80141c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801420:	89 34 24             	mov    %esi,(%esp)
  801423:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801427:	85 c0                	test   %eax,%eax
  801429:	89 c2                	mov    %eax,%edx
  80142b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80142f:	75 17                	jne    801448 <__umoddi3+0x48>
  801431:	39 fe                	cmp    %edi,%esi
  801433:	76 4b                	jbe    801480 <__umoddi3+0x80>
  801435:	89 c8                	mov    %ecx,%eax
  801437:	89 fa                	mov    %edi,%edx
  801439:	f7 f6                	div    %esi
  80143b:	89 d0                	mov    %edx,%eax
  80143d:	31 d2                	xor    %edx,%edx
  80143f:	83 c4 14             	add    $0x14,%esp
  801442:	5e                   	pop    %esi
  801443:	5f                   	pop    %edi
  801444:	5d                   	pop    %ebp
  801445:	c3                   	ret    
  801446:	66 90                	xchg   %ax,%ax
  801448:	39 f8                	cmp    %edi,%eax
  80144a:	77 54                	ja     8014a0 <__umoddi3+0xa0>
  80144c:	0f bd e8             	bsr    %eax,%ebp
  80144f:	83 f5 1f             	xor    $0x1f,%ebp
  801452:	75 5c                	jne    8014b0 <__umoddi3+0xb0>
  801454:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801458:	39 3c 24             	cmp    %edi,(%esp)
  80145b:	0f 87 e7 00 00 00    	ja     801548 <__umoddi3+0x148>
  801461:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801465:	29 f1                	sub    %esi,%ecx
  801467:	19 c7                	sbb    %eax,%edi
  801469:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80146d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801471:	8b 44 24 08          	mov    0x8(%esp),%eax
  801475:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801479:	83 c4 14             	add    $0x14,%esp
  80147c:	5e                   	pop    %esi
  80147d:	5f                   	pop    %edi
  80147e:	5d                   	pop    %ebp
  80147f:	c3                   	ret    
  801480:	85 f6                	test   %esi,%esi
  801482:	89 f5                	mov    %esi,%ebp
  801484:	75 0b                	jne    801491 <__umoddi3+0x91>
  801486:	b8 01 00 00 00       	mov    $0x1,%eax
  80148b:	31 d2                	xor    %edx,%edx
  80148d:	f7 f6                	div    %esi
  80148f:	89 c5                	mov    %eax,%ebp
  801491:	8b 44 24 04          	mov    0x4(%esp),%eax
  801495:	31 d2                	xor    %edx,%edx
  801497:	f7 f5                	div    %ebp
  801499:	89 c8                	mov    %ecx,%eax
  80149b:	f7 f5                	div    %ebp
  80149d:	eb 9c                	jmp    80143b <__umoddi3+0x3b>
  80149f:	90                   	nop
  8014a0:	89 c8                	mov    %ecx,%eax
  8014a2:	89 fa                	mov    %edi,%edx
  8014a4:	83 c4 14             	add    $0x14,%esp
  8014a7:	5e                   	pop    %esi
  8014a8:	5f                   	pop    %edi
  8014a9:	5d                   	pop    %ebp
  8014aa:	c3                   	ret    
  8014ab:	90                   	nop
  8014ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014b0:	8b 04 24             	mov    (%esp),%eax
  8014b3:	be 20 00 00 00       	mov    $0x20,%esi
  8014b8:	89 e9                	mov    %ebp,%ecx
  8014ba:	29 ee                	sub    %ebp,%esi
  8014bc:	d3 e2                	shl    %cl,%edx
  8014be:	89 f1                	mov    %esi,%ecx
  8014c0:	d3 e8                	shr    %cl,%eax
  8014c2:	89 e9                	mov    %ebp,%ecx
  8014c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c8:	8b 04 24             	mov    (%esp),%eax
  8014cb:	09 54 24 04          	or     %edx,0x4(%esp)
  8014cf:	89 fa                	mov    %edi,%edx
  8014d1:	d3 e0                	shl    %cl,%eax
  8014d3:	89 f1                	mov    %esi,%ecx
  8014d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014d9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8014dd:	d3 ea                	shr    %cl,%edx
  8014df:	89 e9                	mov    %ebp,%ecx
  8014e1:	d3 e7                	shl    %cl,%edi
  8014e3:	89 f1                	mov    %esi,%ecx
  8014e5:	d3 e8                	shr    %cl,%eax
  8014e7:	89 e9                	mov    %ebp,%ecx
  8014e9:	09 f8                	or     %edi,%eax
  8014eb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8014ef:	f7 74 24 04          	divl   0x4(%esp)
  8014f3:	d3 e7                	shl    %cl,%edi
  8014f5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014f9:	89 d7                	mov    %edx,%edi
  8014fb:	f7 64 24 08          	mull   0x8(%esp)
  8014ff:	39 d7                	cmp    %edx,%edi
  801501:	89 c1                	mov    %eax,%ecx
  801503:	89 14 24             	mov    %edx,(%esp)
  801506:	72 2c                	jb     801534 <__umoddi3+0x134>
  801508:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80150c:	72 22                	jb     801530 <__umoddi3+0x130>
  80150e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801512:	29 c8                	sub    %ecx,%eax
  801514:	19 d7                	sbb    %edx,%edi
  801516:	89 e9                	mov    %ebp,%ecx
  801518:	89 fa                	mov    %edi,%edx
  80151a:	d3 e8                	shr    %cl,%eax
  80151c:	89 f1                	mov    %esi,%ecx
  80151e:	d3 e2                	shl    %cl,%edx
  801520:	89 e9                	mov    %ebp,%ecx
  801522:	d3 ef                	shr    %cl,%edi
  801524:	09 d0                	or     %edx,%eax
  801526:	89 fa                	mov    %edi,%edx
  801528:	83 c4 14             	add    $0x14,%esp
  80152b:	5e                   	pop    %esi
  80152c:	5f                   	pop    %edi
  80152d:	5d                   	pop    %ebp
  80152e:	c3                   	ret    
  80152f:	90                   	nop
  801530:	39 d7                	cmp    %edx,%edi
  801532:	75 da                	jne    80150e <__umoddi3+0x10e>
  801534:	8b 14 24             	mov    (%esp),%edx
  801537:	89 c1                	mov    %eax,%ecx
  801539:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80153d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801541:	eb cb                	jmp    80150e <__umoddi3+0x10e>
  801543:	90                   	nop
  801544:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801548:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80154c:	0f 82 0f ff ff ff    	jb     801461 <__umoddi3+0x61>
  801552:	e9 1a ff ff ff       	jmp    801471 <__umoddi3+0x71>
