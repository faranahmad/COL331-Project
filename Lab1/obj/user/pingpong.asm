
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 d6 00 00 00       	call   800107 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 24             	sub    $0x24,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003a:	e8 41 14 00 00       	call   801480 <fork>
  80003f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800042:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800045:	85 c0                	test   %eax,%eax
  800047:	74 3f                	je     800088 <umain+0x55>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800049:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80004c:	e8 46 0f 00 00       	call   800f97 <sys_getenvid>
  800051:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 c0 1b 80 00 	movl   $0x801bc0,(%esp)
  800060:	e8 c4 01 00 00       	call   800229 <cprintf>
		ipc_send(who, 0, 0, 0);
  800065:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800068:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006f:	00 
  800070:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800077:	00 
  800078:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007f:	00 
  800080:	89 04 24             	mov    %eax,(%esp)
  800083:	e8 56 16 00 00       	call   8016de <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800088:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80008f:	00 
  800090:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800097:	00 
  800098:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80009b:	89 04 24             	mov    %eax,(%esp)
  80009e:	e8 9f 15 00 00       	call   801642 <ipc_recv>
  8000a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a6:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8000a9:	e8 e9 0e 00 00       	call   800f97 <sys_getenvid>
  8000ae:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8000b5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000bd:	c7 04 24 d6 1b 80 00 	movl   $0x801bd6,(%esp)
  8000c4:	e8 60 01 00 00       	call   800229 <cprintf>
		if (i == 10)
  8000c9:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
  8000cd:	75 02                	jne    8000d1 <umain+0x9e>
			return;
  8000cf:	eb 30                	jmp    800101 <umain+0xce>
		i++;
  8000d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		ipc_send(who, i, 0, 0);
  8000d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000d8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000df:	00 
  8000e0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000e7:	00 
  8000e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8000eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8000ef:	89 04 24             	mov    %eax,(%esp)
  8000f2:	e8 e7 15 00 00       	call   8016de <ipc_send>
		if (i == 10)
  8000f7:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
  8000fb:	75 02                	jne    8000ff <umain+0xcc>
			return;
  8000fd:	eb 02                	jmp    800101 <umain+0xce>
	}
  8000ff:	eb 87                	jmp    800088 <umain+0x55>

}
  800101:	83 c4 24             	add    $0x24,%esp
  800104:	5b                   	pop    %ebx
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80010d:	e8 85 0e 00 00       	call   800f97 <sys_getenvid>
  800112:	25 ff 03 00 00       	and    $0x3ff,%eax
  800117:	c1 e0 02             	shl    $0x2,%eax
  80011a:	89 c2                	mov    %eax,%edx
  80011c:	c1 e2 05             	shl    $0x5,%edx
  80011f:	29 c2                	sub    %eax,%edx
  800121:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  800127:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800130:	7e 0a                	jle    80013c <libmain+0x35>
		binaryname = argv[0];
  800132:	8b 45 0c             	mov    0xc(%ebp),%eax
  800135:	8b 00                	mov    (%eax),%eax
  800137:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80013c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800143:	8b 45 08             	mov    0x8(%ebp),%eax
  800146:	89 04 24             	mov    %eax,(%esp)
  800149:	e8 e5 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80014e:	e8 02 00 00 00       	call   800155 <exit>
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80015b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800162:	e8 ed 0d 00 00       	call   800f54 <sys_env_destroy>
}
  800167:	c9                   	leave  
  800168:	c3                   	ret    

00800169 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  80016f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800172:	8b 00                	mov    (%eax),%eax
  800174:	8d 48 01             	lea    0x1(%eax),%ecx
  800177:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017a:	89 0a                	mov    %ecx,(%edx)
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	89 d1                	mov    %edx,%ecx
  800181:	8b 55 0c             	mov    0xc(%ebp),%edx
  800184:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800188:	8b 45 0c             	mov    0xc(%ebp),%eax
  80018b:	8b 00                	mov    (%eax),%eax
  80018d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800192:	75 20                	jne    8001b4 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800194:	8b 45 0c             	mov    0xc(%ebp),%eax
  800197:	8b 00                	mov    (%eax),%eax
  800199:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019c:	83 c2 08             	add    $0x8,%edx
  80019f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a3:	89 14 24             	mov    %edx,(%esp)
  8001a6:	e8 23 0d 00 00       	call   800ece <sys_cputs>
		b->idx = 0;
  8001ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ae:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8001b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b7:	8b 40 04             	mov    0x4(%eax),%eax
  8001ba:	8d 50 01             	lea    0x1(%eax),%edx
  8001bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c0:	89 50 04             	mov    %edx,0x4(%eax)
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ce:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d5:	00 00 00 
	b.cnt = 0;
  8001d8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001df:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fa:	c7 04 24 69 01 80 00 	movl   $0x800169,(%esp)
  800201:	e8 bd 01 00 00       	call   8003c3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800206:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80020c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800210:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800216:	83 c0 08             	add    $0x8,%eax
  800219:	89 04 24             	mov    %eax,(%esp)
  80021c:	e8 ad 0c 00 00       	call   800ece <sys_cputs>

	return b.cnt;
  800221:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022f:	8d 45 0c             	lea    0xc(%ebp),%eax
  800232:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800235:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023c:	8b 45 08             	mov    0x8(%ebp),%eax
  80023f:	89 04 24             	mov    %eax,(%esp)
  800242:	e8 7e ff ff ff       	call   8001c5 <vcprintf>
  800247:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80024a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80024d:	c9                   	leave  
  80024e:	c3                   	ret    

0080024f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	53                   	push   %ebx
  800253:	83 ec 34             	sub    $0x34,%esp
  800256:	8b 45 10             	mov    0x10(%ebp),%eax
  800259:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80025c:	8b 45 14             	mov    0x14(%ebp),%eax
  80025f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800262:	8b 45 18             	mov    0x18(%ebp),%eax
  800265:	ba 00 00 00 00       	mov    $0x0,%edx
  80026a:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80026d:	77 72                	ja     8002e1 <printnum+0x92>
  80026f:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800272:	72 05                	jb     800279 <printnum+0x2a>
  800274:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800277:	77 68                	ja     8002e1 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800279:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80027c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80027f:	8b 45 18             	mov    0x18(%ebp),%eax
  800282:	ba 00 00 00 00       	mov    $0x0,%edx
  800287:	89 44 24 08          	mov    %eax,0x8(%esp)
  80028b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80028f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800292:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800295:	89 04 24             	mov    %eax,(%esp)
  800298:	89 54 24 04          	mov    %edx,0x4(%esp)
  80029c:	e8 8f 16 00 00       	call   801930 <__udivdi3>
  8002a1:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8002a4:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8002a8:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002ac:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002af:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c5:	89 04 24             	mov    %eax,(%esp)
  8002c8:	e8 82 ff ff ff       	call   80024f <printnum>
  8002cd:	eb 1c                	jmp    8002eb <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d6:	8b 45 20             	mov    0x20(%ebp),%eax
  8002d9:	89 04 24             	mov    %eax,(%esp)
  8002dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002df:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e1:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8002e5:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8002e9:	7f e4                	jg     8002cf <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002eb:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8002f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002fd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800301:	89 04 24             	mov    %eax,(%esp)
  800304:	89 54 24 04          	mov    %edx,0x4(%esp)
  800308:	e8 53 17 00 00       	call   801a60 <__umoddi3>
  80030d:	05 c8 1c 80 00       	add    $0x801cc8,%eax
  800312:	0f b6 00             	movzbl (%eax),%eax
  800315:	0f be c0             	movsbl %al,%eax
  800318:	8b 55 0c             	mov    0xc(%ebp),%edx
  80031b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80031f:	89 04 24             	mov    %eax,(%esp)
  800322:	8b 45 08             	mov    0x8(%ebp),%eax
  800325:	ff d0                	call   *%eax
}
  800327:	83 c4 34             	add    $0x34,%esp
  80032a:	5b                   	pop    %ebx
  80032b:	5d                   	pop    %ebp
  80032c:	c3                   	ret    

0080032d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800330:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800334:	7e 14                	jle    80034a <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800336:	8b 45 08             	mov    0x8(%ebp),%eax
  800339:	8b 00                	mov    (%eax),%eax
  80033b:	8d 48 08             	lea    0x8(%eax),%ecx
  80033e:	8b 55 08             	mov    0x8(%ebp),%edx
  800341:	89 0a                	mov    %ecx,(%edx)
  800343:	8b 50 04             	mov    0x4(%eax),%edx
  800346:	8b 00                	mov    (%eax),%eax
  800348:	eb 30                	jmp    80037a <getuint+0x4d>
	else if (lflag)
  80034a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80034e:	74 16                	je     800366 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800350:	8b 45 08             	mov    0x8(%ebp),%eax
  800353:	8b 00                	mov    (%eax),%eax
  800355:	8d 48 04             	lea    0x4(%eax),%ecx
  800358:	8b 55 08             	mov    0x8(%ebp),%edx
  80035b:	89 0a                	mov    %ecx,(%edx)
  80035d:	8b 00                	mov    (%eax),%eax
  80035f:	ba 00 00 00 00       	mov    $0x0,%edx
  800364:	eb 14                	jmp    80037a <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800366:	8b 45 08             	mov    0x8(%ebp),%eax
  800369:	8b 00                	mov    (%eax),%eax
  80036b:	8d 48 04             	lea    0x4(%eax),%ecx
  80036e:	8b 55 08             	mov    0x8(%ebp),%edx
  800371:	89 0a                	mov    %ecx,(%edx)
  800373:	8b 00                	mov    (%eax),%eax
  800375:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037a:	5d                   	pop    %ebp
  80037b:	c3                   	ret    

0080037c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80037f:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800383:	7e 14                	jle    800399 <getint+0x1d>
		return va_arg(*ap, long long);
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	8b 00                	mov    (%eax),%eax
  80038a:	8d 48 08             	lea    0x8(%eax),%ecx
  80038d:	8b 55 08             	mov    0x8(%ebp),%edx
  800390:	89 0a                	mov    %ecx,(%edx)
  800392:	8b 50 04             	mov    0x4(%eax),%edx
  800395:	8b 00                	mov    (%eax),%eax
  800397:	eb 28                	jmp    8003c1 <getint+0x45>
	else if (lflag)
  800399:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80039d:	74 12                	je     8003b1 <getint+0x35>
		return va_arg(*ap, long);
  80039f:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a2:	8b 00                	mov    (%eax),%eax
  8003a4:	8d 48 04             	lea    0x4(%eax),%ecx
  8003a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003aa:	89 0a                	mov    %ecx,(%edx)
  8003ac:	8b 00                	mov    (%eax),%eax
  8003ae:	99                   	cltd   
  8003af:	eb 10                	jmp    8003c1 <getint+0x45>
	else
		return va_arg(*ap, int);
  8003b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b4:	8b 00                	mov    (%eax),%eax
  8003b6:	8d 48 04             	lea    0x4(%eax),%ecx
  8003b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003bc:	89 0a                	mov    %ecx,(%edx)
  8003be:	8b 00                	mov    (%eax),%eax
  8003c0:	99                   	cltd   
}
  8003c1:	5d                   	pop    %ebp
  8003c2:	c3                   	ret    

