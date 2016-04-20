
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 96 00 00 00       	call   8000c7 <libmain>
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
	envid_t who, id;

	id = sys_getenvid();
  800039:	e8 19 0f 00 00       	call   800f57 <sys_getenvid>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)

	if (thisenv == &envs[1]) {
  800041:	a1 04 20 80 00       	mov    0x802004,%eax
  800046:	3d 7c 00 c0 ee       	cmp    $0xeec0007c,%eax
  80004b:	75 37                	jne    800084 <umain+0x51>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800054:	00 
  800055:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80005c:	00 
  80005d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800060:	89 04 24             	mov    %eax,(%esp)
  800063:	e8 47 11 00 00       	call   8011af <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  800068:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80006b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800072:	89 44 24 04          	mov    %eax,0x4(%esp)
  800076:	c7 04 24 a0 16 80 00 	movl   $0x8016a0,(%esp)
  80007d:	e8 67 01 00 00       	call   8001e9 <cprintf>
		}
  800082:	eb c9                	jmp    80004d <umain+0x1a>
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800084:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800089:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800090:	89 44 24 04          	mov    %eax,0x4(%esp)
  800094:	c7 04 24 b1 16 80 00 	movl   $0x8016b1,(%esp)
  80009b:	e8 49 01 00 00       	call   8001e9 <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  8000a0:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  8000a5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000ac:	00 
  8000ad:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b4:	00 
  8000b5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000bc:	00 
  8000bd:	89 04 24             	mov    %eax,(%esp)
  8000c0:	e8 86 11 00 00       	call   80124b <ipc_send>
  8000c5:	eb d9                	jmp    8000a0 <umain+0x6d>

008000c7 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c7:	55                   	push   %ebp
  8000c8:	89 e5                	mov    %esp,%ebp
  8000ca:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000cd:	e8 85 0e 00 00       	call   800f57 <sys_getenvid>
  8000d2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d7:	c1 e0 02             	shl    $0x2,%eax
  8000da:	89 c2                	mov    %eax,%edx
  8000dc:	c1 e2 05             	shl    $0x5,%edx
  8000df:	29 c2                	sub    %eax,%edx
  8000e1:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  8000e7:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000f0:	7e 0a                	jle    8000fc <libmain+0x35>
		binaryname = argv[0];
  8000f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f5:	8b 00                	mov    (%eax),%eax
  8000f7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800103:	8b 45 08             	mov    0x8(%ebp),%eax
  800106:	89 04 24             	mov    %eax,(%esp)
  800109:	e8 25 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80010e:	e8 02 00 00 00       	call   800115 <exit>
}
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80011b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800122:	e8 ed 0d 00 00       	call   800f14 <sys_env_destroy>
}
  800127:	c9                   	leave  
  800128:	c3                   	ret    

00800129 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  80012f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800132:	8b 00                	mov    (%eax),%eax
  800134:	8d 48 01             	lea    0x1(%eax),%ecx
  800137:	8b 55 0c             	mov    0xc(%ebp),%edx
  80013a:	89 0a                	mov    %ecx,(%edx)
  80013c:	8b 55 08             	mov    0x8(%ebp),%edx
  80013f:	89 d1                	mov    %edx,%ecx
  800141:	8b 55 0c             	mov    0xc(%ebp),%edx
  800144:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800148:	8b 45 0c             	mov    0xc(%ebp),%eax
  80014b:	8b 00                	mov    (%eax),%eax
  80014d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800152:	75 20                	jne    800174 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800154:	8b 45 0c             	mov    0xc(%ebp),%eax
  800157:	8b 00                	mov    (%eax),%eax
  800159:	8b 55 0c             	mov    0xc(%ebp),%edx
  80015c:	83 c2 08             	add    $0x8,%edx
  80015f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800163:	89 14 24             	mov    %edx,(%esp)
  800166:	e8 23 0d 00 00       	call   800e8e <sys_cputs>
		b->idx = 0;
  80016b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80016e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800174:	8b 45 0c             	mov    0xc(%ebp),%eax
  800177:	8b 40 04             	mov    0x4(%eax),%eax
  80017a:	8d 50 01             	lea    0x1(%eax),%edx
  80017d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800180:	89 50 04             	mov    %edx,0x4(%eax)
}
  800183:	c9                   	leave  
  800184:	c3                   	ret    

00800185 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80018e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800195:	00 00 00 
	b.cnt = 0;
  800198:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80019f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ba:	c7 04 24 29 01 80 00 	movl   $0x800129,(%esp)
  8001c1:	e8 bd 01 00 00       	call   800383 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001c6:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d6:	83 c0 08             	add    $0x8,%eax
  8001d9:	89 04 24             	mov    %eax,(%esp)
  8001dc:	e8 ad 0c 00 00       	call   800e8e <sys_cputs>

	return b.cnt;
  8001e1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8001e7:	c9                   	leave  
  8001e8:	c3                   	ret    

008001e9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ef:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8001f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ff:	89 04 24             	mov    %eax,(%esp)
  800202:	e8 7e ff ff ff       	call   800185 <vcprintf>
  800207:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80020a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	53                   	push   %ebx
  800213:	83 ec 34             	sub    $0x34,%esp
  800216:	8b 45 10             	mov    0x10(%ebp),%eax
  800219:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80021c:	8b 45 14             	mov    0x14(%ebp),%eax
  80021f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800222:	8b 45 18             	mov    0x18(%ebp),%eax
  800225:	ba 00 00 00 00       	mov    $0x0,%edx
  80022a:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80022d:	77 72                	ja     8002a1 <printnum+0x92>
  80022f:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800232:	72 05                	jb     800239 <printnum+0x2a>
  800234:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800237:	77 68                	ja     8002a1 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800239:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80023c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80023f:	8b 45 18             	mov    0x18(%ebp),%eax
  800242:	ba 00 00 00 00       	mov    $0x0,%edx
  800247:	89 44 24 08          	mov    %eax,0x8(%esp)
  80024b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80024f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800252:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800255:	89 04 24             	mov    %eax,(%esp)
  800258:	89 54 24 04          	mov    %edx,0x4(%esp)
  80025c:	e8 9f 11 00 00       	call   801400 <__udivdi3>
  800261:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800264:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800268:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80026c:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80026f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800273:	89 44 24 08          	mov    %eax,0x8(%esp)
  800277:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80027b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	89 04 24             	mov    %eax,(%esp)
  800288:	e8 82 ff ff ff       	call   80020f <printnum>
  80028d:	eb 1c                	jmp    8002ab <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800292:	89 44 24 04          	mov    %eax,0x4(%esp)
  800296:	8b 45 20             	mov    0x20(%ebp),%eax
  800299:	89 04 24             	mov    %eax,(%esp)
  80029c:	8b 45 08             	mov    0x8(%ebp),%eax
  80029f:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a1:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8002a5:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8002a9:	7f e4                	jg     80028f <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ab:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8002b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002bd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002c1:	89 04 24             	mov    %eax,(%esp)
  8002c4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002c8:	e8 63 12 00 00       	call   801530 <__umoddi3>
  8002cd:	05 a8 17 80 00       	add    $0x8017a8,%eax
  8002d2:	0f b6 00             	movzbl (%eax),%eax
  8002d5:	0f be c0             	movsbl %al,%eax
  8002d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002db:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002df:	89 04 24             	mov    %eax,(%esp)
  8002e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e5:	ff d0                	call   *%eax
}
  8002e7:	83 c4 34             	add    $0x34,%esp
  8002ea:	5b                   	pop    %ebx
  8002eb:	5d                   	pop    %ebp
  8002ec:	c3                   	ret    

008002ed <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f0:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002f4:	7e 14                	jle    80030a <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8002f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f9:	8b 00                	mov    (%eax),%eax
  8002fb:	8d 48 08             	lea    0x8(%eax),%ecx
  8002fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800301:	89 0a                	mov    %ecx,(%edx)
  800303:	8b 50 04             	mov    0x4(%eax),%edx
  800306:	8b 00                	mov    (%eax),%eax
  800308:	eb 30                	jmp    80033a <getuint+0x4d>
	else if (lflag)
  80030a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80030e:	74 16                	je     800326 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800310:	8b 45 08             	mov    0x8(%ebp),%eax
  800313:	8b 00                	mov    (%eax),%eax
  800315:	8d 48 04             	lea    0x4(%eax),%ecx
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	89 0a                	mov    %ecx,(%edx)
  80031d:	8b 00                	mov    (%eax),%eax
  80031f:	ba 00 00 00 00       	mov    $0x0,%edx
  800324:	eb 14                	jmp    80033a <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800326:	8b 45 08             	mov    0x8(%ebp),%eax
  800329:	8b 00                	mov    (%eax),%eax
  80032b:	8d 48 04             	lea    0x4(%eax),%ecx
  80032e:	8b 55 08             	mov    0x8(%ebp),%edx
  800331:	89 0a                	mov    %ecx,(%edx)
  800333:	8b 00                	mov    (%eax),%eax
  800335:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80033a:	5d                   	pop    %ebp
  80033b:	c3                   	ret    

