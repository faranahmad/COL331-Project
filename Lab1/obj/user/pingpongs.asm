
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 31 01 00 00       	call   800162 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 3c             	sub    $0x3c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
  80003c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if ((who = sfork()) != 0) {
  800043:	e8 33 16 00 00       	call   80167b <sfork>
  800048:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80004b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80004e:	85 c0                	test   %eax,%eax
  800050:	74 5e                	je     8000b0 <umain+0x7d>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800052:	8b 1d 08 30 80 00    	mov    0x803008,%ebx
  800058:	e8 95 0f 00 00       	call   800ff2 <sys_getenvid>
  80005d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800061:	89 44 24 04          	mov    %eax,0x4(%esp)
  800065:	c7 04 24 20 1c 80 00 	movl   $0x801c20,(%esp)
  80006c:	e8 13 02 00 00       	call   800284 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800071:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800074:	e8 79 0f 00 00       	call   800ff2 <sys_getenvid>
  800079:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80007d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800081:	c7 04 24 3a 1c 80 00 	movl   $0x801c3a,(%esp)
  800088:	e8 f7 01 00 00       	call   800284 <cprintf>
		ipc_send(who, 0, 0, 0);
  80008d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800090:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800097:	00 
  800098:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80009f:	00 
  8000a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000a7:	00 
  8000a8:	89 04 24             	mov    %eax,(%esp)
  8000ab:	e8 89 16 00 00       	call   801739 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b7:	00 
  8000b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000bf:	00 
  8000c0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8000c3:	89 04 24             	mov    %eax,(%esp)
  8000c6:	e8 d2 15 00 00       	call   80169d <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000cb:	a1 08 30 80 00       	mov    0x803008,%eax
  8000d0:	8b 40 48             	mov    0x48(%eax),%eax
  8000d3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000d6:	8b 3d 08 30 80 00    	mov    0x803008,%edi
  8000dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8000df:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  8000e5:	e8 08 0f 00 00       	call   800ff2 <sys_getenvid>
  8000ea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000ed:	89 54 24 14          	mov    %edx,0x14(%esp)
  8000f1:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8000f5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800101:	c7 04 24 50 1c 80 00 	movl   $0x801c50,(%esp)
  800108:	e8 77 01 00 00       	call   800284 <cprintf>
		if (val == 10)
  80010d:	a1 04 30 80 00       	mov    0x803004,%eax
  800112:	83 f8 0a             	cmp    $0xa,%eax
  800115:	75 02                	jne    800119 <umain+0xe6>
			return;
  800117:	eb 41                	jmp    80015a <umain+0x127>
		++val;
  800119:	a1 04 30 80 00       	mov    0x803004,%eax
  80011e:	83 c0 01             	add    $0x1,%eax
  800121:	a3 04 30 80 00       	mov    %eax,0x803004
		ipc_send(who, 0, 0, 0);
  800126:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800129:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800130:	00 
  800131:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800138:	00 
  800139:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800140:	00 
  800141:	89 04 24             	mov    %eax,(%esp)
  800144:	e8 f0 15 00 00       	call   801739 <ipc_send>
		if (val == 10)
  800149:	a1 04 30 80 00       	mov    0x803004,%eax
  80014e:	83 f8 0a             	cmp    $0xa,%eax
  800151:	75 02                	jne    800155 <umain+0x122>
			return;
  800153:	eb 05                	jmp    80015a <umain+0x127>
	}
  800155:	e9 56 ff ff ff       	jmp    8000b0 <umain+0x7d>

}
  80015a:	83 c4 3c             	add    $0x3c,%esp
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800168:	e8 85 0e 00 00       	call   800ff2 <sys_getenvid>
  80016d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800172:	c1 e0 02             	shl    $0x2,%eax
  800175:	89 c2                	mov    %eax,%edx
  800177:	c1 e2 05             	shl    $0x5,%edx
  80017a:	29 c2                	sub    %eax,%edx
  80017c:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  800182:	a3 08 30 80 00       	mov    %eax,0x803008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800187:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80018b:	7e 0a                	jle    800197 <libmain+0x35>
		binaryname = argv[0];
  80018d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800190:	8b 00                	mov    (%eax),%eax
  800192:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800197:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 04 24             	mov    %eax,(%esp)
  8001a4:	e8 8a fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001a9:	e8 02 00 00 00       	call   8001b0 <exit>
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001bd:	e8 ed 0d 00 00       	call   800faf <sys_env_destroy>
}
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8001ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001cd:	8b 00                	mov    (%eax),%eax
  8001cf:	8d 48 01             	lea    0x1(%eax),%ecx
  8001d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d5:	89 0a                	mov    %ecx,(%edx)
  8001d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001da:	89 d1                	mov    %edx,%ecx
  8001dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001df:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8001e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e6:	8b 00                	mov    (%eax),%eax
  8001e8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ed:	75 20                	jne    80020f <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8001ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f2:	8b 00                	mov    (%eax),%eax
  8001f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f7:	83 c2 08             	add    $0x8,%edx
  8001fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fe:	89 14 24             	mov    %edx,(%esp)
  800201:	e8 23 0d 00 00       	call   800f29 <sys_cputs>
		b->idx = 0;
  800206:	8b 45 0c             	mov    0xc(%ebp),%eax
  800209:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80020f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800212:	8b 40 04             	mov    0x4(%eax),%eax
  800215:	8d 50 01             	lea    0x1(%eax),%edx
  800218:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021b:	89 50 04             	mov    %edx,0x4(%eax)
}
  80021e:	c9                   	leave  
  80021f:	c3                   	ret    

00800220 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800229:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800230:	00 00 00 
	b.cnt = 0;
  800233:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80023a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80023d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800240:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800244:	8b 45 08             	mov    0x8(%ebp),%eax
  800247:	89 44 24 08          	mov    %eax,0x8(%esp)
  80024b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800251:	89 44 24 04          	mov    %eax,0x4(%esp)
  800255:	c7 04 24 c4 01 80 00 	movl   $0x8001c4,(%esp)
  80025c:	e8 bd 01 00 00       	call   80041e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800261:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800267:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800271:	83 c0 08             	add    $0x8,%eax
  800274:	89 04 24             	mov    %eax,(%esp)
  800277:	e8 ad 0c 00 00       	call   800f29 <sys_cputs>

	return b.cnt;
  80027c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028a:	8d 45 0c             	lea    0xc(%ebp),%eax
  80028d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800290:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800293:	89 44 24 04          	mov    %eax,0x4(%esp)
  800297:	8b 45 08             	mov    0x8(%ebp),%eax
  80029a:	89 04 24             	mov    %eax,(%esp)
  80029d:	e8 7e ff ff ff       	call   800220 <vcprintf>
  8002a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8002a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8002a8:	c9                   	leave  
  8002a9:	c3                   	ret    

008002aa <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	53                   	push   %ebx
  8002ae:	83 ec 34             	sub    $0x34,%esp
  8002b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8002b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002bd:	8b 45 18             	mov    0x18(%ebp),%eax
  8002c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c5:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002c8:	77 72                	ja     80033c <printnum+0x92>
  8002ca:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002cd:	72 05                	jb     8002d4 <printnum+0x2a>
  8002cf:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8002d2:	77 68                	ja     80033c <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d4:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8002d7:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002da:	8b 45 18             	mov    0x18(%ebp),%eax
  8002dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8002f0:	89 04 24             	mov    %eax,(%esp)
  8002f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f7:	e8 94 16 00 00       	call   801990 <__udivdi3>
  8002fc:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8002ff:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800303:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800307:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80030a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80030e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800312:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800316:	8b 45 0c             	mov    0xc(%ebp),%eax
  800319:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031d:	8b 45 08             	mov    0x8(%ebp),%eax
  800320:	89 04 24             	mov    %eax,(%esp)
  800323:	e8 82 ff ff ff       	call   8002aa <printnum>
  800328:	eb 1c                	jmp    800346 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800331:	8b 45 20             	mov    0x20(%ebp),%eax
  800334:	89 04 24             	mov    %eax,(%esp)
  800337:	8b 45 08             	mov    0x8(%ebp),%eax
  80033a:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033c:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800340:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800344:	7f e4                	jg     80032a <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800346:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800349:	bb 00 00 00 00       	mov    $0x0,%ebx
  80034e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800351:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800354:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800358:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80035c:	89 04 24             	mov    %eax,(%esp)
  80035f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800363:	e8 58 17 00 00       	call   801ac0 <__umoddi3>
  800368:	05 48 1d 80 00       	add    $0x801d48,%eax
  80036d:	0f b6 00             	movzbl (%eax),%eax
  800370:	0f be c0             	movsbl %al,%eax
  800373:	8b 55 0c             	mov    0xc(%ebp),%edx
  800376:	89 54 24 04          	mov    %edx,0x4(%esp)
  80037a:	89 04 24             	mov    %eax,(%esp)
  80037d:	8b 45 08             	mov    0x8(%ebp),%eax
  800380:	ff d0                	call   *%eax
}
  800382:	83 c4 34             	add    $0x34,%esp
  800385:	5b                   	pop    %ebx
  800386:	5d                   	pop    %ebp
  800387:	c3                   	ret    

00800388 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80038b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80038f:	7e 14                	jle    8003a5 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800391:	8b 45 08             	mov    0x8(%ebp),%eax
  800394:	8b 00                	mov    (%eax),%eax
  800396:	8d 48 08             	lea    0x8(%eax),%ecx
  800399:	8b 55 08             	mov    0x8(%ebp),%edx
  80039c:	89 0a                	mov    %ecx,(%edx)
  80039e:	8b 50 04             	mov    0x4(%eax),%edx
  8003a1:	8b 00                	mov    (%eax),%eax
  8003a3:	eb 30                	jmp    8003d5 <getuint+0x4d>
	else if (lflag)
  8003a5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003a9:	74 16                	je     8003c1 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8003ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ae:	8b 00                	mov    (%eax),%eax
  8003b0:	8d 48 04             	lea    0x4(%eax),%ecx
  8003b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b6:	89 0a                	mov    %ecx,(%edx)
  8003b8:	8b 00                	mov    (%eax),%eax
  8003ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8003bf:	eb 14                	jmp    8003d5 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8003c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c4:	8b 00                	mov    (%eax),%eax
  8003c6:	8d 48 04             	lea    0x4(%eax),%ecx
  8003c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003cc:	89 0a                	mov    %ecx,(%edx)
  8003ce:	8b 00                	mov    (%eax),%eax
  8003d0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003d5:	5d                   	pop    %ebp
  8003d6:	c3                   	ret    

008003d7 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003da:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003de:	7e 14                	jle    8003f4 <getint+0x1d>
		return va_arg(*ap, long long);
  8003e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e3:	8b 00                	mov    (%eax),%eax
  8003e5:	8d 48 08             	lea    0x8(%eax),%ecx
  8003e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003eb:	89 0a                	mov    %ecx,(%edx)
  8003ed:	8b 50 04             	mov    0x4(%eax),%edx
  8003f0:	8b 00                	mov    (%eax),%eax
  8003f2:	eb 28                	jmp    80041c <getint+0x45>
	else if (lflag)
  8003f4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003f8:	74 12                	je     80040c <getint+0x35>
		return va_arg(*ap, long);
  8003fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fd:	8b 00                	mov    (%eax),%eax
  8003ff:	8d 48 04             	lea    0x4(%eax),%ecx
  800402:	8b 55 08             	mov    0x8(%ebp),%edx
  800405:	89 0a                	mov    %ecx,(%edx)
  800407:	8b 00                	mov    (%eax),%eax
  800409:	99                   	cltd   
  80040a:	eb 10                	jmp    80041c <getint+0x45>
	else
		return va_arg(*ap, int);
  80040c:	8b 45 08             	mov    0x8(%ebp),%eax
  80040f:	8b 00                	mov    (%eax),%eax
  800411:	8d 48 04             	lea    0x4(%eax),%ecx
  800414:	8b 55 08             	mov    0x8(%ebp),%edx
  800417:	89 0a                	mov    %ecx,(%edx)
  800419:	8b 00                	mov    (%eax),%eax
  80041b:	99                   	cltd   
}
  80041c:	5d                   	pop    %ebp
  80041d:	c3                   	ret    