008003c3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	56                   	push   %esi
  8003c7:	53                   	push   %ebx
  8003c8:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003cb:	eb 18                	jmp    8003e5 <vprintfmt+0x22>
			if (ch == '\0')
  8003cd:	85 db                	test   %ebx,%ebx
  8003cf:	75 05                	jne    8003d6 <vprintfmt+0x13>
				return;
  8003d1:	e9 05 04 00 00       	jmp    8007db <vprintfmt+0x418>
			putch(ch, putdat);
  8003d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003dd:	89 1c 24             	mov    %ebx,(%esp)
  8003e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e3:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8003e8:	8d 50 01             	lea    0x1(%eax),%edx
  8003eb:	89 55 10             	mov    %edx,0x10(%ebp)
  8003ee:	0f b6 00             	movzbl (%eax),%eax
  8003f1:	0f b6 d8             	movzbl %al,%ebx
  8003f4:	83 fb 25             	cmp    $0x25,%ebx
  8003f7:	75 d4                	jne    8003cd <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8003f9:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8003fd:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800404:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80040b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800412:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 45 10             	mov    0x10(%ebp),%eax
  80041c:	8d 50 01             	lea    0x1(%eax),%edx
  80041f:	89 55 10             	mov    %edx,0x10(%ebp)
  800422:	0f b6 00             	movzbl (%eax),%eax
  800425:	0f b6 d8             	movzbl %al,%ebx
  800428:	8d 43 dd             	lea    -0x23(%ebx),%eax
  80042b:	83 f8 55             	cmp    $0x55,%eax
  80042e:	0f 87 76 03 00 00    	ja     8007aa <vprintfmt+0x3e7>
  800434:	8b 04 85 ec 1c 80 00 	mov    0x801cec(,%eax,4),%eax
  80043b:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  80043d:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800441:	eb d6                	jmp    800419 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800443:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800447:	eb d0                	jmp    800419 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800449:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800450:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800453:	89 d0                	mov    %edx,%eax
  800455:	c1 e0 02             	shl    $0x2,%eax
  800458:	01 d0                	add    %edx,%eax
  80045a:	01 c0                	add    %eax,%eax
  80045c:	01 d8                	add    %ebx,%eax
  80045e:	83 e8 30             	sub    $0x30,%eax
  800461:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800464:	8b 45 10             	mov    0x10(%ebp),%eax
  800467:	0f b6 00             	movzbl (%eax),%eax
  80046a:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80046d:	83 fb 2f             	cmp    $0x2f,%ebx
  800470:	7e 0b                	jle    80047d <vprintfmt+0xba>
  800472:	83 fb 39             	cmp    $0x39,%ebx
  800475:	7f 06                	jg     80047d <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800477:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80047b:	eb d3                	jmp    800450 <vprintfmt+0x8d>
			goto process_precision;
  80047d:	eb 33                	jmp    8004b2 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  80047f:	8b 45 14             	mov    0x14(%ebp),%eax
  800482:	8d 50 04             	lea    0x4(%eax),%edx
  800485:	89 55 14             	mov    %edx,0x14(%ebp)
  800488:	8b 00                	mov    (%eax),%eax
  80048a:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80048d:	eb 23                	jmp    8004b2 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80048f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800493:	79 0c                	jns    8004a1 <vprintfmt+0xde>
				width = 0;
  800495:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80049c:	e9 78 ff ff ff       	jmp    800419 <vprintfmt+0x56>
  8004a1:	e9 73 ff ff ff       	jmp    800419 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8004a6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004ad:	e9 67 ff ff ff       	jmp    800419 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8004b2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004b6:	79 12                	jns    8004ca <vprintfmt+0x107>
				width = precision, precision = -1;
  8004b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004be:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8004c5:	e9 4f ff ff ff       	jmp    800419 <vprintfmt+0x56>
  8004ca:	e9 4a ff ff ff       	jmp    800419 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004cf:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8004d3:	e9 41 ff ff ff       	jmp    800419 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004db:	8d 50 04             	lea    0x4(%eax),%edx
  8004de:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e1:	8b 00                	mov    (%eax),%eax
  8004e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004e6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004ea:	89 04 24             	mov    %eax,(%esp)
  8004ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f0:	ff d0                	call   *%eax
			break;
  8004f2:	e9 de 02 00 00       	jmp    8007d5 <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8d 50 04             	lea    0x4(%eax),%edx
  8004fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800500:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800502:	85 db                	test   %ebx,%ebx
  800504:	79 02                	jns    800508 <vprintfmt+0x145>
				err = -err;
  800506:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800508:	83 fb 09             	cmp    $0x9,%ebx
  80050b:	7f 0b                	jg     800518 <vprintfmt+0x155>
  80050d:	8b 34 9d a0 1c 80 00 	mov    0x801ca0(,%ebx,4),%esi
  800514:	85 f6                	test   %esi,%esi
  800516:	75 23                	jne    80053b <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800518:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80051c:	c7 44 24 08 d9 1c 80 	movl   $0x801cd9,0x8(%esp)
  800523:	00 
  800524:	8b 45 0c             	mov    0xc(%ebp),%eax
  800527:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052b:	8b 45 08             	mov    0x8(%ebp),%eax
  80052e:	89 04 24             	mov    %eax,(%esp)
  800531:	e8 ac 02 00 00       	call   8007e2 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800536:	e9 9a 02 00 00       	jmp    8007d5 <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80053b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80053f:	c7 44 24 08 e2 1c 80 	movl   $0x801ce2,0x8(%esp)
  800546:	00 
  800547:	8b 45 0c             	mov    0xc(%ebp),%eax
  80054a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054e:	8b 45 08             	mov    0x8(%ebp),%eax
  800551:	89 04 24             	mov    %eax,(%esp)
  800554:	e8 89 02 00 00       	call   8007e2 <printfmt>
			break;
  800559:	e9 77 02 00 00       	jmp    8007d5 <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8d 50 04             	lea    0x4(%eax),%edx
  800564:	89 55 14             	mov    %edx,0x14(%ebp)
  800567:	8b 30                	mov    (%eax),%esi
  800569:	85 f6                	test   %esi,%esi
  80056b:	75 05                	jne    800572 <vprintfmt+0x1af>
				p = "(null)";
  80056d:	be e5 1c 80 00       	mov    $0x801ce5,%esi
			if (width > 0 && padc != '-')
  800572:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800576:	7e 37                	jle    8005af <vprintfmt+0x1ec>
  800578:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80057c:	74 31                	je     8005af <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80057e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800581:	89 44 24 04          	mov    %eax,0x4(%esp)
  800585:	89 34 24             	mov    %esi,(%esp)
  800588:	e8 72 03 00 00       	call   8008ff <strnlen>
  80058d:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800590:	eb 17                	jmp    8005a9 <vprintfmt+0x1e6>
					putch(padc, putdat);
  800592:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800596:	8b 55 0c             	mov    0xc(%ebp),%edx
  800599:	89 54 24 04          	mov    %edx,0x4(%esp)
  80059d:	89 04 24             	mov    %eax,(%esp)
  8005a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a3:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a5:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005a9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ad:	7f e3                	jg     800592 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005af:	eb 38                	jmp    8005e9 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8005b1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b5:	74 1f                	je     8005d6 <vprintfmt+0x213>
  8005b7:	83 fb 1f             	cmp    $0x1f,%ebx
  8005ba:	7e 05                	jle    8005c1 <vprintfmt+0x1fe>
  8005bc:	83 fb 7e             	cmp    $0x7e,%ebx
  8005bf:	7e 15                	jle    8005d6 <vprintfmt+0x213>
					putch('?', putdat);
  8005c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d2:	ff d0                	call   *%eax
  8005d4:	eb 0f                	jmp    8005e5 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8005d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005dd:	89 1c 24             	mov    %ebx,(%esp)
  8005e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e3:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e5:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005e9:	89 f0                	mov    %esi,%eax
  8005eb:	8d 70 01             	lea    0x1(%eax),%esi
  8005ee:	0f b6 00             	movzbl (%eax),%eax
  8005f1:	0f be d8             	movsbl %al,%ebx
  8005f4:	85 db                	test   %ebx,%ebx
  8005f6:	74 10                	je     800608 <vprintfmt+0x245>
  8005f8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005fc:	78 b3                	js     8005b1 <vprintfmt+0x1ee>
  8005fe:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800602:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800606:	79 a9                	jns    8005b1 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800608:	eb 17                	jmp    800621 <vprintfmt+0x25e>
				putch(' ', putdat);
  80060a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80060d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800611:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800618:	8b 45 08             	mov    0x8(%ebp),%eax
  80061b:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80061d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800621:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800625:	7f e3                	jg     80060a <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800627:	e9 a9 01 00 00       	jmp    8007d5 <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80062c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80062f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
  800636:	89 04 24             	mov    %eax,(%esp)
  800639:	e8 3e fd ff ff       	call   80037c <getint>
  80063e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800641:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800644:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800647:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80064a:	85 d2                	test   %edx,%edx
  80064c:	79 26                	jns    800674 <vprintfmt+0x2b1>
				putch('-', putdat);
  80064e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800651:	89 44 24 04          	mov    %eax,0x4(%esp)
  800655:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80065c:	8b 45 08             	mov    0x8(%ebp),%eax
  80065f:	ff d0                	call   *%eax
				num = -(long long) num;
  800661:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800664:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800667:	f7 d8                	neg    %eax
  800669:	83 d2 00             	adc    $0x0,%edx
  80066c:	f7 da                	neg    %edx
  80066e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800671:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800674:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80067b:	e9 e1 00 00 00       	jmp    800761 <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800680:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800683:	89 44 24 04          	mov    %eax,0x4(%esp)
  800687:	8d 45 14             	lea    0x14(%ebp),%eax
  80068a:	89 04 24             	mov    %eax,(%esp)
  80068d:	e8 9b fc ff ff       	call   80032d <getuint>
  800692:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800695:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800698:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80069f:	e9 bd 00 00 00       	jmp    800761 <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  8006a4:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  8006ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b5:	89 04 24             	mov    %eax,(%esp)
  8006b8:	e8 70 fc ff ff       	call   80032d <getuint>
  8006bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006c0:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  8006c3:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8006c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ca:	89 54 24 18          	mov    %edx,0x18(%esp)
  8006ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006d1:	89 54 24 14          	mov    %edx,0x14(%esp)
  8006d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f1:	89 04 24             	mov    %eax,(%esp)
  8006f4:	e8 56 fb ff ff       	call   80024f <printnum>
			break;
  8006f9:	e9 d7 00 00 00       	jmp    8007d5 <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  8006fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800701:	89 44 24 04          	mov    %eax,0x4(%esp)
  800705:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80070c:	8b 45 08             	mov    0x8(%ebp),%eax
  80070f:	ff d0                	call   *%eax
			putch('x', putdat);
  800711:	8b 45 0c             	mov    0xc(%ebp),%eax
  800714:	89 44 24 04          	mov    %eax,0x4(%esp)
  800718:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80071f:	8b 45 08             	mov    0x8(%ebp),%eax
  800722:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800724:	8b 45 14             	mov    0x14(%ebp),%eax
  800727:	8d 50 04             	lea    0x4(%eax),%edx
  80072a:	89 55 14             	mov    %edx,0x14(%ebp)
  80072d:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80072f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800732:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800739:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800740:	eb 1f                	jmp    800761 <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800742:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800745:	89 44 24 04          	mov    %eax,0x4(%esp)
  800749:	8d 45 14             	lea    0x14(%ebp),%eax
  80074c:	89 04 24             	mov    %eax,(%esp)
  80074f:	e8 d9 fb ff ff       	call   80032d <getuint>
  800754:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800757:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  80075a:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800761:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800765:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800768:	89 54 24 18          	mov    %edx,0x18(%esp)
  80076c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80076f:	89 54 24 14          	mov    %edx,0x14(%esp)
  800773:	89 44 24 10          	mov    %eax,0x10(%esp)
  800777:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80077a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80077d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800781:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800785:	8b 45 0c             	mov    0xc(%ebp),%eax
  800788:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078c:	8b 45 08             	mov    0x8(%ebp),%eax
  80078f:	89 04 24             	mov    %eax,(%esp)
  800792:	e8 b8 fa ff ff       	call   80024f <printnum>
			break;
  800797:	eb 3c                	jmp    8007d5 <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800799:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a0:	89 1c 24             	mov    %ebx,(%esp)
  8007a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a6:	ff d0                	call   *%eax
			break;
  8007a8:	eb 2b                	jmp    8007d5 <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b1:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007bd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8007c1:	eb 04                	jmp    8007c7 <vprintfmt+0x404>
  8007c3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8007c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ca:	83 e8 01             	sub    $0x1,%eax
  8007cd:	0f b6 00             	movzbl (%eax),%eax
  8007d0:	3c 25                	cmp    $0x25,%al
  8007d2:	75 ef                	jne    8007c3 <vprintfmt+0x400>
				/* do nothing */;
			break;
  8007d4:	90                   	nop
		}
	}
  8007d5:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007d6:	e9 0a fc ff ff       	jmp    8003e5 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8007db:	83 c4 40             	add    $0x40,%esp
  8007de:	5b                   	pop    %ebx
  8007df:	5e                   	pop    %esi
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8007e8:	8d 45 14             	lea    0x14(%ebp),%eax
  8007eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8007ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	89 04 24             	mov    %eax,(%esp)
  800809:	e8 b5 fb ff ff       	call   8003c3 <vprintfmt>
	va_end(ap);
}
  80080e:	c9                   	leave  
  80080f:	c3                   	ret    

