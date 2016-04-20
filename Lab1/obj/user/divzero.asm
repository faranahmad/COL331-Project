
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 32 00 00 00       	call   800063 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  800039:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	8b 0d 04 20 80 00    	mov    0x802004,%ecx
  800049:	b8 01 00 00 00       	mov    $0x1,%eax
  80004e:	99                   	cltd   
  80004f:	f7 f9                	idiv   %ecx
  800051:	89 44 24 04          	mov    %eax,0x4(%esp)
  800055:	c7 04 24 40 14 80 00 	movl   $0x801440,(%esp)
  80005c:	e8 24 01 00 00       	call   800185 <cprintf>
}
  800061:	c9                   	leave  
  800062:	c3                   	ret    

00800063 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800063:	55                   	push   %ebp
  800064:	89 e5                	mov    %esp,%ebp
  800066:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800069:	e8 85 0e 00 00       	call   800ef3 <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	c1 e0 02             	shl    $0x2,%eax
  800076:	89 c2                	mov    %eax,%edx
  800078:	c1 e2 05             	shl    $0x5,%edx
  80007b:	29 c2                	sub    %eax,%edx
  80007d:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  800083:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800088:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80008c:	7e 0a                	jle    800098 <libmain+0x35>
		binaryname = argv[0];
  80008e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800091:	8b 00                	mov    (%eax),%eax
  800093:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800098:	8b 45 0c             	mov    0xc(%ebp),%eax
  80009b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009f:	8b 45 08             	mov    0x8(%ebp),%eax
  8000a2:	89 04 24             	mov    %eax,(%esp)
  8000a5:	e8 89 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000aa:	e8 02 00 00 00       	call   8000b1 <exit>
}
  8000af:	c9                   	leave  
  8000b0:	c3                   	ret    

008000b1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b1:	55                   	push   %ebp
  8000b2:	89 e5                	mov    %esp,%ebp
  8000b4:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000be:	e8 ed 0d 00 00       	call   800eb0 <sys_env_destroy>
}
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8000cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ce:	8b 00                	mov    (%eax),%eax
  8000d0:	8d 48 01             	lea    0x1(%eax),%ecx
  8000d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000d6:	89 0a                	mov    %ecx,(%edx)
  8000d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000db:	89 d1                	mov    %edx,%ecx
  8000dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000e0:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8000e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e7:	8b 00                	mov    (%eax),%eax
  8000e9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ee:	75 20                	jne    800110 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8000f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f3:	8b 00                	mov    (%eax),%eax
  8000f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000f8:	83 c2 08             	add    $0x8,%edx
  8000fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ff:	89 14 24             	mov    %edx,(%esp)
  800102:	e8 23 0d 00 00       	call   800e2a <sys_cputs>
		b->idx = 0;
  800107:	8b 45 0c             	mov    0xc(%ebp),%eax
  80010a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800110:	8b 45 0c             	mov    0xc(%ebp),%eax
  800113:	8b 40 04             	mov    0x4(%eax),%eax
  800116:	8d 50 01             	lea    0x1(%eax),%edx
  800119:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011c:	89 50 04             	mov    %edx,0x4(%eax)
}
  80011f:	c9                   	leave  
  800120:	c3                   	ret    

00800121 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80012a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800131:	00 00 00 
	b.cnt = 0;
  800134:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800141:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800145:	8b 45 08             	mov    0x8(%ebp),%eax
  800148:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800152:	89 44 24 04          	mov    %eax,0x4(%esp)
  800156:	c7 04 24 c5 00 80 00 	movl   $0x8000c5,(%esp)
  80015d:	e8 bd 01 00 00       	call   80031f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800162:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800168:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800172:	83 c0 08             	add    $0x8,%eax
  800175:	89 04 24             	mov    %eax,(%esp)
  800178:	e8 ad 0c 00 00       	call   800e2a <sys_cputs>

	return b.cnt;
  80017d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800183:	c9                   	leave  
  800184:	c3                   	ret    

00800185 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80018b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80018e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800191:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800194:	89 44 24 04          	mov    %eax,0x4(%esp)
  800198:	8b 45 08             	mov    0x8(%ebp),%eax
  80019b:	89 04 24             	mov    %eax,(%esp)
  80019e:	e8 7e ff ff ff       	call   800121 <vcprintf>
  8001a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8001a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8001a9:	c9                   	leave  
  8001aa:	c3                   	ret    

008001ab <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 34             	sub    $0x34,%esp
  8001b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8001b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8001bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001be:	8b 45 18             	mov    0x18(%ebp),%eax
  8001c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c6:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001c9:	77 72                	ja     80023d <printnum+0x92>
  8001cb:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001ce:	72 05                	jb     8001d5 <printnum+0x2a>
  8001d0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8001d3:	77 68                	ja     80023d <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d5:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8001d8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001db:	8b 45 18             	mov    0x18(%ebp),%eax
  8001de:	ba 00 00 00 00       	mov    $0x0,%edx
  8001e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8001f1:	89 04 24             	mov    %eax,(%esp)
  8001f4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f8:	e8 b3 0f 00 00       	call   8011b0 <__udivdi3>
  8001fd:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800200:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800204:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800208:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80020b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80020f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800213:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800217:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021e:	8b 45 08             	mov    0x8(%ebp),%eax
  800221:	89 04 24             	mov    %eax,(%esp)
  800224:	e8 82 ff ff ff       	call   8001ab <printnum>
  800229:	eb 1c                	jmp    800247 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800232:	8b 45 20             	mov    0x20(%ebp),%eax
  800235:	89 04 24             	mov    %eax,(%esp)
  800238:	8b 45 08             	mov    0x8(%ebp),%eax
  80023b:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023d:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800241:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800245:	7f e4                	jg     80022b <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800247:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80024a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800252:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800255:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800259:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80025d:	89 04 24             	mov    %eax,(%esp)
  800260:	89 54 24 04          	mov    %edx,0x4(%esp)
  800264:	e8 77 10 00 00       	call   8012e0 <__umoddi3>
  800269:	05 28 15 80 00       	add    $0x801528,%eax
  80026e:	0f b6 00             	movzbl (%eax),%eax
  800271:	0f be c0             	movsbl %al,%eax
  800274:	8b 55 0c             	mov    0xc(%ebp),%edx
  800277:	89 54 24 04          	mov    %edx,0x4(%esp)
  80027b:	89 04 24             	mov    %eax,(%esp)
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	ff d0                	call   *%eax
}
  800283:	83 c4 34             	add    $0x34,%esp
  800286:	5b                   	pop    %ebx
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    

00800289 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80028c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800290:	7e 14                	jle    8002a6 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800292:	8b 45 08             	mov    0x8(%ebp),%eax
  800295:	8b 00                	mov    (%eax),%eax
  800297:	8d 48 08             	lea    0x8(%eax),%ecx
  80029a:	8b 55 08             	mov    0x8(%ebp),%edx
  80029d:	89 0a                	mov    %ecx,(%edx)
  80029f:	8b 50 04             	mov    0x4(%eax),%edx
  8002a2:	8b 00                	mov    (%eax),%eax
  8002a4:	eb 30                	jmp    8002d6 <getuint+0x4d>
	else if (lflag)
  8002a6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002aa:	74 16                	je     8002c2 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8002ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8002af:	8b 00                	mov    (%eax),%eax
  8002b1:	8d 48 04             	lea    0x4(%eax),%ecx
  8002b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b7:	89 0a                	mov    %ecx,(%edx)
  8002b9:	8b 00                	mov    (%eax),%eax
  8002bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c0:	eb 14                	jmp    8002d6 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8002c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c5:	8b 00                	mov    (%eax),%eax
  8002c7:	8d 48 04             	lea    0x4(%eax),%ecx
  8002ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cd:	89 0a                	mov    %ecx,(%edx)
  8002cf:	8b 00                	mov    (%eax),%eax
  8002d1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002db:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002df:	7e 14                	jle    8002f5 <getint+0x1d>
		return va_arg(*ap, long long);
  8002e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e4:	8b 00                	mov    (%eax),%eax
  8002e6:	8d 48 08             	lea    0x8(%eax),%ecx
  8002e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ec:	89 0a                	mov    %ecx,(%edx)
  8002ee:	8b 50 04             	mov    0x4(%eax),%edx
  8002f1:	8b 00                	mov    (%eax),%eax
  8002f3:	eb 28                	jmp    80031d <getint+0x45>
	else if (lflag)
  8002f5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002f9:	74 12                	je     80030d <getint+0x35>
		return va_arg(*ap, long);
  8002fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fe:	8b 00                	mov    (%eax),%eax
  800300:	8d 48 04             	lea    0x4(%eax),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	89 0a                	mov    %ecx,(%edx)
  800308:	8b 00                	mov    (%eax),%eax
  80030a:	99                   	cltd   
  80030b:	eb 10                	jmp    80031d <getint+0x45>
	else
		return va_arg(*ap, int);
  80030d:	8b 45 08             	mov    0x8(%ebp),%eax
  800310:	8b 00                	mov    (%eax),%eax
  800312:	8d 48 04             	lea    0x4(%eax),%ecx
  800315:	8b 55 08             	mov    0x8(%ebp),%edx
  800318:	89 0a                	mov    %ecx,(%edx)
  80031a:	8b 00                	mov    (%eax),%eax
  80031c:	99                   	cltd   
}
  80031d:	5d                   	pop    %ebp
  80031e:	c3                   	ret    

