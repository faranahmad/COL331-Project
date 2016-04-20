
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 c1 00 00 00       	call   8000f2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 38             	sub    $0x38,%esp
  800039:	8b 45 0c             	mov    0xc(%ebp),%eax
  80003c:	88 45 e4             	mov    %al,-0x1c(%ebp)
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80003f:	8b 45 08             	mov    0x8(%ebp),%eax
  800042:	89 04 24             	mov    %eax,(%esp)
  800045:	e8 7a 08 00 00       	call   8008c4 <strlen>
  80004a:	83 f8 02             	cmp    $0x2,%eax
  80004d:	7f 43                	jg     800092 <forkchild+0x5f>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80004f:	0f be 45 e4          	movsbl -0x1c(%ebp),%eax
  800053:	89 44 24 10          	mov    %eax,0x10(%esp)
  800057:	8b 45 08             	mov    0x8(%ebp),%eax
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 c0 19 80 	movl   $0x8019c0,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  80006d:	00 
  80006e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800071:	89 04 24             	mov    %eax,(%esp)
  800074:	e8 17 08 00 00       	call   800890 <snprintf>
	if (fork() == 0) {
  800079:	e8 ed 13 00 00       	call   80146b <fork>
  80007e:	85 c0                	test   %eax,%eax
  800080:	75 10                	jne    800092 <forkchild+0x5f>
		forktree(nxt);
  800082:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800085:	89 04 24             	mov    %eax,(%esp)
  800088:	e8 07 00 00 00       	call   800094 <forktree>
		exit();
  80008d:	e8 ae 00 00 00       	call   800140 <exit>
	}
}
  800092:	c9                   	leave  
  800093:	c3                   	ret    

00800094 <forktree>:

void
forktree(const char *cur)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80009a:	e8 e3 0e 00 00       	call   800f82 <sys_getenvid>
  80009f:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a2:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000aa:	c7 04 24 c5 19 80 00 	movl   $0x8019c5,(%esp)
  8000b1:	e8 5e 01 00 00       	call   800214 <cprintf>

	forkchild(cur, '0');
  8000b6:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  8000bd:	00 
  8000be:	8b 45 08             	mov    0x8(%ebp),%eax
  8000c1:	89 04 24             	mov    %eax,(%esp)
  8000c4:	e8 6a ff ff ff       	call   800033 <forkchild>
	forkchild(cur, '1');
  8000c9:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  8000d0:	00 
  8000d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8000d4:	89 04 24             	mov    %eax,(%esp)
  8000d7:	e8 57 ff ff ff       	call   800033 <forkchild>
}
  8000dc:	c9                   	leave  
  8000dd:	c3                   	ret    

008000de <umain>:

void
umain(int argc, char **argv)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  8000e4:	c7 04 24 d6 19 80 00 	movl   $0x8019d6,(%esp)
  8000eb:	e8 a4 ff ff ff       	call   800094 <forktree>
}
  8000f0:	c9                   	leave  
  8000f1:	c3                   	ret    

008000f2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000f8:	e8 85 0e 00 00       	call   800f82 <sys_getenvid>
  8000fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800102:	c1 e0 02             	shl    $0x2,%eax
  800105:	89 c2                	mov    %eax,%edx
  800107:	c1 e2 05             	shl    $0x5,%edx
  80010a:	29 c2                	sub    %eax,%edx
  80010c:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  800112:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800117:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80011b:	7e 0a                	jle    800127 <libmain+0x35>
		binaryname = argv[0];
  80011d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800120:	8b 00                	mov    (%eax),%eax
  800122:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800127:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012e:	8b 45 08             	mov    0x8(%ebp),%eax
  800131:	89 04 24             	mov    %eax,(%esp)
  800134:	e8 a5 ff ff ff       	call   8000de <umain>

	// exit gracefully
	exit();
  800139:	e8 02 00 00 00       	call   800140 <exit>
}
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    

00800140 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800146:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014d:	e8 ed 0d 00 00       	call   800f3f <sys_env_destroy>
}
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  80015a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015d:	8b 00                	mov    (%eax),%eax
  80015f:	8d 48 01             	lea    0x1(%eax),%ecx
  800162:	8b 55 0c             	mov    0xc(%ebp),%edx
  800165:	89 0a                	mov    %ecx,(%edx)
  800167:	8b 55 08             	mov    0x8(%ebp),%edx
  80016a:	89 d1                	mov    %edx,%ecx
  80016c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80016f:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800173:	8b 45 0c             	mov    0xc(%ebp),%eax
  800176:	8b 00                	mov    (%eax),%eax
  800178:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017d:	75 20                	jne    80019f <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  80017f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800182:	8b 00                	mov    (%eax),%eax
  800184:	8b 55 0c             	mov    0xc(%ebp),%edx
  800187:	83 c2 08             	add    $0x8,%edx
  80018a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018e:	89 14 24             	mov    %edx,(%esp)
  800191:	e8 23 0d 00 00       	call   800eb9 <sys_cputs>
		b->idx = 0;
  800196:	8b 45 0c             	mov    0xc(%ebp),%eax
  800199:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80019f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a2:	8b 40 04             	mov    0x4(%eax),%eax
  8001a5:	8d 50 01             	lea    0x1(%eax),%edx
  8001a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ab:	89 50 04             	mov    %edx,0x4(%eax)
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001b9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c0:	00 00 00 
	b.cnt = 0;
  8001c3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ca:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001db:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e5:	c7 04 24 54 01 80 00 	movl   $0x800154,(%esp)
  8001ec:	e8 bd 01 00 00       	call   8003ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800201:	83 c0 08             	add    $0x8,%eax
  800204:	89 04 24             	mov    %eax,(%esp)
  800207:	e8 ad 0c 00 00       	call   800eb9 <sys_cputs>

	return b.cnt;
  80020c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021a:	8d 45 0c             	lea    0xc(%ebp),%eax
  80021d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800220:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800223:	89 44 24 04          	mov    %eax,0x4(%esp)
  800227:	8b 45 08             	mov    0x8(%ebp),%eax
  80022a:	89 04 24             	mov    %eax,(%esp)
  80022d:	e8 7e ff ff ff       	call   8001b0 <vcprintf>
  800232:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800235:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	53                   	push   %ebx
  80023e:	83 ec 34             	sub    $0x34,%esp
  800241:	8b 45 10             	mov    0x10(%ebp),%eax
  800244:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800247:	8b 45 14             	mov    0x14(%ebp),%eax
  80024a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024d:	8b 45 18             	mov    0x18(%ebp),%eax
  800250:	ba 00 00 00 00       	mov    $0x0,%edx
  800255:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800258:	77 72                	ja     8002cc <printnum+0x92>
  80025a:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80025d:	72 05                	jb     800264 <printnum+0x2a>
  80025f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800262:	77 68                	ja     8002cc <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800264:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800267:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80026a:	8b 45 18             	mov    0x18(%ebp),%eax
  80026d:	ba 00 00 00 00       	mov    $0x0,%edx
  800272:	89 44 24 08          	mov    %eax,0x8(%esp)
  800276:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80027a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80027d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800280:	89 04 24             	mov    %eax,(%esp)
  800283:	89 54 24 04          	mov    %edx,0x4(%esp)
  800287:	e8 94 14 00 00       	call   801720 <__udivdi3>
  80028c:	8b 4d 20             	mov    0x20(%ebp),%ecx
  80028f:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800293:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800297:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80029a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80029e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	89 04 24             	mov    %eax,(%esp)
  8002b3:	e8 82 ff ff ff       	call   80023a <printnum>
  8002b8:	eb 1c                	jmp    8002d6 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c1:	8b 45 20             	mov    0x20(%ebp),%eax
  8002c4:	89 04 24             	mov    %eax,(%esp)
  8002c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ca:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002cc:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8002d0:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8002d4:	7f e4                	jg     8002ba <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002d6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8002e4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002e8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002ec:	89 04 24             	mov    %eax,(%esp)
  8002ef:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f3:	e8 58 15 00 00       	call   801850 <__umoddi3>
  8002f8:	05 c8 1a 80 00       	add    $0x801ac8,%eax
  8002fd:	0f b6 00             	movzbl (%eax),%eax
  800300:	0f be c0             	movsbl %al,%eax
  800303:	8b 55 0c             	mov    0xc(%ebp),%edx
  800306:	89 54 24 04          	mov    %edx,0x4(%esp)
  80030a:	89 04 24             	mov    %eax,(%esp)
  80030d:	8b 45 08             	mov    0x8(%ebp),%eax
  800310:	ff d0                	call   *%eax
}
  800312:	83 c4 34             	add    $0x34,%esp
  800315:	5b                   	pop    %ebx
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80031b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80031f:	7e 14                	jle    800335 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800321:	8b 45 08             	mov    0x8(%ebp),%eax
  800324:	8b 00                	mov    (%eax),%eax
  800326:	8d 48 08             	lea    0x8(%eax),%ecx
  800329:	8b 55 08             	mov    0x8(%ebp),%edx
  80032c:	89 0a                	mov    %ecx,(%edx)
  80032e:	8b 50 04             	mov    0x4(%eax),%edx
  800331:	8b 00                	mov    (%eax),%eax
  800333:	eb 30                	jmp    800365 <getuint+0x4d>
	else if (lflag)
  800335:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800339:	74 16                	je     800351 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  80033b:	8b 45 08             	mov    0x8(%ebp),%eax
  80033e:	8b 00                	mov    (%eax),%eax
  800340:	8d 48 04             	lea    0x4(%eax),%ecx
  800343:	8b 55 08             	mov    0x8(%ebp),%edx
  800346:	89 0a                	mov    %ecx,(%edx)
  800348:	8b 00                	mov    (%eax),%eax
  80034a:	ba 00 00 00 00       	mov    $0x0,%edx
  80034f:	eb 14                	jmp    800365 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800351:	8b 45 08             	mov    0x8(%ebp),%eax
  800354:	8b 00                	mov    (%eax),%eax
  800356:	8d 48 04             	lea    0x4(%eax),%ecx
  800359:	8b 55 08             	mov    0x8(%ebp),%edx
  80035c:	89 0a                	mov    %ecx,(%edx)
  80035e:	8b 00                	mov    (%eax),%eax
  800360:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800365:	5d                   	pop    %ebp
  800366:	c3                   	ret    