0080041e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80041e:	55                   	push   %ebp
  80041f:	89 e5                	mov    %esp,%ebp
  800421:	56                   	push   %esi
  800422:	53                   	push   %ebx
  800423:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800426:	eb 18                	jmp    800440 <vprintfmt+0x22>
			if (ch == '\0')
  800428:	85 db                	test   %ebx,%ebx
  80042a:	75 05                	jne    800431 <vprintfmt+0x13>
				return;
  80042c:	e9 05 04 00 00       	jmp    800836 <vprintfmt+0x418>
			putch(ch, putdat);
  800431:	8b 45 0c             	mov    0xc(%ebp),%eax
  800434:	89 44 24 04          	mov    %eax,0x4(%esp)
  800438:	89 1c 24             	mov    %ebx,(%esp)
  80043b:	8b 45 08             	mov    0x8(%ebp),%eax
  80043e:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800440:	8b 45 10             	mov    0x10(%ebp),%eax
  800443:	8d 50 01             	lea    0x1(%eax),%edx
  800446:	89 55 10             	mov    %edx,0x10(%ebp)
  800449:	0f b6 00             	movzbl (%eax),%eax
  80044c:	0f b6 d8             	movzbl %al,%ebx
  80044f:	83 fb 25             	cmp    $0x25,%ebx
  800452:	75 d4                	jne    800428 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800454:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800458:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80045f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800466:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80046d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800474:	8b 45 10             	mov    0x10(%ebp),%eax
  800477:	8d 50 01             	lea    0x1(%eax),%edx
  80047a:	89 55 10             	mov    %edx,0x10(%ebp)
  80047d:	0f b6 00             	movzbl (%eax),%eax
  800480:	0f b6 d8             	movzbl %al,%ebx
  800483:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800486:	83 f8 55             	cmp    $0x55,%eax
  800489:	0f 87 76 03 00 00    	ja     800805 <vprintfmt+0x3e7>
  80048f:	8b 04 85 6c 1d 80 00 	mov    0x801d6c(,%eax,4),%eax
  800496:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800498:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80049c:	eb d6                	jmp    800474 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80049e:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8004a2:	eb d0                	jmp    800474 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004a4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8004ab:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004ae:	89 d0                	mov    %edx,%eax
  8004b0:	c1 e0 02             	shl    $0x2,%eax
  8004b3:	01 d0                	add    %edx,%eax
  8004b5:	01 c0                	add    %eax,%eax
  8004b7:	01 d8                	add    %ebx,%eax
  8004b9:	83 e8 30             	sub    $0x30,%eax
  8004bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8004bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8004c2:	0f b6 00             	movzbl (%eax),%eax
  8004c5:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8004c8:	83 fb 2f             	cmp    $0x2f,%ebx
  8004cb:	7e 0b                	jle    8004d8 <vprintfmt+0xba>
  8004cd:	83 fb 39             	cmp    $0x39,%ebx
  8004d0:	7f 06                	jg     8004d8 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d2:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004d6:	eb d3                	jmp    8004ab <vprintfmt+0x8d>
			goto process_precision;
  8004d8:	eb 33                	jmp    80050d <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8004da:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dd:	8d 50 04             	lea    0x4(%eax),%edx
  8004e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e3:	8b 00                	mov    (%eax),%eax
  8004e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8004e8:	eb 23                	jmp    80050d <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8004ea:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ee:	79 0c                	jns    8004fc <vprintfmt+0xde>
				width = 0;
  8004f0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8004f7:	e9 78 ff ff ff       	jmp    800474 <vprintfmt+0x56>
  8004fc:	e9 73 ff ff ff       	jmp    800474 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800501:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800508:	e9 67 ff ff ff       	jmp    800474 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80050d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800511:	79 12                	jns    800525 <vprintfmt+0x107>
				width = precision, precision = -1;
  800513:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800516:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800519:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800520:	e9 4f ff ff ff       	jmp    800474 <vprintfmt+0x56>
  800525:	e9 4a ff ff ff       	jmp    800474 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80052a:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80052e:	e9 41 ff ff ff       	jmp    800474 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 50 04             	lea    0x4(%eax),%edx
  800539:	89 55 14             	mov    %edx,0x14(%ebp)
  80053c:	8b 00                	mov    (%eax),%eax
  80053e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800541:	89 54 24 04          	mov    %edx,0x4(%esp)
  800545:	89 04 24             	mov    %eax,(%esp)
  800548:	8b 45 08             	mov    0x8(%ebp),%eax
  80054b:	ff d0                	call   *%eax
			break;
  80054d:	e9 de 02 00 00       	jmp    800830 <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8d 50 04             	lea    0x4(%eax),%edx
  800558:	89 55 14             	mov    %edx,0x14(%ebp)
  80055b:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80055d:	85 db                	test   %ebx,%ebx
  80055f:	79 02                	jns    800563 <vprintfmt+0x145>
				err = -err;
  800561:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800563:	83 fb 09             	cmp    $0x9,%ebx
  800566:	7f 0b                	jg     800573 <vprintfmt+0x155>
  800568:	8b 34 9d 20 1d 80 00 	mov    0x801d20(,%ebx,4),%esi
  80056f:	85 f6                	test   %esi,%esi
  800571:	75 23                	jne    800596 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800573:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800577:	c7 44 24 08 59 1d 80 	movl   $0x801d59,0x8(%esp)
  80057e:	00 
  80057f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800582:	89 44 24 04          	mov    %eax,0x4(%esp)
  800586:	8b 45 08             	mov    0x8(%ebp),%eax
  800589:	89 04 24             	mov    %eax,(%esp)
  80058c:	e8 ac 02 00 00       	call   80083d <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800591:	e9 9a 02 00 00       	jmp    800830 <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800596:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80059a:	c7 44 24 08 62 1d 80 	movl   $0x801d62,0x8(%esp)
  8005a1:	00 
  8005a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ac:	89 04 24             	mov    %eax,(%esp)
  8005af:	e8 89 02 00 00       	call   80083d <printfmt>
			break;
  8005b4:	e9 77 02 00 00       	jmp    800830 <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8d 50 04             	lea    0x4(%eax),%edx
  8005bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c2:	8b 30                	mov    (%eax),%esi
  8005c4:	85 f6                	test   %esi,%esi
  8005c6:	75 05                	jne    8005cd <vprintfmt+0x1af>
				p = "(null)";
  8005c8:	be 65 1d 80 00       	mov    $0x801d65,%esi
			if (width > 0 && padc != '-')
  8005cd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d1:	7e 37                	jle    80060a <vprintfmt+0x1ec>
  8005d3:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8005d7:	74 31                	je     80060a <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e0:	89 34 24             	mov    %esi,(%esp)
  8005e3:	e8 72 03 00 00       	call   80095a <strnlen>
  8005e8:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8005eb:	eb 17                	jmp    800604 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8005ed:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8005f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005f4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005f8:	89 04 24             	mov    %eax,(%esp)
  8005fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005fe:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800600:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800604:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800608:	7f e3                	jg     8005ed <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060a:	eb 38                	jmp    800644 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  80060c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800610:	74 1f                	je     800631 <vprintfmt+0x213>
  800612:	83 fb 1f             	cmp    $0x1f,%ebx
  800615:	7e 05                	jle    80061c <vprintfmt+0x1fe>
  800617:	83 fb 7e             	cmp    $0x7e,%ebx
  80061a:	7e 15                	jle    800631 <vprintfmt+0x213>
					putch('?', putdat);
  80061c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80061f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800623:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80062a:	8b 45 08             	mov    0x8(%ebp),%eax
  80062d:	ff d0                	call   *%eax
  80062f:	eb 0f                	jmp    800640 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800631:	8b 45 0c             	mov    0xc(%ebp),%eax
  800634:	89 44 24 04          	mov    %eax,0x4(%esp)
  800638:	89 1c 24             	mov    %ebx,(%esp)
  80063b:	8b 45 08             	mov    0x8(%ebp),%eax
  80063e:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800640:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800644:	89 f0                	mov    %esi,%eax
  800646:	8d 70 01             	lea    0x1(%eax),%esi
  800649:	0f b6 00             	movzbl (%eax),%eax
  80064c:	0f be d8             	movsbl %al,%ebx
  80064f:	85 db                	test   %ebx,%ebx
  800651:	74 10                	je     800663 <vprintfmt+0x245>
  800653:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800657:	78 b3                	js     80060c <vprintfmt+0x1ee>
  800659:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80065d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800661:	79 a9                	jns    80060c <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800663:	eb 17                	jmp    80067c <vprintfmt+0x25e>
				putch(' ', putdat);
  800665:	8b 45 0c             	mov    0xc(%ebp),%eax
  800668:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800673:	8b 45 08             	mov    0x8(%ebp),%eax
  800676:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800678:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80067c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800680:	7f e3                	jg     800665 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800682:	e9 a9 01 00 00       	jmp    800830 <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800687:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80068a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068e:	8d 45 14             	lea    0x14(%ebp),%eax
  800691:	89 04 24             	mov    %eax,(%esp)
  800694:	e8 3e fd ff ff       	call   8003d7 <getint>
  800699:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80069c:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  80069f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006a5:	85 d2                	test   %edx,%edx
  8006a7:	79 26                	jns    8006cf <vprintfmt+0x2b1>
				putch('-', putdat);
  8006a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ba:	ff d0                	call   *%eax
				num = -(long long) num;
  8006bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006c2:	f7 d8                	neg    %eax
  8006c4:	83 d2 00             	adc    $0x0,%edx
  8006c7:	f7 da                	neg    %edx
  8006c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006cc:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8006cf:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006d6:	e9 e1 00 00 00       	jmp    8007bc <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006db:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e5:	89 04 24             	mov    %eax,(%esp)
  8006e8:	e8 9b fc ff ff       	call   800388 <getuint>
  8006ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006f0:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8006f3:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006fa:	e9 bd 00 00 00       	jmp    8007bc <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  8006ff:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  800706:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800709:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070d:	8d 45 14             	lea    0x14(%ebp),%eax
  800710:	89 04 24             	mov    %eax,(%esp)
  800713:	e8 70 fc ff ff       	call   800388 <getuint>
  800718:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80071b:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  80071e:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800722:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800725:	89 54 24 18          	mov    %edx,0x18(%esp)
  800729:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80072c:	89 54 24 14          	mov    %edx,0x14(%esp)
  800730:	89 44 24 10          	mov    %eax,0x10(%esp)
  800734:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800737:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80073a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80073e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800742:	8b 45 0c             	mov    0xc(%ebp),%eax
  800745:	89 44 24 04          	mov    %eax,0x4(%esp)
  800749:	8b 45 08             	mov    0x8(%ebp),%eax
  80074c:	89 04 24             	mov    %eax,(%esp)
  80074f:	e8 56 fb ff ff       	call   8002aa <printnum>
			break;
  800754:	e9 d7 00 00 00       	jmp    800830 <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  800759:	8b 45 0c             	mov    0xc(%ebp),%eax
  80075c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800760:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800767:	8b 45 08             	mov    0x8(%ebp),%eax
  80076a:	ff d0                	call   *%eax
			putch('x', putdat);
  80076c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800773:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80077a:	8b 45 08             	mov    0x8(%ebp),%eax
  80077d:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
  800782:	8d 50 04             	lea    0x4(%eax),%edx
  800785:	89 55 14             	mov    %edx,0x14(%ebp)
  800788:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80078a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80078d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800794:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  80079b:	eb 1f                	jmp    8007bc <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80079d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8007a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a4:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a7:	89 04 24             	mov    %eax,(%esp)
  8007aa:	e8 d9 fb ff ff       	call   800388 <getuint>
  8007af:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007b2:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8007b5:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007bc:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8007c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c3:	89 54 24 18          	mov    %edx,0x18(%esp)
  8007c7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007ca:	89 54 24 14          	mov    %edx,0x14(%esp)
  8007ce:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ea:	89 04 24             	mov    %eax,(%esp)
  8007ed:	e8 b8 fa ff ff       	call   8002aa <printnum>
			break;
  8007f2:	eb 3c                	jmp    800830 <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007fb:	89 1c 24             	mov    %ebx,(%esp)
  8007fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800801:	ff d0                	call   *%eax
			break;
  800803:	eb 2b                	jmp    800830 <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800805:	8b 45 0c             	mov    0xc(%ebp),%eax
  800808:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800818:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80081c:	eb 04                	jmp    800822 <vprintfmt+0x404>
  80081e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800822:	8b 45 10             	mov    0x10(%ebp),%eax
  800825:	83 e8 01             	sub    $0x1,%eax
  800828:	0f b6 00             	movzbl (%eax),%eax
  80082b:	3c 25                	cmp    $0x25,%al
  80082d:	75 ef                	jne    80081e <vprintfmt+0x400>
				/* do nothing */;
			break;
  80082f:	90                   	nop
		}
	}
  800830:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800831:	e9 0a fc ff ff       	jmp    800440 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800836:	83 c4 40             	add    $0x40,%esp
  800839:	5b                   	pop    %ebx
  80083a:	5e                   	pop    %esi
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800843:	8d 45 14             	lea    0x14(%ebp),%eax
  800846:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800849:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800850:	8b 45 10             	mov    0x10(%ebp),%eax
  800853:	89 44 24 08          	mov    %eax,0x8(%esp)
  800857:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085e:	8b 45 08             	mov    0x8(%ebp),%eax
  800861:	89 04 24             	mov    %eax,(%esp)
  800864:	e8 b5 fb ff ff       	call   80041e <vprintfmt>
	va_end(ap);
}
  800869:	c9                   	leave  
  80086a:	c3                   	ret    