0080031f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031f:	55                   	push   %ebp
  800320:	89 e5                	mov    %esp,%ebp
  800322:	56                   	push   %esi
  800323:	53                   	push   %ebx
  800324:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800327:	eb 18                	jmp    800341 <vprintfmt+0x22>
			if (ch == '\0')
  800329:	85 db                	test   %ebx,%ebx
  80032b:	75 05                	jne    800332 <vprintfmt+0x13>
				return;
  80032d:	e9 05 04 00 00       	jmp    800737 <vprintfmt+0x418>
			putch(ch, putdat);
  800332:	8b 45 0c             	mov    0xc(%ebp),%eax
  800335:	89 44 24 04          	mov    %eax,0x4(%esp)
  800339:	89 1c 24             	mov    %ebx,(%esp)
  80033c:	8b 45 08             	mov    0x8(%ebp),%eax
  80033f:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800341:	8b 45 10             	mov    0x10(%ebp),%eax
  800344:	8d 50 01             	lea    0x1(%eax),%edx
  800347:	89 55 10             	mov    %edx,0x10(%ebp)
  80034a:	0f b6 00             	movzbl (%eax),%eax
  80034d:	0f b6 d8             	movzbl %al,%ebx
  800350:	83 fb 25             	cmp    $0x25,%ebx
  800353:	75 d4                	jne    800329 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800355:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800359:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800360:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800367:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80036e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 45 10             	mov    0x10(%ebp),%eax
  800378:	8d 50 01             	lea    0x1(%eax),%edx
  80037b:	89 55 10             	mov    %edx,0x10(%ebp)
  80037e:	0f b6 00             	movzbl (%eax),%eax
  800381:	0f b6 d8             	movzbl %al,%ebx
  800384:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800387:	83 f8 55             	cmp    $0x55,%eax
  80038a:	0f 87 76 03 00 00    	ja     800706 <vprintfmt+0x3e7>
  800390:	8b 04 85 4c 15 80 00 	mov    0x80154c(,%eax,4),%eax
  800397:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800399:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80039d:	eb d6                	jmp    800375 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80039f:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8003a3:	eb d0                	jmp    800375 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8003ac:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003af:	89 d0                	mov    %edx,%eax
  8003b1:	c1 e0 02             	shl    $0x2,%eax
  8003b4:	01 d0                	add    %edx,%eax
  8003b6:	01 c0                	add    %eax,%eax
  8003b8:	01 d8                	add    %ebx,%eax
  8003ba:	83 e8 30             	sub    $0x30,%eax
  8003bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8003c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c3:	0f b6 00             	movzbl (%eax),%eax
  8003c6:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8003c9:	83 fb 2f             	cmp    $0x2f,%ebx
  8003cc:	7e 0b                	jle    8003d9 <vprintfmt+0xba>
  8003ce:	83 fb 39             	cmp    $0x39,%ebx
  8003d1:	7f 06                	jg     8003d9 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d3:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d7:	eb d3                	jmp    8003ac <vprintfmt+0x8d>
			goto process_precision;
  8003d9:	eb 33                	jmp    80040e <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8003db:	8b 45 14             	mov    0x14(%ebp),%eax
  8003de:	8d 50 04             	lea    0x4(%eax),%edx
  8003e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e4:	8b 00                	mov    (%eax),%eax
  8003e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8003e9:	eb 23                	jmp    80040e <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8003eb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ef:	79 0c                	jns    8003fd <vprintfmt+0xde>
				width = 0;
  8003f1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8003f8:	e9 78 ff ff ff       	jmp    800375 <vprintfmt+0x56>
  8003fd:	e9 73 ff ff ff       	jmp    800375 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800402:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800409:	e9 67 ff ff ff       	jmp    800375 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80040e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800412:	79 12                	jns    800426 <vprintfmt+0x107>
				width = precision, precision = -1;
  800414:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800417:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80041a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800421:	e9 4f ff ff ff       	jmp    800375 <vprintfmt+0x56>
  800426:	e9 4a ff ff ff       	jmp    800375 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80042b:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80042f:	e9 41 ff ff ff       	jmp    800375 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	8d 50 04             	lea    0x4(%eax),%edx
  80043a:	89 55 14             	mov    %edx,0x14(%ebp)
  80043d:	8b 00                	mov    (%eax),%eax
  80043f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800442:	89 54 24 04          	mov    %edx,0x4(%esp)
  800446:	89 04 24             	mov    %eax,(%esp)
  800449:	8b 45 08             	mov    0x8(%ebp),%eax
  80044c:	ff d0                	call   *%eax
			break;
  80044e:	e9 de 02 00 00       	jmp    800731 <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800453:	8b 45 14             	mov    0x14(%ebp),%eax
  800456:	8d 50 04             	lea    0x4(%eax),%edx
  800459:	89 55 14             	mov    %edx,0x14(%ebp)
  80045c:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80045e:	85 db                	test   %ebx,%ebx
  800460:	79 02                	jns    800464 <vprintfmt+0x145>
				err = -err;
  800462:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800464:	83 fb 09             	cmp    $0x9,%ebx
  800467:	7f 0b                	jg     800474 <vprintfmt+0x155>
  800469:	8b 34 9d 00 15 80 00 	mov    0x801500(,%ebx,4),%esi
  800470:	85 f6                	test   %esi,%esi
  800472:	75 23                	jne    800497 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800474:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800478:	c7 44 24 08 39 15 80 	movl   $0x801539,0x8(%esp)
  80047f:	00 
  800480:	8b 45 0c             	mov    0xc(%ebp),%eax
  800483:	89 44 24 04          	mov    %eax,0x4(%esp)
  800487:	8b 45 08             	mov    0x8(%ebp),%eax
  80048a:	89 04 24             	mov    %eax,(%esp)
  80048d:	e8 ac 02 00 00       	call   80073e <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800492:	e9 9a 02 00 00       	jmp    800731 <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800497:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80049b:	c7 44 24 08 42 15 80 	movl   $0x801542,0x8(%esp)
  8004a2:	00 
  8004a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ad:	89 04 24             	mov    %eax,(%esp)
  8004b0:	e8 89 02 00 00       	call   80073e <printfmt>
			break;
  8004b5:	e9 77 02 00 00       	jmp    800731 <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bd:	8d 50 04             	lea    0x4(%eax),%edx
  8004c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c3:	8b 30                	mov    (%eax),%esi
  8004c5:	85 f6                	test   %esi,%esi
  8004c7:	75 05                	jne    8004ce <vprintfmt+0x1af>
				p = "(null)";
  8004c9:	be 45 15 80 00       	mov    $0x801545,%esi
			if (width > 0 && padc != '-')
  8004ce:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004d2:	7e 37                	jle    80050b <vprintfmt+0x1ec>
  8004d4:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8004d8:	74 31                	je     80050b <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e1:	89 34 24             	mov    %esi,(%esp)
  8004e4:	e8 72 03 00 00       	call   80085b <strnlen>
  8004e9:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8004ec:	eb 17                	jmp    800505 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8004ee:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8004f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004f9:	89 04 24             	mov    %eax,(%esp)
  8004fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ff:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800501:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800505:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800509:	7f e3                	jg     8004ee <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050b:	eb 38                	jmp    800545 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  80050d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800511:	74 1f                	je     800532 <vprintfmt+0x213>
  800513:	83 fb 1f             	cmp    $0x1f,%ebx
  800516:	7e 05                	jle    80051d <vprintfmt+0x1fe>
  800518:	83 fb 7e             	cmp    $0x7e,%ebx
  80051b:	7e 15                	jle    800532 <vprintfmt+0x213>
					putch('?', putdat);
  80051d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800520:	89 44 24 04          	mov    %eax,0x4(%esp)
  800524:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80052b:	8b 45 08             	mov    0x8(%ebp),%eax
  80052e:	ff d0                	call   *%eax
  800530:	eb 0f                	jmp    800541 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800532:	8b 45 0c             	mov    0xc(%ebp),%eax
  800535:	89 44 24 04          	mov    %eax,0x4(%esp)
  800539:	89 1c 24             	mov    %ebx,(%esp)
  80053c:	8b 45 08             	mov    0x8(%ebp),%eax
  80053f:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800541:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800545:	89 f0                	mov    %esi,%eax
  800547:	8d 70 01             	lea    0x1(%eax),%esi
  80054a:	0f b6 00             	movzbl (%eax),%eax
  80054d:	0f be d8             	movsbl %al,%ebx
  800550:	85 db                	test   %ebx,%ebx
  800552:	74 10                	je     800564 <vprintfmt+0x245>
  800554:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800558:	78 b3                	js     80050d <vprintfmt+0x1ee>
  80055a:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80055e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800562:	79 a9                	jns    80050d <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800564:	eb 17                	jmp    80057d <vprintfmt+0x25e>
				putch(' ', putdat);
  800566:	8b 45 0c             	mov    0xc(%ebp),%eax
  800569:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800574:	8b 45 08             	mov    0x8(%ebp),%eax
  800577:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800579:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80057d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800581:	7f e3                	jg     800566 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800583:	e9 a9 01 00 00       	jmp    800731 <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800588:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80058b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058f:	8d 45 14             	lea    0x14(%ebp),%eax
  800592:	89 04 24             	mov    %eax,(%esp)
  800595:	e8 3e fd ff ff       	call   8002d8 <getint>
  80059a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80059d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8005a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005a6:	85 d2                	test   %edx,%edx
  8005a8:	79 26                	jns    8005d0 <vprintfmt+0x2b1>
				putch('-', putdat);
  8005aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005bb:	ff d0                	call   *%eax
				num = -(long long) num;
  8005bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005c3:	f7 d8                	neg    %eax
  8005c5:	83 d2 00             	adc    $0x0,%edx
  8005c8:	f7 da                	neg    %edx
  8005ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005cd:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8005d0:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8005d7:	e9 e1 00 00 00       	jmp    8006bd <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e6:	89 04 24             	mov    %eax,(%esp)
  8005e9:	e8 9b fc ff ff       	call   800289 <getuint>
  8005ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005f1:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8005f4:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8005fb:	e9 bd 00 00 00       	jmp    8006bd <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  800600:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  800607:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80060a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060e:	8d 45 14             	lea    0x14(%ebp),%eax
  800611:	89 04 24             	mov    %eax,(%esp)
  800614:	e8 70 fc ff ff       	call   800289 <getuint>
  800619:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80061c:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  80061f:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800623:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800626:	89 54 24 18          	mov    %edx,0x18(%esp)
  80062a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80062d:	89 54 24 14          	mov    %edx,0x14(%esp)
  800631:	89 44 24 10          	mov    %eax,0x10(%esp)
  800635:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800638:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80063b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80063f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800643:	8b 45 0c             	mov    0xc(%ebp),%eax
  800646:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064a:	8b 45 08             	mov    0x8(%ebp),%eax
  80064d:	89 04 24             	mov    %eax,(%esp)
  800650:	e8 56 fb ff ff       	call   8001ab <printnum>
			break;
  800655:	e9 d7 00 00 00       	jmp    800731 <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  80065a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80065d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800661:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800668:	8b 45 08             	mov    0x8(%ebp),%eax
  80066b:	ff d0                	call   *%eax
			putch('x', putdat);
  80066d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800670:	89 44 24 04          	mov    %eax,0x4(%esp)
  800674:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80067b:	8b 45 08             	mov    0x8(%ebp),%eax
  80067e:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 50 04             	lea    0x4(%eax),%edx
  800686:	89 55 14             	mov    %edx,0x14(%ebp)
  800689:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80068b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80068e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800695:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  80069c:	eb 1f                	jmp    8006bd <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80069e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a8:	89 04 24             	mov    %eax,(%esp)
  8006ab:	e8 d9 fb ff ff       	call   800289 <getuint>
  8006b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006b3:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8006b6:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006bd:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8006c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c4:	89 54 24 18          	mov    %edx,0x18(%esp)
  8006c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006cb:	89 54 24 14          	mov    %edx,0x14(%esp)
  8006cf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006dd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006eb:	89 04 24             	mov    %eax,(%esp)
  8006ee:	e8 b8 fa ff ff       	call   8001ab <printnum>
			break;
  8006f3:	eb 3c                	jmp    800731 <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fc:	89 1c 24             	mov    %ebx,(%esp)
  8006ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800702:	ff d0                	call   *%eax
			break;
  800704:	eb 2b                	jmp    800731 <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800706:	8b 45 0c             	mov    0xc(%ebp),%eax
  800709:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800714:	8b 45 08             	mov    0x8(%ebp),%eax
  800717:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800719:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80071d:	eb 04                	jmp    800723 <vprintfmt+0x404>
  80071f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800723:	8b 45 10             	mov    0x10(%ebp),%eax
  800726:	83 e8 01             	sub    $0x1,%eax
  800729:	0f b6 00             	movzbl (%eax),%eax
  80072c:	3c 25                	cmp    $0x25,%al
  80072e:	75 ef                	jne    80071f <vprintfmt+0x400>
				/* do nothing */;
			break;
  800730:	90                   	nop
		}
	}
  800731:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800732:	e9 0a fc ff ff       	jmp    800341 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800737:	83 c4 40             	add    $0x40,%esp
  80073a:	5b                   	pop    %ebx
  80073b:	5e                   	pop    %esi
  80073c:	5d                   	pop    %ebp
  80073d:	c3                   	ret    