00800810 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800813:	8b 45 0c             	mov    0xc(%ebp),%eax
  800816:	8b 40 08             	mov    0x8(%eax),%eax
  800819:	8d 50 01             	lea    0x1(%eax),%edx
  80081c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081f:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800822:	8b 45 0c             	mov    0xc(%ebp),%eax
  800825:	8b 10                	mov    (%eax),%edx
  800827:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082a:	8b 40 04             	mov    0x4(%eax),%eax
  80082d:	39 c2                	cmp    %eax,%edx
  80082f:	73 12                	jae    800843 <sprintputch+0x33>
		*b->buf++ = ch;
  800831:	8b 45 0c             	mov    0xc(%ebp),%eax
  800834:	8b 00                	mov    (%eax),%eax
  800836:	8d 48 01             	lea    0x1(%eax),%ecx
  800839:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083c:	89 0a                	mov    %ecx,(%edx)
  80083e:	8b 55 08             	mov    0x8(%ebp),%edx
  800841:	88 10                	mov    %dl,(%eax)
}
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800851:	8b 45 0c             	mov    0xc(%ebp),%eax
  800854:	8d 50 ff             	lea    -0x1(%eax),%edx
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	01 d0                	add    %edx,%eax
  80085c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80085f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800866:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80086a:	74 06                	je     800872 <vsnprintf+0x2d>
  80086c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800870:	7f 07                	jg     800879 <vsnprintf+0x34>
		return -E_INVAL;
  800872:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800877:	eb 2a                	jmp    8008a3 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800879:	8b 45 14             	mov    0x14(%ebp),%eax
  80087c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800880:	8b 45 10             	mov    0x10(%ebp),%eax
  800883:	89 44 24 08          	mov    %eax,0x8(%esp)
  800887:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80088a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088e:	c7 04 24 10 08 80 00 	movl   $0x800810,(%esp)
  800895:	e8 29 fb ff ff       	call   8003c3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80089a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80089d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008a3:	c9                   	leave  
  8008a4:	c3                   	ret    

008008a5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8008bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	89 04 24             	mov    %eax,(%esp)
  8008cc:	e8 74 ff ff ff       	call   800845 <vsnprintf>
  8008d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  8008d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008d7:	c9                   	leave  
  8008d8:	c3                   	ret    

008008d9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  8008df:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008e6:	eb 08                	jmp    8008f0 <strlen+0x17>
		n++;
  8008e8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	0f b6 00             	movzbl (%eax),%eax
  8008f6:	84 c0                	test   %al,%al
  8008f8:	75 ee                	jne    8008e8 <strlen+0xf>
		n++;
	return n;
  8008fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008fd:	c9                   	leave  
  8008fe:	c3                   	ret    

008008ff <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800905:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80090c:	eb 0c                	jmp    80091a <strnlen+0x1b>
		n++;
  80090e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800912:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800916:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  80091a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80091e:	74 0a                	je     80092a <strnlen+0x2b>
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	0f b6 00             	movzbl (%eax),%eax
  800926:	84 c0                	test   %al,%al
  800928:	75 e4                	jne    80090e <strnlen+0xf>
		n++;
	return n;
  80092a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  80093b:	90                   	nop
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	8d 50 01             	lea    0x1(%eax),%edx
  800942:	89 55 08             	mov    %edx,0x8(%ebp)
  800945:	8b 55 0c             	mov    0xc(%ebp),%edx
  800948:	8d 4a 01             	lea    0x1(%edx),%ecx
  80094b:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  80094e:	0f b6 12             	movzbl (%edx),%edx
  800951:	88 10                	mov    %dl,(%eax)
  800953:	0f b6 00             	movzbl (%eax),%eax
  800956:	84 c0                	test   %al,%al
  800958:	75 e2                	jne    80093c <strcpy+0xd>
		/* do nothing */;
	return ret;
  80095a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80095d:	c9                   	leave  
  80095e:	c3                   	ret    

0080095f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	89 04 24             	mov    %eax,(%esp)
  80096b:	e8 69 ff ff ff       	call   8008d9 <strlen>
  800970:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800973:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	01 c2                	add    %eax,%edx
  80097b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800982:	89 14 24             	mov    %edx,(%esp)
  800985:	e8 a5 ff ff ff       	call   80092f <strcpy>
	return dst;
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80098d:	c9                   	leave  
  80098e:	c3                   	ret    

0080098f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  80099b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009a2:	eb 23                	jmp    8009c7 <strncpy+0x38>
		*dst++ = *src;
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8d 50 01             	lea    0x1(%eax),%edx
  8009aa:	89 55 08             	mov    %edx,0x8(%ebp)
  8009ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b0:	0f b6 12             	movzbl (%edx),%edx
  8009b3:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8009b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b8:	0f b6 00             	movzbl (%eax),%eax
  8009bb:	84 c0                	test   %al,%al
  8009bd:	74 04                	je     8009c3 <strncpy+0x34>
			src++;
  8009bf:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8009c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009ca:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009cd:	72 d5                	jb     8009a4 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8009cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8009d2:	c9                   	leave  
  8009d3:	c3                   	ret    

008009d4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  8009e0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009e4:	74 33                	je     800a19 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009e6:	eb 17                	jmp    8009ff <strlcpy+0x2b>
			*dst++ = *src++;
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	8d 50 01             	lea    0x1(%eax),%edx
  8009ee:	89 55 08             	mov    %edx,0x8(%ebp)
  8009f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009f7:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009fa:	0f b6 12             	movzbl (%edx),%edx
  8009fd:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009ff:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a03:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a07:	74 0a                	je     800a13 <strlcpy+0x3f>
  800a09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0c:	0f b6 00             	movzbl (%eax),%eax
  800a0f:	84 c0                	test   %al,%al
  800a11:	75 d5                	jne    8009e8 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800a13:	8b 45 08             	mov    0x8(%ebp),%eax
  800a16:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a19:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a1f:	29 c2                	sub    %eax,%edx
  800a21:	89 d0                	mov    %edx,%eax
}
  800a23:	c9                   	leave  
  800a24:	c3                   	ret    

00800a25 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a28:	eb 08                	jmp    800a32 <strcmp+0xd>
		p++, q++;
  800a2a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a2e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	0f b6 00             	movzbl (%eax),%eax
  800a38:	84 c0                	test   %al,%al
  800a3a:	74 10                	je     800a4c <strcmp+0x27>
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	0f b6 10             	movzbl (%eax),%edx
  800a42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a45:	0f b6 00             	movzbl (%eax),%eax
  800a48:	38 c2                	cmp    %al,%dl
  800a4a:	74 de                	je     800a2a <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	0f b6 00             	movzbl (%eax),%eax
  800a52:	0f b6 d0             	movzbl %al,%edx
  800a55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a58:	0f b6 00             	movzbl (%eax),%eax
  800a5b:	0f b6 c0             	movzbl %al,%eax
  800a5e:	29 c2                	sub    %eax,%edx
  800a60:	89 d0                	mov    %edx,%eax
}
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a67:	eb 0c                	jmp    800a75 <strncmp+0x11>
		n--, p++, q++;
  800a69:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a6d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a71:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a75:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a79:	74 1a                	je     800a95 <strncmp+0x31>
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	0f b6 00             	movzbl (%eax),%eax
  800a81:	84 c0                	test   %al,%al
  800a83:	74 10                	je     800a95 <strncmp+0x31>
  800a85:	8b 45 08             	mov    0x8(%ebp),%eax
  800a88:	0f b6 10             	movzbl (%eax),%edx
  800a8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8e:	0f b6 00             	movzbl (%eax),%eax
  800a91:	38 c2                	cmp    %al,%dl
  800a93:	74 d4                	je     800a69 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800a95:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a99:	75 07                	jne    800aa2 <strncmp+0x3e>
		return 0;
  800a9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa0:	eb 16                	jmp    800ab8 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa5:	0f b6 00             	movzbl (%eax),%eax
  800aa8:	0f b6 d0             	movzbl %al,%edx
  800aab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aae:	0f b6 00             	movzbl (%eax),%eax
  800ab1:	0f b6 c0             	movzbl %al,%eax
  800ab4:	29 c2                	sub    %eax,%edx
  800ab6:	89 d0                	mov    %edx,%eax
}
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	83 ec 04             	sub    $0x4,%esp
  800ac0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac3:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800ac6:	eb 14                	jmp    800adc <strchr+0x22>
		if (*s == c)
  800ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  800acb:	0f b6 00             	movzbl (%eax),%eax
  800ace:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ad1:	75 05                	jne    800ad8 <strchr+0x1e>
			return (char *) s;
  800ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad6:	eb 13                	jmp    800aeb <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ad8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800adc:	8b 45 08             	mov    0x8(%ebp),%eax
  800adf:	0f b6 00             	movzbl (%eax),%eax
  800ae2:	84 c0                	test   %al,%al
  800ae4:	75 e2                	jne    800ac8 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800ae6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aeb:	c9                   	leave  
  800aec:	c3                   	ret    

00800aed <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	83 ec 04             	sub    $0x4,%esp
  800af3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af6:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800af9:	eb 11                	jmp    800b0c <strfind+0x1f>
		if (*s == c)
  800afb:	8b 45 08             	mov    0x8(%ebp),%eax
  800afe:	0f b6 00             	movzbl (%eax),%eax
  800b01:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b04:	75 02                	jne    800b08 <strfind+0x1b>
			break;
  800b06:	eb 0e                	jmp    800b16 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b08:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0f:	0f b6 00             	movzbl (%eax),%eax
  800b12:	84 c0                	test   %al,%al
  800b14:	75 e5                	jne    800afb <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800b16:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b19:	c9                   	leave  
  800b1a:	c3                   	ret    

