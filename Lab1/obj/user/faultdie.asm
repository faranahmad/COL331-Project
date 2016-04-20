
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 64 00 00 00       	call   800095 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 28             	sub    $0x28,%esp
	void *addr = (void*)utf->utf_fault_va;
  800039:	8b 45 08             	mov    0x8(%ebp),%eax
  80003c:	8b 00                	mov    (%eax),%eax
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  800041:	8b 45 08             	mov    0x8(%ebp),%eax
  800044:	8b 40 04             	mov    0x4(%eax),%eax
  800047:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80004a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80004d:	83 e0 07             	and    $0x7,%eax
  800050:	89 44 24 08          	mov    %eax,0x8(%esp)
  800054:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800057:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005b:	c7 04 24 00 15 80 00 	movl   $0x801500,(%esp)
  800062:	e8 50 01 00 00       	call   8001b7 <cprintf>
	sys_env_destroy(sys_getenvid());
  800067:	e8 b9 0e 00 00       	call   800f25 <sys_getenvid>
  80006c:	89 04 24             	mov    %eax,(%esp)
  80006f:	e8 6e 0e 00 00       	call   800ee2 <sys_env_destroy>
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    

00800076 <umain>:

void
umain(int argc, char **argv)
{
  800076:	55                   	push   %ebp
  800077:	89 e5                	mov    %esp,%ebp
  800079:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80007c:	c7 04 24 33 00 80 00 	movl   $0x800033,(%esp)
  800083:	e8 f5 10 00 00       	call   80117d <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800088:	b8 ef be ad de       	mov    $0xdeadbeef,%eax
  80008d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
  800093:	c9                   	leave  
  800094:	c3                   	ret    

00800095 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800095:	55                   	push   %ebp
  800096:	89 e5                	mov    %esp,%ebp
  800098:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80009b:	e8 85 0e 00 00       	call   800f25 <sys_getenvid>
  8000a0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a5:	c1 e0 02             	shl    $0x2,%eax
  8000a8:	89 c2                	mov    %eax,%edx
  8000aa:	c1 e2 05             	shl    $0x5,%edx
  8000ad:	29 c2                	sub    %eax,%edx
  8000af:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  8000b5:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ba:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000be:	7e 0a                	jle    8000ca <libmain+0x35>
		binaryname = argv[0];
  8000c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000c3:	8b 00                	mov    (%eax),%eax
  8000c5:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8000d4:	89 04 24             	mov    %eax,(%esp)
  8000d7:	e8 9a ff ff ff       	call   800076 <umain>

	// exit gracefully
	exit();
  8000dc:	e8 02 00 00 00       	call   8000e3 <exit>
}
  8000e1:	c9                   	leave  
  8000e2:	c3                   	ret    

008000e3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f0:	e8 ed 0d 00 00       	call   800ee2 <sys_env_destroy>
}
  8000f5:	c9                   	leave  
  8000f6:	c3                   	ret    

008000f7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8000fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800100:	8b 00                	mov    (%eax),%eax
  800102:	8d 48 01             	lea    0x1(%eax),%ecx
  800105:	8b 55 0c             	mov    0xc(%ebp),%edx
  800108:	89 0a                	mov    %ecx,(%edx)
  80010a:	8b 55 08             	mov    0x8(%ebp),%edx
  80010d:	89 d1                	mov    %edx,%ecx
  80010f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800112:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800116:	8b 45 0c             	mov    0xc(%ebp),%eax
  800119:	8b 00                	mov    (%eax),%eax
  80011b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800120:	75 20                	jne    800142 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800122:	8b 45 0c             	mov    0xc(%ebp),%eax
  800125:	8b 00                	mov    (%eax),%eax
  800127:	8b 55 0c             	mov    0xc(%ebp),%edx
  80012a:	83 c2 08             	add    $0x8,%edx
  80012d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800131:	89 14 24             	mov    %edx,(%esp)
  800134:	e8 23 0d 00 00       	call   800e5c <sys_cputs>
		b->idx = 0;
  800139:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800142:	8b 45 0c             	mov    0xc(%ebp),%eax
  800145:	8b 40 04             	mov    0x4(%eax),%eax
  800148:	8d 50 01             	lea    0x1(%eax),%edx
  80014b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80014e:	89 50 04             	mov    %edx,0x4(%eax)
}
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80015c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800163:	00 00 00 
	b.cnt = 0;
  800166:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800170:	8b 45 0c             	mov    0xc(%ebp),%eax
  800173:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800177:	8b 45 08             	mov    0x8(%ebp),%eax
  80017a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80017e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800184:	89 44 24 04          	mov    %eax,0x4(%esp)
  800188:	c7 04 24 f7 00 80 00 	movl   $0x8000f7,(%esp)
  80018f:	e8 bd 01 00 00       	call   800351 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800194:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80019a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a4:	83 c0 08             	add    $0x8,%eax
  8001a7:	89 04 24             	mov    %eax,(%esp)
  8001aa:	e8 ad 0c 00 00       	call   800e5c <sys_cputs>

	return b.cnt;
  8001af:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8001b5:	c9                   	leave  
  8001b6:	c3                   	ret    

008001b7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001bd:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8001c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cd:	89 04 24             	mov    %eax,(%esp)
  8001d0:	e8 7e ff ff ff       	call   800153 <vcprintf>
  8001d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8001db:	c9                   	leave  
  8001dc:	c3                   	ret    

008001dd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001dd:	55                   	push   %ebp
  8001de:	89 e5                	mov    %esp,%ebp
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 34             	sub    $0x34,%esp
  8001e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8001ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f0:	8b 45 18             	mov    0x18(%ebp),%eax
  8001f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8001f8:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001fb:	77 72                	ja     80026f <printnum+0x92>
  8001fd:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800200:	72 05                	jb     800207 <printnum+0x2a>
  800202:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800205:	77 68                	ja     80026f <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800207:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80020a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80020d:	8b 45 18             	mov    0x18(%ebp),%eax
  800210:	ba 00 00 00 00       	mov    $0x0,%edx
  800215:	89 44 24 08          	mov    %eax,0x8(%esp)
  800219:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80021d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800220:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800223:	89 04 24             	mov    %eax,(%esp)
  800226:	89 54 24 04          	mov    %edx,0x4(%esp)
  80022a:	e8 41 10 00 00       	call   801270 <__udivdi3>
  80022f:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800232:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800236:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80023a:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80023d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800241:	89 44 24 08          	mov    %eax,0x8(%esp)
  800245:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800249:	8b 45 0c             	mov    0xc(%ebp),%eax
  80024c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800250:	8b 45 08             	mov    0x8(%ebp),%eax
  800253:	89 04 24             	mov    %eax,(%esp)
  800256:	e8 82 ff ff ff       	call   8001dd <printnum>
  80025b:	eb 1c                	jmp    800279 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80025d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800260:	89 44 24 04          	mov    %eax,0x4(%esp)
  800264:	8b 45 20             	mov    0x20(%ebp),%eax
  800267:	89 04 24             	mov    %eax,(%esp)
  80026a:	8b 45 08             	mov    0x8(%ebp),%eax
  80026d:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80026f:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800273:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800277:	7f e4                	jg     80025d <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800279:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800284:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800287:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80028b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80028f:	89 04 24             	mov    %eax,(%esp)
  800292:	89 54 24 04          	mov    %edx,0x4(%esp)
  800296:	e8 05 11 00 00       	call   8013a0 <__umoddi3>
  80029b:	05 08 16 80 00       	add    $0x801608,%eax
  8002a0:	0f b6 00             	movzbl (%eax),%eax
  8002a3:	0f be c0             	movsbl %al,%eax
  8002a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ad:	89 04 24             	mov    %eax,(%esp)
  8002b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b3:	ff d0                	call   *%eax
}
  8002b5:	83 c4 34             	add    $0x34,%esp
  8002b8:	5b                   	pop    %ebx
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002be:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002c2:	7e 14                	jle    8002d8 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8002c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c7:	8b 00                	mov    (%eax),%eax
  8002c9:	8d 48 08             	lea    0x8(%eax),%ecx
  8002cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cf:	89 0a                	mov    %ecx,(%edx)
  8002d1:	8b 50 04             	mov    0x4(%eax),%edx
  8002d4:	8b 00                	mov    (%eax),%eax
  8002d6:	eb 30                	jmp    800308 <getuint+0x4d>
	else if (lflag)
  8002d8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002dc:	74 16                	je     8002f4 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8002de:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e1:	8b 00                	mov    (%eax),%eax
  8002e3:	8d 48 04             	lea    0x4(%eax),%ecx
  8002e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e9:	89 0a                	mov    %ecx,(%edx)
  8002eb:	8b 00                	mov    (%eax),%eax
  8002ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f2:	eb 14                	jmp    800308 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8002f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f7:	8b 00                	mov    (%eax),%eax
  8002f9:	8d 48 04             	lea    0x4(%eax),%ecx
  8002fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ff:	89 0a                	mov    %ecx,(%edx)
  800301:	8b 00                	mov    (%eax),%eax
  800303:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80030d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800311:	7e 14                	jle    800327 <getint+0x1d>
		return va_arg(*ap, long long);
  800313:	8b 45 08             	mov    0x8(%ebp),%eax
  800316:	8b 00                	mov    (%eax),%eax
  800318:	8d 48 08             	lea    0x8(%eax),%ecx
  80031b:	8b 55 08             	mov    0x8(%ebp),%edx
  80031e:	89 0a                	mov    %ecx,(%edx)
  800320:	8b 50 04             	mov    0x4(%eax),%edx
  800323:	8b 00                	mov    (%eax),%eax
  800325:	eb 28                	jmp    80034f <getint+0x45>
	else if (lflag)
  800327:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80032b:	74 12                	je     80033f <getint+0x35>
		return va_arg(*ap, long);
  80032d:	8b 45 08             	mov    0x8(%ebp),%eax
  800330:	8b 00                	mov    (%eax),%eax
  800332:	8d 48 04             	lea    0x4(%eax),%ecx
  800335:	8b 55 08             	mov    0x8(%ebp),%edx
  800338:	89 0a                	mov    %ecx,(%edx)
  80033a:	8b 00                	mov    (%eax),%eax
  80033c:	99                   	cltd   
  80033d:	eb 10                	jmp    80034f <getint+0x45>
	else
		return va_arg(*ap, int);
  80033f:	8b 45 08             	mov    0x8(%ebp),%eax
  800342:	8b 00                	mov    (%eax),%eax
  800344:	8d 48 04             	lea    0x4(%eax),%ecx
  800347:	8b 55 08             	mov    0x8(%ebp),%edx
  80034a:	89 0a                	mov    %ecx,(%edx)
  80034c:	8b 00                	mov    (%eax),%eax
  80034e:	99                   	cltd   
}
  80034f:	5d                   	pop    %ebp
  800350:	c3                   	ret    

