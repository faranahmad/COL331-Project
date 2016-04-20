
obj/user/faultreadkernel:     file format elf32-i386


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
  80002c:	e8 21 00 00 00       	call   800052 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	b8 00 00 10 f0       	mov    $0xf0100000,%eax
  80003e:	8b 00                	mov    (%eax),%eax
  800040:	89 44 24 04          	mov    %eax,0x4(%esp)
  800044:	c7 04 24 40 14 80 00 	movl   $0x801440,(%esp)
  80004b:	e8 24 01 00 00       	call   800174 <cprintf>
}
  800050:	c9                   	leave  
  800051:	c3                   	ret    

00800052 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800052:	55                   	push   %ebp
  800053:	89 e5                	mov    %esp,%ebp
  800055:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800058:	e8 85 0e 00 00       	call   800ee2 <sys_getenvid>
  80005d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800062:	c1 e0 02             	shl    $0x2,%eax
  800065:	89 c2                	mov    %eax,%edx
  800067:	c1 e2 05             	shl    $0x5,%edx
  80006a:	29 c2                	sub    %eax,%edx
  80006c:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  800072:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800077:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80007b:	7e 0a                	jle    800087 <libmain+0x35>
		binaryname = argv[0];
  80007d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800080:	8b 00                	mov    (%eax),%eax
  800082:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800087:	8b 45 0c             	mov    0xc(%ebp),%eax
  80008a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008e:	8b 45 08             	mov    0x8(%ebp),%eax
  800091:	89 04 24             	mov    %eax,(%esp)
  800094:	e8 9a ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800099:	e8 02 00 00 00       	call   8000a0 <exit>
}
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ad:	e8 ed 0d 00 00       	call   800e9f <sys_env_destroy>
}
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8000ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000bd:	8b 00                	mov    (%eax),%eax
  8000bf:	8d 48 01             	lea    0x1(%eax),%ecx
  8000c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000c5:	89 0a                	mov    %ecx,(%edx)
  8000c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ca:	89 d1                	mov    %edx,%ecx
  8000cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000cf:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8000d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000d6:	8b 00                	mov    (%eax),%eax
  8000d8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000dd:	75 20                	jne    8000ff <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8000df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e2:	8b 00                	mov    (%eax),%eax
  8000e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000e7:	83 c2 08             	add    $0x8,%edx
  8000ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ee:	89 14 24             	mov    %edx,(%esp)
  8000f1:	e8 23 0d 00 00       	call   800e19 <sys_cputs>
		b->idx = 0;
  8000f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8000ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800102:	8b 40 04             	mov    0x4(%eax),%eax
  800105:	8d 50 01             	lea    0x1(%eax),%edx
  800108:	8b 45 0c             	mov    0xc(%ebp),%eax
  80010b:	89 50 04             	mov    %edx,0x4(%eax)
}
  80010e:	c9                   	leave  
  80010f:	c3                   	ret    

00800110 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800119:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800120:	00 00 00 
	b.cnt = 0;
  800123:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80012a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800130:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800134:	8b 45 08             	mov    0x8(%ebp),%eax
  800137:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800141:	89 44 24 04          	mov    %eax,0x4(%esp)
  800145:	c7 04 24 b4 00 80 00 	movl   $0x8000b4,(%esp)
  80014c:	e8 bd 01 00 00       	call   80030e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800151:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800157:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800161:	83 c0 08             	add    $0x8,%eax
  800164:	89 04 24             	mov    %eax,(%esp)
  800167:	e8 ad 0c 00 00       	call   800e19 <sys_cputs>

	return b.cnt;
  80016c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017a:	8d 45 0c             	lea    0xc(%ebp),%eax
  80017d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800180:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800183:	89 44 24 04          	mov    %eax,0x4(%esp)
  800187:	8b 45 08             	mov    0x8(%ebp),%eax
  80018a:	89 04 24             	mov    %eax,(%esp)
  80018d:	e8 7e ff ff ff       	call   800110 <vcprintf>
  800192:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800195:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800198:	c9                   	leave  
  800199:	c3                   	ret    

0080019a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80019a:	55                   	push   %ebp
  80019b:	89 e5                	mov    %esp,%ebp
  80019d:	53                   	push   %ebx
  80019e:	83 ec 34             	sub    $0x34,%esp
  8001a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8001a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8001aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ad:	8b 45 18             	mov    0x18(%ebp),%eax
  8001b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b5:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001b8:	77 72                	ja     80022c <printnum+0x92>
  8001ba:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001bd:	72 05                	jb     8001c4 <printnum+0x2a>
  8001bf:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8001c2:	77 68                	ja     80022c <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c4:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8001c7:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001ca:	8b 45 18             	mov    0x18(%ebp),%eax
  8001cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8001d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8001e0:	89 04 24             	mov    %eax,(%esp)
  8001e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001e7:	e8 b4 0f 00 00       	call   8011a0 <__udivdi3>
  8001ec:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8001ef:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8001f3:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8001f7:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001fa:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800202:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800206:	8b 45 0c             	mov    0xc(%ebp),%eax
  800209:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020d:	8b 45 08             	mov    0x8(%ebp),%eax
  800210:	89 04 24             	mov    %eax,(%esp)
  800213:	e8 82 ff ff ff       	call   80019a <printnum>
  800218:	eb 1c                	jmp    800236 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800221:	8b 45 20             	mov    0x20(%ebp),%eax
  800224:	89 04 24             	mov    %eax,(%esp)
  800227:	8b 45 08             	mov    0x8(%ebp),%eax
  80022a:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022c:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800230:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800234:	7f e4                	jg     80021a <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800236:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800239:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800241:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800244:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800248:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80024c:	89 04 24             	mov    %eax,(%esp)
  80024f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800253:	e8 78 10 00 00       	call   8012d0 <__umoddi3>
  800258:	05 48 15 80 00       	add    $0x801548,%eax
  80025d:	0f b6 00             	movzbl (%eax),%eax
  800260:	0f be c0             	movsbl %al,%eax
  800263:	8b 55 0c             	mov    0xc(%ebp),%edx
  800266:	89 54 24 04          	mov    %edx,0x4(%esp)
  80026a:	89 04 24             	mov    %eax,(%esp)
  80026d:	8b 45 08             	mov    0x8(%ebp),%eax
  800270:	ff d0                	call   *%eax
}
  800272:	83 c4 34             	add    $0x34,%esp
  800275:	5b                   	pop    %ebx
  800276:	5d                   	pop    %ebp
  800277:	c3                   	ret    

00800278 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80027f:	7e 14                	jle    800295 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800281:	8b 45 08             	mov    0x8(%ebp),%eax
  800284:	8b 00                	mov    (%eax),%eax
  800286:	8d 48 08             	lea    0x8(%eax),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	89 0a                	mov    %ecx,(%edx)
  80028e:	8b 50 04             	mov    0x4(%eax),%edx
  800291:	8b 00                	mov    (%eax),%eax
  800293:	eb 30                	jmp    8002c5 <getuint+0x4d>
	else if (lflag)
  800295:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800299:	74 16                	je     8002b1 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  80029b:	8b 45 08             	mov    0x8(%ebp),%eax
  80029e:	8b 00                	mov    (%eax),%eax
  8002a0:	8d 48 04             	lea    0x4(%eax),%ecx
  8002a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a6:	89 0a                	mov    %ecx,(%edx)
  8002a8:	8b 00                	mov    (%eax),%eax
  8002aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8002af:	eb 14                	jmp    8002c5 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8002b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b4:	8b 00                	mov    (%eax),%eax
  8002b6:	8d 48 04             	lea    0x4(%eax),%ecx
  8002b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bc:	89 0a                	mov    %ecx,(%edx)
  8002be:	8b 00                	mov    (%eax),%eax
  8002c0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c5:	5d                   	pop    %ebp
  8002c6:	c3                   	ret    