0080086b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  80086e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800871:	8b 40 08             	mov    0x8(%eax),%eax
  800874:	8d 50 01             	lea    0x1(%eax),%edx
  800877:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087a:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  80087d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800880:	8b 10                	mov    (%eax),%edx
  800882:	8b 45 0c             	mov    0xc(%ebp),%eax
  800885:	8b 40 04             	mov    0x4(%eax),%eax
  800888:	39 c2                	cmp    %eax,%edx
  80088a:	73 12                	jae    80089e <sprintputch+0x33>
		*b->buf++ = ch;
  80088c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088f:	8b 00                	mov    (%eax),%eax
  800891:	8d 48 01             	lea    0x1(%eax),%ecx
  800894:	8b 55 0c             	mov    0xc(%ebp),%edx
  800897:	89 0a                	mov    %ecx,(%edx)
  800899:	8b 55 08             	mov    0x8(%ebp),%edx
  80089c:	88 10                	mov    %dl,(%eax)
}
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008af:	8d 50 ff             	lea    -0x1(%eax),%edx
  8008b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b5:	01 d0                	add    %edx,%eax
  8008b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008c1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8008c5:	74 06                	je     8008cd <vsnprintf+0x2d>
  8008c7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008cb:	7f 07                	jg     8008d4 <vsnprintf+0x34>
		return -E_INVAL;
  8008cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d2:	eb 2a                	jmp    8008fe <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008db:	8b 45 10             	mov    0x10(%ebp),%eax
  8008de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008e2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e9:	c7 04 24 6b 08 80 00 	movl   $0x80086b,(%esp)
  8008f0:	e8 29 fb ff ff       	call   80041e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008f8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008fe:	c9                   	leave  
  8008ff:	c3                   	ret    

00800900 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800906:	8d 45 14             	lea    0x14(%ebp),%eax
  800909:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  80090c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80090f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800913:	8b 45 10             	mov    0x10(%ebp),%eax
  800916:	89 44 24 08          	mov    %eax,0x8(%esp)
  80091a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	89 04 24             	mov    %eax,(%esp)
  800927:	e8 74 ff ff ff       	call   8008a0 <vsnprintf>
  80092c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  80092f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800932:	c9                   	leave  
  800933:	c3                   	ret    

00800934 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  80093a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800941:	eb 08                	jmp    80094b <strlen+0x17>
		n++;
  800943:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800947:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	0f b6 00             	movzbl (%eax),%eax
  800951:	84 c0                	test   %al,%al
  800953:	75 ee                	jne    800943 <strlen+0xf>
		n++;
	return n;
  800955:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800958:	c9                   	leave  
  800959:	c3                   	ret    

0080095a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800960:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800967:	eb 0c                	jmp    800975 <strnlen+0x1b>
		n++;
  800969:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80096d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800971:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800975:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800979:	74 0a                	je     800985 <strnlen+0x2b>
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	0f b6 00             	movzbl (%eax),%eax
  800981:	84 c0                	test   %al,%al
  800983:	75 e4                	jne    800969 <strnlen+0xf>
		n++;
	return n;
  800985:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800988:	c9                   	leave  
  800989:	c3                   	ret    

0080098a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800996:	90                   	nop
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8d 50 01             	lea    0x1(%eax),%edx
  80099d:	89 55 08             	mov    %edx,0x8(%ebp)
  8009a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009a6:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009a9:	0f b6 12             	movzbl (%edx),%edx
  8009ac:	88 10                	mov    %dl,(%eax)
  8009ae:	0f b6 00             	movzbl (%eax),%eax
  8009b1:	84 c0                	test   %al,%al
  8009b3:	75 e2                	jne    800997 <strcpy+0xd>
		/* do nothing */;
	return ret;
  8009b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009b8:	c9                   	leave  
  8009b9:	c3                   	ret    

008009ba <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	89 04 24             	mov    %eax,(%esp)
  8009c6:	e8 69 ff ff ff       	call   800934 <strlen>
  8009cb:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  8009ce:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8009d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d4:	01 c2                	add    %eax,%edx
  8009d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009dd:	89 14 24             	mov    %edx,(%esp)
  8009e0:	e8 a5 ff ff ff       	call   80098a <strcpy>
	return dst;
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    

008009ea <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f3:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8009f6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009fd:	eb 23                	jmp    800a22 <strncpy+0x38>
		*dst++ = *src;
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800a02:	8d 50 01             	lea    0x1(%eax),%edx
  800a05:	89 55 08             	mov    %edx,0x8(%ebp)
  800a08:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0b:	0f b6 12             	movzbl (%edx),%edx
  800a0e:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800a10:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a13:	0f b6 00             	movzbl (%eax),%eax
  800a16:	84 c0                	test   %al,%al
  800a18:	74 04                	je     800a1e <strncpy+0x34>
			src++;
  800a1a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a1e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800a22:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a25:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a28:	72 d5                	jb     8009ff <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800a2a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800a2d:	c9                   	leave  
  800a2e:	c3                   	ret    

00800a2f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800a35:	8b 45 08             	mov    0x8(%ebp),%eax
  800a38:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800a3b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a3f:	74 33                	je     800a74 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800a41:	eb 17                	jmp    800a5a <strlcpy+0x2b>
			*dst++ = *src++;
  800a43:	8b 45 08             	mov    0x8(%ebp),%eax
  800a46:	8d 50 01             	lea    0x1(%eax),%edx
  800a49:	89 55 08             	mov    %edx,0x8(%ebp)
  800a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a52:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a55:	0f b6 12             	movzbl (%edx),%edx
  800a58:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a5a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a5e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a62:	74 0a                	je     800a6e <strlcpy+0x3f>
  800a64:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a67:	0f b6 00             	movzbl (%eax),%eax
  800a6a:	84 c0                	test   %al,%al
  800a6c:	75 d5                	jne    800a43 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a71:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a74:	8b 55 08             	mov    0x8(%ebp),%edx
  800a77:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a7a:	29 c2                	sub    %eax,%edx
  800a7c:	89 d0                	mov    %edx,%eax
}
  800a7e:	c9                   	leave  
  800a7f:	c3                   	ret    

00800a80 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a83:	eb 08                	jmp    800a8d <strcmp+0xd>
		p++, q++;
  800a85:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a89:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	0f b6 00             	movzbl (%eax),%eax
  800a93:	84 c0                	test   %al,%al
  800a95:	74 10                	je     800aa7 <strcmp+0x27>
  800a97:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9a:	0f b6 10             	movzbl (%eax),%edx
  800a9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa0:	0f b6 00             	movzbl (%eax),%eax
  800aa3:	38 c2                	cmp    %al,%dl
  800aa5:	74 de                	je     800a85 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	0f b6 00             	movzbl (%eax),%eax
  800aad:	0f b6 d0             	movzbl %al,%edx
  800ab0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab3:	0f b6 00             	movzbl (%eax),%eax
  800ab6:	0f b6 c0             	movzbl %al,%eax
  800ab9:	29 c2                	sub    %eax,%edx
  800abb:	89 d0                	mov    %edx,%eax
}
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800ac2:	eb 0c                	jmp    800ad0 <strncmp+0x11>
		n--, p++, q++;
  800ac4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ac8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800acc:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ad0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ad4:	74 1a                	je     800af0 <strncmp+0x31>
  800ad6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad9:	0f b6 00             	movzbl (%eax),%eax
  800adc:	84 c0                	test   %al,%al
  800ade:	74 10                	je     800af0 <strncmp+0x31>
  800ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae3:	0f b6 10             	movzbl (%eax),%edx
  800ae6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae9:	0f b6 00             	movzbl (%eax),%eax
  800aec:	38 c2                	cmp    %al,%dl
  800aee:	74 d4                	je     800ac4 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800af0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800af4:	75 07                	jne    800afd <strncmp+0x3e>
		return 0;
  800af6:	b8 00 00 00 00       	mov    $0x0,%eax
  800afb:	eb 16                	jmp    800b13 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800afd:	8b 45 08             	mov    0x8(%ebp),%eax
  800b00:	0f b6 00             	movzbl (%eax),%eax
  800b03:	0f b6 d0             	movzbl %al,%edx
  800b06:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b09:	0f b6 00             	movzbl (%eax),%eax
  800b0c:	0f b6 c0             	movzbl %al,%eax
  800b0f:	29 c2                	sub    %eax,%edx
  800b11:	89 d0                	mov    %edx,%eax
}
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	83 ec 04             	sub    $0x4,%esp
  800b1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1e:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b21:	eb 14                	jmp    800b37 <strchr+0x22>
		if (*s == c)
  800b23:	8b 45 08             	mov    0x8(%ebp),%eax
  800b26:	0f b6 00             	movzbl (%eax),%eax
  800b29:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b2c:	75 05                	jne    800b33 <strchr+0x1e>
			return (char *) s;
  800b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b31:	eb 13                	jmp    800b46 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b33:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b37:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3a:	0f b6 00             	movzbl (%eax),%eax
  800b3d:	84 c0                	test   %al,%al
  800b3f:	75 e2                	jne    800b23 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800b41:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b46:	c9                   	leave  
  800b47:	c3                   	ret    

00800b48 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	83 ec 04             	sub    $0x4,%esp
  800b4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b51:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b54:	eb 11                	jmp    800b67 <strfind+0x1f>
		if (*s == c)
  800b56:	8b 45 08             	mov    0x8(%ebp),%eax
  800b59:	0f b6 00             	movzbl (%eax),%eax
  800b5c:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b5f:	75 02                	jne    800b63 <strfind+0x1b>
			break;
  800b61:	eb 0e                	jmp    800b71 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b63:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b67:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6a:	0f b6 00             	movzbl (%eax),%eax
  800b6d:	84 c0                	test   %al,%al
  800b6f:	75 e5                	jne    800b56 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800b71:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b74:	c9                   	leave  
  800b75:	c3                   	ret    