00800367 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80036a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80036e:	7e 14                	jle    800384 <getint+0x1d>
		return va_arg(*ap, long long);
  800370:	8b 45 08             	mov    0x8(%ebp),%eax
  800373:	8b 00                	mov    (%eax),%eax
  800375:	8d 48 08             	lea    0x8(%eax),%ecx
  800378:	8b 55 08             	mov    0x8(%ebp),%edx
  80037b:	89 0a                	mov    %ecx,(%edx)
  80037d:	8b 50 04             	mov    0x4(%eax),%edx
  800380:	8b 00                	mov    (%eax),%eax
  800382:	eb 28                	jmp    8003ac <getint+0x45>
	else if (lflag)
  800384:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800388:	74 12                	je     80039c <getint+0x35>
		return va_arg(*ap, long);
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
  80038d:	8b 00                	mov    (%eax),%eax
  80038f:	8d 48 04             	lea    0x4(%eax),%ecx
  800392:	8b 55 08             	mov    0x8(%ebp),%edx
  800395:	89 0a                	mov    %ecx,(%edx)
  800397:	8b 00                	mov    (%eax),%eax
  800399:	99                   	cltd   
  80039a:	eb 10                	jmp    8003ac <getint+0x45>
	else
		return va_arg(*ap, int);
  80039c:	8b 45 08             	mov    0x8(%ebp),%eax
  80039f:	8b 00                	mov    (%eax),%eax
  8003a1:	8d 48 04             	lea    0x4(%eax),%ecx
  8003a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a7:	89 0a                	mov    %ecx,(%edx)
  8003a9:	8b 00                	mov    (%eax),%eax
  8003ab:	99                   	cltd   
}
  8003ac:	5d                   	pop    %ebp
  8003ad:	c3                   	ret    

008003ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	56                   	push   %esi
  8003b2:	53                   	push   %ebx
  8003b3:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b6:	eb 18                	jmp    8003d0 <vprintfmt+0x22>
			if (ch == '\0')
  8003b8:	85 db                	test   %ebx,%ebx
  8003ba:	75 05                	jne    8003c1 <vprintfmt+0x13>
				return;
  8003bc:	e9 05 04 00 00       	jmp    8007c6 <vprintfmt+0x418>
			putch(ch, putdat);
  8003c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c8:	89 1c 24             	mov    %ebx,(%esp)
  8003cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ce:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d3:	8d 50 01             	lea    0x1(%eax),%edx
  8003d6:	89 55 10             	mov    %edx,0x10(%ebp)
  8003d9:	0f b6 00             	movzbl (%eax),%eax
  8003dc:	0f b6 d8             	movzbl %al,%ebx
  8003df:	83 fb 25             	cmp    $0x25,%ebx
  8003e2:	75 d4                	jne    8003b8 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8003e4:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8003e8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8003ef:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003f6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8003fd:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 45 10             	mov    0x10(%ebp),%eax
  800407:	8d 50 01             	lea    0x1(%eax),%edx
  80040a:	89 55 10             	mov    %edx,0x10(%ebp)
  80040d:	0f b6 00             	movzbl (%eax),%eax
  800410:	0f b6 d8             	movzbl %al,%ebx
  800413:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800416:	83 f8 55             	cmp    $0x55,%eax
  800419:	0f 87 76 03 00 00    	ja     800795 <vprintfmt+0x3e7>
  80041f:	8b 04 85 ec 1a 80 00 	mov    0x801aec(,%eax,4),%eax
  800426:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800428:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80042c:	eb d6                	jmp    800404 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80042e:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800432:	eb d0                	jmp    800404 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800434:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  80043b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80043e:	89 d0                	mov    %edx,%eax
  800440:	c1 e0 02             	shl    $0x2,%eax
  800443:	01 d0                	add    %edx,%eax
  800445:	01 c0                	add    %eax,%eax
  800447:	01 d8                	add    %ebx,%eax
  800449:	83 e8 30             	sub    $0x30,%eax
  80044c:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  80044f:	8b 45 10             	mov    0x10(%ebp),%eax
  800452:	0f b6 00             	movzbl (%eax),%eax
  800455:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800458:	83 fb 2f             	cmp    $0x2f,%ebx
  80045b:	7e 0b                	jle    800468 <vprintfmt+0xba>
  80045d:	83 fb 39             	cmp    $0x39,%ebx
  800460:	7f 06                	jg     800468 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800462:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800466:	eb d3                	jmp    80043b <vprintfmt+0x8d>
			goto process_precision;
  800468:	eb 33                	jmp    80049d <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  80046a:	8b 45 14             	mov    0x14(%ebp),%eax
  80046d:	8d 50 04             	lea    0x4(%eax),%edx
  800470:	89 55 14             	mov    %edx,0x14(%ebp)
  800473:	8b 00                	mov    (%eax),%eax
  800475:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800478:	eb 23                	jmp    80049d <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80047a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80047e:	79 0c                	jns    80048c <vprintfmt+0xde>
				width = 0;
  800480:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800487:	e9 78 ff ff ff       	jmp    800404 <vprintfmt+0x56>
  80048c:	e9 73 ff ff ff       	jmp    800404 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800491:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800498:	e9 67 ff ff ff       	jmp    800404 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80049d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004a1:	79 12                	jns    8004b5 <vprintfmt+0x107>
				width = precision, precision = -1;
  8004a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8004b0:	e9 4f ff ff ff       	jmp    800404 <vprintfmt+0x56>
  8004b5:	e9 4a ff ff ff       	jmp    800404 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004ba:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8004be:	e9 41 ff ff ff       	jmp    800404 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c6:	8d 50 04             	lea    0x4(%eax),%edx
  8004c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cc:	8b 00                	mov    (%eax),%eax
  8004ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004d5:	89 04 24             	mov    %eax,(%esp)
  8004d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004db:	ff d0                	call   *%eax
			break;
  8004dd:	e9 de 02 00 00       	jmp    8007c0 <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e5:	8d 50 04             	lea    0x4(%eax),%edx
  8004e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004eb:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8004ed:	85 db                	test   %ebx,%ebx
  8004ef:	79 02                	jns    8004f3 <vprintfmt+0x145>
				err = -err;
  8004f1:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f3:	83 fb 09             	cmp    $0x9,%ebx
  8004f6:	7f 0b                	jg     800503 <vprintfmt+0x155>
  8004f8:	8b 34 9d a0 1a 80 00 	mov    0x801aa0(,%ebx,4),%esi
  8004ff:	85 f6                	test   %esi,%esi
  800501:	75 23                	jne    800526 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800503:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800507:	c7 44 24 08 d9 1a 80 	movl   $0x801ad9,0x8(%esp)
  80050e:	00 
  80050f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800512:	89 44 24 04          	mov    %eax,0x4(%esp)
  800516:	8b 45 08             	mov    0x8(%ebp),%eax
  800519:	89 04 24             	mov    %eax,(%esp)
  80051c:	e8 ac 02 00 00       	call   8007cd <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800521:	e9 9a 02 00 00       	jmp    8007c0 <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800526:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80052a:	c7 44 24 08 e2 1a 80 	movl   $0x801ae2,0x8(%esp)
  800531:	00 
  800532:	8b 45 0c             	mov    0xc(%ebp),%eax
  800535:	89 44 24 04          	mov    %eax,0x4(%esp)
  800539:	8b 45 08             	mov    0x8(%ebp),%eax
  80053c:	89 04 24             	mov    %eax,(%esp)
  80053f:	e8 89 02 00 00       	call   8007cd <printfmt>
			break;
  800544:	e9 77 02 00 00       	jmp    8007c0 <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
  80054c:	8d 50 04             	lea    0x4(%eax),%edx
  80054f:	89 55 14             	mov    %edx,0x14(%ebp)
  800552:	8b 30                	mov    (%eax),%esi
  800554:	85 f6                	test   %esi,%esi
  800556:	75 05                	jne    80055d <vprintfmt+0x1af>
				p = "(null)";
  800558:	be e5 1a 80 00       	mov    $0x801ae5,%esi
			if (width > 0 && padc != '-')
  80055d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800561:	7e 37                	jle    80059a <vprintfmt+0x1ec>
  800563:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800567:	74 31                	je     80059a <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800569:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80056c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800570:	89 34 24             	mov    %esi,(%esp)
  800573:	e8 72 03 00 00       	call   8008ea <strnlen>
  800578:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80057b:	eb 17                	jmp    800594 <vprintfmt+0x1e6>
					putch(padc, putdat);
  80057d:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800581:	8b 55 0c             	mov    0xc(%ebp),%edx
  800584:	89 54 24 04          	mov    %edx,0x4(%esp)
  800588:	89 04 24             	mov    %eax,(%esp)
  80058b:	8b 45 08             	mov    0x8(%ebp),%eax
  80058e:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800590:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800594:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800598:	7f e3                	jg     80057d <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059a:	eb 38                	jmp    8005d4 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  80059c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a0:	74 1f                	je     8005c1 <vprintfmt+0x213>
  8005a2:	83 fb 1f             	cmp    $0x1f,%ebx
  8005a5:	7e 05                	jle    8005ac <vprintfmt+0x1fe>
  8005a7:	83 fb 7e             	cmp    $0x7e,%ebx
  8005aa:	7e 15                	jle    8005c1 <vprintfmt+0x213>
					putch('?', putdat);
  8005ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b3:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8005bd:	ff d0                	call   *%eax
  8005bf:	eb 0f                	jmp    8005d0 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8005c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c8:	89 1c 24             	mov    %ebx,(%esp)
  8005cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ce:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d0:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005d4:	89 f0                	mov    %esi,%eax
  8005d6:	8d 70 01             	lea    0x1(%eax),%esi
  8005d9:	0f b6 00             	movzbl (%eax),%eax
  8005dc:	0f be d8             	movsbl %al,%ebx
  8005df:	85 db                	test   %ebx,%ebx
  8005e1:	74 10                	je     8005f3 <vprintfmt+0x245>
  8005e3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e7:	78 b3                	js     80059c <vprintfmt+0x1ee>
  8005e9:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005ed:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005f1:	79 a9                	jns    80059c <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005f3:	eb 17                	jmp    80060c <vprintfmt+0x25e>
				putch(' ', putdat);
  8005f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800603:	8b 45 08             	mov    0x8(%ebp),%eax
  800606:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800608:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80060c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800610:	7f e3                	jg     8005f5 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800612:	e9 a9 01 00 00       	jmp    8007c0 <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800617:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80061a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061e:	8d 45 14             	lea    0x14(%ebp),%eax
  800621:	89 04 24             	mov    %eax,(%esp)
  800624:	e8 3e fd ff ff       	call   800367 <getint>
  800629:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80062c:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  80062f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800632:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800635:	85 d2                	test   %edx,%edx
  800637:	79 26                	jns    80065f <vprintfmt+0x2b1>
				putch('-', putdat);
  800639:	8b 45 0c             	mov    0xc(%ebp),%eax
  80063c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800640:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800647:	8b 45 08             	mov    0x8(%ebp),%eax
  80064a:	ff d0                	call   *%eax
				num = -(long long) num;
  80064c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800652:	f7 d8                	neg    %eax
  800654:	83 d2 00             	adc    $0x0,%edx
  800657:	f7 da                	neg    %edx
  800659:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80065c:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  80065f:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800666:	e9 e1 00 00 00       	jmp    80074c <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80066e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800672:	8d 45 14             	lea    0x14(%ebp),%eax
  800675:	89 04 24             	mov    %eax,(%esp)
  800678:	e8 9b fc ff ff       	call   800318 <getuint>
  80067d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800680:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800683:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80068a:	e9 bd 00 00 00       	jmp    80074c <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  80068f:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  800696:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800699:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069d:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a0:	89 04 24             	mov    %eax,(%esp)
  8006a3:	e8 70 fc ff ff       	call   800318 <getuint>
  8006a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006ab:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  8006ae:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8006b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b5:	89 54 24 18          	mov    %edx,0x18(%esp)
  8006b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006bc:	89 54 24 14          	mov    %edx,0x14(%esp)
  8006c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dc:	89 04 24             	mov    %eax,(%esp)
  8006df:	e8 56 fb ff ff       	call   80023a <printnum>
			break;
  8006e4:	e9 d7 00 00 00       	jmp    8007c0 <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  8006e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f0:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fa:	ff d0                	call   *%eax
			putch('x', putdat);
  8006fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800703:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80070a:	8b 45 08             	mov    0x8(%ebp),%eax
  80070d:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8d 50 04             	lea    0x4(%eax),%edx
  800715:	89 55 14             	mov    %edx,0x14(%ebp)
  800718:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80071a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80071d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800724:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  80072b:	eb 1f                	jmp    80074c <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80072d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800730:	89 44 24 04          	mov    %eax,0x4(%esp)
  800734:	8d 45 14             	lea    0x14(%ebp),%eax
  800737:	89 04 24             	mov    %eax,(%esp)
  80073a:	e8 d9 fb ff ff       	call   800318 <getuint>
  80073f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800742:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800745:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  80074c:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800750:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800753:	89 54 24 18          	mov    %edx,0x18(%esp)
  800757:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80075a:	89 54 24 14          	mov    %edx,0x14(%esp)
  80075e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800762:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800765:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800768:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800770:	8b 45 0c             	mov    0xc(%ebp),%eax
  800773:	89 44 24 04          	mov    %eax,0x4(%esp)
  800777:	8b 45 08             	mov    0x8(%ebp),%eax
  80077a:	89 04 24             	mov    %eax,(%esp)
  80077d:	e8 b8 fa ff ff       	call   80023a <printnum>
			break;
  800782:	eb 3c                	jmp    8007c0 <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800784:	8b 45 0c             	mov    0xc(%ebp),%eax
  800787:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078b:	89 1c 24             	mov    %ebx,(%esp)
  80078e:	8b 45 08             	mov    0x8(%ebp),%eax
  800791:	ff d0                	call   *%eax
			break;
  800793:	eb 2b                	jmp    8007c0 <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800795:	8b 45 0c             	mov    0xc(%ebp),%eax
  800798:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a6:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007a8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8007ac:	eb 04                	jmp    8007b2 <vprintfmt+0x404>
  8007ae:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8007b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b5:	83 e8 01             	sub    $0x1,%eax
  8007b8:	0f b6 00             	movzbl (%eax),%eax
  8007bb:	3c 25                	cmp    $0x25,%al
  8007bd:	75 ef                	jne    8007ae <vprintfmt+0x400>
				/* do nothing */;
			break;
  8007bf:	90                   	nop
		}
	}
  8007c0:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007c1:	e9 0a fc ff ff       	jmp    8003d0 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8007c6:	83 c4 40             	add    $0x40,%esp
  8007c9:	5b                   	pop    %ebx
  8007ca:	5e                   	pop    %esi
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8007d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8007d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f1:	89 04 24             	mov    %eax,(%esp)
  8007f4:	e8 b5 fb ff ff       	call   8003ae <vprintfmt>
	va_end(ap);
}
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  8007fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800801:	8b 40 08             	mov    0x8(%eax),%eax
  800804:	8d 50 01             	lea    0x1(%eax),%edx
  800807:	8b 45 0c             	mov    0xc(%ebp),%eax
  80080a:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  80080d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800810:	8b 10                	mov    (%eax),%edx
  800812:	8b 45 0c             	mov    0xc(%ebp),%eax
  800815:	8b 40 04             	mov    0x4(%eax),%eax
  800818:	39 c2                	cmp    %eax,%edx
  80081a:	73 12                	jae    80082e <sprintputch+0x33>
		*b->buf++ = ch;
  80081c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081f:	8b 00                	mov    (%eax),%eax
  800821:	8d 48 01             	lea    0x1(%eax),%ecx
  800824:	8b 55 0c             	mov    0xc(%ebp),%edx
  800827:	89 0a                	mov    %ecx,(%edx)
  800829:	8b 55 08             	mov    0x8(%ebp),%edx
  80082c:	88 10                	mov    %dl,(%eax)
}
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800836:	8b 45 08             	mov    0x8(%ebp),%eax
  800839:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80083c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083f:	8d 50 ff             	lea    -0x1(%eax),%edx
  800842:	8b 45 08             	mov    0x8(%ebp),%eax
  800845:	01 d0                	add    %edx,%eax
  800847:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80084a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800851:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800855:	74 06                	je     80085d <vsnprintf+0x2d>
  800857:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80085b:	7f 07                	jg     800864 <vsnprintf+0x34>
		return -E_INVAL;
  80085d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800862:	eb 2a                	jmp    80088e <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800864:	8b 45 14             	mov    0x14(%ebp),%eax
  800867:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80086b:	8b 45 10             	mov    0x10(%ebp),%eax
  80086e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800872:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800875:	89 44 24 04          	mov    %eax,0x4(%esp)
  800879:	c7 04 24 fb 07 80 00 	movl   $0x8007fb,(%esp)
  800880:	e8 29 fb ff ff       	call   8003ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800885:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800888:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80088b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80088e:	c9                   	leave  
  80088f:	c3                   	ret    