008002c7 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002c7:	55                   	push   %ebp
  8002c8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ca:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002ce:	7e 14                	jle    8002e4 <getint+0x1d>
		return va_arg(*ap, long long);
  8002d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d3:	8b 00                	mov    (%eax),%eax
  8002d5:	8d 48 08             	lea    0x8(%eax),%ecx
  8002d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002db:	89 0a                	mov    %ecx,(%edx)
  8002dd:	8b 50 04             	mov    0x4(%eax),%edx
  8002e0:	8b 00                	mov    (%eax),%eax
  8002e2:	eb 28                	jmp    80030c <getint+0x45>
	else if (lflag)
  8002e4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002e8:	74 12                	je     8002fc <getint+0x35>
		return va_arg(*ap, long);
  8002ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ed:	8b 00                	mov    (%eax),%eax
  8002ef:	8d 48 04             	lea    0x4(%eax),%ecx
  8002f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f5:	89 0a                	mov    %ecx,(%edx)
  8002f7:	8b 00                	mov    (%eax),%eax
  8002f9:	99                   	cltd   
  8002fa:	eb 10                	jmp    80030c <getint+0x45>
	else
		return va_arg(*ap, int);
  8002fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ff:	8b 00                	mov    (%eax),%eax
  800301:	8d 48 04             	lea    0x4(%eax),%ecx
  800304:	8b 55 08             	mov    0x8(%ebp),%edx
  800307:	89 0a                	mov    %ecx,(%edx)
  800309:	8b 00                	mov    (%eax),%eax
  80030b:	99                   	cltd   
}
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	56                   	push   %esi
  800312:	53                   	push   %ebx
  800313:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800316:	eb 18                	jmp    800330 <vprintfmt+0x22>
			if (ch == '\0')
  800318:	85 db                	test   %ebx,%ebx
  80031a:	75 05                	jne    800321 <vprintfmt+0x13>
				return;
  80031c:	e9 05 04 00 00       	jmp    800726 <vprintfmt+0x418>
			putch(ch, putdat);
  800321:	8b 45 0c             	mov    0xc(%ebp),%eax
  800324:	89 44 24 04          	mov    %eax,0x4(%esp)
  800328:	89 1c 24             	mov    %ebx,(%esp)
  80032b:	8b 45 08             	mov    0x8(%ebp),%eax
  80032e:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800330:	8b 45 10             	mov    0x10(%ebp),%eax
  800333:	8d 50 01             	lea    0x1(%eax),%edx
  800336:	89 55 10             	mov    %edx,0x10(%ebp)
  800339:	0f b6 00             	movzbl (%eax),%eax
  80033c:	0f b6 d8             	movzbl %al,%ebx
  80033f:	83 fb 25             	cmp    $0x25,%ebx
  800342:	75 d4                	jne    800318 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800344:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800348:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80034f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800356:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80035d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8b 45 10             	mov    0x10(%ebp),%eax
  800367:	8d 50 01             	lea    0x1(%eax),%edx
  80036a:	89 55 10             	mov    %edx,0x10(%ebp)
  80036d:	0f b6 00             	movzbl (%eax),%eax
  800370:	0f b6 d8             	movzbl %al,%ebx
  800373:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800376:	83 f8 55             	cmp    $0x55,%eax
  800379:	0f 87 76 03 00 00    	ja     8006f5 <vprintfmt+0x3e7>
  80037f:	8b 04 85 6c 15 80 00 	mov    0x80156c(,%eax,4),%eax
  800386:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800388:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80038c:	eb d6                	jmp    800364 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80038e:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800392:	eb d0                	jmp    800364 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800394:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  80039b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80039e:	89 d0                	mov    %edx,%eax
  8003a0:	c1 e0 02             	shl    $0x2,%eax
  8003a3:	01 d0                	add    %edx,%eax
  8003a5:	01 c0                	add    %eax,%eax
  8003a7:	01 d8                	add    %ebx,%eax
  8003a9:	83 e8 30             	sub    $0x30,%eax
  8003ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8003af:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b2:	0f b6 00             	movzbl (%eax),%eax
  8003b5:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8003b8:	83 fb 2f             	cmp    $0x2f,%ebx
  8003bb:	7e 0b                	jle    8003c8 <vprintfmt+0xba>
  8003bd:	83 fb 39             	cmp    $0x39,%ebx
  8003c0:	7f 06                	jg     8003c8 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c2:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c6:	eb d3                	jmp    80039b <vprintfmt+0x8d>
			goto process_precision;
  8003c8:	eb 33                	jmp    8003fd <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8003ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cd:	8d 50 04             	lea    0x4(%eax),%edx
  8003d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d3:	8b 00                	mov    (%eax),%eax
  8003d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8003d8:	eb 23                	jmp    8003fd <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8003da:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003de:	79 0c                	jns    8003ec <vprintfmt+0xde>
				width = 0;
  8003e0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8003e7:	e9 78 ff ff ff       	jmp    800364 <vprintfmt+0x56>
  8003ec:	e9 73 ff ff ff       	jmp    800364 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8003f1:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003f8:	e9 67 ff ff ff       	jmp    800364 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8003fd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800401:	79 12                	jns    800415 <vprintfmt+0x107>
				width = precision, precision = -1;
  800403:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800406:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800409:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800410:	e9 4f ff ff ff       	jmp    800364 <vprintfmt+0x56>
  800415:	e9 4a ff ff ff       	jmp    800364 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80041a:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80041e:	e9 41 ff ff ff       	jmp    800364 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800423:	8b 45 14             	mov    0x14(%ebp),%eax
  800426:	8d 50 04             	lea    0x4(%eax),%edx
  800429:	89 55 14             	mov    %edx,0x14(%ebp)
  80042c:	8b 00                	mov    (%eax),%eax
  80042e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800431:	89 54 24 04          	mov    %edx,0x4(%esp)
  800435:	89 04 24             	mov    %eax,(%esp)
  800438:	8b 45 08             	mov    0x8(%ebp),%eax
  80043b:	ff d0                	call   *%eax
			break;
  80043d:	e9 de 02 00 00       	jmp    800720 <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800442:	8b 45 14             	mov    0x14(%ebp),%eax
  800445:	8d 50 04             	lea    0x4(%eax),%edx
  800448:	89 55 14             	mov    %edx,0x14(%ebp)
  80044b:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80044d:	85 db                	test   %ebx,%ebx
  80044f:	79 02                	jns    800453 <vprintfmt+0x145>
				err = -err;
  800451:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800453:	83 fb 09             	cmp    $0x9,%ebx
  800456:	7f 0b                	jg     800463 <vprintfmt+0x155>
  800458:	8b 34 9d 20 15 80 00 	mov    0x801520(,%ebx,4),%esi
  80045f:	85 f6                	test   %esi,%esi
  800461:	75 23                	jne    800486 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800463:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800467:	c7 44 24 08 59 15 80 	movl   $0x801559,0x8(%esp)
  80046e:	00 
  80046f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800472:	89 44 24 04          	mov    %eax,0x4(%esp)
  800476:	8b 45 08             	mov    0x8(%ebp),%eax
  800479:	89 04 24             	mov    %eax,(%esp)
  80047c:	e8 ac 02 00 00       	call   80072d <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800481:	e9 9a 02 00 00       	jmp    800720 <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800486:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80048a:	c7 44 24 08 62 15 80 	movl   $0x801562,0x8(%esp)
  800491:	00 
  800492:	8b 45 0c             	mov    0xc(%ebp),%eax
  800495:	89 44 24 04          	mov    %eax,0x4(%esp)
  800499:	8b 45 08             	mov    0x8(%ebp),%eax
  80049c:	89 04 24             	mov    %eax,(%esp)
  80049f:	e8 89 02 00 00       	call   80072d <printfmt>
			break;
  8004a4:	e9 77 02 00 00       	jmp    800720 <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 50 04             	lea    0x4(%eax),%edx
  8004af:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b2:	8b 30                	mov    (%eax),%esi
  8004b4:	85 f6                	test   %esi,%esi
  8004b6:	75 05                	jne    8004bd <vprintfmt+0x1af>
				p = "(null)";
  8004b8:	be 65 15 80 00       	mov    $0x801565,%esi
			if (width > 0 && padc != '-')
  8004bd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c1:	7e 37                	jle    8004fa <vprintfmt+0x1ec>
  8004c3:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8004c7:	74 31                	je     8004fa <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d0:	89 34 24             	mov    %esi,(%esp)
  8004d3:	e8 72 03 00 00       	call   80084a <strnlen>
  8004d8:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8004db:	eb 17                	jmp    8004f4 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8004dd:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8004e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004e4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004e8:	89 04 24             	mov    %eax,(%esp)
  8004eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ee:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f0:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8004f4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f8:	7f e3                	jg     8004dd <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fa:	eb 38                	jmp    800534 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8004fc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800500:	74 1f                	je     800521 <vprintfmt+0x213>
  800502:	83 fb 1f             	cmp    $0x1f,%ebx
  800505:	7e 05                	jle    80050c <vprintfmt+0x1fe>
  800507:	83 fb 7e             	cmp    $0x7e,%ebx
  80050a:	7e 15                	jle    800521 <vprintfmt+0x213>
					putch('?', putdat);
  80050c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800513:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80051a:	8b 45 08             	mov    0x8(%ebp),%eax
  80051d:	ff d0                	call   *%eax
  80051f:	eb 0f                	jmp    800530 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800521:	8b 45 0c             	mov    0xc(%ebp),%eax
  800524:	89 44 24 04          	mov    %eax,0x4(%esp)
  800528:	89 1c 24             	mov    %ebx,(%esp)
  80052b:	8b 45 08             	mov    0x8(%ebp),%eax
  80052e:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800530:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800534:	89 f0                	mov    %esi,%eax
  800536:	8d 70 01             	lea    0x1(%eax),%esi
  800539:	0f b6 00             	movzbl (%eax),%eax
  80053c:	0f be d8             	movsbl %al,%ebx
  80053f:	85 db                	test   %ebx,%ebx
  800541:	74 10                	je     800553 <vprintfmt+0x245>
  800543:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800547:	78 b3                	js     8004fc <vprintfmt+0x1ee>
  800549:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80054d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800551:	79 a9                	jns    8004fc <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800553:	eb 17                	jmp    80056c <vprintfmt+0x25e>
				putch(' ', putdat);
  800555:	8b 45 0c             	mov    0xc(%ebp),%eax
  800558:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800563:	8b 45 08             	mov    0x8(%ebp),%eax
  800566:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800568:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80056c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800570:	7f e3                	jg     800555 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800572:	e9 a9 01 00 00       	jmp    800720 <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800577:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80057a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057e:	8d 45 14             	lea    0x14(%ebp),%eax
  800581:	89 04 24             	mov    %eax,(%esp)
  800584:	e8 3e fd ff ff       	call   8002c7 <getint>
  800589:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80058c:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  80058f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800592:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800595:	85 d2                	test   %edx,%edx
  800597:	79 26                	jns    8005bf <vprintfmt+0x2b1>
				putch('-', putdat);
  800599:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005aa:	ff d0                	call   *%eax
				num = -(long long) num;
  8005ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005af:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005b2:	f7 d8                	neg    %eax
  8005b4:	83 d2 00             	adc    $0x0,%edx
  8005b7:	f7 da                	neg    %edx
  8005b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005bc:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8005bf:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8005c6:	e9 e1 00 00 00       	jmp    8006ac <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d5:	89 04 24             	mov    %eax,(%esp)
  8005d8:	e8 9b fc ff ff       	call   800278 <getuint>
  8005dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005e0:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8005e3:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8005ea:	e9 bd 00 00 00       	jmp    8006ac <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  8005ef:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  8005f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fd:	8d 45 14             	lea    0x14(%ebp),%eax
  800600:	89 04 24             	mov    %eax,(%esp)
  800603:	e8 70 fc ff ff       	call   800278 <getuint>
  800608:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80060b:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  80060e:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800612:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800615:	89 54 24 18          	mov    %edx,0x18(%esp)
  800619:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061c:	89 54 24 14          	mov    %edx,0x14(%esp)
  800620:	89 44 24 10          	mov    %eax,0x10(%esp)
  800624:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800627:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80062a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80062e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800632:	8b 45 0c             	mov    0xc(%ebp),%eax
  800635:	89 44 24 04          	mov    %eax,0x4(%esp)
  800639:	8b 45 08             	mov    0x8(%ebp),%eax
  80063c:	89 04 24             	mov    %eax,(%esp)
  80063f:	e8 56 fb ff ff       	call   80019a <printnum>
			break;
  800644:	e9 d7 00 00 00       	jmp    800720 <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  800649:	8b 45 0c             	mov    0xc(%ebp),%eax
  80064c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800650:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800657:	8b 45 08             	mov    0x8(%ebp),%eax
  80065a:	ff d0                	call   *%eax
			putch('x', putdat);
  80065c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80065f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800663:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80066a:	8b 45 08             	mov    0x8(%ebp),%eax
  80066d:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8d 50 04             	lea    0x4(%eax),%edx
  800675:	89 55 14             	mov    %edx,0x14(%ebp)
  800678:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80067a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80067d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800684:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  80068b:	eb 1f                	jmp    8006ac <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80068d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800690:	89 44 24 04          	mov    %eax,0x4(%esp)
  800694:	8d 45 14             	lea    0x14(%ebp),%eax
  800697:	89 04 24             	mov    %eax,(%esp)
  80069a:	e8 d9 fb ff ff       	call   800278 <getuint>
  80069f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006a2:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8006a5:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ac:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8006b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b3:	89 54 24 18          	mov    %edx,0x18(%esp)
  8006b7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006ba:	89 54 24 14          	mov    %edx,0x14(%esp)
  8006be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006cc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006da:	89 04 24             	mov    %eax,(%esp)
  8006dd:	e8 b8 fa ff ff       	call   80019a <printnum>
			break;
  8006e2:	eb 3c                	jmp    800720 <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006eb:	89 1c 24             	mov    %ebx,(%esp)
  8006ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f1:	ff d0                	call   *%eax
			break;
  8006f3:	eb 2b                	jmp    800720 <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800703:	8b 45 08             	mov    0x8(%ebp),%eax
  800706:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800708:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80070c:	eb 04                	jmp    800712 <vprintfmt+0x404>
  80070e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800712:	8b 45 10             	mov    0x10(%ebp),%eax
  800715:	83 e8 01             	sub    $0x1,%eax
  800718:	0f b6 00             	movzbl (%eax),%eax
  80071b:	3c 25                	cmp    $0x25,%al
  80071d:	75 ef                	jne    80070e <vprintfmt+0x400>
				/* do nothing */;
			break;
  80071f:	90                   	nop
		}
	}
  800720:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800721:	e9 0a fc ff ff       	jmp    800330 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800726:	83 c4 40             	add    $0x40,%esp
  800729:	5b                   	pop    %ebx
  80072a:	5e                   	pop    %esi
  80072b:	5d                   	pop    %ebp
  80072c:	c3                   	ret    