00800351 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
  800354:	56                   	push   %esi
  800355:	53                   	push   %ebx
  800356:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800359:	eb 18                	jmp    800373 <vprintfmt+0x22>
			if (ch == '\0')
  80035b:	85 db                	test   %ebx,%ebx
  80035d:	75 05                	jne    800364 <vprintfmt+0x13>
				return;
  80035f:	e9 05 04 00 00       	jmp    800769 <vprintfmt+0x418>
			putch(ch, putdat);
  800364:	8b 45 0c             	mov    0xc(%ebp),%eax
  800367:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036b:	89 1c 24             	mov    %ebx,(%esp)
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800373:	8b 45 10             	mov    0x10(%ebp),%eax
  800376:	8d 50 01             	lea    0x1(%eax),%edx
  800379:	89 55 10             	mov    %edx,0x10(%ebp)
  80037c:	0f b6 00             	movzbl (%eax),%eax
  80037f:	0f b6 d8             	movzbl %al,%ebx
  800382:	83 fb 25             	cmp    $0x25,%ebx
  800385:	75 d4                	jne    80035b <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800387:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80038b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800392:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800399:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8003a0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003aa:	8d 50 01             	lea    0x1(%eax),%edx
  8003ad:	89 55 10             	mov    %edx,0x10(%ebp)
  8003b0:	0f b6 00             	movzbl (%eax),%eax
  8003b3:	0f b6 d8             	movzbl %al,%ebx
  8003b6:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8003b9:	83 f8 55             	cmp    $0x55,%eax
  8003bc:	0f 87 76 03 00 00    	ja     800738 <vprintfmt+0x3e7>
  8003c2:	8b 04 85 2c 16 80 00 	mov    0x80162c(,%eax,4),%eax
  8003c9:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8003cb:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8003cf:	eb d6                	jmp    8003a7 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d1:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8003d5:	eb d0                	jmp    8003a7 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8003de:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003e1:	89 d0                	mov    %edx,%eax
  8003e3:	c1 e0 02             	shl    $0x2,%eax
  8003e6:	01 d0                	add    %edx,%eax
  8003e8:	01 c0                	add    %eax,%eax
  8003ea:	01 d8                	add    %ebx,%eax
  8003ec:	83 e8 30             	sub    $0x30,%eax
  8003ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8003f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f5:	0f b6 00             	movzbl (%eax),%eax
  8003f8:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8003fb:	83 fb 2f             	cmp    $0x2f,%ebx
  8003fe:	7e 0b                	jle    80040b <vprintfmt+0xba>
  800400:	83 fb 39             	cmp    $0x39,%ebx
  800403:	7f 06                	jg     80040b <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800405:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800409:	eb d3                	jmp    8003de <vprintfmt+0x8d>
			goto process_precision;
  80040b:	eb 33                	jmp    800440 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 50 04             	lea    0x4(%eax),%edx
  800413:	89 55 14             	mov    %edx,0x14(%ebp)
  800416:	8b 00                	mov    (%eax),%eax
  800418:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80041b:	eb 23                	jmp    800440 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80041d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800421:	79 0c                	jns    80042f <vprintfmt+0xde>
				width = 0;
  800423:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80042a:	e9 78 ff ff ff       	jmp    8003a7 <vprintfmt+0x56>
  80042f:	e9 73 ff ff ff       	jmp    8003a7 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800434:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80043b:	e9 67 ff ff ff       	jmp    8003a7 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800440:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800444:	79 12                	jns    800458 <vprintfmt+0x107>
				width = precision, precision = -1;
  800446:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800449:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800453:	e9 4f ff ff ff       	jmp    8003a7 <vprintfmt+0x56>
  800458:	e9 4a ff ff ff       	jmp    8003a7 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80045d:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800461:	e9 41 ff ff ff       	jmp    8003a7 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	8d 50 04             	lea    0x4(%eax),%edx
  80046c:	89 55 14             	mov    %edx,0x14(%ebp)
  80046f:	8b 00                	mov    (%eax),%eax
  800471:	8b 55 0c             	mov    0xc(%ebp),%edx
  800474:	89 54 24 04          	mov    %edx,0x4(%esp)
  800478:	89 04 24             	mov    %eax,(%esp)
  80047b:	8b 45 08             	mov    0x8(%ebp),%eax
  80047e:	ff d0                	call   *%eax
			break;
  800480:	e9 de 02 00 00       	jmp    800763 <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800485:	8b 45 14             	mov    0x14(%ebp),%eax
  800488:	8d 50 04             	lea    0x4(%eax),%edx
  80048b:	89 55 14             	mov    %edx,0x14(%ebp)
  80048e:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800490:	85 db                	test   %ebx,%ebx
  800492:	79 02                	jns    800496 <vprintfmt+0x145>
				err = -err;
  800494:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800496:	83 fb 09             	cmp    $0x9,%ebx
  800499:	7f 0b                	jg     8004a6 <vprintfmt+0x155>
  80049b:	8b 34 9d e0 15 80 00 	mov    0x8015e0(,%ebx,4),%esi
  8004a2:	85 f6                	test   %esi,%esi
  8004a4:	75 23                	jne    8004c9 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8004a6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004aa:	c7 44 24 08 19 16 80 	movl   $0x801619,0x8(%esp)
  8004b1:	00 
  8004b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004bc:	89 04 24             	mov    %eax,(%esp)
  8004bf:	e8 ac 02 00 00       	call   800770 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8004c4:	e9 9a 02 00 00       	jmp    800763 <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004c9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004cd:	c7 44 24 08 22 16 80 	movl   $0x801622,0x8(%esp)
  8004d4:	00 
  8004d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8004df:	89 04 24             	mov    %eax,(%esp)
  8004e2:	e8 89 02 00 00       	call   800770 <printfmt>
			break;
  8004e7:	e9 77 02 00 00       	jmp    800763 <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ef:	8d 50 04             	lea    0x4(%eax),%edx
  8004f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f5:	8b 30                	mov    (%eax),%esi
  8004f7:	85 f6                	test   %esi,%esi
  8004f9:	75 05                	jne    800500 <vprintfmt+0x1af>
				p = "(null)";
  8004fb:	be 25 16 80 00       	mov    $0x801625,%esi
			if (width > 0 && padc != '-')
  800500:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800504:	7e 37                	jle    80053d <vprintfmt+0x1ec>
  800506:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80050a:	74 31                	je     80053d <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80050c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80050f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800513:	89 34 24             	mov    %esi,(%esp)
  800516:	e8 72 03 00 00       	call   80088d <strnlen>
  80051b:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80051e:	eb 17                	jmp    800537 <vprintfmt+0x1e6>
					putch(padc, putdat);
  800520:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800524:	8b 55 0c             	mov    0xc(%ebp),%edx
  800527:	89 54 24 04          	mov    %edx,0x4(%esp)
  80052b:	89 04 24             	mov    %eax,(%esp)
  80052e:	8b 45 08             	mov    0x8(%ebp),%eax
  800531:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800533:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800537:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80053b:	7f e3                	jg     800520 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053d:	eb 38                	jmp    800577 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  80053f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800543:	74 1f                	je     800564 <vprintfmt+0x213>
  800545:	83 fb 1f             	cmp    $0x1f,%ebx
  800548:	7e 05                	jle    80054f <vprintfmt+0x1fe>
  80054a:	83 fb 7e             	cmp    $0x7e,%ebx
  80054d:	7e 15                	jle    800564 <vprintfmt+0x213>
					putch('?', putdat);
  80054f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800552:	89 44 24 04          	mov    %eax,0x4(%esp)
  800556:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80055d:	8b 45 08             	mov    0x8(%ebp),%eax
  800560:	ff d0                	call   *%eax
  800562:	eb 0f                	jmp    800573 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800564:	8b 45 0c             	mov    0xc(%ebp),%eax
  800567:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056b:	89 1c 24             	mov    %ebx,(%esp)
  80056e:	8b 45 08             	mov    0x8(%ebp),%eax
  800571:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800573:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800577:	89 f0                	mov    %esi,%eax
  800579:	8d 70 01             	lea    0x1(%eax),%esi
  80057c:	0f b6 00             	movzbl (%eax),%eax
  80057f:	0f be d8             	movsbl %al,%ebx
  800582:	85 db                	test   %ebx,%ebx
  800584:	74 10                	je     800596 <vprintfmt+0x245>
  800586:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058a:	78 b3                	js     80053f <vprintfmt+0x1ee>
  80058c:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800590:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800594:	79 a9                	jns    80053f <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800596:	eb 17                	jmp    8005af <vprintfmt+0x25e>
				putch(' ', putdat);
  800598:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a9:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ab:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005af:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005b3:	7f e3                	jg     800598 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8005b5:	e9 a9 01 00 00       	jmp    800763 <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c4:	89 04 24             	mov    %eax,(%esp)
  8005c7:	e8 3e fd ff ff       	call   80030a <getint>
  8005cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005cf:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8005d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005d8:	85 d2                	test   %edx,%edx
  8005da:	79 26                	jns    800602 <vprintfmt+0x2b1>
				putch('-', putdat);
  8005dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ed:	ff d0                	call   *%eax
				num = -(long long) num;
  8005ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005f5:	f7 d8                	neg    %eax
  8005f7:	83 d2 00             	adc    $0x0,%edx
  8005fa:	f7 da                	neg    %edx
  8005fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005ff:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800602:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800609:	e9 e1 00 00 00       	jmp    8006ef <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80060e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800611:	89 44 24 04          	mov    %eax,0x4(%esp)
  800615:	8d 45 14             	lea    0x14(%ebp),%eax
  800618:	89 04 24             	mov    %eax,(%esp)
  80061b:	e8 9b fc ff ff       	call   8002bb <getuint>
  800620:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800623:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800626:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80062d:	e9 bd 00 00 00       	jmp    8006ef <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  800632:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  800639:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80063c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800640:	8d 45 14             	lea    0x14(%ebp),%eax
  800643:	89 04 24             	mov    %eax,(%esp)
  800646:	e8 70 fc ff ff       	call   8002bb <getuint>
  80064b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80064e:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  800651:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800655:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800658:	89 54 24 18          	mov    %edx,0x18(%esp)
  80065c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80065f:	89 54 24 14          	mov    %edx,0x14(%esp)
  800663:	89 44 24 10          	mov    %eax,0x10(%esp)
  800667:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80066a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80066d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800671:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800675:	8b 45 0c             	mov    0xc(%ebp),%eax
  800678:	89 44 24 04          	mov    %eax,0x4(%esp)
  80067c:	8b 45 08             	mov    0x8(%ebp),%eax
  80067f:	89 04 24             	mov    %eax,(%esp)
  800682:	e8 56 fb ff ff       	call   8001dd <printnum>
			break;
  800687:	e9 d7 00 00 00       	jmp    800763 <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  80068c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80068f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800693:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80069a:	8b 45 08             	mov    0x8(%ebp),%eax
  80069d:	ff d0                	call   *%eax
			putch('x', putdat);
  80069f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a6:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b0:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8d 50 04             	lea    0x4(%eax),%edx
  8006b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bb:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006c7:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8006ce:	eb 1f                	jmp    8006ef <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006da:	89 04 24             	mov    %eax,(%esp)
  8006dd:	e8 d9 fb ff ff       	call   8002bb <getuint>
  8006e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006e5:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8006e8:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ef:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8006f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f6:	89 54 24 18          	mov    %edx,0x18(%esp)
  8006fa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006fd:	89 54 24 14          	mov    %edx,0x14(%esp)
  800701:	89 44 24 10          	mov    %eax,0x10(%esp)
  800705:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800708:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80070b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80070f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800713:	8b 45 0c             	mov    0xc(%ebp),%eax
  800716:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071a:	8b 45 08             	mov    0x8(%ebp),%eax
  80071d:	89 04 24             	mov    %eax,(%esp)
  800720:	e8 b8 fa ff ff       	call   8001dd <printnum>
			break;
  800725:	eb 3c                	jmp    800763 <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800727:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072e:	89 1c 24             	mov    %ebx,(%esp)
  800731:	8b 45 08             	mov    0x8(%ebp),%eax
  800734:	ff d0                	call   *%eax
			break;
  800736:	eb 2b                	jmp    800763 <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800738:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800746:	8b 45 08             	mov    0x8(%ebp),%eax
  800749:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  80074b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80074f:	eb 04                	jmp    800755 <vprintfmt+0x404>
  800751:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800755:	8b 45 10             	mov    0x10(%ebp),%eax
  800758:	83 e8 01             	sub    $0x1,%eax
  80075b:	0f b6 00             	movzbl (%eax),%eax
  80075e:	3c 25                	cmp    $0x25,%al
  800760:	75 ef                	jne    800751 <vprintfmt+0x400>
				/* do nothing */;
			break;
  800762:	90                   	nop
		}
	}
  800763:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800764:	e9 0a fc ff ff       	jmp    800373 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800769:	83 c4 40             	add    $0x40,%esp
  80076c:	5b                   	pop    %ebx
  80076d:	5e                   	pop    %esi
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800776:	8d 45 14             	lea    0x14(%ebp),%eax
  800779:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80077c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800783:	8b 45 10             	mov    0x10(%ebp),%eax
  800786:	89 44 24 08          	mov    %eax,0x8(%esp)
  80078a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80078d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800791:	8b 45 08             	mov    0x8(%ebp),%eax
  800794:	89 04 24             	mov    %eax,(%esp)
  800797:	e8 b5 fb ff ff       	call   800351 <vprintfmt>
	va_end(ap);
}
  80079c:	c9                   	leave  
  80079d:	c3                   	ret    

