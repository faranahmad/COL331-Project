
obj/user/spin:     file format elf32-i386


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
  80002c:	e8 7d 00 00 00       	call   8000ae <libmain>
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
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  800039:	c7 04 24 80 19 80 00 	movl   $0x801980,(%esp)
  800040:	e8 8b 01 00 00       	call   8001d0 <cprintf>
	if ((env = fork()) == 0) {
  800045:	e8 dd 13 00 00       	call   801427 <fork>
  80004a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80004d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800051:	75 0e                	jne    800061 <umain+0x2e>
		cprintf("I am the child.  Spinning...\n");
  800053:	c7 04 24 a8 19 80 00 	movl   $0x8019a8,(%esp)
  80005a:	e8 71 01 00 00       	call   8001d0 <cprintf>
		while (1)
			/* do nothing */;
  80005f:	eb fe                	jmp    80005f <umain+0x2c>
	}

	cprintf("I am the parent.  Running the child...\n");
  800061:	c7 04 24 c8 19 80 00 	movl   $0x8019c8,(%esp)
  800068:	e8 63 01 00 00       	call   8001d0 <cprintf>
	sys_yield();
  80006d:	e8 10 0f 00 00       	call   800f82 <sys_yield>
	sys_yield();
  800072:	e8 0b 0f 00 00       	call   800f82 <sys_yield>
	sys_yield();
  800077:	e8 06 0f 00 00       	call   800f82 <sys_yield>
	sys_yield();
  80007c:	e8 01 0f 00 00       	call   800f82 <sys_yield>
	sys_yield();
  800081:	e8 fc 0e 00 00       	call   800f82 <sys_yield>
	sys_yield();
  800086:	e8 f7 0e 00 00       	call   800f82 <sys_yield>
	sys_yield();
  80008b:	e8 f2 0e 00 00       	call   800f82 <sys_yield>
	sys_yield();
  800090:	e8 ed 0e 00 00       	call   800f82 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800095:	c7 04 24 f0 19 80 00 	movl   $0x8019f0,(%esp)
  80009c:	e8 2f 01 00 00       	call   8001d0 <cprintf>
	sys_env_destroy(env);
  8000a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000a4:	89 04 24             	mov    %eax,(%esp)
  8000a7:	e8 4f 0e 00 00       	call   800efb <sys_env_destroy>
}
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000b4:	e8 85 0e 00 00       	call   800f3e <sys_getenvid>
  8000b9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000be:	c1 e0 02             	shl    $0x2,%eax
  8000c1:	89 c2                	mov    %eax,%edx
  8000c3:	c1 e2 05             	shl    $0x5,%edx
  8000c6:	29 c2                	sub    %eax,%edx
  8000c8:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  8000ce:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000d7:	7e 0a                	jle    8000e3 <libmain+0x35>
		binaryname = argv[0];
  8000d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000dc:	8b 00                	mov    (%eax),%eax
  8000de:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8000ed:	89 04 24             	mov    %eax,(%esp)
  8000f0:	e8 3e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 02 00 00 00       	call   8000fc <exit>
}
  8000fa:	c9                   	leave  
  8000fb:	c3                   	ret    

008000fc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800102:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800109:	e8 ed 0d 00 00       	call   800efb <sys_env_destroy>
}
  80010e:	c9                   	leave  
  80010f:	c3                   	ret    

00800110 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800116:	8b 45 0c             	mov    0xc(%ebp),%eax
  800119:	8b 00                	mov    (%eax),%eax
  80011b:	8d 48 01             	lea    0x1(%eax),%ecx
  80011e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800121:	89 0a                	mov    %ecx,(%edx)
  800123:	8b 55 08             	mov    0x8(%ebp),%edx
  800126:	89 d1                	mov    %edx,%ecx
  800128:	8b 55 0c             	mov    0xc(%ebp),%edx
  80012b:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  80012f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800132:	8b 00                	mov    (%eax),%eax
  800134:	3d ff 00 00 00       	cmp    $0xff,%eax
  800139:	75 20                	jne    80015b <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  80013b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013e:	8b 00                	mov    (%eax),%eax
  800140:	8b 55 0c             	mov    0xc(%ebp),%edx
  800143:	83 c2 08             	add    $0x8,%edx
  800146:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014a:	89 14 24             	mov    %edx,(%esp)
  80014d:	e8 23 0d 00 00       	call   800e75 <sys_cputs>
		b->idx = 0;
  800152:	8b 45 0c             	mov    0xc(%ebp),%eax
  800155:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80015b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015e:	8b 40 04             	mov    0x4(%eax),%eax
  800161:	8d 50 01             	lea    0x1(%eax),%edx
  800164:	8b 45 0c             	mov    0xc(%ebp),%eax
  800167:	89 50 04             	mov    %edx,0x4(%eax)
}
  80016a:	c9                   	leave  
  80016b:	c3                   	ret    

0080016c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800175:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80017c:	00 00 00 
	b.cnt = 0;
  80017f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800186:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800189:	8b 45 0c             	mov    0xc(%ebp),%eax
  80018c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800190:	8b 45 08             	mov    0x8(%ebp),%eax
  800193:	89 44 24 08          	mov    %eax,0x8(%esp)
  800197:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80019d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a1:	c7 04 24 10 01 80 00 	movl   $0x800110,(%esp)
  8001a8:	e8 bd 01 00 00       	call   80036a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ad:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001bd:	83 c0 08             	add    $0x8,%eax
  8001c0:	89 04 24             	mov    %eax,(%esp)
  8001c3:	e8 ad 0c 00 00       	call   800e75 <sys_cputs>

	return b.cnt;
  8001c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8001ce:	c9                   	leave  
  8001cf:	c3                   	ret    

008001d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d6:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8001dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e6:	89 04 24             	mov    %eax,(%esp)
  8001e9:	e8 7e ff ff ff       	call   80016c <vcprintf>
  8001ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8001f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8001f4:	c9                   	leave  
  8001f5:	c3                   	ret    

008001f6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	53                   	push   %ebx
  8001fa:	83 ec 34             	sub    $0x34,%esp
  8001fd:	8b 45 10             	mov    0x10(%ebp),%eax
  800200:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800203:	8b 45 14             	mov    0x14(%ebp),%eax
  800206:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800209:	8b 45 18             	mov    0x18(%ebp),%eax
  80020c:	ba 00 00 00 00       	mov    $0x0,%edx
  800211:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800214:	77 72                	ja     800288 <printnum+0x92>
  800216:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800219:	72 05                	jb     800220 <printnum+0x2a>
  80021b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80021e:	77 68                	ja     800288 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800220:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800223:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800226:	8b 45 18             	mov    0x18(%ebp),%eax
  800229:	ba 00 00 00 00       	mov    $0x0,%edx
  80022e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800232:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800236:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800239:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80023c:	89 04 24             	mov    %eax,(%esp)
  80023f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800243:	e8 98 14 00 00       	call   8016e0 <__udivdi3>
  800248:	8b 4d 20             	mov    0x20(%ebp),%ecx
  80024b:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  80024f:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800253:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800256:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80025a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80025e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800262:	8b 45 0c             	mov    0xc(%ebp),%eax
  800265:	89 44 24 04          	mov    %eax,0x4(%esp)
  800269:	8b 45 08             	mov    0x8(%ebp),%eax
  80026c:	89 04 24             	mov    %eax,(%esp)
  80026f:	e8 82 ff ff ff       	call   8001f6 <printnum>
  800274:	eb 1c                	jmp    800292 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800276:	8b 45 0c             	mov    0xc(%ebp),%eax
  800279:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027d:	8b 45 20             	mov    0x20(%ebp),%eax
  800280:	89 04 24             	mov    %eax,(%esp)
  800283:	8b 45 08             	mov    0x8(%ebp),%eax
  800286:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800288:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  80028c:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800290:	7f e4                	jg     800276 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800292:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800295:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80029d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8002a0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002a4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002a8:	89 04 24             	mov    %eax,(%esp)
  8002ab:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002af:	e8 5c 15 00 00       	call   801810 <__umoddi3>
  8002b4:	05 08 1b 80 00       	add    $0x801b08,%eax
  8002b9:	0f b6 00             	movzbl (%eax),%eax
  8002bc:	0f be c0             	movsbl %al,%eax
  8002bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002c6:	89 04 24             	mov    %eax,(%esp)
  8002c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cc:	ff d0                	call   *%eax
}
  8002ce:	83 c4 34             	add    $0x34,%esp
  8002d1:	5b                   	pop    %ebx
  8002d2:	5d                   	pop    %ebp
  8002d3:	c3                   	ret    