0080072d <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800733:	8d 45 14             	lea    0x14(%ebp),%eax
  800736:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800739:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800740:	8b 45 10             	mov    0x10(%ebp),%eax
  800743:	89 44 24 08          	mov    %eax,0x8(%esp)
  800747:	8b 45 0c             	mov    0xc(%ebp),%eax
  80074a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074e:	8b 45 08             	mov    0x8(%ebp),%eax
  800751:	89 04 24             	mov    %eax,(%esp)
  800754:	e8 b5 fb ff ff       	call   80030e <vprintfmt>
	va_end(ap);
}
  800759:	c9                   	leave  
  80075a:	c3                   	ret    

0080075b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  80075e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800761:	8b 40 08             	mov    0x8(%eax),%eax
  800764:	8d 50 01             	lea    0x1(%eax),%edx
  800767:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076a:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  80076d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800770:	8b 10                	mov    (%eax),%edx
  800772:	8b 45 0c             	mov    0xc(%ebp),%eax
  800775:	8b 40 04             	mov    0x4(%eax),%eax
  800778:	39 c2                	cmp    %eax,%edx
  80077a:	73 12                	jae    80078e <sprintputch+0x33>
		*b->buf++ = ch;
  80077c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80077f:	8b 00                	mov    (%eax),%eax
  800781:	8d 48 01             	lea    0x1(%eax),%ecx
  800784:	8b 55 0c             	mov    0xc(%ebp),%edx
  800787:	89 0a                	mov    %ecx,(%edx)
  800789:	8b 55 08             	mov    0x8(%ebp),%edx
  80078c:	88 10                	mov    %dl,(%eax)
}
  80078e:	5d                   	pop    %ebp
  80078f:	c3                   	ret    

00800790 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800796:	8b 45 08             	mov    0x8(%ebp),%eax
  800799:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80079c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079f:	8d 50 ff             	lea    -0x1(%eax),%edx
  8007a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a5:	01 d0                	add    %edx,%eax
  8007a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8007b5:	74 06                	je     8007bd <vsnprintf+0x2d>
  8007b7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007bb:	7f 07                	jg     8007c4 <vsnprintf+0x34>
		return -E_INVAL;
  8007bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c2:	eb 2a                	jmp    8007ee <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d9:	c7 04 24 5b 07 80 00 	movl   $0x80075b,(%esp)
  8007e0:	e8 29 fb ff ff       	call   80030e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8007fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800803:	8b 45 10             	mov    0x10(%ebp),%eax
  800806:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80080d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800811:	8b 45 08             	mov    0x8(%ebp),%eax
  800814:	89 04 24             	mov    %eax,(%esp)
  800817:	e8 74 ff ff ff       	call   800790 <vsnprintf>
  80081c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  80081f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800822:	c9                   	leave  
  800823:	c3                   	ret    

