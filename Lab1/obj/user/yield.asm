
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 71 00 00 00       	call   8000a2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 28             	sub    $0x28,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  800039:	a1 04 20 80 00       	mov    0x802004,%eax
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	89 44 24 04          	mov    %eax,0x4(%esp)
  800045:	c7 04 24 80 14 80 00 	movl   $0x801480,(%esp)
  80004c:	e8 73 01 00 00       	call   8001c4 <cprintf>
	for (i = 0; i < 5; i++) {
  800051:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  800058:	eb 28                	jmp    800082 <umain+0x4f>
		sys_yield();
  80005a:	e8 17 0f 00 00       	call   800f76 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005f:	a1 04 20 80 00       	mov    0x802004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800064:	8b 40 48             	mov    0x48(%eax),%eax
  800067:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80006a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80006e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800072:	c7 04 24 a0 14 80 00 	movl   $0x8014a0,(%esp)
  800079:	e8 46 01 00 00       	call   8001c4 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  80007e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  800082:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
  800086:	7e d2                	jle    80005a <umain+0x27>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800088:	a1 04 20 80 00       	mov    0x802004,%eax
  80008d:	8b 40 48             	mov    0x48(%eax),%eax
  800090:	89 44 24 04          	mov    %eax,0x4(%esp)
  800094:	c7 04 24 cc 14 80 00 	movl   $0x8014cc,(%esp)
  80009b:	e8 24 01 00 00       	call   8001c4 <cprintf>
}
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000a8:	e8 85 0e 00 00       	call   800f32 <sys_getenvid>
  8000ad:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b2:	c1 e0 02             	shl    $0x2,%eax
  8000b5:	89 c2                	mov    %eax,%edx
  8000b7:	c1 e2 05             	shl    $0x5,%edx
  8000ba:	29 c2                	sub    %eax,%edx
  8000bc:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  8000c2:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000cb:	7e 0a                	jle    8000d7 <libmain+0x35>
		binaryname = argv[0];
  8000cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000d0:	8b 00                	mov    (%eax),%eax
  8000d2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000de:	8b 45 08             	mov    0x8(%ebp),%eax
  8000e1:	89 04 24             	mov    %eax,(%esp)
  8000e4:	e8 4a ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000e9:	e8 02 00 00 00       	call   8000f0 <exit>
}
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    

008000f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fd:	e8 ed 0d 00 00       	call   800eef <sys_env_destroy>
}
  800102:	c9                   	leave  
  800103:	c3                   	ret    

00800104 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  80010a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80010d:	8b 00                	mov    (%eax),%eax
  80010f:	8d 48 01             	lea    0x1(%eax),%ecx
  800112:	8b 55 0c             	mov    0xc(%ebp),%edx
  800115:	89 0a                	mov    %ecx,(%edx)
  800117:	8b 55 08             	mov    0x8(%ebp),%edx
  80011a:	89 d1                	mov    %edx,%ecx
  80011c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80011f:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800123:	8b 45 0c             	mov    0xc(%ebp),%eax
  800126:	8b 00                	mov    (%eax),%eax
  800128:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012d:	75 20                	jne    80014f <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  80012f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800132:	8b 00                	mov    (%eax),%eax
  800134:	8b 55 0c             	mov    0xc(%ebp),%edx
  800137:	83 c2 08             	add    $0x8,%edx
  80013a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013e:	89 14 24             	mov    %edx,(%esp)
  800141:	e8 23 0d 00 00       	call   800e69 <sys_cputs>
		b->idx = 0;
  800146:	8b 45 0c             	mov    0xc(%ebp),%eax
  800149:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80014f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800152:	8b 40 04             	mov    0x4(%eax),%eax
  800155:	8d 50 01             	lea    0x1(%eax),%edx
  800158:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015b:	89 50 04             	mov    %edx,0x4(%eax)
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800169:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800170:	00 00 00 
	b.cnt = 0;
  800173:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800180:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800184:	8b 45 08             	mov    0x8(%ebp),%eax
  800187:	89 44 24 08          	mov    %eax,0x8(%esp)
  80018b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800191:	89 44 24 04          	mov    %eax,0x4(%esp)
  800195:	c7 04 24 04 01 80 00 	movl   $0x800104,(%esp)
  80019c:	e8 bd 01 00 00       	call   80035e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ab:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b1:	83 c0 08             	add    $0x8,%eax
  8001b4:	89 04 24             	mov    %eax,(%esp)
  8001b7:	e8 ad 0c 00 00       	call   800e69 <sys_cputs>

	return b.cnt;
  8001bc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ca:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8001d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001da:	89 04 24             	mov    %eax,(%esp)
  8001dd:	e8 7e ff ff ff       	call   800160 <vcprintf>
  8001e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8001e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8001e8:	c9                   	leave  
  8001e9:	c3                   	ret    

008001ea <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 34             	sub    $0x34,%esp
  8001f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8001f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8001fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001fd:	8b 45 18             	mov    0x18(%ebp),%eax
  800200:	ba 00 00 00 00       	mov    $0x0,%edx
  800205:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800208:	77 72                	ja     80027c <printnum+0x92>
  80020a:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80020d:	72 05                	jb     800214 <printnum+0x2a>
  80020f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800212:	77 68                	ja     80027c <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800214:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800217:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80021a:	8b 45 18             	mov    0x18(%ebp),%eax
  80021d:	ba 00 00 00 00       	mov    $0x0,%edx
  800222:	89 44 24 08          	mov    %eax,0x8(%esp)
  800226:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80022a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80022d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800230:	89 04 24             	mov    %eax,(%esp)
  800233:	89 54 24 04          	mov    %edx,0x4(%esp)
  800237:	e8 b4 0f 00 00       	call   8011f0 <__udivdi3>
  80023c:	8b 4d 20             	mov    0x20(%ebp),%ecx
  80023f:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800243:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800247:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80024a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80024e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800252:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800256:	8b 45 0c             	mov    0xc(%ebp),%eax
  800259:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025d:	8b 45 08             	mov    0x8(%ebp),%eax
  800260:	89 04 24             	mov    %eax,(%esp)
  800263:	e8 82 ff ff ff       	call   8001ea <printnum>
  800268:	eb 1c                	jmp    800286 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800271:	8b 45 20             	mov    0x20(%ebp),%eax
  800274:	89 04 24             	mov    %eax,(%esp)
  800277:	8b 45 08             	mov    0x8(%ebp),%eax
  80027a:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027c:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800280:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800284:	7f e4                	jg     80026a <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800286:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800289:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800291:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800294:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800298:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80029c:	89 04 24             	mov    %eax,(%esp)
  80029f:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002a3:	e8 78 10 00 00       	call   801320 <__umoddi3>
  8002a8:	05 c8 15 80 00       	add    $0x8015c8,%eax
  8002ad:	0f b6 00             	movzbl (%eax),%eax
  8002b0:	0f be c0             	movsbl %al,%eax
  8002b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ba:	89 04 24             	mov    %eax,(%esp)
  8002bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c0:	ff d0                	call   *%eax
}
  8002c2:	83 c4 34             	add    $0x34,%esp
  8002c5:	5b                   	pop    %ebx
  8002c6:	5d                   	pop    %ebp
  8002c7:	c3                   	ret    

008002c8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002cb:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002cf:	7e 14                	jle    8002e5 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8002d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d4:	8b 00                	mov    (%eax),%eax
  8002d6:	8d 48 08             	lea    0x8(%eax),%ecx
  8002d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002dc:	89 0a                	mov    %ecx,(%edx)
  8002de:	8b 50 04             	mov    0x4(%eax),%edx
  8002e1:	8b 00                	mov    (%eax),%eax
  8002e3:	eb 30                	jmp    800315 <getuint+0x4d>
	else if (lflag)
  8002e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002e9:	74 16                	je     800301 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8002eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ee:	8b 00                	mov    (%eax),%eax
  8002f0:	8d 48 04             	lea    0x4(%eax),%ecx
  8002f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f6:	89 0a                	mov    %ecx,(%edx)
  8002f8:	8b 00                	mov    (%eax),%eax
  8002fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ff:	eb 14                	jmp    800315 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800301:	8b 45 08             	mov    0x8(%ebp),%eax
  800304:	8b 00                	mov    (%eax),%eax
  800306:	8d 48 04             	lea    0x4(%eax),%ecx
  800309:	8b 55 08             	mov    0x8(%ebp),%edx
  80030c:	89 0a                	mov    %ecx,(%edx)
  80030e:	8b 00                	mov    (%eax),%eax
  800310:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800315:	5d                   	pop    %ebp
  800316:	c3                   	ret    