008002d4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d7:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002db:	7e 14                	jle    8002f1 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8002dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e0:	8b 00                	mov    (%eax),%eax
  8002e2:	8d 48 08             	lea    0x8(%eax),%ecx
  8002e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e8:	89 0a                	mov    %ecx,(%edx)
  8002ea:	8b 50 04             	mov    0x4(%eax),%edx
  8002ed:	8b 00                	mov    (%eax),%eax
  8002ef:	eb 30                	jmp    800321 <getuint+0x4d>
	else if (lflag)
  8002f1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002f5:	74 16                	je     80030d <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8002f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fa:	8b 00                	mov    (%eax),%eax
  8002fc:	8d 48 04             	lea    0x4(%eax),%ecx
  8002ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800302:	89 0a                	mov    %ecx,(%edx)
  800304:	8b 00                	mov    (%eax),%eax
  800306:	ba 00 00 00 00       	mov    $0x0,%edx
  80030b:	eb 14                	jmp    800321 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  80030d:	8b 45 08             	mov    0x8(%ebp),%eax
  800310:	8b 00                	mov    (%eax),%eax
  800312:	8d 48 04             	lea    0x4(%eax),%ecx
  800315:	8b 55 08             	mov    0x8(%ebp),%edx
  800318:	89 0a                	mov    %ecx,(%edx)
  80031a:	8b 00                	mov    (%eax),%eax
  80031c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800326:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80032a:	7e 14                	jle    800340 <getint+0x1d>
		return va_arg(*ap, long long);
  80032c:	8b 45 08             	mov    0x8(%ebp),%eax
  80032f:	8b 00                	mov    (%eax),%eax
  800331:	8d 48 08             	lea    0x8(%eax),%ecx
  800334:	8b 55 08             	mov    0x8(%ebp),%edx
  800337:	89 0a                	mov    %ecx,(%edx)
  800339:	8b 50 04             	mov    0x4(%eax),%edx
  80033c:	8b 00                	mov    (%eax),%eax
  80033e:	eb 28                	jmp    800368 <getint+0x45>
	else if (lflag)
  800340:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800344:	74 12                	je     800358 <getint+0x35>
		return va_arg(*ap, long);
  800346:	8b 45 08             	mov    0x8(%ebp),%eax
  800349:	8b 00                	mov    (%eax),%eax
  80034b:	8d 48 04             	lea    0x4(%eax),%ecx
  80034e:	8b 55 08             	mov    0x8(%ebp),%edx
  800351:	89 0a                	mov    %ecx,(%edx)
  800353:	8b 00                	mov    (%eax),%eax
  800355:	99                   	cltd   
  800356:	eb 10                	jmp    800368 <getint+0x45>
	else
		return va_arg(*ap, int);
  800358:	8b 45 08             	mov    0x8(%ebp),%eax
  80035b:	8b 00                	mov    (%eax),%eax
  80035d:	8d 48 04             	lea    0x4(%eax),%ecx
  800360:	8b 55 08             	mov    0x8(%ebp),%edx
  800363:	89 0a                	mov    %ecx,(%edx)
  800365:	8b 00                	mov    (%eax),%eax
  800367:	99                   	cltd   
}
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	56                   	push   %esi
  80036e:	53                   	push   %ebx
  80036f:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800372:	eb 18                	jmp    80038c <vprintfmt+0x22>
			if (ch == '\0')
  800374:	85 db                	test   %ebx,%ebx
  800376:	75 05                	jne    80037d <vprintfmt+0x13>
				return;
  800378:	e9 05 04 00 00       	jmp    800782 <vprintfmt+0x418>
			putch(ch, putdat);
  80037d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800380:	89 44 24 04          	mov    %eax,0x4(%esp)
  800384:	89 1c 24             	mov    %ebx,(%esp)
  800387:	8b 45 08             	mov    0x8(%ebp),%eax
  80038a:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038c:	8b 45 10             	mov    0x10(%ebp),%eax
  80038f:	8d 50 01             	lea    0x1(%eax),%edx
  800392:	89 55 10             	mov    %edx,0x10(%ebp)
  800395:	0f b6 00             	movzbl (%eax),%eax
  800398:	0f b6 d8             	movzbl %al,%ebx
  80039b:	83 fb 25             	cmp    $0x25,%ebx
  80039e:	75 d4                	jne    800374 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8003a0:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8003a4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8003ab:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003b2:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8003b9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c3:	8d 50 01             	lea    0x1(%eax),%edx
  8003c6:	89 55 10             	mov    %edx,0x10(%ebp)
  8003c9:	0f b6 00             	movzbl (%eax),%eax
  8003cc:	0f b6 d8             	movzbl %al,%ebx
  8003cf:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8003d2:	83 f8 55             	cmp    $0x55,%eax
  8003d5:	0f 87 76 03 00 00    	ja     800751 <vprintfmt+0x3e7>
  8003db:	8b 04 85 2c 1b 80 00 	mov    0x801b2c(,%eax,4),%eax
  8003e2:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8003e4:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8003e8:	eb d6                	jmp    8003c0 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ea:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8003ee:	eb d0                	jmp    8003c0 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8003f7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003fa:	89 d0                	mov    %edx,%eax
  8003fc:	c1 e0 02             	shl    $0x2,%eax
  8003ff:	01 d0                	add    %edx,%eax
  800401:	01 c0                	add    %eax,%eax
  800403:	01 d8                	add    %ebx,%eax
  800405:	83 e8 30             	sub    $0x30,%eax
  800408:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  80040b:	8b 45 10             	mov    0x10(%ebp),%eax
  80040e:	0f b6 00             	movzbl (%eax),%eax
  800411:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800414:	83 fb 2f             	cmp    $0x2f,%ebx
  800417:	7e 0b                	jle    800424 <vprintfmt+0xba>
  800419:	83 fb 39             	cmp    $0x39,%ebx
  80041c:	7f 06                	jg     800424 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80041e:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800422:	eb d3                	jmp    8003f7 <vprintfmt+0x8d>
			goto process_precision;
  800424:	eb 33                	jmp    800459 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800426:	8b 45 14             	mov    0x14(%ebp),%eax
  800429:	8d 50 04             	lea    0x4(%eax),%edx
  80042c:	89 55 14             	mov    %edx,0x14(%ebp)
  80042f:	8b 00                	mov    (%eax),%eax
  800431:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800434:	eb 23                	jmp    800459 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800436:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80043a:	79 0c                	jns    800448 <vprintfmt+0xde>
				width = 0;
  80043c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800443:	e9 78 ff ff ff       	jmp    8003c0 <vprintfmt+0x56>
  800448:	e9 73 ff ff ff       	jmp    8003c0 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  80044d:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800454:	e9 67 ff ff ff       	jmp    8003c0 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800459:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80045d:	79 12                	jns    800471 <vprintfmt+0x107>
				width = precision, precision = -1;
  80045f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800462:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800465:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80046c:	e9 4f ff ff ff       	jmp    8003c0 <vprintfmt+0x56>
  800471:	e9 4a ff ff ff       	jmp    8003c0 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800476:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80047a:	e9 41 ff ff ff       	jmp    8003c0 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80047f:	8b 45 14             	mov    0x14(%ebp),%eax
  800482:	8d 50 04             	lea    0x4(%eax),%edx
  800485:	89 55 14             	mov    %edx,0x14(%ebp)
  800488:	8b 00                	mov    (%eax),%eax
  80048a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80048d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800491:	89 04 24             	mov    %eax,(%esp)
  800494:	8b 45 08             	mov    0x8(%ebp),%eax
  800497:	ff d0                	call   *%eax
			break;
  800499:	e9 de 02 00 00       	jmp    80077c <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80049e:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a1:	8d 50 04             	lea    0x4(%eax),%edx
  8004a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a7:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8004a9:	85 db                	test   %ebx,%ebx
  8004ab:	79 02                	jns    8004af <vprintfmt+0x145>
				err = -err;
  8004ad:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004af:	83 fb 09             	cmp    $0x9,%ebx
  8004b2:	7f 0b                	jg     8004bf <vprintfmt+0x155>
  8004b4:	8b 34 9d e0 1a 80 00 	mov    0x801ae0(,%ebx,4),%esi
  8004bb:	85 f6                	test   %esi,%esi
  8004bd:	75 23                	jne    8004e2 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8004bf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004c3:	c7 44 24 08 19 1b 80 	movl   $0x801b19,0x8(%esp)
  8004ca:	00 
  8004cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d5:	89 04 24             	mov    %eax,(%esp)
  8004d8:	e8 ac 02 00 00       	call   800789 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8004dd:	e9 9a 02 00 00       	jmp    80077c <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004e6:	c7 44 24 08 22 1b 80 	movl   $0x801b22,0x8(%esp)
  8004ed:	00 
  8004ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f8:	89 04 24             	mov    %eax,(%esp)
  8004fb:	e8 89 02 00 00       	call   800789 <printfmt>
			break;
  800500:	e9 77 02 00 00       	jmp    80077c <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800505:	8b 45 14             	mov    0x14(%ebp),%eax
  800508:	8d 50 04             	lea    0x4(%eax),%edx
  80050b:	89 55 14             	mov    %edx,0x14(%ebp)
  80050e:	8b 30                	mov    (%eax),%esi
  800510:	85 f6                	test   %esi,%esi
  800512:	75 05                	jne    800519 <vprintfmt+0x1af>
				p = "(null)";
  800514:	be 25 1b 80 00       	mov    $0x801b25,%esi
			if (width > 0 && padc != '-')
  800519:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80051d:	7e 37                	jle    800556 <vprintfmt+0x1ec>
  80051f:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800523:	74 31                	je     800556 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800525:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800528:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052c:	89 34 24             	mov    %esi,(%esp)
  80052f:	e8 72 03 00 00       	call   8008a6 <strnlen>
  800534:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800537:	eb 17                	jmp    800550 <vprintfmt+0x1e6>
					putch(padc, putdat);
  800539:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80053d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800540:	89 54 24 04          	mov    %edx,0x4(%esp)
  800544:	89 04 24             	mov    %eax,(%esp)
  800547:	8b 45 08             	mov    0x8(%ebp),%eax
  80054a:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80054c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800550:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800554:	7f e3                	jg     800539 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800556:	eb 38                	jmp    800590 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800558:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80055c:	74 1f                	je     80057d <vprintfmt+0x213>
  80055e:	83 fb 1f             	cmp    $0x1f,%ebx
  800561:	7e 05                	jle    800568 <vprintfmt+0x1fe>
  800563:	83 fb 7e             	cmp    $0x7e,%ebx
  800566:	7e 15                	jle    80057d <vprintfmt+0x213>
					putch('?', putdat);
  800568:	8b 45 0c             	mov    0xc(%ebp),%eax
  80056b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800576:	8b 45 08             	mov    0x8(%ebp),%eax
  800579:	ff d0                	call   *%eax
  80057b:	eb 0f                	jmp    80058c <vprintfmt+0x222>
				else
					putch(ch, putdat);
  80057d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800580:	89 44 24 04          	mov    %eax,0x4(%esp)
  800584:	89 1c 24             	mov    %ebx,(%esp)
  800587:	8b 45 08             	mov    0x8(%ebp),%eax
  80058a:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800590:	89 f0                	mov    %esi,%eax
  800592:	8d 70 01             	lea    0x1(%eax),%esi
  800595:	0f b6 00             	movzbl (%eax),%eax
  800598:	0f be d8             	movsbl %al,%ebx
  80059b:	85 db                	test   %ebx,%ebx
  80059d:	74 10                	je     8005af <vprintfmt+0x245>
  80059f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a3:	78 b3                	js     800558 <vprintfmt+0x1ee>
  8005a5:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005a9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ad:	79 a9                	jns    800558 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005af:	eb 17                	jmp    8005c8 <vprintfmt+0x25e>
				putch(' ', putdat);
  8005b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c2:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c4:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005cc:	7f e3                	jg     8005b1 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8005ce:	e9 a9 01 00 00       	jmp    80077c <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005da:	8d 45 14             	lea    0x14(%ebp),%eax
  8005dd:	89 04 24             	mov    %eax,(%esp)
  8005e0:	e8 3e fd ff ff       	call   800323 <getint>
  8005e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005e8:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8005eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005f1:	85 d2                	test   %edx,%edx
  8005f3:	79 26                	jns    80061b <vprintfmt+0x2b1>
				putch('-', putdat);
  8005f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800603:	8b 45 08             	mov    0x8(%ebp),%eax
  800606:	ff d0                	call   *%eax
				num = -(long long) num;
  800608:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80060b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80060e:	f7 d8                	neg    %eax
  800610:	83 d2 00             	adc    $0x0,%edx
  800613:	f7 da                	neg    %edx
  800615:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800618:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  80061b:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800622:	e9 e1 00 00 00       	jmp    800708 <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800627:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80062a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062e:	8d 45 14             	lea    0x14(%ebp),%eax
  800631:	89 04 24             	mov    %eax,(%esp)
  800634:	e8 9b fc ff ff       	call   8002d4 <getuint>
  800639:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80063c:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  80063f:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800646:	e9 bd 00 00 00       	jmp    800708 <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  80064b:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  800652:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800655:	89 44 24 04          	mov    %eax,0x4(%esp)
  800659:	8d 45 14             	lea    0x14(%ebp),%eax
  80065c:	89 04 24             	mov    %eax,(%esp)
  80065f:	e8 70 fc ff ff       	call   8002d4 <getuint>
  800664:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800667:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  80066a:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  80066e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800671:	89 54 24 18          	mov    %edx,0x18(%esp)
  800675:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800678:	89 54 24 14          	mov    %edx,0x14(%esp)
  80067c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800680:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800683:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800686:	89 44 24 08          	mov    %eax,0x8(%esp)
  80068a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80068e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800691:	89 44 24 04          	mov    %eax,0x4(%esp)
  800695:	8b 45 08             	mov    0x8(%ebp),%eax
  800698:	89 04 24             	mov    %eax,(%esp)
  80069b:	e8 56 fb ff ff       	call   8001f6 <printnum>
			break;
  8006a0:	e9 d7 00 00 00       	jmp    80077c <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  8006a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ac:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b6:	ff d0                	call   *%eax
			putch('x', putdat);
  8006b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006bf:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c9:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8d 50 04             	lea    0x4(%eax),%edx
  8006d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d4:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e0:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8006e7:	eb 1f                	jmp    800708 <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f3:	89 04 24             	mov    %eax,(%esp)
  8006f6:	e8 d9 fb ff ff       	call   8002d4 <getuint>
  8006fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006fe:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800701:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800708:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  80070c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070f:	89 54 24 18          	mov    %edx,0x18(%esp)
  800713:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800716:	89 54 24 14          	mov    %edx,0x14(%esp)
  80071a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80071e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800721:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800724:	89 44 24 08          	mov    %eax,0x8(%esp)
  800728:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80072c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800733:	8b 45 08             	mov    0x8(%ebp),%eax
  800736:	89 04 24             	mov    %eax,(%esp)
  800739:	e8 b8 fa ff ff       	call   8001f6 <printnum>
			break;
  80073e:	eb 3c                	jmp    80077c <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800740:	8b 45 0c             	mov    0xc(%ebp),%eax
  800743:	89 44 24 04          	mov    %eax,0x4(%esp)
  800747:	89 1c 24             	mov    %ebx,(%esp)
  80074a:	8b 45 08             	mov    0x8(%ebp),%eax
  80074d:	ff d0                	call   *%eax
			break;
  80074f:	eb 2b                	jmp    80077c <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800751:	8b 45 0c             	mov    0xc(%ebp),%eax
  800754:	89 44 24 04          	mov    %eax,0x4(%esp)
  800758:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80075f:	8b 45 08             	mov    0x8(%ebp),%eax
  800762:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800764:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800768:	eb 04                	jmp    80076e <vprintfmt+0x404>
  80076a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80076e:	8b 45 10             	mov    0x10(%ebp),%eax
  800771:	83 e8 01             	sub    $0x1,%eax
  800774:	0f b6 00             	movzbl (%eax),%eax
  800777:	3c 25                	cmp    $0x25,%al
  800779:	75 ef                	jne    80076a <vprintfmt+0x400>
				/* do nothing */;
			break;
  80077b:	90                   	nop
		}
	}
  80077c:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80077d:	e9 0a fc ff ff       	jmp    80038c <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800782:	83 c4 40             	add    $0x40,%esp
  800785:	5b                   	pop    %ebx
  800786:	5e                   	pop    %esi
  800787:	5d                   	pop    %ebp
  800788:	c3                   	ret    