0080073e <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800744:	8d 45 14             	lea    0x14(%ebp),%eax
  800747:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80074a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800751:	8b 45 10             	mov    0x10(%ebp),%eax
  800754:	89 44 24 08          	mov    %eax,0x8(%esp)
  800758:	8b 45 0c             	mov    0xc(%ebp),%eax
  80075b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075f:	8b 45 08             	mov    0x8(%ebp),%eax
  800762:	89 04 24             	mov    %eax,(%esp)
  800765:	e8 b5 fb ff ff       	call   80031f <vprintfmt>
	va_end(ap);
}
  80076a:	c9                   	leave  
  80076b:	c3                   	ret    

0080076c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  80076f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800772:	8b 40 08             	mov    0x8(%eax),%eax
  800775:	8d 50 01             	lea    0x1(%eax),%edx
  800778:	8b 45 0c             	mov    0xc(%ebp),%eax
  80077b:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  80077e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800781:	8b 10                	mov    (%eax),%edx
  800783:	8b 45 0c             	mov    0xc(%ebp),%eax
  800786:	8b 40 04             	mov    0x4(%eax),%eax
  800789:	39 c2                	cmp    %eax,%edx
  80078b:	73 12                	jae    80079f <sprintputch+0x33>
		*b->buf++ = ch;
  80078d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800790:	8b 00                	mov    (%eax),%eax
  800792:	8d 48 01             	lea    0x1(%eax),%ecx
  800795:	8b 55 0c             	mov    0xc(%ebp),%edx
  800798:	89 0a                	mov    %ecx,(%edx)
  80079a:	8b 55 08             	mov    0x8(%ebp),%edx
  80079d:	88 10                	mov    %dl,(%eax)
}
  80079f:	5d                   	pop    %ebp
  8007a0:	c3                   	ret    

008007a1 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b0:	8d 50 ff             	lea    -0x1(%eax),%edx
  8007b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b6:	01 d0                	add    %edx,%eax
  8007b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8007c6:	74 06                	je     8007ce <vsnprintf+0x2d>
  8007c8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007cc:	7f 07                	jg     8007d5 <vsnprintf+0x34>
		return -E_INVAL;
  8007ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d3:	eb 2a                	jmp    8007ff <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8007df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ea:	c7 04 24 6c 07 80 00 	movl   $0x80076c,(%esp)
  8007f1:	e8 29 fb ff ff       	call   80031f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007ff:	c9                   	leave  
  800800:	c3                   	ret    

00800801 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800807:	8d 45 14             	lea    0x14(%ebp),%eax
  80080a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  80080d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800810:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800814:	8b 45 10             	mov    0x10(%ebp),%eax
  800817:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800822:	8b 45 08             	mov    0x8(%ebp),%eax
  800825:	89 04 24             	mov    %eax,(%esp)
  800828:	e8 74 ff ff ff       	call   8007a1 <vsnprintf>
  80082d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800830:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800833:	c9                   	leave  
  800834:	c3                   	ret    