00800b76 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
	char *p;

	if (n == 0)
  800b7a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b7e:	75 05                	jne    800b85 <memset+0xf>
		return v;
  800b80:	8b 45 08             	mov    0x8(%ebp),%eax
  800b83:	eb 5c                	jmp    800be1 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800b85:	8b 45 08             	mov    0x8(%ebp),%eax
  800b88:	83 e0 03             	and    $0x3,%eax
  800b8b:	85 c0                	test   %eax,%eax
  800b8d:	75 41                	jne    800bd0 <memset+0x5a>
  800b8f:	8b 45 10             	mov    0x10(%ebp),%eax
  800b92:	83 e0 03             	and    $0x3,%eax
  800b95:	85 c0                	test   %eax,%eax
  800b97:	75 37                	jne    800bd0 <memset+0x5a>
		c &= 0xFF;
  800b99:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ba0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba3:	c1 e0 18             	shl    $0x18,%eax
  800ba6:	89 c2                	mov    %eax,%edx
  800ba8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bab:	c1 e0 10             	shl    $0x10,%eax
  800bae:	09 c2                	or     %eax,%edx
  800bb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb3:	c1 e0 08             	shl    $0x8,%eax
  800bb6:	09 d0                	or     %edx,%eax
  800bb8:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bbb:	8b 45 10             	mov    0x10(%ebp),%eax
  800bbe:	c1 e8 02             	shr    $0x2,%eax
  800bc1:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc9:	89 d7                	mov    %edx,%edi
  800bcb:	fc                   	cld    
  800bcc:	f3 ab                	rep stos %eax,%es:(%edi)
  800bce:	eb 0e                	jmp    800bde <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bd9:	89 d7                	mov    %edx,%edi
  800bdb:	fc                   	cld    
  800bdc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800bde:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
  800bea:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800bed:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf0:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800bf3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf6:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bfc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800bff:	73 6d                	jae    800c6e <memmove+0x8a>
  800c01:	8b 45 10             	mov    0x10(%ebp),%eax
  800c04:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c07:	01 d0                	add    %edx,%eax
  800c09:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800c0c:	76 60                	jbe    800c6e <memmove+0x8a>
		s += n;
  800c0e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c11:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800c14:	8b 45 10             	mov    0x10(%ebp),%eax
  800c17:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c1d:	83 e0 03             	and    $0x3,%eax
  800c20:	85 c0                	test   %eax,%eax
  800c22:	75 2f                	jne    800c53 <memmove+0x6f>
  800c24:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c27:	83 e0 03             	and    $0x3,%eax
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	75 25                	jne    800c53 <memmove+0x6f>
  800c2e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c31:	83 e0 03             	and    $0x3,%eax
  800c34:	85 c0                	test   %eax,%eax
  800c36:	75 1b                	jne    800c53 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c38:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c3b:	83 e8 04             	sub    $0x4,%eax
  800c3e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c41:	83 ea 04             	sub    $0x4,%edx
  800c44:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c47:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c4a:	89 c7                	mov    %eax,%edi
  800c4c:	89 d6                	mov    %edx,%esi
  800c4e:	fd                   	std    
  800c4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c51:	eb 18                	jmp    800c6b <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c53:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c56:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c5c:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c5f:	8b 45 10             	mov    0x10(%ebp),%eax
  800c62:	89 d7                	mov    %edx,%edi
  800c64:	89 de                	mov    %ebx,%esi
  800c66:	89 c1                	mov    %eax,%ecx
  800c68:	fd                   	std    
  800c69:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c6b:	fc                   	cld    
  800c6c:	eb 45                	jmp    800cb3 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c71:	83 e0 03             	and    $0x3,%eax
  800c74:	85 c0                	test   %eax,%eax
  800c76:	75 2b                	jne    800ca3 <memmove+0xbf>
  800c78:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c7b:	83 e0 03             	and    $0x3,%eax
  800c7e:	85 c0                	test   %eax,%eax
  800c80:	75 21                	jne    800ca3 <memmove+0xbf>
  800c82:	8b 45 10             	mov    0x10(%ebp),%eax
  800c85:	83 e0 03             	and    $0x3,%eax
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	75 17                	jne    800ca3 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c8c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c8f:	c1 e8 02             	shr    $0x2,%eax
  800c92:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c94:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c97:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c9a:	89 c7                	mov    %eax,%edi
  800c9c:	89 d6                	mov    %edx,%esi
  800c9e:	fc                   	cld    
  800c9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ca1:	eb 10                	jmp    800cb3 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ca3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ca6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ca9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800cac:	89 c7                	mov    %eax,%edi
  800cae:	89 d6                	mov    %edx,%esi
  800cb0:	fc                   	cld    
  800cb1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800cb3:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cb6:	83 c4 10             	add    $0x10,%esp
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cc4:	8b 45 10             	mov    0x10(%ebp),%eax
  800cc7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ccb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cce:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd5:	89 04 24             	mov    %eax,(%esp)
  800cd8:	e8 07 ff ff ff       	call   800be4 <memmove>
}
  800cdd:	c9                   	leave  
  800cde:	c3                   	ret    

00800cdf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800ce5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce8:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cee:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800cf1:	eb 30                	jmp    800d23 <memcmp+0x44>
		if (*s1 != *s2)
  800cf3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cf6:	0f b6 10             	movzbl (%eax),%edx
  800cf9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800cfc:	0f b6 00             	movzbl (%eax),%eax
  800cff:	38 c2                	cmp    %al,%dl
  800d01:	74 18                	je     800d1b <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800d03:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d06:	0f b6 00             	movzbl (%eax),%eax
  800d09:	0f b6 d0             	movzbl %al,%edx
  800d0c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d0f:	0f b6 00             	movzbl (%eax),%eax
  800d12:	0f b6 c0             	movzbl %al,%eax
  800d15:	29 c2                	sub    %eax,%edx
  800d17:	89 d0                	mov    %edx,%eax
  800d19:	eb 1a                	jmp    800d35 <memcmp+0x56>
		s1++, s2++;
  800d1b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d1f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d23:	8b 45 10             	mov    0x10(%ebp),%eax
  800d26:	8d 50 ff             	lea    -0x1(%eax),%edx
  800d29:	89 55 10             	mov    %edx,0x10(%ebp)
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	75 c3                	jne    800cf3 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d35:	c9                   	leave  
  800d36:	c3                   	ret    

00800d37 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800d3d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	01 d0                	add    %edx,%eax
  800d45:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800d48:	eb 13                	jmp    800d5d <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4d:	0f b6 10             	movzbl (%eax),%edx
  800d50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d53:	38 c2                	cmp    %al,%dl
  800d55:	75 02                	jne    800d59 <memfind+0x22>
			break;
  800d57:	eb 0c                	jmp    800d65 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d59:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d60:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800d63:	72 e5                	jb     800d4a <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800d65:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d68:	c9                   	leave  
  800d69:	c3                   	ret    

00800d6a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800d70:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800d77:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d7e:	eb 04                	jmp    800d84 <strtol+0x1a>
		s++;
  800d80:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d84:	8b 45 08             	mov    0x8(%ebp),%eax
  800d87:	0f b6 00             	movzbl (%eax),%eax
  800d8a:	3c 20                	cmp    $0x20,%al
  800d8c:	74 f2                	je     800d80 <strtol+0x16>
  800d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d91:	0f b6 00             	movzbl (%eax),%eax
  800d94:	3c 09                	cmp    $0x9,%al
  800d96:	74 e8                	je     800d80 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d98:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9b:	0f b6 00             	movzbl (%eax),%eax
  800d9e:	3c 2b                	cmp    $0x2b,%al
  800da0:	75 06                	jne    800da8 <strtol+0x3e>
		s++;
  800da2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800da6:	eb 15                	jmp    800dbd <strtol+0x53>
	else if (*s == '-')
  800da8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dab:	0f b6 00             	movzbl (%eax),%eax
  800dae:	3c 2d                	cmp    $0x2d,%al
  800db0:	75 0b                	jne    800dbd <strtol+0x53>
		s++, neg = 1;
  800db2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800db6:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dbd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dc1:	74 06                	je     800dc9 <strtol+0x5f>
  800dc3:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800dc7:	75 24                	jne    800ded <strtol+0x83>
  800dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcc:	0f b6 00             	movzbl (%eax),%eax
  800dcf:	3c 30                	cmp    $0x30,%al
  800dd1:	75 1a                	jne    800ded <strtol+0x83>
  800dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd6:	83 c0 01             	add    $0x1,%eax
  800dd9:	0f b6 00             	movzbl (%eax),%eax
  800ddc:	3c 78                	cmp    $0x78,%al
  800dde:	75 0d                	jne    800ded <strtol+0x83>
		s += 2, base = 16;
  800de0:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800de4:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800deb:	eb 2a                	jmp    800e17 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800ded:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800df1:	75 17                	jne    800e0a <strtol+0xa0>
  800df3:	8b 45 08             	mov    0x8(%ebp),%eax
  800df6:	0f b6 00             	movzbl (%eax),%eax
  800df9:	3c 30                	cmp    $0x30,%al
  800dfb:	75 0d                	jne    800e0a <strtol+0xa0>
		s++, base = 8;
  800dfd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e01:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800e08:	eb 0d                	jmp    800e17 <strtol+0xad>
	else if (base == 0)
  800e0a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e0e:	75 07                	jne    800e17 <strtol+0xad>
		base = 10;
  800e10:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e17:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1a:	0f b6 00             	movzbl (%eax),%eax
  800e1d:	3c 2f                	cmp    $0x2f,%al
  800e1f:	7e 1b                	jle    800e3c <strtol+0xd2>
  800e21:	8b 45 08             	mov    0x8(%ebp),%eax
  800e24:	0f b6 00             	movzbl (%eax),%eax
  800e27:	3c 39                	cmp    $0x39,%al
  800e29:	7f 11                	jg     800e3c <strtol+0xd2>
			dig = *s - '0';
  800e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2e:	0f b6 00             	movzbl (%eax),%eax
  800e31:	0f be c0             	movsbl %al,%eax
  800e34:	83 e8 30             	sub    $0x30,%eax
  800e37:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e3a:	eb 48                	jmp    800e84 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3f:	0f b6 00             	movzbl (%eax),%eax
  800e42:	3c 60                	cmp    $0x60,%al
  800e44:	7e 1b                	jle    800e61 <strtol+0xf7>
  800e46:	8b 45 08             	mov    0x8(%ebp),%eax
  800e49:	0f b6 00             	movzbl (%eax),%eax
  800e4c:	3c 7a                	cmp    $0x7a,%al
  800e4e:	7f 11                	jg     800e61 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800e50:	8b 45 08             	mov    0x8(%ebp),%eax
  800e53:	0f b6 00             	movzbl (%eax),%eax
  800e56:	0f be c0             	movsbl %al,%eax
  800e59:	83 e8 57             	sub    $0x57,%eax
  800e5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e5f:	eb 23                	jmp    800e84 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800e61:	8b 45 08             	mov    0x8(%ebp),%eax
  800e64:	0f b6 00             	movzbl (%eax),%eax
  800e67:	3c 40                	cmp    $0x40,%al
  800e69:	7e 3d                	jle    800ea8 <strtol+0x13e>
  800e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6e:	0f b6 00             	movzbl (%eax),%eax
  800e71:	3c 5a                	cmp    $0x5a,%al
  800e73:	7f 33                	jg     800ea8 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800e75:	8b 45 08             	mov    0x8(%ebp),%eax
  800e78:	0f b6 00             	movzbl (%eax),%eax
  800e7b:	0f be c0             	movsbl %al,%eax
  800e7e:	83 e8 37             	sub    $0x37,%eax
  800e81:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e87:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e8a:	7c 02                	jl     800e8e <strtol+0x124>
			break;
  800e8c:	eb 1a                	jmp    800ea8 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800e8e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e92:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e95:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e99:	89 c2                	mov    %eax,%edx
  800e9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e9e:	01 d0                	add    %edx,%eax
  800ea0:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800ea3:	e9 6f ff ff ff       	jmp    800e17 <strtol+0xad>

	if (endptr)
  800ea8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800eac:	74 08                	je     800eb6 <strtol+0x14c>
		*endptr = (char *) s;
  800eae:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb4:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800eb6:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800eba:	74 07                	je     800ec3 <strtol+0x159>
  800ebc:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ebf:	f7 d8                	neg    %eax
  800ec1:	eb 03                	jmp    800ec6 <strtol+0x15c>
  800ec3:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800ec6:	c9                   	leave  
  800ec7:	c3                   	ret    