0080079e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  8007a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a4:	8b 40 08             	mov    0x8(%eax),%eax
  8007a7:	8d 50 01             	lea    0x1(%eax),%edx
  8007aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ad:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  8007b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b3:	8b 10                	mov    (%eax),%edx
  8007b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b8:	8b 40 04             	mov    0x4(%eax),%eax
  8007bb:	39 c2                	cmp    %eax,%edx
  8007bd:	73 12                	jae    8007d1 <sprintputch+0x33>
		*b->buf++ = ch;
  8007bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c2:	8b 00                	mov    (%eax),%eax
  8007c4:	8d 48 01             	lea    0x1(%eax),%ecx
  8007c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ca:	89 0a                	mov    %ecx,(%edx)
  8007cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8007cf:	88 10                	mov    %dl,(%eax)
}
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    

008007d3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e2:	8d 50 ff             	lea    -0x1(%eax),%edx
  8007e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e8:	01 d0                	add    %edx,%eax
  8007ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007f4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8007f8:	74 06                	je     800800 <vsnprintf+0x2d>
  8007fa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007fe:	7f 07                	jg     800807 <vsnprintf+0x34>
		return -E_INVAL;
  800800:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800805:	eb 2a                	jmp    800831 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800807:	8b 45 14             	mov    0x14(%ebp),%eax
  80080a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080e:	8b 45 10             	mov    0x10(%ebp),%eax
  800811:	89 44 24 08          	mov    %eax,0x8(%esp)
  800815:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800818:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081c:	c7 04 24 9e 07 80 00 	movl   $0x80079e,(%esp)
  800823:	e8 29 fb ff ff       	call   800351 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800828:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80082e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800831:	c9                   	leave  
  800832:	c3                   	ret    

00800833 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800839:	8d 45 14             	lea    0x14(%ebp),%eax
  80083c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  80083f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800842:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800846:	8b 45 10             	mov    0x10(%ebp),%eax
  800849:	89 44 24 08          	mov    %eax,0x8(%esp)
  80084d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800850:	89 44 24 04          	mov    %eax,0x4(%esp)
  800854:	8b 45 08             	mov    0x8(%ebp),%eax
  800857:	89 04 24             	mov    %eax,(%esp)
  80085a:	e8 74 ff ff ff       	call   8007d3 <vsnprintf>
  80085f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800862:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800865:	c9                   	leave  
  800866:	c3                   	ret    