00800835 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  80083b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800842:	eb 08                	jmp    80084c <strlen+0x17>
		n++;
  800844:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800848:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80084c:	8b 45 08             	mov    0x8(%ebp),%eax
  80084f:	0f b6 00             	movzbl (%eax),%eax
  800852:	84 c0                	test   %al,%al
  800854:	75 ee                	jne    800844 <strlen+0xf>
		n++;
	return n;
  800856:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800859:	c9                   	leave  
  80085a:	c3                   	ret    

0080085b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800861:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800868:	eb 0c                	jmp    800876 <strnlen+0x1b>
		n++;
  80086a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800872:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800876:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80087a:	74 0a                	je     800886 <strnlen+0x2b>
  80087c:	8b 45 08             	mov    0x8(%ebp),%eax
  80087f:	0f b6 00             	movzbl (%eax),%eax
  800882:	84 c0                	test   %al,%al
  800884:	75 e4                	jne    80086a <strnlen+0xf>
		n++;
	return n;
  800886:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800889:	c9                   	leave  
  80088a:	c3                   	ret    

0080088b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800891:	8b 45 08             	mov    0x8(%ebp),%eax
  800894:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800897:	90                   	nop
  800898:	8b 45 08             	mov    0x8(%ebp),%eax
  80089b:	8d 50 01             	lea    0x1(%eax),%edx
  80089e:	89 55 08             	mov    %edx,0x8(%ebp)
  8008a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8008a7:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8008aa:	0f b6 12             	movzbl (%edx),%edx
  8008ad:	88 10                	mov    %dl,(%eax)
  8008af:	0f b6 00             	movzbl (%eax),%eax
  8008b2:	84 c0                	test   %al,%al
  8008b4:	75 e2                	jne    800898 <strcpy+0xd>
		/* do nothing */;
	return ret;
  8008b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008b9:	c9                   	leave  
  8008ba:	c3                   	ret    

008008bb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	89 04 24             	mov    %eax,(%esp)
  8008c7:	e8 69 ff ff ff       	call   800835 <strlen>
  8008cc:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  8008cf:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8008d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d5:	01 c2                	add    %eax,%edx
  8008d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008de:	89 14 24             	mov    %edx,(%esp)
  8008e1:	e8 a5 ff ff ff       	call   80088b <strcpy>
	return dst;
  8008e6:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8008e9:	c9                   	leave  
  8008ea:	c3                   	ret    

008008eb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8008f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f4:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8008f7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008fe:	eb 23                	jmp    800923 <strncpy+0x38>
		*dst++ = *src;
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	8d 50 01             	lea    0x1(%eax),%edx
  800906:	89 55 08             	mov    %edx,0x8(%ebp)
  800909:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090c:	0f b6 12             	movzbl (%edx),%edx
  80090f:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800911:	8b 45 0c             	mov    0xc(%ebp),%eax
  800914:	0f b6 00             	movzbl (%eax),%eax
  800917:	84 c0                	test   %al,%al
  800919:	74 04                	je     80091f <strncpy+0x34>
			src++;
  80091b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80091f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800923:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800926:	3b 45 10             	cmp    0x10(%ebp),%eax
  800929:	72 d5                	jb     800900 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  80092b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80092e:	c9                   	leave  
  80092f:	c3                   	ret    

00800930 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800936:	8b 45 08             	mov    0x8(%ebp),%eax
  800939:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  80093c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800940:	74 33                	je     800975 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800942:	eb 17                	jmp    80095b <strlcpy+0x2b>
			*dst++ = *src++;
  800944:	8b 45 08             	mov    0x8(%ebp),%eax
  800947:	8d 50 01             	lea    0x1(%eax),%edx
  80094a:	89 55 08             	mov    %edx,0x8(%ebp)
  80094d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800950:	8d 4a 01             	lea    0x1(%edx),%ecx
  800953:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800956:	0f b6 12             	movzbl (%edx),%edx
  800959:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80095b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80095f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800963:	74 0a                	je     80096f <strlcpy+0x3f>
  800965:	8b 45 0c             	mov    0xc(%ebp),%eax
  800968:	0f b6 00             	movzbl (%eax),%eax
  80096b:	84 c0                	test   %al,%al
  80096d:	75 d5                	jne    800944 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800975:	8b 55 08             	mov    0x8(%ebp),%edx
  800978:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80097b:	29 c2                	sub    %eax,%edx
  80097d:	89 d0                	mov    %edx,%eax
}
  80097f:	c9                   	leave  
  800980:	c3                   	ret    

00800981 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800984:	eb 08                	jmp    80098e <strcmp+0xd>
		p++, q++;
  800986:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80098a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	0f b6 00             	movzbl (%eax),%eax
  800994:	84 c0                	test   %al,%al
  800996:	74 10                	je     8009a8 <strcmp+0x27>
  800998:	8b 45 08             	mov    0x8(%ebp),%eax
  80099b:	0f b6 10             	movzbl (%eax),%edx
  80099e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a1:	0f b6 00             	movzbl (%eax),%eax
  8009a4:	38 c2                	cmp    %al,%dl
  8009a6:	74 de                	je     800986 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	0f b6 00             	movzbl (%eax),%eax
  8009ae:	0f b6 d0             	movzbl %al,%edx
  8009b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b4:	0f b6 00             	movzbl (%eax),%eax
  8009b7:	0f b6 c0             	movzbl %al,%eax
  8009ba:	29 c2                	sub    %eax,%edx
  8009bc:	89 d0                	mov    %edx,%eax
}
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  8009c3:	eb 0c                	jmp    8009d1 <strncmp+0x11>
		n--, p++, q++;
  8009c5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8009c9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009cd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009d1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009d5:	74 1a                	je     8009f1 <strncmp+0x31>
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	0f b6 00             	movzbl (%eax),%eax
  8009dd:	84 c0                	test   %al,%al
  8009df:	74 10                	je     8009f1 <strncmp+0x31>
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	0f b6 10             	movzbl (%eax),%edx
  8009e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ea:	0f b6 00             	movzbl (%eax),%eax
  8009ed:	38 c2                	cmp    %al,%dl
  8009ef:	74 d4                	je     8009c5 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  8009f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009f5:	75 07                	jne    8009fe <strncmp+0x3e>
		return 0;
  8009f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fc:	eb 16                	jmp    800a14 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	0f b6 00             	movzbl (%eax),%eax
  800a04:	0f b6 d0             	movzbl %al,%edx
  800a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0a:	0f b6 00             	movzbl (%eax),%eax
  800a0d:	0f b6 c0             	movzbl %al,%eax
  800a10:	29 c2                	sub    %eax,%edx
  800a12:	89 d0                	mov    %edx,%eax
}
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	83 ec 04             	sub    $0x4,%esp
  800a1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1f:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a22:	eb 14                	jmp    800a38 <strchr+0x22>
		if (*s == c)
  800a24:	8b 45 08             	mov    0x8(%ebp),%eax
  800a27:	0f b6 00             	movzbl (%eax),%eax
  800a2a:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a2d:	75 05                	jne    800a34 <strchr+0x1e>
			return (char *) s;
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	eb 13                	jmp    800a47 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a34:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a38:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3b:	0f b6 00             	movzbl (%eax),%eax
  800a3e:	84 c0                	test   %al,%al
  800a40:	75 e2                	jne    800a24 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a42:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a47:	c9                   	leave  
  800a48:	c3                   	ret    

00800a49 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	83 ec 04             	sub    $0x4,%esp
  800a4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a52:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a55:	eb 11                	jmp    800a68 <strfind+0x1f>
		if (*s == c)
  800a57:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5a:	0f b6 00             	movzbl (%eax),%eax
  800a5d:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a60:	75 02                	jne    800a64 <strfind+0x1b>
			break;
  800a62:	eb 0e                	jmp    800a72 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a64:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a68:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6b:	0f b6 00             	movzbl (%eax),%eax
  800a6e:	84 c0                	test   %al,%al
  800a70:	75 e5                	jne    800a57 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a75:	c9                   	leave  
  800a76:	c3                   	ret    