00800824 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  80082a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800831:	eb 08                	jmp    80083b <strlen+0x17>
		n++;
  800833:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800837:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80083b:	8b 45 08             	mov    0x8(%ebp),%eax
  80083e:	0f b6 00             	movzbl (%eax),%eax
  800841:	84 c0                	test   %al,%al
  800843:	75 ee                	jne    800833 <strlen+0xf>
		n++;
	return n;
  800845:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800848:	c9                   	leave  
  800849:	c3                   	ret    

0080084a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800850:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800857:	eb 0c                	jmp    800865 <strnlen+0x1b>
		n++;
  800859:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800861:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800865:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800869:	74 0a                	je     800875 <strnlen+0x2b>
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	0f b6 00             	movzbl (%eax),%eax
  800871:	84 c0                	test   %al,%al
  800873:	75 e4                	jne    800859 <strnlen+0xf>
		n++;
	return n;
  800875:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800878:	c9                   	leave  
  800879:	c3                   	ret    

0080087a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800886:	90                   	nop
  800887:	8b 45 08             	mov    0x8(%ebp),%eax
  80088a:	8d 50 01             	lea    0x1(%eax),%edx
  80088d:	89 55 08             	mov    %edx,0x8(%ebp)
  800890:	8b 55 0c             	mov    0xc(%ebp),%edx
  800893:	8d 4a 01             	lea    0x1(%edx),%ecx
  800896:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800899:	0f b6 12             	movzbl (%edx),%edx
  80089c:	88 10                	mov    %dl,(%eax)
  80089e:	0f b6 00             	movzbl (%eax),%eax
  8008a1:	84 c0                	test   %al,%al
  8008a3:	75 e2                	jne    800887 <strcpy+0xd>
		/* do nothing */;
	return ret;
  8008a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008a8:	c9                   	leave  
  8008a9:	c3                   	ret    

008008aa <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	89 04 24             	mov    %eax,(%esp)
  8008b6:	e8 69 ff ff ff       	call   800824 <strlen>
  8008bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  8008be:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	01 c2                	add    %eax,%edx
  8008c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008cd:	89 14 24             	mov    %edx,(%esp)
  8008d0:	e8 a5 ff ff ff       	call   80087a <strcpy>
	return dst;
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8008d8:	c9                   	leave  
  8008d9:	c3                   	ret    

008008da <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8008e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e3:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8008e6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008ed:	eb 23                	jmp    800912 <strncpy+0x38>
		*dst++ = *src;
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	8d 50 01             	lea    0x1(%eax),%edx
  8008f5:	89 55 08             	mov    %edx,0x8(%ebp)
  8008f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fb:	0f b6 12             	movzbl (%edx),%edx
  8008fe:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800900:	8b 45 0c             	mov    0xc(%ebp),%eax
  800903:	0f b6 00             	movzbl (%eax),%eax
  800906:	84 c0                	test   %al,%al
  800908:	74 04                	je     80090e <strncpy+0x34>
			src++;
  80090a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80090e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800912:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800915:	3b 45 10             	cmp    0x10(%ebp),%eax
  800918:	72 d5                	jb     8008ef <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  80091a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  80092b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80092f:	74 33                	je     800964 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800931:	eb 17                	jmp    80094a <strlcpy+0x2b>
			*dst++ = *src++;
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	8d 50 01             	lea    0x1(%eax),%edx
  800939:	89 55 08             	mov    %edx,0x8(%ebp)
  80093c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800942:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800945:	0f b6 12             	movzbl (%edx),%edx
  800948:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80094a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80094e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800952:	74 0a                	je     80095e <strlcpy+0x3f>
  800954:	8b 45 0c             	mov    0xc(%ebp),%eax
  800957:	0f b6 00             	movzbl (%eax),%eax
  80095a:	84 c0                	test   %al,%al
  80095c:	75 d5                	jne    800933 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800964:	8b 55 08             	mov    0x8(%ebp),%edx
  800967:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80096a:	29 c2                	sub    %eax,%edx
  80096c:	89 d0                	mov    %edx,%eax
}
  80096e:	c9                   	leave  
  80096f:	c3                   	ret    

00800970 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800973:	eb 08                	jmp    80097d <strcmp+0xd>
		p++, q++;
  800975:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800979:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	0f b6 00             	movzbl (%eax),%eax
  800983:	84 c0                	test   %al,%al
  800985:	74 10                	je     800997 <strcmp+0x27>
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	0f b6 10             	movzbl (%eax),%edx
  80098d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800990:	0f b6 00             	movzbl (%eax),%eax
  800993:	38 c2                	cmp    %al,%dl
  800995:	74 de                	je     800975 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	0f b6 00             	movzbl (%eax),%eax
  80099d:	0f b6 d0             	movzbl %al,%edx
  8009a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a3:	0f b6 00             	movzbl (%eax),%eax
  8009a6:	0f b6 c0             	movzbl %al,%eax
  8009a9:	29 c2                	sub    %eax,%edx
  8009ab:	89 d0                	mov    %edx,%eax
}
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  8009b2:	eb 0c                	jmp    8009c0 <strncmp+0x11>
		n--, p++, q++;
  8009b4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8009b8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009bc:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009c0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009c4:	74 1a                	je     8009e0 <strncmp+0x31>
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	0f b6 00             	movzbl (%eax),%eax
  8009cc:	84 c0                	test   %al,%al
  8009ce:	74 10                	je     8009e0 <strncmp+0x31>
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	0f b6 10             	movzbl (%eax),%edx
  8009d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d9:	0f b6 00             	movzbl (%eax),%eax
  8009dc:	38 c2                	cmp    %al,%dl
  8009de:	74 d4                	je     8009b4 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  8009e0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009e4:	75 07                	jne    8009ed <strncmp+0x3e>
		return 0;
  8009e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009eb:	eb 16                	jmp    800a03 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	0f b6 00             	movzbl (%eax),%eax
  8009f3:	0f b6 d0             	movzbl %al,%edx
  8009f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f9:	0f b6 00             	movzbl (%eax),%eax
  8009fc:	0f b6 c0             	movzbl %al,%eax
  8009ff:	29 c2                	sub    %eax,%edx
  800a01:	89 d0                	mov    %edx,%eax
}
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	83 ec 04             	sub    $0x4,%esp
  800a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0e:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a11:	eb 14                	jmp    800a27 <strchr+0x22>
		if (*s == c)
  800a13:	8b 45 08             	mov    0x8(%ebp),%eax
  800a16:	0f b6 00             	movzbl (%eax),%eax
  800a19:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a1c:	75 05                	jne    800a23 <strchr+0x1e>
			return (char *) s;
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	eb 13                	jmp    800a36 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a23:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	0f b6 00             	movzbl (%eax),%eax
  800a2d:	84 c0                	test   %al,%al
  800a2f:	75 e2                	jne    800a13 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a31:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a36:	c9                   	leave  
  800a37:	c3                   	ret    

00800a38 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	83 ec 04             	sub    $0x4,%esp
  800a3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a41:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a44:	eb 11                	jmp    800a57 <strfind+0x1f>
		if (*s == c)
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
  800a49:	0f b6 00             	movzbl (%eax),%eax
  800a4c:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a4f:	75 02                	jne    800a53 <strfind+0x1b>
			break;
  800a51:	eb 0e                	jmp    800a61 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a53:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a57:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5a:	0f b6 00             	movzbl (%eax),%eax
  800a5d:	84 c0                	test   %al,%al
  800a5f:	75 e5                	jne    800a46 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800a61:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a64:	c9                   	leave  
  800a65:	c3                   	ret    

