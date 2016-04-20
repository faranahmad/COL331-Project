
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2e 00 00 00       	call   80005f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  800039:	c7 04 24 40 14 80 00 	movl   $0x801440,(%esp)
  800040:	e8 3c 01 00 00       	call   800181 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800045:	a1 04 20 80 00       	mov    0x802004,%eax
  80004a:	8b 40 48             	mov    0x48(%eax),%eax
  80004d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800051:	c7 04 24 4e 14 80 00 	movl   $0x80144e,(%esp)
  800058:	e8 24 01 00 00       	call   800181 <cprintf>
}
  80005d:	c9                   	leave  
  80005e:	c3                   	ret    

0080005f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800065:	e8 85 0e 00 00       	call   800eef <sys_getenvid>
  80006a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006f:	c1 e0 02             	shl    $0x2,%eax
  800072:	89 c2                	mov    %eax,%edx
  800074:	c1 e2 05             	shl    $0x5,%edx
  800077:	29 c2                	sub    %eax,%edx
  800079:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  80007f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800084:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800088:	7e 0a                	jle    800094 <libmain+0x35>
		binaryname = argv[0];
  80008a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80008d:	8b 00                	mov    (%eax),%eax
  80008f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800094:	8b 45 0c             	mov    0xc(%ebp),%eax
  800097:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009b:	8b 45 08             	mov    0x8(%ebp),%eax
  80009e:	89 04 24             	mov    %eax,(%esp)
  8000a1:	e8 8d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a6:	e8 02 00 00 00       	call   8000ad <exit>
}
  8000ab:	c9                   	leave  
  8000ac:	c3                   	ret    

008000ad <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ad:	55                   	push   %ebp
  8000ae:	89 e5                	mov    %esp,%ebp
  8000b0:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ba:	e8 ed 0d 00 00       	call   800eac <sys_env_destroy>
}
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    

008000c1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8000c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ca:	8b 00                	mov    (%eax),%eax
  8000cc:	8d 48 01             	lea    0x1(%eax),%ecx
  8000cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000d2:	89 0a                	mov    %ecx,(%edx)
  8000d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d7:	89 d1                	mov    %edx,%ecx
  8000d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000dc:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8000e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e3:	8b 00                	mov    (%eax),%eax
  8000e5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ea:	75 20                	jne    80010c <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8000ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ef:	8b 00                	mov    (%eax),%eax
  8000f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000f4:	83 c2 08             	add    $0x8,%edx
  8000f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000fb:	89 14 24             	mov    %edx,(%esp)
  8000fe:	e8 23 0d 00 00       	call   800e26 <sys_cputs>
		b->idx = 0;
  800103:	8b 45 0c             	mov    0xc(%ebp),%eax
  800106:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80010c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80010f:	8b 40 04             	mov    0x4(%eax),%eax
  800112:	8d 50 01             	lea    0x1(%eax),%edx
  800115:	8b 45 0c             	mov    0xc(%ebp),%eax
  800118:	89 50 04             	mov    %edx,0x4(%eax)
}
  80011b:	c9                   	leave  
  80011c:	c3                   	ret    

0080011d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800126:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80012d:	00 00 00 
	b.cnt = 0;
  800130:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800137:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800141:	8b 45 08             	mov    0x8(%ebp),%eax
  800144:	89 44 24 08          	mov    %eax,0x8(%esp)
  800148:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800152:	c7 04 24 c1 00 80 00 	movl   $0x8000c1,(%esp)
  800159:	e8 bd 01 00 00       	call   80031b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800164:	89 44 24 04          	mov    %eax,0x4(%esp)
  800168:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016e:	83 c0 08             	add    $0x8,%eax
  800171:	89 04 24             	mov    %eax,(%esp)
  800174:	e8 ad 0c 00 00       	call   800e26 <sys_cputs>

	return b.cnt;
  800179:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80017f:	c9                   	leave  
  800180:	c3                   	ret    

00800181 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800187:	8d 45 0c             	lea    0xc(%ebp),%eax
  80018a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80018d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800190:	89 44 24 04          	mov    %eax,0x4(%esp)
  800194:	8b 45 08             	mov    0x8(%ebp),%eax
  800197:	89 04 24             	mov    %eax,(%esp)
  80019a:	e8 7e ff ff ff       	call   80011d <vcprintf>
  80019f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8001a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 34             	sub    $0x34,%esp
  8001ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8001b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8001b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ba:	8b 45 18             	mov    0x18(%ebp),%eax
  8001bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c2:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001c5:	77 72                	ja     800239 <printnum+0x92>
  8001c7:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001ca:	72 05                	jb     8001d1 <printnum+0x2a>
  8001cc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8001cf:	77 68                	ja     800239 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d1:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8001d4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001d7:	8b 45 18             	mov    0x18(%ebp),%eax
  8001da:	ba 00 00 00 00       	mov    $0x0,%edx
  8001df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8001ed:	89 04 24             	mov    %eax,(%esp)
  8001f0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f4:	e8 b7 0f 00 00       	call   8011b0 <__udivdi3>
  8001f9:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8001fc:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800200:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800204:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800207:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80020b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800213:	8b 45 0c             	mov    0xc(%ebp),%eax
  800216:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021a:	8b 45 08             	mov    0x8(%ebp),%eax
  80021d:	89 04 24             	mov    %eax,(%esp)
  800220:	e8 82 ff ff ff       	call   8001a7 <printnum>
  800225:	eb 1c                	jmp    800243 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800227:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022e:	8b 45 20             	mov    0x20(%ebp),%eax
  800231:	89 04 24             	mov    %eax,(%esp)
  800234:	8b 45 08             	mov    0x8(%ebp),%eax
  800237:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800239:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  80023d:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800241:	7f e4                	jg     800227 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800243:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800246:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80024e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800251:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800255:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800259:	89 04 24             	mov    %eax,(%esp)
  80025c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800260:	e8 7b 10 00 00       	call   8012e0 <__umoddi3>
  800265:	05 48 15 80 00       	add    $0x801548,%eax
  80026a:	0f b6 00             	movzbl (%eax),%eax
  80026d:	0f be c0             	movsbl %al,%eax
  800270:	8b 55 0c             	mov    0xc(%ebp),%edx
  800273:	89 54 24 04          	mov    %edx,0x4(%esp)
  800277:	89 04 24             	mov    %eax,(%esp)
  80027a:	8b 45 08             	mov    0x8(%ebp),%eax
  80027d:	ff d0                	call   *%eax
}
  80027f:	83 c4 34             	add    $0x34,%esp
  800282:	5b                   	pop    %ebx
  800283:	5d                   	pop    %ebp
  800284:	c3                   	ret    