00800867 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  80086d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800874:	eb 08                	jmp    80087e <strlen+0x17>
		n++;
  800876:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80087a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80087e:	8b 45 08             	mov    0x8(%ebp),%eax
  800881:	0f b6 00             	movzbl (%eax),%eax
  800884:	84 c0                	test   %al,%al
  800886:	75 ee                	jne    800876 <strlen+0xf>
		n++;
	return n;
  800888:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80088b:	c9                   	leave  
  80088c:	c3                   	ret    

0080088d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800893:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80089a:	eb 0c                	jmp    8008a8 <strnlen+0x1b>
		n++;
  80089c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8008a4:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  8008a8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008ac:	74 0a                	je     8008b8 <strnlen+0x2b>
  8008ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b1:	0f b6 00             	movzbl (%eax),%eax
  8008b4:	84 c0                	test   %al,%al
  8008b6:	75 e4                	jne    80089c <strnlen+0xf>
		n++;
	return n;
  8008b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  8008c9:	90                   	nop
  8008ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cd:	8d 50 01             	lea    0x1(%eax),%edx
  8008d0:	89 55 08             	mov    %edx,0x8(%ebp)
  8008d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8008d9:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8008dc:	0f b6 12             	movzbl (%edx),%edx
  8008df:	88 10                	mov    %dl,(%eax)
  8008e1:	0f b6 00             	movzbl (%eax),%eax
  8008e4:	84 c0                	test   %al,%al
  8008e6:	75 e2                	jne    8008ca <strcpy+0xd>
		/* do nothing */;
	return ret;
  8008e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008eb:	c9                   	leave  
  8008ec:	c3                   	ret    

008008ed <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	89 04 24             	mov    %eax,(%esp)
  8008f9:	e8 69 ff ff ff       	call   800867 <strlen>
  8008fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800901:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	01 c2                	add    %eax,%edx
  800909:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800910:	89 14 24             	mov    %edx,(%esp)
  800913:	e8 a5 ff ff ff       	call   8008bd <strcpy>
	return dst;
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80091b:	c9                   	leave  
  80091c:	c3                   	ret    

0080091d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800929:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800930:	eb 23                	jmp    800955 <strncpy+0x38>
		*dst++ = *src;
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	8d 50 01             	lea    0x1(%eax),%edx
  800938:	89 55 08             	mov    %edx,0x8(%ebp)
  80093b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093e:	0f b6 12             	movzbl (%edx),%edx
  800941:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800943:	8b 45 0c             	mov    0xc(%ebp),%eax
  800946:	0f b6 00             	movzbl (%eax),%eax
  800949:	84 c0                	test   %al,%al
  80094b:	74 04                	je     800951 <strncpy+0x34>
			src++;
  80094d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800951:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800955:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800958:	3b 45 10             	cmp    0x10(%ebp),%eax
  80095b:	72 d5                	jb     800932 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  80095d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800960:	c9                   	leave  
  800961:	c3                   	ret    

00800962 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  80096e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800972:	74 33                	je     8009a7 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800974:	eb 17                	jmp    80098d <strlcpy+0x2b>
			*dst++ = *src++;
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8d 50 01             	lea    0x1(%eax),%edx
  80097c:	89 55 08             	mov    %edx,0x8(%ebp)
  80097f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800982:	8d 4a 01             	lea    0x1(%edx),%ecx
  800985:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800988:	0f b6 12             	movzbl (%edx),%edx
  80098b:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80098d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800991:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800995:	74 0a                	je     8009a1 <strlcpy+0x3f>
  800997:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099a:	0f b6 00             	movzbl (%eax),%eax
  80099d:	84 c0                	test   %al,%al
  80099f:	75 d5                	jne    800976 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8009aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009ad:	29 c2                	sub    %eax,%edx
  8009af:	89 d0                	mov    %edx,%eax
}
  8009b1:	c9                   	leave  
  8009b2:	c3                   	ret    

008009b3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  8009b6:	eb 08                	jmp    8009c0 <strcmp+0xd>
		p++, q++;
  8009b8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009bc:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	0f b6 00             	movzbl (%eax),%eax
  8009c6:	84 c0                	test   %al,%al
  8009c8:	74 10                	je     8009da <strcmp+0x27>
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	0f b6 10             	movzbl (%eax),%edx
  8009d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d3:	0f b6 00             	movzbl (%eax),%eax
  8009d6:	38 c2                	cmp    %al,%dl
  8009d8:	74 de                	je     8009b8 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	0f b6 00             	movzbl (%eax),%eax
  8009e0:	0f b6 d0             	movzbl %al,%edx
  8009e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e6:	0f b6 00             	movzbl (%eax),%eax
  8009e9:	0f b6 c0             	movzbl %al,%eax
  8009ec:	29 c2                	sub    %eax,%edx
  8009ee:	89 d0                	mov    %edx,%eax
}
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  8009f5:	eb 0c                	jmp    800a03 <strncmp+0x11>
		n--, p++, q++;
  8009f7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8009fb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009ff:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a03:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a07:	74 1a                	je     800a23 <strncmp+0x31>
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	0f b6 00             	movzbl (%eax),%eax
  800a0f:	84 c0                	test   %al,%al
  800a11:	74 10                	je     800a23 <strncmp+0x31>
  800a13:	8b 45 08             	mov    0x8(%ebp),%eax
  800a16:	0f b6 10             	movzbl (%eax),%edx
  800a19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1c:	0f b6 00             	movzbl (%eax),%eax
  800a1f:	38 c2                	cmp    %al,%dl
  800a21:	74 d4                	je     8009f7 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800a23:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a27:	75 07                	jne    800a30 <strncmp+0x3e>
		return 0;
  800a29:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2e:	eb 16                	jmp    800a46 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	0f b6 00             	movzbl (%eax),%eax
  800a36:	0f b6 d0             	movzbl %al,%edx
  800a39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3c:	0f b6 00             	movzbl (%eax),%eax
  800a3f:	0f b6 c0             	movzbl %al,%eax
  800a42:	29 c2                	sub    %eax,%edx
  800a44:	89 d0                	mov    %edx,%eax
}
  800a46:	5d                   	pop    %ebp
  800a47:	c3                   	ret    

00800a48 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	83 ec 04             	sub    $0x4,%esp
  800a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a51:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a54:	eb 14                	jmp    800a6a <strchr+0x22>
		if (*s == c)
  800a56:	8b 45 08             	mov    0x8(%ebp),%eax
  800a59:	0f b6 00             	movzbl (%eax),%eax
  800a5c:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a5f:	75 05                	jne    800a66 <strchr+0x1e>
			return (char *) s;
  800a61:	8b 45 08             	mov    0x8(%ebp),%eax
  800a64:	eb 13                	jmp    800a79 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a66:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	0f b6 00             	movzbl (%eax),%eax
  800a70:	84 c0                	test   %al,%al
  800a72:	75 e2                	jne    800a56 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a79:	c9                   	leave  
  800a7a:	c3                   	ret    

00800a7b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	83 ec 04             	sub    $0x4,%esp
  800a81:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a84:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a87:	eb 11                	jmp    800a9a <strfind+0x1f>
		if (*s == c)
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	0f b6 00             	movzbl (%eax),%eax
  800a8f:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a92:	75 02                	jne    800a96 <strfind+0x1b>
			break;
  800a94:	eb 0e                	jmp    800aa4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a96:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9d:	0f b6 00             	movzbl (%eax),%eax
  800aa0:	84 c0                	test   %al,%al
  800aa2:	75 e5                	jne    800a89 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800aa4:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800aa7:	c9                   	leave  
  800aa8:	c3                   	ret    