0080033c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80033f:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800343:	7e 14                	jle    800359 <getint+0x1d>
		return va_arg(*ap, long long);
  800345:	8b 45 08             	mov    0x8(%ebp),%eax
  800348:	8b 00                	mov    (%eax),%eax
  80034a:	8d 48 08             	lea    0x8(%eax),%ecx
  80034d:	8b 55 08             	mov    0x8(%ebp),%edx
  800350:	89 0a                	mov    %ecx,(%edx)
  800352:	8b 50 04             	mov    0x4(%eax),%edx
  800355:	8b 00                	mov    (%eax),%eax
  800357:	eb 28                	jmp    800381 <getint+0x45>
	else if (lflag)
  800359:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80035d:	74 12                	je     800371 <getint+0x35>
		return va_arg(*ap, long);
  80035f:	8b 45 08             	mov    0x8(%ebp),%eax
  800362:	8b 00                	mov    (%eax),%eax
  800364:	8d 48 04             	lea    0x4(%eax),%ecx
  800367:	8b 55 08             	mov    0x8(%ebp),%edx
  80036a:	89 0a                	mov    %ecx,(%edx)
  80036c:	8b 00                	mov    (%eax),%eax
  80036e:	99                   	cltd   
  80036f:	eb 10                	jmp    800381 <getint+0x45>
	else
		return va_arg(*ap, int);
  800371:	8b 45 08             	mov    0x8(%ebp),%eax
  800374:	8b 00                	mov    (%eax),%eax
  800376:	8d 48 04             	lea    0x4(%eax),%ecx
  800379:	8b 55 08             	mov    0x8(%ebp),%edx
  80037c:	89 0a                	mov    %ecx,(%edx)
  80037e:	8b 00                	mov    (%eax),%eax
  800380:	99                   	cltd   
}
  800381:	5d                   	pop    %ebp
  800382:	c3                   	ret    

00800383 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	56                   	push   %esi
  800387:	53                   	push   %ebx
  800388:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038b:	eb 18                	jmp    8003a5 <vprintfmt+0x22>
			if (ch == '\0')
  80038d:	85 db                	test   %ebx,%ebx
  80038f:	75 05                	jne    800396 <vprintfmt+0x13>
				return;
  800391:	e9 05 04 00 00       	jmp    80079b <vprintfmt+0x418>
			putch(ch, putdat);
  800396:	8b 45 0c             	mov    0xc(%ebp),%eax
  800399:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039d:	89 1c 24             	mov    %ebx,(%esp)
  8003a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a3:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a8:	8d 50 01             	lea    0x1(%eax),%edx
  8003ab:	89 55 10             	mov    %edx,0x10(%ebp)
  8003ae:	0f b6 00             	movzbl (%eax),%eax
  8003b1:	0f b6 d8             	movzbl %al,%ebx
  8003b4:	83 fb 25             	cmp    $0x25,%ebx
  8003b7:	75 d4                	jne    80038d <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8003b9:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8003bd:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8003c4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003cb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8003d2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003dc:	8d 50 01             	lea    0x1(%eax),%edx
  8003df:	89 55 10             	mov    %edx,0x10(%ebp)
  8003e2:	0f b6 00             	movzbl (%eax),%eax
  8003e5:	0f b6 d8             	movzbl %al,%ebx
  8003e8:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8003eb:	83 f8 55             	cmp    $0x55,%eax
  8003ee:	0f 87 76 03 00 00    	ja     80076a <vprintfmt+0x3e7>
  8003f4:	8b 04 85 cc 17 80 00 	mov    0x8017cc(,%eax,4),%eax
  8003fb:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8003fd:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800401:	eb d6                	jmp    8003d9 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800403:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800407:	eb d0                	jmp    8003d9 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800409:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800410:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800413:	89 d0                	mov    %edx,%eax
  800415:	c1 e0 02             	shl    $0x2,%eax
  800418:	01 d0                	add    %edx,%eax
  80041a:	01 c0                	add    %eax,%eax
  80041c:	01 d8                	add    %ebx,%eax
  80041e:	83 e8 30             	sub    $0x30,%eax
  800421:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800424:	8b 45 10             	mov    0x10(%ebp),%eax
  800427:	0f b6 00             	movzbl (%eax),%eax
  80042a:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80042d:	83 fb 2f             	cmp    $0x2f,%ebx
  800430:	7e 0b                	jle    80043d <vprintfmt+0xba>
  800432:	83 fb 39             	cmp    $0x39,%ebx
  800435:	7f 06                	jg     80043d <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800437:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80043b:	eb d3                	jmp    800410 <vprintfmt+0x8d>
			goto process_precision;
  80043d:	eb 33                	jmp    800472 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	8d 50 04             	lea    0x4(%eax),%edx
  800445:	89 55 14             	mov    %edx,0x14(%ebp)
  800448:	8b 00                	mov    (%eax),%eax
  80044a:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80044d:	eb 23                	jmp    800472 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80044f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800453:	79 0c                	jns    800461 <vprintfmt+0xde>
				width = 0;
  800455:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80045c:	e9 78 ff ff ff       	jmp    8003d9 <vprintfmt+0x56>
  800461:	e9 73 ff ff ff       	jmp    8003d9 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800466:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80046d:	e9 67 ff ff ff       	jmp    8003d9 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800472:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800476:	79 12                	jns    80048a <vprintfmt+0x107>
				width = precision, precision = -1;
  800478:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80047b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80047e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800485:	e9 4f ff ff ff       	jmp    8003d9 <vprintfmt+0x56>
  80048a:	e9 4a ff ff ff       	jmp    8003d9 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048f:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800493:	e9 41 ff ff ff       	jmp    8003d9 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800498:	8b 45 14             	mov    0x14(%ebp),%eax
  80049b:	8d 50 04             	lea    0x4(%eax),%edx
  80049e:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a1:	8b 00                	mov    (%eax),%eax
  8004a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004aa:	89 04 24             	mov    %eax,(%esp)
  8004ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b0:	ff d0                	call   *%eax
			break;
  8004b2:	e9 de 02 00 00       	jmp    800795 <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ba:	8d 50 04             	lea    0x4(%eax),%edx
  8004bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c0:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8004c2:	85 db                	test   %ebx,%ebx
  8004c4:	79 02                	jns    8004c8 <vprintfmt+0x145>
				err = -err;
  8004c6:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c8:	83 fb 09             	cmp    $0x9,%ebx
  8004cb:	7f 0b                	jg     8004d8 <vprintfmt+0x155>
  8004cd:	8b 34 9d 80 17 80 00 	mov    0x801780(,%ebx,4),%esi
  8004d4:	85 f6                	test   %esi,%esi
  8004d6:	75 23                	jne    8004fb <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8004d8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004dc:	c7 44 24 08 b9 17 80 	movl   $0x8017b9,0x8(%esp)
  8004e3:	00 
  8004e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ee:	89 04 24             	mov    %eax,(%esp)
  8004f1:	e8 ac 02 00 00       	call   8007a2 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8004f6:	e9 9a 02 00 00       	jmp    800795 <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004fb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004ff:	c7 44 24 08 c2 17 80 	movl   $0x8017c2,0x8(%esp)
  800506:	00 
  800507:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050e:	8b 45 08             	mov    0x8(%ebp),%eax
  800511:	89 04 24             	mov    %eax,(%esp)
  800514:	e8 89 02 00 00       	call   8007a2 <printfmt>
			break;
  800519:	e9 77 02 00 00       	jmp    800795 <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80051e:	8b 45 14             	mov    0x14(%ebp),%eax
  800521:	8d 50 04             	lea    0x4(%eax),%edx
  800524:	89 55 14             	mov    %edx,0x14(%ebp)
  800527:	8b 30                	mov    (%eax),%esi
  800529:	85 f6                	test   %esi,%esi
  80052b:	75 05                	jne    800532 <vprintfmt+0x1af>
				p = "(null)";
  80052d:	be c5 17 80 00       	mov    $0x8017c5,%esi
			if (width > 0 && padc != '-')
  800532:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800536:	7e 37                	jle    80056f <vprintfmt+0x1ec>
  800538:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80053c:	74 31                	je     80056f <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800541:	89 44 24 04          	mov    %eax,0x4(%esp)
  800545:	89 34 24             	mov    %esi,(%esp)
  800548:	e8 72 03 00 00       	call   8008bf <strnlen>
  80054d:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800550:	eb 17                	jmp    800569 <vprintfmt+0x1e6>
					putch(padc, putdat);
  800552:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800556:	8b 55 0c             	mov    0xc(%ebp),%edx
  800559:	89 54 24 04          	mov    %edx,0x4(%esp)
  80055d:	89 04 24             	mov    %eax,(%esp)
  800560:	8b 45 08             	mov    0x8(%ebp),%eax
  800563:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800565:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800569:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80056d:	7f e3                	jg     800552 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056f:	eb 38                	jmp    8005a9 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800571:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800575:	74 1f                	je     800596 <vprintfmt+0x213>
  800577:	83 fb 1f             	cmp    $0x1f,%ebx
  80057a:	7e 05                	jle    800581 <vprintfmt+0x1fe>
  80057c:	83 fb 7e             	cmp    $0x7e,%ebx
  80057f:	7e 15                	jle    800596 <vprintfmt+0x213>
					putch('?', putdat);
  800581:	8b 45 0c             	mov    0xc(%ebp),%eax
  800584:	89 44 24 04          	mov    %eax,0x4(%esp)
  800588:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80058f:	8b 45 08             	mov    0x8(%ebp),%eax
  800592:	ff d0                	call   *%eax
  800594:	eb 0f                	jmp    8005a5 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800596:	8b 45 0c             	mov    0xc(%ebp),%eax
  800599:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059d:	89 1c 24             	mov    %ebx,(%esp)
  8005a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a3:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a5:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005a9:	89 f0                	mov    %esi,%eax
  8005ab:	8d 70 01             	lea    0x1(%eax),%esi
  8005ae:	0f b6 00             	movzbl (%eax),%eax
  8005b1:	0f be d8             	movsbl %al,%ebx
  8005b4:	85 db                	test   %ebx,%ebx
  8005b6:	74 10                	je     8005c8 <vprintfmt+0x245>
  8005b8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005bc:	78 b3                	js     800571 <vprintfmt+0x1ee>
  8005be:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005c2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c6:	79 a9                	jns    800571 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c8:	eb 17                	jmp    8005e1 <vprintfmt+0x25e>
				putch(' ', putdat);
  8005ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005db:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005dd:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005e1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005e5:	7f e3                	jg     8005ca <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8005e7:	e9 a9 01 00 00       	jmp    800795 <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f6:	89 04 24             	mov    %eax,(%esp)
  8005f9:	e8 3e fd ff ff       	call   80033c <getint>
  8005fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800601:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800604:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800607:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80060a:	85 d2                	test   %edx,%edx
  80060c:	79 26                	jns    800634 <vprintfmt+0x2b1>
				putch('-', putdat);
  80060e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800611:	89 44 24 04          	mov    %eax,0x4(%esp)
  800615:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80061c:	8b 45 08             	mov    0x8(%ebp),%eax
  80061f:	ff d0                	call   *%eax
				num = -(long long) num;
  800621:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800624:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800627:	f7 d8                	neg    %eax
  800629:	83 d2 00             	adc    $0x0,%edx
  80062c:	f7 da                	neg    %edx
  80062e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800631:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800634:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80063b:	e9 e1 00 00 00       	jmp    800721 <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800640:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800643:	89 44 24 04          	mov    %eax,0x4(%esp)
  800647:	8d 45 14             	lea    0x14(%ebp),%eax
  80064a:	89 04 24             	mov    %eax,(%esp)
  80064d:	e8 9b fc ff ff       	call   8002ed <getuint>
  800652:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800655:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800658:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80065f:	e9 bd 00 00 00       	jmp    800721 <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  800664:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  80066b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80066e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800672:	8d 45 14             	lea    0x14(%ebp),%eax
  800675:	89 04 24             	mov    %eax,(%esp)
  800678:	e8 70 fc ff ff       	call   8002ed <getuint>
  80067d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800680:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  800683:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800687:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80068a:	89 54 24 18          	mov    %edx,0x18(%esp)
  80068e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800691:	89 54 24 14          	mov    %edx,0x14(%esp)
  800695:	89 44 24 10          	mov    %eax,0x10(%esp)
  800699:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80069c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80069f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b1:	89 04 24             	mov    %eax,(%esp)
  8006b4:	e8 56 fb ff ff       	call   80020f <printnum>
			break;
  8006b9:	e9 d7 00 00 00       	jmp    800795 <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  8006be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c5:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cf:	ff d0                	call   *%eax
			putch('x', putdat);
  8006d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006df:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e2:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ed:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006f9:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800700:	eb 1f                	jmp    800721 <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800702:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800705:	89 44 24 04          	mov    %eax,0x4(%esp)
  800709:	8d 45 14             	lea    0x14(%ebp),%eax
  80070c:	89 04 24             	mov    %eax,(%esp)
  80070f:	e8 d9 fb ff ff       	call   8002ed <getuint>
  800714:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800717:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  80071a:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800721:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800725:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800728:	89 54 24 18          	mov    %edx,0x18(%esp)
  80072c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80072f:	89 54 24 14          	mov    %edx,0x14(%esp)
  800733:	89 44 24 10          	mov    %eax,0x10(%esp)
  800737:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80073d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800741:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800745:	8b 45 0c             	mov    0xc(%ebp),%eax
  800748:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074c:	8b 45 08             	mov    0x8(%ebp),%eax
  80074f:	89 04 24             	mov    %eax,(%esp)
  800752:	e8 b8 fa ff ff       	call   80020f <printnum>
			break;
  800757:	eb 3c                	jmp    800795 <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800759:	8b 45 0c             	mov    0xc(%ebp),%eax
  80075c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800760:	89 1c 24             	mov    %ebx,(%esp)
  800763:	8b 45 08             	mov    0x8(%ebp),%eax
  800766:	ff d0                	call   *%eax
			break;
  800768:	eb 2b                	jmp    800795 <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80076a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800771:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800778:	8b 45 08             	mov    0x8(%ebp),%eax
  80077b:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  80077d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800781:	eb 04                	jmp    800787 <vprintfmt+0x404>
  800783:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800787:	8b 45 10             	mov    0x10(%ebp),%eax
  80078a:	83 e8 01             	sub    $0x1,%eax
  80078d:	0f b6 00             	movzbl (%eax),%eax
  800790:	3c 25                	cmp    $0x25,%al
  800792:	75 ef                	jne    800783 <vprintfmt+0x400>
				/* do nothing */;
			break;
  800794:	90                   	nop
		}
	}
  800795:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800796:	e9 0a fc ff ff       	jmp    8003a5 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80079b:	83 c4 40             	add    $0x40,%esp
  80079e:	5b                   	pop    %ebx
  80079f:	5e                   	pop    %esi
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8007a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8007ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c6:	89 04 24             	mov    %eax,(%esp)
  8007c9:	e8 b5 fb ff ff       	call   800383 <vprintfmt>
	va_end(ap);
}
  8007ce:	c9                   	leave  
  8007cf:	c3                   	ret    