00800285 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800288:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80028c:	7e 14                	jle    8002a2 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	8b 00                	mov    (%eax),%eax
  800293:	8d 48 08             	lea    0x8(%eax),%ecx
  800296:	8b 55 08             	mov    0x8(%ebp),%edx
  800299:	89 0a                	mov    %ecx,(%edx)
  80029b:	8b 50 04             	mov    0x4(%eax),%edx
  80029e:	8b 00                	mov    (%eax),%eax
  8002a0:	eb 30                	jmp    8002d2 <getuint+0x4d>
	else if (lflag)
  8002a2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002a6:	74 16                	je     8002be <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8002a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ab:	8b 00                	mov    (%eax),%eax
  8002ad:	8d 48 04             	lea    0x4(%eax),%ecx
  8002b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b3:	89 0a                	mov    %ecx,(%edx)
  8002b5:	8b 00                	mov    (%eax),%eax
  8002b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bc:	eb 14                	jmp    8002d2 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8002be:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c1:	8b 00                	mov    (%eax),%eax
  8002c3:	8d 48 04             	lea    0x4(%eax),%ecx
  8002c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c9:	89 0a                	mov    %ecx,(%edx)
  8002cb:	8b 00                	mov    (%eax),%eax
  8002cd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d2:	5d                   	pop    %ebp
  8002d3:	c3                   	ret    

008002d4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d7:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002db:	7e 14                	jle    8002f1 <getint+0x1d>
		return va_arg(*ap, long long);
  8002dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e0:	8b 00                	mov    (%eax),%eax
  8002e2:	8d 48 08             	lea    0x8(%eax),%ecx
  8002e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e8:	89 0a                	mov    %ecx,(%edx)
  8002ea:	8b 50 04             	mov    0x4(%eax),%edx
  8002ed:	8b 00                	mov    (%eax),%eax
  8002ef:	eb 28                	jmp    800319 <getint+0x45>
	else if (lflag)
  8002f1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002f5:	74 12                	je     800309 <getint+0x35>
		return va_arg(*ap, long);
  8002f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fa:	8b 00                	mov    (%eax),%eax
  8002fc:	8d 48 04             	lea    0x4(%eax),%ecx
  8002ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800302:	89 0a                	mov    %ecx,(%edx)
  800304:	8b 00                	mov    (%eax),%eax
  800306:	99                   	cltd   
  800307:	eb 10                	jmp    800319 <getint+0x45>
	else
		return va_arg(*ap, int);
  800309:	8b 45 08             	mov    0x8(%ebp),%eax
  80030c:	8b 00                	mov    (%eax),%eax
  80030e:	8d 48 04             	lea    0x4(%eax),%ecx
  800311:	8b 55 08             	mov    0x8(%ebp),%edx
  800314:	89 0a                	mov    %ecx,(%edx)
  800316:	8b 00                	mov    (%eax),%eax
  800318:	99                   	cltd   
}
  800319:	5d                   	pop    %ebp
  80031a:	c3                   	ret    