00800890 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800896:	8d 45 14             	lea    0x14(%ebp),%eax
  800899:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  80089c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80089f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	89 04 24             	mov    %eax,(%esp)
  8008b7:	e8 74 ff ff ff       	call   800830 <vsnprintf>
  8008bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  8008bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008c2:	c9                   	leave  
  8008c3:	c3                   	ret    

008008c4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ca:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008d1:	eb 08                	jmp    8008db <strlen+0x17>
		n++;
  8008d3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	0f b6 00             	movzbl (%eax),%eax
  8008e1:	84 c0                	test   %al,%al
  8008e3:	75 ee                	jne    8008d3 <strlen+0xf>
		n++;
	return n;
  8008e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008e8:	c9                   	leave  
  8008e9:	c3                   	ret    

008008ea <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008f7:	eb 0c                	jmp    800905 <strnlen+0x1b>
		n++;
  8008f9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008fd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800901:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800905:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800909:	74 0a                	je     800915 <strnlen+0x2b>
  80090b:	8b 45 08             	mov    0x8(%ebp),%eax
  80090e:	0f b6 00             	movzbl (%eax),%eax
  800911:	84 c0                	test   %al,%al
  800913:	75 e4                	jne    8008f9 <strnlen+0xf>
		n++;
	return n;
  800915:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800918:	c9                   	leave  
  800919:	c3                   	ret    

0080091a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800926:	90                   	nop
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	8d 50 01             	lea    0x1(%eax),%edx
  80092d:	89 55 08             	mov    %edx,0x8(%ebp)
  800930:	8b 55 0c             	mov    0xc(%ebp),%edx
  800933:	8d 4a 01             	lea    0x1(%edx),%ecx
  800936:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800939:	0f b6 12             	movzbl (%edx),%edx
  80093c:	88 10                	mov    %dl,(%eax)
  80093e:	0f b6 00             	movzbl (%eax),%eax
  800941:	84 c0                	test   %al,%al
  800943:	75 e2                	jne    800927 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800945:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800948:	c9                   	leave  
  800949:	c3                   	ret    

0080094a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	89 04 24             	mov    %eax,(%esp)
  800956:	e8 69 ff ff ff       	call   8008c4 <strlen>
  80095b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  80095e:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	01 c2                	add    %eax,%edx
  800966:	8b 45 0c             	mov    0xc(%ebp),%eax
  800969:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096d:	89 14 24             	mov    %edx,(%esp)
  800970:	e8 a5 ff ff ff       	call   80091a <strcpy>
	return dst;
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800978:	c9                   	leave  
  800979:	c3                   	ret    

0080097a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800986:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80098d:	eb 23                	jmp    8009b2 <strncpy+0x38>
		*dst++ = *src;
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	8d 50 01             	lea    0x1(%eax),%edx
  800995:	89 55 08             	mov    %edx,0x8(%ebp)
  800998:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099b:	0f b6 12             	movzbl (%edx),%edx
  80099e:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8009a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a3:	0f b6 00             	movzbl (%eax),%eax
  8009a6:	84 c0                	test   %al,%al
  8009a8:	74 04                	je     8009ae <strncpy+0x34>
			src++;
  8009aa:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ae:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8009b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009b5:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009b8:	72 d5                	jb     80098f <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8009ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8009bd:	c9                   	leave  
  8009be:	c3                   	ret    

008009bf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  8009cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009cf:	74 33                	je     800a04 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009d1:	eb 17                	jmp    8009ea <strlcpy+0x2b>
			*dst++ = *src++;
  8009d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d6:	8d 50 01             	lea    0x1(%eax),%edx
  8009d9:	89 55 08             	mov    %edx,0x8(%ebp)
  8009dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009df:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009e2:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009e5:	0f b6 12             	movzbl (%edx),%edx
  8009e8:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009ea:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8009ee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009f2:	74 0a                	je     8009fe <strlcpy+0x3f>
  8009f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f7:	0f b6 00             	movzbl (%eax),%eax
  8009fa:	84 c0                	test   %al,%al
  8009fc:	75 d5                	jne    8009d3 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a04:	8b 55 08             	mov    0x8(%ebp),%edx
  800a07:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a0a:	29 c2                	sub    %eax,%edx
  800a0c:	89 d0                	mov    %edx,%eax
}
  800a0e:	c9                   	leave  
  800a0f:	c3                   	ret    