008007d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  8007d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d6:	8b 40 08             	mov    0x8(%eax),%eax
  8007d9:	8d 50 01             	lea    0x1(%eax),%edx
  8007dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007df:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  8007e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e5:	8b 10                	mov    (%eax),%edx
  8007e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ea:	8b 40 04             	mov    0x4(%eax),%eax
  8007ed:	39 c2                	cmp    %eax,%edx
  8007ef:	73 12                	jae    800803 <sprintputch+0x33>
		*b->buf++ = ch;
  8007f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f4:	8b 00                	mov    (%eax),%eax
  8007f6:	8d 48 01             	lea    0x1(%eax),%ecx
  8007f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fc:	89 0a                	mov    %ecx,(%edx)
  8007fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800801:	88 10                	mov    %dl,(%eax)
}
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800811:	8b 45 0c             	mov    0xc(%ebp),%eax
  800814:	8d 50 ff             	lea    -0x1(%eax),%edx
  800817:	8b 45 08             	mov    0x8(%ebp),%eax
  80081a:	01 d0                	add    %edx,%eax
  80081c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80081f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800826:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80082a:	74 06                	je     800832 <vsnprintf+0x2d>
  80082c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800830:	7f 07                	jg     800839 <vsnprintf+0x34>
		return -E_INVAL;
  800832:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800837:	eb 2a                	jmp    800863 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800839:	8b 45 14             	mov    0x14(%ebp),%eax
  80083c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800840:	8b 45 10             	mov    0x10(%ebp),%eax
  800843:	89 44 24 08          	mov    %eax,0x8(%esp)
  800847:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084e:	c7 04 24 d0 07 80 00 	movl   $0x8007d0,(%esp)
  800855:	e8 29 fb ff ff       	call   800383 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80085a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800860:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800863:	c9                   	leave  
  800864:	c3                   	ret    

00800865 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80086b:	8d 45 14             	lea    0x14(%ebp),%eax
  80086e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800871:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800874:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800878:	8b 45 10             	mov    0x10(%ebp),%eax
  80087b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80087f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800882:	89 44 24 04          	mov    %eax,0x4(%esp)
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	89 04 24             	mov    %eax,(%esp)
  80088c:	e8 74 ff ff ff       	call   800805 <vsnprintf>
  800891:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800894:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800897:	c9                   	leave  
  800898:	c3                   	ret    

00800899 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  80089f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008a6:	eb 08                	jmp    8008b0 <strlen+0x17>
		n++;
  8008a8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ac:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	0f b6 00             	movzbl (%eax),%eax
  8008b6:	84 c0                	test   %al,%al
  8008b8:	75 ee                	jne    8008a8 <strlen+0xf>
		n++;
	return n;
  8008ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008bd:	c9                   	leave  
  8008be:	c3                   	ret    

008008bf <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008cc:	eb 0c                	jmp    8008da <strnlen+0x1b>
		n++;
  8008ce:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8008d6:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  8008da:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008de:	74 0a                	je     8008ea <strnlen+0x2b>
  8008e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e3:	0f b6 00             	movzbl (%eax),%eax
  8008e6:	84 c0                	test   %al,%al
  8008e8:	75 e4                	jne    8008ce <strnlen+0xf>
		n++;
	return n;
  8008ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008ed:	c9                   	leave  
  8008ee:	c3                   	ret    

008008ef <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  8008fb:	90                   	nop
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ff:	8d 50 01             	lea    0x1(%eax),%edx
  800902:	89 55 08             	mov    %edx,0x8(%ebp)
  800905:	8b 55 0c             	mov    0xc(%ebp),%edx
  800908:	8d 4a 01             	lea    0x1(%edx),%ecx
  80090b:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  80090e:	0f b6 12             	movzbl (%edx),%edx
  800911:	88 10                	mov    %dl,(%eax)
  800913:	0f b6 00             	movzbl (%eax),%eax
  800916:	84 c0                	test   %al,%al
  800918:	75 e2                	jne    8008fc <strcpy+0xd>
		/* do nothing */;
	return ret;
  80091a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	89 04 24             	mov    %eax,(%esp)
  80092b:	e8 69 ff ff ff       	call   800899 <strlen>
  800930:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800933:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800936:	8b 45 08             	mov    0x8(%ebp),%eax
  800939:	01 c2                	add    %eax,%edx
  80093b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800942:	89 14 24             	mov    %edx,(%esp)
  800945:	e8 a5 ff ff ff       	call   8008ef <strcpy>
	return dst;
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    

0080094f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  80095b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800962:	eb 23                	jmp    800987 <strncpy+0x38>
		*dst++ = *src;
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	8d 50 01             	lea    0x1(%eax),%edx
  80096a:	89 55 08             	mov    %edx,0x8(%ebp)
  80096d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800970:	0f b6 12             	movzbl (%edx),%edx
  800973:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800975:	8b 45 0c             	mov    0xc(%ebp),%eax
  800978:	0f b6 00             	movzbl (%eax),%eax
  80097b:	84 c0                	test   %al,%al
  80097d:	74 04                	je     800983 <strncpy+0x34>
			src++;
  80097f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800983:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800987:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80098a:	3b 45 10             	cmp    0x10(%ebp),%eax
  80098d:	72 d5                	jb     800964 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  80098f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800992:	c9                   	leave  
  800993:	c3                   	ret    