00800b1b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
	char *p;

	if (n == 0)
  800b1f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b23:	75 05                	jne    800b2a <memset+0xf>
		return v;
  800b25:	8b 45 08             	mov    0x8(%ebp),%eax
  800b28:	eb 5c                	jmp    800b86 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2d:	83 e0 03             	and    $0x3,%eax
  800b30:	85 c0                	test   %eax,%eax
  800b32:	75 41                	jne    800b75 <memset+0x5a>
  800b34:	8b 45 10             	mov    0x10(%ebp),%eax
  800b37:	83 e0 03             	and    $0x3,%eax
  800b3a:	85 c0                	test   %eax,%eax
  800b3c:	75 37                	jne    800b75 <memset+0x5a>
		c &= 0xFF;
  800b3e:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b48:	c1 e0 18             	shl    $0x18,%eax
  800b4b:	89 c2                	mov    %eax,%edx
  800b4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b50:	c1 e0 10             	shl    $0x10,%eax
  800b53:	09 c2                	or     %eax,%edx
  800b55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b58:	c1 e0 08             	shl    $0x8,%eax
  800b5b:	09 d0                	or     %edx,%eax
  800b5d:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b60:	8b 45 10             	mov    0x10(%ebp),%eax
  800b63:	c1 e8 02             	shr    $0x2,%eax
  800b66:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b68:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6e:	89 d7                	mov    %edx,%edi
  800b70:	fc                   	cld    
  800b71:	f3 ab                	rep stos %eax,%es:(%edi)
  800b73:	eb 0e                	jmp    800b83 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b75:	8b 55 08             	mov    0x8(%ebp),%edx
  800b78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b7e:	89 d7                	mov    %edx,%edi
  800b80:	fc                   	cld    
  800b81:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800b83:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	56                   	push   %esi
  800b8e:	53                   	push   %ebx
  800b8f:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b95:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800b98:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800b9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ba1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ba4:	73 6d                	jae    800c13 <memmove+0x8a>
  800ba6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bac:	01 d0                	add    %edx,%eax
  800bae:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800bb1:	76 60                	jbe    800c13 <memmove+0x8a>
		s += n;
  800bb3:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb6:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800bb9:	8b 45 10             	mov    0x10(%ebp),%eax
  800bbc:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bc2:	83 e0 03             	and    $0x3,%eax
  800bc5:	85 c0                	test   %eax,%eax
  800bc7:	75 2f                	jne    800bf8 <memmove+0x6f>
  800bc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bcc:	83 e0 03             	and    $0x3,%eax
  800bcf:	85 c0                	test   %eax,%eax
  800bd1:	75 25                	jne    800bf8 <memmove+0x6f>
  800bd3:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd6:	83 e0 03             	and    $0x3,%eax
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	75 1b                	jne    800bf8 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bdd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800be0:	83 e8 04             	sub    $0x4,%eax
  800be3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800be6:	83 ea 04             	sub    $0x4,%edx
  800be9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bec:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bef:	89 c7                	mov    %eax,%edi
  800bf1:	89 d6                	mov    %edx,%esi
  800bf3:	fd                   	std    
  800bf4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bf6:	eb 18                	jmp    800c10 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bf8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bfb:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c01:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c04:	8b 45 10             	mov    0x10(%ebp),%eax
  800c07:	89 d7                	mov    %edx,%edi
  800c09:	89 de                	mov    %ebx,%esi
  800c0b:	89 c1                	mov    %eax,%ecx
  800c0d:	fd                   	std    
  800c0e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c10:	fc                   	cld    
  800c11:	eb 45                	jmp    800c58 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c16:	83 e0 03             	and    $0x3,%eax
  800c19:	85 c0                	test   %eax,%eax
  800c1b:	75 2b                	jne    800c48 <memmove+0xbf>
  800c1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c20:	83 e0 03             	and    $0x3,%eax
  800c23:	85 c0                	test   %eax,%eax
  800c25:	75 21                	jne    800c48 <memmove+0xbf>
  800c27:	8b 45 10             	mov    0x10(%ebp),%eax
  800c2a:	83 e0 03             	and    $0x3,%eax
  800c2d:	85 c0                	test   %eax,%eax
  800c2f:	75 17                	jne    800c48 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c31:	8b 45 10             	mov    0x10(%ebp),%eax
  800c34:	c1 e8 02             	shr    $0x2,%eax
  800c37:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c39:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c3c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c3f:	89 c7                	mov    %eax,%edi
  800c41:	89 d6                	mov    %edx,%esi
  800c43:	fc                   	cld    
  800c44:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c46:	eb 10                	jmp    800c58 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c48:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c4b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c51:	89 c7                	mov    %eax,%edi
  800c53:	89 d6                	mov    %edx,%esi
  800c55:	fc                   	cld    
  800c56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800c58:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c5b:	83 c4 10             	add    $0x10,%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c69:	8b 45 10             	mov    0x10(%ebp),%eax
  800c6c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c73:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c77:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7a:	89 04 24             	mov    %eax,(%esp)
  800c7d:	e8 07 ff ff ff       	call   800b89 <memmove>
}
  800c82:	c9                   	leave  
  800c83:	c3                   	ret    

00800c84 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800c8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800c90:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c93:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800c96:	eb 30                	jmp    800cc8 <memcmp+0x44>
		if (*s1 != *s2)
  800c98:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c9b:	0f b6 10             	movzbl (%eax),%edx
  800c9e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ca1:	0f b6 00             	movzbl (%eax),%eax
  800ca4:	38 c2                	cmp    %al,%dl
  800ca6:	74 18                	je     800cc0 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800ca8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cab:	0f b6 00             	movzbl (%eax),%eax
  800cae:	0f b6 d0             	movzbl %al,%edx
  800cb1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800cb4:	0f b6 00             	movzbl (%eax),%eax
  800cb7:	0f b6 c0             	movzbl %al,%eax
  800cba:	29 c2                	sub    %eax,%edx
  800cbc:	89 d0                	mov    %edx,%eax
  800cbe:	eb 1a                	jmp    800cda <memcmp+0x56>
		s1++, s2++;
  800cc0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800cc4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cc8:	8b 45 10             	mov    0x10(%ebp),%eax
  800ccb:	8d 50 ff             	lea    -0x1(%eax),%edx
  800cce:	89 55 10             	mov    %edx,0x10(%ebp)
  800cd1:	85 c0                	test   %eax,%eax
  800cd3:	75 c3                	jne    800c98 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cda:	c9                   	leave  
  800cdb:	c3                   	ret    

00800cdc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800ce2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce8:	01 d0                	add    %edx,%eax
  800cea:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800ced:	eb 13                	jmp    800d02 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cef:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf2:	0f b6 10             	movzbl (%eax),%edx
  800cf5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf8:	38 c2                	cmp    %al,%dl
  800cfa:	75 02                	jne    800cfe <memfind+0x22>
			break;
  800cfc:	eb 0c                	jmp    800d0a <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cfe:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d02:	8b 45 08             	mov    0x8(%ebp),%eax
  800d05:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800d08:	72 e5                	jb     800cef <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800d0a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d0d:	c9                   	leave  
  800d0e:	c3                   	ret    

00800d0f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800d15:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800d1c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d23:	eb 04                	jmp    800d29 <strtol+0x1a>
		s++;
  800d25:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d29:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2c:	0f b6 00             	movzbl (%eax),%eax
  800d2f:	3c 20                	cmp    $0x20,%al
  800d31:	74 f2                	je     800d25 <strtol+0x16>
  800d33:	8b 45 08             	mov    0x8(%ebp),%eax
  800d36:	0f b6 00             	movzbl (%eax),%eax
  800d39:	3c 09                	cmp    $0x9,%al
  800d3b:	74 e8                	je     800d25 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d40:	0f b6 00             	movzbl (%eax),%eax
  800d43:	3c 2b                	cmp    $0x2b,%al
  800d45:	75 06                	jne    800d4d <strtol+0x3e>
		s++;
  800d47:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d4b:	eb 15                	jmp    800d62 <strtol+0x53>
	else if (*s == '-')
  800d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d50:	0f b6 00             	movzbl (%eax),%eax
  800d53:	3c 2d                	cmp    $0x2d,%al
  800d55:	75 0b                	jne    800d62 <strtol+0x53>
		s++, neg = 1;
  800d57:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d5b:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d62:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d66:	74 06                	je     800d6e <strtol+0x5f>
  800d68:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800d6c:	75 24                	jne    800d92 <strtol+0x83>
  800d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d71:	0f b6 00             	movzbl (%eax),%eax
  800d74:	3c 30                	cmp    $0x30,%al
  800d76:	75 1a                	jne    800d92 <strtol+0x83>
  800d78:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7b:	83 c0 01             	add    $0x1,%eax
  800d7e:	0f b6 00             	movzbl (%eax),%eax
  800d81:	3c 78                	cmp    $0x78,%al
  800d83:	75 0d                	jne    800d92 <strtol+0x83>
		s += 2, base = 16;
  800d85:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800d89:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800d90:	eb 2a                	jmp    800dbc <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800d92:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d96:	75 17                	jne    800daf <strtol+0xa0>
  800d98:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9b:	0f b6 00             	movzbl (%eax),%eax
  800d9e:	3c 30                	cmp    $0x30,%al
  800da0:	75 0d                	jne    800daf <strtol+0xa0>
		s++, base = 8;
  800da2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800da6:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800dad:	eb 0d                	jmp    800dbc <strtol+0xad>
	else if (base == 0)
  800daf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800db3:	75 07                	jne    800dbc <strtol+0xad>
		base = 10;
  800db5:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbf:	0f b6 00             	movzbl (%eax),%eax
  800dc2:	3c 2f                	cmp    $0x2f,%al
  800dc4:	7e 1b                	jle    800de1 <strtol+0xd2>
  800dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc9:	0f b6 00             	movzbl (%eax),%eax
  800dcc:	3c 39                	cmp    $0x39,%al
  800dce:	7f 11                	jg     800de1 <strtol+0xd2>
			dig = *s - '0';
  800dd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd3:	0f b6 00             	movzbl (%eax),%eax
  800dd6:	0f be c0             	movsbl %al,%eax
  800dd9:	83 e8 30             	sub    $0x30,%eax
  800ddc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800ddf:	eb 48                	jmp    800e29 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800de1:	8b 45 08             	mov    0x8(%ebp),%eax
  800de4:	0f b6 00             	movzbl (%eax),%eax
  800de7:	3c 60                	cmp    $0x60,%al
  800de9:	7e 1b                	jle    800e06 <strtol+0xf7>
  800deb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dee:	0f b6 00             	movzbl (%eax),%eax
  800df1:	3c 7a                	cmp    $0x7a,%al
  800df3:	7f 11                	jg     800e06 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800df5:	8b 45 08             	mov    0x8(%ebp),%eax
  800df8:	0f b6 00             	movzbl (%eax),%eax
  800dfb:	0f be c0             	movsbl %al,%eax
  800dfe:	83 e8 57             	sub    $0x57,%eax
  800e01:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e04:	eb 23                	jmp    800e29 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800e06:	8b 45 08             	mov    0x8(%ebp),%eax
  800e09:	0f b6 00             	movzbl (%eax),%eax
  800e0c:	3c 40                	cmp    $0x40,%al
  800e0e:	7e 3d                	jle    800e4d <strtol+0x13e>
  800e10:	8b 45 08             	mov    0x8(%ebp),%eax
  800e13:	0f b6 00             	movzbl (%eax),%eax
  800e16:	3c 5a                	cmp    $0x5a,%al
  800e18:	7f 33                	jg     800e4d <strtol+0x13e>
			dig = *s - 'A' + 10;
  800e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1d:	0f b6 00             	movzbl (%eax),%eax
  800e20:	0f be c0             	movsbl %al,%eax
  800e23:	83 e8 37             	sub    $0x37,%eax
  800e26:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e2c:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e2f:	7c 02                	jl     800e33 <strtol+0x124>
			break;
  800e31:	eb 1a                	jmp    800e4d <strtol+0x13e>
		s++, val = (val * base) + dig;
  800e33:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e37:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e3a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e3e:	89 c2                	mov    %eax,%edx
  800e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e43:	01 d0                	add    %edx,%eax
  800e45:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800e48:	e9 6f ff ff ff       	jmp    800dbc <strtol+0xad>

	if (endptr)
  800e4d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e51:	74 08                	je     800e5b <strtol+0x14c>
		*endptr = (char *) s;
  800e53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e56:	8b 55 08             	mov    0x8(%ebp),%edx
  800e59:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800e5b:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e5f:	74 07                	je     800e68 <strtol+0x159>
  800e61:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e64:	f7 d8                	neg    %eax
  800e66:	eb 03                	jmp    800e6b <strtol+0x15c>
  800e68:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800e6b:	c9                   	leave  
  800e6c:	c3                   	ret    

00800e6d <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
  800e70:	57                   	push   %edi
  800e71:	56                   	push   %esi
  800e72:	53                   	push   %ebx
  800e73:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e76:	8b 45 08             	mov    0x8(%ebp),%eax
  800e79:	8b 55 10             	mov    0x10(%ebp),%edx
  800e7c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800e7f:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800e82:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800e85:	8b 75 20             	mov    0x20(%ebp),%esi
  800e88:	cd 30                	int    $0x30
  800e8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e8d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e91:	74 30                	je     800ec3 <syscall+0x56>
  800e93:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e97:	7e 2a                	jle    800ec3 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e9c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ea7:	c7 44 24 08 44 1e 80 	movl   $0x801e44,0x8(%esp)
  800eae:	00 
  800eaf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb6:	00 
  800eb7:	c7 04 24 61 1e 80 00 	movl   $0x801e61,(%esp)
  800ebe:	e8 75 09 00 00       	call   801838 <_panic>

	return ret;
  800ec3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800ec6:	83 c4 3c             	add    $0x3c,%esp
  800ec9:	5b                   	pop    %ebx
  800eca:	5e                   	pop    %esi
  800ecb:	5f                   	pop    %edi
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    