00800789 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
  800792:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800795:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800798:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079c:	8b 45 10             	mov    0x10(%ebp),%eax
  80079f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ad:	89 04 24             	mov    %eax,(%esp)
  8007b0:	e8 b5 fb ff ff       	call   80036a <vprintfmt>
	va_end(ap);
}
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    

008007b7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  8007ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007bd:	8b 40 08             	mov    0x8(%eax),%eax
  8007c0:	8d 50 01             	lea    0x1(%eax),%edx
  8007c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c6:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  8007c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cc:	8b 10                	mov    (%eax),%edx
  8007ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d1:	8b 40 04             	mov    0x4(%eax),%eax
  8007d4:	39 c2                	cmp    %eax,%edx
  8007d6:	73 12                	jae    8007ea <sprintputch+0x33>
		*b->buf++ = ch;
  8007d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007db:	8b 00                	mov    (%eax),%eax
  8007dd:	8d 48 01             	lea    0x1(%eax),%ecx
  8007e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e3:	89 0a                	mov    %ecx,(%edx)
  8007e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8007e8:	88 10                	mov    %dl,(%eax)
}
  8007ea:	5d                   	pop    %ebp
  8007eb:	c3                   	ret    

008007ec <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007fb:	8d 50 ff             	lea    -0x1(%eax),%edx
  8007fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800801:	01 d0                	add    %edx,%eax
  800803:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800806:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80080d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800811:	74 06                	je     800819 <vsnprintf+0x2d>
  800813:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800817:	7f 07                	jg     800820 <vsnprintf+0x34>
		return -E_INVAL;
  800819:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80081e:	eb 2a                	jmp    80084a <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800820:	8b 45 14             	mov    0x14(%ebp),%eax
  800823:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800827:	8b 45 10             	mov    0x10(%ebp),%eax
  80082a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800831:	89 44 24 04          	mov    %eax,0x4(%esp)
  800835:	c7 04 24 b7 07 80 00 	movl   $0x8007b7,(%esp)
  80083c:	e8 29 fb ff ff       	call   80036a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800841:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800844:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800847:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80084a:	c9                   	leave  
  80084b:	c3                   	ret    

0080084c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800852:	8d 45 14             	lea    0x14(%ebp),%eax
  800855:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800858:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80085b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80085f:	8b 45 10             	mov    0x10(%ebp),%eax
  800862:	89 44 24 08          	mov    %eax,0x8(%esp)
  800866:	8b 45 0c             	mov    0xc(%ebp),%eax
  800869:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086d:	8b 45 08             	mov    0x8(%ebp),%eax
  800870:	89 04 24             	mov    %eax,(%esp)
  800873:	e8 74 ff ff ff       	call   8007ec <vsnprintf>
  800878:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  80087b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80087e:	c9                   	leave  
  80087f:	c3                   	ret    

00800880 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800886:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80088d:	eb 08                	jmp    800897 <strlen+0x17>
		n++;
  80088f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800893:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800897:	8b 45 08             	mov    0x8(%ebp),%eax
  80089a:	0f b6 00             	movzbl (%eax),%eax
  80089d:	84 c0                	test   %al,%al
  80089f:	75 ee                	jne    80088f <strlen+0xf>
		n++;
	return n;
  8008a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008a4:	c9                   	leave  
  8008a5:	c3                   	ret    

008008a6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ac:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008b3:	eb 0c                	jmp    8008c1 <strnlen+0x1b>
		n++;
  8008b5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8008bd:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  8008c1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008c5:	74 0a                	je     8008d1 <strnlen+0x2b>
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	0f b6 00             	movzbl (%eax),%eax
  8008cd:	84 c0                	test   %al,%al
  8008cf:	75 e4                	jne    8008b5 <strnlen+0xf>
		n++;
	return n;
  8008d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008d4:	c9                   	leave  
  8008d5:	c3                   	ret    

008008d6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  8008dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008df:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  8008e2:	90                   	nop
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	8d 50 01             	lea    0x1(%eax),%edx
  8008e9:	89 55 08             	mov    %edx,0x8(%ebp)
  8008ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ef:	8d 4a 01             	lea    0x1(%edx),%ecx
  8008f2:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8008f5:	0f b6 12             	movzbl (%edx),%edx
  8008f8:	88 10                	mov    %dl,(%eax)
  8008fa:	0f b6 00             	movzbl (%eax),%eax
  8008fd:	84 c0                	test   %al,%al
  8008ff:	75 e2                	jne    8008e3 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800901:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800904:	c9                   	leave  
  800905:	c3                   	ret    

00800906 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	89 04 24             	mov    %eax,(%esp)
  800912:	e8 69 ff ff ff       	call   800880 <strlen>
  800917:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  80091a:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	01 c2                	add    %eax,%edx
  800922:	8b 45 0c             	mov    0xc(%ebp),%eax
  800925:	89 44 24 04          	mov    %eax,0x4(%esp)
  800929:	89 14 24             	mov    %edx,(%esp)
  80092c:	e8 a5 ff ff ff       	call   8008d6 <strcpy>
	return dst;
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800934:	c9                   	leave  
  800935:	c3                   	ret    

00800936 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800942:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800949:	eb 23                	jmp    80096e <strncpy+0x38>
		*dst++ = *src;
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8d 50 01             	lea    0x1(%eax),%edx
  800951:	89 55 08             	mov    %edx,0x8(%ebp)
  800954:	8b 55 0c             	mov    0xc(%ebp),%edx
  800957:	0f b6 12             	movzbl (%edx),%edx
  80095a:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  80095c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095f:	0f b6 00             	movzbl (%eax),%eax
  800962:	84 c0                	test   %al,%al
  800964:	74 04                	je     80096a <strncpy+0x34>
			src++;
  800966:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80096a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80096e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800971:	3b 45 10             	cmp    0x10(%ebp),%eax
  800974:	72 d5                	jb     80094b <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800976:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800987:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80098b:	74 33                	je     8009c0 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80098d:	eb 17                	jmp    8009a6 <strlcpy+0x2b>
			*dst++ = *src++;
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	8d 50 01             	lea    0x1(%eax),%edx
  800995:	89 55 08             	mov    %edx,0x8(%ebp)
  800998:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80099e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009a1:	0f b6 12             	movzbl (%edx),%edx
  8009a4:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009a6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8009aa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009ae:	74 0a                	je     8009ba <strlcpy+0x3f>
  8009b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b3:	0f b6 00             	movzbl (%eax),%eax
  8009b6:	84 c0                	test   %al,%al
  8009b8:	75 d5                	jne    80098f <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8009c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009c6:	29 c2                	sub    %eax,%edx
  8009c8:	89 d0                	mov    %edx,%eax
}
  8009ca:	c9                   	leave  
  8009cb:	c3                   	ret    