0080031b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800323:	eb 18                	jmp    80033d <vprintfmt+0x22>
			if (ch == '\0')
  800325:	85 db                	test   %ebx,%ebx
  800327:	75 05                	jne    80032e <vprintfmt+0x13>
				return;
  800329:	e9 05 04 00 00       	jmp    800733 <vprintfmt+0x418>
			putch(ch, putdat);
  80032e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800331:	89 44 24 04          	mov    %eax,0x4(%esp)
  800335:	89 1c 24             	mov    %ebx,(%esp)
  800338:	8b 45 08             	mov    0x8(%ebp),%eax
  80033b:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80033d:	8b 45 10             	mov    0x10(%ebp),%eax
  800340:	8d 50 01             	lea    0x1(%eax),%edx
  800343:	89 55 10             	mov    %edx,0x10(%ebp)
  800346:	0f b6 00             	movzbl (%eax),%eax
  800349:	0f b6 d8             	movzbl %al,%ebx
  80034c:	83 fb 25             	cmp    $0x25,%ebx
  80034f:	75 d4                	jne    800325 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800351:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800355:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80035c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800363:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80036a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800371:	8b 45 10             	mov    0x10(%ebp),%eax
  800374:	8d 50 01             	lea    0x1(%eax),%edx
  800377:	89 55 10             	mov    %edx,0x10(%ebp)
  80037a:	0f b6 00             	movzbl (%eax),%eax
  80037d:	0f b6 d8             	movzbl %al,%ebx
  800380:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800383:	83 f8 55             	cmp    $0x55,%eax
  800386:	0f 87 76 03 00 00    	ja     800702 <vprintfmt+0x3e7>
  80038c:	8b 04 85 6c 15 80 00 	mov    0x80156c(,%eax,4),%eax
  800393:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800395:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800399:	eb d6                	jmp    800371 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80039b:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80039f:	eb d0                	jmp    800371 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8003a8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003ab:	89 d0                	mov    %edx,%eax
  8003ad:	c1 e0 02             	shl    $0x2,%eax
  8003b0:	01 d0                	add    %edx,%eax
  8003b2:	01 c0                	add    %eax,%eax
  8003b4:	01 d8                	add    %ebx,%eax
  8003b6:	83 e8 30             	sub    $0x30,%eax
  8003b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8003bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8003bf:	0f b6 00             	movzbl (%eax),%eax
  8003c2:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8003c5:	83 fb 2f             	cmp    $0x2f,%ebx
  8003c8:	7e 0b                	jle    8003d5 <vprintfmt+0xba>
  8003ca:	83 fb 39             	cmp    $0x39,%ebx
  8003cd:	7f 06                	jg     8003d5 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003cf:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d3:	eb d3                	jmp    8003a8 <vprintfmt+0x8d>
			goto process_precision;
  8003d5:	eb 33                	jmp    80040a <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8003d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003da:	8d 50 04             	lea    0x4(%eax),%edx
  8003dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e0:	8b 00                	mov    (%eax),%eax
  8003e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8003e5:	eb 23                	jmp    80040a <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8003e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003eb:	79 0c                	jns    8003f9 <vprintfmt+0xde>
				width = 0;
  8003ed:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8003f4:	e9 78 ff ff ff       	jmp    800371 <vprintfmt+0x56>
  8003f9:	e9 73 ff ff ff       	jmp    800371 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8003fe:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800405:	e9 67 ff ff ff       	jmp    800371 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80040a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80040e:	79 12                	jns    800422 <vprintfmt+0x107>
				width = precision, precision = -1;
  800410:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800413:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800416:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80041d:	e9 4f ff ff ff       	jmp    800371 <vprintfmt+0x56>
  800422:	e9 4a ff ff ff       	jmp    800371 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800427:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80042b:	e9 41 ff ff ff       	jmp    800371 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800430:	8b 45 14             	mov    0x14(%ebp),%eax
  800433:	8d 50 04             	lea    0x4(%eax),%edx
  800436:	89 55 14             	mov    %edx,0x14(%ebp)
  800439:	8b 00                	mov    (%eax),%eax
  80043b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800442:	89 04 24             	mov    %eax,(%esp)
  800445:	8b 45 08             	mov    0x8(%ebp),%eax
  800448:	ff d0                	call   *%eax
			break;
  80044a:	e9 de 02 00 00       	jmp    80072d <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044f:	8b 45 14             	mov    0x14(%ebp),%eax
  800452:	8d 50 04             	lea    0x4(%eax),%edx
  800455:	89 55 14             	mov    %edx,0x14(%ebp)
  800458:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80045a:	85 db                	test   %ebx,%ebx
  80045c:	79 02                	jns    800460 <vprintfmt+0x145>
				err = -err;
  80045e:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800460:	83 fb 09             	cmp    $0x9,%ebx
  800463:	7f 0b                	jg     800470 <vprintfmt+0x155>
  800465:	8b 34 9d 20 15 80 00 	mov    0x801520(,%ebx,4),%esi
  80046c:	85 f6                	test   %esi,%esi
  80046e:	75 23                	jne    800493 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800470:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800474:	c7 44 24 08 59 15 80 	movl   $0x801559,0x8(%esp)
  80047b:	00 
  80047c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80047f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800483:	8b 45 08             	mov    0x8(%ebp),%eax
  800486:	89 04 24             	mov    %eax,(%esp)
  800489:	e8 ac 02 00 00       	call   80073a <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80048e:	e9 9a 02 00 00       	jmp    80072d <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800493:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800497:	c7 44 24 08 62 15 80 	movl   $0x801562,0x8(%esp)
  80049e:	00 
  80049f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a9:	89 04 24             	mov    %eax,(%esp)
  8004ac:	e8 89 02 00 00       	call   80073a <printfmt>
			break;
  8004b1:	e9 77 02 00 00       	jmp    80072d <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b9:	8d 50 04             	lea    0x4(%eax),%edx
  8004bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bf:	8b 30                	mov    (%eax),%esi
  8004c1:	85 f6                	test   %esi,%esi
  8004c3:	75 05                	jne    8004ca <vprintfmt+0x1af>
				p = "(null)";
  8004c5:	be 65 15 80 00       	mov    $0x801565,%esi
			if (width > 0 && padc != '-')
  8004ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ce:	7e 37                	jle    800507 <vprintfmt+0x1ec>
  8004d0:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8004d4:	74 31                	je     800507 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004dd:	89 34 24             	mov    %esi,(%esp)
  8004e0:	e8 72 03 00 00       	call   800857 <strnlen>
  8004e5:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8004e8:	eb 17                	jmp    800501 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8004ea:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8004ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004f5:	89 04 24             	mov    %eax,(%esp)
  8004f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fb:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fd:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800501:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800505:	7f e3                	jg     8004ea <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800507:	eb 38                	jmp    800541 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800509:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80050d:	74 1f                	je     80052e <vprintfmt+0x213>
  80050f:	83 fb 1f             	cmp    $0x1f,%ebx
  800512:	7e 05                	jle    800519 <vprintfmt+0x1fe>
  800514:	83 fb 7e             	cmp    $0x7e,%ebx
  800517:	7e 15                	jle    80052e <vprintfmt+0x213>
					putch('?', putdat);
  800519:	8b 45 0c             	mov    0xc(%ebp),%eax
  80051c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800520:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800527:	8b 45 08             	mov    0x8(%ebp),%eax
  80052a:	ff d0                	call   *%eax
  80052c:	eb 0f                	jmp    80053d <vprintfmt+0x222>
				else
					putch(ch, putdat);
  80052e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800531:	89 44 24 04          	mov    %eax,0x4(%esp)
  800535:	89 1c 24             	mov    %ebx,(%esp)
  800538:	8b 45 08             	mov    0x8(%ebp),%eax
  80053b:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800541:	89 f0                	mov    %esi,%eax
  800543:	8d 70 01             	lea    0x1(%eax),%esi
  800546:	0f b6 00             	movzbl (%eax),%eax
  800549:	0f be d8             	movsbl %al,%ebx
  80054c:	85 db                	test   %ebx,%ebx
  80054e:	74 10                	je     800560 <vprintfmt+0x245>
  800550:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800554:	78 b3                	js     800509 <vprintfmt+0x1ee>
  800556:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80055a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80055e:	79 a9                	jns    800509 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800560:	eb 17                	jmp    800579 <vprintfmt+0x25e>
				putch(' ', putdat);
  800562:	8b 45 0c             	mov    0xc(%ebp),%eax
  800565:	89 44 24 04          	mov    %eax,0x4(%esp)
  800569:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800570:	8b 45 08             	mov    0x8(%ebp),%eax
  800573:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800575:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800579:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80057d:	7f e3                	jg     800562 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  80057f:	e9 a9 01 00 00       	jmp    80072d <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800584:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800587:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058b:	8d 45 14             	lea    0x14(%ebp),%eax
  80058e:	89 04 24             	mov    %eax,(%esp)
  800591:	e8 3e fd ff ff       	call   8002d4 <getint>
  800596:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800599:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  80059c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80059f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005a2:	85 d2                	test   %edx,%edx
  8005a4:	79 26                	jns    8005cc <vprintfmt+0x2b1>
				putch('-', putdat);
  8005a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ad:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b7:	ff d0                	call   *%eax
				num = -(long long) num;
  8005b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005bf:	f7 d8                	neg    %eax
  8005c1:	83 d2 00             	adc    $0x0,%edx
  8005c4:	f7 da                	neg    %edx
  8005c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8005cc:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8005d3:	e9 e1 00 00 00       	jmp    8006b9 <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005df:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e2:	89 04 24             	mov    %eax,(%esp)
  8005e5:	e8 9b fc ff ff       	call   800285 <getuint>
  8005ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005ed:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8005f0:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8005f7:	e9 bd 00 00 00       	jmp    8006b9 <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  8005fc:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  800603:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800606:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060a:	8d 45 14             	lea    0x14(%ebp),%eax
  80060d:	89 04 24             	mov    %eax,(%esp)
  800610:	e8 70 fc ff ff       	call   800285 <getuint>
  800615:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800618:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  80061b:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  80061f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800622:	89 54 24 18          	mov    %edx,0x18(%esp)
  800626:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800629:	89 54 24 14          	mov    %edx,0x14(%esp)
  80062d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800631:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800634:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800637:	89 44 24 08          	mov    %eax,0x8(%esp)
  80063b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80063f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800642:	89 44 24 04          	mov    %eax,0x4(%esp)
  800646:	8b 45 08             	mov    0x8(%ebp),%eax
  800649:	89 04 24             	mov    %eax,(%esp)
  80064c:	e8 56 fb ff ff       	call   8001a7 <printnum>
			break;
  800651:	e9 d7 00 00 00       	jmp    80072d <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  800656:	8b 45 0c             	mov    0xc(%ebp),%eax
  800659:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800664:	8b 45 08             	mov    0x8(%ebp),%eax
  800667:	ff d0                	call   *%eax
			putch('x', putdat);
  800669:	8b 45 0c             	mov    0xc(%ebp),%eax
  80066c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800670:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800677:	8b 45 08             	mov    0x8(%ebp),%eax
  80067a:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8d 50 04             	lea    0x4(%eax),%edx
  800682:	89 55 14             	mov    %edx,0x14(%ebp)
  800685:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800687:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80068a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800691:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800698:	eb 1f                	jmp    8006b9 <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80069a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80069d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a4:	89 04 24             	mov    %eax,(%esp)
  8006a7:	e8 d9 fb ff ff       	call   800285 <getuint>
  8006ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006af:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8006b2:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b9:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8006bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c0:	89 54 24 18          	mov    %edx,0x18(%esp)
  8006c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006c7:	89 54 24 14          	mov    %edx,0x14(%esp)
  8006cb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e7:	89 04 24             	mov    %eax,(%esp)
  8006ea:	e8 b8 fa ff ff       	call   8001a7 <printnum>
			break;
  8006ef:	eb 3c                	jmp    80072d <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f8:	89 1c 24             	mov    %ebx,(%esp)
  8006fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fe:	ff d0                	call   *%eax
			break;
  800700:	eb 2b                	jmp    80072d <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800702:	8b 45 0c             	mov    0xc(%ebp),%eax
  800705:	89 44 24 04          	mov    %eax,0x4(%esp)
  800709:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800710:	8b 45 08             	mov    0x8(%ebp),%eax
  800713:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800715:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800719:	eb 04                	jmp    80071f <vprintfmt+0x404>
  80071b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80071f:	8b 45 10             	mov    0x10(%ebp),%eax
  800722:	83 e8 01             	sub    $0x1,%eax
  800725:	0f b6 00             	movzbl (%eax),%eax
  800728:	3c 25                	cmp    $0x25,%al
  80072a:	75 ef                	jne    80071b <vprintfmt+0x400>
				/* do nothing */;
			break;
  80072c:	90                   	nop
		}
	}
  80072d:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80072e:	e9 0a fc ff ff       	jmp    80033d <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800733:	83 c4 40             	add    $0x40,%esp
  800736:	5b                   	pop    %ebx
  800737:	5e                   	pop    %esi
  800738:	5d                   	pop    %ebp
  800739:	c3                   	ret    