00800994 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  8009a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009a4:	74 33                	je     8009d9 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009a6:	eb 17                	jmp    8009bf <strlcpy+0x2b>
			*dst++ = *src++;
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	8d 50 01             	lea    0x1(%eax),%edx
  8009ae:	89 55 08             	mov    %edx,0x8(%ebp)
  8009b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009b7:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009ba:	0f b6 12             	movzbl (%edx),%edx
  8009bd:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009bf:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8009c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009c7:	74 0a                	je     8009d3 <strlcpy+0x3f>
  8009c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cc:	0f b6 00             	movzbl (%eax),%eax
  8009cf:	84 c0                	test   %al,%al
  8009d1:	75 d5                	jne    8009a8 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  8009d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8009dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009df:	29 c2                	sub    %eax,%edx
  8009e1:	89 d0                	mov    %edx,%eax
}
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  8009e8:	eb 08                	jmp    8009f2 <strcmp+0xd>
		p++, q++;
  8009ea:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009ee:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	0f b6 00             	movzbl (%eax),%eax
  8009f8:	84 c0                	test   %al,%al
  8009fa:	74 10                	je     800a0c <strcmp+0x27>
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	0f b6 10             	movzbl (%eax),%edx
  800a02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a05:	0f b6 00             	movzbl (%eax),%eax
  800a08:	38 c2                	cmp    %al,%dl
  800a0a:	74 de                	je     8009ea <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	0f b6 00             	movzbl (%eax),%eax
  800a12:	0f b6 d0             	movzbl %al,%edx
  800a15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a18:	0f b6 00             	movzbl (%eax),%eax
  800a1b:	0f b6 c0             	movzbl %al,%eax
  800a1e:	29 c2                	sub    %eax,%edx
  800a20:	89 d0                	mov    %edx,%eax
}
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    

00800a24 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a27:	eb 0c                	jmp    800a35 <strncmp+0x11>
		n--, p++, q++;
  800a29:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a2d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a31:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a35:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a39:	74 1a                	je     800a55 <strncmp+0x31>
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3e:	0f b6 00             	movzbl (%eax),%eax
  800a41:	84 c0                	test   %al,%al
  800a43:	74 10                	je     800a55 <strncmp+0x31>
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
  800a48:	0f b6 10             	movzbl (%eax),%edx
  800a4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4e:	0f b6 00             	movzbl (%eax),%eax
  800a51:	38 c2                	cmp    %al,%dl
  800a53:	74 d4                	je     800a29 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800a55:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a59:	75 07                	jne    800a62 <strncmp+0x3e>
		return 0;
  800a5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a60:	eb 16                	jmp    800a78 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a62:	8b 45 08             	mov    0x8(%ebp),%eax
  800a65:	0f b6 00             	movzbl (%eax),%eax
  800a68:	0f b6 d0             	movzbl %al,%edx
  800a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6e:	0f b6 00             	movzbl (%eax),%eax
  800a71:	0f b6 c0             	movzbl %al,%eax
  800a74:	29 c2                	sub    %eax,%edx
  800a76:	89 d0                	mov    %edx,%eax
}
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	83 ec 04             	sub    $0x4,%esp
  800a80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a83:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a86:	eb 14                	jmp    800a9c <strchr+0x22>
		if (*s == c)
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	0f b6 00             	movzbl (%eax),%eax
  800a8e:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a91:	75 05                	jne    800a98 <strchr+0x1e>
			return (char *) s;
  800a93:	8b 45 08             	mov    0x8(%ebp),%eax
  800a96:	eb 13                	jmp    800aab <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a98:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	0f b6 00             	movzbl (%eax),%eax
  800aa2:	84 c0                	test   %al,%al
  800aa4:	75 e2                	jne    800a88 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800aa6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aab:	c9                   	leave  
  800aac:	c3                   	ret    

00800aad <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	83 ec 04             	sub    $0x4,%esp
  800ab3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab6:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800ab9:	eb 11                	jmp    800acc <strfind+0x1f>
		if (*s == c)
  800abb:	8b 45 08             	mov    0x8(%ebp),%eax
  800abe:	0f b6 00             	movzbl (%eax),%eax
  800ac1:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ac4:	75 02                	jne    800ac8 <strfind+0x1b>
			break;
  800ac6:	eb 0e                	jmp    800ad6 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ac8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800acc:	8b 45 08             	mov    0x8(%ebp),%eax
  800acf:	0f b6 00             	movzbl (%eax),%eax
  800ad2:	84 c0                	test   %al,%al
  800ad4:	75 e5                	jne    800abb <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800ad6:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ad9:	c9                   	leave  
  800ada:	c3                   	ret    

00800adb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
	char *p;

	if (n == 0)
  800adf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ae3:	75 05                	jne    800aea <memset+0xf>
		return v;
  800ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae8:	eb 5c                	jmp    800b46 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800aea:	8b 45 08             	mov    0x8(%ebp),%eax
  800aed:	83 e0 03             	and    $0x3,%eax
  800af0:	85 c0                	test   %eax,%eax
  800af2:	75 41                	jne    800b35 <memset+0x5a>
  800af4:	8b 45 10             	mov    0x10(%ebp),%eax
  800af7:	83 e0 03             	and    $0x3,%eax
  800afa:	85 c0                	test   %eax,%eax
  800afc:	75 37                	jne    800b35 <memset+0x5a>
		c &= 0xFF;
  800afe:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b08:	c1 e0 18             	shl    $0x18,%eax
  800b0b:	89 c2                	mov    %eax,%edx
  800b0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b10:	c1 e0 10             	shl    $0x10,%eax
  800b13:	09 c2                	or     %eax,%edx
  800b15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b18:	c1 e0 08             	shl    $0x8,%eax
  800b1b:	09 d0                	or     %edx,%eax
  800b1d:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b20:	8b 45 10             	mov    0x10(%ebp),%eax
  800b23:	c1 e8 02             	shr    $0x2,%eax
  800b26:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b28:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2e:	89 d7                	mov    %edx,%edi
  800b30:	fc                   	cld    
  800b31:	f3 ab                	rep stos %eax,%es:(%edi)
  800b33:	eb 0e                	jmp    800b43 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b35:	8b 55 08             	mov    0x8(%ebp),%edx
  800b38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b3e:	89 d7                	mov    %edx,%edi
  800b40:	fc                   	cld    
  800b41:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800b43:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b46:	5f                   	pop    %edi
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	57                   	push   %edi
  800b4d:	56                   	push   %esi
  800b4e:	53                   	push   %ebx
  800b4f:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b55:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800b58:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800b5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b61:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b64:	73 6d                	jae    800bd3 <memmove+0x8a>
  800b66:	8b 45 10             	mov    0x10(%ebp),%eax
  800b69:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b6c:	01 d0                	add    %edx,%eax
  800b6e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b71:	76 60                	jbe    800bd3 <memmove+0x8a>
		s += n;
  800b73:	8b 45 10             	mov    0x10(%ebp),%eax
  800b76:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800b79:	8b 45 10             	mov    0x10(%ebp),%eax
  800b7c:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b82:	83 e0 03             	and    $0x3,%eax
  800b85:	85 c0                	test   %eax,%eax
  800b87:	75 2f                	jne    800bb8 <memmove+0x6f>
  800b89:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b8c:	83 e0 03             	and    $0x3,%eax
  800b8f:	85 c0                	test   %eax,%eax
  800b91:	75 25                	jne    800bb8 <memmove+0x6f>
  800b93:	8b 45 10             	mov    0x10(%ebp),%eax
  800b96:	83 e0 03             	and    $0x3,%eax
  800b99:	85 c0                	test   %eax,%eax
  800b9b:	75 1b                	jne    800bb8 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ba0:	83 e8 04             	sub    $0x4,%eax
  800ba3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ba6:	83 ea 04             	sub    $0x4,%edx
  800ba9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bac:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800baf:	89 c7                	mov    %eax,%edi
  800bb1:	89 d6                	mov    %edx,%esi
  800bb3:	fd                   	std    
  800bb4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb6:	eb 18                	jmp    800bd0 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bbb:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bc1:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bc4:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc7:	89 d7                	mov    %edx,%edi
  800bc9:	89 de                	mov    %ebx,%esi
  800bcb:	89 c1                	mov    %eax,%ecx
  800bcd:	fd                   	std    
  800bce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bd0:	fc                   	cld    
  800bd1:	eb 45                	jmp    800c18 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bd6:	83 e0 03             	and    $0x3,%eax
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	75 2b                	jne    800c08 <memmove+0xbf>
  800bdd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800be0:	83 e0 03             	and    $0x3,%eax
  800be3:	85 c0                	test   %eax,%eax
  800be5:	75 21                	jne    800c08 <memmove+0xbf>
  800be7:	8b 45 10             	mov    0x10(%ebp),%eax
  800bea:	83 e0 03             	and    $0x3,%eax
  800bed:	85 c0                	test   %eax,%eax
  800bef:	75 17                	jne    800c08 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bf1:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf4:	c1 e8 02             	shr    $0x2,%eax
  800bf7:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bf9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bfc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bff:	89 c7                	mov    %eax,%edi
  800c01:	89 d6                	mov    %edx,%esi
  800c03:	fc                   	cld    
  800c04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c06:	eb 10                	jmp    800c18 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c08:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c0b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c11:	89 c7                	mov    %eax,%edi
  800c13:	89 d6                	mov    %edx,%esi
  800c15:	fc                   	cld    
  800c16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800c18:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c1b:	83 c4 10             	add    $0x10,%esp
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c29:	8b 45 10             	mov    0x10(%ebp),%eax
  800c2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c33:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c37:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3a:	89 04 24             	mov    %eax,(%esp)
  800c3d:	e8 07 ff ff ff       	call   800b49 <memmove>
}
  800c42:	c9                   	leave  
  800c43:	c3                   	ret    