00800a77 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	57                   	push   %edi
	char *p;

	if (n == 0)
  800a7b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a7f:	75 05                	jne    800a86 <memset+0xf>
		return v;
  800a81:	8b 45 08             	mov    0x8(%ebp),%eax
  800a84:	eb 5c                	jmp    800ae2 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800a86:	8b 45 08             	mov    0x8(%ebp),%eax
  800a89:	83 e0 03             	and    $0x3,%eax
  800a8c:	85 c0                	test   %eax,%eax
  800a8e:	75 41                	jne    800ad1 <memset+0x5a>
  800a90:	8b 45 10             	mov    0x10(%ebp),%eax
  800a93:	83 e0 03             	and    $0x3,%eax
  800a96:	85 c0                	test   %eax,%eax
  800a98:	75 37                	jne    800ad1 <memset+0x5a>
		c &= 0xFF;
  800a9a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa4:	c1 e0 18             	shl    $0x18,%eax
  800aa7:	89 c2                	mov    %eax,%edx
  800aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aac:	c1 e0 10             	shl    $0x10,%eax
  800aaf:	09 c2                	or     %eax,%edx
  800ab1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab4:	c1 e0 08             	shl    $0x8,%eax
  800ab7:	09 d0                	or     %edx,%eax
  800ab9:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800abc:	8b 45 10             	mov    0x10(%ebp),%eax
  800abf:	c1 e8 02             	shr    $0x2,%eax
  800ac2:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ac4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aca:	89 d7                	mov    %edx,%edi
  800acc:	fc                   	cld    
  800acd:	f3 ab                	rep stos %eax,%es:(%edi)
  800acf:	eb 0e                	jmp    800adf <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ad1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ada:	89 d7                	mov    %edx,%edi
  800adc:	fc                   	cld    
  800add:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800adf:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	57                   	push   %edi
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
  800aeb:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800aee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800af4:	8b 45 08             	mov    0x8(%ebp),%eax
  800af7:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800afa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800afd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b00:	73 6d                	jae    800b6f <memmove+0x8a>
  800b02:	8b 45 10             	mov    0x10(%ebp),%eax
  800b05:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b08:	01 d0                	add    %edx,%eax
  800b0a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b0d:	76 60                	jbe    800b6f <memmove+0x8a>
		s += n;
  800b0f:	8b 45 10             	mov    0x10(%ebp),%eax
  800b12:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800b15:	8b 45 10             	mov    0x10(%ebp),%eax
  800b18:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b1e:	83 e0 03             	and    $0x3,%eax
  800b21:	85 c0                	test   %eax,%eax
  800b23:	75 2f                	jne    800b54 <memmove+0x6f>
  800b25:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b28:	83 e0 03             	and    $0x3,%eax
  800b2b:	85 c0                	test   %eax,%eax
  800b2d:	75 25                	jne    800b54 <memmove+0x6f>
  800b2f:	8b 45 10             	mov    0x10(%ebp),%eax
  800b32:	83 e0 03             	and    $0x3,%eax
  800b35:	85 c0                	test   %eax,%eax
  800b37:	75 1b                	jne    800b54 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b39:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b3c:	83 e8 04             	sub    $0x4,%eax
  800b3f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b42:	83 ea 04             	sub    $0x4,%edx
  800b45:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b48:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b4b:	89 c7                	mov    %eax,%edi
  800b4d:	89 d6                	mov    %edx,%esi
  800b4f:	fd                   	std    
  800b50:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b52:	eb 18                	jmp    800b6c <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b54:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b57:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b5d:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b60:	8b 45 10             	mov    0x10(%ebp),%eax
  800b63:	89 d7                	mov    %edx,%edi
  800b65:	89 de                	mov    %ebx,%esi
  800b67:	89 c1                	mov    %eax,%ecx
  800b69:	fd                   	std    
  800b6a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b6c:	fc                   	cld    
  800b6d:	eb 45                	jmp    800bb4 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b72:	83 e0 03             	and    $0x3,%eax
  800b75:	85 c0                	test   %eax,%eax
  800b77:	75 2b                	jne    800ba4 <memmove+0xbf>
  800b79:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b7c:	83 e0 03             	and    $0x3,%eax
  800b7f:	85 c0                	test   %eax,%eax
  800b81:	75 21                	jne    800ba4 <memmove+0xbf>
  800b83:	8b 45 10             	mov    0x10(%ebp),%eax
  800b86:	83 e0 03             	and    $0x3,%eax
  800b89:	85 c0                	test   %eax,%eax
  800b8b:	75 17                	jne    800ba4 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b8d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b90:	c1 e8 02             	shr    $0x2,%eax
  800b93:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b95:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b98:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b9b:	89 c7                	mov    %eax,%edi
  800b9d:	89 d6                	mov    %edx,%esi
  800b9f:	fc                   	cld    
  800ba0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba2:	eb 10                	jmp    800bb4 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ba4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ba7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800baa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bad:	89 c7                	mov    %eax,%edi
  800baf:	89 d6                	mov    %edx,%esi
  800bb1:	fc                   	cld    
  800bb2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800bb4:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bb7:	83 c4 10             	add    $0x10,%esp
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bc5:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd6:	89 04 24             	mov    %eax,(%esp)
  800bd9:	e8 07 ff ff ff       	call   800ae5 <memmove>
}
  800bde:	c9                   	leave  
  800bdf:	c3                   	ret    

00800be0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800be6:	8b 45 08             	mov    0x8(%ebp),%eax
  800be9:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800bec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bef:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800bf2:	eb 30                	jmp    800c24 <memcmp+0x44>
		if (*s1 != *s2)
  800bf4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bf7:	0f b6 10             	movzbl (%eax),%edx
  800bfa:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bfd:	0f b6 00             	movzbl (%eax),%eax
  800c00:	38 c2                	cmp    %al,%dl
  800c02:	74 18                	je     800c1c <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800c04:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c07:	0f b6 00             	movzbl (%eax),%eax
  800c0a:	0f b6 d0             	movzbl %al,%edx
  800c0d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c10:	0f b6 00             	movzbl (%eax),%eax
  800c13:	0f b6 c0             	movzbl %al,%eax
  800c16:	29 c2                	sub    %eax,%edx
  800c18:	89 d0                	mov    %edx,%eax
  800c1a:	eb 1a                	jmp    800c36 <memcmp+0x56>
		s1++, s2++;
  800c1c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800c20:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c24:	8b 45 10             	mov    0x10(%ebp),%eax
  800c27:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c2a:	89 55 10             	mov    %edx,0x10(%ebp)
  800c2d:	85 c0                	test   %eax,%eax
  800c2f:	75 c3                	jne    800bf4 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c31:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c36:	c9                   	leave  
  800c37:	c3                   	ret    

00800c38 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c3e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	01 d0                	add    %edx,%eax
  800c46:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c49:	eb 13                	jmp    800c5e <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4e:	0f b6 10             	movzbl (%eax),%edx
  800c51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c54:	38 c2                	cmp    %al,%dl
  800c56:	75 02                	jne    800c5a <memfind+0x22>
			break;
  800c58:	eb 0c                	jmp    800c66 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c5a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c61:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c64:	72 e5                	jb     800c4b <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800c66:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c69:	c9                   	leave  
  800c6a:	c3                   	ret    