0080073a <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800740:	8d 45 14             	lea    0x14(%ebp),%eax
  800743:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800746:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800749:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074d:	8b 45 10             	mov    0x10(%ebp),%eax
  800750:	89 44 24 08          	mov    %eax,0x8(%esp)
  800754:	8b 45 0c             	mov    0xc(%ebp),%eax
  800757:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075b:	8b 45 08             	mov    0x8(%ebp),%eax
  80075e:	89 04 24             	mov    %eax,(%esp)
  800761:	e8 b5 fb ff ff       	call   80031b <vprintfmt>
	va_end(ap);
}
  800766:	c9                   	leave  
  800767:	c3                   	ret    

00800768 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  80076b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076e:	8b 40 08             	mov    0x8(%eax),%eax
  800771:	8d 50 01             	lea    0x1(%eax),%edx
  800774:	8b 45 0c             	mov    0xc(%ebp),%eax
  800777:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  80077a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80077d:	8b 10                	mov    (%eax),%edx
  80077f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800782:	8b 40 04             	mov    0x4(%eax),%eax
  800785:	39 c2                	cmp    %eax,%edx
  800787:	73 12                	jae    80079b <sprintputch+0x33>
		*b->buf++ = ch;
  800789:	8b 45 0c             	mov    0xc(%ebp),%eax
  80078c:	8b 00                	mov    (%eax),%eax
  80078e:	8d 48 01             	lea    0x1(%eax),%ecx
  800791:	8b 55 0c             	mov    0xc(%ebp),%edx
  800794:	89 0a                	mov    %ecx,(%edx)
  800796:	8b 55 08             	mov    0x8(%ebp),%edx
  800799:	88 10                	mov    %dl,(%eax)
}
  80079b:	5d                   	pop    %ebp
  80079c:	c3                   	ret    

0080079d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ac:	8d 50 ff             	lea    -0x1(%eax),%edx
  8007af:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b2:	01 d0                	add    %edx,%eax
  8007b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007be:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8007c2:	74 06                	je     8007ca <vsnprintf+0x2d>
  8007c4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007c8:	7f 07                	jg     8007d1 <vsnprintf+0x34>
		return -E_INVAL;
  8007ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007cf:	eb 2a                	jmp    8007fb <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8007db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007df:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e6:	c7 04 24 68 07 80 00 	movl   $0x800768,(%esp)
  8007ed:	e8 29 fb ff ff       	call   80031b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    

008007fd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800803:	8d 45 14             	lea    0x14(%ebp),%eax
  800806:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800809:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80080c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800810:	8b 45 10             	mov    0x10(%ebp),%eax
  800813:	89 44 24 08          	mov    %eax,0x8(%esp)
  800817:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081e:	8b 45 08             	mov    0x8(%ebp),%eax
  800821:	89 04 24             	mov    %eax,(%esp)
  800824:	e8 74 ff ff ff       	call   80079d <vsnprintf>
  800829:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  80082c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80082f:	c9                   	leave  
  800830:	c3                   	ret    

00800831 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800837:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80083e:	eb 08                	jmp    800848 <strlen+0x17>
		n++;
  800840:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800844:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	0f b6 00             	movzbl (%eax),%eax
  80084e:	84 c0                	test   %al,%al
  800850:	75 ee                	jne    800840 <strlen+0xf>
		n++;
	return n;
  800852:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800855:	c9                   	leave  
  800856:	c3                   	ret    

00800857 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800864:	eb 0c                	jmp    800872 <strnlen+0x1b>
		n++;
  800866:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80086e:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800872:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800876:	74 0a                	je     800882 <strnlen+0x2b>
  800878:	8b 45 08             	mov    0x8(%ebp),%eax
  80087b:	0f b6 00             	movzbl (%eax),%eax
  80087e:	84 c0                	test   %al,%al
  800880:	75 e4                	jne    800866 <strnlen+0xf>
		n++;
	return n;
  800882:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800885:	c9                   	leave  
  800886:	c3                   	ret    