00800ec8 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	57                   	push   %edi
  800ecc:	56                   	push   %esi
  800ecd:	53                   	push   %ebx
  800ece:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed4:	8b 55 10             	mov    0x10(%ebp),%edx
  800ed7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800eda:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800edd:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800ee0:	8b 75 20             	mov    0x20(%ebp),%esi
  800ee3:	cd 30                	int    $0x30
  800ee5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800eec:	74 30                	je     800f1e <syscall+0x56>
  800eee:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ef2:	7e 2a                	jle    800f1e <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ef7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800efb:	8b 45 08             	mov    0x8(%ebp),%eax
  800efe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f02:	c7 44 24 08 c4 1e 80 	movl   $0x801ec4,0x8(%esp)
  800f09:	00 
  800f0a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f11:	00 
  800f12:	c7 04 24 e1 1e 80 00 	movl   $0x801ee1,(%esp)
  800f19:	e8 75 09 00 00       	call   801893 <_panic>

	return ret;
  800f1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800f21:	83 c4 3c             	add    $0x3c,%esp
  800f24:	5b                   	pop    %ebx
  800f25:	5e                   	pop    %esi
  800f26:	5f                   	pop    %edi
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    

00800f29 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800f2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f32:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f39:	00 
  800f3a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f41:	00 
  800f42:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f49:	00 
  800f4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f4d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f51:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f55:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f5c:	00 
  800f5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f64:	e8 5f ff ff ff       	call   800ec8 <syscall>
}
  800f69:	c9                   	leave  
  800f6a:	c3                   	ret    

00800f6b <sys_cgetc>:

int
sys_cgetc(void)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f71:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f78:	00 
  800f79:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f80:	00 
  800f81:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f88:	00 
  800f89:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f90:	00 
  800f91:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f98:	00 
  800f99:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fa0:	00 
  800fa1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800fa8:	e8 1b ff ff ff       	call   800ec8 <syscall>
}
  800fad:	c9                   	leave  
  800fae:	c3                   	ret    

00800faf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800fb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb8:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fbf:	00 
  800fc0:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fc7:	00 
  800fc8:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fcf:	00 
  800fd0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fd7:	00 
  800fd8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fdc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fe3:	00 
  800fe4:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800feb:	e8 d8 fe ff ff       	call   800ec8 <syscall>
}
  800ff0:	c9                   	leave  
  800ff1:	c3                   	ret    

00800ff2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800ff8:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fff:	00 
  801000:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801007:	00 
  801008:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80100f:	00 
  801010:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801017:	00 
  801018:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80101f:	00 
  801020:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801027:	00 
  801028:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80102f:	e8 94 fe ff ff       	call   800ec8 <syscall>
}
  801034:	c9                   	leave  
  801035:	c3                   	ret    

00801036 <sys_yield>:

void
sys_yield(void)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80103c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801043:	00 
  801044:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80104b:	00 
  80104c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801053:	00 
  801054:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80105b:	00 
  80105c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801063:	00 
  801064:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80106b:	00 
  80106c:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  801073:	e8 50 fe ff ff       	call   800ec8 <syscall>
}
  801078:	c9                   	leave  
  801079:	c3                   	ret    

0080107a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801080:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801083:	8b 55 0c             	mov    0xc(%ebp),%edx
  801086:	8b 45 08             	mov    0x8(%ebp),%eax
  801089:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801090:	00 
  801091:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801098:	00 
  801099:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80109d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010ac:	00 
  8010ad:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  8010b4:	e8 0f fe ff ff       	call   800ec8 <syscall>
}
  8010b9:	c9                   	leave  
  8010ba:	c3                   	ret    

008010bb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	56                   	push   %esi
  8010bf:	53                   	push   %ebx
  8010c0:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8010c3:	8b 75 18             	mov    0x18(%ebp),%esi
  8010c6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d2:	89 74 24 18          	mov    %esi,0x18(%esp)
  8010d6:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8010da:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8010de:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010e6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010ed:	00 
  8010ee:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8010f5:	e8 ce fd ff ff       	call   800ec8 <syscall>
}
  8010fa:	83 c4 20             	add    $0x20,%esp
  8010fd:	5b                   	pop    %ebx
  8010fe:	5e                   	pop    %esi
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801107:	8b 55 0c             	mov    0xc(%ebp),%edx
  80110a:	8b 45 08             	mov    0x8(%ebp),%eax
  80110d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801114:	00 
  801115:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80111c:	00 
  80111d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801124:	00 
  801125:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801129:	89 44 24 08          	mov    %eax,0x8(%esp)
  80112d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801134:	00 
  801135:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  80113c:	e8 87 fd ff ff       	call   800ec8 <syscall>
}
  801141:	c9                   	leave  
  801142:	c3                   	ret    

00801143 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801149:	8b 55 0c             	mov    0xc(%ebp),%edx
  80114c:	8b 45 08             	mov    0x8(%ebp),%eax
  80114f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801156:	00 
  801157:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80115e:	00 
  80115f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801166:	00 
  801167:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80116b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80116f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801176:	00 
  801177:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  80117e:	e8 45 fd ff ff       	call   800ec8 <syscall>
}
  801183:	c9                   	leave  
  801184:	c3                   	ret    

00801185 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
  801188:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80118b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118e:	8b 45 08             	mov    0x8(%ebp),%eax
  801191:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801198:	00 
  801199:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011a0:	00 
  8011a1:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011a8:	00 
  8011a9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011b8:	00 
  8011b9:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8011c0:	e8 03 fd ff ff       	call   800ec8 <syscall>
}
  8011c5:	c9                   	leave  
  8011c6:	c3                   	ret    

008011c7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8011cd:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8011d0:	8b 55 10             	mov    0x10(%ebp),%edx
  8011d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011dd:	00 
  8011de:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8011e2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011f8:	00 
  8011f9:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  801200:	e8 c3 fc ff ff       	call   800ec8 <syscall>
}
  801205:	c9                   	leave  
  801206:	c3                   	ret    

00801207 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80120d:	8b 45 08             	mov    0x8(%ebp),%eax
  801210:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801217:	00 
  801218:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80121f:	00 
  801220:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801227:	00 
  801228:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80122f:	00 
  801230:	89 44 24 08          	mov    %eax,0x8(%esp)
  801234:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80123b:	00 
  80123c:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801243:	e8 80 fc ff ff       	call   800ec8 <syscall>
}
  801248:	c9                   	leave  
  801249:	c3                   	ret    

0080124a <pgfault>:
// map in our own private writable copy.
//

static void
pgfault(struct UTrapframe *utf)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  801250:	8b 45 08             	mov    0x8(%ebp),%eax
  801253:	8b 00                	mov    (%eax),%eax
  801255:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  801258:	8b 45 08             	mov    0x8(%ebp),%eax
  80125b:	8b 40 04             	mov    0x4(%eax),%eax
  80125e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	uint32_t t = PGNUM(addr);
  801261:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801264:	c1 e8 0c             	shr    $0xc,%eax
  801267:	89 45 ec             	mov    %eax,-0x14(%ebp)
	pte_t pte = uvpt[t];
  80126a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80126d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801274:	89 45 e8             	mov    %eax,-0x18(%ebp)
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  801277:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127a:	83 e0 02             	and    $0x2,%eax
  80127d:	85 c0                	test   %eax,%eax
  80127f:	74 0c                	je     80128d <pgfault+0x43>
  801281:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801284:	25 00 08 00 00       	and    $0x800,%eax
  801289:	85 c0                	test   %eax,%eax
  80128b:	75 1c                	jne    8012a9 <pgfault+0x5f>
		panic("permission denied in copy on write pgfault handler\n");
  80128d:	c7 44 24 08 f0 1e 80 	movl   $0x801ef0,0x8(%esp)
  801294:	00 
  801295:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80129c:	00 
  80129d:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  8012a4:	e8 ea 05 00 00       	call   801893 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	r = sys_page_alloc(0,PFTEMP,PTE_P|PTE_U|PTE_W);
  8012a9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012b0:	00 
  8012b1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012b8:	00 
  8012b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012c0:	e8 b5 fd ff ff       	call   80107a <sys_page_alloc>
  8012c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if(r < 0)
  8012c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012cc:	79 1c                	jns    8012ea <pgfault+0xa0>
	{
		panic("page cant be allocated\n");
  8012ce:	c7 44 24 08 2f 1f 80 	movl   $0x801f2f,0x8(%esp)
  8012d5:	00 
  8012d6:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8012dd:	00 
  8012de:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  8012e5:	e8 a9 05 00 00       	call   801893 <_panic>
	}
	memmove(PFTEMP, ROUNDDOWN(addr,PGSIZE), PGSIZE);
  8012ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012f8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8012ff:	00 
  801300:	89 44 24 04          	mov    %eax,0x4(%esp)
  801304:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80130b:	e8 d4 f8 ff ff       	call   800be4 <memmove>
	int r1 = sys_page_map(0,PFTEMP,0,ROUNDDOWN(addr,PGSIZE),PTE_W|PTE_U|PTE_P);
  801310:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801313:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801316:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801319:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80131e:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801325:	00 
  801326:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80132a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801331:	00 
  801332:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801339:	00 
  80133a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801341:	e8 75 fd ff ff       	call   8010bb <sys_page_map>
  801346:	89 45 d8             	mov    %eax,-0x28(%ebp)
	if(r1 < 0)
  801349:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80134d:	79 1c                	jns    80136b <pgfault+0x121>
	{
		panic("page cant be mapped\n");
  80134f:	c7 44 24 08 47 1f 80 	movl   $0x801f47,0x8(%esp)
  801356:	00 
  801357:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  80135e:	00 
  80135f:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  801366:	e8 28 05 00 00       	call   801893 <_panic>
	}	

	// panic("pgfault not implemented");
}
  80136b:	c9                   	leave  
  80136c:	c3                   	ret    