00800a10 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a13:	eb 08                	jmp    800a1d <strcmp+0xd>
		p++, q++;
  800a15:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a19:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	0f b6 00             	movzbl (%eax),%eax
  800a23:	84 c0                	test   %al,%al
  800a25:	74 10                	je     800a37 <strcmp+0x27>
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	0f b6 10             	movzbl (%eax),%edx
  800a2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a30:	0f b6 00             	movzbl (%eax),%eax
  800a33:	38 c2                	cmp    %al,%dl
  800a35:	74 de                	je     800a15 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a37:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3a:	0f b6 00             	movzbl (%eax),%eax
  800a3d:	0f b6 d0             	movzbl %al,%edx
  800a40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a43:	0f b6 00             	movzbl (%eax),%eax
  800a46:	0f b6 c0             	movzbl %al,%eax
  800a49:	29 c2                	sub    %eax,%edx
  800a4b:	89 d0                	mov    %edx,%eax
}
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a52:	eb 0c                	jmp    800a60 <strncmp+0x11>
		n--, p++, q++;
  800a54:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a58:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a5c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a60:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a64:	74 1a                	je     800a80 <strncmp+0x31>
  800a66:	8b 45 08             	mov    0x8(%ebp),%eax
  800a69:	0f b6 00             	movzbl (%eax),%eax
  800a6c:	84 c0                	test   %al,%al
  800a6e:	74 10                	je     800a80 <strncmp+0x31>
  800a70:	8b 45 08             	mov    0x8(%ebp),%eax
  800a73:	0f b6 10             	movzbl (%eax),%edx
  800a76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a79:	0f b6 00             	movzbl (%eax),%eax
  800a7c:	38 c2                	cmp    %al,%dl
  800a7e:	74 d4                	je     800a54 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800a80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a84:	75 07                	jne    800a8d <strncmp+0x3e>
		return 0;
  800a86:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8b:	eb 16                	jmp    800aa3 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	0f b6 00             	movzbl (%eax),%eax
  800a93:	0f b6 d0             	movzbl %al,%edx
  800a96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a99:	0f b6 00             	movzbl (%eax),%eax
  800a9c:	0f b6 c0             	movzbl %al,%eax
  800a9f:	29 c2                	sub    %eax,%edx
  800aa1:	89 d0                	mov    %edx,%eax
}
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	83 ec 04             	sub    $0x4,%esp
  800aab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aae:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800ab1:	eb 14                	jmp    800ac7 <strchr+0x22>
		if (*s == c)
  800ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab6:	0f b6 00             	movzbl (%eax),%eax
  800ab9:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800abc:	75 05                	jne    800ac3 <strchr+0x1e>
			return (char *) s;
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac1:	eb 13                	jmp    800ad6 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ac3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aca:	0f b6 00             	movzbl (%eax),%eax
  800acd:	84 c0                	test   %al,%al
  800acf:	75 e2                	jne    800ab3 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad6:	c9                   	leave  
  800ad7:	c3                   	ret    

00800ad8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	83 ec 04             	sub    $0x4,%esp
  800ade:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae1:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800ae4:	eb 11                	jmp    800af7 <strfind+0x1f>
		if (*s == c)
  800ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae9:	0f b6 00             	movzbl (%eax),%eax
  800aec:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800aef:	75 02                	jne    800af3 <strfind+0x1b>
			break;
  800af1:	eb 0e                	jmp    800b01 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800af3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800af7:	8b 45 08             	mov    0x8(%ebp),%eax
  800afa:	0f b6 00             	movzbl (%eax),%eax
  800afd:	84 c0                	test   %al,%al
  800aff:	75 e5                	jne    800ae6 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800b01:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b04:	c9                   	leave  
  800b05:	c3                   	ret    

00800b06 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
	char *p;

	if (n == 0)
  800b0a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b0e:	75 05                	jne    800b15 <memset+0xf>
		return v;
  800b10:	8b 45 08             	mov    0x8(%ebp),%eax
  800b13:	eb 5c                	jmp    800b71 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800b15:	8b 45 08             	mov    0x8(%ebp),%eax
  800b18:	83 e0 03             	and    $0x3,%eax
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	75 41                	jne    800b60 <memset+0x5a>
  800b1f:	8b 45 10             	mov    0x10(%ebp),%eax
  800b22:	83 e0 03             	and    $0x3,%eax
  800b25:	85 c0                	test   %eax,%eax
  800b27:	75 37                	jne    800b60 <memset+0x5a>
		c &= 0xFF;
  800b29:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b33:	c1 e0 18             	shl    $0x18,%eax
  800b36:	89 c2                	mov    %eax,%edx
  800b38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3b:	c1 e0 10             	shl    $0x10,%eax
  800b3e:	09 c2                	or     %eax,%edx
  800b40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b43:	c1 e0 08             	shl    $0x8,%eax
  800b46:	09 d0                	or     %edx,%eax
  800b48:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b4b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4e:	c1 e8 02             	shr    $0x2,%eax
  800b51:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b53:	8b 55 08             	mov    0x8(%ebp),%edx
  800b56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b59:	89 d7                	mov    %edx,%edi
  800b5b:	fc                   	cld    
  800b5c:	f3 ab                	rep stos %eax,%es:(%edi)
  800b5e:	eb 0e                	jmp    800b6e <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b60:	8b 55 08             	mov    0x8(%ebp),%edx
  800b63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b66:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b69:	89 d7                	mov    %edx,%edi
  800b6b:	fc                   	cld    
  800b6c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800b6e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	53                   	push   %ebx
  800b7a:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b80:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800b83:	8b 45 08             	mov    0x8(%ebp),%eax
  800b86:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800b89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b8c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b8f:	73 6d                	jae    800bfe <memmove+0x8a>
  800b91:	8b 45 10             	mov    0x10(%ebp),%eax
  800b94:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b97:	01 d0                	add    %edx,%eax
  800b99:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b9c:	76 60                	jbe    800bfe <memmove+0x8a>
		s += n;
  800b9e:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba1:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800ba4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba7:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800baa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bad:	83 e0 03             	and    $0x3,%eax
  800bb0:	85 c0                	test   %eax,%eax
  800bb2:	75 2f                	jne    800be3 <memmove+0x6f>
  800bb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bb7:	83 e0 03             	and    $0x3,%eax
  800bba:	85 c0                	test   %eax,%eax
  800bbc:	75 25                	jne    800be3 <memmove+0x6f>
  800bbe:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc1:	83 e0 03             	and    $0x3,%eax
  800bc4:	85 c0                	test   %eax,%eax
  800bc6:	75 1b                	jne    800be3 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bcb:	83 e8 04             	sub    $0x4,%eax
  800bce:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bd1:	83 ea 04             	sub    $0x4,%edx
  800bd4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bd7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bda:	89 c7                	mov    %eax,%edi
  800bdc:	89 d6                	mov    %edx,%esi
  800bde:	fd                   	std    
  800bdf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800be1:	eb 18                	jmp    800bfb <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800be3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800be6:	8d 50 ff             	lea    -0x1(%eax),%edx
  800be9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bec:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bef:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf2:	89 d7                	mov    %edx,%edi
  800bf4:	89 de                	mov    %ebx,%esi
  800bf6:	89 c1                	mov    %eax,%ecx
  800bf8:	fd                   	std    
  800bf9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bfb:	fc                   	cld    
  800bfc:	eb 45                	jmp    800c43 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c01:	83 e0 03             	and    $0x3,%eax
  800c04:	85 c0                	test   %eax,%eax
  800c06:	75 2b                	jne    800c33 <memmove+0xbf>
  800c08:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c0b:	83 e0 03             	and    $0x3,%eax
  800c0e:	85 c0                	test   %eax,%eax
  800c10:	75 21                	jne    800c33 <memmove+0xbf>
  800c12:	8b 45 10             	mov    0x10(%ebp),%eax
  800c15:	83 e0 03             	and    $0x3,%eax
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	75 17                	jne    800c33 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c1f:	c1 e8 02             	shr    $0x2,%eax
  800c22:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c24:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c27:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c2a:	89 c7                	mov    %eax,%edi
  800c2c:	89 d6                	mov    %edx,%esi
  800c2e:	fc                   	cld    
  800c2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c31:	eb 10                	jmp    800c43 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c33:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c36:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c39:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c3c:	89 c7                	mov    %eax,%edi
  800c3e:	89 d6                	mov    %edx,%esi
  800c40:	fc                   	cld    
  800c41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800c43:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c46:	83 c4 10             	add    $0x10,%esp
  800c49:	5b                   	pop    %ebx
  800c4a:	5e                   	pop    %esi
  800c4b:	5f                   	pop    %edi
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c54:	8b 45 10             	mov    0x10(%ebp),%eax
  800c57:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c62:	8b 45 08             	mov    0x8(%ebp),%eax
  800c65:	89 04 24             	mov    %eax,(%esp)
  800c68:	e8 07 ff ff ff       	call   800b74 <memmove>
}
  800c6d:	c9                   	leave  
  800c6e:	c3                   	ret    

00800c6f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800c75:	8b 45 08             	mov    0x8(%ebp),%eax
  800c78:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800c7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c7e:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800c81:	eb 30                	jmp    800cb3 <memcmp+0x44>
		if (*s1 != *s2)
  800c83:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c86:	0f b6 10             	movzbl (%eax),%edx
  800c89:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c8c:	0f b6 00             	movzbl (%eax),%eax
  800c8f:	38 c2                	cmp    %al,%dl
  800c91:	74 18                	je     800cab <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800c93:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c96:	0f b6 00             	movzbl (%eax),%eax
  800c99:	0f b6 d0             	movzbl %al,%edx
  800c9c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c9f:	0f b6 00             	movzbl (%eax),%eax
  800ca2:	0f b6 c0             	movzbl %al,%eax
  800ca5:	29 c2                	sub    %eax,%edx
  800ca7:	89 d0                	mov    %edx,%eax
  800ca9:	eb 1a                	jmp    800cc5 <memcmp+0x56>
		s1++, s2++;
  800cab:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800caf:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cb3:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb6:	8d 50 ff             	lea    -0x1(%eax),%edx
  800cb9:	89 55 10             	mov    %edx,0x10(%ebp)
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	75 c3                	jne    800c83 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc5:	c9                   	leave  
  800cc6:	c3                   	ret    

00800cc7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800ccd:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd3:	01 d0                	add    %edx,%eax
  800cd5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800cd8:	eb 13                	jmp    800ced <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cda:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdd:	0f b6 10             	movzbl (%eax),%edx
  800ce0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce3:	38 c2                	cmp    %al,%dl
  800ce5:	75 02                	jne    800ce9 <memfind+0x22>
			break;
  800ce7:	eb 0c                	jmp    800cf5 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ce9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ced:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800cf3:	72 e5                	jb     800cda <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800cf5:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cf8:	c9                   	leave  
  800cf9:	c3                   	ret    