00800c44 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800c4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800c50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c53:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800c56:	eb 30                	jmp    800c88 <memcmp+0x44>
		if (*s1 != *s2)
  800c58:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c5b:	0f b6 10             	movzbl (%eax),%edx
  800c5e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c61:	0f b6 00             	movzbl (%eax),%eax
  800c64:	38 c2                	cmp    %al,%dl
  800c66:	74 18                	je     800c80 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800c68:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c6b:	0f b6 00             	movzbl (%eax),%eax
  800c6e:	0f b6 d0             	movzbl %al,%edx
  800c71:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c74:	0f b6 00             	movzbl (%eax),%eax
  800c77:	0f b6 c0             	movzbl %al,%eax
  800c7a:	29 c2                	sub    %eax,%edx
  800c7c:	89 d0                	mov    %edx,%eax
  800c7e:	eb 1a                	jmp    800c9a <memcmp+0x56>
		s1++, s2++;
  800c80:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800c84:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c88:	8b 45 10             	mov    0x10(%ebp),%eax
  800c8b:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c8e:	89 55 10             	mov    %edx,0x10(%ebp)
  800c91:	85 c0                	test   %eax,%eax
  800c93:	75 c3                	jne    800c58 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c95:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c9a:	c9                   	leave  
  800c9b:	c3                   	ret    

00800c9c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800ca2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca8:	01 d0                	add    %edx,%eax
  800caa:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800cad:	eb 13                	jmp    800cc2 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800caf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb2:	0f b6 10             	movzbl (%eax),%edx
  800cb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cb8:	38 c2                	cmp    %al,%dl
  800cba:	75 02                	jne    800cbe <memfind+0x22>
			break;
  800cbc:	eb 0c                	jmp    800cca <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cbe:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800cc8:	72 e5                	jb     800caf <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800cca:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ccd:	c9                   	leave  
  800cce:	c3                   	ret    

00800ccf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800cd5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800cdc:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ce3:	eb 04                	jmp    800ce9 <strtol+0x1a>
		s++;
  800ce5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cec:	0f b6 00             	movzbl (%eax),%eax
  800cef:	3c 20                	cmp    $0x20,%al
  800cf1:	74 f2                	je     800ce5 <strtol+0x16>
  800cf3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf6:	0f b6 00             	movzbl (%eax),%eax
  800cf9:	3c 09                	cmp    $0x9,%al
  800cfb:	74 e8                	je     800ce5 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800d00:	0f b6 00             	movzbl (%eax),%eax
  800d03:	3c 2b                	cmp    $0x2b,%al
  800d05:	75 06                	jne    800d0d <strtol+0x3e>
		s++;
  800d07:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d0b:	eb 15                	jmp    800d22 <strtol+0x53>
	else if (*s == '-')
  800d0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d10:	0f b6 00             	movzbl (%eax),%eax
  800d13:	3c 2d                	cmp    $0x2d,%al
  800d15:	75 0b                	jne    800d22 <strtol+0x53>
		s++, neg = 1;
  800d17:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d1b:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d22:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d26:	74 06                	je     800d2e <strtol+0x5f>
  800d28:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800d2c:	75 24                	jne    800d52 <strtol+0x83>
  800d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d31:	0f b6 00             	movzbl (%eax),%eax
  800d34:	3c 30                	cmp    $0x30,%al
  800d36:	75 1a                	jne    800d52 <strtol+0x83>
  800d38:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3b:	83 c0 01             	add    $0x1,%eax
  800d3e:	0f b6 00             	movzbl (%eax),%eax
  800d41:	3c 78                	cmp    $0x78,%al
  800d43:	75 0d                	jne    800d52 <strtol+0x83>
		s += 2, base = 16;
  800d45:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800d49:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800d50:	eb 2a                	jmp    800d7c <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800d52:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d56:	75 17                	jne    800d6f <strtol+0xa0>
  800d58:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5b:	0f b6 00             	movzbl (%eax),%eax
  800d5e:	3c 30                	cmp    $0x30,%al
  800d60:	75 0d                	jne    800d6f <strtol+0xa0>
		s++, base = 8;
  800d62:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d66:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d6d:	eb 0d                	jmp    800d7c <strtol+0xad>
	else if (base == 0)
  800d6f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d73:	75 07                	jne    800d7c <strtol+0xad>
		base = 10;
  800d75:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7f:	0f b6 00             	movzbl (%eax),%eax
  800d82:	3c 2f                	cmp    $0x2f,%al
  800d84:	7e 1b                	jle    800da1 <strtol+0xd2>
  800d86:	8b 45 08             	mov    0x8(%ebp),%eax
  800d89:	0f b6 00             	movzbl (%eax),%eax
  800d8c:	3c 39                	cmp    $0x39,%al
  800d8e:	7f 11                	jg     800da1 <strtol+0xd2>
			dig = *s - '0';
  800d90:	8b 45 08             	mov    0x8(%ebp),%eax
  800d93:	0f b6 00             	movzbl (%eax),%eax
  800d96:	0f be c0             	movsbl %al,%eax
  800d99:	83 e8 30             	sub    $0x30,%eax
  800d9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d9f:	eb 48                	jmp    800de9 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800da1:	8b 45 08             	mov    0x8(%ebp),%eax
  800da4:	0f b6 00             	movzbl (%eax),%eax
  800da7:	3c 60                	cmp    $0x60,%al
  800da9:	7e 1b                	jle    800dc6 <strtol+0xf7>
  800dab:	8b 45 08             	mov    0x8(%ebp),%eax
  800dae:	0f b6 00             	movzbl (%eax),%eax
  800db1:	3c 7a                	cmp    $0x7a,%al
  800db3:	7f 11                	jg     800dc6 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800db5:	8b 45 08             	mov    0x8(%ebp),%eax
  800db8:	0f b6 00             	movzbl (%eax),%eax
  800dbb:	0f be c0             	movsbl %al,%eax
  800dbe:	83 e8 57             	sub    $0x57,%eax
  800dc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800dc4:	eb 23                	jmp    800de9 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc9:	0f b6 00             	movzbl (%eax),%eax
  800dcc:	3c 40                	cmp    $0x40,%al
  800dce:	7e 3d                	jle    800e0d <strtol+0x13e>
  800dd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd3:	0f b6 00             	movzbl (%eax),%eax
  800dd6:	3c 5a                	cmp    $0x5a,%al
  800dd8:	7f 33                	jg     800e0d <strtol+0x13e>
			dig = *s - 'A' + 10;
  800dda:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddd:	0f b6 00             	movzbl (%eax),%eax
  800de0:	0f be c0             	movsbl %al,%eax
  800de3:	83 e8 37             	sub    $0x37,%eax
  800de6:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dec:	3b 45 10             	cmp    0x10(%ebp),%eax
  800def:	7c 02                	jl     800df3 <strtol+0x124>
			break;
  800df1:	eb 1a                	jmp    800e0d <strtol+0x13e>
		s++, val = (val * base) + dig;
  800df3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800df7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800dfa:	0f af 45 10          	imul   0x10(%ebp),%eax
  800dfe:	89 c2                	mov    %eax,%edx
  800e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e03:	01 d0                	add    %edx,%eax
  800e05:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800e08:	e9 6f ff ff ff       	jmp    800d7c <strtol+0xad>

	if (endptr)
  800e0d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e11:	74 08                	je     800e1b <strtol+0x14c>
		*endptr = (char *) s;
  800e13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e16:	8b 55 08             	mov    0x8(%ebp),%edx
  800e19:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800e1b:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e1f:	74 07                	je     800e28 <strtol+0x159>
  800e21:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e24:	f7 d8                	neg    %eax
  800e26:	eb 03                	jmp    800e2b <strtol+0x15c>
  800e28:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800e2b:	c9                   	leave  
  800e2c:	c3                   	ret    

00800e2d <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	57                   	push   %edi
  800e31:	56                   	push   %esi
  800e32:	53                   	push   %ebx
  800e33:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e36:	8b 45 08             	mov    0x8(%ebp),%eax
  800e39:	8b 55 10             	mov    0x10(%ebp),%edx
  800e3c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800e3f:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800e42:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800e45:	8b 75 20             	mov    0x20(%ebp),%esi
  800e48:	cd 30                	int    $0x30
  800e4a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e4d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e51:	74 30                	je     800e83 <syscall+0x56>
  800e53:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e57:	7e 2a                	jle    800e83 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e5c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e60:	8b 45 08             	mov    0x8(%ebp),%eax
  800e63:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e67:	c7 44 24 08 24 19 80 	movl   $0x801924,0x8(%esp)
  800e6e:	00 
  800e6f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e76:	00 
  800e77:	c7 04 24 41 19 80 00 	movl   $0x801941,(%esp)
  800e7e:	e8 22 05 00 00       	call   8013a5 <_panic>

	return ret;
  800e83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800e86:	83 c4 3c             	add    $0x3c,%esp
  800e89:	5b                   	pop    %ebx
  800e8a:	5e                   	pop    %esi
  800e8b:	5f                   	pop    %edi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e94:	8b 45 08             	mov    0x8(%ebp),%eax
  800e97:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e9e:	00 
  800e9f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ea6:	00 
  800ea7:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800eae:	00 
  800eaf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800eb6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800eba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ec1:	00 
  800ec2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ec9:	e8 5f ff ff ff       	call   800e2d <syscall>
}
  800ece:	c9                   	leave  
  800ecf:	c3                   	ret    