00800a66 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	57                   	push   %edi
	char *p;

	if (n == 0)
  800a6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a6e:	75 05                	jne    800a75 <memset+0xf>
		return v;
  800a70:	8b 45 08             	mov    0x8(%ebp),%eax
  800a73:	eb 5c                	jmp    800ad1 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800a75:	8b 45 08             	mov    0x8(%ebp),%eax
  800a78:	83 e0 03             	and    $0x3,%eax
  800a7b:	85 c0                	test   %eax,%eax
  800a7d:	75 41                	jne    800ac0 <memset+0x5a>
  800a7f:	8b 45 10             	mov    0x10(%ebp),%eax
  800a82:	83 e0 03             	and    $0x3,%eax
  800a85:	85 c0                	test   %eax,%eax
  800a87:	75 37                	jne    800ac0 <memset+0x5a>
		c &= 0xFF;
  800a89:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a90:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a93:	c1 e0 18             	shl    $0x18,%eax
  800a96:	89 c2                	mov    %eax,%edx
  800a98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9b:	c1 e0 10             	shl    $0x10,%eax
  800a9e:	09 c2                	or     %eax,%edx
  800aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa3:	c1 e0 08             	shl    $0x8,%eax
  800aa6:	09 d0                	or     %edx,%eax
  800aa8:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aab:	8b 45 10             	mov    0x10(%ebp),%eax
  800aae:	c1 e8 02             	shr    $0x2,%eax
  800ab1:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ab3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab9:	89 d7                	mov    %edx,%edi
  800abb:	fc                   	cld    
  800abc:	f3 ab                	rep stos %eax,%es:(%edi)
  800abe:	eb 0e                	jmp    800ace <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ac9:	89 d7                	mov    %edx,%edi
  800acb:	fc                   	cld    
  800acc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ace:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ad1:	5f                   	pop    %edi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	57                   	push   %edi
  800ad8:	56                   	push   %esi
  800ad9:	53                   	push   %ebx
  800ada:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800add:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae0:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800ae3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae6:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800ae9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800aec:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800aef:	73 6d                	jae    800b5e <memmove+0x8a>
  800af1:	8b 45 10             	mov    0x10(%ebp),%eax
  800af4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800af7:	01 d0                	add    %edx,%eax
  800af9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800afc:	76 60                	jbe    800b5e <memmove+0x8a>
		s += n;
  800afe:	8b 45 10             	mov    0x10(%ebp),%eax
  800b01:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800b04:	8b 45 10             	mov    0x10(%ebp),%eax
  800b07:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b0d:	83 e0 03             	and    $0x3,%eax
  800b10:	85 c0                	test   %eax,%eax
  800b12:	75 2f                	jne    800b43 <memmove+0x6f>
  800b14:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b17:	83 e0 03             	and    $0x3,%eax
  800b1a:	85 c0                	test   %eax,%eax
  800b1c:	75 25                	jne    800b43 <memmove+0x6f>
  800b1e:	8b 45 10             	mov    0x10(%ebp),%eax
  800b21:	83 e0 03             	and    $0x3,%eax
  800b24:	85 c0                	test   %eax,%eax
  800b26:	75 1b                	jne    800b43 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b28:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b2b:	83 e8 04             	sub    $0x4,%eax
  800b2e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b31:	83 ea 04             	sub    $0x4,%edx
  800b34:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b37:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b3a:	89 c7                	mov    %eax,%edi
  800b3c:	89 d6                	mov    %edx,%esi
  800b3e:	fd                   	std    
  800b3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b41:	eb 18                	jmp    800b5b <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b43:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b46:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b49:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b4c:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b4f:	8b 45 10             	mov    0x10(%ebp),%eax
  800b52:	89 d7                	mov    %edx,%edi
  800b54:	89 de                	mov    %ebx,%esi
  800b56:	89 c1                	mov    %eax,%ecx
  800b58:	fd                   	std    
  800b59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b5b:	fc                   	cld    
  800b5c:	eb 45                	jmp    800ba3 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b61:	83 e0 03             	and    $0x3,%eax
  800b64:	85 c0                	test   %eax,%eax
  800b66:	75 2b                	jne    800b93 <memmove+0xbf>
  800b68:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b6b:	83 e0 03             	and    $0x3,%eax
  800b6e:	85 c0                	test   %eax,%eax
  800b70:	75 21                	jne    800b93 <memmove+0xbf>
  800b72:	8b 45 10             	mov    0x10(%ebp),%eax
  800b75:	83 e0 03             	and    $0x3,%eax
  800b78:	85 c0                	test   %eax,%eax
  800b7a:	75 17                	jne    800b93 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b7f:	c1 e8 02             	shr    $0x2,%eax
  800b82:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b84:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b87:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b8a:	89 c7                	mov    %eax,%edi
  800b8c:	89 d6                	mov    %edx,%esi
  800b8e:	fc                   	cld    
  800b8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b91:	eb 10                	jmp    800ba3 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b93:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b96:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b99:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b9c:	89 c7                	mov    %eax,%edi
  800b9e:	89 d6                	mov    %edx,%esi
  800ba0:	fc                   	cld    
  800ba1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800ba3:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ba6:	83 c4 10             	add    $0x10,%esp
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bb4:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc5:	89 04 24             	mov    %eax,(%esp)
  800bc8:	e8 07 ff ff ff       	call   800ad4 <memmove>
}
  800bcd:	c9                   	leave  
  800bce:	c3                   	ret    

00800bcf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd8:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800bdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bde:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800be1:	eb 30                	jmp    800c13 <memcmp+0x44>
		if (*s1 != *s2)
  800be3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800be6:	0f b6 10             	movzbl (%eax),%edx
  800be9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bec:	0f b6 00             	movzbl (%eax),%eax
  800bef:	38 c2                	cmp    %al,%dl
  800bf1:	74 18                	je     800c0b <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800bf3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bf6:	0f b6 00             	movzbl (%eax),%eax
  800bf9:	0f b6 d0             	movzbl %al,%edx
  800bfc:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bff:	0f b6 00             	movzbl (%eax),%eax
  800c02:	0f b6 c0             	movzbl %al,%eax
  800c05:	29 c2                	sub    %eax,%edx
  800c07:	89 d0                	mov    %edx,%eax
  800c09:	eb 1a                	jmp    800c25 <memcmp+0x56>
		s1++, s2++;
  800c0b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800c0f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c13:	8b 45 10             	mov    0x10(%ebp),%eax
  800c16:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c19:	89 55 10             	mov    %edx,0x10(%ebp)
  800c1c:	85 c0                	test   %eax,%eax
  800c1e:	75 c3                	jne    800be3 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c20:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c25:	c9                   	leave  
  800c26:	c3                   	ret    

00800c27 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c2d:	8b 45 10             	mov    0x10(%ebp),%eax
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	01 d0                	add    %edx,%eax
  800c35:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c38:	eb 13                	jmp    800c4d <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3d:	0f b6 10             	movzbl (%eax),%edx
  800c40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c43:	38 c2                	cmp    %al,%dl
  800c45:	75 02                	jne    800c49 <memfind+0x22>
			break;
  800c47:	eb 0c                	jmp    800c55 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c49:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c50:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c53:	72 e5                	jb     800c3a <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800c55:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c58:	c9                   	leave  
  800c59:	c3                   	ret    