00800887 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800893:	90                   	nop
  800894:	8b 45 08             	mov    0x8(%ebp),%eax
  800897:	8d 50 01             	lea    0x1(%eax),%edx
  80089a:	89 55 08             	mov    %edx,0x8(%ebp)
  80089d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8008a3:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8008a6:	0f b6 12             	movzbl (%edx),%edx
  8008a9:	88 10                	mov    %dl,(%eax)
  8008ab:	0f b6 00             	movzbl (%eax),%eax
  8008ae:	84 c0                	test   %al,%al
  8008b0:	75 e2                	jne    800894 <strcpy+0xd>
		/* do nothing */;
	return ret;
  8008b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008b5:	c9                   	leave  
  8008b6:	c3                   	ret    

008008b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	89 04 24             	mov    %eax,(%esp)
  8008c3:	e8 69 ff ff ff       	call   800831 <strlen>
  8008c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  8008cb:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	01 c2                	add    %eax,%edx
  8008d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008da:	89 14 24             	mov    %edx,(%esp)
  8008dd:	e8 a5 ff ff ff       	call   800887 <strcpy>
	return dst;
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8008e5:	c9                   	leave  
  8008e6:	c3                   	ret    

008008e7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8008f3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008fa:	eb 23                	jmp    80091f <strncpy+0x38>
		*dst++ = *src;
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ff:	8d 50 01             	lea    0x1(%eax),%edx
  800902:	89 55 08             	mov    %edx,0x8(%ebp)
  800905:	8b 55 0c             	mov    0xc(%ebp),%edx
  800908:	0f b6 12             	movzbl (%edx),%edx
  80090b:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  80090d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800910:	0f b6 00             	movzbl (%eax),%eax
  800913:	84 c0                	test   %al,%al
  800915:	74 04                	je     80091b <strncpy+0x34>
			src++;
  800917:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80091b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80091f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800922:	3b 45 10             	cmp    0x10(%ebp),%eax
  800925:	72 d5                	jb     8008fc <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800927:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80092a:	c9                   	leave  
  80092b:	c3                   	ret    

0080092c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800938:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80093c:	74 33                	je     800971 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80093e:	eb 17                	jmp    800957 <strlcpy+0x2b>
			*dst++ = *src++;
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8d 50 01             	lea    0x1(%eax),%edx
  800946:	89 55 08             	mov    %edx,0x8(%ebp)
  800949:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80094f:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800952:	0f b6 12             	movzbl (%edx),%edx
  800955:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800957:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80095b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80095f:	74 0a                	je     80096b <strlcpy+0x3f>
  800961:	8b 45 0c             	mov    0xc(%ebp),%eax
  800964:	0f b6 00             	movzbl (%eax),%eax
  800967:	84 c0                	test   %al,%al
  800969:	75 d5                	jne    800940 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
  80096e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800971:	8b 55 08             	mov    0x8(%ebp),%edx
  800974:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800977:	29 c2                	sub    %eax,%edx
  800979:	89 d0                	mov    %edx,%eax
}
  80097b:	c9                   	leave  
  80097c:	c3                   	ret    

0080097d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800980:	eb 08                	jmp    80098a <strcmp+0xd>
		p++, q++;
  800982:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800986:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	0f b6 00             	movzbl (%eax),%eax
  800990:	84 c0                	test   %al,%al
  800992:	74 10                	je     8009a4 <strcmp+0x27>
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	0f b6 10             	movzbl (%eax),%edx
  80099a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099d:	0f b6 00             	movzbl (%eax),%eax
  8009a0:	38 c2                	cmp    %al,%dl
  8009a2:	74 de                	je     800982 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	0f b6 00             	movzbl (%eax),%eax
  8009aa:	0f b6 d0             	movzbl %al,%edx
  8009ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b0:	0f b6 00             	movzbl (%eax),%eax
  8009b3:	0f b6 c0             	movzbl %al,%eax
  8009b6:	29 c2                	sub    %eax,%edx
  8009b8:	89 d0                	mov    %edx,%eax
}
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  8009bf:	eb 0c                	jmp    8009cd <strncmp+0x11>
		n--, p++, q++;
  8009c1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8009c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009c9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009cd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009d1:	74 1a                	je     8009ed <strncmp+0x31>
  8009d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d6:	0f b6 00             	movzbl (%eax),%eax
  8009d9:	84 c0                	test   %al,%al
  8009db:	74 10                	je     8009ed <strncmp+0x31>
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	0f b6 10             	movzbl (%eax),%edx
  8009e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e6:	0f b6 00             	movzbl (%eax),%eax
  8009e9:	38 c2                	cmp    %al,%dl
  8009eb:	74 d4                	je     8009c1 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  8009ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009f1:	75 07                	jne    8009fa <strncmp+0x3e>
		return 0;
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f8:	eb 16                	jmp    800a10 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	0f b6 00             	movzbl (%eax),%eax
  800a00:	0f b6 d0             	movzbl %al,%edx
  800a03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a06:	0f b6 00             	movzbl (%eax),%eax
  800a09:	0f b6 c0             	movzbl %al,%eax
  800a0c:	29 c2                	sub    %eax,%edx
  800a0e:	89 d0                	mov    %edx,%eax
}
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	83 ec 04             	sub    $0x4,%esp
  800a18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1b:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a1e:	eb 14                	jmp    800a34 <strchr+0x22>
		if (*s == c)
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	0f b6 00             	movzbl (%eax),%eax
  800a26:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a29:	75 05                	jne    800a30 <strchr+0x1e>
			return (char *) s;
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	eb 13                	jmp    800a43 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a30:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
  800a37:	0f b6 00             	movzbl (%eax),%eax
  800a3a:	84 c0                	test   %al,%al
  800a3c:	75 e2                	jne    800a20 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a43:	c9                   	leave  
  800a44:	c3                   	ret    

00800a45 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	83 ec 04             	sub    $0x4,%esp
  800a4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4e:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a51:	eb 11                	jmp    800a64 <strfind+0x1f>
		if (*s == c)
  800a53:	8b 45 08             	mov    0x8(%ebp),%eax
  800a56:	0f b6 00             	movzbl (%eax),%eax
  800a59:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a5c:	75 02                	jne    800a60 <strfind+0x1b>
			break;
  800a5e:	eb 0e                	jmp    800a6e <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a60:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	0f b6 00             	movzbl (%eax),%eax
  800a6a:	84 c0                	test   %al,%al
  800a6c:	75 e5                	jne    800a53 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a71:	c9                   	leave  
  800a72:	c3                   	ret    