00800cfa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800d00:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800d07:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d0e:	eb 04                	jmp    800d14 <strtol+0x1a>
		s++;
  800d10:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d14:	8b 45 08             	mov    0x8(%ebp),%eax
  800d17:	0f b6 00             	movzbl (%eax),%eax
  800d1a:	3c 20                	cmp    $0x20,%al
  800d1c:	74 f2                	je     800d10 <strtol+0x16>
  800d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d21:	0f b6 00             	movzbl (%eax),%eax
  800d24:	3c 09                	cmp    $0x9,%al
  800d26:	74 e8                	je     800d10 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d28:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2b:	0f b6 00             	movzbl (%eax),%eax
  800d2e:	3c 2b                	cmp    $0x2b,%al
  800d30:	75 06                	jne    800d38 <strtol+0x3e>
		s++;
  800d32:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d36:	eb 15                	jmp    800d4d <strtol+0x53>
	else if (*s == '-')
  800d38:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3b:	0f b6 00             	movzbl (%eax),%eax
  800d3e:	3c 2d                	cmp    $0x2d,%al
  800d40:	75 0b                	jne    800d4d <strtol+0x53>
		s++, neg = 1;
  800d42:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d46:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d4d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d51:	74 06                	je     800d59 <strtol+0x5f>
  800d53:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800d57:	75 24                	jne    800d7d <strtol+0x83>
  800d59:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5c:	0f b6 00             	movzbl (%eax),%eax
  800d5f:	3c 30                	cmp    $0x30,%al
  800d61:	75 1a                	jne    800d7d <strtol+0x83>
  800d63:	8b 45 08             	mov    0x8(%ebp),%eax
  800d66:	83 c0 01             	add    $0x1,%eax
  800d69:	0f b6 00             	movzbl (%eax),%eax
  800d6c:	3c 78                	cmp    $0x78,%al
  800d6e:	75 0d                	jne    800d7d <strtol+0x83>
		s += 2, base = 16;
  800d70:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800d74:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800d7b:	eb 2a                	jmp    800da7 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800d7d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d81:	75 17                	jne    800d9a <strtol+0xa0>
  800d83:	8b 45 08             	mov    0x8(%ebp),%eax
  800d86:	0f b6 00             	movzbl (%eax),%eax
  800d89:	3c 30                	cmp    $0x30,%al
  800d8b:	75 0d                	jne    800d9a <strtol+0xa0>
		s++, base = 8;
  800d8d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d91:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d98:	eb 0d                	jmp    800da7 <strtol+0xad>
	else if (base == 0)
  800d9a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d9e:	75 07                	jne    800da7 <strtol+0xad>
		base = 10;
  800da0:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800da7:	8b 45 08             	mov    0x8(%ebp),%eax
  800daa:	0f b6 00             	movzbl (%eax),%eax
  800dad:	3c 2f                	cmp    $0x2f,%al
  800daf:	7e 1b                	jle    800dcc <strtol+0xd2>
  800db1:	8b 45 08             	mov    0x8(%ebp),%eax
  800db4:	0f b6 00             	movzbl (%eax),%eax
  800db7:	3c 39                	cmp    $0x39,%al
  800db9:	7f 11                	jg     800dcc <strtol+0xd2>
			dig = *s - '0';
  800dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbe:	0f b6 00             	movzbl (%eax),%eax
  800dc1:	0f be c0             	movsbl %al,%eax
  800dc4:	83 e8 30             	sub    $0x30,%eax
  800dc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800dca:	eb 48                	jmp    800e14 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800dcc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcf:	0f b6 00             	movzbl (%eax),%eax
  800dd2:	3c 60                	cmp    $0x60,%al
  800dd4:	7e 1b                	jle    800df1 <strtol+0xf7>
  800dd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd9:	0f b6 00             	movzbl (%eax),%eax
  800ddc:	3c 7a                	cmp    $0x7a,%al
  800dde:	7f 11                	jg     800df1 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800de0:	8b 45 08             	mov    0x8(%ebp),%eax
  800de3:	0f b6 00             	movzbl (%eax),%eax
  800de6:	0f be c0             	movsbl %al,%eax
  800de9:	83 e8 57             	sub    $0x57,%eax
  800dec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800def:	eb 23                	jmp    800e14 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800df1:	8b 45 08             	mov    0x8(%ebp),%eax
  800df4:	0f b6 00             	movzbl (%eax),%eax
  800df7:	3c 40                	cmp    $0x40,%al
  800df9:	7e 3d                	jle    800e38 <strtol+0x13e>
  800dfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfe:	0f b6 00             	movzbl (%eax),%eax
  800e01:	3c 5a                	cmp    $0x5a,%al
  800e03:	7f 33                	jg     800e38 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800e05:	8b 45 08             	mov    0x8(%ebp),%eax
  800e08:	0f b6 00             	movzbl (%eax),%eax
  800e0b:	0f be c0             	movsbl %al,%eax
  800e0e:	83 e8 37             	sub    $0x37,%eax
  800e11:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e17:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e1a:	7c 02                	jl     800e1e <strtol+0x124>
			break;
  800e1c:	eb 1a                	jmp    800e38 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800e1e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e22:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e25:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e29:	89 c2                	mov    %eax,%edx
  800e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e2e:	01 d0                	add    %edx,%eax
  800e30:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800e33:	e9 6f ff ff ff       	jmp    800da7 <strtol+0xad>

	if (endptr)
  800e38:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e3c:	74 08                	je     800e46 <strtol+0x14c>
		*endptr = (char *) s;
  800e3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e41:	8b 55 08             	mov    0x8(%ebp),%edx
  800e44:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800e46:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e4a:	74 07                	je     800e53 <strtol+0x159>
  800e4c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e4f:	f7 d8                	neg    %eax
  800e51:	eb 03                	jmp    800e56 <strtol+0x15c>
  800e53:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800e56:	c9                   	leave  
  800e57:	c3                   	ret    

00800e58 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	57                   	push   %edi
  800e5c:	56                   	push   %esi
  800e5d:	53                   	push   %ebx
  800e5e:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e61:	8b 45 08             	mov    0x8(%ebp),%eax
  800e64:	8b 55 10             	mov    0x10(%ebp),%edx
  800e67:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800e6a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800e6d:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800e70:	8b 75 20             	mov    0x20(%ebp),%esi
  800e73:	cd 30                	int    $0x30
  800e75:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e78:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e7c:	74 30                	je     800eae <syscall+0x56>
  800e7e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e82:	7e 2a                	jle    800eae <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e87:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e92:	c7 44 24 08 44 1c 80 	movl   $0x801c44,0x8(%esp)
  800e99:	00 
  800e9a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea1:	00 
  800ea2:	c7 04 24 61 1c 80 00 	movl   $0x801c61,(%esp)
  800ea9:	e8 7f 07 00 00       	call   80162d <_panic>

	return ret;
  800eae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800eb1:	83 c4 3c             	add    $0x3c,%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800ebf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec2:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ec9:	00 
  800eca:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ed1:	00 
  800ed2:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ed9:	00 
  800eda:	8b 55 0c             	mov    0xc(%ebp),%edx
  800edd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ee1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ee5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800eec:	00 
  800eed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ef4:	e8 5f ff ff ff       	call   800e58 <syscall>
}
  800ef9:	c9                   	leave  
  800efa:	c3                   	ret    

00800efb <sys_cgetc>:

int
sys_cgetc(void)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f01:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f08:	00 
  800f09:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f10:	00 
  800f11:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f18:	00 
  800f19:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f20:	00 
  800f21:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f28:	00 
  800f29:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f30:	00 
  800f31:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800f38:	e8 1b ff ff ff       	call   800e58 <syscall>
}
  800f3d:	c9                   	leave  
  800f3e:	c3                   	ret    

00800f3f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800f45:	8b 45 08             	mov    0x8(%ebp),%eax
  800f48:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f4f:	00 
  800f50:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f57:	00 
  800f58:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f5f:	00 
  800f60:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f67:	00 
  800f68:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f6c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f73:	00 
  800f74:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800f7b:	e8 d8 fe ff ff       	call   800e58 <syscall>
}
  800f80:	c9                   	leave  
  800f81:	c3                   	ret    

00800f82 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
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
  800fb8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800fbf:	e8 94 fe ff ff       	call   800e58 <syscall>
}
  800fc4:	c9                   	leave  
  800fc5:	c3                   	ret    

00800fc6 <sys_yield>:

void
sys_yield(void)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800fcc:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fd3:	00 
  800fd4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fdb:	00 
  800fdc:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fe3:	00 
  800fe4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800feb:	00 
  800fec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ff3:	00 
  800ff4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ffb:	00 
  800ffc:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  801003:	e8 50 fe ff ff       	call   800e58 <syscall>
}
  801008:	c9                   	leave  
  801009:	c3                   	ret    

0080100a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801010:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801013:	8b 55 0c             	mov    0xc(%ebp),%edx
  801016:	8b 45 08             	mov    0x8(%ebp),%eax
  801019:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801020:	00 
  801021:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801028:	00 
  801029:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80102d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801031:	89 44 24 08          	mov    %eax,0x8(%esp)
  801035:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80103c:	00 
  80103d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  801044:	e8 0f fe ff ff       	call   800e58 <syscall>
}
  801049:	c9                   	leave  
  80104a:	c3                   	ret    

0080104b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	56                   	push   %esi
  80104f:	53                   	push   %ebx
  801050:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  801053:	8b 75 18             	mov    0x18(%ebp),%esi
  801056:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801059:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80105c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80105f:	8b 45 08             	mov    0x8(%ebp),%eax
  801062:	89 74 24 18          	mov    %esi,0x18(%esp)
  801066:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80106a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80106e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801072:	89 44 24 08          	mov    %eax,0x8(%esp)
  801076:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80107d:	00 
  80107e:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  801085:	e8 ce fd ff ff       	call   800e58 <syscall>
}
  80108a:	83 c4 20             	add    $0x20,%esp
  80108d:	5b                   	pop    %ebx
  80108e:	5e                   	pop    %esi
  80108f:	5d                   	pop    %ebp
  801090:	c3                   	ret    

00801091 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801097:	8b 55 0c             	mov    0xc(%ebp),%edx
  80109a:	8b 45 08             	mov    0x8(%ebp),%eax
  80109d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010a4:	00 
  8010a5:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010ac:	00 
  8010ad:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010b4:	00 
  8010b5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010bd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010c4:	00 
  8010c5:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  8010cc:	e8 87 fd ff ff       	call   800e58 <syscall>
}
  8010d1:	c9                   	leave  
  8010d2:	c3                   	ret    

008010d3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8010d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010df:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010e6:	00 
  8010e7:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010ee:	00 
  8010ef:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010f6:	00 
  8010f7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010ff:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801106:	00 
  801107:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  80110e:	e8 45 fd ff ff       	call   800e58 <syscall>
}
  801113:	c9                   	leave  
  801114:	c3                   	ret    

00801115 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80111b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80111e:	8b 45 08             	mov    0x8(%ebp),%eax
  801121:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801128:	00 
  801129:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801130:	00 
  801131:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801138:	00 
  801139:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80113d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801141:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801148:	00 
  801149:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  801150:	e8 03 fd ff ff       	call   800e58 <syscall>
}
  801155:	c9                   	leave  
  801156:	c3                   	ret    

00801157 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80115d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801160:	8b 55 10             	mov    0x10(%ebp),%edx
  801163:	8b 45 08             	mov    0x8(%ebp),%eax
  801166:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80116d:	00 
  80116e:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801172:	89 54 24 10          	mov    %edx,0x10(%esp)
  801176:	8b 55 0c             	mov    0xc(%ebp),%edx
  801179:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80117d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801181:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801188:	00 
  801189:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  801190:	e8 c3 fc ff ff       	call   800e58 <syscall>
}
  801195:	c9                   	leave  
  801196:	c3                   	ret    

00801197 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80119d:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a0:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011a7:	00 
  8011a8:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011af:	00 
  8011b0:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011b7:	00 
  8011b8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011bf:	00 
  8011c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011cb:	00 
  8011cc:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  8011d3:	e8 80 fc ff ff       	call   800e58 <syscall>
}
  8011d8:	c9                   	leave  
  8011d9:	c3                   	ret    