008009cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  8009cf:	eb 08                	jmp    8009d9 <strcmp+0xd>
		p++, q++;
  8009d1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009d5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	0f b6 00             	movzbl (%eax),%eax
  8009df:	84 c0                	test   %al,%al
  8009e1:	74 10                	je     8009f3 <strcmp+0x27>
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	0f b6 10             	movzbl (%eax),%edx
  8009e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ec:	0f b6 00             	movzbl (%eax),%eax
  8009ef:	38 c2                	cmp    %al,%dl
  8009f1:	74 de                	je     8009d1 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	0f b6 00             	movzbl (%eax),%eax
  8009f9:	0f b6 d0             	movzbl %al,%edx
  8009fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ff:	0f b6 00             	movzbl (%eax),%eax
  800a02:	0f b6 c0             	movzbl %al,%eax
  800a05:	29 c2                	sub    %eax,%edx
  800a07:	89 d0                	mov    %edx,%eax
}
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a0e:	eb 0c                	jmp    800a1c <strncmp+0x11>
		n--, p++, q++;
  800a10:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a14:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a18:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a1c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a20:	74 1a                	je     800a3c <strncmp+0x31>
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	0f b6 00             	movzbl (%eax),%eax
  800a28:	84 c0                	test   %al,%al
  800a2a:	74 10                	je     800a3c <strncmp+0x31>
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	0f b6 10             	movzbl (%eax),%edx
  800a32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a35:	0f b6 00             	movzbl (%eax),%eax
  800a38:	38 c2                	cmp    %al,%dl
  800a3a:	74 d4                	je     800a10 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800a3c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a40:	75 07                	jne    800a49 <strncmp+0x3e>
		return 0;
  800a42:	b8 00 00 00 00       	mov    $0x0,%eax
  800a47:	eb 16                	jmp    800a5f <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	0f b6 00             	movzbl (%eax),%eax
  800a4f:	0f b6 d0             	movzbl %al,%edx
  800a52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a55:	0f b6 00             	movzbl (%eax),%eax
  800a58:	0f b6 c0             	movzbl %al,%eax
  800a5b:	29 c2                	sub    %eax,%edx
  800a5d:	89 d0                	mov    %edx,%eax
}
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	83 ec 04             	sub    $0x4,%esp
  800a67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6a:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a6d:	eb 14                	jmp    800a83 <strchr+0x22>
		if (*s == c)
  800a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a72:	0f b6 00             	movzbl (%eax),%eax
  800a75:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a78:	75 05                	jne    800a7f <strchr+0x1e>
			return (char *) s;
  800a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7d:	eb 13                	jmp    800a92 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a7f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	0f b6 00             	movzbl (%eax),%eax
  800a89:	84 c0                	test   %al,%al
  800a8b:	75 e2                	jne    800a6f <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a92:	c9                   	leave  
  800a93:	c3                   	ret    

00800a94 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	83 ec 04             	sub    $0x4,%esp
  800a9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9d:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800aa0:	eb 11                	jmp    800ab3 <strfind+0x1f>
		if (*s == c)
  800aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa5:	0f b6 00             	movzbl (%eax),%eax
  800aa8:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800aab:	75 02                	jne    800aaf <strfind+0x1b>
			break;
  800aad:	eb 0e                	jmp    800abd <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aaf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab6:	0f b6 00             	movzbl (%eax),%eax
  800ab9:	84 c0                	test   %al,%al
  800abb:	75 e5                	jne    800aa2 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800abd:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ac0:	c9                   	leave  
  800ac1:	c3                   	ret    

00800ac2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	57                   	push   %edi
	char *p;

	if (n == 0)
  800ac6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800aca:	75 05                	jne    800ad1 <memset+0xf>
		return v;
  800acc:	8b 45 08             	mov    0x8(%ebp),%eax
  800acf:	eb 5c                	jmp    800b2d <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad4:	83 e0 03             	and    $0x3,%eax
  800ad7:	85 c0                	test   %eax,%eax
  800ad9:	75 41                	jne    800b1c <memset+0x5a>
  800adb:	8b 45 10             	mov    0x10(%ebp),%eax
  800ade:	83 e0 03             	and    $0x3,%eax
  800ae1:	85 c0                	test   %eax,%eax
  800ae3:	75 37                	jne    800b1c <memset+0x5a>
		c &= 0xFF;
  800ae5:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aef:	c1 e0 18             	shl    $0x18,%eax
  800af2:	89 c2                	mov    %eax,%edx
  800af4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af7:	c1 e0 10             	shl    $0x10,%eax
  800afa:	09 c2                	or     %eax,%edx
  800afc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aff:	c1 e0 08             	shl    $0x8,%eax
  800b02:	09 d0                	or     %edx,%eax
  800b04:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b07:	8b 45 10             	mov    0x10(%ebp),%eax
  800b0a:	c1 e8 02             	shr    $0x2,%eax
  800b0d:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b15:	89 d7                	mov    %edx,%edi
  800b17:	fc                   	cld    
  800b18:	f3 ab                	rep stos %eax,%es:(%edi)
  800b1a:	eb 0e                	jmp    800b2a <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b22:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b25:	89 d7                	mov    %edx,%edi
  800b27:	fc                   	cld    
  800b28:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800b2a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
  800b36:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b42:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800b45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b48:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b4b:	73 6d                	jae    800bba <memmove+0x8a>
  800b4d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b50:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b53:	01 d0                	add    %edx,%eax
  800b55:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b58:	76 60                	jbe    800bba <memmove+0x8a>
		s += n;
  800b5a:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5d:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800b60:	8b 45 10             	mov    0x10(%ebp),%eax
  800b63:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b66:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b69:	83 e0 03             	and    $0x3,%eax
  800b6c:	85 c0                	test   %eax,%eax
  800b6e:	75 2f                	jne    800b9f <memmove+0x6f>
  800b70:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b73:	83 e0 03             	and    $0x3,%eax
  800b76:	85 c0                	test   %eax,%eax
  800b78:	75 25                	jne    800b9f <memmove+0x6f>
  800b7a:	8b 45 10             	mov    0x10(%ebp),%eax
  800b7d:	83 e0 03             	and    $0x3,%eax
  800b80:	85 c0                	test   %eax,%eax
  800b82:	75 1b                	jne    800b9f <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b84:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b87:	83 e8 04             	sub    $0x4,%eax
  800b8a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b8d:	83 ea 04             	sub    $0x4,%edx
  800b90:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b93:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b96:	89 c7                	mov    %eax,%edi
  800b98:	89 d6                	mov    %edx,%esi
  800b9a:	fd                   	std    
  800b9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b9d:	eb 18                	jmp    800bb7 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ba2:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ba5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ba8:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bab:	8b 45 10             	mov    0x10(%ebp),%eax
  800bae:	89 d7                	mov    %edx,%edi
  800bb0:	89 de                	mov    %ebx,%esi
  800bb2:	89 c1                	mov    %eax,%ecx
  800bb4:	fd                   	std    
  800bb5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bb7:	fc                   	cld    
  800bb8:	eb 45                	jmp    800bff <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bbd:	83 e0 03             	and    $0x3,%eax
  800bc0:	85 c0                	test   %eax,%eax
  800bc2:	75 2b                	jne    800bef <memmove+0xbf>
  800bc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bc7:	83 e0 03             	and    $0x3,%eax
  800bca:	85 c0                	test   %eax,%eax
  800bcc:	75 21                	jne    800bef <memmove+0xbf>
  800bce:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd1:	83 e0 03             	and    $0x3,%eax
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	75 17                	jne    800bef <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bd8:	8b 45 10             	mov    0x10(%ebp),%eax
  800bdb:	c1 e8 02             	shr    $0x2,%eax
  800bde:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800be0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800be3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800be6:	89 c7                	mov    %eax,%edi
  800be8:	89 d6                	mov    %edx,%esi
  800bea:	fc                   	cld    
  800beb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bed:	eb 10                	jmp    800bff <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bf2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bf5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bf8:	89 c7                	mov    %eax,%edi
  800bfa:	89 d6                	mov    %edx,%esi
  800bfc:	fc                   	cld    
  800bfd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800bff:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c02:	83 c4 10             	add    $0x10,%esp
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c10:	8b 45 10             	mov    0x10(%ebp),%eax
  800c13:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c21:	89 04 24             	mov    %eax,(%esp)
  800c24:	e8 07 ff ff ff       	call   800b30 <memmove>
}
  800c29:	c9                   	leave  
  800c2a:	c3                   	ret    

00800c2b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800c31:	8b 45 08             	mov    0x8(%ebp),%eax
  800c34:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800c37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3a:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800c3d:	eb 30                	jmp    800c6f <memcmp+0x44>
		if (*s1 != *s2)
  800c3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c42:	0f b6 10             	movzbl (%eax),%edx
  800c45:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c48:	0f b6 00             	movzbl (%eax),%eax
  800c4b:	38 c2                	cmp    %al,%dl
  800c4d:	74 18                	je     800c67 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800c4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c52:	0f b6 00             	movzbl (%eax),%eax
  800c55:	0f b6 d0             	movzbl %al,%edx
  800c58:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c5b:	0f b6 00             	movzbl (%eax),%eax
  800c5e:	0f b6 c0             	movzbl %al,%eax
  800c61:	29 c2                	sub    %eax,%edx
  800c63:	89 d0                	mov    %edx,%eax
  800c65:	eb 1a                	jmp    800c81 <memcmp+0x56>
		s1++, s2++;
  800c67:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800c6b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c6f:	8b 45 10             	mov    0x10(%ebp),%eax
  800c72:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c75:	89 55 10             	mov    %edx,0x10(%ebp)
  800c78:	85 c0                	test   %eax,%eax
  800c7a:	75 c3                	jne    800c3f <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c81:	c9                   	leave  
  800c82:	c3                   	ret    

00800c83 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c89:	8b 45 10             	mov    0x10(%ebp),%eax
  800c8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8f:	01 d0                	add    %edx,%eax
  800c91:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c94:	eb 13                	jmp    800ca9 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c96:	8b 45 08             	mov    0x8(%ebp),%eax
  800c99:	0f b6 10             	movzbl (%eax),%edx
  800c9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9f:	38 c2                	cmp    %al,%dl
  800ca1:	75 02                	jne    800ca5 <memfind+0x22>
			break;
  800ca3:	eb 0c                	jmp    800cb1 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ca5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ca9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cac:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800caf:	72 e5                	jb     800c96 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800cb1:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cb4:	c9                   	leave  
  800cb5:	c3                   	ret    