00800a73 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	57                   	push   %edi
	char *p;

	if (n == 0)
  800a77:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a7b:	75 05                	jne    800a82 <memset+0xf>
		return v;
  800a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a80:	eb 5c                	jmp    800ade <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800a82:	8b 45 08             	mov    0x8(%ebp),%eax
  800a85:	83 e0 03             	and    $0x3,%eax
  800a88:	85 c0                	test   %eax,%eax
  800a8a:	75 41                	jne    800acd <memset+0x5a>
  800a8c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a8f:	83 e0 03             	and    $0x3,%eax
  800a92:	85 c0                	test   %eax,%eax
  800a94:	75 37                	jne    800acd <memset+0x5a>
		c &= 0xFF;
  800a96:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa0:	c1 e0 18             	shl    $0x18,%eax
  800aa3:	89 c2                	mov    %eax,%edx
  800aa5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa8:	c1 e0 10             	shl    $0x10,%eax
  800aab:	09 c2                	or     %eax,%edx
  800aad:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab0:	c1 e0 08             	shl    $0x8,%eax
  800ab3:	09 d0                	or     %edx,%eax
  800ab5:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ab8:	8b 45 10             	mov    0x10(%ebp),%eax
  800abb:	c1 e8 02             	shr    $0x2,%eax
  800abe:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ac0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac6:	89 d7                	mov    %edx,%edi
  800ac8:	fc                   	cld    
  800ac9:	f3 ab                	rep stos %eax,%es:(%edi)
  800acb:	eb 0e                	jmp    800adb <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800acd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ad6:	89 d7                	mov    %edx,%edi
  800ad8:	fc                   	cld    
  800ad9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800adb:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ade:	5f                   	pop    %edi
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
  800ae7:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800aea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aed:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800af0:	8b 45 08             	mov    0x8(%ebp),%eax
  800af3:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800af6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800af9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800afc:	73 6d                	jae    800b6b <memmove+0x8a>
  800afe:	8b 45 10             	mov    0x10(%ebp),%eax
  800b01:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b04:	01 d0                	add    %edx,%eax
  800b06:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b09:	76 60                	jbe    800b6b <memmove+0x8a>
		s += n;
  800b0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b0e:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800b11:	8b 45 10             	mov    0x10(%ebp),%eax
  800b14:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b1a:	83 e0 03             	and    $0x3,%eax
  800b1d:	85 c0                	test   %eax,%eax
  800b1f:	75 2f                	jne    800b50 <memmove+0x6f>
  800b21:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b24:	83 e0 03             	and    $0x3,%eax
  800b27:	85 c0                	test   %eax,%eax
  800b29:	75 25                	jne    800b50 <memmove+0x6f>
  800b2b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2e:	83 e0 03             	and    $0x3,%eax
  800b31:	85 c0                	test   %eax,%eax
  800b33:	75 1b                	jne    800b50 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b35:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b38:	83 e8 04             	sub    $0x4,%eax
  800b3b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b3e:	83 ea 04             	sub    $0x4,%edx
  800b41:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b44:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b47:	89 c7                	mov    %eax,%edi
  800b49:	89 d6                	mov    %edx,%esi
  800b4b:	fd                   	std    
  800b4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4e:	eb 18                	jmp    800b68 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b50:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b53:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b59:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5f:	89 d7                	mov    %edx,%edi
  800b61:	89 de                	mov    %ebx,%esi
  800b63:	89 c1                	mov    %eax,%ecx
  800b65:	fd                   	std    
  800b66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b68:	fc                   	cld    
  800b69:	eb 45                	jmp    800bb0 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b6e:	83 e0 03             	and    $0x3,%eax
  800b71:	85 c0                	test   %eax,%eax
  800b73:	75 2b                	jne    800ba0 <memmove+0xbf>
  800b75:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b78:	83 e0 03             	and    $0x3,%eax
  800b7b:	85 c0                	test   %eax,%eax
  800b7d:	75 21                	jne    800ba0 <memmove+0xbf>
  800b7f:	8b 45 10             	mov    0x10(%ebp),%eax
  800b82:	83 e0 03             	and    $0x3,%eax
  800b85:	85 c0                	test   %eax,%eax
  800b87:	75 17                	jne    800ba0 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b89:	8b 45 10             	mov    0x10(%ebp),%eax
  800b8c:	c1 e8 02             	shr    $0x2,%eax
  800b8f:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b91:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b94:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b97:	89 c7                	mov    %eax,%edi
  800b99:	89 d6                	mov    %edx,%esi
  800b9b:	fc                   	cld    
  800b9c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b9e:	eb 10                	jmp    800bb0 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ba0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ba3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ba6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ba9:	89 c7                	mov    %eax,%edi
  800bab:	89 d6                	mov    %edx,%esi
  800bad:	fc                   	cld    
  800bae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800bb0:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bb3:	83 c4 10             	add    $0x10,%esp
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bc1:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bcb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd2:	89 04 24             	mov    %eax,(%esp)
  800bd5:	e8 07 ff ff ff       	call   800ae1 <memmove>
}
  800bda:	c9                   	leave  
  800bdb:	c3                   	ret    

00800bdc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800be2:	8b 45 08             	mov    0x8(%ebp),%eax
  800be5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800be8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800beb:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800bee:	eb 30                	jmp    800c20 <memcmp+0x44>
		if (*s1 != *s2)
  800bf0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bf3:	0f b6 10             	movzbl (%eax),%edx
  800bf6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bf9:	0f b6 00             	movzbl (%eax),%eax
  800bfc:	38 c2                	cmp    %al,%dl
  800bfe:	74 18                	je     800c18 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800c00:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c03:	0f b6 00             	movzbl (%eax),%eax
  800c06:	0f b6 d0             	movzbl %al,%edx
  800c09:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c0c:	0f b6 00             	movzbl (%eax),%eax
  800c0f:	0f b6 c0             	movzbl %al,%eax
  800c12:	29 c2                	sub    %eax,%edx
  800c14:	89 d0                	mov    %edx,%eax
  800c16:	eb 1a                	jmp    800c32 <memcmp+0x56>
		s1++, s2++;
  800c18:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800c1c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c20:	8b 45 10             	mov    0x10(%ebp),%eax
  800c23:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c26:	89 55 10             	mov    %edx,0x10(%ebp)
  800c29:	85 c0                	test   %eax,%eax
  800c2b:	75 c3                	jne    800bf0 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c32:	c9                   	leave  
  800c33:	c3                   	ret    

00800c34 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c3a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c40:	01 d0                	add    %edx,%eax
  800c42:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c45:	eb 13                	jmp    800c5a <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c47:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4a:	0f b6 10             	movzbl (%eax),%edx
  800c4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c50:	38 c2                	cmp    %al,%dl
  800c52:	75 02                	jne    800c56 <memfind+0x22>
			break;
  800c54:	eb 0c                	jmp    800c62 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c56:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c60:	72 e5                	jb     800c47 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800c62:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c65:	c9                   	leave  
  800c66:	c3                   	ret    