00800aa9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	57                   	push   %edi
	char *p;

	if (n == 0)
  800aad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ab1:	75 05                	jne    800ab8 <memset+0xf>
		return v;
  800ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab6:	eb 5c                	jmp    800b14 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  800abb:	83 e0 03             	and    $0x3,%eax
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	75 41                	jne    800b03 <memset+0x5a>
  800ac2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ac5:	83 e0 03             	and    $0x3,%eax
  800ac8:	85 c0                	test   %eax,%eax
  800aca:	75 37                	jne    800b03 <memset+0x5a>
		c &= 0xFF;
  800acc:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad6:	c1 e0 18             	shl    $0x18,%eax
  800ad9:	89 c2                	mov    %eax,%edx
  800adb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ade:	c1 e0 10             	shl    $0x10,%eax
  800ae1:	09 c2                	or     %eax,%edx
  800ae3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae6:	c1 e0 08             	shl    $0x8,%eax
  800ae9:	09 d0                	or     %edx,%eax
  800aeb:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aee:	8b 45 10             	mov    0x10(%ebp),%eax
  800af1:	c1 e8 02             	shr    $0x2,%eax
  800af4:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800af6:	8b 55 08             	mov    0x8(%ebp),%edx
  800af9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afc:	89 d7                	mov    %edx,%edi
  800afe:	fc                   	cld    
  800aff:	f3 ab                	rep stos %eax,%es:(%edi)
  800b01:	eb 0e                	jmp    800b11 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b03:	8b 55 08             	mov    0x8(%ebp),%edx
  800b06:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b09:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b0c:	89 d7                	mov    %edx,%edi
  800b0e:	fc                   	cld    
  800b0f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800b11:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b14:	5f                   	pop    %edi
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	57                   	push   %edi
  800b1b:	56                   	push   %esi
  800b1c:	53                   	push   %ebx
  800b1d:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b23:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800b26:	8b 45 08             	mov    0x8(%ebp),%eax
  800b29:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800b2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b2f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b32:	73 6d                	jae    800ba1 <memmove+0x8a>
  800b34:	8b 45 10             	mov    0x10(%ebp),%eax
  800b37:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b3a:	01 d0                	add    %edx,%eax
  800b3c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b3f:	76 60                	jbe    800ba1 <memmove+0x8a>
		s += n;
  800b41:	8b 45 10             	mov    0x10(%ebp),%eax
  800b44:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800b47:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4a:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b50:	83 e0 03             	and    $0x3,%eax
  800b53:	85 c0                	test   %eax,%eax
  800b55:	75 2f                	jne    800b86 <memmove+0x6f>
  800b57:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b5a:	83 e0 03             	and    $0x3,%eax
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	75 25                	jne    800b86 <memmove+0x6f>
  800b61:	8b 45 10             	mov    0x10(%ebp),%eax
  800b64:	83 e0 03             	and    $0x3,%eax
  800b67:	85 c0                	test   %eax,%eax
  800b69:	75 1b                	jne    800b86 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b6e:	83 e8 04             	sub    $0x4,%eax
  800b71:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b74:	83 ea 04             	sub    $0x4,%edx
  800b77:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b7a:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b7d:	89 c7                	mov    %eax,%edi
  800b7f:	89 d6                	mov    %edx,%esi
  800b81:	fd                   	std    
  800b82:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b84:	eb 18                	jmp    800b9e <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b86:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b89:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b8f:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b92:	8b 45 10             	mov    0x10(%ebp),%eax
  800b95:	89 d7                	mov    %edx,%edi
  800b97:	89 de                	mov    %ebx,%esi
  800b99:	89 c1                	mov    %eax,%ecx
  800b9b:	fd                   	std    
  800b9c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b9e:	fc                   	cld    
  800b9f:	eb 45                	jmp    800be6 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ba4:	83 e0 03             	and    $0x3,%eax
  800ba7:	85 c0                	test   %eax,%eax
  800ba9:	75 2b                	jne    800bd6 <memmove+0xbf>
  800bab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bae:	83 e0 03             	and    $0x3,%eax
  800bb1:	85 c0                	test   %eax,%eax
  800bb3:	75 21                	jne    800bd6 <memmove+0xbf>
  800bb5:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb8:	83 e0 03             	and    $0x3,%eax
  800bbb:	85 c0                	test   %eax,%eax
  800bbd:	75 17                	jne    800bd6 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bbf:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc2:	c1 e8 02             	shr    $0x2,%eax
  800bc5:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bc7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bca:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bcd:	89 c7                	mov    %eax,%edi
  800bcf:	89 d6                	mov    %edx,%esi
  800bd1:	fc                   	cld    
  800bd2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bd4:	eb 10                	jmp    800be6 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bd9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bdc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bdf:	89 c7                	mov    %eax,%edi
  800be1:	89 d6                	mov    %edx,%esi
  800be3:	fc                   	cld    
  800be4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800be6:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800be9:	83 c4 10             	add    $0x10,%esp
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bf7:	8b 45 10             	mov    0x10(%ebp),%eax
  800bfa:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bfe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c01:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c05:	8b 45 08             	mov    0x8(%ebp),%eax
  800c08:	89 04 24             	mov    %eax,(%esp)
  800c0b:	e8 07 ff ff ff       	call   800b17 <memmove>
}
  800c10:	c9                   	leave  
  800c11:	c3                   	ret    

00800c12 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800c18:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800c1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c21:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800c24:	eb 30                	jmp    800c56 <memcmp+0x44>
		if (*s1 != *s2)
  800c26:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c29:	0f b6 10             	movzbl (%eax),%edx
  800c2c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c2f:	0f b6 00             	movzbl (%eax),%eax
  800c32:	38 c2                	cmp    %al,%dl
  800c34:	74 18                	je     800c4e <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800c36:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c39:	0f b6 00             	movzbl (%eax),%eax
  800c3c:	0f b6 d0             	movzbl %al,%edx
  800c3f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c42:	0f b6 00             	movzbl (%eax),%eax
  800c45:	0f b6 c0             	movzbl %al,%eax
  800c48:	29 c2                	sub    %eax,%edx
  800c4a:	89 d0                	mov    %edx,%eax
  800c4c:	eb 1a                	jmp    800c68 <memcmp+0x56>
		s1++, s2++;
  800c4e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800c52:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c56:	8b 45 10             	mov    0x10(%ebp),%eax
  800c59:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c5c:	89 55 10             	mov    %edx,0x10(%ebp)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	75 c3                	jne    800c26 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c68:	c9                   	leave  
  800c69:	c3                   	ret    

00800c6a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c70:	8b 45 10             	mov    0x10(%ebp),%eax
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	01 d0                	add    %edx,%eax
  800c78:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c7b:	eb 13                	jmp    800c90 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c80:	0f b6 10             	movzbl (%eax),%edx
  800c83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c86:	38 c2                	cmp    %al,%dl
  800c88:	75 02                	jne    800c8c <memfind+0x22>
			break;
  800c8a:	eb 0c                	jmp    800c98 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c8c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c90:	8b 45 08             	mov    0x8(%ebp),%eax
  800c93:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c96:	72 e5                	jb     800c7d <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800c98:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c9b:	c9                   	leave  
  800c9c:	c3                   	ret    