00800317 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800317:	55                   	push   %ebp
  800318:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80031a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80031e:	7e 14                	jle    800334 <getint+0x1d>
		return va_arg(*ap, long long);
  800320:	8b 45 08             	mov    0x8(%ebp),%eax
  800323:	8b 00                	mov    (%eax),%eax
  800325:	8d 48 08             	lea    0x8(%eax),%ecx
  800328:	8b 55 08             	mov    0x8(%ebp),%edx
  80032b:	89 0a                	mov    %ecx,(%edx)
  80032d:	8b 50 04             	mov    0x4(%eax),%edx
  800330:	8b 00                	mov    (%eax),%eax
  800332:	eb 28                	jmp    80035c <getint+0x45>
	else if (lflag)
  800334:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800338:	74 12                	je     80034c <getint+0x35>
		return va_arg(*ap, long);
  80033a:	8b 45 08             	mov    0x8(%ebp),%eax
  80033d:	8b 00                	mov    (%eax),%eax
  80033f:	8d 48 04             	lea    0x4(%eax),%ecx
  800342:	8b 55 08             	mov    0x8(%ebp),%edx
  800345:	89 0a                	mov    %ecx,(%edx)
  800347:	8b 00                	mov    (%eax),%eax
  800349:	99                   	cltd   
  80034a:	eb 10                	jmp    80035c <getint+0x45>
	else
		return va_arg(*ap, int);
  80034c:	8b 45 08             	mov    0x8(%ebp),%eax
  80034f:	8b 00                	mov    (%eax),%eax
  800351:	8d 48 04             	lea    0x4(%eax),%ecx
  800354:	8b 55 08             	mov    0x8(%ebp),%edx
  800357:	89 0a                	mov    %ecx,(%edx)
  800359:	8b 00                	mov    (%eax),%eax
  80035b:	99                   	cltd   
}
  80035c:	5d                   	pop    %ebp
  80035d:	c3                   	ret    