00800ed0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ed6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800edd:	00 
  800ede:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ee5:	00 
  800ee6:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800eed:	00 
  800eee:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ef5:	00 
  800ef6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800efd:	00 
  800efe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f05:	00 
  800f06:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800f0d:	e8 1b ff ff ff       	call   800e2d <syscall>
}
  800f12:	c9                   	leave  
  800f13:	c3                   	ret    

00800f14 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800f1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f24:	00 
  800f25:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f2c:	00 
  800f2d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f34:	00 
  800f35:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f3c:	00 
  800f3d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f41:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f48:	00 
  800f49:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800f50:	e8 d8 fe ff ff       	call   800e2d <syscall>
}
  800f55:	c9                   	leave  
  800f56:	c3                   	ret    

00800f57 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800f5d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f64:	00 
  800f65:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f6c:	00 
  800f6d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f74:	00 
  800f75:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f7c:	00 
  800f7d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f84:	00 
  800f85:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f8c:	00 
  800f8d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f94:	e8 94 fe ff ff       	call   800e2d <syscall>
}
  800f99:	c9                   	leave  
  800f9a:	c3                   	ret    

00800f9b <sys_yield>:

void
sys_yield(void)
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800fa1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fa8:	00 
  800fa9:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fb0:	00 
  800fb1:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fb8:	00 
  800fb9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fc0:	00 
  800fc1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fc8:	00 
  800fc9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fd0:	00 
  800fd1:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800fd8:	e8 50 fe ff ff       	call   800e2d <syscall>
}
  800fdd:	c9                   	leave  
  800fde:	c3                   	ret    

00800fdf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800fe5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fe8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800feb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fee:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ff5:	00 
  800ff6:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ffd:	00 
  800ffe:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801002:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801006:	89 44 24 08          	mov    %eax,0x8(%esp)
  80100a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801011:	00 
  801012:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  801019:	e8 0f fe ff ff       	call   800e2d <syscall>
}
  80101e:	c9                   	leave  
  80101f:	c3                   	ret    

00801020 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	56                   	push   %esi
  801024:	53                   	push   %ebx
  801025:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  801028:	8b 75 18             	mov    0x18(%ebp),%esi
  80102b:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80102e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801031:	8b 55 0c             	mov    0xc(%ebp),%edx
  801034:	8b 45 08             	mov    0x8(%ebp),%eax
  801037:	89 74 24 18          	mov    %esi,0x18(%esp)
  80103b:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80103f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801043:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801047:	89 44 24 08          	mov    %eax,0x8(%esp)
  80104b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801052:	00 
  801053:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  80105a:	e8 ce fd ff ff       	call   800e2d <syscall>
}
  80105f:	83 c4 20             	add    $0x20,%esp
  801062:	5b                   	pop    %ebx
  801063:	5e                   	pop    %esi
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80106c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80106f:	8b 45 08             	mov    0x8(%ebp),%eax
  801072:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801079:	00 
  80107a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801081:	00 
  801082:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801089:	00 
  80108a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80108e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801092:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801099:	00 
  80109a:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  8010a1:	e8 87 fd ff ff       	call   800e2d <syscall>
}
  8010a6:	c9                   	leave  
  8010a7:	c3                   	ret    

008010a8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010a8:	55                   	push   %ebp
  8010a9:	89 e5                	mov    %esp,%ebp
  8010ab:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8010ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b4:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010bb:	00 
  8010bc:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010c3:	00 
  8010c4:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010cb:	00 
  8010cc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010d4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010db:	00 
  8010dc:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8010e3:	e8 45 fd ff ff       	call   800e2d <syscall>
}
  8010e8:	c9                   	leave  
  8010e9:	c3                   	ret    

008010ea <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8010f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010fd:	00 
  8010fe:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801105:	00 
  801106:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80110d:	00 
  80110e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801112:	89 44 24 08          	mov    %eax,0x8(%esp)
  801116:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80111d:	00 
  80111e:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  801125:	e8 03 fd ff ff       	call   800e2d <syscall>
}
  80112a:	c9                   	leave  
  80112b:	c3                   	ret    

0080112c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801132:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801135:	8b 55 10             	mov    0x10(%ebp),%edx
  801138:	8b 45 08             	mov    0x8(%ebp),%eax
  80113b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801142:	00 
  801143:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801147:	89 54 24 10          	mov    %edx,0x10(%esp)
  80114b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80114e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801152:	89 44 24 08          	mov    %eax,0x8(%esp)
  801156:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80115d:	00 
  80115e:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  801165:	e8 c3 fc ff ff       	call   800e2d <syscall>
}
  80116a:	c9                   	leave  
  80116b:	c3                   	ret    

0080116c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801172:	8b 45 08             	mov    0x8(%ebp),%eax
  801175:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80117c:	00 
  80117d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801184:	00 
  801185:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80118c:	00 
  80118d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801194:	00 
  801195:	89 44 24 08          	mov    %eax,0x8(%esp)
  801199:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011a0:	00 
  8011a1:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  8011a8:	e8 80 fc ff ff       	call   800e2d <syscall>
}
  8011ad:	c9                   	leave  
  8011ae:	c3                   	ret    

008011af <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int r;
	if(pg != NULL)
  8011b5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011b9:	74 10                	je     8011cb <ipc_recv+0x1c>
	{
		r = sys_ipc_recv(pg);
  8011bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011be:	89 04 24             	mov    %eax,(%esp)
  8011c1:	e8 a6 ff ff ff       	call   80116c <sys_ipc_recv>
  8011c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8011c9:	eb 0f                	jmp    8011da <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  8011cb:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8011d2:	e8 95 ff ff ff       	call   80116c <sys_ipc_recv>
  8011d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}

	if(from_env_store != NULL && r == 0) 
  8011da:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8011de:	74 13                	je     8011f3 <ipc_recv+0x44>
  8011e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8011e4:	75 0d                	jne    8011f3 <ipc_recv+0x44>
	{
		*from_env_store = thisenv->env_ipc_from;
  8011e6:	a1 04 20 80 00       	mov    0x802004,%eax
  8011eb:	8b 50 74             	mov    0x74(%eax),%edx
  8011ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f1:	89 10                	mov    %edx,(%eax)
	}
	if(from_env_store != NULL && r < 0)
  8011f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8011f7:	74 0f                	je     801208 <ipc_recv+0x59>
  8011f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8011fd:	79 09                	jns    801208 <ipc_recv+0x59>
	{
		*from_env_store = 0;
  8011ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801202:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}

	if(perm_store != NULL)
  801208:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80120c:	74 28                	je     801236 <ipc_recv+0x87>
	{
		if(r==0 && (uint32_t)pg<UTOP)
  80120e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801212:	75 19                	jne    80122d <ipc_recv+0x7e>
  801214:	8b 45 0c             	mov    0xc(%ebp),%eax
  801217:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
  80121c:	77 0f                	ja     80122d <ipc_recv+0x7e>
		{
			*perm_store = thisenv->env_ipc_perm;
  80121e:	a1 04 20 80 00       	mov    0x802004,%eax
  801223:	8b 50 78             	mov    0x78(%eax),%edx
  801226:	8b 45 10             	mov    0x10(%ebp),%eax
  801229:	89 10                	mov    %edx,(%eax)
  80122b:	eb 09                	jmp    801236 <ipc_recv+0x87>
		}
		else
		{
			*perm_store = 0;
  80122d:	8b 45 10             	mov    0x10(%ebp),%eax
  801230:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		}
	}
	if (r == 0)
  801236:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80123a:	75 0a                	jne    801246 <ipc_recv+0x97>
	{
    	return thisenv->env_ipc_value;
  80123c:	a1 04 20 80 00       	mov    0x802004,%eax
  801241:	8b 40 70             	mov    0x70(%eax),%eax
  801244:	eb 03                	jmp    801249 <ipc_recv+0x9a>
    } 
  	else
  	{
    	return r;
  801246:	8b 45 f4             	mov    -0xc(%ebp),%eax
    }
	// panic("ipc_recv not implemented");
	// return 0;
}
  801249:	c9                   	leave  
  80124a:	c3                   	ret    