00800c5a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800c60:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800c67:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c6e:	eb 04                	jmp    800c74 <strtol+0x1a>
		s++;
  800c70:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c74:	8b 45 08             	mov    0x8(%ebp),%eax
  800c77:	0f b6 00             	movzbl (%eax),%eax
  800c7a:	3c 20                	cmp    $0x20,%al
  800c7c:	74 f2                	je     800c70 <strtol+0x16>
  800c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c81:	0f b6 00             	movzbl (%eax),%eax
  800c84:	3c 09                	cmp    $0x9,%al
  800c86:	74 e8                	je     800c70 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c88:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8b:	0f b6 00             	movzbl (%eax),%eax
  800c8e:	3c 2b                	cmp    $0x2b,%al
  800c90:	75 06                	jne    800c98 <strtol+0x3e>
		s++;
  800c92:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c96:	eb 15                	jmp    800cad <strtol+0x53>
	else if (*s == '-')
  800c98:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9b:	0f b6 00             	movzbl (%eax),%eax
  800c9e:	3c 2d                	cmp    $0x2d,%al
  800ca0:	75 0b                	jne    800cad <strtol+0x53>
		s++, neg = 1;
  800ca2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ca6:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cb1:	74 06                	je     800cb9 <strtol+0x5f>
  800cb3:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800cb7:	75 24                	jne    800cdd <strtol+0x83>
  800cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbc:	0f b6 00             	movzbl (%eax),%eax
  800cbf:	3c 30                	cmp    $0x30,%al
  800cc1:	75 1a                	jne    800cdd <strtol+0x83>
  800cc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc6:	83 c0 01             	add    $0x1,%eax
  800cc9:	0f b6 00             	movzbl (%eax),%eax
  800ccc:	3c 78                	cmp    $0x78,%al
  800cce:	75 0d                	jne    800cdd <strtol+0x83>
		s += 2, base = 16;
  800cd0:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800cd4:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800cdb:	eb 2a                	jmp    800d07 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800cdd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ce1:	75 17                	jne    800cfa <strtol+0xa0>
  800ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce6:	0f b6 00             	movzbl (%eax),%eax
  800ce9:	3c 30                	cmp    $0x30,%al
  800ceb:	75 0d                	jne    800cfa <strtol+0xa0>
		s++, base = 8;
  800ced:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cf1:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800cf8:	eb 0d                	jmp    800d07 <strtol+0xad>
	else if (base == 0)
  800cfa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cfe:	75 07                	jne    800d07 <strtol+0xad>
		base = 10;
  800d00:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d07:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0a:	0f b6 00             	movzbl (%eax),%eax
  800d0d:	3c 2f                	cmp    $0x2f,%al
  800d0f:	7e 1b                	jle    800d2c <strtol+0xd2>
  800d11:	8b 45 08             	mov    0x8(%ebp),%eax
  800d14:	0f b6 00             	movzbl (%eax),%eax
  800d17:	3c 39                	cmp    $0x39,%al
  800d19:	7f 11                	jg     800d2c <strtol+0xd2>
			dig = *s - '0';
  800d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1e:	0f b6 00             	movzbl (%eax),%eax
  800d21:	0f be c0             	movsbl %al,%eax
  800d24:	83 e8 30             	sub    $0x30,%eax
  800d27:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d2a:	eb 48                	jmp    800d74 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800d2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2f:	0f b6 00             	movzbl (%eax),%eax
  800d32:	3c 60                	cmp    $0x60,%al
  800d34:	7e 1b                	jle    800d51 <strtol+0xf7>
  800d36:	8b 45 08             	mov    0x8(%ebp),%eax
  800d39:	0f b6 00             	movzbl (%eax),%eax
  800d3c:	3c 7a                	cmp    $0x7a,%al
  800d3e:	7f 11                	jg     800d51 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800d40:	8b 45 08             	mov    0x8(%ebp),%eax
  800d43:	0f b6 00             	movzbl (%eax),%eax
  800d46:	0f be c0             	movsbl %al,%eax
  800d49:	83 e8 57             	sub    $0x57,%eax
  800d4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d4f:	eb 23                	jmp    800d74 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800d51:	8b 45 08             	mov    0x8(%ebp),%eax
  800d54:	0f b6 00             	movzbl (%eax),%eax
  800d57:	3c 40                	cmp    $0x40,%al
  800d59:	7e 3d                	jle    800d98 <strtol+0x13e>
  800d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5e:	0f b6 00             	movzbl (%eax),%eax
  800d61:	3c 5a                	cmp    $0x5a,%al
  800d63:	7f 33                	jg     800d98 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800d65:	8b 45 08             	mov    0x8(%ebp),%eax
  800d68:	0f b6 00             	movzbl (%eax),%eax
  800d6b:	0f be c0             	movsbl %al,%eax
  800d6e:	83 e8 37             	sub    $0x37,%eax
  800d71:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d77:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d7a:	7c 02                	jl     800d7e <strtol+0x124>
			break;
  800d7c:	eb 1a                	jmp    800d98 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800d7e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d82:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d85:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d89:	89 c2                	mov    %eax,%edx
  800d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d8e:	01 d0                	add    %edx,%eax
  800d90:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800d93:	e9 6f ff ff ff       	jmp    800d07 <strtol+0xad>

	if (endptr)
  800d98:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d9c:	74 08                	je     800da6 <strtol+0x14c>
		*endptr = (char *) s;
  800d9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da1:	8b 55 08             	mov    0x8(%ebp),%edx
  800da4:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800da6:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800daa:	74 07                	je     800db3 <strtol+0x159>
  800dac:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800daf:	f7 d8                	neg    %eax
  800db1:	eb 03                	jmp    800db6 <strtol+0x15c>
  800db3:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800db6:	c9                   	leave  
  800db7:	c3                   	ret    

00800db8 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	57                   	push   %edi
  800dbc:	56                   	push   %esi
  800dbd:	53                   	push   %ebx
  800dbe:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc4:	8b 55 10             	mov    0x10(%ebp),%edx
  800dc7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800dca:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800dcd:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800dd0:	8b 75 20             	mov    0x20(%ebp),%esi
  800dd3:	cd 30                	int    $0x30
  800dd5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ddc:	74 30                	je     800e0e <syscall+0x56>
  800dde:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800de2:	7e 2a                	jle    800e0e <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800de7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800deb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800df2:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  800df9:	00 
  800dfa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e01:	00 
  800e02:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  800e09:	e8 2c 03 00 00       	call   80113a <_panic>

	return ret;
  800e0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800e11:	83 c4 3c             	add    $0x3c,%esp
  800e14:	5b                   	pop    %ebx
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e22:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e29:	00 
  800e2a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e31:	00 
  800e32:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e39:	00 
  800e3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e3d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e41:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e45:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e4c:	00 
  800e4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e54:	e8 5f ff ff ff       	call   800db8 <syscall>
}
  800e59:	c9                   	leave  
  800e5a:	c3                   	ret    

00800e5b <sys_cgetc>:

int
sys_cgetc(void)
{
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800e61:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e68:	00 
  800e69:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e70:	00 
  800e71:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e78:	00 
  800e79:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e80:	00 
  800e81:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e88:	00 
  800e89:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e90:	00 
  800e91:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800e98:	e8 1b ff ff ff       	call   800db8 <syscall>
}
  800e9d:	c9                   	leave  
  800e9e:	c3                   	ret    

00800e9f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800ea5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea8:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800eaf:	00 
  800eb0:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800eb7:	00 
  800eb8:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ebf:	00 
  800ec0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ec7:	00 
  800ec8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ecc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800ed3:	00 
  800ed4:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800edb:	e8 d8 fe ff ff       	call   800db8 <syscall>
}
  800ee0:	c9                   	leave  
  800ee1:	c3                   	ret    

00800ee2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800ee8:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800eef:	00 
  800ef0:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ef7:	00 
  800ef8:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800eff:	00 
  800f00:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f07:	00 
  800f08:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f0f:	00 
  800f10:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f17:	00 
  800f18:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f1f:	e8 94 fe ff ff       	call   800db8 <syscall>
}
  800f24:	c9                   	leave  
  800f25:	c3                   	ret    

00800f26 <sys_yield>:

void
sys_yield(void)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f2c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f33:	00 
  800f34:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f3b:	00 
  800f3c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f43:	00 
  800f44:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f4b:	00 
  800f4c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f53:	00 
  800f54:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f5b:	00 
  800f5c:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800f63:	e8 50 fe ff ff       	call   800db8 <syscall>
}
  800f68:	c9                   	leave  
  800f69:	c3                   	ret    

00800f6a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f70:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f73:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f76:	8b 45 08             	mov    0x8(%ebp),%eax
  800f79:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f80:	00 
  800f81:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f88:	00 
  800f89:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f8d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f91:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f95:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f9c:	00 
  800f9d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800fa4:	e8 0f fe ff ff       	call   800db8 <syscall>
}
  800fa9:	c9                   	leave  
  800faa:	c3                   	ret    

00800fab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	56                   	push   %esi
  800faf:	53                   	push   %ebx
  800fb0:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800fb3:	8b 75 18             	mov    0x18(%ebp),%esi
  800fb6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800fb9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fbc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc2:	89 74 24 18          	mov    %esi,0x18(%esp)
  800fc6:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800fca:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fd2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fd6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fdd:	00 
  800fde:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  800fe5:	e8 ce fd ff ff       	call   800db8 <syscall>
}
  800fea:	83 c4 20             	add    $0x20,%esp
  800fed:	5b                   	pop    %ebx
  800fee:	5e                   	pop    %esi
  800fef:	5d                   	pop    %ebp
  800ff0:	c3                   	ret    

00800ff1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800ff7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ffa:	8b 45 08             	mov    0x8(%ebp),%eax
  800ffd:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801004:	00 
  801005:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80100c:	00 
  80100d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801014:	00 
  801015:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801019:	89 44 24 08          	mov    %eax,0x8(%esp)
  80101d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801024:	00 
  801025:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  80102c:	e8 87 fd ff ff       	call   800db8 <syscall>
}
  801031:	c9                   	leave  
  801032:	c3                   	ret    