0080035e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	56                   	push   %esi
  800362:	53                   	push   %ebx
  800363:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800366:	eb 18                	jmp    800380 <vprintfmt+0x22>
			if (ch == '\0')
  800368:	85 db                	test   %ebx,%ebx
  80036a:	75 05                	jne    800371 <vprintfmt+0x13>
				return;
  80036c:	e9 05 04 00 00       	jmp    800776 <vprintfmt+0x418>
			putch(ch, putdat);
  800371:	8b 45 0c             	mov    0xc(%ebp),%eax
  800374:	89 44 24 04          	mov    %eax,0x4(%esp)
  800378:	89 1c 24             	mov    %ebx,(%esp)
  80037b:	8b 45 08             	mov    0x8(%ebp),%eax
  80037e:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800380:	8b 45 10             	mov    0x10(%ebp),%eax
  800383:	8d 50 01             	lea    0x1(%eax),%edx
  800386:	89 55 10             	mov    %edx,0x10(%ebp)
  800389:	0f b6 00             	movzbl (%eax),%eax
  80038c:	0f b6 d8             	movzbl %al,%ebx
  80038f:	83 fb 25             	cmp    $0x25,%ebx
  800392:	75 d4                	jne    800368 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800394:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800398:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80039f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003a6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8003ad:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b7:	8d 50 01             	lea    0x1(%eax),%edx
  8003ba:	89 55 10             	mov    %edx,0x10(%ebp)
  8003bd:	0f b6 00             	movzbl (%eax),%eax
  8003c0:	0f b6 d8             	movzbl %al,%ebx
  8003c3:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8003c6:	83 f8 55             	cmp    $0x55,%eax
  8003c9:	0f 87 76 03 00 00    	ja     800745 <vprintfmt+0x3e7>
  8003cf:	8b 04 85 ec 15 80 00 	mov    0x8015ec(,%eax,4),%eax
  8003d6:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8003d8:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8003dc:	eb d6                	jmp    8003b4 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003de:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8003e2:	eb d0                	jmp    8003b4 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8003eb:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003ee:	89 d0                	mov    %edx,%eax
  8003f0:	c1 e0 02             	shl    $0x2,%eax
  8003f3:	01 d0                	add    %edx,%eax
  8003f5:	01 c0                	add    %eax,%eax
  8003f7:	01 d8                	add    %ebx,%eax
  8003f9:	83 e8 30             	sub    $0x30,%eax
  8003fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8003ff:	8b 45 10             	mov    0x10(%ebp),%eax
  800402:	0f b6 00             	movzbl (%eax),%eax
  800405:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800408:	83 fb 2f             	cmp    $0x2f,%ebx
  80040b:	7e 0b                	jle    800418 <vprintfmt+0xba>
  80040d:	83 fb 39             	cmp    $0x39,%ebx
  800410:	7f 06                	jg     800418 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800412:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800416:	eb d3                	jmp    8003eb <vprintfmt+0x8d>
			goto process_precision;
  800418:	eb 33                	jmp    80044d <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  80041a:	8b 45 14             	mov    0x14(%ebp),%eax
  80041d:	8d 50 04             	lea    0x4(%eax),%edx
  800420:	89 55 14             	mov    %edx,0x14(%ebp)
  800423:	8b 00                	mov    (%eax),%eax
  800425:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800428:	eb 23                	jmp    80044d <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80042a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80042e:	79 0c                	jns    80043c <vprintfmt+0xde>
				width = 0;
  800430:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800437:	e9 78 ff ff ff       	jmp    8003b4 <vprintfmt+0x56>
  80043c:	e9 73 ff ff ff       	jmp    8003b4 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800441:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800448:	e9 67 ff ff ff       	jmp    8003b4 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80044d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800451:	79 12                	jns    800465 <vprintfmt+0x107>
				width = precision, precision = -1;
  800453:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800456:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800459:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800460:	e9 4f ff ff ff       	jmp    8003b4 <vprintfmt+0x56>
  800465:	e9 4a ff ff ff       	jmp    8003b4 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046a:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80046e:	e9 41 ff ff ff       	jmp    8003b4 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800473:	8b 45 14             	mov    0x14(%ebp),%eax
  800476:	8d 50 04             	lea    0x4(%eax),%edx
  800479:	89 55 14             	mov    %edx,0x14(%ebp)
  80047c:	8b 00                	mov    (%eax),%eax
  80047e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800481:	89 54 24 04          	mov    %edx,0x4(%esp)
  800485:	89 04 24             	mov    %eax,(%esp)
  800488:	8b 45 08             	mov    0x8(%ebp),%eax
  80048b:	ff d0                	call   *%eax
			break;
  80048d:	e9 de 02 00 00       	jmp    800770 <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800492:	8b 45 14             	mov    0x14(%ebp),%eax
  800495:	8d 50 04             	lea    0x4(%eax),%edx
  800498:	89 55 14             	mov    %edx,0x14(%ebp)
  80049b:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80049d:	85 db                	test   %ebx,%ebx
  80049f:	79 02                	jns    8004a3 <vprintfmt+0x145>
				err = -err;
  8004a1:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a3:	83 fb 09             	cmp    $0x9,%ebx
  8004a6:	7f 0b                	jg     8004b3 <vprintfmt+0x155>
  8004a8:	8b 34 9d a0 15 80 00 	mov    0x8015a0(,%ebx,4),%esi
  8004af:	85 f6                	test   %esi,%esi
  8004b1:	75 23                	jne    8004d6 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8004b3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004b7:	c7 44 24 08 d9 15 80 	movl   $0x8015d9,0x8(%esp)
  8004be:	00 
  8004bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c9:	89 04 24             	mov    %eax,(%esp)
  8004cc:	e8 ac 02 00 00       	call   80077d <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8004d1:	e9 9a 02 00 00       	jmp    800770 <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004d6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004da:	c7 44 24 08 e2 15 80 	movl   $0x8015e2,0x8(%esp)
  8004e1:	00 
  8004e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ec:	89 04 24             	mov    %eax,(%esp)
  8004ef:	e8 89 02 00 00       	call   80077d <printfmt>
			break;
  8004f4:	e9 77 02 00 00       	jmp    800770 <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8d 50 04             	lea    0x4(%eax),%edx
  8004ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800502:	8b 30                	mov    (%eax),%esi
  800504:	85 f6                	test   %esi,%esi
  800506:	75 05                	jne    80050d <vprintfmt+0x1af>
				p = "(null)";
  800508:	be e5 15 80 00       	mov    $0x8015e5,%esi
			if (width > 0 && padc != '-')
  80050d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800511:	7e 37                	jle    80054a <vprintfmt+0x1ec>
  800513:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800517:	74 31                	je     80054a <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800519:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80051c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800520:	89 34 24             	mov    %esi,(%esp)
  800523:	e8 72 03 00 00       	call   80089a <strnlen>
  800528:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80052b:	eb 17                	jmp    800544 <vprintfmt+0x1e6>
					putch(padc, putdat);
  80052d:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800531:	8b 55 0c             	mov    0xc(%ebp),%edx
  800534:	89 54 24 04          	mov    %edx,0x4(%esp)
  800538:	89 04 24             	mov    %eax,(%esp)
  80053b:	8b 45 08             	mov    0x8(%ebp),%eax
  80053e:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800540:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800544:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800548:	7f e3                	jg     80052d <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054a:	eb 38                	jmp    800584 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  80054c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800550:	74 1f                	je     800571 <vprintfmt+0x213>
  800552:	83 fb 1f             	cmp    $0x1f,%ebx
  800555:	7e 05                	jle    80055c <vprintfmt+0x1fe>
  800557:	83 fb 7e             	cmp    $0x7e,%ebx
  80055a:	7e 15                	jle    800571 <vprintfmt+0x213>
					putch('?', putdat);
  80055c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80055f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800563:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80056a:	8b 45 08             	mov    0x8(%ebp),%eax
  80056d:	ff d0                	call   *%eax
  80056f:	eb 0f                	jmp    800580 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800571:	8b 45 0c             	mov    0xc(%ebp),%eax
  800574:	89 44 24 04          	mov    %eax,0x4(%esp)
  800578:	89 1c 24             	mov    %ebx,(%esp)
  80057b:	8b 45 08             	mov    0x8(%ebp),%eax
  80057e:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800580:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800584:	89 f0                	mov    %esi,%eax
  800586:	8d 70 01             	lea    0x1(%eax),%esi
  800589:	0f b6 00             	movzbl (%eax),%eax
  80058c:	0f be d8             	movsbl %al,%ebx
  80058f:	85 db                	test   %ebx,%ebx
  800591:	74 10                	je     8005a3 <vprintfmt+0x245>
  800593:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800597:	78 b3                	js     80054c <vprintfmt+0x1ee>
  800599:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80059d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a1:	79 a9                	jns    80054c <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a3:	eb 17                	jmp    8005bc <vprintfmt+0x25e>
				putch(' ', putdat);
  8005a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ac:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b6:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b8:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005c0:	7f e3                	jg     8005a5 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8005c2:	e9 a9 01 00 00       	jmp    800770 <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d1:	89 04 24             	mov    %eax,(%esp)
  8005d4:	e8 3e fd ff ff       	call   800317 <getint>
  8005d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005dc:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8005df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005e5:	85 d2                	test   %edx,%edx
  8005e7:	79 26                	jns    80060f <vprintfmt+0x2b1>
				putch('-', putdat);
  8005e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005fa:	ff d0                	call   *%eax
				num = -(long long) num;
  8005fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800602:	f7 d8                	neg    %eax
  800604:	83 d2 00             	adc    $0x0,%edx
  800607:	f7 da                	neg    %edx
  800609:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80060c:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  80060f:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800616:	e9 e1 00 00 00       	jmp    8006fc <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80061b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80061e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800622:	8d 45 14             	lea    0x14(%ebp),%eax
  800625:	89 04 24             	mov    %eax,(%esp)
  800628:	e8 9b fc ff ff       	call   8002c8 <getuint>
  80062d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800630:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800633:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80063a:	e9 bd 00 00 00       	jmp    8006fc <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  80063f:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  800646:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800649:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064d:	8d 45 14             	lea    0x14(%ebp),%eax
  800650:	89 04 24             	mov    %eax,(%esp)
  800653:	e8 70 fc ff ff       	call   8002c8 <getuint>
  800658:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80065b:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  80065e:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800662:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800665:	89 54 24 18          	mov    %edx,0x18(%esp)
  800669:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80066c:	89 54 24 14          	mov    %edx,0x14(%esp)
  800670:	89 44 24 10          	mov    %eax,0x10(%esp)
  800674:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800677:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80067a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80067e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800682:	8b 45 0c             	mov    0xc(%ebp),%eax
  800685:	89 44 24 04          	mov    %eax,0x4(%esp)
  800689:	8b 45 08             	mov    0x8(%ebp),%eax
  80068c:	89 04 24             	mov    %eax,(%esp)
  80068f:	e8 56 fb ff ff       	call   8001ea <printnum>
			break;
  800694:	e9 d7 00 00 00       	jmp    800770 <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  800699:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a0:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006aa:	ff d0                	call   *%eax
			putch('x', putdat);
  8006ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b3:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bd:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c2:	8d 50 04             	lea    0x4(%eax),%edx
  8006c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c8:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d4:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8006db:	eb 1f                	jmp    8006fc <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e7:	89 04 24             	mov    %eax,(%esp)
  8006ea:	e8 d9 fb ff ff       	call   8002c8 <getuint>
  8006ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006f2:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8006f5:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006fc:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800700:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800703:	89 54 24 18          	mov    %edx,0x18(%esp)
  800707:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80070a:	89 54 24 14          	mov    %edx,0x14(%esp)
  80070e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800712:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800715:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800718:	89 44 24 08          	mov    %eax,0x8(%esp)
  80071c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800720:	8b 45 0c             	mov    0xc(%ebp),%eax
  800723:	89 44 24 04          	mov    %eax,0x4(%esp)
  800727:	8b 45 08             	mov    0x8(%ebp),%eax
  80072a:	89 04 24             	mov    %eax,(%esp)
  80072d:	e8 b8 fa ff ff       	call   8001ea <printnum>
			break;
  800732:	eb 3c                	jmp    800770 <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800734:	8b 45 0c             	mov    0xc(%ebp),%eax
  800737:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073b:	89 1c 24             	mov    %ebx,(%esp)
  80073e:	8b 45 08             	mov    0x8(%ebp),%eax
  800741:	ff d0                	call   *%eax
			break;
  800743:	eb 2b                	jmp    800770 <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800745:	8b 45 0c             	mov    0xc(%ebp),%eax
  800748:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800753:	8b 45 08             	mov    0x8(%ebp),%eax
  800756:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800758:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80075c:	eb 04                	jmp    800762 <vprintfmt+0x404>
  80075e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800762:	8b 45 10             	mov    0x10(%ebp),%eax
  800765:	83 e8 01             	sub    $0x1,%eax
  800768:	0f b6 00             	movzbl (%eax),%eax
  80076b:	3c 25                	cmp    $0x25,%al
  80076d:	75 ef                	jne    80075e <vprintfmt+0x400>
				/* do nothing */;
			break;
  80076f:	90                   	nop
		}
	}
  800770:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800771:	e9 0a fc ff ff       	jmp    800380 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800776:	83 c4 40             	add    $0x40,%esp
  800779:	5b                   	pop    %ebx
  80077a:	5e                   	pop    %esi
  80077b:	5d                   	pop    %ebp
  80077c:	c3                   	ret    

0080077d <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800783:	8d 45 14             	lea    0x14(%ebp),%eax
  800786:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800789:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800790:	8b 45 10             	mov    0x10(%ebp),%eax
  800793:	89 44 24 08          	mov    %eax,0x8(%esp)
  800797:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079e:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a1:	89 04 24             	mov    %eax,(%esp)
  8007a4:	e8 b5 fb ff ff       	call   80035e <vprintfmt>
	va_end(ap);
}
  8007a9:	c9                   	leave  
  8007aa:	c3                   	ret    

008007ab <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  8007ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b1:	8b 40 08             	mov    0x8(%eax),%eax
  8007b4:	8d 50 01             	lea    0x1(%eax),%edx
  8007b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ba:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  8007bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c0:	8b 10                	mov    (%eax),%edx
  8007c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c5:	8b 40 04             	mov    0x4(%eax),%eax
  8007c8:	39 c2                	cmp    %eax,%edx
  8007ca:	73 12                	jae    8007de <sprintputch+0x33>
		*b->buf++ = ch;
  8007cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cf:	8b 00                	mov    (%eax),%eax
  8007d1:	8d 48 01             	lea    0x1(%eax),%ecx
  8007d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d7:	89 0a                	mov    %ecx,(%edx)
  8007d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8007dc:	88 10                	mov    %dl,(%eax)
}
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ef:	8d 50 ff             	lea    -0x1(%eax),%edx
  8007f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f5:	01 d0                	add    %edx,%eax
  8007f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800801:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800805:	74 06                	je     80080d <vsnprintf+0x2d>
  800807:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80080b:	7f 07                	jg     800814 <vsnprintf+0x34>
		return -E_INVAL;
  80080d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800812:	eb 2a                	jmp    80083e <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800814:	8b 45 14             	mov    0x14(%ebp),%eax
  800817:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081b:	8b 45 10             	mov    0x10(%ebp),%eax
  80081e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800822:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800825:	89 44 24 04          	mov    %eax,0x4(%esp)
  800829:	c7 04 24 ab 07 80 00 	movl   $0x8007ab,(%esp)
  800830:	e8 29 fb ff ff       	call   80035e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800835:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800838:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80083b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80083e:	c9                   	leave  
  80083f:	c3                   	ret    