0080124b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int r;
	if(pg == NULL)
  801251:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801255:	75 4c                	jne    8012a3 <ipc_send+0x58>
	{
		r = sys_ipc_try_send(to_env,val,(void *)UTOP, perm);
  801257:	8b 45 14             	mov    0x14(%ebp),%eax
  80125a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80125e:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801265:	ee 
  801266:	8b 45 0c             	mov    0xc(%ebp),%eax
  801269:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126d:	8b 45 08             	mov    0x8(%ebp),%eax
  801270:	89 04 24             	mov    %eax,(%esp)
  801273:	e8 b4 fe ff ff       	call   80112c <sys_ipc_try_send>
  801278:	89 45 f4             	mov    %eax,-0xc(%ebp)
    	if (r != 0 && r != -E_IPC_NOT_RECV)
  80127b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80127f:	74 6e                	je     8012ef <ipc_send+0xa4>
  801281:	83 7d f4 f8          	cmpl   $0xfffffff8,-0xc(%ebp)
  801285:	74 68                	je     8012ef <ipc_send+0xa4>
    	{
    		panic("in ipc_send\n");
  801287:	c7 44 24 08 4f 19 80 	movl   $0x80194f,0x8(%esp)
  80128e:	00 
  80128f:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  801296:	00 
  801297:	c7 04 24 5c 19 80 00 	movl   $0x80195c,(%esp)
  80129e:	e8 02 01 00 00       	call   8013a5 <_panic>
    	} 
	}
	else
	{
		r = sys_ipc_try_send(to_env,val,(void *)UTOP, perm);
  8012a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8012a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012aa:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8012b1:	ee 
  8012b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bc:	89 04 24             	mov    %eax,(%esp)
  8012bf:	e8 68 fe ff ff       	call   80112c <sys_ipc_try_send>
  8012c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    	if (r != 0 && r != -E_IPC_NOT_RECV)
  8012c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8012cb:	74 22                	je     8012ef <ipc_send+0xa4>
  8012cd:	83 7d f4 f8          	cmpl   $0xfffffff8,-0xc(%ebp)
  8012d1:	74 1c                	je     8012ef <ipc_send+0xa4>
    	{
    		panic("in ipc_send\n");
  8012d3:	c7 44 24 08 4f 19 80 	movl   $0x80194f,0x8(%esp)
  8012da:	00 
  8012db:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
  8012e2:	00 
  8012e3:	c7 04 24 5c 19 80 00 	movl   $0x80195c,(%esp)
  8012ea:	e8 b6 00 00 00       	call   8013a5 <_panic>
    	}	
	}
	while(r != 0)
  8012ef:	eb 58                	jmp    801349 <ipc_send+0xfe>
    //cprintf("[%x]ipc_send\n", thisenv->env_id);
	{
    	r = sys_ipc_try_send(to_env, val, pg ? pg : (void*)UTOP, perm);
  8012f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012f5:	74 05                	je     8012fc <ipc_send+0xb1>
  8012f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8012fa:	eb 05                	jmp    801301 <ipc_send+0xb6>
  8012fc:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801301:	8b 55 14             	mov    0x14(%ebp),%edx
  801304:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801308:	89 44 24 08          	mov    %eax,0x8(%esp)
  80130c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80130f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801313:	8b 45 08             	mov    0x8(%ebp),%eax
  801316:	89 04 24             	mov    %eax,(%esp)
  801319:	e8 0e fe ff ff       	call   80112c <sys_ipc_try_send>
  80131e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    	if (r != 0 && r != -E_IPC_NOT_RECV) 
  801321:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801325:	74 22                	je     801349 <ipc_send+0xfe>
  801327:	83 7d f4 f8          	cmpl   $0xfffffff8,-0xc(%ebp)
  80132b:	74 1c                	je     801349 <ipc_send+0xfe>
    	{
      		panic("in ipc_send\n");
  80132d:	c7 44 24 08 4f 19 80 	movl   $0x80194f,0x8(%esp)
  801334:	00 
  801335:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  80133c:	00 
  80133d:	c7 04 24 5c 19 80 00 	movl   $0x80195c,(%esp)
  801344:	e8 5c 00 00 00       	call   8013a5 <_panic>
    	if (r != 0 && r != -E_IPC_NOT_RECV)
    	{
    		panic("in ipc_send\n");
    	}	
	}
	while(r != 0)
  801349:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80134d:	75 a2                	jne    8012f1 <ipc_send+0xa6>
    	{
      		panic("in ipc_send\n");
    	}
    } 
	// panic("ipc_send not implemented");
}
  80134f:	c9                   	leave  
  801350:	c3                   	ret    

00801351 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801351:	55                   	push   %ebp
  801352:	89 e5                	mov    %esp,%ebp
  801354:	83 ec 10             	sub    $0x10,%esp
	int i;
	for (i = 0; i < NENV; i++)
  801357:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80135e:	eb 35                	jmp    801395 <ipc_find_env+0x44>
		if (envs[i].env_type == type)
  801360:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801363:	c1 e0 02             	shl    $0x2,%eax
  801366:	89 c2                	mov    %eax,%edx
  801368:	c1 e2 05             	shl    $0x5,%edx
  80136b:	29 c2                	sub    %eax,%edx
  80136d:	8d 82 50 00 c0 ee    	lea    -0x113fffb0(%edx),%eax
  801373:	8b 00                	mov    (%eax),%eax
  801375:	3b 45 08             	cmp    0x8(%ebp),%eax
  801378:	75 17                	jne    801391 <ipc_find_env+0x40>
			return envs[i].env_id;
  80137a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80137d:	c1 e0 02             	shl    $0x2,%eax
  801380:	89 c2                	mov    %eax,%edx
  801382:	c1 e2 05             	shl    $0x5,%edx
  801385:	29 c2                	sub    %eax,%edx
  801387:	8d 82 48 00 c0 ee    	lea    -0x113fffb8(%edx),%eax
  80138d:	8b 00                	mov    (%eax),%eax
  80138f:	eb 12                	jmp    8013a3 <ipc_find_env+0x52>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801391:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  801395:	81 7d fc ff 03 00 00 	cmpl   $0x3ff,-0x4(%ebp)
  80139c:	7e c2                	jle    801360 <ipc_find_env+0xf>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80139e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013a3:	c9                   	leave  
  8013a4:	c3                   	ret    

008013a5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	53                   	push   %ebx
  8013a9:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8013ac:	8d 45 14             	lea    0x14(%ebp),%eax
  8013af:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013b2:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8013b8:	e8 9a fb ff ff       	call   800f57 <sys_getenvid>
  8013bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8013c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8013cb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d3:	c7 04 24 68 19 80 00 	movl   $0x801968,(%esp)
  8013da:	e8 0a ee ff ff       	call   8001e9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8013e9:	89 04 24             	mov    %eax,(%esp)
  8013ec:	e8 94 ed ff ff       	call   800185 <vcprintf>
	cprintf("\n");
  8013f1:	c7 04 24 8b 19 80 00 	movl   $0x80198b,(%esp)
  8013f8:	e8 ec ed ff ff       	call   8001e9 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013fd:	cc                   	int3   
  8013fe:	eb fd                	jmp    8013fd <_panic+0x58>

00801400 <__udivdi3>:
  801400:	55                   	push   %ebp
  801401:	57                   	push   %edi
  801402:	56                   	push   %esi
  801403:	83 ec 0c             	sub    $0xc,%esp
  801406:	8b 44 24 28          	mov    0x28(%esp),%eax
  80140a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80140e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801412:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801416:	85 c0                	test   %eax,%eax
  801418:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80141c:	89 ea                	mov    %ebp,%edx
  80141e:	89 0c 24             	mov    %ecx,(%esp)
  801421:	75 2d                	jne    801450 <__udivdi3+0x50>
  801423:	39 e9                	cmp    %ebp,%ecx
  801425:	77 61                	ja     801488 <__udivdi3+0x88>
  801427:	85 c9                	test   %ecx,%ecx
  801429:	89 ce                	mov    %ecx,%esi
  80142b:	75 0b                	jne    801438 <__udivdi3+0x38>
  80142d:	b8 01 00 00 00       	mov    $0x1,%eax
  801432:	31 d2                	xor    %edx,%edx
  801434:	f7 f1                	div    %ecx
  801436:	89 c6                	mov    %eax,%esi
  801438:	31 d2                	xor    %edx,%edx
  80143a:	89 e8                	mov    %ebp,%eax
  80143c:	f7 f6                	div    %esi
  80143e:	89 c5                	mov    %eax,%ebp
  801440:	89 f8                	mov    %edi,%eax
  801442:	f7 f6                	div    %esi
  801444:	89 ea                	mov    %ebp,%edx
  801446:	83 c4 0c             	add    $0xc,%esp
  801449:	5e                   	pop    %esi
  80144a:	5f                   	pop    %edi
  80144b:	5d                   	pop    %ebp
  80144c:	c3                   	ret    
  80144d:	8d 76 00             	lea    0x0(%esi),%esi
  801450:	39 e8                	cmp    %ebp,%eax
  801452:	77 24                	ja     801478 <__udivdi3+0x78>
  801454:	0f bd e8             	bsr    %eax,%ebp
  801457:	83 f5 1f             	xor    $0x1f,%ebp
  80145a:	75 3c                	jne    801498 <__udivdi3+0x98>
  80145c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801460:	39 34 24             	cmp    %esi,(%esp)
  801463:	0f 86 9f 00 00 00    	jbe    801508 <__udivdi3+0x108>
  801469:	39 d0                	cmp    %edx,%eax
  80146b:	0f 82 97 00 00 00    	jb     801508 <__udivdi3+0x108>
  801471:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801478:	31 d2                	xor    %edx,%edx
  80147a:	31 c0                	xor    %eax,%eax
  80147c:	83 c4 0c             	add    $0xc,%esp
  80147f:	5e                   	pop    %esi
  801480:	5f                   	pop    %edi
  801481:	5d                   	pop    %ebp
  801482:	c3                   	ret    
  801483:	90                   	nop
  801484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801488:	89 f8                	mov    %edi,%eax
  80148a:	f7 f1                	div    %ecx
  80148c:	31 d2                	xor    %edx,%edx
  80148e:	83 c4 0c             	add    $0xc,%esp
  801491:	5e                   	pop    %esi
  801492:	5f                   	pop    %edi
  801493:	5d                   	pop    %ebp
  801494:	c3                   	ret    
  801495:	8d 76 00             	lea    0x0(%esi),%esi
  801498:	89 e9                	mov    %ebp,%ecx
  80149a:	8b 3c 24             	mov    (%esp),%edi
  80149d:	d3 e0                	shl    %cl,%eax
  80149f:	89 c6                	mov    %eax,%esi
  8014a1:	b8 20 00 00 00       	mov    $0x20,%eax
  8014a6:	29 e8                	sub    %ebp,%eax
  8014a8:	89 c1                	mov    %eax,%ecx
  8014aa:	d3 ef                	shr    %cl,%edi
  8014ac:	89 e9                	mov    %ebp,%ecx
  8014ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8014b2:	8b 3c 24             	mov    (%esp),%edi
  8014b5:	09 74 24 08          	or     %esi,0x8(%esp)
  8014b9:	89 d6                	mov    %edx,%esi
  8014bb:	d3 e7                	shl    %cl,%edi
  8014bd:	89 c1                	mov    %eax,%ecx
  8014bf:	89 3c 24             	mov    %edi,(%esp)
  8014c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014c6:	d3 ee                	shr    %cl,%esi
  8014c8:	89 e9                	mov    %ebp,%ecx
  8014ca:	d3 e2                	shl    %cl,%edx
  8014cc:	89 c1                	mov    %eax,%ecx
  8014ce:	d3 ef                	shr    %cl,%edi
  8014d0:	09 d7                	or     %edx,%edi
  8014d2:	89 f2                	mov    %esi,%edx
  8014d4:	89 f8                	mov    %edi,%eax
  8014d6:	f7 74 24 08          	divl   0x8(%esp)
  8014da:	89 d6                	mov    %edx,%esi
  8014dc:	89 c7                	mov    %eax,%edi
  8014de:	f7 24 24             	mull   (%esp)
  8014e1:	39 d6                	cmp    %edx,%esi
  8014e3:	89 14 24             	mov    %edx,(%esp)
  8014e6:	72 30                	jb     801518 <__udivdi3+0x118>
  8014e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8014ec:	89 e9                	mov    %ebp,%ecx
  8014ee:	d3 e2                	shl    %cl,%edx
  8014f0:	39 c2                	cmp    %eax,%edx
  8014f2:	73 05                	jae    8014f9 <__udivdi3+0xf9>
  8014f4:	3b 34 24             	cmp    (%esp),%esi
  8014f7:	74 1f                	je     801518 <__udivdi3+0x118>
  8014f9:	89 f8                	mov    %edi,%eax
  8014fb:	31 d2                	xor    %edx,%edx
  8014fd:	e9 7a ff ff ff       	jmp    80147c <__udivdi3+0x7c>
  801502:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801508:	31 d2                	xor    %edx,%edx
  80150a:	b8 01 00 00 00       	mov    $0x1,%eax
  80150f:	e9 68 ff ff ff       	jmp    80147c <__udivdi3+0x7c>
  801514:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801518:	8d 47 ff             	lea    -0x1(%edi),%eax
  80151b:	31 d2                	xor    %edx,%edx
  80151d:	83 c4 0c             	add    $0xc,%esp
  801520:	5e                   	pop    %esi
  801521:	5f                   	pop    %edi
  801522:	5d                   	pop    %ebp
  801523:	c3                   	ret    
  801524:	66 90                	xchg   %ax,%ax
  801526:	66 90                	xchg   %ax,%ax
  801528:	66 90                	xchg   %ax,%ax
  80152a:	66 90                	xchg   %ax,%ax
  80152c:	66 90                	xchg   %ax,%ax
  80152e:	66 90                	xchg   %ax,%ax