00800ece <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800ed4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed7:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ede:	00 
  800edf:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ee6:	00 
  800ee7:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800eee:	00 
  800eef:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ef2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ef6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800efa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f01:	00 
  800f02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f09:	e8 5f ff ff ff       	call   800e6d <syscall>
}
  800f0e:	c9                   	leave  
  800f0f:	c3                   	ret    

00800f10 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f16:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f1d:	00 
  800f1e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f25:	00 
  800f26:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f2d:	00 
  800f2e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f35:	00 
  800f36:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f3d:	00 
  800f3e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f45:	00 
  800f46:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800f4d:	e8 1b ff ff ff       	call   800e6d <syscall>
}
  800f52:	c9                   	leave  
  800f53:	c3                   	ret    

00800f54 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800f5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f64:	00 
  800f65:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f6c:	00 
  800f6d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f74:	00 
  800f75:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f7c:	00 
  800f7d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f81:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f88:	00 
  800f89:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800f90:	e8 d8 fe ff ff       	call   800e6d <syscall>
}
  800f95:	c9                   	leave  
  800f96:	c3                   	ret    

00800f97 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f97:	55                   	push   %ebp
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800f9d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fa4:	00 
  800fa5:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fac:	00 
  800fad:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fb4:	00 
  800fb5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fbc:	00 
  800fbd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fc4:	00 
  800fc5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fcc:	00 
  800fcd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800fd4:	e8 94 fe ff ff       	call   800e6d <syscall>
}
  800fd9:	c9                   	leave  
  800fda:	c3                   	ret    

00800fdb <sys_yield>:

void
sys_yield(void)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800fe1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fe8:	00 
  800fe9:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ff0:	00 
  800ff1:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ff8:	00 
  800ff9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801000:	00 
  801001:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801008:	00 
  801009:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801010:	00 
  801011:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  801018:	e8 50 fe ff ff       	call   800e6d <syscall>
}
  80101d:	c9                   	leave  
  80101e:	c3                   	ret    

0080101f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801025:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801028:	8b 55 0c             	mov    0xc(%ebp),%edx
  80102b:	8b 45 08             	mov    0x8(%ebp),%eax
  80102e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801035:	00 
  801036:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80103d:	00 
  80103e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801042:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801046:	89 44 24 08          	mov    %eax,0x8(%esp)
  80104a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801051:	00 
  801052:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  801059:	e8 0f fe ff ff       	call   800e6d <syscall>
}
  80105e:	c9                   	leave  
  80105f:	c3                   	ret    

00801060 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	56                   	push   %esi
  801064:	53                   	push   %ebx
  801065:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  801068:	8b 75 18             	mov    0x18(%ebp),%esi
  80106b:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80106e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801071:	8b 55 0c             	mov    0xc(%ebp),%edx
  801074:	8b 45 08             	mov    0x8(%ebp),%eax
  801077:	89 74 24 18          	mov    %esi,0x18(%esp)
  80107b:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80107f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801083:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801087:	89 44 24 08          	mov    %eax,0x8(%esp)
  80108b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801092:	00 
  801093:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  80109a:	e8 ce fd ff ff       	call   800e6d <syscall>
}
  80109f:	83 c4 20             	add    $0x20,%esp
  8010a2:	5b                   	pop    %ebx
  8010a3:	5e                   	pop    %esi
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    

008010a6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8010ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010af:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b2:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010b9:	00 
  8010ba:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010c1:	00 
  8010c2:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010c9:	00 
  8010ca:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010d2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010d9:	00 
  8010da:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  8010e1:	e8 87 fd ff ff       	call   800e6d <syscall>
}
  8010e6:	c9                   	leave  
  8010e7:	c3                   	ret    

008010e8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8010ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f4:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010fb:	00 
  8010fc:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801103:	00 
  801104:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80110b:	00 
  80110c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801110:	89 44 24 08          	mov    %eax,0x8(%esp)
  801114:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80111b:	00 
  80111c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801123:	e8 45 fd ff ff       	call   800e6d <syscall>
}
  801128:	c9                   	leave  
  801129:	c3                   	ret    

0080112a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801130:	8b 55 0c             	mov    0xc(%ebp),%edx
  801133:	8b 45 08             	mov    0x8(%ebp),%eax
  801136:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80113d:	00 
  80113e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801145:	00 
  801146:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80114d:	00 
  80114e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801152:	89 44 24 08          	mov    %eax,0x8(%esp)
  801156:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80115d:	00 
  80115e:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  801165:	e8 03 fd ff ff       	call   800e6d <syscall>
}
  80116a:	c9                   	leave  
  80116b:	c3                   	ret    

0080116c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801172:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801175:	8b 55 10             	mov    0x10(%ebp),%edx
  801178:	8b 45 08             	mov    0x8(%ebp),%eax
  80117b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801182:	00 
  801183:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801187:	89 54 24 10          	mov    %edx,0x10(%esp)
  80118b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801192:	89 44 24 08          	mov    %eax,0x8(%esp)
  801196:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80119d:	00 
  80119e:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8011a5:	e8 c3 fc ff ff       	call   800e6d <syscall>
}
  8011aa:	c9                   	leave  
  8011ab:	c3                   	ret    

008011ac <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8011b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011bc:	00 
  8011bd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011c4:	00 
  8011c5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011cc:	00 
  8011cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011d4:	00 
  8011d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011d9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011e0:	00 
  8011e1:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  8011e8:	e8 80 fc ff ff       	call   800e6d <syscall>
}
  8011ed:	c9                   	leave  
  8011ee:	c3                   	ret    

008011ef <pgfault>:
// map in our own private writable copy.
//

static void
pgfault(struct UTrapframe *utf)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  8011f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f8:	8b 00                	mov    (%eax),%eax
  8011fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  8011fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801200:	8b 40 04             	mov    0x4(%eax),%eax
  801203:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	uint32_t t = PGNUM(addr);
  801206:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801209:	c1 e8 0c             	shr    $0xc,%eax
  80120c:	89 45 ec             	mov    %eax,-0x14(%ebp)
	pte_t pte = uvpt[t];
  80120f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801212:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801219:	89 45 e8             	mov    %eax,-0x18(%ebp)
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  80121c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121f:	83 e0 02             	and    $0x2,%eax
  801222:	85 c0                	test   %eax,%eax
  801224:	74 0c                	je     801232 <pgfault+0x43>
  801226:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801229:	25 00 08 00 00       	and    $0x800,%eax
  80122e:	85 c0                	test   %eax,%eax
  801230:	75 1c                	jne    80124e <pgfault+0x5f>
		panic("permission denied in copy on write pgfault handler\n");
  801232:	c7 44 24 08 70 1e 80 	movl   $0x801e70,0x8(%esp)
  801239:	00 
  80123a:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801241:	00 
  801242:	c7 04 24 a4 1e 80 00 	movl   $0x801ea4,(%esp)
  801249:	e8 ea 05 00 00       	call   801838 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	r = sys_page_alloc(0,PFTEMP,PTE_P|PTE_U|PTE_W);
  80124e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801255:	00 
  801256:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80125d:	00 
  80125e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801265:	e8 b5 fd ff ff       	call   80101f <sys_page_alloc>
  80126a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if(r < 0)
  80126d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801271:	79 1c                	jns    80128f <pgfault+0xa0>
	{
		panic("page cant be allocated\n");
  801273:	c7 44 24 08 af 1e 80 	movl   $0x801eaf,0x8(%esp)
  80127a:	00 
  80127b:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  801282:	00 
  801283:	c7 04 24 a4 1e 80 00 	movl   $0x801ea4,(%esp)
  80128a:	e8 a9 05 00 00       	call   801838 <_panic>
	}
	memmove(PFTEMP, ROUNDDOWN(addr,PGSIZE), PGSIZE);
  80128f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801292:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801295:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801298:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80129d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8012a4:	00 
  8012a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a9:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8012b0:	e8 d4 f8 ff ff       	call   800b89 <memmove>
	int r1 = sys_page_map(0,PFTEMP,0,ROUNDDOWN(addr,PGSIZE),PTE_W|PTE_U|PTE_P);
  8012b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8012bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012be:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012c3:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8012ca:	00 
  8012cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012d6:	00 
  8012d7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012de:	00 
  8012df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012e6:	e8 75 fd ff ff       	call   801060 <sys_page_map>
  8012eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
	if(r1 < 0)
  8012ee:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8012f2:	79 1c                	jns    801310 <pgfault+0x121>
	{
		panic("page cant be mapped\n");
  8012f4:	c7 44 24 08 c7 1e 80 	movl   $0x801ec7,0x8(%esp)
  8012fb:	00 
  8012fc:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  801303:	00 
  801304:	c7 04 24 a4 1e 80 00 	movl   $0x801ea4,(%esp)
  80130b:	e8 28 05 00 00       	call   801838 <_panic>
	}	

	// panic("pgfault not implemented");
}
  801310:	c9                   	leave  
  801311:	c3                   	ret    