00800840 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800846:	8d 45 14             	lea    0x14(%ebp),%eax
  800849:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  80084c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800853:	8b 45 10             	mov    0x10(%ebp),%eax
  800856:	89 44 24 08          	mov    %eax,0x8(%esp)
  80085a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800861:	8b 45 08             	mov    0x8(%ebp),%eax
  800864:	89 04 24             	mov    %eax,(%esp)
  800867:	e8 74 ff ff ff       	call   8007e0 <vsnprintf>
  80086c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  80086f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800872:	c9                   	leave  
  800873:	c3                   	ret    

00800874 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  80087a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800881:	eb 08                	jmp    80088b <strlen+0x17>
		n++;
  800883:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800887:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	0f b6 00             	movzbl (%eax),%eax
  800891:	84 c0                	test   %al,%al
  800893:	75 ee                	jne    800883 <strlen+0xf>
		n++;
	return n;
  800895:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800898:	c9                   	leave  
  800899:	c3                   	ret    

0080089a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008a7:	eb 0c                	jmp    8008b5 <strnlen+0x1b>
		n++;
  8008a9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ad:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8008b1:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  8008b5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008b9:	74 0a                	je     8008c5 <strnlen+0x2b>
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	0f b6 00             	movzbl (%eax),%eax
  8008c1:	84 c0                	test   %al,%al
  8008c3:	75 e4                	jne    8008a9 <strnlen+0xf>
		n++;
	return n;
  8008c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008c8:	c9                   	leave  
  8008c9:	c3                   	ret    

008008ca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  8008d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  8008d6:	90                   	nop
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	8d 50 01             	lea    0x1(%eax),%edx
  8008dd:	89 55 08             	mov    %edx,0x8(%ebp)
  8008e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8008e6:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8008e9:	0f b6 12             	movzbl (%edx),%edx
  8008ec:	88 10                	mov    %dl,(%eax)
  8008ee:	0f b6 00             	movzbl (%eax),%eax
  8008f1:	84 c0                	test   %al,%al
  8008f3:	75 e2                	jne    8008d7 <strcpy+0xd>
		/* do nothing */;
	return ret;
  8008f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008f8:	c9                   	leave  
  8008f9:	c3                   	ret    

008008fa <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	89 04 24             	mov    %eax,(%esp)
  800906:	e8 69 ff ff ff       	call   800874 <strlen>
  80090b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  80090e:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800911:	8b 45 08             	mov    0x8(%ebp),%eax
  800914:	01 c2                	add    %eax,%edx
  800916:	8b 45 0c             	mov    0xc(%ebp),%eax
  800919:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091d:	89 14 24             	mov    %edx,(%esp)
  800920:	e8 a5 ff ff ff       	call   8008ca <strcpy>
	return dst;
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800928:	c9                   	leave  
  800929:	c3                   	ret    

0080092a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800936:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80093d:	eb 23                	jmp    800962 <strncpy+0x38>
		*dst++ = *src;
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	8d 50 01             	lea    0x1(%eax),%edx
  800945:	89 55 08             	mov    %edx,0x8(%ebp)
  800948:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094b:	0f b6 12             	movzbl (%edx),%edx
  80094e:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800950:	8b 45 0c             	mov    0xc(%ebp),%eax
  800953:	0f b6 00             	movzbl (%eax),%eax
  800956:	84 c0                	test   %al,%al
  800958:	74 04                	je     80095e <strncpy+0x34>
			src++;
  80095a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80095e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800962:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800965:	3b 45 10             	cmp    0x10(%ebp),%eax
  800968:	72 d5                	jb     80093f <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  80096a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  80097b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80097f:	74 33                	je     8009b4 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800981:	eb 17                	jmp    80099a <strlcpy+0x2b>
			*dst++ = *src++;
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	8d 50 01             	lea    0x1(%eax),%edx
  800989:	89 55 08             	mov    %edx,0x8(%ebp)
  80098c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800992:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800995:	0f b6 12             	movzbl (%edx),%edx
  800998:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80099a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80099e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009a2:	74 0a                	je     8009ae <strlcpy+0x3f>
  8009a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a7:	0f b6 00             	movzbl (%eax),%eax
  8009aa:	84 c0                	test   %al,%al
  8009ac:	75 d5                	jne    800983 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009ba:	29 c2                	sub    %eax,%edx
  8009bc:	89 d0                	mov    %edx,%eax
}
  8009be:	c9                   	leave  
  8009bf:	c3                   	ret    

008009c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  8009c3:	eb 08                	jmp    8009cd <strcmp+0xd>
		p++, q++;
  8009c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009c9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	0f b6 00             	movzbl (%eax),%eax
  8009d3:	84 c0                	test   %al,%al
  8009d5:	74 10                	je     8009e7 <strcmp+0x27>
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	0f b6 10             	movzbl (%eax),%edx
  8009dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e0:	0f b6 00             	movzbl (%eax),%eax
  8009e3:	38 c2                	cmp    %al,%dl
  8009e5:	74 de                	je     8009c5 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ea:	0f b6 00             	movzbl (%eax),%eax
  8009ed:	0f b6 d0             	movzbl %al,%edx
  8009f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f3:	0f b6 00             	movzbl (%eax),%eax
  8009f6:	0f b6 c0             	movzbl %al,%eax
  8009f9:	29 c2                	sub    %eax,%edx
  8009fb:	89 d0                	mov    %edx,%eax
}
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a02:	eb 0c                	jmp    800a10 <strncmp+0x11>
		n--, p++, q++;
  800a04:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a08:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a0c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a10:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a14:	74 1a                	je     800a30 <strncmp+0x31>
  800a16:	8b 45 08             	mov    0x8(%ebp),%eax
  800a19:	0f b6 00             	movzbl (%eax),%eax
  800a1c:	84 c0                	test   %al,%al
  800a1e:	74 10                	je     800a30 <strncmp+0x31>
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	0f b6 10             	movzbl (%eax),%edx
  800a26:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a29:	0f b6 00             	movzbl (%eax),%eax
  800a2c:	38 c2                	cmp    %al,%dl
  800a2e:	74 d4                	je     800a04 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800a30:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a34:	75 07                	jne    800a3d <strncmp+0x3e>
		return 0;
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3b:	eb 16                	jmp    800a53 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a40:	0f b6 00             	movzbl (%eax),%eax
  800a43:	0f b6 d0             	movzbl %al,%edx
  800a46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a49:	0f b6 00             	movzbl (%eax),%eax
  800a4c:	0f b6 c0             	movzbl %al,%eax
  800a4f:	29 c2                	sub    %eax,%edx
  800a51:	89 d0                	mov    %edx,%eax
}
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	83 ec 04             	sub    $0x4,%esp
  800a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5e:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a61:	eb 14                	jmp    800a77 <strchr+0x22>
		if (*s == c)
  800a63:	8b 45 08             	mov    0x8(%ebp),%eax
  800a66:	0f b6 00             	movzbl (%eax),%eax
  800a69:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a6c:	75 05                	jne    800a73 <strchr+0x1e>
			return (char *) s;
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a71:	eb 13                	jmp    800a86 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a73:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a77:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7a:	0f b6 00             	movzbl (%eax),%eax
  800a7d:	84 c0                	test   %al,%al
  800a7f:	75 e2                	jne    800a63 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a86:	c9                   	leave  
  800a87:	c3                   	ret    

00800a88 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	83 ec 04             	sub    $0x4,%esp
  800a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a91:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a94:	eb 11                	jmp    800aa7 <strfind+0x1f>
		if (*s == c)
  800a96:	8b 45 08             	mov    0x8(%ebp),%eax
  800a99:	0f b6 00             	movzbl (%eax),%eax
  800a9c:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a9f:	75 02                	jne    800aa3 <strfind+0x1b>
			break;
  800aa1:	eb 0e                	jmp    800ab1 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aa3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	0f b6 00             	movzbl (%eax),%eax
  800aad:	84 c0                	test   %al,%al
  800aaf:	75 e5                	jne    800a96 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800ab1:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ab4:	c9                   	leave  
  800ab5:	c3                   	ret    