00800cb6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800cbc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800cc3:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cca:	eb 04                	jmp    800cd0 <strtol+0x1a>
		s++;
  800ccc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd3:	0f b6 00             	movzbl (%eax),%eax
  800cd6:	3c 20                	cmp    $0x20,%al
  800cd8:	74 f2                	je     800ccc <strtol+0x16>
  800cda:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdd:	0f b6 00             	movzbl (%eax),%eax
  800ce0:	3c 09                	cmp    $0x9,%al
  800ce2:	74 e8                	je     800ccc <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce7:	0f b6 00             	movzbl (%eax),%eax
  800cea:	3c 2b                	cmp    $0x2b,%al
  800cec:	75 06                	jne    800cf4 <strtol+0x3e>
		s++;
  800cee:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cf2:	eb 15                	jmp    800d09 <strtol+0x53>
	else if (*s == '-')
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf7:	0f b6 00             	movzbl (%eax),%eax
  800cfa:	3c 2d                	cmp    $0x2d,%al
  800cfc:	75 0b                	jne    800d09 <strtol+0x53>
		s++, neg = 1;
  800cfe:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d02:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d09:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d0d:	74 06                	je     800d15 <strtol+0x5f>
  800d0f:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800d13:	75 24                	jne    800d39 <strtol+0x83>
  800d15:	8b 45 08             	mov    0x8(%ebp),%eax
  800d18:	0f b6 00             	movzbl (%eax),%eax
  800d1b:	3c 30                	cmp    $0x30,%al
  800d1d:	75 1a                	jne    800d39 <strtol+0x83>
  800d1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d22:	83 c0 01             	add    $0x1,%eax
  800d25:	0f b6 00             	movzbl (%eax),%eax
  800d28:	3c 78                	cmp    $0x78,%al
  800d2a:	75 0d                	jne    800d39 <strtol+0x83>
		s += 2, base = 16;
  800d2c:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800d30:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800d37:	eb 2a                	jmp    800d63 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800d39:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d3d:	75 17                	jne    800d56 <strtol+0xa0>
  800d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d42:	0f b6 00             	movzbl (%eax),%eax
  800d45:	3c 30                	cmp    $0x30,%al
  800d47:	75 0d                	jne    800d56 <strtol+0xa0>
		s++, base = 8;
  800d49:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d4d:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d54:	eb 0d                	jmp    800d63 <strtol+0xad>
	else if (base == 0)
  800d56:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d5a:	75 07                	jne    800d63 <strtol+0xad>
		base = 10;
  800d5c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d63:	8b 45 08             	mov    0x8(%ebp),%eax
  800d66:	0f b6 00             	movzbl (%eax),%eax
  800d69:	3c 2f                	cmp    $0x2f,%al
  800d6b:	7e 1b                	jle    800d88 <strtol+0xd2>
  800d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d70:	0f b6 00             	movzbl (%eax),%eax
  800d73:	3c 39                	cmp    $0x39,%al
  800d75:	7f 11                	jg     800d88 <strtol+0xd2>
			dig = *s - '0';
  800d77:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7a:	0f b6 00             	movzbl (%eax),%eax
  800d7d:	0f be c0             	movsbl %al,%eax
  800d80:	83 e8 30             	sub    $0x30,%eax
  800d83:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d86:	eb 48                	jmp    800dd0 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800d88:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8b:	0f b6 00             	movzbl (%eax),%eax
  800d8e:	3c 60                	cmp    $0x60,%al
  800d90:	7e 1b                	jle    800dad <strtol+0xf7>
  800d92:	8b 45 08             	mov    0x8(%ebp),%eax
  800d95:	0f b6 00             	movzbl (%eax),%eax
  800d98:	3c 7a                	cmp    $0x7a,%al
  800d9a:	7f 11                	jg     800dad <strtol+0xf7>
			dig = *s - 'a' + 10;
  800d9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9f:	0f b6 00             	movzbl (%eax),%eax
  800da2:	0f be c0             	movsbl %al,%eax
  800da5:	83 e8 57             	sub    $0x57,%eax
  800da8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800dab:	eb 23                	jmp    800dd0 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800dad:	8b 45 08             	mov    0x8(%ebp),%eax
  800db0:	0f b6 00             	movzbl (%eax),%eax
  800db3:	3c 40                	cmp    $0x40,%al
  800db5:	7e 3d                	jle    800df4 <strtol+0x13e>
  800db7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dba:	0f b6 00             	movzbl (%eax),%eax
  800dbd:	3c 5a                	cmp    $0x5a,%al
  800dbf:	7f 33                	jg     800df4 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800dc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc4:	0f b6 00             	movzbl (%eax),%eax
  800dc7:	0f be c0             	movsbl %al,%eax
  800dca:	83 e8 37             	sub    $0x37,%eax
  800dcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dd3:	3b 45 10             	cmp    0x10(%ebp),%eax
  800dd6:	7c 02                	jl     800dda <strtol+0x124>
			break;
  800dd8:	eb 1a                	jmp    800df4 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800dda:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dde:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800de1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800de5:	89 c2                	mov    %eax,%edx
  800de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dea:	01 d0                	add    %edx,%eax
  800dec:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800def:	e9 6f ff ff ff       	jmp    800d63 <strtol+0xad>

	if (endptr)
  800df4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800df8:	74 08                	je     800e02 <strtol+0x14c>
		*endptr = (char *) s;
  800dfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800e00:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800e02:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e06:	74 07                	je     800e0f <strtol+0x159>
  800e08:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e0b:	f7 d8                	neg    %eax
  800e0d:	eb 03                	jmp    800e12 <strtol+0x15c>
  800e0f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800e12:	c9                   	leave  
  800e13:	c3                   	ret    

00800e14 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	57                   	push   %edi
  800e18:	56                   	push   %esi
  800e19:	53                   	push   %ebx
  800e1a:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e20:	8b 55 10             	mov    0x10(%ebp),%edx
  800e23:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800e26:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800e29:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800e2c:	8b 75 20             	mov    0x20(%ebp),%esi
  800e2f:	cd 30                	int    $0x30
  800e31:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e34:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e38:	74 30                	je     800e6a <syscall+0x56>
  800e3a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e3e:	7e 2a                	jle    800e6a <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e43:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e47:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e4e:	c7 44 24 08 84 1c 80 	movl   $0x801c84,0x8(%esp)
  800e55:	00 
  800e56:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e5d:	00 
  800e5e:	c7 04 24 a1 1c 80 00 	movl   $0x801ca1,(%esp)
  800e65:	e8 7f 07 00 00       	call   8015e9 <_panic>

	return ret;
  800e6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800e6d:	83 c4 3c             	add    $0x3c,%esp
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e85:	00 
  800e86:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e8d:	00 
  800e8e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e95:	00 
  800e96:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e99:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e9d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ea1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ea8:	00 
  800ea9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eb0:	e8 5f ff ff ff       	call   800e14 <syscall>
}
  800eb5:	c9                   	leave  
  800eb6:	c3                   	ret    

00800eb7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ebd:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ec4:	00 
  800ec5:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ecc:	00 
  800ecd:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ed4:	00 
  800ed5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800edc:	00 
  800edd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ee4:	00 
  800ee5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800eec:	00 
  800eed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800ef4:	e8 1b ff ff ff       	call   800e14 <syscall>
}
  800ef9:	c9                   	leave  
  800efa:	c3                   	ret    

00800efb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800f01:	8b 45 08             	mov    0x8(%ebp),%eax
  800f04:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f0b:	00 
  800f0c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f13:	00 
  800f14:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f1b:	00 
  800f1c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f23:	00 
  800f24:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f28:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f2f:	00 
  800f30:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800f37:	e8 d8 fe ff ff       	call   800e14 <syscall>
}
  800f3c:	c9                   	leave  
  800f3d:	c3                   	ret    

00800f3e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f3e:	55                   	push   %ebp
  800f3f:	89 e5                	mov    %esp,%ebp
  800f41:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800f44:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f4b:	00 
  800f4c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f53:	00 
  800f54:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f5b:	00 
  800f5c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f63:	00 
  800f64:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f6b:	00 
  800f6c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f73:	00 
  800f74:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f7b:	e8 94 fe ff ff       	call   800e14 <syscall>
}
  800f80:	c9                   	leave  
  800f81:	c3                   	ret    

00800f82 <sys_yield>:

void
sys_yield(void)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f88:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f8f:	00 
  800f90:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f97:	00 
  800f98:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f9f:	00 
  800fa0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fa7:	00 
  800fa8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800faf:	00 
  800fb0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fb7:	00 
  800fb8:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800fbf:	e8 50 fe ff ff       	call   800e14 <syscall>
}
  800fc4:	c9                   	leave  
  800fc5:	c3                   	ret    

00800fc6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800fcc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fcf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fdc:	00 
  800fdd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fe4:	00 
  800fe5:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fe9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fed:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ff1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800ff8:	00 
  800ff9:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  801000:	e8 0f fe ff ff       	call   800e14 <syscall>
}
  801005:	c9                   	leave  
  801006:	c3                   	ret    

00801007 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	56                   	push   %esi
  80100b:	53                   	push   %ebx
  80100c:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80100f:	8b 75 18             	mov    0x18(%ebp),%esi
  801012:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801015:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801018:	8b 55 0c             	mov    0xc(%ebp),%edx
  80101b:	8b 45 08             	mov    0x8(%ebp),%eax
  80101e:	89 74 24 18          	mov    %esi,0x18(%esp)
  801022:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  801026:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80102a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80102e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801032:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801039:	00 
  80103a:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  801041:	e8 ce fd ff ff       	call   800e14 <syscall>
}
  801046:	83 c4 20             	add    $0x20,%esp
  801049:	5b                   	pop    %ebx
  80104a:	5e                   	pop    %esi
  80104b:	5d                   	pop    %ebp
  80104c:	c3                   	ret    

0080104d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801053:	8b 55 0c             	mov    0xc(%ebp),%edx
  801056:	8b 45 08             	mov    0x8(%ebp),%eax
  801059:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801060:	00 
  801061:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801068:	00 
  801069:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801070:	00 
  801071:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801075:	89 44 24 08          	mov    %eax,0x8(%esp)
  801079:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801080:	00 
  801081:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801088:	e8 87 fd ff ff       	call   800e14 <syscall>
}
  80108d:	c9                   	leave  
  80108e:	c3                   	ret    

0080108f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
  801092:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801095:	8b 55 0c             	mov    0xc(%ebp),%edx
  801098:	8b 45 08             	mov    0x8(%ebp),%eax
  80109b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010a2:	00 
  8010a3:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010aa:	00 
  8010ab:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010b2:	00 
  8010b3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010bb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010c2:	00 
  8010c3:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8010ca:	e8 45 fd ff ff       	call   800e14 <syscall>
}
  8010cf:	c9                   	leave  
  8010d0:	c3                   	ret    

008010d1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8010d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010da:	8b 45 08             	mov    0x8(%ebp),%eax
  8010dd:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010e4:	00 
  8010e5:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010ec:	00 
  8010ed:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010f4:	00 
  8010f5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010fd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801104:	00 
  801105:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  80110c:	e8 03 fd ff ff       	call   800e14 <syscall>
}
  801111:	c9                   	leave  
  801112:	c3                   	ret    

00801113 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801113:	55                   	push   %ebp
  801114:	89 e5                	mov    %esp,%ebp
  801116:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801119:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80111c:	8b 55 10             	mov    0x10(%ebp),%edx
  80111f:	8b 45 08             	mov    0x8(%ebp),%eax
  801122:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801129:	00 
  80112a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80112e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801132:	8b 55 0c             	mov    0xc(%ebp),%edx
  801135:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801139:	89 44 24 08          	mov    %eax,0x8(%esp)
  80113d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801144:	00 
  801145:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  80114c:	e8 c3 fc ff ff       	call   800e14 <syscall>
}
  801151:	c9                   	leave  
  801152:	c3                   	ret    