00801312 <duppage>:
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
static int
duppage(envid_t envid, unsigned pn)
{
  801312:	55                   	push   %ebp
  801313:	89 e5                	mov    %esp,%ebp
  801315:	83 ec 48             	sub    $0x48,%esp
	int r;
	
	// LAB 4: Your code here.
	uint32_t t = uvpt[pn];
  801318:	8b 45 0c             	mov    0xc(%ebp),%eax
  80131b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801322:	89 45 f4             	mov    %eax,-0xc(%ebp)
	void *va_pn = (void *)(pn*PGSIZE);
  801325:	8b 45 0c             	mov    0xc(%ebp),%eax
  801328:	c1 e0 0c             	shl    $0xc,%eax
  80132b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if((t && PTE_W) || (t && PTE_COW))
  80132e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801332:	75 0a                	jne    80133e <duppage+0x2c>
  801334:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801338:	0f 84 ed 00 00 00    	je     80142b <duppage+0x119>
	{
		r = sys_page_map(0,va_pn,envid,va_pn,PTE_P|PTE_U|PTE_COW);
  80133e:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801345:	00 
  801346:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801349:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80134d:	8b 45 08             	mov    0x8(%ebp),%eax
  801350:	89 44 24 08          	mov    %eax,0x8(%esp)
  801354:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801357:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801362:	e8 f9 fc ff ff       	call   801060 <sys_page_map>
  801367:	89 45 e8             	mov    %eax,-0x18(%ebp)
		if(r < 0)
  80136a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80136e:	79 1c                	jns    80138c <duppage+0x7a>
		{
			panic("error in page map\n");
  801370:	c7 44 24 08 dc 1e 80 	movl   $0x801edc,0x8(%esp)
  801377:	00 
  801378:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  80137f:	00 
  801380:	c7 04 24 a4 1e 80 00 	movl   $0x801ea4,(%esp)
  801387:	e8 ac 04 00 00       	call   801838 <_panic>
		}
		int r1 = sys_page_map(envid,va_pn,0,va_pn,PTE_P|PTE_U|PTE_COW);
  80138c:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801393:	00 
  801394:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801397:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80139b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013a2:	00 
  8013a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ad:	89 04 24             	mov    %eax,(%esp)
  8013b0:	e8 ab fc ff ff       	call   801060 <sys_page_map>
  8013b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if(r1 < 0)
  8013b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8013bc:	79 1c                	jns    8013da <duppage+0xc8>
		{
			panic("error in page map\n");
  8013be:	c7 44 24 08 dc 1e 80 	movl   $0x801edc,0x8(%esp)
  8013c5:	00 
  8013c6:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8013cd:	00 
  8013ce:	c7 04 24 a4 1e 80 00 	movl   $0x801ea4,(%esp)
  8013d5:	e8 5e 04 00 00       	call   801838 <_panic>
		}
		int r2 = sys_page_map(0,va_pn,0,va_pn,PTE_P|PTE_U|PTE_COW);
  8013da:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8013e1:	00 
  8013e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013e9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013f0:	00 
  8013f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013ff:	e8 5c fc ff ff       	call   801060 <sys_page_map>
  801404:	89 45 e0             	mov    %eax,-0x20(%ebp)
		if(r2 < 0)
  801407:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80140b:	79 1c                	jns    801429 <duppage+0x117>
		{
			panic("error in page map\n");
  80140d:	c7 44 24 08 dc 1e 80 	movl   $0x801edc,0x8(%esp)
  801414:	00 
  801415:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  80141c:	00 
  80141d:	c7 04 24 a4 1e 80 00 	movl   $0x801ea4,(%esp)
  801424:	e8 0f 04 00 00       	call   801838 <_panic>
	
	// LAB 4: Your code here.
	uint32_t t = uvpt[pn];
	void *va_pn = (void *)(pn*PGSIZE);
	if((t && PTE_W) || (t && PTE_COW))
	{
  801429:	eb 4e                	jmp    801479 <duppage+0x167>
			panic("error in page map\n");
		}
	}
	else
	{
		int r3 = sys_page_map(0,va_pn,envid,va_pn,PTE_U|PTE_P);
  80142b:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801432:	00 
  801433:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801436:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80143a:	8b 45 08             	mov    0x8(%ebp),%eax
  80143d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801441:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801444:	89 44 24 04          	mov    %eax,0x4(%esp)
  801448:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80144f:	e8 0c fc ff ff       	call   801060 <sys_page_map>
  801454:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if(r3 < 0)
  801457:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80145b:	79 1c                	jns    801479 <duppage+0x167>
		{
			panic("error in page map\n");
  80145d:	c7 44 24 08 dc 1e 80 	movl   $0x801edc,0x8(%esp)
  801464:	00 
  801465:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  80146c:	00 
  80146d:	c7 04 24 a4 1e 80 00 	movl   $0x801ea4,(%esp)
  801474:	e8 bf 03 00 00       	call   801838 <_panic>
		}
	}
	// panic("duppage not implemented");
	return 0;
  801479:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80147e:	c9                   	leave  
  80147f:	c3                   	ret    

00801480 <fork>:


envid_t
fork(void)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
  801483:	83 ec 38             	sub    $0x38,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801486:	c7 04 24 ef 11 80 00 	movl   $0x8011ef,(%esp)
  80148d:	e8 01 04 00 00       	call   801893 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801492:	b8 07 00 00 00       	mov    $0x7,%eax
  801497:	cd 30                	int    $0x30
  801499:	89 45 e0             	mov    %eax,-0x20(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  80149c:	8b 45 e0             	mov    -0x20(%ebp),%eax
	envid_t envid = sys_exofork();
  80149f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (envid < 0)
  8014a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8014a6:	79 1c                	jns    8014c4 <fork+0x44>
	{
		panic("sys_exofork not succeeded\n");
  8014a8:	c7 44 24 08 ef 1e 80 	movl   $0x801eef,0x8(%esp)
  8014af:	00 
  8014b0:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
  8014b7:	00 
  8014b8:	c7 04 24 a4 1e 80 00 	movl   $0x801ea4,(%esp)
  8014bf:	e8 74 03 00 00       	call   801838 <_panic>
	}
	if (envid == 0)
  8014c4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8014c8:	75 29                	jne    8014f3 <fork+0x73>
	{	
		thisenv = &envs[ENVX(sys_getenvid())];
  8014ca:	e8 c8 fa ff ff       	call   800f97 <sys_getenvid>
  8014cf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8014d4:	c1 e0 02             	shl    $0x2,%eax
  8014d7:	89 c2                	mov    %eax,%edx
  8014d9:	c1 e2 05             	shl    $0x5,%edx
  8014dc:	29 c2                	sub    %eax,%edx
  8014de:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  8014e4:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  8014e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ee:	e9 2b 01 00 00       	jmp    80161e <fork+0x19e>
	}
	else
	{
		int p;
		for (p = 0; p < PGNUM(UTOP); p++) 
  8014f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  8014fa:	e9 9a 00 00 00       	jmp    801599 <fork+0x119>
		{
			if(p == PGNUM(UTOP) - 1)
  8014ff:	81 7d f4 ff eb 0e 00 	cmpl   $0xeebff,-0xc(%ebp)
  801506:	75 42                	jne    80154a <fork+0xca>
			{
				int r1 = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE), PTE_P|PTE_W|PTE_U);
  801508:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80150f:	00 
  801510:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801517:	ee 
  801518:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151b:	89 04 24             	mov    %eax,(%esp)
  80151e:	e8 fc fa ff ff       	call   80101f <sys_page_alloc>
  801523:	89 45 ec             	mov    %eax,-0x14(%ebp)
  				if(r1 < 0)
  801526:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80152a:	79 1c                	jns    801548 <fork+0xc8>
  				{
    				panic("sys_page_alloc failed\n");
  80152c:	c7 44 24 08 0a 1f 80 	movl   $0x801f0a,0x8(%esp)
  801533:	00 
  801534:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  80153b:	00 
  80153c:	c7 04 24 a4 1e 80 00 	movl   $0x801ea4,(%esp)
  801543:	e8 f0 02 00 00       	call   801838 <_panic>
				}
				break;
  801548:	eb 5d                	jmp    8015a7 <fork+0x127>
			}
			if((uvpd[PDX(p*PGSIZE)]&PTE_P))
  80154a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154d:	c1 e0 0c             	shl    $0xc,%eax
  801550:	c1 e8 16             	shr    $0x16,%eax
  801553:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80155a:	83 e0 01             	and    $0x1,%eax
  80155d:	85 c0                	test   %eax,%eax
  80155f:	74 34                	je     801595 <fork+0x115>
			{
				if((uvpt[p]&PTE_P) && (uvpt[p] & PTE_U))
  801561:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801564:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80156b:	83 e0 01             	and    $0x1,%eax
  80156e:	85 c0                	test   %eax,%eax
  801570:	74 23                	je     801595 <fork+0x115>
  801572:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801575:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80157c:	83 e0 04             	and    $0x4,%eax
  80157f:	85 c0                	test   %eax,%eax
  801581:	74 12                	je     801595 <fork+0x115>
				{
					duppage(envid, p);
  801583:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801586:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158d:	89 04 24             	mov    %eax,(%esp)
  801590:	e8 7d fd ff ff       	call   801312 <duppage>
		return 0;
	}
	else
	{
		int p;
		for (p = 0; p < PGNUM(UTOP); p++) 
  801595:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  801599:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159c:	3d ff eb 0e 00       	cmp    $0xeebff,%eax
  8015a1:	0f 86 58 ff ff ff    	jbe    8014ff <fork+0x7f>
				}
			}	
		}
  		
		extern void _pgfault_upcall();
		int r = sys_env_set_pgfault_upcall(envid,thisenv->env_pgfault_upcall);
  8015a7:	a1 04 20 80 00       	mov    0x802004,%eax
  8015ac:	8b 40 64             	mov    0x64(%eax),%eax
  8015af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b6:	89 04 24             	mov    %eax,(%esp)
  8015b9:	e8 6c fb ff ff       	call   80112a <sys_env_set_pgfault_upcall>
  8015be:	89 45 e8             	mov    %eax,-0x18(%ebp)
    	if(r < 0)
  8015c1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8015c5:	79 1c                	jns    8015e3 <fork+0x163>
    	{
    		panic("sys_env_set_pgfault_upcall failed\n");
  8015c7:	c7 44 24 08 24 1f 80 	movl   $0x801f24,0x8(%esp)
  8015ce:	00 
  8015cf:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  8015d6:	00 
  8015d7:	c7 04 24 a4 1e 80 00 	movl   $0x801ea4,(%esp)
  8015de:	e8 55 02 00 00       	call   801838 <_panic>
    	}
  		int r2 = sys_env_set_status(envid, ENV_RUNNABLE);
  8015e3:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8015ea:	00 
  8015eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ee:	89 04 24             	mov    %eax,(%esp)
  8015f1:	e8 f2 fa ff ff       	call   8010e8 <sys_env_set_status>
  8015f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  		if(r2 < 0)
  8015f9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8015fd:	79 1c                	jns    80161b <fork+0x19b>
  		{
    		panic("sys_env_set_status failes\n");
  8015ff:	c7 44 24 08 47 1f 80 	movl   $0x801f47,0x8(%esp)
  801606:	00 
  801607:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  80160e:	00 
  80160f:	c7 04 24 a4 1e 80 00 	movl   $0x801ea4,(%esp)
  801616:	e8 1d 02 00 00       	call   801838 <_panic>
    	}
  		return envid;
  80161b:	8b 45 f0             	mov    -0x10(%ebp),%eax
	}


	// panic("fork not implemented");
}
  80161e:	c9                   	leave  
  80161f:	c3                   	ret    

00801620 <sfork>:


// Challenge!
int
sfork(void)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801626:	c7 44 24 08 62 1f 80 	movl   $0x801f62,0x8(%esp)
  80162d:	00 
  80162e:	c7 44 24 04 a8 00 00 	movl   $0xa8,0x4(%esp)
  801635:	00 
  801636:	c7 04 24 a4 1e 80 00 	movl   $0x801ea4,(%esp)
  80163d:	e8 f6 01 00 00       	call   801838 <_panic>

00801642 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801642:	55                   	push   %ebp
  801643:	89 e5                	mov    %esp,%ebp
  801645:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int r;
	if(pg != NULL)
  801648:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80164c:	74 10                	je     80165e <ipc_recv+0x1c>
	{
		r = sys_ipc_recv(pg);
  80164e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801651:	89 04 24             	mov    %eax,(%esp)
  801654:	e8 53 fb ff ff       	call   8011ac <sys_ipc_recv>
  801659:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80165c:	eb 0f                	jmp    80166d <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  80165e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801665:	e8 42 fb ff ff       	call   8011ac <sys_ipc_recv>
  80166a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}

	if(from_env_store != NULL && r == 0) 
  80166d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801671:	74 13                	je     801686 <ipc_recv+0x44>
  801673:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801677:	75 0d                	jne    801686 <ipc_recv+0x44>
	{
		*from_env_store = thisenv->env_ipc_from;
  801679:	a1 04 20 80 00       	mov    0x802004,%eax
  80167e:	8b 50 74             	mov    0x74(%eax),%edx
  801681:	8b 45 08             	mov    0x8(%ebp),%eax
  801684:	89 10                	mov    %edx,(%eax)
	}
	if(from_env_store != NULL && r < 0)
  801686:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80168a:	74 0f                	je     80169b <ipc_recv+0x59>
  80168c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801690:	79 09                	jns    80169b <ipc_recv+0x59>
	{
		*from_env_store = 0;
  801692:	8b 45 08             	mov    0x8(%ebp),%eax
  801695:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}

	if(perm_store != NULL)
  80169b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80169f:	74 28                	je     8016c9 <ipc_recv+0x87>
	{
		if(r==0 && (uint32_t)pg<UTOP)
  8016a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8016a5:	75 19                	jne    8016c0 <ipc_recv+0x7e>
  8016a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016aa:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
  8016af:	77 0f                	ja     8016c0 <ipc_recv+0x7e>
		{
			*perm_store = thisenv->env_ipc_perm;
  8016b1:	a1 04 20 80 00       	mov    0x802004,%eax
  8016b6:	8b 50 78             	mov    0x78(%eax),%edx
  8016b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8016bc:	89 10                	mov    %edx,(%eax)
  8016be:	eb 09                	jmp    8016c9 <ipc_recv+0x87>
		}
		else
		{
			*perm_store = 0;
  8016c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8016c3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		}
	}
	if (r == 0)
  8016c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8016cd:	75 0a                	jne    8016d9 <ipc_recv+0x97>
	{
    	return thisenv->env_ipc_value;
  8016cf:	a1 04 20 80 00       	mov    0x802004,%eax
  8016d4:	8b 40 70             	mov    0x70(%eax),%eax
  8016d7:	eb 03                	jmp    8016dc <ipc_recv+0x9a>
    } 
  	else
  	{
    	return r;
  8016d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    }
	// panic("ipc_recv not implemented");
	// return 0;
}
  8016dc:	c9                   	leave  
  8016dd:	c3                   	ret    