00800c9d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800ca3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800caa:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb1:	eb 04                	jmp    800cb7 <strtol+0x1a>
		s++;
  800cb3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cba:	0f b6 00             	movzbl (%eax),%eax
  800cbd:	3c 20                	cmp    $0x20,%al
  800cbf:	74 f2                	je     800cb3 <strtol+0x16>
  800cc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc4:	0f b6 00             	movzbl (%eax),%eax
  800cc7:	3c 09                	cmp    $0x9,%al
  800cc9:	74 e8                	je     800cb3 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cce:	0f b6 00             	movzbl (%eax),%eax
  800cd1:	3c 2b                	cmp    $0x2b,%al
  800cd3:	75 06                	jne    800cdb <strtol+0x3e>
		s++;
  800cd5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cd9:	eb 15                	jmp    800cf0 <strtol+0x53>
	else if (*s == '-')
  800cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cde:	0f b6 00             	movzbl (%eax),%eax
  800ce1:	3c 2d                	cmp    $0x2d,%al
  800ce3:	75 0b                	jne    800cf0 <strtol+0x53>
		s++, neg = 1;
  800ce5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ce9:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cf0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cf4:	74 06                	je     800cfc <strtol+0x5f>
  800cf6:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800cfa:	75 24                	jne    800d20 <strtol+0x83>
  800cfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cff:	0f b6 00             	movzbl (%eax),%eax
  800d02:	3c 30                	cmp    $0x30,%al
  800d04:	75 1a                	jne    800d20 <strtol+0x83>
  800d06:	8b 45 08             	mov    0x8(%ebp),%eax
  800d09:	83 c0 01             	add    $0x1,%eax
  800d0c:	0f b6 00             	movzbl (%eax),%eax
  800d0f:	3c 78                	cmp    $0x78,%al
  800d11:	75 0d                	jne    800d20 <strtol+0x83>
		s += 2, base = 16;
  800d13:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800d17:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800d1e:	eb 2a                	jmp    800d4a <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800d20:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d24:	75 17                	jne    800d3d <strtol+0xa0>
  800d26:	8b 45 08             	mov    0x8(%ebp),%eax
  800d29:	0f b6 00             	movzbl (%eax),%eax
  800d2c:	3c 30                	cmp    $0x30,%al
  800d2e:	75 0d                	jne    800d3d <strtol+0xa0>
		s++, base = 8;
  800d30:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d34:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d3b:	eb 0d                	jmp    800d4a <strtol+0xad>
	else if (base == 0)
  800d3d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d41:	75 07                	jne    800d4a <strtol+0xad>
		base = 10;
  800d43:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4d:	0f b6 00             	movzbl (%eax),%eax
  800d50:	3c 2f                	cmp    $0x2f,%al
  800d52:	7e 1b                	jle    800d6f <strtol+0xd2>
  800d54:	8b 45 08             	mov    0x8(%ebp),%eax
  800d57:	0f b6 00             	movzbl (%eax),%eax
  800d5a:	3c 39                	cmp    $0x39,%al
  800d5c:	7f 11                	jg     800d6f <strtol+0xd2>
			dig = *s - '0';
  800d5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d61:	0f b6 00             	movzbl (%eax),%eax
  800d64:	0f be c0             	movsbl %al,%eax
  800d67:	83 e8 30             	sub    $0x30,%eax
  800d6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d6d:	eb 48                	jmp    800db7 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d72:	0f b6 00             	movzbl (%eax),%eax
  800d75:	3c 60                	cmp    $0x60,%al
  800d77:	7e 1b                	jle    800d94 <strtol+0xf7>
  800d79:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7c:	0f b6 00             	movzbl (%eax),%eax
  800d7f:	3c 7a                	cmp    $0x7a,%al
  800d81:	7f 11                	jg     800d94 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800d83:	8b 45 08             	mov    0x8(%ebp),%eax
  800d86:	0f b6 00             	movzbl (%eax),%eax
  800d89:	0f be c0             	movsbl %al,%eax
  800d8c:	83 e8 57             	sub    $0x57,%eax
  800d8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d92:	eb 23                	jmp    800db7 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800d94:	8b 45 08             	mov    0x8(%ebp),%eax
  800d97:	0f b6 00             	movzbl (%eax),%eax
  800d9a:	3c 40                	cmp    $0x40,%al
  800d9c:	7e 3d                	jle    800ddb <strtol+0x13e>
  800d9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800da1:	0f b6 00             	movzbl (%eax),%eax
  800da4:	3c 5a                	cmp    $0x5a,%al
  800da6:	7f 33                	jg     800ddb <strtol+0x13e>
			dig = *s - 'A' + 10;
  800da8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dab:	0f b6 00             	movzbl (%eax),%eax
  800dae:	0f be c0             	movsbl %al,%eax
  800db1:	83 e8 37             	sub    $0x37,%eax
  800db4:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dba:	3b 45 10             	cmp    0x10(%ebp),%eax
  800dbd:	7c 02                	jl     800dc1 <strtol+0x124>
			break;
  800dbf:	eb 1a                	jmp    800ddb <strtol+0x13e>
		s++, val = (val * base) + dig;
  800dc1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dc5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800dc8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800dcc:	89 c2                	mov    %eax,%edx
  800dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dd1:	01 d0                	add    %edx,%eax
  800dd3:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800dd6:	e9 6f ff ff ff       	jmp    800d4a <strtol+0xad>

	if (endptr)
  800ddb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ddf:	74 08                	je     800de9 <strtol+0x14c>
		*endptr = (char *) s;
  800de1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de4:	8b 55 08             	mov    0x8(%ebp),%edx
  800de7:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800de9:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800ded:	74 07                	je     800df6 <strtol+0x159>
  800def:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800df2:	f7 d8                	neg    %eax
  800df4:	eb 03                	jmp    800df9 <strtol+0x15c>
  800df6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800df9:	c9                   	leave  
  800dfa:	c3                   	ret    

00800dfb <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	57                   	push   %edi
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
  800e01:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e04:	8b 45 08             	mov    0x8(%ebp),%eax
  800e07:	8b 55 10             	mov    0x10(%ebp),%edx
  800e0a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800e0d:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800e10:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800e13:	8b 75 20             	mov    0x20(%ebp),%esi
  800e16:	cd 30                	int    $0x30
  800e18:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e1f:	74 30                	je     800e51 <syscall+0x56>
  800e21:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e25:	7e 2a                	jle    800e51 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e31:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e35:	c7 44 24 08 84 17 80 	movl   $0x801784,0x8(%esp)
  800e3c:	00 
  800e3d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e44:	00 
  800e45:	c7 04 24 a1 17 80 00 	movl   $0x8017a1,(%esp)
  800e4c:	e8 bf 03 00 00       	call   801210 <_panic>

	return ret;
  800e51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800e54:	83 c4 3c             	add    $0x3c,%esp
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5f                   	pop    %edi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e62:	8b 45 08             	mov    0x8(%ebp),%eax
  800e65:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e6c:	00 
  800e6d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e74:	00 
  800e75:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e7c:	00 
  800e7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e80:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e84:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e88:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e8f:	00 
  800e90:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e97:	e8 5f ff ff ff       	call   800dfb <syscall>
}
  800e9c:	c9                   	leave  
  800e9d:	c3                   	ret    

00800e9e <sys_cgetc>:

int
sys_cgetc(void)
{
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ea4:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800eab:	00 
  800eac:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800eb3:	00 
  800eb4:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ebb:	00 
  800ebc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ec3:	00 
  800ec4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ecb:	00 
  800ecc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ed3:	00 
  800ed4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800edb:	e8 1b ff ff ff       	call   800dfb <syscall>
}
  800ee0:	c9                   	leave  
  800ee1:	c3                   	ret    

00800ee2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800ee8:	8b 45 08             	mov    0x8(%ebp),%eax
  800eeb:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ef2:	00 
  800ef3:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800efa:	00 
  800efb:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f02:	00 
  800f03:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f0a:	00 
  800f0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f0f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f16:	00 
  800f17:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800f1e:	e8 d8 fe ff ff       	call   800dfb <syscall>
}
  800f23:	c9                   	leave  
  800f24:	c3                   	ret    

00800f25 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800f2b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f32:	00 
  800f33:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f3a:	00 
  800f3b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f42:	00 
  800f43:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f4a:	00 
  800f4b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f52:	00 
  800f53:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f5a:	00 
  800f5b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f62:	e8 94 fe ff ff       	call   800dfb <syscall>
}
  800f67:	c9                   	leave  
  800f68:	c3                   	ret    

00800f69 <sys_yield>:

void
sys_yield(void)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f6f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f76:	00 
  800f77:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f7e:	00 
  800f7f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f86:	00 
  800f87:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f8e:	00 
  800f8f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f96:	00 
  800f97:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f9e:	00 
  800f9f:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800fa6:	e8 50 fe ff ff       	call   800dfb <syscall>
}
  800fab:	c9                   	leave  
  800fac:	c3                   	ret    

00800fad <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800fb3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fb6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbc:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fc3:	00 
  800fc4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fcb:	00 
  800fcc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fd0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fd4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fd8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fdf:	00 
  800fe0:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800fe7:	e8 0f fe ff ff       	call   800dfb <syscall>
}
  800fec:	c9                   	leave  
  800fed:	c3                   	ret    

00800fee <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fee:	55                   	push   %ebp
  800fef:	89 e5                	mov    %esp,%ebp
  800ff1:	56                   	push   %esi
  800ff2:	53                   	push   %ebx
  800ff3:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800ff6:	8b 75 18             	mov    0x18(%ebp),%esi
  800ff9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800ffc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801002:	8b 45 08             	mov    0x8(%ebp),%eax
  801005:	89 74 24 18          	mov    %esi,0x18(%esp)
  801009:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80100d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801011:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801015:	89 44 24 08          	mov    %eax,0x8(%esp)
  801019:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801020:	00 
  801021:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  801028:	e8 ce fd ff ff       	call   800dfb <syscall>
}
  80102d:	83 c4 20             	add    $0x20,%esp
  801030:	5b                   	pop    %ebx
  801031:	5e                   	pop    %esi
  801032:	5d                   	pop    %ebp
  801033:	c3                   	ret    

00801034 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80103a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80103d:	8b 45 08             	mov    0x8(%ebp),%eax
  801040:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801047:	00 
  801048:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80104f:	00 
  801050:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801057:	00 
  801058:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80105c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801060:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801067:	00 
  801068:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  80106f:	e8 87 fd ff ff       	call   800dfb <syscall>
}
  801074:	c9                   	leave  
  801075:	c3                   	ret    

00801076 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80107c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80107f:	8b 45 08             	mov    0x8(%ebp),%eax
  801082:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801089:	00 
  80108a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801091:	00 
  801092:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801099:	00 
  80109a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80109e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010a9:	00 
  8010aa:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8010b1:	e8 45 fd ff ff       	call   800dfb <syscall>
}
  8010b6:	c9                   	leave  
  8010b7:	c3                   	ret    

008010b8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8010be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c4:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010cb:	00 
  8010cc:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010d3:	00 
  8010d4:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010db:	00 
  8010dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010e4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010eb:	00 
  8010ec:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8010f3:	e8 03 fd ff ff       	call   800dfb <syscall>
}
  8010f8:	c9                   	leave  
  8010f9:	c3                   	ret    

008010fa <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010fa:	55                   	push   %ebp
  8010fb:	89 e5                	mov    %esp,%ebp
  8010fd:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801100:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801103:	8b 55 10             	mov    0x10(%ebp),%edx
  801106:	8b 45 08             	mov    0x8(%ebp),%eax
  801109:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801110:	00 
  801111:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801115:	89 54 24 10          	mov    %edx,0x10(%esp)
  801119:	8b 55 0c             	mov    0xc(%ebp),%edx
  80111c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801120:	89 44 24 08          	mov    %eax,0x8(%esp)
  801124:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80112b:	00 
  80112c:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  801133:	e8 c3 fc ff ff       	call   800dfb <syscall>
}
  801138:	c9                   	leave  
  801139:	c3                   	ret    