008011da <pgfault>:
// map in our own private writable copy.
//

static void
pgfault(struct UTrapframe *utf)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  8011e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e3:	8b 00                	mov    (%eax),%eax
  8011e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  8011e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011eb:	8b 40 04             	mov    0x4(%eax),%eax
  8011ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	uint32_t t = PGNUM(addr);
  8011f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f4:	c1 e8 0c             	shr    $0xc,%eax
  8011f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
	pte_t pte = uvpt[t];
  8011fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8011fd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801204:	89 45 e8             	mov    %eax,-0x18(%ebp)
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  801207:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120a:	83 e0 02             	and    $0x2,%eax
  80120d:	85 c0                	test   %eax,%eax
  80120f:	74 0c                	je     80121d <pgfault+0x43>
  801211:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801214:	25 00 08 00 00       	and    $0x800,%eax
  801219:	85 c0                	test   %eax,%eax
  80121b:	75 1c                	jne    801239 <pgfault+0x5f>
		panic("permission denied in copy on write pgfault handler\n");
  80121d:	c7 44 24 08 70 1c 80 	movl   $0x801c70,0x8(%esp)
  801224:	00 
  801225:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80122c:	00 
  80122d:	c7 04 24 a4 1c 80 00 	movl   $0x801ca4,(%esp)
  801234:	e8 f4 03 00 00       	call   80162d <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	r = sys_page_alloc(0,PFTEMP,PTE_P|PTE_U|PTE_W);
  801239:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801240:	00 
  801241:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801248:	00 
  801249:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801250:	e8 b5 fd ff ff       	call   80100a <sys_page_alloc>
  801255:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if(r < 0)
  801258:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80125c:	79 1c                	jns    80127a <pgfault+0xa0>
	{
		panic("page cant be allocated\n");
  80125e:	c7 44 24 08 af 1c 80 	movl   $0x801caf,0x8(%esp)
  801265:	00 
  801266:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80126d:	00 
  80126e:	c7 04 24 a4 1c 80 00 	movl   $0x801ca4,(%esp)
  801275:	e8 b3 03 00 00       	call   80162d <_panic>
	}
	memmove(PFTEMP, ROUNDDOWN(addr,PGSIZE), PGSIZE);
  80127a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80127d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801280:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801283:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801288:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80128f:	00 
  801290:	89 44 24 04          	mov    %eax,0x4(%esp)
  801294:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80129b:	e8 d4 f8 ff ff       	call   800b74 <memmove>
	int r1 = sys_page_map(0,PFTEMP,0,ROUNDDOWN(addr,PGSIZE),PTE_W|PTE_U|PTE_P);
  8012a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8012a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012a9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012ae:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8012b5:	00 
  8012b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012ba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012c1:	00 
  8012c2:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012c9:	00 
  8012ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012d1:	e8 75 fd ff ff       	call   80104b <sys_page_map>
  8012d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
	if(r1 < 0)
  8012d9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8012dd:	79 1c                	jns    8012fb <pgfault+0x121>
	{
		panic("page cant be mapped\n");
  8012df:	c7 44 24 08 c7 1c 80 	movl   $0x801cc7,0x8(%esp)
  8012e6:	00 
  8012e7:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  8012ee:	00 
  8012ef:	c7 04 24 a4 1c 80 00 	movl   $0x801ca4,(%esp)
  8012f6:	e8 32 03 00 00       	call   80162d <_panic>
	}	

	// panic("pgfault not implemented");
}
  8012fb:	c9                   	leave  
  8012fc:	c3                   	ret    