008016de <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int r;
	if(pg == NULL)
  8016e4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8016e8:	75 4c                	jne    801736 <ipc_send+0x58>
	{
		r = sys_ipc_try_send(to_env,val,(void *)UTOP, perm);
  8016ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8016ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016f1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8016f8:	ee 
  8016f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801700:	8b 45 08             	mov    0x8(%ebp),%eax
  801703:	89 04 24             	mov    %eax,(%esp)
  801706:	e8 61 fa ff ff       	call   80116c <sys_ipc_try_send>
  80170b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    	if (r != 0 && r != -E_IPC_NOT_RECV)
  80170e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801712:	74 6e                	je     801782 <ipc_send+0xa4>
  801714:	83 7d f4 f8          	cmpl   $0xfffffff8,-0xc(%ebp)
  801718:	74 68                	je     801782 <ipc_send+0xa4>
    	{
    		panic("in ipc_send\n");
  80171a:	c7 44 24 08 78 1f 80 	movl   $0x801f78,0x8(%esp)
  801721:	00 
  801722:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  801729:	00 
  80172a:	c7 04 24 85 1f 80 00 	movl   $0x801f85,(%esp)
  801731:	e8 02 01 00 00       	call   801838 <_panic>
    	} 
	}
	else
	{
		r = sys_ipc_try_send(to_env,val,(void *)UTOP, perm);
  801736:	8b 45 14             	mov    0x14(%ebp),%eax
  801739:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80173d:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801744:	ee 
  801745:	8b 45 0c             	mov    0xc(%ebp),%eax
  801748:	89 44 24 04          	mov    %eax,0x4(%esp)
  80174c:	8b 45 08             	mov    0x8(%ebp),%eax
  80174f:	89 04 24             	mov    %eax,(%esp)
  801752:	e8 15 fa ff ff       	call   80116c <sys_ipc_try_send>
  801757:	89 45 f4             	mov    %eax,-0xc(%ebp)
    	if (r != 0 && r != -E_IPC_NOT_RECV)
  80175a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80175e:	74 22                	je     801782 <ipc_send+0xa4>
  801760:	83 7d f4 f8          	cmpl   $0xfffffff8,-0xc(%ebp)
  801764:	74 1c                	je     801782 <ipc_send+0xa4>
    	{
    		panic("in ipc_send\n");
  801766:	c7 44 24 08 78 1f 80 	movl   $0x801f78,0x8(%esp)
  80176d:	00 
  80176e:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
  801775:	00 
  801776:	c7 04 24 85 1f 80 00 	movl   $0x801f85,(%esp)
  80177d:	e8 b6 00 00 00       	call   801838 <_panic>
    	}	
	}
	while(r != 0)
  801782:	eb 58                	jmp    8017dc <ipc_send+0xfe>
    //cprintf("[%x]ipc_send\n", thisenv->env_id);
	{
    	r = sys_ipc_try_send(to_env, val, pg ? pg : (void*)UTOP, perm);
  801784:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801788:	74 05                	je     80178f <ipc_send+0xb1>
  80178a:	8b 45 10             	mov    0x10(%ebp),%eax
  80178d:	eb 05                	jmp    801794 <ipc_send+0xb6>
  80178f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801794:	8b 55 14             	mov    0x14(%ebp),%edx
  801797:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80179b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80179f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a9:	89 04 24             	mov    %eax,(%esp)
  8017ac:	e8 bb f9 ff ff       	call   80116c <sys_ipc_try_send>
  8017b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    	if (r != 0 && r != -E_IPC_NOT_RECV) 
  8017b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8017b8:	74 22                	je     8017dc <ipc_send+0xfe>
  8017ba:	83 7d f4 f8          	cmpl   $0xfffffff8,-0xc(%ebp)
  8017be:	74 1c                	je     8017dc <ipc_send+0xfe>
    	{
      		panic("in ipc_send\n");
  8017c0:	c7 44 24 08 78 1f 80 	movl   $0x801f78,0x8(%esp)
  8017c7:	00 
  8017c8:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  8017cf:	00 
  8017d0:	c7 04 24 85 1f 80 00 	movl   $0x801f85,(%esp)
  8017d7:	e8 5c 00 00 00       	call   801838 <_panic>
    	if (r != 0 && r != -E_IPC_NOT_RECV)
    	{
    		panic("in ipc_send\n");
    	}	
	}
	while(r != 0)
  8017dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8017e0:	75 a2                	jne    801784 <ipc_send+0xa6>
    	{
      		panic("in ipc_send\n");
    	}
    } 
	// panic("ipc_send not implemented");
}
  8017e2:	c9                   	leave  
  8017e3:	c3                   	ret    

008017e4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	83 ec 10             	sub    $0x10,%esp
	int i;
	for (i = 0; i < NENV; i++)
  8017ea:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8017f1:	eb 35                	jmp    801828 <ipc_find_env+0x44>
		if (envs[i].env_type == type)
  8017f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017f6:	c1 e0 02             	shl    $0x2,%eax
  8017f9:	89 c2                	mov    %eax,%edx
  8017fb:	c1 e2 05             	shl    $0x5,%edx
  8017fe:	29 c2                	sub    %eax,%edx
  801800:	8d 82 50 00 c0 ee    	lea    -0x113fffb0(%edx),%eax
  801806:	8b 00                	mov    (%eax),%eax
  801808:	3b 45 08             	cmp    0x8(%ebp),%eax
  80180b:	75 17                	jne    801824 <ipc_find_env+0x40>
			return envs[i].env_id;
  80180d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801810:	c1 e0 02             	shl    $0x2,%eax
  801813:	89 c2                	mov    %eax,%edx
  801815:	c1 e2 05             	shl    $0x5,%edx
  801818:	29 c2                	sub    %eax,%edx
  80181a:	8d 82 48 00 c0 ee    	lea    -0x113fffb8(%edx),%eax
  801820:	8b 00                	mov    (%eax),%eax
  801822:	eb 12                	jmp    801836 <ipc_find_env+0x52>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801824:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  801828:	81 7d fc ff 03 00 00 	cmpl   $0x3ff,-0x4(%ebp)
  80182f:	7e c2                	jle    8017f3 <ipc_find_env+0xf>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801831:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801836:	c9                   	leave  
  801837:	c3                   	ret    

00801838 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	53                   	push   %ebx
  80183c:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80183f:	8d 45 14             	lea    0x14(%ebp),%eax
  801842:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801845:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80184b:	e8 47 f7 ff ff       	call   800f97 <sys_getenvid>
  801850:	8b 55 0c             	mov    0xc(%ebp),%edx
  801853:	89 54 24 10          	mov    %edx,0x10(%esp)
  801857:	8b 55 08             	mov    0x8(%ebp),%edx
  80185a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80185e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801862:	89 44 24 04          	mov    %eax,0x4(%esp)
  801866:	c7 04 24 90 1f 80 00 	movl   $0x801f90,(%esp)
  80186d:	e8 b7 e9 ff ff       	call   800229 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801872:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801875:	89 44 24 04          	mov    %eax,0x4(%esp)
  801879:	8b 45 10             	mov    0x10(%ebp),%eax
  80187c:	89 04 24             	mov    %eax,(%esp)
  80187f:	e8 41 e9 ff ff       	call   8001c5 <vcprintf>
	cprintf("\n");
  801884:	c7 04 24 b3 1f 80 00 	movl   $0x801fb3,(%esp)
  80188b:	e8 99 e9 ff ff       	call   800229 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801890:	cc                   	int3   
  801891:	eb fd                	jmp    801890 <_panic+0x58>