0080113a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801140:	8b 45 08             	mov    0x8(%ebp),%eax
  801143:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80114a:	00 
  80114b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801152:	00 
  801153:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80115a:	00 
  80115b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801162:	00 
  801163:	89 44 24 08          	mov    %eax,0x8(%esp)
  801167:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80116e:	00 
  80116f:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801176:	e8 80 fc ff ff       	call   800dfb <syscall>
}
  80117b:	c9                   	leave  
  80117c:	c3                   	ret    

0080117d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80117d:	55                   	push   %ebp
  80117e:	89 e5                	mov    %esp,%ebp
  801180:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  801183:	a1 08 20 80 00       	mov    0x802008,%eax
  801188:	85 c0                	test   %eax,%eax
  80118a:	75 55                	jne    8011e1 <set_pgfault_handler+0x64>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE),PTE_U|PTE_P|PTE_W);
  80118c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801193:	00 
  801194:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80119b:	ee 
  80119c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011a3:	e8 05 fe ff ff       	call   800fad <sys_page_alloc>
  8011a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(r < 0)
  8011ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8011af:	79 1c                	jns    8011cd <set_pgfault_handler+0x50>
		{
			panic("sys_page_alloc_failed");
  8011b1:	c7 44 24 08 af 17 80 	movl   $0x8017af,0x8(%esp)
  8011b8:	00 
  8011b9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011c0:	00 
  8011c1:	c7 04 24 c5 17 80 00 	movl   $0x8017c5,(%esp)
  8011c8:	e8 43 00 00 00       	call   801210 <_panic>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8011cd:	c7 44 24 04 eb 11 80 	movl   $0x8011eb,0x4(%esp)
  8011d4:	00 
  8011d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011dc:	e8 d7 fe ff ff       	call   8010b8 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e4:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8011e9:	c9                   	leave  
  8011ea:	c3                   	ret    

008011eb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8011eb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8011ec:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8011f1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8011f3:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x30(%esp), %eax
  8011f6:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  8011fa:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8011fd:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 0x28(%esp), %ecx
  801201:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	movl %ecx, (%eax)
  801205:	89 08                	mov    %ecx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	//add $8, %esp
	popl %edx 
  801207:	5a                   	pop    %edx
	popl %edx
  801208:	5a                   	pop    %edx
	popal
  801209:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp
  80120a:	83 c4 04             	add    $0x4,%esp
	popf
  80120d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80120e:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80120f:	c3                   	ret    

00801210 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	53                   	push   %ebx
  801214:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  801217:	8d 45 14             	lea    0x14(%ebp),%eax
  80121a:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80121d:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801223:	e8 fd fc ff ff       	call   800f25 <sys_getenvid>
  801228:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80122f:	8b 55 08             	mov    0x8(%ebp),%edx
  801232:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801236:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80123a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123e:	c7 04 24 d4 17 80 00 	movl   $0x8017d4,(%esp)
  801245:	e8 6d ef ff ff       	call   8001b7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80124a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80124d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801251:	8b 45 10             	mov    0x10(%ebp),%eax
  801254:	89 04 24             	mov    %eax,(%esp)
  801257:	e8 f7 ee ff ff       	call   800153 <vcprintf>
	cprintf("\n");
  80125c:	c7 04 24 f7 17 80 00 	movl   $0x8017f7,(%esp)
  801263:	e8 4f ef ff ff       	call   8001b7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801268:	cc                   	int3   
  801269:	eb fd                	jmp    801268 <_panic+0x58>
  80126b:	66 90                	xchg   %ax,%ax
  80126d:	66 90                	xchg   %ax,%ax
  80126f:	90                   	nop

00801270 <__udivdi3>:
  801270:	55                   	push   %ebp
  801271:	57                   	push   %edi
  801272:	56                   	push   %esi
  801273:	83 ec 0c             	sub    $0xc,%esp
  801276:	8b 44 24 28          	mov    0x28(%esp),%eax
  80127a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80127e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801282:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801286:	85 c0                	test   %eax,%eax
  801288:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80128c:	89 ea                	mov    %ebp,%edx
  80128e:	89 0c 24             	mov    %ecx,(%esp)
  801291:	75 2d                	jne    8012c0 <__udivdi3+0x50>
  801293:	39 e9                	cmp    %ebp,%ecx
  801295:	77 61                	ja     8012f8 <__udivdi3+0x88>
  801297:	85 c9                	test   %ecx,%ecx
  801299:	89 ce                	mov    %ecx,%esi
  80129b:	75 0b                	jne    8012a8 <__udivdi3+0x38>
  80129d:	b8 01 00 00 00       	mov    $0x1,%eax
  8012a2:	31 d2                	xor    %edx,%edx
  8012a4:	f7 f1                	div    %ecx
  8012a6:	89 c6                	mov    %eax,%esi
  8012a8:	31 d2                	xor    %edx,%edx
  8012aa:	89 e8                	mov    %ebp,%eax
  8012ac:	f7 f6                	div    %esi
  8012ae:	89 c5                	mov    %eax,%ebp
  8012b0:	89 f8                	mov    %edi,%eax
  8012b2:	f7 f6                	div    %esi
  8012b4:	89 ea                	mov    %ebp,%edx
  8012b6:	83 c4 0c             	add    $0xc,%esp
  8012b9:	5e                   	pop    %esi
  8012ba:	5f                   	pop    %edi
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    
  8012bd:	8d 76 00             	lea    0x0(%esi),%esi
  8012c0:	39 e8                	cmp    %ebp,%eax
  8012c2:	77 24                	ja     8012e8 <__udivdi3+0x78>
  8012c4:	0f bd e8             	bsr    %eax,%ebp
  8012c7:	83 f5 1f             	xor    $0x1f,%ebp
  8012ca:	75 3c                	jne    801308 <__udivdi3+0x98>
  8012cc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8012d0:	39 34 24             	cmp    %esi,(%esp)
  8012d3:	0f 86 9f 00 00 00    	jbe    801378 <__udivdi3+0x108>
  8012d9:	39 d0                	cmp    %edx,%eax
  8012db:	0f 82 97 00 00 00    	jb     801378 <__udivdi3+0x108>
  8012e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012e8:	31 d2                	xor    %edx,%edx
  8012ea:	31 c0                	xor    %eax,%eax
  8012ec:	83 c4 0c             	add    $0xc,%esp
  8012ef:	5e                   	pop    %esi
  8012f0:	5f                   	pop    %edi
  8012f1:	5d                   	pop    %ebp
  8012f2:	c3                   	ret    
  8012f3:	90                   	nop
  8012f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012f8:	89 f8                	mov    %edi,%eax
  8012fa:	f7 f1                	div    %ecx
  8012fc:	31 d2                	xor    %edx,%edx
  8012fe:	83 c4 0c             	add    $0xc,%esp
  801301:	5e                   	pop    %esi
  801302:	5f                   	pop    %edi
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    
  801305:	8d 76 00             	lea    0x0(%esi),%esi
  801308:	89 e9                	mov    %ebp,%ecx
  80130a:	8b 3c 24             	mov    (%esp),%edi
  80130d:	d3 e0                	shl    %cl,%eax
  80130f:	89 c6                	mov    %eax,%esi
  801311:	b8 20 00 00 00       	mov    $0x20,%eax
  801316:	29 e8                	sub    %ebp,%eax
  801318:	89 c1                	mov    %eax,%ecx
  80131a:	d3 ef                	shr    %cl,%edi
  80131c:	89 e9                	mov    %ebp,%ecx
  80131e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801322:	8b 3c 24             	mov    (%esp),%edi
  801325:	09 74 24 08          	or     %esi,0x8(%esp)
  801329:	89 d6                	mov    %edx,%esi
  80132b:	d3 e7                	shl    %cl,%edi
  80132d:	89 c1                	mov    %eax,%ecx
  80132f:	89 3c 24             	mov    %edi,(%esp)
  801332:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801336:	d3 ee                	shr    %cl,%esi
  801338:	89 e9                	mov    %ebp,%ecx
  80133a:	d3 e2                	shl    %cl,%edx
  80133c:	89 c1                	mov    %eax,%ecx
  80133e:	d3 ef                	shr    %cl,%edi
  801340:	09 d7                	or     %edx,%edi
  801342:	89 f2                	mov    %esi,%edx
  801344:	89 f8                	mov    %edi,%eax
  801346:	f7 74 24 08          	divl   0x8(%esp)
  80134a:	89 d6                	mov    %edx,%esi
  80134c:	89 c7                	mov    %eax,%edi
  80134e:	f7 24 24             	mull   (%esp)
  801351:	39 d6                	cmp    %edx,%esi
  801353:	89 14 24             	mov    %edx,(%esp)
  801356:	72 30                	jb     801388 <__udivdi3+0x118>
  801358:	8b 54 24 04          	mov    0x4(%esp),%edx
  80135c:	89 e9                	mov    %ebp,%ecx
  80135e:	d3 e2                	shl    %cl,%edx
  801360:	39 c2                	cmp    %eax,%edx
  801362:	73 05                	jae    801369 <__udivdi3+0xf9>
  801364:	3b 34 24             	cmp    (%esp),%esi
  801367:	74 1f                	je     801388 <__udivdi3+0x118>
  801369:	89 f8                	mov    %edi,%eax
  80136b:	31 d2                	xor    %edx,%edx
  80136d:	e9 7a ff ff ff       	jmp    8012ec <__udivdi3+0x7c>
  801372:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801378:	31 d2                	xor    %edx,%edx
  80137a:	b8 01 00 00 00       	mov    $0x1,%eax
  80137f:	e9 68 ff ff ff       	jmp    8012ec <__udivdi3+0x7c>
  801384:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801388:	8d 47 ff             	lea    -0x1(%edi),%eax
  80138b:	31 d2                	xor    %edx,%edx
  80138d:	83 c4 0c             	add    $0xc,%esp
  801390:	5e                   	pop    %esi
  801391:	5f                   	pop    %edi
  801392:	5d                   	pop    %ebp
  801393:	c3                   	ret    
  801394:	66 90                	xchg   %ax,%ax
  801396:	66 90                	xchg   %ax,%ax
  801398:	66 90                	xchg   %ax,%ax
  80139a:	66 90                	xchg   %ax,%ax
  80139c:	66 90                	xchg   %ax,%ax
  80139e:	66 90                	xchg   %ax,%ax

008013a0 <__umoddi3>:
  8013a0:	55                   	push   %ebp
  8013a1:	57                   	push   %edi
  8013a2:	56                   	push   %esi
  8013a3:	83 ec 14             	sub    $0x14,%esp
  8013a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8013aa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8013ae:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8013b2:	89 c7                	mov    %eax,%edi
  8013b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8013bc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8013c0:	89 34 24             	mov    %esi,(%esp)
  8013c3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	89 c2                	mov    %eax,%edx
  8013cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013cf:	75 17                	jne    8013e8 <__umoddi3+0x48>
  8013d1:	39 fe                	cmp    %edi,%esi
  8013d3:	76 4b                	jbe    801420 <__umoddi3+0x80>
  8013d5:	89 c8                	mov    %ecx,%eax
  8013d7:	89 fa                	mov    %edi,%edx
  8013d9:	f7 f6                	div    %esi
  8013db:	89 d0                	mov    %edx,%eax
  8013dd:	31 d2                	xor    %edx,%edx
  8013df:	83 c4 14             	add    $0x14,%esp
  8013e2:	5e                   	pop    %esi
  8013e3:	5f                   	pop    %edi
  8013e4:	5d                   	pop    %ebp
  8013e5:	c3                   	ret    
  8013e6:	66 90                	xchg   %ax,%ax
  8013e8:	39 f8                	cmp    %edi,%eax
  8013ea:	77 54                	ja     801440 <__umoddi3+0xa0>
  8013ec:	0f bd e8             	bsr    %eax,%ebp
  8013ef:	83 f5 1f             	xor    $0x1f,%ebp
  8013f2:	75 5c                	jne    801450 <__umoddi3+0xb0>
  8013f4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8013f8:	39 3c 24             	cmp    %edi,(%esp)
  8013fb:	0f 87 e7 00 00 00    	ja     8014e8 <__umoddi3+0x148>
  801401:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801405:	29 f1                	sub    %esi,%ecx
  801407:	19 c7                	sbb    %eax,%edi
  801409:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80140d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801411:	8b 44 24 08          	mov    0x8(%esp),%eax
  801415:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801419:	83 c4 14             	add    $0x14,%esp
  80141c:	5e                   	pop    %esi
  80141d:	5f                   	pop    %edi
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    
  801420:	85 f6                	test   %esi,%esi
  801422:	89 f5                	mov    %esi,%ebp
  801424:	75 0b                	jne    801431 <__umoddi3+0x91>
  801426:	b8 01 00 00 00       	mov    $0x1,%eax
  80142b:	31 d2                	xor    %edx,%edx
  80142d:	f7 f6                	div    %esi
  80142f:	89 c5                	mov    %eax,%ebp
  801431:	8b 44 24 04          	mov    0x4(%esp),%eax
  801435:	31 d2                	xor    %edx,%edx
  801437:	f7 f5                	div    %ebp
  801439:	89 c8                	mov    %ecx,%eax
  80143b:	f7 f5                	div    %ebp
  80143d:	eb 9c                	jmp    8013db <__umoddi3+0x3b>
  80143f:	90                   	nop
  801440:	89 c8                	mov    %ecx,%eax
  801442:	89 fa                	mov    %edi,%edx
  801444:	83 c4 14             	add    $0x14,%esp
  801447:	5e                   	pop    %esi
  801448:	5f                   	pop    %edi
  801449:	5d                   	pop    %ebp
  80144a:	c3                   	ret    
  80144b:	90                   	nop
  80144c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801450:	8b 04 24             	mov    (%esp),%eax
  801453:	be 20 00 00 00       	mov    $0x20,%esi
  801458:	89 e9                	mov    %ebp,%ecx
  80145a:	29 ee                	sub    %ebp,%esi
  80145c:	d3 e2                	shl    %cl,%edx
  80145e:	89 f1                	mov    %esi,%ecx
  801460:	d3 e8                	shr    %cl,%eax
  801462:	89 e9                	mov    %ebp,%ecx
  801464:	89 44 24 04          	mov    %eax,0x4(%esp)
  801468:	8b 04 24             	mov    (%esp),%eax
  80146b:	09 54 24 04          	or     %edx,0x4(%esp)
  80146f:	89 fa                	mov    %edi,%edx
  801471:	d3 e0                	shl    %cl,%eax
  801473:	89 f1                	mov    %esi,%ecx
  801475:	89 44 24 08          	mov    %eax,0x8(%esp)
  801479:	8b 44 24 10          	mov    0x10(%esp),%eax
  80147d:	d3 ea                	shr    %cl,%edx
  80147f:	89 e9                	mov    %ebp,%ecx
  801481:	d3 e7                	shl    %cl,%edi
  801483:	89 f1                	mov    %esi,%ecx
  801485:	d3 e8                	shr    %cl,%eax
  801487:	89 e9                	mov    %ebp,%ecx
  801489:	09 f8                	or     %edi,%eax
  80148b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80148f:	f7 74 24 04          	divl   0x4(%esp)
  801493:	d3 e7                	shl    %cl,%edi
  801495:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801499:	89 d7                	mov    %edx,%edi
  80149b:	f7 64 24 08          	mull   0x8(%esp)
  80149f:	39 d7                	cmp    %edx,%edi
  8014a1:	89 c1                	mov    %eax,%ecx
  8014a3:	89 14 24             	mov    %edx,(%esp)
  8014a6:	72 2c                	jb     8014d4 <__umoddi3+0x134>
  8014a8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8014ac:	72 22                	jb     8014d0 <__umoddi3+0x130>
  8014ae:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014b2:	29 c8                	sub    %ecx,%eax
  8014b4:	19 d7                	sbb    %edx,%edi
  8014b6:	89 e9                	mov    %ebp,%ecx
  8014b8:	89 fa                	mov    %edi,%edx
  8014ba:	d3 e8                	shr    %cl,%eax
  8014bc:	89 f1                	mov    %esi,%ecx
  8014be:	d3 e2                	shl    %cl,%edx
  8014c0:	89 e9                	mov    %ebp,%ecx
  8014c2:	d3 ef                	shr    %cl,%edi
  8014c4:	09 d0                	or     %edx,%eax
  8014c6:	89 fa                	mov    %edi,%edx
  8014c8:	83 c4 14             	add    $0x14,%esp
  8014cb:	5e                   	pop    %esi
  8014cc:	5f                   	pop    %edi
  8014cd:	5d                   	pop    %ebp
  8014ce:	c3                   	ret    
  8014cf:	90                   	nop
  8014d0:	39 d7                	cmp    %edx,%edi
  8014d2:	75 da                	jne    8014ae <__umoddi3+0x10e>
  8014d4:	8b 14 24             	mov    (%esp),%edx
  8014d7:	89 c1                	mov    %eax,%ecx
  8014d9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8014dd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8014e1:	eb cb                	jmp    8014ae <__umoddi3+0x10e>
  8014e3:	90                   	nop
  8014e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014e8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8014ec:	0f 82 0f ff ff ff    	jb     801401 <__umoddi3+0x61>
  8014f2:	e9 1a ff ff ff       	jmp    801411 <__umoddi3+0x71>