00800ab6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	57                   	push   %edi
	char *p;

	if (n == 0)
  800aba:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800abe:	75 05                	jne    800ac5 <memset+0xf>
		return v;
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	eb 5c                	jmp    800b21 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac8:	83 e0 03             	and    $0x3,%eax
  800acb:	85 c0                	test   %eax,%eax
  800acd:	75 41                	jne    800b10 <memset+0x5a>
  800acf:	8b 45 10             	mov    0x10(%ebp),%eax
  800ad2:	83 e0 03             	and    $0x3,%eax
  800ad5:	85 c0                	test   %eax,%eax
  800ad7:	75 37                	jne    800b10 <memset+0x5a>
		c &= 0xFF;
  800ad9:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ae0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae3:	c1 e0 18             	shl    $0x18,%eax
  800ae6:	89 c2                	mov    %eax,%edx
  800ae8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aeb:	c1 e0 10             	shl    $0x10,%eax
  800aee:	09 c2                	or     %eax,%edx
  800af0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af3:	c1 e0 08             	shl    $0x8,%eax
  800af6:	09 d0                	or     %edx,%eax
  800af8:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800afb:	8b 45 10             	mov    0x10(%ebp),%eax
  800afe:	c1 e8 02             	shr    $0x2,%eax
  800b01:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b03:	8b 55 08             	mov    0x8(%ebp),%edx
  800b06:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b09:	89 d7                	mov    %edx,%edi
  800b0b:	fc                   	cld    
  800b0c:	f3 ab                	rep stos %eax,%es:(%edi)
  800b0e:	eb 0e                	jmp    800b1e <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b10:	8b 55 08             	mov    0x8(%ebp),%edx
  800b13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b16:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b19:	89 d7                	mov    %edx,%edi
  800b1b:	fc                   	cld    
  800b1c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800b1e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
  800b2a:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b30:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800b33:	8b 45 08             	mov    0x8(%ebp),%eax
  800b36:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800b39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b3c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b3f:	73 6d                	jae    800bae <memmove+0x8a>
  800b41:	8b 45 10             	mov    0x10(%ebp),%eax
  800b44:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b47:	01 d0                	add    %edx,%eax
  800b49:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b4c:	76 60                	jbe    800bae <memmove+0x8a>
		s += n;
  800b4e:	8b 45 10             	mov    0x10(%ebp),%eax
  800b51:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800b54:	8b 45 10             	mov    0x10(%ebp),%eax
  800b57:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b5d:	83 e0 03             	and    $0x3,%eax
  800b60:	85 c0                	test   %eax,%eax
  800b62:	75 2f                	jne    800b93 <memmove+0x6f>
  800b64:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b67:	83 e0 03             	and    $0x3,%eax
  800b6a:	85 c0                	test   %eax,%eax
  800b6c:	75 25                	jne    800b93 <memmove+0x6f>
  800b6e:	8b 45 10             	mov    0x10(%ebp),%eax
  800b71:	83 e0 03             	and    $0x3,%eax
  800b74:	85 c0                	test   %eax,%eax
  800b76:	75 1b                	jne    800b93 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b78:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b7b:	83 e8 04             	sub    $0x4,%eax
  800b7e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b81:	83 ea 04             	sub    $0x4,%edx
  800b84:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b87:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b8a:	89 c7                	mov    %eax,%edi
  800b8c:	89 d6                	mov    %edx,%esi
  800b8e:	fd                   	std    
  800b8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b91:	eb 18                	jmp    800bab <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b93:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b96:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b9c:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b9f:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba2:	89 d7                	mov    %edx,%edi
  800ba4:	89 de                	mov    %ebx,%esi
  800ba6:	89 c1                	mov    %eax,%ecx
  800ba8:	fd                   	std    
  800ba9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bab:	fc                   	cld    
  800bac:	eb 45                	jmp    800bf3 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bb1:	83 e0 03             	and    $0x3,%eax
  800bb4:	85 c0                	test   %eax,%eax
  800bb6:	75 2b                	jne    800be3 <memmove+0xbf>
  800bb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bbb:	83 e0 03             	and    $0x3,%eax
  800bbe:	85 c0                	test   %eax,%eax
  800bc0:	75 21                	jne    800be3 <memmove+0xbf>
  800bc2:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc5:	83 e0 03             	and    $0x3,%eax
  800bc8:	85 c0                	test   %eax,%eax
  800bca:	75 17                	jne    800be3 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bcc:	8b 45 10             	mov    0x10(%ebp),%eax
  800bcf:	c1 e8 02             	shr    $0x2,%eax
  800bd2:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bd4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bd7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bda:	89 c7                	mov    %eax,%edi
  800bdc:	89 d6                	mov    %edx,%esi
  800bde:	fc                   	cld    
  800bdf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800be1:	eb 10                	jmp    800bf3 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800be3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800be6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800be9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bec:	89 c7                	mov    %eax,%edi
  800bee:	89 d6                	mov    %edx,%esi
  800bf0:	fc                   	cld    
  800bf1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800bf3:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bf6:	83 c4 10             	add    $0x10,%esp
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c04:	8b 45 10             	mov    0x10(%ebp),%eax
  800c07:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c12:	8b 45 08             	mov    0x8(%ebp),%eax
  800c15:	89 04 24             	mov    %eax,(%esp)
  800c18:	e8 07 ff ff ff       	call   800b24 <memmove>
}
  800c1d:	c9                   	leave  
  800c1e:	c3                   	ret    

00800c1f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800c25:	8b 45 08             	mov    0x8(%ebp),%eax
  800c28:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2e:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800c31:	eb 30                	jmp    800c63 <memcmp+0x44>
		if (*s1 != *s2)
  800c33:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c36:	0f b6 10             	movzbl (%eax),%edx
  800c39:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c3c:	0f b6 00             	movzbl (%eax),%eax
  800c3f:	38 c2                	cmp    %al,%dl
  800c41:	74 18                	je     800c5b <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800c43:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c46:	0f b6 00             	movzbl (%eax),%eax
  800c49:	0f b6 d0             	movzbl %al,%edx
  800c4c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c4f:	0f b6 00             	movzbl (%eax),%eax
  800c52:	0f b6 c0             	movzbl %al,%eax
  800c55:	29 c2                	sub    %eax,%edx
  800c57:	89 d0                	mov    %edx,%eax
  800c59:	eb 1a                	jmp    800c75 <memcmp+0x56>
		s1++, s2++;
  800c5b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800c5f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c63:	8b 45 10             	mov    0x10(%ebp),%eax
  800c66:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c69:	89 55 10             	mov    %edx,0x10(%ebp)
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	75 c3                	jne    800c33 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c75:	c9                   	leave  
  800c76:	c3                   	ret    

00800c77 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c7d:	8b 45 10             	mov    0x10(%ebp),%eax
  800c80:	8b 55 08             	mov    0x8(%ebp),%edx
  800c83:	01 d0                	add    %edx,%eax
  800c85:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c88:	eb 13                	jmp    800c9d <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8d:	0f b6 10             	movzbl (%eax),%edx
  800c90:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c93:	38 c2                	cmp    %al,%dl
  800c95:	75 02                	jne    800c99 <memfind+0x22>
			break;
  800c97:	eb 0c                	jmp    800ca5 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c99:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800ca3:	72 e5                	jb     800c8a <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800ca5:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ca8:	c9                   	leave  
  800ca9:	c3                   	ret    