00801530 <__umoddi3>:
  801530:	55                   	push   %ebp
  801531:	57                   	push   %edi
  801532:	56                   	push   %esi
  801533:	83 ec 14             	sub    $0x14,%esp
  801536:	8b 44 24 28          	mov    0x28(%esp),%eax
  80153a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80153e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801542:	89 c7                	mov    %eax,%edi
  801544:	89 44 24 04          	mov    %eax,0x4(%esp)
  801548:	8b 44 24 30          	mov    0x30(%esp),%eax
  80154c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801550:	89 34 24             	mov    %esi,(%esp)
  801553:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801557:	85 c0                	test   %eax,%eax
  801559:	89 c2                	mov    %eax,%edx
  80155b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80155f:	75 17                	jne    801578 <__umoddi3+0x48>
  801561:	39 fe                	cmp    %edi,%esi
  801563:	76 4b                	jbe    8015b0 <__umoddi3+0x80>
  801565:	89 c8                	mov    %ecx,%eax
  801567:	89 fa                	mov    %edi,%edx
  801569:	f7 f6                	div    %esi
  80156b:	89 d0                	mov    %edx,%eax
  80156d:	31 d2                	xor    %edx,%edx
  80156f:	83 c4 14             	add    $0x14,%esp
  801572:	5e                   	pop    %esi
  801573:	5f                   	pop    %edi
  801574:	5d                   	pop    %ebp
  801575:	c3                   	ret    
  801576:	66 90                	xchg   %ax,%ax
  801578:	39 f8                	cmp    %edi,%eax
  80157a:	77 54                	ja     8015d0 <__umoddi3+0xa0>
  80157c:	0f bd e8             	bsr    %eax,%ebp
  80157f:	83 f5 1f             	xor    $0x1f,%ebp
  801582:	75 5c                	jne    8015e0 <__umoddi3+0xb0>
  801584:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801588:	39 3c 24             	cmp    %edi,(%esp)
  80158b:	0f 87 e7 00 00 00    	ja     801678 <__umoddi3+0x148>
  801591:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801595:	29 f1                	sub    %esi,%ecx
  801597:	19 c7                	sbb    %eax,%edi
  801599:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80159d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015a1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8015a5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8015a9:	83 c4 14             	add    $0x14,%esp
  8015ac:	5e                   	pop    %esi
  8015ad:	5f                   	pop    %edi
  8015ae:	5d                   	pop    %ebp
  8015af:	c3                   	ret    
  8015b0:	85 f6                	test   %esi,%esi
  8015b2:	89 f5                	mov    %esi,%ebp
  8015b4:	75 0b                	jne    8015c1 <__umoddi3+0x91>
  8015b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8015bb:	31 d2                	xor    %edx,%edx
  8015bd:	f7 f6                	div    %esi
  8015bf:	89 c5                	mov    %eax,%ebp
  8015c1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8015c5:	31 d2                	xor    %edx,%edx
  8015c7:	f7 f5                	div    %ebp
  8015c9:	89 c8                	mov    %ecx,%eax
  8015cb:	f7 f5                	div    %ebp
  8015cd:	eb 9c                	jmp    80156b <__umoddi3+0x3b>
  8015cf:	90                   	nop
  8015d0:	89 c8                	mov    %ecx,%eax
  8015d2:	89 fa                	mov    %edi,%edx
  8015d4:	83 c4 14             	add    $0x14,%esp
  8015d7:	5e                   	pop    %esi
  8015d8:	5f                   	pop    %edi
  8015d9:	5d                   	pop    %ebp
  8015da:	c3                   	ret    
  8015db:	90                   	nop
  8015dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015e0:	8b 04 24             	mov    (%esp),%eax
  8015e3:	be 20 00 00 00       	mov    $0x20,%esi
  8015e8:	89 e9                	mov    %ebp,%ecx
  8015ea:	29 ee                	sub    %ebp,%esi
  8015ec:	d3 e2                	shl    %cl,%edx
  8015ee:	89 f1                	mov    %esi,%ecx
  8015f0:	d3 e8                	shr    %cl,%eax
  8015f2:	89 e9                	mov    %ebp,%ecx
  8015f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f8:	8b 04 24             	mov    (%esp),%eax
  8015fb:	09 54 24 04          	or     %edx,0x4(%esp)
  8015ff:	89 fa                	mov    %edi,%edx
  801601:	d3 e0                	shl    %cl,%eax
  801603:	89 f1                	mov    %esi,%ecx
  801605:	89 44 24 08          	mov    %eax,0x8(%esp)
  801609:	8b 44 24 10          	mov    0x10(%esp),%eax
  80160d:	d3 ea                	shr    %cl,%edx
  80160f:	89 e9                	mov    %ebp,%ecx
  801611:	d3 e7                	shl    %cl,%edi
  801613:	89 f1                	mov    %esi,%ecx
  801615:	d3 e8                	shr    %cl,%eax
  801617:	89 e9                	mov    %ebp,%ecx
  801619:	09 f8                	or     %edi,%eax
  80161b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80161f:	f7 74 24 04          	divl   0x4(%esp)
  801623:	d3 e7                	shl    %cl,%edi
  801625:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801629:	89 d7                	mov    %edx,%edi
  80162b:	f7 64 24 08          	mull   0x8(%esp)
  80162f:	39 d7                	cmp    %edx,%edi
  801631:	89 c1                	mov    %eax,%ecx
  801633:	89 14 24             	mov    %edx,(%esp)
  801636:	72 2c                	jb     801664 <__umoddi3+0x134>
  801638:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80163c:	72 22                	jb     801660 <__umoddi3+0x130>
  80163e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801642:	29 c8                	sub    %ecx,%eax
  801644:	19 d7                	sbb    %edx,%edi
  801646:	89 e9                	mov    %ebp,%ecx
  801648:	89 fa                	mov    %edi,%edx
  80164a:	d3 e8                	shr    %cl,%eax
  80164c:	89 f1                	mov    %esi,%ecx
  80164e:	d3 e2                	shl    %cl,%edx
  801650:	89 e9                	mov    %ebp,%ecx
  801652:	d3 ef                	shr    %cl,%edi
  801654:	09 d0                	or     %edx,%eax
  801656:	89 fa                	mov    %edi,%edx
  801658:	83 c4 14             	add    $0x14,%esp
  80165b:	5e                   	pop    %esi
  80165c:	5f                   	pop    %edi
  80165d:	5d                   	pop    %ebp
  80165e:	c3                   	ret    
  80165f:	90                   	nop
  801660:	39 d7                	cmp    %edx,%edi
  801662:	75 da                	jne    80163e <__umoddi3+0x10e>
  801664:	8b 14 24             	mov    (%esp),%edx
  801667:	89 c1                	mov    %eax,%ecx
  801669:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80166d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801671:	eb cb                	jmp    80163e <__umoddi3+0x10e>
  801673:	90                   	nop
  801674:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801678:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80167c:	0f 82 0f ff ff ff    	jb     801591 <__umoddi3+0x61>
  801682:	e9 1a ff ff ff       	jmp    8015a1 <__umoddi3+0x71>