0080136d <duppage>:
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
static int
duppage(envid_t envid, unsigned pn)
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	83 ec 48             	sub    $0x48,%esp
	int r;
	
	// LAB 4: Your code here.
	uint32_t t = uvpt[pn];
  801373:	8b 45 0c             	mov    0xc(%ebp),%eax
  801376:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80137d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	void *va_pn = (void *)(pn*PGSIZE);
  801380:	8b 45 0c             	mov    0xc(%ebp),%eax
  801383:	c1 e0 0c             	shl    $0xc,%eax
  801386:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if((t && PTE_W) || (t && PTE_COW))
  801389:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80138d:	75 0a                	jne    801399 <duppage+0x2c>
  80138f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801393:	0f 84 ed 00 00 00    	je     801486 <duppage+0x119>
	{
		r = sys_page_map(0,va_pn,envid,va_pn,PTE_P|PTE_U|PTE_COW);
  801399:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8013a0:	00 
  8013a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013bd:	e8 f9 fc ff ff       	call   8010bb <sys_page_map>
  8013c2:	89 45 e8             	mov    %eax,-0x18(%ebp)
		if(r < 0)
  8013c5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8013c9:	79 1c                	jns    8013e7 <duppage+0x7a>
		{
			panic("error in page map\n");
  8013cb:	c7 44 24 08 5c 1f 80 	movl   $0x801f5c,0x8(%esp)
  8013d2:	00 
  8013d3:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  8013da:	00 
  8013db:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  8013e2:	e8 ac 04 00 00       	call   801893 <_panic>
		}
		int r1 = sys_page_map(envid,va_pn,0,va_pn,PTE_P|PTE_U|PTE_COW);
  8013e7:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8013ee:	00 
  8013ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013f6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013fd:	00 
  8013fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801401:	89 44 24 04          	mov    %eax,0x4(%esp)
  801405:	8b 45 08             	mov    0x8(%ebp),%eax
  801408:	89 04 24             	mov    %eax,(%esp)
  80140b:	e8 ab fc ff ff       	call   8010bb <sys_page_map>
  801410:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if(r1 < 0)
  801413:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801417:	79 1c                	jns    801435 <duppage+0xc8>
		{
			panic("error in page map\n");
  801419:	c7 44 24 08 5c 1f 80 	movl   $0x801f5c,0x8(%esp)
  801420:	00 
  801421:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801428:	00 
  801429:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  801430:	e8 5e 04 00 00       	call   801893 <_panic>
		}
		int r2 = sys_page_map(0,va_pn,0,va_pn,PTE_P|PTE_U|PTE_COW);
  801435:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80143c:	00 
  80143d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801440:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801444:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80144b:	00 
  80144c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801453:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80145a:	e8 5c fc ff ff       	call   8010bb <sys_page_map>
  80145f:	89 45 e0             	mov    %eax,-0x20(%ebp)
		if(r2 < 0)
  801462:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801466:	79 1c                	jns    801484 <duppage+0x117>
		{
			panic("error in page map\n");
  801468:	c7 44 24 08 5c 1f 80 	movl   $0x801f5c,0x8(%esp)
  80146f:	00 
  801470:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  801477:	00 
  801478:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  80147f:	e8 0f 04 00 00       	call   801893 <_panic>
	
	// LAB 4: Your code here.
	uint32_t t = uvpt[pn];
	void *va_pn = (void *)(pn*PGSIZE);
	if((t && PTE_W) || (t && PTE_COW))
	{
  801484:	eb 4e                	jmp    8014d4 <duppage+0x167>
			panic("error in page map\n");
		}
	}
	else
	{
		int r3 = sys_page_map(0,va_pn,envid,va_pn,PTE_U|PTE_P);
  801486:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80148d:	00 
  80148e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801491:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801495:	8b 45 08             	mov    0x8(%ebp),%eax
  801498:	89 44 24 08          	mov    %eax,0x8(%esp)
  80149c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014aa:	e8 0c fc ff ff       	call   8010bb <sys_page_map>
  8014af:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if(r3 < 0)
  8014b2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8014b6:	79 1c                	jns    8014d4 <duppage+0x167>
		{
			panic("error in page map\n");
  8014b8:	c7 44 24 08 5c 1f 80 	movl   $0x801f5c,0x8(%esp)
  8014bf:	00 
  8014c0:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  8014c7:	00 
  8014c8:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  8014cf:	e8 bf 03 00 00       	call   801893 <_panic>
		}
	}
	// panic("duppage not implemented");
	return 0;
  8014d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d9:	c9                   	leave  
  8014da:	c3                   	ret    

008014db <fork>:


envid_t
fork(void)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	83 ec 38             	sub    $0x38,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8014e1:	c7 04 24 4a 12 80 00 	movl   $0x80124a,(%esp)
  8014e8:	e8 01 04 00 00       	call   8018ee <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8014ed:	b8 07 00 00 00       	mov    $0x7,%eax
  8014f2:	cd 30                	int    $0x30
  8014f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  8014f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
	envid_t envid = sys_exofork();
  8014fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (envid < 0)
  8014fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801501:	79 1c                	jns    80151f <fork+0x44>
	{
		panic("sys_exofork not succeeded\n");
  801503:	c7 44 24 08 6f 1f 80 	movl   $0x801f6f,0x8(%esp)
  80150a:	00 
  80150b:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
  801512:	00 
  801513:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  80151a:	e8 74 03 00 00       	call   801893 <_panic>
	}
	if (envid == 0)
  80151f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801523:	75 29                	jne    80154e <fork+0x73>
	{	
		thisenv = &envs[ENVX(sys_getenvid())];
  801525:	e8 c8 fa ff ff       	call   800ff2 <sys_getenvid>
  80152a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80152f:	c1 e0 02             	shl    $0x2,%eax
  801532:	89 c2                	mov    %eax,%edx
  801534:	c1 e2 05             	shl    $0x5,%edx
  801537:	29 c2                	sub    %eax,%edx
  801539:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  80153f:	a3 08 30 80 00       	mov    %eax,0x803008
		return 0;
  801544:	b8 00 00 00 00       	mov    $0x0,%eax
  801549:	e9 2b 01 00 00       	jmp    801679 <fork+0x19e>
	}
	else
	{
		int p;
		for (p = 0; p < PGNUM(UTOP); p++) 
  80154e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  801555:	e9 9a 00 00 00       	jmp    8015f4 <fork+0x119>
		{
			if(p == PGNUM(UTOP) - 1)
  80155a:	81 7d f4 ff eb 0e 00 	cmpl   $0xeebff,-0xc(%ebp)
  801561:	75 42                	jne    8015a5 <fork+0xca>
			{
				int r1 = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE), PTE_P|PTE_W|PTE_U);
  801563:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80156a:	00 
  80156b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801572:	ee 
  801573:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801576:	89 04 24             	mov    %eax,(%esp)
  801579:	e8 fc fa ff ff       	call   80107a <sys_page_alloc>
  80157e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  				if(r1 < 0)
  801581:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801585:	79 1c                	jns    8015a3 <fork+0xc8>
  				{
    				panic("sys_page_alloc failed\n");
  801587:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  80158e:	00 
  80158f:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801596:	00 
  801597:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  80159e:	e8 f0 02 00 00       	call   801893 <_panic>
				}
				break;
  8015a3:	eb 5d                	jmp    801602 <fork+0x127>
			}
			if((uvpd[PDX(p*PGSIZE)]&PTE_P))
  8015a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a8:	c1 e0 0c             	shl    $0xc,%eax
  8015ab:	c1 e8 16             	shr    $0x16,%eax
  8015ae:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015b5:	83 e0 01             	and    $0x1,%eax
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	74 34                	je     8015f0 <fork+0x115>
			{
				if((uvpt[p]&PTE_P) && (uvpt[p] & PTE_U))
  8015bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015bf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015c6:	83 e0 01             	and    $0x1,%eax
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	74 23                	je     8015f0 <fork+0x115>
  8015cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015d7:	83 e0 04             	and    $0x4,%eax
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	74 12                	je     8015f0 <fork+0x115>
				{
					duppage(envid, p);
  8015de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e8:	89 04 24             	mov    %eax,(%esp)
  8015eb:	e8 7d fd ff ff       	call   80136d <duppage>
		return 0;
	}
	else
	{
		int p;
		for (p = 0; p < PGNUM(UTOP); p++) 
  8015f0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  8015f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f7:	3d ff eb 0e 00       	cmp    $0xeebff,%eax
  8015fc:	0f 86 58 ff ff ff    	jbe    80155a <fork+0x7f>
				}
			}	
		}
  		
		extern void _pgfault_upcall();
		int r = sys_env_set_pgfault_upcall(envid,thisenv->env_pgfault_upcall);
  801602:	a1 08 30 80 00       	mov    0x803008,%eax
  801607:	8b 40 64             	mov    0x64(%eax),%eax
  80160a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801611:	89 04 24             	mov    %eax,(%esp)
  801614:	e8 6c fb ff ff       	call   801185 <sys_env_set_pgfault_upcall>
  801619:	89 45 e8             	mov    %eax,-0x18(%ebp)
    	if(r < 0)
  80161c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801620:	79 1c                	jns    80163e <fork+0x163>
    	{
    		panic("sys_env_set_pgfault_upcall failed\n");
  801622:	c7 44 24 08 a4 1f 80 	movl   $0x801fa4,0x8(%esp)
  801629:	00 
  80162a:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  801631:	00 
  801632:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  801639:	e8 55 02 00 00       	call   801893 <_panic>
    	}
  		int r2 = sys_env_set_status(envid, ENV_RUNNABLE);
  80163e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801645:	00 
  801646:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801649:	89 04 24             	mov    %eax,(%esp)
  80164c:	e8 f2 fa ff ff       	call   801143 <sys_env_set_status>
  801651:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  		if(r2 < 0)
  801654:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801658:	79 1c                	jns    801676 <fork+0x19b>
  		{
    		panic("sys_env_set_status failes\n");
  80165a:	c7 44 24 08 c7 1f 80 	movl   $0x801fc7,0x8(%esp)
  801661:	00 
  801662:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  801669:	00 
  80166a:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  801671:	e8 1d 02 00 00       	call   801893 <_panic>
    	}
  		return envid;
  801676:	8b 45 f0             	mov    -0x10(%ebp),%eax
	}


	// panic("fork not implemented");
}
  801679:	c9                   	leave  
  80167a:	c3                   	ret    

0080167b <sfork>:


// Challenge!
int
sfork(void)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801681:	c7 44 24 08 e2 1f 80 	movl   $0x801fe2,0x8(%esp)
  801688:	00 
  801689:	c7 44 24 04 a8 00 00 	movl   $0xa8,0x4(%esp)
  801690:	00 
  801691:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  801698:	e8 f6 01 00 00       	call   801893 <_panic>

0080169d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int r;
	if(pg != NULL)
  8016a3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8016a7:	74 10                	je     8016b9 <ipc_recv+0x1c>
	{
		r = sys_ipc_recv(pg);
  8016a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016ac:	89 04 24             	mov    %eax,(%esp)
  8016af:	e8 53 fb ff ff       	call   801207 <sys_ipc_recv>
  8016b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8016b7:	eb 0f                	jmp    8016c8 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  8016b9:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8016c0:	e8 42 fb ff ff       	call   801207 <sys_ipc_recv>
  8016c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}

	if(from_env_store != NULL && r == 0) 
  8016c8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8016cc:	74 13                	je     8016e1 <ipc_recv+0x44>
  8016ce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8016d2:	75 0d                	jne    8016e1 <ipc_recv+0x44>
	{
		*from_env_store = thisenv->env_ipc_from;
  8016d4:	a1 08 30 80 00       	mov    0x803008,%eax
  8016d9:	8b 50 74             	mov    0x74(%eax),%edx
  8016dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016df:	89 10                	mov    %edx,(%eax)
	}
	if(from_env_store != NULL && r < 0)
  8016e1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8016e5:	74 0f                	je     8016f6 <ipc_recv+0x59>
  8016e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8016eb:	79 09                	jns    8016f6 <ipc_recv+0x59>
	{
		*from_env_store = 0;
  8016ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}

	if(perm_store != NULL)
  8016f6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8016fa:	74 28                	je     801724 <ipc_recv+0x87>
	{
		if(r==0 && (uint32_t)pg<UTOP)
  8016fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801700:	75 19                	jne    80171b <ipc_recv+0x7e>
  801702:	8b 45 0c             	mov    0xc(%ebp),%eax
  801705:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
  80170a:	77 0f                	ja     80171b <ipc_recv+0x7e>
		{
			*perm_store = thisenv->env_ipc_perm;
  80170c:	a1 08 30 80 00       	mov    0x803008,%eax
  801711:	8b 50 78             	mov    0x78(%eax),%edx
  801714:	8b 45 10             	mov    0x10(%ebp),%eax
  801717:	89 10                	mov    %edx,(%eax)
  801719:	eb 09                	jmp    801724 <ipc_recv+0x87>
		}
		else
		{
			*perm_store = 0;
  80171b:	8b 45 10             	mov    0x10(%ebp),%eax
  80171e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		}
	}
	if (r == 0)
  801724:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801728:	75 0a                	jne    801734 <ipc_recv+0x97>
	{
    	return thisenv->env_ipc_value;
  80172a:	a1 08 30 80 00       	mov    0x803008,%eax
  80172f:	8b 40 70             	mov    0x70(%eax),%eax
  801732:	eb 03                	jmp    801737 <ipc_recv+0x9a>
    } 
  	else
  	{
    	return r;
  801734:	8b 45 f4             	mov    -0xc(%ebp),%eax
    }
	// panic("ipc_recv not implemented");
	// return 0;
}
  801737:	c9                   	leave  
  801738:	c3                   	ret    