00801153 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801159:	8b 45 08             	mov    0x8(%ebp),%eax
  80115c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801163:	00 
  801164:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80116b:	00 
  80116c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801173:	00 
  801174:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80117b:	00 
  80117c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801180:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801187:	00 
  801188:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80118f:	e8 80 fc ff ff       	call   800e14 <syscall>
}
  801194:	c9                   	leave  
  801195:	c3                   	ret    

00801196 <pgfault>:
// map in our own private writable copy.
//

static void
pgfault(struct UTrapframe *utf)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  80119c:	8b 45 08             	mov    0x8(%ebp),%eax
  80119f:	8b 00                	mov    (%eax),%eax
  8011a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  8011a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a7:	8b 40 04             	mov    0x4(%eax),%eax
  8011aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	uint32_t t = PGNUM(addr);
  8011ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b0:	c1 e8 0c             	shr    $0xc,%eax
  8011b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
	pte_t pte = uvpt[t];
  8011b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8011b9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011c0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  8011c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c6:	83 e0 02             	and    $0x2,%eax
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	74 0c                	je     8011d9 <pgfault+0x43>
  8011cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8011d0:	25 00 08 00 00       	and    $0x800,%eax
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	75 1c                	jne    8011f5 <pgfault+0x5f>
		panic("permission denied in copy on write pgfault handler\n");
  8011d9:	c7 44 24 08 b0 1c 80 	movl   $0x801cb0,0x8(%esp)
  8011e0:	00 
  8011e1:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8011e8:	00 
  8011e9:	c7 04 24 e4 1c 80 00 	movl   $0x801ce4,(%esp)
  8011f0:	e8 f4 03 00 00       	call   8015e9 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	r = sys_page_alloc(0,PFTEMP,PTE_P|PTE_U|PTE_W);
  8011f5:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011fc:	00 
  8011fd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801204:	00 
  801205:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80120c:	e8 b5 fd ff ff       	call   800fc6 <sys_page_alloc>
  801211:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if(r < 0)
  801214:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801218:	79 1c                	jns    801236 <pgfault+0xa0>
	{
		panic("page cant be allocated\n");
  80121a:	c7 44 24 08 ef 1c 80 	movl   $0x801cef,0x8(%esp)
  801221:	00 
  801222:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  801229:	00 
  80122a:	c7 04 24 e4 1c 80 00 	movl   $0x801ce4,(%esp)
  801231:	e8 b3 03 00 00       	call   8015e9 <_panic>
	}
	memmove(PFTEMP, ROUNDDOWN(addr,PGSIZE), PGSIZE);
  801236:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801239:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80123c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80123f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801244:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80124b:	00 
  80124c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801250:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801257:	e8 d4 f8 ff ff       	call   800b30 <memmove>
	int r1 = sys_page_map(0,PFTEMP,0,ROUNDDOWN(addr,PGSIZE),PTE_W|PTE_U|PTE_P);
  80125c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80125f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801262:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801265:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80126a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801271:	00 
  801272:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801276:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80127d:	00 
  80127e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801285:	00 
  801286:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80128d:	e8 75 fd ff ff       	call   801007 <sys_page_map>
  801292:	89 45 d8             	mov    %eax,-0x28(%ebp)
	if(r1 < 0)
  801295:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801299:	79 1c                	jns    8012b7 <pgfault+0x121>
	{
		panic("page cant be mapped\n");
  80129b:	c7 44 24 08 07 1d 80 	movl   $0x801d07,0x8(%esp)
  8012a2:	00 
  8012a3:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  8012aa:	00 
  8012ab:	c7 04 24 e4 1c 80 00 	movl   $0x801ce4,(%esp)
  8012b2:	e8 32 03 00 00       	call   8015e9 <_panic>
	}	

	// panic("pgfault not implemented");
}
  8012b7:	c9                   	leave  
  8012b8:	c3                   	ret    

008012b9 <duppage>:
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
static int
duppage(envid_t envid, unsigned pn)
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	83 ec 48             	sub    $0x48,%esp
	int r;
	
	// LAB 4: Your code here.
	uint32_t t = uvpt[pn];
  8012bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
	void *va_pn = (void *)(pn*PGSIZE);
  8012cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012cf:	c1 e0 0c             	shl    $0xc,%eax
  8012d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if((t && PTE_W) || (t && PTE_COW))
  8012d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8012d9:	75 0a                	jne    8012e5 <duppage+0x2c>
  8012db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8012df:	0f 84 ed 00 00 00    	je     8013d2 <duppage+0x119>
	{
		r = sys_page_map(0,va_pn,envid,va_pn,PTE_P|PTE_U|PTE_COW);
  8012e5:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8012ec:	00 
  8012ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801302:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801309:	e8 f9 fc ff ff       	call   801007 <sys_page_map>
  80130e:	89 45 e8             	mov    %eax,-0x18(%ebp)
		if(r < 0)
  801311:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801315:	79 1c                	jns    801333 <duppage+0x7a>
		{
			panic("error in page map\n");
  801317:	c7 44 24 08 1c 1d 80 	movl   $0x801d1c,0x8(%esp)
  80131e:	00 
  80131f:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  801326:	00 
  801327:	c7 04 24 e4 1c 80 00 	movl   $0x801ce4,(%esp)
  80132e:	e8 b6 02 00 00       	call   8015e9 <_panic>
		}
		int r1 = sys_page_map(envid,va_pn,0,va_pn,PTE_P|PTE_U|PTE_COW);
  801333:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80133a:	00 
  80133b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801342:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801349:	00 
  80134a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801351:	8b 45 08             	mov    0x8(%ebp),%eax
  801354:	89 04 24             	mov    %eax,(%esp)
  801357:	e8 ab fc ff ff       	call   801007 <sys_page_map>
  80135c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if(r1 < 0)
  80135f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801363:	79 1c                	jns    801381 <duppage+0xc8>
		{
			panic("error in page map\n");
  801365:	c7 44 24 08 1c 1d 80 	movl   $0x801d1c,0x8(%esp)
  80136c:	00 
  80136d:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801374:	00 
  801375:	c7 04 24 e4 1c 80 00 	movl   $0x801ce4,(%esp)
  80137c:	e8 68 02 00 00       	call   8015e9 <_panic>
		}
		int r2 = sys_page_map(0,va_pn,0,va_pn,PTE_P|PTE_U|PTE_COW);
  801381:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801388:	00 
  801389:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801390:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801397:	00 
  801398:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013a6:	e8 5c fc ff ff       	call   801007 <sys_page_map>
  8013ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
		if(r2 < 0)
  8013ae:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013b2:	79 1c                	jns    8013d0 <duppage+0x117>
		{
			panic("error in page map\n");
  8013b4:	c7 44 24 08 1c 1d 80 	movl   $0x801d1c,0x8(%esp)
  8013bb:	00 
  8013bc:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  8013c3:	00 
  8013c4:	c7 04 24 e4 1c 80 00 	movl   $0x801ce4,(%esp)
  8013cb:	e8 19 02 00 00       	call   8015e9 <_panic>
	
	// LAB 4: Your code here.
	uint32_t t = uvpt[pn];
	void *va_pn = (void *)(pn*PGSIZE);
	if((t && PTE_W) || (t && PTE_COW))
	{
  8013d0:	eb 4e                	jmp    801420 <duppage+0x167>
			panic("error in page map\n");
		}
	}
	else
	{
		int r3 = sys_page_map(0,va_pn,envid,va_pn,PTE_U|PTE_P);
  8013d2:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8013d9:	00 
  8013da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013f6:	e8 0c fc ff ff       	call   801007 <sys_page_map>
  8013fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if(r3 < 0)
  8013fe:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801402:	79 1c                	jns    801420 <duppage+0x167>
		{
			panic("error in page map\n");
  801404:	c7 44 24 08 1c 1d 80 	movl   $0x801d1c,0x8(%esp)
  80140b:	00 
  80140c:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  801413:	00 
  801414:	c7 04 24 e4 1c 80 00 	movl   $0x801ce4,(%esp)
  80141b:	e8 c9 01 00 00       	call   8015e9 <_panic>
		}
	}
	// panic("duppage not implemented");
	return 0;
  801420:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801425:	c9                   	leave  
  801426:	c3                   	ret    

00801427 <fork>:


envid_t
fork(void)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	83 ec 38             	sub    $0x38,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80142d:	c7 04 24 96 11 80 00 	movl   $0x801196,(%esp)
  801434:	e8 0b 02 00 00       	call   801644 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801439:	b8 07 00 00 00       	mov    $0x7,%eax
  80143e:	cd 30                	int    $0x30
  801440:	89 45 e0             	mov    %eax,-0x20(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  801443:	8b 45 e0             	mov    -0x20(%ebp),%eax
	envid_t envid = sys_exofork();
  801446:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (envid < 0)
  801449:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80144d:	79 1c                	jns    80146b <fork+0x44>
	{
		panic("sys_exofork not succeeded\n");
  80144f:	c7 44 24 08 2f 1d 80 	movl   $0x801d2f,0x8(%esp)
  801456:	00 
  801457:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
  80145e:	00 
  80145f:	c7 04 24 e4 1c 80 00 	movl   $0x801ce4,(%esp)
  801466:	e8 7e 01 00 00       	call   8015e9 <_panic>
	}
	if (envid == 0)
  80146b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80146f:	75 29                	jne    80149a <fork+0x73>
	{	
		thisenv = &envs[ENVX(sys_getenvid())];
  801471:	e8 c8 fa ff ff       	call   800f3e <sys_getenvid>
  801476:	25 ff 03 00 00       	and    $0x3ff,%eax
  80147b:	c1 e0 02             	shl    $0x2,%eax
  80147e:	89 c2                	mov    %eax,%edx
  801480:	c1 e2 05             	shl    $0x5,%edx
  801483:	29 c2                	sub    %eax,%edx
  801485:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  80148b:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  801490:	b8 00 00 00 00       	mov    $0x0,%eax
  801495:	e9 2b 01 00 00       	jmp    8015c5 <fork+0x19e>
	}
	else
	{
		int p;
		for (p = 0; p < PGNUM(UTOP); p++) 
  80149a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  8014a1:	e9 9a 00 00 00       	jmp    801540 <fork+0x119>
		{
			if(p == PGNUM(UTOP) - 1)
  8014a6:	81 7d f4 ff eb 0e 00 	cmpl   $0xeebff,-0xc(%ebp)
  8014ad:	75 42                	jne    8014f1 <fork+0xca>
			{
				int r1 = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE), PTE_P|PTE_W|PTE_U);
  8014af:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8014b6:	00 
  8014b7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8014be:	ee 
  8014bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c2:	89 04 24             	mov    %eax,(%esp)
  8014c5:	e8 fc fa ff ff       	call   800fc6 <sys_page_alloc>
  8014ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  				if(r1 < 0)
  8014cd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8014d1:	79 1c                	jns    8014ef <fork+0xc8>
  				{
    				panic("sys_page_alloc failed\n");
  8014d3:	c7 44 24 08 4a 1d 80 	movl   $0x801d4a,0x8(%esp)
  8014da:	00 
  8014db:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  8014e2:	00 
  8014e3:	c7 04 24 e4 1c 80 00 	movl   $0x801ce4,(%esp)
  8014ea:	e8 fa 00 00 00       	call   8015e9 <_panic>
				}
				break;
  8014ef:	eb 5d                	jmp    80154e <fork+0x127>
			}
			if((uvpd[PDX(p*PGSIZE)]&PTE_P))
  8014f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f4:	c1 e0 0c             	shl    $0xc,%eax
  8014f7:	c1 e8 16             	shr    $0x16,%eax
  8014fa:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801501:	83 e0 01             	and    $0x1,%eax
  801504:	85 c0                	test   %eax,%eax
  801506:	74 34                	je     80153c <fork+0x115>
			{
				if((uvpt[p]&PTE_P) && (uvpt[p] & PTE_U))
  801508:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80150b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801512:	83 e0 01             	and    $0x1,%eax
  801515:	85 c0                	test   %eax,%eax
  801517:	74 23                	je     80153c <fork+0x115>
  801519:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801523:	83 e0 04             	and    $0x4,%eax
  801526:	85 c0                	test   %eax,%eax
  801528:	74 12                	je     80153c <fork+0x115>
				{
					duppage(envid, p);
  80152a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80152d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801531:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801534:	89 04 24             	mov    %eax,(%esp)
  801537:	e8 7d fd ff ff       	call   8012b9 <duppage>
		return 0;
	}
	else
	{
		int p;
		for (p = 0; p < PGNUM(UTOP); p++) 
  80153c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  801540:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801543:	3d ff eb 0e 00       	cmp    $0xeebff,%eax
  801548:	0f 86 58 ff ff ff    	jbe    8014a6 <fork+0x7f>
				}
			}	
		}
  		
		extern void _pgfault_upcall();
		int r = sys_env_set_pgfault_upcall(envid,thisenv->env_pgfault_upcall);
  80154e:	a1 04 20 80 00       	mov    0x802004,%eax
  801553:	8b 40 64             	mov    0x64(%eax),%eax
  801556:	89 44 24 04          	mov    %eax,0x4(%esp)
  80155a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155d:	89 04 24             	mov    %eax,(%esp)
  801560:	e8 6c fb ff ff       	call   8010d1 <sys_env_set_pgfault_upcall>
  801565:	89 45 e8             	mov    %eax,-0x18(%ebp)
    	if(r < 0)
  801568:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80156c:	79 1c                	jns    80158a <fork+0x163>
    	{
    		panic("sys_env_set_pgfault_upcall failed\n");
  80156e:	c7 44 24 08 64 1d 80 	movl   $0x801d64,0x8(%esp)
  801575:	00 
  801576:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  80157d:	00 
  80157e:	c7 04 24 e4 1c 80 00 	movl   $0x801ce4,(%esp)
  801585:	e8 5f 00 00 00       	call   8015e9 <_panic>
    	}
  		int r2 = sys_env_set_status(envid, ENV_RUNNABLE);
  80158a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801591:	00 
  801592:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801595:	89 04 24             	mov    %eax,(%esp)
  801598:	e8 f2 fa ff ff       	call   80108f <sys_env_set_status>
  80159d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  		if(r2 < 0)
  8015a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8015a4:	79 1c                	jns    8015c2 <fork+0x19b>
  		{
    		panic("sys_env_set_status failes\n");
  8015a6:	c7 44 24 08 87 1d 80 	movl   $0x801d87,0x8(%esp)
  8015ad:	00 
  8015ae:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  8015b5:	00 
  8015b6:	c7 04 24 e4 1c 80 00 	movl   $0x801ce4,(%esp)
  8015bd:	e8 27 00 00 00       	call   8015e9 <_panic>
    	}
  		return envid;
  8015c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
	}


	// panic("fork not implemented");
}
  8015c5:	c9                   	leave  
  8015c6:	c3                   	ret    