00800caa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800cb0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800cb7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cbe:	eb 04                	jmp    800cc4 <strtol+0x1a>
		s++;
  800cc0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc7:	0f b6 00             	movzbl (%eax),%eax
  800cca:	3c 20                	cmp    $0x20,%al
  800ccc:	74 f2                	je     800cc0 <strtol+0x16>
  800cce:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd1:	0f b6 00             	movzbl (%eax),%eax
  800cd4:	3c 09                	cmp    $0x9,%al
  800cd6:	74 e8                	je     800cc0 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdb:	0f b6 00             	movzbl (%eax),%eax
  800cde:	3c 2b                	cmp    $0x2b,%al
  800ce0:	75 06                	jne    800ce8 <strtol+0x3e>
		s++;
  800ce2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ce6:	eb 15                	jmp    800cfd <strtol+0x53>
	else if (*s == '-')
  800ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ceb:	0f b6 00             	movzbl (%eax),%eax
  800cee:	3c 2d                	cmp    $0x2d,%al
  800cf0:	75 0b                	jne    800cfd <strtol+0x53>
		s++, neg = 1;
  800cf2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cf6:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cfd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d01:	74 06                	je     800d09 <strtol+0x5f>
  800d03:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800d07:	75 24                	jne    800d2d <strtol+0x83>
  800d09:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0c:	0f b6 00             	movzbl (%eax),%eax
  800d0f:	3c 30                	cmp    $0x30,%al
  800d11:	75 1a                	jne    800d2d <strtol+0x83>
  800d13:	8b 45 08             	mov    0x8(%ebp),%eax
  800d16:	83 c0 01             	add    $0x1,%eax
  800d19:	0f b6 00             	movzbl (%eax),%eax
  800d1c:	3c 78                	cmp    $0x78,%al
  800d1e:	75 0d                	jne    800d2d <strtol+0x83>
		s += 2, base = 16;
  800d20:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800d24:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800d2b:	eb 2a                	jmp    800d57 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800d2d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d31:	75 17                	jne    800d4a <strtol+0xa0>
  800d33:	8b 45 08             	mov    0x8(%ebp),%eax
  800d36:	0f b6 00             	movzbl (%eax),%eax
  800d39:	3c 30                	cmp    $0x30,%al
  800d3b:	75 0d                	jne    800d4a <strtol+0xa0>
		s++, base = 8;
  800d3d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d41:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d48:	eb 0d                	jmp    800d57 <strtol+0xad>
	else if (base == 0)
  800d4a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d4e:	75 07                	jne    800d57 <strtol+0xad>
		base = 10;
  800d50:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d57:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5a:	0f b6 00             	movzbl (%eax),%eax
  800d5d:	3c 2f                	cmp    $0x2f,%al
  800d5f:	7e 1b                	jle    800d7c <strtol+0xd2>
  800d61:	8b 45 08             	mov    0x8(%ebp),%eax
  800d64:	0f b6 00             	movzbl (%eax),%eax
  800d67:	3c 39                	cmp    $0x39,%al
  800d69:	7f 11                	jg     800d7c <strtol+0xd2>
			dig = *s - '0';
  800d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6e:	0f b6 00             	movzbl (%eax),%eax
  800d71:	0f be c0             	movsbl %al,%eax
  800d74:	83 e8 30             	sub    $0x30,%eax
  800d77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d7a:	eb 48                	jmp    800dc4 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7f:	0f b6 00             	movzbl (%eax),%eax
  800d82:	3c 60                	cmp    $0x60,%al
  800d84:	7e 1b                	jle    800da1 <strtol+0xf7>
  800d86:	8b 45 08             	mov    0x8(%ebp),%eax
  800d89:	0f b6 00             	movzbl (%eax),%eax
  800d8c:	3c 7a                	cmp    $0x7a,%al
  800d8e:	7f 11                	jg     800da1 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800d90:	8b 45 08             	mov    0x8(%ebp),%eax
  800d93:	0f b6 00             	movzbl (%eax),%eax
  800d96:	0f be c0             	movsbl %al,%eax
  800d99:	83 e8 57             	sub    $0x57,%eax
  800d9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d9f:	eb 23                	jmp    800dc4 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800da1:	8b 45 08             	mov    0x8(%ebp),%eax
  800da4:	0f b6 00             	movzbl (%eax),%eax
  800da7:	3c 40                	cmp    $0x40,%al
  800da9:	7e 3d                	jle    800de8 <strtol+0x13e>
  800dab:	8b 45 08             	mov    0x8(%ebp),%eax
  800dae:	0f b6 00             	movzbl (%eax),%eax
  800db1:	3c 5a                	cmp    $0x5a,%al
  800db3:	7f 33                	jg     800de8 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800db5:	8b 45 08             	mov    0x8(%ebp),%eax
  800db8:	0f b6 00             	movzbl (%eax),%eax
  800dbb:	0f be c0             	movsbl %al,%eax
  800dbe:	83 e8 37             	sub    $0x37,%eax
  800dc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dc7:	3b 45 10             	cmp    0x10(%ebp),%eax
  800dca:	7c 02                	jl     800dce <strtol+0x124>
			break;
  800dcc:	eb 1a                	jmp    800de8 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800dce:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dd2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800dd5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800dd9:	89 c2                	mov    %eax,%edx
  800ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dde:	01 d0                	add    %edx,%eax
  800de0:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800de3:	e9 6f ff ff ff       	jmp    800d57 <strtol+0xad>

	if (endptr)
  800de8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dec:	74 08                	je     800df6 <strtol+0x14c>
		*endptr = (char *) s;
  800dee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df1:	8b 55 08             	mov    0x8(%ebp),%edx
  800df4:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800df6:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800dfa:	74 07                	je     800e03 <strtol+0x159>
  800dfc:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800dff:	f7 d8                	neg    %eax
  800e01:	eb 03                	jmp    800e06 <strtol+0x15c>
  800e03:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800e06:	c9                   	leave  
  800e07:	c3                   	ret    

00800e08 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	57                   	push   %edi
  800e0c:	56                   	push   %esi
  800e0d:	53                   	push   %ebx
  800e0e:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e11:	8b 45 08             	mov    0x8(%ebp),%eax
  800e14:	8b 55 10             	mov    0x10(%ebp),%edx
  800e17:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800e1a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800e1d:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800e20:	8b 75 20             	mov    0x20(%ebp),%esi
  800e23:	cd 30                	int    $0x30
  800e25:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e28:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e2c:	74 30                	je     800e5e <syscall+0x56>
  800e2e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e32:	7e 2a                	jle    800e5e <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e42:	c7 44 24 08 44 17 80 	movl   $0x801744,0x8(%esp)
  800e49:	00 
  800e4a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e51:	00 
  800e52:	c7 04 24 61 17 80 00 	movl   $0x801761,(%esp)
  800e59:	e8 2c 03 00 00       	call   80118a <_panic>

	return ret;
  800e5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800e61:	83 c4 3c             	add    $0x3c,%esp
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e72:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e79:	00 
  800e7a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e81:	00 
  800e82:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e89:	00 
  800e8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e8d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e91:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e95:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e9c:	00 
  800e9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ea4:	e8 5f ff ff ff       	call   800e08 <syscall>
}
  800ea9:	c9                   	leave  
  800eaa:	c3                   	ret    

00800eab <sys_cgetc>:

int
sys_cgetc(void)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800eb1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800eb8:	00 
  800eb9:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ec0:	00 
  800ec1:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ec8:	00 
  800ec9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ed8:	00 
  800ed9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ee0:	00 
  800ee1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800ee8:	e8 1b ff ff ff       	call   800e08 <syscall>
}
  800eed:	c9                   	leave  
  800eee:	c3                   	ret    

00800eef <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800ef5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef8:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800eff:	00 
  800f00:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f07:	00 
  800f08:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f0f:	00 
  800f10:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f17:	00 
  800f18:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f1c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f23:	00 
  800f24:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800f2b:	e8 d8 fe ff ff       	call   800e08 <syscall>
}
  800f30:	c9                   	leave  
  800f31:	c3                   	ret    

00800f32 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800f38:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f3f:	00 
  800f40:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f47:	00 
  800f48:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f4f:	00 
  800f50:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f57:	00 
  800f58:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f5f:	00 
  800f60:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f67:	00 
  800f68:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f6f:	e8 94 fe ff ff       	call   800e08 <syscall>
}
  800f74:	c9                   	leave  
  800f75:	c3                   	ret    

00800f76 <sys_yield>:

void
sys_yield(void)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f7c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f83:	00 
  800f84:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f8b:	00 
  800f8c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f93:	00 
  800f94:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f9b:	00 
  800f9c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fa3:	00 
  800fa4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fab:	00 
  800fac:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800fb3:	e8 50 fe ff ff       	call   800e08 <syscall>
}
  800fb8:	c9                   	leave  
  800fb9:	c3                   	ret    

00800fba <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800fc0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fc3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc9:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fd0:	00 
  800fd1:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fd8:	00 
  800fd9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fdd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fe1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fe5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fec:	00 
  800fed:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800ff4:	e8 0f fe ff ff       	call   800e08 <syscall>
}
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    

00800ffb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	56                   	push   %esi
  800fff:	53                   	push   %ebx
  801000:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  801003:	8b 75 18             	mov    0x18(%ebp),%esi
  801006:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801009:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80100c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80100f:	8b 45 08             	mov    0x8(%ebp),%eax
  801012:	89 74 24 18          	mov    %esi,0x18(%esp)
  801016:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80101a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80101e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801022:	89 44 24 08          	mov    %eax,0x8(%esp)
  801026:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80102d:	00 
  80102e:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  801035:	e8 ce fd ff ff       	call   800e08 <syscall>
}
  80103a:	83 c4 20             	add    $0x20,%esp
  80103d:	5b                   	pop    %ebx
  80103e:	5e                   	pop    %esi
  80103f:	5d                   	pop    %ebp
  801040:	c3                   	ret    