00800c6b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800c71:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800c78:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c7f:	eb 04                	jmp    800c85 <strtol+0x1a>
		s++;
  800c81:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c85:	8b 45 08             	mov    0x8(%ebp),%eax
  800c88:	0f b6 00             	movzbl (%eax),%eax
  800c8b:	3c 20                	cmp    $0x20,%al
  800c8d:	74 f2                	je     800c81 <strtol+0x16>
  800c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c92:	0f b6 00             	movzbl (%eax),%eax
  800c95:	3c 09                	cmp    $0x9,%al
  800c97:	74 e8                	je     800c81 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c99:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9c:	0f b6 00             	movzbl (%eax),%eax
  800c9f:	3c 2b                	cmp    $0x2b,%al
  800ca1:	75 06                	jne    800ca9 <strtol+0x3e>
		s++;
  800ca3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ca7:	eb 15                	jmp    800cbe <strtol+0x53>
	else if (*s == '-')
  800ca9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cac:	0f b6 00             	movzbl (%eax),%eax
  800caf:	3c 2d                	cmp    $0x2d,%al
  800cb1:	75 0b                	jne    800cbe <strtol+0x53>
		s++, neg = 1;
  800cb3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cb7:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cbe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cc2:	74 06                	je     800cca <strtol+0x5f>
  800cc4:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800cc8:	75 24                	jne    800cee <strtol+0x83>
  800cca:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccd:	0f b6 00             	movzbl (%eax),%eax
  800cd0:	3c 30                	cmp    $0x30,%al
  800cd2:	75 1a                	jne    800cee <strtol+0x83>
  800cd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd7:	83 c0 01             	add    $0x1,%eax
  800cda:	0f b6 00             	movzbl (%eax),%eax
  800cdd:	3c 78                	cmp    $0x78,%al
  800cdf:	75 0d                	jne    800cee <strtol+0x83>
		s += 2, base = 16;
  800ce1:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800ce5:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800cec:	eb 2a                	jmp    800d18 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800cee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cf2:	75 17                	jne    800d0b <strtol+0xa0>
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf7:	0f b6 00             	movzbl (%eax),%eax
  800cfa:	3c 30                	cmp    $0x30,%al
  800cfc:	75 0d                	jne    800d0b <strtol+0xa0>
		s++, base = 8;
  800cfe:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d02:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d09:	eb 0d                	jmp    800d18 <strtol+0xad>
	else if (base == 0)
  800d0b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d0f:	75 07                	jne    800d18 <strtol+0xad>
		base = 10;
  800d11:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d18:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1b:	0f b6 00             	movzbl (%eax),%eax
  800d1e:	3c 2f                	cmp    $0x2f,%al
  800d20:	7e 1b                	jle    800d3d <strtol+0xd2>
  800d22:	8b 45 08             	mov    0x8(%ebp),%eax
  800d25:	0f b6 00             	movzbl (%eax),%eax
  800d28:	3c 39                	cmp    $0x39,%al
  800d2a:	7f 11                	jg     800d3d <strtol+0xd2>
			dig = *s - '0';
  800d2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2f:	0f b6 00             	movzbl (%eax),%eax
  800d32:	0f be c0             	movsbl %al,%eax
  800d35:	83 e8 30             	sub    $0x30,%eax
  800d38:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d3b:	eb 48                	jmp    800d85 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d40:	0f b6 00             	movzbl (%eax),%eax
  800d43:	3c 60                	cmp    $0x60,%al
  800d45:	7e 1b                	jle    800d62 <strtol+0xf7>
  800d47:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4a:	0f b6 00             	movzbl (%eax),%eax
  800d4d:	3c 7a                	cmp    $0x7a,%al
  800d4f:	7f 11                	jg     800d62 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800d51:	8b 45 08             	mov    0x8(%ebp),%eax
  800d54:	0f b6 00             	movzbl (%eax),%eax
  800d57:	0f be c0             	movsbl %al,%eax
  800d5a:	83 e8 57             	sub    $0x57,%eax
  800d5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d60:	eb 23                	jmp    800d85 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800d62:	8b 45 08             	mov    0x8(%ebp),%eax
  800d65:	0f b6 00             	movzbl (%eax),%eax
  800d68:	3c 40                	cmp    $0x40,%al
  800d6a:	7e 3d                	jle    800da9 <strtol+0x13e>
  800d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6f:	0f b6 00             	movzbl (%eax),%eax
  800d72:	3c 5a                	cmp    $0x5a,%al
  800d74:	7f 33                	jg     800da9 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800d76:	8b 45 08             	mov    0x8(%ebp),%eax
  800d79:	0f b6 00             	movzbl (%eax),%eax
  800d7c:	0f be c0             	movsbl %al,%eax
  800d7f:	83 e8 37             	sub    $0x37,%eax
  800d82:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d88:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d8b:	7c 02                	jl     800d8f <strtol+0x124>
			break;
  800d8d:	eb 1a                	jmp    800da9 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800d8f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d93:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d96:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d9a:	89 c2                	mov    %eax,%edx
  800d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d9f:	01 d0                	add    %edx,%eax
  800da1:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800da4:	e9 6f ff ff ff       	jmp    800d18 <strtol+0xad>

	if (endptr)
  800da9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dad:	74 08                	je     800db7 <strtol+0x14c>
		*endptr = (char *) s;
  800daf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800db7:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800dbb:	74 07                	je     800dc4 <strtol+0x159>
  800dbd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800dc0:	f7 d8                	neg    %eax
  800dc2:	eb 03                	jmp    800dc7 <strtol+0x15c>
  800dc4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800dc7:	c9                   	leave  
  800dc8:	c3                   	ret    

00800dc9 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	57                   	push   %edi
  800dcd:	56                   	push   %esi
  800dce:	53                   	push   %ebx
  800dcf:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd5:	8b 55 10             	mov    0x10(%ebp),%edx
  800dd8:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800ddb:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800dde:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800de1:	8b 75 20             	mov    0x20(%ebp),%esi
  800de4:	cd 30                	int    $0x30
  800de6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ded:	74 30                	je     800e1f <syscall+0x56>
  800def:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800df3:	7e 2a                	jle    800e1f <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800df8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e03:	c7 44 24 08 a4 16 80 	movl   $0x8016a4,0x8(%esp)
  800e0a:	00 
  800e0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e12:	00 
  800e13:	c7 04 24 c1 16 80 00 	movl   $0x8016c1,(%esp)
  800e1a:	e8 2c 03 00 00       	call   80114b <_panic>

	return ret;
  800e1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800e22:	83 c4 3c             	add    $0x3c,%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e30:	8b 45 08             	mov    0x8(%ebp),%eax
  800e33:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e3a:	00 
  800e3b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e42:	00 
  800e43:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e4a:	00 
  800e4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e4e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e52:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e56:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e5d:	00 
  800e5e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e65:	e8 5f ff ff ff       	call   800dc9 <syscall>
}
  800e6a:	c9                   	leave  
  800e6b:	c3                   	ret    

00800e6c <sys_cgetc>:

int
sys_cgetc(void)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800e72:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e79:	00 
  800e7a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e81:	00 
  800e82:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e89:	00 
  800e8a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e91:	00 
  800e92:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e99:	00 
  800e9a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ea1:	00 
  800ea2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800ea9:	e8 1b ff ff ff       	call   800dc9 <syscall>
}
  800eae:	c9                   	leave  
  800eaf:	c3                   	ret    

00800eb0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800eb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb9:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ec0:	00 
  800ec1:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ec8:	00 
  800ec9:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ed8:	00 
  800ed9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800edd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800ee4:	00 
  800ee5:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800eec:	e8 d8 fe ff ff       	call   800dc9 <syscall>
}
  800ef1:	c9                   	leave  
  800ef2:	c3                   	ret    

00800ef3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800ef9:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f00:	00 
  800f01:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f08:	00 
  800f09:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f10:	00 
  800f11:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f18:	00 
  800f19:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f20:	00 
  800f21:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f28:	00 
  800f29:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f30:	e8 94 fe ff ff       	call   800dc9 <syscall>
}
  800f35:	c9                   	leave  
  800f36:	c3                   	ret    

00800f37 <sys_yield>:

void
sys_yield(void)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f3d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f44:	00 
  800f45:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f4c:	00 
  800f4d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f54:	00 
  800f55:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f5c:	00 
  800f5d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f64:	00 
  800f65:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f6c:	00 
  800f6d:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800f74:	e8 50 fe ff ff       	call   800dc9 <syscall>
}
  800f79:	c9                   	leave  
  800f7a:	c3                   	ret    

00800f7b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f81:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f84:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f87:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f91:	00 
  800f92:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f99:	00 
  800f9a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f9e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fa2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fa6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fad:	00 
  800fae:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800fb5:	e8 0f fe ff ff       	call   800dc9 <syscall>
}
  800fba:	c9                   	leave  
  800fbb:	c3                   	ret    

00800fbc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	56                   	push   %esi
  800fc0:	53                   	push   %ebx
  800fc1:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800fc4:	8b 75 18             	mov    0x18(%ebp),%esi
  800fc7:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800fca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fcd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd3:	89 74 24 18          	mov    %esi,0x18(%esp)
  800fd7:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800fdb:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fdf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fe3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fe7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fee:	00 
  800fef:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  800ff6:	e8 ce fd ff ff       	call   800dc9 <syscall>
}
  800ffb:	83 c4 20             	add    $0x20,%esp
  800ffe:	5b                   	pop    %ebx
  800fff:	5e                   	pop    %esi
  801000:	5d                   	pop    %ebp
  801001:	c3                   	ret    

00801002 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801008:	8b 55 0c             	mov    0xc(%ebp),%edx
  80100b:	8b 45 08             	mov    0x8(%ebp),%eax
  80100e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801015:	00 
  801016:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80101d:	00 
  80101e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801025:	00 
  801026:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80102a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80102e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801035:	00 
  801036:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  80103d:	e8 87 fd ff ff       	call   800dc9 <syscall>
}
  801042:	c9                   	leave  
  801043:	c3                   	ret    