008015c7 <sfork>:


// Challenge!
int
sfork(void)
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8015cd:	c7 44 24 08 a2 1d 80 	movl   $0x801da2,0x8(%esp)
  8015d4:	00 
  8015d5:	c7 44 24 04 a8 00 00 	movl   $0xa8,0x4(%esp)
  8015dc:	00 
  8015dd:	c7 04 24 e4 1c 80 00 	movl   $0x801ce4,(%esp)
  8015e4:	e8 00 00 00 00       	call   8015e9 <_panic>

008015e9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8015e9:	55                   	push   %ebp
  8015ea:	89 e5                	mov    %esp,%ebp
  8015ec:	53                   	push   %ebx
  8015ed:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8015f0:	8d 45 14             	lea    0x14(%ebp),%eax
  8015f3:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8015f6:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8015fc:	e8 3d f9 ff ff       	call   800f3e <sys_getenvid>
  801601:	8b 55 0c             	mov    0xc(%ebp),%edx
  801604:	89 54 24 10          	mov    %edx,0x10(%esp)
  801608:	8b 55 08             	mov    0x8(%ebp),%edx
  80160b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80160f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801613:	89 44 24 04          	mov    %eax,0x4(%esp)
  801617:	c7 04 24 b8 1d 80 00 	movl   $0x801db8,(%esp)
  80161e:	e8 ad eb ff ff       	call   8001d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801623:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801626:	89 44 24 04          	mov    %eax,0x4(%esp)
  80162a:	8b 45 10             	mov    0x10(%ebp),%eax
  80162d:	89 04 24             	mov    %eax,(%esp)
  801630:	e8 37 eb ff ff       	call   80016c <vcprintf>
	cprintf("\n");
  801635:	c7 04 24 db 1d 80 00 	movl   $0x801ddb,(%esp)
  80163c:	e8 8f eb ff ff       	call   8001d0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801641:	cc                   	int3   
  801642:	eb fd                	jmp    801641 <_panic+0x58>