00801041 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801047:	8b 55 0c             	mov    0xc(%ebp),%edx
  80104a:	8b 45 08             	mov    0x8(%ebp),%eax
  80104d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801054:	00 
  801055:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80105c:	00 
  80105d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801064:	00 
  801065:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801069:	89 44 24 08          	mov    %eax,0x8(%esp)
  80106d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801074:	00 
  801075:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  80107c:	e8 87 fd ff ff       	call   800e08 <syscall>
}
  801081:	c9                   	leave  
  801082:	c3                   	ret    

00801083 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801089:	8b 55 0c             	mov    0xc(%ebp),%edx
  80108c:	8b 45 08             	mov    0x8(%ebp),%eax
  80108f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801096:	00 
  801097:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80109e:	00 
  80109f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010a6:	00 
  8010a7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010af:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010b6:	00 
  8010b7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8010be:	e8 45 fd ff ff       	call   800e08 <syscall>
}
  8010c3:	c9                   	leave  
  8010c4:	c3                   	ret    

008010c5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8010cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010d8:	00 
  8010d9:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010e0:	00 
  8010e1:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010e8:	00 
  8010e9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010f8:	00 
  8010f9:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  801100:	e8 03 fd ff ff       	call   800e08 <syscall>
}
  801105:	c9                   	leave  
  801106:	c3                   	ret    

00801107 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80110d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801110:	8b 55 10             	mov    0x10(%ebp),%edx
  801113:	8b 45 08             	mov    0x8(%ebp),%eax
  801116:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80111d:	00 
  80111e:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801122:	89 54 24 10          	mov    %edx,0x10(%esp)
  801126:	8b 55 0c             	mov    0xc(%ebp),%edx
  801129:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80112d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801131:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801138:	00 
  801139:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  801140:	e8 c3 fc ff ff       	call   800e08 <syscall>
}
  801145:	c9                   	leave  
  801146:	c3                   	ret    

00801147 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80114d:	8b 45 08             	mov    0x8(%ebp),%eax
  801150:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801157:	00 
  801158:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80115f:	00 
  801160:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801167:	00 
  801168:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80116f:	00 
  801170:	89 44 24 08          	mov    %eax,0x8(%esp)
  801174:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80117b:	00 
  80117c:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801183:	e8 80 fc ff ff       	call   800e08 <syscall>
}
  801188:	c9                   	leave  
  801189:	c3                   	ret    

0080118a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80118a:	55                   	push   %ebp
  80118b:	89 e5                	mov    %esp,%ebp
  80118d:	53                   	push   %ebx
  80118e:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  801191:	8d 45 14             	lea    0x14(%ebp),%eax
  801194:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801197:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80119d:	e8 90 fd ff ff       	call   800f32 <sys_getenvid>
  8011a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b8:	c7 04 24 70 17 80 00 	movl   $0x801770,(%esp)
  8011bf:	e8 00 f0 ff ff       	call   8001c4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8011ce:	89 04 24             	mov    %eax,(%esp)
  8011d1:	e8 8a ef ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  8011d6:	c7 04 24 93 17 80 00 	movl   $0x801793,(%esp)
  8011dd:	e8 e2 ef ff ff       	call   8001c4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011e2:	cc                   	int3   
  8011e3:	eb fd                	jmp    8011e2 <_panic+0x58>
  8011e5:	66 90                	xchg   %ax,%ax
  8011e7:	66 90                	xchg   %ax,%ax
  8011e9:	66 90                	xchg   %ax,%ax
  8011eb:	66 90                	xchg   %ax,%ax
  8011ed:	66 90                	xchg   %ax,%ax
  8011ef:	90                   	nop

008011f0 <__udivdi3>:
  8011f0:	55                   	push   %ebp
  8011f1:	57                   	push   %edi
  8011f2:	56                   	push   %esi
  8011f3:	83 ec 0c             	sub    $0xc,%esp
  8011f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8011fa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8011fe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801202:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801206:	85 c0                	test   %eax,%eax
  801208:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80120c:	89 ea                	mov    %ebp,%edx
  80120e:	89 0c 24             	mov    %ecx,(%esp)
  801211:	75 2d                	jne    801240 <__udivdi3+0x50>
  801213:	39 e9                	cmp    %ebp,%ecx
  801215:	77 61                	ja     801278 <__udivdi3+0x88>
  801217:	85 c9                	test   %ecx,%ecx
  801219:	89 ce                	mov    %ecx,%esi
  80121b:	75 0b                	jne    801228 <__udivdi3+0x38>
  80121d:	b8 01 00 00 00       	mov    $0x1,%eax
  801222:	31 d2                	xor    %edx,%edx
  801224:	f7 f1                	div    %ecx
  801226:	89 c6                	mov    %eax,%esi
  801228:	31 d2                	xor    %edx,%edx
  80122a:	89 e8                	mov    %ebp,%eax
  80122c:	f7 f6                	div    %esi
  80122e:	89 c5                	mov    %eax,%ebp
  801230:	89 f8                	mov    %edi,%eax
  801232:	f7 f6                	div    %esi
  801234:	89 ea                	mov    %ebp,%edx
  801236:	83 c4 0c             	add    $0xc,%esp
  801239:	5e                   	pop    %esi
  80123a:	5f                   	pop    %edi
  80123b:	5d                   	pop    %ebp
  80123c:	c3                   	ret    
  80123d:	8d 76 00             	lea    0x0(%esi),%esi
  801240:	39 e8                	cmp    %ebp,%eax
  801242:	77 24                	ja     801268 <__udivdi3+0x78>
  801244:	0f bd e8             	bsr    %eax,%ebp
  801247:	83 f5 1f             	xor    $0x1f,%ebp
  80124a:	75 3c                	jne    801288 <__udivdi3+0x98>
  80124c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801250:	39 34 24             	cmp    %esi,(%esp)
  801253:	0f 86 9f 00 00 00    	jbe    8012f8 <__udivdi3+0x108>
  801259:	39 d0                	cmp    %edx,%eax
  80125b:	0f 82 97 00 00 00    	jb     8012f8 <__udivdi3+0x108>
  801261:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801268:	31 d2                	xor    %edx,%edx
  80126a:	31 c0                	xor    %eax,%eax
  80126c:	83 c4 0c             	add    $0xc,%esp
  80126f:	5e                   	pop    %esi
  801270:	5f                   	pop    %edi
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    
  801273:	90                   	nop
  801274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801278:	89 f8                	mov    %edi,%eax
  80127a:	f7 f1                	div    %ecx
  80127c:	31 d2                	xor    %edx,%edx
  80127e:	83 c4 0c             	add    $0xc,%esp
  801281:	5e                   	pop    %esi
  801282:	5f                   	pop    %edi
  801283:	5d                   	pop    %ebp
  801284:	c3                   	ret    
  801285:	8d 76 00             	lea    0x0(%esi),%esi
  801288:	89 e9                	mov    %ebp,%ecx
  80128a:	8b 3c 24             	mov    (%esp),%edi
  80128d:	d3 e0                	shl    %cl,%eax
  80128f:	89 c6                	mov    %eax,%esi
  801291:	b8 20 00 00 00       	mov    $0x20,%eax
  801296:	29 e8                	sub    %ebp,%eax
  801298:	89 c1                	mov    %eax,%ecx
  80129a:	d3 ef                	shr    %cl,%edi
  80129c:	89 e9                	mov    %ebp,%ecx
  80129e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8012a2:	8b 3c 24             	mov    (%esp),%edi
  8012a5:	09 74 24 08          	or     %esi,0x8(%esp)
  8012a9:	89 d6                	mov    %edx,%esi
  8012ab:	d3 e7                	shl    %cl,%edi
  8012ad:	89 c1                	mov    %eax,%ecx
  8012af:	89 3c 24             	mov    %edi,(%esp)
  8012b2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012b6:	d3 ee                	shr    %cl,%esi
  8012b8:	89 e9                	mov    %ebp,%ecx
  8012ba:	d3 e2                	shl    %cl,%edx
  8012bc:	89 c1                	mov    %eax,%ecx
  8012be:	d3 ef                	shr    %cl,%edi
  8012c0:	09 d7                	or     %edx,%edi
  8012c2:	89 f2                	mov    %esi,%edx
  8012c4:	89 f8                	mov    %edi,%eax
  8012c6:	f7 74 24 08          	divl   0x8(%esp)
  8012ca:	89 d6                	mov    %edx,%esi
  8012cc:	89 c7                	mov    %eax,%edi
  8012ce:	f7 24 24             	mull   (%esp)
  8012d1:	39 d6                	cmp    %edx,%esi
  8012d3:	89 14 24             	mov    %edx,(%esp)
  8012d6:	72 30                	jb     801308 <__udivdi3+0x118>
  8012d8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012dc:	89 e9                	mov    %ebp,%ecx
  8012de:	d3 e2                	shl    %cl,%edx
  8012e0:	39 c2                	cmp    %eax,%edx
  8012e2:	73 05                	jae    8012e9 <__udivdi3+0xf9>
  8012e4:	3b 34 24             	cmp    (%esp),%esi
  8012e7:	74 1f                	je     801308 <__udivdi3+0x118>
  8012e9:	89 f8                	mov    %edi,%eax
  8012eb:	31 d2                	xor    %edx,%edx
  8012ed:	e9 7a ff ff ff       	jmp    80126c <__udivdi3+0x7c>
  8012f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012f8:	31 d2                	xor    %edx,%edx
  8012fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8012ff:	e9 68 ff ff ff       	jmp    80126c <__udivdi3+0x7c>
  801304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801308:	8d 47 ff             	lea    -0x1(%edi),%eax
  80130b:	31 d2                	xor    %edx,%edx
  80130d:	83 c4 0c             	add    $0xc,%esp
  801310:	5e                   	pop    %esi
  801311:	5f                   	pop    %edi
  801312:	5d                   	pop    %ebp
  801313:	c3                   	ret    
  801314:	66 90                	xchg   %ax,%ax
  801316:	66 90                	xchg   %ax,%ax
  801318:	66 90                	xchg   %ax,%ax
  80131a:	66 90                	xchg   %ax,%ax
  80131c:	66 90                	xchg   %ax,%ax
  80131e:	66 90                	xchg   %ax,%ax