00801739 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int r;
	if(pg == NULL)
  80173f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801743:	75 4c                	jne    801791 <ipc_send+0x58>
	{
		r = sys_ipc_try_send(to_env,val,(void *)UTOP, perm);
  801745:	8b 45 14             	mov    0x14(%ebp),%eax
  801748:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80174c:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801753:	ee 
  801754:	8b 45 0c             	mov    0xc(%ebp),%eax
  801757:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175b:	8b 45 08             	mov    0x8(%ebp),%eax
  80175e:	89 04 24             	mov    %eax,(%esp)
  801761:	e8 61 fa ff ff       	call   8011c7 <sys_ipc_try_send>
  801766:	89 45 f4             	mov    %eax,-0xc(%ebp)
    	if (r != 0 && r != -E_IPC_NOT_RECV)
  801769:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80176d:	74 6e                	je     8017dd <ipc_send+0xa4>
  80176f:	83 7d f4 f8          	cmpl   $0xfffffff8,-0xc(%ebp)
  801773:	74 68                	je     8017dd <ipc_send+0xa4>
    	{
    		panic("in ipc_send\n");
  801775:	c7 44 24 08 f8 1f 80 	movl   $0x801ff8,0x8(%esp)
  80177c:	00 
  80177d:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  801784:	00 
  801785:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  80178c:	e8 02 01 00 00       	call   801893 <_panic>
    	} 
	}
	else
	{
		r = sys_ipc_try_send(to_env,val,(void *)UTOP, perm);
  801791:	8b 45 14             	mov    0x14(%ebp),%eax
  801794:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801798:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80179f:	ee 
  8017a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017aa:	89 04 24             	mov    %eax,(%esp)
  8017ad:	e8 15 fa ff ff       	call   8011c7 <sys_ipc_try_send>
  8017b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    	if (r != 0 && r != -E_IPC_NOT_RECV)
  8017b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8017b9:	74 22                	je     8017dd <ipc_send+0xa4>
  8017bb:	83 7d f4 f8          	cmpl   $0xfffffff8,-0xc(%ebp)
  8017bf:	74 1c                	je     8017dd <ipc_send+0xa4>
    	{
    		panic("in ipc_send\n");
  8017c1:	c7 44 24 08 f8 1f 80 	movl   $0x801ff8,0x8(%esp)
  8017c8:	00 
  8017c9:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
  8017d0:	00 
  8017d1:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  8017d8:	e8 b6 00 00 00       	call   801893 <_panic>
    	}	
	}
	while(r != 0)
  8017dd:	eb 58                	jmp    801837 <ipc_send+0xfe>
    //cprintf("[%x]ipc_send\n", thisenv->env_id);
	{
    	r = sys_ipc_try_send(to_env, val, pg ? pg : (void*)UTOP, perm);
  8017df:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017e3:	74 05                	je     8017ea <ipc_send+0xb1>
  8017e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8017e8:	eb 05                	jmp    8017ef <ipc_send+0xb6>
  8017ea:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8017ef:	8b 55 14             	mov    0x14(%ebp),%edx
  8017f2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8017f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801801:	8b 45 08             	mov    0x8(%ebp),%eax
  801804:	89 04 24             	mov    %eax,(%esp)
  801807:	e8 bb f9 ff ff       	call   8011c7 <sys_ipc_try_send>
  80180c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    	if (r != 0 && r != -E_IPC_NOT_RECV) 
  80180f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801813:	74 22                	je     801837 <ipc_send+0xfe>
  801815:	83 7d f4 f8          	cmpl   $0xfffffff8,-0xc(%ebp)
  801819:	74 1c                	je     801837 <ipc_send+0xfe>
    	{
      		panic("in ipc_send\n");
  80181b:	c7 44 24 08 f8 1f 80 	movl   $0x801ff8,0x8(%esp)
  801822:	00 
  801823:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  80182a:	00 
  80182b:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  801832:	e8 5c 00 00 00       	call   801893 <_panic>
    	if (r != 0 && r != -E_IPC_NOT_RECV)
    	{
    		panic("in ipc_send\n");
    	}	
	}
	while(r != 0)
  801837:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80183b:	75 a2                	jne    8017df <ipc_send+0xa6>
    	{
      		panic("in ipc_send\n");
    	}
    } 
	// panic("ipc_send not implemented");
}
  80183d:	c9                   	leave  
  80183e:	c3                   	ret    

0080183f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	83 ec 10             	sub    $0x10,%esp
	int i;
	for (i = 0; i < NENV; i++)
  801845:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80184c:	eb 35                	jmp    801883 <ipc_find_env+0x44>
		if (envs[i].env_type == type)
  80184e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801851:	c1 e0 02             	shl    $0x2,%eax
  801854:	89 c2                	mov    %eax,%edx
  801856:	c1 e2 05             	shl    $0x5,%edx
  801859:	29 c2                	sub    %eax,%edx
  80185b:	8d 82 50 00 c0 ee    	lea    -0x113fffb0(%edx),%eax
  801861:	8b 00                	mov    (%eax),%eax
  801863:	3b 45 08             	cmp    0x8(%ebp),%eax
  801866:	75 17                	jne    80187f <ipc_find_env+0x40>
			return envs[i].env_id;
  801868:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80186b:	c1 e0 02             	shl    $0x2,%eax
  80186e:	89 c2                	mov    %eax,%edx
  801870:	c1 e2 05             	shl    $0x5,%edx
  801873:	29 c2                	sub    %eax,%edx
  801875:	8d 82 48 00 c0 ee    	lea    -0x113fffb8(%edx),%eax
  80187b:	8b 00                	mov    (%eax),%eax
  80187d:	eb 12                	jmp    801891 <ipc_find_env+0x52>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80187f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  801883:	81 7d fc ff 03 00 00 	cmpl   $0x3ff,-0x4(%ebp)
  80188a:	7e c2                	jle    80184e <ipc_find_env+0xf>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80188c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801891:	c9                   	leave  
  801892:	c3                   	ret    

00801893 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	53                   	push   %ebx
  801897:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80189a:	8d 45 14             	lea    0x14(%ebp),%eax
  80189d:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8018a0:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8018a6:	e8 47 f7 ff ff       	call   800ff2 <sys_getenvid>
  8018ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ae:	89 54 24 10          	mov    %edx,0x10(%esp)
  8018b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8018b5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8018b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c1:	c7 04 24 10 20 80 00 	movl   $0x802010,(%esp)
  8018c8:	e8 b7 e9 ff ff       	call   800284 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8018cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8018d7:	89 04 24             	mov    %eax,(%esp)
  8018da:	e8 41 e9 ff ff       	call   800220 <vcprintf>
	cprintf("\n");
  8018df:	c7 04 24 33 20 80 00 	movl   $0x802033,(%esp)
  8018e6:	e8 99 e9 ff ff       	call   800284 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8018eb:	cc                   	int3   
  8018ec:	eb fd                	jmp    8018eb <_panic+0x58>

008018ee <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8018ee:	55                   	push   %ebp
  8018ef:	89 e5                	mov    %esp,%ebp
  8018f1:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  8018f4:	a1 0c 30 80 00       	mov    0x80300c,%eax
  8018f9:	85 c0                	test   %eax,%eax
  8018fb:	75 55                	jne    801952 <set_pgfault_handler+0x64>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE),PTE_U|PTE_P|PTE_W);
  8018fd:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801904:	00 
  801905:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80190c:	ee 
  80190d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801914:	e8 61 f7 ff ff       	call   80107a <sys_page_alloc>
  801919:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(r < 0)
  80191c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801920:	79 1c                	jns    80193e <set_pgfault_handler+0x50>
		{
			panic("sys_page_alloc_failed");
  801922:	c7 44 24 08 35 20 80 	movl   $0x802035,0x8(%esp)
  801929:	00 
  80192a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801931:	00 
  801932:	c7 04 24 4b 20 80 00 	movl   $0x80204b,(%esp)
  801939:	e8 55 ff ff ff       	call   801893 <_panic>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80193e:	c7 44 24 04 5c 19 80 	movl   $0x80195c,0x4(%esp)
  801945:	00 
  801946:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80194d:	e8 33 f8 ff ff       	call   801185 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801952:	8b 45 08             	mov    0x8(%ebp),%eax
  801955:	a3 0c 30 80 00       	mov    %eax,0x80300c
}
  80195a:	c9                   	leave  
  80195b:	c3                   	ret    

0080195c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80195c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80195d:	a1 0c 30 80 00       	mov    0x80300c,%eax
	call *%eax
  801962:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801964:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x30(%esp), %eax
  801967:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  80196b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80196e:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 0x28(%esp), %ecx
  801972:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	movl %ecx, (%eax)
  801976:	89 08                	mov    %ecx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	//add $8, %esp
	popl %edx 
  801978:	5a                   	pop    %edx
	popl %edx
  801979:	5a                   	pop    %edx
	popal
  80197a:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp
  80197b:	83 c4 04             	add    $0x4,%esp
	popf
  80197e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80197f:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801980:	c3                   	ret    
  801981:	66 90                	xchg   %ax,%ax
  801983:	66 90                	xchg   %ax,%ax
  801985:	66 90                	xchg   %ax,%ax
  801987:	66 90                	xchg   %ax,%ax
  801989:	66 90                	xchg   %ax,%ax
  80198b:	66 90                	xchg   %ax,%ax
  80198d:	66 90                	xchg   %ax,%ax
  80198f:	90                   	nop