00801644 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  80164a:	a1 08 20 80 00       	mov    0x802008,%eax
  80164f:	85 c0                	test   %eax,%eax
  801651:	75 55                	jne    8016a8 <set_pgfault_handler+0x64>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE),PTE_U|PTE_P|PTE_W);
  801653:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80165a:	00 
  80165b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801662:	ee 
  801663:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80166a:	e8 57 f9 ff ff       	call   800fc6 <sys_page_alloc>
  80166f:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(r < 0)
  801672:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801676:	79 1c                	jns    801694 <set_pgfault_handler+0x50>
		{
			panic("sys_page_alloc_failed");
  801678:	c7 44 24 08 dd 1d 80 	movl   $0x801ddd,0x8(%esp)
  80167f:	00 
  801680:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801687:	00 
  801688:	c7 04 24 f3 1d 80 00 	movl   $0x801df3,(%esp)
  80168f:	e8 55 ff ff ff       	call   8015e9 <_panic>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801694:	c7 44 24 04 b2 16 80 	movl   $0x8016b2,0x4(%esp)
  80169b:	00 
  80169c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016a3:	e8 29 fa ff ff       	call   8010d1 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8016a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ab:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8016b0:	c9                   	leave  
  8016b1:	c3                   	ret    

008016b2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8016b2:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8016b3:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8016b8:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8016ba:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x30(%esp), %eax
  8016bd:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  8016c1:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8016c4:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 0x28(%esp), %ecx
  8016c8:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	movl %ecx, (%eax)
  8016cc:	89 08                	mov    %ecx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	//add $8, %esp
	popl %edx 
  8016ce:	5a                   	pop    %edx
	popl %edx
  8016cf:	5a                   	pop    %edx
	popal
  8016d0:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp
  8016d1:	83 c4 04             	add    $0x4,%esp
	popf
  8016d4:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8016d5:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8016d6:	c3                   	ret    
  8016d7:	66 90                	xchg   %ax,%ax
  8016d9:	66 90                	xchg   %ax,%ax
  8016db:	66 90                	xchg   %ax,%ax
  8016dd:	66 90                	xchg   %ax,%ax
  8016df:	90                   	nop

008016e0 <__udivdi3>:
  8016e0:	55                   	push   %ebp
  8016e1:	57                   	push   %edi
  8016e2:	56                   	push   %esi
  8016e3:	83 ec 0c             	sub    $0xc,%esp
  8016e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8016ea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8016ee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8016f2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016fc:	89 ea                	mov    %ebp,%edx
  8016fe:	89 0c 24             	mov    %ecx,(%esp)
  801701:	75 2d                	jne    801730 <__udivdi3+0x50>
  801703:	39 e9                	cmp    %ebp,%ecx
  801705:	77 61                	ja     801768 <__udivdi3+0x88>
  801707:	85 c9                	test   %ecx,%ecx
  801709:	89 ce                	mov    %ecx,%esi
  80170b:	75 0b                	jne    801718 <__udivdi3+0x38>
  80170d:	b8 01 00 00 00       	mov    $0x1,%eax
  801712:	31 d2                	xor    %edx,%edx
  801714:	f7 f1                	div    %ecx
  801716:	89 c6                	mov    %eax,%esi
  801718:	31 d2                	xor    %edx,%edx
  80171a:	89 e8                	mov    %ebp,%eax
  80171c:	f7 f6                	div    %esi
  80171e:	89 c5                	mov    %eax,%ebp
  801720:	89 f8                	mov    %edi,%eax
  801722:	f7 f6                	div    %esi
  801724:	89 ea                	mov    %ebp,%edx
  801726:	83 c4 0c             	add    $0xc,%esp
  801729:	5e                   	pop    %esi
  80172a:	5f                   	pop    %edi
  80172b:	5d                   	pop    %ebp
  80172c:	c3                   	ret    
  80172d:	8d 76 00             	lea    0x0(%esi),%esi
  801730:	39 e8                	cmp    %ebp,%eax
  801732:	77 24                	ja     801758 <__udivdi3+0x78>
  801734:	0f bd e8             	bsr    %eax,%ebp
  801737:	83 f5 1f             	xor    $0x1f,%ebp
  80173a:	75 3c                	jne    801778 <__udivdi3+0x98>
  80173c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801740:	39 34 24             	cmp    %esi,(%esp)
  801743:	0f 86 9f 00 00 00    	jbe    8017e8 <__udivdi3+0x108>
  801749:	39 d0                	cmp    %edx,%eax
  80174b:	0f 82 97 00 00 00    	jb     8017e8 <__udivdi3+0x108>
  801751:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801758:	31 d2                	xor    %edx,%edx
  80175a:	31 c0                	xor    %eax,%eax
  80175c:	83 c4 0c             	add    $0xc,%esp
  80175f:	5e                   	pop    %esi
  801760:	5f                   	pop    %edi
  801761:	5d                   	pop    %ebp
  801762:	c3                   	ret    
  801763:	90                   	nop
  801764:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801768:	89 f8                	mov    %edi,%eax
  80176a:	f7 f1                	div    %ecx
  80176c:	31 d2                	xor    %edx,%edx
  80176e:	83 c4 0c             	add    $0xc,%esp
  801771:	5e                   	pop    %esi
  801772:	5f                   	pop    %edi
  801773:	5d                   	pop    %ebp
  801774:	c3                   	ret    
  801775:	8d 76 00             	lea    0x0(%esi),%esi
  801778:	89 e9                	mov    %ebp,%ecx
  80177a:	8b 3c 24             	mov    (%esp),%edi
  80177d:	d3 e0                	shl    %cl,%eax
  80177f:	89 c6                	mov    %eax,%esi
  801781:	b8 20 00 00 00       	mov    $0x20,%eax
  801786:	29 e8                	sub    %ebp,%eax
  801788:	89 c1                	mov    %eax,%ecx
  80178a:	d3 ef                	shr    %cl,%edi
  80178c:	89 e9                	mov    %ebp,%ecx
  80178e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801792:	8b 3c 24             	mov    (%esp),%edi
  801795:	09 74 24 08          	or     %esi,0x8(%esp)
  801799:	89 d6                	mov    %edx,%esi
  80179b:	d3 e7                	shl    %cl,%edi
  80179d:	89 c1                	mov    %eax,%ecx
  80179f:	89 3c 24             	mov    %edi,(%esp)
  8017a2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8017a6:	d3 ee                	shr    %cl,%esi
  8017a8:	89 e9                	mov    %ebp,%ecx
  8017aa:	d3 e2                	shl    %cl,%edx
  8017ac:	89 c1                	mov    %eax,%ecx
  8017ae:	d3 ef                	shr    %cl,%edi
  8017b0:	09 d7                	or     %edx,%edi
  8017b2:	89 f2                	mov    %esi,%edx
  8017b4:	89 f8                	mov    %edi,%eax
  8017b6:	f7 74 24 08          	divl   0x8(%esp)
  8017ba:	89 d6                	mov    %edx,%esi
  8017bc:	89 c7                	mov    %eax,%edi
  8017be:	f7 24 24             	mull   (%esp)
  8017c1:	39 d6                	cmp    %edx,%esi
  8017c3:	89 14 24             	mov    %edx,(%esp)
  8017c6:	72 30                	jb     8017f8 <__udivdi3+0x118>
  8017c8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8017cc:	89 e9                	mov    %ebp,%ecx
  8017ce:	d3 e2                	shl    %cl,%edx
  8017d0:	39 c2                	cmp    %eax,%edx
  8017d2:	73 05                	jae    8017d9 <__udivdi3+0xf9>
  8017d4:	3b 34 24             	cmp    (%esp),%esi
  8017d7:	74 1f                	je     8017f8 <__udivdi3+0x118>
  8017d9:	89 f8                	mov    %edi,%eax
  8017db:	31 d2                	xor    %edx,%edx
  8017dd:	e9 7a ff ff ff       	jmp    80175c <__udivdi3+0x7c>
  8017e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8017e8:	31 d2                	xor    %edx,%edx
  8017ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8017ef:	e9 68 ff ff ff       	jmp    80175c <__udivdi3+0x7c>
  8017f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8017f8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8017fb:	31 d2                	xor    %edx,%edx
  8017fd:	83 c4 0c             	add    $0xc,%esp
  801800:	5e                   	pop    %esi
  801801:	5f                   	pop    %edi
  801802:	5d                   	pop    %ebp
  801803:	c3                   	ret    
  801804:	66 90                	xchg   %ax,%ax
  801806:	66 90                	xchg   %ax,%ax
  801808:	66 90                	xchg   %ax,%ax
  80180a:	66 90                	xchg   %ax,%ax
  80180c:	66 90                	xchg   %ax,%ax
  80180e:	66 90                	xchg   %ax,%ax

00801810 <__umoddi3>:
  801810:	55                   	push   %ebp
  801811:	57                   	push   %edi
  801812:	56                   	push   %esi
  801813:	83 ec 14             	sub    $0x14,%esp
  801816:	8b 44 24 28          	mov    0x28(%esp),%eax
  80181a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80181e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801822:	89 c7                	mov    %eax,%edi
  801824:	89 44 24 04          	mov    %eax,0x4(%esp)
  801828:	8b 44 24 30          	mov    0x30(%esp),%eax
  80182c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801830:	89 34 24             	mov    %esi,(%esp)
  801833:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801837:	85 c0                	test   %eax,%eax
  801839:	89 c2                	mov    %eax,%edx
  80183b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80183f:	75 17                	jne    801858 <__umoddi3+0x48>
  801841:	39 fe                	cmp    %edi,%esi
  801843:	76 4b                	jbe    801890 <__umoddi3+0x80>
  801845:	89 c8                	mov    %ecx,%eax
  801847:	89 fa                	mov    %edi,%edx
  801849:	f7 f6                	div    %esi
  80184b:	89 d0                	mov    %edx,%eax
  80184d:	31 d2                	xor    %edx,%edx
  80184f:	83 c4 14             	add    $0x14,%esp
  801852:	5e                   	pop    %esi
  801853:	5f                   	pop    %edi
  801854:	5d                   	pop    %ebp
  801855:	c3                   	ret    
  801856:	66 90                	xchg   %ax,%ax
  801858:	39 f8                	cmp    %edi,%eax
  80185a:	77 54                	ja     8018b0 <__umoddi3+0xa0>
  80185c:	0f bd e8             	bsr    %eax,%ebp
  80185f:	83 f5 1f             	xor    $0x1f,%ebp
  801862:	75 5c                	jne    8018c0 <__umoddi3+0xb0>
  801864:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801868:	39 3c 24             	cmp    %edi,(%esp)
  80186b:	0f 87 e7 00 00 00    	ja     801958 <__umoddi3+0x148>
  801871:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801875:	29 f1                	sub    %esi,%ecx
  801877:	19 c7                	sbb    %eax,%edi
  801879:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80187d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801881:	8b 44 24 08          	mov    0x8(%esp),%eax
  801885:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801889:	83 c4 14             	add    $0x14,%esp
  80188c:	5e                   	pop    %esi
  80188d:	5f                   	pop    %edi
  80188e:	5d                   	pop    %ebp
  80188f:	c3                   	ret    
  801890:	85 f6                	test   %esi,%esi
  801892:	89 f5                	mov    %esi,%ebp
  801894:	75 0b                	jne    8018a1 <__umoddi3+0x91>
  801896:	b8 01 00 00 00       	mov    $0x1,%eax
  80189b:	31 d2                	xor    %edx,%edx
  80189d:	f7 f6                	div    %esi
  80189f:	89 c5                	mov    %eax,%ebp
  8018a1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8018a5:	31 d2                	xor    %edx,%edx
  8018a7:	f7 f5                	div    %ebp
  8018a9:	89 c8                	mov    %ecx,%eax
  8018ab:	f7 f5                	div    %ebp
  8018ad:	eb 9c                	jmp    80184b <__umoddi3+0x3b>
  8018af:	90                   	nop
  8018b0:	89 c8                	mov    %ecx,%eax
  8018b2:	89 fa                	mov    %edi,%edx
  8018b4:	83 c4 14             	add    $0x14,%esp
  8018b7:	5e                   	pop    %esi
  8018b8:	5f                   	pop    %edi
  8018b9:	5d                   	pop    %ebp
  8018ba:	c3                   	ret    
  8018bb:	90                   	nop
  8018bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8018c0:	8b 04 24             	mov    (%esp),%eax
  8018c3:	be 20 00 00 00       	mov    $0x20,%esi
  8018c8:	89 e9                	mov    %ebp,%ecx
  8018ca:	29 ee                	sub    %ebp,%esi
  8018cc:	d3 e2                	shl    %cl,%edx
  8018ce:	89 f1                	mov    %esi,%ecx
  8018d0:	d3 e8                	shr    %cl,%eax
  8018d2:	89 e9                	mov    %ebp,%ecx
  8018d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d8:	8b 04 24             	mov    (%esp),%eax
  8018db:	09 54 24 04          	or     %edx,0x4(%esp)
  8018df:	89 fa                	mov    %edi,%edx
  8018e1:	d3 e0                	shl    %cl,%eax
  8018e3:	89 f1                	mov    %esi,%ecx
  8018e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018e9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8018ed:	d3 ea                	shr    %cl,%edx
  8018ef:	89 e9                	mov    %ebp,%ecx
  8018f1:	d3 e7                	shl    %cl,%edi
  8018f3:	89 f1                	mov    %esi,%ecx
  8018f5:	d3 e8                	shr    %cl,%eax
  8018f7:	89 e9                	mov    %ebp,%ecx
  8018f9:	09 f8                	or     %edi,%eax
  8018fb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8018ff:	f7 74 24 04          	divl   0x4(%esp)
  801903:	d3 e7                	shl    %cl,%edi
  801905:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801909:	89 d7                	mov    %edx,%edi
  80190b:	f7 64 24 08          	mull   0x8(%esp)
  80190f:	39 d7                	cmp    %edx,%edi
  801911:	89 c1                	mov    %eax,%ecx
  801913:	89 14 24             	mov    %edx,(%esp)
  801916:	72 2c                	jb     801944 <__umoddi3+0x134>
  801918:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80191c:	72 22                	jb     801940 <__umoddi3+0x130>
  80191e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801922:	29 c8                	sub    %ecx,%eax
  801924:	19 d7                	sbb    %edx,%edi
  801926:	89 e9                	mov    %ebp,%ecx
  801928:	89 fa                	mov    %edi,%edx
  80192a:	d3 e8                	shr    %cl,%eax
  80192c:	89 f1                	mov    %esi,%ecx
  80192e:	d3 e2                	shl    %cl,%edx
  801930:	89 e9                	mov    %ebp,%ecx
  801932:	d3 ef                	shr    %cl,%edi
  801934:	09 d0                	or     %edx,%eax
  801936:	89 fa                	mov    %edi,%edx
  801938:	83 c4 14             	add    $0x14,%esp
  80193b:	5e                   	pop    %esi
  80193c:	5f                   	pop    %edi
  80193d:	5d                   	pop    %ebp
  80193e:	c3                   	ret    
  80193f:	90                   	nop
  801940:	39 d7                	cmp    %edx,%edi
  801942:	75 da                	jne    80191e <__umoddi3+0x10e>
  801944:	8b 14 24             	mov    (%esp),%edx
  801947:	89 c1                	mov    %eax,%ecx
  801949:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80194d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801951:	eb cb                	jmp    80191e <__umoddi3+0x10e>
  801953:	90                   	nop
  801954:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801958:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80195c:	0f 82 0f ff ff ff    	jb     801871 <__umoddi3+0x61>
  801962:	e9 1a ff ff ff       	jmp    801881 <__umoddi3+0x71>