00801044 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80104a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80104d:	8b 45 08             	mov    0x8(%ebp),%eax
  801050:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801057:	00 
  801058:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80105f:	00 
  801060:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801067:	00 
  801068:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80106c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801070:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801077:	00 
  801078:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  80107f:	e8 45 fd ff ff       	call   800dc9 <syscall>
}
  801084:	c9                   	leave  
  801085:	c3                   	ret    

00801086 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80108c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80108f:	8b 45 08             	mov    0x8(%ebp),%eax
  801092:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801099:	00 
  80109a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010a1:	00 
  8010a2:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010a9:	00 
  8010aa:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010b2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010b9:	00 
  8010ba:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8010c1:	e8 03 fd ff ff       	call   800dc9 <syscall>
}
  8010c6:	c9                   	leave  
  8010c7:	c3                   	ret    

008010c8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8010ce:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8010d1:	8b 55 10             	mov    0x10(%ebp),%edx
  8010d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d7:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010de:	00 
  8010df:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8010e3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ea:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010f9:	00 
  8010fa:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  801101:	e8 c3 fc ff ff       	call   800dc9 <syscall>
}
  801106:	c9                   	leave  
  801107:	c3                   	ret    

00801108 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801108:	55                   	push   %ebp
  801109:	89 e5                	mov    %esp,%ebp
  80110b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80110e:	8b 45 08             	mov    0x8(%ebp),%eax
  801111:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801118:	00 
  801119:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801120:	00 
  801121:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801128:	00 
  801129:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801130:	00 
  801131:	89 44 24 08          	mov    %eax,0x8(%esp)
  801135:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80113c:	00 
  80113d:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801144:	e8 80 fc ff ff       	call   800dc9 <syscall>
}
  801149:	c9                   	leave  
  80114a:	c3                   	ret    

0080114b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80114b:	55                   	push   %ebp
  80114c:	89 e5                	mov    %esp,%ebp
  80114e:	53                   	push   %ebx
  80114f:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  801152:	8d 45 14             	lea    0x14(%ebp),%eax
  801155:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801158:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80115e:	e8 90 fd ff ff       	call   800ef3 <sys_getenvid>
  801163:	8b 55 0c             	mov    0xc(%ebp),%edx
  801166:	89 54 24 10          	mov    %edx,0x10(%esp)
  80116a:	8b 55 08             	mov    0x8(%ebp),%edx
  80116d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801171:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801175:	89 44 24 04          	mov    %eax,0x4(%esp)
  801179:	c7 04 24 d0 16 80 00 	movl   $0x8016d0,(%esp)
  801180:	e8 00 f0 ff ff       	call   800185 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801185:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801188:	89 44 24 04          	mov    %eax,0x4(%esp)
  80118c:	8b 45 10             	mov    0x10(%ebp),%eax
  80118f:	89 04 24             	mov    %eax,(%esp)
  801192:	e8 8a ef ff ff       	call   800121 <vcprintf>
	cprintf("\n");
  801197:	c7 04 24 f3 16 80 00 	movl   $0x8016f3,(%esp)
  80119e:	e8 e2 ef ff ff       	call   800185 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011a3:	cc                   	int3   
  8011a4:	eb fd                	jmp    8011a3 <_panic+0x58>
  8011a6:	66 90                	xchg   %ax,%ax
  8011a8:	66 90                	xchg   %ax,%ax
  8011aa:	66 90                	xchg   %ax,%ax
  8011ac:	66 90                	xchg   %ax,%ax
  8011ae:	66 90                	xchg   %ax,%ax

008011b0 <__udivdi3>:
  8011b0:	55                   	push   %ebp
  8011b1:	57                   	push   %edi
  8011b2:	56                   	push   %esi
  8011b3:	83 ec 0c             	sub    $0xc,%esp
  8011b6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8011ba:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8011be:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8011c2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8011c6:	85 c0                	test   %eax,%eax
  8011c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011cc:	89 ea                	mov    %ebp,%edx
  8011ce:	89 0c 24             	mov    %ecx,(%esp)
  8011d1:	75 2d                	jne    801200 <__udivdi3+0x50>
  8011d3:	39 e9                	cmp    %ebp,%ecx
  8011d5:	77 61                	ja     801238 <__udivdi3+0x88>
  8011d7:	85 c9                	test   %ecx,%ecx
  8011d9:	89 ce                	mov    %ecx,%esi
  8011db:	75 0b                	jne    8011e8 <__udivdi3+0x38>
  8011dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8011e2:	31 d2                	xor    %edx,%edx
  8011e4:	f7 f1                	div    %ecx
  8011e6:	89 c6                	mov    %eax,%esi
  8011e8:	31 d2                	xor    %edx,%edx
  8011ea:	89 e8                	mov    %ebp,%eax
  8011ec:	f7 f6                	div    %esi
  8011ee:	89 c5                	mov    %eax,%ebp
  8011f0:	89 f8                	mov    %edi,%eax
  8011f2:	f7 f6                	div    %esi
  8011f4:	89 ea                	mov    %ebp,%edx
  8011f6:	83 c4 0c             	add    $0xc,%esp
  8011f9:	5e                   	pop    %esi
  8011fa:	5f                   	pop    %edi
  8011fb:	5d                   	pop    %ebp
  8011fc:	c3                   	ret    
  8011fd:	8d 76 00             	lea    0x0(%esi),%esi
  801200:	39 e8                	cmp    %ebp,%eax
  801202:	77 24                	ja     801228 <__udivdi3+0x78>
  801204:	0f bd e8             	bsr    %eax,%ebp
  801207:	83 f5 1f             	xor    $0x1f,%ebp
  80120a:	75 3c                	jne    801248 <__udivdi3+0x98>
  80120c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801210:	39 34 24             	cmp    %esi,(%esp)
  801213:	0f 86 9f 00 00 00    	jbe    8012b8 <__udivdi3+0x108>
  801219:	39 d0                	cmp    %edx,%eax
  80121b:	0f 82 97 00 00 00    	jb     8012b8 <__udivdi3+0x108>
  801221:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801228:	31 d2                	xor    %edx,%edx
  80122a:	31 c0                	xor    %eax,%eax
  80122c:	83 c4 0c             	add    $0xc,%esp
  80122f:	5e                   	pop    %esi
  801230:	5f                   	pop    %edi
  801231:	5d                   	pop    %ebp
  801232:	c3                   	ret    
  801233:	90                   	nop
  801234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801238:	89 f8                	mov    %edi,%eax
  80123a:	f7 f1                	div    %ecx
  80123c:	31 d2                	xor    %edx,%edx
  80123e:	83 c4 0c             	add    $0xc,%esp
  801241:	5e                   	pop    %esi
  801242:	5f                   	pop    %edi
  801243:	5d                   	pop    %ebp
  801244:	c3                   	ret    
  801245:	8d 76 00             	lea    0x0(%esi),%esi
  801248:	89 e9                	mov    %ebp,%ecx
  80124a:	8b 3c 24             	mov    (%esp),%edi
  80124d:	d3 e0                	shl    %cl,%eax
  80124f:	89 c6                	mov    %eax,%esi
  801251:	b8 20 00 00 00       	mov    $0x20,%eax
  801256:	29 e8                	sub    %ebp,%eax
  801258:	89 c1                	mov    %eax,%ecx
  80125a:	d3 ef                	shr    %cl,%edi
  80125c:	89 e9                	mov    %ebp,%ecx
  80125e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801262:	8b 3c 24             	mov    (%esp),%edi
  801265:	09 74 24 08          	or     %esi,0x8(%esp)
  801269:	89 d6                	mov    %edx,%esi
  80126b:	d3 e7                	shl    %cl,%edi
  80126d:	89 c1                	mov    %eax,%ecx
  80126f:	89 3c 24             	mov    %edi,(%esp)
  801272:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801276:	d3 ee                	shr    %cl,%esi
  801278:	89 e9                	mov    %ebp,%ecx
  80127a:	d3 e2                	shl    %cl,%edx
  80127c:	89 c1                	mov    %eax,%ecx
  80127e:	d3 ef                	shr    %cl,%edi
  801280:	09 d7                	or     %edx,%edi
  801282:	89 f2                	mov    %esi,%edx
  801284:	89 f8                	mov    %edi,%eax
  801286:	f7 74 24 08          	divl   0x8(%esp)
  80128a:	89 d6                	mov    %edx,%esi
  80128c:	89 c7                	mov    %eax,%edi
  80128e:	f7 24 24             	mull   (%esp)
  801291:	39 d6                	cmp    %edx,%esi
  801293:	89 14 24             	mov    %edx,(%esp)
  801296:	72 30                	jb     8012c8 <__udivdi3+0x118>
  801298:	8b 54 24 04          	mov    0x4(%esp),%edx
  80129c:	89 e9                	mov    %ebp,%ecx
  80129e:	d3 e2                	shl    %cl,%edx
  8012a0:	39 c2                	cmp    %eax,%edx
  8012a2:	73 05                	jae    8012a9 <__udivdi3+0xf9>
  8012a4:	3b 34 24             	cmp    (%esp),%esi
  8012a7:	74 1f                	je     8012c8 <__udivdi3+0x118>
  8012a9:	89 f8                	mov    %edi,%eax
  8012ab:	31 d2                	xor    %edx,%edx
  8012ad:	e9 7a ff ff ff       	jmp    80122c <__udivdi3+0x7c>
  8012b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012b8:	31 d2                	xor    %edx,%edx
  8012ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8012bf:	e9 68 ff ff ff       	jmp    80122c <__udivdi3+0x7c>
  8012c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012c8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8012cb:	31 d2                	xor    %edx,%edx
  8012cd:	83 c4 0c             	add    $0xc,%esp
  8012d0:	5e                   	pop    %esi
  8012d1:	5f                   	pop    %edi
  8012d2:	5d                   	pop    %ebp
  8012d3:	c3                   	ret    
  8012d4:	66 90                	xchg   %ax,%ax
  8012d6:	66 90                	xchg   %ax,%ax
  8012d8:	66 90                	xchg   %ax,%ax
  8012da:	66 90                	xchg   %ax,%ax
  8012dc:	66 90                	xchg   %ax,%ax
  8012de:	66 90                	xchg   %ax,%ax