008012fd <duppage>:
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
static int
duppage(envid_t envid, unsigned pn)
{
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
  801300:	83 ec 48             	sub    $0x48,%esp
	int r;
	
	// LAB 4: Your code here.
	uint32_t t = uvpt[pn];
  801303:	8b 45 0c             	mov    0xc(%ebp),%eax
  801306:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80130d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	void *va_pn = (void *)(pn*PGSIZE);
  801310:	8b 45 0c             	mov    0xc(%ebp),%eax
  801313:	c1 e0 0c             	shl    $0xc,%eax
  801316:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if((t && PTE_W) || (t && PTE_COW))
  801319:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80131d:	75 0a                	jne    801329 <duppage+0x2c>
  80131f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801323:	0f 84 ed 00 00 00    	je     801416 <duppage+0x119>
	{
		r = sys_page_map(0,va_pn,envid,va_pn,PTE_P|PTE_U|PTE_COW);
  801329:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801330:	00 
  801331:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801334:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801338:	8b 45 08             	mov    0x8(%ebp),%eax
  80133b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80133f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801342:	89 44 24 04          	mov    %eax,0x4(%esp)
  801346:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80134d:	e8 f9 fc ff ff       	call   80104b <sys_page_map>
  801352:	89 45 e8             	mov    %eax,-0x18(%ebp)
		if(r < 0)
  801355:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801359:	79 1c                	jns    801377 <duppage+0x7a>
		{
			panic("error in page map\n");
  80135b:	c7 44 24 08 dc 1c 80 	movl   $0x801cdc,0x8(%esp)
  801362:	00 
  801363:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  80136a:	00 
  80136b:	c7 04 24 a4 1c 80 00 	movl   $0x801ca4,(%esp)
  801372:	e8 b6 02 00 00       	call   80162d <_panic>
		}
		int r1 = sys_page_map(envid,va_pn,0,va_pn,PTE_P|PTE_U|PTE_COW);
  801377:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80137e:	00 
  80137f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801382:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801386:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80138d:	00 
  80138e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801391:	89 44 24 04          	mov    %eax,0x4(%esp)
  801395:	8b 45 08             	mov    0x8(%ebp),%eax
  801398:	89 04 24             	mov    %eax,(%esp)
  80139b:	e8 ab fc ff ff       	call   80104b <sys_page_map>
  8013a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if(r1 < 0)
  8013a3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8013a7:	79 1c                	jns    8013c5 <duppage+0xc8>
		{
			panic("error in page map\n");
  8013a9:	c7 44 24 08 dc 1c 80 	movl   $0x801cdc,0x8(%esp)
  8013b0:	00 
  8013b1:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8013b8:	00 
  8013b9:	c7 04 24 a4 1c 80 00 	movl   $0x801ca4,(%esp)
  8013c0:	e8 68 02 00 00       	call   80162d <_panic>
		}
		int r2 = sys_page_map(0,va_pn,0,va_pn,PTE_P|PTE_U|PTE_COW);
  8013c5:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8013cc:	00 
  8013cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013db:	00 
  8013dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013ea:	e8 5c fc ff ff       	call   80104b <sys_page_map>
  8013ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
		if(r2 < 0)
  8013f2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013f6:	79 1c                	jns    801414 <duppage+0x117>
		{
			panic("error in page map\n");
  8013f8:	c7 44 24 08 dc 1c 80 	movl   $0x801cdc,0x8(%esp)
  8013ff:	00 
  801400:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  801407:	00 
  801408:	c7 04 24 a4 1c 80 00 	movl   $0x801ca4,(%esp)
  80140f:	e8 19 02 00 00       	call   80162d <_panic>
	
	// LAB 4: Your code here.
	uint32_t t = uvpt[pn];
	void *va_pn = (void *)(pn*PGSIZE);
	if((t && PTE_W) || (t && PTE_COW))
	{
  801414:	eb 4e                	jmp    801464 <duppage+0x167>
			panic("error in page map\n");
		}
	}
	else
	{
		int r3 = sys_page_map(0,va_pn,envid,va_pn,PTE_U|PTE_P);
  801416:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80141d:	00 
  80141e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801421:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801425:	8b 45 08             	mov    0x8(%ebp),%eax
  801428:	89 44 24 08          	mov    %eax,0x8(%esp)
  80142c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801433:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80143a:	e8 0c fc ff ff       	call   80104b <sys_page_map>
  80143f:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if(r3 < 0)
  801442:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801446:	79 1c                	jns    801464 <duppage+0x167>
		{
			panic("error in page map\n");
  801448:	c7 44 24 08 dc 1c 80 	movl   $0x801cdc,0x8(%esp)
  80144f:	00 
  801450:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  801457:	00 
  801458:	c7 04 24 a4 1c 80 00 	movl   $0x801ca4,(%esp)
  80145f:	e8 c9 01 00 00       	call   80162d <_panic>
		}
	}
	// panic("duppage not implemented");
	return 0;
  801464:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801469:	c9                   	leave  
  80146a:	c3                   	ret    

0080146b <fork>:


envid_t
fork(void)
{
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
  80146e:	83 ec 38             	sub    $0x38,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801471:	c7 04 24 da 11 80 00 	movl   $0x8011da,(%esp)
  801478:	e8 0b 02 00 00       	call   801688 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80147d:	b8 07 00 00 00       	mov    $0x7,%eax
  801482:	cd 30                	int    $0x30
  801484:	89 45 e0             	mov    %eax,-0x20(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  801487:	8b 45 e0             	mov    -0x20(%ebp),%eax
	envid_t envid = sys_exofork();
  80148a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (envid < 0)
  80148d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801491:	79 1c                	jns    8014af <fork+0x44>
	{
		panic("sys_exofork not succeeded\n");
  801493:	c7 44 24 08 ef 1c 80 	movl   $0x801cef,0x8(%esp)
  80149a:	00 
  80149b:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
  8014a2:	00 
  8014a3:	c7 04 24 a4 1c 80 00 	movl   $0x801ca4,(%esp)
  8014aa:	e8 7e 01 00 00       	call   80162d <_panic>
	}
	if (envid == 0)
  8014af:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8014b3:	75 29                	jne    8014de <fork+0x73>
	{	
		thisenv = &envs[ENVX(sys_getenvid())];
  8014b5:	e8 c8 fa ff ff       	call   800f82 <sys_getenvid>
  8014ba:	25 ff 03 00 00       	and    $0x3ff,%eax
  8014bf:	c1 e0 02             	shl    $0x2,%eax
  8014c2:	89 c2                	mov    %eax,%edx
  8014c4:	c1 e2 05             	shl    $0x5,%edx
  8014c7:	29 c2                	sub    %eax,%edx
  8014c9:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  8014cf:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  8014d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d9:	e9 2b 01 00 00       	jmp    801609 <fork+0x19e>
	}
	else
	{
		int p;
		for (p = 0; p < PGNUM(UTOP); p++) 
  8014de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  8014e5:	e9 9a 00 00 00       	jmp    801584 <fork+0x119>
		{
			if(p == PGNUM(UTOP) - 1)
  8014ea:	81 7d f4 ff eb 0e 00 	cmpl   $0xeebff,-0xc(%ebp)
  8014f1:	75 42                	jne    801535 <fork+0xca>
			{
				int r1 = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE), PTE_P|PTE_W|PTE_U);
  8014f3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8014fa:	00 
  8014fb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801502:	ee 
  801503:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801506:	89 04 24             	mov    %eax,(%esp)
  801509:	e8 fc fa ff ff       	call   80100a <sys_page_alloc>
  80150e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  				if(r1 < 0)
  801511:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801515:	79 1c                	jns    801533 <fork+0xc8>
  				{
    				panic("sys_page_alloc failed\n");
  801517:	c7 44 24 08 0a 1d 80 	movl   $0x801d0a,0x8(%esp)
  80151e:	00 
  80151f:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801526:	00 
  801527:	c7 04 24 a4 1c 80 00 	movl   $0x801ca4,(%esp)
  80152e:	e8 fa 00 00 00       	call   80162d <_panic>
				}
				break;
  801533:	eb 5d                	jmp    801592 <fork+0x127>
			}
			if((uvpd[PDX(p*PGSIZE)]&PTE_P))
  801535:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801538:	c1 e0 0c             	shl    $0xc,%eax
  80153b:	c1 e8 16             	shr    $0x16,%eax
  80153e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801545:	83 e0 01             	and    $0x1,%eax
  801548:	85 c0                	test   %eax,%eax
  80154a:	74 34                	je     801580 <fork+0x115>
			{
				if((uvpt[p]&PTE_P) && (uvpt[p] & PTE_U))
  80154c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801556:	83 e0 01             	and    $0x1,%eax
  801559:	85 c0                	test   %eax,%eax
  80155b:	74 23                	je     801580 <fork+0x115>
  80155d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801560:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801567:	83 e0 04             	and    $0x4,%eax
  80156a:	85 c0                	test   %eax,%eax
  80156c:	74 12                	je     801580 <fork+0x115>
				{
					duppage(envid, p);
  80156e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801571:	89 44 24 04          	mov    %eax,0x4(%esp)
  801575:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801578:	89 04 24             	mov    %eax,(%esp)
  80157b:	e8 7d fd ff ff       	call   8012fd <duppage>
		return 0;
	}
	else
	{
		int p;
		for (p = 0; p < PGNUM(UTOP); p++) 
  801580:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  801584:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801587:	3d ff eb 0e 00       	cmp    $0xeebff,%eax
  80158c:	0f 86 58 ff ff ff    	jbe    8014ea <fork+0x7f>
				}
			}	
		}
  		
		extern void _pgfault_upcall();
		int r = sys_env_set_pgfault_upcall(envid,thisenv->env_pgfault_upcall);
  801592:	a1 04 20 80 00       	mov    0x802004,%eax
  801597:	8b 40 64             	mov    0x64(%eax),%eax
  80159a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80159e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a1:	89 04 24             	mov    %eax,(%esp)
  8015a4:	e8 6c fb ff ff       	call   801115 <sys_env_set_pgfault_upcall>
  8015a9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    	if(r < 0)
  8015ac:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8015b0:	79 1c                	jns    8015ce <fork+0x163>
    	{
    		panic("sys_env_set_pgfault_upcall failed\n");
  8015b2:	c7 44 24 08 24 1d 80 	movl   $0x801d24,0x8(%esp)
  8015b9:	00 
  8015ba:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  8015c1:	00 
  8015c2:	c7 04 24 a4 1c 80 00 	movl   $0x801ca4,(%esp)
  8015c9:	e8 5f 00 00 00       	call   80162d <_panic>
    	}
  		int r2 = sys_env_set_status(envid, ENV_RUNNABLE);
  8015ce:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8015d5:	00 
  8015d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d9:	89 04 24             	mov    %eax,(%esp)
  8015dc:	e8 f2 fa ff ff       	call   8010d3 <sys_env_set_status>
  8015e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  		if(r2 < 0)
  8015e4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8015e8:	79 1c                	jns    801606 <fork+0x19b>
  		{
    		panic("sys_env_set_status failes\n");
  8015ea:	c7 44 24 08 47 1d 80 	movl   $0x801d47,0x8(%esp)
  8015f1:	00 
  8015f2:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  8015f9:	00 
  8015fa:	c7 04 24 a4 1c 80 00 	movl   $0x801ca4,(%esp)
  801601:	e8 27 00 00 00       	call   80162d <_panic>
    	}
  		return envid;
  801606:	8b 45 f0             	mov    -0x10(%ebp),%eax
	}


	// panic("fork not implemented");
}
  801609:	c9                   	leave  
  80160a:	c3                   	ret    

0080160b <sfork>:


// Challenge!
int
sfork(void)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801611:	c7 44 24 08 62 1d 80 	movl   $0x801d62,0x8(%esp)
  801618:	00 
  801619:	c7 44 24 04 a8 00 00 	movl   $0xa8,0x4(%esp)
  801620:	00 
  801621:	c7 04 24 a4 1c 80 00 	movl   $0x801ca4,(%esp)
  801628:	e8 00 00 00 00       	call   80162d <_panic>

0080162d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80162d:	55                   	push   %ebp
  80162e:	89 e5                	mov    %esp,%ebp
  801630:	53                   	push   %ebx
  801631:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  801634:	8d 45 14             	lea    0x14(%ebp),%eax
  801637:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80163a:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801640:	e8 3d f9 ff ff       	call   800f82 <sys_getenvid>
  801645:	8b 55 0c             	mov    0xc(%ebp),%edx
  801648:	89 54 24 10          	mov    %edx,0x10(%esp)
  80164c:	8b 55 08             	mov    0x8(%ebp),%edx
  80164f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801653:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801657:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165b:	c7 04 24 78 1d 80 00 	movl   $0x801d78,(%esp)
  801662:	e8 ad eb ff ff       	call   800214 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801667:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166e:	8b 45 10             	mov    0x10(%ebp),%eax
  801671:	89 04 24             	mov    %eax,(%esp)
  801674:	e8 37 eb ff ff       	call   8001b0 <vcprintf>
	cprintf("\n");
  801679:	c7 04 24 9b 1d 80 00 	movl   $0x801d9b,(%esp)
  801680:	e8 8f eb ff ff       	call   800214 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801685:	cc                   	int3   
  801686:	eb fd                	jmp    801685 <_panic+0x58>

00801688 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  80168e:	a1 08 20 80 00       	mov    0x802008,%eax
  801693:	85 c0                	test   %eax,%eax
  801695:	75 55                	jne    8016ec <set_pgfault_handler+0x64>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE),PTE_U|PTE_P|PTE_W);
  801697:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80169e:	00 
  80169f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8016a6:	ee 
  8016a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016ae:	e8 57 f9 ff ff       	call   80100a <sys_page_alloc>
  8016b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(r < 0)
  8016b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8016ba:	79 1c                	jns    8016d8 <set_pgfault_handler+0x50>
		{
			panic("sys_page_alloc_failed");
  8016bc:	c7 44 24 08 9d 1d 80 	movl   $0x801d9d,0x8(%esp)
  8016c3:	00 
  8016c4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8016cb:	00 
  8016cc:	c7 04 24 b3 1d 80 00 	movl   $0x801db3,(%esp)
  8016d3:	e8 55 ff ff ff       	call   80162d <_panic>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8016d8:	c7 44 24 04 f6 16 80 	movl   $0x8016f6,0x4(%esp)
  8016df:	00 
  8016e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016e7:	e8 29 fa ff ff       	call   801115 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8016ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ef:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8016f4:	c9                   	leave  
  8016f5:	c3                   	ret    

008016f6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8016f6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8016f7:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8016fc:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8016fe:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x30(%esp), %eax
  801701:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  801705:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801708:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 0x28(%esp), %ecx
  80170c:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	movl %ecx, (%eax)
  801710:	89 08                	mov    %ecx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	//add $8, %esp
	popl %edx 
  801712:	5a                   	pop    %edx
	popl %edx
  801713:	5a                   	pop    %edx
	popal
  801714:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp
  801715:	83 c4 04             	add    $0x4,%esp
	popf
  801718:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801719:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80171a:	c3                   	ret    
  80171b:	66 90                	xchg   %ax,%ax
  80171d:	66 90                	xchg   %ax,%ax
  80171f:	90                   	nop

00801720 <__udivdi3>:
  801720:	55                   	push   %ebp
  801721:	57                   	push   %edi
  801722:	56                   	push   %esi
  801723:	83 ec 0c             	sub    $0xc,%esp
  801726:	8b 44 24 28          	mov    0x28(%esp),%eax
  80172a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80172e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801732:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801736:	85 c0                	test   %eax,%eax
  801738:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80173c:	89 ea                	mov    %ebp,%edx
  80173e:	89 0c 24             	mov    %ecx,(%esp)
  801741:	75 2d                	jne    801770 <__udivdi3+0x50>
  801743:	39 e9                	cmp    %ebp,%ecx
  801745:	77 61                	ja     8017a8 <__udivdi3+0x88>
  801747:	85 c9                	test   %ecx,%ecx
  801749:	89 ce                	mov    %ecx,%esi
  80174b:	75 0b                	jne    801758 <__udivdi3+0x38>
  80174d:	b8 01 00 00 00       	mov    $0x1,%eax
  801752:	31 d2                	xor    %edx,%edx
  801754:	f7 f1                	div    %ecx
  801756:	89 c6                	mov    %eax,%esi
  801758:	31 d2                	xor    %edx,%edx
  80175a:	89 e8                	mov    %ebp,%eax
  80175c:	f7 f6                	div    %esi
  80175e:	89 c5                	mov    %eax,%ebp
  801760:	89 f8                	mov    %edi,%eax
  801762:	f7 f6                	div    %esi
  801764:	89 ea                	mov    %ebp,%edx
  801766:	83 c4 0c             	add    $0xc,%esp
  801769:	5e                   	pop    %esi
  80176a:	5f                   	pop    %edi
  80176b:	5d                   	pop    %ebp
  80176c:	c3                   	ret    
  80176d:	8d 76 00             	lea    0x0(%esi),%esi
  801770:	39 e8                	cmp    %ebp,%eax
  801772:	77 24                	ja     801798 <__udivdi3+0x78>
  801774:	0f bd e8             	bsr    %eax,%ebp
  801777:	83 f5 1f             	xor    $0x1f,%ebp
  80177a:	75 3c                	jne    8017b8 <__udivdi3+0x98>
  80177c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801780:	39 34 24             	cmp    %esi,(%esp)
  801783:	0f 86 9f 00 00 00    	jbe    801828 <__udivdi3+0x108>
  801789:	39 d0                	cmp    %edx,%eax
  80178b:	0f 82 97 00 00 00    	jb     801828 <__udivdi3+0x108>
  801791:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801798:	31 d2                	xor    %edx,%edx
  80179a:	31 c0                	xor    %eax,%eax
  80179c:	83 c4 0c             	add    $0xc,%esp
  80179f:	5e                   	pop    %esi
  8017a0:	5f                   	pop    %edi
  8017a1:	5d                   	pop    %ebp
  8017a2:	c3                   	ret    
  8017a3:	90                   	nop
  8017a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8017a8:	89 f8                	mov    %edi,%eax
  8017aa:	f7 f1                	div    %ecx
  8017ac:	31 d2                	xor    %edx,%edx
  8017ae:	83 c4 0c             	add    $0xc,%esp
  8017b1:	5e                   	pop    %esi
  8017b2:	5f                   	pop    %edi
  8017b3:	5d                   	pop    %ebp
  8017b4:	c3                   	ret    
  8017b5:	8d 76 00             	lea    0x0(%esi),%esi
  8017b8:	89 e9                	mov    %ebp,%ecx
  8017ba:	8b 3c 24             	mov    (%esp),%edi
  8017bd:	d3 e0                	shl    %cl,%eax
  8017bf:	89 c6                	mov    %eax,%esi
  8017c1:	b8 20 00 00 00       	mov    $0x20,%eax
  8017c6:	29 e8                	sub    %ebp,%eax
  8017c8:	89 c1                	mov    %eax,%ecx
  8017ca:	d3 ef                	shr    %cl,%edi
  8017cc:	89 e9                	mov    %ebp,%ecx
  8017ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8017d2:	8b 3c 24             	mov    (%esp),%edi
  8017d5:	09 74 24 08          	or     %esi,0x8(%esp)
  8017d9:	89 d6                	mov    %edx,%esi
  8017db:	d3 e7                	shl    %cl,%edi
  8017dd:	89 c1                	mov    %eax,%ecx
  8017df:	89 3c 24             	mov    %edi,(%esp)
  8017e2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8017e6:	d3 ee                	shr    %cl,%esi
  8017e8:	89 e9                	mov    %ebp,%ecx
  8017ea:	d3 e2                	shl    %cl,%edx
  8017ec:	89 c1                	mov    %eax,%ecx
  8017ee:	d3 ef                	shr    %cl,%edi
  8017f0:	09 d7                	or     %edx,%edi
  8017f2:	89 f2                	mov    %esi,%edx
  8017f4:	89 f8                	mov    %edi,%eax
  8017f6:	f7 74 24 08          	divl   0x8(%esp)
  8017fa:	89 d6                	mov    %edx,%esi
  8017fc:	89 c7                	mov    %eax,%edi
  8017fe:	f7 24 24             	mull   (%esp)
  801801:	39 d6                	cmp    %edx,%esi
  801803:	89 14 24             	mov    %edx,(%esp)
  801806:	72 30                	jb     801838 <__udivdi3+0x118>
  801808:	8b 54 24 04          	mov    0x4(%esp),%edx
  80180c:	89 e9                	mov    %ebp,%ecx
  80180e:	d3 e2                	shl    %cl,%edx
  801810:	39 c2                	cmp    %eax,%edx
  801812:	73 05                	jae    801819 <__udivdi3+0xf9>
  801814:	3b 34 24             	cmp    (%esp),%esi
  801817:	74 1f                	je     801838 <__udivdi3+0x118>
  801819:	89 f8                	mov    %edi,%eax
  80181b:	31 d2                	xor    %edx,%edx
  80181d:	e9 7a ff ff ff       	jmp    80179c <__udivdi3+0x7c>
  801822:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801828:	31 d2                	xor    %edx,%edx
  80182a:	b8 01 00 00 00       	mov    $0x1,%eax
  80182f:	e9 68 ff ff ff       	jmp    80179c <__udivdi3+0x7c>
  801834:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801838:	8d 47 ff             	lea    -0x1(%edi),%eax
  80183b:	31 d2                	xor    %edx,%edx
  80183d:	83 c4 0c             	add    $0xc,%esp
  801840:	5e                   	pop    %esi
  801841:	5f                   	pop    %edi
  801842:	5d                   	pop    %ebp
  801843:	c3                   	ret    
  801844:	66 90                	xchg   %ax,%ax
  801846:	66 90                	xchg   %ax,%ax
  801848:	66 90                	xchg   %ax,%ax
  80184a:	66 90                	xchg   %ax,%ax
  80184c:	66 90                	xchg   %ax,%ax
  80184e:	66 90                	xchg   %ax,%ax

00801850 <__umoddi3>:
  801850:	55                   	push   %ebp
  801851:	57                   	push   %edi
  801852:	56                   	push   %esi
  801853:	83 ec 14             	sub    $0x14,%esp
  801856:	8b 44 24 28          	mov    0x28(%esp),%eax
  80185a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80185e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801862:	89 c7                	mov    %eax,%edi
  801864:	89 44 24 04          	mov    %eax,0x4(%esp)
  801868:	8b 44 24 30          	mov    0x30(%esp),%eax
  80186c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801870:	89 34 24             	mov    %esi,(%esp)
  801873:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801877:	85 c0                	test   %eax,%eax
  801879:	89 c2                	mov    %eax,%edx
  80187b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80187f:	75 17                	jne    801898 <__umoddi3+0x48>
  801881:	39 fe                	cmp    %edi,%esi
  801883:	76 4b                	jbe    8018d0 <__umoddi3+0x80>
  801885:	89 c8                	mov    %ecx,%eax
  801887:	89 fa                	mov    %edi,%edx
  801889:	f7 f6                	div    %esi
  80188b:	89 d0                	mov    %edx,%eax
  80188d:	31 d2                	xor    %edx,%edx
  80188f:	83 c4 14             	add    $0x14,%esp
  801892:	5e                   	pop    %esi
  801893:	5f                   	pop    %edi
  801894:	5d                   	pop    %ebp
  801895:	c3                   	ret    
  801896:	66 90                	xchg   %ax,%ax
  801898:	39 f8                	cmp    %edi,%eax
  80189a:	77 54                	ja     8018f0 <__umoddi3+0xa0>
  80189c:	0f bd e8             	bsr    %eax,%ebp
  80189f:	83 f5 1f             	xor    $0x1f,%ebp
  8018a2:	75 5c                	jne    801900 <__umoddi3+0xb0>
  8018a4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8018a8:	39 3c 24             	cmp    %edi,(%esp)
  8018ab:	0f 87 e7 00 00 00    	ja     801998 <__umoddi3+0x148>
  8018b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8018b5:	29 f1                	sub    %esi,%ecx
  8018b7:	19 c7                	sbb    %eax,%edi
  8018b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8018c1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8018c5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8018c9:	83 c4 14             	add    $0x14,%esp
  8018cc:	5e                   	pop    %esi
  8018cd:	5f                   	pop    %edi
  8018ce:	5d                   	pop    %ebp
  8018cf:	c3                   	ret    
  8018d0:	85 f6                	test   %esi,%esi
  8018d2:	89 f5                	mov    %esi,%ebp
  8018d4:	75 0b                	jne    8018e1 <__umoddi3+0x91>
  8018d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8018db:	31 d2                	xor    %edx,%edx
  8018dd:	f7 f6                	div    %esi
  8018df:	89 c5                	mov    %eax,%ebp
  8018e1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8018e5:	31 d2                	xor    %edx,%edx
  8018e7:	f7 f5                	div    %ebp
  8018e9:	89 c8                	mov    %ecx,%eax
  8018eb:	f7 f5                	div    %ebp
  8018ed:	eb 9c                	jmp    80188b <__umoddi3+0x3b>
  8018ef:	90                   	nop
  8018f0:	89 c8                	mov    %ecx,%eax
  8018f2:	89 fa                	mov    %edi,%edx
  8018f4:	83 c4 14             	add    $0x14,%esp
  8018f7:	5e                   	pop    %esi
  8018f8:	5f                   	pop    %edi
  8018f9:	5d                   	pop    %ebp
  8018fa:	c3                   	ret    
  8018fb:	90                   	nop
  8018fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801900:	8b 04 24             	mov    (%esp),%eax
  801903:	be 20 00 00 00       	mov    $0x20,%esi
  801908:	89 e9                	mov    %ebp,%ecx
  80190a:	29 ee                	sub    %ebp,%esi
  80190c:	d3 e2                	shl    %cl,%edx
  80190e:	89 f1                	mov    %esi,%ecx
  801910:	d3 e8                	shr    %cl,%eax
  801912:	89 e9                	mov    %ebp,%ecx
  801914:	89 44 24 04          	mov    %eax,0x4(%esp)
  801918:	8b 04 24             	mov    (%esp),%eax
  80191b:	09 54 24 04          	or     %edx,0x4(%esp)
  80191f:	89 fa                	mov    %edi,%edx
  801921:	d3 e0                	shl    %cl,%eax
  801923:	89 f1                	mov    %esi,%ecx
  801925:	89 44 24 08          	mov    %eax,0x8(%esp)
  801929:	8b 44 24 10          	mov    0x10(%esp),%eax
  80192d:	d3 ea                	shr    %cl,%edx
  80192f:	89 e9                	mov    %ebp,%ecx
  801931:	d3 e7                	shl    %cl,%edi
  801933:	89 f1                	mov    %esi,%ecx
  801935:	d3 e8                	shr    %cl,%eax
  801937:	89 e9                	mov    %ebp,%ecx
  801939:	09 f8                	or     %edi,%eax
  80193b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80193f:	f7 74 24 04          	divl   0x4(%esp)
  801943:	d3 e7                	shl    %cl,%edi
  801945:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801949:	89 d7                	mov    %edx,%edi
  80194b:	f7 64 24 08          	mull   0x8(%esp)
  80194f:	39 d7                	cmp    %edx,%edi
  801951:	89 c1                	mov    %eax,%ecx
  801953:	89 14 24             	mov    %edx,(%esp)
  801956:	72 2c                	jb     801984 <__umoddi3+0x134>
  801958:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80195c:	72 22                	jb     801980 <__umoddi3+0x130>
  80195e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801962:	29 c8                	sub    %ecx,%eax
  801964:	19 d7                	sbb    %edx,%edi
  801966:	89 e9                	mov    %ebp,%ecx
  801968:	89 fa                	mov    %edi,%edx
  80196a:	d3 e8                	shr    %cl,%eax
  80196c:	89 f1                	mov    %esi,%ecx
  80196e:	d3 e2                	shl    %cl,%edx
  801970:	89 e9                	mov    %ebp,%ecx
  801972:	d3 ef                	shr    %cl,%edi
  801974:	09 d0                	or     %edx,%eax
  801976:	89 fa                	mov    %edi,%edx
  801978:	83 c4 14             	add    $0x14,%esp
  80197b:	5e                   	pop    %esi
  80197c:	5f                   	pop    %edi
  80197d:	5d                   	pop    %ebp
  80197e:	c3                   	ret    
  80197f:	90                   	nop
  801980:	39 d7                	cmp    %edx,%edi
  801982:	75 da                	jne    80195e <__umoddi3+0x10e>
  801984:	8b 14 24             	mov    (%esp),%edx
  801987:	89 c1                	mov    %eax,%ecx
  801989:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80198d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801991:	eb cb                	jmp    80195e <__umoddi3+0x10e>
  801993:	90                   	nop
  801994:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801998:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80199c:	0f 82 0f ff ff ff    	jb     8018b1 <__umoddi3+0x61>
  8019a2:	e9 1a ff ff ff       	jmp    8018c1 <__umoddi3+0x71>