00801033 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801039:	8b 55 0c             	mov    0xc(%ebp),%edx
  80103c:	8b 45 08             	mov    0x8(%ebp),%eax
  80103f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801046:	00 
  801047:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80104e:	00 
  80104f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801056:	00 
  801057:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80105b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80105f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801066:	00 
  801067:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  80106e:	e8 45 fd ff ff       	call   800db8 <syscall>
}
  801073:	c9                   	leave  
  801074:	c3                   	ret    

00801075 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80107b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80107e:	8b 45 08             	mov    0x8(%ebp),%eax
  801081:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801088:	00 
  801089:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801090:	00 
  801091:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801098:	00 
  801099:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80109d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010a8:	00 
  8010a9:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8010b0:	e8 03 fd ff ff       	call   800db8 <syscall>
}
  8010b5:	c9                   	leave  
  8010b6:	c3                   	ret    

008010b7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8010bd:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8010c0:	8b 55 10             	mov    0x10(%ebp),%edx
  8010c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010cd:	00 
  8010ce:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8010d2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010e1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010e8:	00 
  8010e9:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8010f0:	e8 c3 fc ff ff       	call   800db8 <syscall>
}
  8010f5:	c9                   	leave  
  8010f6:	c3                   	ret    

008010f7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8010fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801100:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801107:	00 
  801108:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80110f:	00 
  801110:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801117:	00 
  801118:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80111f:	00 
  801120:	89 44 24 08          	mov    %eax,0x8(%esp)
  801124:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80112b:	00 
  80112c:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801133:	e8 80 fc ff ff       	call   800db8 <syscall>
}
  801138:	c9                   	leave  
  801139:	c3                   	ret    

0080113a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	53                   	push   %ebx
  80113e:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  801141:	8d 45 14             	lea    0x14(%ebp),%eax
  801144:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801147:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80114d:	e8 90 fd ff ff       	call   800ee2 <sys_getenvid>
  801152:	8b 55 0c             	mov    0xc(%ebp),%edx
  801155:	89 54 24 10          	mov    %edx,0x10(%esp)
  801159:	8b 55 08             	mov    0x8(%ebp),%edx
  80115c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801160:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801164:	89 44 24 04          	mov    %eax,0x4(%esp)
  801168:	c7 04 24 f0 16 80 00 	movl   $0x8016f0,(%esp)
  80116f:	e8 00 f0 ff ff       	call   800174 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801174:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801177:	89 44 24 04          	mov    %eax,0x4(%esp)
  80117b:	8b 45 10             	mov    0x10(%ebp),%eax
  80117e:	89 04 24             	mov    %eax,(%esp)
  801181:	e8 8a ef ff ff       	call   800110 <vcprintf>
	cprintf("\n");
  801186:	c7 04 24 13 17 80 00 	movl   $0x801713,(%esp)
  80118d:	e8 e2 ef ff ff       	call   800174 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801192:	cc                   	int3   
  801193:	eb fd                	jmp    801192 <_panic+0x58>
  801195:	66 90                	xchg   %ax,%ax
  801197:	66 90                	xchg   %ax,%ax
  801199:	66 90                	xchg   %ax,%ax
  80119b:	66 90                	xchg   %ax,%ax
  80119d:	66 90                	xchg   %ax,%ax
  80119f:	90                   	nop

008011a0 <__udivdi3>:
  8011a0:	55                   	push   %ebp
  8011a1:	57                   	push   %edi
  8011a2:	56                   	push   %esi
  8011a3:	83 ec 0c             	sub    $0xc,%esp
  8011a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8011aa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8011ae:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8011b2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011bc:	89 ea                	mov    %ebp,%edx
  8011be:	89 0c 24             	mov    %ecx,(%esp)
  8011c1:	75 2d                	jne    8011f0 <__udivdi3+0x50>
  8011c3:	39 e9                	cmp    %ebp,%ecx
  8011c5:	77 61                	ja     801228 <__udivdi3+0x88>
  8011c7:	85 c9                	test   %ecx,%ecx
  8011c9:	89 ce                	mov    %ecx,%esi
  8011cb:	75 0b                	jne    8011d8 <__udivdi3+0x38>
  8011cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d2:	31 d2                	xor    %edx,%edx
  8011d4:	f7 f1                	div    %ecx
  8011d6:	89 c6                	mov    %eax,%esi
  8011d8:	31 d2                	xor    %edx,%edx
  8011da:	89 e8                	mov    %ebp,%eax
  8011dc:	f7 f6                	div    %esi
  8011de:	89 c5                	mov    %eax,%ebp
  8011e0:	89 f8                	mov    %edi,%eax
  8011e2:	f7 f6                	div    %esi
  8011e4:	89 ea                	mov    %ebp,%edx
  8011e6:	83 c4 0c             	add    $0xc,%esp
  8011e9:	5e                   	pop    %esi
  8011ea:	5f                   	pop    %edi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    
  8011ed:	8d 76 00             	lea    0x0(%esi),%esi
  8011f0:	39 e8                	cmp    %ebp,%eax
  8011f2:	77 24                	ja     801218 <__udivdi3+0x78>
  8011f4:	0f bd e8             	bsr    %eax,%ebp
  8011f7:	83 f5 1f             	xor    $0x1f,%ebp
  8011fa:	75 3c                	jne    801238 <__udivdi3+0x98>
  8011fc:	8b 74 24 04          	mov    0x4(%esp),%esi
  801200:	39 34 24             	cmp    %esi,(%esp)
  801203:	0f 86 9f 00 00 00    	jbe    8012a8 <__udivdi3+0x108>
  801209:	39 d0                	cmp    %edx,%eax
  80120b:	0f 82 97 00 00 00    	jb     8012a8 <__udivdi3+0x108>
  801211:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801218:	31 d2                	xor    %edx,%edx
  80121a:	31 c0                	xor    %eax,%eax
  80121c:	83 c4 0c             	add    $0xc,%esp
  80121f:	5e                   	pop    %esi
  801220:	5f                   	pop    %edi
  801221:	5d                   	pop    %ebp
  801222:	c3                   	ret    
  801223:	90                   	nop
  801224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801228:	89 f8                	mov    %edi,%eax
  80122a:	f7 f1                	div    %ecx
  80122c:	31 d2                	xor    %edx,%edx
  80122e:	83 c4 0c             	add    $0xc,%esp
  801231:	5e                   	pop    %esi
  801232:	5f                   	pop    %edi
  801233:	5d                   	pop    %ebp
  801234:	c3                   	ret    
  801235:	8d 76 00             	lea    0x0(%esi),%esi
  801238:	89 e9                	mov    %ebp,%ecx
  80123a:	8b 3c 24             	mov    (%esp),%edi
  80123d:	d3 e0                	shl    %cl,%eax
  80123f:	89 c6                	mov    %eax,%esi
  801241:	b8 20 00 00 00       	mov    $0x20,%eax
  801246:	29 e8                	sub    %ebp,%eax
  801248:	89 c1                	mov    %eax,%ecx
  80124a:	d3 ef                	shr    %cl,%edi
  80124c:	89 e9                	mov    %ebp,%ecx
  80124e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801252:	8b 3c 24             	mov    (%esp),%edi
  801255:	09 74 24 08          	or     %esi,0x8(%esp)
  801259:	89 d6                	mov    %edx,%esi
  80125b:	d3 e7                	shl    %cl,%edi
  80125d:	89 c1                	mov    %eax,%ecx
  80125f:	89 3c 24             	mov    %edi,(%esp)
  801262:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801266:	d3 ee                	shr    %cl,%esi
  801268:	89 e9                	mov    %ebp,%ecx
  80126a:	d3 e2                	shl    %cl,%edx
  80126c:	89 c1                	mov    %eax,%ecx
  80126e:	d3 ef                	shr    %cl,%edi
  801270:	09 d7                	or     %edx,%edi
  801272:	89 f2                	mov    %esi,%edx
  801274:	89 f8                	mov    %edi,%eax
  801276:	f7 74 24 08          	divl   0x8(%esp)
  80127a:	89 d6                	mov    %edx,%esi
  80127c:	89 c7                	mov    %eax,%edi
  80127e:	f7 24 24             	mull   (%esp)
  801281:	39 d6                	cmp    %edx,%esi
  801283:	89 14 24             	mov    %edx,(%esp)
  801286:	72 30                	jb     8012b8 <__udivdi3+0x118>
  801288:	8b 54 24 04          	mov    0x4(%esp),%edx
  80128c:	89 e9                	mov    %ebp,%ecx
  80128e:	d3 e2                	shl    %cl,%edx
  801290:	39 c2                	cmp    %eax,%edx
  801292:	73 05                	jae    801299 <__udivdi3+0xf9>
  801294:	3b 34 24             	cmp    (%esp),%esi
  801297:	74 1f                	je     8012b8 <__udivdi3+0x118>
  801299:	89 f8                	mov    %edi,%eax
  80129b:	31 d2                	xor    %edx,%edx
  80129d:	e9 7a ff ff ff       	jmp    80121c <__udivdi3+0x7c>
  8012a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012a8:	31 d2                	xor    %edx,%edx
  8012aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8012af:	e9 68 ff ff ff       	jmp    80121c <__udivdi3+0x7c>
  8012b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012b8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8012bb:	31 d2                	xor    %edx,%edx
  8012bd:	83 c4 0c             	add    $0xc,%esp
  8012c0:	5e                   	pop    %esi
  8012c1:	5f                   	pop    %edi
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    
  8012c4:	66 90                	xchg   %ax,%ax
  8012c6:	66 90                	xchg   %ax,%ax
  8012c8:	66 90                	xchg   %ax,%ax
  8012ca:	66 90                	xchg   %ax,%ax
  8012cc:	66 90                	xchg   %ax,%ax
  8012ce:	66 90                	xchg   %ax,%ax