008012e0 <__umoddi3>:
  8012e0:	55                   	push   %ebp
  8012e1:	57                   	push   %edi
  8012e2:	56                   	push   %esi
  8012e3:	83 ec 14             	sub    $0x14,%esp
  8012e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012ea:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8012ee:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8012f2:	89 c7                	mov    %eax,%edi
  8012f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8012fc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801300:	89 34 24             	mov    %esi,(%esp)
  801303:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801307:	85 c0                	test   %eax,%eax
  801309:	89 c2                	mov    %eax,%edx
  80130b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80130f:	75 17                	jne    801328 <__umoddi3+0x48>
  801311:	39 fe                	cmp    %edi,%esi
  801313:	76 4b                	jbe    801360 <__umoddi3+0x80>
  801315:	89 c8                	mov    %ecx,%eax
  801317:	89 fa                	mov    %edi,%edx
  801319:	f7 f6                	div    %esi
  80131b:	89 d0                	mov    %edx,%eax
  80131d:	31 d2                	xor    %edx,%edx
  80131f:	83 c4 14             	add    $0x14,%esp
  801322:	5e                   	pop    %esi
  801323:	5f                   	pop    %edi
  801324:	5d                   	pop    %ebp
  801325:	c3                   	ret    
  801326:	66 90                	xchg   %ax,%ax
  801328:	39 f8                	cmp    %edi,%eax
  80132a:	77 54                	ja     801380 <__umoddi3+0xa0>
  80132c:	0f bd e8             	bsr    %eax,%ebp
  80132f:	83 f5 1f             	xor    $0x1f,%ebp
  801332:	75 5c                	jne    801390 <__umoddi3+0xb0>
  801334:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801338:	39 3c 24             	cmp    %edi,(%esp)
  80133b:	0f 87 e7 00 00 00    	ja     801428 <__umoddi3+0x148>
  801341:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801345:	29 f1                	sub    %esi,%ecx
  801347:	19 c7                	sbb    %eax,%edi
  801349:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80134d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801351:	8b 44 24 08          	mov    0x8(%esp),%eax
  801355:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801359:	83 c4 14             	add    $0x14,%esp
  80135c:	5e                   	pop    %esi
  80135d:	5f                   	pop    %edi
  80135e:	5d                   	pop    %ebp
  80135f:	c3                   	ret    
  801360:	85 f6                	test   %esi,%esi
  801362:	89 f5                	mov    %esi,%ebp
  801364:	75 0b                	jne    801371 <__umoddi3+0x91>
  801366:	b8 01 00 00 00       	mov    $0x1,%eax
  80136b:	31 d2                	xor    %edx,%edx
  80136d:	f7 f6                	div    %esi
  80136f:	89 c5                	mov    %eax,%ebp
  801371:	8b 44 24 04          	mov    0x4(%esp),%eax
  801375:	31 d2                	xor    %edx,%edx
  801377:	f7 f5                	div    %ebp
  801379:	89 c8                	mov    %ecx,%eax
  80137b:	f7 f5                	div    %ebp
  80137d:	eb 9c                	jmp    80131b <__umoddi3+0x3b>
  80137f:	90                   	nop
  801380:	89 c8                	mov    %ecx,%eax
  801382:	89 fa                	mov    %edi,%edx
  801384:	83 c4 14             	add    $0x14,%esp
  801387:	5e                   	pop    %esi
  801388:	5f                   	pop    %edi
  801389:	5d                   	pop    %ebp
  80138a:	c3                   	ret    
  80138b:	90                   	nop
  80138c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801390:	8b 04 24             	mov    (%esp),%eax
  801393:	be 20 00 00 00       	mov    $0x20,%esi
  801398:	89 e9                	mov    %ebp,%ecx
  80139a:	29 ee                	sub    %ebp,%esi
  80139c:	d3 e2                	shl    %cl,%edx
  80139e:	89 f1                	mov    %esi,%ecx
  8013a0:	d3 e8                	shr    %cl,%eax
  8013a2:	89 e9                	mov    %ebp,%ecx
  8013a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a8:	8b 04 24             	mov    (%esp),%eax
  8013ab:	09 54 24 04          	or     %edx,0x4(%esp)
  8013af:	89 fa                	mov    %edi,%edx
  8013b1:	d3 e0                	shl    %cl,%eax
  8013b3:	89 f1                	mov    %esi,%ecx
  8013b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013b9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8013bd:	d3 ea                	shr    %cl,%edx
  8013bf:	89 e9                	mov    %ebp,%ecx
  8013c1:	d3 e7                	shl    %cl,%edi
  8013c3:	89 f1                	mov    %esi,%ecx
  8013c5:	d3 e8                	shr    %cl,%eax
  8013c7:	89 e9                	mov    %ebp,%ecx
  8013c9:	09 f8                	or     %edi,%eax
  8013cb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8013cf:	f7 74 24 04          	divl   0x4(%esp)
  8013d3:	d3 e7                	shl    %cl,%edi
  8013d5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013d9:	89 d7                	mov    %edx,%edi
  8013db:	f7 64 24 08          	mull   0x8(%esp)
  8013df:	39 d7                	cmp    %edx,%edi
  8013e1:	89 c1                	mov    %eax,%ecx
  8013e3:	89 14 24             	mov    %edx,(%esp)
  8013e6:	72 2c                	jb     801414 <__umoddi3+0x134>
  8013e8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8013ec:	72 22                	jb     801410 <__umoddi3+0x130>
  8013ee:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8013f2:	29 c8                	sub    %ecx,%eax
  8013f4:	19 d7                	sbb    %edx,%edi
  8013f6:	89 e9                	mov    %ebp,%ecx
  8013f8:	89 fa                	mov    %edi,%edx
  8013fa:	d3 e8                	shr    %cl,%eax
  8013fc:	89 f1                	mov    %esi,%ecx
  8013fe:	d3 e2                	shl    %cl,%edx
  801400:	89 e9                	mov    %ebp,%ecx
  801402:	d3 ef                	shr    %cl,%edi
  801404:	09 d0                	or     %edx,%eax
  801406:	89 fa                	mov    %edi,%edx
  801408:	83 c4 14             	add    $0x14,%esp
  80140b:	5e                   	pop    %esi
  80140c:	5f                   	pop    %edi
  80140d:	5d                   	pop    %ebp
  80140e:	c3                   	ret    
  80140f:	90                   	nop
  801410:	39 d7                	cmp    %edx,%edi
  801412:	75 da                	jne    8013ee <__umoddi3+0x10e>
  801414:	8b 14 24             	mov    (%esp),%edx
  801417:	89 c1                	mov    %eax,%ecx
  801419:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80141d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801421:	eb cb                	jmp    8013ee <__umoddi3+0x10e>
  801423:	90                   	nop
  801424:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801428:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80142c:	0f 82 0f ff ff ff    	jb     801341 <__umoddi3+0x61>
  801432:	e9 1a ff ff ff       	jmp    801351 <__umoddi3+0x71>