00801990 <__udivdi3>:
  801990:	55                   	push   %ebp
  801991:	57                   	push   %edi
  801992:	56                   	push   %esi
  801993:	83 ec 0c             	sub    $0xc,%esp
  801996:	8b 44 24 28          	mov    0x28(%esp),%eax
  80199a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80199e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8019a2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8019a6:	85 c0                	test   %eax,%eax
  8019a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019ac:	89 ea                	mov    %ebp,%edx
  8019ae:	89 0c 24             	mov    %ecx,(%esp)
  8019b1:	75 2d                	jne    8019e0 <__udivdi3+0x50>
  8019b3:	39 e9                	cmp    %ebp,%ecx
  8019b5:	77 61                	ja     801a18 <__udivdi3+0x88>
  8019b7:	85 c9                	test   %ecx,%ecx
  8019b9:	89 ce                	mov    %ecx,%esi
  8019bb:	75 0b                	jne    8019c8 <__udivdi3+0x38>
  8019bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8019c2:	31 d2                	xor    %edx,%edx
  8019c4:	f7 f1                	div    %ecx
  8019c6:	89 c6                	mov    %eax,%esi
  8019c8:	31 d2                	xor    %edx,%edx
  8019ca:	89 e8                	mov    %ebp,%eax
  8019cc:	f7 f6                	div    %esi
  8019ce:	89 c5                	mov    %eax,%ebp
  8019d0:	89 f8                	mov    %edi,%eax
  8019d2:	f7 f6                	div    %esi
  8019d4:	89 ea                	mov    %ebp,%edx
  8019d6:	83 c4 0c             	add    $0xc,%esp
  8019d9:	5e                   	pop    %esi
  8019da:	5f                   	pop    %edi
  8019db:	5d                   	pop    %ebp
  8019dc:	c3                   	ret    
  8019dd:	8d 76 00             	lea    0x0(%esi),%esi
  8019e0:	39 e8                	cmp    %ebp,%eax
  8019e2:	77 24                	ja     801a08 <__udivdi3+0x78>
  8019e4:	0f bd e8             	bsr    %eax,%ebp
  8019e7:	83 f5 1f             	xor    $0x1f,%ebp
  8019ea:	75 3c                	jne    801a28 <__udivdi3+0x98>
  8019ec:	8b 74 24 04          	mov    0x4(%esp),%esi
  8019f0:	39 34 24             	cmp    %esi,(%esp)
  8019f3:	0f 86 9f 00 00 00    	jbe    801a98 <__udivdi3+0x108>
  8019f9:	39 d0                	cmp    %edx,%eax
  8019fb:	0f 82 97 00 00 00    	jb     801a98 <__udivdi3+0x108>
  801a01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801a08:	31 d2                	xor    %edx,%edx
  801a0a:	31 c0                	xor    %eax,%eax
  801a0c:	83 c4 0c             	add    $0xc,%esp
  801a0f:	5e                   	pop    %esi
  801a10:	5f                   	pop    %edi
  801a11:	5d                   	pop    %ebp
  801a12:	c3                   	ret    
  801a13:	90                   	nop
  801a14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a18:	89 f8                	mov    %edi,%eax
  801a1a:	f7 f1                	div    %ecx
  801a1c:	31 d2                	xor    %edx,%edx
  801a1e:	83 c4 0c             	add    $0xc,%esp
  801a21:	5e                   	pop    %esi
  801a22:	5f                   	pop    %edi
  801a23:	5d                   	pop    %ebp
  801a24:	c3                   	ret    
  801a25:	8d 76 00             	lea    0x0(%esi),%esi
  801a28:	89 e9                	mov    %ebp,%ecx
  801a2a:	8b 3c 24             	mov    (%esp),%edi
  801a2d:	d3 e0                	shl    %cl,%eax
  801a2f:	89 c6                	mov    %eax,%esi
  801a31:	b8 20 00 00 00       	mov    $0x20,%eax
  801a36:	29 e8                	sub    %ebp,%eax
  801a38:	89 c1                	mov    %eax,%ecx
  801a3a:	d3 ef                	shr    %cl,%edi
  801a3c:	89 e9                	mov    %ebp,%ecx
  801a3e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801a42:	8b 3c 24             	mov    (%esp),%edi
  801a45:	09 74 24 08          	or     %esi,0x8(%esp)
  801a49:	89 d6                	mov    %edx,%esi
  801a4b:	d3 e7                	shl    %cl,%edi
  801a4d:	89 c1                	mov    %eax,%ecx
  801a4f:	89 3c 24             	mov    %edi,(%esp)
  801a52:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801a56:	d3 ee                	shr    %cl,%esi
  801a58:	89 e9                	mov    %ebp,%ecx
  801a5a:	d3 e2                	shl    %cl,%edx
  801a5c:	89 c1                	mov    %eax,%ecx
  801a5e:	d3 ef                	shr    %cl,%edi
  801a60:	09 d7                	or     %edx,%edi
  801a62:	89 f2                	mov    %esi,%edx
  801a64:	89 f8                	mov    %edi,%eax
  801a66:	f7 74 24 08          	divl   0x8(%esp)
  801a6a:	89 d6                	mov    %edx,%esi
  801a6c:	89 c7                	mov    %eax,%edi
  801a6e:	f7 24 24             	mull   (%esp)
  801a71:	39 d6                	cmp    %edx,%esi
  801a73:	89 14 24             	mov    %edx,(%esp)
  801a76:	72 30                	jb     801aa8 <__udivdi3+0x118>
  801a78:	8b 54 24 04          	mov    0x4(%esp),%edx
  801a7c:	89 e9                	mov    %ebp,%ecx
  801a7e:	d3 e2                	shl    %cl,%edx
  801a80:	39 c2                	cmp    %eax,%edx
  801a82:	73 05                	jae    801a89 <__udivdi3+0xf9>
  801a84:	3b 34 24             	cmp    (%esp),%esi
  801a87:	74 1f                	je     801aa8 <__udivdi3+0x118>
  801a89:	89 f8                	mov    %edi,%eax
  801a8b:	31 d2                	xor    %edx,%edx
  801a8d:	e9 7a ff ff ff       	jmp    801a0c <__udivdi3+0x7c>
  801a92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801a98:	31 d2                	xor    %edx,%edx
  801a9a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a9f:	e9 68 ff ff ff       	jmp    801a0c <__udivdi3+0x7c>
  801aa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801aa8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801aab:	31 d2                	xor    %edx,%edx
  801aad:	83 c4 0c             	add    $0xc,%esp
  801ab0:	5e                   	pop    %esi
  801ab1:	5f                   	pop    %edi
  801ab2:	5d                   	pop    %ebp
  801ab3:	c3                   	ret    
  801ab4:	66 90                	xchg   %ax,%ax
  801ab6:	66 90                	xchg   %ax,%ax
  801ab8:	66 90                	xchg   %ax,%ax
  801aba:	66 90                	xchg   %ax,%ax
  801abc:	66 90                	xchg   %ax,%ax
  801abe:	66 90                	xchg   %ax,%ax

00801ac0 <__umoddi3>:
  801ac0:	55                   	push   %ebp
  801ac1:	57                   	push   %edi
  801ac2:	56                   	push   %esi
  801ac3:	83 ec 14             	sub    $0x14,%esp
  801ac6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801aca:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801ace:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801ad2:	89 c7                	mov    %eax,%edi
  801ad4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad8:	8b 44 24 30          	mov    0x30(%esp),%eax
  801adc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801ae0:	89 34 24             	mov    %esi,(%esp)
  801ae3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	89 c2                	mov    %eax,%edx
  801aeb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801aef:	75 17                	jne    801b08 <__umoddi3+0x48>
  801af1:	39 fe                	cmp    %edi,%esi
  801af3:	76 4b                	jbe    801b40 <__umoddi3+0x80>
  801af5:	89 c8                	mov    %ecx,%eax
  801af7:	89 fa                	mov    %edi,%edx
  801af9:	f7 f6                	div    %esi
  801afb:	89 d0                	mov    %edx,%eax
  801afd:	31 d2                	xor    %edx,%edx
  801aff:	83 c4 14             	add    $0x14,%esp
  801b02:	5e                   	pop    %esi
  801b03:	5f                   	pop    %edi
  801b04:	5d                   	pop    %ebp
  801b05:	c3                   	ret    
  801b06:	66 90                	xchg   %ax,%ax
  801b08:	39 f8                	cmp    %edi,%eax
  801b0a:	77 54                	ja     801b60 <__umoddi3+0xa0>
  801b0c:	0f bd e8             	bsr    %eax,%ebp
  801b0f:	83 f5 1f             	xor    $0x1f,%ebp
  801b12:	75 5c                	jne    801b70 <__umoddi3+0xb0>
  801b14:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801b18:	39 3c 24             	cmp    %edi,(%esp)
  801b1b:	0f 87 e7 00 00 00    	ja     801c08 <__umoddi3+0x148>
  801b21:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801b25:	29 f1                	sub    %esi,%ecx
  801b27:	19 c7                	sbb    %eax,%edi
  801b29:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b2d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b31:	8b 44 24 08          	mov    0x8(%esp),%eax
  801b35:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801b39:	83 c4 14             	add    $0x14,%esp
  801b3c:	5e                   	pop    %esi
  801b3d:	5f                   	pop    %edi
  801b3e:	5d                   	pop    %ebp
  801b3f:	c3                   	ret    
  801b40:	85 f6                	test   %esi,%esi
  801b42:	89 f5                	mov    %esi,%ebp
  801b44:	75 0b                	jne    801b51 <__umoddi3+0x91>
  801b46:	b8 01 00 00 00       	mov    $0x1,%eax
  801b4b:	31 d2                	xor    %edx,%edx
  801b4d:	f7 f6                	div    %esi
  801b4f:	89 c5                	mov    %eax,%ebp
  801b51:	8b 44 24 04          	mov    0x4(%esp),%eax
  801b55:	31 d2                	xor    %edx,%edx
  801b57:	f7 f5                	div    %ebp
  801b59:	89 c8                	mov    %ecx,%eax
  801b5b:	f7 f5                	div    %ebp
  801b5d:	eb 9c                	jmp    801afb <__umoddi3+0x3b>
  801b5f:	90                   	nop
  801b60:	89 c8                	mov    %ecx,%eax
  801b62:	89 fa                	mov    %edi,%edx
  801b64:	83 c4 14             	add    $0x14,%esp
  801b67:	5e                   	pop    %esi
  801b68:	5f                   	pop    %edi
  801b69:	5d                   	pop    %ebp
  801b6a:	c3                   	ret    
  801b6b:	90                   	nop
  801b6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b70:	8b 04 24             	mov    (%esp),%eax
  801b73:	be 20 00 00 00       	mov    $0x20,%esi
  801b78:	89 e9                	mov    %ebp,%ecx
  801b7a:	29 ee                	sub    %ebp,%esi
  801b7c:	d3 e2                	shl    %cl,%edx
  801b7e:	89 f1                	mov    %esi,%ecx
  801b80:	d3 e8                	shr    %cl,%eax
  801b82:	89 e9                	mov    %ebp,%ecx
  801b84:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b88:	8b 04 24             	mov    (%esp),%eax
  801b8b:	09 54 24 04          	or     %edx,0x4(%esp)
  801b8f:	89 fa                	mov    %edi,%edx
  801b91:	d3 e0                	shl    %cl,%eax
  801b93:	89 f1                	mov    %esi,%ecx
  801b95:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b99:	8b 44 24 10          	mov    0x10(%esp),%eax
  801b9d:	d3 ea                	shr    %cl,%edx
  801b9f:	89 e9                	mov    %ebp,%ecx
  801ba1:	d3 e7                	shl    %cl,%edi
  801ba3:	89 f1                	mov    %esi,%ecx
  801ba5:	d3 e8                	shr    %cl,%eax
  801ba7:	89 e9                	mov    %ebp,%ecx
  801ba9:	09 f8                	or     %edi,%eax
  801bab:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801baf:	f7 74 24 04          	divl   0x4(%esp)
  801bb3:	d3 e7                	shl    %cl,%edi
  801bb5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801bb9:	89 d7                	mov    %edx,%edi
  801bbb:	f7 64 24 08          	mull   0x8(%esp)
  801bbf:	39 d7                	cmp    %edx,%edi
  801bc1:	89 c1                	mov    %eax,%ecx
  801bc3:	89 14 24             	mov    %edx,(%esp)
  801bc6:	72 2c                	jb     801bf4 <__umoddi3+0x134>
  801bc8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801bcc:	72 22                	jb     801bf0 <__umoddi3+0x130>
  801bce:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801bd2:	29 c8                	sub    %ecx,%eax
  801bd4:	19 d7                	sbb    %edx,%edi
  801bd6:	89 e9                	mov    %ebp,%ecx
  801bd8:	89 fa                	mov    %edi,%edx
  801bda:	d3 e8                	shr    %cl,%eax
  801bdc:	89 f1                	mov    %esi,%ecx
  801bde:	d3 e2                	shl    %cl,%edx
  801be0:	89 e9                	mov    %ebp,%ecx
  801be2:	d3 ef                	shr    %cl,%edi
  801be4:	09 d0                	or     %edx,%eax
  801be6:	89 fa                	mov    %edi,%edx
  801be8:	83 c4 14             	add    $0x14,%esp
  801beb:	5e                   	pop    %esi
  801bec:	5f                   	pop    %edi
  801bed:	5d                   	pop    %ebp
  801bee:	c3                   	ret    
  801bef:	90                   	nop
  801bf0:	39 d7                	cmp    %edx,%edi
  801bf2:	75 da                	jne    801bce <__umoddi3+0x10e>
  801bf4:	8b 14 24             	mov    (%esp),%edx
  801bf7:	89 c1                	mov    %eax,%ecx
  801bf9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801bfd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801c01:	eb cb                	jmp    801bce <__umoddi3+0x10e>
  801c03:	90                   	nop
  801c04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c08:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801c0c:	0f 82 0f ff ff ff    	jb     801b21 <__umoddi3+0x61>
  801c12:	e9 1a ff ff ff       	jmp    801b31 <__umoddi3+0x71>