00800c67 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800c6d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800c74:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c7b:	eb 04                	jmp    800c81 <strtol+0x1a>
		s++;
  800c7d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c81:	8b 45 08             	mov    0x8(%ebp),%eax
  800c84:	0f b6 00             	movzbl (%eax),%eax
  800c87:	3c 20                	cmp    $0x20,%al
  800c89:	74 f2                	je     800c7d <strtol+0x16>
  800c8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8e:	0f b6 00             	movzbl (%eax),%eax
  800c91:	3c 09                	cmp    $0x9,%al
  800c93:	74 e8                	je     800c7d <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c95:	8b 45 08             	mov    0x8(%ebp),%eax
  800c98:	0f b6 00             	movzbl (%eax),%eax
  800c9b:	3c 2b                	cmp    $0x2b,%al
  800c9d:	75 06                	jne    800ca5 <strtol+0x3e>
		s++;
  800c9f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ca3:	eb 15                	jmp    800cba <strtol+0x53>
	else if (*s == '-')
  800ca5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca8:	0f b6 00             	movzbl (%eax),%eax
  800cab:	3c 2d                	cmp    $0x2d,%al
  800cad:	75 0b                	jne    800cba <strtol+0x53>
		s++, neg = 1;
  800caf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cb3:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cba:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cbe:	74 06                	je     800cc6 <strtol+0x5f>
  800cc0:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800cc4:	75 24                	jne    800cea <strtol+0x83>
  800cc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc9:	0f b6 00             	movzbl (%eax),%eax
  800ccc:	3c 30                	cmp    $0x30,%al
  800cce:	75 1a                	jne    800cea <strtol+0x83>
  800cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd3:	83 c0 01             	add    $0x1,%eax
  800cd6:	0f b6 00             	movzbl (%eax),%eax
  800cd9:	3c 78                	cmp    $0x78,%al
  800cdb:	75 0d                	jne    800cea <strtol+0x83>
		s += 2, base = 16;
  800cdd:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800ce1:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800ce8:	eb 2a                	jmp    800d14 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800cea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cee:	75 17                	jne    800d07 <strtol+0xa0>
  800cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf3:	0f b6 00             	movzbl (%eax),%eax
  800cf6:	3c 30                	cmp    $0x30,%al
  800cf8:	75 0d                	jne    800d07 <strtol+0xa0>
		s++, base = 8;
  800cfa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cfe:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d05:	eb 0d                	jmp    800d14 <strtol+0xad>
	else if (base == 0)
  800d07:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d0b:	75 07                	jne    800d14 <strtol+0xad>
		base = 10;
  800d0d:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d14:	8b 45 08             	mov    0x8(%ebp),%eax
  800d17:	0f b6 00             	movzbl (%eax),%eax
  800d1a:	3c 2f                	cmp    $0x2f,%al
  800d1c:	7e 1b                	jle    800d39 <strtol+0xd2>
  800d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d21:	0f b6 00             	movzbl (%eax),%eax
  800d24:	3c 39                	cmp    $0x39,%al
  800d26:	7f 11                	jg     800d39 <strtol+0xd2>
			dig = *s - '0';
  800d28:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2b:	0f b6 00             	movzbl (%eax),%eax
  800d2e:	0f be c0             	movsbl %al,%eax
  800d31:	83 e8 30             	sub    $0x30,%eax
  800d34:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d37:	eb 48                	jmp    800d81 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800d39:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3c:	0f b6 00             	movzbl (%eax),%eax
  800d3f:	3c 60                	cmp    $0x60,%al
  800d41:	7e 1b                	jle    800d5e <strtol+0xf7>
  800d43:	8b 45 08             	mov    0x8(%ebp),%eax
  800d46:	0f b6 00             	movzbl (%eax),%eax
  800d49:	3c 7a                	cmp    $0x7a,%al
  800d4b:	7f 11                	jg     800d5e <strtol+0xf7>
			dig = *s - 'a' + 10;
  800d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d50:	0f b6 00             	movzbl (%eax),%eax
  800d53:	0f be c0             	movsbl %al,%eax
  800d56:	83 e8 57             	sub    $0x57,%eax
  800d59:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d5c:	eb 23                	jmp    800d81 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800d5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d61:	0f b6 00             	movzbl (%eax),%eax
  800d64:	3c 40                	cmp    $0x40,%al
  800d66:	7e 3d                	jle    800da5 <strtol+0x13e>
  800d68:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6b:	0f b6 00             	movzbl (%eax),%eax
  800d6e:	3c 5a                	cmp    $0x5a,%al
  800d70:	7f 33                	jg     800da5 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800d72:	8b 45 08             	mov    0x8(%ebp),%eax
  800d75:	0f b6 00             	movzbl (%eax),%eax
  800d78:	0f be c0             	movsbl %al,%eax
  800d7b:	83 e8 37             	sub    $0x37,%eax
  800d7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d84:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d87:	7c 02                	jl     800d8b <strtol+0x124>
			break;
  800d89:	eb 1a                	jmp    800da5 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800d8b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d8f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d92:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d96:	89 c2                	mov    %eax,%edx
  800d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d9b:	01 d0                	add    %edx,%eax
  800d9d:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800da0:	e9 6f ff ff ff       	jmp    800d14 <strtol+0xad>

	if (endptr)
  800da5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800da9:	74 08                	je     800db3 <strtol+0x14c>
		*endptr = (char *) s;
  800dab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dae:	8b 55 08             	mov    0x8(%ebp),%edx
  800db1:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800db3:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800db7:	74 07                	je     800dc0 <strtol+0x159>
  800db9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800dbc:	f7 d8                	neg    %eax
  800dbe:	eb 03                	jmp    800dc3 <strtol+0x15c>
  800dc0:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800dc3:	c9                   	leave  
  800dc4:	c3                   	ret    

00800dc5 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	57                   	push   %edi
  800dc9:	56                   	push   %esi
  800dca:	53                   	push   %ebx
  800dcb:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dce:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd1:	8b 55 10             	mov    0x10(%ebp),%edx
  800dd4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800dd7:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800dda:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800ddd:	8b 75 20             	mov    0x20(%ebp),%esi
  800de0:	cd 30                	int    $0x30
  800de2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800de9:	74 30                	je     800e1b <syscall+0x56>
  800deb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800def:	7e 2a                	jle    800e1b <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800df4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dff:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  800e06:	00 
  800e07:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e0e:	00 
  800e0f:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  800e16:	e8 2c 03 00 00       	call   801147 <_panic>

	return ret;
  800e1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800e1e:	83 c4 3c             	add    $0x3c,%esp
  800e21:	5b                   	pop    %ebx
  800e22:	5e                   	pop    %esi
  800e23:	5f                   	pop    %edi
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    