008012d0 <__umoddi3>:
  8012d0:	55                   	push   %ebp
  8012d1:	57                   	push   %edi
  8012d2:	56                   	push   %esi
  8012d3:	83 ec 14             	sub    $0x14,%esp
  8012d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012da:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8012de:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8012e2:	89 c7                	mov    %eax,%edi
  8012e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8012ec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8012f0:	89 34 24             	mov    %esi,(%esp)
  8012f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	89 c2                	mov    %eax,%edx
  8012fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012ff:	75 17                	jne    801318 <__umoddi3+0x48>
  801301:	39 fe                	cmp    %edi,%esi
  801303:	76 4b                	jbe    801350 <__umoddi3+0x80>
  801305:	89 c8                	mov    %ecx,%eax
  801307:	89 fa                	mov    %edi,%edx
  801309:	f7 f6                	div    %esi
  80130b:	89 d0                	mov    %edx,%eax
  80130d:	31 d2                	xor    %edx,%edx
  80130f:	83 c4 14             	add    $0x14,%esp
  801312:	5e                   	pop    %esi
  801313:	5f                   	pop    %edi
  801314:	5d                   	pop    %ebp
  801315:	c3                   	ret    
  801316:	66 90                	xchg   %ax,%ax
  801318:	39 f8                	cmp    %edi,%eax
  80131a:	77 54                	ja     801370 <__umoddi3+0xa0>
  80131c:	0f bd e8             	bsr    %eax,%ebp
  80131f:	83 f5 1f             	xor    $0x1f,%ebp
  801322:	75 5c                	jne    801380 <__umoddi3+0xb0>
  801324:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801328:	39 3c 24             	cmp    %edi,(%esp)
  80132b:	0f 87 e7 00 00 00    	ja     801418 <__umoddi3+0x148>
  801331:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801335:	29 f1                	sub    %esi,%ecx
  801337:	19 c7                	sbb    %eax,%edi
  801339:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80133d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801341:	8b 44 24 08          	mov    0x8(%esp),%eax
  801345:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801349:	83 c4 14             	add    $0x14,%esp
  80134c:	5e                   	pop    %esi
  80134d:	5f                   	pop    %edi
  80134e:	5d                   	pop    %ebp
  80134f:	c3                   	ret    
  801350:	85 f6                	test   %esi,%esi
  801352:	89 f5                	mov    %esi,%ebp
  801354:	75 0b                	jne    801361 <__umoddi3+0x91>
  801356:	b8 01 00 00 00       	mov    $0x1,%eax
  80135b:	31 d2                	xor    %edx,%edx
  80135d:	f7 f6                	div    %esi
  80135f:	89 c5                	mov    %eax,%ebp
  801361:	8b 44 24 04          	mov    0x4(%esp),%eax
  801365:	31 d2                	xor    %edx,%edx
  801367:	f7 f5                	div    %ebp
  801369:	89 c8                	mov    %ecx,%eax
  80136b:	f7 f5                	div    %ebp
  80136d:	eb 9c                	jmp    80130b <__umoddi3+0x3b>
  80136f:	90                   	nop
  801370:	89 c8                	mov    %ecx,%eax
  801372:	89 fa                	mov    %edi,%edx
  801374:	83 c4 14             	add    $0x14,%esp
  801377:	5e                   	pop    %esi
  801378:	5f                   	pop    %edi
  801379:	5d                   	pop    %ebp
  80137a:	c3                   	ret    
  80137b:	90                   	nop
  80137c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801380:	8b 04 24             	mov    (%esp),%eax
  801383:	be 20 00 00 00       	mov    $0x20,%esi
  801388:	89 e9                	mov    %ebp,%ecx
  80138a:	29 ee                	sub    %ebp,%esi
  80138c:	d3 e2                	shl    %cl,%edx
  80138e:	89 f1                	mov    %esi,%ecx
  801390:	d3 e8                	shr    %cl,%eax
  801392:	89 e9                	mov    %ebp,%ecx
  801394:	89 44 24 04          	mov    %eax,0x4(%esp)
  801398:	8b 04 24             	mov    (%esp),%eax
  80139b:	09 54 24 04          	or     %edx,0x4(%esp)
  80139f:	89 fa                	mov    %edi,%edx
  8013a1:	d3 e0                	shl    %cl,%eax
  8013a3:	89 f1                	mov    %esi,%ecx
  8013a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013a9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8013ad:	d3 ea                	shr    %cl,%edx
  8013af:	89 e9                	mov    %ebp,%ecx
  8013b1:	d3 e7                	shl    %cl,%edi
  8013b3:	89 f1                	mov    %esi,%ecx
  8013b5:	d3 e8                	shr    %cl,%eax
  8013b7:	89 e9                	mov    %ebp,%ecx
  8013b9:	09 f8                	or     %edi,%eax
  8013bb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8013bf:	f7 74 24 04          	divl   0x4(%esp)
  8013c3:	d3 e7                	shl    %cl,%edi
  8013c5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013c9:	89 d7                	mov    %edx,%edi
  8013cb:	f7 64 24 08          	mull   0x8(%esp)
  8013cf:	39 d7                	cmp    %edx,%edi
  8013d1:	89 c1                	mov    %eax,%ecx
  8013d3:	89 14 24             	mov    %edx,(%esp)
  8013d6:	72 2c                	jb     801404 <__umoddi3+0x134>
  8013d8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8013dc:	72 22                	jb     801400 <__umoddi3+0x130>
  8013de:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8013e2:	29 c8                	sub    %ecx,%eax
  8013e4:	19 d7                	sbb    %edx,%edi
  8013e6:	89 e9                	mov    %ebp,%ecx
  8013e8:	89 fa                	mov    %edi,%edx
  8013ea:	d3 e8                	shr    %cl,%eax
  8013ec:	89 f1                	mov    %esi,%ecx
  8013ee:	d3 e2                	shl    %cl,%edx
  8013f0:	89 e9                	mov    %ebp,%ecx
  8013f2:	d3 ef                	shr    %cl,%edi
  8013f4:	09 d0                	or     %edx,%eax
  8013f6:	89 fa                	mov    %edi,%edx
  8013f8:	83 c4 14             	add    $0x14,%esp
  8013fb:	5e                   	pop    %esi
  8013fc:	5f                   	pop    %edi
  8013fd:	5d                   	pop    %ebp
  8013fe:	c3                   	ret    
  8013ff:	90                   	nop
  801400:	39 d7                	cmp    %edx,%edi
  801402:	75 da                	jne    8013de <__umoddi3+0x10e>
  801404:	8b 14 24             	mov    (%esp),%edx
  801407:	89 c1                	mov    %eax,%ecx
  801409:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80140d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801411:	eb cb                	jmp    8013de <__umoddi3+0x10e>
  801413:	90                   	nop
  801414:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801418:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80141c:	0f 82 0f ff ff ff    	jb     801331 <__umoddi3+0x61>
  801422:	e9 1a ff ff ff       	jmp    801341 <__umoddi3+0x71>