00801893 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  801899:	a1 08 20 80 00       	mov    0x802008,%eax
  80189e:	85 c0                	test   %eax,%eax
  8018a0:	75 55                	jne    8018f7 <set_pgfault_handler+0x64>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE),PTE_U|PTE_P|PTE_W);
  8018a2:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8018a9:	00 
  8018aa:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8018b1:	ee 
  8018b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018b9:	e8 61 f7 ff ff       	call   80101f <sys_page_alloc>
  8018be:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(r < 0)
  8018c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8018c5:	79 1c                	jns    8018e3 <set_pgfault_handler+0x50>
		{
			panic("sys_page_alloc_failed");
  8018c7:	c7 44 24 08 b5 1f 80 	movl   $0x801fb5,0x8(%esp)
  8018ce:	00 
  8018cf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8018d6:	00 
  8018d7:	c7 04 24 cb 1f 80 00 	movl   $0x801fcb,(%esp)
  8018de:	e8 55 ff ff ff       	call   801838 <_panic>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8018e3:	c7 44 24 04 01 19 80 	movl   $0x801901,0x4(%esp)
  8018ea:	00 
  8018eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018f2:	e8 33 f8 ff ff       	call   80112a <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8018f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fa:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8018ff:	c9                   	leave  
  801900:	c3                   	ret    

00801901 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801901:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801902:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801907:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801909:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x30(%esp), %eax
  80190c:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  801910:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801913:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 0x28(%esp), %ecx
  801917:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	movl %ecx, (%eax)
  80191b:	89 08                	mov    %ecx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	//add $8, %esp
	popl %edx 
  80191d:	5a                   	pop    %edx
	popl %edx
  80191e:	5a                   	pop    %edx
	popal
  80191f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp
  801920:	83 c4 04             	add    $0x4,%esp
	popf
  801923:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801924:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801925:	c3                   	ret    
  801926:	66 90                	xchg   %ax,%ax
  801928:	66 90                	xchg   %ax,%ax
  80192a:	66 90                	xchg   %ax,%ax
  80192c:	66 90                	xchg   %ax,%ax
  80192e:	66 90                	xchg   %ax,%ax

00801930 <__udivdi3>:
  801930:	55                   	push   %ebp
  801931:	57                   	push   %edi
  801932:	56                   	push   %esi
  801933:	83 ec 0c             	sub    $0xc,%esp
  801936:	8b 44 24 28          	mov    0x28(%esp),%eax
  80193a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80193e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801942:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801946:	85 c0                	test   %eax,%eax
  801948:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80194c:	89 ea                	mov    %ebp,%edx
  80194e:	89 0c 24             	mov    %ecx,(%esp)
  801951:	75 2d                	jne    801980 <__udivdi3+0x50>
  801953:	39 e9                	cmp    %ebp,%ecx
  801955:	77 61                	ja     8019b8 <__udivdi3+0x88>
  801957:	85 c9                	test   %ecx,%ecx
  801959:	89 ce                	mov    %ecx,%esi
  80195b:	75 0b                	jne    801968 <__udivdi3+0x38>
  80195d:	b8 01 00 00 00       	mov    $0x1,%eax
  801962:	31 d2                	xor    %edx,%edx
  801964:	f7 f1                	div    %ecx
  801966:	89 c6                	mov    %eax,%esi
  801968:	31 d2                	xor    %edx,%edx
  80196a:	89 e8                	mov    %ebp,%eax
  80196c:	f7 f6                	div    %esi
  80196e:	89 c5                	mov    %eax,%ebp
  801970:	89 f8                	mov    %edi,%eax
  801972:	f7 f6                	div    %esi
  801974:	89 ea                	mov    %ebp,%edx
  801976:	83 c4 0c             	add    $0xc,%esp
  801979:	5e                   	pop    %esi
  80197a:	5f                   	pop    %edi
  80197b:	5d                   	pop    %ebp
  80197c:	c3                   	ret    
  80197d:	8d 76 00             	lea    0x0(%esi),%esi
  801980:	39 e8                	cmp    %ebp,%eax
  801982:	77 24                	ja     8019a8 <__udivdi3+0x78>
  801984:	0f bd e8             	bsr    %eax,%ebp
  801987:	83 f5 1f             	xor    $0x1f,%ebp
  80198a:	75 3c                	jne    8019c8 <__udivdi3+0x98>
  80198c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801990:	39 34 24             	cmp    %esi,(%esp)
  801993:	0f 86 9f 00 00 00    	jbe    801a38 <__udivdi3+0x108>
  801999:	39 d0                	cmp    %edx,%eax
  80199b:	0f 82 97 00 00 00    	jb     801a38 <__udivdi3+0x108>
  8019a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8019a8:	31 d2                	xor    %edx,%edx
  8019aa:	31 c0                	xor    %eax,%eax
  8019ac:	83 c4 0c             	add    $0xc,%esp
  8019af:	5e                   	pop    %esi
  8019b0:	5f                   	pop    %edi
  8019b1:	5d                   	pop    %ebp
  8019b2:	c3                   	ret    
  8019b3:	90                   	nop
  8019b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8019b8:	89 f8                	mov    %edi,%eax
  8019ba:	f7 f1                	div    %ecx
  8019bc:	31 d2                	xor    %edx,%edx
  8019be:	83 c4 0c             	add    $0xc,%esp
  8019c1:	5e                   	pop    %esi
  8019c2:	5f                   	pop    %edi
  8019c3:	5d                   	pop    %ebp
  8019c4:	c3                   	ret    
  8019c5:	8d 76 00             	lea    0x0(%esi),%esi
  8019c8:	89 e9                	mov    %ebp,%ecx
  8019ca:	8b 3c 24             	mov    (%esp),%edi
  8019cd:	d3 e0                	shl    %cl,%eax
  8019cf:	89 c6                	mov    %eax,%esi
  8019d1:	b8 20 00 00 00       	mov    $0x20,%eax
  8019d6:	29 e8                	sub    %ebp,%eax
  8019d8:	89 c1                	mov    %eax,%ecx
  8019da:	d3 ef                	shr    %cl,%edi
  8019dc:	89 e9                	mov    %ebp,%ecx
  8019de:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8019e2:	8b 3c 24             	mov    (%esp),%edi
  8019e5:	09 74 24 08          	or     %esi,0x8(%esp)
  8019e9:	89 d6                	mov    %edx,%esi
  8019eb:	d3 e7                	shl    %cl,%edi
  8019ed:	89 c1                	mov    %eax,%ecx
  8019ef:	89 3c 24             	mov    %edi,(%esp)
  8019f2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8019f6:	d3 ee                	shr    %cl,%esi
  8019f8:	89 e9                	mov    %ebp,%ecx
  8019fa:	d3 e2                	shl    %cl,%edx
  8019fc:	89 c1                	mov    %eax,%ecx
  8019fe:	d3 ef                	shr    %cl,%edi
  801a00:	09 d7                	or     %edx,%edi
  801a02:	89 f2                	mov    %esi,%edx
  801a04:	89 f8                	mov    %edi,%eax
  801a06:	f7 74 24 08          	divl   0x8(%esp)
  801a0a:	89 d6                	mov    %edx,%esi
  801a0c:	89 c7                	mov    %eax,%edi
  801a0e:	f7 24 24             	mull   (%esp)
  801a11:	39 d6                	cmp    %edx,%esi
  801a13:	89 14 24             	mov    %edx,(%esp)
  801a16:	72 30                	jb     801a48 <__udivdi3+0x118>
  801a18:	8b 54 24 04          	mov    0x4(%esp),%edx
  801a1c:	89 e9                	mov    %ebp,%ecx
  801a1e:	d3 e2                	shl    %cl,%edx
  801a20:	39 c2                	cmp    %eax,%edx
  801a22:	73 05                	jae    801a29 <__udivdi3+0xf9>
  801a24:	3b 34 24             	cmp    (%esp),%esi
  801a27:	74 1f                	je     801a48 <__udivdi3+0x118>
  801a29:	89 f8                	mov    %edi,%eax
  801a2b:	31 d2                	xor    %edx,%edx
  801a2d:	e9 7a ff ff ff       	jmp    8019ac <__udivdi3+0x7c>
  801a32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801a38:	31 d2                	xor    %edx,%edx
  801a3a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a3f:	e9 68 ff ff ff       	jmp    8019ac <__udivdi3+0x7c>
  801a44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a48:	8d 47 ff             	lea    -0x1(%edi),%eax
  801a4b:	31 d2                	xor    %edx,%edx
  801a4d:	83 c4 0c             	add    $0xc,%esp
  801a50:	5e                   	pop    %esi
  801a51:	5f                   	pop    %edi
  801a52:	5d                   	pop    %ebp
  801a53:	c3                   	ret    
  801a54:	66 90                	xchg   %ax,%ax
  801a56:	66 90                	xchg   %ax,%ax
  801a58:	66 90                	xchg   %ax,%ax
  801a5a:	66 90                	xchg   %ax,%ax
  801a5c:	66 90                	xchg   %ax,%ax
  801a5e:	66 90                	xchg   %ax,%ax

00801a60 <__umoddi3>:
  801a60:	55                   	push   %ebp
  801a61:	57                   	push   %edi
  801a62:	56                   	push   %esi
  801a63:	83 ec 14             	sub    $0x14,%esp
  801a66:	8b 44 24 28          	mov    0x28(%esp),%eax
  801a6a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801a6e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801a72:	89 c7                	mov    %eax,%edi
  801a74:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a78:	8b 44 24 30          	mov    0x30(%esp),%eax
  801a7c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801a80:	89 34 24             	mov    %esi,(%esp)
  801a83:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a87:	85 c0                	test   %eax,%eax
  801a89:	89 c2                	mov    %eax,%edx
  801a8b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a8f:	75 17                	jne    801aa8 <__umoddi3+0x48>
  801a91:	39 fe                	cmp    %edi,%esi
  801a93:	76 4b                	jbe    801ae0 <__umoddi3+0x80>
  801a95:	89 c8                	mov    %ecx,%eax
  801a97:	89 fa                	mov    %edi,%edx
  801a99:	f7 f6                	div    %esi
  801a9b:	89 d0                	mov    %edx,%eax
  801a9d:	31 d2                	xor    %edx,%edx
  801a9f:	83 c4 14             	add    $0x14,%esp
  801aa2:	5e                   	pop    %esi
  801aa3:	5f                   	pop    %edi
  801aa4:	5d                   	pop    %ebp
  801aa5:	c3                   	ret    
  801aa6:	66 90                	xchg   %ax,%ax
  801aa8:	39 f8                	cmp    %edi,%eax
  801aaa:	77 54                	ja     801b00 <__umoddi3+0xa0>
  801aac:	0f bd e8             	bsr    %eax,%ebp
  801aaf:	83 f5 1f             	xor    $0x1f,%ebp
  801ab2:	75 5c                	jne    801b10 <__umoddi3+0xb0>
  801ab4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801ab8:	39 3c 24             	cmp    %edi,(%esp)
  801abb:	0f 87 e7 00 00 00    	ja     801ba8 <__umoddi3+0x148>
  801ac1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ac5:	29 f1                	sub    %esi,%ecx
  801ac7:	19 c7                	sbb    %eax,%edi
  801ac9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801acd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ad1:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ad5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ad9:	83 c4 14             	add    $0x14,%esp
  801adc:	5e                   	pop    %esi
  801add:	5f                   	pop    %edi
  801ade:	5d                   	pop    %ebp
  801adf:	c3                   	ret    
  801ae0:	85 f6                	test   %esi,%esi
  801ae2:	89 f5                	mov    %esi,%ebp
  801ae4:	75 0b                	jne    801af1 <__umoddi3+0x91>
  801ae6:	b8 01 00 00 00       	mov    $0x1,%eax
  801aeb:	31 d2                	xor    %edx,%edx
  801aed:	f7 f6                	div    %esi
  801aef:	89 c5                	mov    %eax,%ebp
  801af1:	8b 44 24 04          	mov    0x4(%esp),%eax
  801af5:	31 d2                	xor    %edx,%edx
  801af7:	f7 f5                	div    %ebp
  801af9:	89 c8                	mov    %ecx,%eax
  801afb:	f7 f5                	div    %ebp
  801afd:	eb 9c                	jmp    801a9b <__umoddi3+0x3b>
  801aff:	90                   	nop
  801b00:	89 c8                	mov    %ecx,%eax
  801b02:	89 fa                	mov    %edi,%edx
  801b04:	83 c4 14             	add    $0x14,%esp
  801b07:	5e                   	pop    %esi
  801b08:	5f                   	pop    %edi
  801b09:	5d                   	pop    %ebp
  801b0a:	c3                   	ret    
  801b0b:	90                   	nop
  801b0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b10:	8b 04 24             	mov    (%esp),%eax
  801b13:	be 20 00 00 00       	mov    $0x20,%esi
  801b18:	89 e9                	mov    %ebp,%ecx
  801b1a:	29 ee                	sub    %ebp,%esi
  801b1c:	d3 e2                	shl    %cl,%edx
  801b1e:	89 f1                	mov    %esi,%ecx
  801b20:	d3 e8                	shr    %cl,%eax
  801b22:	89 e9                	mov    %ebp,%ecx
  801b24:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b28:	8b 04 24             	mov    (%esp),%eax
  801b2b:	09 54 24 04          	or     %edx,0x4(%esp)
  801b2f:	89 fa                	mov    %edi,%edx
  801b31:	d3 e0                	shl    %cl,%eax
  801b33:	89 f1                	mov    %esi,%ecx
  801b35:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b39:	8b 44 24 10          	mov    0x10(%esp),%eax
  801b3d:	d3 ea                	shr    %cl,%edx
  801b3f:	89 e9                	mov    %ebp,%ecx
  801b41:	d3 e7                	shl    %cl,%edi
  801b43:	89 f1                	mov    %esi,%ecx
  801b45:	d3 e8                	shr    %cl,%eax
  801b47:	89 e9                	mov    %ebp,%ecx
  801b49:	09 f8                	or     %edi,%eax
  801b4b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801b4f:	f7 74 24 04          	divl   0x4(%esp)
  801b53:	d3 e7                	shl    %cl,%edi
  801b55:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b59:	89 d7                	mov    %edx,%edi
  801b5b:	f7 64 24 08          	mull   0x8(%esp)
  801b5f:	39 d7                	cmp    %edx,%edi
  801b61:	89 c1                	mov    %eax,%ecx
  801b63:	89 14 24             	mov    %edx,(%esp)
  801b66:	72 2c                	jb     801b94 <__umoddi3+0x134>
  801b68:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801b6c:	72 22                	jb     801b90 <__umoddi3+0x130>
  801b6e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801b72:	29 c8                	sub    %ecx,%eax
  801b74:	19 d7                	sbb    %edx,%edi
  801b76:	89 e9                	mov    %ebp,%ecx
  801b78:	89 fa                	mov    %edi,%edx
  801b7a:	d3 e8                	shr    %cl,%eax
  801b7c:	89 f1                	mov    %esi,%ecx
  801b7e:	d3 e2                	shl    %cl,%edx
  801b80:	89 e9                	mov    %ebp,%ecx
  801b82:	d3 ef                	shr    %cl,%edi
  801b84:	09 d0                	or     %edx,%eax
  801b86:	89 fa                	mov    %edi,%edx
  801b88:	83 c4 14             	add    $0x14,%esp
  801b8b:	5e                   	pop    %esi
  801b8c:	5f                   	pop    %edi
  801b8d:	5d                   	pop    %ebp
  801b8e:	c3                   	ret    
  801b8f:	90                   	nop
  801b90:	39 d7                	cmp    %edx,%edi
  801b92:	75 da                	jne    801b6e <__umoddi3+0x10e>
  801b94:	8b 14 24             	mov    (%esp),%edx
  801b97:	89 c1                	mov    %eax,%ecx
  801b99:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801b9d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801ba1:	eb cb                	jmp    801b6e <__umoddi3+0x10e>
  801ba3:	90                   	nop
  801ba4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ba8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801bac:	0f 82 0f ff ff ff    	jb     801ac1 <__umoddi3+0x61>
  801bb2:	e9 1a ff ff ff       	jmp    801ad1 <__umoddi3+0x71>