00800e26 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e36:	00 
  800e37:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e3e:	00 
  800e3f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e46:	00 
  800e47:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e4a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e52:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e59:	00 
  800e5a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e61:	e8 5f ff ff ff       	call   800dc5 <syscall>
}
  800e66:	c9                   	leave  
  800e67:	c3                   	ret    

00800e68 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800e6e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e75:	00 
  800e76:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e7d:	00 
  800e7e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e85:	00 
  800e86:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e8d:	00 
  800e8e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e95:	00 
  800e96:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e9d:	00 
  800e9e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800ea5:	e8 1b ff ff ff       	call   800dc5 <syscall>
}
  800eaa:	c9                   	leave  
  800eab:	c3                   	ret    

00800eac <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800eb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ebc:	00 
  800ebd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ec4:	00 
  800ec5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ecc:	00 
  800ecd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ed4:	00 
  800ed5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ed9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800ee0:	00 
  800ee1:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800ee8:	e8 d8 fe ff ff       	call   800dc5 <syscall>
}
  800eed:	c9                   	leave  
  800eee:	c3                   	ret    

00800eef <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800ef5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800efc:	00 
  800efd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f04:	00 
  800f05:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f0c:	00 
  800f0d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f14:	00 
  800f15:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f1c:	00 
  800f1d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f24:	00 
  800f25:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f2c:	e8 94 fe ff ff       	call   800dc5 <syscall>
}
  800f31:	c9                   	leave  
  800f32:	c3                   	ret    

00800f33 <sys_yield>:

void
sys_yield(void)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f39:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f40:	00 
  800f41:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f48:	00 
  800f49:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f50:	00 
  800f51:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f58:	00 
  800f59:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f60:	00 
  800f61:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f68:	00 
  800f69:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800f70:	e8 50 fe ff ff       	call   800dc5 <syscall>
}
  800f75:	c9                   	leave  
  800f76:	c3                   	ret    

00800f77 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f7d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f80:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f83:	8b 45 08             	mov    0x8(%ebp),%eax
  800f86:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f8d:	00 
  800f8e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f95:	00 
  800f96:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f9a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f9e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fa2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fa9:	00 
  800faa:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800fb1:	e8 0f fe ff ff       	call   800dc5 <syscall>
}
  800fb6:	c9                   	leave  
  800fb7:	c3                   	ret    

00800fb8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	56                   	push   %esi
  800fbc:	53                   	push   %ebx
  800fbd:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800fc0:	8b 75 18             	mov    0x18(%ebp),%esi
  800fc3:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800fc6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fc9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fcc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fcf:	89 74 24 18          	mov    %esi,0x18(%esp)
  800fd3:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800fd7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fdb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fdf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fe3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fea:	00 
  800feb:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  800ff2:	e8 ce fd ff ff       	call   800dc5 <syscall>
}
  800ff7:	83 c4 20             	add    $0x20,%esp
  800ffa:	5b                   	pop    %ebx
  800ffb:	5e                   	pop    %esi
  800ffc:	5d                   	pop    %ebp
  800ffd:	c3                   	ret    

00800ffe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801004:	8b 55 0c             	mov    0xc(%ebp),%edx
  801007:	8b 45 08             	mov    0x8(%ebp),%eax
  80100a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801011:	00 
  801012:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801019:	00 
  80101a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801021:	00 
  801022:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801026:	89 44 24 08          	mov    %eax,0x8(%esp)
  80102a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801031:	00 
  801032:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801039:	e8 87 fd ff ff       	call   800dc5 <syscall>
}
  80103e:	c9                   	leave  
  80103f:	c3                   	ret    

00801040 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801046:	8b 55 0c             	mov    0xc(%ebp),%edx
  801049:	8b 45 08             	mov    0x8(%ebp),%eax
  80104c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801053:	00 
  801054:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80105b:	00 
  80105c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801063:	00 
  801064:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801068:	89 44 24 08          	mov    %eax,0x8(%esp)
  80106c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801073:	00 
  801074:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  80107b:	e8 45 fd ff ff       	call   800dc5 <syscall>
}
  801080:	c9                   	leave  
  801081:	c3                   	ret    

00801082 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801088:	8b 55 0c             	mov    0xc(%ebp),%edx
  80108b:	8b 45 08             	mov    0x8(%ebp),%eax
  80108e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801095:	00 
  801096:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80109d:	00 
  80109e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010a5:	00 
  8010a6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010ae:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010b5:	00 
  8010b6:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8010bd:	e8 03 fd ff ff       	call   800dc5 <syscall>
}
  8010c2:	c9                   	leave  
  8010c3:	c3                   	ret    

008010c4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8010ca:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8010cd:	8b 55 10             	mov    0x10(%ebp),%edx
  8010d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d3:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010da:	00 
  8010db:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8010df:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010e6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010ee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010f5:	00 
  8010f6:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8010fd:	e8 c3 fc ff ff       	call   800dc5 <syscall>
}
  801102:	c9                   	leave  
  801103:	c3                   	ret    

00801104 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80110a:	8b 45 08             	mov    0x8(%ebp),%eax
  80110d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801114:	00 
  801115:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80111c:	00 
  80111d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801124:	00 
  801125:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80112c:	00 
  80112d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801131:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801138:	00 
  801139:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801140:	e8 80 fc ff ff       	call   800dc5 <syscall>
}
  801145:	c9                   	leave  
  801146:	c3                   	ret    

00801147 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	53                   	push   %ebx
  80114b:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80114e:	8d 45 14             	lea    0x14(%ebp),%eax
  801151:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801154:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80115a:	e8 90 fd ff ff       	call   800eef <sys_getenvid>
  80115f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801162:	89 54 24 10          	mov    %edx,0x10(%esp)
  801166:	8b 55 08             	mov    0x8(%ebp),%edx
  801169:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80116d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801171:	89 44 24 04          	mov    %eax,0x4(%esp)
  801175:	c7 04 24 f0 16 80 00 	movl   $0x8016f0,(%esp)
  80117c:	e8 00 f0 ff ff       	call   800181 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801181:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801184:	89 44 24 04          	mov    %eax,0x4(%esp)
  801188:	8b 45 10             	mov    0x10(%ebp),%eax
  80118b:	89 04 24             	mov    %eax,(%esp)
  80118e:	e8 8a ef ff ff       	call   80011d <vcprintf>
	cprintf("\n");
  801193:	c7 04 24 13 17 80 00 	movl   $0x801713,(%esp)
  80119a:	e8 e2 ef ff ff       	call   800181 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80119f:	cc                   	int3   
  8011a0:	eb fd                	jmp    80119f <_panic+0x58>
  8011a2:	66 90                	xchg   %ax,%ax
  8011a4:	66 90                	xchg   %ax,%ax
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