00801320 <__umoddi3>:
  801320:	55                   	push   %ebp
  801321:	57                   	push   %edi
  801322:	56                   	push   %esi
  801323:	83 ec 14             	sub    $0x14,%esp
  801326:	8b 44 24 28          	mov    0x28(%esp),%eax
  80132a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80132e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801332:	89 c7                	mov    %eax,%edi
  801334:	89 44 24 04          	mov    %eax,0x4(%esp)
  801338:	8b 44 24 30          	mov    0x30(%esp),%eax
  80133c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801340:	89 34 24             	mov    %esi,(%esp)
  801343:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801347:	85 c0                	test   %eax,%eax
  801349:	89 c2                	mov    %eax,%edx
  80134b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80134f:	75 17                	jne    801368 <__umoddi3+0x48>
  801351:	39 fe                	cmp    %edi,%esi
  801353:	76 4b                	jbe    8013a0 <__umoddi3+0x80>
  801355:	89 c8                	mov    %ecx,%eax
  801357:	89 fa                	mov    %edi,%edx
  801359:	f7 f6                	div    %esi
  80135b:	89 d0                	mov    %edx,%eax
  80135d:	31 d2                	xor    %edx,%edx
  80135f:	83 c4 14             	add    $0x14,%esp
  801362:	5e                   	pop    %esi
  801363:	5f                   	pop    %edi
  801364:	5d                   	pop    %ebp
  801365:	c3                   	ret    
  801366:	66 90                	xchg   %ax,%ax
  801368:	39 f8                	cmp    %edi,%eax
  80136a:	77 54                	ja     8013c0 <__umoddi3+0xa0>
  80136c:	0f bd e8             	bsr    %eax,%ebp
  80136f:	83 f5 1f             	xor    $0x1f,%ebp
  801372:	75 5c                	jne    8013d0 <__umoddi3+0xb0>
  801374:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801378:	39 3c 24             	cmp    %edi,(%esp)
  80137b:	0f 87 e7 00 00 00    	ja     801468 <__umoddi3+0x148>
  801381:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801385:	29 f1                	sub    %esi,%ecx
  801387:	19 c7                	sbb    %eax,%edi
  801389:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80138d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801391:	8b 44 24 08          	mov    0x8(%esp),%eax
  801395:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801399:	83 c4 14             	add    $0x14,%esp
  80139c:	5e                   	pop    %esi
  80139d:	5f                   	pop    %edi
  80139e:	5d                   	pop    %ebp
  80139f:	c3                   	ret    
  8013a0:	85 f6                	test   %esi,%esi
  8013a2:	89 f5                	mov    %esi,%ebp
  8013a4:	75 0b                	jne    8013b1 <__umoddi3+0x91>
  8013a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013ab:	31 d2                	xor    %edx,%edx
  8013ad:	f7 f6                	div    %esi
  8013af:	89 c5                	mov    %eax,%ebp
  8013b1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8013b5:	31 d2                	xor    %edx,%edx
  8013b7:	f7 f5                	div    %ebp
  8013b9:	89 c8                	mov    %ecx,%eax
  8013bb:	f7 f5                	div    %ebp
  8013bd:	eb 9c                	jmp    80135b <__umoddi3+0x3b>
  8013bf:	90                   	nop
  8013c0:	89 c8                	mov    %ecx,%eax
  8013c2:	89 fa                	mov    %edi,%edx
  8013c4:	83 c4 14             	add    $0x14,%esp
  8013c7:	5e                   	pop    %esi
  8013c8:	5f                   	pop    %edi
  8013c9:	5d                   	pop    %ebp
  8013ca:	c3                   	ret    
  8013cb:	90                   	nop
  8013cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013d0:	8b 04 24             	mov    (%esp),%eax
  8013d3:	be 20 00 00 00       	mov    $0x20,%esi
  8013d8:	89 e9                	mov    %ebp,%ecx
  8013da:	29 ee                	sub    %ebp,%esi
  8013dc:	d3 e2                	shl    %cl,%edx
  8013de:	89 f1                	mov    %esi,%ecx
  8013e0:	d3 e8                	shr    %cl,%eax
  8013e2:	89 e9                	mov    %ebp,%ecx
  8013e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e8:	8b 04 24             	mov    (%esp),%eax
  8013eb:	09 54 24 04          	or     %edx,0x4(%esp)
  8013ef:	89 fa                	mov    %edi,%edx
  8013f1:	d3 e0                	shl    %cl,%eax
  8013f3:	89 f1                	mov    %esi,%ecx
  8013f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013f9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8013fd:	d3 ea                	shr    %cl,%edx
  8013ff:	89 e9                	mov    %ebp,%ecx
  801401:	d3 e7                	shl    %cl,%edi
  801403:	89 f1                	mov    %esi,%ecx
  801405:	d3 e8                	shr    %cl,%eax
  801407:	89 e9                	mov    %ebp,%ecx
  801409:	09 f8                	or     %edi,%eax
  80140b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80140f:	f7 74 24 04          	divl   0x4(%esp)
  801413:	d3 e7                	shl    %cl,%edi
  801415:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801419:	89 d7                	mov    %edx,%edi
  80141b:	f7 64 24 08          	mull   0x8(%esp)
  80141f:	39 d7                	cmp    %edx,%edi
  801421:	89 c1                	mov    %eax,%ecx
  801423:	89 14 24             	mov    %edx,(%esp)
  801426:	72 2c                	jb     801454 <__umoddi3+0x134>
  801428:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80142c:	72 22                	jb     801450 <__umoddi3+0x130>
  80142e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801432:	29 c8                	sub    %ecx,%eax
  801434:	19 d7                	sbb    %edx,%edi
  801436:	89 e9                	mov    %ebp,%ecx
  801438:	89 fa                	mov    %edi,%edx
  80143a:	d3 e8                	shr    %cl,%eax
  80143c:	89 f1                	mov    %esi,%ecx
  80143e:	d3 e2                	shl    %cl,%edx
  801440:	89 e9                	mov    %ebp,%ecx
  801442:	d3 ef                	shr    %cl,%edi
  801444:	09 d0                	or     %edx,%eax
  801446:	89 fa                	mov    %edi,%edx
  801448:	83 c4 14             	add    $0x14,%esp
  80144b:	5e                   	pop    %esi
  80144c:	5f                   	pop    %edi
  80144d:	5d                   	pop    %ebp
  80144e:	c3                   	ret    
  80144f:	90                   	nop
  801450:	39 d7                	cmp    %edx,%edi
  801452:	75 da                	jne    80142e <__umoddi3+0x10e>
  801454:	8b 14 24             	mov    (%esp),%edx
  801457:	89 c1                	mov    %eax,%ecx
  801459:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80145d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801461:	eb cb                	jmp    80142e <__umoddi3+0x10e>
  801463:	90                   	nop
  801464:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801468:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80146c:	0f 82 0f ff ff ff    	jb     801381 <__umoddi3+0x61>
  801472:	e9 1a ff ff ff       	jmp    801391 <__umoddi3+0x71>
